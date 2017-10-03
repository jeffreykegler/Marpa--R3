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
target ::= 'a' 'b' 'c' 'a' 'b' 'c'
=== GRAMMAR ===

my $grammar = Marpa::R3::Scanless::G->new( { source => \($dsl) } );

sub hi_level_read {
   my ($recce, $p_string, $offset, $length) = @_;
   $recce->read($p_string, $offset, $length);
}

sub hi_level_resume {
   my ($recce, $offset, $length) = @_;
   $recce->resume($offset, $length);
}

sub lo_level_read {
    my ($recce, $p_string, $offset, $length) = @_;
    my $block_id = $recce->block_new($p_string);
    $recce->block_set($block_id);
    $recce->block_move($offset, $length);
    $recce->block_read();
    return $recce->pos();
}

sub lo_level_resume {
    my ($recce, $offset, $length) = @_;
    $recce->block_move( $offset, $length );
    $recce->block_read();
    return $recce->pos();
}

sub test {
    my ( $grammar, $string, $read_fn, $resume_fn, $test_name ) = @_;
    my $recce = Marpa::R3::Scanless::R->new( { grammar => $grammar } );
    my $expected_result = 'Parse OK';
    my $expected_value  = \[qw(target a b c a b c)];
    my $actual_result   = "Actual result not set";
    my $actual_value    = "Actual value not set";
  SET_RESULT: {
        if ( not defined eval { $read_fn->( $recce, \$string ); 1 } ) {
            $actual_result = $EVAL_ERROR;
            chomp $actual_result;
            $actual_value = 'Problem in initial read test';
            last SET_RESULT;
        }
        if ( not defined eval { $resume_fn->( $recce, 0 ); 1 } ) {
            $actual_result = $EVAL_ERROR;
            chomp $actual_result;
            $actual_value = 'Problem in resumption test';
            last SET_RESULT;
        }
        $actual_result = 'Parse OK';
        $actual_value  = $recce->value();
    }
    Test::More::is(
        Data::Dumper::Dumper( $actual_value ),
        Data::Dumper::Dumper( $expected_value ),
        qq{Value of $test_name}
    );
    Test::More::is( $actual_result, $expected_result,
        qq{Result of $test_name} );
}

test($grammar, "abc", \&hi_level_read, \&hi_level_resume, 'hi level');
test($grammar, "abc", \&lo_level_read, \&lo_level_resume, 'lo level');

# my $main_block = $recce->block_new( \$string );

# vim: expandtab shiftwidth=4:
