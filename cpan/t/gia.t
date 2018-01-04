#!perl
# Marpa::R3 is Copyright (C) 2017, Jeffrey Kegler.
#
# This module is free software; you can redistribute it and/or modify it
# under the same terms as Perl 5.10.1. For more details, see the full text
# of the licenses in the directory LICENSES.
#
# This program is distributed in the hope that it will be
# useful, but it is provided "as is" and without any express
# or implied warranties. For details, see the full text of
# of the licenses in the directory LICENSES.

# Tests which require only grammar, input, and an output with no
# semantics -- usually just an AST

use 5.010001;

use strict;
use warnings;

use Test::More tests => 98;
use Data::Dumper;
use English qw( -no_match_vars );
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

my @tests_data = ();

our $DEBUG = 0;

# In crediting test, JDD = Jean-Damien Durand
if (1) {
    my $glenn_grammar = Marpa::R3::Grammar->new(
        {   source => \(<<'END_OF_SOURCE'),
            :default ::= action => ::array

            Start  ::= Child DoubleColon Token

            DoubleColon ~ '::'
            Child ~ 'child'
            Token ~
                word
                | word ':' word
            word ~ [\w]+

END_OF_SOURCE
        }
    );

    my $input = 'child::book';

    do_test(
        $glenn_grammar,
        'child::book',
        [ 'child', q{::}, 'book' ],
        'Parse OK',
        'Nate Glenn bug regression'
        );
} ## end if (0)

if (1) {
    my $ic_grammar = Marpa::R3::Grammar->new(
        {   source => \(<<'END_OF_SOURCE'),
            :default ::= action => ::array

            Start  ::= Child DoubleColon Token

            DoubleColon ~ '::'
            Child ~ 'cHILd':i
            Token ~
                word
                | word ':' word
            word ~ [\w]:ic +

END_OF_SOURCE
        }
    );

    do_test(
        $ic_grammar,
        'ChilD::BooK',
        [ 'ChilD', q{::}, 'BooK' ],
        'Parse OK',
        'Case insensitivity test'
        );
} ## end if (0)

if (1) {
    my $durand_grammar1 = Marpa::R3::Grammar->new(
        {   source => \(<<'END_OF_SOURCE'),
:default ::= action => ::array
start symbol is test
test ::= TEST
:lexeme ~ TEST
TEST                  ~ '## Allowed in the input' NEWLINE
WS                    ~ [ \t]
WS_any                ~ WS*
POUND                 ~ '#'
_NEWLINE              ~ [\n]
NOT_NEWLINE_any       ~ [^\n]*
NEWLINE              ~ _NEWLINE
COMMENT               ~ WS_any POUND NOT_NEWLINE_any _NEWLINE
:discard              ~ COMMENT
BLANKLINE             ~ WS_any _NEWLINE
:discard              ~ BLANKLINE
END_OF_SOURCE
        }
    );

    do_test(
        $durand_grammar1, <<INPUT,
## Allowed in the input

# Another comment
INPUT
        ["## Allowed in the input\n"],
        'Parse OK',
        'JDD test of discard versus accepted'
    );
} ## end if (0)

# ===============

if (1) {
    my $durand_grammar2 = Marpa::R3::Grammar->new(
        {   source => \(<<'END_OF_SOURCE'),
:default ::= action => ::array
test ::= 'test input' NEWLINE
WS                    ~ [ \t]
WS_any                ~ WS*
POUND                 ~ '#'
_NEWLINE              ~ [\n]
NOT_NEWLINE_any       ~ [^\n]*
NEWLINE              ~ _NEWLINE
COMMENT               ~ WS_any POUND NOT_NEWLINE_any _NEWLINE
:discard              ~ COMMENT
BLANKLINE             ~ WS_any _NEWLINE
:discard              ~ BLANKLINE
END_OF_SOURCE
        }
    );

    do_test(
        $durand_grammar2, <<INPUT,
# Comment followed by a newline

# Another comment
test input
INPUT
        [ 'test input', "\n" ],
        'Parse OK',
        'Regression test of bug found by JDD'
    );
} ## end if (1)

# ===============

if (1) {
    my $durand_grammar3 = Marpa::R3::Grammar->new(
        {   source => \(<<'END_OF_SOURCE'),
:default ::= action => ::array

Script ::= '=' '/' 'dumb'

_WhiteSpace                            ~ ' '
_LineTerminator                        ~ [\n]
_SingleLineComment                     ~ '//' _SingleLineCommentCharsopt
_SingleLineCommentChars                ~ _SingleLineCommentChar _SingleLineCommentCharsopt
_SingleLineCommentCharsopt             ~ _SingleLineCommentChars
_SingleLineCommentCharsopt             ~
_SingleLineCommentChar                 ~ [^\n]

_S ~
    _WhiteSpace
  | _LineTerminator
  | _SingleLineComment

S_MANY ~ _S+
:discard ~ S_MANY

END_OF_SOURCE
        }
    );

    do_test(
        $durand_grammar3, <<INPUT,
 = / dumb
INPUT
        [qw(= / dumb)],
        'Parse OK',
        'Regression test of perl_pos bug found by JDD'
    );
} ## end if (1)


# ===============

# Regression test of grammar without lexers --
# based on one from Jean-Damien
if (1) {
    my $grammar = Marpa::R3::Grammar->new(
        {   source => \(<<'END_OF_SOURCE'),
:default ::= action => ::undef
:start ::= null
null ::=
END_OF_SOURCE
        }
    );

    do_test(
        $grammar, q{},
        undef,
        'Parse OK',
        'Regression test of lexerless grammar, bug found by JDD'
    );

} ## end if (1)

# Test of forgiving token from Peter Stuifzand
# Note: forgiving is now the default
if (1) {

    my $source = <<'END_OF_SOURCE';
:default ::= action => ::array
product ::= sku (nl) name (nl) price price price (nl)

sku       ~ sku_0 '.' sku_0
sku_0     ~ [\d]+

price     ~ price_0 ',' price_0
price_0   ~ [\d]+
nl        ~ [\n]

sp        ~ [ ]+
:discard  ~ sp

name      ~ [^\n]+

END_OF_SOURCE

    my $input = <<'INPUT';
130.12312
Descriptive line
1,10 1,10 1,30
INPUT

    my $grammar = Marpa::R3::Grammar->new( { source => \$source } );
    do_test(
        $grammar, $input,
        [ '130.12312', 'Descriptive line', '1,10', '1,10', '1,30' ],
        'Parse OK', 'Test of forgiving token from Peter Stuifzand'
        );
}

# Test of LATM token from Ruslan Zakirov
if (1) {

    my $source = <<'END_OF_SOURCE';
:default ::= action => ::array
:start ::= content
content ::= name ':' value
name ~ [A-Za-z0-9-]+
value ~ [A-Za-z0-9:-]+
:lexeme ~ value
END_OF_SOURCE

    my $input = 'UID:urn:uuid:4fbe8971-0bc3-424c-9c26-36c3e1eff6b1';
    my $expected_output =
        [ 'UID', ':', 'urn:uuid:4fbe8971-0bc3-424c-9c26-36c3e1eff6b1' ];

    my $grammar = Marpa::R3::Grammar->new( { source => \$source } );
    do_test(
        $grammar, $input, $expected_output,
        'Parse OK', 'Test of LATM token from Ruslan Zakirov'
        );
}

# Test of LATM token from Ruslan Zakirov
# This time using the lexeme default statement
if (1) {

    my $source = <<'END_OF_SOURCE';
:default ::= action => ::array
:start ::= content
content ::= name ':' value
name ~ [A-Za-z0-9-]+
value ~ [A-Za-z0-9:-]+
END_OF_SOURCE

    my $input = 'UID:urn:uuid:4fbe8971-0bc3-424c-9c26-36c3e1eff6b1';
    my $expected_output =
        [ 'UID', ':', 'urn:uuid:4fbe8971-0bc3-424c-9c26-36c3e1eff6b1' ];

    my $grammar = Marpa::R3::Grammar->new( { source => \$source } );
    do_test(
        $grammar, $input, $expected_output,
        'Parse OK', 'Test of LATM token using lexeme default statement'
        );
}

# Test of rank adverb
if (1) {

    my $source = <<'END_OF_SOURCE';
:start ::= externals
externals ::= external* action => [values]
external ::= sentence action => ::first
sentence ::= ('I' 'am' 'special') words ('--' 'NOT!' ';') rank => 1
sentence ::= words (';') rank => -1
words ::= word* action => [values]

:discard ~ whitespace
whitespace ~ [\s]+
word ~ [\w!-]+
END_OF_SOURCE

    my $input = <<'END_OF_INPUT';
I am special so very special -- NOT!;
I am special and nothing is going to change that;
END_OF_INPUT

    my $expected_output = [
        [ 'sentence', [qw(so very special)] ],
        [   'sentence',
            [qw(I am special and nothing is going to change that)],
        ]
    ];

    my $grammar = Marpa::R3::Grammar->new(
        { ranking_method => 'high_rank_only', source => \$source } );
    do_test(
        $grammar, $input, $expected_output,
        'Parse OK', 'Test of rank adverb for display'
        );
}

# Test of rank adverb
if (1) {

    my $source = <<'END_OF_SOURCE';
:start ::= externals
externals ::= external* action => [values]
external ::= sentence action => ::first
sentence ::= ('I' 'am' 'special') words ('--' 'NOT!' ';') rank => -2
sentence ::= words (';') rank => -3
words ::= word* action => [values]

:discard ~ whitespace
whitespace ~ [\s]+
word ~ [\w!-]+
END_OF_SOURCE

    my $input = <<'END_OF_INPUT';
I am special so very special -- NOT!;
I am special and nothing is going to change that;
END_OF_INPUT

    my $expected_output = [
        [ 'sentence', [qw(so very special)] ],
        [   'sentence',
            [qw(I am special and nothing is going to change that)],
        ]
    ];

    my $grammar = Marpa::R3::Grammar->new(
        { ranking_method => 'high_rank_only', source => \$source } );
    do_test(
        $grammar, $input, $expected_output,
        'Parse OK', 'Test of rank adverb for display'
        );
}

# Test of rule array item descriptor for action adverb
# todo: test by converting rule and lhs ID's to names
# based on $grammar->symbol_is_lexeme(symbol_id) -- to be written
if (1) {
    my $source = <<'END_OF_SOURCE';

    :default ::= action => [lhs, rule, values]
    lexeme default = action => [lhs, rule, value]
    start ::= number1 number2
    number1 ::= <forty two>
    number2 ::= <forty three>
    <forty two> ~ '42'
    <forty three> ~ '43'
END_OF_SOURCE

    my $input = '4243';
    my $expected_output =
        [ 5, 0, [ 3, 1, [ 2, undef, '42' ] ], [ 4, 2, [ 1, undef, '43' ] ] ];

    my $grammar = Marpa::R3::Grammar->new( { source => \$source } );
    do_test(
        $grammar, $input, $expected_output,
        'Parse OK', 'Test of rule array item descriptor for action adverb'
        );
}

# Test of 'symbol', 'name' array item descriptors
if (1) {

    my $source = <<'END_OF_SOURCE';

    :default ::= action => [symbol, name, values]
    lexeme default = action => [symbol, name, value]
    start ::= number1 number2 name => top
    number1 ::= <forty two> name => 'number 1'
    number2 ::= <forty three> name => 'number 2'
    <forty two> ~ '42'
    <forty three> ~ '43'
END_OF_SOURCE

    my $input           = '4243';
    my $expected_output = [
        'start',
        'top',
        [ 'number1', 'number 1', [ 'forty two',   'forty two',   '42' ] ],
        [ 'number2', 'number 2', [ 'forty three', 'forty three', '43' ] ]
    ];

    my $grammar = Marpa::R3::Grammar->new( { source => \$source } );
    do_test(
        $grammar, $input, $expected_output,
        'Parse OK', 'Test of rule array item descriptor for action adverb'
        );
}

### Test of 'inaccessible is ok'
if (1) {

    my $source = <<'END_OF_SOURCE';

    inaccessible is ok by default

    :default ::= action => [values]
    start ::= stuff*
    stuff ::= a | b
    a ::= 'a' action => ::first
    b ::= 'b' action => ::first
    c ::= 'c' action => ::first
END_OF_SOURCE

    my $input           = 'aa';
    my $expected_output = [
        [ 'a' ],
        [ 'a' ]
    ];

    my $grammar = Marpa::R3::Grammar->new( { source => \$source } );
    do_test(
        $grammar, $input, $expected_output,
        'Parse OK', qq{Test of "Inaccessible is ok"}
        );
}

if (1) {
    my $source = <<'END_OF_SOURCE';

    inaccessible is ok by default
    :default ::= action => ::first

    start ::= !START!
    start1 ::= X
    start2 ::= Y

    X ~ 'X'
    Y ~ 'X'

END_OF_SOURCE

    my $input           = 'X';
    my $expected_output = 'X';

    for my $this_start (qw/start1 start2/) {

        my $this_source = $source;
        $this_source =~ s/!START!/$this_start/;
        my $grammar = Marpa::R3::Grammar->new( { source => \$this_source } );
        do_test(
            $grammar, $input, $expected_output,
            'Parse OK', qq{Test of changing start symbols: <$this_start>}
            );

    } ## end for my $this_start (qw/start1 start2/)
}

if (1) {
    my $source = <<'END_OF_SOURCE';

    start ::= literals action => ::first
    literals ::= literal+ action => [values]
    :lexeme ~ literal

    <literal> ~ '[[' <stuff> ']]'
    <stuff> ~ <any char>*
    <any char> ~ [\d\D]

    :discard ~ whitespace
    whitespace ~ [\s]+

END_OF_SOURCE

    my $input           = "[[X]] [[Y]]";
    my $expected_output = [ $input ];

    my $grammar = Marpa::R3::Grammar->new( { source => \$source } );
    do_test(
        $grammar, $input, $expected_output,
        'Parse OK', qq{Test 1 of lazy long brackets}
        );

}

if (1) {
    my $source = <<'END_OF_SOURCE';

    start ::= literals action => ::first
    literals ::= literal+ action => [values]
    :lexeme ~ literal eager => 0

    <literal> ~ '[[' <stuff> ']]'
    <stuff> ~ <any char>*
    <any char> ~ [\d\D]

    :discard ~ whitespace
    whitespace ~ [\s]+

END_OF_SOURCE

    my $input           = "[[X]] [[Y]]";
    my $expected_output = [ $input ];

    my $grammar = Marpa::R3::Grammar->new( { source => \$source } );
    do_test(
        $grammar, $input, $expected_output,
        'Parse OK', qq{Test 2 of lazy long brackets}
        );

}

if (1) {
    my $source = <<'END_OF_SOURCE';

    start ::= literals action => ::first
    literals ::= literal+ action => [values]

    :lexeme ~ literal eager => 1

    <literal> ~ '[[' <stuff> ']]'
    <stuff> ~ <any char>*
    <any char> ~ [\d\D]

    :discard ~ whitespace
    whitespace ~ [\s]+

END_OF_SOURCE

    my $input           = "[[X]] [[Y]]";
    my $expected_output = [ '[[X]]', '[[Y]]' ];

    my $grammar = Marpa::R3::Grammar->new( { source => \$source } );
    do_test(
        $grammar, $input, $expected_output,
        'Parse OK', qq{Test of eager long brackets}
        );

}

if (1) {
    my $source = <<'END_OF_SOURCE';

    start ::= text action => ::first
    text ::= piece+ action => [values]
    piece ::= '/' action => ::first
        | <slashfree text> action => ::first

    <slashfree text> ~ <nonslash char>+
    <nonslash char> ~ [^/]

    :discard ~ whitespace
    whitespace ~ [\s]+

    :discard ~ comment eager => 1

    comment ~ '//' <stuff> <newline>
    <stuff> ~ <any char>*
    <any char> ~ [\d\D]
    <newline> ~ [\n]

END_OF_SOURCE

    my $input           = "abc//xyz\ndef";
    my $expected_output = [ 'abc', 'def' ];

    my $grammar = Marpa::R3::Grammar->new( { source => \$source } );
    do_test(
        $grammar, $input, $expected_output,
        'Parse OK', qq{Test of eager discard}
        );

}

if (1) {
    my $source = <<'END_OF_SOURCE';

    start ::= text action => ::first
    text ::= piece+ action => [values]

    :lexeme ~ piece eager => 1
    piece ~ '[' balanced_eq ']'
    balanced_eq ~ '=' balanced_eq '='
    balanced_eq ~ '[' anything ']'

    <anything> ~ <anychar>+
    <anychar> ~ [\d\D]

    :discard ~ whitespace
    whitespace ~ [\s]+

END_OF_SOURCE

    my @left_pieces  = qw([[X]] [=[X]=] [==[X]==] [===[X]===]);
    my @right_pieces = qw([[Y]] [=[Y]=] [==[Y]==] [===[Y]===]);

    for my $left_piece (@left_pieces) {
        for my $right_piece (@right_pieces) {
            my $input = join " ", $left_piece, $right_piece;
            my $expected_output = [ $left_piece, $right_piece ];
            my $grammar = Marpa::R3::Grammar->new( { source => \$source } );
            do_test( $grammar, $input, $expected_output, 'Parse OK',
                qq{Test of eager discard for "$input"} );
        }
    }

}

if (1) {
    my $source = <<'END_OF_SOURCE';

    :default ::= action => ::first

    dual_start ::= start1 name => 'first start rule'
    dual_start ::= start2 name => 'second start rule'
    start1 ::= X
    start2 ::= Y

    X ~ 'X'
    Y ~ 'Y'

END_OF_SOURCE

    my $input           = 'X';
    my $expected_output = 'X';

    my $grammar = Marpa::R3::Grammar->new( { source => \$source } );

my $start_id;

    $start_id = $grammar->start_symbol_id();

    Test::More::is( $start_id, 4, q{Test of $grammar->start_symbol_id()} );

    $start_id = $grammar->g1_start_symbol_id();

    Test::More::is( $start_id, 2, q{Test of $grammar->g1_start_symbol_id()} );

    $start_id = $grammar->l0_start_symbol_id();

    Test::More::is( $start_id, 2, q{Test of $grammar->l0_start_symbol_id()} );

    my @production_names = ();

    push @production_names, $grammar->production_name($_)
      for 1 .. $grammar->highest_production_id();

    my $production_names = join q{:}, @production_names;
    Test::More::is(
        $production_names,
        (
            join ':',
            qw([:start:] start1 start2),
            'first start rule',
            'second start rule',
            qw([:lex_start:] [:lex_start:] X Y)
        ),
        q{Test of $grammar->production_name()}
    );

    do_test(
        $grammar, $input, $expected_output,
        'Parse OK', qq{Test of alternative as start rule}
        );

}

# Tests of rank adverb based on examples from Lukas Atkinson
# Here longest is highest rank, as in his original

if (1) {

    my $source = <<'END_OF_SOURCE';
  :discard ~ ws; ws ~ [\s]+
  
  List ::= Item3 rank => 3
  List ::= Item2 rank => 2
  List ::= Item1 rank => 1
  List ::= List Item3 rank => 3
  List ::= List Item2 rank => 2
  List ::= List Item1 rank => 1
  Item3 ::= VAR '=' VAR
  Item2 ::= VAR '='
  Item1 ::= VAR
  VAR ~ [\w]+
END_OF_SOURCE

    my @tests = (
        [ 'a = b', [ List => [ 'Item3', 'a', '=', 'b' ] ], ],
        [
            'a = b c = d',
            [ List => [ List => [qw(Item3 a = b)] ], [qw(Item3 c = d)] ]
        ],
        [
            'a = b c = d e',
            [
                List => [
                    List => [ List => [qw(Item3 a = b)] ],
                    [qw(Item3 c = d)]
                ],
                [qw(Item1 e)]
            ]
        ],
        [
            'a = b c = d e =',
            [
                List => [
                    List => [ List => [qw(Item3 a = b)] ],
                    [qw(Item3 c = d)]
                ],
                [qw(Item2 e =)]
            ]
        ],
        [
            'a = b c = d e = f',
            [
                List => [
                    List => [ List => [qw(Item3 a = b)] ],
                    [qw(Item3 c = d)]
                ],
                [qw(Item3 e = f)]
            ]
        ],
    );

    my $grammar = Marpa::R3::Grammar->new(
        { ranking_method => 'high_rank_only', source => \$source } );
    for my $test (@tests) {
        my ( $input, $output ) = @{$test};
        do_test( $grammar, $input, $output, 'Parse OK',
            qq{Test of rank by longest: "$input"} );
    }
}

# Tests of rank adverb based on examples from Lukas Atkinson
# Here *shortest* is highest rank

if (1) {

    my $source = <<'END_OF_SOURCE';
  :discard ~ ws; ws ~ [\s]+

  List ::= Item3 rank => 1
  List ::= Item2 rank => 2
  List ::= Item1 rank => 3
  List ::= List Item3 rank => 1
  List ::= List Item2 rank => 2
  List ::= List Item1 rank => 3
  Item3 ::= VAR '=' VAR
  Item2 ::= VAR '='
  Item1 ::= VAR
  VAR ~ [\w]+
END_OF_SOURCE

    my @tests = (
        [ 'a = b', [ List => [ List => [qw(Item2 a =)] ], [qw(Item1 b)] ], ],
        [
            'a = b c = d',
            [
                List => [
                    List =>
                      [ List => [ List => [qw(Item2 a =)] ], [qw(Item1 b)] ],
                    [qw(Item2 c = )]
                ],
                [qw(Item1 d)]
            ]
        ],
        [
            'a = b c = d e',
            [
                List => [
                    List => [
                        List => [
                            List => [ List => [qw(Item2 a = )] ],
                            [qw(Item1 b )]
                        ],
                        [qw(Item2 c = )]
                    ],
                    [qw(Item1 d)]
                ],
                [qw(Item1 e)]
            ]
        ],
        [
            'a = b c = d e =',
            [
                List => [
                    List => [
                        List => [
                            List => [ List => [qw(Item2 a = )] ],
                            [qw(Item1 b )]
                        ],
                        [qw(Item2 c = )]
                    ],
                    [qw(Item1 d)]
                ],
                [qw(Item2 e =)]
            ]
        ],
        [
            'a = b c = d e = f',
            [
                List => [
                    List => [
                        List => [
                            List => [
                                List => [ List => [qw(Item2 a = )] ],
                                [qw(Item1 b )]
                            ],
                            [qw(Item2 c = )]
                        ],
                        [qw(Item1 d)]
                    ],
                    [qw(Item2 e =)]
                ],
                [qw(Item1 f)]
            ]
        ],
    );

    my $grammar = Marpa::R3::Grammar->new(
        { ranking_method => 'high_rank_only', source => \$source } );
    for my $test (@tests) {
        my ( $input, $output ) = @{$test};
        do_test( $grammar, $input, $output, 'Parse OK',
            qq{Test of rank by shortest: "$input"},
        );
    }
}

sub do_test {
    my ( $grammar, $test_string, $expected_value, $expected_result,
        $test_name ) = @_;
    my ( $actual_value, $actual_result ) =
        my_parser( $grammar, $test_string );
    Test::More::is(
        Data::Dumper::Dumper( \$actual_value ),
        Data::Dumper::Dumper( \$expected_value ),
        qq{Value of $test_name}
    );
    Test::More::is( $actual_result, $expected_result,
        qq{Result of $test_name} );
}

sub my_parser {
    my ( $grammar, $string ) = @_;

    my $recce = Marpa::R3::Recognizer->new( { grammar => $grammar } );

    if ( not defined eval { $recce->read( \$string ); 1 } ) {
        say $EVAL_ERROR if $DEBUG;
        my $abbreviated_error = $EVAL_ERROR;
        chomp $abbreviated_error;
        return 'No parse', $abbreviated_error;
    } ## end if ( not defined eval { $recce->read( \$string ); 1 ...})
    my $value_ref = $recce->value();
    if ( not defined $value_ref ) {
        return 'No parse', 'Input read to end but no parse';
    }
    return [ return ${$value_ref}, 'Parse OK' ];
} ## end sub my_parser

# vim: expandtab shiftwidth=4:
