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

# Note: Converted from NAIF rabend.t

use 5.010001;

use strict;
use warnings;

use English qw( -no_match_vars );
use Fatal qw( open close );
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use Test::More tests => 4;

use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

sub catch_problem {
    my ( $test_name, $test, $expected_result, $expected_error ) = @_;
    my $result;
    my $eval_ok = eval {
        $result = $test->();
        1;
    };
    my $eval_error = $EVAL_ERROR;

    Test::More::is( $result, $expected_result, "Result: $test_name" );
    if ($eval_ok) {
        Test::More::fail("Failed to catch problem: $test_name");
    }
    elsif ( index( $eval_error, $expected_error ) < 0 ) {
        my $diag_message = "Failed to find expected message, was expecting:\n";
        my $temp;
        $temp = $expected_error;
        $temp =~ s/^/=== /xmsg;
        chomp $temp;
        $diag_message .= "$temp\n";
        $diag_message .= "This was the message actually received:\n";
        $temp = $eval_error;
        $temp =~ s/^/=== /xmsg;
        chomp $temp;
        $diag_message .= "$temp\n";
        Test::More::diag($diag_message);
        Test::More::fail("Unexpected message: $test_name");
    } ## end elsif ( index( $eval_error, $expected_error ) < 0 )
    else {
        Test::More::pass("Successfully caught problem: $test_name");
    }
    return;
} ## end sub catch_problem

my $grammar = Marpa::R3::Grammar->new(
    {
        source => \<<'END_OF_DSL',
Top ::= Term+
Term ::= a
Term ::= b
Term ::= c
Term ::= d
a ~ [\d\D]
b ~ [\d\D]
c ~ [\d\D]
d ~ [\d\D]
END_OF_DSL
    }
);

my $test_name;
my $recce;

# First test that duplicates are Detected
$test_name = 'duplicate terminal 1';
$recce = Marpa::R3::Scanless::R->new( { grammar => $grammar, } );
$recce->read( \'abcd', 0, 0 );

sub duplicate_terminal_1 {
    $recce->lexeme_alternative( 'a', \42 );
    $recce->lexeme_alternative( 'a', \711 );
    $recce->lexeme_complete( undef, 0, 1 );
    return 1;
} ## end sub duplicate_terminal_1

catch_problem( $test_name, \&duplicate_terminal_1, undef, q{Duplicate token} );

# 2nd test that duplicates are Detected
$test_name = 'duplicate terminal 2';
$recce = Marpa::R3::Scanless::R->new( { grammar => $grammar, } );
$recce->read( \'abcd', 0, 0 );

sub duplicate_terminal_2 {

    # Should be OK, because different symbols
    $recce->lexeme_alternative( 'a', \11 )
      or return 'alternative a at 0 failed';
    $recce->lexeme_alternative( 'b', \12 )
      or return 'alternative b at 0 failed';
    $recce->lexeme_complete( undef, 0, 1 );

    $recce->lexeme_alternative( 'd', \42 )
      or return 'first alternative d at 2 failed';
    $recce->lexeme_alternative( 'b', \22 )
      or return 'alternative b at 1 failed';

    # this should cause an abend -- a 2nd d
    return 1 if $recce->lexeme_alternative( 'd', \711 );
    return;
} ## end sub duplicate_terminal_2

catch_problem( $test_name, \&duplicate_terminal_2, undef, q{Duplicate token} );

1;    # In case used as "do" file

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
