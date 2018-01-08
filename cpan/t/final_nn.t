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

# Note: This test is duplicate_parse.t and final_nonnullable.t, ...
# Note: converted to the SLIF

# Catch the case of a final non-nulling symbol at the end of a rule
# which has more than 2 proper nullables
# This is to test an untested branch of the CHAF logic.

use 5.010001;

use strict;
use warnings;

use Test::More tests => 10;
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

## no critic (Subroutines::RequireArgUnpacking)

sub default_action {
    my (undef, $v) = @_;
    my $v_count = scalar @{$v};
    return q{-} if $v_count <= 0;
    return $v->[0] if $v_count == 1;
    my @vals = map { $_ // q{-} } @{$v};
    return '(' . join( q{;}, @vals ) . ')';
} ## end sub default_action

## use critic

my $grammar = Marpa::R3::Grammar->new(
    {
        source => \<<'DSL'
:default ::= action => main::default_action
S ::= p p p n
p ::= a
p ::=
n ::= a
a ~ [\d\D]
DSL
    }
);

Marpa::R3::Test::is( $grammar->productions_show( { verbose => 1 } ),
    <<'END_OF_STRING', 'final nonnulling Rules' );
R1 [:start:] ::= S
R2 S ::= p p p n
R3 p ::= a
R4 p ::=
R5 n ::= a
R6 [:lex_start:] ~ a
R7 a ~ [\d\D]
END_OF_STRING

Marpa::R3::Test::is( $grammar->ahms_show(),
    <<'END_OF_STRING', 'final nonnulling AHFA' );
AHM 0: dot=0; nulls=0
    S ::= . p p S[R0:2]
AHM 1: dot=1; nulls=0
    S ::= p . p S[R0:2]
AHM 2: dot=2; nulls=0
    S ::= p p . S[R0:2]
AHM 3: completion; dot=3; nulls=0
    S ::= p p S[R0:2] .
AHM 4: dot=0; nulls=0
    S ::= . p p[] S[R0:2]
AHM 5: dot=2; nulls=1
    S ::= p p[] . S[R0:2]
AHM 6: completion; dot=3; nulls=0
    S ::= p p[] S[R0:2] .
AHM 7: dot=1; nulls=1
    S ::= p[] . p S[R0:2]
AHM 8: dot=2; nulls=0
    S ::= p[] p . S[R0:2]
AHM 9: completion; dot=3; nulls=0
    S ::= p[] p S[R0:2] .
AHM 10: dot=2; nulls=2
    S ::= p[] p[] . S[R0:2]
AHM 11: completion; dot=3; nulls=0
    S ::= p[] p[] S[R0:2] .
AHM 12: dot=0; nulls=0
    S[R0:2] ::= . p n
AHM 13: dot=1; nulls=0
    S[R0:2] ::= p . n
AHM 14: completion; dot=2; nulls=0
    S[R0:2] ::= p n .
AHM 15: dot=1; nulls=1
    S[R0:2] ::= p[] . n
AHM 16: completion; dot=2; nulls=0
    S[R0:2] ::= p[] n .
AHM 17: dot=0; nulls=0
    p ::= . a
AHM 18: completion; dot=1; nulls=0
    p ::= a .
AHM 19: dot=0; nulls=0
    n ::= . a
AHM 20: completion; dot=1; nulls=0
    n ::= a .
AHM 21: dot=0; nulls=0
    [:start:] ::= . S
AHM 22: completion; dot=1; nulls=0
    [:start:] ::= S .
AHM 23: dot=0; nulls=0
    [:start:]['] ::= . [:start:]
AHM 24: completion; dot=1; nulls=0
    [:start:]['] ::= [:start:] .
END_OF_STRING

my @expected = map {
    +{ map { ( $_ => 1 ) } @{$_} }
    }
    [q{}],
    [qw( (-;-;-;a) )],
    [qw( (a;-;-;b) (-;-;a;b) (-;a;-;b) )],
    [qw( (a;b;-;c) (-;a;b;c) (a;-;b;c))],
    [qw( (a;b;c;d) )];

use constant SPACE => 0x60;

for my $input_length ( 1 .. 4 ) {

    my $recce = Marpa::R3::Recognizer->new( { grammar => $grammar } );
    my $input = substr( 'abcd', 0, $input_length );
    $recce->read( \$input );

    # Set max at 10 just in case there's an infinite loop.
    # This is for debugging, after all
    my $valuer =
      Marpa::R3::Valuer->new( { recognizer => $recce, max_parses => 10 } );
    while ( my $value_ref = $valuer->value() ) {
        my $value = $value_ref ? ${$value_ref} : 'No parse';
        my $expected = $expected[$input_length];
        if ( defined $expected->{$value} ) {
            delete $expected->{$value};
            Test::More::pass(qq{Expected value: "$value"});
        }
        else {
            Test::More::fail(qq{Unexpected value: "$value"});
        }
    }
} ## end for my $input_length ( 1 .. 4 )

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
