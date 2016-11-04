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

# CENSUS: ASIS
# Note: THIF TEST

# Testing an ambiguous equation
# using the thin interface

use 5.010001;
use strict;
use warnings;

use Test::More tests => 12;

use lib 'inc';
use Marpa::R3::Test;
use English qw( -no_match_vars );
use Fatal qw( close open );
use Marpa::R3;

# Marpa::R3::Display
# name: Thin example

my $grammar = Marpa::R3::Thin::G->new({});
$grammar->force_valued();
my $symbol_S = $grammar->symbol_new();
my $symbol_E = $grammar->symbol_new();
$grammar->start_symbol_set($symbol_S);
my $symbol_op     = $grammar->symbol_new();
my $symbol_number = $grammar->symbol_new();
my $start_rule_id = $grammar->rule_new( $symbol_S, [$symbol_E] );
my $op_rule_id =
    $grammar->rule_new( $symbol_E, [ $symbol_E, $symbol_op, $symbol_E ] );
my $number_rule_id = $grammar->rule_new( $symbol_E, [$symbol_number] );
$grammar->precompute();

my $recce = Marpa::R3::Thin::R->new($grammar);
$recce->start_input();

my $marpa_lua = Marpa::R3::Lua->new();
$marpa_lua->raw_exec($Marpa::R3::Lua::Inspect::load);

# The numbers from 1 to 3 are themselves --
# that is, they index their own token value.
# Important: zero cannot be itself!

my @token_values         = ( 0 .. 3 );
my $zero                 = -1 + push @token_values, 0;
my $minus_token_value    = -1 + push @token_values, q{-};
my $plus_token_value     = -1 + push @token_values, q{+};
my $multiply_token_value = -1 + push @token_values, q{*};

# Make a copy of the token value array in Lua.
# Note
$marpa_lua->exec(<<'END_OF_LUA');
token_values = { 1, 2, 3, 0, '-', '+', '*' }
-- Lua is 1-based so zero must be a special case.
token_values[0] = 0
END_OF_LUA

$recce->alternative( $symbol_number, 2, 1 );
$recce->earleme_complete();
$recce->alternative( $symbol_op, $minus_token_value, 1 );
$recce->earleme_complete();
$recce->alternative( $symbol_number, $zero, 1 );
$recce->earleme_complete();
$recce->alternative( $symbol_op, $multiply_token_value, 1 );
$recce->earleme_complete();
$recce->alternative( $symbol_number, 3, 1 );
$recce->earleme_complete();
$recce->alternative( $symbol_op, $plus_token_value, 1 );
$recce->earleme_complete();
$recce->alternative( $symbol_number, 1, 1 );
$recce->earleme_complete();

my $latest_earley_set_ID = $recce->latest_earley_set();
my $bocage        = Marpa::R3::Thin::B->new( $recce, $latest_earley_set_ID );
my $order         = Marpa::R3::Thin::O->new($bocage);
$order->dummyup_tree($marpa_lua, "tree");

# my $tree          = Marpa::R3::Thin::T->new($order);
my @actual_values = ();
VALUE: while ( 1 ) {

    my $result = $marpa_lua->exec(<<'END_OF_LUA', $start_rule_id, $number_rule_id, $op_rule_id);
    if not tree:next() then return end
    local value = kollos.value_new(tree)
    local start_rule_id, number_rule_id, op_rule_id = ...
    start_rule_id = start_rule_id+0
    number_rule_id = number_rule_id+0
    op_rule_id = op_rule_id+0
    -- stack will be zero-based
    local stack = {}
    while true do
       -- print(inspect(value))
       local ok, step = value:step()
       if not ok then error_throw(step) end
       if not step then break end
       local type = step[1]
       if type == 'RULE' then
           local _, rule_id, start_loc, end_loc, result, arg_0, arg_n = table.unpack(step)
           rule_id = rule_id+0
           if rule_id == start_rule_id then
               local stack_at_n = stack[arg_n]
               local string = stack_at_n[1]
               local v = stack_at_n[2]
               stack[arg_0] = string.format("%s == %s", string, v)
               goto LAST_STEP
           end
           if rule_id == number_rule_id then
               local number = stack[arg_0]
               stack[arg_0] = { tostring(number), number }
               goto NEXT_STEP
           end
           if rule_id == op_rule_id then
               local op = stack[arg_0+1]
               local stack_at_0 = stack[arg_0]
               local stack_at_n = stack[arg_n]
               local left_string = stack_at_0[1]
               local left_v = stack_at_0[2]
               local right_string = stack_at_n[1]
               local right_v = stack_at_n[2]
               local text = string.format("(%s%s%s)", left_string, op, right_string)
               local new_stack_entry = { text }
               stack[result] = new_stack_entry
               if op == '+' then
                  new_stack_entry[2] = left_v + right_v
               elseif op == '-' then
                  new_stack_entry[2] = left_v - right_v
               elseif op == '*' then
                  new_stack_entry[2] = left_v * right_v
               else
                  stack[result] = { string.format("Unknown op: %q", op), 0 }
               end
               goto NEXT_STEP
           end
           stack[result] = { string.format("Unknown rule ID: %d", rule_id), 0 }
       elseif type == 'TOKEN' then
           local _, symbol, start_loc, end_loc, result, token_value_ix = table.unpack(step)
           stack[result] = token_values[token_value_ix]
       else
           stack[result] = { string.format("Unexpected step type: %q\n", type), 0 }
       end
       ::NEXT_STEP::
    end
    ::LAST_STEP::
    value = nil
    collectgarbage()
    return stack[0]
END_OF_LUA

    last VALUE if not $result;
    push @actual_values, $result;
}

# Marpa::R3::Display::End

my %expected_value = (
    '(2-(0*(3+1))) == 2' => 1,
    '(((2-0)*3)+1) == 7' => 1,
    '((2-(0*3))+1) == 3' => 1,
    '((2-0)*(3+1)) == 8' => 1,
    '(2-((0*3)+1)) == 1' => 1,
);

my $i = 0;
for my $actual_value (@actual_values) {
    if ( defined $expected_value{$actual_value} ) {
        delete $expected_value{$actual_value};
        Test::More::pass("Expected Value $i: $actual_value");
    }
    else {
        Test::More::fail("Unexpected Value $i: $actual_value");
    }
    $i++;
} ## end for my $actual_value (@actual_values)

# For the error methods, start clean,
# with a new, trivial grammar

$marpa_lua = undef;

$grammar = $recce = $bocage = $order = undef;
$grammar = Marpa::R3::Thin::G->new({});
$grammar->force_valued();

# Marpa::R3::Display
# name: Thin throw_set() example

$grammar->throw_set(0);

# Marpa::R3::Display::End

# Turn it right back on, for safety's sake
$grammar->throw_set(1);

# Marpa::R3::Display
# name: Thin grammar error methods

my ( $error_code, $error_description ) = $grammar->error();
my @error_names = Marpa::R3::Thin::error_names();
my $error_name = $error_names[$error_code];

# Marpa::R3::Display::End

Test::More::is( $error_code, 0, 'Grammar error code' );
Test::More::is( $error_name, 'MARPA_ERR_NONE', 'Grammar error name' );
Test::More::is( $error_description, 'No error', 'Grammar error description' );

$symbol_S = $grammar->symbol_new();
my $symbol_a = $grammar->symbol_new();
my $symbol_sep = $grammar->symbol_new();
$grammar->start_symbol_set($symbol_S);

# Marpa::R3::Display
# name: Thin sequence_new() example

my $sequence_rule_id = $grammar->sequence_new(
        $symbol_S,
        $symbol_a,
        {   separator => $symbol_sep,
            proper    => 0,
            min       => 1
        }
    );

# Marpa::R3::Display::End

$grammar->precompute();
my @events;
my $event_ix = $grammar->event_count();
while ( $event_ix-- ) {

# Marpa::R3::Display
# name: Thin event() example

    my ( $event_type, $value ) = $grammar->event( $event_ix++ );

# Marpa::R3::Display::End

}

$recce = Marpa::R3::Thin::R->new($grammar);

# Marpa::R3::Display
# name: Thin ruby_slippers_set() example

$recce->ruby_slippers_set(1);

# Marpa::R3::Display::End

$recce->start_input();
$recce->alternative( $symbol_a, 1, 1 );
$recce->earleme_complete();

# Marpa::R3::Display
# name: Thin terminals_expected() example

   my @terminals = $recce->terminals_expected();

# Marpa::R3::Display::End

Test::More::is( (scalar @terminals), 1, 'count of terminals expected' );
Test::More::is( $terminals[0], $symbol_sep, 'expected terminal' );

my $report;

# Marpa::R3::Display
# name: Thin progress_item() example

    my $ordinal = $recce->latest_earley_set();
    $recce->progress_report_start($ordinal);
    ITEM: while (1) {
        my ($rule_id, $dot_position, $origin) = $recce->progress_item();
        last ITEM if not defined $rule_id;
        push @{$report}, [$rule_id, $dot_position, $origin];
    }
    $recce->progress_report_finish();

# Marpa::R3::Display::End

Test::More::is( ( join q{ }, map { @{$_} } @{$report} ),
    '0 -1 0 0 0 0', 'progress report' );

$recce->alternative( $symbol_sep, 1, 1 );
$recce->earleme_complete();
$recce->alternative( $symbol_a, 1, 1 );
$recce->earleme_complete();
$recce->alternative( $symbol_sep, 1, 1 );
$recce->earleme_complete();
$recce->alternative( $symbol_a, 1, 1 );
$recce->earleme_complete();
$latest_earley_set_ID = $recce->latest_earley_set();
$bocage        = Marpa::R3::Thin::B->new( $recce, $latest_earley_set_ID );

$marpa_lua = Marpa::R3::Lua->new();
$marpa_lua->raw_exec($Marpa::R3::Lua::Inspect::load);

$order         = Marpa::R3::Thin::O->new($bocage);
$order->dummyup_tree($marpa_lua, "tree");

my $result = $marpa_lua->exec(<<'END_OF_LUA');
    tree:next()
    local value = kollos.value_new(tree)
    local result = {}
    while true do
       local ok, step = value:step()
       if not ok then error_throw(step) end
       if not step then break end
       local type, symbol, start_loc, end_loc = table.unpack(step)
       if type == 'RULE' then
           result[#result+1] = string.format("Rule %s is from %d to %d\n", symbol, start_loc, end_loc)
       elseif type == 'TOKEN' then
           result[#result+1] = string.format("Token %s is from %d to %d\n", symbol, start_loc, end_loc)
       elseif type == 'NULLING_SYMBOL' then
           result[#result+1] = string.format("Nulling symbol %s is from %d to %d\n", symbol, start_loc, end_loc)
       else
           result[#result+1] = string.format("Unknown step type: %q\n", type)
       end
    end
    return table.concat(result)
END_OF_LUA

Test::More::is( $result, <<'EXPECTED', 'Step locations' );
Token 1 is from 0 to 1
Token 2 is from 1 to 2
Token 1 is from 2 to 3
Token 2 is from 3 to 4
Token 1 is from 4 to 5
Rule 0 is from 0 to 5
EXPECTED

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
