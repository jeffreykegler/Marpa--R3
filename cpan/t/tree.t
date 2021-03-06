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

# Note: Unfolded the tree testing from ah2.t

# the example grammar in Aycock/Horspool "Practical Earley Parsing",
# _The Computer Journal_, Vol. 45, No. 6, pp. 620-630,
# in its "NNF" form

use 5.010001;

use strict;
use warnings;

use Test::More tests => 33;
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

## no critic (Subroutines::RequireArgUnpacking)

sub default_action {
    my (undef, $v) = @_;
    my $v_count = scalar @{$v};
    return q{}   if $v_count <= 0;
    return $v->[0] if $v_count == 1;
    return '(' . ( join q{;}, @{$v}) . ')';
}

## use critic

my $dsl = <<'END_OF_DSL';
:default ::= action => main::default_action
:start ::= S
S ::= A A A A
A ::=
A ::= 'a'
END_OF_DSL

my $grammar = Marpa::R3::Grammar->new( {   source => \$dsl });

my $recce = Marpa::R3::Recognizer->new( {   grammar => $grammar });
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

my @ambiguity_expected;
$ambiguity_expected[0] = 'No ambiguity';

$ambiguity_expected[1] = <<'END_OF_AMBIGUITY_DESC';
Length of symbol "A" at B1L1c1 is ambiguous
  Choice 1, length=1, ends at B1L1c1
  Choice 1: a
  Choice 2 is zero length
END_OF_AMBIGUITY_DESC

$ambiguity_expected[2] = <<'END_OF_AMBIGUITY_DESC';
Length of symbol "A" at B1L1c1 is ambiguous
  Choice 1 is zero length
  Choice 2, length=1, ends at B1L1c1
  Choice 2: a
END_OF_AMBIGUITY_DESC

$ambiguity_expected[3] = <<'END_OF_AMBIGUITY_DESC';
Length of symbol "A" at B1L1c1 is ambiguous
  Choice 1 is zero length
  Choice 2, length=1, ends at B1L1c1
  Choice 2: a
Length of symbol "A" at B1L1c2 is ambiguous
  Choice 1, length=1, ends at B1L1c2
  Choice 1: a
  Choice 2 is zero length
END_OF_AMBIGUITY_DESC

$ambiguity_expected[4] = 'No ambiguity';

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
 o9[0]* ::= a9 R9:1@2-3S6@2
5: o7[p3] R6:1@1-2 p=ok c=ok
 o7[0]* ::= a7 R6:1@1-2C9@1
6: o5[c5] R9:1@1-2 p=ok c=ok
 o5[0]* ::= a5 R9:1@1-2S6@1
7: o2[p2] R3:1@0-1 p=ok c=ok
 o2[0]* ::= a2 R3:1@0-1C9@0
8: o1[c7] R9:1@0-1 p=ok c=ok
 o1[0]* ::= a1 R9:1@0-1S6@0
9: o0[p1] R2:1@0-0 p=ok c=ok
 o0[0]* ::= a0 R2:1@0-0S1@0
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
 o9[0]* ::= a9 R9:1@2-3S6@2
5: o7[p3] R6:1@1-2 p=ok c=ok
 o7[0]* ::= a7 R6:1@1-2C9@1
6: o5[c5] R9:1@1-2 p=ok c=ok
 o5[0]* ::= a5 R9:1@1-2S6@1
7: o4[p2] R5:1@1-1 p=ok c=ok
 o4[0]* ::= a4 R5:1@1-1S1@1
8: o3[p1] R0:1@0-1 p=ok c=ok
 o3[0]* ::= a3 R0:1@0-1C9@0
9: o1[c8] R9:1@0-1 p=ok c=ok
 o1[0]* ::= a1 R9:1@0-1S6@0
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
 o9[0]* ::= a9 R9:1@2-3S6@2
5: o8[p3] R8:1@2-2 p=ok c=ok
 o8[0]* ::= a8 R8:1@2-2S1@2
6: o6[p2] R3:1@1-2 p=ok c=ok
 o6[0]* ::= a6 R3:1@1-2C9@1
7: o5[c6] R9:1@1-2 p=ok c=ok
 o5[0]* ::= a5 R9:1@1-2S6@1
8: o3[p1] R0:1@0-1 p=ok c=ok
 o3[0]* ::= a3 R0:1@0-1C9@0
9: o1[c8] R9:1@0-1 p=ok c=ok
 o1[0]* ::= a1 R9:1@0-1S6@0
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
 o12[0]* ::= a12 R7:2@2-3S1@3
4: o11[p3] R7:1@2-3 p=ok c=ok
 o11[0]* ::= a11 R7:1@2-3C9@2
5: o9[c4] R9:1@2-3 p=ok c=ok
 o9[0]* ::= a9 R9:1@2-3S6@2
6: o6[p2] R3:1@1-2 p=ok c=ok
 o6[0]* ::= a6 R3:1@1-2C9@1
7: o5[c6] R9:1@1-2 p=ok c=ok
 o5[0]* ::= a5 R9:1@1-2S6@1
8: o3[p1] R0:1@0-1 p=ok c=ok
 o3[0]* ::= a3 R0:1@0-1C9@0
9: o1[c8] R9:1@0-1 p=ok c=ok
 o1[0]* ::= a1 R9:1@0-1S6@0
END_OF_TEXT

for my $i ( 0 .. $input_length ) {

    my $valuer = Marpa::R3::Valuer->new(
        { recognizer => $recce, end => $i, max_parses => 20 } );

    my $expected = $expected[$i];

    my $ambiguity_level = $valuer->ambiguity_level();

    my $expected_level = ( scalar keys %{$expected} > 1 ? 2 : 1 );
    Test::More::is( $ambiguity_level, $expected_level,
        "Ambiguity check for length $i" );

    if ( $i == 3 ) {
      TESTS_FOLDED_FROM_bocage_t: {

            my $and_node_output = <<'END_OF_TEXT';
And-node #0: R2:1@0-0S1@0
And-node #3: R0:1@0-1C9@0
And-node #2: R3:1@0-1C9@0
And-node #1: R9:1@0-1S6@0
And-node #20: R0:2@0-3C3@1
And-node #19: R0:2@0-3C5@1
And-node #16: R2:2@0-3C3@0
And-node #15: R3:2@0-3C6@1
And-node #18: R10:1@0-3C0@0
And-node #17: R10:1@0-3C2@0
And-node #4: R5:1@1-1S1@1
And-node #6: R3:1@1-2C9@1
And-node #7: R6:1@1-2C9@1
And-node #5: R9:1@1-2S6@1
And-node #21: R3:2@1-3C7@2
And-node #22: R3:2@1-3C8@2
And-node #14: R5:2@1-3C6@1
And-node #13: R6:2@1-3C9@2
And-node #8: R8:1@2-2S1@2
And-node #11: R7:1@2-3C9@2
And-node #12: R7:2@2-3S1@3
And-node #10: R8:2@2-3C9@2
And-node #9: R9:1@2-3S6@2
END_OF_TEXT

            Marpa::R3::Test::is( $valuer->and_nodes_show(),
                $and_node_output, 'XS And nodes' );

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

            Marpa::R3::Test::is( $valuer->or_nodes_show(),
                $or_node_output, 'XS Or nodes' );

                my $bocage_output = <<'END_OF_TEXT';
0: 0=R2:1@0-0 - S1
1: 1=R9:1@0-1 - S6
2: 2=R3:1@0-1 - R9:1@0-1
3: 3=R0:1@0-1 - R9:1@0-1
4: 4=R5:1@1-1 - S1
5: 5=R9:1@1-2 - S6
6: 6=R3:1@1-2 - R9:1@1-2
7: 7=R6:1@1-2 - R9:1@1-2
8: 8=R8:1@2-2 - S1
9: 9=R9:1@2-3 - S6
10: 10=R8:2@2-3 R8:1@2-2 R9:1@2-3
11: 11=R7:1@2-3 - R9:1@2-3
12: 12=R7:2@2-3 R7:1@2-3 S1
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

                Marpa::R3::Test::is( $valuer->bocage_show(), $bocage_output,
                    'XS Bocage' );

        } ## end TESTS_FOLDED_FROM_bocage_t
    }

    while ( my $value_ref = $valuer->value() ) {

        my $value = $value_ref ? ${$value_ref} : 'No parse';
        $value //= '[undef]';
        if ( defined $expected->{$value} ) {
            delete $expected->{$value};
            Test::More::pass(qq{Expected result for length=$i, "$value"});
        }
        else {
            Test::More::fail(qq{Unexpected result for length=$i, "$value"});
        }

        if ( $i == 3 ) {
                Marpa::R3::Test::is( $valuer->tree_show(),
                    $tree_expected{$value}, qq{Tree, "$value"} );
        }

    }

    for my $value ( keys %{$expected} ) {
        Test::More::fail(qq{Missing result for length=$i, "$value"});
    }

    my $ambiguity_desc = 'No ambiguity';
    if ( $ambiguity_level > 1 ) {

        my $asf = Marpa::R3::ASF2->new( { recognizer => $recce, end => $i } );
        die 'No ASF' if not defined $asf;
        my $ambiguities = Marpa::R3::Internal_ASF2::ambiguities($asf);

        # Only report the first two
        my @ambiguities = grep { defined } @{$ambiguities}[ 0 .. 1 ];

        $ambiguity_desc =
          Marpa::R3::Internal_ASF2::ambiguities_show( $asf, \@ambiguities );
    }

    Marpa::R3::Test::is( $ambiguity_desc, $ambiguity_expected[$i],
        "Ambiguity description for length $i" );

} ## end for my $i ( 0 .. $input_length )

# vim: expandtab shiftwidth=4:
