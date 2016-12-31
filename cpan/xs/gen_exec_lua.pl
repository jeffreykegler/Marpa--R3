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

my $lua_load_string = <<'END_OF_LOAD_STRING';
    {
        const int load_status = marpa_luaL_loadstring (L, codestr);
        if (load_status != 0) {
            /* The following is complex, because the error string
             * must be copied before it is removed from the Lua stack.
             * This is done with a Perl mortal SV.
             */
            const char *error_string = marpa_lua_tostring (L, -1);
            SV *temp_sv = sv_newmortal ();
            sv_setpvf (temp_sv, "Marpa::R3::Lua error in luaL_loadstring: %s",
                error_string);
            marpa_lua_settop (L, base_of_stack);
            croak ("%s", SvPV_nolen (temp_sv));
        }
    }
END_OF_LOAD_STRING

# This is not a subtroutine because I use XS preprocessor
# to deal with the Perl stack.  XS uses macros like XPUSHs(), and
# these assume they are in a method using the top-level XS calling
# protocol.  Putting this code in a C subroutine will confuse XS.
my $lua_exec_body = <<'END_OF_EXEC_BODY';
    {
        const int function_stack_ix = marpa_lua_gettop (L);
        int i, status;
        int top_after;

        marpa_luaL_checkstack(L, items+20, "xlua EXEC_BODY");

        if (is_method) {
            /* first argument is object table */
            marpa_lua_pushvalue (L, object_stack_ix);
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

        status = marpa_lua_pcall (L, (items - 2) + is_method, LUA_MULTRET, msghandler_ix);
        if (status != 0) {
            const char *exception_string = handle_pcall_error(L, status);
            marpa_lua_settop (L, base_of_stack);
            croak(exception_string);
        }

        marpa_luaL_checkstack(L, 20, "xlua EXEC_BODY");

        /* return args to caller */
        top_after = marpa_lua_gettop (L);
        for (i = function_stack_ix; i <= top_after; i++) {
            SV *sv_result = coerce_to_sv (L, i, '-');
            /* Took ownership of sv_result, we now need to mortalize it */
            XPUSHs (sv_2mortal (sv_result));
        }

        marpa_lua_settop (L, base_of_stack);
    }
END_OF_EXEC_BODY

# This is not a subtroutine because I use XS preprocessor
# to deal with the Perl stack.  XS uses macros like XPUSHs(), and
# these assume they are in a method using the top-level XS calling
# protocol.  Putting this code in a C subroutine will confuse XS.
my $lua_exec_sig_body = <<'END_OF_EXEC_SIG_BODY';
    {
        const int signature_stack_ix = marpa_lua_gettop (L);
        int i, status;
        char default_return_sig[] = "*";
        const char* return_signature = default_return_sig;

        marpa_luaL_checkstack(L, items+20, "xlua EXEC_SIG_BODY");

        if (is_method) {
            /* first argument is table for object */
            marpa_lua_pushvalue (L, object_stack_ix);
            /* [ object_table, function, signature, object_table ] */
        }

        /* the remaining arguments are those passed to the Perl call */
        for (i = 0; ; i++) {
            const char this_sig = signature[i];
            const int arg_ix = first_optional_arg + i;
            SV *arg_sv;

            switch (this_sig) {
            case '>':              /* end of arguments */
                return_signature = signature+i+1;
                goto endargs;
            case 0:              /* end of arguments */
                goto endargs;
            }

            if ((size_t)arg_ix >= (size_t)items) {
                croak
                    ("Internal error: signature ('%s') wants %ld items, but only %ld arguments in xlua EXEC_SIG_BODY",
                        signature, (long)arg_ix, (long)items - 2);
            }

            arg_sv = ST (arg_ix);

            /* warn("this_sig: %c", this_sig); */
            switch (this_sig) {
            case 'n':
                marpa_lua_pushnumber (L, (lua_Number)SvNV(arg_sv));
                break;
            case 'i':
                marpa_lua_pushinteger (L, (lua_Integer)SvIV(arg_sv));
                break;
            case 's':
                marpa_lua_pushstring (L, SvPV_nolen(arg_sv));
                break;
            case 'S':
                SvREFCNT_inc_simple_void_NN (arg_sv);
                marpa_sv_sv_noinc(L, arg_sv);
                break;
            default:
                croak
                    ("Internal error: invalid sig option %c in xlua EXEC_SIG_BODY", this_sig);
            }
            /* warn("%s %d narg=%d *sig=%c", __FILE__, __LINE__, narg, *sig); */
        }
      endargs:;

        status = marpa_lua_pcall (L, (items - first_optional_arg) + is_method, LUA_MULTRET, msghandler_ix);
        if (status != 0) {
            const char *exception_string = handle_pcall_error(L, status);
            marpa_lua_settop (L, base_of_stack);
            croak(exception_string);
        }

        marpa_luaL_checkstack(L, 20, "xlua EXEC_SIG_BODY");

        /* return args to caller */
        {
            const int top_after = marpa_lua_gettop (L);
            SV *sv_result;
            int stack_ix;
            int signature_ix = 0;
            for (stack_ix = signature_stack_ix;
                    stack_ix <= top_after;
                    stack_ix++) {
                const char this_sig = return_signature[signature_ix];
                switch (this_sig) {
                    case '*':
                        sv_result = coerce_to_sv (L, stack_ix, '-');
                        /* Took ownership of sv_result, we now need to mortalize it */
                        XPUSHs (sv_2mortal (sv_result));
                        break;
                    case '-':
                    case '0':
                    case '2':
                        sv_result = coerce_to_sv (L, stack_ix, this_sig);
                        /* Took ownership of sv_result, we now need to mortalize it */
                        XPUSHs (sv_2mortal (sv_result));
                        signature_ix++;
                        break;
                    default:
                        croak
                            ("Internal error: invalid return sig option %c in xlua EXEC_SIG_BODY",
                            this_sig);
                    case 0:
                        croak
                            ("Internal error: return sig too short ('%s') in xlua EXEC_SIG_BODY",
                            signature);
                }
            }
        }

        marpa_lua_settop (L, base_of_stack);
    }
END_OF_EXEC_SIG_BODY

my $code = <<'END_OF_MAIN_CODE';

MODULE = Marpa::R3        PACKAGE = Marpa::R3::Thin::SLG

void
call_by_name( outer_slg, name, signature, ... )
   Outer_G *outer_slg;
   char* name;
   char *signature;
PPCODE:
{
    int object_stack_ix;
    const int first_optional_arg = 3;
    const int is_method = 1;
    lua_State *const L = outer_slg->L;
    const int base_of_stack = marpa_lua_gettop (L);
    int msghandler_ix;
    int type;

    marpa_lua_pushcfunction(L, xlua_msghandler);
    msghandler_ix = marpa_lua_gettop(L);

    marpa_lua_rawgeti (L, LUA_REGISTRYINDEX, outer_slg->lua_ref);
    /* Lua stack: [ grammar_table ] */
    object_stack_ix = marpa_lua_gettop (L);

    type = marpa_lua_getglobal (L, name);
    if (type != LUA_TFUNCTION)
    {
      croak ("call_by_name(): global %s name is not a function", name);
    }
    /* [ grammar_table, function ] */

    === LUA_EXEC_SIG_BODY ===
}

void
call_by_tag( outer_slg, tag, codestr, signature, ... )
   Outer_G *outer_slg;
   const char* tag;
   const char* codestr;
   const char *signature;
PPCODE:
{
    int object_stack_ix;
    const int first_optional_arg = 4;
    const int is_method = 1;
    lua_State *const L = outer_slg->L;
    const int base_of_stack = marpa_lua_gettop (L);
    int msghandler_ix;
    int cache_ix;
    int type;

    marpa_lua_pushcfunction(L, xlua_msghandler);
    msghandler_ix = marpa_lua_gettop(L);

    marpa_lua_rawgeti (L, LUA_REGISTRYINDEX, outer_slg->lua_ref);
    /* Lua stack: [ grammar_table ] */
    object_stack_ix = marpa_lua_gettop (L);

    marpa_lua_getglobal (L, "code_by_tag");
    cache_ix = marpa_lua_gettop(L);
    type = marpa_lua_getfield (L, cache_ix, tag);

    /*    warn("%s %d", __FILE__, __LINE__); */
    if (type != LUA_TFUNCTION) {

        const int status =
            marpa_luaL_loadbuffer (L, codestr, strlen (codestr), tag);
        if (status != 0) {
            const char *error_string = marpa_lua_tostring (L, -1);
            marpa_lua_pop (L, 1);
            croak ("Marpa::R3 error in call_by_tag(): %s", error_string);
        }
        marpa_lua_pushvalue (L, -1);
        marpa_lua_setfield (L, cache_ix, tag);
    }

    /* [ grammar_table, function ] */

    === LUA_EXEC_SIG_BODY ===
}

MODULE = Marpa::R3        PACKAGE = Marpa::R3::Thin::SLR

void
exec( outer_slr, codestr, ... )
   Outer_R *outer_slr;
   char* codestr;
PPCODE:
{
    int object_stack_ix;
    const int is_method = 1;
    lua_State *const L = outer_slr->L;
    const int base_of_stack = marpa_lua_gettop (L);
    int msghandler_ix;

    marpa_lua_pushcfunction(L, xlua_msghandler);
    msghandler_ix = marpa_lua_gettop(L);

    marpa_lua_rawgeti (L, LUA_REGISTRYINDEX, outer_slr->lua_ref);
    /* Lua stack: [ recce_table ] */
    object_stack_ix = marpa_lua_gettop (L);

    === LUA_LOAD_STRING ===
    === LUA_EXEC_BODY ===
}

void
call_by_name( outer_slr, name, signature, ... )
   Outer_R *outer_slr;
   char* name;
   char *signature;
PPCODE:
{
    int object_stack_ix;
    const int first_optional_arg = 3;
    const int is_method = 1;
    lua_State *const L = outer_slr->L;
    const int base_of_stack = marpa_lua_gettop (L);
    int msghandler_ix;
    int type;

    marpa_lua_pushcfunction(L, xlua_msghandler);
    msghandler_ix = marpa_lua_gettop(L);

    marpa_lua_rawgeti (L, LUA_REGISTRYINDEX, outer_slr->lua_ref);
    /* Lua stack: [ recce_table ] */
    object_stack_ix = marpa_lua_gettop (L);

    type = marpa_lua_getglobal (L, name);
    if (type != LUA_TFUNCTION)
    {
      croak ("call_by_name(): global %s name is not a function", name);
    }
    /* [ recce_table, function ] */

    === LUA_EXEC_SIG_BODY ===
}

void
call_by_tag( outer_slr, tag, codestr, signature, ... )
   Outer_R *outer_slr;
   const char* tag;
   const char* codestr;
   const char *signature;
PPCODE:
{
    int object_stack_ix;
    const int first_optional_arg = 4;
    const int is_method = 1;
    lua_State *const L = outer_slr->L;
    const int base_of_stack = marpa_lua_gettop (L);
    int msghandler_ix;
    int cache_ix;
    int type;

    marpa_lua_pushcfunction(L, xlua_msghandler);
    msghandler_ix = marpa_lua_gettop(L);

    marpa_lua_rawgeti (L, LUA_REGISTRYINDEX, outer_slr->lua_ref);
    /* Lua stack: [ recce_table ] */
    object_stack_ix = marpa_lua_gettop (L);

    marpa_lua_getglobal (L, "code_by_tag");
    cache_ix = marpa_lua_gettop(L);
    type = marpa_lua_getfield (L, cache_ix, tag);

    /*    warn("%s %d", __FILE__, __LINE__); */
    if (type != LUA_TFUNCTION) {

        const int status =
            marpa_luaL_loadbuffer (L, codestr, strlen (codestr), tag);
        if (status != 0) {
            const char *error_string = marpa_lua_tostring (L, -1);
            marpa_lua_pop (L, 1);
            croak ("Marpa::R3 error in call_by_tag(): %s", error_string);
        }
        marpa_lua_pushvalue (L, -1);
        marpa_lua_setfield (L, cache_ix, tag);
    }

    /* [ recce_table, function ] */

    === LUA_EXEC_SIG_BODY ===
}

MODULE = Marpa::R3            PACKAGE = Marpa::R3::Lua

void
raw_exec( lua_wrapper, codestr, ... )
   Marpa_Lua* lua_wrapper;
   char* codestr;
PPCODE:
{
    /* object_stack_ix is actually never used */
    const int object_stack_ix = -1;
    const int is_method = 0;
    lua_State *const L = lua_wrapper->L;
    const int base_of_stack = marpa_lua_gettop (L);
    int msghandler_ix;

    marpa_lua_pushcfunction(L, xlua_msghandler);
    msghandler_ix = marpa_lua_gettop(L);

    === LUA_LOAD_STRING ===
    === LUA_EXEC_BODY ===
}

void
exec( lua_wrapper, codestr, ... )
   Marpa_Lua* lua_wrapper;
   char* codestr;
PPCODE:
{
    /* object_stack_ix is actually never used */
    const int object_stack_ix = -1;
    const int is_method = 0;
    lua_State *const L = lua_wrapper->L;
    const int base_of_stack = marpa_lua_gettop (L);
    int msghandler_ix;

    marpa_lua_pushcfunction(L, xlua_msghandler);
    msghandler_ix = marpa_lua_gettop(L);

    === LUA_LOAD_STRING ===

    /* At this point, the Lua function is on the top of the stack:
     * [func]
     * Set its first up value to the sandbox table.
     */
    marpa_lua_getglobal (L, "sandbox");
    if (!marpa_lua_setupvalue (L, -2, 1)) {
        marpa_lua_settop (L, base_of_stack);
        croak ("Marpa::R3::Lua error -- lua_setupvalue() failed");
    }
    /* [func] */

    === LUA_EXEC_BODY ===
}

END_OF_MAIN_CODE

$code =~ s/=== \s* LUA_EXEC_BODY \s* === \s /$lua_exec_body/xsmg;
$code =~ s/=== \s* LUA_EXEC_SIG_BODY \s* === \s /$lua_exec_sig_body/xsmg;
$code =~ s/=== \s* LUA_LOAD_STRING \s* === \s /$lua_load_string/xsmg;

print {$out} $code;

# vim: expandtab shiftwidth=4:
