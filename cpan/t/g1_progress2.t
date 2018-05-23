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

use Test::More tests => 15;
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
S ::= SS SS
SS ::= A A A A A A A
A ::=
A ::= 'a'
END_OF_DSL

my $grammar = Marpa::R3::Grammar->new( {   source => \$dsl });

GRAMMAR_TESTS_FOLDED_FROM_ah2_t: {

Marpa::R3::Test::is( $grammar->g1_rules_show(), <<'EOS', 'Aycock/Horspool G1 Rules' );
R0 S ::= SS SS
R1 SS ::= A A A A A A A
R2 A ::=
R3 A ::= 'a'
R4 [:start:] ::= S
EOS

Marpa::R3::Test::is( $grammar->g1_symbols_show,
    <<'EOS', 'Aycock/Horspool G1 Symbols' );
g1 S0 A
g1 S1 S
g1 S2 SS
g1 S3 [:start:]
g1 S4 'a'
EOS

Marpa::R3::Test::is( $grammar->nrls_show(),
    <<'EOS', 'Aycock/Horspool IRLs' );
0: S ::= SS SS
1: S ::= SS SS[]
2: S ::= SS[] SS
3: SS ::= A SS[R1:1]
4: SS ::= A A[] A[] A[] A[] A[] A[]
5: SS ::= A[] SS[R1:1]
6: SS[R1:1] ::= A SS[R1:2]
7: SS[R1:1] ::= A A[] A[] A[] A[] A[]
8: SS[R1:1] ::= A[] SS[R1:2]
9: SS[R1:2] ::= A SS[R1:3]
10: SS[R1:2] ::= A A[] A[] A[] A[]
11: SS[R1:2] ::= A[] SS[R1:3]
12: SS[R1:3] ::= A SS[R1:4]
13: SS[R1:3] ::= A A[] A[] A[]
14: SS[R1:3] ::= A[] SS[R1:4]
15: SS[R1:4] ::= A SS[R1:5]
16: SS[R1:4] ::= A A[] A[]
17: SS[R1:4] ::= A[] SS[R1:5]
18: SS[R1:5] ::= A A
19: SS[R1:5] ::= A A[]
20: SS[R1:5] ::= A[] A
21: A ::= [Lex-0]
22: [:start:] ::= S
EOS

}

my $SS_sym;
SYMBOL: for (
    my $iter = $grammar->g1_symbol_ids_gen() ;
    defined( my $symbol_id = $iter->() ) ;
  )
{
    if ( $grammar->g1_symbol_name($symbol_id) eq 'SS' ) {
        $SS_sym = $symbol_id;
        last SYMBOL;
    }
}

my $target_rule;
RULE: for (
    my $iter = $grammar->g1_rule_ids_gen() ;
    defined( my $rule_id = $iter->() ) ;
  )
{
    if ( ( $grammar->g1_rule_expand($rule_id) )[0] eq $SS_sym ) {
        $target_rule = $rule_id;
        last RULE;
    }
}

my $target_rule_length = -1 + scalar (() = $grammar->g1_rule_expand($target_rule));

my $recce = Marpa::R3::Recognizer->new( {   grammar => $grammar });
my $input_length = 11;
my $input = ('a' x $input_length);
$recce->read( \$input );

sub earley_set_display {
    my ($earley_set) = @_;
    my @target_items =
      grep { $_->[0] eq $target_rule } @{ $recce->g1_progress($earley_set) };
    my @data = ();
    for my $target_item (@target_items) {
        my ( $rule_id, $dot, $origin ) = @{$target_item};
        my $desc .=
            "S:$dot " . '@'
          . "$origin-$earley_set "
          . $grammar->g1_dotted_rule_show( $rule_id, $dot );
        my $raw_dot = $dot < 0 ? $target_rule_length : $dot;
        my @datum = ( $raw_dot, $origin, $rule_id, $dot, $origin, $desc );
        push @data, \@datum;
    }
    my @sorted = map { $_->[-1] } sort { $a->[0] <=> $b->[0] || $a->[1] <=> $b->[1] } @data;
    return join "\n", "=== Earley Set $earley_set ===", @sorted, '';
}

Marpa::R3::Test::is( earley_set_display(0), <<'EOS', 'Earley Set 0' );
=== Earley Set 0 ===
S:0 @0-0 SS ::= . A A A A A A A
S:1 @0-0 SS ::= A . A A A A A A
S:2 @0-0 SS ::= A A . A A A A A
S:3 @0-0 SS ::= A A A . A A A A
S:4 @0-0 SS ::= A A A A . A A A
S:5 @0-0 SS ::= A A A A A . A A
S:6 @0-0 SS ::= A A A A A A . A
EOS

Marpa::R3::Test::is( earley_set_display(1), <<'EOS', 'Earley Set 1' );
=== Earley Set 1 ===
S:0 @1-1 SS ::= . A A A A A A A
S:1 @0-1 SS ::= A . A A A A A A
S:1 @1-1 SS ::= A . A A A A A A
S:2 @0-1 SS ::= A A . A A A A A
S:2 @1-1 SS ::= A A . A A A A A
S:3 @0-1 SS ::= A A A . A A A A
S:3 @1-1 SS ::= A A A . A A A A
S:4 @0-1 SS ::= A A A A . A A A
S:4 @1-1 SS ::= A A A A . A A A
S:5 @0-1 SS ::= A A A A A . A A
S:5 @1-1 SS ::= A A A A A . A A
S:6 @0-1 SS ::= A A A A A A . A
S:6 @1-1 SS ::= A A A A A A . A
S:-1 @0-1 SS ::= A A A A A A A .
EOS

Marpa::R3::Test::is( earley_set_display(2), <<'EOS', 'Earley Set 2' );
=== Earley Set 2 ===
S:0 @2-2 SS ::= . A A A A A A A
S:1 @1-2 SS ::= A . A A A A A A
S:1 @2-2 SS ::= A . A A A A A A
S:2 @0-2 SS ::= A A . A A A A A
S:2 @1-2 SS ::= A A . A A A A A
S:2 @2-2 SS ::= A A . A A A A A
S:3 @0-2 SS ::= A A A . A A A A
S:3 @1-2 SS ::= A A A . A A A A
S:3 @2-2 SS ::= A A A . A A A A
S:4 @0-2 SS ::= A A A A . A A A
S:4 @1-2 SS ::= A A A A . A A A
S:4 @2-2 SS ::= A A A A . A A A
S:5 @0-2 SS ::= A A A A A . A A
S:5 @1-2 SS ::= A A A A A . A A
S:5 @2-2 SS ::= A A A A A . A A
S:6 @0-2 SS ::= A A A A A A . A
S:6 @1-2 SS ::= A A A A A A . A
S:6 @2-2 SS ::= A A A A A A . A
S:-1 @0-2 SS ::= A A A A A A A .
S:-1 @1-2 SS ::= A A A A A A A .
EOS

Marpa::R3::Test::is( earley_set_display(3), <<'EOS', 'Earley Set 3' );
=== Earley Set 3 ===
S:0 @3-3 SS ::= . A A A A A A A
S:1 @2-3 SS ::= A . A A A A A A
S:1 @3-3 SS ::= A . A A A A A A
S:2 @1-3 SS ::= A A . A A A A A
S:2 @2-3 SS ::= A A . A A A A A
S:2 @3-3 SS ::= A A . A A A A A
S:3 @0-3 SS ::= A A A . A A A A
S:3 @1-3 SS ::= A A A . A A A A
S:3 @2-3 SS ::= A A A . A A A A
S:3 @3-3 SS ::= A A A . A A A A
S:4 @0-3 SS ::= A A A A . A A A
S:4 @1-3 SS ::= A A A A . A A A
S:4 @2-3 SS ::= A A A A . A A A
S:4 @3-3 SS ::= A A A A . A A A
S:5 @0-3 SS ::= A A A A A . A A
S:5 @1-3 SS ::= A A A A A . A A
S:5 @2-3 SS ::= A A A A A . A A
S:5 @3-3 SS ::= A A A A A . A A
S:6 @0-3 SS ::= A A A A A A . A
S:6 @1-3 SS ::= A A A A A A . A
S:6 @2-3 SS ::= A A A A A A . A
S:6 @3-3 SS ::= A A A A A A . A
S:-1 @0-3 SS ::= A A A A A A A .
S:-1 @1-3 SS ::= A A A A A A A .
S:-1 @2-3 SS ::= A A A A A A A .
EOS

Marpa::R3::Test::is( earley_set_display(4), <<'EOS', 'Earley Set 4' );
=== Earley Set 4 ===
S:0 @4-4 SS ::= . A A A A A A A
S:1 @3-4 SS ::= A . A A A A A A
S:1 @4-4 SS ::= A . A A A A A A
S:2 @2-4 SS ::= A A . A A A A A
S:2 @3-4 SS ::= A A . A A A A A
S:2 @4-4 SS ::= A A . A A A A A
S:3 @1-4 SS ::= A A A . A A A A
S:3 @2-4 SS ::= A A A . A A A A
S:3 @3-4 SS ::= A A A . A A A A
S:3 @4-4 SS ::= A A A . A A A A
S:4 @0-4 SS ::= A A A A . A A A
S:4 @1-4 SS ::= A A A A . A A A
S:4 @2-4 SS ::= A A A A . A A A
S:4 @3-4 SS ::= A A A A . A A A
S:4 @4-4 SS ::= A A A A . A A A
S:5 @0-4 SS ::= A A A A A . A A
S:5 @1-4 SS ::= A A A A A . A A
S:5 @2-4 SS ::= A A A A A . A A
S:5 @3-4 SS ::= A A A A A . A A
S:5 @4-4 SS ::= A A A A A . A A
S:6 @0-4 SS ::= A A A A A A . A
S:6 @1-4 SS ::= A A A A A A . A
S:6 @2-4 SS ::= A A A A A A . A
S:6 @3-4 SS ::= A A A A A A . A
S:6 @4-4 SS ::= A A A A A A . A
S:-1 @0-4 SS ::= A A A A A A A .
S:-1 @1-4 SS ::= A A A A A A A .
S:-1 @2-4 SS ::= A A A A A A A .
S:-1 @3-4 SS ::= A A A A A A A .
EOS

Marpa::R3::Test::is( earley_set_display(5), <<'EOS', 'Earley Set 5' );
=== Earley Set 5 ===
S:0 @5-5 SS ::= . A A A A A A A
S:1 @4-5 SS ::= A . A A A A A A
S:1 @5-5 SS ::= A . A A A A A A
S:2 @3-5 SS ::= A A . A A A A A
S:2 @4-5 SS ::= A A . A A A A A
S:2 @5-5 SS ::= A A . A A A A A
S:3 @2-5 SS ::= A A A . A A A A
S:3 @3-5 SS ::= A A A . A A A A
S:3 @4-5 SS ::= A A A . A A A A
S:3 @5-5 SS ::= A A A . A A A A
S:4 @1-5 SS ::= A A A A . A A A
S:4 @2-5 SS ::= A A A A . A A A
S:4 @3-5 SS ::= A A A A . A A A
S:4 @4-5 SS ::= A A A A . A A A
S:4 @5-5 SS ::= A A A A . A A A
S:5 @0-5 SS ::= A A A A A . A A
S:5 @1-5 SS ::= A A A A A . A A
S:5 @2-5 SS ::= A A A A A . A A
S:5 @3-5 SS ::= A A A A A . A A
S:5 @4-5 SS ::= A A A A A . A A
S:5 @5-5 SS ::= A A A A A . A A
S:6 @0-5 SS ::= A A A A A A . A
S:6 @1-5 SS ::= A A A A A A . A
S:6 @2-5 SS ::= A A A A A A . A
S:6 @3-5 SS ::= A A A A A A . A
S:6 @4-5 SS ::= A A A A A A . A
S:6 @5-5 SS ::= A A A A A A . A
S:-1 @0-5 SS ::= A A A A A A A .
S:-1 @1-5 SS ::= A A A A A A A .
S:-1 @2-5 SS ::= A A A A A A A .
S:-1 @3-5 SS ::= A A A A A A A .
S:-1 @4-5 SS ::= A A A A A A A .
EOS

Marpa::R3::Test::is( earley_set_display(6), <<'EOS', 'Earley Set 6' );
=== Earley Set 6 ===
S:0 @6-6 SS ::= . A A A A A A A
S:1 @5-6 SS ::= A . A A A A A A
S:1 @6-6 SS ::= A . A A A A A A
S:2 @4-6 SS ::= A A . A A A A A
S:2 @5-6 SS ::= A A . A A A A A
S:2 @6-6 SS ::= A A . A A A A A
S:3 @3-6 SS ::= A A A . A A A A
S:3 @4-6 SS ::= A A A . A A A A
S:3 @5-6 SS ::= A A A . A A A A
S:3 @6-6 SS ::= A A A . A A A A
S:4 @2-6 SS ::= A A A A . A A A
S:4 @3-6 SS ::= A A A A . A A A
S:4 @4-6 SS ::= A A A A . A A A
S:4 @5-6 SS ::= A A A A . A A A
S:4 @6-6 SS ::= A A A A . A A A
S:5 @1-6 SS ::= A A A A A . A A
S:5 @2-6 SS ::= A A A A A . A A
S:5 @3-6 SS ::= A A A A A . A A
S:5 @4-6 SS ::= A A A A A . A A
S:5 @5-6 SS ::= A A A A A . A A
S:5 @6-6 SS ::= A A A A A . A A
S:6 @0-6 SS ::= A A A A A A . A
S:6 @1-6 SS ::= A A A A A A . A
S:6 @2-6 SS ::= A A A A A A . A
S:6 @3-6 SS ::= A A A A A A . A
S:6 @4-6 SS ::= A A A A A A . A
S:6 @5-6 SS ::= A A A A A A . A
S:6 @6-6 SS ::= A A A A A A . A
S:-1 @0-6 SS ::= A A A A A A A .
S:-1 @1-6 SS ::= A A A A A A A .
S:-1 @2-6 SS ::= A A A A A A A .
S:-1 @3-6 SS ::= A A A A A A A .
S:-1 @4-6 SS ::= A A A A A A A .
S:-1 @5-6 SS ::= A A A A A A A .
EOS

Marpa::R3::Test::is( earley_set_display(7), <<'EOS', 'Earley Set 7' );
=== Earley Set 7 ===
S:0 @7-7 SS ::= . A A A A A A A
S:1 @6-7 SS ::= A . A A A A A A
S:1 @7-7 SS ::= A . A A A A A A
S:2 @5-7 SS ::= A A . A A A A A
S:2 @6-7 SS ::= A A . A A A A A
S:2 @7-7 SS ::= A A . A A A A A
S:3 @4-7 SS ::= A A A . A A A A
S:3 @5-7 SS ::= A A A . A A A A
S:3 @6-7 SS ::= A A A . A A A A
S:3 @7-7 SS ::= A A A . A A A A
S:4 @3-7 SS ::= A A A A . A A A
S:4 @4-7 SS ::= A A A A . A A A
S:4 @5-7 SS ::= A A A A . A A A
S:4 @6-7 SS ::= A A A A . A A A
S:4 @7-7 SS ::= A A A A . A A A
S:5 @2-7 SS ::= A A A A A . A A
S:5 @3-7 SS ::= A A A A A . A A
S:5 @4-7 SS ::= A A A A A . A A
S:5 @5-7 SS ::= A A A A A . A A
S:5 @6-7 SS ::= A A A A A . A A
S:5 @7-7 SS ::= A A A A A . A A
S:6 @1-7 SS ::= A A A A A A . A
S:6 @2-7 SS ::= A A A A A A . A
S:6 @3-7 SS ::= A A A A A A . A
S:6 @4-7 SS ::= A A A A A A . A
S:6 @5-7 SS ::= A A A A A A . A
S:6 @6-7 SS ::= A A A A A A . A
S:6 @7-7 SS ::= A A A A A A . A
S:-1 @0-7 SS ::= A A A A A A A .
S:-1 @1-7 SS ::= A A A A A A A .
S:-1 @2-7 SS ::= A A A A A A A .
S:-1 @3-7 SS ::= A A A A A A A .
S:-1 @4-7 SS ::= A A A A A A A .
S:-1 @5-7 SS ::= A A A A A A A .
S:-1 @6-7 SS ::= A A A A A A A .
EOS

Marpa::R3::Test::is( earley_set_display(8), <<'EOS', 'Earley Set 8' );
=== Earley Set 8 ===
S:1 @7-8 SS ::= A . A A A A A A
S:2 @6-8 SS ::= A A . A A A A A
S:2 @7-8 SS ::= A A . A A A A A
S:3 @5-8 SS ::= A A A . A A A A
S:3 @6-8 SS ::= A A A . A A A A
S:3 @7-8 SS ::= A A A . A A A A
S:4 @4-8 SS ::= A A A A . A A A
S:4 @5-8 SS ::= A A A A . A A A
S:4 @6-8 SS ::= A A A A . A A A
S:4 @7-8 SS ::= A A A A . A A A
S:5 @3-8 SS ::= A A A A A . A A
S:5 @4-8 SS ::= A A A A A . A A
S:5 @5-8 SS ::= A A A A A . A A
S:5 @6-8 SS ::= A A A A A . A A
S:5 @7-8 SS ::= A A A A A . A A
S:6 @2-8 SS ::= A A A A A A . A
S:6 @3-8 SS ::= A A A A A A . A
S:6 @4-8 SS ::= A A A A A A . A
S:6 @5-8 SS ::= A A A A A A . A
S:6 @6-8 SS ::= A A A A A A . A
S:6 @7-8 SS ::= A A A A A A . A
S:-1 @1-8 SS ::= A A A A A A A .
S:-1 @2-8 SS ::= A A A A A A A .
S:-1 @3-8 SS ::= A A A A A A A .
S:-1 @4-8 SS ::= A A A A A A A .
S:-1 @5-8 SS ::= A A A A A A A .
S:-1 @6-8 SS ::= A A A A A A A .
S:-1 @7-8 SS ::= A A A A A A A .
EOS

Marpa::R3::Test::is( earley_set_display(9), <<'EOS', 'Earley Set 9' );
=== Earley Set 9 ===
S:2 @7-9 SS ::= A A . A A A A A
S:3 @6-9 SS ::= A A A . A A A A
S:3 @7-9 SS ::= A A A . A A A A
S:4 @5-9 SS ::= A A A A . A A A
S:4 @6-9 SS ::= A A A A . A A A
S:4 @7-9 SS ::= A A A A . A A A
S:5 @4-9 SS ::= A A A A A . A A
S:5 @5-9 SS ::= A A A A A . A A
S:5 @6-9 SS ::= A A A A A . A A
S:5 @7-9 SS ::= A A A A A . A A
S:6 @3-9 SS ::= A A A A A A . A
S:6 @4-9 SS ::= A A A A A A . A
S:6 @5-9 SS ::= A A A A A A . A
S:6 @6-9 SS ::= A A A A A A . A
S:6 @7-9 SS ::= A A A A A A . A
S:-1 @2-9 SS ::= A A A A A A A .
S:-1 @3-9 SS ::= A A A A A A A .
S:-1 @4-9 SS ::= A A A A A A A .
S:-1 @5-9 SS ::= A A A A A A A .
S:-1 @6-9 SS ::= A A A A A A A .
S:-1 @7-9 SS ::= A A A A A A A .
EOS

Marpa::R3::Test::is( earley_set_display(10), <<'EOS', 'Earley Set 10' );
=== Earley Set 10 ===
S:3 @7-10 SS ::= A A A . A A A A
S:4 @6-10 SS ::= A A A A . A A A
S:4 @7-10 SS ::= A A A A . A A A
S:5 @5-10 SS ::= A A A A A . A A
S:5 @6-10 SS ::= A A A A A . A A
S:5 @7-10 SS ::= A A A A A . A A
S:6 @4-10 SS ::= A A A A A A . A
S:6 @5-10 SS ::= A A A A A A . A
S:6 @6-10 SS ::= A A A A A A . A
S:6 @7-10 SS ::= A A A A A A . A
S:-1 @3-10 SS ::= A A A A A A A .
S:-1 @4-10 SS ::= A A A A A A A .
S:-1 @5-10 SS ::= A A A A A A A .
S:-1 @6-10 SS ::= A A A A A A A .
S:-1 @7-10 SS ::= A A A A A A A .
EOS

Marpa::R3::Test::is( earley_set_display(11), <<'EOS', 'Earley Set 11' );
=== Earley Set 11 ===
S:4 @7-11 SS ::= A A A A . A A A
S:5 @6-11 SS ::= A A A A A . A A
S:5 @7-11 SS ::= A A A A A . A A
S:6 @5-11 SS ::= A A A A A A . A
S:6 @6-11 SS ::= A A A A A A . A
S:6 @7-11 SS ::= A A A A A A . A
S:-1 @4-11 SS ::= A A A A A A A .
S:-1 @5-11 SS ::= A A A A A A A .
S:-1 @6-11 SS ::= A A A A A A A .
S:-1 @7-11 SS ::= A A A A A A A .
EOS

# vim: expandtab shiftwidth=4:
