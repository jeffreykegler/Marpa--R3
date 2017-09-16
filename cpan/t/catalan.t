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

# Note: replacement for catalan.t ...

# VALUATOR: TODO

use 5.010001;


# Count the ways of parenthesizing N symbols in pairs
# This generates the Catalan numbers

use strict;
use warnings;

use Test::More tests => 7;
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

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
