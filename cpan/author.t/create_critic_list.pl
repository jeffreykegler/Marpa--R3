#!perl
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

my %exclude = map { ( $_, 1 ) } qw();

open my $manifest, '<', '../MANIFEST'
    or Marpa::R3::exception("open of ../MANIFEST failed: $ERRNO");

my @test_files = ();
FILE: while ( my $file = <$manifest> ) {
    chomp $file;
    $file =~ s/\s*[#].*\z//xms;
    next FILE if $exclude{$file};
    my ($ext) = $file =~ / [.] ([^.]+) \z /xms;
    given ( lc $ext ) {
        when (undef) {
            break
        }
        when ('pl') { say $file or die "Cannot say: $ERRNO" }
        when ('pm') { say $file or die "Cannot say: $ERRNO" }
        when ('t')  { say $file or die "Cannot say: $ERRNO" }
    } ## end given
} ## end while ( my $file = <$manifest> )

close $manifest;
