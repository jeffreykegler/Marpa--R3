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

# The Kollos code

# Table of contents
<!--
../lua/lua toc.lua < init.lua.md
-->
* [About Kollos](#about-kollos)
* [Kollos semantics](#kollos-semantics)
  * [VM operations](#vm-operations)
    * [VM debug operation](#vm-debug-operation)
    * [VM no-op operation](#vm-no-op-operation)
    * [VM bail operation](#vm-bail-operation)
    * [VM result operations](#vm-result-operations)
    * [VM "result is undef" operation](#vm-result-is-undef-operation)
    * [VM "result is token value" operation](#vm-result-is-token-value-operation)
    * [VM "result is N of RHS" operation](#vm-result-is-n-of-rhs-operation)
    * [VM "result is N of sequence" operation](#vm-result-is-n-of-sequence-operation)
    * [VM operation: result is constant](#vm-operation-result-is-constant)
    * [Operation of the values array](#operation-of-the-values-array)
    * [VM "push undef" operation](#vm-push-undef-operation)
    * [VM "push one" operation](#vm-push-one-operation)
    * [Find current token literal](#find-current-token-literal)
    * [VM "push values" operation](#vm-push-values-operation)
    * [VM operation: push start location](#vm-operation-push-start-location)
    * [VM operation: push length](#vm-operation-push-length)
    * [VM operation: push G1 start location](#vm-operation-push-g1-start-location)
    * [VM operation: push G1 length](#vm-operation-push-g1-length)
    * [VM operation: push constant onto values array](#vm-operation-push-constant-onto-values-array)
    * [VM operation: set the array blessing](#vm-operation-set-the-array-blessing)
    * [VM operation: result is array](#vm-operation-result-is-array)
    * [VM operation: callback](#vm-operation-callback)
  * [Run the virtual machine](#run-the-virtual-machine)
  * [Find and perform the VM operations](#find-and-perform-the-vm-operations)
  * [VM-related utilities for use in the Perl code](#vm-related-utilities-for-use-in-the-perl-code)
    * [Return operation key given its name](#return-operation-key-given-its-name)
    * [Return operation name given its key](#return-operation-name-given-its-key)
    * [Register a constant](#register-a-constant)
    * [Register semantics for a token](#register-semantics-for-a-token)
    * [Register semantics for a nulling symbol](#register-semantics-for-a-nulling-symbol)
    * [Register semantics for a rule](#register-semantics-for-a-rule)
    * [Return the top index of the stack](#return-the-top-index-of-the-stack)
    * [Return the value of a stack entry](#return-the-value-of-a-stack-entry)
    * [Set the value of a stack entry](#set-the-value-of-a-stack-entry)
* [The Kollos valuator](#the-kollos-valuator)
  * [Initialize a valuator](#initialize-a-valuator)
  * [Reset a valuator](#reset-a-valuator)
* [Preliminaries to the main code](#preliminaries-to-the-main-code)

## About Kollos

This is the code for Kollos, the "middle layer" of Marpa.
Below it is Libmarpa, a library written in
the C language which contains the actual parse engine.
Above it is code in a higher level language -- at this point Perl.

This document is evolving.  Most of the "middle layer" is still
in the Perl code or in the Perl XS, and not represented here.
This document only contains those portions converted to Lua or
to Lua-centeric C code.

## Kollos semantics

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

### VM operations

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

#### VM debug operation

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

#### VM no-op operation

This is to be kept after development,
even if not used.
It may be useful in debugging.

```
    -- luatangle: section+ VM operations

    function op_fn_noop (recce)
        return -2
    end

```

#### VM bail operation

This is to used for development.
Its intended use is as a dummy argument,
which, if it is used by accident
as a VM operation,
fast fails with a clear message.

```
    -- luatangle: section+ VM operations

    function op_fn_bail (recce)
        error('executing VM op "bail"')
    end

```

#### VM result operations

If an operation in the VM returns -1, it is a
"result operation".
The actual result is expected to be in the stack
at index `recce.v.step.result`.

The result operation is not required to be the
last operation in a sequence,
and
a sequence of operations does not have to contain
a result operation.
If there are
other operations after the result operation,
they will not be performed.
If a sequence ends without encountering a result
operation, an implicit "no-op" result operation
is assumed and, as usual,
the result is the value in the stack
at index `recce.v.step.result`.

#### VM "result is undef" operation

Perhaps the simplest operation.
The result of the semantics is a Perl undef.

```
    -- luatangle: section+ VM operations

    function op_fn_result_is_undef(recce)
        local stack = recce.v.stack
        stack[recce.v.step.result] = marpa.sv.undef()
        return -1
    end

```

#### VM "result is token value" operation

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
        local stack = recce.v.stack
        local result_ix = recce.v.step.result
        stack[result_ix] = current_token_literal(recce)
        if recce.trace_values > 0 then
          local top_of_queue = #recce.trace_values_queue;
          recce.trace_values_queue[top_of_queue+1] =
             {tag, recce.v.step.type, recce.v.step.symbol, recce.v.step.value, token_sv};
             -- io.stderr:write('[step_type]: ', inspect(recce))
        end
        return -1
    end

```

#### VM "result is N of RHS" operation

```
    -- luatangle: section+ VM operations
    function op_fn_result_is_n_of_rhs(recce, rhs_ix)
        if recce.v.step.type ~= 'MARPA_STEP_RULE' then
          return op_fn_result_is_undef(recce)
        end
        local stack = recce.v.stack
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
        return -1
    end

```

#### VM "result is N of sequence" operation

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
        local stack = recce.v.stack
        if item_ix > 0 then
            stack[result_ix] = stack[fetch_ix]
        end
        return -1
    end

```

#### VM operation: result is constant

Returns a constant result.

```
    -- luatangle: section+ VM operations
    function op_fn_result_is_constant(recce, constant_ix)
        local constants = recce:constants()
        local constant = constants[constant_ix]
        local stack = recce.v.stack
        local result_ix = recce.v.step.result
        stack[result_ix] = constant
        if recce.trace_values > 0 and recce.v.step.type == 'MARPA_STEP_TOKEN' then
            local top_of_queue = #recce.trace_values_queue
            recce.trace_values_queue[top_of_queue+1] =
                { "valuator unknown step", recce.v.step.type, recce.token, constant}
                      -- io.stderr:write('valuator unknown step: ', inspect(recce))
        end
        return -1
    end

```

#### Operation of the values array

The following operations add elements to the `values` array.
This is a special array which may eventually be the result of the
sequence of operations.

#### VM "push undef" operation

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

#### VM "push one" operation

Push one of the RHS child values onto the values array.

```
    -- luatangle: section+ VM operations

    function op_fn_push_one(recce, rhs_ix)
        if recce.v.step.type ~= 'MARPA_STEP_RULE' then
          return op_fn_push_undef(recce)
        end
        local stack = recce.v.stack
        local values = recce:values()
        local result_ix = recce.v.step.result
        local next_ix = marpa.sv.top_index(values) + 1;
        values[next_ix] = stack[result_ix + rhs_ix]
        return -2
    end

```

#### Find current token literal

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

#### VM "push values" operation

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
            local stack = recce.v.stack
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

#### VM operation: push start location

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

#### VM operation: push length

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

#### VM operation: push G1 start location

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

#### VM operation: push G1 length

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

#### VM operation: push constant onto values array

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

#### VM operation: set the array blessing

The blessing is registered in a constant, and this operation
lets the VM know its index.  The index is cleared at the beginning
of every sequence of operations

```
    -- luatangle: section+ VM operations
    function op_fn_bless(recce, blessing_ix)
        recce.v.step.blessing_ix = blessing_ix
        return -2
    end

```

#### VM operation: result is array

This operation tells the VM that the current `values` array
is the result of this sequence of operations.

```
    -- luatangle: section+ VM operations
    function op_fn_result_is_array(recce)
        local blessing_ix = recce.v.step.blessing_ix
        local values = recce:values()
        if blessing_ix then
          local constants = recce:constants()
          local blessing = constants[blessing_ix]
          marpa.sv.bless(values, blessing)
        end
        local stack = recce.v.stack
        local result_ix = recce.v.step.result
        stack[result_ix] = values
        return -1
    end

```

#### VM operation: callback

Tells the VM to create a callback to Perl, with
the `values` array as an argument.
The return value of 3 is a vestige of an earlier
implementation, which returned the size of the
`values` array.

```
    -- luatangle: section+ VM operations
    function op_fn_callback(recce)
        local step_type = recce.v.step.type
        if step_type ~= 'MARPA_STEP_RULE'
            and step_type ~= 'MARPA_STEP_NULLING_SYMBOL'
        then
            io.stderr:write(
                'Internal error: callback for wrong step type ',
                step_type
            )
            os.exit(false)
        end
        local blessing_ix = recce.v.step.blessing_ix
        if blessing_ix then
          local values = recce:values()
          local constants = recce:constants()
          local blessing = constants[blessing_ix]
          marpa.sv.bless(values, blessing)
        end
        return 3
    end

```

### Run the virtual machine

```
    -- luatangle: section+ VM operations
    function do_ops(recce, ops)
        local op_ix = 1
        while op_ix <= #ops do
            local op_code = ops[op_ix]
            if op_code == 0 then return -1 end
            if op_code ~= op_lua then
            end
            -- io.stderr:write('op_code: ', inspect(op_code), '\\n')
            -- io.stderr:write('op_lua: ', inspect(op_lua), '\\n')
            local fn_key = ops[op_ix+1]
            -- io.stderr:write('ops: ', inspect(ops), '\\n')
            -- io.stderr:write('fn_key: ', inspect(fn_key), '\\n')
            -- io.stderr:write('fn name: ', recce.op_fn_key[fn_key], '\\n')
            local arg = ops[op_ix+2]
            -- io.stderr:write('arg: ', inspect(arg), '\\n')
            if recce.trace_values >= 3 then
              local queue = recce.trace_values_queue
              local tag = 'starting lua op'
              queue[#queue+1] = {'starting op', recce.v.step.type, 'lua'}
              queue[#queue+1] = {tag, recce.v.step.type, recce.op_fn_key[fn_key]}
              -- io.stderr:write('starting op: ', inspect(recce))
            end
            op_fn = recce[fn_key]
            result = op_fn(recce, arg)
            if result >= -1 then return result end
            op_ix = op_ix + 3
            end
        return -1
    end

```

### Find and perform the VM operations

Determine the appropriate VM operations for this
step, and perform them.
Return codes are

* 3 for callback;
* 1 for return the step type;
* 0 for return an empty list;
* -1 for return 'trace';
* -2 for no return.

The mnemonic for these codes is
that they represent the size of the list returned to Perl,
with "trace" and "do not return" being special cases.

```
    -- luatangle: section+ VM operations
    function find_and_do_ops(recce)
        local ops = {}
        recce:step()
        if recce.v.step.type == 'MARPA_STEP_INACTIVE' then
            return 0
        end
        if recce.v.step.type == 'MARPA_STEP_RULE' then
            ops = recce.rule_semantics[recce.v.step.rule]
            if not ops then
                ops = recce.rule_semantics.default
            end
            goto DO_OPS
        end
        if recce.v.step.type == 'MARPA_STEP_TOKEN' then
            ops = recce.token_semantics[recce.v.step.symbol]
            if not ops then
                ops = recce.token_semantics.default
            end
            goto DO_OPS
        end
        if recce.v.step.type == 'MARPA_STEP_NULLING_SYMBOL' then
            ops = recce.nulling_semantics[recce.v.step.symbol]
            if not ops then
                ops = recce.nulling_semantics.default
            end
            goto DO_OPS
        end
        if true then return 1 end
        ::DO_OPS::
        if not ops then
            error(string.format('No semantics defined for %s', recce.v.step.type))
        end
        local do_ops_result = do_ops(recce, ops)
        local stack = recce.v.stack
        -- truncate stack
        local above_top = recce.v.step.result + 1
        for i = above_top,#stack do stack[i] = nil end
        if do_ops_result > 0 then return 3 end
        if #recce.trace_values_queue > 0 then return -1 end
        return -2
    end

```


### VM-related utilities for use in the Perl code

The following operations are used by the higher-level Perl code
to set and discover various Lua values.

#### Return operation key given its name

```
    -- luatangle: section Utilities for Perl code
    function get_op_fn_key_by_name(recce, op_name_sv)
        local op_name = tostring(op_name_sv)
        return recce.op_fn_key[op_name]
    end

```

#### Return operation name given its key

```
    -- luatangle: section+ Utilities for Perl code
    function get_op_fn_name_by_key(recce, op_key_sv)
        local op_key = op_key_sv + 0
        return recce.op_fn_key[op_key]
    end

```

#### Register a constant

Register a constant, returning its key.

```
    -- luatangle: section+ Utilities for Perl code
    function constant_register(recce, constant_sv)
        local constants = recce:constants()
        local next_constant_key = marpa.sv.top_index(constants) + 1
        constants[next_constant_key] = constant_sv
        return next_constant_key
    end

```

#### Register semantics for a token

Register the semantic operations, `ops`, for the token
whose id is `id`.

```
    -- luatangle: section+ Utilities for Perl code
    function token_register(...)
        local args = {...}
        local recce = args[1]
        local id = args[2]+0
        local ops = {}
        for ix = 3, #args do
            ops[#ops+1] = args[ix]+0
        end
        recce.token_semantics[id] = ops
    end

```

#### Register semantics for a nulling symbol

Register the semantic operations, `ops`, for the nulling symbol
whose id is `id`.

```
    -- luatangle: section+ Utilities for Perl code
    function nulling_register(...)
        local args = {...}
        local recce = args[1]
        local id = args[2]+0
        local ops = {}
        for ix = 3, #args do
            ops[#ops+1] = args[ix]+0
        end
        recce.nulling_semantics[id] = ops
    end

```

#### Register semantics for a rule

Register the semantic operations, `ops`, for the rule
whose id is `id`.

```
    -- luatangle: section+ Utilities for Perl code
    function rule_register(...)
        local args = {...}
        local recce = args[1]
        local id = args[2]+0
        local ops = {}
        for ix = 3, #args do
            ops[#ops+1] = args[ix]+0
        end
        recce.rule_semantics[id] = ops
    end

```

#### Return the top index of the stack

```
    -- luatangle: section+ Utilities for Perl code
    function stack_top_index(recce)
        return recce.v.step.result
    end

```

#### Return the value of a stack entry

```
    -- luatangle: section+ Utilities for Perl code
    function stack_get(recce, ix)
        local stack = recce.v.stack
        return stack[ix+0]
    end

```

#### Set the value of a stack entry

```
    -- luatangle: section+ Utilities for Perl code
    function stack_set(recce, ix, v)
        local stack = recce.v.stack
        stack[ix+0] = v
    end

```

## The Kollos valuator

The "valuator" portion of Kollos produces the
value of a
Kollos parse.

### Initialize a valuator

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

        -- we record these values to set the defaults, below
        local op_bail_key = op_fn_create("bail", op_fn_bail)
        local result_is_constant_key = op_fn_create("result_is_constant", op_fn_result_is_constant)
        local result_is_undef_key = op_fn_create("result_is_undef", op_fn_result_is_undef)
        local result_is_token_value_key = op_fn_create("result_is_token_value", op_fn_result_is_token_value)

        -- these values are accessed only by name
        op_fn_create("debug", op_fn_debug)
        op_fn_create("noop", op_fn_noop)
        op_fn_create("bless", op_fn_bless)
        op_fn_create("callback", op_fn_callback)
        op_fn_create("result_is_n_of_rhs", op_fn_result_is_n_of_rhs)
        op_fn_create("result_is_n_of_sequence", op_fn_result_is_n_of_sequence)
        op_fn_create("result_is_array", op_fn_result_is_array)
        op_fn_create("push_constant", op_fn_push_constant)
        op_fn_create("push_g1_length", op_fn_push_g1_length)
        op_fn_create("push_g1_start", op_fn_push_g1_start)
        op_fn_create("push_length", op_fn_push_length)
        op_fn_create("push_start", op_fn_push_start)
        op_fn_create("push_one", op_fn_push_one)
        op_fn_create("push_undef", op_fn_push_undef)
        op_fn_create("push_values", op_fn_push_values)

        -- io.stderr:write('Initializing rule semantics to {}\n')
        recce.rule_semantics = {}
        recce.token_semantics = {}
        recce.nulling_semantics = {}

        recce.nulling_semantics.default = { marpa.ops.lua, result_is_undef_key, op_bail_key, 0 }
        recce.token_semantics.default = { marpa.ops.lua, result_is_token_value_key, op_bail_key, 0 }
        recce.rule_semantics.default = { marpa.ops.lua, result_is_undef_key, op_bail_key, 0 }

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
        recce.v.stack = {}
    end

```

### Reset a valuator

A function to be called whenever a valuator is reset.

```

    -- luatangle: section value_reset()

    function value_reset(recce)
        recce.op_fn_key = nil
        -- io.stderr:write('Initializing rule semantics to nil\n')
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
    -- luatangle: insert Utilities for Perl code

    return "OK"

    -- luatangle: write stdout main

    -- vim: set expandtab shiftwidth=4:
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

<!--
vim: expandtab shiftwidth=4:
-->
