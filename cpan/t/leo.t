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

# The example from p. 166 of Leo's paper,
# augmented to test Leo prediction items.

use 5.010001;
use strict;
use warnings;
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use Test::More tests => 2;

use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

## no critic (Subroutines::RequireArgUnpacking)

sub main::default_action {
    my (undef, $values) = @_;
    return ( join q{}, grep {defined} @{$values} );
}

## use critic

my $grammar = Marpa::R3::Scanless::G->new(
    { 
        source => \(<<'END_OF_DSL'),
:default ::= action => main::default_action
:start ::= S
S ::= 'a' A
A ::= B
B ::= C
C ::= S
S ::=
event A = completed <A>
event C = completed <C>
event S = completed <S>
event 'A[]' = nulled <A>
event 'C[]' = nulled <C>
event 'S[]' = nulled <S>
END_OF_DSL
    }
);

my %events;
my $common_handler = sub () {
    my ($slr, $event_name) = @_;
    $events{$event_name} = 1;
    'pause';
};

my $recce = Marpa::R3::Scanless::R->new(
    {
        grammar => $grammar,
        event_handlers => {
            A     => $common_handler,
            C     => $common_handler,
            S     => $common_handler,
            'A[]' => $common_handler,
            'C[]' => $common_handler,
            'S[]' => $common_handler,
        }
    },
);

my $pos           = 0;
my $input         = 'aaa';
my @event_history = (join q{ }, $pos, sort keys %events);
$pos           = $recce->read( \$input );
READ: while (1) {
    push @event_history, join q{ }, $pos, sort keys %events;
    last READ if $pos >= length $input;
    $pos = $recce->resume();
} ## end READ: while (1)
my $value_ref = $recce->value();
my $value = $value_ref ? ${$value_ref} : 'No parse';
Marpa::R3::Test::is( $value,         'aaa',           'Leo SLIF parse' );
my $event_history = join "\n", @event_history, '';
Marpa::R3::Test::is( $event_history, <<'END_OF_TEXT', 'Event history' );
0 S[]
1 A[] C[] S S[]
2 A A[] C C[] S S[]
3 A A[] C C[] S S[]
END_OF_TEXT

# vim: expandtab shiftwidth=4:
