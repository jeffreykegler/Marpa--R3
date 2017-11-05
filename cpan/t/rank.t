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

# Note: SLIF TEST

# Tests negative ranks, SLIF ranks and
# external SLIF scanning

# This uses an ambiguous grammar to implement a binary
# counter.  A very expensive way to do it, but a
# good test of the ranking logic.

use 5.010001;

use strict;
use warnings;
use English qw( -no_match_vars );
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use Test::More tests => 16;
use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

sub My_Actions::zero { return '0' }
sub My_Actions::one  { return '1' }

sub My_Actions::start_rule_action {
    my (undef, $values) = @_;
    return join q{}, @{$values};
}

## use critic

    my $grammar = Marpa::R3::Grammar->new(
        {
            semantics_package => 'My_Actions',
            ranking_method    => 'rule',
            source            => \(<<'END_OF_GRAMMAR'),
:start ::= S
S ::= digit digit digit digit action => start_rule_action
digit ::=
      zero rank => 1 action => zero
    | one  rank => -1 action => one
zero ~ 't'
one ~ 't'
END_OF_GRAMMAR
        }
    );

my @counting_up =
    qw{ 0000 0001 0010 0011 0100 0101 0110 0111 1000 1001 1010 1011 1100 1101 1110 1111 };

my $recce = Marpa::R3::Scanless::R->new( { grammar => $grammar } );

$recce->read(\'tttt');

my $i = 0;
my $valuer = Marpa::R3::Scanless::V->new( { recognizer => $recce } );
while ( my $result = $valuer->value() ) {
    my $got      = ${$result};
    my $expected = reverse $counting_up[$i];
    Test::More::is( $got, $expected, "counting up $i" );
    $i++;
}

1;    # In case used as "do" file

# vim: expandtab shiftwidth=4:
