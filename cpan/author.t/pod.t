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
use English qw( -no_match_vars );
use Fatal qw( open close );
use Carp;
use Pod::Simple;
use Test::Pod;
use Test::More;

# Test that the module passes perlcritic
BEGIN {
    $OUTPUT_AUTOFLUSH = 1;
}

my %exclude = map { ( $_, 1 ) } qw(
    inc/Test/Weaken.pm
);

open my $manifest, '<', 'MANIFEST'
    or Marpa::R3::exception("open of MANIFEST failed: $ERRNO");

my @test_files = ();
FILE: while ( my $file = <$manifest> ) {
    chomp $file;
    $file =~ s/\s*[#].*\z//xms;
    next FILE if -d $file;
    next FILE if $exclude{$file};
    my ($ext) = $file =~ / [.] ([^.]+) \z /xms;
    next FILE if not defined $ext;
    $ext = lc $ext;
    given ($ext) {
        when ('pl')  { push @test_files, $file }
        when ('pod') { push @test_files, $file }
        when ('t')   { push @test_files, $file }
        when ('pm')  { push @test_files, $file }
    } ## end given
}    # FILE
close $manifest;

Test::Pod::all_pod_files_ok(@test_files);

1;
