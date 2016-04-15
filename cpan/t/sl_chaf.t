#!perl
# Copyright 2016 Jeffrey Kegler
# This file is part of Marpa::R3.  Marpa::R3 is free software: you can
# redistribute it and/or modify it under the terms of the GNU Lesser
# General Public License as published by the Free Software Foundation,
# either version 3 of the License, or (at your option) any later version.
#
# Marpa::R3 is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser
# General Public License along with Marpa::R3.  If not, see
# http://www.gnu.org/licenses/.

# CENSUS: ASIS
# Note: Converted from sl_gia.t

use 5.010001;
use strict;
use warnings;

use Test::More tests => 2;
use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

## no critic (Subroutines::RequireArgUnpacking)

sub default_action {
    shift;
    my $v_count = scalar @_;
    return q{}   if $v_count <= 0;
    return $_[0] if $v_count == 1;
    return '(' . ( join q{;}, @_ ) . ')';
} ## end sub default_action

## use critic

my $grammar = Marpa::R3::Scanless::G->new(
    {   source => \<<'END_OF_DSL'
:default ::= action => default_action
S ::= A B B B C C
A ::= 'a'
B ::= 'a'
B ::=
C ::=
END_OF_DSL
    }
);

Marpa::R3::Test::is( $grammar->show_rules, <<'EOS', 'Aycock/Horspool Rules' );
G1 R0 S ::= A B B B C C
G1 R1 A ::= 'a'
G1 R2 B ::= 'a'
G1 R3 B ::=
G1 R4 C ::=
G1 R5 :start ::= S
EOS

my $recce = Marpa::R3::Scanless::R->new(
	{ grammar => $grammar, semantics_package => 'main' } );

$recce->read( \q{a} );

my $value_ref = $recce->value();
my $value = defined $value_ref ? ${$value_ref} : 'undef';
Test::More::is( $value, '(a;;;;;)', 'subp test' );

# vim: expandtab shiftwidth=4:
