#!/usr/bin/perl
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

# Tests of the SLIF's discard events

# VALUATOR: TODO

use 5.010001;

use strict;
use warnings;
use Test::More tests => 23;
use English qw( -no_match_vars );
use Scalar::Util;
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use lib 'inc';
use Marpa::R3::Test;

## no critic (ErrorHandling::RequireCarping);

use Marpa::R3;

my $null_grammar = Marpa::R3::Scanless::G->new(
    {   bless_package => 'My_Nodes',
        source        => \(<<'END_OF_SOURCE'),
:default ::= action => [g1start,g1length,name,values]
discard default = event => :symbol=off
lexeme default = action => [ g1start, g1length, start, length, value ]

Script ::=
:discard ~ whitespace event => ws
whitespace ~ [\s]
END_OF_SOURCE
    }
);

for my $input ( q{}, ' ', '  ', '   ' ) {
    my ($recce, $p_events) = gather_events( $null_grammar, {}, $input );
    my $actual_events = join q{ }, map { $_->[0], $_->[-1] } @{$p_events};
    my $length = length $input;
    my $expected_events = join q{ }, ( ('ws 0') x $length );
    Test::More::is( $actual_events, $expected_events,
        "Test of $length discarded spaces" );

    my $value_ref = $recce->old_value();
    die "No parse was found\n" if not defined $value_ref;

    my $result = ${$value_ref};
    # say Data::Dumper::Dumper($result);
} ## end for my $input ( q{}, ' ', '  ', '   ' )

# Test of 2 types of events
my $grammar2 = Marpa::R3::Scanless::G->new(
    {   bless_package => 'My_Nodes',
        source        => \(<<'END_OF_SOURCE'),
:default ::= action => [g1start,g1length,name,values]
discard default = event => :symbol=off
lexeme default = action => [ g1start, g1length, start, length, value ]

Script ::=
:discard ~ whitespace event => ws
whitespace ~ [\s]
:discard ~ bracketed event => bracketed
bracketed ~ '(' <no close bracket> ')'
<no close bracket> ~ [^)]*
END_OF_SOURCE
    }
);


for my $input ( q{ (x) }, q{(x) }, q{ (x)})
{
    my ($recce, $p_events) = gather_events( $grammar2, {}, $input );
    my $actual_events = join q{ }, map { $_->[0], $_->[-1] } @{$p_events};
    my $expected_events = $input;
    $expected_events =~ s/[(] [x]+ [)]/bracketed 0/xms;
    $expected_events =~ s/\A \s /ws 0 /xms;
    $expected_events =~ s/\s \z/ ws 0/xms;
    Test::More::is( $actual_events, $expected_events,
        qq{Test of two discard types, input="$input"} );

    my $value_ref = $recce->old_value();
    die "No parse was found\n" if not defined $value_ref;

    my $result = ${$value_ref};
}

# Discards with a non-trivial grammar

my $non_trivial_grammar = Marpa::R3::Scanless::G->new(
    {   bless_package => 'My_Nodes',
        source        => \(<<'END_OF_SOURCE'),
:default ::= action => [g1start,g1length,name,values]
discard default = event => :symbol=off
lexeme default = action => [ g1start, g1length, start, length, value ]

text ::= a b c
a ~ 'a'
b ~ 'b'
c ~ 'c'
:discard ~ whitespace event => ws
whitespace ~ [\s]
END_OF_SOURCE
    }
);

for my $pattern (0 .. 15)
{
    # use binary numbers to generate all possible
    # space patterns
    my @spaces = split //xms, sprintf "%04b", $pattern;
    my @chars = qw{a b c};
    my @input = ();
    for my $i (0 .. 2) {
       push @input, ' ' if $spaces[$i];
       push @input, $chars[$i];
    }
    push @input, ' ' if $spaces[3];

    my @expected = ();
    for my $i (0 .. 3) {
        push @expected, "ws $i" if $spaces[$i];
    }

    # say join q{}, '^', @input, '$';
    my $input = join q{}, @input;

    my ($recce, $p_events) = gather_events( $non_trivial_grammar, {}, $input );
    my $actual_events = join q{ }, map { $_->[0], $_->[-1] } @{$p_events};
    my $expected_events = join q{ }, @expected;
    Test::More::is( $actual_events, $expected_events,
        qq{Test of non-trivial parse, input="$input"} );

    my $value_ref = $recce->old_value();
    die "No parse was found\n" if not defined $value_ref;

    my $result = ${$value_ref};
}

sub gather_events {
    my ( $grammar, $extra_recce_args, $input ) = @_;
    my @actual_events;
    my $recce = Marpa::R3::Scanless::R->new(
        {
            grammar        => $grammar,
            event_handlers => {
                "'default" => sub () {
                    my ( $slr, @event ) = @_;
                    push @actual_events, \@event;
                    'ok';
                }
              }

        },
        $extra_recce_args
    );
    my $length = length $input;
    my $pos    = $recce->read( \$input );
  READ: while ( $pos < $length ) {
        $pos = $recce->resume($pos);
    }
    return $recce, \@actual_events;
}

# vim: expandtab shiftwidth=4:
