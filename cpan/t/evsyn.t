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

# Example for synopsis in POD for overview of parse events

use 5.010001;

use strict;
use warnings;

use Test::More tests => 2;
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use lib 'inc';
use Marpa::R3::Test;

## no critic (ErrorHandling::RequireCarping);

# Marpa::R3::Display
# name: Event synopsis

sub forty_two { return 42; };

use Marpa::R3;

my $dsl = <<'END_OF_DSL';

test ::= a b c d e e f g h action => main::forty_two
    | a ambig1 | a ambig2
e ::= <real e> | <null e>
<null e> ::=
g ::= g1 | g3
g1 ::= g2
g2 ::=
g3 ::= g4
g4 ::=
d ::= <real d> | <insert d>
ambig1 ::= start1 mid1 z
ambig2 ::= start2 mid2 z
start1 ::= b  mid1 ::= c d
start2 ::= b c  mid2 ::= d

a ~ 'a' b ~ 'b' c ~ 'c'
<real d> ~ 'd'
<insert d> ~ ["] 'insert d here' ["]
<real e> ~ 'e'
f ~ 'f'
h ~ 'h'
z ~ 'z'

:lexeme ~ <a> pause => after event => '"a"'
:lexeme ~ <b> pause => after event => '"b"'
:lexeme ~ <c> pause => after event => '"c"'
:lexeme ~ <real d> pause => after event => '"d"'
:lexeme ~ <insert d> pause => before event => 'insert d'
:lexeme ~ <real e> pause => after event => '"e"'
:lexeme ~ <f> pause => after event => '"f"'
:lexeme ~ <h> pause => after event => '"h"'

event '^test' = predicted test
event 'test$' = completed test
event '^start1' = predicted start1
event 'start1$' = completed start1
event '^start2' = predicted start2
event 'start2$' = completed start2
event '^mid1' = predicted mid1
event 'mid1$' = completed mid1
event '^mid2' = predicted mid2
event 'mid2$' = completed mid2

event '^a' = predicted a
event '^b' = predicted b
event '^c' = predicted c
event 'd[]' = nulled d
event 'd$' = completed d
event '^d' = predicted d
event '^e' = predicted e
event 'e[]' = nulled e
event 'e$' = completed e
event '^f' = predicted f
event 'g[]' = nulled g
event '^g' = predicted g
event 'g$' = completed g
event 'g1[]' = nulled g1
event 'g2[]' = nulled g2
event 'g3[]' = nulled g3
event 'g4[]' = nulled g4
event '^h' = predicted h

:discard ~ whitespace
whitespace ~ [\s]+
END_OF_DSL

my $grammar = Marpa::R3::Grammar->new(
    {
        source            => \$dsl,
        semantics_package => 'My_Actions'
    }
);

my @events = ();
my @event_history = ();
my $next_lexeme_length = undef;

my $slr = Marpa::R3::Scanless::R->new( { grammar => $grammar,
    event_handlers => {
        "'default" => sub () {
            my ($slr, $event_name, undef, undef, undef, $length) = @_;
            if ($event_name eq 'insert d') {
               $next_lexeme_length = $length;
            }
            push @events, $event_name;
            'pause';
        }
    }
} );

push @event_history, join q{ }, "Events at position 0:", sort @events
   if @events;
@events = ();

my $input = q{a b c "insert d here" e e f h};
my $length = length $input;
my $pos    = $slr->read( \$input );

READ: while (1) {

    push @event_history, join q{ }, "Events at position $pos:", sort @events
       if @events;
    @events = ();

    if (defined $next_lexeme_length) {
        $slr->lexeme_read_literal('real d', undef, undef, $next_lexeme_length);
        (undef, $pos) = $slr->block_progress();
        $next_lexeme_length = undef;
        next READ;
    }
    if ($pos < $length) {
        $pos = $slr->resume();
        next READ;
    }
    last READ;
} ## end READ: while (1)

my $expected_events = <<'=== EOS ===';
Events at position 0: ^a ^test
Events at position 1: "a" ^b ^start1 ^start2
Events at position 3: "b" ^c ^mid1 start1$
Events at position 5: "c" ^d ^mid2 start2$
Events at position 6: insert d
Events at position 21: ^e ^f d$ e[] mid1$ mid2$
Events at position 23: "e" ^e ^f e$ e[]
Events at position 25: "e" ^f e$
Events at position 27: "f" ^h g1[] g2[] g3[] g4[] g[]
Events at position 29: "h" test$
=== EOS ===

# Marpa::R3::Display::End

my $value_ref = $slr->value();
my $value = $value_ref ? ${$value_ref} : 'No Parse';

my $actual_events = join "\n", @event_history, '';
Marpa::R3::Test::is( $actual_events, $expected_events, 'parse event synopsis' );

Test::More::is( $value, 42, 'parse event synopsis value' );

1;    # In case used as "do" file

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
