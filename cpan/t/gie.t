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

# Tests requiring a grammar, an input and the expected events --
# no semantics required and output is not tested.

use 5.010001;

use strict;
use warnings;
use English qw( -no_match_vars );
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use Test::More tests => 8;

use lib 'inc';
use Marpa::R3::Test;

## no critic (ErrorHandling::RequireCarping);

use Marpa::R3;

my $DEBUG = 0;
my @tests_data = ();

# Location 0 events
# Bug found by Jean-Damien Durand

my $loc0_dsl = <<GRAMMAR_SOURCE;
:start ::= Script
Script ::= null1 null2 digits1 null3 null4 digits2 null5
digits1 ::= DIGITS
digits2 ::= DIGITS
null1   ::=
null2   ::=
null3   ::=
null4   ::=
null5   ::=
DIGITS ~ [\\d]+
WS ~ [\\s]
:discard ~ WS
GRAMMAR_SOURCE

foreach (
    qw/Script/,
    ( map {"digits$_"} ( 1 .. 2 ) ),
    ( map {"null$_"}   ( 1 .. 5 ) )
    )
{
    $loc0_dsl .= <<EVENTS;
event '${_}\$' = completed <$_>
event '^${_}' = predicted <$_>
event '${_}[]' = nulled <$_>
EVENTS
} ## end foreach ( qw/Script/, ( map {"digits$_"} ( 1 .. 2 ) ), ( ...))

my $loc0_input = '    1 2';
my $loc0_grammar = Marpa::R3::Grammar->new( { source  => \$loc0_dsl } );
my $loc0_events = <<'END_OF_EXPECTED_EVENTS';
0: ^Script ^digits1 null1[] null2[]
1: ^digits2 digits1$ null3[] null4[]
2: Script$ digits2$ null5[]
END_OF_EXPECTED_EVENTS

push @tests_data, [ $loc0_grammar, $loc0_input, $loc0_events, 'Location 0 events' ];

{
    my $reject_dup_dsl = <<'END_OF_DSL';
:start ::= Script

Script ::= 'x' DUP 'y'

_S      ~ [\s]
_S_MANY ~ _S+
_S_ANY  ~ _S*
:lexeme ~ <DUP> pause => after event => 'DUP$'
DUP  ~ _S_ANY _S
     | _S _S_ANY

:discard ~ _S_MANY
END_OF_DSL
    my $reject_dup_grammar =
        Marpa::R3::Grammar->new( { source => \$reject_dup_dsl } );
    my $reject_dup_input = " x y\n\n";
    my $reject_dup_events = '1: DUP$' . "\n";
    push @tests_data,
        [
        $reject_dup_grammar, $reject_dup_input,
        $reject_dup_events,  'Events for rejected duplicates'
        ];
}

{
    # Example for synopsis of discard events

# Marpa::R3::Display
# name: discard event statement synopsis 2

    my $dsl = <<'END_OF_DSL';
:start ::= Script

Script ::= numbers
numbers ::= number*
number ~ [\d]+

:discard ~ ws event => ws
ws ~ [\s]+
:discard ~ [,] event => comma=off
:discard ~ [;] event => 'semicolon'=on
:discard ~ [.] event => period

END_OF_DSL

# Marpa::R3::Display::End

    my $grammar =
        Marpa::R3::Grammar->new( { source => \$dsl } );
    my $input = "1,2; 3,42.  1729,8675309; 8675311,711.";
    my $events = <<'END_OF_EVENTS';
1: semicolon
2: ws
3: period
4: ws
5: semicolon
6: ws
7: period
END_OF_EVENTS

    push @tests_data,
        [
        $grammar, $input,
        $events,  'Discard events for synopsis'
        ];
}

for my $default (qw(on off))
{
    # Test of ':symbol' reserved event value

# Marpa::R3::Display
# name: default discard event statement synopsis 1

    my $dsl = <<'END_OF_DSL';
discard default = event => :symbol=on

Script ::= numbers
numbers ::= number*
number ~ [\d]+

:discard ~ ws
ws ~ [\s]+
:discard ~ [,] event => comma=off
:discard ~ semicolon
semicolon ~ [;]
:discard ~ period
period ~ [.]

END_OF_DSL

    $dsl =~ s/:symbol=on/:symbol=$default/xmsg;

# Marpa::R3::Display::End

    my $grammar = Marpa::R3::Grammar->new( { source => \$dsl } );
    my $input   = "1,2; 3,42.  1729,8675309; 8675311,711.";
    my $events  = q{};
    if ( $default eq 'on' ) {
        $events  = <<'END_OF_EVENTS';
1: semicolon
2: ws
3: period
4: ws
5: semicolon
6: ws
7: period
END_OF_EVENTS
    } ## end if ( $default eq 'on' )

    push @tests_data,
        [ $grammar, $input, $events,
            "Discard events for synopsis, default = $default" ];
}

{
    # Test of ':symbol' reserved event value
    # in discard pseudo-rules

    my $dsl = <<'END_OF_DSL';
Script ::= numbers
numbers ::= number*
number ~ [\d]+

:discard ~ ws event => :symbol
ws ~ [\s]+
:discard ~ [,] event => comma=off
:discard ~ semicolon event => :symbol=on
semicolon ~ [;]
:discard ~ period event => :symbol
period ~ [.]

END_OF_DSL

    my $grammar =
        Marpa::R3::Grammar->new( { source => \$dsl } );
    my $input = "1,2; 3,42.  1729,8675309; 8675311,711.";
    my $events  = <<'END_OF_EVENTS';
1: semicolon
2: ws
3: period
4: ws
5: semicolon
6: ws
7: period
END_OF_EVENTS

    push @tests_data,
        [
        $grammar, $input,
        $events,  'Discard events for synopsis'
        ];
}

{
    # Test of ':symbol' reserved event value
    # in discard pseudo-rules

    my $dsl = <<'END_OF_DSL';
Script ::= numbers
numbers ::= number*
number ~ [\d]+

:discard ~ ws event => :symbol
ws ~ [\s]+
:discard ~ [,] event => comma=off
:discard ~ [\x3B] event => :symbol=on
:discard ~ [.] event => :symbol

END_OF_DSL

    my $grammar =
        Marpa::R3::Grammar->new( { source => \$dsl } );
    my $input = "1,2; 3,42.  1729,8675309; 8675311,711.";
    my $events = <<'END_OF_EVENTS';
1: [\x3B]
2: ws
3: [.]
4: ws
5: [\x3B]
6: ws
7: [.]
END_OF_EVENTS

    push @tests_data,
        [
        $grammar, $input,
        $events,  'Discard events for synopsis'
        ];
}

{
    # Test of ':symbol' reserved event value
    # in discard default statement

# Marpa::R3::Display
# name: default discard event statement synopsis 2

    my $dsl = <<'END_OF_DSL';
discard default = event => :symbol
Script ::= numbers
numbers ::= number*
number ~ [\d]+

:discard ~ ws
ws ~ [\s]+
:discard ~ [,] event => comma=off
:discard ~ [\x3B]
:discard ~ [.]

END_OF_DSL

# Marpa::R3::Display::End

    my $grammar =
        Marpa::R3::Grammar->new( { source => \$dsl } );
    my $input = "1,2; 3,42.  1729,8675309; 8675311,711.";
    my $events = <<'END_OF_EVENTS';
1: [\x3B]
2: ws
3: [.]
4: ws
5: [\x3B]
6: ws
7: [.]
END_OF_EVENTS

    push @tests_data,
        [
        $grammar, $input,
        $events,  'Discard events for synopsis'
        ];
}

TEST:
for my $test_data (@tests_data) {
    my ( $grammar, $test_string, $expected_events, $test_name ) = @{$test_data};
    my @events        = ();
    my @event_history = ();
    my $recce         = Marpa::R3::Scanless::R->new(
        {
            grammar        => $grammar,
            event_handlers => {
                "'default" => sub () {
                    my ( $slr, $event_name ) = @_;
                    push @events, $event_name;
                    'pause';
                }
            }
        }
    );

    push @event_history, '0: ' .join q{ }, sort @events if @events;
    @events = ();
    my $pos    = -1;
    my $length = length $test_string;
    for ( my $pass = 1 ; $pos < $length ; $pass++ ) {
        my $eval_ok;
        if ($pass > 1) {
            $eval_ok = eval { $pos = $recce->resume(); 1 };
        }
        else {
            $eval_ok = eval { $pos = $recce->read( \$test_string ); 1 };
        }
        die $EVAL_ERROR if not $eval_ok;
        push @event_history, "$pass: " .join q{ }, sort @events
            if @events;
        @events = ();
    } ## end for ( my $pass = 0; $pos < $length; $pass++ )

    my $actual_events = join "\n", @event_history, '';
    # say "actual: $actual_events";
    # say "expected: $expected_events";
    Test::More::is( $actual_events, $expected_events, $test_name );
}

# vim: expandtab shiftwidth=4:
