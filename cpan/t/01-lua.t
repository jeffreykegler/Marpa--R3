#!perl
# Marpa::R3 is Copyright (C) 2016, Jeffrey Kegler.
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

use Test::More tests => 28;
use English qw( -no_match_vars );
use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

my $salve = ' return [[salve, munde!]], ...';

do_raw_test($salve, [], ['salve, munde!'], 'Salve, 0 args');
do_raw_test($salve, [qw{hi}], ['salve, munde!', 'hi'], 'Salve, 1 arg');
do_raw_test($salve, [qw{hi hi2}], ['salve, munde!', qw(hi hi2)], 'Salve, 2 args');
do_raw_test('return 42', [], ['42']);
do_raw_test('function taxicurry(fact2) return 9^3 + fact2 end', [], []);
do_raw_test('return taxicurry(10^3)', [], [1729]);

sub do_raw_test {
    my ($code, $args, $expected, $test_name) = @_;
    $test_name //= qq{"$code"};
    my @actual = Marpa::R3::Lua::raw_exec($code, @{$args});
    Test::More::is_deeply( \@actual, $expected, $test_name);
}

do_global_test($salve, [], ['salve, munde!'], 'Salve, 0 args');
do_global_test($salve, [qw{hi}], ['salve, munde!', 'hi'], 'Salve, 1 arg');
do_global_test($salve, [qw{hi hi2}], ['salve, munde!', qw(hi hi2)], 'Salve, 2 args');
do_global_test('return 42', [], ['42']);
do_global_test('function taxicurry(fact2) return 9^3 + fact2 end', [], []);
do_global_test('return taxicurry(10^3)', [], [1729]);
do_global_test("local x = ...; x[0] = 42; return x", [[]], [[42]]);
do_global_test("local x = ...; local tmp = x[1]; x[1] = x[0]; x[0] = tmp; return x", [[42, 7]], [[7, 42]], "Swap array elements #1");
do_global_test("local y = ...; y[1], y[0] = y[0], y[1]; return y", [[42, 7]], [[7, 42]], "Swap array elements #2");

sub do_global_test {
    my ($code, $args, $expected, $test_name) = @_;
    $test_name //= qq{"$code"};
    my @actual = Marpa::R3::Lua::exec($code, @{$args});
    Test::More::is_deeply( \@actual, $expected, $test_name);
}

Marpa::R3::Lua::raw_exec("collectgarbage()");

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

do_recce_test($salve, [], ['salve, munde!'], 'Salve, 0 args');
do_recce_test($salve, [qw{hi}], ['salve, munde!', 'hi'], 'Salve, 1 arg');
do_recce_test($salve, [qw{hi hi2}], ['salve, munde!', qw(hi hi2)], 'Salve, 2 args');
do_recce_test('return 42', [], ['42']);
do_recce_test('function taxicurry(fact2) return 9^3 + fact2 end', [], []);
do_recce_test('return taxicurry(10^3)', [], [1729]);
do_recce_test("local x = ...; x[0] = 42; return x", [[]], [[42]]);
do_recce_test("local x = ...; local tmp = x[1]; x[1] = x[0]; x[0] = tmp; return x", [[42, 7]], [[7, 42]], "Swap array elements #1");
do_recce_test("local x = ...; x[1], x[0] = x[0], x[1]; return x", [[42, 7]], [[7, 42]], "Swap array elements #2");
do_recce_test("local x = ...; Marpa_sv.fill(x, 1); return x", [[1, 2, 3, 4]], [[1, 2]], "Fill method #1");
do_recce_test("local x = ...; Marpa_sv.fill(x, 4); return x", [[1, 2, 3, 4]], [[1, 2, 3, 4, undef]], "Fill method #2");
do_recce_test("local x = ...; Marpa_sv.fill(x, -1); return x", [[1, 2, 3, 4]], [[]], "Fill method #2");

sub do_recce_test {
    my ($code, $args, $expected, $test_name) = @_;
    $test_name //= qq{"$code"};
    $test_name = "Recce: $test_name";
    my $fn_key = $recce->register_fn($code);
    my @actual = $recce->exec($fn_key, @{$args});
    Test::More::is_deeply( \@actual, $expected, $test_name);
}
Marpa::R3::Lua::raw_exec("collectgarbage()");

my $input = '42 * 1 + 7';
$recce->read( \$input );
my $value_ref = $recce->value();
Marpa::R3::Test::is( ${$value_ref}, 49, 'Synopsis value test' );

sub do_add       { return $_[1]->[0] + $_[1]->[2] }
sub do_multiply  { return $_[1]->[0] * $_[1]->[2] }

# vim: expandtab shiftwidth=4:
