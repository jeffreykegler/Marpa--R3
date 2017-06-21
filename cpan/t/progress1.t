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

use Test::More tests => 11;
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
S ::= A A A A A A A
A ::=
A ::= 'a'
END_OF_DSL

my $grammar = Marpa::R3::Scanless::G->new( {   source => \$dsl });

GRAMMAR_TESTS_FOLDED_FROM_ah2_t: {

Marpa::R3::Test::is( $grammar->show_rules, <<'EOS', 'Aycock/Horspool Rules' );
G1 R0 S ::= A A A A A A A
G1 R1 A ::=
G1 R2 A ::= 'a'
G1 R3 [:start] ::= S
EOS

Marpa::R3::Test::is( $grammar->show_symbols,
    <<'EOS', 'Aycock/Horspool Symbols' );
G1 S0 A
G1 S1 S
G1 S2 [:start]
G1 S3 'a'
EOS

Marpa::R3::Test::is( $grammar->show_nrls,
    <<'EOS', 'Aycock/Horspool IRLs' );
0: S -> A S[R0:1]
1: S -> A A[] A[] A[] A[] A[] A[]
2: S -> A[] S[R0:1]
3: S[R0:1] -> A S[R0:2]
4: S[R0:1] -> A A[] A[] A[] A[] A[]
5: S[R0:1] -> A[] S[R0:2]
6: S[R0:2] -> A S[R0:3]
7: S[R0:2] -> A A[] A[] A[] A[]
8: S[R0:2] -> A[] S[R0:3]
9: S[R0:3] -> A S[R0:4]
10: S[R0:3] -> A A[] A[] A[]
11: S[R0:3] -> A[] S[R0:4]
12: S[R0:4] -> A S[R0:5]
13: S[R0:4] -> A A[] A[]
14: S[R0:4] -> A[] S[R0:5]
15: S[R0:5] -> A A
16: S[R0:5] -> A A[]
17: S[R0:5] -> A[] A
18: A -> [Lex-0]
19: [:start] -> S
20: [:start]['] -> [:start]
EOS

}

my ($S_sym) = grep { $grammar->g1_symbol_name($_) eq 'S' } $grammar->g1_symbol_ids();
my ($target_rule) = grep { ($grammar->g1_rule_expand($_))[0] eq $S_sym } $grammar->rule_ids();
my $target_rule_length = -1 + scalar (() = $grammar->g1_rule_expand($target_rule));

my $recce = Marpa::R3::Scanless::R->new( {   grammar => $grammar });
my $input_length = 7;
my $input = ('a' x $input_length);
$recce->read( \$input );

sub earley_set_display {
    my ($earley_set) = @_;
    my @target_items =
      grep { $_->[0] eq $target_rule } @{ $recce->progress($earley_set) };
    my @data = ();
    for my $target_item (@target_items) {
        my ( $rule_id, $dot, $origin ) = @{$target_item};
        my $desc .=
            "S:$dot " . '@'
          . "$origin-$earley_set "
          . $grammar->show_dotted_rule( $rule_id, $dot );
        my $raw_dot = $dot < 0 ? $target_rule_length : $dot;
        my @datum = ( $raw_dot, $origin, $rule_id, $dot, $origin, $desc );
        push @data, \@datum;
    }
    my @sorted = map { $_->[-1] } sort { $a->[0] <=> $b->[0] || $a->[1] <=> $b->[1] } @data;
    return join "\n", "=== Earley Set $earley_set ===", @sorted, '';
}

Marpa::R3::Test::is( earley_set_display(0), <<'EOS', 'Earley Set 0' );
=== Earley Set 0 ===
S:0 @0-0 S -> . A A A A A A A
S:1 @0-0 S -> A . A A A A A A
S:2 @0-0 S -> A A . A A A A A
S:3 @0-0 S -> A A A . A A A A
S:4 @0-0 S -> A A A A . A A A
S:5 @0-0 S -> A A A A A . A A
S:6 @0-0 S -> A A A A A A . A
EOS

Marpa::R3::Test::is( earley_set_display(1), <<'EOS', 'Earley Set 1' );
=== Earley Set 1 ===
S:1 @0-1 S -> A . A A A A A A
S:2 @0-1 S -> A A . A A A A A
S:3 @0-1 S -> A A A . A A A A
S:4 @0-1 S -> A A A A . A A A
S:5 @0-1 S -> A A A A A . A A
S:6 @0-1 S -> A A A A A A . A
S:-1 @0-1 S -> A A A A A A A .
EOS

Marpa::R3::Test::is( earley_set_display(2), <<'EOS', 'Earley Set 2' );
=== Earley Set 2 ===
S:2 @0-2 S -> A A . A A A A A
S:3 @0-2 S -> A A A . A A A A
S:4 @0-2 S -> A A A A . A A A
S:5 @0-2 S -> A A A A A . A A
S:6 @0-2 S -> A A A A A A . A
S:-1 @0-2 S -> A A A A A A A .
EOS

Marpa::R3::Test::is( earley_set_display(3), <<'EOS', 'Earley Set 3' );
=== Earley Set 3 ===
S:3 @0-3 S -> A A A . A A A A
S:4 @0-3 S -> A A A A . A A A
S:5 @0-3 S -> A A A A A . A A
S:6 @0-3 S -> A A A A A A . A
S:-1 @0-3 S -> A A A A A A A .
EOS

Marpa::R3::Test::is( earley_set_display(4), <<'EOS', 'Earley Set 4' );
=== Earley Set 4 ===
S:4 @0-4 S -> A A A A . A A A
S:5 @0-4 S -> A A A A A . A A
S:6 @0-4 S -> A A A A A A . A
S:-1 @0-4 S -> A A A A A A A .
EOS

Marpa::R3::Test::is( earley_set_display(5), <<'EOS', 'Earley Set 5' );
=== Earley Set 5 ===
S:5 @0-5 S -> A A A A A . A A
S:6 @0-5 S -> A A A A A A . A
S:-1 @0-5 S -> A A A A A A A .
EOS

Marpa::R3::Test::is( earley_set_display(6), <<'EOS', 'Earley Set 6' );
=== Earley Set 6 ===
S:6 @0-6 S -> A A A A A A . A
S:-1 @0-6 S -> A A A A A A A .
EOS

Marpa::R3::Test::is( earley_set_display(7), <<'EOS', 'Earley Set 7' );
=== Earley Set 7 ===
S:-1 @0-7 S -> A A A A A A A .
EOS

# vim: expandtab shiftwidth=4:
