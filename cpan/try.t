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

# Note: ah2.t and bocage.t folded into this test

# the example grammar in Aycock/Horspool "Practical Earley Parsing",
# _The Computer Journal_, Vol. 45, No. 6, pp. 620-630,
# in its "NNF" form

use 5.010001;

use strict;
use warnings;

use Test::More tests => 37;
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

Marpa::R3::Test::is( $grammar->ahms_show({verbose=>2}),
    <<'EOS', 'Aycock/Horspool AHMs' );
AHM 0: dot=0; nulls=0
    S ::= . A S[R0:1]
    {}
AHM 1: dot=1; nulls=0
    S ::= A . S[R0:1]
    { { 1, "b" } }
AHM 2: completion; dot=2; nulls=0
    S ::= A S[R0:1] .
    {}
AHM 3: dot=0; nulls=0
    S ::= . A A[] A[] A[]
    {}
AHM 4: completion; dot=4; nulls=3
    S ::= A A[] A[] A[] .
    { { 1, "b" }, { 1, "n" }, { 1, "n" }, { 1, "n" } }
AHM 5: dot=1; nulls=1
    S ::= A[] . S[R0:1]
    { { 1, "n" } }
AHM 6: completion; dot=2; nulls=0
    S ::= A[] S[R0:1] .
    {}
AHM 7: dot=0; nulls=0
    S[R0:1] ::= . A S[R0:2]
    {}
AHM 8: dot=1; nulls=0
    S[R0:1] ::= A . S[R0:2]
    { { 1, "b" } }
AHM 9: completion; dot=2; nulls=0
    S[R0:1] ::= A S[R0:2] .
    {}
AHM 10: dot=0; nulls=0
    S[R0:1] ::= . A A[] A[]
    {}
AHM 11: completion; dot=3; nulls=2
    S[R0:1] ::= A A[] A[] .
    { { 1, "b" }, { 1, "n" }, { 1, "n" } }
AHM 12: dot=1; nulls=1
    S[R0:1] ::= A[] . S[R0:2]
    { { 1, "n" } }
AHM 13: completion; dot=2; nulls=0
    S[R0:1] ::= A[] S[R0:2] .
    {}
AHM 14: dot=0; nulls=0
    S[R0:2] ::= . A A
    {}
AHM 15: dot=1; nulls=0
    S[R0:2] ::= A . A
    { { 1, "b" } }
AHM 16: completion; dot=2; nulls=0
    S[R0:2] ::= A A .
    { { 1, "b" } }
AHM 17: dot=0; nulls=0
    S[R0:2] ::= . A A[]
    {}
AHM 18: completion; dot=2; nulls=1
    S[R0:2] ::= A A[] .
    { { 1, "b" }, { 1, "n" } }
AHM 19: dot=1; nulls=1
    S[R0:2] ::= A[] . A
    { { 1, "n" } }
AHM 20: completion; dot=2; nulls=0
    S[R0:2] ::= A[] A .
    { { 1, "b" } }
AHM 21: dot=0; nulls=0
    A ::= . [Lex-0]
    {}
AHM 22: completion; dot=1; nulls=0
    A ::= [Lex-0] .
    { { 5, "t" } }
AHM 23: dot=0; nulls=0
    [:start:] ::= . S
    {}
AHM 24: completion; dot=1; nulls=0
    [:start:] ::= S .
    { { 2, "b" } }
AHM 25: dot=0; nulls=0
    [:start:]['] ::= . [:start:]
    {}
AHM 26: completion; dot=1; nulls=0
    [:start:]['] ::= [:start:] .
    { { 4, "b" } }
EOS

}

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

for my $i ( 0 .. $input_length ) {

    my $valuer = Marpa::R3::Valuer->new( { recognizer => $recce, end => $i } );
    my $expected = $expected[$i];

    my $ambiguity_level = $valuer->ambiguity_level();

    my $expected_metric = ( scalar keys %{$expected} > 1 ? 2 : 1 );
    Test::More::is( $ambiguity_level, $expected_metric,
        "Ambiguity check for length $i" );

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

    # TODO: For now, we don't handle null parses
    if ($i > 0) {
        my $asf =
          Marpa::R3::ASF->new( { recognizer => $recce, end => $i } );
        die 'No ASF' if not defined $asf;
    }

    # TODO: Commented out for now.
    if (0) {

        my $ambiguity_desc = 'No ambiguity';
        if ( $ambiguity_level > 1 ) {

            my $asf =
              Marpa::R3::ASF->new( { recognizer => $recce, end => $i } );
            die 'No ASF' if not defined $asf;
            my $ambiguities = Marpa::R3::Internal_ASF::ambiguities($asf);

            # Only report the first two
            my @ambiguities = grep { defined } @{$ambiguities}[ 0 .. 1 ];

            $ambiguity_desc =
              Marpa::R3::Internal_ASF::ambiguities_show( $asf, \@ambiguities );
        }

        Marpa::R3::Test::is( $ambiguity_desc, $ambiguity_expected[$i],
            "Ambiguity description for length $i" );

    }

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
