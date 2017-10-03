#!/usr/bin/env perl
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

# This tests the displays for the SLIF recognizer's block_*()
# methods

use 5.010001;

use strict;
use warnings;
use Marpa::R3;
use Data::Dumper;
use English qw( -no_match_vars );
use Getopt::Long ();
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use Test::More tests => 9;

my $dsl = << '=== GRAMMAR ===';
target ::= 'abcabc'
=== GRAMMAR ===

my $grammar = Marpa::R3::Scanless::G->new( { source => \($dsl) } );

my $recce = Marpa::R3::Scanless::R->new( { grammar => $grammar } );

# my $main_block = $recce->block_new( \$string );

# vim: expandtab shiftwidth=4:
