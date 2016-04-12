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
# Note: replacement for catalan.t ...

use 5.010001;

# Count the ways of parenthesizing N symbols in pairs
# This generates the Catalan numbers

use strict;
use warnings;

use Test::More tests => 7;
use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

my $grammar = Marpa::R3::Scanless::G->new(
    {
        source => \<<'END_OF_DSL',
pair ::= a a
pair ::= pair a
pair ::= a pair
pair ::= pair pair
a ~ 'a'
END_OF_DSL
    }
);

sub do_pairings {
    my $n           = shift;
    my $parse_count = 0;

    my $recce = Marpa::R3::Scanless::R->new( { grammar => $grammar } );

    # An arbitrary maximum is put on the number of parses -- this is for
    # debugging, and infinite loops happen.
    $recce->set( { max_parses => 999, } );

    $recce->read( \( 'a' x $n ) );

    while ( my $value_ref = $recce->value() ) {
        $parse_count++;
    }
    return $parse_count;
} ## end sub do_pairings

my @catalan_numbers = ( 0, 1, 1, 2, 5, 14, 42, 132, 429 );

for my $a ( ( 2 .. 8 ) ) {

    my $actual_parse_count = do_pairings($a);
    Marpa::R3::Test::is( $actual_parse_count, $catalan_numbers[$a],
        "Catalan number $a matches parse count ($actual_parse_count)" );

} ## end for my $a ( ( 2 .. 8 ) )

1;    # In case used as "do" file

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
