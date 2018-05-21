#!perl
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

# Converted to SLIF from Marpa::R2 leo2.t

# The example from p. 166 of Leo's paper.

use 5.010001;

use strict;
use warnings;

use Test::More tests => 5;

use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

## no critic (Subroutines::RequireArgUnpacking)

sub main::default_action {
    my (undef, $values) = @_;
    return ( join q{}, grep { defined } @{$values} );
}

## use critic

my $dsl = <<'END_OF_DSL';
:default ::= action => main::default_action
S ::= a S
S ::=
a ~ 'a'
END_OF_DSL

my $grammar = Marpa::R3::Grammar->new( { source => \$dsl } );

Marpa::R3::Test::is( $grammar->symbols_show(),
    <<'END_OF_STRING', 'Leo166 Symbols' );
S1 S
S2 [:lex_start:]
S3 [:start:]
S4 [:target:]
S5 [a]
S6 a
END_OF_STRING

Marpa::R3::Test::is( $grammar->productions_show(), <<'END_OF_STRING', 'Leo166 Productions' );
R1 [:start:] ::= S
R2 S ::= a S
R3 S ::=
R4 [:lex_start:] ~ [:target:]
R5 [:target:] ~ a
R6 a ~ [a]
END_OF_STRING

Marpa::R3::Test::is( $grammar->ahms_show(), <<'END_OF_STRING', 'Leo166 AHMs' );
AHM 0: dot=0; nulls=0
    S ::= . a S
AHM 1: dot=1; nulls=0
    S ::= a . S
AHM 2: completion; dot=2; nulls=0
    S ::= a S .
AHM 3: dot=0; nulls=0
    S ::= . a S[]
AHM 4: completion; dot=2; nulls=1
    S ::= a S[] .
AHM 5: dot=0; nulls=0
    [:start:] ::= . S
AHM 6: completion; dot=1; nulls=0
    [:start:] ::= S .
AHM 7: dot=0; nulls=0
    [:start:]['] ::= . [:start:]
AHM 8: completion; dot=1; nulls=0
    [:start:]['] ::= [:start:] .
END_OF_STRING

my $length = 50;
my $input = 'a' x $length;

my $recce = Marpa::R3::Recognizer->new( { grammar => $grammar } );
$recce->read( \$input, 0, 0 );

my $g1_pos = $recce->g1_pos();

my $max_size = $recce->earley_set_size($g1_pos);
TOKEN: for ( my $i = 0; $i < $length; $i++ ) {
    $recce->lexeme_read_literal( 'a', undef, $i, 1 );
    $g1_pos = $recce->g1_pos();
    my $size = $recce->earley_set_size($g1_pos);
    $max_size = $size > $max_size ? $size : $max_size;
} ## end while ( $i++ < $length )

my $expected_size = 7;
Marpa::R3::Test::is( $max_size, $expected_size, "Leo test of earley set size" );

my $value_ref = $recce->value();
my $value = $value_ref ? ${$value_ref} : 'No parse';
Marpa::R3::Test::is( $value, 'a' x $length, 'Leo p166 parse' );

# vim: expandtab shiftwidth=4:
