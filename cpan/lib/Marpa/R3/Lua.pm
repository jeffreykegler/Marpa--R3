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

package Marpa::R3::Lua;

use 5.010001;
use warnings;
use strict;

use vars qw($VERSION $STRING_VERSION);
$VERSION        = '4.001_013';
$STRING_VERSION = $VERSION;
$VERSION        = eval $VERSION;

# Lua methods

# These can, and probably should, be pre-compiled someday,
# reducing start-up time.

$Marpa::R3::Lua::lua_init = <<'END_OF_LUA';
    -- for k,v in pairs(marpa.ops)
    -- do io.stderr:write(string.format("OP: %s %s\n", k, v))
    -- end

function op_fn_debug (...)
    local recce = ...
    for k,v in pairs(recce) do
	print(k, v)
    end
    mt = debug.getmetatable(recce)
    print([[=== metatable ===]])
    for k,v in pairs(mt) do
	print(k, v)
    end
    return -2
end

function op_fn_result_is_undef(...)
        local recce = ...
        local stack = recce:stack()
        stack[recce.v.step.result] = marpa.sv.undef()
        marpa.sv.fill(stack, recce.v.step.result)
        return -1
end

function op_fn_result_is_token_value(...)
  local recce = ...;
  local stack = recce:stack()
  local result_ix = recce.v.step.result
  repeat
    if recce.v.step.type ~= 'MARPA_STEP_TOKEN' then
      stack[result_ix] = marpa.sv.undef()
      marpa.sv.fill(stack, result_ix)
      break
    end
    if recce.token_is_literal == recce.v.step.value then
      local start_es = recce.v.step.start_es_id
      local end_es = recce.v.step.es_id
      stack[result_ix] = recce:literal_of_es_span(start_es, end_es)
      marpa.sv.fill(stack, result_ix)
      break
    end
    stack[result_ix] = recce.token_values[recce.v.step.value]
    marpa.sv.fill(stack, result_ix)
    if recce.trace_values > 0 then
      local top_of_queue = #recce.trace_values_queue;
      recce.trace_values_queue[top_of_queue+1] =
	 {tag, recce.v.step.type, recce.v.step.symbol, recce.v.step.value, token_sv};
	 -- io.stderr:write('[step_type]: ', inspect(recce))
    end
  until 1
  return -1
end

function value_init(recce, trace_values)

    if recce.v then return end

    recce.op_fn_key = {}

    function op_fn_create(name, fn) 
	local ref = recce:ref(fn);
	recce.op_fn_key[name] = ref;
	return ref
    end

    op_fn_create("debug", op_fn_debug)
    local result_is_undef_key = op_fn_create("result_is_undef", op_fn_result_is_undef)

    recce.rule_semantics = {}
    recce.token_semantics = {}
    recce.nulling_semantics = {}
    recce.nulling_semantics.default
        = marpa.array.from_list(marpa.ops.lua, result_is_undef_key,0)
    recce.token_semantics.default
        = marpa.array.from_list(marpa.ops.result_is_token_value,0)
    recce.rule_semantics.default
        = marpa.array.from_list(marpa.ops.lua, result_is_undef_key,0)
    -- print( recce.nulling_semantics.default )
    -- io.stderr:write(string.format("len: %s\n", #(recce.nulling_semantics.default)))
    -- io.stderr:write(string.format("#0: %s\n", recce.nulling_semantics.default[0]))
    -- io.stderr:write(string.format("#1: %s\n", recce.nulling_semantics.default[1]))

    recce.trace_values = trace_values + 0;
    recce.trace_values_queue = {};
    if recce.trace_values > 0 then
      local top_of_queue = #recce.trace_values_queue;
      recce.trace_values_queue[top_of_queue+1] = {
	"valuator trace level", 0,
	recce.trace_values,
      }
    end

    recce.v = {}
end

function value_reset(recce)
    recce.op_fn_key = nil
    recce.rule_semantics = nil
    recce.token_semantics = nil
    recce.nulling_semantics = nil

    recce.trace_values = 0;
    recce.trace_values_queue = {};

    recce.v = nil
end

END_OF_LUA
1;
