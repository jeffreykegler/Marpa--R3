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
* [Kollos object](#kollos-object)
* [Kollos Lua interpreter](#kollos-lua-interpreter)
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
* [Libmarpa interface](#libmarpa-interface)
  * [Standard template methods](#standard-template-methods)
* [The main Lua code file](#the-main-lua-code-file)
  * [Preliminaries to the main code](#preliminaries-to-the-main-code)
* [The Kollos C code file](#the-kollos-c-code-file)
  * [Stuff from okollos](#stuff-from-okollos)
  * [`marpa_luaopen_kollos`](#marpa-luaopen-kollos)
  * [Preliminaries to the C library code](#preliminaries-to-the-c-library-code)
* [The Kollos C header file](#the-kollos-c-header-file)
  * [Preliminaries to the C header file](#preliminaries-to-the-c-header-file)
* [Meta-coding utilities](#meta-coding-utilities)
  * [Metacode execution sequence](#metacode-execution-sequence)
  * [Dedent method](#dedent-method)
  * [`c_safe_string` method](#c-safe-string-method)
  * [Meta code argument processing](#meta-code-argument-processing)

## About Kollos

This is the code for Kollos, the "middle layer" of Marpa.
Below it is Libmarpa, a library written in
the C language which contains the actual parse engine.
Above it is code in a higher level language -- at this point Perl.

This document is evolving.  Most of the "middle layer" is still
in the Perl code or in the Perl XS, and not represented here.
This document only contains those portions converted to Lua or
to Lua-centeric C code.

The intent is that eventually
all the code in this file will be "pure"
Kollos -- no Perl knowledge.
That is not the case at the moment.

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
        marpa_lua_pushboolean(L, 1);
        marpa_lua_setglobal(L, "throw");
        /* Lua stack: [] */
        marpa_lua_settop(L, base_of_stack);
        return L;
    }

```

```
    -- miranda: section+ lua interpreter management
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
    -- miranda: section+ lua interpreter management
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
    -- miranda: section+ lua interpreter management
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
    -- miranda: section+ lua interpreter management
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
    -- miranda: section+ lua interpreter management
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

## Kollos registry objects

A Kollos registry object is an object kept in its
registry.
These generated ID's which allow them to be identified
safely to non-Lua code.
They have increment and decrement methods.

These increment and decrement methods are intended only
for non-Lua code.
They make it possible
for the non-Lua code to be sure that the Lua
registry object exists for as long as they
require it.

Lua code should not use the reference counter.
Lua code
should simply copy the table object -- in Lua this
is a reference and Lua's GC will do the right thing.

`kollos_robrefinc()`
creates a new reference
to a Kollos registry object,
and takes ownership of it.

```

    -- miranda: section+ C function declarations
    void kollos_robrefinc(lua_State* L, int lua_ref);
    -- miranda: section+ lua interpreter management
    void kollos_robrefinc(lua_State* L, int lua_ref)
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

Give up ownership of a reference to a Kollos registry object.
Deletes the interpreter if the reference count drops to zero.

```

    -- miranda: section+ C function declarations
    void kollos_robrefdec(lua_State* L, int lua_ref);
    -- miranda: section+ lua interpreter management
    void kollos_robrefdec(lua_State* L, int lua_ref)
    {
        const int base_of_stack = marpa_lua_gettop(L);
        lua_Integer refcount;
        marpa_lua_geti(L, LUA_REGISTRYINDEX, lua_ref);
        /* Lua stack [ table ] */
        marpa_lua_getfield(L, -1, "ref_count");
        refcount = marpa_lua_tointeger(L, -1);
        /* Lua stack [ table, ref_count ] */
        if (refcount <= 1) {
           /* default_warn("kollos_robrefdec lua_ref %d ref_count %d, will unref", lua_ref, refcount); */
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
        /* default_warn("kollos_robrefdec lua_ref %d to ref_count %d", lua_ref, refcount); */
        marpa_lua_settop(L, base_of_stack);
        /* Lua stack [ ] */
    }

```

## Kollos recognizer registry object

Add a recce to the Kollos object, returning its
"lua_id".
The inner SLR C structure is passed in for now,
because it uses a lot of PERL/XS data structures.

```
    -- miranda: section+ C function declarations
    #define MT_NAME_RECCE "Marpa_recce"
    int kollos_slr_new(lua_State* L, void* slr, int slg_ref);
    -- miranda: section+ lua interpreter management
    int kollos_slr_new(lua_State* L, void* slr, int slg_ref)
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

        /* recce_table.slg = slg */
        marpa_lua_rawgeti (L, LUA_REGISTRYINDEX, slg_ref);
        /* Lua stack: [ recce_table, slg_table ] */
        marpa_lua_setfield(L, -2, "slg");
        /* Lua stack: [ recce_table ] */

        /* Set up a reference to this recce table in the Lua state
         * registry.
         */
        lua_id = marpa_luaL_ref(L, LUA_REGISTRYINDEX);
        marpa_lua_settop(L, base_of_stack);
        return lua_id;
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
at index `recce.lmw_v.step.result`.

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
at index `recce.lmw_v.step.result`.

#### VM "result is undef" operation

Perhaps the simplest operation.
The result of the semantics is a Perl undef.

```
    -- miranda: section+ VM operations

    function op_fn_result_is_undef(recce)
        local stack = recce.lmw_v.stack
        stack[recce.lmw_v.step.result] = marpa.sv.undef()
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
        if recce.lmw_v.step.type ~= 'MARPA_STEP_TOKEN' then
          return op_fn_result_is_undef(recce)
        end
        local stack = recce.lmw_v.stack
        local result_ix = recce.lmw_v.step.result
        stack[result_ix] = current_token_literal(recce)
        if recce.trace_values > 0 then
          local top_of_queue = #recce.trace_values_queue;
          local tag, token_sv
          recce.trace_values_queue[top_of_queue+1] =
             {tag, recce.lmw_v.step.type, recce.lmw_v.step.symbol, recce.lmw_v.step.value, token_sv};
             -- io.stderr:write('[step_type]: ', inspect(recce))
        end
        return -1
    end

```

#### VM "result is N of RHS" operation

```
    -- miranda: section+ VM operations
    function op_fn_result_is_n_of_rhs(recce, rhs_ix)
        if recce.lmw_v.step.type ~= 'MARPA_STEP_RULE' then
          return op_fn_result_is_undef(recce)
        end
        local stack = recce.lmw_v.stack
        local result_ix = recce.lmw_v.step.result
        repeat
            if rhs_ix == 0 then break end
            local fetch_ix = result_ix + rhs_ix
            if fetch_ix > recce.lmw_v.step.arg_n then
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
        if recce.lmw_v.step.type ~= 'MARPA_STEP_RULE' then
          return op_fn_result_is_undef(recce)
        end
        local result_ix = recce.lmw_v.step.result
        local fetch_ix = result_ix + item_ix * 2
        if fetch_ix > recce.lmw_v.step.arg_n then
          return op_fn_result_is_undef(recce)
        end
        local stack = recce.lmw_v.stack
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
        local stack = recce.lmw_v.stack
        local result_ix = recce.lmw_v.step.result
        stack[result_ix] = constant
        if recce.trace_values > 0 and recce.lmw_v.step.type == 'MARPA_STEP_TOKEN' then
            local top_of_queue = #recce.trace_values_queue
            recce.trace_values_queue[top_of_queue+1] =
                { "valuator unknown step", recce.lmw_v.step.type, recce.token, constant}
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

    function op_fn_push_undef(recce, dummy, new_values)
        local next_ix = marpa.sv.top_index(new_values) + 1;
        new_values[next_ix] = marpa.sv.undef()
        return -2
    end

```

#### VM "push one" operation

Push one of the RHS child values onto the values array.

```
    -- miranda: section+ VM operations

    function op_fn_push_one(recce, rhs_ix, new_values)
        if recce.lmw_v.step.type ~= 'MARPA_STEP_RULE' then
          return op_fn_push_undef(recce, nil, new_values)
        end
        local stack = recce.lmw_v.stack
        local result_ix = recce.lmw_v.step.result
        local next_ix = marpa.sv.top_index(new_values) + 1;
        new_values[next_ix] = stack[result_ix + rhs_ix]
        return -2
    end

```

#### Find current token literal

`current_token_literal` return the literal
equivalent of the current token.
It assumes that there *is* a current token,
that is,
it assumes that the caller has ensured that
`recce.lmw_v.step.type ~= 'MARPA_STEP_TOKEN'`.

```
    -- miranda: section+ VM operations
    function current_token_literal(recce)
      if recce.token_is_literal == recce.lmw_v.step.value then
          local start_es = recce.lmw_v.step.start_es_id
          local end_es = recce.lmw_v.step.es_id
          return recce:literal_of_es_span(start_es, end_es)
      end
      return recce.token_values[recce.lmw_v.step.value]
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

    function op_fn_push_values(recce, increment, new_values)
        if recce.lmw_v.step.type == 'MARPA_STEP_TOKEN' then
            local next_ix = marpa.sv.top_index(new_values) + 1;
            new_values[next_ix] = current_token_literal(recce)
            return -2
        end
        if recce.lmw_v.step.type == 'MARPA_STEP_RULE' then
            local stack = recce.lmw_v.stack
            local arg_n = recce.lmw_v.step.arg_n
            local result_ix = recce.lmw_v.step.result
            local to_ix = marpa.sv.top_index(new_values) + 1;
            for from_ix = result_ix,arg_n,increment do
                new_values[to_ix] = stack[from_ix]
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
    function op_fn_push_start(recce, dummy, new_values)
        local start_es = recce.lmw_v.step.start_es_id
        local end_es = recce.lmw_v.step.es_id
        local start, l = recce:span(start_es, end_es)
        local next_ix = marpa.sv.top_index(new_values) + 1;
        local _
        new_values[next_ix], _ = recce:span(start_es, end_es)
        return -2
    end

```

#### VM operation: push length

The length of the current step in input location terms --
that is, in terms of the input string

```
    -- miranda: section+ VM operations
    function op_fn_push_length(recce, dummy, new_values)
        local start_es = recce.lmw_v.step.start_es_id
        local end_es = recce.lmw_v.step.es_id
        local next_ix = marpa.sv.top_index(new_values) + 1;
        local _
        _, new_values[next_ix] = recce:span(start_es, end_es)
        return -2
    end

```

#### VM operation: push G1 start location

The current start location in G1 location terms -- that is,
in terms of G1 Earley sets.

```
    -- miranda: section+ VM operations
    function op_fn_push_g1_start(recce, dummy, new_values)
        local next_ix = marpa.sv.top_index(new_values) + 1;
        new_values[next_ix] = recce.lmw_v.step.start_es_id
        return -2
    end

```

#### VM operation: push G1 length

The length of the current step in G1 terms --
that is, in terms of G1 Earley sets.

```
    -- miranda: section+ VM operations
    function op_fn_push_g1_length(recce, dummy, new_values)
        local next_ix = marpa.sv.top_index(new_values) + 1;
        new_values[next_ix] = (recce.lmw_v.step.es_id
            - recce.lmw_v.step.start_es_id) + 1
        return -2
    end

```

#### VM operation: push constant onto values array

```
    -- miranda: section+ VM operations
    function op_fn_push_constant(recce, constant_ix, new_values)
        local constants = recce:constants()
        -- io.stderr:write('constants: ', inspect(constants), "\n")
        -- io.stderr:write('constant_ix: ', constant_ix, "\n")
        -- io.stderr:write('constants top ix: ', marpa.sv.top_index(constants), "\n")

        local constant = constants[constant_ix]
        local next_ix = marpa.sv.top_index(new_values) + 1;
        new_values[next_ix] = constant
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
        recce.lmw_v.step.blessing_ix = blessing_ix
        return -2
    end

```

#### VM operation: result is array

This operation tells the VM that the current `values` array
is the result of this sequence of operations.

```
    -- miranda: section+ VM operations
    function op_fn_result_is_array(recce, dummy, new_values)
        local blessing_ix = recce.lmw_v.step.blessing_ix
        if blessing_ix then
          local constants = recce:constants()
          local blessing = constants[blessing_ix]
          marpa.sv.bless(new_values, blessing)
        end
        local stack = recce.lmw_v.stack
        local result_ix = recce.lmw_v.step.result
        stack[result_ix] = new_values
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
    function op_fn_callback(recce, dummy, new_values)
        local step_type = recce.lmw_v.step.type
        if step_type ~= 'MARPA_STEP_RULE'
            and step_type ~= 'MARPA_STEP_NULLING_SYMBOL'
        then
            io.stderr:write(
                'Internal error: callback for wrong step type ',
                step_type
            )
            os.exit(false)
        end
        local blessing_ix = recce.lmw_v.step.blessing_ix
        if blessing_ix then
          local constants = recce:constants()
          local blessing = constants[blessing_ix]
          marpa.sv.bless(new_values, blessing)
        end
        return 3
    end

```

### Run the virtual machine

```
    -- miranda: section+ VM operations
    function do_ops(recce, ops, new_values)
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
              queue[#queue+1] = {'starting op', recce.lmw_v.step.type, 'lua'}
              queue[#queue+1] = {tag, recce.lmw_v.step.type, recce.op_fn_key[fn_key]}
              -- io.stderr:write('starting op: ', inspect(recce))
            end
            local op_fn = recce[fn_key]
            local result = op_fn(recce, arg, new_values)
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
        recce.trace_values_queue = {}
        while true do
            local new_values = marpa.sv.av_new()
            local ops = {}
            recce:step()
            if recce.lmw_v.step.type == 'MARPA_STEP_INACTIVE' then
                return 0, new_values
            end
            if recce.lmw_v.step.type == 'MARPA_STEP_RULE' then
                ops = recce.rule_semantics[recce.lmw_v.step.rule]
                if not ops then
                    ops = recce.rule_semantics.default
                end
                goto DO_OPS
            end
            if recce.lmw_v.step.type == 'MARPA_STEP_TOKEN' then
                ops = recce.token_semantics[recce.lmw_v.step.symbol]
                if not ops then
                    ops = recce.token_semantics.default
                end
                goto DO_OPS
            end
            if recce.lmw_v.step.type == 'MARPA_STEP_NULLING_SYMBOL' then
                ops = recce.nulling_semantics[recce.lmw_v.step.symbol]
                if not ops then
                    ops = recce.nulling_semantics.default
                end
                goto DO_OPS
            end
            if true then return 1, new_values end
            ::DO_OPS::
            if not ops then
                error(string.format('No semantics defined for %s', recce.lmw_v.step.type))
            end
            local do_ops_result = do_ops(recce, ops, new_values)
            local stack = recce.lmw_v.stack
            -- truncate stack
            local above_top = recce.lmw_v.step.result + 1
            for i = above_top,#stack do stack[i] = nil end
            if do_ops_result > 0 then
                return 3, new_values
            end
            if #recce.trace_values_queue > 0 then return -1, new_values end
        end
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
        return recce.lmw_v.step.result
    end

```

#### Return the value of a stack entry

```
    -- miranda: section+ Utilities for Perl code
    function stack_get(recce, ix)
        local stack = recce.lmw_v.stack
        return stack[ix+0]
    end

```

#### Set the value of a stack entry

```
    -- miranda: section+ Utilities for Perl code
    function stack_set(recce, ix, v)
        local stack = recce.lmw_v.stack
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

        if not recce.lmw_v then
            error('no recce.lmw_v in value_init()')
        end

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

        recce.lmw_v = {}
        recce.lmw_v.stack = {}
    end

```

### Reset a valuator

A function to be called whenever a valuator is reset.
It should free all memory associated with the valuation.

```

    -- miranda: section valuation_reset()

    function valuation_reset(recce)
        recce.op_fn_key = nil
        -- io.stderr:write('Initializing rule semantics to nil\n')
        recce.rule_semantics = nil
        recce.token_semantics = nil
        recce.nulling_semantics = nil

        recce.trace_values = 0;
        recce.trace_values_queue = {};

        recce.lmw_b = nil
        recce.lmw_o = nil
        recce.lmw_t = nil
        recce.lmw_v = nil
        -- Libmarpa's tree pausing requires value objects to
        -- be destroyed quickly
        -- print("About to collect garbage")
        collectgarbage()
    end

```

### Create the thin valuator Lua class

```
  -- miranda: section create the thin valuator Lua class

  value_class = {}
  for k,v in pairs(kollos_c) do
    if k:match('^[_]?value') then
      local c_wrapper_name = k:gsub('value', '', 1)
      value_class[c_wrapper_name] = v
    end
  end
```

## Libmarpa interface

```
    --[==[ miranda: exec libmarpa interface globals

    function c_type_of_libmarpa_type(libmarpa_type)
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

    libmarpa_class_type = {
      g = "Marpa_Grammar",
      r = "Marpa_Recognizer",
      b = "Marpa_Bocage",
      o = "Marpa_Order",
      t = "Marpa_Tree",
      v = "Marpa_Value",
    };

    libmarpa_class_name = {
      g = "grammar",
      r = "recce",
      b = "bocage",
      o = "order",
      t = "tree",
      v = "value",
    };

    function wrap_libmarpa_method(signature)
       local arg_count = math.floor(#signature/2)
       local function_name = signature[1]
       local unprefixed_name = string.gsub(function_name, "^[_]?marpa_", "");
       local class_letter = string.gsub(unprefixed_name, "_.*$", "");
       local wrapper_name = "wrap_" .. unprefixed_name;
       local result = {}
       result[#result+1] = "static int " .. wrapper_name .. "(lua_State *L)\n"
       result[#result+1] = "{\n"
       result[#result+1] = "  " .. libmarpa_class_type[class_letter] .. " self;\n"
       result[#result+1] = "  const int self_stack_ix = 1;\n"
       for arg_ix = 1, arg_count do
         local arg_type = signature[arg_ix*2]
         local arg_name = signature[1 + arg_ix*2]
         result[#result+1] = "  " .. arg_type .. " " .. arg_name .. ";\n"
       end
       result[#result+1] = "  int result;\n\n"

       -- These wrappers will not be external interfaces
       -- so eventually they will run unsafe.
       -- But for now we check arguments, and we'll leave
       -- the possibility for debugging
       local safe = true;
       if (safe) then
          result[#result+1] = "  if (1) {\n"

          result[#result+1] = "    marpa_luaL_checktype(L, self_stack_ix, LUA_TTABLE);"
          -- I do not get the values from the integer checks,
          -- because this code
          -- will be turned off most of the time
          for arg_ix = 1, arg_count do
              result[#result+1] = "    marpa_luaL_checkinteger(L, " .. (arg_ix+1) .. ");\n"
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
       result[#result+1] = "  self = *" .. cast_to_ptr_to_class_type .. "marpa_lua_touserdata (L, -1);\n"
       result[#result+1] = "  marpa_lua_pop(L, 1);\n"
       -- stack is [ self ]

       -- assumes converting result to int is safe and right thing to do
       -- if that assumption is wrong, generate the wrapper by hand
       result[#result+1] = "  result = (int)" .. function_name .. "(self\n"
       for arg_ix = 1, arg_count do
         local arg_name = signature[1 + arg_ix*2]
         result[#result+1] = "     ," .. arg_name .. "\n"
       end
       result[#result+1] = "    );\n"
       result[#result+1] = "  if (result == -1) { marpa_lua_pushnil(L); return 1; }\n"
       result[#result+1] = "  if (result < -1) {\n"
       result[#result+1] = string.format(
                            "   libmarpa_error_handle(L, self_stack_ix, %q);\n",
                            wrapper_name .. '()')
       result[#result+1] = "    return 1;\n"
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
  --[==[ miranda: exec declare standard libmarpa wrappers
  signatures = {
    {"marpa_g_completion_symbol_activate", "Marpa_Symbol_ID", "sym_id", "int", "activate"},
    {"marpa_g_error_clear"},
    {"marpa_g_event_count"},
    {"marpa_g_force_valued"},
    {"marpa_g_has_cycle"},
    {"marpa_g_highest_rule_id"},
    {"marpa_g_highest_symbol_id"},
    {"marpa_g_is_precomputed"},
    {"marpa_g_nulled_symbol_activate", "Marpa_Symbol_ID", "sym_id", "int", "activate"},
    {"marpa_g_precompute"},
    {"marpa_g_prediction_symbol_activate", "Marpa_Symbol_ID", "sym_id", "int", "activate"},
    {"marpa_g_rule_is_accessible", "Marpa_Rule_ID", "rule_id"},
    {"marpa_g_rule_is_loop", "Marpa_Rule_ID", "rule_id"},
    {"marpa_g_rule_is_nullable", "Marpa_Rule_ID", "rule_id"},
    {"marpa_g_rule_is_nulling", "Marpa_Rule_ID", "rule_id"},
    {"marpa_g_rule_is_productive", "Marpa_Rule_ID", "rule_id"},
    {"marpa_g_rule_is_proper_separation", "Marpa_Rule_ID", "rule_id"},
    {"marpa_g_rule_length", "Marpa_Rule_ID", "rule_id"},
    {"marpa_g_rule_lhs", "Marpa_Rule_ID", "rule_id"},
    {"marpa_g_rule_null_high", "Marpa_Rule_ID", "rule_id"},
    {"marpa_g_rule_null_high_set", "Marpa_Rule_ID", "rule_id", "int", "flag"},
    {"marpa_g_rule_rhs", "Marpa_Rule_ID", "rule_id", "int", "ix"},
    {"marpa_g_sequence_min", "Marpa_Rule_ID", "rule_id"},
    {"marpa_g_sequence_separator", "Marpa_Rule_ID", "rule_id"},
    {"marpa_g_start_symbol"},
    {"marpa_g_start_symbol_set", "Marpa_Symbol_ID", "id"},
    {"marpa_g_symbol_is_accessible", "Marpa_Symbol_ID", "symbol_id"},
    {"marpa_g_symbol_is_completion_event", "Marpa_Symbol_ID", "sym_id"},
    {"marpa_g_symbol_is_completion_event_set", "Marpa_Symbol_ID", "sym_id", "int", "value"},
    {"marpa_g_symbol_is_counted", "Marpa_Symbol_ID", "symbol_id"},
    {"marpa_g_symbol_is_nullable", "Marpa_Symbol_ID", "symbol_id"},
    {"marpa_g_symbol_is_nulled_event", "Marpa_Symbol_ID", "sym_id"},
    {"marpa_g_symbol_is_nulled_event_set", "Marpa_Symbol_ID", "sym_id", "int", "value"},
    {"marpa_g_symbol_is_nulling", "Marpa_Symbol_ID", "symbol_id"},
    {"marpa_g_symbol_is_prediction_event", "Marpa_Symbol_ID", "sym_id"},
    {"marpa_g_symbol_is_prediction_event_set", "Marpa_Symbol_ID", "sym_id", "int", "value"},
    {"marpa_g_symbol_is_productive", "Marpa_Symbol_ID", "symbol_id"},
    {"marpa_g_symbol_is_start", "Marpa_Symbol_ID", "symbol_id"},
    {"marpa_g_symbol_is_terminal", "Marpa_Symbol_ID", "symbol_id"},
    {"marpa_g_symbol_is_terminal_set", "Marpa_Symbol_ID", "symbol_id", "int", "boolean"},
    {"marpa_g_symbol_is_valued", "Marpa_Symbol_ID", "symbol_id"},
    {"marpa_g_symbol_is_valued_set", "Marpa_Symbol_ID", "symbol_id", "int", "boolean"},
    {"marpa_g_symbol_new"},
    {"marpa_g_zwa_new", "int", "default_value"},
    {"marpa_g_zwa_place", "Marpa_Assertion_ID", "zwaid", "Marpa_Rule_ID", "xrl_id", "int", "rhs_ix"},
    {"marpa_r_completion_symbol_activate", "Marpa_Symbol_ID", "sym_id", "int", "reactivate"},
    {"marpa_r_alternative", "Marpa_Symbol_ID", "token", "int", "value", "int", "length"}, -- See above,
    {"marpa_r_current_earleme"},
    {"marpa_r_earleme_complete"}, -- See note above,
    {"marpa_r_earleme", "Marpa_Earley_Set_ID", "ordinal"},
    {"marpa_r_earley_item_warning_threshold"},
    {"marpa_r_earley_item_warning_threshold_set", "int", "too_many_earley_items"},
    {"marpa_r_earley_set_value", "Marpa_Earley_Set_ID", "ordinal"},
    {"marpa_r_expected_symbol_event_set", "Marpa_Symbol_ID", "xsyid", "int", "value"},
    {"marpa_r_furthest_earleme"},
    {"marpa_r_is_exhausted"},
    {"marpa_r_latest_earley_set"},
    {"marpa_r_latest_earley_set_value_set", "int", "value"},
    {"marpa_r_nulled_symbol_activate", "Marpa_Symbol_ID", "sym_id", "int", "reactivate"},
    {"marpa_r_prediction_symbol_activate", "Marpa_Symbol_ID", "sym_id", "int", "reactivate"},
    {"marpa_r_progress_report_finish"},
    {"marpa_r_progress_report_start", "Marpa_Earley_Set_ID", "ordinal"},
    {"marpa_r_start_input"},
    {"marpa_r_terminal_is_expected", "Marpa_Symbol_ID", "xsyid"},
    {"marpa_r_zwa_default", "Marpa_Assertion_ID", "zwaid"},
    {"marpa_r_zwa_default_set", "Marpa_Assertion_ID", "zwaid", "int", "default_value"},
    {"marpa_b_ambiguity_metric"},
    {"marpa_b_is_null"},
    {"marpa_o_ambiguity_metric"},
    {"marpa_o_high_rank_only_set", "int", "flag"},
    {"marpa_o_high_rank_only"},
    {"marpa_o_is_null"},
    {"marpa_o_rank"},
    {"marpa_t_next"},
    {"marpa_t_parse_count"},
    {"marpa_v_valued_force"},
    {"marpa_v_rule_is_valued_set", "Marpa_Rule_ID", "symbol_id", "int", "value"},
    {"marpa_v_symbol_is_valued_set", "Marpa_Symbol_ID", "symbol_id", "int", "value"},
    {"_marpa_g_ahm_count"},
    {"_marpa_g_ahm_irl", "Marpa_AHM_ID", "item_id"},
    {"_marpa_g_ahm_position", "Marpa_AHM_ID", "item_id"},
    {"_marpa_g_ahm_postdot", "Marpa_AHM_ID", "item_id"},
    {"_marpa_g_irl_count"},
    {"_marpa_g_irl_is_virtual_rhs", "Marpa_IRL_ID", "irl_id"},
    {"_marpa_g_irl_length", "Marpa_IRL_ID", "irl_id"},
    {"_marpa_g_irl_lhs", "Marpa_IRL_ID", "irl_id"},
    {"_marpa_g_irl_rank", "Marpa_IRL_ID", "irl_id"},
    {"_marpa_g_irl_rhs", "Marpa_IRL_ID", "irl_id", "int", "ix"},
    {"_marpa_g_irl_semantic_equivalent", "Marpa_IRL_ID", "irl_id"},
    {"_marpa_g_nsy_count"},
    {"_marpa_g_nsy_is_lhs", "Marpa_NSY_ID", "nsy_id"},
    {"_marpa_g_nsy_is_nulling", "Marpa_NSY_ID", "nsy_id"},
    {"_marpa_g_nsy_is_semantic", "Marpa_NSY_ID", "nsy_id"},
    {"_marpa_g_nsy_is_start", "Marpa_NSY_ID", "nsy_id"},
    {"_marpa_g_nsy_lhs_xrl", "Marpa_NSY_ID", "nsy_id"},
    {"_marpa_g_nsy_rank", "Marpa_NSY_ID", "nsy_id"},
    {"_marpa_g_nsy_xrl_offset", "Marpa_NSY_ID", "nsy_id"},
    {"_marpa_g_real_symbol_count", "Marpa_IRL_ID", "irl_id"},
    {"_marpa_g_rule_is_keep_separation", "Marpa_Rule_ID", "rule_id"},
    {"_marpa_g_rule_is_used", "Marpa_Rule_ID", "rule_id"},
    {"_marpa_g_source_xrl", "Marpa_IRL_ID", "irl_id"},
    {"_marpa_g_source_xsy", "Marpa_NSY_ID", "nsy_id"},
    {"_marpa_g_virtual_end", "Marpa_IRL_ID", "irl_id"},
    {"_marpa_g_virtual_start", "Marpa_IRL_ID", "irl_id"},
    {"_marpa_g_xsy_nsy", "Marpa_Symbol_ID", "symid"},
    {"_marpa_g_xsy_nulling_nsy", "Marpa_Symbol_ID", "symid"},
    {"_marpa_r_earley_item_origin"},
    {"_marpa_r_earley_item_trace", "Marpa_Earley_Item_ID", "item_id"},
    {"_marpa_r_earley_set_size", "Marpa_Earley_Set_ID", "set_id"},
    {"_marpa_r_earley_set_trace", "Marpa_Earley_Set_ID", "set_id"},
    {"_marpa_r_first_completion_link_trace"},
    {"_marpa_r_first_leo_link_trace"},
    {"_marpa_r_first_postdot_item_trace"},
    {"_marpa_r_first_token_link_trace"},
    {"_marpa_r_is_use_leo"},
    {"_marpa_r_is_use_leo_set", "int", "value"},
    {"_marpa_r_leo_base_origin"},
    {"_marpa_r_leo_base_state"},
    {"_marpa_r_leo_predecessor_symbol"},
    {"_marpa_r_next_completion_link_trace"},
    {"_marpa_r_next_leo_link_trace"},
    {"_marpa_r_next_postdot_item_trace"},
    {"_marpa_r_next_token_link_trace"},
    {"_marpa_r_postdot_item_symbol"},
    {"_marpa_r_postdot_symbol_trace", "Marpa_Symbol_ID", "symid"},
    {"_marpa_r_source_leo_transition_symbol"},
    {"_marpa_r_source_middle"},
    {"_marpa_r_source_predecessor_state"},
    -- {"_marpa_r_source_token", "int", "*value_p"},
    {"_marpa_r_trace_earley_set"},
    {"_marpa_b_and_node_cause", "Marpa_And_Node_ID", "ordinal"},
    {"_marpa_b_and_node_count"},
    {"_marpa_b_and_node_middle", "Marpa_And_Node_ID", "and_node_id"},
    {"_marpa_b_and_node_parent", "Marpa_And_Node_ID", "and_node_id"},
    {"_marpa_b_and_node_predecessor", "Marpa_And_Node_ID", "ordinal"},
    {"_marpa_b_and_node_symbol", "Marpa_And_Node_ID", "and_node_id"},
    {"_marpa_b_or_node_and_count", "Marpa_Or_Node_ID", "or_node_id"},
    {"_marpa_b_or_node_first_and", "Marpa_Or_Node_ID", "ordinal"},
    {"_marpa_b_or_node_irl", "Marpa_Or_Node_ID", "ordinal"},
    {"_marpa_b_or_node_is_semantic", "Marpa_Or_Node_ID", "or_node_id"},
    {"_marpa_b_or_node_is_whole", "Marpa_Or_Node_ID", "or_node_id"},
    {"_marpa_b_or_node_last_and", "Marpa_Or_Node_ID", "ordinal"},
    {"_marpa_b_or_node_origin", "Marpa_Or_Node_ID", "ordinal"},
    {"_marpa_b_or_node_position", "Marpa_Or_Node_ID", "ordinal"},
    {"_marpa_b_or_node_set", "Marpa_Or_Node_ID", "ordinal"},
    {"_marpa_b_top_or_node"},
    {"_marpa_o_and_order_get", "Marpa_Or_Node_ID", "or_node_id", "int", "ix"},
    {"_marpa_o_or_node_and_node_count", "Marpa_Or_Node_ID", "or_node_id"},
    {"_marpa_o_or_node_and_node_id_by_ix", "Marpa_Or_Node_ID", "or_node_id", "int", "ix"},
  }
  local result = {}
  for ix = 1,#signatures do
      result[#result+1] = wrap_libmarpa_method(signatures[ix])
  end
  return table.concat(result)
  -- end of exec
  ]==]

  -- miranda: section register standard libmarpa wrappers
  --[==[ miranda: exec register standard libmarpa wrappers
        local result = {}
        for ix = 1, #signatures do
           local signature = signatures[ix]
           local function_name = signature[1]
           local unprefixed_name = function_name:gsub("^[_]?marpa_", "", 1)
           local class_letter = unprefixed_name:gsub("_.*$", "", 1)
           local class_name = libmarpa_class_name[class_letter]
           local class_table_name = 'class_' .. class_name
           -- for example: marpa_lua_getfield(L, kollos_table_stack_ix, "class_grammar")
           result[#result+1] = string.format("  marpa_lua_getfield(L, kollos_table_stack_ix, %q);\n", class_table_name)
           local wrapper_name = "wrap_" .. unprefixed_name;
           -- for example: marpa_lua_pushcfunction(L, wrap_g_highest_rule_id)
           result[#result+1] = string.format("  marpa_lua_pushcfunction(L, %s);\n", wrapper_name)
           local classless_name = function_name:gsub("^[_]?marpa_[^_]*_", "")
           local initial_underscore = function_name:match('^_') and '_' or ''
           local field_name = initial_underscore .. classless_name
           -- for example: marpa_lua_setfield(L, -2, "highest_rule_id")
           result[#result+1] = string.format("  marpa_lua_setfield(L, -2, %q);\n", field_name)
           result[#result+1] = string.format("  marpa_lua_pop(L, 1);\n", field_name)
        end
        return table.concat(result)
  ]==]

  -- miranda: section create kollos class tables
  --[==[ miranda: exec create kollos class tables
        local result = {}
        for class_letter, class in pairs(libmarpa_class_name) do
           local class_table_name = 'class_' .. class
           local functions_to_register = class .. '_methods'
           result[#result+1] = string.format("  marpa_luaL_newlib(L, %s);\n", functions_to_register)
           result[#result+1] = "  marpa_lua_pushvalue(L, -1);\n"
           result[#result+1] = '  marpa_lua_setfield(L, -2, "__index");\n'
           result[#result+1] = string.format("  marpa_lua_setfield(L, kollos_table_stack_ix, %q);\n", class_table_name);
        end
        return table.concat(result)
  ]==]

```

## The main Lua code file

```
    -- miranda: section main
    -- miranda: insert legal preliminaries
    -- miranda: insert luacheck declarations
    -- miranda: insert enforce strict globals
    -- miranda: insert VM operations
    -- miranda: insert value_init()
    -- miranda: insert valuation_reset()
    -- miranda: insert Utilities for Perl code

    return "OK"

    -- vim: set expandtab shiftwidth=4:
```

### Preliminaries to the main code

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

## The Kollos C code file

```
    -- miranda: section kollos_c
    -- miranda: language c
    -- miranda: insert preliminaries to the c library code
    -- miranda: insert private error code declarations
    -- miranda: insert define error codes
    -- miranda: insert private event code declarations
    -- miranda: insert define event codes
    -- miranda: insert private step code declarations
    -- miranda: insert define step codes

    -- miranda: insert utilities from okollos.c.lua
    -- miranda: insert error object code from okollos.c.lua
    -- miranda: insert base error handlers
    -- miranda: insert error handlers
    -- miranda: insert event related code from okollos.c.lua
    -- miranda: insert step structure code
    -- miranda: insert metatable keys
    -- miranda: insert grammar object non-standard wrappers
    -- miranda: insert recognizer object non-standard wrappers
    -- miranda: insert bocage object non-standard wrappers
    -- miranda: insert order object non-standard wrappers
    -- miranda: insert tree object non-standard wrappers
    -- miranda: insert value object non-standard wrappers
    -- miranda: insert object userdata gc methods

    -- miranda: insert standard libmarpa wrappers
    -- miranda: insert define marpa_luaopen_kollos method
    -- miranda: insert lua interpreter management
    /* vim: set expandtab shiftwidth=4: */
```

### Stuff from okollos

```

    -- miranda: section utilities from okollos.c.lua

    /* For debugging */
    static void dump_stack (lua_State *L) UNUSED;
    static void dump_stack (lua_State *L) {
          int i;
          int top = marpa_lua_gettop(L);
          for (i = 1; i <= top; i++) {  /* repeat for each level */
            int t = marpa_lua_type(L, i);
            switch (t) {

              case LUA_TSTRING:  /* strings */
                printf("`%s'", marpa_lua_tostring(L, i));
                break;

              case LUA_TBOOLEAN:  /* booleans */
                printf(marpa_lua_toboolean(L, i) ? "true" : "false");
                break;

              case LUA_TNUMBER:  /* numbers */
                printf("%g", marpa_lua_tonumber(L, i));
                break;

              default:  /* other values */
                printf("%s", marpa_lua_typename(L, t));
                break;

            }
            printf("  ");  /* put a separator */
          }
          printf("\n");  /* end the listing */
    }

    static void dump_table(lua_State *L, int raw_table_index)
    {
        /* Original stack: [ ... ] */
        const int table_index = marpa_lua_absindex(L, raw_table_index);
        marpa_lua_pushnil(L);
        /* [ ..., nil ] */
        while (marpa_lua_next(L, table_index))
        {
            /* [ ..., key, value ] */
            const int value_stack_ix = marpa_lua_gettop(L);
            const int key_stack_ix = marpa_lua_gettop(L)+1;
            /* Copy the key, because marpa_lua_tostring() can be destructive */
            marpa_lua_pushvalue(L, -2);
            /* [ ..., key, value, key_copy ] */
            switch (marpa_lua_type(L, key_stack_ix)) {

              case LUA_TSTRING:  /* strings */
                printf("`%s'", marpa_lua_tostring(L, key_stack_ix));
                break;

              case LUA_TBOOLEAN:  /* booleans */
                printf(marpa_lua_toboolean(L, key_stack_ix) ? "true" : "false");
                break;

              case LUA_TNUMBER:  /* numbers */
                printf("%g", marpa_lua_tonumber(L, key_stack_ix));
                break;

              case LUA_TTABLE:  /* numbers */
                printf("table %s", marpa_lua_tostring(L, key_stack_ix));
                break;

              default:  /* other values */
                printf("%s", marpa_lua_typename(L, marpa_lua_type(L, key_stack_ix)));
                break;

            }
            printf(" -> ");  /* end the listing */
            switch (marpa_lua_type(L, value_stack_ix)) {

              case LUA_TSTRING:  /* strings */
                printf("`%s'", marpa_lua_tostring(L, value_stack_ix));
                break;

              case LUA_TBOOLEAN:  /* booleans */
                printf(marpa_lua_toboolean(L, value_stack_ix) ? "true" : "false");
                break;

              case LUA_TNUMBER:  /* numbers */
                printf("%g", marpa_lua_tonumber(L, value_stack_ix));
                break;

              case LUA_TTABLE:  /* numbers */
                printf("table %s", marpa_lua_tostring(L, value_stack_ix));
                break;

              default:  /* other values */
                printf("%s", marpa_lua_typename(L, marpa_lua_type(L, value_stack_ix)));
                break;

            }
            printf("\n");  /* end the listing */
            /* [ ..., key, value, key_copy ] */
            marpa_lua_pop(L, 2);
            /* [ ..., key ] */
        }
        /* Back to original stack: [ ... ] */
    }

    -- miranda: section private error code declarations
    /* error codes */

    static char kollos_error_mt_key;

    struct s_libmarpa_error_code {
       lua_Integer code;
       const char* mnemonic;
       const char* description;
    };

    -- miranda: section+ error object code from okollos.c.lua

    /* error objects
     *
     * There are written in C, but not because of efficiency --
     * efficiency is not needed, and in any case, when the overhead
     * from the use of the debug calls is considered, is not really
     * gained.
     *
     * The reason for the use of C is that the error routines
     * must be available for use inside both C and Lua, and must
     * also be available as early as possible during set up.
     * It's possible to run Lua code both inside C and early in
     * the set up, but the added unclarity, complexity from issues
     * of error reporting for the Lua code, etc., etc. mean that
     * it actually is easier to write them in C than in Lua.
     */

    -- miranda: section+ error object code from okollos.c.lua

    static inline const char* error_description_by_code(lua_Integer error_code)
    {
       if (error_code >= LIBMARPA_MIN_ERROR_CODE && error_code <= LIBMARPA_MAX_ERROR_CODE) {
           return marpa_error_codes[error_code-LIBMARPA_MIN_ERROR_CODE].description;
       }
       if (error_code >= KOLLOS_MIN_ERROR_CODE && error_code <= KOLLOS_MAX_ERROR_CODE) {
           return marpa_kollos_error_codes[error_code-KOLLOS_MIN_ERROR_CODE].description;
       }
       return (const char *)0;
    }

    static inline int l_error_description_by_code(lua_State* L)
    {
       const lua_Integer error_code = marpa_luaL_checkinteger(L, 1);
       const char* description = error_description_by_code(error_code);
       if (description)
       {
           marpa_lua_pushstring(L, description);
       } else {
           marpa_lua_pushfstring(L, "Unknown error code (%d)", error_code);
       }
       return 1;
    }

    static inline const char* error_name_by_code(lua_Integer error_code)
    {
       if (error_code >= LIBMARPA_MIN_ERROR_CODE && error_code <= LIBMARPA_MAX_ERROR_CODE) {
           return marpa_error_codes[error_code-LIBMARPA_MIN_ERROR_CODE].mnemonic;
       }
       if (error_code >= KOLLOS_MIN_ERROR_CODE && error_code <= KOLLOS_MAX_ERROR_CODE) {
           return marpa_kollos_error_codes[error_code-KOLLOS_MIN_ERROR_CODE].mnemonic;
       }
       return (const char *)0;
    }

    static inline int l_error_name_by_code(lua_State* L)
    {
       const lua_Integer error_code = marpa_luaL_checkinteger(L, 1);
       const char* mnemonic = error_name_by_code(error_code);
       if (mnemonic)
       {
           marpa_lua_pushstring(L, mnemonic);
       } else {
           marpa_lua_pushfstring(L, "Unknown error code (%d)", error_code);
       }
       return 1;
    }

    -- miranda: section private event code declarations

    struct s_libmarpa_event_code {
       lua_Integer code;
       const char* mnemonic;
       const char* description;
    };

    -- miranda: section+ event related code from okollos.c.lua

    static inline const char* event_description_by_code(lua_Integer event_code)
    {
       if (event_code >= LIBMARPA_MIN_EVENT_CODE && event_code <= LIBMARPA_MAX_EVENT_CODE) {
           return marpa_event_codes[event_code-LIBMARPA_MIN_EVENT_CODE].description;
       }
       return (const char *)0;
    }

    static inline int l_event_description_by_code(lua_State* L)
    {
       const lua_Integer event_code = marpa_luaL_checkinteger(L, 1);
       const char* description = event_description_by_code(event_code);
       if (description)
       {
           marpa_lua_pushstring(L, description);
       } else {
           marpa_lua_pushfstring(L, "Unknown event code (%d)", event_code);
       }
       return 1;
    }

    static inline const char* event_name_by_code(lua_Integer event_code)
    {
       if (event_code >= LIBMARPA_MIN_EVENT_CODE && event_code <= LIBMARPA_MAX_EVENT_CODE) {
           return marpa_event_codes[event_code-LIBMARPA_MIN_EVENT_CODE].mnemonic;
       }
       return (const char *)0;
    }

    static inline int l_event_name_by_code(lua_State* L)
    {
       const lua_Integer event_code = marpa_luaL_checkinteger(L, 1);
       const char* mnemonic = event_name_by_code(event_code);
       if (mnemonic)
       {
           marpa_lua_pushstring(L, mnemonic);
       } else {
           marpa_lua_pushfstring(L, "Unknown event code (%d)", event_code);
       }
       return 1;
    }

    -- miranda: section private step code declarations

    /* step codes */

    struct s_libmarpa_step_code {
       lua_Integer code;
       const char* mnemonic;
    };

    -- miranda: section+ step structure code

    static inline const char* step_name_by_code(lua_Integer step_code)
    {
       if (step_code >= MARPA_MIN_STEP_CODE && step_code <= MARPA_MAX_STEP_CODE) {
           return marpa_step_codes[step_code-MARPA_MIN_STEP_CODE].mnemonic;
       }
       return (const char *)0;
    }

    static inline int l_step_name_by_code(lua_State* L)
    {
       const lua_Integer step_code = marpa_luaL_checkinteger(L, 1);
       const char* mnemonic = step_name_by_code(step_code);
       if (mnemonic)
       {
           marpa_lua_pushstring(L, mnemonic);
       } else {
           marpa_lua_pushfstring(L, "Unknown step code (%d)", step_code);
       }
       return 1;
    }

    -- miranda: section+ metatable keys

    /* userdata metatable keys
       The contents of these locations are never examined.
       These location are used as a key in the Lua registry.
       This guarantees that the key will be unique
       within the Lua state.
    */
    static char kollos_g_ud_mt_key;
    static char kollos_r_ud_mt_key;
    static char kollos_b_ud_mt_key;
    static char kollos_o_ud_mt_key;
    static char kollos_t_ud_mt_key;
    static char kollos_v_ud_mt_key;

    -- miranda: section+ base error handlers

    /* Leaves the stack as before,
       except with the error object on top */
    static inline void push_error_object(lua_State* L,
        lua_Integer code, const char* details)
    {
       const int error_object_stack_ix = marpa_lua_gettop(L)+1;
       marpa_lua_newtable(L);
       /* [ ..., error_object ] */
       marpa_lua_rawgetp(L, LUA_REGISTRYINDEX, &kollos_error_mt_key);
       /* [ ..., error_object, error_metatable ] */
       marpa_lua_setmetatable(L, error_object_stack_ix);
       /* [ ..., error_object ] */
       marpa_lua_pushinteger(L, code);
       marpa_lua_setfield(L, error_object_stack_ix, "code" );
      if (0) printf ("%s %s %d\n", __PRETTY_FUNCTION__, __FILE__, __LINE__);
      if (0) printf ("%s code = %ld\n", __PRETTY_FUNCTION__, (long)code);
       /* [ ..., error_object ] */
       marpa_lua_pushstring(L, details);
       marpa_lua_setfield(L, error_object_stack_ix, "details" );
       /* [ ..., error_object ] */
    }

    -- miranda: section+ error handlers

    static int l_error_new(lua_State* L)
    {
        if (marpa_lua_istable (L, 1)) {
            const int table_ix = 1;
            marpa_lua_getfield (L, table_ix, "code");
            /* [ error_table,  code ] */
            if (!marpa_lua_isnumber (L, -1)) {
                /* Want a special code for this, eventually */
                const Marpa_Error_Code code = MARPA_ERR_DEVELOPMENT;
                marpa_lua_pushinteger (L, (lua_Integer) code);
                marpa_lua_setfield (L, table_ix, "code");
            }
            marpa_lua_pop (L, 1);
            marpa_lua_rawgetp (L, LUA_REGISTRYINDEX, &kollos_error_mt_key);
            /* [ error_table, error_metatable ] */
            marpa_lua_setmetatable (L, table_ix);
            /* [ error_table ] */
            return 1;
        }
        if (marpa_lua_isnumber (L, 1)) {
            const lua_Integer code = marpa_lua_tointeger (L, 1);
            const char *details = marpa_lua_tostring (L, 2);
            marpa_lua_pop (L, 2);
            push_error_object (L, code, details);
            return 1;
        }
        {
            /* Want a special code for this, eventually */
            const lua_Integer code = MARPA_ERR_DEVELOPMENT;
            const char *details = "Error code is not a number";
            push_error_object (L, code, details);
            return 1;
        }
    }

    /* Return string equivalent of error argument
     */
    static inline int l_error_tostring(lua_State* L)
    {
      lua_Integer error_code = -1;
      const int error_object_ix = 1;
      const char *temp_string;

      marpa_lua_getfield (L, error_object_ix, "string");

      /* [ ..., error_object, string ] */

      if (0) printf ("%s %s %d\n", __PRETTY_FUNCTION__, __FILE__, __LINE__);
      /* If present, a "string" overrides everything else */
      if (marpa_lua_isstring (L, -1))
        {
          marpa_lua_replace (L, error_object_ix);
          return 1;
        }

      /* [ ..., error_object, bad-string ] */
      marpa_lua_pop (L, 1);
      /* [ ..., error_object ] */

      marpa_lua_getfield (L, error_object_ix, "details");
      /* [ ..., error_object, details ] */
      if (marpa_lua_isstring (L, -1))
        {
          marpa_lua_pushstring (L, ": ");
        }
      else
        {
          marpa_lua_pop (L, 1);
        }

      /* [ ..., error_object ] */
      marpa_lua_getfield (L, error_object_ix, "code");
      /* [ ..., error_object, code ] */
      if (0) printf ("%s %s %d\n", __PRETTY_FUNCTION__, __FILE__, __LINE__);
      if (!marpa_lua_isnumber (L, -1))
        {
          marpa_lua_pop (L, 1);
          marpa_lua_pushstring (L, "[No error code]");
        }
      else
        {
          error_code = marpa_lua_tointeger (L, -1);
          /* Concatenation will eventually convert a numeric
           * code on top of the stack to a string, so we do
           * nothing with it here.
           */
        }

      marpa_lua_pushstring (L, " ");        /* Add space separator */

      temp_string = error_name_by_code (error_code);
      if (temp_string)
        {
          marpa_lua_pushstring (L, temp_string);
        }
      else
        {
          marpa_lua_pushfstring (L, "Unknown error code (%d)", (int) error_code);
        }
      marpa_lua_pushstring (L, " ");        /* Add space separator */

      temp_string = error_description_by_code (error_code);
      marpa_lua_pushstring (L, temp_string ? temp_string : "[no description]");
      marpa_lua_pushstring (L, "\n");        /* Add space separator */

      if (0) printf ("%s %s %d\n", __PRETTY_FUNCTION__, __FILE__, __LINE__);
      marpa_lua_concat (L, marpa_lua_gettop (L) - error_object_ix);
      /* stack is [ ..., error_object, concatenated_result ] */
      marpa_lua_replace (L, error_object_ix);
      /* [ ..., concatenated_result ] */
      return 1;
    }

    /* not safe - intended for internal use */
    static inline int wrap_kollos_throw(lua_State* L)
    {
       const lua_Integer code = marpa_lua_tointeger(L, 1);
       const char* details = marpa_lua_tostring(L, 2);
      if (0) printf ("%s %s %d\n", __PRETTY_FUNCTION__, __FILE__, __LINE__);
      if (0) printf ("%s code = %ld\n", __PRETTY_FUNCTION__, (long)code);
       libmarpa_error_code_handle(L, (int)code, details);
       return 1;
       /* NOTREACHED */
    }

    -- miranda: section+ error handlers

    /* functions */

    static void luif_err_throw(lua_State *L, int error_code) UNUSED;
    static void luif_err_throw(lua_State *L, int error_code) {

    #if 0
        const char *where;
        marpa_luaL_where(L, 1);
        where = marpa_lua_tostring(L, -1);
    #endif

        if (error_code < LIBMARPA_MIN_ERROR_CODE || error_code > LIBMARPA_MAX_ERROR_CODE) {
            marpa_luaL_error(L, "Libmarpa returned invalid error code %d", error_code);
        }
        marpa_luaL_error(L, "%s", marpa_error_codes[error_code].description );
    }

    static void luif_err_throw2(lua_State *L, int error_code, const char *msg) {

    #if 0
        const char *where;
        marpa_luaL_where(L, 1);
        where = marpa_lua_tostring(L, -1);
    #endif

        if (error_code < 0 || error_code > LIBMARPA_MAX_ERROR_CODE) {
            marpa_luaL_error(L, "%s\n    Libmarpa returned invalid error code %d", msg, error_code);
        }
        marpa_luaL_error(L, "%s\n    %s", msg, marpa_error_codes[error_code].description);
    }

    -- miranda: section+ base error handlers

    /* grammar wrappers which need to be hand written */

    /* If the error is not thrown, these handlers leave
     * the original items on the stack intact, and place
     * an error object on top of the stack.
     */
    static void
    development_error_handle (lua_State * L,
                            const char *details)
    {
      int throw_flag;
      marpa_lua_getglobal (L, "throw");
      /* [ ..., throw_flag ] */
      throw_flag = marpa_lua_toboolean (L, -1);
      /* [ ..., throw_flag ] */
      marpa_lua_pop(L, 1);
      push_error_object(L, MARPA_ERR_DEVELOPMENT, details);
      marpa_lua_pushvalue(L, -1);
      marpa_lua_setglobal(L, "error_object");
      /* [ ..., error_object ] */
      if (!throw_flag) return;
      marpa_lua_error(L);
    }

    static void
    libmarpa_error_code_handle (lua_State * L,
                            int error_code, const char *details)
    {
      int throw_flag;
      marpa_lua_getglobal (L, "throw");
      /* [ ..., throw_flag ] */
      throw_flag = marpa_lua_toboolean (L, -1);
      /* [ ..., throw_flag ] */
      marpa_lua_pop(L, 1);
      push_error_object(L, error_code, details);
      marpa_lua_pushvalue(L, -1);
      marpa_lua_setglobal(L, "error_object");
      /* [ ..., error_object ] */
      if (!throw_flag) return;
      marpa_lua_error(L);
    }

    /* Handle libmarpa errors in the most usual way.
       Uses 1 position on the stack, and throws the
       error, if so desired.
       The error may not be thrown, and it expects the
       caller to handle any non-thrown error.
    */
    static void
    libmarpa_error_handle (lua_State * L,
                            int stack_ix, const char *details)
    {
      Marpa_Error_Code error_code;
      Marpa_Grammar *grammar_ud;
      marpa_lua_getfield (L, stack_ix, "_libmarpa_g");
      /* [ ..., grammar_ud ] */
      grammar_ud = (Marpa_Grammar *) marpa_lua_touserdata (L, -1);
      marpa_lua_pop(L, 1);
      error_code = marpa_g_error (*grammar_ud, NULL);
      libmarpa_error_code_handle(L, error_code, details);
    }

    -- miranda: section+ C function declarations
    void marpa_gen_grammar_ud(lua_State* L, Marpa_Grammar g);
    -- miranda: section+ grammar object non-standard wrappers
    /* Caller must ensure enough stack space.
     * Leaves a new userdata on top of the stack.
     */
    void marpa_gen_grammar_ud(lua_State* L, Marpa_Grammar g)
    {
        Marpa_Grammar* p_g;
        p_g = (Marpa_Grammar *) marpa_lua_newuserdata (L, sizeof (Marpa_Grammar));
        *p_g = g;
        /* [ userdata ] */
        marpa_lua_rawgetp (L, LUA_REGISTRYINDEX, &kollos_g_ud_mt_key);
        /* [ userdata, metatable ] */
        marpa_lua_setmetatable (L, -2);
        /* [ userdata ] */
    }

I'm not sure I use this Libmarpa grammar wrapper constructor.
It might be deleted after development.

`wrap_grammar_new()`'s second argument is for development.
The intent is, eventually, for Kollos to create all its Libmarpa
grammars inside `wrap_grammar_new()`.
Kollos takes ownership of `g`, so the Libmarpa grammar must
have a reference to transfer
to `wrap_grammar_new()`.

    -- miranda: section+ grammar object non-standard wrappers

    static int
    wrap_grammar_new (lua_State * L)
    {
      /* [ grammar_table ] */
      const int grammar_stack_ix = 1;
      if (0)
        printf ("%s %s %d\n", __PRETTY_FUNCTION__, __FILE__, __LINE__);

      /* expecting a table */
      if (1)
        {
          marpa_luaL_checktype(L, grammar_stack_ix, LUA_TTABLE);
        }

      /* stack is [ grammar_table ] */
      {
        Marpa_Config marpa_config;
        Marpa_Grammar *p_g;
        int result;
        /* [ grammar_table ] */
        p_g = (Marpa_Grammar *) marpa_lua_newuserdata (L, sizeof (Marpa_Grammar));
        /* [ grammar_table, userdata ] */
        marpa_lua_rawgetp (L, LUA_REGISTRYINDEX, &kollos_g_ud_mt_key);
        marpa_lua_setmetatable (L, -2);
        /* [ grammar_table, userdata ] */

        /* dup top of stack */
        marpa_lua_pushvalue (L, -1);
        /* [ grammar_table, userdata, userdata ] */
        marpa_lua_setfield (L, grammar_stack_ix, "_libmarpa");
        /* [ grammar_table, userdata ] */
        marpa_lua_setfield (L, grammar_stack_ix, "_libmarpa_g");
        /* [ grammar_table ] */

        marpa_c_init (&marpa_config);
        *p_g = marpa_g_new (&marpa_config);
        if (!*p_g)
          {
            const Marpa_Error_Code marpa_error = marpa_c_error (&marpa_config, NULL);
            libmarpa_error_code_handle(L, marpa_error, "marpa_g_new()");
            return 0;
          }
        result = marpa_g_force_valued (*p_g);
        if (result < 0)
          {
            libmarpa_error_handle(L, grammar_stack_ix,
                                    "marpa_g_force_valued()");
            return 0;
          }
        if (0)
          printf ("%s %s %d\n", __PRETTY_FUNCTION__, __FILE__, __LINE__);
        /* [ grammar_table ] */
        return 1;
      }
    }

`dummyup_grammar` is not Lua C API.
This may be the basis of the actual constructor.
Takes ownership of a Libmarpa grammar reference,
so the caller must make sure that one is available.

    -- miranda: section+ C function declarations
    int
    marpa_k_dummyup_grammar (lua_State * L, Marpa_Grammar g, int slg_ref, const char *name);
    -- miranda: section+ grammar object non-standard wrappers

    int
    marpa_k_dummyup_grammar (lua_State * L, Marpa_Grammar g, int slg_ref, const char *name)
    {

        int result;
        Marpa_Grammar *p_g;
        const int base_of_stack = marpa_lua_gettop (L);
        int lmw_g_stack_ix;

        marpa_lua_checkstack(L, 20);

        marpa_lua_newtable (L);
        lmw_g_stack_ix = marpa_lua_gettop (L);

        if (0)
            printf ("%s %s %d\n", __PRETTY_FUNCTION__, __FILE__, __LINE__);

        /* [ ] */
        p_g =
            (Marpa_Grammar *) marpa_lua_newuserdata (L,
            sizeof (Marpa_Grammar));
        /* [ userdata ] */
        marpa_lua_rawgetp (L, LUA_REGISTRYINDEX, &kollos_g_ud_mt_key);
        marpa_lua_setmetatable (L, -2);
        /* [ userdata ] */

        /* dup top of stack */
        marpa_lua_pushvalue (L, -1);
        /* [ userdata, userdata ] */
        marpa_lua_setfield (L, lmw_g_stack_ix, "_libmarpa");
        /* [ userdata ] */

        /* _libmarpa_g is just a dup of _libmarpa but is here for
         * orthogonality with the other Kollos Libmarpa wrappers.
         */
        /* dup top of stack */
        marpa_lua_pushvalue (L, -1);
        /* [ userdata, userdata ] */
        marpa_lua_setfield (L, lmw_g_stack_ix, "_libmarpa_g");
        /* [ userdata ] */

        *p_g = g;
        result = marpa_g_force_valued (g);
        if (result < 0) {
            marpa_lua_settop (L, base_of_stack);
            return 0;
        }
        if (0)
            printf ("%s %s %d\n", __PRETTY_FUNCTION__, __FILE__, __LINE__);

        marpa_lua_rawgeti (L, LUA_REGISTRYINDEX, slg_ref);
        /* [ userdata, slg_table ] */
        marpa_lua_pushvalue (L, -2);
        /* [ userdata, slg_table, userdata ] */
        marpa_lua_setfield (L, -2, name);

        marpa_lua_settop (L, base_of_stack);
        return 1;
    }

    -- miranda: section+ grammar object non-standard wrappers

    /* The grammar error code */
    static int wrap_grammar_error(lua_State *L)
    {
       /* [ grammar_object ] */
      const int grammar_stack_ix = 1;
      Marpa_Grammar *p_g;
      Marpa_Error_Code marpa_error;
      const char *error_string = NULL;

      marpa_lua_getfield (L, grammar_stack_ix, "_libmarpa");
      /* [ grammar_object, grammar_ud ] */
      p_g = (Marpa_Grammar *) marpa_lua_touserdata (L, -1);
      marpa_error = marpa_g_error(*p_g, &error_string);
      marpa_lua_pushinteger(L, (lua_Integer)marpa_error);
      marpa_lua_pushstring(L, error_string);
      /* [ grammar_object, grammar_ud, error_code, error_string ] */
      return 2;
    }

    /* The C wrapper for Libmarpa event reading.
       It assumes we just want all of them.
     */
    static int wrap_grammar_events(lua_State *L)
    {
      /* [ grammar_object ] */
      const int grammar_stack_ix = 1;
      Marpa_Grammar *p_g;
      int event_count;

      marpa_lua_getfield (L, grammar_stack_ix, "_libmarpa");
      /* [ grammar_object, grammar_ud ] */
      p_g = (Marpa_Grammar *) marpa_lua_touserdata (L, -1);
      event_count = marpa_g_event_count (*p_g);
      if (event_count < 0)
        {
          libmarpa_error_handle (L, grammar_stack_ix,
                                  "marpa_g_event_count()");
          return 0;
        }
      marpa_lua_pop (L, 1);
      /* [ grammar_object ] */
      marpa_lua_createtable (L, event_count, 0);
      /* [ grammar_object, result_table ] */
      {
        const int result_table_ix = marpa_lua_gettop (L);
        int event_ix;
        for (event_ix = 0; event_ix < event_count; event_ix++)
          {
            Marpa_Event_Type event_type;
            Marpa_Event event;
            /* [ grammar_object, result_table ] */
            event_type = marpa_g_event (*p_g, &event, event_ix);
            if (event_type <= -2)
              {
                libmarpa_error_handle (L, grammar_stack_ix,
                                        "marpa_g_event()");
                return 0;
              }
            marpa_lua_pushinteger (L, event_ix*2 + 1);
            marpa_lua_pushinteger (L, event_type);
            /* [ grammar_object, result_table, event_ix*2+1, event_type ] */
            marpa_lua_settable (L, result_table_ix);
            /* [ grammar_object, result_table ] */
            marpa_lua_pushinteger (L, event_ix*2 + 2);
            marpa_lua_pushinteger (L, marpa_g_event_value (&event));
            /* [ grammar_object, result_table, event_ix*2+2, event_value ] */
            marpa_lua_settable (L, result_table_ix);
            /* [ grammar_object, result_table ] */
          }
      }
      /* [ grammar_object, result_table ] */
      return 1;
    }

    /* Another C wrapper for Libmarpa event reading.
       It assumes we want them one by one.
     */
    static int wrap_grammar_event(lua_State *L)
    {
      /* [ grammar_object ] */
      const int grammar_stack_ix = 1;
      const int event_ix_stack_ix = 2;
      Marpa_Grammar *p_g;
      Marpa_Event_Type event_type;
      Marpa_Event event;
      const int event_ix = (Marpa_Symbol_ID)marpa_lua_tointeger(L, event_ix_stack_ix)-1;

      marpa_lua_getfield (L, grammar_stack_ix, "_libmarpa");
      /* [ grammar_object, grammar_ud ] */
      p_g = (Marpa_Grammar *) marpa_lua_touserdata (L, -1);
      /* [ grammar_object, grammar_ud ] */
      event_type = marpa_g_event (*p_g, &event, event_ix);
      if (event_type <= -2)
        {
          libmarpa_error_handle (L, grammar_stack_ix, "marpa_g_event()");
          return 0;
        }
      marpa_lua_pushinteger (L, event_type);
      marpa_lua_pushinteger (L, marpa_g_event_value (&event));
      /* [ grammar_object, grammar_ud, event_type, event_value ] */
      return 2;
    }
    /* Rule RHS limited to 7 symbols --
     * 7 because I can encode dot position in 3 bit
     */
    static int wrap_grammar_rule_new(lua_State *L)
    {
        Marpa_Grammar *p_g;
        Marpa_Rule_ID result;
        Marpa_Symbol_ID lhs;
        /* As an old kernel driver programmer, I
         * don't like to put arrays on the stack,
         * but one of this size should be safe on
         * anything like a modern architecture.
         */
        Marpa_Symbol_ID rhs[2];
        int rhs_length;
        /* [ grammar_object, lhs, rhs ... ] */
        const int grammar_stack_ix = 1;

        /* This will not be an external interface,
         * so eventually we will run unsafe.
         * This checking code is for debugging.
         */
        marpa_luaL_checktype(L, grammar_stack_ix, LUA_TTABLE);

        lhs = (Marpa_Symbol_ID)marpa_lua_tointeger(L, 2);
        /* Unsafe, no arg count checking */
        rhs_length = marpa_lua_isnumber(L, 4) ? 2 : 1;
        {
          int rhs_ix;
          for (rhs_ix = 0; rhs_ix < rhs_length; rhs_ix++)
            {
              rhs[rhs_ix] = (Marpa_Symbol_ID) marpa_lua_tointeger (L, rhs_ix + 3);
            }
        }
        marpa_lua_pop(L, marpa_lua_gettop(L)-1);
        /* [ grammar_object ] */

        marpa_lua_getfield (L, -1, "_libmarpa");
        /* [ grammar_object, grammar_ud ] */
        p_g = (Marpa_Grammar *) marpa_lua_touserdata (L, -1);

        result = (Marpa_Rule_ID)marpa_g_rule_new(*p_g, lhs, rhs, rhs_length);
        if (result <= -1) libmarpa_error_handle (L, grammar_stack_ix,
                                "marpa_g_rule_new()");
        marpa_lua_pushinteger(L, (lua_Integer)result);
        return 1;
    }

    static const struct luaL_Reg grammar_methods[] = {
      { NULL, NULL },
    };

    -- miranda: section+ recognizer object non-standard wrappers

    /* recognizer wrappers which need to be hand-written */

    static int
    wrap_recce_new (lua_State * L)
    {
      const int recce_stack_ix = 1;
      const int grammar_stack_ix = 2;
      if (0)
        printf ("%s %s %d\n", __PRETTY_FUNCTION__, __FILE__, __LINE__);
      /* [ recce_table, grammar_table ] */

      marpa_luaL_checktype(L, recce_stack_ix, LUA_TTABLE);
      marpa_luaL_checktype(L, grammar_stack_ix, LUA_TTABLE);

      /* [ recce_table, grammar_table ] */
      {
        Marpa_Recognizer *recce_ud;
        Marpa_Grammar *grammar_ud;

        /* [ recce_table, grammar_table ] */
        recce_ud =
          (Marpa_Recognizer *) marpa_lua_newuserdata (L, sizeof (Marpa_Recognizer));
        /* [ recce_table, , grammar_table, recce_ud ] */
        marpa_lua_rawgetp (L, LUA_REGISTRYINDEX, &kollos_r_ud_mt_key);
        /* [ recce_table, grammar_table, recce_ud, recce_ud_mt ] */
        marpa_lua_setmetatable (L, -2);
        /* [ recce_table, grammar_table, recce_ud ] */

        marpa_lua_setfield (L, recce_stack_ix, "_libmarpa");
        /* [ recce_table, grammar_table ] */
        marpa_lua_getfield (L, grammar_stack_ix, "_libmarpa_g");
        /* [ recce_table, grammar_table, g_ud ] */
        grammar_ud = (Marpa_Grammar *) marpa_lua_touserdata (L, -1);
        marpa_lua_setfield (L, recce_stack_ix, "_libmarpa_g");
        /* [ recce_table, grammar_table ] */

        *recce_ud = marpa_r_new (*grammar_ud);
        if (!*recce_ud)
          {
            libmarpa_error_handle (L, grammar_stack_ix, "marpa_r_new()");
            marpa_lua_pushnil (L);
            return 1;
          }
      }
      if (0)
        printf ("%s %s %d\n", __PRETTY_FUNCTION__, __FILE__, __LINE__);
      /* [ recce_table, grammar_table ] */
      marpa_lua_pop (L, 1);
      /* [ recce_table ] */
      return 1;
    }

    /* The grammar error code */
    static int wrap_progress_item(lua_State *L)
    {
      /* [ grammar_object ] */
      const int recce_stack_ix = 1;
      Marpa_Recce *p_r;
      Marpa_Earley_Set_ID origin;
      int position;
      Marpa_Rule_ID rule_id;

      marpa_lua_getfield (L, recce_stack_ix, "_libmarpa");
      /* [ recce_object, recce_ud ] */
      p_r = (Marpa_Recce *) marpa_lua_touserdata (L, -1);
      rule_id = marpa_r_progress_item (*p_r, &position, &origin);
      if (rule_id < -1)
        {
          libmarpa_error_handle (L, recce_stack_ix, "marpa_r_progress_item()");
          marpa_lua_pushinteger (L, (lua_Integer) rule_id);
          return 1;
        }
      if (rule_id == -1)
        {
          return 0;
        }
      marpa_lua_pushinteger (L, (lua_Integer) rule_id);
      marpa_lua_pushinteger (L, (lua_Integer) position);
      marpa_lua_pushinteger (L, (lua_Integer) origin);
      /* [ recce_object, recce_ud,
       *     rule_id, position, origin ]
       */
      return 3;
    }

    static const struct luaL_Reg recce_methods[] = {
      { NULL, NULL },
    };

    -- miranda: section+ bocage object non-standard wrappers

    /* bocage wrappers which need to be hand-written */

    static int
    wrap_bocage_new (lua_State * L)
    {
        const int bocage_stack_ix = 1;
        const int recce_stack_ix = 2;
        const int symbol_stack_ix = 3;
        const int start_stack_ix = 4;
        const int end_stack_ix = 5;
        Marpa_Earley_Set_ID end_earley_set = -1;
        int end_earley_set_is_nil = 0;

        if (0)
            printf ("%s %s %d\n", __PRETTY_FUNCTION__, __FILE__, __LINE__);
        /* [ bocage_table, recce_table ] */
        if (1) {
          marpa_luaL_checktype(L, bocage_stack_ix, LUA_TTABLE);
          marpa_luaL_checktype(L, recce_stack_ix, LUA_TTABLE);
          marpa_luaL_checktype (L, symbol_stack_ix, LUA_TNIL);
          marpa_luaL_checktype (L, start_stack_ix, LUA_TNIL);
        }

        if (marpa_lua_type (L, end_stack_ix) == LUA_TNIL) {
            end_earley_set_is_nil = 1;
        } else {
            const lua_Integer es_arg =
                marpa_luaL_checkinteger (L, end_stack_ix);
            marpa_luaL_argcheck (L, (0 <= es_arg
                    && es_arg <= (2 ^ 30)), end_stack_ix,
                "earley set index out of range");
            end_earley_set = (Marpa_Earley_Set_ID) es_arg;
        }
        /* Make some stack space */
        marpa_lua_settop (L, recce_stack_ix);

        /* [ bocage_table, recce_table ] */
        {
            Marpa_Recognizer *recce_ud;
            /* Important: the bocage does *not* hold a reference to
               the recognizer, so it should not memoize the userdata
               pointing to it. */

            /* [ bocage_table, recce_table ] */
            Marpa_Bocage *bocage_ud =
                (Marpa_Bocage *) marpa_lua_newuserdata (L,
                sizeof (Marpa_Bocage));
            /* [ bocage_table, recce_table, bocage_ud ] */
            marpa_lua_rawgetp (L, LUA_REGISTRYINDEX, &kollos_b_ud_mt_key);
            /* [ bocage_table, recce_table, bocage_ud, bocage_ud_mt ] */
            marpa_lua_setmetatable (L, -2);
            /* [ bocage_table, recce_table, bocage_ud ] */

            marpa_lua_setfield (L, bocage_stack_ix, "_libmarpa");
            /* [ bocage_table, recce_table ] */
            marpa_lua_getfield (L, recce_stack_ix, "_libmarpa_g");
            /* [ recce_table, recce_table, g_ud ] */
            marpa_lua_setfield (L, bocage_stack_ix, "_libmarpa_g");
            /* [ bocage_table, recce_table ] */
            marpa_lua_getfield (L, recce_stack_ix, "_libmarpa");
            /* [ recce_table, recce_table, recce_ud ] */
            recce_ud = (Marpa_Recognizer *) marpa_lua_touserdata (L, -1);
            /* [ bocage_table, recce_table, recce_ud ] */

            if (end_earley_set_is_nil) {
                /* No error check -- always succeeds, say libmarpa docs */
                end_earley_set = marpa_r_latest_earley_set (*recce_ud);
            } else {
                if (end_earley_set < 0) {
                    libmarpa_error_handle (L, bocage_stack_ix,
                        "bocage_new(): end earley set arg is negative");
                    marpa_lua_pushnil (L);
                    return 1;
                }
            }

            *bocage_ud = marpa_b_new (*recce_ud, end_earley_set);
            if (!*bocage_ud) {
                libmarpa_error_handle (L, bocage_stack_ix, "marpa_b_new()");
                marpa_lua_pushnil (L);
                return 1;
            }
        }
        if (0)
            printf ("%s %s %d\n", __PRETTY_FUNCTION__, __FILE__, __LINE__);
        /* [ bocage_table, recce_table, recce_ud ] */
        marpa_lua_pop (L, 2);
        /* [ bocage_table ] */
        return 1;
    }

    static const struct luaL_Reg bocage_methods[] = {
      { NULL, NULL },
    };

    -- miranda: section+ order object non-standard wrappers

    /* order wrappers which need to be hand-written */

    static int
    wrap_order_new (lua_State * L)
    {
      const int order_stack_ix = 1;
      const int bocage_stack_ix = 2;

      if (0)
        printf ("%s %s %d\n", __PRETTY_FUNCTION__, __FILE__, __LINE__);
      /* [ order_table, bocage_table ] */
      if (1)
        {
          marpa_luaL_checktype(L, order_stack_ix, LUA_TTABLE);
          marpa_luaL_checktype(L, bocage_stack_ix, LUA_TTABLE);
        }

      /* [ order_table, bocage_table ] */
      {
        Marpa_Bocage *bocage_ud;

        /* [ order_table, bocage_table ] */
        Marpa_Order* order_ud =
          (Marpa_Order *) marpa_lua_newuserdata (L, sizeof (Marpa_Order));
        /* [ order_table, bocage_table, order_ud ] */
        marpa_lua_rawgetp (L, LUA_REGISTRYINDEX, &kollos_o_ud_mt_key);
        /* [ order_table, bocage_table, order_ud, order_ud_mt ] */
        marpa_lua_setmetatable (L, -2);
        /* [ order_table, bocage_table, order_ud ] */

        marpa_lua_setfield (L, order_stack_ix, "_libmarpa");
        /* [ order_table, bocage_table ] */
        marpa_lua_getfield (L, bocage_stack_ix, "_libmarpa_g");
        /* [ order_table, bocage_table, g_ud ] */
        marpa_lua_setfield (L, order_stack_ix, "_libmarpa_g");
        /* [ order_table, bocage_table ] */
        marpa_lua_getfield (L, bocage_stack_ix, "_libmarpa");
        /* [ order_table, bocage_table, bocage_ud ] */
        bocage_ud = (Marpa_Bocage *) marpa_lua_touserdata (L, -1);
        /* [ order_table, bocage_table, bocage_ud ] */

        *order_ud = marpa_o_new (*bocage_ud);
        if (!*order_ud)
          {
            libmarpa_error_handle (L, order_stack_ix, "marpa_o_new()");
            return 0;
          }
      }
      if (0)
        printf ("%s %s %d\n", __PRETTY_FUNCTION__, __FILE__, __LINE__);
      /* [ order_table, bocage_table, bocage_ud ] */
      marpa_lua_pop (L, 2);
      /* [ order_table ] */
      return 1;
    }

    static const struct luaL_Reg order_methods[] = {
      { NULL, NULL },
    };

    -- miranda: section+ tree object non-standard wrappers

    /* tree wrappers which need to be hand-written */

    static int
    wrap_tree_new (lua_State * L)
    {
      const int tree_stack_ix = 1;
      const int order_stack_ix = 2;

      if (0)
        printf ("%s %s %d\n", __PRETTY_FUNCTION__, __FILE__, __LINE__);
      /* [ tree_table, order_table ] */
      if (1)
        {
          marpa_luaL_checktype(L, tree_stack_ix, LUA_TTABLE);
          marpa_luaL_checktype(L, order_stack_ix, LUA_TTABLE);
        }

      /* [ tree_table, order_table ] */
      {
        Marpa_Order *order_ud;
        /* Important: the tree does *not* hold a reference to
             the recognizer, so it should not memoize the userdata
             pointing to it. */

        /* [ tree_table, order_table ] */
        Marpa_Tree* tree_ud =
          (Marpa_Tree *) marpa_lua_newuserdata (L, sizeof (Marpa_Tree));
        /* [ tree_table, order_table, tree_ud ] */
        marpa_lua_rawgetp (L, LUA_REGISTRYINDEX, &kollos_t_ud_mt_key);
        /* [ tree_table, order_table, tree_ud, tree_ud_mt ] */
        marpa_lua_setmetatable (L, -2);
        /* [ tree_table, order_table, tree_ud ] */

        marpa_lua_setfield (L, tree_stack_ix, "_libmarpa");
        /* [ tree_table, order_table ] */
        marpa_lua_getfield (L, order_stack_ix, "_libmarpa_g");
        /* [ tree_table, order_table, g_ud ] */
        marpa_lua_setfield (L, tree_stack_ix, "_libmarpa_g");
        /* [ tree_table, order_table ] */
        marpa_lua_getfield (L, order_stack_ix, "_libmarpa");
        /* [ tree_table, order_table, order_ud ] */
        order_ud = (Marpa_Order *) marpa_lua_touserdata (L, -1);
        /* [ tree_table, order_table, order_ud ] */

        *tree_ud = marpa_t_new (*order_ud);
        if (!*tree_ud)
          {
            libmarpa_error_handle (L, tree_stack_ix, "marpa_t_new()");
            return 0;
          }
      }
      if (0)
        printf ("%s %s %d\n", __PRETTY_FUNCTION__, __FILE__, __LINE__);
      /* [ tree_table, order_table, order_ud ] */
      marpa_lua_pop (L, 2);
      /* [ tree_table ] */
      return 1;
    }

    static const struct luaL_Reg tree_methods[] = {
      { NULL, NULL },
    };

    -- miranda: section+ C function declarations

    /* value wrappers which need to be hand-written */

    void marpa_gen_value_ud(lua_State* L, Marpa_Value g);

    -- miranda: section+ value object non-standard wrappers

    /* Caller must ensure enough stack space.
     * Leaves a new userdata on top of the stack.
     */
    void marpa_gen_value_ud(lua_State* L, Marpa_Value v)
    {
        Marpa_Value* p_v;
        p_v = (Marpa_Value *) marpa_lua_newuserdata (L, sizeof (Marpa_Value));
        *p_v = v;
        /* [ userdata ] */
        marpa_lua_rawgetp (L, LUA_REGISTRYINDEX, &kollos_v_ud_mt_key);
        /* [ userdata, metatable ] */
        marpa_lua_setmetatable (L, -2);
        /* [ userdata ] */
    }

    static int
    wrap_value_new (lua_State * L)
    {
      const int value_stack_ix = 1;
      const int tree_stack_ix = 2;

      if (0)
        printf ("%s %s %d\n", __PRETTY_FUNCTION__, __FILE__, __LINE__);
      /* [ value_table, tree_table ] */
      if (1)
        {
          marpa_luaL_checktype(L, value_stack_ix, LUA_TTABLE);
          marpa_luaL_checktype(L, tree_stack_ix, LUA_TTABLE);
        }

      /* [ value_table, tree_table ] */
      {
        Marpa_Tree *tree_ud;
        /* Important: the value does *not* hold a reference to
             the recognizer, so it should not memoize the userdata
             pointing to it. */

        /* [ value_table, tree_table ] */
        Marpa_Value* value_ud =
          (Marpa_Value *) marpa_lua_newuserdata (L, sizeof (Marpa_Value));
        /* [ value_table, tree_table, value_ud ] */
        marpa_lua_rawgetp (L, LUA_REGISTRYINDEX, &kollos_v_ud_mt_key);
        /* [ value_table, tree_table, value_ud, value_ud_mt ] */
        marpa_lua_setmetatable (L, -2);
        /* [ value_table, tree_table, value_ud ] */

        marpa_lua_setfield (L, value_stack_ix, "_libmarpa");
        /* [ value_table, tree_table ] */
        marpa_lua_getfield (L, tree_stack_ix, "_libmarpa_g");
        /* [ value_table, tree_table, g_ud ] */
        marpa_lua_setfield (L, value_stack_ix, "_libmarpa_g");
        /* [ value_table, tree_table ] */
        marpa_lua_getfield (L, tree_stack_ix, "_libmarpa");
        /* [ value_table, tree_table, tree_ud ] */
        tree_ud = (Marpa_Tree *) marpa_lua_touserdata (L, -1);
        /* [ value_table, tree_table, tree_ud ] */

        *value_ud = marpa_v_new (*tree_ud);
        if (!*value_ud)
          {
            libmarpa_error_handle (L, value_stack_ix, "marpa_v_new()");
            return 0;
          }
      }
      if (0)
        printf ("%s %s %d\n", __PRETTY_FUNCTION__, __FILE__, __LINE__);
      /* [ value_table, tree_table, tree_ud ] */
      marpa_lua_pop (L, 2);
      /* [ value_table ] */
      return 1;
    }

    /* Returns ok, result,
     * where ok is a boolean and
     * on failure, result is an error object, while
     * on success, result is an table
     */
    static int
    wrap_v_step (lua_State * L)
    {
      const char *result_string;
      Marpa_Value v;
      Marpa_Step_Type step_type;
      const int value_stack_ix = 1;

      marpa_luaL_checktype (L, value_stack_ix, LUA_TTABLE);

      marpa_lua_getglobal (L, "throw");
      marpa_lua_toboolean (L, -1);
      /* `throw` left on stack */

      marpa_lua_getfield (L, value_stack_ix, "_libmarpa");
      /* [ value_table, value_ud ] */
      v = *(Marpa_Value *) marpa_lua_touserdata (L, -1);
      step_type = marpa_v_step (v);

      if (0) printf("%s %s %d\n", __PRETTY_FUNCTION__, __FILE__, __LINE__);

      if (step_type == MARPA_STEP_INACTIVE)
        {
          marpa_lua_pushboolean (L, 1);
          marpa_lua_pushnil (L);
          return 2;
        }

      if (step_type < 0)
        {
          libmarpa_error_handle (L, value_stack_ix, "marpa_v_step()");
          marpa_lua_pushboolean (L, 0);
          marpa_lua_insert (L, -2);
          return 2;
        }

      if (0) printf("%s %s %d\n", __PRETTY_FUNCTION__, __FILE__, __LINE__);

      result_string = step_name_by_code (step_type);
      if (result_string)
        {

          int return_value_ix;

          /* The table containing the return value */
          marpa_lua_newtable (L);
          return_value_ix = marpa_lua_gettop(L);
          marpa_lua_pushstring (L, result_string);
          marpa_lua_seti (L, return_value_ix, 1);

          if (step_type == MARPA_STEP_TOKEN)
            {
              marpa_lua_pushinteger (L, marpa_v_token (v));
              marpa_lua_seti (L, return_value_ix, 2);
              marpa_lua_pushinteger (L, marpa_v_token_start_es_id (v));
              marpa_lua_seti (L, return_value_ix, 3);
              marpa_lua_pushinteger (L, marpa_v_es_id (v));
              marpa_lua_seti (L, return_value_ix, 4);
              marpa_lua_pushinteger (L, marpa_v_result (v));
              marpa_lua_seti (L, return_value_ix, 5);
              marpa_lua_pushinteger (L, marpa_v_token_value (v));
              marpa_lua_seti (L, return_value_ix, 6);
              marpa_lua_pushboolean (L, 1);
              marpa_lua_insert (L, -2);
              return 2;
            }

          if (step_type == MARPA_STEP_NULLING_SYMBOL)
            {
              marpa_lua_pushinteger (L, marpa_v_token (v));
              marpa_lua_seti (L, return_value_ix, 2);
              marpa_lua_pushinteger (L, marpa_v_rule_start_es_id (v));
              marpa_lua_seti (L, return_value_ix, 3);
              marpa_lua_pushinteger (L, marpa_v_es_id (v));
              marpa_lua_seti (L, return_value_ix, 4);
              marpa_lua_pushinteger (L, marpa_v_result (v));
              marpa_lua_seti (L, return_value_ix, 5);
              marpa_lua_pushboolean (L, 1);
              marpa_lua_insert (L, -2);
              return 2;
            }

          if (step_type == MARPA_STEP_RULE)
            {
              marpa_lua_pushinteger (L, marpa_v_rule (v));
              marpa_lua_seti (L, return_value_ix, 2);
              marpa_lua_pushinteger (L, marpa_v_rule_start_es_id (v));
              marpa_lua_seti (L, return_value_ix, 3);
              marpa_lua_pushinteger (L, marpa_v_es_id (v));
              marpa_lua_seti (L, return_value_ix, 4);
              marpa_lua_pushinteger (L, marpa_v_result (v));
              marpa_lua_seti (L, return_value_ix, 5);
              marpa_lua_pushinteger (L, marpa_v_arg_0 (v));
              marpa_lua_seti (L, return_value_ix, 6);
              marpa_lua_pushinteger (L, marpa_v_arg_n (v));
              marpa_lua_seti (L, return_value_ix, 7);
              marpa_lua_pushboolean (L, 1);
              marpa_lua_insert (L, -2);
              return 2;
            }
        }

      if (0) printf("%s %s %d\n", __PRETTY_FUNCTION__, __FILE__, __LINE__);

      marpa_lua_pushfstring (L, "Problem in v->step(): unknown step type %d",
                             step_type);
      development_error_handle (L, marpa_lua_tostring (L, -1));
      marpa_lua_pushboolean (L, 0);
      marpa_lua_insert (L, -2);
      return 2;

    }

    static const struct luaL_Reg value_methods[] = {
      { "step", wrap_v_step },
      { NULL, NULL },
    };

    -- miranda: section+ object userdata gc methods

    /*
     * Userdata metatable methods
     */

    --[==[ miranda: exec object userdata gc methods
        local result = {}
        local template = [[
        |static int l_!NAME!_ud_mt_gc(lua_State *L) {
        |  !TYPE! *p_ud;
        |  if (0) printf("%s %s %d\n", __PRETTY_FUNCTION__, __FILE__, __LINE__);
        |  p_ud = (!TYPE! *) marpa_lua_touserdata (L, 1);
        |  if (*p_ud) marpa_!LETTER!_unref(*p_ud);
        |  *p_ud = NULL;
        |  return 0;
        |}
        ]]
        for letter, class_name in pairs(libmarpa_class_name) do
           local class_type = libmarpa_class_type[letter]
           result[#result+1] =
               pipe_dedent(template)
                   :gsub("!NAME!", class_name)
                   :gsub("!TYPE!", class_type)
                   :gsub("!LETTER!", letter)
        end
        return table.concat(result)
    ]==]

```

### `marpa_luaopen_kollos`

```
    -- miranda: section define marpa_luaopen_kollos method
    static int marpa_luaopen_kollos(lua_State *L)
    {
        /* Create the main kollos object */
        const int kollos_table_stack_ix = marpa_lua_gettop(L) + 1;

      {
        const char *const header_mismatch =
          "Header version does not match expected version";
        /* Make sure the header is from the version we want */
        if (MARPA_MAJOR_VERSION != EXPECTED_LIBMARPA_MAJOR)
          luif_err_throw2 (L, LUIF_ERR_MAJOR_VERSION_MISMATCH, header_mismatch);
        if (MARPA_MINOR_VERSION != EXPECTED_LIBMARPA_MINOR)
          luif_err_throw2 (L, LUIF_ERR_MINOR_VERSION_MISMATCH, header_mismatch);
        if (MARPA_MICRO_VERSION != EXPECTED_LIBMARPA_MICRO)
          luif_err_throw2 (L, LUIF_ERR_MICRO_VERSION_MISMATCH, header_mismatch);
      }

      {
        /* Now make sure the library is from the version we want */
        const char *const library_mismatch =
          "Library version does not match expected version";
        int version[3];
        const Marpa_Error_Code error_code = marpa_version (version);
        if (error_code != MARPA_ERR_NONE)
          luif_err_throw2 (L, error_code, "marpa_version() failed");
        if (version[0] != EXPECTED_LIBMARPA_MAJOR)
          luif_err_throw2 (L, LUIF_ERR_MAJOR_VERSION_MISMATCH, library_mismatch);
        if (version[1] != EXPECTED_LIBMARPA_MINOR)
          luif_err_throw2 (L, LUIF_ERR_MINOR_VERSION_MISMATCH, library_mismatch);
        if (version[2] != EXPECTED_LIBMARPA_MICRO)
          luif_err_throw2 (L, LUIF_ERR_MICRO_VERSION_MISMATCH, library_mismatch);
      }

        marpa_lua_newtable(L);
        /* Create the main kollos_c object, to give the
         * C language Libmarpa wrappers their own namespace.
         *
         */
        /* [ kollos ] */

        -- miranda: insert create kollos class tables

        /* Set up Kollos error handling metatable.
           The metatable starts out empty.
        */
        marpa_lua_newtable(L);
        /* [ kollos, error_mt ] */
        marpa_lua_pushcfunction(L, l_error_tostring);
        /* [ kollos, error_mt, tostring_fn ] */
        marpa_lua_setfield(L, -2, "__tostring");
        /* [ kollos, error_mt ] */
        marpa_lua_rawsetp(L, LUA_REGISTRYINDEX, &kollos_error_mt_key);
        /* [ kollos ] */

        /* Set up Kollos grammar userdata metatable */
        marpa_lua_newtable(L);
        /* [ kollos, mt_ud_g ] */
        marpa_lua_pushcfunction(L, l_grammar_ud_mt_gc);
        /* [ kollos, mt_g_ud, gc_function ] */
        marpa_lua_setfield(L, -2, "__gc");
        /* [ kollos, mt_g_ud ] */
        marpa_lua_rawsetp(L, LUA_REGISTRYINDEX, &kollos_g_ud_mt_key);
        /* [ kollos ] */

        /* Set up Kollos recce userdata metatable */
        marpa_lua_newtable(L);
        /* [ kollos, mt_ud_r ] */
        marpa_lua_pushcfunction(L, l_recce_ud_mt_gc);
        /* [ kollos, mt_r_ud, gc_function ] */
        marpa_lua_setfield(L, -2, "__gc");
        /* [ kollos, mt_r_ud ] */
        marpa_lua_rawsetp(L, LUA_REGISTRYINDEX, &kollos_r_ud_mt_key);
        /* [ kollos ] */

        /* Set up Kollos bocage userdata metatable */
        marpa_lua_newtable(L);
        /* [ kollos, mt_ud_bocage ] */
        marpa_lua_pushcfunction(L, l_bocage_ud_mt_gc);
        /* [ kollos, mt_b_ud, gc_function ] */
        marpa_lua_setfield(L, -2, "__gc");
        /* [ kollos, mt_b_ud ] */
        marpa_lua_rawsetp(L, LUA_REGISTRYINDEX, &kollos_b_ud_mt_key);
        /* [ kollos ] */

        /* Set up Kollos order userdata metatable */
        marpa_lua_newtable(L);
        /* [ kollos, mt_ud_order ] */
        marpa_lua_pushcfunction(L, l_order_ud_mt_gc);
        /* [ kollos, mt_o_ud, gc_function ] */
        marpa_lua_setfield(L, -2, "__gc");
        /* [ kollos, mt_o_ud ] */
        marpa_lua_rawsetp(L, LUA_REGISTRYINDEX, &kollos_o_ud_mt_key);
        /* [ kollos ] */

        /* Set up Kollos tree userdata metatable */
        marpa_lua_newtable(L);
        /* [ kollos, mt_ud_tree ] */
        marpa_lua_pushcfunction(L, l_tree_ud_mt_gc);
        /* [ kollos, mt_t_ud, gc_function ] */
        marpa_lua_setfield(L, -2, "__gc");
        /* [ kollos, mt_t_ud ] */
        marpa_lua_rawsetp(L, LUA_REGISTRYINDEX, &kollos_t_ud_mt_key);
        /* [ kollos ] */

        /* Set up Kollos value userdata metatable */
        marpa_lua_newtable(L);
        /* [ kollos, mt_ud_value ] */
        marpa_lua_pushcfunction(L, l_value_ud_mt_gc);
        /* [ kollos, mt_v_ud, gc_function ] */
        marpa_lua_setfield(L, -2, "__gc");
        /* [ kollos, mt_v_ud ] */
        marpa_lua_rawsetp(L, LUA_REGISTRYINDEX, &kollos_v_ud_mt_key);
        /* [ kollos ] */

        /* In alphabetical order by field name */

        marpa_lua_pushcfunction(L, l_error_description_by_code);
        /* [ kollos, function ] */
        marpa_lua_setfield(L, kollos_table_stack_ix, "error_description");
        /* [ kollos ] */

        marpa_lua_pushcfunction(L, l_error_name_by_code);
        marpa_lua_setfield(L, kollos_table_stack_ix, "error_name");

        marpa_lua_pushcfunction(L, l_error_new);
        marpa_lua_setfield(L, kollos_table_stack_ix, "error_new");

        marpa_lua_pushcfunction(L, wrap_kollos_throw);
        marpa_lua_setfield(L, kollos_table_stack_ix, "error_throw");

        marpa_lua_pushcfunction(L, l_event_name_by_code);
        marpa_lua_setfield(L, kollos_table_stack_ix, "event_name");

        marpa_lua_pushcfunction(L, l_event_description_by_code);
        marpa_lua_setfield(L, kollos_table_stack_ix, "event_description");

        marpa_lua_pushcfunction(L, wrap_grammar_error);
        marpa_lua_setfield(L, kollos_table_stack_ix, "grammar_error");

        marpa_lua_pushcfunction(L, wrap_grammar_event);
        marpa_lua_setfield(L, kollos_table_stack_ix, "grammar_event");

        marpa_lua_pushcfunction(L, wrap_grammar_events);
        marpa_lua_setfield(L, kollos_table_stack_ix, "grammar_events");

        marpa_lua_pushcfunction(L, wrap_grammar_new);
        marpa_lua_setfield(L, kollos_table_stack_ix, "grammar_new");

        marpa_lua_pushcfunction(L, wrap_grammar_rule_new);
        marpa_lua_setfield(L, kollos_table_stack_ix, "grammar_rule_new");

        marpa_lua_pushcfunction(L, wrap_recce_new);
        marpa_lua_setfield(L, kollos_table_stack_ix, "recce_new");

        marpa_lua_pushcfunction(L, wrap_progress_item);
        marpa_lua_setfield(L, kollos_table_stack_ix, "recce_progress_item");

        marpa_lua_pushcfunction(L, wrap_bocage_new);
        marpa_lua_setfield(L, kollos_table_stack_ix, "bocage_new");

        marpa_lua_pushcfunction(L, wrap_order_new);
        marpa_lua_setfield(L, kollos_table_stack_ix, "order_new");

        marpa_lua_pushcfunction(L, wrap_tree_new);
        marpa_lua_setfield(L, kollos_table_stack_ix, "tree_new");

        marpa_lua_pushcfunction(L, wrap_value_new);
        marpa_lua_setfield(L, kollos_table_stack_ix, "value_new");

        marpa_lua_newtable (L);
        /* [ kollos, error_code_table ] */
        {
          const int name_table_stack_ix = marpa_lua_gettop (L);
          int error_code;
          for (error_code = LIBMARPA_MIN_ERROR_CODE;
               error_code <= LIBMARPA_MAX_ERROR_CODE; error_code++)
            {
              marpa_lua_pushinteger (L, (lua_Integer) error_code);
              marpa_lua_setfield (L, name_table_stack_ix,
                            marpa_error_codes[error_code -
                                                 LIBMARPA_MIN_ERROR_CODE].mnemonic);
            }
          for (error_code = KOLLOS_MIN_ERROR_CODE;
               error_code <= KOLLOS_MAX_ERROR_CODE; error_code++)
            {
              marpa_lua_pushinteger (L, (lua_Integer) error_code);
              marpa_lua_setfield (L, name_table_stack_ix,
                            marpa_kollos_error_codes[error_code -
                                               KOLLOS_MIN_ERROR_CODE].mnemonic);
            }
        }
          /* if (1) dump_table(L, -1); */

        /* [ kollos, error_code_table ] */
        marpa_lua_setfield (L, kollos_table_stack_ix, "error_code_by_name");

        marpa_lua_newtable (L);
        /* [ kollos, event_code_table ] */
        {
          const int name_table_stack_ix = marpa_lua_gettop (L);
          int event_code;
          for (event_code = LIBMARPA_MIN_EVENT_CODE;
               event_code <= LIBMARPA_MAX_EVENT_CODE; event_code++)
            {
              marpa_lua_pushinteger (L, (lua_Integer) event_code);
              marpa_lua_setfield (L, name_table_stack_ix,
                            marpa_event_codes[event_code -
                                                 LIBMARPA_MIN_EVENT_CODE].mnemonic);
            }
        }
          /* if (1) dump_table(L, -1); */

        /* [ kollos, event_code_table ] */
        marpa_lua_setfield (L, kollos_table_stack_ix, "event_code_by_name");

    -- miranda: insert register standard libmarpa wrappers
    /* Place code here to go through the signatures table again,
     * to put the wrappers into kollos object fields
     * See okollos
     */

    /* [ kollos ] */
    -- miranda: insert create sandbox table

      /* For debugging */
      if (0) dump_table(L, -1);

      marpa_lua_settop(L, kollos_table_stack_ix);
      /* [ kollos ] */
      return 1;
    }
```

### Create a sandbox

Given a Lua state,
create a table, which can be used
as a "sandbox" for protect the global environment
from user code.
The table is named `sandbox` and itself *is*
kept in the global environment.
This code only creates the sandbox, it does not
set it as an environment -- it is assumed that
that will be done later,
after to-be-sandboxed Lua code is loaded,
but before it is executed.
Not Lua-callable, but leaves the stack as before.

```
    -- miranda: section create sandbox table
    {
        const int base_of_stack = marpa_lua_gettop(L);
        marpa_lua_newtable (L);
        /* sandbox.__index = _G */
        marpa_lua_pushglobaltable(L);
        marpa_lua_setfield(L, -2, "__index");

        /* sandbox metatable is itself */
        marpa_lua_pushvalue(L, -1);
        marpa_lua_setmetatable(L, -2);
        marpa_lua_pushglobaltable(L);
        /* [ sandbox, _G ] */
        marpa_lua_insert(L, -2);
        /* [ _G, sandbox ] */
        marpa_lua_setfield(L, -2, "sandbox");
        marpa_lua_settop (L, base_of_stack);
    }
```

### Preliminaries to the C library code
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

    #define EXPECTED_LIBMARPA_MAJOR 8
    #define EXPECTED_LIBMARPA_MINOR 4
    #define EXPECTED_LIBMARPA_MICRO 0

```

## The Kollos C header file

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

### Preliminaries to the C header file
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

## Meta-coding utilities

### Metacode execution sequence

```
    -- miranda: sequence-exec argument processing
    -- miranda: sequence-exec metacode utilities
    -- miranda: sequence-exec libmarpa interface globals
    -- miranda: sequence-exec declare standard libmarpa wrappers
    -- miranda: sequence-exec register standard libmarpa wrappers
    -- miranda: sequence-exec create kollos class tables
    -- miranda: sequence-exec object userdata gc methods
```

### Dedent method

A pipe symbol is used when inlining code to separate the code's indentation
from the indentation used to display the code in this document.
The `pipe_dedent` method removes the display indentation.

```
    --[==[ miranda: exec metacode utilities
    function pipe_dedent(code)
        return code:gsub('\n *|', '\n'):gsub('^ *|', '', 1)
    end
    ]==]
```

### `c_safe_string` method

```
    --[==[ miranda: exec metacode utilities
    local function c_safe_string (s)
        s = string.gsub(s, '"', '\\034')
        s = string.gsub(s, '\\', '\\092')
        return '"' .. s .. '"'
    end
    ]==]

```

### Meta code argument processing

The arguments show where to find the files containing event
and error codes.

```
    -- assumes that, when called, out_file to set to output file
    --[==[ miranda: exec argument processing
    local error_file
    local event_file

    for _,v in ipairs(arg) do
       if not v:find("=")
       then return nil, "Bad options: ", arg end
       local id, val = v:match("^([^=]+)%=(.*)") -- no space around =
       if id == "out" then io.output(val)
       elseif id == "errors" then error_file = val
       elseif id == "events" then event_file = val
       else return nil, "Bad id in options: ", id end
    end
    ]==]
```

<!--
vim: expandtab shiftwidth=4:
-->
