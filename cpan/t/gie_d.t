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

# A display-focused test.
# Examples of event handler usage

use 5.010001;
use strict;
use warnings;
use English qw( -no_match_vars );
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use Test::More tests => 1;

use lib 'inc';
use Marpa::R3::Test;

## no critic (ErrorHandling::RequireCarping);

## Basic

use Marpa::R3;

# Marpa::R3::Display
# name: event examples: grammar 1

my $dsl = <<'END_OF_DSL';
    top ::= A B C
    A ::= 'a'
    B ::= 'b'
    C ::= 'c'
    event A = completed A
    event B = completed B
    event C = completed C
    :discard ~ ws
    ws ~ [\s]+
END_OF_DSL

my $g = Marpa::R3::Scanless::G->new( { source => \$dsl } );

# Marpa::R3::Display::End

my @results = ();
my $recce;

# Marpa::R3::Display
# name: event examples: basic

@results = ();
$recce   = Marpa::R3::Scanless::R->new(
    {
        grammar        => $g,
        event_handlers => {
            A => sub () { push @results, 'A'; 'ok' },
            B => sub () { push @results, 'B'; 'ok' },
            C => sub () { push @results, 'C'; 'ok' },
        }
    }
);

# Marpa::R3::Display::End

$recce->read( \"a b c" );
Test::More::is( ( join q{ }, @results ), 'A B C', 'example 1' );

# Marpa::R3::Display
# name: event examples: default

@results = ();
$recce = Marpa::R3::Scanless::R->new(
    {
        grammar        => $g,
        event_handlers => {
            "'default" => sub () {
                my ( $slr, $event_name ) = @_;
                push @results, $event_name;
                'ok';
            },
        }
    }
);

# Marpa::R3::Display::End

$recce->read( \"a b c" );
Test::More::is( ( join q{ }, @results ), 'A B C', 'example 1' );

# Marpa::R3::Display
# name: event examples: default and explicit

@results = ();
$recce = Marpa::R3::Scanless::R->new(
    {
        grammar        => $g,
        event_handlers => {
            A => sub () { push @results, 'A'; 'ok' },
            "'default" => sub () {
                my ( $slr, $event_name ) = @_;
                push @results, "!A=$event_name";
                'ok';
            },
        }
    }
);

# Marpa::R3::Display::End

$recce->read( \"a b c" );
Test::More::is( ( join q{ }, @results ), 'A !A=B !A=C', 'example 1' );

sub make_recce() {

# Marpa::R3::Display
# name: event examples: rejected and exhausted

my $dsl = <<'END_OF_DSL';
        top ::= A B C
        A ::= 'a'
        B ::= 'b'
        C ::= 'c'
        :discard ~ ws
        ws ~ [\s]+
END_OF_DSL

my $g = Marpa::R3::Scanless::G->new(
    {
        source => \$dsl,
        rejection => 'event',
        exhaustion => 'event',
    },
);

@results = ();
$recce = Marpa::R3::Scanless::R->new(
    {
        grammar        => $g,
        event_handlers => {
            "'rejected" => sub () { @results = ('rejected'); 'pause' },
            "'exhausted" => sub () { @results = ('exhausted'); 'pause' },
        }
    }
);

# Marpa::R3::Display::End

   return $recce, \@results;
}

($recce, @results) = make_recce();
$recce->read( \"a a a" );
Test::More::is( ( join q{ }, @results ), 'rejected', 'rejected' );
($recce, @results) = make_recce();
$recce->read( \"a b c a" );
Test::More::is( ( join q{ }, @results ), 'exhausted', 'exhausted' );

# Marpa::R3::Display
# name: event examples: event with data

$dsl = <<'END_OF_DSL';
        top ::= A B C
        A ~ 'a' B ~ 'b' C ~ 'c'
        :lexeme ~ <A> pause => after event => 'A'
        :lexeme ~ <B> pause => after event => 'B'
        :lexeme ~ <C> pause => after event => 'C'
        :discard ~ ws
        ws ~ [\s]+
END_OF_DSL

$g = Marpa::R3::Scanless::G->new(
    {
        source => \$dsl,
        rejection => 'event',
        exhaustion => 'event',
    },
);

@results = ();
$recce = Marpa::R3::Scanless::R->new(
    {
        grammar        => $g,
        event_handlers => {
            "'default" => sub () {
                my ( $slr, $event_name, $symid, $start, $length ) = @_;
                my $symbol_name = $g->symbol_name($symid);
                push @results,
                    "event $event_name for symbol $symbol_name at location $start, length=$length";
                'ok';
            },
        }
    }
);

# Marpa::R3::Display::End

$recce->read( \"a b c" );
Test::More::is( ( join qq{\n}, @results, q{} ), <<'END_OF_EXPECTED', 'event with data' );
event A for symbol A at location 0, length=1
event B for symbol B at location 2, length=1
event C for symbol C at location 4, length=1
END_OF_EXPECTED

## Data using factory

## Per-location processing, using pause

## Per-location processing, using array

# vim: expandtab shiftwidth=4:
