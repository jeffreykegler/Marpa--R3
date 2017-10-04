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

use Test::More tests => 12;

use English qw( -no_match_vars );
use Fatal qw( open close );
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;
use Data::Dumper;

my $progress_report = q{};

my $dsl = <<'END_OF_DSL';
## This is a deliberate error in the grammar
## The next line should be:
##    Expression ::= Term
## I have changed the Term to 'Factor' which
## will cause problems.
inaccessible is ok by default
:default ::= action => ::first

Expression ::= Factor
Term ::= Factor
Factor ::= Number
Term ::= Term Add Term action => do_add
Factor ::= Factor Multiply Factor action => do_multiply
Number ~ [\d]+
Multiply ~ [*]
Add ~ [+]
END_OF_DSL


## no critic (InputOutput::RequireBriefOpen)
open my $trace_fh, q{>}, \( my $trace_output = q{} );
## use critic

my $grammar = Marpa::R3::Scanless::G->new(
    { semantics_package => 'My_Actions', source => \$dsl } );

$grammar->set( { trace_file_handle => $trace_fh } );

sub My_Actions::do_add {
    my ( undef, $v ) = @_;
    my ( $t1, undef, $t2 ) = @${v};
    return $t1 + $t2;
}

sub My_Actions::do_multiply {
    my ( undef, $v ) = @_;
    my ( $t1, undef, $t2 ) = @${v};
    return $t1 * $t2;
}

my $recce = Marpa::R3::Scanless::R->new(
    {
        grammar           => $grammar,
        trace_terminals   => 99
    }
);

my @tokens = (
    [ 'Number',   '42' ],
    [ 'Multiply', q{*} ],
    [ 'Number',   '1' ],
    [ 'Add',      q{+} ],
    [ 'Number',   '7' ],
);

my $dummy_input = join q{}, map { $_->[1] } @tokens;
$recce->read( \$dummy_input, 0, 0);
TOKEN: for my $token_and_value (@tokens) {
    my ($name, $value) = @{$token_and_value};
    my (undef, $offset) = $recce->block_where();
    last TOKEN if not defined $recce->lexeme_read( $name, $offset, (length $value), $value );
}

$progress_report = $recce->progress_show( 0, -1 );

my $value_ref = $recce->value;
my $value = $value_ref ? ${$value_ref} : 'No Parse';

Test::More::is( $value, 42, 'value' );

Marpa::R3::Test::is( $progress_report,
    <<'END_PROGRESS_REPORT', 'progress report' );
=== Earley set 0 at B1L1c1 ===
P1 B1L1c1 [:start:] ::= . Expression
P2 B1L1c1 Expression ::= . Factor
P4 B1L1c1 Factor ::= . Number
P6 B1L1c1 Factor ::= . Factor Multiply Factor
=== Earley set 1 at B1L1c3 ===
R6:1 B1L1c1 Factor ::= Factor . Multiply Factor
F1 B1L1c1 [:start:] ::= Expression .
F2 B1L1c1 Expression ::= Factor .
F4 B1L1c1 Factor ::= Number .
=== Earley set 2 at B1L1c4 ===
P4 B1L1c4 Factor ::= . Number
P6 B1L1c4 Factor ::= . Factor Multiply Factor
R6:2 B1L1c1 Factor ::= Factor Multiply . Factor
=== Earley set 3 at B1L1c5 ===
R6:1 x2 B1L1c1-4 Factor ::= Factor . Multiply Factor
F1 B1L1c1 [:start:] ::= Expression .
F2 B1L1c1 Expression ::= Factor .
F4 B1L1c4 Factor ::= Number .
F6 B1L1c1 Factor ::= Factor Multiply Factor .
END_PROGRESS_REPORT

$Data::Dumper::Indent = 0;
$Data::Dumper::Terse  = 1;

my $report0 = $recce->progress(0);

chomp( my $expected_report0 = <<'END_PROGRESS_REPORT');
[[1,0,0],[2,0,0],[4,0,0],[6,0,0]]
END_PROGRESS_REPORT
Marpa::R3::Test::is( Data::Dumper::Dumper($report0),
    $expected_report0, 'progress report at location 0' );

# Try again with negative index
$report0 = $recce->progress(-4);
Marpa::R3::Test::is( Data::Dumper::Dumper($report0),
    $expected_report0, 'progress report at location -4' );

my $report1 = $recce->progress(1);

chomp( my $expected_report1 = <<'END_PROGRESS_REPORT');
[[1,1,0],[2,1,0],[4,1,0],[6,1,0]]
END_PROGRESS_REPORT
Marpa::R3::Test::is( Data::Dumper::Dumper($report1),
    $expected_report1, 'progress report at location 1' );

# Try again with negative index
$report1 = $recce->progress(-3);
Marpa::R3::Test::is( Data::Dumper::Dumper($report1),
    $expected_report1, 'progress report at location -3' );

my $report2 = $recce->progress(2);

chomp( my $expected_report2 = <<'END_PROGRESS_REPORT');
[[4,0,2],[6,0,2],[6,2,0]]
END_PROGRESS_REPORT
Marpa::R3::Test::is( Data::Dumper::Dumper($report2),
    $expected_report2, 'progress report at location 2' );

# Try again with negative index
$report2 = $recce->progress(-2);
Marpa::R3::Test::is( Data::Dumper::Dumper($report2),
    $expected_report2, 'progress report at location -2' );

my $latest_report = $recce->progress();

chomp( my $expected_report3 = <<'END_PROGRESS_REPORT');
[[1,1,0],[2,1,0],[4,1,2],[6,1,0],[6,1,2],[6,3,0]]
END_PROGRESS_REPORT
Marpa::R3::Test::is( Data::Dumper::Dumper($latest_report),
    $expected_report3, 'progress report at location 3' );

# Try latest report again with explicit index
my $report3 = $recce->progress(3);
Marpa::R3::Test::is( Data::Dumper::Dumper($report3),
    $expected_report3, 'progress report at location 3' );

# Try latest report again with negative index
$latest_report = $recce->progress(-1);
Marpa::R3::Test::is( Data::Dumper::Dumper($latest_report),
    $expected_report3, 'progress report at location -1' );

# Currently external scanning does not show up in trace_terminals
Marpa::R3::Test::is( $trace_output, <<'END_TRACE_OUTPUT', 'trace output' );
Setting trace_terminals option
Expecting "Number" at earleme 0
Registering character U+0034 "4" as symbol 6: [\d]
Registering character U+0032 "2" as symbol 6: [\d]
Registering character U+002a "*" as symbol 4: [*]
Registering character U+0031 "1" as symbol 6: [\d]
Registering character U+002b "+" as symbol 5: [+]
Registering character U+0037 "7" as symbol 6: [\d]
END_TRACE_OUTPUT

# vim: expandtab shiftwidth=4:
