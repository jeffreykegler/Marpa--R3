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

# Note: Converted to SLIF from minus.t

use 5.010001;

use strict;
use warnings;
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use Test::More tests => 10;

use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

# The inefficiency (at least some of it) is deliberate.
# Passing up a duples of [ string, value ] and then
# assembling a final string at the top would be better
# than assembling the string then taking it
# apart at each step.  But I wanted to test having
# a start symbol that appears repeatedly on the RHS.

## no critic (Subroutines::RequireArgUnpacking)

sub subtraction {
    my (undef, $values) = @_;
    my ( $right_string, $right_value ) = ( $values->[2] =~ /^(.*)==(.*)$/xms );
    my ( $left_string,  $left_value )  = ( $values->[0] =~ /^(.*)==(.*)$/xms );
    my $value = $left_value - $right_value;
    return '(' . $left_string . q{-} . $right_string . ')==' . $value;
} ## end sub subtraction

sub postfix_decr {
    my (undef, $values) = @_;
    my ( $string, $value ) = ( $values->[0] =~ /^(.*)==(.*)$/xms );
    return '(' . $string . q{--} . ')==' . $value--;
}

sub prefix_decr {
    my (undef, $values) = @_;
    my ( $string, $value ) = ( $values->[1] =~ /^(.*)==(.*)$/xms );
    return '(' . q{--} . $string . ')==' . --$value;
}

sub negation {
    my (undef, $values) = @_;
    my ( $string, $value ) = ( $values->[1] =~ /^(.*)==(.*)$/xms );
    return '(' . q{-} . $string . ')==' . -$value;
}

sub number {
    my (undef, $values) = @_;
    my $value = $values->[0];
    return "$value==$value";
}

sub minusminus {
    return q{--};
}

sub default_action {
    my (undef, $values) = @_;
    return q{} if not defined $values;
    return $values->[0] if scalar @{$values} == 1;
    return '(' . join( q{;}, @{$values} ) . ')';
} ## end sub default_action

## use critic

my $grammar = Marpa::R3::Scanless::G->new(
    {
        semantics_package => 'main',
        source            => \<<'END_OF_DSL',
:default ::= action => default_action
E ::= E Minus E action => subtraction
E ::= E MinusMinus action => postfix_decr
E ::= MinusMinus E action => prefix_decr
E ::= Minus E action => negation
E ::= Number action => number
MinusMinus ::= Minus Minus action => minusminus
Minus ~ '-'
Number ~ [\d]+
END_OF_DSL
    }
);

my $recce = Marpa::R3::Scanless::R->new(
    {
        grammar => $grammar
    }
);

Marpa::R3::Test::is( $grammar->g1_show_rules,
    <<'END_RULES', 'Minuses Equation Rules' );
G1 R0 E ::= E Minus E
G1 R1 E ::= E MinusMinus
G1 R2 E ::= MinusMinus E
G1 R3 E ::= Minus E
G1 R4 E ::= Number
G1 R5 MinusMinus ::= Minus Minus
G1 R6 [:start:] ::= E
END_RULES

Marpa::R3::Test::is( $grammar->show_ahms,
    <<'END_AHMS', 'Minuses Equation AHMs' );
AHM 0: postdot = "E"
    E ::= . E Minus E
AHM 1: postdot = "Minus"
    E ::= E . Minus E
AHM 2: postdot = "E"
    E ::= E Minus . E
AHM 3: completion
    E ::= E Minus E .
AHM 4: postdot = "E"
    E ::= . E MinusMinus
AHM 5: postdot = "MinusMinus"
    E ::= E . MinusMinus
AHM 6: completion
    E ::= E MinusMinus .
AHM 7: postdot = "MinusMinus"
    E ::= . MinusMinus E
AHM 8: postdot = "E"
    E ::= MinusMinus . E
AHM 9: completion
    E ::= MinusMinus E .
AHM 10: postdot = "Minus"
    E ::= . Minus E
AHM 11: postdot = "E"
    E ::= Minus . E
AHM 12: completion
    E ::= Minus E .
AHM 13: postdot = "Number"
    E ::= . Number
AHM 14: completion
    E ::= Number .
AHM 15: postdot = "Minus"
    MinusMinus ::= . Minus Minus
AHM 16: postdot = "Minus"
    MinusMinus ::= Minus . Minus
AHM 17: completion
    MinusMinus ::= Minus Minus .
AHM 18: postdot = "E"
    [:start:] ::= . E
AHM 19: completion
    [:start:] ::= E .
AHM 20: postdot = "[:start:]"
    [:start:]['] ::= . [:start:]
AHM 21: completion
    [:start:]['] ::= [:start:] .
END_AHMS

my %expected = map { ( $_ => 1 ) } (
    #<<< no perltidy
    '(((6--)--)-1)==5',
    '((6--)-(--1))==6',
    '((6--)-(-(-1)))==5',
    '(6-(--(--1)))==7',
    '(6-(--(-(-1))))==6',
    '(6-(-(--(-1))))==4',
    '(6-(-(-(--1))))==6',
    '(6-(-(-(-(-1)))))==5',
    #>>>
);

$recce->read( \q{6-----1} );

# Set max_parses to 20 in case there's an infinite loop.
# This is for debugging, after all
$recce->set( { max_parses => 20 } );

while ( my $value_ref = $recce->value() ) {
    my $value = $value_ref ? ${$value_ref} : 'No parse';
    if ( defined $expected{$value} ) {
        delete $expected{$value};
        Test::More::pass("Expected Value $value");
    }
    else {
        Test::More::fail("Unexpected Value $value");
    }
} ## end while ( my $value_ref = $recce->value() )

1;    # In case used as "do" file

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
