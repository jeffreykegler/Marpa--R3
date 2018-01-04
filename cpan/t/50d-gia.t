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

use Test::More tests => 110;
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

# Marpa::R3::Display

    my $expected_output = [
        [ 'sentence', [qw(so very special)] ],
        [ 'sentence',   [qw(I am special and nothing is going to change that)], ]
    ];

    my $grammar = Marpa::R3::Grammar->new(
        { source => \$source, ranking_method => 'high_rank_only' } );
    do_test( $grammar, $input, $expected_output,
        'Parse OK', 'Test of rank adverb for display' );
}

# Tests of rank adverb based on examples from Lukas Atkinson
# Here longest is highest rank, as in his original

if (1) {

    my $source = <<'END_OF_SOURCE';
  :discard ~ ws; ws ~ [\s]+
  :default ::= action => ::array

  Top ::= List action => main::group
  List ::= Item3 rank => 3
  List ::= Item2 rank => 2
  List ::= Item1 rank => 1
  List ::= List Item3 rank => 3
  List ::= List Item2 rank => 2
  List ::= List Item1 rank => 1
  Item3 ::= VAR '=' VAR action => main::concat
  Item2 ::= VAR '='     action => main::concat
  Item1 ::= VAR         action => main::concat
  VAR ~ [\w]+

END_OF_SOURCE

    my @tests = (
        [ 'a',                 '(a)', ],
        [ 'a = b',             '(a=b)', ],
        [ 'a = b = c',         '(a=)(b=c)', ],
        [ 'a = b = c = d',     '(a=)(b=)(c=d)', ],
        [ 'a = b c = d',       '(a=b)(c=d)' ],
        [ 'a = b c = d e =',   '(a=b)(c=d)(e=)' ],
        [ 'a = b c = d e',     '(a=b)(c=d)(e)' ],
        [ 'a = b c = d e = f', '(a=b)(c=d)(e=f)' ],
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

# Marpa::R3::Display
# name: Ranking, shortest highest, version 1
# start-after-line: END_OF_SOURCE
# end-before-line: '^END_OF_SOURCE$'

    my $source = <<'END_OF_SOURCE';
  :discard ~ ws; ws ~ [\s]+
  :default ::= action => ::array

  Top ::= List action => main::group
  List ::= Item3 rank => 1
  List ::= Item2 rank => 2
  List ::= Item1 rank => 3
  List ::= List Item3 rank => 1
  List ::= List Item2 rank => 2
  List ::= List Item1 rank => 3
  Item3 ::= VAR '=' VAR action => main::concat
  Item2 ::= VAR '='     action => main::concat
  Item1 ::= VAR         action => main::concat
  VAR ~ [\w]+

END_OF_SOURCE


# Marpa::R3::Display
# name: Ranking results, shortest highest, version 1

    my @tests = (
        [ 'a',                 '(a)', ],
        [ 'a = b',             '(a=)(b)', ],
        [ 'a = b = c',         '(a=)(b=)(c)', ],
        [ 'a = b = c = d',     '(a=)(b=)(c=)(d)', ],
        [ 'a = b c = d',       '(a=)(b)(c=)(d)' ],
        [ 'a = b c = d e =',   '(a=)(b)(c=)(d)(e=)' ],
        [ 'a = b c = d e',     '(a=)(b)(c=)(d)(e)' ],
        [ 'a = b c = d e = f', '(a=)(b)(c=)(d)(e=)(f)' ],
    );

# Marpa::R3::Display::End

    my $grammar = Marpa::R3::Grammar->new(
        { ranking_method => 'high_rank_only', source => \$source } );
    for my $test (@tests) {
        my ( $input, $output ) = @{$test};
        do_test( $grammar, $input, $output, 'Parse OK',
            qq{Test of rank by shortest: "$input"},
        );
    }
}

# Tests of rank adverb based on examples from Lukas Atkinson
# version 2
# Here longest is highest rank, as in his original

if (1) {

# Marpa::R3::Display
# name: Ranking, longest highest, version 2
# start-after-line: END_OF_SOURCE
# end-before-line: '^END_OF_SOURCE$'

    my $source = <<'END_OF_SOURCE';
  :discard ~ ws; ws ~ [\s]+
  :default ::= action => ::array

  Top ::= List action => main::group
  List ::= Item rank => 1
  List ::= List Item rank => 0
  Item ::= VAR '=' VAR rank => 3 action => main::concat
  Item ::= VAR '='     rank => 2 action => main::concat
  Item ::= VAR         rank => 1 action => main::concat
  VAR ~ [\w]+

END_OF_SOURCE

# Marpa::R3::Display::End

    my @tests = (
        [ 'a',                 '(a)', ],
        [ 'a = b',             '(a=b)', ],
        [ 'a = b = c',         '(a=)(b=c)', ],
        [ 'a = b = c = d',     '(a=)(b=)(c=d)', ],
        [ 'a = b c = d',       '(a=b)(c=d)' ],
        [ 'a = b c = d e =',   '(a=b)(c=d)(e=)' ],
        [ 'a = b c = d e',     '(a=b)(c=d)(e)' ],
        [ 'a = b c = d e = f', '(a=b)(c=d)(e=f)' ],
    );

    my $grammar = Marpa::R3::Grammar->new(
        { ranking_method => 'high_rank_only', source => \$source } );
    for my $test (@tests) {
        my ( $input, $output ) = @{$test};
        do_test( $grammar, $input, $output, 'Parse OK',
            qq{Test of rank by longest (v2): "$input"} );
    }
}

# Tests of rank adverb based on examples from Lukas Atkinson
# version 2
# Here *shortest* is highest rank

if (1) {

# Marpa::R3::Display
# name: Ranking, shortest highest, version 2
# start-after-line: END_OF_SOURCE
# end-before-line: '^END_OF_SOURCE$'

    my $source = <<'END_OF_SOURCE';
  :discard ~ ws; ws ~ [\s]+
  :default ::= action => ::array

  Top ::= List action => main::group
  List ::= Item rank => 0
  List ::= List Item rank => 1
  Item ::= VAR '=' VAR rank => 1 action => main::concat
  Item ::= VAR '='     rank => 2 action => main::concat
  Item ::= VAR         rank => 3 action => main::concat
  VAR ~ [\w]+

END_OF_SOURCE

# Marpa::R3::Display::End

    my @tests = (
        [ 'a',                 '(a)', ],
        [ 'a = b',             '(a=)(b)', ],
        [ 'a = b = c',         '(a=)(b=)(c)', ],
        [ 'a = b = c = d',     '(a=)(b=)(c=)(d)', ],
        [ 'a = b c = d',       '(a=)(b)(c=)(d)' ],
        [ 'a = b c = d e =',   '(a=)(b)(c=)(d)(e=)' ],
        [ 'a = b c = d e',     '(a=)(b)(c=)(d)(e)' ],
        [ 'a = b c = d e = f', '(a=)(b)(c=)(d)(e=)(f)' ],
    );

    my $grammar = Marpa::R3::Grammar->new(
        { ranking_method => 'high_rank_only', source => \$source } );
    for my $test (@tests) {
        my ( $input, $output ) = @{$test};
        do_test( $grammar, $input, $output, 'Parse OK',
            qq{Test of rank by shortest (v2): "$input"},
        );
    }
}

# Tests of rank adverb based on examples from Lukas Atkinson
# version 3: reimplemented via BNF
# Here longest is highest rank, as in his original

if (1) {

# Marpa::R3::Display
# name: Ranking via BNF, longest highest, version 3
# start-after-line: END_OF_SOURCE
# end-before-line: '^END_OF_SOURCE$'

    my $source = <<'END_OF_SOURCE';
  :discard ~ ws; ws ~ [\s]+
  :default ::= action => ::array

  Top            ::= Max_Boundeds action => main::group
  Top            ::= Max_Boundeds Unbounded action => main::group
  Top            ::= Unbounded action => main::group
  Max_Boundeds   ::= Max_Bounded+
  Max_Bounded    ::= Eq_Finals Var_Final3
  Max_Bounded    ::= Var_Final
  Unbounded      ::= Eq_Finals
  Eq_Finals      ::= Eq_Final+
  Var_Final      ::= Var_Final3 | Var_Final1
  Var_Final3     ::= VAR '=' VAR action => main::concat
  Eq_Final       ::= VAR '='     action => main::concat
  Var_Final1     ::= VAR         action => main::concat
  VAR ~ [\w]+

END_OF_SOURCE

# Marpa::R3::Display::End

    my @tests = (
        [ 'a',                 '(a)', ],
        [ 'a = b',             '(a=b)', ],
        [ 'a = b = c',         '(a=)(b=c)', ],
        [ 'a = b = c = d',     '(a=)(b=)(c=d)', ],
        [ 'a = b c = d',       '(a=b)(c=d)' ],
        [ 'a = b c = d e =',   '(a=b)(c=d)(e=)' ],
        [ 'a = b c = d e',     '(a=b)(c=d)(e)' ],
        [ 'a = b c = d e = f', '(a=b)(c=d)(e=f)' ],
    );

    my $grammar = Marpa::R3::Grammar->new(
        { ranking_method => 'high_rank_only', source => \$source } );
    for my $test (@tests) {
        my ( $input, $output ) = @{$test};
        do_test( $grammar, $input, $output, 'Parse OK',
            qq{Test of rank by longest (v3): "$input"} );
    }
}

# Tests of rank adverb based on examples from Lukas Atkinson
# version 3: reimplemented via BNF
# Here *shortest* is highest rank

if (1) {

# Marpa::R3::Display
# name: Ranking via BNF, shortest highest, version 3
# start-after-line: END_OF_SOURCE
# end-before-line: '^END_OF_SOURCE$'

    my $source = <<'END_OF_SOURCE';
  :discard ~ ws; ws ~ [\s]+
  :default ::= action => ::array

  Top            ::= Max_Boundeds action => main::group
  Top            ::= Max_Boundeds Unbounded action => main::group
  Top            ::= Unbounded action => main::group
  Max_Boundeds   ::= Max_Bounded+
  Max_Bounded    ::= Eq_Finals Var_Final
  Max_Bounded    ::= Var_Final
  Unbounded      ::= Eq_Finals
  Eq_Finals      ::= Eq_Final+
  Eq_Final       ::= VAR '='     action => main::concat
  Var_Final      ::= VAR         action => main::concat
  VAR ~ [\w]+

END_OF_SOURCE

# Marpa::R3::Display::End

    my @tests = (
        [ 'a',                 '(a)', ],
        [ 'a = b',             '(a=)(b)', ],
        [ 'a = b = c',         '(a=)(b=)(c)', ],
        [ 'a = b = c = d',     '(a=)(b=)(c=)(d)', ],
        [ 'a = b c = d',       '(a=)(b)(c=)(d)' ],
        [ 'a = b c = d e =',   '(a=)(b)(c=)(d)(e=)' ],
        [ 'a = b c = d e',     '(a=)(b)(c=)(d)(e)' ],
        [ 'a = b c = d e = f', '(a=)(b)(c=)(d)(e=)(f)' ],
    );

    my $grammar = Marpa::R3::Grammar->new(
        { ranking_method => 'high_rank_only', source => \$source } );
    for my $test (@tests) {
        my ( $input, $output ) = @{$test};
        do_test( $grammar, $input, $output, 'Parse OK',
            qq{Test of rank by shortest (v3): "$input"},
        );
    }
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
    a ::= 'a' action => ::first
    b ::= 'b' action => ::first
    c ::= 'c' action => ::first
END_OF_SOURCE

# Marpa::R3::Display::End

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
    my $value_ref = $recce->value();
    if ( not defined $value_ref ) {
        return 'No parse', 'Input read to end but no parse';
    }
    return [ return ${$value_ref}, 'Parse OK' ];
} ## end sub my_parser

sub flatten {
    my ($array) = @_;
    return [] if not defined $array;
    my $ref = ref $array;
    return [$array] if $ref ne 'ARRAY';
    my @flat = ();
    ELEMENT: for my $element (@{$array}) {
       my $ref = ref $element;
       if ($ref ne 'ARRAY') {
           push @flat, $element;
           next ELEMENT;
       }
       my $flat_piece = flatten($element);
       push @flat, @{$flat_piece};
    }
    return \@flat;
}

# For use as a parse action
sub concat {
    my ($pp, @args) = @_;
    # say STDERR 'concat: ', Data::Dumper::Dumper(\@args);
    my $flat = flatten(\@args);
    # say STDERR 'flat: ', Data::Dumper::Dumper($flat);
    return join '', @{$flat};
}

# For use as a parse action
sub group {
    my ($pp, @args) = @_;
    # say STDERR 'group args: ', Data::Dumper::Dumper(\@args);
    my $flat = flatten(\@args);
    # say STDERR 'flat: ', Data::Dumper::Dumper($flat);
    return join '', map { +'(' . $_ . ')'; } grep { defined } @{$flat};
}

# vim: expandtab shiftwidth=4:
