#!/usr/bin/perl
# Marpa::R3 is Copyright (C) 2018, Jeffrey Kegler.
#
# This module is free software; you can redistribute it and/or modify it
# under the same terms as Perl 5.10.1. For more details, see the full text
# of the licenses in the directory LICENSES.
#
# This program is distributed in the hope that it will be
# useful, but it is provided "as is" and without any express
# or implied warranties. For details, see the full text of
# of the licenses in the directory LICENSES.

# Test of variable-length lexemes,
# focusing on earleme_catchup() method.

use 5.010001;

use strict;
use warnings;
use Test::More tests => 212;
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale( LC_ALL, "C" );

use lib 'inc';
use Marpa::R3::Test;

## no critic (ErrorHandling::RequireCarping);

use Marpa::R3;

sub max {
    my ( $a, $b ) = @_;
    return $a > $b ? $a : $b;
}

sub min {
    my ( $a, $b ) = @_;
    return $b > $a ? $a : $b;
}

my $grammar = Marpa::R3::Grammar->new(
    {
        source => \(<<'END_OF_SOURCE'),
:default ::= action => ::array
As ::= A+

# we don't actually use the SLIF lexer
# This is a placebo lexer that recognizes nothing,
# and discards everything
:discard ~ [\s\S]
A ~ unicorn
unicorn ~ [^\s\S]
END_OF_SOURCE
    }
);

my ($hash)   = @_;
my $expected = {};
my $string   = '123456789';
my $recce = Marpa::R3::Recognizer->new( { grammar => $grammar } );

test_locations( 0, 0, 0, 0, "before read()" );

$recce->read( \$string, 0, 0 );

test_locations( 0, 0, 0, 0, "after read()" );

my ($main_block) = $recce->block_progress();

my $furthest_expected = 0;
my $length = length $string;
TOKEN: while (1) {
    my ( undef, $start_of_lexeme ) = $recce->block_progress();
    last TOKEN if $length - $start_of_lexeme <= 3;
    my $max_lexeme_length = min( 5, $length - $start_of_lexeme );
    for my $lexeme_length ( 1 .. $max_lexeme_length ) {
        my $ok = $recce->lexeme_alternative_literal( 'A', $lexeme_length );
        $furthest_expected =
          max( $start_of_lexeme + $lexeme_length, $furthest_expected );
        test_locations(
            $start_of_lexeme,
            $start_of_lexeme,
            $start_of_lexeme,
            $furthest_expected,
            "after lexeme_alternative_literal('a', $lexeme_length) @"
              . "$start_of_lexeme"
        );
        die qq{Parser rejected symbol at position $start_of_lexeme}
          if not defined $ok;
    }
    my ($block_id) = $recce->block_progress();
    my $new_offset = $recce->lexeme_complete( $block_id, $start_of_lexeme, 1 );
    test_locations(
        $start_of_lexeme + 1,
        $start_of_lexeme + 1,
        $start_of_lexeme + 1,
        $furthest_expected, "after lexeme complete @" . $start_of_lexeme
    );
} ## end TOKEN: while (1)

$recce->earleme_catchup();
test_locations( 7, 9, 9, 9, "after earleme_catchup()" );

my $valuer = Marpa::R3::Valuer->new( { recognizer => $recce } );
my @values;

local $Data::Dumper::Terse  = 1;    # don't output names where feasible
local $Data::Dumper::Indent = 0;    # turn off all pretty print

VALUE: while (1) {
    my $value_ref = $valuer->value();
    last VALUE if not $value_ref;
    my $value = Data::Dumper::Dumper($value_ref);
    push @values, $value;
}
@values = sort { $a cmp $b } @values;
Test::More::is_deeply( \@values, $expected, qq{"variable length" test} );

sub test_locations {
    my ( $latest_es_wanted, $latest_earleme_wanted, $current_earleme_wanted,
        $furthest_earleme_wanted, $where )
      = @_;
    Test::More::is( $recce->g1_pos(), $latest_es_wanted, "latest es $where" );
    Test::More::is( $recce->latest_earleme(),
        $latest_earleme_wanted, "latest earleme $where" );
    Test::More::is( $recce->current_earleme(),
        $current_earleme_wanted, "current earleme $where" );
    Test::More::is( $recce->furthest_earleme(),
        $furthest_earleme_wanted, "furthest earleme $where" );
}

# vim: expandtab shiftwidth=4:
