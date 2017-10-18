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

# Note: ah2.t and bocage.t folded into this test

# the example grammar in Aycock/Horspool "Practical Earley Parsing",
# _The Computer Journal_, Vol. 45, No. 6, pp. 620-630,
# in its "NNF" form

use 5.010001;

use strict;
use warnings;

use Test::More tests => 40;
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

my $grammar = Marpa::R3::Scanless::G->new( {   source => \$dsl });

GRAMMAR_TESTS_FOLDED_FROM_ah2_t: {

Marpa::R3::Test::is( $grammar->productions_show(), <<'EOS', 'Aycock/Horspool Productions' );
R1 [:start:] ::= S
R2 S ::= A A A A
R3 A ::=
R4 A ::= 'a'
R5 [:lex_start:] ~ 'a'
R6 'a' ~ [a]
EOS

Marpa::R3::Test::is( $grammar->g1_rules_show(), <<'EOS', 'Aycock/Horspool G1 Rules' );
R0 S ::= A A A A
R1 A ::=
R2 A ::= 'a'
R3 [:start:] ::= S
EOS

Marpa::R3::Test::is( $grammar->symbols_show(),
    <<'EOS', 'Aycock/Horspool Symbols' );
S1 A
S2 S
S3 [:lex_start:]
S4 [:start:]
S5 'a'
S6 [a]
EOS

Marpa::R3::Test::is( $grammar->g1_symbols_show(),
    <<'EOS', 'Aycock/Horspool G1 Symbols' );
g1 S0 A
g1 S1 S
g1 S2 [:start:]
g1 S3 'a'
EOS

Marpa::R3::Test::is( $grammar->nsys_show(),
        <<'EOS', 'Aycock/Horspool ISYs' );
0: A
1: A[], nulling
2: S
3: S[], nulling
4: [:start:]
5: [:start:][], nulling
6: [Lex-0]
7: S[R0:1]
8: S[R0:2]
9: [:start:][']
EOS

Marpa::R3::Test::is( $grammar->nrls_show(),
    <<'EOS', 'Aycock/Horspool IRLs' );
0: S ::= A S[R0:1]
1: S ::= A A[] A[] A[]
2: S ::= A[] S[R0:1]
3: S[R0:1] ::= A S[R0:2]
4: S[R0:1] ::= A A[] A[]
5: S[R0:1] ::= A[] S[R0:2]
6: S[R0:2] ::= A A
7: S[R0:2] ::= A A[]
8: S[R0:2] ::= A[] A
9: A ::= [Lex-0]
10: [:start:] ::= S
11: [:start:]['] ::= [:start:]
EOS

# This is in term of ISYs. We don't track these properties for
# XSYs, at least not currently

my @g1_symbols = ();
for (
    my $iter = $grammar->g1_symbol_ids_gen() ;
    defined( my $symbol_id = $iter->() ) ;
  )
{
    push @g1_symbols, $symbol_id;
}

my $nulling_symbols = join q{ }, sort map { $grammar->g1_symbol_name($_) }
  grep { $grammar->g1_symbol_is_nulling($_) } @g1_symbols;
Marpa::R3::Test::is( $nulling_symbols, q{},
    'Aycock/Horspool Nulling Symbols' );

my $productive_symbols = join q{ }, sort map { $grammar->g1_symbol_name($_) }
  grep { $grammar->g1_symbol_is_productive($_) } @g1_symbols;
Marpa::R3::Test::is( $productive_symbols, q{A S [:start:] [Lex-0]},
    'Aycock/Horspool Productive Symbols' );

my $accessible_symbols = join q{ }, sort map { $grammar->g1_symbol_name($_) }
  grep { $grammar->g1_symbol_is_accessible($_) } @g1_symbols;
Marpa::R3::Test::is( $accessible_symbols, q{A S [:start:] [Lex-0]},
    'Aycock/Horspool Accessible Symbols' );

Marpa::R3::Test::is( $grammar->ahms_show(),
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
AHM 21: postdot = "[Lex-0]"
    A ::= . [Lex-0]
AHM 22: completion
    A ::= [Lex-0] .
AHM 23: postdot = "S"
    [:start:] ::= . S
AHM 24: completion
    [:start:] ::= S .
AHM 25: postdot = "[:start:]"
    [:start:]['] ::= . [:start:]
AHM 26: completion
    [:start:]['] ::= [:start:] .
EOS

}

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
0: o18[-] R11:1@0-3 p=ok c=ok
 o18[0]* ::= a19 R11:1@0-3C10@0
1: o17[c0] R10:1@0-3 p=ok c=ok
 o17[0]* ::= a17 R10:1@0-3C2@0
 o17[1] ::= a18 R10:1@0-3C0@0
2: o16[c1] R2:2@0-3 p=ok c=ok
 o16[0]* ::= a16 R2:2@0-3C3@0
3: o15[c2] R3:2@0-3 p=ok c=ok
 o15[0]* ::= a15 R3:2@0-3C6@1
4: o13[c3] R6:2@1-3 p=ok c=ok
 o13[0]* ::= a13 R6:2@1-3C9@2
5: o9[c4] R9:1@2-3 p=ok c=ok
 o9[0]* ::= a9 R9:1@2-3S6@2
6: o7[p4] R6:1@1-2 p=ok c=ok
 o7[0]* ::= a7 R6:1@1-2C9@1
7: o5[c6] R9:1@1-2 p=ok c=ok
 o5[0]* ::= a5 R9:1@1-2S6@1
8: o2[p3] R3:1@0-1 p=ok c=ok
 o2[0]* ::= a2 R3:1@0-1C9@0
9: o1[c8] R9:1@0-1 p=ok c=ok
 o1[0]* ::= a1 R9:1@0-1S6@0
10: o0[p2] R2:1@0-0 p=ok c=ok
 o0[0]* ::= a0 R2:1@0-0S1@0
END_OF_TEXT

$tree_expected{'(a;;a;a)'} = <<'END_OF_TEXT';
0: o18[-] R11:1@0-3 p=ok c=ok
 o18[0]* ::= a19 R11:1@0-3C10@0
1: o17[c0] R10:1@0-3 p=ok c=ok
 o17[0] ::= a17 R10:1@0-3C2@0
 o17[1]* ::= a18 R10:1@0-3C0@0
2: o19[c1] R0:2@0-3 p=ok c=ok
 o19[0]* ::= a20 R0:2@0-3C5@1
 o19[1] ::= a21 R0:2@0-3C3@1
3: o14[c2] R5:2@1-3 p=ok c=ok
 o14[0]* ::= a14 R5:2@1-3C6@1
4: o13[c3] R6:2@1-3 p=ok c=ok
 o13[0]* ::= a13 R6:2@1-3C9@2
5: o9[c4] R9:1@2-3 p=ok c=ok
 o9[0]* ::= a9 R9:1@2-3S6@2
6: o7[p4] R6:1@1-2 p=ok c=ok
 o7[0]* ::= a7 R6:1@1-2C9@1
7: o5[c6] R9:1@1-2 p=ok c=ok
 o5[0]* ::= a5 R9:1@1-2S6@1
8: o4[p3] R5:1@1-1 p=ok c=ok
 o4[0]* ::= a4 R5:1@1-1S1@1
9: o3[p2] R0:1@0-1 p=ok c=ok
 o3[0]* ::= a3 R0:1@0-1C9@0
10: o1[c9] R9:1@0-1 p=ok c=ok
 o1[0]* ::= a1 R9:1@0-1S6@0
END_OF_TEXT

$tree_expected{'(a;a;;a)'} = <<'END_OF_TEXT';
0: o18[-] R11:1@0-3 p=ok c=ok
 o18[0]* ::= a19 R11:1@0-3C10@0
1: o17[c0] R10:1@0-3 p=ok c=ok
 o17[0] ::= a17 R10:1@0-3C2@0
 o17[1]* ::= a18 R10:1@0-3C0@0
2: o19[c1] R0:2@0-3 p=ok c=ok
 o19[0] ::= a20 R0:2@0-3C5@1
 o19[1]* ::= a21 R0:2@0-3C3@1
3: o20[c2] R3:2@1-3 p=ok c=ok
 o20[0] ::= a22 R3:2@1-3C7@2
 o20[1]* ::= a23 R3:2@1-3C8@2
4: o10[c3] R8:2@2-3 p=ok c=ok
 o10[0]* ::= a10 R8:2@2-3C9@2
5: o9[c4] R9:1@2-3 p=ok c=ok
 o9[0]* ::= a9 R9:1@2-3S6@2
6: o8[p4] R8:1@2-2 p=ok c=ok
 o8[0]* ::= a8 R8:1@2-2S1@2
7: o6[p3] R3:1@1-2 p=ok c=ok
 o6[0]* ::= a6 R3:1@1-2C9@1
8: o5[c7] R9:1@1-2 p=ok c=ok
 o5[0]* ::= a5 R9:1@1-2S6@1
9: o3[p2] R0:1@0-1 p=ok c=ok
 o3[0]* ::= a3 R0:1@0-1C9@0
10: o1[c9] R9:1@0-1 p=ok c=ok
 o1[0]* ::= a1 R9:1@0-1S6@0
END_OF_TEXT

$tree_expected{'(a;a;a;)'} = <<'END_OF_TEXT';
0: o18[-] R11:1@0-3 p=ok c=ok
 o18[0]* ::= a19 R11:1@0-3C10@0
1: o17[c0] R10:1@0-3 p=ok c=ok
 o17[0] ::= a17 R10:1@0-3C2@0
 o17[1]* ::= a18 R10:1@0-3C0@0
2: o19[c1] R0:2@0-3 p=ok c=ok
 o19[0] ::= a20 R0:2@0-3C5@1
 o19[1]* ::= a21 R0:2@0-3C3@1
3: o20[c2] R3:2@1-3 p=ok c=ok
 o20[0]* ::= a22 R3:2@1-3C7@2
 o20[1] ::= a23 R3:2@1-3C8@2
4: o12[c3] R7:2@2-3 p=ok c=ok
 o12[0]* ::= a12 R7:2@2-3S1@3
5: o11[p4] R7:1@2-3 p=ok c=ok
 o11[0]* ::= a11 R7:1@2-3C9@2
6: o9[c5] R9:1@2-3 p=ok c=ok
 o9[0]* ::= a9 R9:1@2-3S6@2
7: o6[p3] R3:1@1-2 p=ok c=ok
 o6[0]* ::= a6 R3:1@1-2C9@1
8: o5[c7] R9:1@1-2 p=ok c=ok
 o5[0]* ::= a5 R9:1@1-2S6@1
9: o3[p2] R0:1@0-1 p=ok c=ok
 o3[0]* ::= a3 R0:1@0-1C9@0
10: o1[c9] R9:1@0-1 p=ok c=ok
 o1[0]* ::= a1 R9:1@0-1S6@0
END_OF_TEXT

for my $i ( 0 .. $input_length ) {

    my $valuer = Marpa::R3::Scanless::V->new( { recognizer => $recce, end => $i } );
    my $expected = $expected[$i];

    my $ambiguity_level = $valuer->ambiguity_level();

    my $expected_metric = ( scalar keys %{$expected} > 1 ? 2 : 1 );
    Test::More::is( $ambiguity_level, $expected_metric,
        "Ambiguity check for length $i" );

    if ( $i == 3 ) {
      TESTS_FOLDED_FROM_bocage_t: {

            my $and_node_output = <<'END_OF_TEXT';
And-node #0: R2:1@0-0S1@0
And-node #3: R0:1@0-1C9@0
And-node #2: R3:1@0-1C9@0
And-node #1: R9:1@0-1S6@0
And-node #21: R0:2@0-3C3@1
And-node #20: R0:2@0-3C5@1
And-node #16: R2:2@0-3C3@0
And-node #15: R3:2@0-3C6@1
And-node #18: R10:1@0-3C0@0
And-node #17: R10:1@0-3C2@0
And-node #19: R11:1@0-3C10@0
And-node #4: R5:1@1-1S1@1
And-node #6: R3:1@1-2C9@1
And-node #7: R6:1@1-2C9@1
And-node #5: R9:1@1-2S6@1
And-node #22: R3:2@1-3C7@2
And-node #23: R3:2@1-3C8@2
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
R11:1@0-3
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
19: 18=R11:1@0-3 - R10:1@0-3
20: 19=R0:2@0-3 R0:1@0-1 R5:2@1-3
21: 19=R0:2@0-3 R0:1@0-1 R3:2@1-3
22: 20=R3:2@1-3 R3:1@1-2 R7:2@2-3
23: 20=R3:2@1-3 R3:1@1-2 R8:2@2-3
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

    }

    for my $value ( keys %{$expected} ) {
        Test::More::fail(qq{Missing result for length=$i, "$value"});
    }

    my $ambiguity_desc = 'No ambiguity';
    if ( $ambiguity_level > 1 ) {

        my $asf = Marpa::R3::ASF->new( { recognizer => $recce, end => $i } );
        die 'No ASF' if not defined $asf;
        my $ambiguities = Marpa::R3::Internal::ASF::ambiguities($asf);

        # Only report the first two
        my @ambiguities = grep { defined } @{$ambiguities}[ 0 .. 1 ];

        $ambiguity_desc =
          Marpa::R3::Internal::ASF::ambiguities_show( $asf, \@ambiguities );
    }

    Marpa::R3::Test::is( $ambiguity_desc, $ambiguity_expected[$i],
        "Ambiguity description for length $i" );

} ## end for my $i ( 0 .. $input_length )

RECCE_TESTS_FOLDED_FROM_ah2_t: {

my $expected_earley_sets = <<'END_OF_SETS';
Last Completed: 4; Furthest: 4
Earley Set 0
ahm25: R11:0@0-0
  R11:0: [:start:]['] ::= . [:start:]
ahm23: R10:0@0-0
  R10:0: [:start:] ::= . S
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
  R9:0: A ::= . [Lex-0]
Earley Set 1
ahm22: R9$@0-1
  R9$: A ::= [Lex-0] .
  [c=R9:0@0-0; s=[Lex-0]; t=\'a']
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
  R10$: [:start:] ::= S .
  [p=R10:0@0-0; c=R1$@0-1]
  [p=R10:0@0-0; c=R2$@0-1]
ahm26: R11$@0-1
  R11$: [:start:]['] ::= [:start:] .
  [p=R11:0@0-0; c=R10$@0-1]
ahm6: R2$@0-1
  R2$: S ::= A[] S[R0:1] .
  [p=R2:1@0-0; c=R4$@0-1]
  [p=R2:1@0-0; c=R5$@0-1]
ahm13: R5$@0-1
  R5$: S[R0:1] ::= A[] S[R0:2] .
  [p=R5:1@0-0; c=R7$@0-1]
  [p=R5:1@0-0; c=R8$@0-1]
ahm21: R9:0@1-1
  R9:0: A ::= . [Lex-0]
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
  R9$: A ::= [Lex-0] .
  [c=R9:0@1-1; s=[Lex-0]; t=\'a']
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
  [p=R2:1@0-0; c=R3$@0-2]
  [p=R2:1@0-0; c=R5$@0-2]
ahm24: R10$@0-2
  R10$: [:start:] ::= S .
  [p=R10:0@0-0; c=R0$@0-2]
  [p=R10:0@0-0; c=R2$@0-2]
ahm26: R11$@0-2
  R11$: [:start:]['] ::= [:start:] .
  [p=R11:0@0-0; c=R10$@0-2]
ahm13: R5$@1-2
  R5$: S[R0:1] ::= A[] S[R0:2] .
  [p=R5:1@1-1; c=R7$@1-2]
  [p=R5:1@1-1; c=R8$@1-2]
ahm9: R3$@0-2
  R3$: S[R0:1] ::= A S[R0:2] .
  [p=R3:1@0-1; c=R7$@1-2]
  [p=R3:1@0-1; c=R8$@1-2]
ahm2: R0$@0-2
  R0$: S ::= A S[R0:1] .
  [p=R0:1@0-1; c=R4$@1-2]
  [p=R0:1@0-1; c=R5$@1-2]
ahm14: R6:0@2-2
  R6:0: S[R0:2] ::= . A A
ahm17: R7:0@2-2
  R7:0: S[R0:2] ::= . A A[]
ahm19: R8:1@2-2
  R8:1: S[R0:2] ::= A[] . A
ahm21: R9:0@2-2
  R9:0: A ::= . [Lex-0]
Earley Set 3
ahm22: R9$@2-3
  R9$: A ::= [Lex-0] .
  [c=R9:0@2-2; s=[Lex-0]; t=\'a']
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
  R10$: [:start:] ::= S .
  [p=R10:0@0-0; c=R0$@0-3]
  [p=R10:0@0-0; c=R2$@0-3]
ahm26: R11$@0-3
  R11$: [:start:]['] ::= [:start:] .
  [p=R11:0@0-0; c=R10$@0-3]
ahm2: R0$@0-3
  R0$: S ::= A S[R0:1] .
  [p=R0:1@0-1; c=R3$@1-3]
  [p=R0:1@0-1; c=R5$@1-3]
ahm9: R3$@1-3
  R3$: S[R0:1] ::= A S[R0:2] .
  [p=R3:1@1-2; c=R7$@2-3]
  [p=R3:1@1-2; c=R8$@2-3]
ahm21: R9:0@3-3
  R9:0: A ::= . [Lex-0]
Earley Set 4
ahm22: R9$@3-4
  R9$: A ::= [Lex-0] .
  [c=R9:0@3-3; s=[Lex-0]; t=\'a']
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
  R10$: [:start:] ::= S .
  [p=R10:0@0-0; c=R0$@0-4]
ahm26: R11$@0-4
  R11$: [:start:]['] ::= [:start:] .
  [p=R11:0@0-0; c=R10$@0-4]
END_OF_SETS

Marpa::R3::Test::is(
    $recce->earley_sets_show(2),
    $expected_earley_sets,
    'Aycock/Horspool Earley sets'
);

} ## end TESTS_FOLDED_FROM_ah2_t

# vim: expandtab shiftwidth=4:
