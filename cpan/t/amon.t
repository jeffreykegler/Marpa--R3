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

# Bug found by amon: duplicate events when mixing external
# and internal scanning.

use 5.010001;
use strict;
use warnings;
use English qw( -no_match_vars );
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use Test::More tests => 2;

use lib 'inc';
use Marpa::R3::Test;

## no critic (ErrorHandling::RequireCarping);

use Marpa::R3;

my $g = Marpa::R3::Scanless::G->new({
    source => \q{
        Top::= 'start' TOKEN OTHER_TOKEN
        TOKEN       ~ [^\s\S]
        OTHER_TOKEN ~ [^\s\S]
        event ev_token          = predicted TOKEN
        event ev_other_token    = predicted OTHER_TOKEN
        :discard ~ [_]
    },
});
my $r = Marpa::R3::Scanless::R->new({ grammar => $g });

# This is the "control" -- a test before where the bug
# occurred, just to make sure the context is right.
$r->read(\"start_");
{
    my @events = map { $_->[0] } @{ $r->events };
    Test::More::is( (join q{ }, @events), q{ev_token}, 'before' );
}

# Now look where the bug occurred.
# The problem was that the "ev_token" from the previous
# check for events was not cleared.
$r->lexeme_read(TOKEN => 0, 1, "_");
{
    my @events = map { $_->[0] } @{ $r->events };
    # ev_token should NOT be reported here.
    Test::More::is( (join q{ }, @events), q{ev_other_token}, 'after' );
}

# vim: expandtab shiftwidth=4:
