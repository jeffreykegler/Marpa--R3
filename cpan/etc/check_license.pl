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

use 5.010001;
use strict;
use warnings;
use autodie;
use English qw( -no_match_vars );
use ExtUtils::Manifest;

use Getopt::Long;
my $verbose = 1;
my $result = Getopt::Long::GetOptions( 'verbose=i' => \$verbose );
die "usage $PROGRAM_NAME [--verbose=n] file ...\n" if not $result;

use inc::Marpa::R3::License;

my $file_count;
my @license_problems;
if ( $#ARGV > 0 ) {
    $file_count = @ARGV;
    @license_problems =
      map { Marpa::R3::License::file_license_problems( $_, $verbose ) } @ARGV;

}
else {

    require inc::Marpa::R3::License;

    my $manifest = [ keys %{ ExtUtils::Manifest::maniread() } ];
    $file_count = $#{$manifest};
    @license_problems =
      Marpa::R3::License::license_problems( $manifest, $verbose );
} ## end sub ACTION_licensecheck

print join "\n", @license_problems;

my $problem_count = scalar @license_problems;

$problem_count and say +( q{=} x 50 );
say
"Found $problem_count license language problems after examining $file_count files";
