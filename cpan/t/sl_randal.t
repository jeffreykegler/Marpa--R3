#!/usr/bin/perl
# Copyright 2016 Jeffrey Kegler
# This file is part of Marpa::R3.  Marpa::R3 is free software: you can
# redistribute it and/or modify it under the terms of the GNU Lesser
# General Public License as published by the Free Software Foundation,
# either version 3 of the License, or (at your option) any later version.
#
# Marpa::R3 is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser
# General Public License along with Marpa::R3.  If not, see
# http://www.gnu.org/licenses/.

# CENSUS: REWORK
# Note: Rewrite this as sl_randal.t ...
# Note: then mark this for deletion.

use 5.010001;
use strict;
use warnings;
use English qw( -no_match_vars );

use Test::More tests => 6;
use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

package Test_Grammar;

# This grammar is from Data::Dumper,
# which disagrees with Perl::Critic about proper
# use of quotes and with perltidy about
# formatting

#<<< no perltidy
##no critic (ValuesAndExpressions::ProhibitNoisyQuotes)

$Test_Grammar::MARPA_OPTIONS = [
    {
    	source => \<<'END_OF_DSL',
:default ::= action => ::undef,
:start ::= <perl line>
<comment optional> ::= comment action => comment
<comment optional> ::=

<perl line> ::= <perl statements> <comment optional>
	action => show_perl_line

<perl statements> ::= <perl statement>+ separator => semicolon
	action => show_statement_sequence

<perl statement> ::= division action => show_division
<perl statement> ::= <function call> action => show_function_call
<perl statement> ::= <die k0> <string literal> action => show_die

division ::= expr <division sign> expr

expr ::= <function call>
expr ::= number

<function call> ::= <unary function name> argument action => show_unary

<function call> ::= <nullary function name> action => show_nullary

argument ::= <pattern match>

<die k0> ~ 'die'
event 'die k0' = predicted <die k0>

<unary function name> ~ 'caller' | 'eof' | 'sin' | 'localtime'
event 'unary function name' = predicted <unary function name>

<nullary function name> ~ 'caller' | 'eof' | 'sin' | 'time' | 'localtime'
event 'nullary function name' = predicted <nullary function name>

<number> ~ [\d]+
event 'number' = predicted <number>

<semicolon> ~ ';'
event 'semicolon' = predicted <semicolon>

<division sign> ~ [/]
event 'division sign' = predicted <division sign>

<pattern match> ~ [/] <pattern match chars> [/]
<pattern match chars> ~ [^/]*
event 'pattern match' = predicted <pattern match>

<comment> ~ [#] <comment chars>
<comment chars> ~ [.]*
event 'comment' = predicted <comment>

<string literal> ~ '"' <string literal chars> '"'
<string literal chars> ~ [^"]* #"
event 'string literal' = predicted <string literal>

whitespace ~ [\s]
:discard ~ whitespace

END_OF_DSL
    }
  ];

# not really needed, but preserved from randal.t just in case,
# like probably unneeded critic/perltidy comments above and below
my %regexes = (
    'die:k0'                => 'die',
    'unary-function-name'   => '(caller|eof|sin|localtime)',
    'nullary-function-name' => '(caller|eof|sin|time|localtime)',
    'number'                => '\\d+',
    'semicolon'             => ';',
    'division-sign'         => '[/]',
    'pattern-match'         => '[/][^/]*/',
    'comment'               => '[#].*',
    'string-literal'        => '"[^"]*"',
);

## use critic
#>>>
#

package main;

my @test_data = (
    [   'sin',
        q{sin  / 25 ; # / ; die "this dies!"},
        [ 'sin function call, die statement', 'division, comment' ]
    ],
    [ 'time', q{time  / 25 ; # / ; die "this dies!"}, ['division, comment'] ]
);

my $g = Marpa::R3::Scanless::G->new(
    @{$Test_Grammar::MARPA_OPTIONS}
);

TEST: for my $test_data (@test_data) {

    my ( $test_name, $test_input, $test_results ) = @{$test_data};

    my $recce = Marpa::R3::Scanless::R->new(
    	{ grammar => $g, semantics_package => 'main' }
    );

    my $input_length = length $test_input;
    pos $test_input = 0;
    my $terminals_expected_matches_events = 1;

	INPUT: for(
	  my $pos = $recce->read( \$test_input );
	  $pos < length($test_input);
	  $pos = $recce->resume($pos)
	) {
      my @expected_symbols = map { @$_ } @{ $recce->events() };
      my $terminals_expected = $recce->terminals_expected();
	  EVENTS: {
		for my $event (@{ $recce->events }) {
			my ($name) = @{$event};
		}

        TOKEN: for my $token ( @{$terminals_expected} ) {
            next TOKEN if grep { $token eq $_ } @expected_symbols;
            $terminals_expected_matches_events = 0;
            Test::More::diag( $token, ' not in events() at pos ', $pos );
        } ## end TOKEN: for my $token ( @{$terminals_expected} )

        TOKEN: for my $token (@expected_symbols) {
            next TOKEN if grep { $token eq $_ } @{$terminals_expected};
            $terminals_expected_matches_events = 0;
            Test::More::diag( $token, ' not in terminals_expected() at pos ',
                $pos );
        } ## end TOKEN: for my $token (@expected_symbols)

	  }
	}

    my @parses;
    while ( defined( my $value_ref = $recce->value() ) ) {
        my $value = $value_ref ? ${$value_ref} : 'No parse';
        push @parses, $value;
    }
    my $expected_parse_count = scalar @{$test_results};
    my $parse_count          = scalar @parses;
    Marpa::R3::Test::is( $parse_count, $expected_parse_count,
        "$test_name: Parse count" );

    my $expected = join "\n", sort @{$test_results};
    my $actual   = join "\n", sort @parses;
    Marpa::R3::Test::is( $actual, $expected, "$test_name: Parse match" );

    Test::More::ok( $terminals_expected_matches_events,
        'Output of terminals_expected() matched events()' );

} ## end TEST: for my $test_data (@test_data)

sub show_perl_line {
    shift;
    return join ', ', grep {defined} @_;
}

sub comment                 { return 'comment' }
sub show_statement_sequence { shift; return join q{, }, @_ }
sub show_division           { return 'division' }
sub show_function_call      { return $_[1] }
sub show_die                { return 'die statement' }
sub show_unary              { return $_[1] . ' function call' }
sub show_nullary            { return $_[1] . ' function call' }

1;    # In case used as "do" file
