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

# Test of scannerless parsing -- predicted, nulled and completed events
# which are initialized off in the DSL, and selectively reactivated

use 5.010001;

use strict;
use warnings;

use Test::More tests => 46;
use English qw( -no_match_vars );
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

my $rules = <<'END_OF_GRAMMAR';
:start ::= sequence
sequence ::= A B C D E F G  H I J K L
    action => OK
A ::= 'a'
B ::= 'b'
C ::= 'c'
D ::= 'd'
E ::=
F ::= 'f'
G ::=
H ::= 'h'
I ::= 'i'
J ::= 'j'
K ::=
L ::= 'l'

event '^a'=off = predicted A
event '^b'=off = predicted B
event '^c'=off = predicted C
event '^d'=off = predicted D
event '^e'=off = predicted E
event '^f'=off = predicted F
event '^g'=off = predicted G
event '^h'=off = predicted H
event '^i'=off = predicted I
event '^j'=off = predicted J
event '^k'=off = predicted K
event '^l'=off = predicted L
event 'a'=off = completed A
event 'b'=off = completed B
event 'c'=off = completed C
event 'd'=off = completed D
event 'e'=off = completed E
event 'f'=off = completed F
event 'g'=off = completed G
event 'h'=off = completed H
event 'i'=off = completed I
event 'j'=off = completed J
event 'k'=off = completed K
event 'l'=off = completed L
event 'a[]'=off = nulled A
event 'b[]'=off = nulled B
event 'c[]'=off = nulled C
event 'd[]'=off = nulled D
event 'e[]'=off = nulled E
event 'f[]'=off = nulled F
event 'g[]'=off = nulled G
event 'h[]'=off = nulled H
event 'i[]'=off = nulled I
event 'j[]'=off = nulled J
event 'k[]'=off = nulled K
event 'l[]'=off = nulled L
END_OF_GRAMMAR

# This test the order of events
# No more than one of each event type per line
# so that order is non-arbitrary
my $all_events_expected = <<'END_OF_EVENTS';
0 ^a
1 ^b a
2 ^c b
3 ^d c
4 ^f d e[]
5 ^h f g[]
6 ^i h
7 ^j i
8 ^l j k[]
9 l
END_OF_EVENTS

my %pos_by_event = ();
my @events;
for my $event_line  (split /\n/xms, $all_events_expected)
{
    my ($pos, @pos_events) = split " ", $event_line;
    $pos_by_event{$_} = $pos for @pos_events;
    push @events, @pos_events;
}

my $grammar = Marpa::R3::Grammar->new(
    { semantics_package => 'My_Actions', source => \$rules } );

# Test of all events
my %active_events = map { ( $_, 1 ) } @events;
do_test( "all events activated", $grammar, q{abcdfhijl}, $all_events_expected, \%active_events );

# Now deactivate all events
do_test( "no events activated", $grammar, q{abcdfhijl}, q{}, );

# Now deactivate all events, and turn them back on, one at a time
EVENT: for my $event (@events) {
    my $expected_events = $pos_by_event{$event} . " $event\n";
    do_test( qq{event "$event" reactivated},
        $grammar, q{abcdfhijl}, $expected_events,
        { $event => 1 } );
} ## end EVENT: for my $event (@events)

sub do_test {
    my ( $test, $slg, $string, $expected_events, $active_events ) = @_;
    my $extra_recce_args = {};
    $extra_recce_args = { event_is_active => $active_events }
        if defined $active_events;

    my @actual_events = ();
    my $recce =
      Marpa::R3::Scanless::R->new( { grammar => $grammar,
          event_handlers => {
              "'default" => sub () {
                  my ($slr, $event_name) = @_;
                  my (undef, $pos) = $slr->block_progress();
                  $pos //= 0;
                  $actual_events[$pos]{$event_name} = 1;
                  'ok';
              }
          }
      }, $extra_recce_args );

    my $length = length $string;
    my $pos    = $recce->read( \$string );
    while ( $pos < $length ) {
        $pos = $recce->resume($pos);
    }

    my $value_ref = $recce->value();
    if ( not defined $value_ref ) {
        die "No parse\n";
    }
    my $actual_value = ${$value_ref};
    Test::More::is( $actual_value, q{1792}, qq{Value for $test} );

    my @events_by_pos = ();
    for (my $ix = 0; $ix <= $#events; $ix++) {
        my @these_events = keys %{$actual_events[$ix]};
        push @events_by_pos, "$ix " . join q{ }, sort @these_events
           if @these_events;
    }
    my $actual_events = join "\n", @events_by_pos, q{};

    Marpa::R3::Test::is( $actual_events, $expected_events,
        qq{Events for $test} );
} ## end sub do_test

sub My_Actions::OK { return 1792 };

# vim: expandtab shiftwidth=4:
