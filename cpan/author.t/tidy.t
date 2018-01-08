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
use Perl::Critic;
use Test::Perl::Critic;
use Test::More;

# Test that the module passes perlcritic
BEGIN {
    $OUTPUT_AUTOFLUSH = 1;
}

open my $critic_list, '<', 'author.t/critic.list';
my @test_files = <$critic_list>;
close $critic_list;
chomp @test_files;

my $rcfile = File::Spec->catfile( 'author.t', 'perlcriticrc' );
Test::Perl::Critic->import(
    -verbose         => '%l:%c %p %r',
    -profile         => $rcfile,
    '-single-policy' => 'CodeLayout::RequireTidyCode',
);
Test::Perl::Critic::all_critic_ok(@test_files);
