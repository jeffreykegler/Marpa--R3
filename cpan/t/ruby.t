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

# VALUATOR: TODO

use 5.010001;

use strict;
use warnings;
use Data::Dumper;
use Getopt::Long ();
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use Test::More tests => 3;
use Marpa::R3;

my $verbose;
die if not Getopt::Long::GetOptions( verbose => \$verbose );

# This example tests the Ruby Slippers using the SLIF

my $grammar = << '=== GRAMMAR ===';
lexeme default = action => [ name, value ] # to add token names to ast

script ::= E+ separator => semi action => [values]
E ::= 
     number action => main::number
     || E ('*') E action => main::multiply
     || E ('+') E action => main::add

:discard ~ whitespace
whitespace ~ [\s]+
number ~ [\d]+
semi ~ ';'

=== GRAMMAR ===

# Marpa::R3::Display
# name: SLIF rejection grammar setting synopsis part 1

my $g = Marpa::R3::Scanless::G->new(
    {
        source    => \($grammar),
        rejection => 'event'
    }
);

# Marpa::R3::Display::End

my @tests = (
    [ '1+2+3*4',                '15' ],
    [ '1+2 3+4',                '3,7' ],
    [ '0+42 21*2 3*7+21 3*7*2', '42,42,42,42' ],
);

for my $test (@tests) {
    my ( $string, $expected_result ) = @{$test};
    my $actual_result = test( $g, $string );
    # say "Input: $string";
    Test::More::is( $actual_result, $expected_result,
        qq{Result of "$string"} );
} ## end for my $test (@tests)

sub test {
    my ( $g, $string ) = @_;
    my @found = ();

    diag("Input: $string") if $verbose;
    my $original_length = length $string;
    my $suffixed_string = $string . ';';
    my $target_start    = 0;

    # state $recce_debug_args = { trace_terminals => 1, trace_values => 1 };
    state $recce_debug_args = {};

# Marpa::R3::Display
# name: SLIF rejection grammar setting synopsis part 2

    my $rejection = 0;
    my $pos;

    my $recce =
      Marpa::R3::Scanless::R->new( { grammar => $g,
         event_handlers => {
             q{'rejected} => sub {
                $rejection = 1;
                diag("You fool! you forget the semi-colon at location $pos!")
                    if $verbose;
                return 'pause'
             }
         },
      }, $recce_debug_args );
    $pos = $recce->read( \$suffixed_string, 0, $original_length );

    READ_LOOP: while (1) {
        $pos       = $recce->pos();
        last READ_LOOP if not $rejection;
        $recce->resume( $original_length, 1 );
        diag("I fixed it for you.  Now you owe me.") if $verbose;
        $rejection = 0;
        $recce->resume( $pos, $original_length - $pos );
    } ## end READ_LOOP: while (1)

# Marpa::R3::Display::End

    my $ref_value = $recce->value();
    return 'No parse' if not $ref_value;
    if ( ref $ref_value ne 'REF' ) {
        my $ref_type = ref $ref_value;
        my $ref_description = $ref_type ? "ref to $ref_type" : 'not a ref';
        return "Got $ref_description -- want REF to REF to ARRAY";
    }
    return join q{,}, @{ ${$ref_value} };

} ## end sub test

sub number {
    my ( undef, $values ) = @_;
    my ( $v1 ) = @{$values};
    return $v1->[1];
}

sub add {
    my ( undef, $values ) = @_;
    my ( $v1, $v2 ) = @{$values};
    return $v1 + $v2;
}

sub multiply {
    my ( undef, $values ) = @_;
    my ( $v1, $v2 ) = @{$values};
    return $v1 * $v2;
}

# vim: expandtab shiftwidth=4:
