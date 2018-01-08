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
use IPC::Cmd;
use File::Path;

my $libmarpa_repo = 'git@github.com:jeffreykegler/libmarpa.git';
my $stage = 'engine/stage';

my $deleted_count = File::Path::remove_tree($stage);
say "$deleted_count files deleted in $stage";

$deleted_count = File::Path::remove_tree('libmarpa_build');
say "$deleted_count files deleted in 'libmarpa_build'";

if (not IPC::Cmd::run(
        command => [ qw(git clone -b r2 --depth 5), $libmarpa_repo, $stage ],
        verbose => 1
    )
    )
{
    die "Could not clone";
} ## end if ( not IPC::Cmd::run( command => [ qw(git clone -n --depth 1)...]))

# CHIDR into staging dir
chdir $stage || die "Could not chdir";

my $log_data;
if (not IPC::Cmd::run(
        command => [ qw(git log -n 5) ],
        verbose => 1,
        buffer => \$log_data
    )
    )
{
    die "Could not clone";
} ## end if ( not IPC::Cmd::run( command => [ qw(git clone -n --depth 1)...]))

{
   open my $fh, q{>}, '../LOG_DATA';
   print {$fh} $log_data;
   close $fh;
}

if (not IPC::Cmd::run(
        command => [ qw(make dist) ],
        verbose => 1
    )
    )
{
    die qq{Could not make dist};
} ## end if ( not IPC::Cmd::run( command => [ qw(git checkout)...]))

$deleted_count = File::Path::remove_tree('../read_only');
say "$deleted_count files deleted in ../read_only";

if (not IPC::Cmd::run(
        command => [ qw(sh etc/cp_libmarpa.sh ../read_only) ],
        verbose => 1
    )
    )
{
    die qq{Could not make dist};
} ## end if ( not IPC::Cmd::run( command => [ qw(git checkout)...]))

exit 0
