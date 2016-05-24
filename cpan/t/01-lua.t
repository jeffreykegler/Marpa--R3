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

use Test::More tests => 13;
use English qw( -no_match_vars );
use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

my $salve = ' return [[salve, munde!]], ...';
my @tests1 = (
   [$salve, [], ['salve, munde!'], 'Salve, 0 args'],
   [$salve, [qw{hi}], ['salve, munde!', 'hi'], 'Salve, 1 arg'],
   [$salve, [qw{hi hi2}], ['salve, munde!', qw(hi hi2)], 'Salve, 2 args'],
   ['return 42', [], ['42']],
   ['function taxicurry(fact2) return 9^3 + fact2 end', [], []],
   ['return taxicurry(10^3)', [], [1729]],
);

for my $test (@tests1) {
    my ($code, $args, $expected, $test_name) = @{$test};
    $test_name //= qq{"$code"};
    my @actual = Marpa::R3::Lua::coerce_exec($code, @{$args});
    Test::More::is_deeply( \@actual, $expected, $test_name);
}

my @tests2 = (
   ["local x = ...; x[0] = 42; return x", [[]], [[42]]],
);

for my $test (@tests1, @tests2) {
    my ($code, $args, $expected, $test_name) = @{$test};
    $test_name //= qq{"$code"};
    my @actual = Marpa::R3::Lua::exec($code, @{$args});
    Test::More::is_deeply( \@actual, $expected, $test_name);
}
Marpa::R3::Lua::coerce_exec("collectgarbage()");

# vim: expandtab shiftwidth=4:
