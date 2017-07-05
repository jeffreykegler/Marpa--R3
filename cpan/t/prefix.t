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

# Test of scannerless parsing -- prefix addition

# MITOSIS: TODO

use 5.010001;
use strict;
use warnings;

use English qw( -no_match_vars );
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use Test::More tests => 30;
use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

my $prefix_grammar = Marpa::R3::Scanless::G->new(
    {
        semantics_package => 'My_Actions',
        source            => \(<<'END_OF_RULES'),
:default ::= action => do_arg0
:start ::= Script
Script ::= Calculation* action => do_list
Calculation ::= Expression | ('say') Expression
Expression ::=
     Number
   | ('+') Expression Expression action => do_add
Number ~ [\d] +
:discard ~ whitespace
whitespace ~ [\s]+
# allow comments
:discard ~ <hash comment>
<hash comment> ~ <terminated hash comment> | <unterminated
   final hash comment>
<terminated hash comment> ~ '#' <hash comment body> <vertical space char>
<unterminated final hash comment> ~ '#' <hash comment body>
<hash comment body> ~ <hash comment char>*
<vertical space char> ~ [\x{A}\x{B}\x{C}\x{D}\x{2028}\x{2029}]
<hash comment char> ~ [^\x{A}\x{B}\x{C}\x{D}\x{2028}\x{2029}]
END_OF_RULES
    }
);

sub My_Actions::do_list {
    my ( $self, $results ) = @_;
    return +( scalar @{$results} ) . ' results: ' . join q{ }, @{$results};
}

sub My_Actions::do_add  { return $_[1]->[0] + $_[1]->[1] }
sub My_Actions::do_arg0 { return $_[1]->[0] }

sub My_Actions::show_last_expression {
    my ($self) = @_;
    my $recce = $self->{recce};
    my ( $start, $length ) = $recce->last_completed('Expression');
    return if not defined $start;
    my $last_expression = $recce->g1_literal( $start, $length );
    return $last_expression;
} ## end sub My_Actions::show_last_expression

sub my_parser {
    my ( $grammar, $string ) = @_;

    my $recce = Marpa::R3::Scanless::R->new( { grammar => $grammar, } );
    my $self = bless { grammar => $grammar, recce => $recce }, 'My_Actions';
    my ( $parse_value, $parse_status, $last_expression );

    if ( not defined eval { $recce->read( \$string ); 1 } ) {
        my $abbreviated_error = $EVAL_ERROR;
        chomp $abbreviated_error;
        $abbreviated_error =~ s/\n.*//xms;
        return 'No parse', $abbreviated_error, $self->show_last_expression();
    } ## end if ( not defined eval { $recce->read( \$string ); 1 ...})
    my $value_ref = $recce->value($self);
    if ( not defined $value_ref ) {
        return 'No parse', 'Input read to end but no parse',
          $self->show_last_expression();
    }
    return [ return ${$value_ref}, 'Parse OK', 'entire input' ];
} ## end sub my_parser

my @tests_data = (
    [ '+++ 1 2 3 + + 1 2 4',     '1 results: 13', 'Parse OK', 'entire input' ],
    [ 'say + 1 2',               '1 results: 3', 'Parse OK', 'entire input' ],
    [ '+ 1 say 2',               'No parse', 'Error in SLIF parse: No lexeme found at B1L1c5', '1' ],
    [ '+ 1 2 3 + + 1 2 4',       '3 results: 3 3 7', 'Parse OK', 'entire input' ],
    [ '+++',                     'No parse', 'Input read to end but no parse', 'none' ],
    [ '++1 2++',                 'No parse', 'Input read to end but no parse', '+1 2' ],
    [ '++1 2++3 4++',            'No parse', 'Input read to end but no parse', '+3 4' ],
    [ '1 + 2 +3  4 + 5 + 6 + 7', 'No parse', 'Input read to end but no parse', '7' ],
    [ '+12',                     'No parse', 'Input read to end but no parse', '12' ],
    [ '+1234',                   'No parse', 'Input read to end but no parse', '1234' ],
);

TEST:
for my $test_data (@tests_data) {
    my ($test_string,     $expected_value,
        $expected_result, $expected_last_expression
    ) = @{$test_data};
    my ($actual_value,
        $actual_result, $actual_last_expression
    ) = my_parser( $prefix_grammar, $test_string );
    $actual_last_expression //= 'none';
    Test::More::is( $actual_value, $expected_value, qq{Value of "$test_string"} );
    Test::More::is( $actual_result, $expected_result, qq{Result of "$test_string"} );
    Test::More::is( $actual_last_expression, $expected_last_expression, qq{Last expression found in "$test_string"} );
} ## end TEST: for my $test_string (@test_strings)

# vim: expandtab shiftwidth=4:
