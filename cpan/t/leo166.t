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

# CENSUS: ASIS
# Note: Converted to SLIF from leo2.t

# The example from p. 166 of Leo's paper.

# MITOSIS: TODO

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

my $grammar = Marpa::R3::Scanless::G->new( { source => \$dsl } );

Marpa::R3::Test::is( $grammar->g1_show_symbols(),
    <<'END_OF_STRING', 'Leo166 Symbols' );
G1 S0 S
G1 S1 [:start:]
G1 S2 a
END_OF_STRING

Marpa::R3::Test::is( $grammar->g1_rules_show, <<'END_OF_STRING', 'Leo166 Rules' );
R0 S ::= a S
R1 S ::=
R2 [:start:] ::= S
END_OF_STRING

Marpa::R3::Test::is( $grammar->show_ahms, <<'END_OF_STRING', 'Leo166 AHMs' );
AHM 0: postdot = "a"
    S ::= . a S
AHM 1: postdot = "S"
    S ::= a . S
AHM 2: completion
    S ::= a S .
AHM 3: postdot = "a"
    S ::= . a S[]
AHM 4: completion
    S ::= a S[] .
AHM 5: postdot = "S"
    [:start:] ::= . S
AHM 6: completion
    [:start:] ::= S .
AHM 7: postdot = "[:start:]"
    [:start:]['] ::= . [:start:]
AHM 8: completion
    [:start:]['] ::= [:start:] .
END_OF_STRING

my $length = 50;
my $input = 'a' x $length;

my $recce = Marpa::R3::Scanless::R->new( { grammar => $grammar } );
$recce->read( \$input, 0, 0 );

my $g1_pos = $recce->g1_pos();

my $max_size = $recce->earley_set_size($g1_pos);
TOKEN: for ( my $i = 0; $i < $length; $i++ ) {
    $recce->lexeme_read( 'a', undef, 1, (substr $input, $i, 1) );
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
