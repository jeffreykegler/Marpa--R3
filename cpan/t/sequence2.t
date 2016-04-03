#!/usr/bin/perl
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

# Tests of the sequence in the Marpa::R3::Grammar doc

use 5.010001;
use strict;
use warnings;

use Fatal qw(open close);
use Test::More tests => 3;

use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

sub do_sequence { shift; return 'seq(' .  ( join q{;}, @_ ) . ')' }
sub do_item     { shift; return 'item(' . ( join q{;}, @_ ) . ')' }

my $grammar;
my $recce;
my $value_ref;
my $value;

my $min0 =
  { lhs => 'sequence', rhs => ['item'], min => 0, action => 'do_sequence' };

$grammar = Marpa::R3::Grammar->new(
    {   start     => 'sequence',
        terminals => [qw(item)],
        rules     => [$min0],
        actions => 'main'
    }
);

$grammar->precompute();

$recce = Marpa::R3::Recognizer->new( { grammar => $grammar } );

$recce->read( 'item', '0');
$recce->read( 'item', '1');

$value_ref = $recce->value();
$value = $value_ref ? ${$value_ref} : 'No Parse';
$value //= 'undef returned';

Marpa::R3::Test::is( $value, 'seq(0;1)', 'min 0 value' );

my $min1 =
  { lhs => 'sequence', rhs => ['item'], min => 1, action => 'do_sequence' };

$grammar = Marpa::R3::Grammar->new({
     start => 'sequence',
     rules => [ $min1 ],
        actions => 'main'
});

$grammar->precompute();

$recce = Marpa::R3::Recognizer->new( { grammar => $grammar } );

$recce->read( 'item', '0');
$recce->read( 'item', '1');


$value_ref = $recce->value();
$value = $value_ref ? ${$value_ref} : 'No Parse';
$value //= 'undef returned';

Marpa::R3::Test::is( $value, 'seq(0;1)', 'min 1 value' );

my $multipart = [
    { lhs => 'sequence', rhs => [qw(item)], min => 0, action => 'do_sequence' },
    { lhs => 'item', rhs => [qw(part1 part2)], action => 'do_item' },
];

$grammar = Marpa::R3::Grammar->new(
    {   start => 'sequence',
        terminals => [qw(part1 part2)],
        rules => $multipart,
        actions => 'main'
    }
);


$grammar->precompute();

$recce = Marpa::R3::Recognizer->new( { grammar => $grammar } );

$recce->read( 'part1', '0' );
$recce->read( 'part2', '1' );

$value_ref = $recce->value();
$value = $value_ref ? ${$value_ref} : 'No Parse';
$value //= 'undef returned';

Marpa::R3::Test::is( $value, 'seq(item(0;1))', 'multipart rhs value' );

1; # In case used as "do" file

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
