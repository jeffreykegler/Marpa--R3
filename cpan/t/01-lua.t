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

use Test::More tests => 16;
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
    my @actual = Marpa::R3::Lua::raw_exec($code, @{$args});
    Test::More::is_deeply( \@actual, $expected, $test_name);
}

my @tests2 = (
   ["local x = ...; x[0] = 42; return x", [[]], [[42]]],
   ["local x = ...; local tmp = x[1]; x[1] = x[0]; x[0] = tmp; return x", [[42, 7]], [[7, 42]], "Swap array elements #1"],
   ["local x = ...;  x[1], x[0] = x[0], x[1]; return x", [[42, 7]], [[7, 42]], "Swap array elements #2"],
);

for my $test (@tests1, @tests2) {
    my ($code, $args, $expected, $test_name) = @{$test};
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

for my $test (@tests1, @tests2) {
    my ($code, $args, $expected, $test_name) = @{$test};
    $test_name //= qq{"$code"};
    $test_name = "Recce: $test_name";
    my $fn_key = $recce->register_fn($code);
    my @actual = $recce->exec($fn_key, @{$args});
    Test::More::is_deeply( \@actual, $expected, $test_name);
}

my $input = '42 * 1 + 7';
$recce->read( \$input );
my $value_ref = $recce->value();
Marpa::R3::Test::is( ${$value_ref}, 49, 'Synopsis value test' );

sub do_add       { return $_[1]->[0] + $_[1]->[2] }
sub do_multiply  { return $_[1]->[0] * $_[1]->[2] }

# vim: expandtab shiftwidth=4:
