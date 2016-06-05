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
$VERSION        = '4.001_010';
$STRING_VERSION = $VERSION;
$VERSION        = eval $VERSION;

# Lua methods

# These can, and probably should, be pre-compiled someday,
# reducing start-up time.

$Marpa::R3::Lua::value_init = <<'END_OF_LUA';
    -- for k,v in pairs(marpa.ops)
    -- do io.stderr:write(string.format("OP: %s %s\n", k, v))
    -- end

    local recce = ...

    recce.op_fn_key = {}

    function op_fn_create(name, fn) 
        local ref = recce:ref(fn);
        recce.op_fn_key[name] = ref;
	return ref
    end

    recce.rule_semantics = {}
    recce.token_semantics = {}
    recce.nulling_semantics = {}
    recce.nulling_semantics.default
        = marpa.array.from_list(marpa.ops.result_is_undef,0)
    recce.token_semantics.default
        = marpa.array.from_list(marpa.ops.result_is_token_value,0)
    recce.rule_semantics.default
        = marpa.array.from_list(marpa.ops.result_is_undef, 0)
    -- print( recce.nulling_semantics.default )
    -- io.stderr:write(string.format("len: %s\n", #(recce.nulling_semantics.default)))
    -- io.stderr:write(string.format("#0: %s\n", recce.nulling_semantics.default[0]))
    -- io.stderr:write(string.format("#1: %s\n", recce.nulling_semantics.default[1]))

    op_fn_create("debug", function (...)
        local recce, type, result_ix, rule_id, arg_n = ...
        print([[OP_LUA:]], recce, type, result_ix, rule_id, arg_n)
        for k,v in pairs(recce) do
            print(k, v)
        end
        mt = debug.getmetatable(recce)
        print([[=== metatable ===]])
        for k,v in pairs(mt) do
            print(k, v)
        end
    end)

    -- print("stack len:", marpa.sv.top_index(recce:stack()))

    local result_is_undef_key = op_fn_create("result_is_undef", function (...)
        local recce, type, result_ix = ...
        local stack = recce:stack()
        stack[result_ix] = marpa.sv.lua_nil()
        marpa.sv.fill(stack, result_ix)
        return 0
    end)

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

END_OF_LUA
1;
