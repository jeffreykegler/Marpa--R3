#!/usr/bin/perl
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

# Synopsis for Valuer object

use 5.010001;
use strict;
use warnings;
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use Test::More tests => 11;

use lib 'inc';
use Marpa::R3::Test;

## no critic (ErrorHandling::RequireCarping);

# Marpa::R3::Display
# name: Valuer synopsis

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

my $grammar = Marpa::R3::Scanless::G->new(
    {
        semantics_package => 'My_Actions',
        source            => \$dsl
    }
);
my $recce       = Marpa::R3::Scanless::R->new( { grammar => $grammar } );
my $input       = '42 * 1 + 7';
my $length_read = $recce->read( \$input );

die "Read ended after $length_read of ", length $input, " characters"
    if $length_read != length $input;

my $valuer = Marpa::R3::Scanless::V->new( { recce => $recce } );
my $value_ref = $valuer->value();
my $value = ${$value_ref};

# Marpa::R3::Display::End

# Marpa::R3::Display
# name: Valuer semantics

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

Test::More::is( $value, 49, 'synopsis value' );

# Marpa::R3::Display
# name: Valuer ambiguity_level() synopsis

    my $ambiguity_level = $valuer->ambiguity_level();

# Marpa::R3::Display::End

Test::More::is( $ambiguity_level, 1, 'valuer synopsis ambiguity level' );

my $ambiguity_status;

# Marpa::R3::Display
# name: Valuer ambiguous() synopsis

    $ambiguity_status = $valuer->ambiguous();
    if ( $ambiguity_status ) {
        chomp $ambiguity_status;
        die "Parse is ambiguous\n", $ambiguity_status;
    }

# Marpa::R3::Display::End

Test::More::is( $ambiguity_status, "", 'valuer synopsis ambiguity status' );

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
S9 '*'
S10 '+'
S11 [\*]
S12 [\+]
S13 [\d]
S14 [\s]
S15 digits
S16 whitespace
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
R8 [:lex_start:] ~ Number
R9 [:lex_start:] ~ [:discard:]
R10 [:lex_start:] ~ '*'
R11 [:lex_start:] ~ '+'
R12 '*' ~ [\*]
R13 '+' ~ [\+]
R14 Number ~ digits
R15 digits ~ [\d] +
R16 [:discard:] ~ whitespace
R17 whitespace ~ [\s] +
END_RULES

my $ahms_show_output = $grammar->ahms_show();

Marpa::R3::Test::is( $ahms_show_output,
    <<'END_AHM', 'Implementation Example AHMs' );
AHM 0: postdot = "Expression"
    Calculator ::= . Expression
AHM 1: completion
    Calculator ::= Expression .
AHM 2: postdot = "Number"
    Factor ::= . Number
AHM 3: completion
    Factor ::= Number .
AHM 4: postdot = "Term"
    Term ::= . Term [Lex-0] Factor
AHM 5: postdot = "[Lex-0]"
    Term ::= Term . [Lex-0] Factor
AHM 6: postdot = "Factor"
    Term ::= Term [Lex-0] . Factor
AHM 7: completion
    Term ::= Term [Lex-0] Factor .
AHM 8: postdot = "Factor"
    Term ::= . Factor
AHM 9: completion
    Term ::= Factor .
AHM 10: postdot = "Expression"
    Expression ::= . Expression [Lex-1] Term
AHM 11: postdot = "[Lex-1]"
    Expression ::= Expression . [Lex-1] Term
AHM 12: postdot = "Term"
    Expression ::= Expression [Lex-1] . Term
AHM 13: completion
    Expression ::= Expression [Lex-1] Term .
AHM 14: postdot = "Term"
    Expression ::= . Term
AHM 15: completion
    Expression ::= Term .
AHM 16: postdot = "Calculator"
    [:start:] ::= . Calculator
AHM 17: completion
    [:start:] ::= Calculator .
AHM 18: postdot = "[:start:]"
    [:start:]['] ::= . [:start:]
AHM 19: completion
    [:start:]['] ::= [:start:] .
END_AHM

my $earley_sets_show_output = $recce->earley_sets_show();

my $expected_earley_sets = <<'END_EARLEY_SETS';
Last Completed: 5; Furthest: 5
Earley Set 0
ahm18: R7:0@0-0
  R7:0: [:start:]['] ::= . [:start:]
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
ahm19: R7$@0-1
  R7$: [:start:]['] ::= [:start:] .
  [p=R7:0@0-0; c=R6$@0-1]
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
ahm19: R7$@0-3
  R7$: [:start:]['] ::= [:start:] .
  [p=R7:0@0-0; c=R6$@0-3]
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
ahm19: R7$@0-5
  R7$: [:start:]['] ::= [:start:] .
  [p=R7:0@0-0; c=R6$@0-5]
END_EARLEY_SETS

Marpa::R3::Test::is( $earley_sets_show_output, $expected_earley_sets,
    'Implementation Example Earley Sets' );

# Marpa::R3::Display
# name: Valuer g1_pos() synopsis

my $end_of_parse = $valuer->g1_pos();

# Marpa::R3::Display::End

Marpa::R3::Test::is( $end_of_parse, 5, 'end of parse' );

$valuer = Marpa::R3::Scanless::V->new( { recce => $recce } );

my $trace_output;
open my $trace_fh, q{>}, \$trace_output;
$valuer->set( { trace_file_handle => $trace_fh } );

# Marpa::R3::Display
# name: Valuer set() synopsis

$valuer->set( { trace_values => 3 } );

# Marpa::R3::Display::End

$value_ref = $valuer->value();
$valuer->set( { trace_file_handle => \*STDOUT, trace_values => 0 } );
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
New Virtual Rule: R7:1@0-5C6@0, rule: 7: [:start:]['] ::= [:start:]
Real symbol count is 1
END_TRACE_OUTPUT

Marpa::R3::Test::is( $trace_output, $expected_trace_output,
    'Implementation Example Trace Output' );

$valuer = Marpa::R3::Scanless::V->new( { recce => $recce } );
$value_ref = $valuer->value();
$value = $value_ref ? ${$value_ref} : 'No Parse';
Marpa::R3::Test::is( 49, $value, 'Implementation Example Value 3' );

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
