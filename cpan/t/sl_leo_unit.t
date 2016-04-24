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
# Note: Converted to SLIF from leo_unit.t

# Test of Leo logic for unit rule.

use 5.010001;
use strict;
use warnings;

use List::Util;
use Test::More tests => 5;

use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

## no critic (Subroutines::RequireArgUnpacking)

sub main::default_action {
    shift;
    return ( join q{}, grep {defined} @_ );
}

## use critic

my $dsl = <<'END_OF_DSL';
:default ::= action => main::default_action
A ::= a B
B ::= C
C ::= c A
C ::= c
a ~ 'a'
c ~ 'c'
END_OF_DSL

my $grammar = Marpa::R3::Scanless::G->new( { source => \$dsl } );

Marpa::R3::Test::is( $grammar->show_symbols(),
    <<'END_OF_STRING', 'Leo166 Symbols' );
G1 S0 :start
G1 S1 A
G1 S2 a
G1 S3 B
G1 S4 C
G1 S5 c
END_OF_STRING

Marpa::R3::Test::is( $grammar->show_rules,
    <<'END_OF_STRING', 'Leo166 Rules' );
G1 R0 A ::= a B
G1 R1 B ::= C
G1 R2 C ::= c A
G1 R3 C ::= c
G1 R4 :start ::= A
END_OF_STRING


Marpa::R3::Test::is( $grammar->show_ahms, <<'END_OF_STRING', 'Leo166 AHMs' );
AHM 0: postdot = "a"
    A ::= . a B
AHM 1: postdot = "B"
    A ::= a . B
AHM 2: completion
    A ::= a B .
AHM 3: postdot = "C"
    B ::= . C
AHM 4: completion
    B ::= C .
AHM 5: postdot = "c"
    C ::= . c A
AHM 6: postdot = "A"
    C ::= c . A
AHM 7: completion
    C ::= c A .
AHM 8: postdot = "c"
    C ::= . c
AHM 9: completion
    C ::= c .
AHM 10: postdot = "A"
    [:start] ::= . A
AHM 11: completion
    [:start] ::= A .
AHM 12: postdot = "[:start]"
    [:start]['] ::= . [:start]
AHM 13: completion
    [:start]['] ::= [:start] .
END_OF_STRING

my $recce = Marpa::R3::Scanless::R->new(
    { grammar => $grammar } );

my $input = 'acacac';
my $length_of_input = length $input;
$recce->read( \$input );

my @sizes = (0);
TOKEN: for ( my $i = 0; $i < $length_of_input; $i++ ) {
    push @sizes, $recce->earley_set_size($i);
}

my $max_size = List::Util::max(@sizes);
my $expected_size = 6;
Marpa::R3::Test::is( $max_size, $expected_size,
    "Earley set size was $max_size; $expected_size was expected" );

my $value_ref = $recce->value();
my $value = $value_ref ? ${$value_ref} : 'No parse';
Marpa::R3::Test::is( $value, 'acacac', 'Leo unit rule parse' );

# vim: expandtab shiftwidth=4:
