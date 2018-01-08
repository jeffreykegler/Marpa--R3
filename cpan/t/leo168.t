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

# The example from p. 168-169 of Leo's paper.

# Converted to SLIF from leo.t in Marpa::R2

use 5.010001;

use strict;
use warnings;

use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use Test::More tests => 17;

use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

## no critic (Subroutines::RequireArgUnpacking)

sub generate_action {
    my ($lhs) = @_;
    return sub {
        my (undef, $values) = @_;
        return q{-} if @{$values} == 0;
        my @vals = map { $_ // q{-} } @{$values};
        return $lhs . '(' . ( join q{;}, @vals ) . ')';
        }
} ## end sub generate_action

*{My_Action::C_action} = generate_action('C');
$My_Action::C_action = 0 if 0; # prevent spurious warning
*{My_Action::S_action} = generate_action('S');
$My_Action::S_action = 0 if 0; # prevent spurious warning
*{My_Action::default_action} = generate_action(q{?});
$My_Action::default_action = 0 if 0; # prevent spurious warning

## use critic

my $dsl = <<'END_OF_DSL';
:default ::= action => My_Action::default_action;
S ::= a S action => My_Action::S_action
S ::= C action => My_Action::S_action
C ::= a C b action => My_Action::C_action
C ::=
a ~ 'a'
b ~ 'b'
END_OF_DSL

my $grammar = Marpa::R3::Grammar->new( { source => \$dsl } );

Marpa::R3::Test::is( $grammar->symbols_show(),
    <<'END_OF_STRING', 'Leo168 Symbols' );
S1 C
S2 S
S3 [:lex_start:]
S4 [:start:]
S5 [a]
S6 [b]
S7 a
S8 b
END_OF_STRING

Marpa::R3::Test::is( $grammar->productions_show(),
    <<'END_OF_STRING', 'Leo168 Rules' );
R1 [:start:] ::= S
R2 C ::= a C b
R3 C ::=
R4 S ::= a S
R5 S ::= C
R6 [:lex_start:] ~ a
R7 [:lex_start:] ~ b
R8 a ~ [a]
R9 b ~ [b]
END_OF_STRING

Marpa::R3::Test::is( $grammar->ahms_show(), <<'END_OF_STRING', 'Leo168 AHMs' );
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
    S ::= . C
AHM 6: completion; dot=1; nulls=0
    S ::= C .
AHM 7: dot=0; nulls=0
    C ::= . a C b
AHM 8: dot=1; nulls=0
    C ::= a . C b
AHM 9: dot=2; nulls=0
    C ::= a C . b
AHM 10: completion; dot=3; nulls=0
    C ::= a C b .
AHM 11: dot=0; nulls=0
    C ::= . a C[] b
AHM 12: dot=2; nulls=1
    C ::= a C[] . b
AHM 13: completion; dot=3; nulls=0
    C ::= a C[] b .
AHM 14: dot=0; nulls=0
    [:start:] ::= . S
AHM 15: completion; dot=1; nulls=0
    [:start:] ::= S .
AHM 16: dot=0; nulls=0
    [:start:]['] ::= . [:start:]
AHM 17: completion; dot=1; nulls=0
    [:start:]['] ::= [:start:] .
END_OF_STRING

my %expected = (
    'a'        => q{S(a;-)},
    'ab'       => q{S(C(a;-;b))},
    'aa'       => q{S(a;S(a;-))},
    'aab'      => q{S(a;S(C(a;-;b)))},
    'aabb'     => q{S(C(a;C(a;-;b);b))},
    'aaa'      => q{S(a;S(a;S(a;-)))},
    'aaab'     => q{S(a;S(a;S(C(a;-;b))))},
    'aaabb'    => q{S(a;S(C(a;C(a;-;b);b)))},
    'aaabbb'   => q{S(C(a;C(a;C(a;-;b);b);b))},
    'aaaa'     => q{S(a;S(a;S(a;S(a;-))))},
    'aaaab'    => q{S(a;S(a;S(a;S(C(a;-;b)))))},
    'aaaabb'   => q{S(a;S(a;S(C(a;C(a;-;b);b))))},
    'aaaabbb'  => q{S(a;S(C(a;C(a;C(a;-;b);b);b)))},
    'aaaabbbb' => q{S(C(a;C(a;C(a;C(a;-;b);b);b);b))},
);

for my $a_length ( 1 .. 4 ) {
    for my $b_length ( 0 .. $a_length ) {

        my $string = ( 'a' x $a_length ) . ( 'b' x $b_length );
        my $recce = Marpa::R3::Recognizer->new(
            {   grammar  => $grammar,
            }
        );
        my $input = ('a' x $a_length) .  ('b' x $b_length);
        $recce->read( \$input );
        my $value_ref = $recce->value();
        my $value = $value_ref ? ${$value_ref} : 'No parse';
        Marpa::R3::Test::is( $value, $expected{$string}, "Parse of $string" );

    } ## end for my $b_length ( 0 .. $a_length )
} ## end for my $a_length ( 1 .. 4 )

# vim: expandtab shiftwidth=4:
