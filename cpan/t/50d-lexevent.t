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
# use Test::More skip_all => 'NYI';
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
# name: named lexeme event synopsis

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

my $grammar = Marpa::R3::Grammar->new(
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
$grammar = Marpa::R3::Grammar->new(
    {
        semantics_package => 'My_Actions',
        source            => \$rules
    }
);

my @actual_events = ();
my $current_position;

my $before_handler = sub () {
   my ( $slr, $event_name, undef, undef, $start_of_lexeme, $length_of_lexeme ) = @_;
   $current_position = $start_of_lexeme + $length_of_lexeme;
   push @actual_events, "$start_of_lexeme $event_name";
   'pause';
};

my $after_handler = sub () {
   my ( $slr, $event_name, undef, undef, $start_of_lexeme, $length_of_lexeme ) = @_;
   $current_position = $start_of_lexeme + $length_of_lexeme;
   push @actual_events, "$current_position $event_name";
   'pause';
};

# Marpa::R3::Display
# name: recognizer event_is_active named arg synopsis

my $slr = Marpa::R3::Scanless::R->new(
    {
        grammar         => $grammar,
        event_is_active => { 'before c' => 1, 'after b' => 0 },
        event_handlers  => {
            'after a'  => $after_handler,
            'after b'  => $after_handler,
            'after c'  => $after_handler,
            'after d'  => $after_handler,
            'before a' => $before_handler,
            'before b' => $before_handler,
            'before c' => $before_handler,
            'before d' => $before_handler,
        }
    }
);

# Marpa::R3::Display::End

my $string = q{aabbbcccdaaabccddddabcd};
my $length = length $string;
$slr->read( \$string );

while ($current_position < $length) {
    $slr->resume($current_position);
}

my $actual_events .= join "\n", @actual_events, q{};

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
