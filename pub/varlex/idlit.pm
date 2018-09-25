#!/usr/bin/perl

# TO READERS OF THIS CODE:

# The code is in 3 parts
#
# 1.) A Perl-oriented preamble
#
# 2.) The Marpa grammars
#
# 3.) Wrappers and event handlers, in Perl.
#
# ===== Part 1: Perl preamble =====

use 5.010;
use strict;
use warnings;

use Marpa::R3 4.001_053;

package MarpaX::R3::Idlit;

use Data::Dumper;
$Data::Dumper::Terse    = 1;
$Data::Dumper::Deepcopy = 1;

use English qw( -no_match_vars );

sub show_last_expression {
    my ($recce, $target) = @_;
    my ( $g1_start, $g1_length ) = $recce->last_completed($target);
    return qq{No "$target" was successfully parsed} if not defined $g1_start;
    my $last_expression = $recce->substring( $g1_start, $g1_length );
    return "Last expression successfully parsed was: $last_expression";
} 

sub divergence {
    die join '', 'Unrecoverable internal error: ', @_;
}

# ===== Part 2: Marpa grammars =====

# Marpa divides symbols into
#
# * those for the context-free grammar (G1 in Marpa terms), whose rules
#   are indicated by the '::=' operator; and
# * those for the lexical grammar (L0 in Marpa terms), whose rules are
#   indicated by the '~' operator.
#
# In Marpa, the lexical grammar(L0)  is also allowed to be fully contest-free.
# For implemenation, Marpa requires those symbols which are the "boundary"
# between G1 and L0 to be specified clearly.  Usually this is done implicitly --
# a symbol which is on a RHS but not a LHS in G1, and which is on a LHS but not
# a RHS in L0, is considered a G1/L0 boundary symbol, or "lexeme".
#
# To specify explicitly what the lexeme are.  This is done
# with the ":lexeme" declarations.  Where a symbol needed to be introduced
# to allow a clean boundary, the new symbol has the prefix "L0_".

my $dsl = <<'END_OF_TOP_DSL';

# This tells Marpa to construct an AST whose nodes consist of the
# symbol name, line,and column; followed a by a list of the child values.
:default ::= action => [name,line,column,values]

# top ::= perlCode luaCode CCode texSource
top ::= perlCode texSource

texSource ::= texBody ( texTrailer )
texTrailer ::= L0_textLine+
texBody ::= texBodyElement*
texBodyElement ::= L0_textLine
texBodyElement ::= L0_texCodeBlock
texBodyElement ::= L0_texCodeOpenBlock

textLines ::= L0_textLine*

:lexeme ~ L0_textline priority => 0
L0_textLine ~ nonNewLines newLine
nonNewLines ~ nonNewLine*
nonNewLine ~ [^\n]
newLine ~ [\n]

perlCode ~ unicorn event => perlCode pause => before priority => 1

:lexeme ~ L0_unicorn
L0_unicorn ~ unicorn
unicorn ~ [^\d\D]
anything ~ anyChar*
anyChar ~ [\d\D]

texCodeBegin ~ '\begin{code}'
texCodeEnd ~ '\end{code}'

:lexeme ~ L0_texCodeBlock priority => 1 eager => 1 event => properBlock pause => after
L0_texCodeBlock ~ texCodeBegin anything newLine texCodeEnd

:lexeme ~ L0_texCodeOpenBlock priority => 1 event => openBlock pause => after
L0_texCodeEnd ~ texCodeEnd
texCodeEnd ~ '\begin{code}' anything

END_OF_TOP_DSL

# ===== Part 4: Wrappers and handlers =====

# The following logic pre-generates all the grammars we
# will need, both for the top level and the combinators.

my $topGrammar = Marpa::R2::Scanless::G->new( { source => \$dsl } );

%main::GRAMMARS = (
    'ruby_x_body'  => ['body'],
    'ruby_x_stmts'  => ['stmts'],
    'ruby_x_decls' => ['decls'],
    'ruby_x_alts'  => ['alts'],
);

# Rather than writing 6 grammars for the combinators, we can
# (mostly) reuse the top-level grammar.  Marpa's ":start"
# pseudo-symbol allows us to override the default start
# symbol.  Changing the start symbol makes a long of symbols
# inaccessible, but the "inaccessible is ok by default"
# statement turns of the warnings for these.

for my $key ( keys %main::GRAMMARS ) {
    my $grammar_data = $main::GRAMMARS{$key};
    my ($start)      = @{$grammar_data};
    my $this_dsl     = ":start ::= $start\n";
    $this_dsl .= "inaccessible is ok by default\n";
    $this_dsl .= $dsl;
    my $this_grammar = Marpa::R2::Scanless::G->new( { source => \$this_dsl } );
    $grammar_data->[1] = $this_grammar;
    my $iKey = $key;
    $iKey =~ s/_x_/_i_/xms;
    $main::GRAMMARS{$iKey} = $grammar_data;

}

local $main::DEBUG = 0;

# This is the top level parse routine.

sub parse {
    my ($inputRef) = @_;
    my ($initialWS) = ${$inputRef} =~ m/ ^ ([\s]*) /xms;
    my $firstLexemeOffset = length $initialWS;

    # Create the recognizer instance.
    # The 'indent' event is turned on or off, depending on whether
    # explicit or implicit layout is in use.

    my $indent_is_active = ($currentIndent >= 0 ? 1 : 0);
    say STDERR "Calling top level parser, indentation = $indent_is_active" if $main::DEBUG;
    my $recce = Marpa::R2::Scanless::R->new(
        {
            grammar   => $topGrammar,
            rejection => 'event',
	    event_is_active => { 'indent' => $indent_is_active },
            trace_terminals => ($main::DEBUG ? 99 : 0),
        }
    );

    # Get the parse value.

    my $value_ref;
    my $result = 'OK';
    my $eval_ok =
      eval { ( $value_ref, undef ) = getValue( $recce, 'module', $inputRef, $firstLexemeOffset, $currentIndent ); 1; };

    if ($main::TRACE_ES) {
      say STDERR qq{Returning from top level parser};
      my $latest_es = $recce->current_g1_location();
      for my $es (0 .. $latest_es) {
	say STDERR "ES = ", $es;
	if ($main::TRACE_ES >= 2) {
	    # These calls are undocumented, and should not be
	    # called in the test suite.
	    my $thick_recce = $recce->thick_g1_recce();
	    say STDERR "Size of ES $es is ", $thick_recce->earley_set_size($es);
	}
	say STDERR $recce->show_progress($es);
      }
    }
    # Return result and parse value

    if ( !$eval_ok ) {
        my $eval_error = $EVAL_ERROR;
	$result = "Error: $EVAL_ERROR";
    }
    return $result, $value_ref;
}

# This handler assumes a recognizer has been created.  Given
# an input, an offset into that input, it reads using that recognizer.
# The return values are the parse value and a new offset in the input.
# Errors are thrown.

sub getValue {
    my ( $recce, $target, $input ) = @_;
    my $input_length = length ${$input};
    my $resume_pos;
    my $this_pos;

    my @values = ();

    # The main read loop.  Read starting at $offset.
    # If interrupted execute the handler logic,
    # and, possibly, resume.

  READ:
    for (
        $this_pos = $recce->read( $input, $offset ) ;
        $this_pos < $input_length ;
        $this_pos = $recce->resume($resume_pos)
      )
    {

        # Only one event at a time is expected -- more
        # than one is an error.  No event means parsing
        # is exhausted.

        my $events      = $recce->events();
        my $event_count = scalar @{$events};
        if ( $event_count < 0 ) {
            last READ;
        }
        if ( $event_count != 1 ) {
            divergence("One event expected, instead got $event_count");
        }

        # Find the event name

        my $event = $events->[0];
        my $name  = $event->[0];

        if ( $name eq 'properBlock' ) {

            my ( undef, $symbolID, $blockID, $offset, $length ) = @{$event};
            my $eoCodeBlock = $offset + $length;
            my $firstNL     = index( ${$input}, "\n" );
            my $lastNL      = rindex( ${$input}, "\n", $eoCodeBlock );

            my ( $line, $column );
            ( $line1, $column1 ) = $recce->line_column( $blockID, $offset );
            ( $line2, $column2 ) = $recce->line_column( $blockID, $firstNL );
            push @values, join '',
              'L', $line1, 'c', $column1,
              '-', 'L', $line2, 'c', $column2,
              ' \begin{code}';

            ( $line1, $column1 ) =
              $recce->line_column( $blockID, $firstNL + 1 );
            ( $line2, $column2 ) = $recce->line_column( $blockID, $lastNL );
            push @values, join '',
              'L', $line1, 'c', $column1,
              '-', 'L', $line2, 'c', $column2,
              ' [CODE]';

            ( $line1, $column1 ) = $recce->line_column( $blockID, $lastNL + 1 );
            ( $line2, $column2 ) =
              $recce->line_column( $blockID, $eoCodeBlock );
            push @values, join '',
              'L', $line1, 'c', $column1,
              '-', 'L', $line2, 'c', $column2,
              ' [CODE]';

            $this_pos = $lastNL;
            last READ;
        }

        if ( $name eq 'openBlock' ) {

            my ( undef, $symbolID, $blockID, $offset, $length ) = @{$event};
            my $eoCodeBlock = $offset + $length;
            my $firstNL     = index( ${$input}, "\n" );

            my @values = ();
            my ( $line, $column );
            ( $line1, $column1 ) = $recce->line_column( $blockID, $offset );
            ( $line2, $column2 ) = $recce->line_column( $blockID, $firstNL );
            push @values, join '',
              'L', $line1, 'c', $column1,
              '-', 'L', $line2, 'c', $column2,
              ' \begin{code}';

            ( $line1, $column1 ) =
              $recce->line_column( $blockID, $firstNL + 1 );
            ( $line2, $column2 ) =
              $recce->line_column( $blockID, $eoCodeBlock );
            push @values, join '',
              'L', $line1, 'c', $column1,
              '-', 'L', $line2, 'c', $column2,
              ' [CODE]';

            $this_pos = $lastNL;
            last READ;
        }

        # Items subject to layout are represented by Ruby Slippers tokens,
        # which are not recognized by the internal lexer.  Therefore they
        # generate rejection events.

        # Errors in the source can also generate "rejected" events.  To
        # become ready for production, this module would need to add better
        # logic for debugging and tracing in those cases.
        if ( $name eq "'rejected" ) {
            my $expected = $recce->terminals_expected();
            return divergence(
                "All tokens rejected, expecting ",
                ( join " ", @{$expected} )
            );
        }

        divergence(qq{Unexpected event: "$name"});
    }

    return [\@values], $this_pos;

    if (0) {
        say STDERR "Left main READ loop" if $main::DEBUG;

        # Return value and new offset

        my $value_ref = $recce->value();
        if ( !$value_ref ) {
            say STDERR $recce->show_progress() if $main::DEBUG;
            divergence(qq{input read, but there was no parse});
        }

        return $value_ref, $this_pos;
    }
}

sub subParse {
    my ( $target, $input, $offset, $currentIndent ) = @_;
    say STDERR qq{Starting combinator for "$target" at $currentIndent}
        if $main::TRACE_ES;
    say STDERR qq{Starting combinator for "$target" at $currentIndent}
        if $main::DEBUG;
    my $grammar_data = $main::GRAMMARS{$target};

    divergence(qq{No grammar for target = "$target"}) if not $grammar_data;
    my ( undef, $subgrammar ) = @{$grammar_data};
    my $indent_is_active = ($currentIndent >= 0 ? 1 : 0);
    my $recce = Marpa::R2::Scanless::R->new(
        {
            grammar         => $subgrammar,
            rejection       => 'event',
	    event_is_active => { 'indent' => $indent_is_active },
            trace_terminals => ($main::DEBUG ? 99 : 0),
        }
    );
    my ( $value_ref, $pos ) = getValue( $recce, $target, $input, $offset, $currentIndent );
    say STDERR qq{Returning from combinator for "$target" at $currentIndent}
        if $main::DEBUG;

    if ($main::TRACE_ES) {
      my $thick_recce = $recce->thick_g1_recce();
      say STDERR qq{Returning from combinator for "$target" at $currentIndent};
      my $latest_es = $thick_recce->latest_earley_set();
      say STDERR "latest ES = ", $latest_es;
      for my $es (0 .. $latest_es) {
	say STDERR "ES $es = ", $thick_recce->earley_set_size($es);
      }
      say STDERR qq{Returning from combinator for "$target" at $currentIndent};
    }

    return $value_ref, $pos;
}

# This utility right now is primarily for testing.  It takes an
# AST and returns one whose nodes more closely match the standard.
# Right now, this makes it easy for test cases, but perhaps this
# could also be the start of a compile/interpretation phase.

# Takes one argument and returns a ref to an array of acceptable
# nodes.  The array may be empty.  All scalars are acceptable
# leaf nodes.  Acceptable interior nodes have length at least 1
# and contain a Haskell Standard symbol name, followed by zero or
# more acceptable nodes.
sub pruneNodes {
    my ($v) = @_;

    state $deleteIfEmpty = {
        # topdecl => 1,
        # decl => 1,
    };

    state $nonStandard = {
        # apats             => 1,
    };

    return [] if not defined $v;
    my $reftype = ref $v;
    return [$v] if not $reftype; # An acceptable leaf node
    return pruneNodes($$v) if $reftype eq 'REF';
    divergence("Tree node has reftype $reftype") if $reftype ne 'ARRAY';
    my @source = grep { defined } @{$v};
    my $element_count = scalar @source;
    return [] if $element_count <= 0; # must have at least one element
    my $name = shift @source;
    my $nameReftype = ref $name;
    # divergence("Tree node name has reftype $nameReftype") if $nameReftype;
    if ($nameReftype) {
      my @result = ();
      ELEMENT:for my $element ($name, @source) {
	if (ref $element eq 'ARRAY') {
	  push @result, grep { defined }
		  map { @{$_}; }
		  map { pruneNodes($_); }
		  @{$element}
		;
	  next ELEMENT;
	}
	push @result, $_;
      }
      return [@result];
    }
    if (defined $deleteIfEmpty->{$name} and $element_count == 1) {
      return [];
    }
    if (defined $nonStandard->{$name}) {
      # Not an acceptable branch node, but (hopefully)
      # its children are acceptable
      return [ grep { defined }
	      map { @{$_}; }
	      map { pruneNodes($_); }
	      @source
	    ];
    }

    # An acceptable branch node
    my @result = ($name);
    push @result, grep { defined }
	    map { @{$_}; }
	    map { pruneNodes($_); }
	    @source;
    return [\@result];
}

1;
