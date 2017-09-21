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

# Note: Converted to SLIF from randal.t

# VALUATOR: TODO

use 5.010001;

use strict;
use warnings;
use English qw( -no_match_vars );
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use Test::More tests => 4;
use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

package Test_Grammar;

my $dsl = <<'END_OF_DSL';
:default ::= action => ::undef
<perl line> ::= <leading material> <perl statements> <final material> <opt comment>
    action => show_statements
<final material> ::= <padded semicolon>
<final material> ::= <opt ws>
<final material> ::=
<leading material> ::= <opt ws>
<leading material> ::=
<opt comment> ::= <comment> action => flatten
<opt comment> ::=

<perl statements> ::= <perl statement>+
  separator => <padded semicolon> proper => 1
  action => flatten

<padded semicolon> ::= <opt ws> <semicolon> <opt ws>
<perl statement> ::= division action => flatten
<perl statement> ::= <function call> action => flatten
<perl statement> ::= <die k0> <opt ws> <string literal> action => show_die

division ::= expr <opt ws> <division sign> <opt ws> expr
    action => show_division

expr ::= <function call>
expr ::= number

<function call> ::= <unary function name> <opt ws> argument
    action => show_function_call

<function call> ::= <nullary function name>
    action => show_function_call

argument ::= <pattern match>

<die k0> ::= 'd' 'i' 'e' action => concatenate

<unary function name> ::= 's' 'i' 'n' action => concatenate
<nullary function name> ::= 's' 'i' 'n' action => concatenate
  | 't' 'i' 'm' 'e' action => concatenate

<number> ::= <number chars>
<number chars> ::= <number char>+
<number char> ::= [\d]
<semicolon> ::= ';'
<division sign> ::= [/]

<pattern match> ::= [/] <pattern match chars> [/]
<pattern match chars> ::= <pattern match char>*
<pattern match char> ::= [^/]

<comment> ::= [#] <comment content chars>
     action => show_comment
<comment content chars> ::= <comment content char>*
<comment content char> ::= [^\r\n]

<string literal> ::= '"' <string literal chars> '"'
<string literal chars> ::= <string literal char>*
<string literal char> ::= [^"]

<opt ws> ::= <ws piece>*
<ws piece> ::= [\s]

END_OF_DSL

package main;

my @test_data = (
    [
        'sin',
        q{sin  / 25 ; # / ; die "this dies!"},
        [ 'division@B1L1c1-9, comment@B1L1c13-34', 'sin@B1L1c1-15, die@B1L1c19-34' ],
    ],
    [
        'time',
        q{time  / 25 ; # / ; die "this dies!"},
        ['division@B1L1c1-10, comment@B1L1c14-35']
    ]
);

my $g = Marpa::R3::Scanless::G->new(
    {
        semantics_package => 'main',
        source            => \$dsl
    }
);

TEST: for my $test_data (@test_data) {

    my ( $test_name, $test_input, $test_results ) = @{$test_data};

    my $recce = Marpa::R3::Scanless::R->new( { grammar => $g, } );

    $recce->read( \$test_input );

    my @parses;
    while ( defined( my $value_ref = $recce->old_value() ) ) {
        push @parses, ${$value_ref};
    }
    my $expected_parse_count = scalar @{$test_results};
    my $parse_count          = scalar @parses;
    Marpa::R3::Test::is( $parse_count, $expected_parse_count,
        "$test_name: Parse count" );

    my $expected = join "\n", sort @{$test_results};
    my $actual   = join "\n", sort @parses;
    Marpa::R3::Test::is( $actual, $expected, "$test_name: Parse match" );

} ## end TEST: for my $test_data (@test_data)

sub concatenate {
    my (undef, $values) = @_;
    return join q{}, grep { defined } @{$values};
}

sub flatten {
    my (undef, $values) = @_;
    my @children = ();
  CHILD: for my $child (@{$values}) {
        next CHILD if not defined $child;
        if ( ref $child eq 'ARRAY' ) {
            push @children, @{$child};
            next CHILD;
        }
        push @children, $child;
    }
    return \@children;
}

sub show_comment {
    return 'comment@' . Marpa::R3::Context::lc_range();
}

sub show_statements {
    my $statements = flatten(@_);
    return join q{, }, @{$statements};
}

sub show_die {
    return 'die@' . Marpa::R3::Context::lc_range();
}

sub show_division {
    return 'division@' . Marpa::R3::Context::lc_range();
}

sub show_function_call {
    my (undef, $values) = @_;
    return $values->[0] . '@' . Marpa::R3::Context::lc_range();
}

# vim: expandtab shiftwidth=4:
