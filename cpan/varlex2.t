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
use Test::More tests => 11;
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

# A single lexeme complete
if (1) {
    my $string = '12345';
    my $recce = Marpa::R3::Recognizer->new( { grammar => $grammar } );

    $recce->read( \$string, 0, 0 );

    my ($main_block) = $recce->block_progress();

    my $new_offset_wanted = 5;
    my $ok = $recce->lexeme_alternative_literal( 'A', 5 );

    Test::More::ok( $ok, "lexeme_alternative_literal() succeeded" );

    test_locations( $recce, 0, 0, 0, 5, "after lexeme_alternative_literal()" );

    my $new_offset = $recce->lexeme_complete( undef, 0, -1 );
    Test::More::is( $new_offset, $new_offset_wanted,
        "lexeme_complete() (is $new_offset vs $new_offset_wanted)" );

    test_locations( $recce, 1, 5, 5, 5, "after lexeme_complete()" );

    my $valuer = Marpa::R3::Valuer->new( { recognizer => $recce } );
    my @values;

    local $Data::Dumper::Terse  = 1;    # don't output names where feasible
    local $Data::Dumper::Indent = 0;    # turn off all pretty print

  VALUE: while (1) {
        my $value_ref = $valuer->value();
        say Data::Dumper::Dumper($value_ref);
        last VALUE if not $value_ref;
        my $value = Data::Dumper::Dumper($value_ref);
        push @values, $value;
    }
    @values = sort { $a cmp $b } @values;
    my $values_expected = ['\\[\'12345\']'];
    Test::More::is_deeply( \@values, $values_expected,
        qq{"variable length" test} );

    say STDERR Data::Dumper::Dumper( \@values );
    say STDERR Data::Dumper::Dumper($values_expected);
}

sub test_locations {
    my ( $recce, $latest_es_wanted, $latest_earleme_wanted, $current_earleme_wanted,
        $furthest_earleme_wanted, $where )
      = @_;
    my $latest_es_seen = $recce->g1_pos();
    Test::More::is( $latest_es_seen, $latest_es_wanted,
        "latest es (is $latest_es_seen vs $latest_es_wanted) $where" );
    my $latest_earleme_seen = $recce->latest_earleme();
    Test::More::is( $latest_earleme_seen, $latest_earleme_wanted,
        "latest earleme (is $latest_earleme_seen vs $latest_earleme_wanted) $where" );
    my $current_earleme_seen = $recce->current_earleme();
    Test::More::is( $current_earleme_seen, $current_earleme_wanted,
        "current earleme (is $current_earleme_seen vs $current_earleme_wanted) $where" );
    my $furthest_earleme_seen = $recce->furthest_earleme();
    Test::More::is( $furthest_earleme_seen, $furthest_earleme_wanted,
        "furthest earleme (is $furthest_earleme_seen vs $furthest_earleme_wanted) $where" );
}

# vim: expandtab shiftwidth=4:
