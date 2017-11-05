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

# Tests that include a grammar, an input, and an resolution
# error message, but no (or minimal?) semantics.
#
# The intent is that this file will contain tests of the
# valuator's resolution phase

use 5.010001;

use strict;
use warnings;

use Data::Dumper;
use English qw( -no_match_vars );
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use Test::More tests => 6;
use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

our $DEBUG = 0;
my @tests_data = ();

sub My_Semantics::new {}

####

{
    my $grammar = \(<<'END_OF_SOURCE');
:start ::= test
test   ::= 'X'       action => nowhere
END_OF_SOURCE

    push @tests_data, [ $grammar, 'X',
    'SLIF grammar failed',
    <<'END_OF_MESSAGE',
Could not resolve rule action named 'nowhere'
  Rule was test ::= 'X'
  Failed resolution of action "nowhere" to My_Semantics::nowhere
END_OF_MESSAGE
    'Missing action' ];
}

####

# Test trivial grammar with action --
# Problem found by Jean-Damien

{
    my $grammar = \(<<'END_OF_SOURCE');
:start ::= test
test   ::= action => main::not_null
END_OF_SOURCE

    push @tests_data, [ $grammar, q{},
    'not null',
    'Parse OK', 'Trivial grammar with action' ];
}

####

{

# Marpa::R3::Display
# name: inaccessible is fatal statement
# start-after-line: END_OF_SOURCE
# end-before-line: '^END_OF_SOURCE$'

    my $source = <<'END_OF_SOURCE';

    inaccessible is fatal by default
    :default ::= action => [symbol, name, values]
    lexeme default = action => [symbol, name, value]
    start ::= stuff*
    stuff ::= a | b
    a ::= x 
    b ::= x 
    c ::= x 
    x ::= 'x'
END_OF_SOURCE

# Marpa::R3::Display::End

    my $input           = 'xxx';
    my $expected_value = 'SLIF grammar failed';

    push @tests_data,
        [
        \$source, $input, $expected_value,
        "Inaccessible g1 symbol: c\n", qq{test "inaccessible is fatal by default"}
        ];
}

###

TEST:
for my $test_data (@tests_data) {
    my ( $source, $input, $expected_value, $expected_result, $test_name ) =
        @{$test_data};
    my ( $actual_value, $actual_result );
    PROCESSING: {
        my $grammar;
        my $eval_ok = eval {
            $grammar = Marpa::R3::Grammar->new(
                {
                    source            => $source,
                    semantics_package => 'My_Semantics'
                }
            );
            1;
        };
        if (not defined $eval_ok)
        {
            say $EVAL_ERROR if $DEBUG;
            my $abbreviated_error = $EVAL_ERROR;

            chomp $abbreviated_error;
            $abbreviated_error =~ s/^ Marpa[:][:]R3 \s+ exception \s+ at \s+ .* \z//xms;
            $actual_value  = 'SLIF grammar failed';
            $actual_result = $abbreviated_error;
            last PROCESSING;
        } ## end if ( not defined eval { $grammar = Marpa::R3::Grammar...})
        my $recce = Marpa::R3::Recognizer->new(
            { grammar => $grammar,
            } );

        if ( not defined eval { $recce->read( \$input ); 1 } ) {
            say $EVAL_ERROR if $DEBUG;
            my $abbreviated_error = $EVAL_ERROR;
            chomp $abbreviated_error;
            $abbreviated_error =~ s/\n.*//xms;
            $actual_value  = 'No parse';
            $actual_result = $abbreviated_error;
            last PROCESSING;
        } ## end if ( not defined eval { $recce->read( \$input ); 1 })
        my $value_ref ;
        if ( not defined eval { $value_ref = $recce->value(); 1 } ) {
            say $EVAL_ERROR if $DEBUG;
            my $abbreviated_error = $EVAL_ERROR;
            chomp $abbreviated_error;
            $abbreviated_error =~ s/^ Marpa[:][:]R3 \s+ exception \s+ at \s+ .* \z//xms;
            $actual_value  = 'Failure in value() method';
            $actual_result = $abbreviated_error;
            last PROCESSING;
        }
        if ( not defined $value_ref ) {
            $actual_value  = 'No parse';
            $actual_result = 'Input read to end but no parse';
            last PROCESSING;
        }
        $actual_value  = ${$value_ref};
        $actual_result = 'Parse OK';
        last PROCESSING;
    } ## end PROCESSING:

    Marpa::R3::Test::is(
        Data::Dumper::Dumper( \$actual_value ),
        Data::Dumper::Dumper( \$expected_value ),
        qq{Value of $test_name}
    );
    Marpa::R3::Test::is( $actual_result, $expected_result,
        qq{Result of $test_name} );
} ## end for my $test_data (@tests_data)

# An example action, for tests which need one
sub main::not_null {
   return 'not null';
}

# vim: expandtab shiftwidth=4:
