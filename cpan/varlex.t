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

sub value_reader {
    my ( $recce, $lexeme_length ) = @_;
    my $ok = $recce->lexeme_alternative( 'A', 42, $lexeme_length );
    return $ok;
}

my $grammar = Marpa::R3::Grammar->new(
    {
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
    my $string = 'aaaa';
    my $recce  = Marpa::R3::Recognizer->new( { grammar => $grammar } );

    $recce->read( \$string, 0, 0 );

    my ($main_block) = $recce->block_progress();

    my $length = length $string;
  TOKEN: while (1) {
        my (undef, $start_of_lexeme) = $recce->block_progress();
        last TOKEN if $start_of_lexeme >= $length;
        for my $lexeme_length ( 1 .. $length - $start_of_lexeme ) {
            my $ok = $reader->( $recce, $lexeme_length );
            die qq{Parser rejected symbol at position $start_of_lexeme}
                if not defined $ok;
        }
        my ($block_id) = $recce->block_progress();
        my $new_offset =
          $recce->lexeme_complete( $block_id, $start_of_lexeme, 1 );
    } ## end TOKEN: while (1)
  VALUE: while (1) {
        my $value_ref = $recce->value();
        last VALUE if not $value_ref;
        say STDERR Data::Dumper::Dumper($value_ref);
    }
}

do_test( { reader => \&value_reader } );
# do_test( { reader => \&undef_reader } );
# do_test( { reader => \&literal_reader } );

# vim: expandtab shiftwidth=4:
