#!/usr/bin/perl
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

use 5.010001;

use strict;
use warnings;

use Test::More tests => 2;

use English qw( -no_match_vars );
use Fatal qw( open close );
use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

my $progress_report = q{};

my $dsl = <<'END_OF_DSL';
S ::= Top_sequence
Top_sequence ::= Top Top_sequence | Top
Top ::= Upper_Middle
Upper_Middle ::= Lower_Middle
Lower_Middle ::= Bottom
Bottom ::= T
T ~ 'T'
END_OF_DSL

my $grammar = Marpa::R3::Grammar->new(
    {   source => \$dsl }
);

my $recce = Marpa::R3::Scanless::R->new( { grammar => $grammar } );
$recce->read( \('T' x 20) );

$progress_report = $recce->progress_show();

my $value_ref = $recce->value;
Test::More::ok( $value_ref, 'Parse ok?' );

Marpa::R3::Test::is( $progress_report,
    <<'END_PROGRESS_REPORT', 'sorted progress report' );
=== Earley set 20 at B1L1c21 ===
P3 B1L1c21 Lower_Middle ::= . Bottom
P4 B1L1c21 Bottom ::= . T
P5 B1L1c21 Top_sequence ::= . Top Top_sequence
P6 B1L1c21 Top_sequence ::= . Top
P7 B1L1c21 Top ::= . Upper_Middle
P8 B1L1c21 Upper_Middle ::= . Lower_Middle
R5:1 B1L1c20 Top_sequence ::= Top . Top_sequence
F1 B1L1c1 [:start:] ::= S .
F2 B1L1c1 S ::= Top_sequence .
F3 B1L1c20 Lower_Middle ::= Bottom .
F4 B1L1c20 Bottom ::= T .
F5 x19 B1L1c1-19 Top_sequence ::= Top Top_sequence .
F6 B1L1c20 Top_sequence ::= Top .
F7 B1L1c20 Top ::= Upper_Middle .
F8 B1L1c20 Upper_Middle ::= Lower_Middle .
END_PROGRESS_REPORT

# vim: expandtab shiftwidth=4:
