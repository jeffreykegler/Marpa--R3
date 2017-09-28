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

# This is leo3.t from Marpa::R2 converted to the SLIF

# The example from p. 166 of Leo's paper,
# augmented to test Leo prediction items.
# Similar to other tests, but the focuses in this
# one are the Earley set counts and the
# diagnostics.

use 5.010001;

use strict;
use warnings;

use Test::More tests => 5;
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

## no critic (Subroutines::RequireArgUnpacking)

sub main::default_action {
    return ( join q{}, grep {defined} @{$_[1]} );
}

## use critic

my $grammar = Marpa::R3::Scanless::G->new(
    { 
        source => \(<<'END_OF_DSL'),
:default ::= action => main::default_action
:start ::= S
S ::= a A
A ::= B
B ::= C
C ::= S
S ::=
a ~ 'a'
END_OF_DSL
    }
);

Marpa::R3::Test::is( $grammar->symbols_show(),
    <<'END_OF_STRING', 'Leo166 Symbols' );
S1 A
S2 B
S3 C
S4 S
S5 [:lex_start:]
S6 [:start:]
S7 [a]
S8 a
END_OF_STRING

Marpa::R3::Test::is( $grammar->productions_show,
    <<'END_OF_STRING', 'Leo166 Productions' );
R1 [:start:] ::= S
R2 S ::= a A
R3 A ::= B
R4 B ::= C
R5 C ::= S
R6 S ::=
R7 [:lex_start:] ~ a
R8 a ~ [a]
END_OF_STRING

Marpa::R3::Test::is( $grammar->ahms_show(), <<'END_OF_STRING', 'Leo166 AHMs' );
AHM 0: postdot = "a"
    S ::= . a A
AHM 1: postdot = "A"
    S ::= a . A
AHM 2: completion
    S ::= a A .
AHM 3: postdot = "a"
    S ::= . a A[]
AHM 4: completion
    S ::= a A[] .
AHM 5: postdot = "B"
    A ::= . B
AHM 6: completion
    A ::= B .
AHM 7: postdot = "C"
    B ::= . C
AHM 8: completion
    B ::= C .
AHM 9: postdot = "S"
    C ::= . S
AHM 10: completion
    C ::= S .
AHM 11: postdot = "S"
    [:start:] ::= . S
AHM 12: completion
    [:start:] ::= S .
AHM 13: postdot = "[:start:]"
    [:start:]['] ::= . [:start:]
AHM 14: completion
    [:start:]['] ::= [:start:] .
END_OF_STRING

my $length = 20;

my $recce = Marpa::R3::Scanless::R->new(
    { grammar => $grammar } );

my $i                 = 0;
my $g1_pos = $recce->g1_pos();
my $max_size          = $recce->earley_set_size($g1_pos);
$recce->read( \('a' x $length) );
TOKEN: for ( my $i = 0; $i < $length; $i++ ) {
    my $size = $recce->earley_set_size($i);
    $max_size = $size > $max_size ? $size : $max_size;
} ## end while ( $i++ < $length )

my $expected_size = 10;
Marpa::R3::Test::is( $max_size, $expected_size,
"Earley set size, got $max_size, expected $expected_size" );

my $value_ref = $recce->value();
my $value = $value_ref ? ${$value_ref} : 'No parse';
Marpa::R3::Test::is( $value, 'a' x $length, 'Leo p166 parse' );

# vim: expandtab shiftwidth=4:
