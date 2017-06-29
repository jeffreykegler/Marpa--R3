<!--
Copyright 2017 Jeffrey Kegler
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
cd kollos && ../lua/lua toc.lua < kollos.md
-->
* [About Kollos](#about-kollos)
* [Abbreviations](#abbreviations)
* [Development Notes](#development-notes)
  * [To Do](#to-do)
    * [TODO notes](#todo-notes)
  * [Terminology fixes](#terminology-fixes)
  * [Use generations in Libmarpa trees](#use-generations-in-libmarpa-trees)
  * [Kollos assumes core libraries are loaded](#kollos-assumes-core-libraries-are-loaded)
  * [New lexer features](#new-lexer-features)
  * [Discard default statement?](#discard-default-statement)
* [Kollos object](#kollos-object)
* [Kollos registry objects](#kollos-registry-objects)
  * [External, inner and internal](#external-inner-and-internal)
* [Symbols](#symbols)
* [Kollos SLIF grammar object](#kollos-slif-grammar-object)
  * [Fields](#fields)
  * [Accessors](#accessors)
  * [Mutators](#mutators)
  * [Hash to runtime processing](#hash-to-runtime-processing)
* [Kollos SLIF recognizer object](#kollos-slif-recognizer-object)
  * [Fields](#fields)
  * [Constructors](#constructors)
  * [Reading](#reading)
    * [External reading](#external-reading)
      * [Methods](#methods)
  * [Evaluation](#evaluation)
  * [Locations](#locations)
  * [Events](#events)
  * [Progress reporting](#progress-reporting)
* [Inner symbol (ISY) class](#inner-symbol-isy-class)
  * [Fields](#fields)
  * [Accessors](#accessors)
  * [Constants: Ranking methods](#constants-ranking-methods)
  * [Diagnostics](#diagnostics)
* [Kollos semantics](#kollos-semantics)
  * [VM operations](#vm-operations)
    * [VM debug operation](#vm-debug-operation)
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
  * [Tree export operations](#tree-export-operations)
  * [VM-related utilities for use in the Perl code](#vm-related-utilities-for-use-in-the-perl-code)
    * [Return operation key given its name](#return-operation-key-given-its-name)
    * [Return operation name given its key](#return-operation-name-given-its-key)
    * [Return the top index of the stack](#return-the-top-index-of-the-stack)
    * [Return the value of a stack entry](#return-the-value-of-a-stack-entry)
    * [Set the value of a stack entry](#set-the-value-of-a-stack-entry)
    * [Convert current, origin Earley set to L0 span](#convert-current-origin-earley-set-to-l0-span)
* [The valuator Libmarpa wrapper](#the-valuator-libmarpa-wrapper)
  * [Initialize a valuator](#initialize-a-valuator)
  * [Reset a valuator](#reset-a-valuator)
* [Diagnostics](#diagnostics)
  * [Input](#input)
* [Libmarpa grammar class](#libmarpa-grammar-class)
  * [Fields](#fields)
  * [Constructor](#constructor)
  * [Layer grammar accessors](#layer-grammar-accessors)
* [The recognizer Libmarpa wrapper](#the-recognizer-libmarpa-wrapper)
  * [Fields](#fields)
  * [Functions for tracing Earley sets](#functions-for-tracing-earley-sets)
* [External symbol (XSY) class](#external-symbol-xsy-class)
  * [Fields](#fields)
* [Accessors](#accessors)
* [Rules](#rules)
* [IRL Fields](#irl-fields)
* [XRL Fields](#xrl-fields)
* [XBNF Fields](#xbnf-fields)
* [Libmarpa interface](#libmarpa-interface)
  * [Standard template methods](#standard-template-methods)
  * [Constructors](#constructors)
* [The main Lua code file](#the-main-lua-code-file)
  * [Preliminaries to the main code](#preliminaries-to-the-main-code)
* [The Kollos C code file](#the-kollos-c-code-file)
  * [Stuff from okollos](#stuff-from-okollos)
  * [Kollos metal loader](#kollos-metal-loader)
  * [Create a sandbox](#create-a-sandbox)
  * [Preliminaries to the C library code](#preliminaries-to-the-c-library-code)
* [The Kollos C header file](#the-kollos-c-header-file)
  * [Preliminaries to the C header file](#preliminaries-to-the-c-header-file)
* [Internal utilities](#internal-utilities)
  * [Coroutines](#coroutines)
  * [Exceptions](#exceptions)
* [Meta-coding](#meta-coding)
  * [Metacode execution sequence](#metacode-execution-sequence)
  * [Dedent method](#dedent-method)
  * [`c_safe_string` method](#c-safe-string-method)
  * [Meta code argument processing](#meta-code-argument-processing)
* [Kollos utilities](#kollos-utilities)
  * [VLQ (Variable-Length Quantity)](#vlq-variable-length-quantity)

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

## Abbreviations

* desc -- Short for "description".  Used a lot for
strings which "describe" something, usually for the
purpose of being assembled into a larger string,
and usually as part of some message.

* giter -- An *Iter*ator factory (aka generator).
In _Programming Lua_,
Roberto insists that the argument of the generic
for is not an iterator, but an iterator generator.

* iter -- An *Iter*ator.
But see also "giter".

* ix -- Index

* pcs -- Short for "pieces".  Often used as table name,
where the tables purposes is to assemble a larger string,
which is usually a message,
and which is usually assembled using `table.concat()`.

## Development Notes

This section is first for the convenience of the
active developers.
Readers trying to familiarize themselves with Kollos
may want to skip it or skim it
in their first readings.

### To Do

#### TODO notes

Throughout the code, the string "TODO" marks notes
for action during or after development.
Not all of these are included or mentioned
in these "Development Notes".

### Terminology fixes

* Check all uses of "pauses", eliminating those where
  it refers to parse events.

* Eliminate all uses of "physical" and "virtual" wrt
  parse location.

### Use generations in Libmarpa trees

Currently a valuator "pauses" its base tree, so
that it does not change during the life of the tree.
This gets tricky for the Lua garbage collection --
the valuator may not be garbage collected quickly,
and no new tree can be created meantime.
Instead, add a generation number to the tree, and
use that.

### Kollos assumes core libraries are loaded

Currently Kollos assumes that the
core libraries are loaded.
Going forward, it needs to "require" then,
like an ordinary Lua library.

### New lexer features

*  Changing priorities to be "non-local".  Current priorities only break
ties for tokens at the same location.  "Non-local" means if there is a
priority 2 lexeme of any length and/or eagerness, you will get that
lexeme, and not any lexeme of priority 1 or lower.

* Lookahead?

### Discard default statement?

These is a leftover
design note from some time ago, for a never-implemented
feature.
I'm keeping this note until I decide about this feature,
one way or the other.

The `discard default` statement would be modeled on the
`lexeme default` statement.  An example:

```
   discard default => event => ::name=off
```

## Concepts

This section describes those Kollos concepts who do
not fall conveniently into one of the code sections.

### External, inner and internal

The Kollos upper layers and Libmarpa both
makes substantial use of rule rewriting.
As a result,
Kollos has external rules (xrl's),
inner rules (irl's)
and internal rules (nrl's).
External rules contain external symbols (xsy's).
Inner rules contain inner symbols (isy's).
Internal rules contain internal symbols (nsy's).

Xrl's and xsy's are the
only rules and symbols
intended to be visible to the SLIF user.
Irl's, isy's, nrl's and nsy's are
intended to be seen by Kollos
developers and maintainers only.

Libmarpa and the
Kollos upper layers
each have
two sets of rules and symbols,
one pre-rewrite and one post-rewrite.
The xrl's and xsy's are the Kollos upper
layer's pre-rewrite rules and symbols.

The irl's and isy's are the Kollos upper
layer's post-rewrite rules and symbols.
The irl's and isy's are also Libmarpa's
pre-rewrite rules and symbols.
Irl's and isy's
are, therefore, a "common language"
that Libmarpa and the Kollos upper layers share.

Libmarpa's post-rewrite symbols are
the nrl's and nsy's.
Nrl's and nsy's are
intended to be known only to Libmarpa,
and to Libmarpa's developers and maintainers.

For historical reasons,
and confusingly,
some of Libmarpa's
internal methods refer to nrl's as irl's.
The names of these methods will eventually be
changed.
They are being kept for now so that
Kollos's Libmarpa does not diverge
too far from
Marpa::R2's Libmarpa.

### Symbol names, IDs and forms

Symbols are show several "forms".

Name and ID are unique identifiers, available for
all valid symbols,
and only for valid symbols.
IDs are integers.
Names are strings.
The symbol name may be an internal creation,
subject to change in future versions of Kollos.

*DSL form* is the form as it appears in the SLIF DSL.
It does not vary as long as the DSL does not vary.
It is not guaranteed unique and many valid symbols
will not have a DSL form.

*Display form* is a string
available
for all valid symbols,
and for invalid symbols IDs as well.
It is Kollos's idea of "best" form for
display.
Display forms are not necessarily unique.

In the case of an invalid symbol,
display form dummies up a symbol name
describing the problem.
This may be consider a kind of "soft failure".

The display form of an ISY
will be the display form of the XSY when
possible,
and a "soft failure" otherwise.
Because of this,
code which requires the display form of the XSY
corresponding to an ISY
will usually just ask for the display form of the ISY.

## Kollos object

`ref_count` maintains a reference count that controls
the destruction of Kollos interpreters.
`warn` is for a warning callback -- it's not
currently used.
`buffer` is used by kollos internally, usually
for buffering symbol ID's in the libmarpa wrappers.
`buffer_capacity` is its current capacity.

The buffer strategy currently is to set its capacity to the
maximum symbol count of any of the grammars in the Kollos
interpreter.

```
    -- miranda: section utility function definitions

    /* I assume this will be inlined by the compiler */
    static Marpa_Symbol_ID *shared_buffer_get(lua_State* L)
    {
        Marpa_Symbol_ID* buffer;
        const int base_of_stack = marpa_lua_gettop(L);
        marpa_lua_pushvalue(L, marpa_lua_upvalueindex(1));
        if (!marpa_lua_istable(L, -1)) {
            internal_error_handle(L, "missing upvalue table",
            __PRETTY_FUNCTION__, __FILE__, __LINE__);
        }
        marpa_lua_getfield(L, -1, "buffer");
        buffer = marpa_lua_touserdata(L, -1);
        marpa_lua_settop(L, base_of_stack);
        return buffer;
    }

    -- miranda: section C function declarations
    /* I probably will, in the final version, want this to be a
     * static utility, internal to Kollos
     */
    void kollos_shared_buffer_resize(
        lua_State* L,
        size_t desired_capacity);
```

Not Lua C API.
Manipulates Lua stack,
leaving it as is.

```
    -- miranda: section external C function definitions
    void kollos_shared_buffer_resize(
        lua_State* L,
        size_t desired_capacity)
    {
        size_t buffer_capacity;
        const int base_of_stack = marpa_lua_gettop(L);
        const int upvalue_ix = base_of_stack + 1;

        marpa_lua_pushvalue(L, marpa_lua_upvalueindex(1));
        if (!marpa_lua_istable(L, -1)) {
            internal_error_handle(L, "missing upvalue table",
            __PRETTY_FUNCTION__, __FILE__, __LINE__);
        }
        marpa_lua_getfield(L, upvalue_ix, "buffer_capacity");
        buffer_capacity = (size_t)marpa_lua_tointeger(L, -1);
        /* Is this test needed after development? */
        if (buffer_capacity < 1) {
            internal_error_handle(L, "bad buffer capacity",
            __PRETTY_FUNCTION__, __FILE__, __LINE__);
        }
        if (desired_capacity > buffer_capacity) {
            /* TODO: this optimizes for space, not speed.
             * Insist capacity double on each realloc()?
             */
            (void)marpa_lua_newuserdata (L,
                desired_capacity * sizeof (Marpa_Symbol_ID));
            marpa_lua_setfield(L, upvalue_ix, "buffer");
            marpa_lua_pushinteger(L, (lua_Integer)desired_capacity);
            marpa_lua_setfield(L, upvalue_ix, "buffer_capacity");
        }
        marpa_lua_settop(L, base_of_stack);
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

```
    -- miranda: section+ kollos table methods
    static int lca_registry_get(lua_State* L)
    {
      /* Lua stack [ recce_ref ] */
      lua_Integer recce_ref = marpa_luaL_checkinteger(L, 1);
      marpa_lua_rawgeti (L, LUA_REGISTRYINDEX, recce_ref);
      /* Lua stack [ recce_ref, recce_table ] */
      return 1;
    }

    static int
    lca_register(lua_State* L)
    {
        marpa_luaL_checktype(L, 1, LUA_TTABLE);
        marpa_luaL_checkany(L, 2);
        marpa_lua_pushinteger(L, marpa_luaL_ref(L, 1));
        return 1;
    }

    static int
    lca_unregister(lua_State* L)
    {
        marpa_luaL_checktype(L, 1, LUA_TTABLE);
        marpa_luaL_checkinteger(L, 2);
        marpa_luaL_unref(L, 1, (int)marpa_lua_tointeger(L, 2));
        return 0;
    }

    -- miranda: section+ luaL_Reg definitions
    static const struct luaL_Reg kollos_funcs[] = {
      { "from_vlq", lca_from_vlq },
      { "to_vlq", lca_to_vlq },
      { "registry_get", lca_registry_get },
      { "register", lca_register },
      { "unregister", lca_unregister },
      { NULL, NULL },
    };

```

`kollos_robrefinc()`
creates a new reference
to a Kollos registry object,
and takes ownership of it.

```

    -- miranda: section+ C function declarations
    void kollos_robrefinc(lua_State* L, lua_Integer lua_ref);
    -- miranda: section+ lua interpreter management
    void kollos_robrefinc(lua_State* L, lua_Integer lua_ref)
    {
        int rob_ix;
        const int base_of_stack = marpa_lua_gettop(L);
        lua_Integer refcount;
        if (marpa_lua_geti(L, LUA_REGISTRYINDEX, lua_ref) != LUA_TTABLE) {
            internal_error_handle (L, "registry object is not a table",
                __PRETTY_FUNCTION__, __FILE__, __LINE__);
        }
        rob_ix = marpa_lua_gettop(L);
        if (marpa_lua_getfield(L, rob_ix, "ref_count") != LUA_TNUMBER) {
            internal_error_handle (L, "rob ref_count is not a number",
                __PRETTY_FUNCTION__, __FILE__, __LINE__);
        }
        refcount = marpa_lua_tointeger(L, -1);
        refcount += 1;
        marpa_lua_pushinteger(L, refcount);
        marpa_lua_setfield(L, rob_ix, "ref_count");
        marpa_lua_settop(L, base_of_stack);
    }

```

Give up ownership of a reference to a Kollos registry object.
Deletes the interpreter if the reference count drops to zero.

```

    -- miranda: section+ C function declarations
    void kollos_robrefdec(lua_State* L, lua_Integer lua_ref);
    -- miranda: section+ lua interpreter management
    void kollos_robrefdec(lua_State* L, lua_Integer lua_ref)
    {
        int rob_ix;
        const int base_of_stack = marpa_lua_gettop(L);
        lua_Integer refcount;
        if (marpa_lua_geti(L, LUA_REGISTRYINDEX, lua_ref) != LUA_TTABLE) {
            internal_error_handle (L, "registry object is not a table",
                __PRETTY_FUNCTION__, __FILE__, __LINE__);
        }
        rob_ix = marpa_lua_gettop(L);
        if (marpa_lua_getfield(L, rob_ix, "ref_count") != LUA_TNUMBER) {
            internal_error_handle (L, "rob ref_count is not a number",
                __PRETTY_FUNCTION__, __FILE__, __LINE__);
        }
        refcount = marpa_lua_tointeger(L, -1);
        if (refcount <= 1) {
           marpa_luaL_unref(L, LUA_REGISTRYINDEX, (int)lua_ref);
           marpa_lua_settop(L, base_of_stack);
           return;
        }
        refcount -= 1;
        marpa_lua_pushinteger(L, refcount);
        marpa_lua_setfield(L, rob_ix, "ref_count");
        marpa_lua_settop(L, base_of_stack);
    }

```

## Kollos SLIF grammar object

### Fields

```
    -- miranda: section+ class_slg field declarations
    class_slg_fields['g1'] = true
    class_slg_fields['l0'] = true

    class_slg_fields['completion_event_by_isy'] = true
    class_slg_fields['completion_event_by_name'] = true
    class_slg_fields['discard_event_by_irl'] = true
    class_slg_fields['discard_event_by_name'] = true
    class_slg_fields['lexeme_event_by_isy'] = true
    class_slg_fields['lexeme_event_by_name'] = true
    class_slg_fields['nulled_event_by_isy'] = true
    class_slg_fields['nulled_event_by_name'] = true
    class_slg_fields['prediction_event_by_isy'] = true
    class_slg_fields['prediction_event_by_name'] = true

    class_slg_fields['exhaustion_action'] = true
    class_slg_fields['rejection_action'] = true

    class_slg_fields['nulling_semantics'] = true
    class_slg_fields['per_codepoint'] = true
    class_slg_fields['ranking_method'] = true
    class_slg_fields['ref_count'] = true

    class_slg_fields['rule_semantics'] = true
    class_slg_fields['token_semantics'] = true

    class_slg_fields.xrls = true
    class_slg_fields.xbnfs = true
    class_slg_fields.xsys = true
```

```
    -- miranda: section+ populate metatables
    local class_slg_fields = {}
    -- miranda: insert class_slg field declarations
    declarations(_M.class_slg, class_slg_fields, 'slg')
```

This is a registry object.

```
    -- miranda: section+ luaL_Reg definitions
    static const struct luaL_Reg slg_methods[] = {
      { NULL, NULL },
    };

```

### Accessors

Display any XBNF

```
    -- miranda: section+ most Lua function definitions
    function _M.class_slg.xbnf_display(slg, xbnf)
        local pieces = {}
        pieces[#pieces+1]
            = xbnf.lhs:display_form()
        pieces[#pieces+1] = '::='
        local rhs = xbnf.rhs
        for ix = 1, #rhs do
            pieces[#pieces+1]
                = rhs[ix]:display_form()
        end
        local minimum = xbnf.min
        if minimum then
            pieces[#pieces+1] =
                minimum <= 0 and '*' or '+'
        end
        return table.concat(pieces, ' ')
    end
```

```
    -- miranda: section+ most Lua function definitions
    function _M.class_slg.last_xbnfid(slg)
        return #slg.xbnfs
    end
```

```
    -- miranda: section+ most Lua function definitions
    function _M.class_slg.xbnf_name_o(slg, xbnf)
        local name = xbnf.name
        if name then return name end
        local lhs = xbnf.lhs
        return lhs.name
    end
    function _M.class_slg.xbnf_name(slg, xbnfid)
        local xbnf = slg.xbnfs[xbnfid]
        if xbnf then return slg:xbnf_name_o(xbnf) end
        return _M._internal_error('xbnf_name(), bad argument = %d', xbnfid)
    end
```

```
    -- miranda: section+ most Lua function definitions
    function _M.class_slg.lmg_rule_to_xbnfid(slg, irlid, subg_name)
        local subg = slg[subg_name]
        local irl = subg.irls[irlid]
        if not irl then
            return _M._internal_error('lmg_rule_to_xbnfid(), bad argument = %d', irlid)
        end
        local xbnf = irl.xbnf
        if xbnf then return xbnf.id end
    end
    function _M.class_slg.g1_rule_to_xbnfid(slg, irlid)
        return slg:lmg_rule_to_xbnfid(irlid, 'g1')
    end
    function _M.class_slg.l0_rule_to_xbnfid(slg, irlid)
        return slg:lmg_rule_to_xbnfid(irlid, 'l0')
    end
```

TODO -- Turn lmg_*() forms into local functions?

TODO -- Census all Lua and perl symbol name functions, including
but not limited to lmg_*(), *_name(), *_{dsl,display}_form()
and eliminate the redundant ones.

Lowest XSYID is 1.

```
    -- miranda: section+ most Lua function definitions
    function _M.class_slg.highest_symbol_id(slg)
        return #slg.xsys
    end
```

```
    -- miranda: section+ most Lua function definitions
    function _M.class_slg.symbol_name(slg, xsyid)
        local xsy = slg.xsys[xsyid]
        if not xsy then return end
        return xsy.name
    end
    function _M.class_slg.lmg_symbol_name(slg, symbol_id, subg_name)
        local subg = slg[subg_name]
        return subg:symbol_name(symbol_id)
    end
    function _M.class_slg.g1_symbol_name(slg, symbol_id)
        return slg:lmg_symbol_name(symbol_id, 'g1')
    end
    function _M.class_slg.l0_symbol_name(slg, symbol_id)
        return slg:lmg_symbol_name(symbol_id, 'l0')
    end

    function _M.class_slg.symbol_by_name(slg, xsy_name)
        local xsy = slg.xsys[xsy_name]
        if not xsy then return end
        return xsy.id
    end
    function _M.class_slg.lmg_symbol_by_name(slg, symbol_name, subg_name)
        local subg = slg[subg_name]
        return subg.isyid_by_name[symbol_name]
    end
    function _M.class_slg.g1_symbol_by_name(slg, symbol_name)
        return slg:lmg_symbol_by_name(symbol_name, 'g1')
    end
    function _M.class_slg.l0_symbol_by_name(slg, symbol_name)
        return slg:lmg_symbol_by_name(symbol_name, 'l0')
    end

    function _M.class_slg.lmg_symbol_dsl_form(slg, symbol_id, subg_name)
        local subg = slg[subg_name]
        return subg:symbol_dsl_form(symbol_id)
    end
    function _M.class_slg.g1_symbol_dsl_form(slg, symbol_id)
        return slg:lmg_symbol_dsl_form(symbol_id, 'g1')
    end
    function _M.class_slg.l0_symbol_dsl_form(slg, symbol_id)
        return slg:lmg_symbol_dsl_form(symbol_id, 'l0')
    end

    function _M.class_slg.lmg_symbol_display_form(slg, symbol_id, subg_name)
        local subg = slg[subg_name]
        return subg:symbol_display_form(symbol_id)
    end
    function _M.class_slg.g1_symbol_display_form(slg, symbol_id)
        return slg:lmg_symbol_display_form(symbol_id, 'g1')
    end
    function _M.class_slg.l0_symbol_display_form(slg, symbol_id)
        return slg:lmg_symbol_display_form(symbol_id, 'l0')
    end

```

```
    -- miranda: section+ most Lua function definitions
    function _M.class_slg.lmg_rule_show(slg, irlid, subg_name)
        local subg = slg[subg_name]
        local irl_isyids = subg:irl_isyids(irlid)
        local pieces = {}
        pieces[#pieces+1]
            = subg:symbol_display_form(irl_isyids[1])
        pieces[#pieces+1] = '::='
        for ix = 2, #irl_isyids do
            pieces[#pieces+1]
                = subg:symbol_display_form(irl_isyids[ix])
        end
        local minimum = subg:sequence_min(irlid)
        if minimum then
            pieces[#pieces+1] =
                minimum <= 0 and '*' or '+'
        end
        return table.concat(pieces, ' ')
    end
    function _M.class_slg.g1_rule_show(slg, irlid)
        return slg:lmg_rule_show(irlid, 'g1')
    end
    function _M.class_slg.l0_rule_show(slg, irlid)
        return slg:lmg_rule_show(irlid, 'l0')
    end

    function _M.class_slg.lmg_rule_display(slg, irlid, subg_name)
        local subg = slg[subg_name]
        local irl = subg.irls[irlid]
        if not irl then
            return '(bad irlid ' .. irlid .. ')'
        end
        local xbnf = irl.xbnf
        if xbnf then
             return slg:xbnf_display(xbnf)
        end
        return slg:lmg_rule_show(irlid, subg_name)
    end
    function _M.class_slg.g1_rule_display(slg, irlid)
        return slg:lmg_rule_display(irlid, 'g1')
    end
    function _M.class_slg.l0_rule_display(slg, irlid)
        return slg:lmg_rule_display(irlid, 'l0')
    end

    -- library IF
    function _M.class_slg.lmg_dotted_rule_show(slg, irlid, dot_arg, subg_name)
        local subg = slg[subg_name]
        local irl_isyids = subg:irl_isyids(irlid)
        if not irl_isyids then
             _M.userX(string.format(
                 "dotted_rule_show(%s, %s, %s): %s is not a valid irlid",
                 irlid, dot_arg, subg_name, irlid
             ))
        end
        local pieces = {}
        pieces[#pieces+1]
            = subg:symbol_display_form(irl_isyids[1])
        pieces[#pieces+1] = '::='
        local dot_used
        local dot = dot_arg == -1 and #irl_isyids + 1 or dot_arg + 2
        for ix = 2, #irl_isyids do
            if dot == ix then
                pieces[#pieces+1] = '.'
                dot_used = true
            end
            pieces[#pieces+1]
                = subg:symbol_display_form(irl_isyids[ix])
        end
        local minimum = subg:sequence_min(irlid)
        if minimum then
            pieces[#pieces+1] =
                minimum <= 0 and '*' or '+'
        end
        if dot == #irl_isyids + 1 then
            pieces[#pieces+1] = '.'
            dot_used = true
        end
        if not dot_used then
             _M.userX(string.format(
                 "dotted_rule_show(%s, %s, %s): dot is %s; must be -1, or 0-%d",
                 irlid, dot_arg, subg_name, dot_arg, #irl_isyids + 1
             ))
        end
        return table.concat(pieces, ' ')
    end
    -- library IF
    function _M.class_slg.g1_dotted_rule_show(slg, irlid, dot)
        return slg:lmg_dotted_rule_show(irlid, dot, 'g1')
    end
    -- library IF
    function _M.class_slg.l0_dotted_rule_show(slg, irlid, dot)
        return slg:lmg_dotted_rule_show(irlid, dot, 'l0')
    end

    function _M.class_slg.lmg_rules_show(slg, subg_name, verbose)
        verbose = verbose or 0
        local lmw_g = slg[subg_name].lmw_g
        local pcs = {}
        for irlid = 0, lmw_g:highest_rule_id() do

            local pcs2 = {}
            pcs2[#pcs2+1] = string.upper(subg_name)
            pcs2[#pcs2+1] = 'R' .. irlid
            pcs2[#pcs2+1] = slg:lmg_rule_show(irlid, subg_name)
            pcs[#pcs+1] = table.concat(pcs2, ' ')
            pcs[#pcs+1] = "\n"

            local lhsid
            local rhsids = {}
            local rule_length
            if verbose >= 2 then
                lhsid = lmw_g:rule_lhs(irlid)
                rhsids = {}
                rule_length = lmw_g:rule_length(irlid)
                local comments = {}
                if lmw_g:rule_length(irlid) == 0 then
                    comments[#comments+1] = 'empty'
                end
                if lmw_g:_rule_is_used(irlid) == 0 then
                    comments[#comments+1] = '!used'
                end
                if lmw_g:rule_is_productive(irlid) == 0 then
                    comments[#comments+1] = 'unproductive'
                end
                if lmw_g:rule_is_accessible(irlid) == 0 then
                    comments[#comments+1] = 'inaccessible'
                end
                local irl = slg[subg_name].lmw_g.irls[irlid]
                local xbnf = irl.xbnf
                if xbnf then
                    if xbnf.discard_separation then
                        comments[#comments+1] = 'discard_sep'
                    end
                end
                if #comments > 0 then
                    local pcs3 = {}
                    for ix = 1, #comments do
                        pcs3[#pcs3+1] = "/*" .. comments[ix] .. "*/"
                    end
                    pcs[#pcs+1] = table.concat(pcs3, ' ')
                    pcs[#pcs+1] = "\n"
                end
                pcs2 = {}
                pcs2[#pcs2+1] = '  Symbol IDs:'
                for ix = 0, rule_length - 1 do
                   rhsids[ix] = lmw_g:rule_rhs(irlid, ix)
                end
                pcs2[#pcs2+1] = '<' .. lhsid .. '>'
                pcs2[#pcs2+1] = '::='
                for ix = 0, rule_length - 1 do
                    pcs2[#pcs2+1] = '<' .. rhsids[ix] .. '>'
                end
                pcs[#pcs+1] = table.concat(pcs2, ' ')
                pcs[#pcs+1] = "\n"
            end
            if verbose >= 3 then
                local pcs2 = {}
                pcs2[#pcs2+1] = '  Internal symbols:'
                pcs2[#pcs2+1] = '<' .. slg:lmg_symbol_name(lhsid, subg_name) .. '>'
                pcs2[#pcs2+1] = '::='
                for ix = 0, rule_length - 1 do
                    pcs2[#pcs2+1]
                        = '<'
                            ..  slg:lmg_symbol_name(rhsids[ix], subg_name)
                            ..  '>'
                end
                pcs[#pcs+1] = table.concat(pcs2, ' ')
                pcs[#pcs+1] = "\n"
            end
        end
        return table.concat(pcs)
    end
    function _M.class_slg.g1_rules_show(slg, verbose)
        return slg:lmg_rules_show('g1', verbose)
    end
    function _M.class_slg.l0_rules_show(slg, verbose)
        return slg:lmg_rules_show('l0', verbose)
    end
```

### Mutators

```
    -- miranda: section+ most Lua function definitions
    function _M.class_slg.g1_symbol_assign(slg, symbol_name, options)
        local isyid = slg:g1_symbol_by_name(symbol_name)
        if isyid then
            -- symbol already exists
            return isyid
        end

        local g1g = slg.g1
        local isy = g1g:symbol_new(symbol_name)
        isyid = isy.id
        g1g.isys[isyid] = isy
        local properties = {}
        -- Assuming order does not matter
        for property, value in pairs(options or {}) do
            if property == 'wsyid' then
                goto NEXT_PROPERTY
            end
            if property == 'xsy' then
                local xsy = slg.xsys[value]
                g1g.xsys[isyid] = xsy
                goto NEXT_PROPERTY
            end
            if property == 'terminal' then
                gig:symbol_is_terminal_set(isyid, value)
                goto NEXT_PROPERTY
            end
            if property == 'rank' then
                int_value = math.tointeger(value)
                if not int_value then
                    error(string.format('Symbol %q": rank is %s; must be an integer',
                        symbol_name,
                        inspect(value, {depth = 1})
                    ))
                end
                g1g:symbol_rank_set(isyid, value)
                goto NEXT_PROPERTY
            end
            error(string.format('Internal error: Symbol %q has unknown property %q',
                symbol_name,
                property
            ))
            ::NEXT_PROPERTY::
        end
        return isyid
    end

```

```
    -- miranda: section+ most Lua function definitions
    function _M.class_slg.l0_symbol_assign(slg, symbol_name, options)
        local isyid = slg:l0_symbol_by_name(symbol_name)
        if isyid then
            -- symbol already exists
            return isyid
        end

        local l0g = slg.l0
        local isy = l0g:symbol_new(symbol_name)
        local isyid = isy.id
        l0g.isys[isyid] = isy

        local properties = {}
        -- Assuming order does not matter
        for property, value in pairs(options or {}) do
            if property == 'wsyid' then
                goto NEXT_PROPERTY
            end
            if property == 'xsy' then
                local xsy = slg.xsys[value]
                l0g.xsys[isyid] = xsy
                goto NEXT_PROPERTY
            end
            if property == 'terminal' then
                gig:symbol_is_terminal_set(isyid, value)
                goto NEXT_PROPERTY
            end
            if property == 'rank' then
                local int_value = math.tointeger(value)
                if not int_value then
                    error(string.format('Symbol %q": rank is %s; must be an integer',
                        symbol_name,
                        inspect(value, {depth = 1})
                    ))
                end
                l0g:symbol_rank_set(isyid, value)
                goto NEXT_PROPERTY
            end
            if property == 'eager' then
                local int_value = math.tointeger(value)
                if not int_value or (int_value > 1 and int_value < 0) then
                    error(string.format('Symbol %q": eager is %s; must be a boolean',
                        symbol_name,
                        inspect(value, {depth = 1})
                    ))
                end
                if int_value == 1 then
                    l0g.isys[isyid].eager = true
                end
                goto NEXT_PROPERTY
            end
            error(string.format('Internal error: Symbol %q has unknown property %q',
                symbol_name,
                property
            ))
            ::NEXT_PROPERTY::
        end
        return isyid
    end
```

### Hash to runtime processing

The object, in computing the hash, is to get as much
precomputation in as possible, without using undue space.
That means CPU-intensive processing should tend to be done
before or during hash creation, and space-intensive processing
should tend to be done here, in the code that converts the
hash to its runtime equivalent.

Populate the `xsys` table.

```
    -- miranda: section+ most Lua function definitions
    function _M.class_slg.xsys_populate(slg, source_hash)
        local xsys = {}
        slg.xsys = xsys

        -- io.stderr:write(inspect(source_hash))
        local xsy_names = {}
        local hash_xsy_data = source_hash.xsy
        for xsy_name, _ in pairs(hash_xsy_data) do
             xsy_names[#xsy_names+1] = xsy_name
        end
        table.sort(xsy_names)
        for xsy_id = 1, #xsy_names do
            local xsy_name = xsy_names[xsy_id]

            local runtime_xsy = setmetatable({}, _M.class_xsy)
            local xsy_source = hash_xsy_data[xsy_name]

            runtime_xsy.id = xsy_id
            runtime_xsy.name = xsy_name
            -- copy, so that we can destroy `source_hash`
            runtime_xsy.lexeme_semantics = xsy_source.action
            runtime_xsy.blessing = xsy_source.blessing
            runtime_xsy.dsl_form = xsy_source.dsl_form
            runtime_xsy.if_inaccessible = xsy_source.if_inaccessible
            runtime_xsy.name_source = xsy_source.name_source

            xsys[xsy_name] = runtime_xsy
            xsys[xsy_id] = runtime_xsy
        end
    end
```

Populate the `xrls` table.
The contents of this table are not used,
currently,
but Jeffrey thinks they might be used someday,
for example in error messages.

```
    -- miranda: section+ most Lua function definitions
    function _M.class_slg.xrls_populate(slg, source_hash)
        local xrls = {}
        slg.xrls = xrls

        -- io.stderr:write(inspect(source_hash))
        local xrl_names = {}
        local hash_xrl_data = source_hash.xrl
        for xrl_name, _ in pairs(hash_xrl_data) do
             xrl_names[#xrl_names+1] = xrl_name
        end
        table.sort(xrl_names,
           function(a, b)
                if a ~= b then return a < b end
                local start_a = hash_xrl_data[a].start
                local start_b = hash_xrl_data[b].start
                return start_a < start_b
           end
        )
        for xrl_id = 1, #xrl_names do
            local xrl_name = xrl_names[xrl_id]
            local runtime_xrl = setmetatable({}, _M.class_xrl)
            local xrl_source = hash_xrl_data[xrl_name]

            runtime_xrl.id = xrl_id
            runtime_xrl.name = xrl_name
            -- copy, so that we can destroy `source_hash`
            runtime_xrl.precedence_count = xrl_source.precedence_count
            runtime_xrl.lhs = xrl_source.lhs
            runtime_xrl.start = xrl_source.start
            runtime_xrl.length = xrl_source.length

            xrls[xrl_name] = runtime_xrl
            xrls[xrl_id] = runtime_xrl
        end
    end
```

Populate xbnfs.
"xbnfs" are eXternal BNF rules.
They are actually not fully external,
but are first translation of the XRLs into
BNF form.
One symptom of their less-than-fully external
nature is that they are two `xbnfs` tables,
one for each subgrammar.
(The subgrammars are only visible internally.)

```
    -- miranda: section+ most Lua function definitions
    function _M.class_slg.xbnfs_subg_populate(slg, source_hash, subgrammar)
        local xbnfs = slg.xbnfs
        -- io.stderr:write(inspect(source_hash))
        local xbnf_names = {}
        local xsys = slg.xsys
        local hash_xbnf_data = source_hash.xbnf[subgrammar]
        for xbnf_name, _ in pairs(hash_xbnf_data) do
             xbnf_names[#xbnf_names+1] = xbnf_name
        end
        table.sort(xbnf_names,
           function(a, b)
                local start_a = hash_xbnf_data[a].start
                local start_b = hash_xbnf_data[b].start
                if start_a ~= start_b then return start_a < start_b end
                local subkey_a = hash_xbnf_data[a].subkey
                local subkey_b = hash_xbnf_data[b].subkey
                return subkey_a < subkey_b
           end
        )
        for ix = 1, #xbnf_names do
            local xbnf_name = xbnf_names[ix]
            local runtime_xbnf = setmetatable({}, _M.class_xbnf)

            local xbnf_source = hash_xbnf_data[xbnf_name]

            -- copy, so that we can destroy `source_hash`

            runtime_xbnf.xrl_name = xbnf_source.xrlid
            runtime_xbnf.name = xbnf_source.name
            runtime_xbnf.subgrammar = xbnf_source.subgrammar
            runtime_xbnf.lhs = xsys[xbnf_source.lhs]
            local to_rhs = {}
            local from_rhs = xbnf_source.rhs
            for ix = 1, #from_rhs do
                to_rhs[ix] = xsys[xbnf_source.rhs[ix]]
            end
            runtime_xbnf.rhs = to_rhs
            runtime_xbnf.rank = xbnf_source.rank
            runtime_xbnf.null_ranking = xbnf_source.null_ranking

            runtime_xbnf.symbol_as_event = xbnf_source.symbol_as_event
            local source_event = xbnf_source.event
            if source_event then
                runtime_xbnf.event_name = source_event[1]
                -- TODO revisit type (boolean? string? integer?)
                --   once conversion to Lua is complete
                runtime_xbnf.event_starts_active
                    = (math.tointeger(source_event[2]) ~= 0)
            end

            if xbnf_source.min then
                runtime_xbnf.min = math.tointeger(xbnf_source.min)
            end
            runtime_xbnf.separator = xbnf_source.separator
            runtime_xbnf.proper = xbnf_source.proper
            runtime_xbnf.bless = xbnf_source.bless
            runtime_xbnf.action = xbnf_source.action
            runtime_xbnf.start = xbnf_source.start
            runtime_xbnf.length = xbnf_source.length

            runtime_xbnf.discard_separation =
                xbnf_source.separator and
                    not xbnf_source.keep

            local rhs_length = #xbnf_source.rhs

            -- min defined if sequence rule
            if not xbnf_source.min or rhs_length == 0 then
                if xbnf_source.mask then
                    runtime_xbnf.mask = xbnf_source.mask
                else
                    local mask = {}
                    for i = 1, rhs_length do
                        mask[i] = 1
                    end
                    runtime_xbnf.mask = mask
                end
            end

            local next_xbnf_id = #xbnfs + 1
            runtime_xbnf.id = next_xbnf_id
            xbnfs[xbnf_name] = runtime_xbnf
            xbnfs[next_xbnf_id] = runtime_xbnf
        end
    end
    function _M.class_slg.xbnfs_populate(slg, source_hash)
        slg.xbnfs = {}
        slg:xbnfs_subg_populate(source_hash, 'l0')
        return slg:xbnfs_subg_populate(source_hash, 'g1')
    end
```

```
    -- miranda: section+ most Lua function definitions
    function _M.class_slg.g1_xsyid(slg, isy_key)
        return slg.g1:xsyid(isy_key)
    end
    function _M.class_slg.l0_xsyid(slg, isy_key)
        return slg.l0:xsyid(isy_key)
    end
```

## Kollos SLIF recognizer object

This is a registry object.

### Fields

```
    -- miranda: section+ class_slr field declarations
    class_slr_fields.accept_queue = true
    class_slr_fields.codepoint = true
    class_slr_fields.current_block = true
    class_slr_fields.end_of_lexeme = true
    class_slr_fields.end_of_parse = true
    class_slr_fields.event_queue = true
    class_slr_fields.g1 = true
    class_slr_fields.has_parse = true
    class_slr_fields.inputs = true
    class_slr_fields.is_external_scanning = true
    class_slr_fields.l0 = true
    class_slr_fields.l0_candidate = true
    class_slr_fields.g1_isys = true
    class_slr_fields.l0_irls = true
    class_slr_fields.irls = true
    class_slr_fields.lexeme_queue = true
    class_slr_fields.lmw_b = true
    class_slr_fields.lmw_o = true
    class_slr_fields.lmw_t = true
    class_slr_fields.lmw_v = true
    class_slr_fields.max_parses = true
    class_slr_fields.per_es = true
    class_slr_fields.phase = true
    class_slr_fields.regix = true
    class_slr_fields.ref_count = true
    class_slr_fields.slg = true
    class_slr_fields.start_of_lexeme = true
    class_slr_fields.terminals_expected = true
    class_slr_fields.this_step = true
    class_slr_fields.too_many_earley_items = true
    class_slr_fields.token_is_literal = true
    class_slr_fields.token_is_undef = true
    class_slr_fields.token_values = true
    class_slr_fields.trace_terminals = true
    class_slr_fields.trace_values = true
    class_slr_fields.trace_values_queue = true
    class_slr_fields.tree_mode = true
    class_slr_fields.trailers = true
    -- TODO delete after development
    class_slr_fields.has_event_handlers = true
    class_slr_fields.end_of_pause_lexeme = true
    class_slr_fields.start_of_pause_lexeme = true
```

*At end of input* field:
`true` when at "end of input",
nil otherwise.
It is "end of input" because
a Kollos input can traverse multiple
files.
This is a common requirement:
It is necessary, for example,
for parsing C language.

```
    -- miranda: section+ class_slr field declarations
    class_slr_fields.at_eoi = true
```

*Block mode*:
`true` in block mode,
`nil` otherwise.
Kollos read method and its block-by-block
methods are not compatible.
This boolean keeps them from begin used
together.

```
    -- miranda: section+ class_slr field declarations
    class_slr_fields.block_mode = true
```

```
    -- miranda: section+ populate metatables
    local class_slr_fields = {}
    -- miranda: insert class_slr field declarations
    declarations(_M.class_slr, class_slr_fields, 'slr')
```

```
    -- miranda: section+ luaL_Reg definitions
    static const struct luaL_Reg slr_methods[] = {
      {"step", lca_slr_step_meth},
      { NULL, NULL },
    };

```

### Constructors

```
    -- miranda: section+ most Lua function definitions
    function _M.class_slg.slr_new(slg, flat_args)
        local slr = {}
        setmetatable(slr, _M.class_slr)
        slr.phase = 'initial'
        slr.slg = slg
        local registry = debug.getregistry()
        slr.regix = _M.register(registry, slr)
        slr.ref_count = 1

        local l0g = slg.l0
        slr.l0 = {}
        slr.l0_irls = {}

        local g1g = slg.g1
        slr.g1 = _M.recce_new(g1g)
        local g1r = slr.g1

        -- TODO Census, eliminate most (all?) references via lmw_g
        slr.g1_isys = {}

        slr.codepoint = nil
        slr.inputs = {}

        slr.max_parses = nil
        slr.per_es = {}
        slr.current_block = nil

        -- Trailing (that is, discarded) sweeps by
        -- G0 Earley set index.  Integer indices, but not
        -- necessarily a sequence.
        slr.trailers = {}

        slr.event_queue = {}

        slr.lexeme_queue = {}
        slr.accept_queue = {}

        slr.too_many_earley_items = -1
        slr.trace_terminals = 0
        slr.start_of_lexeme = 0
        slr.end_of_lexeme = 0
        slr.start_of_pause_lexeme = -1
        slr.end_of_pause_lexeme = -1
        slr.is_external_scanning = false

        local g_l0_rules = slg.l0.irls
        local r_l0_rules = slr.l0_irls
        -- print('g_l0_rules: ', inspect(g_l0_rules))
        local max_l0_rule_id = l0g:highest_rule_id()
        for rule_id = 0, max_l0_rule_id do
            local r_l0_rule = {}
            local g_l0_rule = g_l0_rules[rule_id]
            if g_l0_rule then
                for field, value in pairs(g_l0_rule) do
                    r_l0_rule[field] = value
                end
            end
            r_l0_rules[rule_id] = r_l0_rule
        end
        -- print('r_l0_rules: ', inspect(r_l0_rules))
        local g_g1_symbols = slg.g1.isys
        local r_g1_symbols = slr.g1_isys
        local max_g1_symbol_id = g1g:highest_symbol_id()
        for symbol_id = 0, max_g1_symbol_id do
            r_g1_symbols[symbol_id] = {
                lexeme_priority =
                    g_g1_symbols[symbol_id].priority,
                pause_before_active =
                    g_g1_symbols[symbol_id].pause_before_active,
                pause_after_active =
                    g_g1_symbols[symbol_id].pause_after_active
            }
        end
        slr:valuation_reset()

        slr:common_set(flat_args, {'event_is_active',
            -- TODO delete after development
            'event_handlers'
        })
        local trace_terminals = slr.trace_terminals
        local start_input_return = g1r:start_input()
        if start_input_return == -1 then
            error( string.format('Recognizer start of input failed: %s',
                g1g.error_description()))
        end
        if start_input_return < 0 then
            error( string.format('Problem in start_input(): %s',
                g1g.error_description()))
        end
        slr:g1_convert_events()

        if trace_terminals > 1 then
            local terminals_expected = slr.g1:terminals_expected()
            table.sort(terminals_expected)
            for ix = 1, #terminals_expected do
                local terminal = terminals_expected[ix]
                coroutine.yield('trace',
                    string.format('Expecting %q at earleme 0',
                    slg:g1_symbol_name(terminal)))
            end
        end
        slr.token_values = {}
        slr.token_is_undef = 1
        slr.token_values[slr.token_is_undef] = glue.sv.undef()

        -- token is literal is a pseudo-index, and the SV undef
        -- is just a place holder
        slr.token_is_literal = 2
        slr.token_values[slr.token_is_literal] = glue.sv.undef()

        return slr
    end
```

```
    -- miranda: section+ most Lua function definitions
    function _M.class_slr.l0r_new(slr)
        local l0r = _M.recce_new(slr.slg.l0)

        local block_ix, l0_pos = slr:block_where()
        local g1g = slr.slg.g1

        if not l0r then
            error('Internal error: l0r_new() failed %s',
                slr.slg.l0:error_description())
        end
        slr.l0 = l0r
        -- reset the candidate in the lexer
        slr.l0_candidate = nil
        local too_many_earley_items = slr.too_many_earley_items
        if too_many_earley_items >= 0 then
            l0r:earley_item_warning_threshold_set(too_many_earley_items)
        end
         -- for now use a per-slr field
         -- later replace with a local
        slr.terminals_expected = slr.g1:terminals_expected()
        local count = #slr.terminals_expected
        if not count or count < 0 then
            local error_description = slr.g1:error_description()
            error('Internal error: terminals_expected() failed in u_l0r_new(); %s',
                    error_description)
        end
        for i = 0, count -1 do
            local ix = i + 1
            local terminal = slr.terminals_expected[ix]
            local assertion = slr.slg.g1.isys[terminal].assertion
            assertion = assertion or -1
            if assertion >= 0 then
                local result = l0r:zwa_default_set(assertion, 1)
                if result < 0 then
                    local error_description = l0r:error_description()
                    error('Problem in u_l0r_new() with assertion ID %ld and lexeme ID %ld: %s',
                        assertion, terminal, error_description
                    )
                end
            end

            if slr.trace_terminals >= 3 then
                local xsy = g1g:_xsy(terminal)
                if xsy then
                    local display_form = xsy:display_form()
                    coroutine.yield('trace', string.format(
                        "Expected lexeme %s at %s; assertion ID = %d",
                        display_form,
                        slr:lc_brief(l0_pos),
                        assertion
                    ))
                end
            end

        end
        local result = l0r:start_input()
        if result and result <= -2 then
            local error_description = l0r:error_description()
            error('Internal error: problem with slr:start_input(l0r): %s',
                error_description)
        end
    end

```

A common processor for
the recognizer's Lua-level settings.

```
    -- miranda: section+ most Lua function definitions
    function _M.class_slr.common_set(slr, flat_args, extra_args)
        local ok_args = {
            trace_terminals = true,
            ['end'] = true,
            max_parses = true,
            too_many_earley_items = true,
            trace_values = true
        }
        if extra_args then
            for ix = 1, #extra_args do
                ok_args[extra_args[ix]] = true
            end
        end

        for name, value in pairs(flat_args) do
           if not ok_args[name] then
               error(string.format(
                   'Bad slr named argument: %s => %s',
                   inspect(name),
                   inspect(value)
               ))
           end
        end

        local raw_value

        -- TODO delete after development
        raw_value = flat_args.event_handlers
        if raw_value then
            slr.has_event_handlers = true
        end

        -- trace_terminals named argument --
        raw_value = flat_args.trace_terminals
        if raw_value then
            local value = math.tointeger(raw_value)
            if not value then
               error(string.format(
                   'Bad value for "trace_terminals" named argument: %s',
                   inspect(raw_value)))
            end
            if value ~= 0 then
                coroutine.yield('trace', 'Setting trace_terminals option')
            end
            slr.trace_terminals = value
        end

        -- max_parses named argument --
        raw_value = flat_args.max_parses
        if raw_value then
            local value = math.tointeger(raw_value)
            if not value then
               error(string.format(
                   'Bad value for "max_parses" named argument: %s',
                   inspect(raw_value)))
            end
            slr.max_parses = value
        end

        -- trace_values named argument --
        raw_value = flat_args.trace_values
        if raw_value then
            local value = math.tointeger(raw_value)
            if not value then
               error(string.format(
                   'Bad value for "trace_values" named argument: %s',
                   inspect(raw_value)))
            end
            if value ~= 0 then
                coroutine.yield('trace', 'Setting trace_values option to ' .. value)
            end
            slr.trace_values = value
        end

        -- too_many_earley_items named argument --
        raw_value = flat_args.too_many_earley_items
        if raw_value then
            local value = math.tointeger(raw_value)
            if not value then
               error(string.format(
                   'Bad value for "too_many_earley_items" named argument: %s',
                   inspect(raw_value)))
            end
            slr.too_many_earley_items = value
            slr.g1:earley_item_warning_threshold_set(value)
        end

        -- 'end' named argument --
        raw_value = flat_args["end"]
        if raw_value then
            local value = math.tointeger(raw_value)
            if not value then
               error(string.format(
                   'Bad value for "end" named argument: %s',
                   inspect(raw_value)))
            end
            if slr.lmw_b then
                error'Cannot reset end of parse once evaluation has started'
            end
            slr.end_of_parse = value
        end

        -- 'event_is_active' named argument --
        -- Completion/nulled/prediction events are always initialized by
        -- Libmarpa to 'on'.  So here we need to override that if and only
        -- if we in fact want to initialize them to 'off'.
        --
        -- Events are already initialized as described by
        -- the DSL.  Here we override that with the recce arg, if
        -- necessary.
        raw_value = flat_args.event_is_active
        if raw_value then
            if type(raw_value) ~= 'table' then
               error(string.format(
                   'Bad value for "event_is_active" named argument: %s',
                   inspect(raw_value,{depth=1})))
            end
            for event_name, raw_activate in pairs(raw_value) do
                local activate = math.tointeger(raw_activate)
                if not activate or activate > 1 or activate < 0 then
                   error(string.format(
                       'Bad activation value for %q event in\z
                       "event_is_active" named argument: %s',
                       inspect(raw_activate,{depth=1})))
                end
                activate = activate == 1 and true or false
                slr:activate_by_event_name(event_name, activate)
            end
        end
    end
```

### Reading

The top-level read function.

Return `true` if the read is alive (this is,
if there is some way to continue it),
`false` otherwise.

```
    -- miranda: section+ most Lua function definitions
    function _M.class_slr.read(slr)
        if slr.is_external_scanning then
           _M.userX( 'unpermitted mix of external and internal scanning' )
        end
        if slr.block_mode then
           _M.userX( 'unpermitted use of slr.read() in block mode' )
        end
        slr.start_of_pause_lexeme = -1
        slr.end_of_pause_lexeme = -1
        slr.event_queue = {}
        while true do
            local _, l0_pos, end_pos = slr:block_where()
            if l0_pos >= end_pos then
                -- a 'normal' return
                return false
            end
            if l0_pos >= 0 then
                slr.start_of_lexeme = l0_pos
                slr.l0 = nil
                if slr.trace_terminals >= 1 then
                    coroutine.yield('trace', string.format(
                        'Restarted recognizer at %s',
                        slr:lc_brief(l0_pos)
                    ))
                end
            end
            local g1r = slr.g1
            slr:l0_read_lexeme()
            local discard_mode = (g1r:is_exhausted() ~= 0)
            -- TODO: work on this
            local alive = slr:alternatives(discard_mode)
            if not alive then return false end
            local event_count = #slr.event_queue
            if event_count >= 1 then return true end
        end
        error('Internal error: unexcepted end of read loop')
    end
```

"Complete" an earleme in L0.
Return `true` if the parser is "alive",
that is, not exhausted.
otherwise `false` and a status string.

```
    -- miranda: section+ most Lua function definitions
    function _M.class_slr.l0_earleme_complete(slr)
        local l0r = slr.l0
        local complete_result = l0r:earleme_complete()
        if complete_result == -2 then
            if l0r:error_code() == _M.err.PARSE_EXHAUSTED then
                return false, 'exhausted on failure'
            end
        end
        if complete_result < 0 then
            error('Problem in r->l0_read(), earleme_complete() failed: ',
            l0r:error_description())
        end
        if complete_result > 0 then
            slr:l0_convert_events()
            local is_exhausted = l0r:is_exhausted()
            if is_exhausted ~= 0 then
                return false, 'exhausted on success'
            end
        end
        return true
    end

```

Read an alternative.
Returns the number of alternatives accepted,
which will be 1 or 0.

```
    -- miranda: section+ most Lua function definitions
    function _M.class_slr.l0_alternative(slr, symbol_id)
        local l0r = slr.l0
        local l0g = slr.slg.l0
        local codepoint = slr.codepoint
        local result = l0r:alternative(symbol_id, 1, 1)
        local _, l0_pos = slr:block_where()
        if result == _M.err.UNEXPECTED_TOKEN_ID then
            if slr.trace_terminals >= 1 then
                coroutine.yield('trace', string.format(
                    'Codepoint %q 0x%04x rejected as %s at %s',
                    utf8.char(codepoint),
                    codepoint,
                    l0g:symbol_display_form(symbol_id),
                    slr:lc_brief(l0_pos)
                ))
            end
            return 0
        end
        if result == _M.err.NONE then
            if slr.trace_terminals >= 1 then
                coroutine.yield('trace', string.format(
                    'Codepoint %q 0x%04x accepted as %s at %s',
                    utf8.char(codepoint),
                    codepoint,
                    l0g:symbol_display_form(symbol_id),
                    slr:lc_brief(l0_pos)
                ))
            end
            return 1
        end
        error(string.format([[
             Problem alternative() failed at char ix %d; symbol id %d; codepoint 0x%x
             Problem in l0_read(), alternative() failed: %s
        ]],
            l0_pos, symbol_id, codepoint, l0r:error_description()
        ))
    end


```

Read the current codepoint in L0.
Returns `true` if the parser is "alive"
(not exhausted)/
Otherwise returns `false` and a status string.

```
    -- miranda: section+ most Lua function definitions
    function _M.class_slr.l0_read_codepoint(slr)
        local codepoint = slr.codepoint

        local ops = slr.slg.per_codepoint[codepoint]
        local op_count = ops and #ops or -1

        if op_count <= 0 then
            error( string.format(
                "Internal error: registered codepoint %d, but no ops\n", codepoint
            ))
        end

        if slr.trace_terminals >= 1 then
           local _, l0_pos = slr:block_where()
           coroutine.yield('trace', string.format(
               'Reading codepoint %q 0x%04x at %s',
               utf8.char(codepoint),
               codepoint,
               slr:lc_brief(l0_pos)
           ))
        end
        local tokens_accepted = 0
        for ix = 1, op_count do
            local symbol_id = ops[ix]
            tokens_accepted = tokens_accepted +
                 slr:l0_alternative(symbol_id)
        end

        if tokens_accepted < 1 then return false, 'rejected char' end
        return slr:l0_earleme_complete()
    end

```

Read a lexeme from the L0 recognizer.
Returns `true` on success,
otherwise `false` and a status string.

```
    -- miranda: section+ most Lua function definitions
    function _M.class_slr.l0_read_lexeme(slr)
        if not slr.l0 then
            slr:l0r_new()
        end
        while true do
            local block_ix, l0_pos, end_pos = slr:block_where()
            if l0_pos >= end_pos then
                return true
            end
            -- +1 because codepoints array is 1-based
            slr.codepoint = slr:codepoint_from_pos(block_ix, l0_pos)
            local alive, status = slr:l0_read_codepoint()
            local this_candidate, eager = slr:l0_track_candidates()
            if this_candidate then slr.l0_candidate = this_candidate end
            if eager then return true end
            if not alive then return false, status end
            slr:block_move(l0_pos + 1)
        end
        error('Unexpected fall through in l0_read()')
    end

```

Determine which paths
and candidates
are active.
Right now this is a prototype:
Only LATM is implemented;
a candidate is an earley set ID;
candidates are moved
and seconded at once.

The candidate eventually
chosen is the last one
moved, unless one of the candidates is
eager.
That is decided by the caller --
the candidate and an `eager` boolean are
returned  so it can make that decision.

Return earley set ID if we have the completion of a lexeme
rule, false otherwise.

```
    -- miranda: section+ most Lua function definitions
    function _M.class_slr.l0_track_candidates(slr)
        local l0r = slr.l0
        local l0g = slr.slg.l0
        local l0_rules = slr.l0_irls
        local eager = false
        local complete_lexemes = false
        local es_id = l0r:latest_earley_set()
        -- Do we have a completion of a lexeme rule?
        for eim_id = 0, math.maxinteger do
            local rule_id, dot = l0r:earley_item_look(es_id, eim_id)
            if not rule_id then goto LAST_EIM end
            -- ignore rules with no XRL
            if rule_id < 0 then goto NEXT_EIM end
            -- ignore non-completions
            if dot >= 0 then goto NEXT_EIM end
            complete_lexemes = true
            -- when we expand this, the ID of the g1 lexeme
            -- will matter; right now it does not.
            -- local g1_lexeme = l0_rules[rule_id].g1_lexeme
            eager = eager or l0_rules[rule_id].eager
            ::NEXT_EIM::
        end
        ::LAST_EIM::
        if complete_lexemes then return es_id, eager end
        return
    end
```

`no_lexeme_handle()` handles the situation where the recognizer does
not find an acceptable lexeme.

```
    -- miranda: section+ most Lua function definitions
    function _M.class_slr.no_lexeme_handle(slr)
       if slr.slg.rejection_action == 'event' then
           local q = slr.event_queue
           q[#q+1] = { "'rejected" }
           return
       end
       return slr:throw_at_pos(string.format(
            "No lexeme found at %s",
            slr:lc_brief(slr.start_of_lexeme))
            )
    end
```

```
    -- miranda: section exhausted(), nested function of slr:alternatives()
    local function exhausted()
        -- no accepted or discarded lexemes
        if discard_mode then
           if slr.slg.exhaustion_action == 'event' then
               local q = slr.event_queue
               q[#q+1] = { "'exhausted" }
               return
           end
           return slr:throw_at_pos(string.format(
                "Parse exhausted, but lexemes remain, at %s",
                slr:lc_brief(slr.start_of_lexeme))
                )
        end
        local start_of_lexeme = slr.start_of_lexeme
        slr:block_move(start_of_lexeme)
        return slr:no_lexeme_handle()
    end
```

Read find and read the alternatives in the SLIF.
Returns `true` if the parse is alive,
`false` if it's exhausted.
Also returns `false` on "pause before" because
special action is probably needed before the parse
should resume.
When `false` is returned, `alternatives()`
may also return
a string indicating the status.

TODO: Is the status string needed/used?

```
    -- miranda: section+ most Lua function definitions
    function _M.class_slr.alternatives(slr, discard_mode)

        -- miranda: insert exhausted(), nested function of slr:alternatives()

        slr.lexeme_queue = {}
        slr.accept_queue = {}
        local l0r = slr.l0
        if not l0r then
            _M._internal_error('No l0r in slr_alternatives(): %s',
                slr.slg.l0:error_description())
        end
        local elect_earley_set = slr.l0_candidate
        -- no zero-length lexemes, so Earley set 0 is ignored
        if not elect_earley_set then return false, exhausted() end
        local working_pos = slr.start_of_lexeme + elect_earley_set
        local return_value = l0r:progress_report_start(elect_earley_set)
        if return_value < 0 then
            _M._internal_error('Problem in slr:progress_report_start(...,%d): %s',
                elect_earley_set, l0r:error_description())
        end
        local discarded, high_lexeme_priority = slr:l0_earley_set_examine(working_pos)
        -- PASS 2 --
        slr:lexeme_queue_examine(high_lexeme_priority)
        local accept_q = slr.accept_queue
        if #accept_q <= 0 then
            if discarded <= 0 then return false, exhausted() end
            -- if here, no accepted lexemes, but discarded ones
            slr:block_move(working_pos)
            local latest_es = slr.g1:latest_earley_set()
            local trailers = slr.trailers
            trailers[latest_es] =
                _M.sweep_add(trailers[latest_es],
                    slr.current_block.index,
                    slr.start_of_lexeme,
                    working_pos - slr.start_of_lexeme
                )
            return true
        end
        -- PASS 3 --
        local result = slr:do_pause_before()
        if result then return false, 'pause before' end
        slr:g1_earleme_complete()
        return true
    end
```

A utility function to create discard traces,
because this is done in two different places.

```
    -- miranda: section+ forward declarations
    local discard_event_gen
    -- miranda: section+ most Lua function definitions
    function discard_event_gen(slr, irlid, lexeme_start, lexeme_end)
        local l0g = slr.slg.l0
        local discarded_isyid = l0g:rule_rhs(irlid, 0)
        local discard_desc =
            discarded_isyid and l0g:symbol_display_form(discarded_isyid)
                or '<Bad irlid ' .. irlid .. '>'
        local block = slr.current_block
        local block_ix = block.index
        local event = { 'discarded lexeme',
            irlid, block_ix, lexeme_start, lexeme_end }
        event.msg = string.format(
            'Discarded lexeme %s: %s',
            slr:lc_range_brief(block_ix, lexeme_start, block_ix, lexeme_end - 1),
            discard_desc
        )
        return event
    end

```

Determine which lexemes are acceptable or discards.

```
    -- miranda: section+ most Lua function definitions
    function _M.class_slr.l0_earley_set_examine(slr, working_pos)
        local discarded = 0
        local high_lexeme_priority = math.mininteger
        local block = slr.current_block
        local block_ix = block.index
        while true do
            local g1_lexeme = -1
            local rule_id, dot_position, origin = slr.l0:progress_item()
            if not rule_id then
                return discarded, high_lexeme_priority
            end
            if rule_id <= -2 then
                error(string.format('Problem in slr:progress_item(): %s'),
                    slr.l0:error_description())
            end
            if origin ~= 0 then
               goto NEXT_EARLEY_ITEM
            end
            if dot_position ~= -1 then
               goto NEXT_EARLEY_ITEM
            end
            g1_lexeme = slr.l0_irls[rule_id].g1_lexeme
            g1_lexeme = g1_lexeme or -1
            if g1_lexeme == -1 then
               goto NEXT_EARLEY_ITEM
            end
            slr.end_of_lexeme = working_pos
            -- -2 means a discarded item
            if g1_lexeme <= -2 then
               discarded = discarded + 1
               local q = slr.lexeme_queue
               q[#q+1] = discard_event_gen(slr, rule_id, slr.start_of_lexeme, slr.end_of_lexeme)
               goto NEXT_EARLEY_ITEM
            end
            -- this block hides the local's and allows the goto to work
            do
                local is_expected = slr.g1:terminal_is_expected(g1_lexeme)
                if not is_expected then
                    error(string.format('Internnal error: Marpa recognized unexpected token @%d-%d: lexme=%d',
                        slr.start_of_lexeme, slr.end_of_lexeme, g1_lexeme))
                end
                local this_lexeme_priority = slr.g1_isys[g1_lexeme].lexeme_priority
                if this_lexeme_priority > high_lexeme_priority then
                    high_lexeme_priority = this_lexeme_priority
                end
                local q = slr.lexeme_queue
                -- at this point we know the lexeme will be accepted by the grammar
                -- but we do not yet know about priority
                q[#q+1] = { 'acceptable lexeme',
                   block_ix, slr.start_of_lexeme, slr.end_of_lexeme,
                   g1_lexeme, this_lexeme_priority, this_lexeme_priority}
            end
            ::NEXT_EARLEY_ITEM::
        end
    end

```

Process the lexeme queue generated in pass 1.
In pass 1, we used a stack of tentative
trace events to record which lexemes
are acceptable, to be discarded, etc.
At this point, if we are tracing,
we convert the tentative trace
events into real trace events.

```
    -- miranda: section+ most Lua function definitions
    function _M.class_slr.lexeme_queue_examine(slr, high_lexeme_priority)
        local lexeme_q = slr.lexeme_queue
        local block = slr.current_block
        local block_ix = block.index
        for ix = 1, #slr.lexeme_queue do
            local this_event = lexeme_q[ix]
            local event_type = this_event[1]
            if event_type == 'acceptable lexeme' then
                local event_type, lexeme_block, lexeme_start, lexeme_end,
                g1_lexeme, priority, required_priority =
                    table.unpack(this_event)
                if priority < high_lexeme_priority then
                    if slr.trace_terminals > 0 then
                        local xsy = g1g:_xsy(g1_lexeme)
                        if xsy then
                            coroutine.yield('trace', string.format(
                                "Outprioritized lexeme %s: %s; value=%q;\z
                                 priority was %d, but %d is required",
                                slr:lc_range_brief(block_ix, lexeme_start, block_ix, lexeme_end - 1),
                                xsy:display_form(),
                                slr:l0_literal( lexeme_start,  lexeme_end - lexeme_start, block_ix ),
                                priority, high_lexeme_priority
                            ))
                        end
                    end
                    goto NEXT_LEXEME
                end
                -- TODO accept_queue
                local q = slr.accept_queue
                q[#q+1] = this_event
                goto NEXT_LEXEME
            end
            if event_type == 'discarded lexeme' then
                local event_type, rule_id,
                        lexeme_block, lexeme_start, lexeme_end
                    = table.unpack(this_event)
                -- we do not have the lexeme, only the lexer rule,
                -- so we will let the upper layer figure things out.
                if slr.trace_terminals > 0 then
                    local event = discard_event_gen(slr, rule_id, lexeme_start, lexeme_end)
                    coroutine.yield('trace', event.msg)
                end
                    local g1r = slr.g1
                    local event_on_discard_active =
                        slr.l0_irls[rule_id].event_on_discard_active
                    if event_on_discard_active then
                        local last_g1_location = g1r:latest_earley_set()
                        local q = slr.event_queue
                        q[#q+1] = { 'discarded lexeme',
                            rule_id,
                            lexeme_block, lexeme_start, lexeme_end - lexeme_start,
                            last_g1_location}
                     end
            end
            ::NEXT_LEXEME::
        end
        return
    end
```

Process any "pause before" lexemes.
Returns `true` is there was one,
`false` otherwise.

```
    -- miranda: section+ most Lua function definitions
    function _M.class_slr.do_pause_before(slr)
        local accept_q = slr.accept_queue
        for ix = 1, #accept_q do
            local this_event = accept_q[ix]
                -- TODO accept_queue
            local event_type, lexeme_block, lexeme_start, lexeme_end,
                    g1_lexeme, priority, required_priority =
                table.unpack(this_event)
            local pause_before_active = slr.g1_isys[g1_lexeme].pause_before_active
            if pause_before_active then
                if slr.trace_terminals > 2 then
                    coroutine.yield('trace', 'g1 before lexeme event')
                end
                local q = slr.event_queue
                q[#q+1] = {
                    'before lexeme', g1_lexeme, lexeme_block, lexeme_start,
                    lexeme_end - lexeme_start
                }
                slr.start_of_pause_lexeme = lexeme_start
                slr.end_of_pause_lexeme = lexeme_end
                local start_of_lexeme = slr.start_of_lexeme
                slr:block_move(start_of_lexeme)
                return true
            end
        end
        return false
    end
```

```
    -- miranda: section+ most Lua function definitions
    function _M.class_slr.g1_earleme_complete(slr)
        slr:g1_alternatives()
        local g1r = slr.g1
        local result = g1r:earleme_complete()
        if result < 0 then
            error(string.format(
                'Problem in marpa_r_earleme_complete(): %s',
                g1r:error_description()
            ))
        end
        local end_of_lexeme = slr.end_of_lexeme
        slr:block_move(end_of_lexeme)
        if result > 0 then slr:g1_convert_events() end
        local start_of_lexeme = slr.start_of_lexeme
        local end_of_lexeme = slr.end_of_lexeme
        local lexeme_length = end_of_lexeme - start_of_lexeme
        local g1r = slr.g1
        local latest_earley_set = g1r:latest_earley_set()
        slr.per_es[latest_earley_set] =
            { slr.current_block.index, start_of_lexeme, lexeme_length }
    end
```

Read alternatives into the G1 grammar.

```
    -- miranda: section+ most Lua function definitions
    function _M.class_slr.g1_alternatives(slr)
        local accept_q = slr.accept_queue
        local block = slr.current_block
        local block_ix = block.index
        local slg = slr.slg
        local g1g = slg.g1
        for ix = 1, #accept_q do
            local this_event = accept_q[ix]
                -- TODO accept_queue
            local event_type, lexeme_block, lexeme_start, lexeme_end,
                    g1_lexeme, priority, required_priority =
                table.unpack(this_event)

            if slr.trace_terminals > 2 then
                local xsy = g1g:_xsy(g1_lexeme)
                if xsy then
                    local working_earley_set = slr.g1:latest_earley_set() + 1
                    coroutine.yield('trace', string.format(
                        'Attempting to read lexeme %s e%d: %s; value=%q',
                        slr:lc_range_brief(block_ix, lexeme_start, block_ix, lexeme_end - 1),
                        working_earley_set,
                        xsy:display_form(),
                        slr:l0_literal( lexeme_start,  lexeme_end - lexeme_start, block_ix )
                    ))
                end
            end
            local g1r = slr.g1
            local kollos = getmetatable(g1r).kollos
            local value_is_literal = _M.defines.TOKEN_VALUE_IS_LITERAL
            local return_value = g1r:alternative(g1_lexeme, value_is_literal, 1)
            -- print('return value = ', inspect(return_value))
            if return_value == _M.err.UNEXPECTED_TOKEN_ID then
                error('Internal error: Marpa rejected expected token')
            end
            if return_value == _M.err.DUPLICATE_TOKEN then
                local xsy = g1g:_xsy(g1_lexeme)
                if xsy then
                    coroutine.yield('trace', string.format(
                        'Rejected as duplicate lexeme %s: %s; value=%q',
                        slr:lc_range_brief(block_ix, lexeme_start, block_ix, lexeme_end - 1),
                        xsy:display_form(),
                        slr:l0_literal( lexeme_start,  lexeme_end - lexeme_start, block_ix )
                    ))
                end
                goto NEXT_EVENT
            end
            if return_value ~= _M.err.NONE then
                local l0r = slr.l0
                local _, l0_pos  = slr:block_where()
                error(string.format([[
                     'Problem SLR->read() failed on symbol id %d at position %d: %s'
                ]],
                    g1_lexeme, l0_pos, l0r:error_description()
                ))
                goto NEXT_EVENT
            end
            do

                if slr.trace_terminals > 0 then
                    local xsy = g1g:_xsy(g1_lexeme)
                    if xsy then
                        local display_form = xsy:display_form()
                        local working_earley_set = slr.g1:latest_earley_set() + 1
                        coroutine.yield('trace', string.format(
                            "Accepted lexeme %s e%d: %s; value=%q",
                            slr:lc_range_brief(block_ix, lexeme_start, block_ix, lexeme_end - 1),
                            working_earley_set,
                            display_form,
                            slr:l0_literal( lexeme_start,  lexeme_end - lexeme_start, block_ix )
                        ))
                    end
                end

                slr.start_of_pause_lexeme = lexeme_start
                slr.end_of_pause_lexeme = lexeme_end
                local pause_after_active = slr.g1_isys[g1_lexeme].pause_after_active
                if pause_after_active then
                    local display_form = g1g:symbol_display_form(g1_lexeme)
                    if slr.trace_terminals > 2 then
                        coroutine.yield('trace', string.format(
                            'Paused after lexeme %s: %s',
                            slr:lc_range_brief(block_ix, lexeme_start, block_ix, lexeme_end - 1),
                            display_form
                        ))
                    end
                    local q = slr.event_queue
                    q[#q+1] = { 'after lexeme', g1_lexeme, block_ix, lexeme_start, lexeme_end - lexeme_start}
                end
            end
            ::NEXT_EVENT::

        end
    end
```

#### External reading

These functions are for "external" reading of tokens --
that is reading tokens by a means other than Marpa's own
lexer.

##### Methods

```
    -- miranda: section+ most Lua function definitions
    function _M.class_slr.ext_lexeme_complete(slr, start_arg, length_arg)
        local block_ix, l0_pos = slr:block_where()
        local longueur = 0
        do
            if length_arg then
                longueur = length_arg
                goto LONGUEUR_IS_SET
            end
            if l0_pos == slr.start_of_pause_lexeme then
                longueur = slr.end_of_pause_lexeme - slr.start_of_pause_lexeme
                goto LONGUEUR_IS_SET
           end
            longueur = 0
        end
        ::LONGUEUR_IS_SET::
        longueur = math.tointeger(longueur)
        if not longueur then
            error(string.format(
                'Bad length in lexeme_complete(): %s',
                    length_arg
            ))
        end

        local input_length = #slr.current_block
        local start_pos = start_arg or l0_pos
        start_pos = math.tointeger(start_pos)
        if not start_pos then
            error(string.format(
                'Bad length in lexeme_complete(): %s',
                    start_pos
            ))
        end
        if start_pos < 0 then
            start_pos = input_length + start_pos
        end
        if start_pos < 0 or start_pos > input_length then
            error(string.format(
                'Bad start position in lexeme_complete(): %s',
                    start_arg
            ))
        end
        slr:block_move(start_pos)
        do
            local end_pos
            if longueur < 0 then
               end_pos = input_length + longueur + 1
            else
               end_pos = start_pos + longueur
            end
            if end_pos < 0 or end_pos > input_length then
                error(string.format(
                   'Bad length in lexeme_complete(): %s', length_arg
               ))
            end
        end
        local g1r = slr.g1
        slr.event_queue = {}
        slr.is_external_scanning = false
        local result = g1r:earleme_complete()
        if result >= 0 then
            slr:g1_convert_events()
            local g1r = slr.g1
            local latest_earley_set = g1r:latest_earley_set()
            slr.per_es[latest_earley_set] =
                { slr.current_block.index, start_pos, longueur }
            local new_l0_pos = start_pos + longueur
            slr:block_move(new_l0_pos)
            return new_l0_pos
        end
        if result == -2 then
            -- Current, we do nothing with an exhausted error code
            -- here

            -- local error_code = slr.slg.g1:error_code()
            -- if error_code == _M.err.PARSE_EXHAUSTED then
                -- local q = slr.event_queue
                -- q[#q+1] = { 'no acceptable input' }
            -- end
            return 0
        end
        error('Problem in slr->g1_lexeme_complete(): '
            ..  slr.slg.g1:error_description())
    end
```

Get the Libmarpa ordering object of `slr`,
creating it if necessary.
Returns the Libmarpa object if it could "get" one,
`nil` otherwise

```
    -- miranda: section+ most Lua function definitions
    function _M.class_slr.ordering_get(slr)
        local slg = slr.slg
        local ranking_method = slg.ranking_method
        if slr.has_parse == false then return slr.has_parse end
        local lmw_o = slr.lmw_o
        if lmw_o then
            slr.has_parse = true
            return lmw_o
        end
        _M.throw = false
        local bocage = _M.bocage_new(slr.g1, slr.end_of_parse)
        _M.throw = true
        slr.lmw_b = bocage
        if not bocage then
            slr.has_parse = false
            return
        end

        lmw_o = _M.order_new(bocage)
        slr.lmw_o = lmw_o

        if ranking_method == 'high_rule_only' then
            slr.lmw_o:high_rank_only_set(1)
            slr.lmw_o:rank()
        end
        if ranking_method == 'rule' then
            slr.lmw_o:high_rank_only_set(0)
            slr.lmw_o:rank()
        end
        slr.has_parse = true
        return lmw_o
    end
```

### Evaluation

```
    -- miranda: section+ class_slr C methods
    static int lca_slr_step_meth (lua_State * L)
    {
        Marpa_Value v;
        lua_Integer step_type;
        const int recce_table = marpa_lua_gettop (L);
        int step_table;

        marpa_luaL_checktype (L, 1, LUA_TTABLE);
        /* Lua stack: [ recce_table ] */
        marpa_lua_getfield(L, recce_table, "lmw_v");
        /* Lua stack: [ recce_table, lmw_v ] */
        marpa_luaL_argcheck (L, (LUA_TUSERDATA == marpa_lua_getfield (L,
                    -1, "_libmarpa")), 1,
            "Internal error: recce._libmarpa userdata not set");
        /* Lua stack: [ recce_table, lmw_v, v_ud ] */
        v = *(Marpa_Value *) marpa_lua_touserdata (L, -1);
        /* Lua stack: [ recce_table, lmw_v, v_ud ] */
        marpa_lua_settop (L, recce_table);
        /* Lua stack: [ recce_table ] */
        marpa_lua_newtable (L);
        /* Lua stack: [ recce_table, step_table ] */
        step_table = marpa_lua_gettop (L);
        marpa_lua_pushvalue (L, -1);
        marpa_lua_setfield (L, recce_table, "this_step");
        /* Lua stack: [ recce_table, step_table ] */

        step_type = (lua_Integer) marpa_v_step (v);
        marpa_lua_pushstring (L, step_name_by_code (step_type));
        marpa_lua_setfield (L, step_table, "type");

        /* Stack indexes adjusted up by 1, because Lua arrays
         * are 1-based.
         */
        switch (step_type) {
        case MARPA_STEP_RULE:
            marpa_lua_pushinteger (L, marpa_v_result (v)+1);
            marpa_lua_setfield (L, step_table, "result");
            marpa_lua_pushinteger (L, marpa_v_arg_n (v)+1);
            marpa_lua_setfield (L, step_table, "arg_n");
            marpa_lua_pushinteger (L, marpa_v_rule (v));
            marpa_lua_setfield (L, step_table, "rule");
            marpa_lua_pushinteger (L, marpa_v_rule_start_es_id (v));
            marpa_lua_setfield (L, step_table, "start_es_id");
            marpa_lua_pushinteger (L, marpa_v_es_id (v));
            marpa_lua_setfield (L, step_table, "es_id");
            break;
        case MARPA_STEP_TOKEN:
            marpa_lua_pushinteger (L, marpa_v_result (v)+1);
            marpa_lua_setfield (L, step_table, "result");
            marpa_lua_pushinteger (L, marpa_v_token (v));
            marpa_lua_setfield (L, step_table, "symbol");
            marpa_lua_pushinteger (L, marpa_v_token_value (v));
            marpa_lua_setfield (L, step_table, "value");
            marpa_lua_pushinteger (L, marpa_v_token_start_es_id (v));
            marpa_lua_setfield (L, step_table, "start_es_id");
            marpa_lua_pushinteger (L, marpa_v_es_id (v));
            marpa_lua_setfield (L, step_table, "es_id");
            break;
        case MARPA_STEP_NULLING_SYMBOL:
            marpa_lua_pushinteger (L, marpa_v_result (v)+1);
            marpa_lua_setfield (L, step_table, "result");
            marpa_lua_pushinteger (L, marpa_v_token (v));
            marpa_lua_setfield (L, step_table, "symbol");
            marpa_lua_pushinteger (L, marpa_v_token_start_es_id (v));
            marpa_lua_setfield (L, step_table, "start_es_id");
            marpa_lua_pushinteger (L, marpa_v_es_id (v));
            marpa_lua_setfield (L, step_table, "es_id");
            break;
        }

        return 0;
    }

```

### Locations

A "sweep" is a set of trios represeenting spans in the input.
Each trio is `[block, start, length]`.
The trios are stored as a sequence in a table, so that,
if `n` is the number of trios,
the table's length is `3*n`.
Each trio represents a consecutive sequence of characters
in `block`.
A sweep can store other data in its non-numeric keys.

Factory to create iterator over the sweeps in a G1 range.
`g1_last` defaults to `g1_first`.

TODO: Allow for leading trailer, final trailer.

```
    -- miranda: section+ forward declarations
    local sweep_range
    -- miranda: section+ most Lua function definitions
    function sweep_range(slr, g1_first, g1_last)
         local function iter()
             if not g1_last then g1_last = g1_first end
             local g1_ix = g1_first+1
             while true do
                 local this_per_es = slr.per_es[g1_ix]
                 if not this_per_es then return end
                 for sweep_ix = 1, #this_per_es, 3 do
                      coroutine.yield(this_per_es[sweep_ix],
                          this_per_es[sweep_ix+1],
                          this_per_es[sweep_ix+2])
                 end
                 if g1_ix > g1_last then return end
                 local this_trailer = slr.trailers[g1_ix]
                 if this_trailer then
                     for sweep_ix = 1, #this_trailer, 3 do
                          coroutine.yield(this_trailer[sweep_ix],
                              this_trailer[sweep_ix+1],
                              this_trailer[sweep_ix+2])
                     end
                 end
                 g1_ix = g1_ix + 1
             end
         end
         return coroutine.wrap(iter)
    end

    -- miranda: section+ forward declarations
    local reverse_sweep_range
    -- miranda: section+ most Lua function definitions
    local function reverse_sweep_range(slr, g1_last, g1_first)
         local function iter()
             if not g1_first then g1_first = g1_last end
             local g1_ix = g1_last+1
             while true do
                 local this_per_es = slr.per_es[g1_ix]
                 if not this_per_es then return end
                 local last_sweep_ix = 3*math.tointeger((#this_per_es-1)/3)+1
                 for sweep_ix = last_sweep_ix, 1, -3 do
                      coroutine.yield(this_per_es[sweep_ix],
                          this_per_es[sweep_ix+1],
                          this_per_es[sweep_ix+2])
                 end
                 if g1_ix <= g1_first then return end
                 local this_trailer = slr.trailers[g1_ix]
                 if this_trailer then
                     for sweep_ix = 1, #this_trailer, 3 do
                          coroutine.yield(this_trailer[sweep_ix],
                              this_trailer[sweep_ix+1],
                              this_trailer[sweep_ix+2])
                     end
                 end
                 g1_ix = g1_ix - 1
             end
         end
         return coroutine.wrap(iter)
    end

    function _M.sweep_add(sweep, block, start, len)
        -- io.stderr:write(string.format("Call: sweep, block,start,len = %s,%s,%s,%s\n",
            -- inspect(sweep), inspect(block), inspect(start), inspect(len)))

        if not sweep then
            return { block, start, len }
        end
        local last_block, last_start, last_len =
            table.unpack(sweep, (#sweep-2))

        -- io.stderr:write(string.format("sweep, last block,start,len = %s,%s,%s,%s\n",
            -- inspect(sweep), inspect(last_block), inspect(last_start), inspect(last_len)))

        -- As a special case, if the new sweep
        -- abuts the last one, we simply extend
        -- the last one
        if (block == last_block)
            and (last_start + last_len ==  start)
        then
            sweep[#sweep] = last_len + len
            -- io.stderr:write('Special case: ', inspect(sweep), "\n")
            return sweep
        end
        sweep[#sweep+1] = block
        sweep[#sweep+1] = start
        sweep[#sweep+1] = len
        -- io.stderr:write('Main case: ', inspect(sweep), "\n")
        return sweep
    end

```

```
    -- miranda: section+ most Lua function definitions
    function _M.class_slr.token_link_data(slr, lmw_r)
        local lmw_g = lmw_r.lmw_g
        local result = {}
        local token_id, value_ix = lmw_r:_source_token()
        local predecessor_ahm = lmw_r:_source_predecessor_state()
        local origin_set_id = lmw_r:_earley_item_origin()
        local origin_earleme = lmw_r:earleme(origin_set_id)
        local middle_earleme = origin_earleme
        local middle_set_id = lmw_r:_source_middle()
        if predecessor_ahm then
            middle_earleme = lmw_r:earleme(middle_set_id)
        end
        local token_name = lmw_g:nsy_name(token_id)
        result.predecessor_ahm = predecessor_ahm
        result.origin_earleme = origin_earleme
        result.middle_set_id = middle_set_id
        result.middle_earleme = middle_earleme
        result.token_name = token_name
        result.token_id = token_id
        result.value_ix = value_ix
        if value_ix ~= 2 then
            result.value = slr.token_values[value_ix]
        end
        return result
    end

```

```
    -- miranda: section+ most Lua function definitions
    function _M.class_slr.l0_literal(slr, l0_start, l0_length, block_ix)
        if not block_ix then block_ix = slr.current_block.index end
        local block = slr.inputs[block_ix]
        local start_byte_p = slr:per_pos(block_ix, l0_start)
        local end_byte_p = slr:per_pos(block_ix, l0_start + l0_length)
        local text = block.text
        return text:sub(start_byte_p, end_byte_p - 1)
    end
```

```
    -- miranda: section+ most Lua function definitions
    function _M.class_slr.g1_literal(slr, g1_start, g1_count)
        -- io.stderr:write(string.format("g1_literal(%d, %d)\n",
            -- g1_start, g1_count
        -- ))

        if g1_count <= 0 then return '' end
        local pieces = {}
        local inputs = slr.inputs
        for block_ix, start, len in
            sweep_range(slr, g1_start, g1_start+g1_count-1)
        do
            local start_byte_p = slr:per_pos(block_ix, start)
            local end_byte_p = slr:per_pos(block_ix, start + len)
            local block = inputs[block_ix]
            local text = block.text
            local piece = text:sub(start_byte_p, end_byte_p - 1)
            pieces[#pieces+1] = piece
        end
        return table.concat(pieces)
    end

    function _M.class_slr.g1_span_l0_length(slr, g1_start, g1_count)
        if g1_count == 0 then return 0 end
        local inputs = slr.inputs
        local length = 0;
        for _, _, sweep_length in
            sweep_range(slr, g1_start, g1_start+g1_count-1)
        do
            length = length + sweep_length
        end
        return length
    end
```

The current position in L0 terms -- a kind of "end of parse" location.

```
    -- miranda: section+ most Lua function definitions
    function _M.class_slr.l0_current_pos(slr)
        local per_es = slr.per_es
        local this_sweep = per_es[#per_es]
        local end_block = this_sweep[#this_sweep-2]
        local end_pos = this_sweep[#this_sweep-1]
        local end_len = this_sweep[#this_sweep]
        return end_block, end_pos + end_len
    end
```

Takes a g1 position,
call it `g1_pos`,
and returns
L0 position where the g1 position starts
as a `block, pos` duple.
As a special case,
when `g1_pos` is one after the last actual
g1 position,
treats it as
an "end of parse" location,
and returns the current L0 position.

```
    -- miranda: section+ most Lua function definitions
    function _M.class_slr.g1_pos_to_l0_first(slr, g1_pos)
        local per_es = slr.per_es
        if g1_pos == #per_es then
            return slr:l0_current_pos()
        end
        local this_sweep = per_es[g1_pos+1]
        if not this_sweep then
            error(string.format(
                "slr:g1_pos_to_l0_range(%d): bad argument\n\z
                \u{20}   Allowed values are %d-%d\n",
                g1_pos, 0, #per_es-1
            ))
        end
        local start_block = this_sweep[1]
        local start_pos = this_sweep[2]
        return start_block, start_pos
    end
```

Takes a g1 position and returns
the last actual L0 position of the g1 position
as a `block, pos` duple.
The position is "actual" in the sense that
there is actually a codepoint at that position.
Allows for the possible future, where the per-es sweep
contains more than one L0 span.

```
    -- miranda: section+ most Lua function definitions
    function _M.class_slr.g1_pos_to_l0_last(slr, g1_pos)
        local per_es = slr.per_es
        local this_sweep = per_es[g1_pos+1]
        if not this_sweep then
            error(string.format(
                "slr:g1_pos_to_l0_range(%d): bad argument\n\z
                \u{20}   Allowed values are %d-%d\n",
                g1_pos, 0, #per_es-1
            ))
        end
        local end_block = this_sweep[#this_sweep-2]
        local end_pos = this_sweep[#this_sweep-1]
        local end_len = this_sweep[#this_sweep]
        return end_block, end_pos + end_len - 1
    end
```

# Brief description of block/line/column for
# an L0 range

```
    -- miranda: section+ most Lua function definitions
    function _M.class_slr.lc_brief(slr, l0_pos, block)
        if not block then block = slr.current_block.index end
        local _, line_no, column_no = slr:per_pos(block, l0_pos)
        return string.format("B%dL%dc%d",
            block, line_no, column_no)
    end
}
```

Brief description of block/line/column for
an L0 range

```
    -- miranda: section+ most Lua function definitions
    function _M.class_slr.lc_range_brief(slr, block1, l0_pos1, block2, l0_pos2)
        local _, line1, column1 = slr:per_pos(block1, l0_pos1)
        local _, line2, column2 = slr:per_pos(block2, l0_pos2)
        if block1 ~= block2 then
           return string.format("B%dL%dc%d-B%dL%dc%d",
             block1, line1, column1, block2, line2, column2)
        end
        if line1 ~= line2 then
           return string.format("B%dL%dc%d-L%dc%d",
             block1, line1, column1, line2, column2)
        end
        if column1 ~= column2 then
           return string.format("B%dL%dc%d-%d",
             block1, line1, column1, column2)
        end
       return string.format("B%dL%dc%d",
             block1, line1, column1)
    end
```

`block_new` must be called in a coroutine which handles
the `codepoint` command.

```
    -- miranda: section+ most Lua function definitions
    local eols = {
        [0x0A] = 0x0A,
        [0x0D] = 0x0D,
        [0x0085] = 0x0085,
        [0x000B] = 0x000B,
        [0x000C] = 0x000C,
        [0x2028] = 0x2028,
        [0x2029] = 0x2029
    }

    function _M.class_slr.block_new(slr, input_string)
        local trace_terminals = slr.trace_terminals
        local inputs = slr.inputs
        local new_block = {}
        local this_index = #inputs + 1
        inputs[this_index] = new_block
        new_block.text = input_string
        new_block.index = #inputs
        local ix = 1

        local eol_seen = false
        local line_no = 1
        local column_no = 0
        local per_codepoint = slr.slg.per_codepoint
        for byte_p, codepoint in utf8.codes(input_string) do

            if not per_codepoint[codepoint] then
               local new_codepoint = {}
               per_codepoint[codepoint] = new_codepoint
               local codepoint_data = coroutine.yield('codepoint', codepoint, trace_terminals)
               -- print('coro_ret: ', inspect(codepoint_data) )
               if codepoint_data.is_graphic == 'true' then
                   new_codepoint.is_graphic = true
               end
               local symbols = codepoint_data.symbols or {}
               for ix = 1, #symbols do
                   new_codepoint[ix] = math.tointeger(symbols[ix])
               end
               -- print('new_codepoint:', inspect(new_codepoint))
            end

            -- line numbering logic
            if eol_seen and
               (eol_seen ~= 0x0D or codepoint ~= 0x0A) then
               eol_seen = false
               line_no = line_no + 1
               column_no = 0
            end
            column_no = column_no + 1
            eol_seen = eols[codepoint]

            local vlq = _M.to_vlq({ byte_p, line_no, column_no })
            new_block[#new_block+1] = vlq
        end
        new_block.l0_pos = 0
        new_block.end_pos = #new_block
        return this_index
    end
```

```
    -- miranda: section+ most Lua function definitions
    function _M.class_slr.block_where(slr, block_ix)
        local block
        if block_ix then
            block = slr.inputs[block_ix]
            if not block then return end
        else
            block = slr.current_block
        end
        if not block then return 0, 0, 0 end
        return block.index, block.l0_pos,
            block.end_pos
    end
    function _M.class_slr.block_set(slr, block_ix)
        local block = slr.inputs[block_ix]
        slr.current_block = block
    end
    function _M.class_slr.block_move(slr, l0_pos, end_pos, block_ix)
        local block =
            block_ix and slr.inputs[block_ix] or slr.current_block
        if l0_pos then
            block.l0_pos = l0_pos
        end
        if end_pos then
            block.end_pos = end_pos
        end
    end
```

```
    -- miranda: section+ most Lua function definitions
    function _M.class_slr.block_read(slr)
        local events = {}
        local event_status
        while true do
            local alive = slr:read()
            event_status, events = glue.convert_libmarpa_events(slr)
            if not alive or #events > 0 or event_status == 'pause' then
                break
            end
        end
        return 'ok', events
    end
```

Returns byte position, line and column of `pos`
in block with index `block_ix`.
Caller must ensure `block` and `pos` are valid.

```
    -- miranda: section+ most Lua function definitions
    function _M.class_slr.per_pos(slr, block_ix, pos)
        local block = slr.inputs[block_ix]
        -- codepoints array is 1-based
        local codepoint_ix = pos+1
        local text = block.text
        if codepoint_ix > #block then
            -- It is useful to have an "end of block"
            -- position.  No codepoint, but line is
            -- last line and byte_p and column are one
            -- after the end
            if codepoint_ix == #block + 1 then
                local vlq = block[#block]
                local last_byte_p, last_line_no, last_column_no
                    = table.unpack(_M.from_vlq(vlq))
                return #text+1, last_line_no, last_column_no+1
            end
            error(string.format(
                "Internal error: invalid block,pos: %d, %d\n\z
                \u{20}   pos must be from 0-%d\n",
                block_ix, pos, #block))
        end
        local vlq = block[codepoint_ix]
        -- print(inspect(_M.from_vlq(vlq)))
        return table.unpack(_M.from_vlq(vlq))
    end
```

```
    -- miranda: section+ most Lua function definitions
    function _M.class_slr.codepoint_from_pos(slr, block, pos)
        local byte_p = slr:per_pos(block, pos)
        local input = slr.inputs[block]
        local text = input.text
        if byte_p > #text then return end
        return utf8.codepoint(text, byte_p)
    end

```

### Events

```
    -- miranda: section+ most Lua function definitions

    function _M.class_slr.g1_convert_events(slr)
        local _, l0_pos = slr:block_where()
        local g1g = slr.slg.g1
        local q = slr.event_queue
        local events = g1g:events()
        for i = 1, #events, 2 do
            local event_type = events[i]
            local event_value = events[i+1]
            if event_type == _M.event["EXHAUSTED"] then
                goto NEXT_EVENT
            end
            if event_type == _M.event["SYMBOL_COMPLETED"] then
                q[#q+1] = { 'symbol completed', event_value}
                goto NEXT_EVENT
            end
            if event_type == _M.event["SYMBOL_NULLED"] then
                q[#q+1] = { 'symbol nulled', event_value}
                goto NEXT_EVENT
            end
            if event_type == _M.event["SYMBOL_PREDICTED"] then
                q[#q+1] = { 'symbol predicted', event_value}
                goto NEXT_EVENT
            end
            if event_type == _M.event["EARLEY_ITEM_THRESHOLD"] then
                coroutine.yield('trace', string.format(
                    'G1 exceeded earley item threshold at pos %d: %d Earley items',
                    l0_pos, event_value))
                goto NEXT_EVENT
            end
            local event_data = _M.event[event_type]
            if not event_data then
                result_string = string.format(
                    'unknown event code, %d', event_type
                )
            else
                result_string = event_data.name
            end
            q[#q+1] = { 'unknown_event', result_string}
            ::NEXT_EVENT::
        end
    end

    function _M.class_slr.l0_convert_events(slr)
        local l0g = slr.slg.l0
        local _, l0_pos = slr:block_where()
        local q = slr.event_queue
        local events = l0g:events()
        for i = 1, #events, 2 do
            local event_type = events[i]
            local event_value = events[i+1]
            if event_type == _M.event["EXHAUSTED"] then
                goto NEXT_EVENT
            end
            if event_type == _M.event["EARLEY_ITEM_THRESHOLD"] then
                coroutine.yield('trace', string.format(
                    'L0 exceeded earley item threshold at pos %d: %d Earley items',
                    l0_pos, event_value))
                goto NEXT_EVENT
            end
            local event_data = _M.event[event_type]
            if not event_data then
                result_string = string.format(
                    'unknown event code, %d', event_type
                )
            else
                result_string = event_data.name
            end
            q[#q+1] = { 'unknown_event', result_string}
            ::NEXT_EVENT::
        end
    end

```

```
    -- miranda: section+ most Lua function definitions
    function _M.class_slr.activate_by_event_name(slr, event_name, activate)
        local slg = slr.slg
        local events
        local active_flag = activate and 1 or 0

        events = slg.completion_event_by_name[event_name]
        if events then
            for ix = 1, #events do
                local event_data = events[ix]
                local isyid = event_data.isyid
                slr.g1:completion_symbol_activate(isyid, active_flag)
            end
        end

        events = slg.nulled_event_by_name[event_name]
        if events then
            for ix = 1, #events do
                local event_data = events[ix]
                local isyid = event_data.isyid
                slr.g1:nulled_symbol_activate(isyid, active_flag)
            end
        end

        events = slg.prediction_event_by_name[event_name]
        if events then
            for ix = 1, #events do
                local event_data = events[ix]
                local isyid = event_data.isyid
                slr.g1:prediction_symbol_activate(isyid, active_flag)
            end
        end

        events = slg.discard_event_by_name[event_name]
        if events then
            local g_l0_rules = slg.l0.irls
            local r_l0_rules = slr.l0_irls
            for ix = 1, #events do
                local event_data = events[ix]
                local irlid = event_data.irlid
                if activate
                    and not g_l0_rules[irlid].event_on_discard
                then
                    -- TODO: Can this be a user error?
                    error("Attempt to activate non-existent discard event")
                end
                r_l0_rules[irlid].event_on_discard_active = activate
            end
        end

        events = slg.lexeme_event_by_name[event_name]
        if events then
            local g_g1_symbols = slg.g1.isys
            local r_g1_symbols = slr.g1_isys
            for ix = 1, #events do
                    local event_data = events[ix]
                    local isyid = event_data.isyid
                    -- print(event_name, activate)
                    if activate then
                        r_g1_symbols[isyid].pause_after_active
                            = g_g1_symbols[isyid].pause_after
                        r_g1_symbols[isyid].pause_before_active
                            = g_g1_symbols[isyid].pause_before
                    else
                        r_g1_symbols[isyid].pause_after_active = nil
                        r_g1_symbols[isyid].pause_before_active = nil
                    end
            end
        end
    end
```

```
    -- miranda: section+ most Lua function definitions
    function _M.class_slr.convert_libmarpa_events(slr)
        local in_q = slr.event_queue
        local pause = false
        for event_ix = 1, #in_q do
            local event = in_q[event_ix]
            -- print(inspect(event))
            local event_type = event[1]

            if event_type == "'exhausted" then
                local yield_result = coroutine.yield ( 'event', event_type )
                pause = pause or yield_result == 'pause'
            end

            if event_type == "'rejected" then
                local yield_result = coroutine.yield ( 'event', event_type )
                pause = pause or yield_result == 'pause'
            end

            -- The code next set of events is highly similar -- an isyid at
            -- event[2] is looked up in a table of event names.  Does it
            -- make sense to share code, perhaps using closures?
            if event_type == 'symbol completed' then
                local completed_isyid = event[2]
                local slg = slr.slg
                local event_name = slg.completion_event_by_isy[completed_isyid].name
                local yield_result = coroutine.yield ( 'event', event_name )
                pause = pause or yield_result == 'pause'
            end

            if event_type == 'symbol nulled' then
                local nulled_isyid = event[2]
                local slg = slr.slg
                local event_name = slg.nulled_event_by_isy[nulled_isyid].name
                local yield_result = coroutine.yield ( 'event', event_name )
                pause = pause or yield_result == 'pause'
            end

            if event_type == 'symbol predicted' then
                local predicted_isyid = event[2]
                local slg = slr.slg
                local event_name = slg.prediction_event_by_isy[predicted_isyid].name
                local yield_result = coroutine.yield ( 'event', event_name )
                pause = pause or yield_result == 'pause'
            end

            if event_type == 'after lexeme'
                or event_type == 'before lexeme'
            then
                local lexeme_isyid = event[2]
                local slg = slr.slg
                local g1g = slg.g1
                local event_name = slg.lexeme_event_by_isy[lexeme_isyid].name
                -- there must be an XSY
                local lexeme_xsy = g1g:_xsy(lexeme_isyid)
                local lexeme_xsyid = lexeme_xsy.id
                local yield_result = coroutine.yield ( 'event', event_name,
                    lexeme_xsyid,
                    table.unpack(event, 3) )
                pause = pause or yield_result == 'pause'
            end

            -- end of run of highly similar events

            if event_type == 'discarded lexeme' then
                local lexeme_irlid = event[2]
                local slg = slr.slg
                local event_name = slg.discard_event_by_irl[lexeme_irlid].name
                local new_event = { 'event', event_name }
                for ix = 4, #event do
                    new_event[#new_event+1] = event[ix]
                end
                local yield_result = coroutine.yield( 'event', event_name, table.unpack(event, 3) )
                pause = pause or yield_result == 'pause'
            end
        end

        -- TODO -- after development, change to just return status?
        local event_status = pause and 'pause' or 'ok'
        -- print('event_status:', event_status)
        return event_status, {}
    end

```

### Progress reporting

Given a scanless
recognizer and a symbol,
`last_completed()`
returns the start earley set
and length
of the last such symbol completed,
or nil if there was none.

```
    -- miranda: section+ most Lua function definitions
    function _M.class_slr.last_completed(slr, xsyid)
         local g1r = slr.g1
         local g1g = slr.slg.g1
         local latest_earley_set = g1r:latest_earley_set()
         local first_origin = latest_earley_set + 1
         local earley_set = latest_earley_set
         while earley_set >= 0 do
             g1r:progress_report_start(earley_set)
             while true do
                 local rule_id, dot_position, origin = g1r:progress_item()
                 if not rule_id then goto LAST_ITEM end
                 if dot_position ~= -1 then goto NEXT_ITEM end
                 local lhs_id = g1g:rule_lhs(rule_id)
                 local lhs_xsy = g1g:_xsy(lhs_id)
                 if not lhs_xsy then goto NEXT_ITEM end
                 local lhs_xsyid = lhs_xsy.id
                 if xsyid ~= lhs_xsyid then goto NEXT_ITEM end
                 if origin < first_origin then
                     first_origin = origin
                 end
                 ::NEXT_ITEM::
             end
             ::LAST_ITEM::
             g1r:progress_report_finish()
             if first_origin <= latest_earley_set then
                 goto LAST_EARLEY_SET
             end
             earley_set = earley_set - 1
         end
         ::LAST_EARLEY_SET::
         if earley_set < 0 then return end
         return first_origin, earley_set - first_origin
    end

```

```
    -- miranda: section+ most Lua function definitions
    function _M.class_slr.g1_progress(slr, ordinal_arg)
        local g1r = slr.g1
        local ordinal = ordinal_arg
        local latest_earley_set = g1r:latest_earley_set()
        if ordinal > latest_earley_set then
            error(string.format(
                "Argument out of bounds in slr->progress(%d)\n"
                .. "   Argument specifies Earley set after the latest Earley set 0\n"
                .. "   The latest Earley set is Earley set $latest_earley_set\n",
                ordinal_arg
                ))
        elseif ordinal < 0 then
            ordinal = latest_earley_set + 1 + ordinal
            if ordinal < 0 then
                error(string.format(
                    "Argument out of bounds in slr->progress(%d)\n"
                    .. "   Argument specifies Earley set before Earley set 0\n",
                    ordinal_arg
                ))
            end
            end
        local result = {}
        g1r:progress_report_start(ordinal)
        while true do
            local rule_id, dot_position, origin = g1r:progress_item()
            if not rule_id then goto LAST_ITEM end
            result[#result+1] = { rule_id, dot_position, origin }
        end
        ::LAST_ITEM::
        g1r:progress_report_finish()
        return result
    end

```

### Diagnostics

TODO -- after development, this should be a local function.

`throw_at_pos` appends a location description to `desc`
and throws the error.
It is designed to be convenient for use as a tail call.

```
    -- miranda: section+ most Lua function definitions
    function _M.class_slr.throw_at_pos(slr, desc, block_ix, pos)
      desc = desc or ''
      local current_block_ix, l0_pos = slr:block_where()
      block_ix = block_ix or current_block_ix
      pos = pos or l0_pos
      local codepoint = slr:codepoint_from_pos(block_ix, pos)
      return _M.userX(string.format(
             "Error in SLIF parse: %s\n\z
              * String before error: %s\n\z
              * The error was at %s, and at character %s, ...\n\z
              * here: %s\n",
              desc,
              slr:reversed_input_escape(block_ix, pos, 50),
              slr:lc_brief(pos, block_ix),
              slr:character_describe(codepoint),
              slr:input_escape(block_ix, pos, 50)
          ))
    end
```

This is not currently used.
It was created for development,
and is being kept for use as
part of a "Pure Lua" implementation.

```
    -- miranda: section+ most Lua function definitions
    function _M.class_slr.show_leo_item(slr)
        local g1r = slr.g1
        local g1g = slr.slg.g1
        local leo_base_state = g1r:_leo_base_state()
        if not leo_base_state then return '' end
        local trace_earley_set = g1r:_trace_earley_set()
        local trace_earleme = g1r:earleme(trace_earley_set)
        local postdot_symbol_id = g1r:_postdot_item_symbol()
        local postdot_symbol_name = g1g:nsy_name(postdot_symbol_id)
        local predecessor_symbol_id = g1r:_leo_predecessor_symbol()
        local base_origin_set_id = g1r:_leo_base_origin()
        local base_origin_earleme = g1r:earleme(base_origin_set_id)
        local link_texts = {
            string.format("%q", postdot_symbol_name)
        }
        if predecessor_symbol_id then
            link_texts[#link_texts+1] = string.format(
                'L%d@%d', predecessor_symbol_id, base_origin_earleme
            );
        end
        link_texts[#link_texts+1] = string.format(
            'S%d@%d-%d',
            leo_base_state,
            base_origin_earleme,
            trace_earleme
        );
        return string.format('L%d@%d [%s]',
             postdot_symbol_id, trace_earleme,
             table.concat(link_texts, '; '));
    end

```

```
    -- miranda: section+ most Lua function definitions
    function _M.class_slr._progress_line_do(
        slr, current_ordinal, origins, rule_id, position
    )

        -- For origins[0], we apply
        --     -1 to convert earley set to G1, then
        --     +1 because it is an origin and the character
        --        doesn't begin until the next Earley set
        -- In other words, they balance and we do nothing
        local g1_first = origins[1]

        local slg = slr.slg
        local g1g = slg.g1
        local pcs = {}

        local origins_desc = #origins <= 3
             and table.concat(origins, ',')
             or origins[1] .. '...' .. origins[#origins]

        local dotted_type
        if position >= g1g:rule_length(rule_id) then
            dotted_type = 'F'
            pcs[#pcs+1] = 'F' .. rule_id
            goto TAG_FOUND
        end
        if position > 0 then
            dotted_type = 'R'
            pcs[#pcs+1] = 'R' .. rule_id .. ':' .. position
            goto TAG_FOUND
        end
        dotted_type = 'P'
        pcs[#pcs+1] = 'P' .. rule_id
        ::TAG_FOUND::

        if #origins > 1 then
            pcs[#pcs+1] = 'x' .. #origins
        end

        local current_earleme = slr.g1:earleme(current_ordinal)
        pcs[#pcs+1] = '@' .. origins_desc .. '-' .. current_earleme

        -- find the range
        if current_ordinal <= 0 then
            pcs[#pcs+1] = 'B0L0c0'
            goto HAVE_RANGE
        end
        if dotted_type == 'P' then
            local block, pos = slr:g1_pos_to_l0_first(current_ordinal)
            pcs[#pcs+1] = slr:lc_brief(pos, block)
            goto HAVE_RANGE
        end
        do
            if g1_first < 0 then g1_first = 0 end
            local g1_last = current_ordinal - 1
            local l0_first_b, l0_first_p = slr:g1_pos_to_l0_first(g1_first)
            local l0_last_b, l0_last_p = slr:g1_pos_to_l0_last(g1_last)
            pcs[#pcs+1] = slr:lc_range_brief(l0_first_b, l0_first_p, l0_last_b, l0_last_p)
            goto HAVE_RANGE
        end
        ::HAVE_RANGE::
        pcs[#pcs+1] = slg:g1_dotted_rule_show(rule_id, position)
        return table.concat(pcs, ' '), { current_ordinal, rule_id, position } ;
    end
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
Maintainers should be aware that these are finicky.
In particular, while `return f(x)` is turned into a tail call,
`return (f(x))` is not.

The next function is a utility to set
up the VM table.

#### VM debug operation

```
    -- miranda: section VM utilities

        _M.vm_ops = {}
        _M.vm_op_names = {}
        _M.vm_op_keys = {}
        local function op_fn_add(name, fn)
            local ops = _M.vm_ops
            local new_ix = #ops + 1
            ops[new_ix] = fn
            ops[name] = fn
            _M.vm_op_names[new_ix] = name
            _M.vm_op_keys[name] = new_ix
            return new_ix
        end

```


#### VM debug operation

Was used for development.
Perhaps I should delete this.

```
    -- miranda: section VM operations

    local function op_fn_debug (slr)
        for k,v in pairs(slr) do
            print(k, v)
        end
        mt = debug.getmetatable(slr)
        print([[=== metatable ===]])
        for k,v in pairs(mt) do
            print(k, v)
        end
        return -2
    end
    op_fn_add("debug", op_fn_debug)

```

#### VM no-op operation

This is to be kept after development,
even if not used.
It may be useful in debugging.

```
    -- miranda: section+ VM operations

    local function op_fn_noop (slr)
        return -2
    end
    op_fn_add("noop", op_fn_noop)

```

#### VM bail operation

This is to used for development.
Its intended use is as a dummy argument,
which, if it is used by accident
as a VM operation,
fast fails with a clear message.

```
    -- miranda: section+ VM operations

    local function op_fn_bail (slr)
        error('executing VM op "bail"')
    end
    op_fn_add("bail", op_fn_bail)

```

#### VM result operations

If an operation in the VM returns -1, it is a
"result operation".
The actual result is expected to be in the stack
at index `slr.this_step.result`.

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
at index `slr.this_step.result`.

#### VM "result is undef" operation

Perhaps the simplest operation.
The result of the semantics is a Perl undef.

```
    -- miranda: section+ VM operations

    local function op_fn_result_is_undef(slr)
        local stack = slr.lmw_v.stack
        local undef_tree_op = { 'perl', 'undef' }
        setmetatable(undef_tree_op, _M.mt_tree_op)
        stack[slr.this_step.result] = undef_tree_op
        return -1
    end
    op_fn_add("result_is_undef", op_fn_result_is_undef)

```

#### VM "result is token value" operation

The result of the semantics is the value of the
token at the current location.
It's assumed to be a MARPA_STEP_TOKEN step --
if not the value is an undef.

```
    -- miranda: section+ VM operations

    local function op_fn_result_is_token_value(slr)
        if slr.this_step.type ~= 'MARPA_STEP_TOKEN' then
          return op_fn_result_is_undef(slr)
        end
        local stack = slr.lmw_v.stack
        local result_ix = slr.this_step.result
        stack[result_ix] = slr:current_token_literal()
        if slr.trace_values > 0 then
          local top_of_queue = #slr.trace_values_queue;
          local tag, token_sv
          slr.trace_values_queue[top_of_queue+1] =
             {tag, slr.this_step.type, slr.this_step.symbol, slr.this_step.value, token_sv};
             -- io.stderr:write('[step_type]: ', inspect(slr))
        end
        return -1
    end
    op_fn_add("result_is_token_value", op_fn_result_is_token_value)

```

#### VM "result is N of RHS" operation

```
    -- miranda: section+ VM operations
    local function op_fn_result_is_n_of_rhs(slr, rhs_ix)
        if slr.this_step.type ~= 'MARPA_STEP_RULE' then
          return op_fn_result_is_undef(slr)
        end
        local stack = slr.lmw_v.stack
        local result_ix = slr.this_step.result
        repeat
            if rhs_ix == 0 then break end
            local fetch_ix = result_ix + rhs_ix
            if fetch_ix > slr.this_step.arg_n then
                local undef_tree_op = { 'perl', 'undef' }
                setmetatable(undef_tree_op, _M.mt_tree_op)
                stack[result_ix] = undef_tree_op
                break
            end
            stack[result_ix] = stack[fetch_ix]
        until 1
        return -1
    end
    op_fn_add("result_is_n_of_rhs", op_fn_result_is_n_of_rhs)

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
    local function op_fn_result_is_n_of_sequence(slr, item_ix)
        if slr.this_step.type ~= 'MARPA_STEP_RULE' then
          return op_fn_result_is_undef(slr)
        end
        local result_ix = slr.this_step.result
        local fetch_ix = result_ix + item_ix * 2
        if fetch_ix > slr.this_step.arg_n then
          return op_fn_result_is_undef(slr)
        end
        local stack = slr.lmw_v.stack
        if item_ix > 0 then
            stack[result_ix] = stack[fetch_ix]
        end
        return -1
    end
    op_fn_add("result_is_n_of_sequence", op_fn_result_is_n_of_sequence)

```

#### VM operation: result is constant

Returns a constant result.

```
    -- miranda: section+ VM operations
    local function op_fn_result_is_constant(slr, constant_ix)
        local constant_tree_op = { 'perl', 'constant', constant_ix }
        setmetatable(constant_tree_op, _M.mt_tree_op)
        local stack = slr.lmw_v.stack
        local result_ix = slr.this_step.result
        stack[result_ix] = constant_tree_op
        if slr.trace_values > 0 and slr.this_step.type == 'MARPA_STEP_TOKEN' then
            local top_of_queue = #slr.trace_values_queue
            slr.trace_values_queue[top_of_queue+1] =
                { "valuator unknown step", slr.this_step.type, slr.token, constant}
                      -- io.stderr:write('valuator unknown step: ', inspect(slr))
        end
        return -1
    end
    op_fn_add("result_is_constant", op_fn_result_is_constant)

```

#### Operation of the values array

The following operations add elements to the `values` array.
This is a special array which may eventually be the result of the
sequence of operations.

#### VM "push undef" operation

Push an undef on the values array.

```
    -- miranda: section+ VM operations

    local function op_fn_push_undef(slr, dummy, new_values)
        local next_ix = #new_values + 1;
        local undef_tree_op = { 'perl', 'undef' }
        setmetatable(undef_tree_op, _M.mt_tree_op)
        new_values[next_ix] = undef_tree_op
        return -2
    end
    op_fn_add("push_undef", op_fn_push_undef)

```

#### VM "push one" operation

Push one of the RHS child values onto the values array.

```
    -- miranda: section+ VM operations

    local function op_fn_push_one(slr, rhs_ix, new_values)
        if slr.this_step.type ~= 'MARPA_STEP_RULE' then
          return op_fn_push_undef(slr, nil, new_values)
        end
        local stack = slr.lmw_v.stack
        local result_ix = slr.this_step.result
        local next_ix = #new_values + 1;
        new_values[next_ix] = stack[result_ix + rhs_ix]
        return -2
    end
    op_fn_add("push_one", op_fn_push_one)

```

#### Find current token literal

`current_token_literal` return the literal
equivalent of the current token.
It assumes that there *is* a current token,
that is,
it assumes that the caller has ensured that
`slr.this_step.type ~= 'MARPA_STEP_TOKEN'`.

```
    -- miranda: section+ VM operations
    function _M.class_slr.current_token_literal(slr)
      if slr.token_is_literal == slr.this_step.value then
          local start_es = slr.this_step.start_es_id
          local end_es = slr.this_step.es_id
          local g1_count = end_es - start_es
          local literal = slr:g1_literal(start_es, g1_count)
          return literal
      end
      return slr.token_values[slr.this_step.value]
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

    local function op_fn_push_values(slr, increment, new_values)
        if slr.this_step.type == 'MARPA_STEP_TOKEN' then
            local next_ix = #new_values + 1;
            new_values[next_ix] = slr:current_token_literal()
            return -2
        end
        if slr.this_step.type == 'MARPA_STEP_RULE' then
            local stack = slr.lmw_v.stack
            local arg_n = slr.this_step.arg_n
            local result_ix = slr.this_step.result
            local to_ix = #new_values + 1;
            for from_ix = result_ix,arg_n,increment do
                new_values[to_ix] = stack[from_ix]
                to_ix = to_ix + 1
            end
            return -2
        end
        -- if 'MARPA_STEP_NULLING_SYMBOL', or unrecogized type
        return -2
    end
    op_fn_add("push_values", op_fn_push_values)

```

#### VM operation: push start location

The current start location in input location terms -- that is,
in terms of the input string.

```
    -- miranda: section+ VM operations
    local function op_fn_push_start(slr, dummy, new_values)
        local start_es = slr.this_step.start_es_id
        local per_es = slr.per_es
        local l0_start
        start_es = start_es + 1
        if start_es > #per_es then
             local es_entry = per_es[#per_es]
             l0_start = es_entry[2] + es_entry[3]
        elseif start_es < 1 then
             l0_start = 0
        else
             local es_entry = per_es[start_es]
             l0_start = es_entry[2]
        end
        local next_ix = #new_values + 1;
        new_values[next_ix] = l0_start
        return -2
    end
    op_fn_add("push_start", op_fn_push_start)


```

#### VM operation: push length

The length of the current step in input location terms --
that is, in terms of the input string

```
    -- miranda: section+ VM operations
    local function op_fn_push_length(slr, dummy, new_values)
        local start_es = slr.this_step.start_es_id
        local end_es = slr.this_step.es_id
        local per_es = slr.per_es
        local l0_length = 0
        start_es = start_es + 1
        local start_es_entry = per_es[start_es]
        if start_es_entry then
            local l0_start = start_es_entry[2]
            local end_es_entry = per_es[end_es]
            l0_length =
                end_es_entry[2] + end_es_entry[3] - l0_start
        end
        local next_ix = #new_values + 1;
        new_values[next_ix] = l0_length
        return -2
    end
    op_fn_add("push_length", op_fn_push_length)

```

#### VM operation: push G1 start location

The current start location in G1 location terms -- that is,
in terms of G1 Earley sets.

```
    -- miranda: section+ VM operations
    local function op_fn_push_g1_start(slr, dummy, new_values)
        local next_ix = #new_values + 1;
        new_values[next_ix] = slr.this_step.start_es_id
        return -2
    end
    op_fn_add("push_g1_start", op_fn_push_g1_start)

```

#### VM operation: push G1 length

The length of the current step in G1 terms --
that is, in terms of G1 Earley sets.

```
    -- miranda: section+ VM operations
    local function op_fn_push_g1_length(slr, dummy, new_values)
        local next_ix = #new_values + 1;
        new_values[next_ix] = (slr.this_step.es_id
            - slr.this_step.start_es_id) + 1
        return -2
    end
    op_fn_add("push_g1_length", op_fn_push_g1_length)

```

#### VM operation: push constant onto values array

```
    -- miranda: section+ VM operations
    local function op_fn_push_constant(slr, constant_ix, new_values)
        local constant_tree_op = { 'perl', 'constant', constant_ix }
        setmetatable(constant_tree_op, _M.mt_tree_op)
        -- io.stderr:write('constant_ix: ', constant_ix, "\n")
        local next_ix = #new_values + 1;
        new_values[next_ix] = constant_tree_op
        return -2
    end
    op_fn_add("push_constant", op_fn_push_constant)

```

#### VM operation: set the array blessing

The blessing is registered in a constant, and this operation
lets the VM know its index.  The index is cleared at the beginning
of every sequence of operations

```
    -- miranda: section+ VM operations
    local function op_fn_bless(slr, blessing_ix)
        slr.this_step.blessing_ix = blessing_ix
        return -2
    end
    op_fn_add("bless", op_fn_bless)

```

#### VM operation: result is array

This operation tells the VM that the current `values` array
is the result of this sequence of operations.

```
    -- miranda: section+ VM operations
    local function op_fn_result_is_array(slr, dummy, new_values)
        local blessing_ix = slr.this_step.blessing_ix
        if blessing_ix then
          new_values = { 'perl', 'bless', new_values, blessing_ix }
          setmetatable(new_values, _M.mt_tree_op)
        end
        local stack = slr.lmw_v.stack
        local result_ix = slr.this_step.result
        stack[result_ix] = new_values
        return -1
    end
    op_fn_add("result_is_array", op_fn_result_is_array)

```

#### VM operation: callback

Tells the VM to create a callback to Perl, with
the `values` array as an argument.
The return value of 3 is a vestige of an earlier
implementation, which returned the size of the
`values` array.

```
    -- miranda: section+ VM operations
    local function op_fn_callback(slr, dummy, new_values)
        local blessing_ix = slr.this_step.blessing_ix
        local step_type = slr.this_step.type
        if step_type ~= 'MARPA_STEP_RULE'
            and step_type ~= 'MARPA_STEP_NULLING_SYMBOL'
        then
            io.stderr:write(
                'Internal error: callback for wrong step type ',
                step_type
            )
            os.exit(false)
        end
        local blessing_ix = slr.this_step.blessing_ix
        if blessing_ix then
          new_values = { 'perl', 'bless', new_values, blessing_ix }
          setmetatable(new_values, _M.mt_tree_op)
        end
        return 3
    end
    op_fn_add("callback", op_fn_callback)

```

### Run the virtual machine

```
    -- miranda: section+ VM operations
    function _M.class_slr.do_ops(slr, ops, new_values)
        local op_ix = 1
        while op_ix <= #ops do
            local op_code = ops[op_ix]
            if op_code == 0 then return -1 end
            if op_code ~= _M.defines.op_lua then
            end
            local fn_key = ops[op_ix+1]
            local arg = ops[op_ix+2]
            if slr.trace_values >= 3 then
              local queue = slr.trace_values_queue
              local tag = 'starting lua op'
              queue[#queue+1] = {'starting op', slr.this_step.type, 'lua'}
              queue[#queue+1] = {tag, slr.this_step.type, _M.vm_op_names[fn_key]}
              -- io.stderr:write('starting op: ', inspect(slr))
            end
            -- io.stderr:write('ops: ', inspect(_M.vm_ops), '\n')
            -- io.stderr:write('fn_key: ', inspect(fn_key), '\n')
            local op_fn = _M.vm_ops[fn_key]
            local result = op_fn(slr, arg, new_values)
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
    function _M.class_slr.find_and_do_ops(slr)
        slr.trace_values_queue = {}
        local grammar = slr.slg
        while true do
            local new_values = {}
            local ops = {}
            slr:step()
            if slr.this_step.type == 'MARPA_STEP_INACTIVE' then
                return 0, new_values
            end
            if slr.this_step.type == 'MARPA_STEP_RULE' then
                ops = grammar.rule_semantics[slr.this_step.rule]
                if not ops then
                    ops = _M.rule_semantics_default
                end
                goto DO_OPS
            end
            if slr.this_step.type == 'MARPA_STEP_TOKEN' then
                ops = grammar.token_semantics[slr.this_step.symbol]
                if not ops then
                    ops = _M.token_semantics_default
                end
                goto DO_OPS
            end
            if slr.this_step.type == 'MARPA_STEP_NULLING_SYMBOL' then
                ops = grammar.nulling_semantics[slr.this_step.symbol]
                if not ops then
                    ops = _M.nulling_semantics_default
                end
                goto DO_OPS
            end
            if true then return 1, new_values end
            ::DO_OPS::
            if not ops then
                error(string.format('No semantics defined for %s', slr.this_step.type))
            end
            local do_ops_result = slr:do_ops(ops, new_values)
            local stack = slr.lmw_v.stack
            -- truncate stack
            local above_top = slr.this_step.result + 1
            for i = above_top,#stack do stack[i] = nil end
            if do_ops_result > 0 then
                return 3, new_values
            end
            if #slr.trace_values_queue > 0 then return -1, new_values end
        end
    end

```

Set up the default VM operations

```
    -- miranda: section+ VM default operations
    do
        -- we record these values to set the defaults, below
        local op_lua =  _M.defines.MARPA_OP_LUA
        local op_bail_key = _M.vm_op_keys["bail"]
        local result_is_constant_key = _M.vm_op_keys["result_is_constant"]
        local result_is_undef_key = _M.vm_op_keys["result_is_undef"]
        local result_is_token_value_key = _M.vm_op_keys["result_is_token_value"]

        _M.nulling_semantics_default = { op_lua, result_is_undef_key, op_bail_key, 0 }
        _M.token_semantics_default = { op_lua, result_is_token_value_key, op_bail_key, 0 }
        _M.rule_semantics_default = { op_lua, result_is_undef_key, op_bail_key, 0 }

    end


```

### Tree export operations

The "tree export operations" are performed when a tree is transformed
from Kollos form to a form
suitable for its parent layer.
Currently the only parent layer is Marpa::R3.

The tree export operations
are defined as light userdata referring to a dedicated global
constant, which guarantees they will never collide with user data.
The global constants are defined only for the purpose of creating
a unique address --
their contents are never used.

These operations are always the first element of a sequence.
They tell
Kollos how to transform the rest of the sequence.

The "asis" operation simply passes on the 2nd element of the sequence
as an SV.
It probably will not be needed much

```
    -- miranda: section+ C global constant variables
    static int tree_op_asis;
    -- miranda: section+ create tree export operations
    marpa_lua_pushlightuserdata(L, (void *)&tree_op_asis);
    marpa_lua_setfield(L, kollos_table_stack_ix, "tree_op_asis");

```

The "bless" operation passes on the 2nd element of the sequence,
blessed using the 3rd element.
The 3rd element must be a string.

```
    -- miranda: section+ C global constant variables
    static int tree_op_bless;
    -- miranda: section+ create tree export operations
    marpa_lua_pushlightuserdata(L, (void *)&tree_op_bless);
    marpa_lua_setfield(L, kollos_table_stack_ix, "tree_op_bless");

```

### VM-related utilities for use in the Perl code

The following operations are used by the higher-level Perl code
to set and discover various Lua values.

#### Return operation key given its name

```
    -- miranda: section Utilities for semantics
    function _M.get_op_fn_key_by_name(op_name)
        return _M.vm_op_keys[op_name]
    end

```

#### Return operation name given its key

```
    -- miranda: section+ Utilities for semantics
    function _M.get_op_fn_name_by_key(op_key)
        return _M.vm_op_names[op_key]
    end

```

#### Return the top index of the stack

```
    -- miranda: section+ Utilities for semantics
    function _M.class_slr.stack_top_index(slr)
        return slr.this_step.result
    end

```

#### Return the value of a stack entry

```
    -- miranda: section+ Utilities for semantics
    function _M.class_slr.stack_get(slr, ix)
        local stack = slr.lmw_v.stack
        return stack[ix+0]
    end

```

#### Set the value of a stack entry

```
    -- miranda: section+ Utilities for semantics
    function _M.class_slr.stack_set(slr, ix, v)
        local stack = slr.lmw_v.stack
        stack[ix+0] = v
    end

```

#### Convert current, origin Earley set to L0 span

Given a current Earley set and an origin Earley set,
return a span in L0 terms.
The purpose is assumed to be a find a literal
equivalent.
All zero length literals are alike,
so the logic is careless about the l0_start when l0_length
is zero.

```
    -- miranda: section+ Utilities for semantics
    function _M.class_slr.earley_sets_to_L0_span(slr, start_earley_set, end_earley_set)
      start_earley_set = start_earley_set + 1
      -- normalize start_earley_set
      if start_earley_set < 1 then start_earley_set = 1 end
      if end_earley_set < start_earley_set then
          return 0, 0
      end
      local per_es = slr.per_es
      local start_entry = per_es[start_earley_set]
      if not start_entry then
          return 0, 0
      end
      local end_entry = per_es[end_earley_set]
      if not end_entry then
          end_entry = per_es[#per_es]
      end
      local l0_start = start_entry[2]
      local l0_length = end_entry[2] + end_entry[3] - l0_start
      return l0_start, l0_length
    end

```

    -- miranda: section+ most Lua function definitions
    function _M.class_slr.earley_item_data(slr, lmw_r, set_id, item_id)
        local item_data = {}
        local lmw_g = lmw_r.lmw_g

        local result = lmw_r:_earley_set_trace(set_id)
        if not result then return end

        local ahm_id_of_yim = lmw_r:_earley_item_trace(item_id)
        if not ahm_id_of_yim then return end

        local origin_set_id  = lmw_r:_earley_item_origin()
        local origin_earleme = lmw_r:earleme(origin_set_id)
        local current_earleme = lmw_r:earleme(set_id)

        local nrl_id = lmw_g:_ahm_irl(ahm_id_of_yim)
        local dot_position = lmw_g:_ahm_position(ahm_id_of_yim)

        item_data.current_set_id = set_id
        item_data.current_earleme = current_earleme
        item_data.ahm_id_of_yim = ahm_id_of_yim
        item_data.origin_set_id = origin_set_id
        item_data.origin_earleme = origin_earleme
        item_data.nrl_id = nrl_id
        item_data.dot_position = dot_position

        do -- token links
            local symbol_id = lmw_r:_first_token_link_trace()
            local links = {}
            while symbol_id do
                links[#links+1] = slr:token_link_data(lmw_r)
                symbol_id = lmw_r:_next_token_link_trace()
            end
            item_data.token_links = links
        end

        do -- completion links
            local ahm_id = lmw_r:_first_completion_link_trace()
            local links = {}
            while ahm_id do
                links[#links+1] = lmw_r:completion_link_data(ahm_id)
                ahm_id = lmw_r:_next_completion_link_trace()
            end
            item_data.completion_links = links
        end

        do -- leo links
            local ahm_id = lmw_r:_first_leo_link_trace()
            local links = {}
            while ahm_id do
                links[#links+1] = lmw_r:leo_link_data(ahm_id)
                ahm_id = lmw_r:_next_leo_link_trace()
            end
            item_data.leo_links = links
        end

        return item_data
    end

    function _M.class_slr.earley_set_data(slr, lmw_r, set_id)
        -- print('earley_set_data(', set_id, ')')
        local lmw_g = lmw_r.lmw_g
        local data = {}

        local result = lmw_r:_earley_set_trace(set_id)
        if not result then return end

        local earleme = lmw_r:earleme(set_id)
        data.earleme = earleme

        local item_id = 0
        while true do
            local item_data = slr:earley_item_data(lmw_r, set_id, item_id)
            if not item_data then break end
            data[#data+1] = item_data
            item_id = item_id + 1
        end
        data.leo = {}
        local postdot_symbol_id = lmw_r:_first_postdot_item_trace();
        while postdot_symbol_id do
            -- If there is no base Earley item,
            -- then this is not a Leo item, so we skip it
            local leo_item_data = lmw_r:leo_item_data()
            if leo_item_data then
                data.leo[#data.leo+1] = leo_item_data
            end
            postdot_symbol_id = lmw_r:_next_postdot_item_trace()
        end
        -- print('earley_set_data() ->', inspect(data))
        return data
    end

    function _M.class_slr.g1_earley_set_data(slr, set_id)
        local lmw_r = slr.g1
        local result = slr:earley_set_data(lmw_r, set_id)
        return result
    end

```

```
    -- miranda: section+ various Kollos lua defines
    _M.defines.TOKEN_VALUE_IS_UNDEF = 1
    _M.defines.TOKEN_VALUE_IS_LITERAL = 2

    _M.defines.MARPA_OP_LUA = 3
    _M.defines.MARPA_OP_NOOP = 4
    _M.op_names = {
        [_M.defines.MARPA_OP_LUA] = "lua",
        [_M.defines.MARPA_OP_NOOP] = "noop",
    }

    -- miranda: section+ temporary defines
    /* TODO: Delete after development */
    #define MARPA_OP_LUA 3
    #define MARPA_OP_NOOP 4

```

## The valuator Libmarpa wrapper

The "valuator" portion of Kollos produces the
value of a
Kollos parse.

### Initialize a valuator

Called when a valuator is set up.

```
    -- miranda: section+ valuator Libmarpa wrapper Lua functions

    function _M.class_slr.value_init(slr, trace_values)

        if not slr.lmw_v then
            error('no slr.lmw_v in value_init()')
        end

        slr.trace_values = trace_values;
        slr.trace_values_queue = {};
        if slr.trace_values > 0 then
          local top_of_queue = #slr.trace_values_queue;
          slr.trace_values_queue[top_of_queue+1] = {
            "valuator trace level", 0,
            slr.trace_values,
          }
        end

        slr.lmw_v.stack = {}
    end

```

### Reset a valuator

A function to be called whenever a valuator is reset.
It should free all memory associated with the valuation.

```

    -- miranda: section+ valuator Libmarpa wrapper Lua functions

    function _M.class_slr.valuation_reset(slr)
        -- io.stderr:write('Initializing rule semantics to nil\n')

        slr.trace_values = 0;
        slr.trace_values_queue = {};

        slr.lmw_b = nil
        slr.lmw_o = nil
        slr.lmw_t = nil
        slr.lmw_v = nil

        slr.tree_mode = nil
        -- Libmarpa's tree pausing requires value objects to
        -- be destroyed quickly
        -- print("About to collect garbage")
        collectgarbage()
    end

```

## Diagnostics

```
    -- miranda: section+ diagnostics
    function _M.class_slr.and_node_tag(slr, and_node_id)
        local bocage = slr.lmw_b
        local parent_or_node_id = bocage:_and_node_parent(and_node_id)
        local origin = bocage:_or_node_origin(parent_or_node_id)
        local origin_earleme = slr.g1:earleme(origin)

        local current_earley_set = bocage:_or_node_set(parent_or_node_id)
        local current_earleme = slr.g1:earleme(current_earley_set)

        local cause_id = bocage:_and_node_cause(and_node_id)
        local predecessor_id = bocage:_and_node_predecessor(and_node_id)

        local middle_earley_set = bocage:_and_node_middle(and_node_id)
        local middle_earleme = slr.g1:earleme(middle_earley_set)

        local position = bocage:_or_node_position(parent_or_node_id)
        local nrl_id = bocage:_or_node_irl(parent_or_node_id)

        local tag = { string.format("R%d:%d@%d-%d",
            nrl_id,
            position,
            origin_earleme,
            current_earleme)
        }

        if cause_id then
            tag[#tag+1] = string.format("C%d", bocage:_or_node_irl(cause_id))
        else
            tag[#tag+1] = string.format("S%d", bocage:_and_node_symbol(and_node_id))
        end
        tag[#tag+1] = string.format("@%d", middle_earleme)
        return table.concat(tag)
    end

    function _M.class_slr.show_and_nodes(slr)
        local bocage = slr.lmw_b
        local g1r = slr.g1
        local data = {}
        local id = -1
        while true do
            id = id + 1
            local parent = bocage:_and_node_parent(id)
            -- print('parent:', parent)
            if not parent then break end
            local predecessor = bocage:_and_node_predecessor(id)
            local cause = bocage:_and_node_cause(id)
            local symbol = bocage:_and_node_symbol(id)
            local origin = bocage:_or_node_origin(parent)
            local set = bocage:_or_node_set(parent)
            local nrl_id = bocage:_or_node_irl(parent)
            local position = bocage:_or_node_position(parent)
            local origin_earleme = g1r:earleme(origin)
            local current_earleme = g1r:earleme(set)
            local middle_earley_set = bocage:_and_node_middle(id)
            local middle_earleme = g1r:earleme(middle_earley_set)
            local desc = {string.format(
                "And-node #%d: R%d:%d@%d-%d",
                id,
                nrl_id,
                position,
                origin_earleme,
                current_earleme)}
            -- Marpa::R2's show_and_nodes() had a minor bug:
            -- cause_nrl_id was not set properly and therefore
            -- not used in the sort.  That problem is fixed
            -- here.
            local cause_nrl_id = -1
            if cause then
                cause_nrl_id = bocage:_or_node_irl(cause)
                desc[#desc+1] = 'C' .. cause_nrl_id
            else
                desc[#desc+1] = 'S' .. symbol
            end
            desc[#desc+1] = '@' .. middle_earleme
            if not symbol then symbol = -1 end
            data[#data+1] = {
                origin_earleme,
                current_earleme,
                nrl_id,
                position,
                middle_earleme,
                symbol,
                cause_nrl_id,
                table.concat(desc)
            }
        end
        -- print('data:', inspect(data))

        table.sort(data, _M.cmp_seq)
        local result = {}
        for _,datum in pairs(data) do
            result[#result+1] = datum[#datum]
        end
        result[#result+1] = '' -- so concat adds a final '\n'
        return table.concat(result, '\n')
    end

    function _M.class_slr.or_node_tag(slr, or_node_id)
        local bocage = slr.lmw_b
        local set = bocage:_or_node_set(or_node_id)
        local nrl_id = bocage:_or_node_irl(or_node_id)
        local origin = bocage:_or_node_origin(or_node_id)
        local position = bocage:_or_node_position(or_node_id)
        return string.format("R%d:%d@%d-%d",
            nrl_id,
            position,
            origin,
            set)
    end

    function _M.class_slr.show_or_nodes(slr)
        local bocage = slr.lmw_b
        local g1r = slr.g1
        local data = {}
        local id = -1
        while true do
            id = id + 1
            local origin = bocage:_or_node_origin(id)
            if not origin then break end
            local set = bocage:_or_node_set(id)
            local nrl_id = bocage:_or_node_irl(id)
            local position = bocage:_or_node_position(id)
            local origin_earleme = g1r:earleme(origin)
            local current_earleme = g1r:earleme(set)

            local desc = {string.format(
                "R%d:%d@%d-%d",
                nrl_id,
                position,
                origin_earleme,
                current_earleme)}
            data[#data+1] = {
                origin_earleme,
                current_earleme,
                nrl_id,
                table.concat(desc)
            }
        end

        local function cmp_data(i, j)
            for ix = 1, #i do
                if i[ix] < j[ix] then return true end
                if i[ix] > j[ix] then return false end
            end
            return false
        end

        table.sort(data, cmp_data)
        local result = {}
        for _,datum in pairs(data) do
            result[#result+1] = datum[#datum]
        end
        result[#result+1] = '' -- so concat adds a final '\n'
        return table.concat(result, '\n')
    end

`show_bocage` returns a string which describes the bocage.

    -- miranda: section+ diagnostics
    function _M.class_slr.show_bocage(slr)
        local bocage = slr.lmw_b
        local data = {}
        local or_node_id = -1
        while true do
            or_node_id = or_node_id + 1
            local irl_id = bocage:_or_node_irl(or_node_id)
            if not irl_id then goto LAST_OR_NODE end
            local position = bocage:_or_node_position(or_node_id)
            local or_origin = bocage:_or_node_origin(or_node_id)
            local origin_earleme = slr.g1:earleme(or_origin)
            local or_set = bocage:_or_node_set(or_node_id)
            local current_earleme = slr.g1:earleme(or_set)
            local and_node_ids = {}
            local first_and_id = bocage:_or_node_first_and(or_node_id)
            local last_and_id = bocage:_or_node_last_and(or_node_id)
            for and_node_id = first_and_id, last_and_id do
                local symbol = bocage:_and_node_symbol(and_node_id)
                local cause_tag
                if symbol then cause_tag = 'S' .. symbol end
                local cause_id = bocage:_and_node_cause(and_node_id)
                local cause_irl_id
                if cause_id then
                    cause_irl_id = bocage:_or_node_irl(cause_id)
                    cause_tag = slr:or_node_tag(cause_id)
                end
                local parent_tag = slr:or_node_tag(or_node_id)
                local predecessor_id = bocage:_and_node_predecessor(and_node_id)
                local predecessor_tag = "-"
                if predecessor_id then
                    predecessor_tag = slr:or_node_tag(predecessor_id)
                end
                local tag = string.format(
                    "%d: %d=%s %s %s",
                    and_node_id,
                    or_node_id,
                    parent_tag,
                    predecessor_tag,
                    cause_tag
                )
                data[#data+1] = { and_node_id, tag }
            end
            ::LAST_AND_NODE::
        end
        ::LAST_OR_NODE::

        local function cmp_data(i, j)
            if i[1] < j[1] then return true end
            return false
        end

        table.sort(data, cmp_data)
        local result = {}
        for _,datum in pairs(data) do
            result[#result+1] = datum[#datum]
        end
        result[#result+1] = '' -- so concat adds a final '\n'
        return table.concat(result, '\n')

    end

```

### Input

```
    -- miranda: section+ diagnostics
    function _M.class_slr.character_describe(slr, codepoint)
        return string.format('U+%04x %q',
           codepoint, utf8.char(codepoint))
    end
```

```
    -- miranda: section+ diagnostics
    function _M.class_slr.input_escape(slr, block_ix, start, max_length)
        local block = slr.inputs[block_ix]
        local pos = start
        local function codes()
            return function()
                if pos > #block then return end
                local codepoint = slr:codepoint_from_pos(block_ix, pos)
                pos = pos + 1
                return codepoint
            end
        end
        return _M.factory_escape(codes, max_length)
    end

    function _M.class_slr.g1_escape(slr, g1_pos, max_length)
        -- a worst case maximum, since each g1 location will have
        --   an L0 length of at least 1
        local g1_last = g1_pos + max_length
        local function factory()
            local function iter()
                for this_block, this_start, this_len in
                    sweep_range(slr, g1_pos, g1_last)
                do
                   for this_pos = this_start, this_start + this_len - 1 do
                       local codepoint = slr:codepoint_from_pos(this_block, this_pos)
                       coroutine.yield(codepoint)
                   end
                end
            end
            return coroutine.wrap(iter)
        end
        return _M.factory_escape(factory, max_length)
    end

    function _M.factory_escape(factory, max_length)
        local length_so_far = 0
        local escapes = {}

        for codepoint in factory() do
             local escape = _M.escape_codepoint(codepoint)
             length_so_far = length_so_far + #escape
             if length_so_far > max_length then
                 length_so_far = length_so_far - #escape
                 break
             end
             escapes[#escapes+1] = escape
        end

             -- print(inspect(escapes))

        -- trailing spaces get special treatment
        for i = #escapes, 1, -1 do
            if escapes[i] ~= ' ' then break end
            escapes[i] = '\\s'
            -- the escaped version is one character longer
            length_so_far = length_so_far + 1
        end

             -- print(inspect(escapes))

        -- trim back to adjust for escaped trailing spaces
        for i = #escapes, 1, -1 do
             -- print(length_so_far, max_length)
            if length_so_far <= max_length then break end
            escapes[i] = ''
            length_so_far = length_so_far - 2
        end

             -- print(inspect(escapes))

        return table.concat(escapes)
    end

    function _M.class_slr.reversed_input_escape(slr, block_ix, base_pos, max_length)
        local pos = base_pos - 1
        local function codes()
            return function()
                if pos < 0 then return end
                local codepoint = slr:codepoint_from_pos(block_ix, pos)
                pos = pos - 1
                return codepoint
            end
        end
        return reverse_factory_escape(codes, max_length)
    end

    function _M.class_slr.reverse_g1_escape(slr, g1_base, max_length)

        -- a worst case maximum, since each g1 location will have
        --   an L0 length of at least 1
        local g1_last = g1_base - (max_length + 1)
        if g1_last < 0 then g1_last = 0 end

        local function factory()
            local function iter()
                for this_block, this_start, this_len in
                    reverse_sweep_range(slr, g1_base - 1, g1_last)
                do
                   for this_pos = this_start + this_len - 1, this_start, -1 do
                       local codepoint = slr:codepoint_from_pos(this_block, this_pos)
                       coroutine.yield(codepoint)
                   end
                end
            end
            return coroutine.wrap(iter)
        end
        return reverse_factory_escape(factory, max_length)
    end

    -- miranda: section+ forward declarations
    local reverse_factory_escape
    -- miranda: section+ diagnostics
    function reverse_factory_escape(factory, max_length)
        local length_so_far = 0
        local reversed = {}
        for codepoint in factory() do
             local escape = _M.escape_codepoint(codepoint)
             length_so_far = length_so_far + #escape
             if length_so_far > max_length then
                 length_so_far = length_so_far - #escape
                 break
             end
             reversed[#reversed+1] = escape
        end

        -- trailing spaces get special treatment
        for i = 1, #reversed  do
            if reversed[i] ~= ' ' then break end
            reversed[i] = '\\s'
            -- the escaped version is one character longer
            length_so_far = length_so_far + 1
        end

        -- trim back to adjust for escaped trailing spaces
        local ix = #reversed
        while length_so_far > max_length do
            local this_escape = reversed[ix]
            reversed[ix] = ''
            length_so_far = length_so_far - #this_escape
            ix = ix - 1
        end

        local escapes = {}
        for i = #reversed, 1, -1 do
            escapes[#escapes+1] = reversed[i]
        end

        return table.concat(escapes)
    end

```

## Libmarpa grammar class

### Fields

```
    -- miranda: section+ class_grammar field declarations
    class_grammar_fields._libmarpa = true
    class_grammar_fields.irls = true
    class_grammar_fields.isyid_by_name = true
    class_grammar_fields.isys = true
    class_grammar_fields.lmw_g = true
    class_grammar_fields.name_by_isyid = true
    class_grammar_fields.slg = true
    class_grammar_fields.start_name = true
    class_grammar_fields.xbnf_by_irlid = true
```

A per-grammar table of the XSY's,
indexed by isyid.

```
    -- miranda: section+ class_grammar field declarations
    class_grammar_fields.xsys = true
```

```
    -- miranda: section+ populate metatables
    local class_grammar_fields = {}
    -- miranda: insert class_grammar field declarations
    declarations(_M.class_grammar, class_grammar_fields, 'grammar')
```

### Constructor

```
    -- miranda: section+ copy metal tables
    _M.metal.grammar_new = _M.grammar_new
    -- miranda: section+ most Lua function definitions
    function _M.grammar_new(slg)
        local grammar = _M.metal.grammar_new()
        setmetatable(grammar, _M.class_grammar)
        grammar:force_valued()
        grammar.isyid_by_name = {}
        grammar.name_by_isyid = {}
        grammar.irls = {}
        grammar.isys = {}
        grammar.slg = slg
        grammar.xbnf_by_irlid = {}
        grammar.xsys = {}

        return grammar
    end

```

```
    -- miranda: section+ copy metal tables
    _M.metal_grammar.symbol_new = _M.class_grammar.symbol_new
    -- miranda: section+ most Lua function definitions
    function _M.class_grammar.symbol_new(grammar, symbol_name)
        local symbol_id = _M.metal_grammar.symbol_new(grammar)
        local symbol = setmetatable({}, _M.class_isy)
        symbol.id = symbol_id
        symbol.name = symbol_name
        grammar.isyid_by_name[symbol_name] = symbol_id
        grammar.name_by_isyid[symbol_id] = symbol_name
        return symbol
    end

```

```
    -- miranda: section+ grammar Libmarpa wrapper Lua functions

    function _M.class_grammar.symbol_name(lmw_g, symbol_id)
        local symbol_name = lmw_g.name_by_isyid[symbol_id]
        return symbol_name
    end

    function _M.class_grammar.irl_isyids(lmw_g, rule_id)
        local lhs = lmw_g:rule_lhs(rule_id)
        if not lhs then return end
        local symbols = { lhs }
        for rhsix = 0, lmw_g:rule_length(rule_id) - 1 do
             symbols[#symbols+1] = lmw_g:rule_rhs(rule_id, rhsix)
        end
        return symbols
    end

    function _M.class_grammar.ahm_describe(lmw_g, ahm_id)
        local irl_id = lmw_g:_ahm_irl(ahm_id)
        local dot_position = lmw_g:_ahm_position(ahm_id)
        if dot_position < 0 then
            return string.format('R%d$', irl_id)
        end
        return string.format('R%d:%d', irl_id, dot_position)
    end

    function _M.class_grammar._dotted_nrl_show(lmw_g, nrl_id, dot_position)
        local lhs_id = lmw_g:_irl_lhs(nrl_id)
        local nrl_length = lmw_g:_irl_length(nrl_id)
        local lhs_name = lmw_g:nsy_name(lhs_id)
        local pieces = { lhs_name, '::=' }
        if dot_position < 0 then
            dot_position = nrl_length
        end
        for ix = 0, nrl_length - 1 do
            local rhs_nsy_id = lmw_g:_irl_rhs(nrl_id, ix)
            local rhs_nsy_name = lmw_g:nsy_name(rhs_nsy_id)
            if ix == dot_position then
                pieces[#pieces+1] = '.'
            end
            pieces[#pieces+1] = rhs_nsy_name
        end
        if dot_position >= nrl_length then
            pieces[#pieces+1] = '.'
        end
        return table.concat(pieces, ' ')
    end

```

```
    -- miranda: section+ grammar Libmarpa wrapper Lua functions

    function _M.class_grammar.nsy_name(lmw_g, nsy_id_arg)
         -- start symbol
         local nsy_id = math.tointeger(nsy_id_arg)
         if not nsy_id then error('Bad nsy_name() symbol ID arg: ' .. inspect(nsy_id_arg)) end
         local nsy_is_start = 0 ~= lmw_g:_nsy_is_start(nsy_id)
         if nsy_is_start then
             local xsy_id = lmw_g:_source_xsy(nsy_id)
             local xsy_name = lmw_g:symbol_name(xsy_id)
             return xsy_name .. "[']"
         end

         -- sequence LHS
         local lhs_xrl = lmw_g:_nsy_lhs_xrl(nsy_id)
         if lhs_xrl and lmw_g:sequence_min(lhs_xrl) then
             local original_lhs_id = lmw_g:rule_lhs(lhs_xrl)
             local lhs_name = lmw_g:symbol_name(original_lhs_id)
             return lhs_name .. "[Seq]"
         end

         -- virtual symbol
         local xrl_offset = lmw_g:_nsy_xrl_offset(nsy_id)
         if xrl_offset and xrl_offset > 0 then
             local original_lhs_id = lmw_g:rule_lhs(lhs_xrl)
             local lhs_name = lmw_g:symbol_name(original_lhs_id)
             return string.format("%s[R%d:%d]",
                 lhs_name, lhs_xrl, xrl_offset)
         end

         -- real, named symbol or its nulling equivalent
         local xsy_id = lmw_g:_source_xsy(nsy_id)
         local xsy_name = lmw_g:symbol_name(xsy_id)
         local is_nulling = 0 ~= lmw_g:_nsy_is_nulling(nsy_id)
         if is_nulling then
             xsy_name = xsy_name .. "[]"
         end
         return xsy_name
    end

    function _M.class_grammar.show_ahm(lmw_g, item_id)
        local postdot_id = lmw_g:_ahm_postdot(item_id)
        local pieces = { "AHM " .. item_id .. ': ' }
        local properties = {}
        if not postdot_id then
            properties[#properties+1] = 'completion'
        else
            properties[#properties+1] =
               'postdot = "' ..  lmw_g:nsy_name(postdot_id) .. '"'
        end
        pieces[#pieces+1] = table.concat(properties, '; ')
        pieces[#pieces+1] = "\n    "
        local irl_id = lmw_g:_ahm_irl(item_id)
        local dot_position = lmw_g:_ahm_position(item_id)
        pieces[#pieces+1] = lmw_g:_dotted_nrl_show(irl_id, dot_position)
        pieces[#pieces+1] = '\n'
        return table.concat(pieces)
    end

    function _M.class_grammar.show_ahms(lmw_g)
        local pieces = {}
        local count = lmw_g:_ahm_count()
        for i = 0, count -1 do
            pieces[#pieces+1] = lmw_g:show_ahm(i)
        end
        return table.concat(pieces)
    end

    function _M.class_grammar.show_nsy(lmw_g, nsy_id)
        local name = lmw_g:nsy_name(nsy_id)
        local pieces = { string.format("%d: %s", nsy_id, name) }
        local tags = {}
        local is_nulling = 0 ~= lmw_g:_nsy_is_nulling(nsy_id)
        if is_nulling then
        tags[#tags+1] = 'nulling'
        end
        if #tags > 0 then
            pieces[#pieces+1] = ', ' .. table.concat(tags, ' ')
        end
        pieces[#pieces+1] = '\n'
        return table.concat(pieces)
    end

    function _M.class_grammar.brief_nrl(lmw_g, nrl_id)
        local pieces = { string.format("%d:", nrl_id) }
        local lhs_id = lmw_g:_irl_lhs(nrl_id)
        pieces[#pieces+1] = lmw_g:nsy_name(lhs_id)
        pieces[#pieces+1] = "::="
        local rh_length = lmw_g:_irl_length(nrl_id)
        if rh_length > 0 then
           for rhs_ix = 0, rh_length - 1 do
              local this_rhs_id = lmw_g:_irl_rhs(nrl_id, rhs_ix)
              pieces[#pieces+1] = lmw_g:nsy_name(this_rhs_id)
           end
        end
        return table.concat(pieces, " ")
    end

```

### Layer grammar accessors

`isy_key` is an ISY id.

TODO: Perhaps `isy_key` should also allow isy tables.

```
    -- miranda: section+ most Lua function definitions
    function _M.class_grammar._xsy(grammar, isy_key)
        return grammar.xsys[isy_key]
    end
    function _M.class_grammar.xsyid(grammar, isy_key)
        local xsy = grammar:xsy(isy_key)
        if not xsy then
            _M.userX(string.format(
               "grammar:xsyid(%s): no such xsy",
               inspect(isy_key)))
        end
        return xsy.id
    end
```

```
    -- miranda: section+ most Lua function definitions
    function _M.class_grammar.symbol_dsl_form(grammar, isyid)
        local xsy = grammar.xsys[isyid]
        if not xsy then return end
        return xsy.dsl_form
    end
```

Finds a displayable
name for an ISYID,
pulling one out of thin air if need be.
The "forced" name is not
necessarily unique.

```
    -- miranda: section+ most Lua function definitions
    function _M.class_grammar.symbol_display_form(grammar, isyid)
        local xsy = grammar.xsys[isyid]
        if xsy then return xsy:display_form() end
        local isy = grammar.isys[isyid]
        if isy then return isy:display_form() end
        return '<isyid ' .. isyid .. '>'
    end
```

## The recognizer Libmarpa wrapper

### Fields

```
    -- miranda: section+ class_recce field declarations
    class_recce_fields._libmarpa = true
    class_recce_fields.lmw_g = true
```

```
    -- miranda: section+ populate metatables
    local class_recce_fields = {}
    -- miranda: insert class_recce field declarations
    declarations(_M.class_recce, class_recce_fields, 'recce')
```

### Functions for tracing Earley sets

```
    -- miranda: section+ recognizer Libmarpa wrapper Lua functions
    function _M.class_recce.leo_item_data(lmw_r)
        local lmw_g = lmw_r.lmw_g
        local leo_base_state = lmw_r:_leo_base_state()
        if not leo_base_state then return end
        local trace_earley_set = lmw_r:_trace_earley_set()
        local trace_earleme = lmw_r:earleme(trace_earley_set)
        local postdot_symbol_id = lmw_r:_postdot_item_symbol()
        local postdot_symbol_name = lmw_g:nsy_name(postdot_symbol_id)
        local predecessor_symbol_id = lmw_r:_leo_predecessor_symbol()
        local base_origin_set_id = lmw_r:_leo_base_origin()
        local base_origin_earleme = lmw_r:earleme(base_origin_set_id)
        return {
            postdot_symbol_name = postdot_symbol_name,
            postdot_symbol_id = postdot_symbol_id,
            predecessor_symbol_id = predecessor_symbol_id,
            base_origin_earleme = base_origin_earleme,
            leo_base_state = leo_base_state,
            trace_earleme = trace_earleme
        }
    end

    function _M.class_recce.completion_link_data(lmw_r, ahm_id)
        local result = {}
        local predecessor_state = lmw_r:_source_predecessor_state()
        local origin_set_id = lmw_r:_earley_item_origin()
        local origin_earleme = lmw_r:earleme(origin_set_id)
        local middle_set_id = lmw_r:_source_middle()
        local middle_earleme = lmw_r:earleme(middle_set_id)
        result.predecessor_state = predecessor_state
        result.origin_earleme = origin_earleme
        result.middle_earleme = middle_earleme
        result.middle_set_id = middle_set_id
        result.ahm_id = ahm_id
        return result
    end

    function _M.class_recce.leo_link_data(lmw_r, ahm_id)
        local result = {}
        local middle_set_id = lmw_r:_source_middle()
        local middle_earleme = lmw_r:earleme(middle_set_id)
        local leo_transition_symbol = lmw_r:_source_leo_transition_symbol()
        result.middle_earleme = middle_earleme
        result.leo_transition_symbol = leo_transition_symbol
        result.ahm_id = ahm_id
        return result
    end
```

## External symbol (XSY) class

### Fields

```
    -- miranda: section+ class_xsy field declarations
    class_xsy_fields.assertion = true
```

```
    -- miranda: section+ create nonmetallic metatables
    _M.class_xsy = {}
    -- miranda: section+ populate metatables
    local class_xsy_fields = {}

    class_xsy_fields.id = true
    class_xsy_fields.name = true
    class_xsy_fields.lexeme_semantics = true
    class_xsy_fields.blessing = true
    class_xsy_fields.dsl_form = true
    class_xsy_fields.if_inaccessible = true
    class_xsy_fields.name_source = true
    class_xsy_fields.g1_lexeme_id = true
    class_xsy_fields.l0_lexeme_id = true

    -- miranda: insert class_xsy field declarations
    declarations(_M.class_xsy, class_xsy_fields, 'xsy')
```

## Accessors

```
    -- miranda: section+ most Lua function definitions
    function _M.class_xsy.display_form(xsy)
        local form1 = xsy.dsl_form or xsy.name
        if form1:find(' ', 1, true) then
            return '<' .. form1 .. '>'
        end
        return form1
    end
```

## Rules

## IRL Fields

```
    -- miranda: section+ class_irl field declarations
    class_irl_fields.id = true
    class_irl_fields.xbnf = true
    class_irl_fields.action = true
    class_irl_fields.mask = true
    class_irl_fields.g1_lexeme = true
    class_irl_fields.xrl_dot = true
```

```
    -- miranda: section+ create nonmetallic metatables
    _M.class_irl = {}
    -- miranda: section+ populate metatables
    local class_irl_fields = {}
    -- miranda: insert class_irl field declarations
    declarations(_M.class_irl, class_irl_fields, 'irl')
```

## XRL Fields

```
    -- miranda: section+ class_xrl field declarations
    class_xrl_fields.id = true
    class_xrl_fields.name = true
    class_xrl_fields.assertion = true
    class_xrl_fields.precedence_count = true
    class_xrl_fields.lhs = true
    class_xrl_fields.start = true
    class_xrl_fields.length = true
```

```
    -- miranda: section+ create nonmetallic metatables
    _M.class_xrl = {}
    -- miranda: section+ populate metatables
    local class_xrl_fields = {}

    class_xrl_fields.id = true

    -- miranda: insert class_xrl field declarations
    declarations(_M.class_xrl, class_xrl_fields, 'xrl')
```

## XBNF Fields

```
    -- miranda: section+ class_xbnf field declarations
    class_xbnf_fields.action = true
    class_xbnf_fields.bless = true
    class_xbnf_fields.discard_separation = true
    class_xbnf_fields.event_name = true
    class_xbnf_fields.event_starts_active = true
    class_xbnf_fields.id = true
    class_xbnf_fields.length = true
    class_xbnf_fields.lhs = true
    class_xbnf_fields.mask = true
    class_xbnf_fields.min = true
    class_xbnf_fields.name = true
    class_xbnf_fields.null_ranking = true
    class_xbnf_fields.proper = true
    class_xbnf_fields.rank = true
    class_xbnf_fields.rhs = true
    class_xbnf_fields.separator = true
    class_xbnf_fields.start = true
    class_xbnf_fields.subgrammar = true
    class_xbnf_fields.symbol_as_event = true
    class_xbnf_fields.xrl_name = true
```

```
    -- miranda: section+ create nonmetallic metatables
    _M.class_xbnf = {}
    -- miranda: section+ populate metatables
    local class_xbnf_fields = {}

    class_xbnf_fields.id = true

    -- miranda: insert class_xbnf field declarations
    declarations(_M.class_xbnf, class_xbnf_fields, 'xbnf')
```

## Inner symbol (ISY) class

### Fields

```
    -- miranda: section+ class_isy field declarations
    class_isy_fields.id = true
    class_isy_fields.name = true
    -- fields for use by upper layers?
    class_isy_fields.assertion = true
    class_isy_fields.pause_after = true
    class_isy_fields.pause_after_active = true
    class_isy_fields.pause_before = true
    class_isy_fields.pause_before_active = true
    class_isy_fields.priority = true
    class_isy_fields.is_lexeme = true
    class_isy_fields.eager = true
```

```
    -- miranda: section+ create nonmetallic metatables
    _M.class_isy = {}
    -- miranda: section+ populate metatables
    local class_isy_fields = {}
    -- miranda: insert class_isy field declarations
    declarations(_M.class_isy, class_isy_fields, 'isy')
```

### Accessors

```
    -- miranda: section+ most Lua function definitions
    function _M.class_isy.display_form(isy)
        local form = isy.name
        if not form:find(' ', 1, true) then
            return form
        end
        return '<' .. form .. '>'
    end
```

## Libmarpa interface

```
    --[==[ miranda: exec libmarpa interface globals

    function c_type_of_libmarpa_type(libmarpa_type)
        if (libmarpa_type == 'int') then return 'int' end
        if (libmarpa_type == 'Marpa_And_Node_ID') then return 'int' end
        if (libmarpa_type == 'Marpa_Assertion_ID') then return 'int' end
        if (libmarpa_type == 'Marpa_AHM_ID') then return 'int' end
        if (libmarpa_type == 'Marpa_Earley_Item_ID') then return 'int' end
        if (libmarpa_type == 'Marpa_Earley_Set_ID') then return 'int' end
        if (libmarpa_type == 'Marpa_IRL_ID') then return 'int' end
        if (libmarpa_type == 'Marpa_Nook_ID') then return 'int' end
        if (libmarpa_type == 'Marpa_NSY_ID') then return 'int' end
        if (libmarpa_type == 'Marpa_Or_Node_ID') then return 'int' end
        if (libmarpa_type == 'Marpa_Rank') then return 'int' end
        if (libmarpa_type == 'Marpa_Rule_ID') then return 'int' end
        if (libmarpa_type == 'Marpa_Symbol_ID') then return 'int' end
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

    libmarpa_class_sequence = { 'g', 'r', 'b', 'o', 't', 'v'}

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
         result[#result+1] = [[  marpa_luaL_argcheck(L, (-(1<<30) <= this_arg && this_arg <= (1<<30)), -1, "argument out of range");]], "\n"

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
                            "   return libmarpa_error_handle(L, self_stack_ix, %q);\n",
                            wrapper_name .. '()')
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
    {"marpa_g_default_rank"},
    {"marpa_g_default_rank_set", "Marpa_Rank", "rank" },
    {"marpa_g_error_clear"},
    {"marpa_g_event_count"},
    {"marpa_g_force_valued"},
    {"marpa_g_has_cycle"},
    {"marpa_g_highest_rule_id"},
    {"marpa_g_highest_symbol_id"},
    {"marpa_g_is_precomputed"},
    {"marpa_g_nulled_symbol_activate", "Marpa_Symbol_ID", "sym_id", "int", "activate"},
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
    {"marpa_g_rule_rank", "Marpa_Rule_ID", "rule_id" },
    {"marpa_g_rule_rank_set", "Marpa_Rule_ID", "rule_id", "Marpa_Rank", "rank" },
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
    {"marpa_g_symbol_rank", "Marpa_Symbol_ID", "symbol_id" },
    {"marpa_g_symbol_rank_set", "Marpa_Symbol_ID", "symbol_id", "Marpa_Rank", "rank" },
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
    {"_marpa_t_size" },
    {"_marpa_t_nook_or_node", "Marpa_Nook_ID", "nook_id" },
    {"_marpa_t_nook_choice", "Marpa_Nook_ID", "nook_id" },
    {"_marpa_t_nook_parent", "Marpa_Nook_ID", "nook_id" },
    {"_marpa_t_nook_is_cause", "Marpa_Nook_ID", "nook_id" },
    {"_marpa_t_nook_cause_is_ready", "Marpa_Nook_ID", "nook_id" },
    {"_marpa_t_nook_is_predecessor", "Marpa_Nook_ID", "nook_id" },
    {"_marpa_t_nook_predecessor_is_ready", "Marpa_Nook_ID", "nook_id" },
    {"marpa_v_valued_force"},
    {"marpa_v_rule_is_valued_set", "Marpa_Rule_ID", "symbol_id", "int", "value"},
    {"marpa_v_symbol_is_valued_set", "Marpa_Symbol_ID", "symbol_id", "int", "value"},
    {"_marpa_v_nook"},
    {"_marpa_v_trace", "int", "flag"},
    {"_marpa_g_ahm_count"},
    {"_marpa_g_ahm_irl", "Marpa_AHM_ID", "item_id"},
    {"_marpa_g_ahm_postdot", "Marpa_AHM_ID", "item_id"},
    {"_marpa_g_irl_count"},
    {"_marpa_g_irl_is_virtual_lhs", "Marpa_IRL_ID", "irl_id"},
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

           result[#result+1] = string.format("  marpa_lua_getfield(L, kollos_table_stack_ix, %q);\n", class_table_name)
           -- for example: marpa_lua_getfield(L, kollos_table_stack_ix, "class_grammar")

           result[#result+1] = "marpa_lua_pushvalue(L, upvalue_stack_ix);\n";

           local wrapper_name = "wrap_" .. unprefixed_name;
           result[#result+1] = string.format("  marpa_lua_pushcclosure(L, %s, 1);\n", wrapper_name)
           -- for example: marpa_lua_pushcclosure(L, wrap_g_highest_rule_id, 1)

           local classless_name = function_name:gsub("^[_]?marpa_[^_]*_", "")
           local initial_underscore = function_name:match('^_') and '_' or ''
           local field_name = initial_underscore .. classless_name
           result[#result+1] = string.format("  marpa_lua_setfield(L, -2, %q);\n", field_name)
           -- for example: marpa_lua_setfield(L, -2, "highest_rule_id")

           result[#result+1] = string.format("  marpa_lua_pop(L, 1);\n", field_name)

        end
        return table.concat(result)
  ]==]

```

```

  -- miranda: section create kollos libmarpa wrapper class tables
  --[==[ miranda: exec create kollos libmarpa wrapper class tables
        local result = {}
        for class_letter, class in pairs(libmarpa_class_name) do
           local class_table_name = 'class_' .. class
           local functions_to_register = class .. '_methods'
           -- class_xyz = {}
           result[#result+1] = string.format("  marpa_luaL_newlibtable(L, %s);\n", functions_to_register)
           -- add functions and upvalue to class_xyz
           result[#result+1] = "  marpa_lua_pushvalue(L, upvalue_stack_ix);\n"
           result[#result+1] = string.format("  marpa_luaL_setfuncs(L, %s, 1);\n", functions_to_register)
           -- class_xyz.__index = class_xyz
           result[#result+1] = "  marpa_lua_pushvalue(L, -1);\n"
           result[#result+1] = '  marpa_lua_setfield(L, -2, "__index");\n'
           -- kollos[class_xyz] = class_xyz
           result[#result+1] = "  marpa_lua_pushvalue(L, -1);\n"
           result[#result+1] = string.format("  marpa_lua_setfield(L, kollos_table_stack_ix, %q);\n", class_table_name);
           -- class_xyz[kollos] = kollos
           result[#result+1] = "  marpa_lua_pushvalue(L, kollos_table_stack_ix);\n"
           result[#result+1] = '  marpa_lua_setfield(L, -2, "kollos");\n'
        end
        return table.concat(result)
  ]==]

```

### Constructors

The standard constructors are generated indirectly, from a template.
This saves a lot of repetition, which makes for easier reading in the
long run.
In the short run, however, you may want first to look at the bocage
constructor.
It is specified directly, which can be easier for a first reading.


  -- miranda: section object constructors
  --[==[ miranda: exec object constructors
        local result = {}
        local template = [[
        |static int
        |wrap_!NAME!_new (lua_State * L)
        |{
        |  const int !BASE_NAME!_stack_ix = 1;
        |  int !NAME!_stack_ix;
        |
        |  if (0)
        |    printf ("%s %s %d\n", __PRETTY_FUNCTION__, __FILE__, __LINE__);
        |  if (1)
        |    {
        |      marpa_luaL_checktype(L, !BASE_NAME!_stack_ix, LUA_TTABLE);
        |    }
        |
        |  marpa_lua_newtable(L);
        |  /* [ base_table, class_table ] */
        |  !NAME!_stack_ix = marpa_lua_gettop(L);
        |  marpa_lua_pushvalue(L, marpa_lua_upvalueindex(2));
        |  marpa_lua_setmetatable (L, !NAME!_stack_ix);
        |  /* [ base_table, class_table ] */
        |
        |  {
        |    !BASE_TYPE! *!BASE_NAME!_ud;
        |
        |    !TYPE! *!NAME!_ud =
        |      (!TYPE! *) marpa_lua_newuserdata (L, sizeof (!TYPE!));
        |    /* [ base_table, class_table, class_ud ] */
        |    marpa_lua_rawgetp (L, LUA_REGISTRYINDEX, &kollos_!LETTER!_ud_mt_key);
        |    /* [ class_table, class_ud, class_ud_mt ] */
        |    marpa_lua_setmetatable (L, -2);
        |    /* [ class_table, class_ud ] */
        |
        |    marpa_lua_setfield (L, !NAME!_stack_ix, "_libmarpa");
        |    marpa_lua_getfield (L, !BASE_NAME!_stack_ix, "lmw_g");
        |    marpa_lua_setfield (L, !NAME!_stack_ix, "lmw_g");
        |    marpa_lua_getfield (L, !BASE_NAME!_stack_ix, "_libmarpa");
        |    !BASE_NAME!_ud = (!BASE_TYPE! *) marpa_lua_touserdata (L, -1);
        |
        |    *!NAME!_ud = marpa_!LETTER!_new (*!BASE_NAME!_ud);
        |    if (!*!NAME!_ud)
        |      {
        |        return libmarpa_error_handle (L, !NAME!_stack_ix, "marpa_!LETTER!_new()");
        |      }
        |  }
        |
        |  if (0)
        |    printf ("%s %s %d\n", __PRETTY_FUNCTION__, __FILE__, __LINE__);
        |  marpa_lua_settop(L, !NAME!_stack_ix );
        |  /* [ base_table, class_table ] */
        |  return 1;
        |}
        ]]
        -- for every class with a base,
        -- so that grammar constructor is special case
        for class_ix = 2, #libmarpa_class_sequence do
            local class_letter = libmarpa_class_sequence[class_ix]
            -- bocage constructor is special case
            if class_letter == 'b' then goto NEXT_CLASS end
            local class_name = libmarpa_class_name[class_letter]
            local class_type = libmarpa_class_type[class_letter]
            local base_class_letter = libmarpa_class_sequence[class_ix-1]
            local base_class_name = libmarpa_class_name[base_class_letter]
            local base_class_type = libmarpa_class_type[base_class_letter]
            local this_piece =
                pipe_dedent(template)
                   :gsub("!BASE_NAME!", base_class_name)
                   :gsub("!BASE_TYPE!", base_class_type)
                   :gsub("!BASE_LETTER!", base_class_letter)
                   :gsub("!NAME!", class_name)
                   :gsub("!TYPE!", class_type)
                   :gsub("!LETTER!", class_letter)
            result[#result+1] = this_piece
            ::NEXT_CLASS::
        end
        return table.concat(result, "\n")
  ]==]

The bocage constructor takes an extra argument, so it's a special
case.
It's close to the standard constructor.
The standard constructors are generated indirectly, from a template.
The template saves repetition, but is harder on a first reading.
This bocage constructor is specified directly,
so you may find it easer to read it first.

    -- miranda: section+ object constructors
    static int
    wrap_bocage_new (lua_State * L)
    {
      const int recce_stack_ix = 1;
      const int ordinal_stack_ix = 2;
      int bocage_stack_ix;

      if (0)
        printf ("%s %s %d\n", __PRETTY_FUNCTION__, __FILE__, __LINE__);
      if (1)
        {
          marpa_luaL_checktype(L, recce_stack_ix, LUA_TTABLE);
        }

      marpa_lua_newtable(L);
      bocage_stack_ix = marpa_lua_gettop(L);
      /* push "class_bocage" metatable */
      marpa_lua_pushvalue(L, marpa_lua_upvalueindex(2));
      marpa_lua_setmetatable (L, bocage_stack_ix);

      {
        Marpa_Recognizer *recce_ud;

        Marpa_Bocage *bocage_ud =
          (Marpa_Bocage *) marpa_lua_newuserdata (L, sizeof (Marpa_Bocage));
        /* [ base_table, class_table, class_ud ] */
        marpa_lua_rawgetp (L, LUA_REGISTRYINDEX, &kollos_b_ud_mt_key);
        /* [ class_table, class_ud, class_ud_mt ] */
        marpa_lua_setmetatable (L, -2);
        /* [ class_table, class_ud ] */

        marpa_lua_setfield (L, bocage_stack_ix, "_libmarpa");
        marpa_lua_getfield (L, recce_stack_ix, "lmw_g");
        marpa_lua_setfield (L, bocage_stack_ix, "lmw_g");
        marpa_lua_getfield (L, recce_stack_ix, "_libmarpa");
        recce_ud = (Marpa_Recognizer *) marpa_lua_touserdata (L, -1);

        {
          int is_ok = 0;
          lua_Integer ordinal = -1;
          if (marpa_lua_isnil(L, ordinal_stack_ix)) {
             is_ok = 1;
          } else {
             ordinal = marpa_lua_tointegerx(L, ordinal_stack_ix, &is_ok);
          }
          if (!is_ok) {
              marpa_luaL_error(L,
                  "problem with bocage_new() arg #2, type was %s",
                  marpa_luaL_typename(L, ordinal_stack_ix)
              );
          }
          *bocage_ud = marpa_b_new (*recce_ud, (int)ordinal);
        }

        if (!*bocage_ud)
          {
            return libmarpa_error_handle (L, bocage_stack_ix, "marpa_b_new()");
          }
      }

      if (0)
        printf ("%s %s %d\n", __PRETTY_FUNCTION__, __FILE__, __LINE__);
      marpa_lua_settop(L, bocage_stack_ix );
      /* [ base_table, class_table ] */
      return 1;
    }

```

The grammar constructor is a special case, because its argument is
a special "configuration" argument.

    -- miranda: section+ object constructors
    static int
    lca_grammar_new (lua_State * L)
    {
        int grammar_stack_ix;

        if (0)
            printf ("%s %s %d\n", __PRETTY_FUNCTION__, __FILE__, __LINE__);

        marpa_lua_newtable (L);
        /* [ grammar_table ] */
        grammar_stack_ix = marpa_lua_gettop (L);
        /* push "class_grammar" metatable */
        marpa_lua_pushvalue(L, marpa_lua_upvalueindex(2));
        marpa_lua_setmetatable (L, grammar_stack_ix);
        /* [ grammar_table ] */

        {
            Marpa_Config marpa_configuration;
            Marpa_Grammar *grammar_ud =
                (Marpa_Grammar *) marpa_lua_newuserdata (L,
                sizeof (Marpa_Grammar));
            /* [ grammar_table, class_ud ] */
            marpa_lua_rawgetp (L, LUA_REGISTRYINDEX, &kollos_g_ud_mt_key);
            /* [ grammar_table, class_ud ] */
            marpa_lua_setmetatable (L, -2);
            /* [ grammar_table, class_ud ] */

            marpa_lua_setfield (L, grammar_stack_ix, "_libmarpa");

            marpa_c_init (&marpa_configuration);
            *grammar_ud = marpa_g_new (&marpa_configuration);
            if (!*grammar_ud) {
                return libmarpa_error_handle (L, grammar_stack_ix, "marpa_g_new()");
            }
        }

        /* Set my "lmw_g" field to myself */
        marpa_lua_pushvalue (L, grammar_stack_ix);
        marpa_lua_setfield (L, grammar_stack_ix, "lmw_g");

        marpa_lua_settop (L, grammar_stack_ix);
        /* [ grammar_table ] */
        return 1;
    }

```

## Output

### The main Lua code file

```
  -- miranda: section create metal tables
  --[==[ miranda: exec create metal tables
        local result = { "  _M.metal = {}" }
        for _, class in pairs(libmarpa_class_name) do
           local metal_table_name = 'metal_' .. class
           result[#result+1] = string.format("  _M[%q] = {}", metal_table_name);
        end
       result[#result+1] = ""
       return table.concat(result, "\n")
  ]==]

```

```
    -- miranda: section main
    -- miranda: insert legal preliminaries
    -- miranda: insert luacheck declarations

    local _M = require "kollos.metal"

    -- miranda: insert forward declarations
    -- miranda: insert internal utilities

    -- miranda: insert create metal tables
    -- miranda: insert copy metal tables
    -- miranda: insert create nonmetallic metatables
    -- miranda: insert populate metatables

    -- set up various tables

    -- miranda: insert constant Lua tables
    _M.upvalues.kollos = _M
    _M.defines = {}

    -- miranda: insert create sandbox table

    -- miranda: insert VM utilities
    -- miranda: insert VM operations
    -- miranda: insert VM default operations
    -- miranda: insert grammar Libmarpa wrapper Lua functions
    -- miranda: insert recognizer Libmarpa wrapper Lua functions
    -- miranda: insert valuator Libmarpa wrapper Lua functions
    -- miranda: insert diagnostics
    -- miranda: insert Utilities for semantics
    -- miranda: insert most Lua function definitions
    -- miranda: insert define Lua error codes
    -- miranda: insert define Lua event codes
    -- miranda: insert define Lua step codes
    -- miranda: insert various Kollos Lua defines

    return _M

    -- vim: set expandtab shiftwidth=4:
```

#### Preliminaries to the main code

Licensing, etc.

```

    -- miranda: section legal preliminaries

    -- Copyright 2017 Jeffrey Kegler
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

### The Kollos C code file

```
    -- miranda: section kollos_c
    -- miranda: language c
    -- miranda: insert preliminaries to the c library code

    -- miranda: insert C global constant variables

    -- miranda: insert private error code declarations
    -- miranda: insert define error codes
    -- miranda: insert private event code declarations
    -- miranda: insert define event codes
    -- miranda: insert private step code declarations
    -- miranda: insert define step codes

    -- miranda: insert error object code from okollos.c.lua
    -- miranda: insert base error handlers

    -- miranda: insert utilities from okollos.c.lua
    -- miranda: insert utility function definitions

    -- miranda: insert event related code from okollos.c.lua
    -- miranda: insert step structure code
    -- miranda: insert metatable keys
    -- miranda: insert non-standard wrappers
    -- miranda: insert object userdata gc methods
    -- miranda: insert kollos table methods
    -- miranda: insert class_slr C methods
    -- miranda: insert luaL_Reg definitions
    -- miranda: insert object constructors

    -- miranda: insert standard libmarpa wrappers
    -- miranda: insert define kollos_metal_loader method
    -- miranda: insert lua interpreter management

    -- miranda: insert  external C function definitions
    /* vim: set expandtab shiftwidth=4: */
```

#### Stuff from okollos

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

    -- miranda: section private error code declarations
    /* error codes */

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

    static inline const char *
    error_description_by_code (lua_Integer error_code)
    {
        if (error_code >= LIBMARPA_MIN_ERROR_CODE
            && error_code <= LIBMARPA_MAX_ERROR_CODE) {
            return marpa_error_codes[error_code -
                LIBMARPA_MIN_ERROR_CODE].description;
        }
        if (error_code >= KOLLOS_MIN_ERROR_CODE
            && error_code <= KOLLOS_MAX_ERROR_CODE) {
            return marpa_kollos_error_codes[error_code -
                KOLLOS_MIN_ERROR_CODE].description;
        }
        return (const char *) 0;
    }

    static inline void
    push_error_description_by_code (lua_State * L,
        lua_Integer error_code)
    {
        const char *description =
            error_description_by_code (error_code);
        if (description) {
            marpa_lua_pushstring (L, description);
        } else {
            marpa_lua_pushfstring (L, "Unknown error code (%d)",
                error_code);
        }
    }

    static inline int lca_error_description_by_code(lua_State* L)
    {
       const lua_Integer error_code = marpa_luaL_checkinteger(L, 1);
       if (marpa_lua_isinteger(L, 1)) {
           push_error_description_by_code(L, error_code);
           return 1;
       }
       marpa_luaL_tolstring(L, 1, NULL);
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

    static inline int lca_error_name_by_code(lua_State* L)
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

    static inline int lca_event_description_by_code(lua_State* L)
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

    static inline int lca_event_name_by_code(lua_State* L)
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

```

The metatable for tree ops is actually empty.
The presence or absence of the metatable itself
is used to determine if a table contains a
tree op.

```
    -- miranda: section+ C extern variables
    extern char kollos_tree_op_mt_key;
    -- miranda: section+ metatable keys
    char kollos_tree_op_mt_key;
    -- miranda: section+ set up empty metatables
    /* Set up tree op metatable, initially empty */
    /* tree_op_metatable = {} */
    marpa_lua_newtable (L);
    marpa_lua_pushvalue (L, -1);
    marpa_lua_rawsetp (L, LUA_REGISTRYINDEX, &kollos_tree_op_mt_key);
    /* kollos.mt_tree_op = tree_op_metatable */
    marpa_lua_setfield (L, kollos_table_stack_ix, "mt_tree_op");

```

```

    -- miranda: section+ base error handlers

    /* Leaves the stack as before,
       except with the error object on top */
    static inline void push_error_object(lua_State* L,
        lua_Integer code, const char* details)
    {
       const int error_object_stack_ix = marpa_lua_gettop(L)+1;
       marpa_lua_newtable(L);
       /* [ ..., error_object ] */
       marpa_lua_rawgetp(L, LUA_REGISTRYINDEX, &kollos_X_mt_key);
       /* [ ..., error_object, error_metatable ] */
       marpa_lua_setmetatable(L, error_object_stack_ix);
       /* [ ..., error_object ] */
       marpa_lua_pushinteger(L, code);
       marpa_lua_setfield(L, error_object_stack_ix, "code" );
      if (0) printf ("%s %s %d\n", __PRETTY_FUNCTION__, __FILE__, __LINE__);
      if (0) printf ("%s code = %ld\n", __PRETTY_FUNCTION__, (long)code);
       /* [ ..., error_object ] */

       marpa_luaL_traceback(L, L, NULL, 1);
       marpa_lua_setfield(L, error_object_stack_ix, "where");

       marpa_lua_pushstring(L, details);
       marpa_lua_setfield(L, error_object_stack_ix, "details" );
       /* [ ..., error_object ] */
    }

    -- miranda: section+ base error handlers

    /* grammar wrappers which need to be hand written */

    /* Get the throw flag from a libmarpa_wrapper.
     */
    static int get_throw_flag(lua_State* L, int lmw_stack_ix)
    {
        int result;
        const int base_of_stack = marpa_lua_gettop (L);
        marpa_luaL_checkstack (L, 10, "cannot grow stack");
        marpa_lua_pushvalue (L, lmw_stack_ix);
        if (!marpa_lua_getmetatable (L, lmw_stack_ix))
            goto FAILURE;
        if (marpa_lua_getfield (L, -1, "kollos") != LUA_TTABLE)
            goto FAILURE;
        if (marpa_lua_getfield (L, -1, "throw") != LUA_TBOOLEAN)
            goto FAILURE;
        result = marpa_lua_toboolean (L, -1);
        marpa_lua_settop (L, base_of_stack);
        return result;
      FAILURE:
        push_error_object (L, MARPA_ERR_DEVELOPMENT, "Bad throw flag");
        return marpa_lua_error (L);
    }

    /* Development errors are always thrown.
     */
    static void
    development_error_handle (lua_State * L,
                            const char *details)
    {
      push_error_object(L, MARPA_ERR_DEVELOPMENT, details);
      marpa_lua_pushvalue(L, -1);
      marpa_lua_setfield(L, marpa_lua_upvalueindex(1), "error_object");
      marpa_lua_error(L);
    }

```

Internal errors are those which "should not happen".
Often they were be caused by bugs.
Under the description, an exact and specific description
of the cause is not possible.
Instead,  information pinpointing the location in the
source code is provided.
The "throw" flag is ignored.

```
    -- miranda: section+ base error handlers
    static void
    internal_error_handle (lua_State * L,
                            const char *details,
                            const char *function,
                            const char *file,
                            int line
                            )
    {
      int error_object_ix;
      push_error_object(L, MARPA_ERR_INTERNAL, details);
      error_object_ix = marpa_lua_gettop(L);
      marpa_lua_pushstring(L, function);
      marpa_lua_setfield(L, error_object_ix, "function");
      marpa_lua_pushstring(L, file);
      marpa_lua_setfield(L, error_object_ix, "file");
      marpa_lua_pushinteger(L, line);
      marpa_lua_setfield(L, error_object_ix, "line");
      marpa_lua_pushvalue(L, error_object_ix);
      marpa_lua_setfield(L, marpa_lua_upvalueindex(1), "error_object");
      marpa_lua_error(L);
    }

    static int out_of_memory(lua_State* L) UNUSED;
    static int out_of_memory(lua_State* L) {
        return marpa_luaL_error(L, "Kollos out of memory");
    }

    /* If error is not thrown, it leaves a nil, then
     * the error object, on the stack.
     */
    static int
    libmarpa_error_code_handle (lua_State * L,
                            int lmw_stack_ix,
                            int error_code, const char *details)
    {
      int throw_flag = get_throw_flag(L, lmw_stack_ix);
      if (!throw_flag) {
          marpa_lua_pushnil(L);
      }
      if (0) fprintf (stderr, "%s %s %d\n", __PRETTY_FUNCTION__, __FILE__, __LINE__);
      push_error_object(L, error_code, details);
      if (0) fprintf (stderr, "%s %s %d\n", __PRETTY_FUNCTION__, __FILE__, __LINE__);
      /* [ ..., nil, error_object ] */
      marpa_lua_pushvalue(L, -1);
      marpa_lua_setfield(L, marpa_lua_upvalueindex(1), "error_object");
      if (0) fprintf (stderr, "%s %s %d\n", __PRETTY_FUNCTION__, __FILE__, __LINE__);
      if (throw_flag) return marpa_lua_error(L);
      if (0) fprintf (stderr, "%s %s %d\n", __PRETTY_FUNCTION__, __FILE__, __LINE__);
      return 2;
    }

    /* Handle libmarpa errors in the most usual way.
       Uses 2 positions on the stack, and throws the
       error, if so desired.
       The error may be thrown or not thrown.
       The caller is expected to handle any non-thrown error.
    */
    static int
    libmarpa_error_handle (lua_State * L,
                            int stack_ix, const char *details)
    {
      Marpa_Error_Code error_code;
      Marpa_Grammar *grammar_ud;
      const int base_of_stack = marpa_lua_gettop(L);

      marpa_lua_getfield (L, stack_ix, "lmw_g");
      marpa_lua_getfield (L, -1, "_libmarpa");
      /* [ ..., grammar_ud ] */
      grammar_ud = (Marpa_Grammar *) marpa_lua_touserdata (L, -1);
      marpa_lua_settop(L, base_of_stack);
      error_code = marpa_g_error (*grammar_ud, NULL);
      return libmarpa_error_code_handle(L, stack_ix, error_code, details);
    }

    /* A wrapper for libmarpa_error_handle to conform with the
     * Lua C API.  The only argument must be a Libmarpa wrapper
     * object.  These all define the `lmw_g` field.
     */
    static int
    lca_libmarpa_error(lua_State* L)
    {
       const int lmw_stack_ix = 1;
       const int details_stack_ix = 2;
       const char* details = marpa_lua_tostring (L, details_stack_ix);
       libmarpa_error_handle(L, lmw_stack_ix, details);
       /* Return only the error object,
        * not the nil on the stack
        * below it.
        */
       return 1;
    }

```

Return the current error_description
Lua C API.  The only argument must be a Libmarpa wrapper
object.
All such objects define the `lmw_g` field.
```
    -- miranda: section+ base error handlers

    static int
    lca_libmarpa_error_description(lua_State* L)
    {
        Marpa_Error_Code error_code;
        Marpa_Grammar *grammar_ud;
        const int lmw_stack_ix = 1;

        marpa_lua_getfield (L, lmw_stack_ix, "lmw_g");
        marpa_lua_getfield (L, -1, "_libmarpa");
        grammar_ud = (Marpa_Grammar *) marpa_lua_touserdata (L, -1);
        error_code = marpa_g_error (*grammar_ud, NULL);
        push_error_description_by_code(L, error_code);
        return 1;
    }

```

Return the current error data:
code, mnemonic and description.
Lua C API.  The only argument must be a Libmarpa wrapper
object.
All such objects define the `lmw_g` field.

```
    -- miranda: section+ base error handlers

    static int
    lca_libmarpa_error_code(lua_State* L)
    {
        Marpa_Error_Code error_code;
        Marpa_Grammar *grammar_ud;
        const int lmw_stack_ix = 1;

        marpa_lua_getfield (L, lmw_stack_ix, "lmw_g");
        marpa_lua_getfield (L, -1, "_libmarpa");
        grammar_ud = (Marpa_Grammar *) marpa_lua_touserdata (L, -1);
        error_code = marpa_g_error (*grammar_ud, NULL);
        marpa_lua_pushinteger (L, error_code);
        return 1;
    }

    -- miranda: section+ non-standard wrappers

    /* The C wrapper for Libmarpa event reading.
       It assumes we just want all of them.
     */
    static int lca_grammar_events(lua_State *L)
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
          return libmarpa_error_handle (L, grammar_stack_ix,
                                  "marpa_g_event_count()");
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
                return libmarpa_error_handle (L, grammar_stack_ix,
                                        "marpa_g_event()");
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
    static int lca_grammar_event(lua_State *L)
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
          return libmarpa_error_handle (L, grammar_stack_ix, "marpa_g_event()");
        }
      marpa_lua_pushinteger (L, event_type);
      marpa_lua_pushinteger (L, marpa_g_event_value (&event));
      /* [ grammar_object, grammar_ud, event_type, event_value ] */
      return 2;
    }

`lca_grammar_rule_new` wraps the Libmarpa method `marpa_g_rule_new()`.
If the rule is 7 symbols or fewer, I put it on the stack.  As an old
kernel driver programmer, I was trained to avoid putting even small
arrays on the stack, but one of this size should be safe on anything
close to a modern architecture.

Perhaps I will eventually limit Libmarpa's
rule RHS to 7 symbols, 7 because I can encode dot position in 3 bit.

    -- miranda: section+ non-standard wrappers

    static int lca_grammar_rule_new(lua_State *L)
    {
        Marpa_Grammar g;
        Marpa_Rule_ID result;
        Marpa_Symbol_ID lhs;

        /* [ grammar_object, lhs, rhs ... ] */
        const int grammar_stack_ix = 1;
        const int args_stack_ix = 2;
        /* 7 should be enough, almost always */
        const int rhs_buffer_size = 7;
        Marpa_Symbol_ID rhs_buffer[rhs_buffer_size];
        Marpa_Symbol_ID *rhs;
        int overflow = 0;
        lua_Integer arg_count;
        lua_Integer table_ix;

        /* This will not be an external interface,
         * so eventually we will run unsafe.
         * This checking code is for debugging.
         */
        marpa_luaL_checktype(L, grammar_stack_ix, LUA_TTABLE);
        marpa_luaL_checktype(L, args_stack_ix, LUA_TTABLE);

        marpa_lua_len(L, args_stack_ix);
        arg_count = marpa_lua_tointeger(L, -1);
        if (arg_count > 1<<30) {
            marpa_luaL_error(L,
                "grammar:rule_new() arg table length too long");
        }
        if (arg_count < 1) {
            marpa_luaL_error(L,
                "grammar:rule_new() arg table length must be at least 1");
        }

        /* arg_count - 2 == rhs_ix
         * For example, arg_count of 3, has one arg for LHS,
         * and 2 for RHS, so max rhs_ix == 1
         */
        if (((size_t)arg_count - 2) >= (sizeof(rhs_buffer)/sizeof(*rhs_buffer))) {
           /* Treat "overflow" arg counts as freaks.
            * We do not optimize for them, but do a custom
            * malloc/free pair for each.
            */
           rhs = malloc(sizeof(Marpa_Symbol_ID) * (size_t)arg_count);
           overflow = 1;
        } else {
           rhs = rhs_buffer;
        }

        marpa_lua_geti(L, args_stack_ix, 1);
        lhs = (Marpa_Symbol_ID)marpa_lua_tointeger(L, -1);
        for (table_ix = 2; table_ix <= arg_count; table_ix++)
        {
            /* Calculated as above */
            const int rhs_ix = (int)table_ix - 2;
            marpa_lua_geti(L, args_stack_ix, table_ix);
            rhs[rhs_ix] = (Marpa_Symbol_ID)marpa_lua_tointeger(L, -1);
            marpa_lua_settop(L, args_stack_ix);
        }

        marpa_lua_getfield (L, grammar_stack_ix, "_libmarpa");
        /* [ grammar_object, grammar_ud ] */
        g = *(Marpa_Grammar *) marpa_lua_touserdata (L, -1);

        result = (Marpa_Rule_ID)marpa_g_rule_new(g, lhs, rhs, ((int)arg_count - 1));
        if (overflow) free(rhs);
        if (result <= -1) return libmarpa_error_handle (L, grammar_stack_ix,
                                "marpa_g_rule_new()");
        marpa_lua_pushinteger(L, (lua_Integer)result);
        return 1;
    }

`lca_grammar_sequence_new` wraps the Libmarpa method `marpa_g_sequence_new()`.
If the rule is 7 symbols or fewer, I put it on the stack.  As an old
kernel driver programmer, I was trained to avoid putting even small
arrays on the stack, but one of this size should be safe on anything
like close to a modern architecture.

Perhaps I will eventually limit Libmarpa's
rule RHS to 7 symbols, 7 because I can encode dot position in 3 bit.

    -- miranda: section+ non-standard wrappers

    static int lca_grammar_sequence_new(lua_State *L)
    {
        Marpa_Grammar *p_g;
        Marpa_Rule_ID result;
        lua_Integer lhs = -1;
        lua_Integer rhs = -1;
        lua_Integer separator = -1;
        lua_Integer min = 1;
        int proper = 0;
        const int grammar_stack_ix = 1;
        const int args_stack_ix = 2;

        marpa_luaL_checktype (L, grammar_stack_ix, LUA_TTABLE);
        marpa_luaL_checktype (L, args_stack_ix, LUA_TTABLE);

        marpa_lua_pushnil (L);
        /* [ ..., nil ] */
        while (marpa_lua_next (L, args_stack_ix)) {
            /* [ ..., key, value ] */
            const char *string_key;
            const int value_stack_ix = marpa_lua_gettop (L);
            const int key_stack_ix = value_stack_ix - 1;
            int is_int = 0;
            switch (marpa_lua_type (L, key_stack_ix)) {

            case LUA_TSTRING:      /* strings */
                /* lua_tostring() is safe because arg is always a string */
                string_key = marpa_lua_tostring (L, key_stack_ix);
                if (!strcmp (string_key, "min")) {
                    min = marpa_lua_tointegerx (L, value_stack_ix, &is_int);
                    if (!is_int) {
                        return marpa_luaL_error (L,
                            "grammar:sequence_new() value of 'min' must be numeric");
                    }
                    goto NEXT_ELEMENT;
                }
                if (!strcmp (string_key, "eager")) {
                    goto NEXT_ELEMENT;
                }
                if (!strcmp (string_key, "proper")) {
                    proper = marpa_lua_toboolean (L, value_stack_ix);
                    goto NEXT_ELEMENT;
                }
                if (!strcmp (string_key, "separator")) {
                    separator =
                        marpa_lua_tointegerx (L, value_stack_ix, &is_int);
                    if (!is_int) {
                        return marpa_luaL_error (L,
                            "grammar:sequence_new() value of 'separator' must be a symbol ID");
                    }
                    goto NEXT_ELEMENT;
                }
                if (!strcmp (string_key, "lhs")) {
                    lhs = marpa_lua_tointegerx (L, value_stack_ix, &is_int);
                    if (!is_int || lhs < 0) {
                        return marpa_luaL_error (L,
                            "grammar:sequence_new() LHS must be a valid symbol ID");
                    }
                    goto NEXT_ELEMENT;
                }
                if (!strcmp (string_key, "rhs")) {
                    rhs = marpa_lua_tointegerx (L, value_stack_ix, &is_int);
                    if (!is_int || rhs < 0) {
                        return marpa_luaL_error (L,
                            "grammar:sequence_new() RHS must be a valid symbol ID");
                    }
                    goto NEXT_ELEMENT;
                }
                return marpa_luaL_error (L,
                    "grammar:sequence_new() bad string key (%s) in arg table",
                    string_key);

            default:               /* other values */
                return marpa_luaL_error (L,
                    "grammar:sequence_new() bad key type (%s) in arg table",
                    marpa_lua_typename (L, marpa_lua_type (L, key_stack_ix))
                    );

            }

          NEXT_ELEMENT:

            /* [ ..., key, value, key_copy ] */
            marpa_lua_settop (L, key_stack_ix);
            /* [ ..., key ] */
        }


        if (lhs < 0) {
            return marpa_luaL_error (L,
                "grammar:sequence_new(): LHS argument is missing");
        }
        if (rhs < 0) {
            return marpa_luaL_error (L,
                "grammar:sequence_new(): RHS argument is missing");
        }

        marpa_lua_getfield (L, grammar_stack_ix, "_libmarpa");
        p_g = (Marpa_Grammar *) marpa_lua_touserdata (L, -1);

        result =
            (Marpa_Rule_ID) marpa_g_sequence_new (*p_g,
            (Marpa_Symbol_ID) lhs,
            (Marpa_Symbol_ID) rhs,
            (Marpa_Symbol_ID) separator,
            (int) min, (proper ? MARPA_PROPER_SEPARATION : 0)
            );
        if (result <= -1)
            return libmarpa_error_handle (L, grammar_stack_ix,
                "marpa_g_rule_new()");
        marpa_lua_pushinteger (L, (lua_Integer) result);
        return 1;
    }

    static int lca_grammar_precompute(lua_State *L)
    {
        Marpa_Grammar self;
        const int self_stack_ix = 1;
        int highest_symbol_id;
        int result;

        if (1) {
            marpa_luaL_checktype (L, self_stack_ix, LUA_TTABLE);
        }
        marpa_lua_getfield (L, -1, "_libmarpa");
        self = *(Marpa_Grammar *) marpa_lua_touserdata (L, -1);
        marpa_lua_pop (L, 1);
        result = (int) marpa_g_precompute (self);
        if (result == -1) {
            marpa_lua_pushnil (L);
            return 1;
        }
        if (result < -1) {
            return libmarpa_error_handle (L, self_stack_ix,
                "grammar:precompute; marpa_g_precompute");
        }

        highest_symbol_id = marpa_g_highest_symbol_id (self);
        if (highest_symbol_id < 0) {
            return libmarpa_error_handle (L, self_stack_ix,
                "grammar:precompute; marpa_g_highest_symbol_id");
            return 1;
        }

        if (0) {
            printf ("%s %s %d\n", __PRETTY_FUNCTION__, __FILE__, __LINE__);
            printf ("About to resize buffer to %ld", (long) ( highest_symbol_id+1));
        }

        (void)kollos_shared_buffer_resize(L, (size_t) highest_symbol_id+1);
        marpa_lua_pushinteger (L, (lua_Integer) result);
        return 1;
    }

    /* -1 is a valid result, so ahm_position() is a special case */
    static int lca_grammar_ahm_position(lua_State *L)
    {
        Marpa_Grammar self;
        const int self_stack_ix = 1;
        Marpa_AHM_ID item_id;
        int result;

        if (1) {
            marpa_luaL_checktype (L, self_stack_ix, LUA_TTABLE);
            marpa_luaL_checkinteger (L, 2);
        }
        {
            const lua_Integer this_arg = marpa_lua_tointeger (L, -1);
            marpa_luaL_argcheck (L, (-(1 << 30) <= this_arg
                    && this_arg <= (1 << 30)), -1, "argument out of range");
            item_id = (Marpa_AHM_ID) this_arg;
            marpa_lua_pop (L, 1);
        }
        marpa_lua_getfield (L, -1, "_libmarpa");
        self = *(Marpa_Grammar *) marpa_lua_touserdata (L, -1);
        marpa_lua_pop (L, 1);
        result = (int) _marpa_g_ahm_position (self, item_id);
        if (result < -1) {
            return libmarpa_error_handle (L, self_stack_ix,
                "lca_grammar_ahm_position()");
        }
        marpa_lua_pushinteger (L, (lua_Integer) result);
        return 1;
    }

    -- miranda: section+ luaL_Reg definitions

    static const struct luaL_Reg grammar_methods[] = {
      { "error", lca_libmarpa_error },
      { "error_code", lca_libmarpa_error_code },
      { "error_description", lca_libmarpa_error_description },
      { "events", lca_grammar_events },
      { "precompute", lca_grammar_precompute },
      { "rule_new", lca_grammar_rule_new },
      { "sequence_new", lca_grammar_sequence_new },
      { "_ahm_position", lca_grammar_ahm_position },
      { NULL, NULL },
    };

    -- miranda: section+ non-standard wrappers

    static int lca_recce_look_yim(lua_State *L)
    {
        const int recce_stack_ix = 1;
        Marpa_Recce r;
        Marpa_Grammar g;
        Marpa_Earley_Item_Look look;
        Marpa_Earley_Set_ID es_id;
        Marpa_Earley_Item_ID eim_id;
        int check_result;

        marpa_lua_getfield (L, recce_stack_ix, "_libmarpa");
        r = *(Marpa_Recce *) marpa_lua_touserdata (L, -1);
        marpa_lua_getfield (L, recce_stack_ix, "lmw_g");
        if (0) fprintf (stderr, "%s %s %d tos=%s\n", __PRETTY_FUNCTION__, __FILE__, __LINE__, marpa_luaL_typename(L, -1));
        marpa_lua_getfield (L, -1, "_libmarpa");
        g = *(Marpa_Grammar *) marpa_lua_touserdata (L, -1);
        es_id = (Marpa_Earley_Set_ID)marpa_luaL_checkinteger (L, 2);
        eim_id = (Marpa_Earley_Item_ID)marpa_luaL_checkinteger (L, 3);
        check_result = _marpa_r_yim_check(r, es_id, eim_id);
        if (check_result <= -2) {
           return libmarpa_error_handle (L, recce_stack_ix, "recce:progress_item()");
        }
        if (check_result == 0) {
            marpa_lua_pushnil(L);
            return 1;
        }
        if (check_result == -1) {
            return marpa_luaL_error(L, "yim_look(%d, %d): No such earley set",
                es_id, eim_id);
        }
        (void) _marpa_r_look_yim(r, &look, es_id, eim_id);
        /* The "raw xrl dot" is a development hack to test a fix
         * to the xrl dot value.
         * TODO -- Delete after development.
         */
        {
            const lua_Integer raw_xrl_dot = (lua_Integer)marpa_eim_look_dot(&look);
            lua_Integer xrl_dot = raw_xrl_dot;
            const lua_Integer irl_dot = (lua_Integer)marpa_eim_look_irl_dot(&look);
            const lua_Integer irl_id = marpa_eim_look_irl_id(&look);
            if (0) fprintf (stderr, "%s %s %d; xrl dot = %ld; irl dot = %ld; irl length = %ld\n", __PRETTY_FUNCTION__, __FILE__, __LINE__,
                (long)xrl_dot,
                (long)irl_dot,
                (long)_marpa_g_irl_length(g, (Marpa_IRL_ID)irl_id));
            if (irl_dot < 0) {
                xrl_dot = -1;
            }
            if (irl_dot >= (lua_Integer)_marpa_g_irl_length(g, (Marpa_IRL_ID)irl_id)) {
                xrl_dot = -1;
            }
            marpa_lua_pushinteger(L, (lua_Integer)marpa_eim_look_rule_id(&look));
            marpa_lua_pushinteger(L, xrl_dot);
            marpa_lua_pushinteger(L, (lua_Integer)marpa_eim_look_origin(&look));
            marpa_lua_pushinteger(L, irl_id);
            marpa_lua_pushinteger(L, irl_dot);
        }
        return 5;
    }

```

For an Earley set, call it `es`,
and an internal symbol, call it `sym`,
`lca_recce_postdot_eims` returns
a sequence containing
the Earley items in `es` whose
postdot symbol is `sym`.
If there are none, an empty table
is returned.

```
    -- miranda: section+ non-standard wrappers
    static int lca_recce_postdot_eims(lua_State *L)
    {
        const int recce_stack_ix = 1;
        Marpa_Recce r;
        Marpa_Postdot_Item_Look look;
        Marpa_Earley_Set_ID es_id;
        Marpa_Symbol_ID isy_id;
        int check_result;
        int table_ix;
        int eim_index;

        marpa_lua_getfield (L, recce_stack_ix, "_libmarpa");
        r = *(Marpa_Recce *) marpa_lua_touserdata (L, -1);
        es_id = (Marpa_Earley_Set_ID) marpa_luaL_checkinteger (L, 2);
        isy_id = (Marpa_Symbol_ID) marpa_luaL_checkinteger (L, 3);
        /* Every Earley set should contain an EIM #0 */
        check_result = _marpa_r_yim_check (r, es_id, 0);
        if (check_result <= -2) {
            return libmarpa_error_handle (L, recce_stack_ix,
                "recce:postdot_eims()");
        }
        if (check_result == 0) {
            marpa_lua_pushnil (L);
            return 1;
        }
        if (check_result == -1) {
            return marpa_luaL_error (L, "yim_look(%d, %d): No such earley set",
                es_id, 0);
        }
        marpa_lua_newtable (L);
        table_ix = 1;
        eim_index = _marpa_r_look_pim_eim_first (r, &look, es_id, isy_id);
        if (0) fprintf (stderr, "%s %s %d eim_index=%ld\n", __PRETTY_FUNCTION__, __FILE__, __LINE__, (long)eim_index);
        while (eim_index >= 0) {
            marpa_lua_pushinteger (L, (lua_Integer) eim_index);
            marpa_lua_rawseti (L, -2, table_ix);
            table_ix++;
            eim_index = _marpa_r_look_pim_eim_next (&look);
            if (0) fprintf (stderr, "%s %s %d eim_index=%ld\n", __PRETTY_FUNCTION__, __FILE__, __LINE__, (long)eim_index);
            if (0) fprintf (stderr, "%s %s %d tos=%ld\n", __PRETTY_FUNCTION__, __FILE__, __LINE__, (long)marpa_lua_gettop(L));
        }
        return 1;
    }

```

```
    -- miranda: section+ non-standard wrappers
    static int lca_recce_progress_item(lua_State *L)
    {
      /* [ recce_object ] */
      const int recce_stack_ix = 1;
      Marpa_Recce r;
      Marpa_Earley_Set_ID origin;
      int position;
      Marpa_Rule_ID rule_id;

      marpa_lua_getfield (L, recce_stack_ix, "_libmarpa");
      /* [ recce_object, recce_ud ] */
      r = *(Marpa_Recce *) marpa_lua_touserdata (L, -1);
      rule_id = marpa_r_progress_item (r, &position, &origin);
      if (rule_id < -1)
        {
          return libmarpa_error_handle (L, recce_stack_ix, "recce:progress_item()");
        }
      if (rule_id == -1)
        {
          return 0;
        }
      marpa_lua_pushinteger (L, (lua_Integer) rule_id);
      marpa_lua_pushinteger (L, (lua_Integer) position);
      marpa_lua_pushinteger (L, (lua_Integer) origin);
      return 3;
    }

    static int lca_recce_terminals_expected( lua_State *L )
    {
      /* [ recce_object ] */
      const int recce_stack_ix = 1;
      int count;
      int ix;
      Marpa_Recce r;

      /* The shared buffer is guaranteed to have space for all the symbol IDS
       * of the grammar.
       */
      Marpa_Symbol_ID* const buffer = shared_buffer_get(L);

      marpa_lua_getfield (L, recce_stack_ix, "_libmarpa");
      /* [ recce_object, recce_ud ] */
      r = *(Marpa_Recce *) marpa_lua_touserdata (L, -1);

      count = marpa_r_terminals_expected (r, buffer);
      if (count < 0) {
          return libmarpa_error_handle(L, recce_stack_ix, "grammar:terminals_expected; marpa_r_terminals_expected");
      }
      marpa_lua_newtable(L);
      for (ix = 0; ix < count; ix++) {
          marpa_lua_pushinteger(L, buffer[ix]);
          marpa_lua_rawseti(L, -2, ix+1);
      }
      return 1;
    }

    /* special-cased because two return values */
    static int lca_recce_source_token( lua_State *L )
    {
      Marpa_Recognizer self;
      const int self_stack_ix = 1;
      int result;
      int value;

      if (1) {
        marpa_luaL_checktype(L, self_stack_ix, LUA_TTABLE);  }
      marpa_lua_getfield (L, -1, "_libmarpa");
      self = *(Marpa_Recognizer*)marpa_lua_touserdata (L, -1);
      marpa_lua_pop(L, 1);
      result = (int)_marpa_r_source_token(self, &value);
      if (result == -1) { marpa_lua_pushnil(L); return 1; }
      if (result < -1) {
       return libmarpa_error_handle(L, self_stack_ix, "lca_recce_source_token()");
      }
      marpa_lua_pushinteger(L, (lua_Integer)result);
      marpa_lua_pushinteger(L, (lua_Integer)value);
      return 2;
    }

    -- miranda: section+ luaL_Reg definitions

    static const struct luaL_Reg recce_methods[] = {
      { "error", lca_libmarpa_error },
      { "error_code", lca_libmarpa_error_code },
      { "error_description", lca_libmarpa_error_description },
      { "terminals_expected", lca_recce_terminals_expected },
      { "earley_item_look", lca_recce_look_yim },
      { "postdot_eims", lca_recce_postdot_eims },
      { "progress_item", lca_recce_progress_item },
      { "_source_token", lca_recce_source_token },
      { NULL, NULL },
    };

    -- miranda: section+ luaL_Reg definitions

    static const struct luaL_Reg bocage_methods[] = {
      { "error", lca_libmarpa_error },
      { "error_code", lca_libmarpa_error_code },
      { "error_description", lca_libmarpa_error_description },
      { NULL, NULL },
    };

    /* order wrappers which need to be hand-written */

    -- miranda: section+ luaL_Reg definitions

    static const struct luaL_Reg order_methods[] = {
      { "error", lca_libmarpa_error },
      { "error_code", lca_libmarpa_error_code },
      { "error_description", lca_libmarpa_error_description },
      { NULL, NULL },
    };

    -- miranda: section+ luaL_Reg definitions

    static const struct luaL_Reg tree_methods[] = {
      { "error", lca_libmarpa_error },
      { "error_code", lca_libmarpa_error_code },
      { "error_description", lca_libmarpa_error_description },
      { NULL, NULL },
    };

    /* value wrappers which need to be hand-written */

    -- miranda: section+ non-standard wrappers

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
          return libmarpa_error_handle (L, value_stack_ix, "marpa_v_step()");
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

    /* Returns ok, result,
     * where ok is a boolean and
     * on failure, result is an error object, while
     * on success, result is an table
     */
    static int
    wrap_v_location (lua_State * L)
    {
      Marpa_Value v;
      Marpa_Step_Type step_type;
      const int value_stack_ix = 1;

      marpa_luaL_checktype (L, value_stack_ix, LUA_TTABLE);

      marpa_lua_getfield (L, value_stack_ix, "_libmarpa");
      /* [ value_table, value_ud ] */
      v = *(Marpa_Value *) marpa_lua_touserdata (L, -1);
      step_type = marpa_v_step_type (v);

      if (0) printf("%s %s %d\n", __PRETTY_FUNCTION__, __FILE__, __LINE__);

      switch(step_type) {
      case MARPA_STEP_RULE:
          marpa_lua_pushinteger(L, marpa_v_rule_start_es_id (v));
          marpa_lua_pushinteger(L, marpa_v_es_id (v));
          return 2;
      case MARPA_STEP_NULLING_SYMBOL:
          marpa_lua_pushinteger(L, marpa_v_token_start_es_id (v));
          marpa_lua_pushinteger(L, marpa_v_es_id (v));
          return 2;
      case MARPA_STEP_TOKEN:
          marpa_lua_pushinteger(L, marpa_v_token_start_es_id (v));
          marpa_lua_pushinteger(L, marpa_v_es_id (v));
          return 2;
      }
      return 0;
    }

    -- miranda: section+ luaL_Reg definitions

    static const struct luaL_Reg value_methods[] = {
      { "location", wrap_v_location },
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

#### Kollos metal loader

To make this a real module, this fuction must be named "luaopen_kollos_metal".
The LUAOPEN_KOLLOS_METAL define allows us to override this for a declaration
compatible with static loading and namespace requirements like those of
Marpa::R3.

```
    -- miranda: section+ C function declarations
    #if !defined(LUAOPEN_KOLLOS_METAL)
    #define LUAOPEN_KOLLOS_METAL luaopen_kollos_metal
    #endif
    int LUAOPEN_KOLLOS_METAL(lua_State *L);
    -- miranda: section define kollos_metal_loader method
    int LUAOPEN_KOLLOS_METAL(lua_State *L)
    {
        /* The main kollos object */
        int kollos_table_stack_ix;
        int upvalue_stack_ix;

        /* Make sure the header is from the version we want */
        if (MARPA_MAJOR_VERSION != EXPECTED_LIBMARPA_MAJOR ||
            MARPA_MINOR_VERSION != EXPECTED_LIBMARPA_MINOR ||
            MARPA_MICRO_VERSION != EXPECTED_LIBMARPA_MICRO) {
            const char *message;
            marpa_lua_pushfstring
                (L,
                "Libmarpa header version mismatch: want %ld.%ld.%ld, have %ld.%ld.%ld",
                EXPECTED_LIBMARPA_MAJOR, EXPECTED_LIBMARPA_MINOR,
                EXPECTED_LIBMARPA_MICRO, MARPA_MAJOR_VERSION,
                MARPA_MINOR_VERSION, MARPA_MICRO_VERSION);
            message = marpa_lua_tostring (L, -1);
            internal_error_handle (L, message,
                __PRETTY_FUNCTION__, __FILE__, __LINE__);
        }

        /* Now make sure the library is from the version we want */
        {
            int version[3];
            const Marpa_Error_Code error_code = marpa_version (version);
            if (error_code != MARPA_ERR_NONE) {
                const char *description =
                    error_description_by_code (error_code);
                const char *message;
                marpa_lua_pushfstring (L, "marpa_version() failed: %s",
                    description);
                message = marpa_lua_tostring (L, -1);
                internal_error_handle (L, message, __PRETTY_FUNCTION__,
                    __FILE__, __LINE__);
            }
            if (version[0] != EXPECTED_LIBMARPA_MAJOR ||
                version[1] != EXPECTED_LIBMARPA_MINOR ||
                version[2] != EXPECTED_LIBMARPA_MICRO) {
                const char *message;
                marpa_lua_pushfstring
                    (L,
                    "Libmarpa library version mismatch: want %ld.%ld.%ld, have %ld.%ld.%ld",
                    EXPECTED_LIBMARPA_MAJOR, EXPECTED_LIBMARPA_MINOR,
                    EXPECTED_LIBMARPA_MICRO, version[0], version[1],
                    version[2]);
                message = marpa_lua_tostring (L, -1);
                internal_error_handle (L, message, __PRETTY_FUNCTION__,
                    __FILE__, __LINE__);
            }
        }

        /* Create the kollos class */
        marpa_lua_newtable (L);
        kollos_table_stack_ix = marpa_lua_gettop (L);
        /* Create the main kollos_c object, to give the
         * C language Libmarpa wrappers their own namespace.
         *
         */
        /* [ kollos ] */

        /* _M.throw = true */
        marpa_lua_pushboolean (L, 1);
        marpa_lua_setfield (L, kollos_table_stack_ix, "throw");

        /* Create the shared upvalue table */
        {
            /* TODO increase initial buffer capacity
             * after testing.
             */
            const size_t initial_buffer_capacity = 1;
            marpa_lua_newtable (L);
            upvalue_stack_ix = marpa_lua_gettop (L);
            marpa_lua_newuserdata (L,
                sizeof (Marpa_Symbol_ID) * initial_buffer_capacity);
            marpa_lua_setfield (L, upvalue_stack_ix, "buffer");
            marpa_lua_pushinteger (L, (lua_Integer) initial_buffer_capacity);
            marpa_lua_setfield (L, upvalue_stack_ix, "buffer_capacity");
        }

        /* Also keep the upvalues in an element of the class */
        marpa_lua_pushvalue (L, upvalue_stack_ix);
        marpa_lua_setfield (L, kollos_table_stack_ix, "upvalues");

        --miranda: insert create kollos libmarpa wrapper class tables

          marpa_lua_pushvalue(L, kollos_table_stack_ix);
          marpa_lua_pushvalue(L, upvalue_stack_ix);
          marpa_luaL_setfuncs(L, kollos_funcs, 1);

          /* Create the SLIF grammar metatable */
          marpa_luaL_newlibtable(L, slg_methods);
          marpa_lua_pushvalue(L, upvalue_stack_ix);
          marpa_luaL_setfuncs(L, slg_methods, 1);
          marpa_lua_pushvalue(L, -1);
          marpa_lua_setfield(L, -2, "__index");
          marpa_lua_pushvalue(L, -1);
          marpa_lua_setfield(L, kollos_table_stack_ix, "class_slg");
          marpa_lua_pushvalue(L, kollos_table_stack_ix);
          marpa_lua_setfield(L, -2, "kollos");

          /* Create the SLIF grammar metatable */
          marpa_luaL_newlibtable(L, slr_methods);
          marpa_lua_pushvalue(L, upvalue_stack_ix);
          marpa_luaL_setfuncs(L, slr_methods, 1);
          marpa_lua_pushvalue(L, -1);
          marpa_lua_setfield(L, -2, "__index");
          marpa_lua_pushvalue(L, -1);
          marpa_lua_setfield(L, kollos_table_stack_ix, "class_slr");
          marpa_lua_pushvalue(L, kollos_table_stack_ix);
          marpa_lua_setfield(L, -2, "kollos");

        /* Set up Kollos grammar userdata metatable */
        marpa_lua_newtable (L);
        /* [ kollos, mt_ud_g ] */
        marpa_lua_pushvalue (L, upvalue_stack_ix);
        marpa_lua_pushcclosure (L, l_grammar_ud_mt_gc, 1);
        /* [ kollos, mt_g_ud, gc_function ] */
        marpa_lua_setfield (L, -2, "__gc");
        /* [ kollos, mt_g_ud ] */
        marpa_lua_rawsetp (L, LUA_REGISTRYINDEX, &kollos_g_ud_mt_key);
        /* [ kollos ] */

        /* Set up Kollos recce userdata metatable */
        marpa_lua_newtable (L);
        /* [ kollos, mt_ud_r ] */
        marpa_lua_pushvalue (L, upvalue_stack_ix);
        marpa_lua_pushcclosure (L, l_recce_ud_mt_gc, 1);
        /* [ kollos, mt_r_ud, gc_function ] */
        marpa_lua_setfield (L, -2, "__gc");
        /* [ kollos, mt_r_ud ] */
        marpa_lua_rawsetp (L, LUA_REGISTRYINDEX, &kollos_r_ud_mt_key);
        /* [ kollos ] */

        /* Set up Kollos bocage userdata metatable */
        marpa_lua_newtable (L);
        /* [ kollos, mt_ud_bocage ] */
        marpa_lua_pushvalue (L, upvalue_stack_ix);
        marpa_lua_pushcclosure (L, l_bocage_ud_mt_gc, 1);
        /* [ kollos, mt_b_ud, gc_function ] */
        marpa_lua_setfield (L, -2, "__gc");
        /* [ kollos, mt_b_ud ] */
        marpa_lua_rawsetp (L, LUA_REGISTRYINDEX, &kollos_b_ud_mt_key);
        /* [ kollos ] */

        /* Set up Kollos order userdata metatable */
        marpa_lua_newtable (L);
        /* [ kollos, mt_ud_order ] */
        marpa_lua_pushvalue (L, upvalue_stack_ix);
        marpa_lua_pushcclosure (L, l_order_ud_mt_gc, 1);
        /* [ kollos, mt_o_ud, gc_function ] */
        marpa_lua_setfield (L, -2, "__gc");
        /* [ kollos, mt_o_ud ] */
        marpa_lua_rawsetp (L, LUA_REGISTRYINDEX, &kollos_o_ud_mt_key);
        /* [ kollos ] */

        /* Set up Kollos tree userdata metatable */
        marpa_lua_newtable (L);
        /* [ kollos, mt_ud_tree ] */
        marpa_lua_pushvalue (L, upvalue_stack_ix);
        marpa_lua_pushcclosure (L, l_tree_ud_mt_gc, 1);
        /* [ kollos, mt_t_ud, gc_function ] */
        marpa_lua_setfield (L, -2, "__gc");
        /* [ kollos, mt_t_ud ] */
        marpa_lua_rawsetp (L, LUA_REGISTRYINDEX, &kollos_t_ud_mt_key);
        /* [ kollos ] */

        /* Set up Kollos value userdata metatable */
        marpa_lua_newtable (L);
        /* [ kollos, mt_ud_value ] */
        marpa_lua_pushvalue (L, upvalue_stack_ix);
        marpa_lua_pushcclosure (L, l_value_ud_mt_gc, 1);
        /* [ kollos, mt_v_ud, gc_function ] */
        marpa_lua_setfield (L, -2, "__gc");
        /* [ kollos, mt_v_ud ] */
        marpa_lua_rawsetp (L, LUA_REGISTRYINDEX, &kollos_v_ud_mt_key);
        /* [ kollos ] */

        -- miranda: insert set up empty metatables

        /* In alphabetical order by field name */

        marpa_lua_pushvalue (L, upvalue_stack_ix);
        marpa_lua_pushcclosure (L, lca_error_description_by_code, 1);
        /* [ kollos, function ] */
        marpa_lua_setfield (L, kollos_table_stack_ix, "error_description");
        /* [ kollos ] */

        marpa_lua_pushvalue (L, upvalue_stack_ix);
        marpa_lua_pushcclosure (L, lca_error_name_by_code, 1);
        marpa_lua_setfield (L, kollos_table_stack_ix, "error_name");

        marpa_lua_pushvalue (L, upvalue_stack_ix);
        marpa_lua_pushcclosure (L, lca_event_name_by_code, 1);
        marpa_lua_setfield (L, kollos_table_stack_ix, "event_name");

        marpa_lua_pushvalue (L, upvalue_stack_ix);
        marpa_lua_pushcclosure (L, lca_event_description_by_code, 1);
        marpa_lua_setfield (L, kollos_table_stack_ix, "event_description");

        /* In Libmarpa object sequence order */

        marpa_lua_pushvalue (L, upvalue_stack_ix);
        marpa_lua_getfield (L, kollos_table_stack_ix, "class_grammar");
        marpa_lua_pushcclosure (L, lca_grammar_new, 2);
        marpa_lua_setfield (L, kollos_table_stack_ix, "grammar_new");

        marpa_lua_pushvalue (L, upvalue_stack_ix);
        marpa_lua_getfield (L, kollos_table_stack_ix, "class_recce");
        marpa_lua_pushcclosure (L, lca_grammar_event, 1);
        marpa_lua_setfield (L, kollos_table_stack_ix, "grammar_event");

        marpa_lua_pushvalue (L, upvalue_stack_ix);
        marpa_lua_getfield (L, kollos_table_stack_ix, "class_recce");
        marpa_lua_pushcclosure (L, wrap_recce_new, 2);
        marpa_lua_setfield (L, kollos_table_stack_ix, "recce_new");

        marpa_lua_pushvalue (L, upvalue_stack_ix);
        marpa_lua_getfield (L, kollos_table_stack_ix, "class_bocage");
        marpa_lua_pushcclosure (L, wrap_bocage_new, 2);
        marpa_lua_setfield (L, kollos_table_stack_ix, "bocage_new");

        marpa_lua_pushvalue (L, upvalue_stack_ix);
        marpa_lua_getfield (L, kollos_table_stack_ix, "class_order");
        marpa_lua_pushcclosure (L, wrap_order_new, 2);
        marpa_lua_setfield (L, kollos_table_stack_ix, "order_new");

        marpa_lua_pushvalue (L, upvalue_stack_ix);
        marpa_lua_getfield (L, kollos_table_stack_ix, "class_tree");
        marpa_lua_pushcclosure (L, wrap_tree_new, 2);
        marpa_lua_setfield (L, kollos_table_stack_ix, "tree_new");

        marpa_lua_pushvalue (L, upvalue_stack_ix);
        marpa_lua_getfield (L, kollos_table_stack_ix, "class_value");
        marpa_lua_pushcclosure (L, wrap_value_new, 2);
        marpa_lua_setfield (L, kollos_table_stack_ix, "value_new");

        marpa_lua_newtable (L);
        /* [ kollos, error_code_table ] */
        {
            const int name_table_stack_ix = marpa_lua_gettop (L);
            int error_code;
            for (error_code = LIBMARPA_MIN_ERROR_CODE;
                error_code <= LIBMARPA_MAX_ERROR_CODE; error_code++) {
                marpa_lua_pushinteger (L, (lua_Integer) error_code);
                marpa_lua_setfield (L, name_table_stack_ix,
                    marpa_error_codes[error_code -
                        LIBMARPA_MIN_ERROR_CODE].mnemonic);
            }
            for (error_code = KOLLOS_MIN_ERROR_CODE;
                error_code <= KOLLOS_MAX_ERROR_CODE; error_code++) {
                marpa_lua_pushinteger (L, (lua_Integer) error_code);
                marpa_lua_setfield (L, name_table_stack_ix,
                    marpa_kollos_error_codes[error_code -
                        KOLLOS_MIN_ERROR_CODE].mnemonic);
            }
        }

        /* [ kollos, error_code_table ] */
        marpa_lua_setfield (L, kollos_table_stack_ix, "error_code_by_name");

        marpa_lua_newtable (L);
        /* [ kollos, event_code_table ] */
        {
            const int name_table_stack_ix = marpa_lua_gettop (L);
            int event_code;
            for (event_code = LIBMARPA_MIN_EVENT_CODE;
                event_code <= LIBMARPA_MAX_EVENT_CODE; event_code++) {
                marpa_lua_pushinteger (L, (lua_Integer) event_code);
                marpa_lua_setfield (L, name_table_stack_ix,
                    marpa_event_codes[event_code -
                        LIBMARPA_MIN_EVENT_CODE].mnemonic);
            }
        }

        /* [ kollos, event_code_table ] */
        marpa_lua_setfield (L, kollos_table_stack_ix, "event_code_by_name");

        -- miranda: insert register standard libmarpa wrappers

            /* [ kollos ] */

        -- miranda: insert create tree export operations

        marpa_lua_settop (L, kollos_table_stack_ix);
        /* [ kollos ] */
        return 1;
    }

```

#### Preliminaries to the C library code
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
    #define EXPECTED_LIBMARPA_MINOR 6
    #define EXPECTED_LIBMARPA_MICRO 0

```

### The Kollos C header file

```
    -- miranda: section kollos_h
    -- miranda: language c
    -- miranda: insert preliminary comments of the c header file

    #ifndef KOLLOS_H
    #define KOLLOS_H

    #include "lua.h"
    #include "lauxlib.h"
    #include "lualib.h"

    -- miranda: insert temporary defines
    -- miranda: insert C extern variables
    -- miranda: insert C function declarations

    #endif

    /* vim: set expandtab shiftwidth=4: */
```

#### Preliminaries to the C header file
```
    -- miranda: section preliminary comments of the c header file

    /*
     * Copyright 2017 Jeffrey Kegler
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

## Internal utilities

Utilities used internally by Kollos and not visible to
Kollos users.

"Declare" the fields allowed in a table.
A variation on the `strict.lua` module, which
requires the fields to be declared in advance.
This is very helpful in development.

TODO -- Do I want to turn this off after developement?

```
    -- miranda: section+ internal utilities
    local function declarations(table, fields, name)
        table.__declared = fields

        table.__newindex = function (t, n, v)
          if not table.__declared[n] then
            error(
                "assign to undeclared member '"
                ..name
                .."."
                ..n
                .."'",
                2)
          end
          rawset(t, n, v)
        end

        table.__index = function (t, n)
          local v = rawget(t, n) or table[n]
          if v == nil and not table.__declared[n] then
            error(string.format(
                "member %s.%s is not declared",
                name, n),
            2)
          end
          return v
        end
    end
```

This is
an exported internal, at least for now, so
that code inlined in Perl can use it.

```
    -- miranda: section+ internal utilities
    function _M._internal_error(...)
        error("Kollos internal error: "
            .. string.format(...))
    end
```

Eventually make this local.
Right now it's a static class method,
so that it can be used from the Lua inlined
in the Perl code.

Compares two sequences.
They must have the same length,
and every element at a given index
in one sequence must be comparable
to every elememt at the same index
in every other sequence.

```
    -- miranda: section+ internal utilities
    function _M.cmp_seq(i, j)
        for ix = 1, #i do
            if i[ix] < j[ix] then return true end
            if i[ix] > j[ix] then return false end
        end
        return false
    end
```

### Coroutines

We use coroutines as "better callbacks".
They allow the upper layer to be called upon for processing
at any point in Kollos's Lua layers.
At this point, we allow the upper layers only one active coroutine
(though it may have child coroutines).
Also, this "upper layer child coroutine" must be run until
it returns before other processing is performed.
Obeying this constraint is currently up to the upper layer --
nothing in the code enforces it.

```
    -- miranda: section+ most Lua function definitions
    function _M.wrap(f)
        if _M.current_coro then
           -- error('Attempt to overwrite active Kollos coro')
        end
        _M.current_coro = coroutine.wrap(f)
    end

    function _M.resume(...)
        local coro = _M.current_coro
        if not coro then
           error('Attempt to resume non-existent Kollos coro')
        end
        local retours = {coro(...)}
        local cmd = table.remove(retours, 1)
        if not cmd or cmd == '' or cmd == 'ok' then
            cmd = false
            _M.current_coro = nil
        end
        return cmd, retours
    end
```

## Exceptions

```
    -- miranda: section+ C extern variables
    extern char kollos_X_fallback_mt_key;
    extern char kollos_X_proto_asis_mt_key;
    extern char kollos_X_proto_mt_key;
    extern char kollos_X_mt_key;
    -- miranda: section+ metatable keys
    char kollos_X_fallback_mt_key;
    char kollos_X_proto_asis_mt_key;
    char kollos_X_proto_mt_key;
    char kollos_X_mt_key;
    -- miranda: section+ set up empty metatables

    /* mt_X_fallback = {} */
    marpa_lua_newtable (L);
    marpa_lua_pushvalue (L, -1);
    marpa_lua_rawsetp (L, LUA_REGISTRYINDEX, &kollos_X_fallback_mt_key);
    /* kollos.mt_X_fallback = mt_X_fallback */
    marpa_lua_setfield (L, kollos_table_stack_ix, "mt_X_fallback");

    /* mt_X_proto = {} */
    marpa_lua_newtable (L);
    marpa_lua_pushvalue (L, -1);
    marpa_lua_rawsetp (L, LUA_REGISTRYINDEX, &kollos_X_proto_mt_key);
    /* kollos.mt_X_proto = mt_X_proto */
    marpa_lua_setfield (L, kollos_table_stack_ix, "mt_X_proto");

    /* mt_X_proto_asis = {} */
    marpa_lua_newtable (L);
    marpa_lua_pushvalue (L, -1);
    marpa_lua_rawsetp (L, LUA_REGISTRYINDEX, &kollos_X_proto_asis_mt_key);
    /* kollos.mt_X_proto_asis = mt_X_proto_asis */
    marpa_lua_setfield (L, kollos_table_stack_ix, "mt_X_proto_asis");

    /* Set up exception metatables, initially empty */
    /* mt_X = {} */
    marpa_lua_newtable (L);
    marpa_lua_pushvalue (L, -1);
    marpa_lua_rawsetp (L, LUA_REGISTRYINDEX, &kollos_X_mt_key);
    /* kollos.mt_X = mt_X */
    marpa_lua_setfield (L, kollos_table_stack_ix, "mt_X");

```

The "fallback" for converting an exception is make it part
of a table with a fallback __tostring method, which uses the
inspect package to dump it.

```
    -- miranda: section+ populate metatables

    -- `inspect` is used in our __tostring methods, but
    -- it also calls __tostring.  This global is used to
    -- prevent any recursive calls.
    _M.recursive_tostring = false

    local function X_fallback_tostring(self)
         -- print("in X_fallback_tostring")
         local desc
         if _M.recursive_tostring then
             desc = '[Recursive call of inspect]'
         else
             _M.recursive_tostring = 'X_fallback_tostring'
             desc = inspect(self, { depth = 3 })
             _M.recursive_tostring = false
         end
         local nl = ''
         local where = ''
         if type(self) == 'table' then
             local where = self.where
             if where and desc:sub(-1) ~= '\n' then
                 nl = '\n'
             end
         end
         local traceback = debug.traceback("Kollos internal error: bad exception object")
         return desc .. nl .. where .. '\n' .. traceback
    end

    local function X_tostring(self)
         -- print("in X_tostring")
         if type(self) ~= 'table' then
              return X_fallback_tostring(self)
         end
         local desc = self.msg
         local desc_type = type(desc)
         if desc_type == "string" then
             local nl = ''
             local where = self.where
             if where then
                 if desc:sub(-1) ~= '\n' then nl = '\n' end
             else
                 where = ''
             end
             return desc .. nl .. where
         end

         -- no `msg` so look for a code
         local error_code = self.code
         if error_code then
              local description = _M.error_description(error_code)
              local details = self.details
              local pieces = {}
              if details then
                  pieces[#pieces+1] = details
                  pieces[#pieces+1] = ': '
              end
              pieces[#pieces+1] = description
              local where = self.where
              if where then
                  pieces[#pieces+1] = '\n'
                  pieces[#pieces+1] = where
              end
              return table.concat(pieces)
         end

         -- no `msg` or `code` so we fall back
         return X_fallback_tostring(self)
    end

    local function error_tostring(self)
         print("Calling error_tostring")
         return '[error_tostring]'
    end

    _M.mt_X.__tostring = X_tostring
    _M.mt_X_proto.__tostring = X_tostring
    _M.mt_X_proto_asis.__tostring = X_tostring
    _M.mt_X_fallback.__tostring = X_fallback_tostring

```

A function to throw exceptions which do not carry a
traceback.  This is for "user" errors, where "user"
means the error can be explained in user-friendly terms
and things like stack traces are unnecessary.
(These errors are also usually "user" errors in the sense
that the user caused them,
but that is not necessarily the case.)

```
    -- miranda: section+ most Lua function definitions
    function _M.userX(msg)
        local X = { msg = msg, traceback = false }
        setmetatable(X, _M.mt_X)
        error(X)
    end
```

## Meta-coding

### Metacode execution sequence

```
    -- miranda: sequence-exec argument processing
    -- miranda: sequence-exec metacode utilities
    -- miranda: sequence-exec libmarpa interface globals
    -- miranda: sequence-exec declare standard libmarpa wrappers
    -- miranda: sequence-exec register standard libmarpa wrappers
    -- miranda: sequence-exec create kollos libmarpa wrapper class tables
    -- miranda: sequence-exec object userdata gc methods
    -- miranda: sequence-exec create metal tables
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
        s = string.gsub(s, '\n', '\\n')
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

## Kollos non-locals

### Create a sandbox

Create a table, which can be used
as a "sandbox" for protect the global environment
from user code.
This code only creates the sandbox, it does not
set it as an environment -- it is assumed that
that will be done later,
after to-be-sandboxed Lua code is loaded,
but before it is executed.

```
    -- miranda: section create sandbox table

    local sandbox = {}
    _M.sandbox = sandbox
    sandbox.__index = _G
    setmetatable(sandbox, sandbox)

```

### Constants: Ranking methods

```
    -- miranda: section+ constant Lua tables
    _M.ranking_methods = { none = true, high_rule_only = true, rule = true }
```

## Kollos utilities

```
    -- miranda: section+ most Lua function definitions
    function _M.posix_lc(str)
       return str:gsub('[A-Z]', function(str) return string.char(string.byte(str)) end)
    end

    local escape_by_codepoint = {
       [string.byte("\a")] = "\\a",
       [string.byte("\b")] = "\\b",
       [string.byte("\f")] = "\\f",
       [string.byte("\n")] = "\\n",
       [string.byte("\r")] = "\\r",
       [string.byte("\t")] = "\\t",
       [string.byte("\v")] = "\\v",
       [string.byte("\\")] = "\\\\"
    }

    function _M.escape_codepoint(codepoint)
        local escape = escape_by_codepoint[codepoint]
        if escape then return escape end
        if 32 <= codepoint and codepoint <= 126 then
            return string.char(codepoint)
        end
        if codepoint < 255 then
            return string.format("\\x{%02x}", codepoint)
        end
        return string.format("\\x{%04x}", codepoint)
    end

```

### VLQ (Variable-Length Quantity)

This is an implementation of
[VLQ (Variable-Length Quantity)|https://en.wikipedia.org/wiki/Variable-length_quantity].

```
    -- miranda: section+ kollos table methods
    /*
    ** From the Lua code
    ** Check that 'arg' either is a table or can behave like one (that is,
    ** has a metatable with the required metamethods)
    */

    /*
    ** Operations that an object must define to mimic a table
    ** (some functions only need some of them)
    */
    #define TAB_R 1   /* read */
    #define TAB_W 2   /* write */
    #define TAB_L 4   /* length */
    #define TAB_RW (TAB_R | TAB_W)  /* read/write */
    #define UNSIGNED_VLQ_SIZE ((8*sizeof(lua_Unsigned))/7 + 1)

    #define aux_getn(L,n,w) (checktab(L, n, (w) | TAB_L), marpa_luaL_len(L, n))

    static int checkfield (lua_State *L, const char *key, int n) {
      marpa_lua_pushstring(L, key);
      return (marpa_lua_rawget(L, -n) != LUA_TNIL);
    }

    static void checktab (lua_State *L, int arg, int what) {
      if (marpa_lua_type(L, arg) != LUA_TTABLE) {  /* is it not a table? */
        int n = 1;  /* number of elements to pop */
        if (marpa_lua_getmetatable(L, arg) &&  /* must have metatable */
            (!(what & TAB_R) || checkfield(L, "__index", ++n)) &&
            (!(what & TAB_W) || checkfield(L, "__newindex", ++n)) &&
            (!(what & TAB_L) || checkfield(L, "__len", ++n))) {
          marpa_lua_pop(L, n);  /* pop metatable and tested metamethods */
        }
        else
          marpa_luaL_argerror(L, arg, "table expected");  /* force an error */
      }
    }

    static const unsigned char* uint_to_vlq(lua_Unsigned x, unsigned char *out)
    {
            unsigned char buf[UNSIGNED_VLQ_SIZE];
            unsigned char *p_buf = buf;
            unsigned char *p_out = out;
      if (0) printf("%s %s %d %lu\n", __PRETTY_FUNCTION__, __FILE__, __LINE__, (unsigned long)x);
            for (;;) {
                *p_buf = x & 0x7F;
      if (0) printf("%s %s %d byte = %lu\n", __PRETTY_FUNCTION__, __FILE__, __LINE__, (unsigned long)(*p_buf));
      if (0) printf("%s %s %d %lu\n", __PRETTY_FUNCTION__, __FILE__, __LINE__, (unsigned long)x);
                x >>= 7;
      if (0) printf("%s %s %d %lu\n", __PRETTY_FUNCTION__, __FILE__, __LINE__, (unsigned long)x);
                if (x == 0) break;
                p_buf++;
            }
            while (p_buf > buf) {
               unsigned char this_byte = *p_buf;
               p_buf--;
               *p_out++ = this_byte | 0x80;
            }
            *p_out++ = *p_buf;
            return p_out;
    }

    static const unsigned char* uint_from_vlq(
        const unsigned char *in, lua_Unsigned* p_x)
    {
            lua_Unsigned r = 0;
            unsigned char this_byte;

            do {
      if (0) printf("%s %s %d in byte = %lu\n", __PRETTY_FUNCTION__, __FILE__, __LINE__, (unsigned long)(*in));
                this_byte = *in++;
      if (0) printf("%s %s %d %lu\n", __PRETTY_FUNCTION__, __FILE__, __LINE__, (unsigned long)r);
                r = (r << 7) | (this_byte & 0x7F);
            } while (this_byte & 0x80);
            *p_x = r;
            return in;
    }

```

Kollos static function for creating VLQ strings.

```
    -- miranda: section+ kollos table methods
    static int lca_to_vlq (lua_State *L) {
      int i;
      unsigned char vlq_buf[UNSIGNED_VLQ_SIZE];
      luaL_Buffer b;
      lua_Integer last = aux_getn(L, 1, TAB_R);
      marpa_luaL_buffinit(L, &b);
      for (i = 1; i <= last; i++) {
        lua_Unsigned x;
        const unsigned char *eobuf;
        marpa_lua_geti(L, 1, i);
        x = (lua_Unsigned)marpa_lua_tointeger(L, -1);
        /* Stack must be restored before luaL_addlstring() */
        marpa_lua_pop(L, 1);
        eobuf = uint_to_vlq(x, vlq_buf);
        marpa_luaL_addlstring(&b, (char *)vlq_buf,
            (size_t)(eobuf - vlq_buf));
      }
      marpa_luaL_pushresult(&b);
      return 1;
    }

```

Kollos static function for unpacking VLQ strings
into integer sequences.

```
    -- miranda: section+ kollos table methods
    static int lca_from_vlq (lua_State *L) {
      int i;
      size_t vlq_len;
      const unsigned char *vlq
          = (unsigned char *)marpa_luaL_checklstring(L, 1, &vlq_len);
      const unsigned char *p = vlq;
      marpa_lua_newtable(L);
      if (0) printf("%s %s %d\n", __PRETTY_FUNCTION__, __FILE__, __LINE__);
      for (i = 1; (size_t)(p - vlq) < vlq_len; i++) {
        lua_Unsigned x;
        p = uint_from_vlq(p, &x);
        marpa_lua_pushinteger(L, (lua_Integer)x);
        marpa_lua_rawseti(L, 2, i);
      }
      if (0) printf("%s %s %d\n", __PRETTY_FUNCTION__, __FILE__, __LINE__);
      return 1;
    }

```

<!--
vim: expandtab shiftwidth=4:
-->
