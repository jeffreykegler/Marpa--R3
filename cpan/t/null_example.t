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
# An ambiguous equation

use 5.010001;
use strict;
use warnings;

use Test::More tests => 1;

use lib 'inc';
use Marpa::R3::Test;
use English qw( -no_match_vars );
use Fatal qw(open close);
use Marpa::R3;

## no critic (InputOutput::RequireBriefOpen)
open my $original_stdout, q{>&STDOUT};
## use critic

sub save_stdout {
    my $save;
    my $save_ref = \$save;
    close STDOUT;
    open STDOUT, q{>}, $save_ref;
    return $save_ref;
} ## end sub save_stdout

sub restore_stdout {
    close STDOUT;
    open STDOUT, q{>&}, $original_stdout;
    return 1;
}

sub do_L {
    shift;
    return 'L(' . ( join q{;}, map { $_ // '[ERROR!]' } @_ ) . ')';
}

sub do_R {
    return 'R(): I will never be called';
}

sub do_S {
    shift;
    return 'S(' . ( join q{;}, map { $_ // '[ERROR!]' } @_ ) . ')';
}

sub do_X { return 'X(' . $_[1] . ')'; }
sub do_Y { return 'Y(' . $_[1] . ')'; }

## no critic (Variables::ProhibitPackageVars)
our $null_A = 'null A';
our $null_B = 'null B';
our $null_L = 'null L';
our $null_R = 'null R';
our $null_X = 'null X';
our $null_Y = 'null Y';
## use critic

my $grammar = Marpa::R3::Grammar->new(
    {   start   => 'S',
        actions => 'main',
        rules   => [
            [ 'S', [qw/L R/],   'do_S' ],
            [ 'L', [qw/A B X/], 'do_L' ],
            [ 'L', [], 'null_L' ],
            [ 'R', [qw/A B Y/], 'do_R' ],
            [ 'R', [], 'null_R' ],
            [ 'A', [], 'null_A' ],
            [ 'B', [], 'null_B' ],
            [ 'X', [], 'null_X' ],
            [ 'X', [qw/x/], 'do_X' ],
            [ 'Y', [], 'null_Y' ],
            [ 'Y', [qw/y/], 'do_Y' ],
        ],
    }
);

$grammar->precompute();

my $recce = Marpa::R3::Recognizer->new( { grammar => $grammar } );

$recce->read( 'x', 'x' );

## use critic

chomp( my $expected = <<'END_OF_OUTPUT');
S(L(null A;null B;X(x));null R)
END_OF_OUTPUT

my $value = $recce->value();
Marpa::R3::Test::is( ${$value}, $expected, 'Null example' );

1;    # In case used as "do" file

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
