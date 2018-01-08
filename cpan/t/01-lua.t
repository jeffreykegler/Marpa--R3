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

# Tests of Marpa's Lua interpreter

use 5.010001;

use strict;
use warnings;

use Test::More tests => 48;
use English qw( -no_match_vars );
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

my $raw_salve = ' return [[salve, munde!]], ...';
my $marpa_lua = Marpa::R3::Lua->new();

do_global_test($raw_salve, [], ['salve, munde!'], 'Salve, 0 args');
do_global_test($raw_salve, [qw{hi}], ['salve, munde!', 'hi'], 'Salve, 1 arg');
do_global_test($raw_salve, [qw{hi hi2}], ['salve, munde!', qw(hi hi2)], 'Salve, 2 args');
do_global_test('return 42', [], ['42'], 'The answer is 42: 1');
do_global_test('strict.declare("taxicurry", true)', [], [], 'Taxi curry: declare');
do_global_test('function taxicurry(fact2) return 9^3 + fact2 end', [], [], 'Taxi curry: 1');
do_global_test('return taxicurry(10^3)', [], [1729], 'Taxi curry: 2');

sub do_global_test {
    my ($code, $args, $expected, $test_name) = @_;
    $test_name //= qq{"$code"};
    my @actual = $marpa_lua->exec($code, @{$args});
    Test::More::is_deeply( \@actual, $expected, $test_name);
}

my $grammar = Marpa::R3::Grammar->new(
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

my $recce = Marpa::R3::Recognizer->new( { grammar => $grammar } );

# A function is used to generate the args, because some tests modify them
# in-place.  The function ensures that each test has a fresh copy.

my @tests = ();
push @tests, [ ( '@' . __FILE__ . ':' . __LINE__ ), 'return 42', '',
    sub { return [] },
    ['42'],
    'The answer is 42: 1'
    ]
    ;
push @tests,
  [
    ( '@' . __FILE__ . ':' . __LINE__ ),
    'strict.declare("taxicurry", true)',
    '', sub { return [] },
    [], 'Taxi curry: declare'
  ];
push @tests, [
    ( '@' . __FILE__ . ':' . __LINE__ ),
    'function taxicurry(fact2) return 9^3 + fact2 end',
    '',
    sub { return [] },
    [],
    'Taxicurry: 1'
];
push @tests, [
    ( '@' . __FILE__ . ':' . __LINE__ ),
    'return taxicurry(10^3)',
    '',
    sub { return [] },
    [1729],
    'Taxicurry: 2'
];
push @tests, [
    ( '@' . __FILE__ . ':' . __LINE__ ),
    'local %OBJECT%, x = ...; return x',
    'S',
    sub { return [42] },
    [42],
    'SV integer to SV'
];
push @tests, [
    ( '@' . __FILE__ . ':' . __LINE__ ),
    'local %OBJECT%, x = ...; return x',
    'S',
    sub { return [[42,"forty two"]] },
    [[42,"forty two"]],
    'SV array to SV'
];
push @tests, [
    ( '@' . __FILE__ . ':' . __LINE__ ),
    'local %OBJECT%, x = ...; return x',
    'S',
    sub { return ["forty two"] },
    ["forty two"],
    'SV string to SV'
];
push @tests, [
    ( '@' . __FILE__ . ':' . __LINE__ ),
    'local %OBJECT%, x = ...; return {x}',
    'S',
    sub { return [[42,"forty two"]] },
    [[[42,"forty two"]]],
    'SV array to SV 2'
];
push @tests, [
    ( '@' . __FILE__ . ':' . __LINE__ ),
    'local %OBJECT%, x = ...; return {x,x}',
    'S',
    sub { return [[42,"forty two"]] },
    [[[42,"forty two"],[42,"forty two"]]],
    'SV array to SV 3'
];
push @tests, [
    ( '@' . __FILE__ . ':' . __LINE__ ),
    'local %OBJECT%, x = ...; return {40,x,41,{x},43}',
    'S',
    sub { return [[42,"forty two"]] },
    [[40,[42,"forty two"],41,[[42,"forty two"]], 43]],
    'SV array to SV 4'
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
    $test_name = "Lua R: $test_name";
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
