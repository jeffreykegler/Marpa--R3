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

# This is the displays-focused version of the test of
# named lexeme events deactivation and reactivation

use 5.010001;
use strict;
use warnings;

use English qw( -no_match_vars );
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use Test::More tests => 2;
use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

my $base_rules = <<'END_OF_GRAMMAR';
:start ::= sequence
sequence ::= char* action => OK
char ::= a | b | c | d
a ~ 'a'
b ~ 'b'
c ~ 'c'
d ~ 'd'

# Marpa::R3::Display
# name: SLIF named lexeme event synopsis

:lexeme ~ <a> pause => before event => 'before a'
:lexeme ~ <b> pause => after event => 'after b'=on
:lexeme ~ <c> pause => before event => 'before c'=off
:lexeme ~ <d> pause => after event => 'after d'

# Marpa::R3::Display::End

END_OF_GRAMMAR

my $rules = $base_rules;
$rules =~ s/=off$//gxms;

# This test the order of events
# No more than one of each event type per line
# so that order is non-arbitrary
my $events_expected = <<'END_OF_EVENTS';
END_OF_EVENTS

my $grammar = Marpa::R3::Scanless::G->new(
    { semantics_package => 'My_Actions', source => \$rules } );

my $expected_events = <<'END_OF_EVENTS';
0 before a
1 before a
3 after b
4 after b
5 after b
5 before c
6 before c
7 before c
9 after d
9 before a
10 before a
11 before a
13 after b
13 before c
14 before c
16 after d
17 after d
18 after d
19 after d
19 before a
21 after b
21 before c
23 after d
END_OF_EVENTS

# Yet another time, with initializers
$expected_events =~ s/^\d+ \s after \s b \n//gxms;
$rules   = $base_rules;
$grammar = Marpa::R3::Scanless::G->new(
    {
        semantics_package => 'My_Actions',
        source            => \$rules
    }
);

# Marpa::R3::Display
# name: SLIF recce event_is_active named arg example

my $slr = Marpa::R3::Scanless::R->new(
    {
        grammar         => $grammar,
        event_is_active => { 'before c' => 1, 'after b' => 0 }
    }
);

# Marpa::R3::Display::End

state $string = q{aabbbcccdaaabccddddabcd};
state $length = length $string;
my $pos           = $slr->read( \$string );
my $actual_events = q{};
my $deactivated_event_name;
READ: while (1) {
    my @actual_events = ();
    my $event_name;
  EVENT:
    for my $event ( @{ $slr->events() } ) {
        my ($event_name) = @{$event};
        die "event name is undef" if not defined $event_name;
        die "Unexpected event: $event_name"
          if not $event_name =~ m/\A (before|after) \s [abcd] \z/xms;
        push @actual_events, $event_name;
    } ## end for my $event ( @{ $slr->events() } )
    if (@actual_events) {
        $actual_events .= join q{ }, $pos, sort @actual_events;
        $actual_events .= "\n";
        my ( $start_of_lexeme, $length_of_lexeme ) = $slr->pause_span();
        $pos = $start_of_lexeme + $length_of_lexeme;
    }
    last READ if $pos >= $length;
    $pos = $slr->resume($pos);
} ## end READ: while (1)
my $value_ref = $slr->value();
if ( not defined $value_ref ) {
    die "No parse\n";
}
my $actual_value = ${$value_ref};
Test::More::is( $actual_value, q{1792}, qq{Value} );
Marpa::R3::Test::is( $actual_events, $expected_events,
    qq{Events} );

sub My_Actions::OK { return 1792 }

# vim: expandtab shiftwidth=4:
