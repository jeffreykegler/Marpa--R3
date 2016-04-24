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
# Note: Converted to SLIF from leo2.t

# The example from p. 166 of Leo's paper.

use 5.010001;
use strict;
use warnings;

use Test::More tests => 5;

use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

## no critic (Subroutines::RequireArgUnpacking)

sub main::default_action {
    shift;
    return ( join q{}, grep { defined } @_ );
}

## use critic

my $dsl = <<'END_OF_DSL';
:default ::= action => main::default_action
S ::= a S
S ::=
a ~ 'a'
END_OF_DSL

my $grammar = Marpa::R3::Scanless::G->new( { source => \$dsl } );

Marpa::R3::Test::is( $grammar->show_symbols(),
    <<'END_OF_STRING', 'Leo166 Symbols' );
G1 S0 :start
G1 S1 S
G1 S2 a
END_OF_STRING

Marpa::R3::Test::is( $grammar->show_rules, <<'END_OF_STRING', 'Leo166 Rules' );
G1 R0 S ::= a S
G1 R1 S ::=
G1 R2 :start ::= S
END_OF_STRING

Marpa::R3::Test::is( $grammar->show_ahms, <<'END_OF_STRING', 'Leo166 AHMs' );
AHM 0: postdot = "a"
    S ::= . a S
AHM 1: postdot = "S"
    S ::= a . S
AHM 2: completion
    S ::= a S .
AHM 3: postdot = "a"
    S ::= . a S[]
AHM 4: completion
    S ::= a S[] .
AHM 5: postdot = "S"
    [:start] ::= . S
AHM 6: completion
    [:start] ::= S .
AHM 7: postdot = "[:start]"
    [:start]['] ::= . [:start]
AHM 8: completion
    [:start]['] ::= [:start] .
END_OF_STRING

my $length = 50;
my $input = 'a' x $length;

my $recce = Marpa::R3::Scanless::R->new( { grammar => $grammar } );
$recce->read( \$input, 0, 0 );

my $g1_pos = $recce->g1_pos();

my $max_size = $recce->earley_set_size($g1_pos);
TOKEN: for ( my $i = 0; $i < $length; $i++ ) {
    $recce->lexeme_read( 'a', undef, 1, (substr $input, $i, 1) );
    $g1_pos = $recce->g1_pos();
    my $size = $recce->earley_set_size($g1_pos);
    $max_size = $size > $max_size ? $size : $max_size;
} ## end while ( $i++ < $length )

my $expected_size = 7;
Marpa::R3::Test::is( $max_size, $expected_size, "Leo test of earley set size" );

my $value_ref = $recce->value();
my $value = $value_ref ? ${$value_ref} : 'No parse';
Marpa::R3::Test::is( $value, 'a' x $length, 'Leo p166 parse' );

# vim: expandtab shiftwidth=4:
