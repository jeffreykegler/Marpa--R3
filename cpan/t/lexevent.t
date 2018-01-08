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

# Note: SLIF TEST

# Test of scannerless parsing -- named lexeme events
# deactivation and reactivation

use 5.010001;

use strict;
use warnings;

use English qw( -no_match_vars );
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use Test::More tests => 10;
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

:lexeme ~ <a> pause => before event => 'before a'
:lexeme ~ <b> pause => after event => 'after b'=on
:lexeme ~ <c> pause => before event => 'before c'=off
:lexeme ~ <d> pause => after event => 'after d'

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

my %base_expected_events;
$base_expected_events{'all'} = <<'END_OF_EVENTS';
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
$base_expected_events{'once'} = <<'END_OF_EVENTS';
0 before a
3 after b
5 before c
9 after d
END_OF_EVENTS
$base_expected_events{'seq'} = <<'END_OF_EVENTS';
0 before a
3 after b
5 before c
9 after d
9 before a
13 after b
13 before c
16 after d
19 before a
21 after b
21 before c
23 after d
END_OF_EVENTS

my %expected_events = %base_expected_events;

sub do_test {
    my ( $test, $grammar, $extra_args ) = @_;
    $extra_args //= {};
    state $string = q{aabbbcccdaaabccddddabcd};
    state $length = length $string;
    my @actual_events = ();
    my $current_position = 0;

    my $deactivated_event_name;
    my $do_activations = sub () {;};
    if ( $test eq 'once' ) {
        $do_activations = sub () {
            my ($slr, $event_name) = @_;
            $slr->activate( $event_name, 0 );
          };
    }
    if ( $test eq 'seq' ) {
        $do_activations = sub () {
            my ($slr, $event_name) = @_;
            $slr->activate( $deactivated_event_name, 1 )
              if defined $deactivated_event_name;
            $slr->activate( $event_name, 0 );
            $deactivated_event_name = $event_name;
          };
    }

    my $before_handler = sub () {
        my ( $slr, $event_name, undef, undef, $start_of_lexeme, $length_of_lexeme ) = @_;
        $do_activations->($slr, $event_name);
        $current_position = $start_of_lexeme + $length_of_lexeme;
        push @actual_events, "$start_of_lexeme $event_name";
        'pause';
    };

    my $after_handler = sub () {
       my ( $slr, $event_name, undef, undef, $start_of_lexeme, $length_of_lexeme ) = @_;
       $do_activations->($slr, $event_name);
       $current_position = $start_of_lexeme + $length_of_lexeme;
       push @actual_events, "$current_position $event_name";
       'pause';
    };

    my $slr =
      Marpa::R3::Recognizer->new( { grammar => $grammar }, $extra_args,
        { event_handlers  => {
            'after a'  => $after_handler,
            'after b'  => $after_handler,
            'after c'  => $after_handler,
            'after d'  => $after_handler,
            'before a' => $before_handler,
            'before b' => $before_handler,
            'before c' => $before_handler,
            'before d' => $before_handler,
        } }
      );

    my $retour = $slr->read( \$string );
    $current_position = $retour if $retour > $current_position;
    while ( $current_position < $length ) {
        $retour = $slr->resume($current_position);
        $current_position = $retour if $retour > $current_position;
    }
    my $value_ref = $slr->value();
    if ( not defined $value_ref ) {
        die "No parse\n";
    }
    my $actual_events .= join qq{\n}, @actual_events, '';
    my $actual_value = ${$value_ref};
    Test::More::is( $actual_value, q{1792}, qq{Value for test "$test"} );
    my $expected_events = q{};
    Marpa::R3::Test::is( $actual_events, $expected_events{$test},
        qq{Events for test "$test"} );
} ## end sub do_test

do_test( 'all', $grammar );
do_test( 'once', $grammar );
do_test( 'seq', $grammar);

# Yet another time, with initializers
%expected_events = %base_expected_events;
$expected_events{'all'} =~ s/^\d+ \s before \s c \n//gxms;
$rules   = $base_rules;
$grammar = Marpa::R3::Grammar->new(
    {
        semantics_package => 'My_Actions',
        source            => \$rules
    }
);
do_test( 'all', $grammar );

# Yet another time, with initializers
%expected_events = %base_expected_events;
$expected_events{'all'} =~ s/^\d+ \s after \s b \n//gxms;
$rules   = $base_rules;
$grammar = Marpa::R3::Grammar->new(
    {
        semantics_package => 'My_Actions',
        source            => \$rules
    }
);
do_test('all', $grammar,
    { event_is_active => { 'before c' => 1, 'after b' => 0 } }
);

sub My_Actions::OK { return 1792 }

# vim: expandtab shiftwidth=4:
