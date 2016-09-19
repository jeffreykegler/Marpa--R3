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

use 5.010001;
use strict;
use warnings;
use English qw( -no_match_vars );
use autodie;

# These contain a lot of repeated code, and the XS
# system is an obstacle to be factoring out into a subroutine.

sub usage {
     die "usage: $PROGRAM_NAME [auto.xs]";
}

if (@ARGV > 1) {
   usage();
}

my $out;
if ( @ARGV == 1 ) {
    my $xsh_file_name = $ARGV[0];
    open $out, q{>}, $xsh_file_name;
} else {
   $out = *STDOUT;
}

my $lua_exec_body = <<'END_OF_EXEC_BODY';
    {
        const int function_stack_ix = marpa_lua_gettop (L);
        int i, status;
        int top_after;

        marpa_luaL_checkstack(L, items+20, "xlua EXEC_BODY");

        if (is_method) {
            /* first argument is recce table */
            marpa_lua_pushvalue (L, -2);
            /* [ object_table, function, object_table ] */
        }

        /* the remaining arguments are those passed to the Perl call */
        for (i = 2; i < items; i++) {
            SV *arg_sv = ST (i);
            if (!SvOK (arg_sv)) {
                croak ("Marpa::R3::Lua::exec arg %d is not an SV", i);
            }
            MARPA_SV_SV (L, arg_sv);
        }

        status = marpa_lua_pcall (L, (items - 2) + is_method, LUA_MULTRET, 0);
        if (status != 0) {
            const char *exception_string = handle_pcall_error(L, status);
            marpa_lua_settop (L, base_of_stack);
            croak(exception_string);
        }

        marpa_luaL_checkstack(L, 20, "xlua EXEC_BODY");

        /* return args to caller */
        top_after = marpa_lua_gettop (L);
        for (i = function_stack_ix; i <= top_after; i++) {
            SV *sv_result = coerce_to_sv (L, i);
            /* Took ownership of sv_result, we now need to mortalize it */
            XPUSHs (sv_2mortal (sv_result));
        }

        marpa_lua_settop (L, base_of_stack);
    }
END_OF_EXEC_BODY

my $code = <<'END_OF_MAIN_CODE';

MODULE = Marpa::R3        PACKAGE = Marpa::R3::Thin::SLG

void
exec_key( outer_slg, fn_key, ... )
   Outer_G *outer_slg;
   int fn_key;
PPCODE:
{
    Scanless_G* slg = slg_inner_get(outer_slg);
    int recce_object;
    const int is_method = 1;
    lua_State *const L = slg->L;
    const int base_of_stack = marpa_lua_gettop (L);

    marpa_lua_rawgeti (L, LUA_REGISTRYINDEX, slg->lua_ref);
    /* Lua stack: [ grammar_table ] */
    recce_object = marpa_lua_gettop (L);
    marpa_lua_rawgeti (L, recce_object, fn_key);
    /* [ grammar_table, function ] */

    === LUA EXEC BODY ===
}

void
exec( outer_slg, codestr, ... )
   Outer_G *outer_slg;
   char* codestr;
PPCODE:
{
    Scanless_G* slg = slg_inner_get(outer_slg);
    const int is_method = 1;
    lua_State *const L = slg->L;
    const int base_of_stack = marpa_lua_gettop (L);
    int load_status;

    marpa_lua_rawgeti (L, LUA_REGISTRYINDEX, slg->lua_ref);
    /* Lua stack: [ grammar_table ] */

    load_status = marpa_luaL_loadbuffer (L, codestr, strlen (codestr), codestr);
    if (load_status != 0)
    {
      const char *error_string = marpa_lua_tostring (L, -1);
      marpa_lua_pop (L, 1);
      croak ("Marpa::R3::Lua error in luaL_loadbuffer: %s", error_string);
    }
    /* [ grammar_table, function ] */

    === LUA EXEC BODY ===
}

void
exec_name( outer_slg, name, ... )
   Outer_G *outer_slg;
   char* name;
PPCODE:
{
    Scanless_G* slg = slg_inner_get(outer_slg);
    const int is_method = 1;
    lua_State *const L = slg->L;
    const int base_of_stack = marpa_lua_gettop (L);
    int type;

    marpa_lua_rawgeti (L, LUA_REGISTRYINDEX, slg->lua_ref);
    /* Lua stack: [ grammar_table ] */

    type = marpa_lua_getglobal (L, name);
    if (type != LUA_TFUNCTION)
    {
      croak ("exec_name: global %s name is not a function", name);
    }
    /* [ grammar_table, function ] */

    === LUA EXEC BODY ===
}

MODULE = Marpa::R3        PACKAGE = Marpa::R3::Thin::SLR

void
exec_key( outer_slr, fn_key, ... )
   Outer_R *outer_slr;
   int fn_key;
PPCODE:
{
    int recce_object;
    const int is_method = 1;
    lua_State *const L = outer_slr->L;
    const int base_of_stack = marpa_lua_gettop (L);

    marpa_lua_rawgeti (L, LUA_REGISTRYINDEX, outer_slr->lua_ref);
    /* Lua stack: [ recce_table ] */
    recce_object = marpa_lua_gettop (L);
    marpa_lua_rawgeti (L, recce_object, fn_key);
    /* [ recce_table, function ] */

    === LUA EXEC BODY ===
}

void
exec( outer_slr, codestr, ... )
   Outer_R *outer_slr;
   char* codestr;
PPCODE:
{
    const int is_method = 1;
    lua_State *const L = outer_slr->L;
    const int base_of_stack = marpa_lua_gettop (L);
    int load_status;

    marpa_lua_rawgeti (L, LUA_REGISTRYINDEX, outer_slr->lua_ref);
    /* Lua stack: [ recce_table ] */

    load_status = marpa_luaL_loadbuffer (L, codestr, strlen (codestr), codestr);
    if (load_status != 0)
    {
      const char *error_string = marpa_lua_tostring (L, -1);
      marpa_lua_pop (L, 1);
      croak ("Marpa::R3::Lua error in luaL_loadbuffer: %s", error_string);
    }
    /* [ recce_table, function ] */

    === LUA EXEC BODY ===
}

void
exec_name( outer_slr, name, ... )
   Outer_R *outer_slr;
   char* name;
PPCODE:
{
    const int is_method = 1;
    lua_State *const L = outer_slr->L;
    const int base_of_stack = marpa_lua_gettop (L);
    int type;

    marpa_lua_rawgeti (L, LUA_REGISTRYINDEX, outer_slr->lua_ref);
    /* Lua stack: [ recce_table ] */

    type = marpa_lua_getglobal (L, name);
    if (type != LUA_TFUNCTION)
    {
      croak ("exec_name: global %s name is not a function", name);
    }
    /* [ recce_table, function ] */

    === LUA EXEC BODY ===
}

MODULE = Marpa::R3            PACKAGE = Marpa::R3::Lua

void
raw_exec( lua_wrapper, codestr, ... )
   Marpa_Lua* lua_wrapper;
   char* codestr;
PPCODE:
{
    const int is_method = 0;
    lua_State *const L = lua_wrapper->L;
    const int base_of_stack = marpa_lua_gettop (L);
    const int load_status =
        marpa_luaL_loadbuffer (L, codestr, strlen (codestr), codestr);

    if (load_status != 0) {
        const char *error_string = marpa_lua_tostring (L, -1);
        marpa_lua_pop (L, 1);
        croak ("Marpa::R3::Lua error in luaL_loadbuffer: %s",
            error_string);
    }

    === LUA EXEC BODY ===
}

void
exec( lua_wrapper, codestr, ... )
   Marpa_Lua* lua_wrapper;
   char* codestr;
PPCODE:
{
  const int is_method = 0;
  lua_State* const L = lua_wrapper->L;
    const int base_of_stack = marpa_lua_gettop (L);

  const int load_status =
    marpa_luaL_loadbuffer (L, codestr, strlen (codestr), codestr);
  if (load_status != 0)
    {
      const char *error_string = marpa_lua_tostring (L, -1);
      marpa_lua_pop (L, 1);
      croak ("Marpa::R3::Lua error in luaL_loadbuffer: %s", error_string);
    }

    === LUA EXEC BODY ===
}

END_OF_MAIN_CODE

$code =~ s/=== \s* LUA \s* EXEC \s* BODY \s* === \s /$lua_exec_body/xsmg;

print {$out} $code;

# vim: expandtab shiftwidth=4:
