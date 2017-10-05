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

use Test::More tests => 9;

use lib 'inc';
use Marpa::R3::Test;

## no critic (ErrorHandling::RequireCarping);

## Basic

use Marpa::R3;

# Marpa::R3::Display
# name: event examples; grammar 1

my $dsl1 = <<'END_OF_DSL';
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

my $grammar1 = Marpa::R3::Scanless::G->new( { source => \$dsl1 } );

# Marpa::R3::Display::End

my @results = ();
my $recce;

# Marpa::R3::Display
# name: event examples - basic

@results = ();
$recce   = Marpa::R3::Scanless::R->new(
    {
        grammar        => $grammar1,
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
# name: event examples - default

@results = ();
$recce = Marpa::R3::Scanless::R->new(
    {
        grammar        => $grammar1,
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
# name: event examples - default and explicit

@results = ();
$recce = Marpa::R3::Scanless::R->new(
    {
        grammar        => $grammar1,
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
# name: event examples - rejected and exhausted

my $dsl2 = <<'END_OF_DSL';
        top ::= A B C
        A ::= 'a'
        B ::= 'b'
        C ::= 'c'
        :discard ~ ws
        ws ~ [\s]+
END_OF_DSL

my $grammar2 = Marpa::R3::Scanless::G->new(
    {
        source => \$dsl2,
        rejection => 'event',
        exhaustion => 'event',
    },
);

@results = ();
$recce = Marpa::R3::Scanless::R->new(
    {
        grammar        => $grammar2,
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
# name: event examples - event with data

my $dsl3 = <<'END_OF_DSL';
        top ::= A B C
        A ~ 'a' B ~ 'b' C ~ 'c'
        :lexeme ~ <A> pause => after event => 'A'
        :lexeme ~ <B> pause => after event => 'B'
        :lexeme ~ <C> pause => after event => 'C'
        :discard ~ ws
        ws ~ [\s]+
END_OF_DSL

my $grammar3 = Marpa::R3::Scanless::G->new(
    {
        source => \$dsl3,
        rejection => 'event',
        exhaustion => 'event',
    },
);

@results = ();
$recce = Marpa::R3::Scanless::R->new(
    {
        grammar        => $grammar3,
        event_handlers => {
            "'default" => sub () {
                my ( $slr, $event_name, $symid, $block_ix, $start, $length ) = @_;
                my $symbol_name = $grammar3->symbol_name($symid);
                push @results,
                    "event $event_name for symbol $symbol_name; block $block_ix, location $start, length=$length";
                'ok';
            },
        }
    }
);

# Marpa::R3::Display::End

$recce->read( \"a b c" );
Test::More::is( ( join qq{\n}, @results, q{} ), <<'END_OF_EXPECTED', 'event with data' );
event A for symbol A; block 1, location 0, length=1
event B for symbol B; block 1, location 2, length=1
event C for symbol C; block 1, location 4, length=1
END_OF_EXPECTED

## Data using factory

# Marpa::R3::Display
# name: event examples - data, using factory

@results = ();
my $A_global = 'A';

sub factory {
    my ($local_arg) = @_;
    my $B_non_local = 'B';
    return sub () {
       my ($slr, $event_name) = @_;
       my $result;
       $result = $A_global if $event_name eq 'A';
       $result = $B_non_local if $event_name eq 'B';
       $result = $local_arg if $event_name eq 'C';
       push @results, $result;
       'ok';
    }
}


sub example_closure {
    my $C_local = 'C';
    return Marpa::R3::Scanless::R->new(
        {
            grammar        => $grammar1,
            event_handlers => {
                "'default" => factory($C_local),
            }
        }
    );
}

# Marpa::R3::Display::End

$recce = example_closure();
$recce->read( \"a b c" );
Test::More::is( ( join q{ }, @results ), 'A B C', 'data, using factory' );

## Per-location processing, using pause

# Marpa::R3::Display
# name: event examples - per-location using pause

my $dsl4 = <<'END_OF_DSL';
        top ::= A B C
        A ::= 'a' B ::= 'b' C ::= 'c'
        event '^A' = predicted A
        event 'A$' = completed A
        event '^B' = predicted B
        event 'B$' = completed B
        event '^C' = predicted C
        event 'C$' = completed C
        :discard ~ ws
        ws ~ [\s]+
END_OF_DSL

my $grammar4 = Marpa::R3::Scanless::G->new(
    {
        source => \$dsl4,
    },
);

@results = ();
$recce = Marpa::R3::Scanless::R->new(
    {
        grammar        => $grammar4,
        event_handlers => {
            "'default" => sub () {
                my ( $slr, $event_name ) = @_;
                push @results, $event_name;
                'pause';
            },
        }
    }
);

# Marpa::R3::Display::End

    my $expected_history = <<'END_OF_TEXT';
0 ^A
1 A$ ^B
3 B$ ^C
5 C$
END_OF_TEXT

{
    my $pos           = 0;
    my $input         = 'a b c';
    my @event_history = ( join q{ }, $pos, sort @results )
      if @results;
    @results = ();
    $pos     = $recce->read( \$input );
    push @event_history, join q{ }, $pos, sort @results
      if @results;
    @results = ();
    while ( $pos < length $input ) {
        $pos = $recce->resume();
        push @event_history, join q{ }, $pos, sort @results
          if @results;
        @results = ();
    } ## end READ: while (1)
    my $event_history = join "\n", @event_history, '';
    Marpa::R3::Test::is( $event_history, $expected_history,
        'per-location, using pause' );
}

## Per-location processing, using AoA
# Marpa::R3::Display
# name: event examples - per-location processing, using AoA

@results = ();
$recce = Marpa::R3::Scanless::R->new(
    {
        grammar        => $grammar4,
        event_handlers => {
            "'default" => sub () {
                my ( $slr, @event_data ) = @_;
                my (undef, $pos) = $slr->block_progress();
                $pos //= 0;
                push @{$results[$pos]}, \@event_data;
                'ok';
            },
        }
    }
);

# Marpa::R3::Display::End

{
    my $input         = 'a b c';
    $recce->read( \$input );
    my @events_by_pos = ();
    for (my $ix = 0; $ix <= $#results; $ix++) {
        my $these_events = $results[$ix];
        if ($these_events) {
            my @event_names = sort map { $_->[0] } @{$these_events};
            push @events_by_pos, "$ix " . join q{ }, @event_names;
       }
    }
    my $actual_history = join "\n", @events_by_pos, q{};

    Marpa::R3::Test::is( $actual_history, $expected_history,
        'per-location, using array');
}

# vim: expandtab shiftwidth=4:
