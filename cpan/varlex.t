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

# Test of SLIF external interface

use 5.010001;

use strict;
use warnings;
use Test::More tests => 11;
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale( LC_ALL, "C" );

use lib 'inc';
use Marpa::R3::Test;

## no critic (ErrorHandling::RequireCarping);

use Marpa::R3;

sub lo_reader {
    my ( $recce, $start_of_lexeme, $lexeme, $symbol_name, $long_name ) = @_;
    my ($block_id) = $recce->block_progress();
    my $value      = $lexeme;
    my $length     = length $value;
    my $offset     = $start_of_lexeme;

    my $ok = $recce->lexeme_alternative( $symbol_name, $value );
    if ( not defined $ok ) {
        my $literal = $recce->literal( $block_id, $offset, $length );
        die qq{Parser rejected symbol named "$symbol_name" },
          qq{at position $offset, before lexeme "$literal"};
    }

    my $new_offset = $recce->lexeme_complete( $block_id, $offset, $length );

}

sub lo_literal_reader {
    my ( $recce, $start_of_lexeme, $lexeme, $symbol_name, $long_name ) = @_;
    my ( $main_block, $offset, $eoread ) = $recce->block_progress();
    my $lexeme_length = length $lexeme;

    # Marpa::R3::Display
    # name: recognizer lexeme_alternative_literal() synopsis

    my $ok = $recce->lexeme_alternative_literal($symbol_name);
    die
qq{Parser rejected token "$long_name" at position $start_of_lexeme, before "},
      $recce->literal( $main_block, $start_of_lexeme, 40 ), q{"}
      if not defined $ok;
    $ok =
      $recce->lexeme_complete( $main_block, $start_of_lexeme, $lexeme_length );

    # Marpa::R3::Display::End

}

my $grammar = Marpa::R3::Grammar->new(
    {
        bless_package => 'Calc_Nodes',
        source        => \(<<'END_OF_SOURCE'),
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

sub do_test {
    my ($hash) = @_;
    my $reader = $hash->{reader};
    my $valuer = $hash->{valuer} || \&hi_valuer;
    my $string = '42*2+7/3, 42*(2+7)/3, 2**7-3, 2**(7-3)';
    my $recce  = Marpa::R3::Recognizer->new( { grammar => $grammar } );

    # Marpa::R3::Display
    # name: recognizer read() synopsis

    $recce->read( \$string, 0, 0 );

    # Marpa::R3::Display::End

    my ($main_block) = $recce->block_progress();

    my $length = length $string;
    pos $string = 0;
  TOKEN: while (1) {
        my $start_of_lexeme = pos $string;
        last TOKEN if $start_of_lexeme >= $length;
        next TOKEN if $string =~ m/\G\s+/gcxms;      # skip whitespace
      TOKEN_TYPE: for my $t (@terminals) {
            my ( $symbol_name, $regex, $long_name ) = @{$t};
            my $start_of_lexeme = pos $string;
            next TOKEN_TYPE if not $string =~ m/\G($regex)/gcxms;
            my $lexeme = $1;
            $reader->(
                $recce, $start_of_lexeme, $lexeme, $symbol_name, $long_name
            );
            $recce->block_move( $start_of_lexeme + length $lexeme );
        }
    } ## end TOKEN: while (1)
    my $value = $valuer->($recce)->doit();
    Test::More::like(
        $value,
        qr/\A 86[.]3\d+ \s+ 126 \s+ 125 \s+ 16\z/xms,
        'Value of parse'
    );
}

do_test( { reader => \&lo_reader } );
do_test( { reader => \&hi_block_reader } );
do_test( { reader => \&eq_block_reader } );
do_test( { reader => \&lo_literal_reader } );
do_test( { reader => \&hi_literal_reader } );
do_test( { reader => \&eq_literal_reader } );
do_test( { reader => \&eq2_literal_reader } );
do_test( { reader => \&hi_string_reader } );
do_test( { reader => \&eq_string_reader } );
do_test( { reader => \&eq2_string_reader } );
do_test( { reader => \&hi_block_reader, valuer => \&eq_valuer } );

# vim: expandtab shiftwidth=4:
