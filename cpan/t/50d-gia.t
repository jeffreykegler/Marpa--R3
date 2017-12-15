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

use Test::More tests => 18;
use Data::Dumper;
use English qw( -no_match_vars );
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

my @tests_data = ();

our $DEBUG = 0;

# Marpa::R3::Display
# name: Case-insensitive characters examples
# start-after-line: END_OF_SOURCE
# end-before-line: '^END_OF_SOURCE$'

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

# Marpa::R3::Display::End

    do_test(
        $ic_grammar,
        'ChilD::BooK',
        [ 'ChilD', q{::}, 'BooK' ],
        'Parse OK',
        'Case insensitivity test'
        );
} ## end if (0)

# ===============

# Test of rank adverb
if (1) {

# Marpa::R3::Display
# name: rank adverb example
# start-after-line: END_OF_SOURCE
# end-before-line: '^END_OF_SOURCE$'

    my $source = <<'END_OF_SOURCE';
:start ::= externals
externals ::= external* action => [values]
external ::= special action => ::first
   | unspecial action => ::first
unspecial ::= ('I' 'am' 'special') words ('--' 'NOT!' ';') rank => 1
special ::= words (';') rank => -1
words ::= word* action => [values]

:discard ~ whitespace
whitespace ~ [\s]+
word ~ [\w!-]+
END_OF_SOURCE

    my $input = <<'END_OF_INPUT';
I am special so very special -- NOT!;
I am special and nothing is going to change that;
END_OF_INPUT

# Marpa::R3::Display

    my $expected_output = [
        [ 'unspecial', [qw(so very special)] ],
        [   'special',
            [qw(I am special and nothing is going to change that)],
        ]
    ];

    my $grammar = Marpa::R3::Grammar->new( { source => \$source } );
    do_test(
        $grammar, $input, $expected_output,
        'Parse OK', 'Test of rank adverb for display'
        );
}

# Test of 'symbol', 'name' array item descriptors
if (1) {

# Marpa::R3::Display
# name: symbol, name array descriptor example
# start-after-line: END_OF_SOURCE
# end-before-line: '^END_OF_SOURCE$'

    my $source = <<'END_OF_SOURCE';

    :default ::= action => [symbol, name, values]
    lexeme default = action => [symbol, name, value]
    start ::= number1 number2 name => top
    number1 ::= <forty two> name => 'number 1'
    number2 ::= <forty three> name => 'number 2'
    <forty two> ~ '42'
    <forty three> ~ '43'
END_OF_SOURCE

# Marpa::R3::Display::End

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

# Marpa::R3::Display
# name: inaccessible is ok statement
# start-after-line: END_OF_SOURCE
# end-before-line: '^END_OF_SOURCE$'

    my $source = <<'END_OF_SOURCE';

    inaccessible is ok by default

    :default ::= action => [values]
    start ::= stuff*
    stuff ::= a | b
    a ::= x action => ::first
    b ::= x action => ::first
    c ::= x action => ::first
    x ::= 'x'
END_OF_SOURCE

# Marpa::R3::Display::End

    my $input           = 'xx';
    my $expected_output = [
        [ [ 'x' ] ],
        [ [ 'x' ] ]
    ];

    my $grammar = Marpa::R3::Grammar->new( { source => \$source } );
    do_test(
        $grammar, $input, $expected_output,
        'Parse OK', qq{Test of "Inaccessible is ok"}
        );
}

if (1) {
    my $source = <<'END_OF_SOURCE';

    start ::= literals action => ::first
    literals ::= literal+ action => [values]

# Marpa::R3::Display
# name: eager lexeme example

    :lexeme ~ literal eager => 1

# Marpa::R3::Display::End

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

# Marpa::R3::Display
# name: eager discard example

    :discard ~ comment eager => 1

# Marpa::R3::Display::End

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

# Marpa::R3::Display
# name: SLG start_symbol_id() synopsis

    $start_id = $grammar->start_symbol_id();

# Marpa::R3::Display::End

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
    my $valuer = Marpa::R3::Valuer->new( { recognizer => $recce } );
    my $value_ref = $valuer->value();
    if ( not defined $value_ref ) {
        return 'No parse', 'Input read to end but no parse';
    }
    return [ return ${$value_ref}, 'Parse OK' ];
} ## end sub my_parser

# vim: expandtab shiftwidth=4:
