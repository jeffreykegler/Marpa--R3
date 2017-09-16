#!perl
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

# VALUATOR: TODO

use 5.010001;


# This test is new with Marpa::R3
# A test of the warning for "too many Earley items"
# Uses a grammar which creates the Catalan numbers
# This version tests the L0 threshold

use strict;
use warnings;
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use Test::More tests => 1;
use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

my $grammar = Marpa::R3::Scanless::G->new(
    {
        source => \<<'END_OF_DSL',
top ::= lex_pair
lex_pair ~ pair
pair ~ a a
pair ~ pair a
pair ~ a pair
pair ~ pair pair
a ~ 'a'
END_OF_DSL
    }
);

my $n           = 20;
my $parse_count = 0;

my $recce = Marpa::R3::Scanless::R->new(
    { grammar => $grammar, too_many_earley_items => 10 } );

# An arbitrary maximum is put on the number of parses -- this is for
# debugging, and infinite loops happen.
$recce->set( { max_parses => 999, } );

my $trace_output;
open my $trace_fh, q{>}, \$trace_output;
$recce->set( { trace_file_handle => $trace_fh } );

$recce->read( \( 'a' x $n ) );

$recce->set( { trace_file_handle => \*STDOUT } );
close $trace_fh;

my $expected_trace_output = <<'END_OF_TRACE';
L0 exceeded earley item threshold at pos 1: 14 Earley items
L0 exceeded earley item threshold at pos 2: 18 Earley items
L0 exceeded earley item threshold at pos 3: 23 Earley items
L0 exceeded earley item threshold at pos 4: 28 Earley items
L0 exceeded earley item threshold at pos 5: 33 Earley items
L0 exceeded earley item threshold at pos 6: 38 Earley items
L0 exceeded earley item threshold at pos 7: 43 Earley items
L0 exceeded earley item threshold at pos 8: 48 Earley items
L0 exceeded earley item threshold at pos 9: 53 Earley items
L0 exceeded earley item threshold at pos 10: 58 Earley items
L0 exceeded earley item threshold at pos 11: 63 Earley items
L0 exceeded earley item threshold at pos 12: 68 Earley items
L0 exceeded earley item threshold at pos 13: 73 Earley items
L0 exceeded earley item threshold at pos 14: 78 Earley items
L0 exceeded earley item threshold at pos 15: 83 Earley items
L0 exceeded earley item threshold at pos 16: 88 Earley items
L0 exceeded earley item threshold at pos 17: 93 Earley items
L0 exceeded earley item threshold at pos 18: 98 Earley items
L0 exceeded earley item threshold at pos 19: 103 Earley items
END_OF_TRACE

Marpa::R3::Test::is( $trace_output, $expected_trace_output,
    '"Too many Earley items" Trace Output' );

1;    # In case used as "do" file

# vim: expandtab shiftwidth=4:
