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

# Regression tests for several bugs found by Jean-Damien

# VALUATOR: TODO

use 5.010001;

use strict;
use warnings;

use Test::More tests => 10;
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use lib 'inc';
use Marpa::R3::Test;

## no critic (ErrorHandling::RequireCarping);

use Marpa::R3;

my $dsl;
my $grammar;
my $recce;
my $input;
my $length;
my $expected_output;
my $actual_output;
my $pos = 0;

# This first problem was with ambiguous SLIF parses when
# used together with values from an external scanner

$dsl = <<'END_OF_SOURCE';
:default ::= action => ::first
:start ::= Expression
Expression ::= Number
    | Expression Add Expression action => do_add
    | Expression Multiply Expression action => do_multiply
      Add ~ '+'
      Multiply ~ '*'
      Number ~ digits
      digits ~ [\d]+
      :discard ~ whitespace
      whitespace ~ [\s]+
END_OF_SOURCE

$grammar = Marpa::R3::Scanless::G->new(
    {
        semantics_package => 'My_Actions',
        source            => \$dsl
    }
);
$recce = Marpa::R3::Scanless::R->new( { grammar => $grammar } );
$input = '2*1+3*4+5';
$pos   = 0;
$recce->read( \$input, 0, 0 );
for my $input_token (qw(2 * 1 + 3 * 4 + 5)) {
    my $token_type =
          $input_token eq '+' ? 'Add'
        : $input_token eq '*' ? 'Multiply'
        :                       'Number';
    my $return_value = $recce->lexeme_read( $token_type, $pos, 1, $input_token );
    $pos++;
    Test::More::is( $return_value, $pos, "Return value of lexeme_read() is $pos" );
} ## end for my $input_token (qw(2 * 1 + 3 * 4 + 5))

my @values = ();
my $valuer = Marpa::R3::Scanless::V->new( { recognizer => $recce } );
while ( my $value_ref = $valuer->value() ) {
    push @values, ${$value_ref};
}

$expected_output = '19 19 25 29 31 36 36 37 37 42 45 56 72 72';
$actual_output = join " ", sort @values;
Test::More::is( $actual_output, $expected_output, 'Values for Durand test' );

sub My_Actions::do_add {
    my ( undef, $v ) = @_;
    my ( $t1, undef, $t2 ) = @{$v};
    return $t1 + $t2;
}

sub My_Actions::do_multiply {
    my ( undef, $v ) = @_;
    my ( $t1, undef, $t2 ) = @{$v};
    return $t1 * $t2;
}

# vim: expandtab shiftwidth=4:
