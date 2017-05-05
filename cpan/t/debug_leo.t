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

my $grammar = Marpa::R3::Scanless::G->new(
    {   source => \$dsl }
);

my $recce = Marpa::R3::Scanless::R->new( { grammar => $grammar } );
$recce->read( \('T' x 20) );

$progress_report = $recce->show_progress();

my $value_ref = $recce->value;
Test::More::ok( $value_ref, 'Parse ok?' );

Marpa::R3::Test::is( $progress_report,
    <<'END_PROGRESS_REPORT', 'sorted progress report' );
F0 @0-20 B1L1c1-20 S -> Top_sequence .
P1 @20-20 B1L1c21 Top_sequence -> . Top Top_sequence
R1:1 @19-20 B1L1c20 Top_sequence -> Top . Top_sequence
F1 x19 @0...18-20 B1L1c1-20 Top_sequence -> Top Top_sequence .
P2 @20-20 B1L1c21 Top_sequence -> . Top
F2 @19-20 B1L1c20 Top_sequence -> Top .
P3 @20-20 B1L1c21 Top -> . Upper_Middle
F3 @19-20 B1L1c20 Top -> Upper_Middle .
P4 @20-20 B1L1c21 Upper_Middle -> . Lower_Middle
F4 @19-20 B1L1c20 Upper_Middle -> Lower_Middle .
P5 @20-20 B1L1c21 Lower_Middle -> . Bottom
F5 @19-20 B1L1c20 Lower_Middle -> Bottom .
P6 @20-20 B1L1c21 Bottom -> . T
F6 @19-20 B1L1c20 Bottom -> T .
F7 @0-20 B1L1c1-20 [:start] -> S .
END_PROGRESS_REPORT

# vim: expandtab shiftwidth=4:
