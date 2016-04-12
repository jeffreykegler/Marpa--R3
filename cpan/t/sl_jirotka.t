#!perl
# Copyright 2016 Jeffrey Kegler
# This file is part of Marpa::R3.  Marpa::R3 is free software: you can
# redistribute it and/or modify it under the terms of the GNU Lesser
# General Public License as published by the Free Software Foundation,
# either version 3 of the License, or (at your option) any later version.
#
# Marpa::R3 is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser
# General Public License along with Marpa::R3.  If not, see
# http://www.gnu.org/licenses/.

# CENSUS: REWORK
# Note: Create an sl_jirotka.t, then mark this for deletion
#

use 5.010001;
use strict;
use warnings;

use Test::More tests => 7;

use lib 'inc';
use Marpa::R3::Test;

use Data::Dumper;
use English qw( -no_match_vars );
use Fatal qw( close open );
use Marpa::R3;

# Regression test for bug originally found and documented
# by Tomas Jirotka

my $grammar = Marpa::R3::Scanless::G->new(
	{
		source => \<<'END_OF_DSL',
Input ::= Statement+ separator => SEPARATOR
Statement ::= CREATE TypeDef
TypeDef ::= METRIC ID_METRIC AS MetricSelect
MetricSelect ::= SELECT MetricExpr ByClause Match Filter WithPf
MetricExpr ::= NUMBER
############################################################################
ByClause ::=
ByClause ::= BY
############################################################################
Match ::=
Match ::= FOR
#############################################################################
Filter ::=
Filter ::= WHERE FilterExpr
FilterExpr ::= TRUE
FilterExpr ::= FALSE
#############################################################################
WithPf ::=
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
    $grammar->show_symbols(),
    <<'END_OF_SYMBOLS', 'Symbols' );
END_OF_SYMBOLS

Marpa::R3::Test::is( $grammar->show_rules(),
<<'END_OF_RULES', 'Rules' );
END_OF_RULES

Marpa::R3::Test::is( $grammar->show_ahms(),
    <<'END_OF_AHMS', 'AHMs' );
AHM 0: postdot = "Input[Seq]"
    Input ::= . Input[Seq]
AHM 1: completion
    Input ::= Input[Seq] .
AHM 2: postdot = "Input[Seq]"
    Input ::= . Input[Seq] SEPARATOR
AHM 3: postdot = "SEPARATOR"
    Input ::= Input[Seq] . SEPARATOR
AHM 4: completion
    Input ::= Input[Seq] SEPARATOR .
AHM 5: postdot = "Statement"
    Input[Seq] ::= . Statement
AHM 6: completion
    Input[Seq] ::= Statement .
AHM 7: postdot = "Input[Seq]"
    Input[Seq] ::= . Input[Seq] SEPARATOR Statement
AHM 8: postdot = "SEPARATOR"
    Input[Seq] ::= Input[Seq] . SEPARATOR Statement
AHM 9: postdot = "Statement"
    Input[Seq] ::= Input[Seq] SEPARATOR . Statement
AHM 10: completion
    Input[Seq] ::= Input[Seq] SEPARATOR Statement .
AHM 11: postdot = "CREATE"
    Statement ::= . CREATE TypeDef
AHM 12: postdot = "TypeDef"
    Statement ::= CREATE . TypeDef
AHM 13: completion
    Statement ::= CREATE TypeDef .
AHM 14: postdot = "METRIC"
    TypeDef ::= . METRIC ID_METRIC AS MetricSelect
AHM 15: postdot = "ID_METRIC"
    TypeDef ::= METRIC . ID_METRIC AS MetricSelect
AHM 16: postdot = "AS"
    TypeDef ::= METRIC ID_METRIC . AS MetricSelect
AHM 17: postdot = "MetricSelect"
    TypeDef ::= METRIC ID_METRIC AS . MetricSelect
AHM 18: completion
    TypeDef ::= METRIC ID_METRIC AS MetricSelect .
AHM 19: postdot = "SELECT"
    MetricSelect ::= . SELECT MetricExpr ByClause MetricSelect[R3:3]
AHM 20: postdot = "MetricExpr"
    MetricSelect ::= SELECT . MetricExpr ByClause MetricSelect[R3:3]
AHM 21: postdot = "ByClause"
    MetricSelect ::= SELECT MetricExpr . ByClause MetricSelect[R3:3]
AHM 22: postdot = "MetricSelect[R3:3]"
    MetricSelect ::= SELECT MetricExpr ByClause . MetricSelect[R3:3]
AHM 23: completion
    MetricSelect ::= SELECT MetricExpr ByClause MetricSelect[R3:3] .
AHM 24: postdot = "SELECT"
    MetricSelect ::= . SELECT MetricExpr ByClause Match[] Filter[] WithPf[]
AHM 25: postdot = "MetricExpr"
    MetricSelect ::= SELECT . MetricExpr ByClause Match[] Filter[] WithPf[]
AHM 26: postdot = "ByClause"
    MetricSelect ::= SELECT MetricExpr . ByClause Match[] Filter[] WithPf[]
AHM 27: completion
    MetricSelect ::= SELECT MetricExpr ByClause Match[] Filter[] WithPf[] .
AHM 28: postdot = "SELECT"
    MetricSelect ::= . SELECT MetricExpr ByClause[] MetricSelect[R3:3]
AHM 29: postdot = "MetricExpr"
    MetricSelect ::= SELECT . MetricExpr ByClause[] MetricSelect[R3:3]
AHM 30: postdot = "MetricSelect[R3:3]"
    MetricSelect ::= SELECT MetricExpr ByClause[] . MetricSelect[R3:3]
AHM 31: completion
    MetricSelect ::= SELECT MetricExpr ByClause[] MetricSelect[R3:3] .
AHM 32: postdot = "SELECT"
    MetricSelect ::= . SELECT MetricExpr ByClause[] Match[] Filter[] WithPf[]
AHM 33: postdot = "MetricExpr"
    MetricSelect ::= SELECT . MetricExpr ByClause[] Match[] Filter[] WithPf[]
AHM 34: completion
    MetricSelect ::= SELECT MetricExpr ByClause[] Match[] Filter[] WithPf[] .
AHM 35: postdot = "Match"
    MetricSelect[R3:3] ::= . Match MetricSelect[R3:4]
AHM 36: postdot = "MetricSelect[R3:4]"
    MetricSelect[R3:3] ::= Match . MetricSelect[R3:4]
AHM 37: completion
    MetricSelect[R3:3] ::= Match MetricSelect[R3:4] .
AHM 38: postdot = "Match"
    MetricSelect[R3:3] ::= . Match Filter[] WithPf[]
AHM 39: completion
    MetricSelect[R3:3] ::= Match Filter[] WithPf[] .
AHM 40: postdot = "MetricSelect[R3:4]"
    MetricSelect[R3:3] ::= Match[] . MetricSelect[R3:4]
AHM 41: completion
    MetricSelect[R3:3] ::= Match[] MetricSelect[R3:4] .
AHM 42: postdot = "Filter"
    MetricSelect[R3:4] ::= . Filter WithPf
AHM 43: postdot = "WithPf"
    MetricSelect[R3:4] ::= Filter . WithPf
AHM 44: completion
    MetricSelect[R3:4] ::= Filter WithPf .
AHM 45: postdot = "Filter"
    MetricSelect[R3:4] ::= . Filter WithPf[]
AHM 46: completion
    MetricSelect[R3:4] ::= Filter WithPf[] .
AHM 47: postdot = "WithPf"
    MetricSelect[R3:4] ::= Filter[] . WithPf
AHM 48: completion
    MetricSelect[R3:4] ::= Filter[] WithPf .
AHM 49: postdot = "NUMBER"
    MetricExpr ::= . NUMBER
AHM 50: completion
    MetricExpr ::= NUMBER .
AHM 51: postdot = "BY"
    ByClause ::= . BY
AHM 52: completion
    ByClause ::= BY .
AHM 53: postdot = "FOR"
    Match ::= . FOR
AHM 54: completion
    Match ::= FOR .
AHM 55: postdot = "WHERE"
    Filter ::= . WHERE FilterExpr
AHM 56: postdot = "FilterExpr"
    Filter ::= WHERE . FilterExpr
AHM 57: completion
    Filter ::= WHERE FilterExpr .
AHM 58: postdot = "TRUE"
    FilterExpr ::= . TRUE
AHM 59: completion
    FilterExpr ::= TRUE .
AHM 60: postdot = "FALSE"
    FilterExpr ::= . FALSE
AHM 61: completion
    FilterExpr ::= FALSE .
AHM 62: postdot = "WITH"
    WithPf ::= . WITH PF
AHM 63: postdot = "PF"
    WithPf ::= WITH . PF
AHM 64: completion
    WithPf ::= WITH PF .
AHM 65: postdot = "Input"
    Input['] ::= . Input
AHM 66: completion
    Input['] ::= Input .
END_OF_AHMS

my $recce = Marpa::R3::Scanless::R->new( { grammar => $grammar, semantics_package => 'Maql_Actions' } );
$recce->read( \$input );
my $value_ref = $recce->value();

Marpa::R3::Test::is( $recce->show_earley_sets(),
    <<'END_OF_EARLEY_SETS', 'Earley Sets' );
Last Completed: 8; Furthest: 8
Earley Set 0
ahm65: R23:0@0-0
  R23:0: Input['] ::= . Input
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
  [c=R16:0@5-5; s=NUMBER; t=\1]
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
  R23$: Input['] ::= Input .
  [p=R23:0@0-0; c=R0$@0-6]
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
  R23$: Input['] ::= Input .
  [p=R23:0@0-0; c=R0$@0-8]
ahm62: R22:0@8-8
  R22:0: WithPf ::= . WITH PF
END_OF_EARLEY_SETS

TODO: {
    todo_skip "show_and_nodes() porting not completed", 1;

    Marpa::R3::Test::is( $recce->show_and_nodes(),
        <<'END_OF_AND_NODES', 'And Nodes' );
    And-node #0: R4:1@0-1S2@0
    And-node #19: R0:1@0-8C2@0
    And-node #18: R2:1@0-8C4@0
    And-node #17: R4:2@0-8C5@1
    And-node #20: R23:1@0-8C0@0
    And-node #1: R5:1@1-2S5@1
    And-node #2: R5:2@1-3S11@2
    And-node #3: R5:3@1-4S0@3
    And-node #16: R5:4@1-8C8@4
    And-node #4: R8:1@4-5S7@4
    And-node #6: R8:2@4-6C16@5
    And-node #7: R8:3@4-6S20@6
    And-node #15: R8:4@4-8C12@6
    And-node #5: R16:1@5-6S13@5
    And-node #8: R12:1@6-6S22@6
    And-node #9: R19:1@6-7S9@6
    And-node #14: R12:2@6-8C14@6
    And-node #12: R14:1@6-8C19@6
    And-node #13: R14:2@6-8S26@8
    And-node #11: R19:2@6-8C20@7
    And-node #10: R20:1@7-8S8@7
END_OF_AND_NODES
}

TODO: {
    todo_skip "show_or_nodes() porting not completed", 1;
    Marpa::R3::Test::is( $recce->show_or_nodes(),
        <<'END_OF_OR_NODES', 'Or Nodes' );
    R4:1@0-1
    R0:1@0-8
    R2:1@0-8
    R4:2@0-8
    R23:1@0-8
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
}

Marpa::R3::Test::is( Dumper( ${$value_ref} ), <<'END_OF_STRING', 'Result' );
$VAR1 = [
          \[
              [
                'Create',
                [
                  'Metric',
                  'm',
                  'As',
                  [
                    'Select',
                    [
                      1
                    ],
                    undef,
                    undef,
                    [
                      'Where',
                      [
                        'True'
                      ]
                    ],
                    undef
                  ]
                ]
              ]
            ]
        ];
END_OF_STRING

#############################################################################
package Maql_Actions;

sub new { }

sub tisk { shift; return \@_; }

