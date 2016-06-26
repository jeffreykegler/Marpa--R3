-- Copyright 2016 Jeffrey Kegler
--
-- Permission is hereby granted, free of charge, to any person obtaining a
-- copy of this software and associated documentation files (the "Software"),
-- to deal in the Software without restriction, including without limitation
-- the rights to use, copy, modify, merge, publish, distribute, sublicense,
-- and/or sell copies of the Software, and to permit persons to whom the
-- Software is furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included
-- in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
-- THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
-- OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
-- ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
-- OTHER DEALINGS IN THE SOFTWARE.
-- END_OF_STRING
--

    -- for k,v in pairs(marpa.ops)
    -- do io.stderr:write(string.format("OP: %s %s\n", k, v))
    -- end

function op_fn_debug (recce)
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

function op_fn_result_is_undef(recce)
    local stack = recce:stack()
    stack[recce.v.step.result] = marpa.sv.undef()
    marpa.sv.fill(stack, recce.v.step.result)
    return -1
end

function op_fn_result_is_token_value(recce)
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
	recce.op_fn_key[ref] = name;
	return ref
    end

    op_fn_create("debug", op_fn_debug)
    local result_is_undef_key = op_fn_create("result_is_undef", op_fn_result_is_undef)
    local result_is_token_value_key = op_fn_create("result_is_token_value", op_fn_result_is_token_value)

    recce.rule_semantics = {}
    recce.token_semantics = {}
    recce.nulling_semantics = {}
    recce.nulling_semantics.default
        = marpa.array.from_list(marpa.ops.lua, result_is_undef_key,0)
    recce.token_semantics.default
        = marpa.array.from_list(marpa.ops.lua, result_is_token_value_key,0)
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

-- vim: set expandtab shiftwidth=4:
