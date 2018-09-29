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
top ::= TOP_Tex_Source
top ::= L0_unicorn TOP_C_CharacterConstant
top ::= L0_unicorn TOP_C_StringLiteral

TOP_C_CharacterConstant ::= L0_i_C_CharacterConstant
TOP_C_StringLiteral ::= L0_i_C_StringLiteral

TOP_Tex_Source ::= texBody
texBody ::= texBodyElement*
texBodyElement ::= BRICK_Tex_Line
BRICK_Tex_Line ::= L0_Tex_Line
texBodyElement ::= L0_Tex_CodeBlock
texBodyElement ::= L0_Tex_StrayOpenCodeBlock

:lexeme ~ L0_Tex_Line
L0_Tex_Line ~ nonNewLines newLine
nonNewLines ~ nonNewLine*
nonNewLine ~ [^\n]
newLine ~ [\n]

TOP_CCode ::= C_element*
C_element ::= BRICK_C_Comment
C_element ::= BRICK_C_Token
C_element ::= BRICK_C_WhiteSpace
C_element ::= BRICK_C_CharacterConstant
C_element ::= BRICK_C_StringLiteral
C_element ::= BRICK_C_DivideOp
C_element ::= ERROR_C_StrayCommentOpen
C_element ::= ERROR_C_StraySingleQuote
C_element ::= ERROR_C_StrayDoubleQuote

BRICK_C_Comment ::= L0_C_Comment
BRICK_C_Token ::= L0_C_Token
BRICK_C_WhiteSpace ::= L0_C_WhiteSpace
BRICK_C_CharacterConstant ::= L0_C_CharacterConstant
BRICK_C_StringLiteral ::= L0_C_StringLiteral
BRICK_C_DivideOp ::= L0_C_DivideOp

ERROR_C_StrayCommentOpen ::= L0_C_StrayCommentOpen
ERROR_C_StraySingleQuote ::= L0_C_StraySingleQuote
ERROR_C_StrayDoubleQuote ::= L0_C_StrayDoubleQuote

:lexeme ~ L0_unicorn
L0_unicorn ~ unicorn
unicorn ~ [^\d\D]
# anything ~ anyChar*
# anyChar ~ [\d\D]
singleQuote ~ [']
doubleQuote ~ ["]
backslash ~ '\'

L0_C_StrayCommentOpen ~ unicorn
L0_C_StraySingleQuote ~ unicorn
L0_C_StrayDoubleQuote ~ unicorn
L0_C_Comment ~ unicorn
L0_C_CharacterConstant ~ unicorn
L0_C_StringLiteral ~ unicorn
L0_C_DivideOp ~ unicorn

L0_i_C_CharacterConstant ~ C_characterConstant
L0_i_C_StringLiteral ~ C_stringLiteral

L0_C_Token ~ unicorn
L0_C_WhiteSpace ~ unicorn
L0_Tex_CodeBlock ~ unicorn
L0_Tex_StrayOpenCodeBlock ~ unicorn

# most of this untested as of Fri Sep 28 17:22:36 EDT 2018
C_universalCharacterName ~ '\' [uU] C_hexQuad C_hexQuad
C_universalCharacterName ~ '\' [uU] C_hexQuad
C_hexQuad ~ C_hexDigit C_hexDigit C_hexDigit C_hexDigit
C_hexdigits1 ~ C_hexDigit+
C_hexDigit ~ [0-9a-fA-F]

C_characterConstant ~ singleQuote C_cCharSequence1 singleQuote
C_cCharSequence1 ~ C_cChar+
C_cChar ~ C_universalCharacterName
C_cChar ~ [^'\\\n] # C std N1256 6.4.4.4
C_cChar ~ C_escapeSequence
C_escapeSequence ~ C_simpleEscapeSequence
C_simpleEscapeSequence ~ backslash singleQuote
C_simpleEscapeSequence ~ backslash doubleQuote
C_simpleEscapeSequence ~ backslash '?'
C_simpleEscapeSequence ~ backslash backslash
C_simpleEscapeSequence ~ backslash 'a'
C_simpleEscapeSequence ~ backslash 'b'
C_simpleEscapeSequence ~ backslash 'f'
C_simpleEscapeSequence ~ backslash 'n'
C_simpleEscapeSequence ~ backslash 'r'
C_simpleEscapeSequence ~ backslash 't'
C_simpleEscapeSequence ~ backslash 'v'
C_escapeSequence ~ C_octalEscapeSequence
C_octalEscapeSequence ~ backslash C_octalDigit
C_octalEscapeSequence ~ backslash C_octalDigit C_octalDigit
C_octalEscapeSequence ~ backslash C_octalDigit C_octalDigit C_octalDigit
C_octalDigit ~ [0-7]

C_escapeSequence ~ C_hexadecimalEscapeSequence
C_hexadecimalEscapeSequence ~ C_hexdigits1

C_stringLiteral ~ doubleQuote C_sCharSequence1 doubleQuote
C_sCharSequence1 ~ C_sChar+
C_sChar ~ C_escapeSequence
C_sChar ~ [^"\\\n] # C std N1256 6.4.5

END_OF_TOP_DSL

my $texCodeBegin = '\\begin{code}';
my $texCodeEnd = '\\end{code}';

# ===== Part 3: Wrappers and handlers =====

# The following logic pre-generates all the grammars we
# will need, both for the top level and the combinators.

my $topGrammar =
  Marpa::R3::Grammar->new( { source => \$dsl, rejection => 'event', } );

my %grammar = ();

for my $top (qw(TOP_CCode)) {
    $grammar{$top} = do {
        my $CCodeDSL =
          join "\n",
          ':start ::= ' . $top,
          'inaccessible is ok by default',
          $dsl,
          ;

        Marpa::R3::Grammar->new(
            {
                source    => \$CCodeDSL,
                rejection => 'event',
            }
        );
    };
}

local $main::DEBUG = 0;

# This is the top level parse routine.

sub lexer {
    my ($recce, $inputRef) = @_;
    my %disabled = ();
    my $inputLength = length ${$inputRef};

    my $thisPos = $recce->read( $inputRef, 0, 0 );
    my ($blockID) = $recce->block_progress();

    # say STDERR join ' ', __LINE__, "inputLength=$inputLength";
    # say STDERR join ' ', __LINE__, substr(${$inputRef}, $thisPos, 10);
  COMPLETION: while ( $thisPos < $inputLength ) {
        my %expected =
          map { +( $_, 1 ) }
          grep { not defined $disabled{$_} } @{ $recce->terminals_expected() };
	 pos ${$inputRef} = $thisPos;
      ALTERNATIVE: {
          TEX_LEXEME: {

                # Find a Tex lexeme
                # L0_Tex_CodeBlock ~ texCodeBegin anything newLine texCodeEnd
                if ( $expected{L0_Tex_CodeBlock}
                    and ${$inputRef} =~ m/\G ( \Q$texCodeBegin\E .*? \Q$texCodeEnd\E )/gcxms )
                {
		    my @values = ();
                    my $match   = $1;
                    my $eoMatch = $thisPos + (length $match) - 1;
                    my $firstNL = index( ${$inputRef}, "\n", $thisPos );
                    my $lastNL  = rindex( ${$inputRef}, "\n", $eoMatch - 1 );
                    my ( $line1, $column1, $line2, $column2 );
                    ( $line1, $column1 ) =
                      $recce->line_column( $blockID, $thisPos );
                    ( $line2, $column2 ) =
                      $recce->line_column( $blockID, $firstNL );
                    push @values,
                      [
                        'BRICK',                     $thisPos,
                        ( $firstNL + 1 ) - $thisPos, join '',
                        'L',                         $line1,
                        'c',                         $column1,
                        '-',                         'L',
                        $line2,                      'c',
                        $column2,                    ' \begin{code}'
                      ];

                    ( $line1, $column1 ) =
                      $recce->line_column( $blockID, $firstNL + 1 );
                    ( $line2, $column2 ) =
                      $recce->line_column( $blockID, $lastNL );
                    push @values,
                      [
                        'BRICK',            $firstNL + 1,
                        $lastNL - $firstNL, join '',
                        'L',                $line1,
                        'c',                $column1,
                        '-',                'L',
                        $line2,             'c',
                        $column2,           ' [CODE]'
                      ];

                    ( $line1, $column1 ) =
                      $recce->line_column( $blockID, $lastNL + 1 );
                    ( $line2, $column2 ) =
                      $recce->line_column( $blockID, $eoMatch );
                    push @values,
                      [
                        'BRICK',            $lastNL + 1,
                        $eoMatch - $lastNL, join '',
                        'L',                $line1,
                        'c',                $column1,
                        '-',                'L',
                        $line2,             'c',
                        $column2,           ' \end{code}'
                      ];

                    # Skip ahead to after next newline.
                    # Sometime check standards to see it this is OK, but
                    # for now it is convenient for testing.
                    my $endPos = index( ${$inputRef}, "\n", $eoMatch ) + 1;
                    $recce->lexeme_alternative( 'L0_Tex_CodeBlock', \@values,
                        $endPos - $thisPos );
                    last TEX_LEXEME;
                }

		# Check for stray '\begin{code}' lines
                if ( $expected{L0_Tex_StrayOpenCodeBlock}
                    and ${$inputRef} =~ m/\G ( \Q$texCodeBegin\E )/gcxms )
                {
		    my @values = ();
                    my $match   = $1;
                    my $eoMatch = $thisPos + (length $match) - 1;
                    my $nextNL = index( ${$inputRef}, "\n", $eoMatch );
                    my ( $line1, $column1, $line2, $column2 );
                    ( $line1, $column1 ) =
                      $recce->line_column( $blockID, $thisPos );
                    ( $line2, $column2 ) =
                      $recce->line_column( $blockID, $nextNL );
                    push @values,
                      [
                        'BRICK',                     $thisPos,
                        ( $nextNL + 1 ) - $thisPos, join '',
                        'L',                         $line1,
                        'c',                         $column1,
                        '-',                         'L',
                        $line2,                      'c',
                        $column2,                    ' stray \begin{code}'
                      ];

                    # Skip ahead to after next newline.
                    # Sometime check standards to see it this is OK, but
                    # for now it is convenient for testing.
                    my $endPos = $nextNL + 1;
                    $recce->lexeme_alternative( 'L0_Tex_StrayOpenCodeBlock',
                        \@values, $endPos - $thisPos );
		    # Once we've seen a stray open, we can never see a valid
		    # block.  Every stray open causes a scan to the end of input,
		    # can in theory they can make a parse go quadratic.  Therefore
		    # we disable tex Code Blocks -- from now on, we will only look
		    # for strays.
		    $disabled{L0_Tex_CodeBlock} = 1;
                    last TEX_LEXEME;
                }

                if ( $expected{L0_Tex_Line} and ${$inputRef} =~ m/\G([^\n]*\n)/gcxms )
                {
                    my $match = $1;
                    $recce->lexeme_alternative( 'L0_Tex_Line', $match,
                        length $match );
                    last TEX_LEXEME;
                }
            }
          C_LEXEME: {

                # Find a C lexeme
                if ( $expected{L0_C_Comment}
                    and ${$inputRef} =~ m{\G ( [/][*] .*? [*][/] )}gcxms )
                {
		    my @values = ();
                    my $match   = $1;
                    my $eoMatch = $thisPos + (length $match) - 1;
                    my ( $line1, $column1, $line2, $column2 );
                    ( $line1, $column1 ) =
                      $recce->line_column( $blockID, $thisPos );
                    ( $line2, $column2 ) =
                      $recce->line_column( $blockID, $eoMatch );
                    push @values,
                      [
                        'BRICK_C',                     $thisPos,
                        ( $eoMatch + 1 ) - $thisPos, join '',
                        'L',                         $line1,
                        'c',                         $column1,
                        '-',                         'L',
                        $line2,                      'c',
                        $column2,                    ' ',
			substr($match, 0, 10)
                      ];

                    # Skip ahead to after next newline.
                    # Sometime check standards to see it this is OK, but
                    # for now it is convenient for testing.
                    my $endPos = index( ${$inputRef}, "\n", $eoMatch ) + 1;
                    $recce->lexeme_alternative( 'L0_C_Comment', \@values,
                        $endPos - $thisPos );
                    last C_LEXEME;
                }

		# Check for unclosed C comments
                if ( $expected{L0_C_StrayCommentOpen}
                    and ${$inputRef} =~ m{\G ( [/][*] )}gcxms )
                {
		    my @values = ();
                    my $match   = $1;
                    my $eoMatch = $thisPos + (length $match) - 1;
                    my $nextNL = index( ${$inputRef}, "\n", $eoMatch );
                    my ( $line1, $column1, $line2, $column2 );
                    ( $line1, $column1 ) =
                      $recce->line_column( $blockID, $thisPos );
                    ( $line2, $column2 ) =
                      $recce->line_column( $blockID, $nextNL );
                    push @values,
                      [
                        'BRICK_C',                     $thisPos,
                        ( $nextNL + 1 ) - $thisPos, join '',
                        'L',                         $line1,
                        'c',                         $column1,
                        '-',                         'L',
                        $line2,                      'c',
                        $column2,                    ' stray "/*"'
                      ];

                    # Skip ahead to after next newline.
                    # Sometime check standards to see it this is OK, but
                    # for now it is convenient for testing.
                    my $endPos = $nextNL + 1;
                    $recce->lexeme_alternative( 'L0_C_StrayCommentOpen',
                        \@values, $endPos - $thisPos );
		    # Once we've seen an unclosed comment, we can never see a valid
		    # C comment.  Every stray open causes a scan to the end of input,
		    # which can make a parse go quadratic.  Therefore
		    # we disable C comments -- from now on, we will only look
		    # for strays.
		    $disabled{L0_C_Comment} = 1;
                    last C_LEXEME;
                }

		# For now, an absurdly liberal idea of what a token is -- any
		# non-whitespace sequence without quotes or slashes.  Quotes
		# and slashes are taken care of above
                if ( $expected{L0_C_DivideOp} and ${$inputRef} =~ m{\G([/])}gcxms )
                {
                    my $match = $1;
                    $recce->lexeme_alternative( 'L0_C_DivideOp', $match,
                        length $match );
                    last C_LEXEME;
                }

		# For now, an absurdly liberal idea of what a token is -- any
		# non-whitespace sequence without quotes or slashes.  Quotes
		# and slashes are taken care of above
                if ( $expected{L0_C_StrayDoubleQuote} and ${$inputRef} =~ m/\G(["])/gcxms )
                {
                    my $match = $1;
                    $recce->lexeme_alternative( 'L0_C_StrayDoubleQuote', $match,
                        length $match );
                    last C_LEXEME;
                }

		# For now, an absurdly liberal idea of what a token is -- any
		# non-whitespace sequence without quotes or slashes.  Quotes
		# and slashes are taken care of above
                if ( $expected{L0_C_StraySingleQuote} and ${$inputRef} =~ m/\G(['])/gcxms )
                {
                    my $match = $1;
                    $recce->lexeme_alternative( 'L0_C_StraySingleQuote', $match,
                        length $match );
                    last C_LEXEME;
                }

		# For now, an absurdly liberal idea of what a token is -- any
		# non-whitespace sequence without quotes or slashes.  Quotes
		# and slashes are taken care of above
                if ( $expected{L0_C_Token} and ${$inputRef} =~ m{\G([^\s'"/]+)}gcxms )
                {
                    my $match = $1;
                    $recce->lexeme_alternative( 'L0_C_Token', $match,
                        length $match );
                    last C_LEXEME;
                }

		# Whitespace
                if ( $expected{L0_C_WhiteSpace} and ${$inputRef} =~ m/\G([\s]+)/gcxms )
                {
                    my $match = $1;
                    $recce->lexeme_alternative( 'L0_C_WhiteSpace', $match,
                        length $match );
                    last C_LEXEME;
                }
            }
        }
        my $closest_earleme = $recce->closest_earleme();

# say STDERR join ' ', __LINE__, "closest_earleme=$closest_earleme";
# say STDERR join ' ', __LINE__, substr(${$inputRef}, $closest_earleme, 10);
# say STDERR join ' ', __LINE__, 'lexeme_complete(', $thisPos, $closest_earleme - $thisPos, ')';

        $thisPos =
          $recce->lexeme_complete( undef, $thisPos,
            $closest_earleme - $thisPos );

        # say STDERR join ' ', __LINE__, substr(${$inputRef}, $thisPos, 10);
        # say STDERR join ' ', __LINE__, "thisPos=$thisPos";
    }

    # say STDERR join ' ', __LINE__, substr(${$inputRef}, $thisPos, 10);
}

sub parse {
    my ($inputRef) = @_;

    my @values = ();
    my $thisPos;

    my $recce = Marpa::R3::Recognizer->new(
        {
            grammar   => $topGrammar,
	    event_handlers => {
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


    lexer($recce, $inputRef);

    if ($main::TRACE_ES) {
        say STDERR qq{Returning from top level parser};
        my $latest_es = $recce->g1_pos();
        for my $es ( 0 .. $latest_es ) {
            say STDERR "ES = ", $es;
            if ( $main::TRACE_ES >= 2 ) {

                # These calls are undocumented, and should not be
                # called in the test suite.
                say STDERR "Size of ES $es is ", $recce->earley_set_size($es);
            }
            say STDERR $recce->progress_show($es);
        }
    }

    # Return value and new offset

    my $valuer = Marpa::R3::Valuer->new( { recognizer => $recce } );
    say STDERR $recce->progress_show( 0, -1 );
    my $valueRef;
    my @results = ();
  VALUE: while (1) {
        $valueRef = $valuer->value();
        last VALUE if not $valueRef;
        say STDERR Data::Dumper::Dumper($valueRef);
        push @results, '=== Value ===';
        push @results, showBricks( $recce, $valueRef );
    }

    # say Data::Dumper::Dumper($value_ref);
    return join "\n", @results, '';

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
	if ($id eq 'BRICK_Tex_Line') {
	    # say "start line=$line1, column=$column1";
	    # say Data::Dumper::Dumper($brick);
	    $tag =~ s/\n.*//;
	    $desc = ' texLine ' . $tag;
	    last FIND_DESC;
	}
	if ($id eq 'BRICK') {
	    # say "start line=$line1, column=$column1";
	    # say Data::Dumper::Dumper($brick);
	    $desc = " $tag";
	    last FIND_DESC;
	}
	if (substr($id, 0, 6) eq 'BRICK_') {
	    # say "start line=$line1, column=$column1";
	    # say Data::Dumper::Dumper($brick);
	    $tag =~ s/\n.*//;
	    $desc = ' ' . substr($id, 6) . $tag;
	    last FIND_DESC;
	}
	if (substr($id, 0, 6) eq 'ERROR_') {
	    # say "start line=$line1, column=$column1";
	    # say Data::Dumper::Dumper($brick);
	    $tag =~ s/\n.*//;
	    $desc = ' ' . $id . ' ' . $tag;
	    last FIND_DESC;
	}
         $desc = " $id $tag";
      }
      push @results, join '', '@', $line1, '-', $line2, $desc, "\n";
    }
    return join '', @results;
}

sub subParse {
    my ( $grammar, $target, $inputRef ) = @_;
    say STDERR qq{Starting combinator for "$target"}
      if $main::TRACE_ES;
    say STDERR qq{Starting combinator for "$target"}
      if $main::DEBUG;
    my $recce = Marpa::R3::Recognizer->new(
        {
            grammar         => $grammar,
            trace_terminals => ( $main::DEBUG ? 99 : 0 ),
        }
    );

    my $thisPos = $recce->read( $inputRef );

    my $valuer = Marpa::R3::Valuer->new( { recognizer => $recce } );
    my @values = ();
  VALUE: while (1) {
        my $valueRef = $valuer->value();
        last VALUE if not $valueRef;

        # my $value = Data::Dumper::Dumper($valueRef);
        push @values, $valueRef;
    }
    say STDERR qq{Returning from combinator for "$target"}
      if $main::DEBUG;

    if ($main::TRACE_ES) {
        my $latest_es = $recce->latest_earley_set();
        say STDERR "latest ES = ", $latest_es;
        for my $es ( 0 .. $latest_es ) {
            say STDERR "ES $es = ", $recce->earley_set_size($es);
        }
        say STDERR qq{Returning from combinator for "$target"};
    }

    return [@values], $thisPos;
}

1;
