<!--
Copyright 2016 Jeffrey Kegler
Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
-->

# Kollos "mid-level" code

This is the code for Kollos, the "middle layer" of Marpa.
Below it is Libmarpa, a library written in
the C language which contains the actual parse engine.
Above it is code in a higher level language -- at this point Perl.

## Marpa virtual machine

Initially, Marpa's semantics were performed using a VM (virtual machine)
of about two dozen
operations.  I am converting them to Lua, one by one.  Once they are in
Lua, the flexibility in defining operations becomes much greater than when
they were in C/XS.  The set of operations which can be defined becomes
literally open-ended.

With Lua replacing C, the constraints which dictated the original design
of this VM are completely altered.
It remains an open question what becomes of this VM and its operation
set as Marpa evolves.
For example,
at the extreme end, every program in the old VM could be replaced with
one that is a single instruction long, with that single instruction
written entirely in Lua.
If this were done, there no longer would be a VM, in any real sense of the
word.

## The Structure of Marpa VM operations

A return value of -1 indicates this should be the last VM operation.
A return value of 0 or greater indicates this is the last VM operation,
and that there is a Perl callback with the contents of the values array
as its arguments.
A return value of -2 or less indicates that the reading of VM operations
should continue.

Note the use of tails calls in the Lua code.
Maintainters should be aware that these are finicky.
In particular, while `return f(x)` is turned into a tail call,
`return (f(x))` is not.

### VM debug operation

Was used for development.
Perhaps I should delete this.

```
    -- luatangle: section VM operations

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

```

### VM no-op operation

This is to be kept after development,
even if not used.
It may be useful in debugging.

```
    -- luatangle: section+ VM operations

    function op_fn_noop (recce)
        return -2
    end

```

### VM abend operation

This is to used for development.
Its intended use is as a dummy argument,
which, if it is used by accident
as a VM operation,
fast fails with a clear message.

```
    -- luatangle: section+ VM operations

    function op_fn_abend (recce)
        io.stderr:write('executing VM op "abend"')
        os.exit(false)
    end

```

### VM "result is undef" operation

Perhaps the simplest operation.
The result of the semantics is a Perl undef.

```
    -- luatangle: section+ VM operations

    function op_fn_result_is_undef(recce)
        local stack = recce:stack()
        stack[recce.v.step.result] = marpa.sv.undef()
        marpa.sv.fill(stack, recce.v.step.result)
        return -1
    end

```

### VM "push undef" operation

Push an undef on the values array.

```
    -- luatangle: section+ VM operations

    function op_fn_push_undef(recce)
        local values = recce:values()
        local next_ix = marpa.sv.top_index(values) + 1;
        values[next_ix] = marpa.sv.undef()
        return -2
    end

```

### VM "push one" operation

Push one of the RHS child values onto the values array.

```
    -- luatangle: section+ VM operations

    function op_fn_push_one(recce, rhs_ix)
        if recce.v.step.type ~= 'MARPA_STEP_RULE' then
          return op_fn_push_undef(recce)
        end
        local stack = recce:stack()
        local values = recce:values()
        local result_ix = recce.v.step.result
        local next_ix = marpa.sv.top_index(values) + 1;
        values[next_ix] = stack[result_ix + rhs_ix]
        return -2
    end

```

### Find current token literal

`current_token_literal` return the literal
equivalent of the current token.
It assumes that there *is* a current token,
that is,
it assumes that the caller has ensured that
`recce.v.step.type ~= 'MARPA_STEP_TOKEN'`.

```
    -- luatangle: section+ VM operations
    function current_token_literal(recce)
      if recce.token_is_literal == recce.v.step.value then
          local start_es = recce.v.step.start_es_id
          local end_es = recce.v.step.es_id
          return recce:literal_of_es_span(start_es, end_es)
      end
      return recce.token_values[recce.v.step.value]
    end

```

### VM "result is token value" operation

The result of the semantics is the value of the
token at the current location.
It's assumed to be a MARPA_STEP_TOKEN step --
if not the value is an undef.

```
    -- luatangle: section+ VM operations

    function op_fn_result_is_token_value(recce)
        if recce.v.step.type ~= 'MARPA_STEP_TOKEN' then
          return op_fn_result_is_undef(recce)
        end
        local stack = recce:stack()
        local result_ix = recce.v.step.result
        stack[result_ix] = current_token_literal(recce)
        marpa.sv.fill(stack, result_ix)
        if recce.trace_values > 0 then
          local top_of_queue = #recce.trace_values_queue;
          recce.trace_values_queue[top_of_queue+1] =
             {tag, recce.v.step.type, recce.v.step.symbol, recce.v.step.value, token_sv};
             -- io.stderr:write('[step_type]: ', inspect(recce))
        end
        return -1
    end

```

### VM "push values" operation

Push the child values onto the `values` list.
If it is a token step, then
the token at the current location is pushed onto the `values` list.
If it is a nulling step, the nothing is pushed.
Otherwise the values of the RHS children are pushed.

`increment` is 2 for sequences where separators must be discarded,
1 otherwise.

```
    -- luatangle: section+ VM operations

    function op_fn_push_values(recce, increment)
        local values = recce:values()
        if recce.v.step.type == 'MARPA_STEP_TOKEN' then
            local next_ix = marpa.sv.top_index(values) + 1;
            values[next_ix] = current_token_literal(recce)
            return -2
        end
        if recce.v.step.type == 'MARPA_STEP_RULE' then
            local stack = recce:stack()
            local arg_n = recce.v.step.arg_n
            local result_ix = recce.v.step.result
            local to_ix = marpa.sv.top_index(values) + 1;
            for from_ix = result_ix,arg_n,increment do
                values[to_ix] = stack[from_ix]
                to_ix = to_ix + 1
            end
            return -2
        end
        -- if 'MARPA_STEP_NULLING_SYMBOL', or unrecogized type
        return -2
    end

```

### VM "result is N of RHS" operation

```
    -- luatangle: section+ VM operations
    function op_fn_result_is_n_of_rhs(recce, rhs_ix)
        if recce.v.step.type ~= 'MARPA_STEP_RULE' then
          return op_fn_result_is_undef(recce)
        end
        local stack = recce:stack()
        local result_ix = recce.v.step.result
        repeat
            if rhs_ix == 0 then break end
            local fetch_ix = result_ix + rhs_ix
            if fetch_ix > recce.v.step.arg_n then
                stack[result_ix] = marpa.sv.undef()
                break
            end
            stack[result_ix] = stack[fetch_ix]
        until 1
        marpa.sv.fill(stack, result_ix)
        return -1
    end

```

### VM "result is N of sequence" operation

In `stack`,
set the result to the `item_ix`'th item of a sequence.
`stack` is a 0-based Perl AV.
Here "sequence" means a sequence in which the separators
have been kept.
For those with separators discarded,
the "N of RHS" operation should be used.

```
    -- luatangle: section+ VM operations
    function op_fn_result_is_n_of_sequence(recce, item_ix)
        if recce.v.step.type ~= 'MARPA_STEP_RULE' then
          return op_fn_result_is_undef(recce)
        end
        local result_ix = recce.v.step.result
        local fetch_ix = result_ix + item_ix * 2
        if fetch_ix > recce.v.step.arg_n then
          return op_fn_result_is_undef(recce)
        end
        local stack = recce:stack()
        if item_ix > 0 then
            stack[result_ix] = stack[fetch_ix]
        end
        marpa.sv.fill(stack, result_ix)
        return -1
    end

```

### VM operation: return start location

The current start location in input location terms -- that is,
in terms of the input string.

```
    -- luatangle: section+ VM operations
    function op_fn_push_start(recce)
        local values = recce:values()
        local start_es = recce.v.step.start_es_id
        local end_es = recce.v.step.es_id
        local next_ix = marpa.sv.top_index(values) + 1;
        local start, l = recce:span(start_es, end_es)
        values[next_ix], _ = recce:span(start_es, end_es)
        return -2
    end

```

### VM operation: return length

The length of the current step in input location terms --
that is, in terms of the input string

```
    -- luatangle: section+ VM operations
    function op_fn_push_length(recce)
        local values = recce:values()
        local start_es = recce.v.step.start_es_id
        local end_es = recce.v.step.es_id
        local next_ix = marpa.sv.top_index(values) + 1;
        _, values[next_ix] = recce:span(start_es, end_es)
        return -2
    end

```

### VM operation: return G1 start location

The current start location in G1 location terms -- that is,
in terms of G1 Earley sets.

```
    -- luatangle: section+ VM operations
    function op_fn_push_g1_start(recce)
        local values = recce:values()
        local next_ix = marpa.sv.top_index(values) + 1;
        values[next_ix] = recce.v.step.start_es_id
        return -2
    end

```

### VM operation: result is constant

Returns a constant result.

```
    -- luatangle: section+ VM operations
    function op_fn_result_is_constant(recce, constant_ix)
        local constants = recce:constants()
        local constant = constants[constant_ix]
        local stack = recce:stack()
        local result_ix = recce.v.step.result
        stack[result_ix] = constant
        marpa.sv.fill(stack, result_ix)
        if recce.trace_values > 0 and recce.v.step.type == 'MARPA_STEP_TOKEN' then
            local top_of_queue = #recce.trace_values_queue
            recce.trace_values_queue[top_of_queue+1] =
                { "valuator unknown step", recce.v.step.type, recce.token, constant}
                      -- io.stderr:write('valuator unknown step: ', inspect(recce))
        end
        return -1
    end

```

### VM operation: return G1 length

The length of the current step in G1 terms --
that is, in terms of G1 Earley sets.

```
    -- luatangle: section+ VM operations
    function op_fn_push_g1_length(recce)
        local values = recce:values()
        local next_ix = marpa.sv.top_index(values) + 1;
        values[next_ix] = (recce.v.step.es_id
            - recce.v.step.start_es_id) + 1
        return -2
    end

```

### VM operation: push constant onto values array

```
    -- luatangle: section+ VM operations
    function op_fn_push_constant(recce, constant_ix)
        local constants = recce:constants()
        -- io.stderr:write('constants: ', inspect(constants), "\n")
        -- io.stderr:write('constant_ix: ', constant_ix, "\n")
        -- io.stderr:write('constants top ix: ', marpa.sv.top_index(constants), "\n")

        local constant = constants[constant_ix]
        local values = recce:values()
        local next_ix = marpa.sv.top_index(values) + 1;
        values[next_ix] = constant
        return -2
    end

```

### Return operation key given its name

```

    -- luatangle: section+ VM operations

    function get_op_fn_key_by_name(recce, op_name_sv)
        local op_name = tostring(op_name_sv)
        return recce.op_fn_key[op_name]
    end

```

### Return operation name given its key

```
    -- luatangle: section+ VM operations
    function get_op_fn_name_by_key(recce, op_key_sv)
        local op_key = op_key_sv + 0
        return recce.op_fn_key[op_key]
    end

```

### Register a constant

Register a constant, returning its key.

```
    -- luatangle: section+ VM operations
    function constant_register(recce, constant_sv)
        local constants = recce:constants()
        local next_constant_key = marpa.sv.top_index(constants) + 1
        constants[next_constant_key] = constant_sv
        return next_constant_key
    end

```

## Preliminaries to the main code

Licensing, etc.

```

    -- luatangle: section preliminaries to main

    -- Copyright 2016 Jeffrey Kegler
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
    --
    -- [ MIT license: http://www.opensource.org/licenses/mit-license.php ]

    -- luacheck: std lua53
    -- luacheck: globals bit
    -- luacheck: globals __FILE__ __LINE__

```

## Initialize a valuator

Called when a valuator is set up.

```
    -- luatangle: section value_init()

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
        local op_abend_key = op_fn_create("abend", op_fn_abend)
        op_fn_create("noop", op_fn_noop)
        local result_is_constant_key = op_fn_create("result_is_constant", op_fn_result_is_constant)
        local result_is_undef_key = op_fn_create("result_is_undef", op_fn_result_is_undef)
        local result_is_token_value_key = op_fn_create("result_is_token_value", op_fn_result_is_token_value)
        op_fn_create("result_is_n_of_rhs", op_fn_result_is_n_of_rhs)
        op_fn_create("result_is_n_of_sequence", op_fn_result_is_n_of_sequence)
        op_fn_create("push_constant", op_fn_push_constant)
        op_fn_create("push_g1_length", op_fn_push_g1_length)
        op_fn_create("push_g1_start", op_fn_push_g1_start)
        op_fn_create("push_length", op_fn_push_length)
        op_fn_create("push_start", op_fn_push_start)
        op_fn_create("push_one", op_fn_push_one)
        op_fn_create("push_undef", op_fn_push_undef)
        op_fn_create("push_values", op_fn_push_values)

        recce.rule_semantics = {}
        recce.token_semantics = {}
        recce.nulling_semantics = {}
        recce.nulling_semantics.default
            = marpa.array.from_list(marpa.ops.lua, result_is_undef_key, op_abend_key, 0)
        recce.token_semantics.default
            = marpa.array.from_list(marpa.ops.lua, result_is_token_value_key, op_abend_key, 0)
        recce.rule_semantics.default
            = marpa.array.from_list(marpa.ops.lua, result_is_undef_key, op_abend_key, 0)
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

```

## Reset a valuator

A function to be called whenever a valuator is reset.

```

    -- luatangle: section value_reset()

    function value_reset(recce)
        recce.op_fn_key = nil
        recce.rule_semantics = nil
        recce.token_semantics = nil
        recce.nulling_semantics = nil

        recce.trace_values = 0;
        recce.trace_values_queue = {};

        recce.v = nil
    end

```

```
    -- luatangle: section main
    -- luatangle: insert preliminaries to main
    -- luatangle: insert VM operations
    -- luatangle: insert value_init()
    -- luatangle: insert value_reset()

    return "OK"

    -- luatangle: write stdout main

    -- vim: set expandtab shiftwidth=4:
```

<!--
vim: expandtab shiftwidth=4:
-->
