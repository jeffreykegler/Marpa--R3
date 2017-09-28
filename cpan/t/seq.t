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

# Note: Convert to SLIF from sequence.t

# Basic tests of sequences.
# The matrix is separation (none/perl5/proper);
# and minimium count (0, 1);

use 5.010001;

use strict;
use warnings;

use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use Test::More tests => 33;
use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

## no critic (Subroutines::RequireArgUnpacking)

sub default_action {
    my (undef, $values) = @_;
    return q{}  if not $values;
    return $values->[0] if scalar @{$values} == 1;
    return join q{:}, @{$values};
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
