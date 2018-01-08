#!/usr/bin/perl
# Marpa::R3 is Copyright (C) 2018, Jeffrey Kegler.
#
# This module is free software; you can redistribute it and/or modify it
# under the same terms as Perl 5.10.1. For more details, see the full text
# of the licenses in the directory LICENSES.
#
# This program is distributed in the hope that it will be
# useful, but it is provided "as is" and without any express
# or implied warranties. For details, see the full text of
# of the licenses in the directory LICENSES.

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
