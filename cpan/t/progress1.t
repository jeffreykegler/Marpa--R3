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

# Non-working code, not kept up to date
# Kept for reference

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

my $grammar = Marpa::R3::Grammar->new( {   source => \$dsl });

Marpa::R3::Test::is( $grammar->productions_show(), <<'EOS', 'Aycock/Horspool Rules' );
R1 [:start:] ::= S
R2 S ::= A A A A A A A
R3 A ::=
R4 A ::= 'a'
R5 [:lex_start:] ~ 'a'
R6 'a' ~ [a]
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

Marpa::R3::Test::is( $grammar->nrls_show(),
    <<'EOS', 'Aycock/Horspool NRLs' );
0: S ::= A S[R0:1]
1: S ::= A A[] A[] A[] A[] A[] A[]
2: S ::= A[] S[R0:1]
3: S[R0:1] ::= A S[R0:2]
4: S[R0:1] ::= A A[] A[] A[] A[] A[]
5: S[R0:1] ::= A[] S[R0:2]
6: S[R0:2] ::= A S[R0:3]
7: S[R0:2] ::= A A[] A[] A[] A[]
8: S[R0:2] ::= A[] S[R0:3]
9: S[R0:3] ::= A S[R0:4]
10: S[R0:3] ::= A A[] A[] A[]
11: S[R0:3] ::= A[] S[R0:4]
12: S[R0:4] ::= A S[R0:5]
13: S[R0:4] ::= A A[] A[]
14: S[R0:4] ::= A[] S[R0:5]
15: S[R0:5] ::= A A
16: S[R0:5] ::= A A[]
17: S[R0:5] ::= A[] A
18: A ::= [Lex-0]
19: [:start:] ::= S
20: [:start:]['] ::= [:start:]
EOS

my $recce = Marpa::R3::Scanless::R->new( {   grammar => $grammar });
my $input_length = 7;
my $input = ('a' x $input_length);
$recce->read( \$input );

sub earley_set_display {
    my ($earley_set) = @_;
    my ($result) = $recce->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 'i', $earley_set );
      local slr, earley_set_id = ...
      return slr:progress_show(earley_set_id)
END_OF_LUA
    return $result;
}

Marpa::R3::Test::is( earley_set_display(0), <<'EOS', 'Earley Set 0' );
=== Earley set 0 at B1L1c1 ===
P1 B1L1c1 [:start:] ::= . S
P2 B1L1c1 S ::= . A A A A A A A
P4 B1L1c1 A ::= . 'a'
R2:1 B1L1c1 S ::= A . A A A A A A
R2:2 B1L1c1 S ::= A A . A A A A A
R2:3 B1L1c1 S ::= A A A . A A A A
R2:4 B1L1c1 S ::= A A A A . A A A
R2:5 B1L1c1 S ::= A A A A A . A A
R2:6 B1L1c1 S ::= A A A A A A . A
EOS

Marpa::R3::Test::is( earley_set_display(1),
    <<'EOS', 'Earley Set 1' );
=== Earley set 1 at B1L1c2 ===
P4 B1L1c2 A ::= . 'a'
R2:1 B1L1c1 S ::= A . A A A A A A
R2:2 B1L1c1 S ::= A A . A A A A A
R2:3 B1L1c1 S ::= A A A . A A A A
R2:4 B1L1c1 S ::= A A A A . A A A
R2:5 B1L1c1 S ::= A A A A A . A A
R2:6 B1L1c1 S ::= A A A A A A . A
F1 B1L1c1 [:start:] ::= S .
F2 B1L1c1 S ::= A A A A A A A .
F4 B1L1c1 A ::= 'a' .
EOS

Marpa::R3::Test::is( earley_set_display(2),
    <<'EOS', 'Earley Set 2' );
=== Earley set 2 at B1L1c3 ===
P4 B1L1c3 A ::= . 'a'
R2:2 B1L1c1 S ::= A A . A A A A A
R2:3 B1L1c1 S ::= A A A . A A A A
R2:4 B1L1c1 S ::= A A A A . A A A
R2:5 B1L1c1 S ::= A A A A A . A A
R2:6 B1L1c1 S ::= A A A A A A . A
F1 B1L1c1 [:start:] ::= S .
F2 B1L1c1 S ::= A A A A A A A .
F4 B1L1c2 A ::= 'a' .
EOS

Marpa::R3::Test::is( earley_set_display(3),
    <<'EOS', 'Earley Set 3' );
=== Earley set 3 at B1L1c4 ===
P4 B1L1c4 A ::= . 'a'
R2:3 B1L1c1 S ::= A A A . A A A A
R2:4 B1L1c1 S ::= A A A A . A A A
R2:5 B1L1c1 S ::= A A A A A . A A
R2:6 B1L1c1 S ::= A A A A A A . A
F1 B1L1c1 [:start:] ::= S .
F2 B1L1c1 S ::= A A A A A A A .
F4 B1L1c3 A ::= 'a' .
EOS

Marpa::R3::Test::is( earley_set_display(4),
    <<'EOS', 'Earley Set 4' );
=== Earley set 4 at B1L1c5 ===
P4 B1L1c5 A ::= . 'a'
R2:4 B1L1c1 S ::= A A A A . A A A
R2:5 B1L1c1 S ::= A A A A A . A A
R2:6 B1L1c1 S ::= A A A A A A . A
F1 B1L1c1 [:start:] ::= S .
F2 B1L1c1 S ::= A A A A A A A .
F4 B1L1c4 A ::= 'a' .
EOS

Marpa::R3::Test::is( earley_set_display(5),
    <<'EOS', 'Earley Set 5' );
=== Earley set 5 at B1L1c6 ===
P4 B1L1c6 A ::= . 'a'
R2:5 B1L1c1 S ::= A A A A A . A A
R2:6 B1L1c1 S ::= A A A A A A . A
F1 B1L1c1 [:start:] ::= S .
F2 B1L1c1 S ::= A A A A A A A .
F4 B1L1c5 A ::= 'a' .
EOS

Marpa::R3::Test::is( earley_set_display(6),
    <<'EOS', 'Earley Set 6' );
=== Earley set 6 at B1L1c7 ===
P4 B1L1c7 A ::= . 'a'
R2:6 B1L1c1 S ::= A A A A A A . A
F1 B1L1c1 [:start:] ::= S .
F2 B1L1c1 S ::= A A A A A A A .
F4 B1L1c6 A ::= 'a' .
EOS

Marpa::R3::Test::is( earley_set_display(7),
    <<'EOS', 'Earley Set 7' );
=== Earley set 7 at B1L1c8 ===
F1 B1L1c1 [:start:] ::= S .
F2 B1L1c1 S ::= A A A A A A A .
F4 B1L1c7 A ::= 'a' .
EOS

# vim: expandtab shiftwidth=4:
