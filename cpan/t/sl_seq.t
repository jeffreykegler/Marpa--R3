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
# Note: Convert to SLIF from sequence.t

# Basic tests of sequences.
# The matrix is separation (none/perl5/proper);
# and minimium count (0, 1);

use 5.010001;
use strict;
use warnings;

use Test::More tests => 33;
use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

## no critic (Subroutines::RequireArgUnpacking)

sub default_action {
    shift;
    my $v_count = scalar @_;
    return q{}  if $v_count <= 0;
    return $_[0] if $v_count == 1;
    return join q{:}, @_;
} ## end sub default_action

## use critic

sub run_sequence_test {
    my ( $minimum, $separation ) = @_;

    my $dsl = ":default ::= action => main::default_action\n";
    $dsl .= "TOP ::= A ";
    $dsl .= $minimum == 0 ? '*' : '+';
    $dsl .= ' proper => 1'      if $separation eq 'proper';
    $dsl .= ' separator => sep' if $separation ne 'none';
    $dsl .= "\n";
    $dsl .= "A ~'a'\n";
    $dsl .= "sep ~ [!]\n "     if $separation ne 'none';

    my $grammar = Marpa::R3::Scanless::G->new( { source => \$dsl } );

    # Number of symbols to test at the higher numbers is
    # more or less arbitrary.  You really need to test 0 .. 3.
    # And you ought to test a couple of higher values,
    # say 5 and 10.
  SYMBOL_COUNT: for my $symbol_count ( 0, 1, 2, 3, 5, 10 ) {

        next SYMBOL_COUNT if $symbol_count < $minimum;
        my $test_name =
            "min=$minimum;"
          . ( $separation ne 'none' ? "$separation;" : q{} )
          . ";count=$symbol_count";
        my $recce = Marpa::R3::Scanless::R->new( { grammar => $grammar } );

        my $separator = $separation eq 'none' ? q{} : q{!};
        my @input     = ( ('a') x $symbol_count );
        my $expected = join q{:}, @input;
        my $input     = join $separator, @input;
        $input .= $separator if $separation eq 'perl5' and $symbol_count > 0;
        $recce->read( \$input );
        my $value_ref = $recce->value();
        my $value = $value_ref ? ${$value_ref} : 'No parse';
        Test::More::is( $value, $expected, $test_name );

    }

    return;
}

for my $minimum ( 0, 1 ) {
    for my $separation (qw(none proper perl5)) {
        run_sequence_test( $minimum, $separation );
    }
} ## end for my $minimum ( 0, 1, 3 )

# vim: expandtab shiftwidth=4:
