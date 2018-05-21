#!perl
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

# Replaces jirotka.t from Marpa::R2

use 5.010001;

use strict;
use warnings;

use Data::Dumper;
use English qw( -no_match_vars );
use Fatal qw( close open );
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use Test::More tests => 7;
use lib 'inc';
use Marpa::R3::Test;

use Marpa::R3;

# Regression test for bug originally found and documented
# by Tomas Jirotka

my $grammar = Marpa::R3::Grammar->new(
    {
        semantics_package => 'Maql_Actions',
        source            => \<<'END_OF_DSL',
:default ::= action => Maql_Actions::tisk

Input ::= Statement+ separator => SEPARATOR
Statement ::= CREATE TypeDef
TypeDef ::= METRIC ID_METRIC AS MetricSelect
MetricSelect ::= SELECT MetricExpr ByClause Match Filter WithPf
MetricExpr ::= NUMBER
############################################################################
ByClause ::= action => ::undef
ByClause ::= BY
############################################################################
Match ::= action => ::undef
Match ::= FOR
#############################################################################
Filter ::= action => ::undef
Filter ::= WHERE FilterExpr
FilterExpr ::= TRUE
FilterExpr ::= FALSE
#############################################################################
WithPf ::= action => ::undef
WithPf ::= WITH PF
#############################################################################
CREATE ~ 'Create'
METRIC ~ 'Metric'
ID_METRIC ~ 'm'
AS ~ 'As'
SELECT ~ 'Select'
NUMBER ~ '1'
WHERE ~ 'Where'
WITH ~ 'With'
FOR ~ 'For'
TRUE ~ 'True'
BY ~ 'By'
FALSE ~ 'False'
SEPARATOR ~ '\n' # is this it?
PF ~ 'Pf'

:discard ~ whitespace
whitespace ~ [\s]+

END_OF_DSL
    }
);

my $input = q{Create Metric m As Select 1 Where True};

Marpa::R3::Test::is(
    $grammar->symbols_show(),
    <<'END_OF_SYMBOLS', 'Symbols' );
S1 AS
S2 BY
S3 ByClause
S4 CREATE
S5 FALSE
S6 FOR
S7 Filter
S8 FilterExpr
S9 ID_METRIC
S10 Input
S11 METRIC
S12 Match
S13 MetricExpr
S14 MetricSelect
S15 NUMBER
S16 PF
S17 SELECT
S18 SEPARATOR
S19 Statement
S20 TRUE
S21 TypeDef
S22 WHERE
S23 WITH
S24 WithPf
S25 [:discard:]
S26 [:lex_start:]
S27 [:start:]
S28 [:target:]
S29 [1]
S30 [A]
S31 [B]
S32 [C]
S33 [F]
S34 [M]
S35 [P]
S36 [S]
S37 [T]
S38 [W]
S39 [\\]
S40 [\s]
S41 [a]
S42 [c]
S43 [e]
S44 [f]
S45 [h]
S46 [i]
S47 [l]
S48 [m]
S49 [n]
S50 [o]
S51 [r]
S52 [s]
S53 [t]
S54 [u]
S55 [y]
S56 whitespace
END_OF_SYMBOLS

Marpa::R3::Test::is( $grammar->productions_show(),
<<'END_OF_RULES', 'Productions' );
R1 [:start:] ::= Input
R2 TypeDef ::= METRIC ID_METRIC AS MetricSelect
R3 MetricSelect ::= SELECT MetricExpr ByClause Match Filter WithPf
R4 MetricExpr ::= NUMBER
R5 ByClause ::=
R6 ByClause ::= BY
R7 Input ::= Statement +
R8 Match ::=
R9 Match ::= FOR
R10 Filter ::=
R11 Filter ::= WHERE FilterExpr
R12 FilterExpr ::= TRUE
R13 FilterExpr ::= FALSE
R14 WithPf ::=
R15 WithPf ::= WITH PF
R16 Statement ::= CREATE TypeDef
R17 [:lex_start:] ~ [:target:]
R18 [:target:] ~ AS
R19 [:target:] ~ BY
R20 [:target:] ~ CREATE
R21 [:target:] ~ FALSE
R22 [:target:] ~ FOR
R23 [:target:] ~ ID_METRIC
R24 [:target:] ~ METRIC
R25 [:target:] ~ NUMBER
R26 [:target:] ~ PF
R27 [:target:] ~ SELECT
R28 [:target:] ~ SEPARATOR
R29 [:target:] ~ TRUE
R30 [:target:] ~ WHERE
R31 [:target:] ~ WITH
R32 [:target:] ~ [:discard:]
R33 TRUE ~ [T] [r] [u] [e]
R34 BY ~ [B] [y]
R35 FALSE ~ [F] [a] [l] [s] [e]
R36 SEPARATOR ~ [\\] [n]
R37 PF ~ [P] [f]
R38 [:discard:] ~ whitespace
R39 whitespace ~ [\s] +
R40 CREATE ~ [C] [r] [e] [a] [t] [e]
R41 METRIC ~ [M] [e] [t] [r] [i] [c]
R42 ID_METRIC ~ [m]
R43 AS ~ [A] [s]
R44 SELECT ~ [S] [e] [l] [e] [c] [t]
R45 NUMBER ~ [1]
R46 WHERE ~ [W] [h] [e] [r] [e]
R47 WITH ~ [W] [i] [t] [h]
R48 FOR ~ [F] [o] [r]
END_OF_RULES

Marpa::R3::Test::is( $grammar->ahms_show(),
    <<'END_OF_AHMS', 'AHMs' );
AHM 0: dot=0; nulls=0
    Input ::= . Input[Seq]
AHM 1: completion; dot=1; nulls=0
    Input ::= Input[Seq] .
AHM 2: dot=0; nulls=0
    Input ::= . Input[Seq] SEPARATOR
AHM 3: dot=1; nulls=0
    Input ::= Input[Seq] . SEPARATOR
AHM 4: completion; dot=2; nulls=0
    Input ::= Input[Seq] SEPARATOR .
AHM 5: dot=0; nulls=0
    Input[Seq] ::= . Statement
AHM 6: completion; dot=1; nulls=0
    Input[Seq] ::= Statement .
AHM 7: dot=0; nulls=0
    Input[Seq] ::= . Input[Seq] SEPARATOR Statement
AHM 8: dot=1; nulls=0
    Input[Seq] ::= Input[Seq] . SEPARATOR Statement
AHM 9: dot=2; nulls=0
    Input[Seq] ::= Input[Seq] SEPARATOR . Statement
AHM 10: completion; dot=3; nulls=0
    Input[Seq] ::= Input[Seq] SEPARATOR Statement .
AHM 11: dot=0; nulls=0
    Statement ::= . CREATE TypeDef
AHM 12: dot=1; nulls=0
    Statement ::= CREATE . TypeDef
AHM 13: completion; dot=2; nulls=0
    Statement ::= CREATE TypeDef .
AHM 14: dot=0; nulls=0
    TypeDef ::= . METRIC ID_METRIC AS MetricSelect
AHM 15: dot=1; nulls=0
    TypeDef ::= METRIC . ID_METRIC AS MetricSelect
AHM 16: dot=2; nulls=0
    TypeDef ::= METRIC ID_METRIC . AS MetricSelect
AHM 17: dot=3; nulls=0
    TypeDef ::= METRIC ID_METRIC AS . MetricSelect
AHM 18: completion; dot=4; nulls=0
    TypeDef ::= METRIC ID_METRIC AS MetricSelect .
AHM 19: dot=0; nulls=0
    MetricSelect ::= . SELECT MetricExpr ByClause MetricSelect[R3:3]
AHM 20: dot=1; nulls=0
    MetricSelect ::= SELECT . MetricExpr ByClause MetricSelect[R3:3]
AHM 21: dot=2; nulls=0
    MetricSelect ::= SELECT MetricExpr . ByClause MetricSelect[R3:3]
AHM 22: dot=3; nulls=0
    MetricSelect ::= SELECT MetricExpr ByClause . MetricSelect[R3:3]
AHM 23: completion; dot=4; nulls=0
    MetricSelect ::= SELECT MetricExpr ByClause MetricSelect[R3:3] .
AHM 24: dot=0; nulls=0
    MetricSelect ::= . SELECT MetricExpr ByClause Match[] Filter[] WithPf[]
AHM 25: dot=1; nulls=0
    MetricSelect ::= SELECT . MetricExpr ByClause Match[] Filter[] WithPf[]
AHM 26: dot=2; nulls=0
    MetricSelect ::= SELECT MetricExpr . ByClause Match[] Filter[] WithPf[]
AHM 27: completion; dot=6; nulls=3
    MetricSelect ::= SELECT MetricExpr ByClause Match[] Filter[] WithPf[] .
AHM 28: dot=0; nulls=0
    MetricSelect ::= . SELECT MetricExpr ByClause[] MetricSelect[R3:3]
AHM 29: dot=1; nulls=0
    MetricSelect ::= SELECT . MetricExpr ByClause[] MetricSelect[R3:3]
AHM 30: dot=3; nulls=1
    MetricSelect ::= SELECT MetricExpr ByClause[] . MetricSelect[R3:3]
AHM 31: completion; dot=4; nulls=0
    MetricSelect ::= SELECT MetricExpr ByClause[] MetricSelect[R3:3] .
AHM 32: dot=0; nulls=0
    MetricSelect ::= . SELECT MetricExpr ByClause[] Match[] Filter[] WithPf[]
AHM 33: dot=1; nulls=0
    MetricSelect ::= SELECT . MetricExpr ByClause[] Match[] Filter[] WithPf[]
AHM 34: completion; dot=6; nulls=4
    MetricSelect ::= SELECT MetricExpr ByClause[] Match[] Filter[] WithPf[] .
AHM 35: dot=0; nulls=0
    MetricSelect[R3:3] ::= . Match MetricSelect[R3:4]
AHM 36: dot=1; nulls=0
    MetricSelect[R3:3] ::= Match . MetricSelect[R3:4]
AHM 37: completion; dot=2; nulls=0
    MetricSelect[R3:3] ::= Match MetricSelect[R3:4] .
AHM 38: dot=0; nulls=0
    MetricSelect[R3:3] ::= . Match Filter[] WithPf[]
AHM 39: completion; dot=3; nulls=2
    MetricSelect[R3:3] ::= Match Filter[] WithPf[] .
AHM 40: dot=1; nulls=1
    MetricSelect[R3:3] ::= Match[] . MetricSelect[R3:4]
AHM 41: completion; dot=2; nulls=0
    MetricSelect[R3:3] ::= Match[] MetricSelect[R3:4] .
AHM 42: dot=0; nulls=0
    MetricSelect[R3:4] ::= . Filter WithPf
AHM 43: dot=1; nulls=0
    MetricSelect[R3:4] ::= Filter . WithPf
AHM 44: completion; dot=2; nulls=0
    MetricSelect[R3:4] ::= Filter WithPf .
AHM 45: dot=0; nulls=0
    MetricSelect[R3:4] ::= . Filter WithPf[]
AHM 46: completion; dot=2; nulls=1
    MetricSelect[R3:4] ::= Filter WithPf[] .
AHM 47: dot=1; nulls=1
    MetricSelect[R3:4] ::= Filter[] . WithPf
AHM 48: completion; dot=2; nulls=0
    MetricSelect[R3:4] ::= Filter[] WithPf .
AHM 49: dot=0; nulls=0
    MetricExpr ::= . NUMBER
AHM 50: completion; dot=1; nulls=0
    MetricExpr ::= NUMBER .
AHM 51: dot=0; nulls=0
    ByClause ::= . BY
AHM 52: completion; dot=1; nulls=0
    ByClause ::= BY .
AHM 53: dot=0; nulls=0
    Match ::= . FOR
AHM 54: completion; dot=1; nulls=0
    Match ::= FOR .
AHM 55: dot=0; nulls=0
    Filter ::= . WHERE FilterExpr
AHM 56: dot=1; nulls=0
    Filter ::= WHERE . FilterExpr
AHM 57: completion; dot=2; nulls=0
    Filter ::= WHERE FilterExpr .
AHM 58: dot=0; nulls=0
    FilterExpr ::= . TRUE
AHM 59: completion; dot=1; nulls=0
    FilterExpr ::= TRUE .
AHM 60: dot=0; nulls=0
    FilterExpr ::= . FALSE
AHM 61: completion; dot=1; nulls=0
    FilterExpr ::= FALSE .
AHM 62: dot=0; nulls=0
    WithPf ::= . WITH PF
AHM 63: dot=1; nulls=0
    WithPf ::= WITH . PF
AHM 64: completion; dot=2; nulls=0
    WithPf ::= WITH PF .
AHM 65: dot=0; nulls=0
    [:start:] ::= . Input
AHM 66: completion; dot=1; nulls=0
    [:start:] ::= Input .
AHM 67: dot=0; nulls=0
    [:start:]['] ::= . [:start:]
AHM 68: completion; dot=1; nulls=0
    [:start:]['] ::= [:start:] .
END_OF_AHMS

my $recce = Marpa::R3::Recognizer->new( { grammar => $grammar } );
$recce->read( \$input );
my $valuer = Marpa::R3::Valuer->new( { recognizer => $recce } );
my $value_ref = $valuer->value();

Marpa::R3::Test::is( $recce->earley_sets_show(),
    <<'END_OF_EARLEY_SETS', 'Earley Sets' );
Last Completed: 8; Furthest: 8
Earley Set 0
ahm67: R24:0@0-0
  R24:0: [:start:]['] ::= . [:start:]
ahm65: R23:0@0-0
  R23:0: [:start:] ::= . Input
ahm0: R0:0@0-0
  R0:0: Input ::= . Input[Seq]
ahm2: R1:0@0-0
  R1:0: Input ::= . Input[Seq] SEPARATOR
ahm5: R2:0@0-0
  R2:0: Input[Seq] ::= . Statement
ahm7: R3:0@0-0
  R3:0: Input[Seq] ::= . Input[Seq] SEPARATOR Statement
ahm11: R4:0@0-0
  R4:0: Statement ::= . CREATE TypeDef
Earley Set 1
ahm12: R4:1@0-1
  R4:1: Statement ::= CREATE . TypeDef
  [c=R4:0@0-0; s=CREATE; t=\'Create']
ahm14: R5:0@1-1
  R5:0: TypeDef ::= . METRIC ID_METRIC AS MetricSelect
Earley Set 2
ahm15: R5:1@1-2
  R5:1: TypeDef ::= METRIC . ID_METRIC AS MetricSelect
  [c=R5:0@1-1; s=METRIC; t=\'Metric']
Earley Set 3
ahm16: R5:2@1-3
  R5:2: TypeDef ::= METRIC ID_METRIC . AS MetricSelect
  [c=R5:1@1-2; s=ID_METRIC; t=\'m']
Earley Set 4
ahm17: R5:3@1-4
  R5:3: TypeDef ::= METRIC ID_METRIC AS . MetricSelect
  [c=R5:2@1-3; s=AS; t=\'As']
ahm19: R6:0@4-4
  R6:0: MetricSelect ::= . SELECT MetricExpr ByClause MetricSelect[R3:3]
ahm24: R7:0@4-4
  R7:0: MetricSelect ::= . SELECT MetricExpr ByClause Match[] Filter[] WithPf[]
ahm28: R8:0@4-4
  R8:0: MetricSelect ::= . SELECT MetricExpr ByClause[] MetricSelect[R3:3]
ahm32: R9:0@4-4
  R9:0: MetricSelect ::= . SELECT MetricExpr ByClause[] Match[] Filter[] WithPf[]
Earley Set 5
ahm33: R9:1@4-5
  R9:1: MetricSelect ::= SELECT . MetricExpr ByClause[] Match[] Filter[] WithPf[]
  [c=R9:0@4-4; s=SELECT; t=\'Select']
ahm29: R8:1@4-5
  R8:1: MetricSelect ::= SELECT . MetricExpr ByClause[] MetricSelect[R3:3]
  [c=R8:0@4-4; s=SELECT; t=\'Select']
ahm25: R7:1@4-5
  R7:1: MetricSelect ::= SELECT . MetricExpr ByClause Match[] Filter[] WithPf[]
  [c=R7:0@4-4; s=SELECT; t=\'Select']
ahm20: R6:1@4-5
  R6:1: MetricSelect ::= SELECT . MetricExpr ByClause MetricSelect[R3:3]
  [c=R6:0@4-4; s=SELECT; t=\'Select']
ahm49: R16:0@5-5
  R16:0: MetricExpr ::= . NUMBER
Earley Set 6
ahm50: R16$@5-6
  R16$: MetricExpr ::= NUMBER .
  [c=R16:0@5-5; s=NUMBER; t=\'1']
ahm21: R6:2@4-6
  R6:2: MetricSelect ::= SELECT MetricExpr . ByClause MetricSelect[R3:3]
  [p=R6:1@4-5; c=R16$@5-6]
ahm26: R7:2@4-6
  R7:2: MetricSelect ::= SELECT MetricExpr . ByClause Match[] Filter[] WithPf[]
  [p=R7:1@4-5; c=R16$@5-6]
ahm30: R8:3@4-6
  R8:3: MetricSelect ::= SELECT MetricExpr ByClause[] . MetricSelect[R3:3]
  [p=R8:1@4-5; c=R16$@5-6]
ahm34: R9$@4-6
  R9$: MetricSelect ::= SELECT MetricExpr ByClause[] Match[] Filter[] WithPf[] .
  [p=R9:1@4-5; c=R16$@5-6]
ahm18: R5$@1-6
  R5$: TypeDef ::= METRIC ID_METRIC AS MetricSelect .
  [p=R5:3@1-4; c=R9$@4-6]
ahm13: R4$@0-6
  R4$: Statement ::= CREATE TypeDef .
  [p=R4:1@0-1; c=R5$@1-6]
ahm6: R2$@0-6
  R2$: Input[Seq] ::= Statement .
  [p=R2:0@0-0; c=R4$@0-6]
ahm8: R3:1@0-6
  R3:1: Input[Seq] ::= Input[Seq] . SEPARATOR Statement
  [p=R3:0@0-0; c=R2$@0-6]
ahm3: R1:1@0-6
  R1:1: Input ::= Input[Seq] . SEPARATOR
  [p=R1:0@0-0; c=R2$@0-6]
ahm1: R0$@0-6
  R0$: Input ::= Input[Seq] .
  [p=R0:0@0-0; c=R2$@0-6]
ahm66: R23$@0-6
  R23$: [:start:] ::= Input .
  [p=R23:0@0-0; c=R0$@0-6]
ahm68: R24$@0-6
  R24$: [:start:]['] ::= [:start:] .
  [p=R24:0@0-0; c=R23$@0-6]
ahm51: R17:0@6-6
  R17:0: ByClause ::= . BY
ahm35: R10:0@6-6
  R10:0: MetricSelect[R3:3] ::= . Match MetricSelect[R3:4]
ahm38: R11:0@6-6
  R11:0: MetricSelect[R3:3] ::= . Match Filter[] WithPf[]
ahm40: R12:1@6-6
  R12:1: MetricSelect[R3:3] ::= Match[] . MetricSelect[R3:4]
ahm42: R13:0@6-6
  R13:0: MetricSelect[R3:4] ::= . Filter WithPf
ahm45: R14:0@6-6
  R14:0: MetricSelect[R3:4] ::= . Filter WithPf[]
ahm47: R15:1@6-6
  R15:1: MetricSelect[R3:4] ::= Filter[] . WithPf
ahm53: R18:0@6-6
  R18:0: Match ::= . FOR
ahm55: R19:0@6-6
  R19:0: Filter ::= . WHERE FilterExpr
ahm62: R22:0@6-6
  R22:0: WithPf ::= . WITH PF
Earley Set 7
ahm56: R19:1@6-7
  R19:1: Filter ::= WHERE . FilterExpr
  [c=R19:0@6-6; s=WHERE; t=\'Where']
ahm58: R20:0@7-7
  R20:0: FilterExpr ::= . TRUE
ahm60: R21:0@7-7
  R21:0: FilterExpr ::= . FALSE
Earley Set 8
ahm59: R20$@7-8
  R20$: FilterExpr ::= TRUE .
  [c=R20:0@7-7; s=TRUE; t=\'True']
ahm57: R19$@6-8
  R19$: Filter ::= WHERE FilterExpr .
  [p=R19:1@6-7; c=R20$@7-8]
ahm46: R14$@6-8
  R14$: MetricSelect[R3:4] ::= Filter WithPf[] .
  [p=R14:0@6-6; c=R19$@6-8]
ahm43: R13:1@6-8
  R13:1: MetricSelect[R3:4] ::= Filter . WithPf
  [p=R13:0@6-6; c=R19$@6-8]
ahm41: R12$@6-8
  R12$: MetricSelect[R3:3] ::= Match[] MetricSelect[R3:4] .
  [p=R12:1@6-6; c=R14$@6-8]
ahm31: R8$@4-8
  R8$: MetricSelect ::= SELECT MetricExpr ByClause[] MetricSelect[R3:3] .
  [p=R8:3@4-6; c=R12$@6-8]
ahm18: R5$@1-8
  R5$: TypeDef ::= METRIC ID_METRIC AS MetricSelect .
  [p=R5:3@1-4; c=R8$@4-8]
ahm13: R4$@0-8
  R4$: Statement ::= CREATE TypeDef .
  [p=R4:1@0-1; c=R5$@1-8]
ahm6: R2$@0-8
  R2$: Input[Seq] ::= Statement .
  [p=R2:0@0-0; c=R4$@0-8]
ahm8: R3:1@0-8
  R3:1: Input[Seq] ::= Input[Seq] . SEPARATOR Statement
  [p=R3:0@0-0; c=R2$@0-8]
ahm3: R1:1@0-8
  R1:1: Input ::= Input[Seq] . SEPARATOR
  [p=R1:0@0-0; c=R2$@0-8]
ahm1: R0$@0-8
  R0$: Input ::= Input[Seq] .
  [p=R0:0@0-0; c=R2$@0-8]
ahm66: R23$@0-8
  R23$: [:start:] ::= Input .
  [p=R23:0@0-0; c=R0$@0-8]
ahm68: R24$@0-8
  R24$: [:start:]['] ::= [:start:] .
  [p=R24:0@0-0; c=R23$@0-8]
ahm62: R22:0@8-8
  R22:0: WithPf ::= . WITH PF
END_OF_EARLEY_SETS

Marpa::R3::Test::is( $valuer->and_nodes_show(),
        <<'END_OF_AND_NODES', 'And Nodes' );
And-node #0: R4:1@0-1S4@0
And-node #19: R0:1@0-8C2@0
And-node #18: R2:1@0-8C4@0
And-node #17: R4:2@0-8C5@1
And-node #20: R23:1@0-8C0@0
And-node #21: R24:1@0-8C23@0
And-node #1: R5:1@1-2S12@1
And-node #2: R5:2@1-3S10@2
And-node #3: R5:3@1-4S0@3
And-node #16: R5:4@1-8C8@4
And-node #4: R8:1@4-5S19@4
And-node #6: R8:2@4-6C16@5
And-node #7: R8:3@4-6S3@6
And-node #15: R8:4@4-8C12@6
And-node #5: R16:1@5-6S17@5
And-node #8: R12:1@6-6S14@6
And-node #9: R19:1@6-7S24@6
And-node #14: R12:2@6-8C14@6
And-node #12: R14:1@6-8C19@6
And-node #13: R14:2@6-8S27@8
And-node #11: R19:2@6-8C20@7
And-node #10: R20:1@7-8S22@7
END_OF_AND_NODES

Marpa::R3::Test::is( $valuer->or_nodes_show(),
        <<'END_OF_OR_NODES', 'Or Nodes' );
R4:1@0-1
R0:1@0-8
R2:1@0-8
R4:2@0-8
R23:1@0-8
R24:1@0-8
R5:1@1-2
R5:2@1-3
R5:3@1-4
R5:4@1-8
R8:1@4-5
R8:2@4-6
R8:3@4-6
R8:4@4-8
R16:1@5-6
R12:1@6-6
R19:1@6-7
R12:2@6-8
R14:1@6-8
R14:2@6-8
R19:2@6-8
R20:1@7-8
END_OF_OR_NODES

my $expected_value = [
    [
        'Create',
        [
            'Metric',
            'm',
            'As',
            [ 'Select', [ '1' ], undef, undef, [ 'Where', [ 'True' ] ], undef ]
        ]
    ]
];
Marpa::R3::Test::is( Dumper( ${$value_ref} ), Dumper($expected_value), 'Result' );

#############################################################################
package Maql_Actions;

sub new { }

sub tisk { return $_[1]; }

# vim: expandtab shiftwidth=4:
