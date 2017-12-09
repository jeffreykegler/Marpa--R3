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

# Converted to SLIF from Marpa::R2 leo_unit.t

# Test of Leo logic for unit rule.

use 5.010001;

use strict;
use warnings;

use List::Util;
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use Test::More tests => 5;

use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

## no critic (Subroutines::RequireArgUnpacking)

sub main::default_action {
    return ( join q{}, grep {defined} @{$_[1]} );
}

## use critic

my $dsl = <<'END_OF_DSL';
:default ::= action => main::default_action
A ::= a B
B ::= C
C ::= c A
C ::= c
a ~ 'a'
c ~ 'c'
END_OF_DSL

my $grammar = Marpa::R3::Grammar->new( { source => \$dsl } );

Marpa::R3::Test::is( $grammar->symbols_show(),
    <<'END_OF_STRING', 'Leo166 Symbols' );
S1 A
S2 B
S3 C
S4 [:lex_start:]
S5 [:start:]
S6 [a]
S7 [c]
S8 a
S9 c
END_OF_STRING

Marpa::R3::Test::is( $grammar->productions_show(),
    <<'END_OF_STRING', 'Leo166 Productions' );
R1 [:start:] ::= A
R2 A ::= a B
R3 B ::= C
R4 C ::= c A
R5 C ::= c
R6 [:lex_start:] ~ a
R7 [:lex_start:] ~ c
R8 a ~ [a]
R9 c ~ [c]
END_OF_STRING


Marpa::R3::Test::is( $grammar->ahms_show(), <<'END_OF_STRING', 'Leo166 AHMs' );
AHM 0: dot=0; nulls=0
    A ::= . a B
AHM 1: dot=1; nulls=0
    A ::= a . B
AHM 2: completion; dot=2; nulls=0
    A ::= a B .
AHM 3: dot=0; nulls=0
    B ::= . C
AHM 4: completion; dot=1; nulls=0
    B ::= C .
AHM 5: dot=0; nulls=0
    C ::= . c A
AHM 6: dot=1; nulls=0
    C ::= c . A
AHM 7: completion; dot=2; nulls=0
    C ::= c A .
AHM 8: dot=0; nulls=0
    C ::= . c
AHM 9: completion; dot=1; nulls=0
    C ::= c .
AHM 10: dot=0; nulls=0
    [:start:] ::= . A
AHM 11: completion; dot=1; nulls=0
    [:start:] ::= A .
AHM 12: dot=0; nulls=0
    [:start:]['] ::= . [:start:]
AHM 13: completion; dot=1; nulls=0
    [:start:]['] ::= [:start:] .
END_OF_STRING

my $recce = Marpa::R3::Recognizer->new(
    { grammar => $grammar } );

my $input = 'acacac';
my $length_of_input = length $input;
$recce->read( \$input );

my @sizes = (0);
TOKEN: for ( my $i = 0; $i < $length_of_input; $i++ ) {
    push @sizes, $recce->earley_set_size($i);
}

my $max_size = List::Util::max(@sizes);
my $expected_size = 6;
Marpa::R3::Test::is( $max_size, $expected_size,
    "Earley set size was $max_size; $expected_size was expected" );

my $value_ref = $recce->value();
my $value = $value_ref ? ${$value_ref} : 'No parse';
Marpa::R3::Test::is( $value, 'acacac', 'Leo unit rule parse' );

# vim: expandtab shiftwidth=4:
