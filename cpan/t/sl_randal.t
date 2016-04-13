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

use Test::More tests => 4;
use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

package Test_Grammar;

my $dsl = <<'END_OF_DSL';
# :default ::= action => main::form_string
<perl line> ::= <opt ws> <perl statements> <opt padded semicolon>

<perl statements> ::= <perl statement>+
  separator => <padded semicolon> proper => 1

<opt padded semicolon> ::= <padded semicolon>
<opt padded semicolon> ::=
<padded semicolon> ::= <opt ws> <semicolon> <opt ws>
<perl statement> ::= division
<perl statement> ::= <function call>
<perl statement> ::= <die k0> <opt ws> <string literal>

division ::= expr <opt ws> <division sign> <opt ws> expr

expr ::= <function call>
expr ::= number

<function call> ::= <unary function name> argument

<function call> ::= <nullary function name>

argument ::= <pattern match>

<die k0> ::= 'd' 'i' 'e'

<unary function name> ::= 's' 'i' 'n'
<nullary function name> ::= 's' 'i' 'n' | 't' 'i' 'm' 'e'

<number> ::= <number chars>
<number chars> ::= <number char>+
<number char> ::= [\d]
<semicolon> ::= ';'
<division sign> ::= [/]

<pattern match> ::= [/] <pattern match chars> [/]
<pattern match chars> ::= <pattern match char>
<pattern match char> ::= [^/]

<comment> ::= [#] <comment content chars>
<comment content chars> ::= <comment content char>*
<comment content char> ::= [^\r\n]

<string literal> ::= '"' <string literal chars> '"'
<string literal chars> ::= <string literal char>
<string literal char> ::= [^"]

<opt ws> ::= <ws piece>*
<ws piece> ::= [\s]
<ws piece> ::= comment

END_OF_DSL

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
    { source => \$dsl }
);

TEST: for my $test_data (@test_data) {

    my ( $test_name, $test_input, $test_results ) = @{$test_data};

    my $recce = Marpa::R3::Scanless::R->new(
    	{ grammar => $g, semantics_package => 'main' }
    );

    $recce->read( \$test_input );
    # say STDERR $recce->show_progress(0, -1);

    my @parses;
    while ( defined( my $value_ref = $recce->value() ) ) {
	local $Data::Dumper::Deepcopy = 1;
	local $Data::Dumper::Terse = 1;
        push @parses, Data::Dumper::Dumper($value_ref);
    }
    my $expected_parse_count = scalar @{$test_results};
    my $parse_count          = scalar @parses;
    Marpa::R3::Test::is( $parse_count, $expected_parse_count,
        "$test_name: Parse count" );

    my $expected = join "\n", sort @{$test_results};
    my $actual   = join "\n", sort @parses;
    Marpa::R3::Test::is( $actual, $expected, "$test_name: Parse match" );

} ## end TEST: for my $test_data (@test_data)

sub show_perl_line {
    shift;
    return join ', ', grep {defined} @_;
}

sub form_string {
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
