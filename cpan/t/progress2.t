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

use Test::More tests => 12;
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


my $recce = Marpa::R3::Scanless::R->new( {   grammar => $grammar });
my $input_length = 11;
my $input = ('a' x $input_length);
$recce->read( \$input );

Marpa::R3::Test::is( $recce->progress_show(0), <<'EOS', 'Earley Set 0' );
=== Earley set 0 at B1L1c1 ===
P1 B1L1c1 [:start:] ::= . S
P2 B1L1c1 S ::= . SS SS
P3 B1L1c1 SS ::= . A A A A A A A
P5 B1L1c1 A ::= . 'a'
R2:1 B1L1c1 S ::= SS . SS
R3:1 B1L1c1 SS ::= A . A A A A A A
R3:2 B1L1c1 SS ::= A A . A A A A A
R3:3 B1L1c1 SS ::= A A A . A A A A
R3:4 B1L1c1 SS ::= A A A A . A A A
R3:5 B1L1c1 SS ::= A A A A A . A A
R3:6 B1L1c1 SS ::= A A A A A A . A
EOS

Marpa::R3::Test::is( $recce->progress_show(1), <<'EOS', 'Earley Set 1' );
=== Earley set 1 at B1L1c2 ===
P3 B1L1c2 SS ::= . A A A A A A A
P5 B1L1c2 A ::= . 'a'
R2:1 B1L1c1 S ::= SS . SS
R3:1 x2 B1L1c1-2 SS ::= A . A A A A A A
R3:2 x2 B1L1c1-2 SS ::= A A . A A A A A
R3:3 x2 B1L1c1-2 SS ::= A A A . A A A A
R3:4 x2 B1L1c1-2 SS ::= A A A A . A A A
R3:5 x2 B1L1c1-2 SS ::= A A A A A . A A
R3:6 x2 B1L1c1-2 SS ::= A A A A A A . A
F1 B1L1c1 [:start:] ::= S .
F2 B1L1c1 S ::= SS SS .
F3 B1L1c1 SS ::= A A A A A A A .
F5 B1L1c1 A ::= 'a' .
EOS

Marpa::R3::Test::is( $recce->progress_show(2), <<'EOS', 'Earley Set 2' );
=== Earley set 2 at B1L1c3 ===
P3 B1L1c3 SS ::= . A A A A A A A
P5 B1L1c3 A ::= . 'a'
R2:1 B1L1c1 S ::= SS . SS
R3:1 x2 B1L1c2-3 SS ::= A . A A A A A A
R3:2 x3 B1L1c1-3 SS ::= A A . A A A A A
R3:3 x3 B1L1c1-3 SS ::= A A A . A A A A
R3:4 x3 B1L1c1-3 SS ::= A A A A . A A A
R3:5 x3 B1L1c1-3 SS ::= A A A A A . A A
R3:6 x3 B1L1c1-3 SS ::= A A A A A A . A
F1 B1L1c1 [:start:] ::= S .
F2 B1L1c1 S ::= SS SS .
F3 x2 B1L1c1-2 SS ::= A A A A A A A .
F5 B1L1c2 A ::= 'a' .
EOS

Marpa::R3::Test::is( $recce->progress_show(3), <<'EOS', 'Earley Set 3' );
=== Earley set 3 at B1L1c4 ===
P3 B1L1c4 SS ::= . A A A A A A A
P5 B1L1c4 A ::= . 'a'
R2:1 B1L1c1 S ::= SS . SS
R3:1 x2 B1L1c3-4 SS ::= A . A A A A A A
R3:2 x3 B1L1c2-4 SS ::= A A . A A A A A
R3:3 x4 B1L1c1-4 SS ::= A A A . A A A A
R3:4 x4 B1L1c1-4 SS ::= A A A A . A A A
R3:5 x4 B1L1c1-4 SS ::= A A A A A . A A
R3:6 x4 B1L1c1-4 SS ::= A A A A A A . A
F1 B1L1c1 [:start:] ::= S .
F2 B1L1c1 S ::= SS SS .
F3 x3 B1L1c1-3 SS ::= A A A A A A A .
F5 B1L1c3 A ::= 'a' .
EOS

Marpa::R3::Test::is( $recce->progress_show(4), <<'EOS', 'Earley Set 4' );
=== Earley set 4 at B1L1c5 ===
P3 B1L1c5 SS ::= . A A A A A A A
P5 B1L1c5 A ::= . 'a'
R2:1 B1L1c1 S ::= SS . SS
R3:1 x2 B1L1c4-5 SS ::= A . A A A A A A
R3:2 x3 B1L1c3-5 SS ::= A A . A A A A A
R3:3 x4 B1L1c2-5 SS ::= A A A . A A A A
R3:4 x5 B1L1c1-5 SS ::= A A A A . A A A
R3:5 x5 B1L1c1-5 SS ::= A A A A A . A A
R3:6 x5 B1L1c1-5 SS ::= A A A A A A . A
F1 B1L1c1 [:start:] ::= S .
F2 B1L1c1 S ::= SS SS .
F3 x4 B1L1c1-4 SS ::= A A A A A A A .
F5 B1L1c4 A ::= 'a' .
EOS

Marpa::R3::Test::is( $recce->progress_show(5), <<'EOS', 'Earley Set 5' );
=== Earley set 5 at B1L1c6 ===
P3 B1L1c6 SS ::= . A A A A A A A
P5 B1L1c6 A ::= . 'a'
R2:1 B1L1c1 S ::= SS . SS
R3:1 x2 B1L1c5-6 SS ::= A . A A A A A A
R3:2 x3 B1L1c4-6 SS ::= A A . A A A A A
R3:3 x4 B1L1c3-6 SS ::= A A A . A A A A
R3:4 x5 B1L1c2-6 SS ::= A A A A . A A A
R3:5 x6 B1L1c1-6 SS ::= A A A A A . A A
R3:6 x6 B1L1c1-6 SS ::= A A A A A A . A
F1 B1L1c1 [:start:] ::= S .
F2 B1L1c1 S ::= SS SS .
F3 x5 B1L1c1-5 SS ::= A A A A A A A .
F5 B1L1c5 A ::= 'a' .
EOS

Marpa::R3::Test::is( $recce->progress_show(6), <<'EOS', 'Earley Set 6' );
=== Earley set 6 at B1L1c7 ===
P3 B1L1c7 SS ::= . A A A A A A A
P5 B1L1c7 A ::= . 'a'
R2:1 B1L1c1 S ::= SS . SS
R3:1 x2 B1L1c6-7 SS ::= A . A A A A A A
R3:2 x3 B1L1c5-7 SS ::= A A . A A A A A
R3:3 x4 B1L1c4-7 SS ::= A A A . A A A A
R3:4 x5 B1L1c3-7 SS ::= A A A A . A A A
R3:5 x6 B1L1c2-7 SS ::= A A A A A . A A
R3:6 x7 B1L1c1-7 SS ::= A A A A A A . A
F1 B1L1c1 [:start:] ::= S .
F2 B1L1c1 S ::= SS SS .
F3 x6 B1L1c1-6 SS ::= A A A A A A A .
F5 B1L1c6 A ::= 'a' .
EOS

Marpa::R3::Test::is( $recce->progress_show(7), <<'EOS', 'Earley Set 7' );
=== Earley set 7 at B1L1c8 ===
P3 B1L1c8 SS ::= . A A A A A A A
P5 B1L1c8 A ::= . 'a'
R2:1 B1L1c1 S ::= SS . SS
R3:1 x2 B1L1c7-8 SS ::= A . A A A A A A
R3:2 x3 B1L1c6-8 SS ::= A A . A A A A A
R3:3 x4 B1L1c5-8 SS ::= A A A . A A A A
R3:4 x5 B1L1c4-8 SS ::= A A A A . A A A
R3:5 x6 B1L1c3-8 SS ::= A A A A A . A A
R3:6 x7 B1L1c2-8 SS ::= A A A A A A . A
F1 B1L1c1 [:start:] ::= S .
F2 B1L1c1 S ::= SS SS .
F3 x7 B1L1c1-7 SS ::= A A A A A A A .
F5 B1L1c7 A ::= 'a' .
EOS

Marpa::R3::Test::is( $recce->progress_show(8), <<'EOS', 'Earley Set 8' );
=== Earley set 8 at B1L1c9 ===
P5 B1L1c9 A ::= . 'a'
R3:1 B1L1c8 SS ::= A . A A A A A A
R3:2 x2 B1L1c7-8 SS ::= A A . A A A A A
R3:3 x3 B1L1c6-8 SS ::= A A A . A A A A
R3:4 x4 B1L1c5-8 SS ::= A A A A . A A A
R3:5 x5 B1L1c4-8 SS ::= A A A A A . A A
R3:6 x6 B1L1c3-8 SS ::= A A A A A A . A
F1 B1L1c1 [:start:] ::= S .
F2 B1L1c1 S ::= SS SS .
F3 x7 B1L1c2-8 SS ::= A A A A A A A .
F5 B1L1c8 A ::= 'a' .
EOS

Marpa::R3::Test::is( $recce->progress_show(9), <<'EOS', 'Earley Set 9' );
=== Earley set 9 at B1L1c10 ===
P5 B1L1c10 A ::= . 'a'
R3:2 B1L1c8 SS ::= A A . A A A A A
R3:3 x2 B1L1c7-8 SS ::= A A A . A A A A
R3:4 x3 B1L1c6-8 SS ::= A A A A . A A A
R3:5 x4 B1L1c5-8 SS ::= A A A A A . A A
R3:6 x5 B1L1c4-8 SS ::= A A A A A A . A
F1 B1L1c1 [:start:] ::= S .
F2 B1L1c1 S ::= SS SS .
F3 x6 B1L1c3-8 SS ::= A A A A A A A .
F5 B1L1c9 A ::= 'a' .
EOS

Marpa::R3::Test::is( $recce->progress_show(10), <<'EOS', 'Earley Set 10' );
=== Earley set 10 at B1L1c11 ===
P5 B1L1c11 A ::= . 'a'
R3:3 B1L1c8 SS ::= A A A . A A A A
R3:4 x2 B1L1c7-8 SS ::= A A A A . A A A
R3:5 x3 B1L1c6-8 SS ::= A A A A A . A A
R3:6 x4 B1L1c5-8 SS ::= A A A A A A . A
F1 B1L1c1 [:start:] ::= S .
F2 B1L1c1 S ::= SS SS .
F3 x5 B1L1c4-8 SS ::= A A A A A A A .
F5 B1L1c10 A ::= 'a' .
EOS

Marpa::R3::Test::is( $recce->progress_show(11), <<'EOS', 'Earley Set 11' );
=== Earley set 11 at B1L1c12 ===
P5 B1L1c12 A ::= . 'a'
R3:4 B1L1c8 SS ::= A A A A . A A A
R3:5 x2 B1L1c7-8 SS ::= A A A A A . A A
R3:6 x3 B1L1c6-8 SS ::= A A A A A A . A
F1 B1L1c1 [:start:] ::= S .
F2 B1L1c1 S ::= SS SS .
F3 x4 B1L1c5-8 SS ::= A A A A A A A .
F5 B1L1c11 A ::= 'a' .
EOS

# vim: expandtab shiftwidth=4:
