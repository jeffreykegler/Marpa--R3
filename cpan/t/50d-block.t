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

use Test::More tests => 8;
use lib 'inc';
use Marpa::R3::Test;

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

# Marpa::R3::Display
# name: Block level read() equivalent

sub block_level_read {
    my ($recce, $p_string, $offset, $length) = @_;
    my $block_id = $recce->block_new($p_string);
    $recce->block_set($block_id);
    $recce->block_move($offset, $length);
    $recce->block_read();
    my (undef, $new_offset) = $recce->block_progress();
    return $new_offset;
}

# Marpa::R3::Display::End

# Marpa::R3::Display
# name: Block level resume() equivalent

sub block_level_resume {
    my ($recce, $offset, $length) = @_;
    $recce->block_move( $offset, $length );
    $recce->block_read();
    my (undef, $new_offset) = $recce->block_progress();
    return $new_offset;
}

# Marpa::R3::Display::End

my $expected_result = 'Parse OK';
my $expected_value  = \[qw(target a b c a b c)];

sub test {
    my ( $grammar, $string, $read_fn, $resume_fn, $test_name ) = @_;
    my $recce = Marpa::R3::Scanless::R->new( { grammar => $grammar } );
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
        qq{Value for $test_name}
    );
    Test::More::is( $actual_result, $expected_result,
        qq{Result for $test_name} );
}

test( $grammar, "abc", \&hi_level_read, \&hi_level_resume, 'hi level methods' );
test( $grammar, "abc", \&block_level_read, \&block_level_resume, 'block level methods' );

# This block for displays of individual methods
if (
    not defined eval {
        my $recce = Marpa::R3::Scanless::R->new( { grammar => $grammar } );

# Marpa::R3::Display
# name: block_new() synopsis

        my $main_block_id = $recce->block_new(\"abc");

# Marpa::R3::Display::End

# Marpa::R3::Display
# name: block_set() synopsis

        $recce->block_set($main_block_id);

# Marpa::R3::Display::End

# Marpa::R3::Display
# name: block_move() synopsis

        $recce->block_move( 0, -1 );

# Marpa::R3::Display::End

        $recce->block_read();

# Marpa::R3::Display
# name: block_progress() synopsis

        my ($block_id, $offset, $eoread) = $recce->block_progress( );

# Marpa::R3::Display::End

        Marpa::R3::Test::is(
            [ $block_id, $offset, $eoread ], [ 1, 3, 3 ],
            qq{test 1 of block_progress()}
        );

        $recce->block_move(0);

# Marpa::R3::Display
# name: block_progress() synopsis 2

        ($block_id, $offset, $eoread) = $recce->block_progress( $main_block_id );

# Marpa::R3::Display::End

        Marpa::R3::Test::is(
            [ $block_id, $offset, $eoread ], [ 1, 0, 3 ],
            qq{test 2 of block_progress()}
        );

# Marpa::R3::Display
# name: block_read() synopsis

        $recce->block_read();

# Marpa::R3::Display::End

        my $actual_value = $recce->value();
        Test::More::is(
            Data::Dumper::Dumper($actual_value),
            Data::Dumper::Dumper($expected_value),
            qq{Value for individual methods}
        );
        1;
    }
  )
{
    my $actual_result = $EVAL_ERROR;
    chomp $actual_result;
    Test::More::is( $actual_result, $expected_result,
        qq{Result for individual methods} );
}
else {
    Test::More::pass(qq{Result for individual methods});
}

# vim: expandtab shiftwidth=4:
