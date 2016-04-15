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

# CENSUS: ASIS
# Note: SLIF TEST

# the example grammar in Aycock/Horspool "Practical Earley Parsing",
# _The Computer Journal_, Vol. 45, No. 6, pp. 620-630,
# in its "NNF" form

use 5.010001;
use strict;
use warnings;

use Test::More tests => 35;
use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

## no critic (Subroutines::RequireArgUnpacking)

sub default_action {
    shift;
    my $v_count = scalar @_;
    return q{}   if $v_count <= 0;
    return $_[0] if $v_count == 1;
    return '(' . ( join q{;}, @_ ) . ')';
} ## end sub default_action

## use critic

my $dsl = <<'END_OF_DSL';
:default ::= action => main::default_action
:start ::= S
S ::= A A A A
A ::=
A ::= 'a'
END_OF_DSL

my $grammar = Marpa::R3::Scanless::G->new( {   source => \$dsl });
my $recce = Marpa::R3::Scanless::R->new( {   grammar => $grammar });
my $input_length = 4;
my $input = ('a' x $input_length);
$recce->read( \$input );

my @expected = map {
    +{ map { ( $_ => 1 ) } @{$_} }
    }
    [q{}],
    [qw( (a;;;) (;a;;) (;;a;) (;;;a) )],
    [qw( (a;a;;) (a;;a;) (a;;;a) (;a;a;) (;a;;a) (;;a;a) )],
    [qw( (a;a;a;) (a;a;;a) (a;;a;a) (;a;a;a) )],
    ['(a;a;a;a)'];

$recce->set( { max_parses => 20 } );

my @ambiguity_expected;
$ambiguity_expected[0] = 'No ambiguity';

$ambiguity_expected[1] = <<'END_OF_AMBIGUITY_DESC';
Length of symbol "A" at line 1, column 1 is ambiguous
  Choice 1, length=1, ends at line 1, column 1
  Choice 1: a
  Choice 2 is zero length
END_OF_AMBIGUITY_DESC

$ambiguity_expected[2] = <<'END_OF_AMBIGUITY_DESC';
Length of symbol "A" at line 1, column 1 is ambiguous
  Choice 1 is zero length
  Choice 2, length=1, ends at line 1, column 1
  Choice 2: a
END_OF_AMBIGUITY_DESC

$ambiguity_expected[3] = <<'END_OF_AMBIGUITY_DESC';
Length of symbol "A" at line 1, column 1 is ambiguous
  Choice 1 is zero length
  Choice 2, length=1, ends at line 1, column 1
  Choice 2: a
Length of symbol "A" at line 1, column 2 is ambiguous
  Choice 1, length=1, ends at line 1, column 2
  Choice 1: a
  Choice 2 is zero length
END_OF_AMBIGUITY_DESC

$ambiguity_expected[4] = 'No ambiguity';

for my $i ( 0 .. $input_length ) {

    $recce->series_restart( { end => $i } );
    my $expected = $expected[$i];

# Marpa::R3::Display
# name: Scanless ambiguity_metric() synopsis

    my $ambiguity_metric = $recce->ambiguity_metric();

# Marpa::R3::Display::End

    $ambiguity_metric = 2 if $ambiguity_metric > 2; # cap at 2 -- higher numbers not defined
    my $expected_metric = (scalar keys %{$expected} > 1 ? 2 : 1);
    Test::More::is($ambiguity_metric, $expected_metric, "Ambiguity check for length $i");

    while ( my $value_ref = $recce->value() ) {

        my $value = $value_ref ? ${$value_ref} : 'No parse';
        if ( defined $expected->{$value} ) {
            delete $expected->{$value};
            Test::More::pass(qq{Expected result for length=$i, "$value"});
        }
        else {
            Test::More::fail(qq{Unexpected result for length=$i, "$value"});
        }
    } ## end while ( my $value_ref = $recce->value() )

    for my $value ( keys %{$expected} ) {
        Test::More::fail(qq{Missing result for length=$i, "$value"});
    }

    my $ambiguity_desc = 'No ambiguity';
    if ($ambiguity_metric > 1) {

        $recce->series_restart( { end => $i } );
        my $asf = Marpa::R3::ASF->new( { slr => $recce } );
        die 'No ASF' if not defined $asf;
        my $ambiguities = Marpa::R3::Internal::ASF::ambiguities($asf);

        # Only report the first two
        my @ambiguities = grep {defined} @{$ambiguities}[ 0 .. 1 ];

        $ambiguity_desc =
            Marpa::R3::Internal::ASF::ambiguities_show( $asf, \@ambiguities );
    }

    Marpa::R3::Test::is($ambiguity_desc, $ambiguity_expected[$i], "Ambiguity description for length $i");

} ## end for my $i ( 0 .. $input_length )

TESTS_FOLDED_FROM_ah2_t: {

Marpa::R3::Test::is( $grammar->show_rules, <<'EOS', 'Aycock/Horspool Rules' );
0: S -> A A A A
1: A -> a
2: A -> E /* !used */
3: E -> /* empty !used */
EOS

Marpa::R3::Test::is( $grammar->show_symbols,
    <<'EOS', 'Aycock/Horspool Symbols' );
0: S
1: A
2: a, terminal
3: E, nulling
EOS

TODO: {

	todo_skip "Marpa::R3::Scanless::G::show_isys() unimplemented", 1;

Marpa::R3::Test::is( $grammar->show_isys,
	<<'EOS', 'Aycock/Horspool ISYs' );
0: S
1: S[], nulling
2: A
3: A[], nulling
4: a
5: E[], nulling
6: S[R0:1]
7: S[R0:2]
8: S[']
EOS

} ## TODO & SKIP show_isys()


TODO: {

	todo_skip "Marpa::R3::Scanless::G::show_irls() unimplemented", 1;

Marpa::R3::Test::is( $grammar->show_irls,
    <<'EOS', 'Aycock/Horspool IRLs' );
0: S -> A S[R0:1]
1: S -> A A[] A[] A[]
2: S -> A[] S[R0:1]
3: S[R0:1] -> A S[R0:2]
4: S[R0:1] -> A A[] A[]
5: S[R0:1] -> A[] S[R0:2]
6: S[R0:2] -> A A
7: S[R0:2] -> A A[]
8: S[R0:2] -> A[] A
9: A -> a
10: S['] -> S
EOS

} ## TODO & SKIP show_irls()

TODO: {

	todo_skip "Marpa::R3::Scanless::G::show_nulling_symbols() unimplemented", 1;

Marpa::R3::Test::is(
    $grammar->show_nulling_symbols,
    q{E},
    'Aycock/Horspool Nulling Symbols'
);

} ## TODO & SKIP show_nulling_symbols()

TODO: {

	todo_skip "Marpa::R3::Scanless::G::show_productive_symbols() unimplemented", 1;

Marpa::R3::Test::is(
    $grammar->show_productive_symbols,
    q{A E S a},
    'Aycock/Horspool Productive Symbols'
);

} ## TODO & SKIP show_productive_symbols()

TODO: {

	todo_skip "Marpa::R3::Scanless::G::show_accessible_symbols() unimplemented", 1;

Marpa::R3::Test::is(
    $grammar->show_accessible_symbols,
    q{A E S a},
    'Aycock/Horspool Accessible Symbols'
);

} ## TODO SKIP show_accessible_symbols()

Marpa::R3::Test::is( $grammar->show_ahms(),
    <<'EOS', 'Aycock/Horspool AHMs' );
AHM 0: postdot = "A"
    S ::= . A S[R0:1]
AHM 1: postdot = "S[R0:1]"
    S ::= A . S[R0:1]
AHM 2: completion
    S ::= A S[R0:1] .
AHM 3: postdot = "A"
    S ::= . A A[] A[] A[]
AHM 4: completion
    S ::= A A[] A[] A[] .
AHM 5: postdot = "S[R0:1]"
    S ::= A[] . S[R0:1]
AHM 6: completion
    S ::= A[] S[R0:1] .
AHM 7: postdot = "A"
    S[R0:1] ::= . A S[R0:2]
AHM 8: postdot = "S[R0:2]"
    S[R0:1] ::= A . S[R0:2]
AHM 9: completion
    S[R0:1] ::= A S[R0:2] .
AHM 10: postdot = "A"
    S[R0:1] ::= . A A[] A[]
AHM 11: completion
    S[R0:1] ::= A A[] A[] .
AHM 12: postdot = "S[R0:2]"
    S[R0:1] ::= A[] . S[R0:2]
AHM 13: completion
    S[R0:1] ::= A[] S[R0:2] .
AHM 14: postdot = "A"
    S[R0:2] ::= . A A
AHM 15: postdot = "A"
    S[R0:2] ::= A . A
AHM 16: completion
    S[R0:2] ::= A A .
AHM 17: postdot = "A"
    S[R0:2] ::= . A A[]
AHM 18: completion
    S[R0:2] ::= A A[] .
AHM 19: postdot = "A"
    S[R0:2] ::= A[] . A
AHM 20: completion
    S[R0:2] ::= A[] A .
AHM 21: postdot = "a"
    A ::= . a
AHM 22: completion
    A ::= a .
AHM 23: postdot = "S"
    S['] ::= . S
AHM 24: completion
    S['] ::= S .
EOS

my $expected_earley_sets = <<'END_OF_SETS';
Last Completed: 4; Furthest: 4
Earley Set 0
ahm23: R10:0@0-0
  R10:0: S['] ::= . S
ahm0: R0:0@0-0
  R0:0: S ::= . A S[R0:1]
ahm3: R1:0@0-0
  R1:0: S ::= . A A[] A[] A[]
ahm5: R2:1@0-0
  R2:1: S ::= A[] . S[R0:1]
ahm7: R3:0@0-0
  R3:0: S[R0:1] ::= . A S[R0:2]
ahm10: R4:0@0-0
  R4:0: S[R0:1] ::= . A A[] A[]
ahm12: R5:1@0-0
  R5:1: S[R0:1] ::= A[] . S[R0:2]
ahm14: R6:0@0-0
  R6:0: S[R0:2] ::= . A A
ahm17: R7:0@0-0
  R7:0: S[R0:2] ::= . A A[]
ahm19: R8:1@0-0
  R8:1: S[R0:2] ::= A[] . A
ahm21: R9:0@0-0
  R9:0: A ::= . a
Earley Set 1
ahm22: R9$@0-1
  R9$: A ::= a .
  [c=R9:0@0-0; s=a; t=\'a']
ahm20: R8$@0-1
  R8$: S[R0:2] ::= A[] A .
  [p=R8:1@0-0; c=R9$@0-1]
ahm18: R7$@0-1
  R7$: S[R0:2] ::= A A[] .
  [p=R7:0@0-0; c=R9$@0-1]
ahm15: R6:1@0-1
  R6:1: S[R0:2] ::= A . A
  [p=R6:0@0-0; c=R9$@0-1]
ahm11: R4$@0-1
  R4$: S[R0:1] ::= A A[] A[] .
  [p=R4:0@0-0; c=R9$@0-1]
ahm8: R3:1@0-1
  R3:1: S[R0:1] ::= A . S[R0:2]
  [p=R3:0@0-0; c=R9$@0-1]
ahm4: R1$@0-1
  R1$: S ::= A A[] A[] A[] .
  [p=R1:0@0-0; c=R9$@0-1]
ahm1: R0:1@0-1
  R0:1: S ::= A . S[R0:1]
  [p=R0:0@0-0; c=R9$@0-1]
ahm24: R10$@0-1
  R10$: S['] ::= S .
  [p=R10:0@0-0; c=R1$@0-1] [p=R10:0@0-0; c=R2$@0-1]
ahm6: R2$@0-1
  R2$: S ::= A[] S[R0:1] .
  [p=R2:1@0-0; c=R4$@0-1] [p=R2:1@0-0; c=R5$@0-1]
ahm13: R5$@0-1
  R5$: S[R0:1] ::= A[] S[R0:2] .
  [p=R5:1@0-0; c=R7$@0-1] [p=R5:1@0-0; c=R8$@0-1]
ahm21: R9:0@1-1
  R9:0: A ::= . a
ahm14: R6:0@1-1
  R6:0: S[R0:2] ::= . A A
ahm17: R7:0@1-1
  R7:0: S[R0:2] ::= . A A[]
ahm19: R8:1@1-1
  R8:1: S[R0:2] ::= A[] . A
ahm7: R3:0@1-1
  R3:0: S[R0:1] ::= . A S[R0:2]
ahm10: R4:0@1-1
  R4:0: S[R0:1] ::= . A A[] A[]
ahm12: R5:1@1-1
  R5:1: S[R0:1] ::= A[] . S[R0:2]
Earley Set 2
ahm22: R9$@1-2
  R9$: A ::= a .
  [c=R9:0@1-1; s=a; t=\'a']
ahm11: R4$@1-2
  R4$: S[R0:1] ::= A A[] A[] .
  [p=R4:0@1-1; c=R9$@1-2]
ahm8: R3:1@1-2
  R3:1: S[R0:1] ::= A . S[R0:2]
  [p=R3:0@1-1; c=R9$@1-2]
ahm20: R8$@1-2
  R8$: S[R0:2] ::= A[] A .
  [p=R8:1@1-1; c=R9$@1-2]
ahm18: R7$@1-2
  R7$: S[R0:2] ::= A A[] .
  [p=R7:0@1-1; c=R9$@1-2]
ahm15: R6:1@1-2
  R6:1: S[R0:2] ::= A . A
  [p=R6:0@1-1; c=R9$@1-2]
ahm16: R6$@0-2
  R6$: S[R0:2] ::= A A .
  [p=R6:1@0-1; c=R9$@1-2]
ahm13: R5$@0-2
  R5$: S[R0:1] ::= A[] S[R0:2] .
  [p=R5:1@0-0; c=R6$@0-2]
ahm6: R2$@0-2
  R2$: S ::= A[] S[R0:1] .
  [p=R2:1@0-0; c=R3$@0-2] [p=R2:1@0-0; c=R5$@0-2]
ahm24: R10$@0-2
  R10$: S['] ::= S .
  [p=R10:0@0-0; c=R0$@0-2] [p=R10:0@0-0; c=R2$@0-2]
ahm13: R5$@1-2
  R5$: S[R0:1] ::= A[] S[R0:2] .
  [p=R5:1@1-1; c=R7$@1-2] [p=R5:1@1-1; c=R8$@1-2]
ahm9: R3$@0-2
  R3$: S[R0:1] ::= A S[R0:2] .
  [p=R3:1@0-1; c=R7$@1-2] [p=R3:1@0-1; c=R8$@1-2]
ahm2: R0$@0-2
  R0$: S ::= A S[R0:1] .
  [p=R0:1@0-1; c=R4$@1-2] [p=R0:1@0-1; c=R5$@1-2]
ahm14: R6:0@2-2
  R6:0: S[R0:2] ::= . A A
ahm17: R7:0@2-2
  R7:0: S[R0:2] ::= . A A[]
ahm19: R8:1@2-2
  R8:1: S[R0:2] ::= A[] . A
ahm21: R9:0@2-2
  R9:0: A ::= . a
Earley Set 3
ahm22: R9$@2-3
  R9$: A ::= a .
  [c=R9:0@2-2; s=a; t=\'a']
ahm20: R8$@2-3
  R8$: S[R0:2] ::= A[] A .
  [p=R8:1@2-2; c=R9$@2-3]
ahm18: R7$@2-3
  R7$: S[R0:2] ::= A A[] .
  [p=R7:0@2-2; c=R9$@2-3]
ahm15: R6:1@2-3
  R6:1: S[R0:2] ::= A . A
  [p=R6:0@2-2; c=R9$@2-3]
ahm16: R6$@1-3
  R6$: S[R0:2] ::= A A .
  [p=R6:1@1-2; c=R9$@2-3]
ahm13: R5$@1-3
  R5$: S[R0:1] ::= A[] S[R0:2] .
  [p=R5:1@1-1; c=R6$@1-3]
ahm9: R3$@0-3
  R3$: S[R0:1] ::= A S[R0:2] .
  [p=R3:1@0-1; c=R6$@1-3]
ahm6: R2$@0-3
  R2$: S ::= A[] S[R0:1] .
  [p=R2:1@0-0; c=R3$@0-3]
ahm24: R10$@0-3
  R10$: S['] ::= S .
  [p=R10:0@0-0; c=R0$@0-3] [p=R10:0@0-0; c=R2$@0-3]
ahm2: R0$@0-3
  R0$: S ::= A S[R0:1] .
  [p=R0:1@0-1; c=R3$@1-3] [p=R0:1@0-1; c=R5$@1-3]
ahm9: R3$@1-3
  R3$: S[R0:1] ::= A S[R0:2] .
  [p=R3:1@1-2; c=R7$@2-3] [p=R3:1@1-2; c=R8$@2-3]
ahm21: R9:0@3-3
  R9:0: A ::= . a
Earley Set 4
ahm22: R9$@3-4
  R9$: A ::= a .
  [c=R9:0@3-3; s=a; t=\'a']
ahm16: R6$@2-4
  R6$: S[R0:2] ::= A A .
  [p=R6:1@2-3; c=R9$@3-4]
ahm9: R3$@1-4
  R3$: S[R0:1] ::= A S[R0:2] .
  [p=R3:1@1-2; c=R6$@2-4]
ahm2: R0$@0-4
  R0$: S ::= A S[R0:1] .
  [p=R0:1@0-1; c=R3$@1-4]
ahm24: R10$@0-4
  R10$: S['] ::= S .
  [p=R10:0@0-0; c=R0$@0-4]
END_OF_SETS

Marpa::R3::Test::is(
    $recce->show_earley_sets(2),
    $expected_earley_sets,
    'Aycock/Horspool Earley sets'
);

} ## end TESTS_FOLDED_FROM_ah2_t

TESTS_FOLDED_FROM_bocage_t: {

my %tree_expected = ();

$tree_expected{'(;a;a;a)'} = <<'END_OF_TEXT';
0: o17[-] R10:1@0-3 p=ok c=ok
 o17[0]* ::= a17 R10:1@0-3C2@0
 o17[1] ::= a18 R10:1@0-3C0@0
1: o16[c0] R2:2@0-3 p=ok c=ok
 o16[0]* ::= a16 R2:2@0-3C3@0
2: o15[c1] R3:2@0-3 p=ok c=ok
 o15[0]* ::= a15 R3:2@0-3C6@1
3: o13[c2] R6:2@1-3 p=ok c=ok
 o13[0]* ::= a13 R6:2@1-3C9@2
4: o9[c3] R9:1@2-3 p=ok c=ok
 o9[0]* ::= a9 R9:1@2-3S4@2
5: o7[p3] R6:1@1-2 p=ok c=ok
 o7[0]* ::= a7 R6:1@1-2C9@1
6: o5[c5] R9:1@1-2 p=ok c=ok
 o5[0]* ::= a5 R9:1@1-2S4@1
7: o2[p2] R3:1@0-1 p=ok c=ok
 o2[0]* ::= a2 R3:1@0-1C9@0
8: o1[c7] R9:1@0-1 p=ok c=ok
 o1[0]* ::= a1 R9:1@0-1S4@0
9: o0[p1] R2:1@0-0 p=ok c=ok
 o0[0]* ::= a0 R2:1@0-0S3@0
END_OF_TEXT

$tree_expected{'(a;;a;a)'} = <<'END_OF_TEXT';
0: o17[-] R10:1@0-3 p=ok c=ok
 o17[0] ::= a17 R10:1@0-3C2@0
 o17[1]* ::= a18 R10:1@0-3C0@0
1: o18[c0] R0:2@0-3 p=ok c=ok
 o18[0]* ::= a19 R0:2@0-3C5@1
 o18[1] ::= a20 R0:2@0-3C3@1
2: o14[c1] R5:2@1-3 p=ok c=ok
 o14[0]* ::= a14 R5:2@1-3C6@1
3: o13[c2] R6:2@1-3 p=ok c=ok
 o13[0]* ::= a13 R6:2@1-3C9@2
4: o9[c3] R9:1@2-3 p=ok c=ok
 o9[0]* ::= a9 R9:1@2-3S4@2
5: o7[p3] R6:1@1-2 p=ok c=ok
 o7[0]* ::= a7 R6:1@1-2C9@1
6: o5[c5] R9:1@1-2 p=ok c=ok
 o5[0]* ::= a5 R9:1@1-2S4@1
7: o4[p2] R5:1@1-1 p=ok c=ok
 o4[0]* ::= a4 R5:1@1-1S3@1
8: o3[p1] R0:1@0-1 p=ok c=ok
 o3[0]* ::= a3 R0:1@0-1C9@0
9: o1[c8] R9:1@0-1 p=ok c=ok
 o1[0]* ::= a1 R9:1@0-1S4@0
END_OF_TEXT

$tree_expected{'(a;a;;a)'} = <<'END_OF_TEXT';
0: o17[-] R10:1@0-3 p=ok c=ok
 o17[0] ::= a17 R10:1@0-3C2@0
 o17[1]* ::= a18 R10:1@0-3C0@0
1: o18[c0] R0:2@0-3 p=ok c=ok
 o18[0] ::= a19 R0:2@0-3C5@1
 o18[1]* ::= a20 R0:2@0-3C3@1
2: o19[c1] R3:2@1-3 p=ok c=ok
 o19[0] ::= a21 R3:2@1-3C7@2
 o19[1]* ::= a22 R3:2@1-3C8@2
3: o10[c2] R8:2@2-3 p=ok c=ok
 o10[0]* ::= a10 R8:2@2-3C9@2
4: o9[c3] R9:1@2-3 p=ok c=ok
 o9[0]* ::= a9 R9:1@2-3S4@2
5: o8[p3] R8:1@2-2 p=ok c=ok
 o8[0]* ::= a8 R8:1@2-2S3@2
6: o6[p2] R3:1@1-2 p=ok c=ok
 o6[0]* ::= a6 R3:1@1-2C9@1
7: o5[c6] R9:1@1-2 p=ok c=ok
 o5[0]* ::= a5 R9:1@1-2S4@1
8: o3[p1] R0:1@0-1 p=ok c=ok
 o3[0]* ::= a3 R0:1@0-1C9@0
9: o1[c8] R9:1@0-1 p=ok c=ok
 o1[0]* ::= a1 R9:1@0-1S4@0
END_OF_TEXT

$tree_expected{'(a;a;a;)'} = <<'END_OF_TEXT';
0: o17[-] R10:1@0-3 p=ok c=ok
 o17[0] ::= a17 R10:1@0-3C2@0
 o17[1]* ::= a18 R10:1@0-3C0@0
1: o18[c0] R0:2@0-3 p=ok c=ok
 o18[0] ::= a19 R0:2@0-3C5@1
 o18[1]* ::= a20 R0:2@0-3C3@1
2: o19[c1] R3:2@1-3 p=ok c=ok
 o19[0]* ::= a21 R3:2@1-3C7@2
 o19[1] ::= a22 R3:2@1-3C8@2
3: o12[c2] R7:2@2-3 p=ok c=ok
 o12[0]* ::= a12 R7:2@2-3S3@3
4: o11[p3] R7:1@2-3 p=ok c=ok
 o11[0]* ::= a11 R7:1@2-3C9@2
5: o9[c4] R9:1@2-3 p=ok c=ok
 o9[0]* ::= a9 R9:1@2-3S4@2
6: o6[p2] R3:1@1-2 p=ok c=ok
 o6[0]* ::= a6 R3:1@1-2C9@1
7: o5[c6] R9:1@1-2 p=ok c=ok
 o5[0]* ::= a5 R9:1@1-2S4@1
8: o3[p1] R0:1@0-1 p=ok c=ok
 o3[0]* ::= a3 R0:1@0-1C9@0
9: o1[c8] R9:1@0-1 p=ok c=ok
 o1[0]* ::= a1 R9:1@0-1S4@0
END_OF_TEXT

my %expected =
    map { ( $_ => 1 ) } qw( (a;a;a;) (a;a;;a) (a;;a;a) (;a;a;a) );

$recce->set( { max_parses => 20 } );

while ( my $value_ref = $recce->value() ) {

    my $tree_output = q{};

    my $value = 'No parse';
    if ($value_ref) {
        $value = ${$value_ref};

        Marpa::R3::Test::is( $recce->show_tree(), $tree_expected{$value},
            qq{Tree, "$value"} );
    }
    else {
        Test::More::fail('Tree');
    }

    if ( defined $expected{$value} ) {
        delete $expected{$value};
        Test::More::pass(qq{Expected result, "$value"});
    }
    else {
        Test::More::fail(qq{Unexpected result, "$value"});
    }
} ## end while ( my $value_ref = $recce->value() )

for my $value ( keys %expected ) {
    Test::More::fail(qq{Missing result, "$value"});
}

my $or_node_output = <<'END_OF_TEXT';
R2:1@0-0
R0:1@0-1
R3:1@0-1
R9:1@0-1
R0:2@0-3
R2:2@0-3
R3:2@0-3
R10:1@0-3
R5:1@1-1
R3:1@1-2
R6:1@1-2
R9:1@1-2
R3:2@1-3
R5:2@1-3
R6:2@1-3
R8:1@2-2
R7:1@2-3
R7:2@2-3
R8:2@2-3
R9:1@2-3
END_OF_TEXT

Marpa::R3::Test::is( $recce->show_or_nodes(), $or_node_output,
    'XS Or nodes' );

my $and_node_output = <<'END_OF_TEXT';
And-node #0: R2:1@0-0S3@0
And-node #3: R0:1@0-1C9@0
And-node #2: R3:1@0-1C9@0
And-node #1: R9:1@0-1S4@0
And-node #19: R0:2@0-3C5@1
And-node #20: R0:2@0-3C3@1
And-node #16: R2:2@0-3C3@0
And-node #15: R3:2@0-3C6@1
And-node #17: R10:1@0-3C2@0
And-node #18: R10:1@0-3C0@0
And-node #4: R5:1@1-1S3@1
And-node #6: R3:1@1-2C9@1
And-node #7: R6:1@1-2C9@1
And-node #5: R9:1@1-2S4@1
And-node #21: R3:2@1-3C7@2
And-node #22: R3:2@1-3C8@2
And-node #14: R5:2@1-3C6@1
And-node #13: R6:2@1-3C9@2
And-node #8: R8:1@2-2S3@2
And-node #11: R7:1@2-3C9@2
And-node #12: R7:2@2-3S3@3
And-node #10: R8:2@2-3C9@2
And-node #9: R9:1@2-3S4@2
END_OF_TEXT

Marpa::R3::Test::is( $recce->show_and_nodes(),
    $and_node_output, 'XS And nodes' );

TODO: {

	todo_skip "Marpa::R3::Scanless::R::show_bocage() unimplemented", 1;

my $bocage_output = <<'END_OF_TEXT';
0: 0=R2:1@0-0 - S3
1: 1=R9:1@0-1 - S4
2: 2=R3:1@0-1 - R9:1@0-1
3: 3=R0:1@0-1 - R9:1@0-1
4: 4=R5:1@1-1 - S3
5: 5=R9:1@1-2 - S4
6: 6=R3:1@1-2 - R9:1@1-2
7: 7=R6:1@1-2 - R9:1@1-2
8: 8=R8:1@2-2 - S3
9: 9=R9:1@2-3 - S4
10: 10=R8:2@2-3 R8:1@2-2 R9:1@2-3
11: 11=R7:1@2-3 - R9:1@2-3
12: 12=R7:2@2-3 R7:1@2-3 S3
13: 13=R6:2@1-3 R6:1@1-2 R9:1@2-3
14: 14=R5:2@1-3 R5:1@1-1 R6:2@1-3
15: 15=R3:2@0-3 R3:1@0-1 R6:2@1-3
16: 16=R2:2@0-3 R2:1@0-0 R3:2@0-3
17: 17=R10:1@0-3 - R2:2@0-3
18: 17=R10:1@0-3 - R0:2@0-3
19: 18=R0:2@0-3 R0:1@0-1 R5:2@1-3
20: 18=R0:2@0-3 R0:1@0-1 R3:2@1-3
21: 19=R3:2@1-3 R3:1@1-2 R7:2@2-3
22: 19=R3:2@1-3 R3:1@1-2 R8:2@2-3
END_OF_TEXT

Marpa::R3::Test::is( $recce->show_bocage(), $bocage_output, 'XS Bocage' );

} ## end TODO & SKIP show_bocage()


} ## end TESTS_FOLDED_FROM_bocage_t

1;    # In case used as "do" file

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
