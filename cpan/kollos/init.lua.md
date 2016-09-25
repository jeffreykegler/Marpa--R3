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

## Kollos object

```
    -- miranda: section C function declarations
    struct kollos_extraspace {
        int ref_count;
        int (*warn)(const char* format, ...);
    };

```

## Kollos Lua interpreter

A Kollos object is a Lua interpreter.
It keeps its own reference count, in its Lua registry.
`kollos_newstate()`,
the constructor, creates one reference
and gives its caller ownership.
When
the reference count falls to zero,
the interpreter (Kollos object) is destroyed.

```

    -- miranda: section+ C function declarations
    lua_State* kollos_newstate(void);
    -- miranda: section Lua interpreter management
    static int default_warn(const char *format, ...);
    lua_State* kollos_newstate(void)
    {
        int base_of_stack;
        struct kollos_extraspace *p_extra;
        lua_State *const L = marpa_luaL_newstate ();

        if (!L) return NULL;
        base_of_stack = marpa_lua_gettop(L);
        p_extra = malloc(sizeof(struct kollos_extraspace));
        *(struct kollos_extraspace **)marpa_lua_getextraspace(L) = p_extra;
        p_extra->ref_count = 1;
        p_extra->warn = &default_warn;
        marpa_luaL_openlibs (L);    /* open libraries */
        /* Lua stack: [] */
        marpa_luaopen_kollos(L); /* Open kollos library */
        /* Lua stack: [ kollos_table ] */
        marpa_lua_setglobal(L, "kollos");
        /* Lua stack: [] */
        marpa_lua_settop(L, base_of_stack);
        return L;
    }

```

Add a recce to the Kollos object, returning its
"lua_id".
The inner SLR C structure is passed in for now,
because it uses a lot of PERL/XS data structures.

```
    -- miranda: section+ C function declarations
    #define MT_NAME_RECCE "Marpa_recce"
    int kollos_recce_new(lua_State* L, void* slr);
    -- miranda: section+ Lua interpreter management
    int kollos_recce_new(lua_State* L, void* slr)
    {
        int lua_id;
        const int base_of_stack = marpa_lua_gettop(L);
        marpa_lua_checkstack(L, 20);
        /* Lua stack: [] */
        /* Create a table for this recce */
        marpa_lua_newtable(L);
        /* Lua stack: [ recce_table ] */
        /* No lock held -- SLR must delete recce table in its */
        /*   destructor. */
        /* Set the metatable for the recce table */
        marpa_luaL_setmetatable(L, MT_NAME_RECCE);
        /* Lua stack: [ recce_table ] */

        /* recce_table.ref_count = 1 */
        marpa_lua_pushinteger(L, 1);
        /* Lua stack: [recce_table, ref_count ] */
        marpa_lua_setfield(L, -2, "ref_count");
        /* Lua stack: [ recce_table ] */

        /* recce_table.lud = slr */
        marpa_lua_pushlightuserdata(L, slr);
        /* Lua stack: [ recce_table, lud ] */
        marpa_lua_setfield(L, -2, "lud");
        /* Lua stack: [ recce_table ] */
        /* Set up a reference to this recce table in the Lua state
         * registry.
         */
        lua_id = marpa_luaL_ref(L, LUA_REGISTRYINDEX);
        marpa_lua_settop(L, base_of_stack);
        return lua_id;
    }
```

```
    -- miranda: section+ Lua interpreter management
    static int default_warn(const char *format, ...)
    {
       va_list args;
       va_start (args, format);
       vfprintf (stderr, format, args);
       va_end (args);
       fputs("\n", stderr);
       return 1;
    }
```

`kollos_refinc()`
creates a new reference
to a Kollos interpreter,
and takes ownership of it.

```

    -- miranda: section+ C function declarations
    void kollos_refinc(lua_State* L);
    -- miranda: section+ Lua interpreter management
    void kollos_refinc(lua_State* L)
    {
        struct kollos_extraspace *p_extra =
            *(struct kollos_extraspace **)marpa_lua_getextraspace(L);
        p_extra->ref_count++;
    }

```

Give up ownership of a reference to a Kollos interpreter.
Deletes the interpreter if the reference count drops to zero.

```

    -- miranda: section+ C function declarations
    void kollos_refdec(lua_State* L);
    -- miranda: section+ Lua interpreter management
    void kollos_refdec(lua_State* L)
    {
        struct kollos_extraspace *p_extra =
            *(struct kollos_extraspace **)marpa_lua_getextraspace(L);
        p_extra->ref_count--;
        if (p_extra->ref_count <= 0) {
           marpa_lua_close(L);
           free(p_extra);
        }
    }

```

Set the warning function of the Kollos interpreter.

```

    -- miranda: section+ C function declarations
    void kollos_warn_set(lua_State* L, int (*warn)(const char * format, ...));
    -- miranda: section+ Lua interpreter management
    void kollos_warn_set(lua_State* L, int (*warn)(const char * format, ...))
    {
       struct kollos_extraspace *p_extra =
           *(struct kollos_extraspace **)marpa_lua_getextraspace(L);
       p_extra->warn = warn;
    }

```

Write a warning message using Kollos's warning handler.

```

    -- miranda: section+ C function declarations
    void kollos_warn(lua_State* L, const char * format, ...);
    -- miranda: section+ Lua interpreter management
    void kollos_warn(lua_State* L, const char * format, ...)
    {
       va_list args;
       struct kollos_extraspace *p_extra;
       va_start (args, format);

       p_extra = *(struct kollos_extraspace **)marpa_lua_getextraspace(L);
       (*p_extra->warn)(format, args);
       va_end (args);
    }

```

`kollos_tblrefinc()`
creates a new reference
to a Kollos interpreter,
and takes ownership of it.

```

    -- miranda: section+ C function declarations
    void kollos_tblrefinc(lua_State* L, int lua_ref);
    -- miranda: section+ Lua interpreter management
    void kollos_tblrefinc(lua_State* L, int lua_ref)
    {
        const int base_of_stack = marpa_lua_gettop(L);
        lua_Integer refcount;
        /* Lua stack [] */
        marpa_lua_geti(L, LUA_REGISTRYINDEX, lua_ref);
        /* Lua stack [ table ] */
        marpa_lua_getfield(L, -1, "ref_count");
        /* Lua stack [ table, ref_count ] */
        refcount = marpa_lua_tointeger(L, -1);
        refcount += 1;
        marpa_lua_pushinteger(L, refcount);
        /* Lua stack [ table, ref_count, new_ref_count ] */
        marpa_lua_setfield(L, -2, "ref_count");
        marpa_lua_settop(L, base_of_stack);
        /* Lua stack [ ] */
    }

```

Give up ownership of a reference to a Kollos interpreter.
Deletes the interpreter if the reference count drops to zero.

```

    -- miranda: section+ C function declarations
    void kollos_tblrefdec(lua_State* L, int lua_ref);
    -- miranda: section+ Lua interpreter management
    void kollos_tblrefdec(lua_State* L, int lua_ref)
    {
        const int base_of_stack = marpa_lua_gettop(L);
        lua_Integer refcount;
        marpa_lua_geti(L, LUA_REGISTRYINDEX, lua_ref);
        /* Lua stack [ table ] */
        marpa_lua_getfield(L, -1, "ref_count");
        refcount = marpa_lua_tointeger(L, -1);
        /* Lua stack [ table, ref_count ] */
        if (refcount <= 1) {
           /* default_warn("kollos_tblrefdec lua_ref %d ref_count %d, will unref", lua_ref, refcount); */
           marpa_luaL_unref(L, LUA_REGISTRYINDEX, lua_ref);
           /* marpa_lua_gc(L, LUA_GCCOLLECT, 0); */
           /* marpa_lua_gc(L, LUA_GCCOLLECT, 0); */
           marpa_lua_settop(L, base_of_stack);
           return;
        }
        refcount -= 1;
        marpa_lua_pushinteger(L, refcount);
        /* Lua stack [ table, ref_count, new_ref_count ] */
        marpa_lua_setfield(L, -2, "ref_count");
        /* default_warn("kollos_tblrefdec lua_ref %d to ref_count %d", lua_ref, refcount); */
        marpa_lua_settop(L, base_of_stack);
        /* Lua stack [ ] */
    }

```

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
    -- miranda: section VM operations

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
    -- miranda: section+ VM operations

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
    -- miranda: section+ VM operations

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
    -- miranda: section+ VM operations

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
    -- miranda: section+ VM operations

    function op_fn_result_is_token_value(recce)
        if recce.v.step.type ~= 'MARPA_STEP_TOKEN' then
          return op_fn_result_is_undef(recce)
        end
        local stack = recce.v.stack
        local result_ix = recce.v.step.result
        stack[result_ix] = current_token_literal(recce)
        if recce.trace_values > 0 then
          local top_of_queue = #recce.trace_values_queue;
          local tag, token_sv
          recce.trace_values_queue[top_of_queue+1] =
             {tag, recce.v.step.type, recce.v.step.symbol, recce.v.step.value, token_sv};
             -- io.stderr:write('[step_type]: ', inspect(recce))
        end
        return -1
    end

```

#### VM "result is N of RHS" operation

```
    -- miranda: section+ VM operations
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
    -- miranda: section+ VM operations
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
    -- miranda: section+ VM operations
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
    -- miranda: section+ VM operations

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
    -- miranda: section+ VM operations

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
    -- miranda: section+ VM operations
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
    -- miranda: section+ VM operations

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
    -- miranda: section+ VM operations
    function op_fn_push_start(recce)
        local values = recce:values()
        local start_es = recce.v.step.start_es_id
        local end_es = recce.v.step.es_id
        local next_ix = marpa.sv.top_index(values) + 1;
        local start, l = recce:span(start_es, end_es)
        local _
        values[next_ix], _ = recce:span(start_es, end_es)
        return -2
    end

```

#### VM operation: push length

The length of the current step in input location terms --
that is, in terms of the input string

```
    -- miranda: section+ VM operations
    function op_fn_push_length(recce)
        local values = recce:values()
        local start_es = recce.v.step.start_es_id
        local end_es = recce.v.step.es_id
        local next_ix = marpa.sv.top_index(values) + 1;
        local _
        _, values[next_ix] = recce:span(start_es, end_es)
        return -2
    end

```

#### VM operation: push G1 start location

The current start location in G1 location terms -- that is,
in terms of G1 Earley sets.

```
    -- miranda: section+ VM operations
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
    -- miranda: section+ VM operations
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
    -- miranda: section+ VM operations
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
    -- miranda: section+ VM operations
    function op_fn_bless(recce, blessing_ix)
        recce.v.step.blessing_ix = blessing_ix
        return -2
    end

```

#### VM operation: result is array

This operation tells the VM that the current `values` array
is the result of this sequence of operations.

```
    -- miranda: section+ VM operations
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
    -- miranda: section+ VM operations
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
    -- miranda: section+ VM operations
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
            local op_fn = recce[fn_key]
            local result = op_fn(recce, arg)
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
    -- miranda: section+ VM operations
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
    -- miranda: section Utilities for Perl code
    function get_op_fn_key_by_name(recce, op_name_sv)
        local op_name = tostring(op_name_sv)
        return recce.op_fn_key[op_name]
    end

```

#### Return operation name given its key

```
    -- miranda: section+ Utilities for Perl code
    function get_op_fn_name_by_key(recce, op_key_sv)
        local op_key = op_key_sv + 0
        return recce.op_fn_key[op_key]
    end

```

#### Register a constant

Register a constant, returning its key.

```
    -- miranda: section+ Utilities for Perl code
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
    -- miranda: section+ Utilities for Perl code
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
    -- miranda: section+ Utilities for Perl code
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
    -- miranda: section+ Utilities for Perl code
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
    -- miranda: section+ Utilities for Perl code
    function stack_top_index(recce)
        return recce.v.step.result
    end

```

#### Return the value of a stack entry

```
    -- miranda: section+ Utilities for Perl code
    function stack_get(recce, ix)
        local stack = recce.v.stack
        return stack[ix+0]
    end

```

#### Set the value of a stack entry

```
    -- miranda: section+ Utilities for Perl code
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
    -- miranda: section value_init()

    function value_init(recce, trace_values)

        if recce.v then return end

        recce.op_fn_key = {}

        local function op_fn_create(name, fn)
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

    -- miranda: section value_reset()

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

## Libmarpa interface

```
    --[==[ miranda: exec
    local function c_type_of_libmarpa_type(libmarpa_type)
        if (libmarpa_type == 'int') then return 'int' end
        if (libmarpa_type == 'Marpa_Assertion_ID') then return 'int' end
        if (libmarpa_type == 'Marpa_Earley_Item_ID') then return 'int' end
        if (libmarpa_type == 'Marpa_AHM_ID') then return 'int' end
        if (libmarpa_type == 'Marpa_IRL_ID') then return 'int' end
        if (libmarpa_type == 'Marpa_NSY_ID') then return 'int' end
        if (libmarpa_type == 'Marpa_Or_Node_ID') then return 'int' end
        if (libmarpa_type == 'Marpa_And_Node_ID') then return 'int' end
        if (libmarpa_type == 'Marpa_Rank') then return 'int' end
        if (libmarpa_type == 'Marpa_Rule_ID') then return 'int' end
        if (libmarpa_type == 'Marpa_Symbol_ID') then return 'int' end
        if (libmarpa_type == 'Marpa_Earley_Set_ID') then return 'int' end
        return "!UNIMPLEMENTED!";
    end

    local libmarpa_class_type = {
      g = "Marpa_Grammar",
      r = "Marpa_Recognizer",
      b = "Marpa_Bocage",
      o = "Marpa_Order",
      t = "Marpa_Tree",
      v = "Marpa_Value",
    };

    local libmarpa_class_name = {
      g = "grammar",
      r = "recce",
      b = "bocage",
      o = "order",
      t = "tree",
      v = "value",
    };

    local check_for_table_template = [=[
    !!INDENT!!check_libmarpa_table(L,
    !!INDENT!!  "!!FUNCNAME!!",
    !!INDENT!!  self_stack_ix,
    !!INDENT!!  "!!CLASS_NAME!!"
    !!INDENT!!);
    ]=]

    function wrap_libmarpa_method(signature)
       local arg_count = math.floor(#signature/2)
       local function_name = signature[1]
       local unprefixed_name = string.gsub(function_name, "^[_]?marpa_", "");
       local class_letter = string.gsub(unprefixed_name, "_.*$", "");
       local wrapper_name = "wrap_" .. unprefixed_name;
       local result = {}
       result[#result+1] = "static int " .. wrapper_name .. "(lua_State *L)\n"
       result[#result+1] = "{\n"
       result[#result+1] = "  ", libmarpa_class_type[class_letter], " self;\n"
       result[#result+1] = "  const int self_stack_ix = 1;\n"
       result[#result+1] = "  Marpa_Grammar grammar;\n"
       for arg_ix = 1, arg_count do
         local arg_type = signature[arg_ix*2]
         local arg_name = signature[1 + arg_ix*2]
         result[#result+1] = "  ", arg_type, " ", arg_name, ";\n"
       end
       result[#result+1] = "  int result;\n\n"

       -- These wrappers will not be external interfaces
       -- so eventually they will run unsafe.
       -- But for now we check arguments, and we'll leave
       -- the possibility for debugging
       local safe = true;
       if (safe) then
          result[#result+1] = "  if (1) {\n"

          local check_for_table =
            string.gsub(check_for_table_template, "!!FUNCNAME!!", wrapper_name);
          check_for_table =
            string.gsub(check_for_table, "!!INDENT!!", "    ");
          check_for_table =
            string.gsub(check_for_table, "!!CLASS_NAME!!", libmarpa_class_name[class_letter])
          result[#result+1] = check_for_table
          -- I do not get the values from the integer checks,
          -- because this code
          -- will be turned off most of the time
          for arg_ix = 1, arg_count do
              result[#result+1] = "    marpa_luaL_checkinteger(L, ", (arg_ix+1), ");\n"
          end
          result[#result+1] = "  }\n"
       end -- if (!unsafe)

       for arg_ix = arg_count, 1, -1 do
         local arg_type = signature[arg_ix*2]
         local arg_name = signature[1 + arg_ix*2]
         local c_type = c_type_of_libmarpa_type(arg_type)
         assert(c_type == "int", ("type " .. arg_type .. " not implemented"))
         result[#result+1] = "{\n"
         result[#result+1] = "  const lua_Integer this_arg = marpa_lua_tointeger(L, -1);\n"

         -- Each call checks that its arguments are in range
         -- the point of this check is to make sure that C's integer conversions
         -- do not change the value before the call gets it.
         -- We assume that all types involved are at least 32 bits and signed, so that
         -- values from -2^30 to 2^30 will be unchanged by any conversions.
         result[#result+1] = [[  marpa_luaL_argcheck(L, (-(2^30) <= this_arg && this_arg <= (2^30)), -1, "argument out of range");]], "\n"

         result[#result+1] = string.format("  %s = (%s)this_arg;\n", arg_name, arg_type)
         result[#result+1] = "  marpa_lua_pop(L, 1);\n"
         result[#result+1] = "}\n"
       end

       result[#result+1] = '  marpa_lua_getfield (L, -1, "_libmarpa");\n'
       -- stack is [ self, self_ud ]
       local cast_to_ptr_to_class_type = "(" ..  libmarpa_class_type[class_letter] .. "*)"
       result[#result+1] = "  self = *", cast_to_ptr_to_class_type, "marpa_lua_touserdata (L, -1);\n"
       result[#result+1] = "  marpa_lua_pop(L, 1);\n"
       -- stack is [ self ]

       result[#result+1] = '  marpa_lua_getfield (L, -1, "_libmarpa_g");\n'
       -- stack is [ self, grammar_ud ]
       result[#result+1] = "  grammar = *(Marpa_Grammar*)marpa_lua_touserdata (L, -1);\n"
       result[#result+1] = "  marpa_lua_pop(L, 1);\n"
       -- stack is [ self ]

       -- assumes converting result to int is safe and right thing to do
       -- if that assumption is wrong, generate the wrapper by hand
       result[#result+1] = "  result = (int)", function_name, "(self\n"
       for arg_ix = 1, arg_count do
         local arg_name = signature[1 + arg_ix*2]
         result[#result+1] = "     ," .. arg_name .. "\n"
       end
       result[#result+1] = "    );\n"
       result[#result+1] = "  if (result == -1) { marpa_lua_pushnil(L); return 1; }\n"
       result[#result+1] = "  if (result < -1) {\n"
       result[#result+1] = "    Marpa_Error_Code marpa_error = marpa_g_error(grammar, NULL);\n"
       result[#result+1] = "    int throw_flag;\n"
       local wrapper_name_as_c_string = '"' .. wrapper_name .. '()"'
       result[#result+1] = '    marpa_lua_getfield (L, -1, "throw");\n'
       -- stack is [ self, throw_flag ]
       result[#result+1] = "    throw_flag = marpa_lua_toboolean (L, -1);\n"
       result[#result+1] = '    if (throw_flag) {\n'
       result[#result+1] = '        kollos_throw( L, marpa_error, ', wrapper_name_as_c_string, ');\n'
       result[#result+1] = '    }\n'
       result[#result+1] = "  }\n"
       result[#result+1] = "  marpa_lua_pushinteger(L, (lua_Integer)result);\n"
       result[#result+1] = "  return 1;\n"
       result[#result+1] = "}\n\n"

       return table.concat(result, '')

    end

    -- end of exec
    ]==]
```

### Standard template methods

Here are the meta-programmed wrappers --
This is Lua code which writes the C code based on
a "signature" for the wrapper

This meta-programming does not attempt to work for
all of the wrappers.  It works only when
1. The number of arguments is fixed.
2. Their type is from a fixed list.
3. Converting the return value to int is a good thing to do.
4. Non-negative return values indicate success
5. Return values less than -1 indicate failure
6. Return values less than -1 set the error code
7. Return value of -1 is "soft" and returning nil is
      the right thing to do

On those methods for which the wrapper requirements are "bent"
a little bit:

* marpa_r_alternative() -- generates events
Returns an error code.  Since these are always non-negative, from
the wrapper's point of view, marpa_r_alternative() always succeeds.

* marpa_r_earleme_complete() -- generates events

```

  -- miranda: section standard libmarpa wrappers
  --[==[ miranda: exec
  wrap_libmarpa_method{"marpa_g_completion_symbol_activate", "Marpa_Symbol_ID", "sym_id", "int", "activate"}
  wrap_libmarpa_method{"marpa_g_error_clear"}
  wrap_libmarpa_method{"marpa_g_event_count"}
  wrap_libmarpa_method{"marpa_g_force_valued"}
  wrap_libmarpa_method{"marpa_g_has_cycle"}
  wrap_libmarpa_method{"marpa_g_highest_rule_id"}
  wrap_libmarpa_method{"marpa_g_highest_symbol_id"}
  wrap_libmarpa_method{"marpa_g_is_precomputed"}
  wrap_libmarpa_method{"marpa_g_nulled_symbol_activate", "Marpa_Symbol_ID", "sym_id", "int", "activate"}
  wrap_libmarpa_method{"marpa_g_precompute"}
  wrap_libmarpa_method{"marpa_g_prediction_symbol_activate", "Marpa_Symbol_ID", "sym_id", "int", "activate"}
  wrap_libmarpa_method{"marpa_g_rule_is_accessible", "Marpa_Rule_ID", "rule_id"}
  wrap_libmarpa_method{"marpa_g_rule_is_loop", "Marpa_Rule_ID", "rule_id"}
  wrap_libmarpa_method{"marpa_g_rule_is_nullable", "Marpa_Rule_ID", "rule_id"}
  wrap_libmarpa_method{"marpa_g_rule_is_nulling", "Marpa_Rule_ID", "rule_id"}
  wrap_libmarpa_method{"marpa_g_rule_is_productive", "Marpa_Rule_ID", "rule_id"}
  wrap_libmarpa_method{"marpa_g_rule_is_proper_separation", "Marpa_Rule_ID", "rule_id"}
  wrap_libmarpa_method{"marpa_g_rule_length", "Marpa_Rule_ID", "rule_id"}
  wrap_libmarpa_method{"marpa_g_rule_lhs", "Marpa_Rule_ID", "rule_id"}
  wrap_libmarpa_method{"marpa_g_rule_null_high", "Marpa_Rule_ID", "rule_id"}
  wrap_libmarpa_method{"marpa_g_rule_null_high_set", "Marpa_Rule_ID", "rule_id", "int", "flag"}
  wrap_libmarpa_method{"marpa_g_rule_rhs", "Marpa_Rule_ID", "rule_id", "int", "ix"}
  wrap_libmarpa_method{"marpa_g_sequence_min", "Marpa_Rule_ID", "rule_id"}
  wrap_libmarpa_method{"marpa_g_sequence_separator", "Marpa_Rule_ID", "rule_id"}
  wrap_libmarpa_method{"marpa_g_start_symbol"}
  wrap_libmarpa_method{"marpa_g_start_symbol_set", "Marpa_Symbol_ID", "id"}
  wrap_libmarpa_method{"marpa_g_symbol_is_accessible", "Marpa_Symbol_ID", "symbol_id"}
  wrap_libmarpa_method{"marpa_g_symbol_is_completion_event", "Marpa_Symbol_ID", "sym_id"}
  wrap_libmarpa_method{"marpa_g_symbol_is_completion_event_set", "Marpa_Symbol_ID", "sym_id", "int", "value"}
  wrap_libmarpa_method{"marpa_g_symbol_is_counted", "Marpa_Symbol_ID", "symbol_id"}
  wrap_libmarpa_method{"marpa_g_symbol_is_nullable", "Marpa_Symbol_ID", "symbol_id"}
  wrap_libmarpa_method{"marpa_g_symbol_is_nulled_event", "Marpa_Symbol_ID", "sym_id"}
  wrap_libmarpa_method{"marpa_g_symbol_is_nulled_event_set", "Marpa_Symbol_ID", "sym_id", "int", "value"}
  wrap_libmarpa_method{"marpa_g_symbol_is_nulling", "Marpa_Symbol_ID", "symbol_id"}
  wrap_libmarpa_method{"marpa_g_symbol_is_prediction_event", "Marpa_Symbol_ID", "sym_id"}
  wrap_libmarpa_method{"marpa_g_symbol_is_prediction_event_set", "Marpa_Symbol_ID", "sym_id", "int", "value"}
  wrap_libmarpa_method{"marpa_g_symbol_is_productive", "Marpa_Symbol_ID", "symbol_id"}
  wrap_libmarpa_method{"marpa_g_symbol_is_start", "Marpa_Symbol_ID", "symbol_id"}
  wrap_libmarpa_method{"marpa_g_symbol_is_terminal", "Marpa_Symbol_ID", "symbol_id"}
  wrap_libmarpa_method{"marpa_g_symbol_is_terminal_set", "Marpa_Symbol_ID", "symbol_id", "int", "boolean"}
  wrap_libmarpa_method{"marpa_g_symbol_is_valued", "Marpa_Symbol_ID", "symbol_id"}
  wrap_libmarpa_method{"marpa_g_symbol_is_valued_set", "Marpa_Symbol_ID", "symbol_id", "int", "boolean"}
  wrap_libmarpa_method{"marpa_g_symbol_new"}
  wrap_libmarpa_method{"marpa_g_zwa_new", "int", "default_value"}
  wrap_libmarpa_method{"marpa_g_zwa_place", "Marpa_Assertion_ID", "zwaid", "Marpa_Rule_ID", "xrl_id", "int", "rhs_ix"}
  wrap_libmarpa_method{"marpa_r_completion_symbol_activate", "Marpa_Symbol_ID", "sym_id", "int", "reactivate"}
  wrap_libmarpa_method{"marpa_r_alternative", "Marpa_Symbol_ID", "token", "int", "value", "int", "length"}, -- See above
  wrap_libmarpa_method{"marpa_r_current_earleme"}
  wrap_libmarpa_method{"marpa_r_earleme_complete"}, -- See note above
  wrap_libmarpa_method{"marpa_r_earleme", "Marpa_Earley_Set_ID", "ordinal"}
  wrap_libmarpa_method{"marpa_r_earley_item_warning_threshold"}
  wrap_libmarpa_method{"marpa_r_earley_item_warning_threshold_set", "int", "too_many_earley_items"}
  wrap_libmarpa_method{"marpa_r_earley_set_value", "Marpa_Earley_Set_ID", "ordinal"}
  wrap_libmarpa_method{"marpa_r_expected_symbol_event_set", "Marpa_Symbol_ID", "xsyid", "int", "value"}
  wrap_libmarpa_method{"marpa_r_furthest_earleme"}
  wrap_libmarpa_method{"marpa_r_is_exhausted"}
  wrap_libmarpa_method{"marpa_r_latest_earley_set"}
  wrap_libmarpa_method{"marpa_r_latest_earley_set_value_set", "int", "value"}
  wrap_libmarpa_method{"marpa_r_nulled_symbol_activate", "Marpa_Symbol_ID", "sym_id", "int", "reactivate"}
  wrap_libmarpa_method{"marpa_r_prediction_symbol_activate", "Marpa_Symbol_ID", "sym_id", "int", "reactivate"}
  wrap_libmarpa_method{"marpa_r_progress_report_finish"}
  wrap_libmarpa_method{"marpa_r_progress_report_start", "Marpa_Earley_Set_ID", "ordinal"}
  wrap_libmarpa_method{"marpa_r_start_input"}
  wrap_libmarpa_method{"marpa_r_terminal_is_expected", "Marpa_Symbol_ID", "xsyid"}
  wrap_libmarpa_method{"marpa_r_zwa_default", "Marpa_Assertion_ID", "zwaid"}
  wrap_libmarpa_method{"marpa_r_zwa_default_set", "Marpa_Assertion_ID", "zwaid", "int", "default_value"}
  wrap_libmarpa_method{"marpa_b_ambiguity_metric"}
  wrap_libmarpa_method{"marpa_b_is_null"}
  wrap_libmarpa_method{"marpa_o_ambiguity_metric"}
  wrap_libmarpa_method{"marpa_o_high_rank_only_set", "int", "flag"}
  wrap_libmarpa_method{"marpa_o_high_rank_only"}
  wrap_libmarpa_method{"marpa_o_is_null"}
  wrap_libmarpa_method{"marpa_o_rank"}
  wrap_libmarpa_method{"marpa_t_next"}
  wrap_libmarpa_method{"marpa_t_parse_count"}
  wrap_libmarpa_method{"marpa_v_valued_force"}
  wrap_libmarpa_method{"marpa_v_rule_is_valued_set", "Marpa_Rule_ID", "symbol_id", "int", "value"}
  wrap_libmarpa_method{"marpa_v_symbol_is_valued_set", "Marpa_Symbol_ID", "symbol_id", "int", "value"}
  wrap_libmarpa_method{"_marpa_g_ahm_count"}
  wrap_libmarpa_method{"_marpa_g_ahm_irl", "Marpa_AHM_ID", "item_id"}
  wrap_libmarpa_method{"_marpa_g_ahm_position", "Marpa_AHM_ID", "item_id"}
  wrap_libmarpa_method{"_marpa_g_ahm_postdot", "Marpa_AHM_ID", "item_id"}
  wrap_libmarpa_method{"_marpa_g_irl_count"}
  wrap_libmarpa_method{"_marpa_g_irl_is_virtual_rhs", "Marpa_IRL_ID", "irl_id"}
  wrap_libmarpa_method{"_marpa_g_irl_length", "Marpa_IRL_ID", "irl_id"}
  wrap_libmarpa_method{"_marpa_g_irl_lhs", "Marpa_IRL_ID", "irl_id"}
  wrap_libmarpa_method{"_marpa_g_irl_rank", "Marpa_IRL_ID", "irl_id"}
  wrap_libmarpa_method{"_marpa_g_irl_rhs", "Marpa_IRL_ID", "irl_id", "int", "ix"}
  wrap_libmarpa_method{"_marpa_g_irl_semantic_equivalent", "Marpa_IRL_ID", "irl_id"}
  wrap_libmarpa_method{"_marpa_g_nsy_count"}
  wrap_libmarpa_method{"_marpa_g_nsy_is_lhs", "Marpa_NSY_ID", "nsy_id"}
  wrap_libmarpa_method{"_marpa_g_nsy_is_nulling", "Marpa_NSY_ID", "nsy_id"}
  wrap_libmarpa_method{"_marpa_g_nsy_is_semantic", "Marpa_NSY_ID", "nsy_id"}
  wrap_libmarpa_method{"_marpa_g_nsy_is_start", "Marpa_NSY_ID", "nsy_id"}
  wrap_libmarpa_method{"_marpa_g_nsy_lhs_xrl", "Marpa_NSY_ID", "nsy_id"}
  wrap_libmarpa_method{"_marpa_g_nsy_rank", "Marpa_NSY_ID", "nsy_id"}
  wrap_libmarpa_method{"_marpa_g_nsy_xrl_offset", "Marpa_NSY_ID", "nsy_id"}
  wrap_libmarpa_method{"_marpa_g_real_symbol_count", "Marpa_IRL_ID", "irl_id"}
  wrap_libmarpa_method{"_marpa_g_rule_is_keep_separation", "Marpa_Rule_ID", "rule_id"}
  wrap_libmarpa_method{"_marpa_g_rule_is_used", "Marpa_Rule_ID", "rule_id"}
  wrap_libmarpa_method{"_marpa_g_source_xrl", "Marpa_IRL_ID", "irl_id"}
  wrap_libmarpa_method{"_marpa_g_source_xsy", "Marpa_NSY_ID", "nsy_id"}
  wrap_libmarpa_method{"_marpa_g_virtual_end", "Marpa_IRL_ID", "irl_id"}
  wrap_libmarpa_method{"_marpa_g_virtual_start", "Marpa_IRL_ID", "irl_id"}
  wrap_libmarpa_method{"_marpa_g_xsy_nsy", "Marpa_Symbol_ID", "symid"}
  wrap_libmarpa_method{"_marpa_g_xsy_nulling_nsy", "Marpa_Symbol_ID", "symid"}
  wrap_libmarpa_method{"_marpa_r_earley_item_origin"}
  wrap_libmarpa_method{"_marpa_r_earley_item_trace", "Marpa_Earley_Item_ID", "item_id"}
  wrap_libmarpa_method{"_marpa_r_earley_set_size", "Marpa_Earley_Set_ID", "set_id"}
  wrap_libmarpa_method{"_marpa_r_earley_set_trace", "Marpa_Earley_Set_ID", "set_id"}
  wrap_libmarpa_method{"_marpa_r_first_completion_link_trace"}
  wrap_libmarpa_method{"_marpa_r_first_leo_link_trace"}
  wrap_libmarpa_method{"_marpa_r_first_postdot_item_trace"}
  wrap_libmarpa_method{"_marpa_r_first_token_link_trace"}
  wrap_libmarpa_method{"_marpa_r_is_use_leo"}
  wrap_libmarpa_method{"_marpa_r_is_use_leo_set", "int", "value"}
  wrap_libmarpa_method{"_marpa_r_leo_base_origin"}
  wrap_libmarpa_method{"_marpa_r_leo_base_state"}
  wrap_libmarpa_method{"_marpa_r_leo_predecessor_symbol"}
  wrap_libmarpa_method{"_marpa_r_next_completion_link_trace"}
  wrap_libmarpa_method{"_marpa_r_next_leo_link_trace"}
  wrap_libmarpa_method{"_marpa_r_next_postdot_item_trace"}
  wrap_libmarpa_method{"_marpa_r_next_token_link_trace"}
  wrap_libmarpa_method{"_marpa_r_postdot_item_symbol"}
  wrap_libmarpa_method{"_marpa_r_postdot_symbol_trace", "Marpa_Symbol_ID", "symid"}
  wrap_libmarpa_method{"_marpa_r_source_leo_transition_symbol"}
  wrap_libmarpa_method{"_marpa_r_source_middle"}
  wrap_libmarpa_method{"_marpa_r_source_predecessor_state"}
  -- wrap_libmarpa_method{"_marpa_r_source_token", "int", "*value_p"}
  wrap_libmarpa_method{"_marpa_r_trace_earley_set"}
  wrap_libmarpa_method{"_marpa_b_and_node_cause", "Marpa_And_Node_ID", "ordinal"}
  wrap_libmarpa_method{"_marpa_b_and_node_count"}
  wrap_libmarpa_method{"_marpa_b_and_node_middle", "Marpa_And_Node_ID", "and_node_id"}
  wrap_libmarpa_method{"_marpa_b_and_node_parent", "Marpa_And_Node_ID", "and_node_id"}
  wrap_libmarpa_method{"_marpa_b_and_node_predecessor", "Marpa_And_Node_ID", "ordinal"}
  wrap_libmarpa_method{"_marpa_b_and_node_symbol", "Marpa_And_Node_ID", "and_node_id"}
  wrap_libmarpa_method{"_marpa_b_or_node_and_count", "Marpa_Or_Node_ID", "or_node_id"}
  wrap_libmarpa_method{"_marpa_b_or_node_first_and", "Marpa_Or_Node_ID", "ordinal"}
  wrap_libmarpa_method{"_marpa_b_or_node_irl", "Marpa_Or_Node_ID", "ordinal"}
  wrap_libmarpa_method{"_marpa_b_or_node_is_semantic", "Marpa_Or_Node_ID", "or_node_id"}
  wrap_libmarpa_method{"_marpa_b_or_node_is_whole", "Marpa_Or_Node_ID", "or_node_id"}
  wrap_libmarpa_method{"_marpa_b_or_node_last_and", "Marpa_Or_Node_ID", "ordinal"}
  wrap_libmarpa_method{"_marpa_b_or_node_origin", "Marpa_Or_Node_ID", "ordinal"}
  wrap_libmarpa_method{"_marpa_b_or_node_position", "Marpa_Or_Node_ID", "ordinal"}
  wrap_libmarpa_method{"_marpa_b_or_node_set", "Marpa_Or_Node_ID", "ordinal"}
  wrap_libmarpa_method{"_marpa_b_top_or_node"}
  wrap_libmarpa_method{"_marpa_o_and_order_get", "Marpa_Or_Node_ID", "or_node_id", "int", "ix"}
  wrap_libmarpa_method{"_marpa_o_or_node_and_node_count", "Marpa_Or_Node_ID", "or_node_id"}
  wrap_libmarpa_method{"_marpa_o_or_node_and_node_id_by_ix", "Marpa_Or_Node_ID", "or_node_id", "int", "ix"}
  ]==]
  -- end of exec

```

# The main Lua code file

```
    -- miranda: section main
    -- miranda: insert legal preliminaries
    -- miranda: insert luacheck declarations
    -- miranda: insert enforce strict globals
    -- miranda: insert VM operations
    -- miranda: insert value_init()
    -- miranda: insert value_reset()
    -- miranda: insert Utilities for Perl code
    -- miranda: insert standard libmarpa wrappers

    return "OK"

    -- vim: set expandtab shiftwidth=4:
```

## Preliminaries to the main code

Licensing, etc.

```

    -- miranda: section legal preliminaries

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
```

Luacheck declarations

```

    -- miranda: section luacheck declarations

    -- luacheck: std lua53
    -- luacheck: globals bit
    -- luacheck: globals __FILE__ __LINE__

```

Set "strict" globals, using code taken from strict.lua.

```

    -- miranda: section enforce strict globals
    do
        local mt = getmetatable(_G)
        if mt == nil then
          mt = {}
          setmetatable(_G, mt)
        end

        mt.__declared = {}

        local function what ()
          local d = debug.getinfo(3, "S")
          return d and d.what or "C"
        end

        mt.__newindex = function (t, n, v)
          if not mt.__declared[n] then
            local w = what()
            if w ~= "main" and w ~= "C" then
              error("assign to undeclared variable '"..n.."'", 2)
            end
            mt.__declared[n] = true
          end
          rawset(t, n, v)
        end

        mt.__index = function (t, n)
          if not mt.__declared[n] and what() ~= "C" then
            error("variable '"..n.."' is not declared", 2)
          end
          return rawget(t, n)
        end
    end

```

# The Kollos C code file

```
    -- miranda: section kollos_c
    -- miranda: language c
    -- miranda: insert preliminaries to the c library code
    -- miranda: insert kollos Lua library
    -- miranda: insert Lua interpreter management
    /* vim: set expandtab shiftwidth=4: */
```

```
    -- miranda: section kollos Lua library
    static int marpa_luaopen_kollos(lua_State *L)
    {
        /* Create the main kollos object */
        marpa_lua_newtable(L);
        /* [ kollos ] */
        return 1;
    }
```

# Preliminaries to the C library code
```
    -- miranda: section preliminaries to the c library code
    /*
    ** Permission is hereby granted, free of charge, to any person obtaining
    ** a copy of this software and associated documentation files (the
    ** "Software"), to deal in the Software without restriction, including
    ** without limitation the rights to use, copy, modify, merge, publish,
    ** distribute, sublicense, and/or sell copies of the Software, and to
    ** permit persons to whom the Software is furnished to do so, subject to
    ** the following conditions:
    **
    ** The above copyright notice and this permission notice shall be
    ** included in all copies or substantial portions of the Software.
    **
    ** THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    ** EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    ** MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    ** IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    ** CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    ** TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    ** SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    **
    ** [ MIT license: http://www.opensource.org/licenses/mit-license.php ]
    */

    /* EDITS IN THIS FILE WILL BE LOST
     * This file is auto-generated.
     */

    #include "marpa.h"
    #include "lua.h"
    #include "lauxlib.h"
    #include "kollos.h"

    #undef UNUSED
    #if     __GNUC__ >  2 || (__GNUC__ == 2 && __GNUC_MINOR__ >  4)
    #define UNUSED __attribute__((__unused__))
    #else
    #define UNUSED
    #endif

    #if defined(_MSC_VER)
    #define inline __inline
    #define __PRETTY_FUNCTION__ __FUNCTION__
    #endif
```

# The Kollos C header file

```
    -- miranda: section kollos_h
    -- miranda: language c
    -- miranda: insert preliminary comments of the c header file

    #ifndef KOLLOS_H
    #define KOLLOS_H

    #include "lua.h"
    #include "lauxlib.h"
    #include "lualib.h"

    -- miranda: insert C function declarations

    #endif

    /* vim: set expandtab shiftwidth=4: */
```

# Preliminaries to the C header file
```
    -- miranda: section preliminary comments of the c header file

    /*
     * Copyright 2016 Jeffrey Kegler
     * Permission is hereby granted, free of charge, to any person obtaining a
     * copy of this software and associated documentation files (the "Software"),
     * to deal in the Software without restriction, including without limitation
     * the rights to use, copy, modify, merge, publish, distribute, sublicense,
     * and/or sell copies of the Software, and to permit persons to whom the
     * Software is furnished to do so, subject to the following conditions:
     *
     * The above copyright notice and this permission notice shall be included
     * in all copies or substantial portions of the Software.
     *
     * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
     * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
     * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
     * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
     * OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
     * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
     * OTHER DEALINGS IN THE SOFTWARE.
     */

    /* EDITS IN THIS FILE WILL BE LOST
     * This file is auto-generated.
     */

```

<!--
vim: expandtab shiftwidth=4:
-->
