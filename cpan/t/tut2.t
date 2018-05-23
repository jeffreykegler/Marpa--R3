#!/usr/bin/perl
# Marpa::R3 is Copyright (C) 2018, Jeffrey Kegler.
#
# This module is free software; you can redistribute it and/or modify it
# under the same terms as Perl 5.10.1. For more details, see the full text
# of the licenses in the directory LICENSES.
#
# This program is distributed in the hope that it will be
# useful, but it is provided "as is" and without any express
# or implied warranties. For details, see the full text of
# of the licenses in the directory LICENSES.

# Note: Adds tests from implementation.t to this test test file

# Tutorial 2 synopsis

use 5.010001;
use strict;
use warnings;
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use Test::More tests => 8;

use lib 'inc';
use Marpa::R3::Test;

## no critic (ErrorHandling::RequireCarping);

# Marpa::R3::Display
# name: Tutorial 2 synopsis

use Marpa::R3;

my $dsl = <<'END_OF_DSL';

Calculator ::= Expression action => ::first

Factor ::= Number action => ::first
Term ::=
    Term '*' Factor action => do_multiply
    | Factor action => ::first
Expression ::=
    Expression '+' Term action => do_add
    | Term action => ::first
Number ~ digits
digits ~ [\d]+
:discard ~ whitespace
whitespace ~ [\s]+
END_OF_DSL

my $grammar = Marpa::R3::Grammar->new(
    {
        semantics_package => 'My_Actions',
        source            => \$dsl
    }
);
my $recce       = Marpa::R3::Recognizer->new( { grammar => $grammar } );
my $input       = '42 * 1 + 7';
my $length_read = $recce->read( \$input );

die "Read ended after $length_read of ", length $input, " characters"
    if $length_read != length $input;

my $value_ref = $recce->value();
die "No parse" if not $value_ref;
my $value = ${$value_ref};

sub My_Actions::do_add {
    my ( undef, $values ) = @_;
    my ( $t1, undef, $t2 ) = @{$values};
    return $t1 + $t2;
}

sub My_Actions::do_multiply {
    my ( undef, $values ) = @_;
    my ( $t1, undef, $t2 ) = @{$values};
    return $t1 * $t2;
}

# Marpa::R3::Display::End

Test::More::is( $value, 49, 'Tutorial 2 synopsis value' );

my $symbols_show_output = $grammar->symbols_show();

Marpa::R3::Test::is( $symbols_show_output,
    <<'END_SYMBOLS', 'Implementation Example Symbols' );
S1 Calculator
S2 Expression
S3 Factor
S4 Number
S5 Term
S6 [:discard:]
S7 [:lex_start:]
S8 [:start:]
S9 [:target:]
S10 '*'
S11 '+'
S12 [\*]
S13 [\+]
S14 [\d]
S15 [\s]
S16 digits
S17 whitespace
END_SYMBOLS

my $productions_show_output = $grammar->productions_show();

Marpa::R3::Test::is( $productions_show_output,
    <<'END_RULES', 'Implementation Example Productions' );
R1 [:start:] ::= Calculator
R2 Calculator ::= Expression
R3 Term ::= Factor
R4 Expression ::= Expression '+' Term
R5 Expression ::= Term
R6 Factor ::= Number
R7 Term ::= Term '*' Factor
R8 [:lex_start:] ~ [:target:]
R9 [:target:] ~ Number
R10 [:target:] ~ [:discard:]
R11 [:target:] ~ '*'
R12 [:target:] ~ '+'
R13 '*' ~ [\*]
R14 '+' ~ [\+]
R15 Number ~ digits
R16 digits ~ [\d] +
R17 [:discard:] ~ whitespace
R18 whitespace ~ [\s] +
END_RULES

my $ahms_show_output = $grammar->ahms_show();

Marpa::R3::Test::is( $ahms_show_output,
    <<'END_AHM', 'Implementation Example AHMs' );
AHM 0: dot=0; nulls=0
    Calculator ::= . Expression
AHM 1: completion; dot=1; nulls=0
    Calculator ::= Expression .
AHM 2: dot=0; nulls=0
    Factor ::= . Number
AHM 3: completion; dot=1; nulls=0
    Factor ::= Number .
AHM 4: dot=0; nulls=0
    Term ::= . Term [Lex-0] Factor
AHM 5: dot=1; nulls=0
    Term ::= Term . [Lex-0] Factor
AHM 6: dot=2; nulls=0
    Term ::= Term [Lex-0] . Factor
AHM 7: completion; dot=3; nulls=0
    Term ::= Term [Lex-0] Factor .
AHM 8: dot=0; nulls=0
    Term ::= . Factor
AHM 9: completion; dot=1; nulls=0
    Term ::= Factor .
AHM 10: dot=0; nulls=0
    Expression ::= . Expression [Lex-1] Term
AHM 11: dot=1; nulls=0
    Expression ::= Expression . [Lex-1] Term
AHM 12: dot=2; nulls=0
    Expression ::= Expression [Lex-1] . Term
AHM 13: completion; dot=3; nulls=0
    Expression ::= Expression [Lex-1] Term .
AHM 14: dot=0; nulls=0
    Expression ::= . Term
AHM 15: completion; dot=1; nulls=0
    Expression ::= Term .
AHM 16: dot=0; nulls=0
    [:start:] ::= . Calculator
AHM 17: completion; dot=1; nulls=0
    [:start:] ::= Calculator .
END_AHM

my $earley_sets_show_output = $recce->earley_sets_show();

my $expected_earley_sets = <<'END_EARLEY_SETS';
Last Completed: 5; Furthest: 5
Earley Set 0
ahm16: R6:0@0-0
  R6:0: [:start:] ::= . Calculator
ahm0: R0:0@0-0
  R0:0: Calculator ::= . Expression
ahm10: R4:0@0-0
  R4:0: Expression ::= . Expression [Lex-1] Term
ahm14: R5:0@0-0
  R5:0: Expression ::= . Term
ahm4: R2:0@0-0
  R2:0: Term ::= . Term [Lex-0] Factor
ahm8: R3:0@0-0
  R3:0: Term ::= . Factor
ahm2: R1:0@0-0
  R1:0: Factor ::= . Number
Earley Set 1
ahm3: R1$@0-1
  R1$: Factor ::= Number .
  [c=R1:0@0-0; s=Number; t=\'42']
ahm9: R3$@0-1
  R3$: Term ::= Factor .
  [p=R3:0@0-0; c=R1$@0-1]
ahm5: R2:1@0-1
  R2:1: Term ::= Term . [Lex-0] Factor
  [p=R2:0@0-0; c=R3$@0-1]
ahm15: R5$@0-1
  R5$: Expression ::= Term .
  [p=R5:0@0-0; c=R3$@0-1]
ahm11: R4:1@0-1
  R4:1: Expression ::= Expression . [Lex-1] Term
  [p=R4:0@0-0; c=R5$@0-1]
ahm1: R0$@0-1
  R0$: Calculator ::= Expression .
  [p=R0:0@0-0; c=R5$@0-1]
ahm17: R6$@0-1
  R6$: [:start:] ::= Calculator .
  [p=R6:0@0-0; c=R0$@0-1]
Earley Set 2
ahm6: R2:2@0-2
  R2:2: Term ::= Term [Lex-0] . Factor
  [c=R2:1@0-1; s=[Lex-0]; t=\'*']
ahm2: R1:0@2-2
  R1:0: Factor ::= . Number
Earley Set 3
ahm3: R1$@2-3
  R1$: Factor ::= Number .
  [c=R1:0@2-2; s=Number; t=\'1']
ahm7: R2$@0-3
  R2$: Term ::= Term [Lex-0] Factor .
  [p=R2:2@0-2; c=R1$@2-3]
ahm5: R2:1@0-3
  R2:1: Term ::= Term . [Lex-0] Factor
  [p=R2:0@0-0; c=R2$@0-3]
ahm15: R5$@0-3
  R5$: Expression ::= Term .
  [p=R5:0@0-0; c=R2$@0-3]
ahm11: R4:1@0-3
  R4:1: Expression ::= Expression . [Lex-1] Term
  [p=R4:0@0-0; c=R5$@0-3]
ahm1: R0$@0-3
  R0$: Calculator ::= Expression .
  [p=R0:0@0-0; c=R5$@0-3]
ahm17: R6$@0-3
  R6$: [:start:] ::= Calculator .
  [p=R6:0@0-0; c=R0$@0-3]
Earley Set 4
ahm12: R4:2@0-4
  R4:2: Expression ::= Expression [Lex-1] . Term
  [c=R4:1@0-3; s=[Lex-1]; t=\'+']
ahm2: R1:0@4-4
  R1:0: Factor ::= . Number
ahm4: R2:0@4-4
  R2:0: Term ::= . Term [Lex-0] Factor
ahm8: R3:0@4-4
  R3:0: Term ::= . Factor
Earley Set 5
ahm3: R1$@4-5
  R1$: Factor ::= Number .
  [c=R1:0@4-4; s=Number; t=\'7']
ahm9: R3$@4-5
  R3$: Term ::= Factor .
  [p=R3:0@4-4; c=R1$@4-5]
ahm5: R2:1@4-5
  R2:1: Term ::= Term . [Lex-0] Factor
  [p=R2:0@4-4; c=R3$@4-5]
ahm13: R4$@0-5
  R4$: Expression ::= Expression [Lex-1] Term .
  [p=R4:2@0-4; c=R3$@4-5]
ahm11: R4:1@0-5
  R4:1: Expression ::= Expression . [Lex-1] Term
  [p=R4:0@0-0; c=R4$@0-5]
ahm1: R0$@0-5
  R0$: Calculator ::= Expression .
  [p=R0:0@0-0; c=R4$@0-5]
ahm17: R6$@0-5
  R6$: [:start:] ::= Calculator .
  [p=R6:0@0-0; c=R0$@0-5]
END_EARLEY_SETS

Marpa::R3::Test::is( $earley_sets_show_output, $expected_earley_sets,
    'Implementation Example Earley Sets' );

my $trace_output;
open my $trace_fh, q{>}, \$trace_output;
$recce->set( { trace_file_handle => $trace_fh, trace_values => 3 } );
$value_ref = $recce->value();
$recce->set( { trace_file_handle => \*STDOUT, trace_values => 0 } );
close $trace_fh;

$value = $value_ref ? ${$value_ref} : 'No Parse';
Marpa::R3::Test::is( 49, $value, 'Implementation Example Value 2' );

my $expected_trace_output = <<'END_TRACE_OUTPUT';
Setting trace_values option to 3
valuator trace level: 3
starting op MARPA_STEP_TOKEN lua
starting lua op MARPA_STEP_TOKEN result_is_token_value
starting op MARPA_STEP_RULE lua
starting lua op MARPA_STEP_RULE result_is_n_of_rhs
starting op MARPA_STEP_RULE lua
starting lua op MARPA_STEP_RULE result_is_n_of_rhs
starting op MARPA_STEP_TOKEN lua
starting lua op MARPA_STEP_TOKEN result_is_token_value
starting op MARPA_STEP_TOKEN lua
starting lua op MARPA_STEP_TOKEN result_is_token_value
starting op MARPA_STEP_RULE lua
starting lua op MARPA_STEP_RULE result_is_n_of_rhs
starting op MARPA_STEP_RULE lua
starting lua op MARPA_STEP_RULE push_one
starting op MARPA_STEP_RULE lua
starting lua op MARPA_STEP_RULE push_one
starting op MARPA_STEP_RULE lua
starting lua op MARPA_STEP_RULE push_one
starting op MARPA_STEP_RULE lua
starting lua op MARPA_STEP_RULE callback
Popping 3 values to evaluate R2:3@0-3C1@2, rule: Term ::= Term '*' Factor
Calculated and pushed value: 42
starting op MARPA_STEP_RULE lua
starting lua op MARPA_STEP_RULE result_is_n_of_rhs
starting op MARPA_STEP_TOKEN lua
starting lua op MARPA_STEP_TOKEN result_is_token_value
starting op MARPA_STEP_TOKEN lua
starting lua op MARPA_STEP_TOKEN result_is_token_value
starting op MARPA_STEP_RULE lua
starting lua op MARPA_STEP_RULE result_is_n_of_rhs
starting op MARPA_STEP_RULE lua
starting lua op MARPA_STEP_RULE result_is_n_of_rhs
starting op MARPA_STEP_RULE lua
starting lua op MARPA_STEP_RULE push_one
starting op MARPA_STEP_RULE lua
starting lua op MARPA_STEP_RULE push_one
starting op MARPA_STEP_RULE lua
starting lua op MARPA_STEP_RULE push_one
starting op MARPA_STEP_RULE lua
starting lua op MARPA_STEP_RULE callback
Popping 3 values to evaluate R4:3@0-5C3@4, rule: Expression ::= Expression '+' Term
Calculated and pushed value: 49
starting op MARPA_STEP_RULE lua
starting lua op MARPA_STEP_RULE result_is_n_of_rhs
starting op MARPA_STEP_RULE lua
starting lua op MARPA_STEP_RULE result_is_n_of_rhs
END_TRACE_OUTPUT

Marpa::R3::Test::is( $trace_output, $expected_trace_output,
    'Implementation Example Trace Output' );

$value_ref = $recce->value();
$value = $value_ref ? ${$value_ref} : 'No Parse';
Marpa::R3::Test::is( 49, $value, 'Implementation Example Value 3' );

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
