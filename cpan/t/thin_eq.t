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

# Testing an ambiguous equation
# The interface used here is a successor to Marpa::R2's THIF.
# It is not fully designed and in fact vague in conception.
# There are two design principles:
# 1.  Support only a single Libmarpa grammar, so that lexing
#     is up to the up.
# 2.  Use only Libmarpa with an "as thin as reasonably possible"
#     Lua interface.
#
# At present, I'm not sure exactly if this interface will ever
# have a formal specification.  I keep it because I feel more
# secure if the test suite has a non-DSL dependent interface to
# full facilities of Libmarpa.

use 5.010001;
use strict;
use warnings;

use lib 'inc';
use Marpa::R3::Lua::Test::More;
use English qw( -no_match_vars );
use Fatal qw( close open );
use Marpa::R3;
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

my $marpa_lua = Marpa::R3::Lua->new();

$marpa_lua->exec('strict.off()');
Marpa::R3::Lua::Test::More::load_me($marpa_lua);
$marpa_lua->exec('strict.on()');

$marpa_lua->exec(<<'END_OF_LUA');
     Test.More.plan(8)

     -- for debugging
     function show_progress (recce)
         local ordinal = recce:latest_earley_set()
         recce:progress_report_start(ordinal)
         local report = {string.format("Progress @%d", ordinal)}
         while true do
             local rule_id, dot_position, origin = recce:progress_item()
             if not rule_id then break end
             report[#report+1] = string.format("R%d D%d @%d",
                 rule_id,
                 dot_position,
                 origin
             )
         end
         io.stderr:write(table.concat(report, '\n'), "\n")
     end

     -- for debugging
     function dump_rule (grammar, rule_id)
         local rhs = {}
         local length = grammar:rule_length(rule_id)
         for i = 0, length - 1 do
             rhs[#rhs+1] = grammar:rule_rhs(rule_id, i)
         end
         print(string.format("%d: %d ::= %s", rule_id, grammar:rule_lhs(rule_id),
            table.concat(rhs, " ")))
     end

     -- Test phase 1

     local grammar = kollos.grammar_new()
     grammar:force_valued()
     local S = grammar:symbol_new("S").id
     local E = grammar:symbol_new("E").id
     local op = grammar:symbol_new("op").id
     local number = grammar:symbol_new("number").id
     local start_rule_id = grammar:rule_new{S, E}
     local op_rule_id = grammar:rule_new{E, E, op, E}
     local number_rule_id = grammar:rule_new{E, number}

     grammar:start_symbol_set(S)
     grammar:precompute()

     local recce = kollos.recce_new(grammar)
     recce:start_input()

    token_strings = {}
    token_ids = {} -- zero-based
    raw_token_values = { '0', '1', '2', '3', '-', '+', '*' }
    for ix = 1, #raw_token_values do
         local token_string = tostring(raw_token_values[ix])
         local token_id = ix
         token_strings[token_id] = token_string
         token_ids[token_string] = token_id
    end
    -- Lua is 1-based so zero must be a special case.

    recce:alternative(number, token_ids['2'], 1)
    recce:earleme_complete()
    recce:alternative(op, token_ids['-'], 1)
    recce:earleme_complete()
    recce:alternative(number, token_ids['0'], 1)
    recce:earleme_complete()
    recce:alternative(op, token_ids['*'], 1)
    recce:earleme_complete()
    recce:alternative(number, token_ids['3'], 1)
    recce:earleme_complete()
    recce:alternative(op, token_ids['+'], 1)
    recce:earleme_complete()
    recce:alternative(number, token_ids['1'], 1)
    recce:earleme_complete()

    latest_earley_set_ID = recce:latest_earley_set()

    local bocage = kollos.bocage_new(recce, latest_earley_set_ID)
    local order = kollos.order_new(bocage)

    local tree = kollos.tree_new(order)

    local actual_values = {}
    while true do
        local has_next = tree:next()
        if not has_next then break end
        local value = kollos.value_new(tree)

        -- stack will be zero-based
        local stack = {}
        while true do
           -- print(inspect(value))
           local ok, step = value:step()
           if not ok then error_throw(step) end
           if not step then break end
           local type = step[1]
           if type == 'MARPA_STEP_RULE' then
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
                   stack[arg_0] = { tostring(number), math.tointeger(number) }
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
           elseif type == 'MARPA_STEP_TOKEN' then
               local _, symbol, start_loc, end_loc, result, token_value_ix = table.unpack(step)
               stack[result] = token_strings[token_value_ix]
           else
               error( string.format("Unexpected step type: %q\n", type) )
           end
           ::NEXT_STEP::
        end
        ::LAST_STEP::
        value = nil
        collectgarbage()
        actual_values[#actual_values+1] = stack[0]
    end

    table.sort(actual_values)
    actual_values[#actual_values+1] = '' -- to get final '\n'
    actual_values_string = table.concat(actual_values, '\n')
    Test.More.is(actual_values_string, [[
(((2-0)*3)+1) == 7
((2-(0*3))+1) == 3
((2-0)*(3+1)) == 8
(2-((0*3)+1)) == 1
(2-(0*(3+1))) == 2
]], 'expected values')

     -- Test phase 2

     -- Reinitialize
     grammar = nil
     recce = nil
     bocage = nil
     order = nil
     tree = nil
     value = nil

     local grammar = kollos.grammar_new()
     grammar:force_valued()
     kollos.throw = false
     local error_object = grammar:error()
     kollos.throw = true
     local error_code = error_object.code
     Test.More.is(error_object.code, 0, 'Grammar error code')
     local error_name = kollos.error_name(error_code)
     Test.More.is(error_name, 'KOLLOS_ERR_NONE', 'Grammar error name' )
     local error_description = kollos.error_description(error_code)
     Test.More.is(error_description, 'No error', 'Grammar error description' )
     local S = grammar:symbol_new("S").id
     local a = grammar:symbol_new("a").id
     local sep = grammar:symbol_new("sep").id
     grammar:start_symbol_set(S)
     grammar:sequence_new{lhs = S, rhs = a, separator = sep, proper = 0, min = 1}
     grammar:precompute()
     local recce = kollos.recce_new(grammar)
     recce:start_input()
     kollos.throw = false
     recce:alternative(a, 1, 1)
     kollos.throw = true
     recce:earleme_complete()
     local terminals_expected = recce:terminals_expected()
     Test.More.is(#terminals_expected, 1, 'count of terminals expected')
     Test.More.is(terminals_expected[1], sep, 'expected terminal')

     local report = {}
     local last_ordinal = recce:latest_earley_set()
     for ordinal = 0, last_ordinal do
         recce:progress_report_start(ordinal)
         while true do
             local rule_id, dot_position, origin = recce:progress_item()
             if not rule_id then break end
             report[#report+1] = string.format("%d:%d@%d",
                 rule_id, dot_position, origin)
         end
     end
     local report_string = table.concat(report, ' ')
     Test.More.is(report_string, '0:0@0 0:-1@0', 'progress report' )

     recce:alternative(sep, 1, 1)
     recce:earleme_complete()
     recce:alternative(a, 1, 1)
     recce:earleme_complete()
     recce:alternative(sep, 1, 1)
     recce:earleme_complete()
     recce:alternative(a, 1, 1)
     recce:earleme_complete()
     latest_earley_set_ID = recce:latest_earley_set()

     local bocage = kollos.bocage_new(recce, latest_earley_set_ID)
     local order = kollos.order_new(bocage)

    -- print(inspect(_G))
    local tree = kollos.tree_new(order)
    tree:next()
    local value = kollos.value_new(tree)
    local result = {}
    while true do
       local ok, step = value:step()
       if not ok then error_throw(step) end
       if not step then break end
       local type, symbol, start_loc, end_loc = table.unpack(step)
       if type == 'MARPA_STEP_RULE' then
           result[#result+1] = string.format("Rule %s is from %d to %d\n", symbol, start_loc, end_loc)
       elseif type == 'MARPA_STEP_TOKEN' then
           result[#result+1] = string.format("Token %s is from %d to %d\n", symbol, start_loc, end_loc)
       elseif type == 'MARPA_STEP_NULLING_SYMBOL' then
           result[#result+1] = string.format("Nulling symbol %s is from %d to %d\n", symbol, start_loc, end_loc)
       else
           result[#result+1] = string.format("Unknown step type: %q\n", type)
       end
    end
    local result_string = table.concat(result)
    Test.More.is(result_string, [[
Token 1 is from 0 to 1
Token 2 is from 1 to 2
Token 1 is from 2 to 3
Token 2 is from 3 to 4
Token 1 is from 4 to 5
Rule 0 is from 0 to 5
]], 'Step locations' )
END_OF_LUA

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
