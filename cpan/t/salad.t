#!/usr/bin/env perl
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

# This example searches for recursively nested braces --
# curly, square and round -- in a "salad" of other things.
# It's to show general BNF search -- sort of a grep or an ack,
# but for general BNF, instead of regexes.  The term
# "salad" I picked up from Michael Roberts, to suggest
# that the targets occur in a sort of "lexeme salad".
# In the literature, this is called a supersequence
# search.

use 5.010001;

use strict;
use warnings;
use Data::Dumper;
use Getopt::Long ();
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use Test::More tests => 3;
use Marpa::R3;

my $verbose;
die if not Getopt::Long::GetOptions( verbose => \$verbose );

my $dsl = << '=== GRAMMAR ===';
lexeme default = action => [ name, value ] # to add token names to ast

<prefixed target> ::= prefix target
prefix ::= <prefix lexeme>*

target ::= balanced
event target = completed target

balanced ::= 
    lparen contents rparen
  | lcurly contents rcurly
  | lsquare contents rsquare

contents ::= <content item>*
<content item> ::= balanced | filler

<prefix lexeme> ~ <deep filler>
filler ~ <deep filler>
# x5b is left square bracket
# x5d is right square bracket
<deep filler> ~ [^(){}\x5B\x5D]+

<prefix lexeme> ~ <deep lparen>
lparen ~ <deep lparen>
<deep lparen> ~ '('

<prefix lexeme> ~ <deep rparen>
rparen ~ <deep rparen>
<deep rparen> ~ ')'

<prefix lexeme> ~ <deep lcurly>
lcurly ~ <deep lcurly>
<deep lcurly> ~ '{'

<prefix lexeme> ~ <deep rcurly>
rcurly ~ <deep rcurly>
<deep rcurly> ~ '}'

<prefix lexeme> ~ <deep lsquare>
lsquare ~ <deep lsquare>
<deep lsquare> ~ '['

<prefix lexeme> ~ <deep rsquare>
rsquare ~ <deep rsquare>
<deep rsquare> ~ ']'

=== GRAMMAR ===

# Marpa::R3::Display
# name: SLIF exhaustion grammar setting synopsis part 1

    my $g = Marpa::R3::Scanless::G->new(
        {
            source     => \$dsl,
            exhaustion => 'event',
            rejection  => 'event',
        }
    );

# Marpa::R3::Display::End

my @tests = (
    [ 'z}ab)({[]})))(([]))zz', ( join "\n", '({[]})', '(([]))', '' ) ],
    [   '9\090]{[][][9]89]8[][]90]{[]\{}{}09[]}[',
        join "\n", '[]', '[]', '[9]', '[]', '[]', '{[]\{}{}09[]}', ''
    ],
    [ '([]([])([]([]', join "\n", '[]', '([])', '[]', '[]', '' ],
);

for my $test (@tests) {
    my ( $string, $expected_result ) = @{$test};
    my $actual_result = test( $g, $string );
    diag("Input: $string") if $verbose;
    Test::More::is( $actual_result, $expected_result,
        qq{Result of "$string"} );
} ## end for my $test (@tests)

sub test {
    my ($g, $string) = @_;
    my @found = ();
    diag( "Input: $string" ) if $verbose;
    my $input_length = length $string;
    my $target_start = 0;

    # my $recce_debug_args = { trace_terminals => 1, trace_values => 1 };
    state $recce_debug_args = {};

    # One pass through this loop for every target found,
    # until we reach end of string without finding a target

    TARGET: while ( $target_start < $input_length ) {

        # PHASE 1

        # First we find the "shortest span" -- the one which ends earliest.
        # This tells us where the prefix should end.
        # No prefix should go beyond the first location of the shortest span.

# Marpa::R3::Display
# name: SLIF exhaustion grammar setting synopsis part 2

        my @shortest_span = ();

        my %event_handlers1 = (
              'target' => sub {
                   my ($slr) = @_;
                   my $pos = $slr->pos();
                   @shortest_span = $slr->last_completed('target');
                   diag(
                       "Preliminary target at $pos: ",
                       $slr->g1_literal(@shortest_span)
                   ) if $verbose;
                  return 'pause';
              },
              q{'exhausted} => sub {
                  return 'pause';
              }
        );

        my $recce =
          Marpa::R3::Scanless::R->new( { grammar => $g,
              event_handlers => \%event_handlers1,
          }, $recce_debug_args );
        my $pos = $recce->read( \$string, $target_start );

# Marpa::R3::Display::End

        last TARGET if not scalar @shortest_span;

        # PHASE 2

        # We now have found the longest allowed prefix.
        # Our "longest match" will begin at the end of this prefix,
        # or before it.

        # We just run until exhausted, the  look for the last
        # completed <target>.  This will be our longest match.

        diag( join q{ }, @shortest_span ) if $verbose;
        my (undef, $prefix_end) = $recce->g1_to_l0_first($shortest_span[0]);

        my %event_handlers2 = (
              q{'exhausted} => sub {
                  return 'pause';
              },
              q{'rejected} => sub {
                  return 'pause';
              }
        );

        $recce = Marpa::R3::Scanless::R->new(
            {   grammar    => $g,
              event_handlers => \%event_handlers2,
            },
            $recce_debug_args
        );
        $recce->activate( 'target', 0 );
        $recce->read( \$string, $target_start, $prefix_end - $target_start );

# Marpa::R3::Display
# name: SLIF recognizer lexeme_priority_set() synopsis

        $recce->lexeme_priority_set( 'prefix lexeme', -1 );

# Marpa::R3::Display::End

        $pos = $recce->resume($prefix_end);

        my @longest_span = $recce->last_completed('target');
        diag( "Actual target at $pos: ", $recce->g1_literal(@longest_span) ) if $verbose;

        last TARGET if not scalar @longest_span;
        push @found, $recce->g1_literal(@longest_span);
        diag( "Found target at $pos: ", $recce->g1_literal(@longest_span) ) if $verbose;

        # Move the search location forward,
        # in preparation for looking for the next target

        ( undef, $target_start ) = $recce->g1_to_l0_last(
             $longest_span[0] + $longest_span[1] - 1);
         $target_start += 1;

    } ## end TARGET: while ( $target_start < $input_length )
    return join "\n", @found, q{};
} ## end sub test

# vim: expandtab shiftwidth=4:
