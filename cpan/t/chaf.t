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

# Note: Converted from sl_gia.t

use 5.010001;
use strict;
use warnings;

use Test::More tests => 2;
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

## no critic (Subroutines::RequireArgUnpacking)

sub default_action {
    my (undef, $v) = @_;
    my $v_count = scalar @{$v};
    return q{}   if $v_count <= 0;
    return $v->[0] if $v_count == 1;
    return '(' . ( join q{;}, @{$v} ) . ')';
} ## end sub default_action

## use critic

my $grammar = Marpa::R3::Scanless::G->new(
    {
        semantics_package => 'main',
        source            => \<<'END_OF_DSL'
:default ::= action => default_action
S ::= A B B B C C
A ::= 'a'
B ::= 'a'
B ::=
C ::=
END_OF_DSL
    }
);

Marpa::R3::Test::is( $grammar->g1_rules_show, <<'EOS', 'Aycock/Horspool Rules' );
G1 R0 S ::= A B B B C C
G1 R1 A ::= 'a'
G1 R2 B ::= 'a'
G1 R3 B ::=
G1 R4 C ::=
G1 R5 [:start:] ::= S
EOS

my $recce = Marpa::R3::Scanless::R->new( { grammar => $grammar } );

$recce->read( \q{a} );

my $value_ref = $recce->value();
my $value = defined $value_ref ? ${$value_ref} : 'undef';
Test::More::is( $value, '(a;;;;;)', 'subp test' );

# vim: expandtab shiftwidth=4:
