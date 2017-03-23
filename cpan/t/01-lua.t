#!perl
# Marpa::R3 is Copyright (C) 2017, Jeffrey Kegler.
#
# This module is free software; you can redistribute it and/or modify it
# under the same terms as Perl 5.10.1. For more details, see the full text
# of the licenses in the directory LICENSES.
#
# This program is distributed in the hope that it will be
# useful, but it is provided “as is” and without any express
# or implied warranties. For details, see the full text of
# of the licenses in the directory LICENSES.

# Tests of Marpa's Lua interpreter

use 5.010001;
use strict;
use warnings;

use Test::More tests => 54;
use English qw( -no_match_vars );
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

my $raw_salve = ' return [[salve, munde!]], ...';
my $marpa_lua = Marpa::R3::Lua->new();

do_raw_test($raw_salve, [], ['salve, munde!'], 'Salve, 0 args');
do_raw_test($raw_salve, [qw{hi}], ['salve, munde!', 'hi'], 'Salve, 1 arg');
do_raw_test($raw_salve, [qw{hi hi2}], ['salve, munde!', qw(hi hi2)], 'Salve, 2 args');
do_raw_test('return 42', [], ['42']);
do_raw_test('function taxicurry(fact2) return 9^3 + fact2 end', [], []);
do_raw_test('return taxicurry(10^3)', [], [1729]);

sub do_raw_test {
    my ($code, $args, $expected, $test_name) = @_;
    $test_name //= qq{"$code"};
    my @actual = $marpa_lua->raw_exec($code, @{$args});
    Test::More::is_deeply( \@actual, $expected, $test_name);
    @actual = $marpa_lua->raw_exec($code, @{$args});
}

do_global_test($raw_salve, [], ['salve, munde!'], 'Salve, 0 args');
do_global_test($raw_salve, [qw{hi}], ['salve, munde!', 'hi'], 'Salve, 1 arg');
do_global_test($raw_salve, [qw{hi hi2}], ['salve, munde!', qw(hi hi2)], 'Salve, 2 args');
do_global_test('return 42', [], ['42']);
do_global_test('function taxicurry(fact2) return 9^3 + fact2 end', [], []);
do_global_test('return taxicurry(10^3)', [], [1729]);
do_global_test("local x = ...; x[0] = 42; return x", [[]], [[42]]);
do_global_test("local x = ...; local tmp = x[1]; x[1] = x[0]; x[0] = tmp; return x", [[42, 7]], [[7, 42]], "Swap array elements #1");
do_global_test("local y = ...; y[1], y[0] = y[0], y[1]; return y", [[42, 7]], [[7, 42]], "Swap array elements #2");
do_global_test("local y = ...; return marpa.sv.top_index(y)", [[42, 7]], [1], "Array top index of 1");
do_global_test("local y = ...; return marpa.sv.top_index(y)", [[]], [-1], "Array top index of -1");

sub do_global_test {
    my ($code, $args, $expected, $test_name) = @_;
    $test_name //= qq{"$code"};
    my @actual = $marpa_lua->exec($code, @{$args});
    Test::More::is_deeply( \@actual, $expected, $test_name);
}

$marpa_lua->raw_exec("collectgarbage()");

my $grammar = Marpa::R3::Scanless::G->new(
    {   
        source          => \(<<'END_OF_SOURCE'),
Expression ::=
      Number action => ::first
   || Expression '*' Expression action => main::do_multiply
   || Expression '+' Expression action => main::do_add

Number ~ [\d]+
:discard ~ whitespace
whitespace ~ [\s]+
END_OF_SOURCE
    }
);

my $recce = Marpa::R3::Scanless::R->new( { grammar => $grammar } );

# A function is used to generate the args, because some tests modify them
# in-place.  The function ensures that each test has a fresh copy.

my @tests = ();
push @tests, [ ( __FILE__ . ':' . __LINE__ ), 'return 42', '',
    sub { return [] },
    ['42'] ];
push @tests, [
    ( __FILE__ . ':' . __LINE__ ),
    'function taxicurry(fact2) return 9^3 + fact2 end',
    '',
    sub { return [] },
    []
];
push @tests, [
    ( __FILE__ . ':' . __LINE__ ),
    'return taxicurry(10^3)',
    '',
    sub { return [] },
    [1729]
];
push @tests, [
    ( __FILE__ . ':' . __LINE__ ),
    "local %OBJECT%, x = ...;
    print('x: ', inspect(x))
    x[0] = 42; return x",
    'S',
    sub { return [ [] ] },
    [ [42] ]
];
push @tests, [
    ( __FILE__ . ':' . __LINE__ ),
    "local %OBJECT%, x = ...;
    local tmp = x[1]; x[1] = x[0]; x[0] = tmp;
    return x",
    'S',
    sub { return [ [ 42, 7 ] ] },
    [ [ 7,  42 ] ],
    "Swap array elements #1"
];
push @tests, [
    ( __FILE__ . ':' . __LINE__ ),
    "local %OBJECT%, x = ...; x[1], x[0] = x[0], x[1]; return x",
    'S',
    sub { return [ [ 42, 7 ] ] },
    [ [ 7,  42 ] ],
    "Swap array elements #2"
];
push @tests, [
    ( __FILE__ . ':' . __LINE__ ),
    "local %OBJECT%, x = ...; marpa.sv.fill(x, 1); return x",
    'S',
    sub { return [ [ 1, 2, 3, 4 ] ] },
    [ [ 1, 2 ] ],
    "Fill method #1"
];
push @tests, [
    ( __FILE__ . ':' . __LINE__ ),
    "local %OBJECT%, x = ...; marpa.sv.fill(x, 4); return x",
    'S',
    sub { return [ [ 1, 2, 3, 4 ] ] },
    [ [ 1, 2, 3, 4, undef ] ],
    "Fill method #2"
];
push @tests, [
    ( __FILE__ . ':' . __LINE__ ),
    "local %OBJECT%, x = ...; marpa.sv.fill(x, -1); return x",
    'S',
    sub { return [ [ 1, 2, 3, 4 ] ] },
    [ [] ], "Fill method #2"
];

sub do_recce_test {
    my ($tag, $code, $signature, $args_fn, $expected, $test_name) = @_;
    my $args = &{$args_fn}();
    $code =~ s/%OBJECT%,\s*/recce, /;
    $test_name //= qq{"$code"};
    $test_name = "Recce: $test_name";
    my @actual = $recce->call_by_tag($tag, $code, $signature, @{$args});
    Test::More::is_deeply( \@actual, $expected, $test_name);
}

for my $test_data (@tests) {
    do_recce_test(@{$test_data});
}

sub do_lua_test {
    my ($tag, $code, $signature, $args_fn, $expected, $test_name) = @_;
    my $args = &{$args_fn}();
    $code =~ s/%OBJECT%,\s*//;
    # We modified $code, so we must modify $tag!!
    $tag = "Lua:$tag";
    $test_name //= qq{"$code"};
    $test_name = "Lua static: $test_name";
    my @actual = $marpa_lua->call_by_tag(-1, $tag, $code, $signature, @{$args});
    Test::More::is_deeply( \@actual, $expected, $test_name);
}

for my $test_data (@tests) {
    do_lua_test(@{$test_data});
}

my $g_regix = $grammar->regix();

sub do_lua_g_test {
    my ($tag, $code, $signature, $args_fn, $expected, $test_name) = @_;
    my $args = &{$args_fn}();
    $code =~ s/%OBJECT%,\s*/grammar, /;
    # We modified $code, so we must modify $tag!!
    $tag = "Lua G:$tag";
    $test_name //= qq{"$code"};
    $test_name = "Lua G: $test_name";
    my @actual = $marpa_lua->call_by_tag($g_regix, $tag, $code, $signature, @{$args});
    Test::More::is_deeply( \@actual, $expected, $test_name);
}

for my $test_data (@tests) {
    do_lua_g_test(@{$test_data});
}

my $r_regix = $recce->regix();

sub do_lua_r_test {
    my ($tag, $code, $signature, $args_fn, $expected, $test_name) = @_;
    my $args = &{$args_fn}();
    $code =~ s/%OBJECT%,\s*/recce, /;
    # We modified $code, so we must modify $tag!!
    $tag = "Lua R:$tag";
    $test_name //= qq{"$code"};
    $test_name = "Lua G: $test_name";
    my @actual = $marpa_lua->call_by_tag($r_regix, $tag, $code, $signature, @{$args});
    Test::More::is_deeply( \@actual, $expected, $test_name);
}

for my $test_data (@tests) {
    do_lua_r_test(@{$test_data});
}

# Marpa::R3::Lua::raw_exec("collectgarbage()");

my $input = '42 * 1 + 7';
$recce->read( \$input );
my $value_ref = $recce->value();
Marpa::R3::Test::is( ${$value_ref}, 49, 'Synopsis value test' );

sub do_add       { return $_[1]->[0] + $_[1]->[2] }
sub do_multiply  { return $_[1]->[0] * $_[1]->[2] }

# vim: expandtab shiftwidth=4:
