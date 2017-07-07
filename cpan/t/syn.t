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

# Synopsis for scannerless parsing, main POD page

use 5.010001;
use strict;
use warnings;

use English qw( -no_match_vars );
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use Test::More tests => 21;
use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

my $grammar = Marpa::R3::Scanless::G->new(
    {

# Marpa::R3::Display
# name: Scanless concept example

        source => \(<<'END_OF_SOURCE'),
:start ::= <number sequence>
<number sequence> ::= <number>+ action => My_Actions::add_sequence
number ~ digit+
digit ~ [0-9]
:discard ~ whitespace
whitespace ~ [\s]+
END_OF_SOURCE

# Marpa::R3::Display::End

    }
);

package My_Actions;

sub add_sequence {
    my ($self, $values) = @_;
    return List::Util::sum @{$values}, 0;
}

sub show_sequence_so_far {
    my ($self) = @_;
    my $recce = $self->{recce};
    my ( $start, $length ) = $recce->last_completed('number sequence');
    return if not defined $start;
    my $sequence_so_far = $recce->g1_literal( $start, $length );
    return $sequence_so_far;
} ## end sub show_sequence_so_far

package main;

sub my_parser {
    my ( $grammar, $string ) = @_;

    my $parse_arg = bless { grammar => $grammar }, 'My_Actions';

    my $recce = Marpa::R3::Scanless::R->new( { grammar => $grammar } );
    $parse_arg->{recce} = $recce;
    my ( $parse_value, $parse_status, $sequence_so_far );

    if ( not defined eval { $recce->read( \$string ); 1 } ) {
        return 'No parse', $EVAL_ERROR, $parse_arg->show_sequence_so_far();
    }
    my $value_ref = $recce->value( $parse_arg);
    if ( not defined $value_ref ) {
        return 'No parse', 'Input read to end but no parse',
            $parse_arg->show_sequence_so_far();
    }
    return [ return ${$value_ref}, 'Parse OK', ];
} ## end sub my_parser

my @tests_data = (
    [ ' 1 2 3   1 2 4', 13,      qr/\AParse \s+ OK\z/xms ],
    [ ' 8675311',       8675311, qr/\AParse \s+ OK\z/xms ],
    [ '867 5311',       6178,    qr/\AParse \s+ OK\z/xms ],
    [ ' 8 6 7 5 3 1 1', 31,      qr/\AParse \s+ OK\z/xms ],
    [ '1234',           1234,    qr/\AParse \s+ OK\z/xms ],
    [   '2 x 1234', 'No parse',
        qr/ Character \s+ in \s+ input \s+ is \s+ not \s+ in \s+ alphabet \s+ of \s+ grammar: \s+ U [+] 0078 \s* "x" /xms
    ],
    [   '', 'No parse',
        qr/\A Input \s+ read \s+ to \s+ end \s+ but \s+ no \s+ parse \z/xms,
    ],
);

TEST:
for my $test_data (@tests_data) {
    my ($test_string,     $expected_value,
        $expected_result, $expected_sequence_so_far
    ) = @{$test_data};
    $expected_sequence_so_far //= 'none';
    my ($actual_value,
        $actual_result, $actual_sequence_so_far
    ) = my_parser( $grammar, $test_string );
    $actual_sequence_so_far //= 'none';
    Test::More::is( $actual_value, $expected_value, qq{Value of "$test_string"} );
    Test::More::like( $actual_result, $expected_result, qq{Result of "$test_string"} );
    Test::More::is( $actual_sequence_so_far, $expected_sequence_so_far, qq{Sequence so far from "$test_string"} );
} ## end TEST: for my $test_string (@test_strings)

# vim: expandtab shiftwidth=4:
