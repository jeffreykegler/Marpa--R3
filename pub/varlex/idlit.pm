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
:default ::= action => [name,start,length,values]

# top ::= perlCode luaCode CCode texSource
top ::= TOP_CCode
top ::= TOP_texSource

TOP_texSource ::= texBody
texBody ::= texBodyElement*
texBodyElement ::= BRICK_texLine
BRICK_texLine ::= L0_texLine
texBodyElement ::= L0_texCodeBlock
texBodyElement ::= L0_texCodeOpenBlock

:lexeme ~ L0_texLine priority => 0
L0_texLine ~ nonNewLines newLine
nonNewLines ~ nonNewLine*
nonNewLine ~ [^\n]
newLine ~ [\n]

TOP_CCode ::= C_element*
C_element ::= BRICK_C_Comment
C_element ::= BRICK_C_Token
C_element ::= BRICK_C_WhiteSpace

BRICK_C_Comment ::= L0_CComment
BRICK_C_Token ::= L0_CToken
BRICK_C_WhiteSpace ::= L0_CWhiteSpace

# :lexeme ~ L0_unicorn
# L0_unicorn ~ unicorn
# unicorn ~ [^\d\D]
anything ~ anyChar*
anyChar ~ [\d\D]

:lexeme ~ L0_CComment eager => 1 priority => 1
L0_CComment ~ '/*' anything '*/'

:lexeme ~ L0_CToken
L0_CToken ~ [\S]+

:lexeme ~ L0_CWhiteSpace
L0_CWhiteSpace ~ [\s]+

texCodeBegin ~ '\begin{code}'
texCodeEnd ~ '\end{code}'

:lexeme ~ L0_texCodeBlock priority => 1 eager => 1 event => properBlock pause => before
L0_texCodeBlock ~ texCodeBegin anything newLine texCodeEnd

:lexeme ~ L0_texCodeOpenBlock priority => 0 event => openBlock pause => before
L0_texCodeOpenBlock ~ texCodeOpenBlock
texCodeOpenBlock ~ texCodeBegin anything

END_OF_TOP_DSL

# ===== Part 3: Wrappers and handlers =====

# The following logic pre-generates all the grammars we
# will need, both for the top level and the combinators.

my $topGrammar =
  Marpa::R3::Grammar->new( { source => \$dsl, rejection => 'event', } );

local $main::DEBUG = 0;

# This is the top level parse routine.

sub parse {
    my ($inputRef) = @_;

    my @values = ();
    my $thisPos;
    my $handlerPos;

    my $properBlockHandler = sub {

        my ( $recce, $name, $symbolID, $blockID, $offset, $length ) = @_;
        my $eoCodeBlock = $offset + $length;
        my $firstNL     = index( ${$inputRef}, "\n", $offset );
        my $lastNL      = rindex( ${$inputRef}, "\n", $eoCodeBlock-1 );

        my ( $line1, $column1, $line2, $column2 );
        ( $line1, $column1 ) = $recce->line_column( $blockID, $offset );
        ( $line2, $column2 ) = $recce->line_column( $blockID, $firstNL );
        push @values, ['BRICK', $offset, ($firstNL+1)-$offset, join '',
          'L', $line1, 'c', $column1,
          '-', 'L', $line2, 'c', $column2,
          ' \begin{code}'];

        ( $line1, $column1 ) = $recce->line_column( $blockID, $firstNL + 1 );
        ( $line2, $column2 ) = $recce->line_column( $blockID, $lastNL );
        push @values, ['BRICK', $firstNL+1, $lastNL-$firstNL, join '',
          'L', $line1, 'c', $column1,
          '-', 'L', $line2, 'c', $column2,
          ' [CODE]'];

        ( $line1, $column1 ) = $recce->line_column( $blockID, $lastNL + 1 );
        ( $line2, $column2 ) = $recce->line_column( $blockID, $eoCodeBlock );
        push @values, ['BRICK', $lastNL+1, $eoCodeBlock-$lastNL, join '',
          'L', $line1, 'c', $column1,
          '-', 'L', $line2, 'c', $column2,
          ' \end{code}'];

	# Skip ahead to after next newline.
	# Sometime check standards to see it this is OK, but
	# for now it is convenient for testing.
        $handlerPos = index(${$inputRef}, "\n", $eoCodeBlock) + 1;
	$recce->lexeme_alternative('L0_texCodeOpenBlock', \@values, $handlerPos - $offset);
        'pause';
    };

    my $openBlockHandler = sub () {

        my ( $recce, $name, $symbolID, $blockID, $offset, $length ) = @_;
        my $eoCodeBlock = $offset + $length;
        my $firstNL = index( ${$inputRef}, "\n", $offset );

        my @values = ();
        my ( $line1, $column1, $line2, $column2 );
        ( $line1, $column1 ) = $recce->line_column( $blockID, $offset );
        ( $line2, $column2 ) = $recce->line_column( $blockID, $firstNL );
        push @values, ['BRICK', $offset, ($firstNL+1)-$offset, join '',
          'L', $line1, 'c', $column1,
          '-', 'L', $line2, 'c', $column2,
          ' \begin{code}'];

        ( $line1, $column1 ) = $recce->line_column( $blockID, $firstNL + 1 );
        ( $line2, $column2 ) = $recce->line_column( $blockID, $eoCodeBlock );
        push @values, ['BRICK', $firstNL+1, $eoCodeBlock-$firstNL, join '',
          'L', $line1, 'c', $column1,
          '-', 'L', $line2, 'c', $column2,
          ' [CODE]'];

        $handlerPos = $eoCodeBlock;

	$recce->lexeme_alternative('L0_texCodeBlock', \@values, $handlerPos - $offset);
        'pause';
    };

    my $recce = Marpa::R3::Recognizer->new(
        {
            grammar   => $topGrammar,
	    # event_is_active => { 'indent' => $indent_is_active },
	    event_handlers => {
		properBlock => $properBlockHandler,
		openBlock => $openBlockHandler,
		q{'rejected} => sub () {
		  my ($recce) = @_;
		  my $expected = $recce->terminals_expected();
		  return divergence(
		      "All tokens rejected, expecting ",
		      ( join " ", @{$expected} )
		  );
		}
	    },
            trace_terminals => ($main::DEBUG ? 99 : 0),
        }
    );

    my $inputLength = length ${$inputRef};
    $thisPos = $recce->read($inputRef);
    say STDERR join ' ', __LINE__, "inputLength=$inputLength";
    say STDERR join ' ', __LINE__, substr(${$inputRef}, $thisPos, 10);
    READ_LOOP: while ( 1 ) {
	my $resumePos = $thisPos;
	if ( defined $handlerPos ) {
	  my $closest_earleme = $recce->closest_earleme();
	  say STDERR join ' ', __LINE__, "closest_earleme=$closest_earleme";
	  say STDERR join ' ', __LINE__, substr(${$inputRef}, $closest_earleme, 10);
	  say STDERR join ' ', __LINE__, 'lexeme_complete(', $thisPos, $closest_earleme - $thisPos, ')';
	  $recce->lexeme_complete( undef, $thisPos, $closest_earleme - $thisPos);
	  $resumePos = $handlerPos;
	  $handlerPos = undef;
	}
	last READ_LOOP if $resumePos >= $inputLength;
	say STDERR join ' ', __LINE__, "resuming at $resumePos";
        $thisPos = $recce->resume($resumePos);
	say STDERR join ' ', __LINE__, substr(${$inputRef}, $thisPos, 10);
	say STDERR join ' ', __LINE__, "thisPos=$thisPos";
    }
    say STDERR join ' ', __LINE__, substr(${$inputRef}, $thisPos, 10);

    if ($main::TRACE_ES) {
      say STDERR qq{Returning from top level parser};
      my $latest_es = $recce->g1_pos();
      for my $es (0 .. $latest_es) {
	say STDERR "ES = ", $es;
	if ($main::TRACE_ES >= 2) {
	    # These calls are undocumented, and should not be
	    # called in the test suite.
	    say STDERR "Size of ES $es is ", $recce->earley_set_size($es);
	}
	say STDERR $recce->progress_show($es);
      }
    }

    # Return value and new offset

    my $value_ref = $recce->value();
    say Data::Dumper::Dumper($value_ref);
    if ( !$value_ref ) {
	say STDERR $recce->show_progress() if $main::DEBUG;
        divergence( qq{input read, but there was no parse} );
    }
    return showBricks($recce, $value_ref);

}

sub extractLines {
   my ($tree) = @_;
   my $refType = ref $tree;
   # say STDERR $refType;
   return extractLines(${$tree}) if $refType eq 'REF';
   # say STDERR __LINE__;
   return [] if $refType ne 'ARRAY';
   # say STDERR __LINE__;
   my @lines = ();
   if (substr($tree->[0], 0, 5) eq 'BRICK') {
       # say STDERR 'BRICK!';
       return [$tree];
   }
   # say STDERR __LINE__;
   # say STDERR '$#$tree: ';
   # say STDERR join '', '$#$tree: ', $#$tree;
   push @lines, @{ extractLines($tree->[$_]) } for 0 .. $#$tree;
   return \@lines;
}

sub showBricks {
    my ($recce, $tree) = @_;
    my $lines = extractLines($tree);
    my @bricks = sort { $a->[1] <=> $b->[1] } @$lines;
    my ($blockID) = $recce->block_progress();
    my @results = ();
    for my $brick (@bricks) {
      my ($id, $start, $length, $tag) = @{$brick};
      my ( $line1, $column1, $line2, $column2 );
      ( $line1, $column1 ) = $recce->line_column( $blockID, $start );
      ( $line2, $column2 ) = $recce->line_column( $blockID, $start+$length-1 );
      my $desc;
      FIND_DESC: {
	if ($id eq 'BRICK_texLine') {
	    say "start line=$line1, column=$column1";
	    say Data::Dumper::Dumper($brick);
	    $tag =~ s/\n.*//;
	    $desc = ' texLine ' . $tag;
	    last FIND_DESC;
	}
	if ($id eq 'BRICK') {
	    say "start line=$line1, column=$column1";
	    say Data::Dumper::Dumper($brick);
	    $desc = " $tag";
	    last FIND_DESC;
	}
         $desc = " $id $tag";
      }
      push @results, join '', '@', $line1, '-', $line2, $desc, "\n";
    }
    return join '', @results;
}

# This handler assumes a recognizer has been created.  Given
# an input, an offset into that input, it reads using that recognizer.
# The return values are the parse value and a new offset in the input.
# Errors are thrown.

sub getValue {
    my ( $recce, $target, $input, $offset ) = @_;
    my $input_length = length ${$input};
    my $resume_pos;
    my @values = ();

    # The main read loop.  Read starting at $offset.
    # If interrupted execute the handler logic,
    # and, possibly, resume.

    my $thisPos = $recce->read( $input, $offset ) ;
        divergence('Premature end of parse') if $thisPos < $input_length;
    return [\@values], $thisPos;

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
    my $recce = Marpa::R3::Recognizer->new(
        {
            grammar         => $subgrammar,
            rejection       => 'event',
	    # event_is_active => { 'indent' => $indent_is_active },
            trace_terminals => ($main::DEBUG ? 99 : 0),
        }
    );
    my ( $value_ref, $pos ) = getValue( $recce, $target, $input, $offset );
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
# and contain a "standard" symbol name, followed by zero or
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
