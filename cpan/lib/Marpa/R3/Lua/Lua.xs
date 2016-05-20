/*
 * Marpa::R3 is Copyright (C) 2016, Jeffrey Kegler.
 *
 * This module is free software; you can redistribute it and/or modify it
 * under the same terms as Perl 5.10.1. For more details, see the full text
 * of the licenses in the directory LICENSES.
 *
 * This program is distributed in the hope that it will be
 * useful, but it is provided “as is” and without any express
 * or implied warranties. For details, see the full text of
 * of the licenses in the directory LICENSES.
 */

/* Portions of this code adopted from Inline::Lua */

#include "marpa_xs.h"

#define PERL_NO_GET_CONTEXT
#include <EXTERN.h>
#include <perl.h>
#include <XSUB.h>
#include "ppport.h"

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

static lua_State *marpa_L = NULL;

static SV* bool_ref	    (lua_State *, int);
static SV* luaval_to_perlsv  (lua_State *, int);

static SV*
luaval_to_perlsv (lua_State * L, int idx)
{
  const int type = marpa_lua_type (L, idx);
  SV *result;
  switch (type)
    {
    case LUA_TNIL:
      result = newSV (0);
      break;
    case LUA_TBOOLEAN:
      result = bool_ref (L, marpa_lua_toboolean (L, idx));
      break;
    case LUA_TNUMBER:
      result = newSVnv (marpa_lua_tonumber (L, idx));
      break;
    case LUA_TSTRING:
      warn("%s %d: %s len=%d\n", __FILE__, __LINE__, marpa_lua_tostring (L, idx), marpa_lua_rawlen (L, idx));
      result = newSVpvn (marpa_lua_tostring (L, idx), marpa_lua_rawlen (L, idx));
      break;
    case LUA_TTABLE:
    case LUA_TFUNCTION:
    default:
      result = newSVpvf ("Lua type %s not yet implemented", type);
      break;
    }
    warn("%s %d\n", __FILE__, __LINE__);
  return result;
}

static SV*
bool_ref (lua_State *L, int b) {
    return b ? newSViv(1) : newSV(0);
}

MODULE = Marpa::R3::Lua        PACKAGE = Marpa::R3::Lua

PROTOTYPES: DISABLE

void
exec( ... )
PPCODE:
{
  // const char* hi = "salve, munde";
  // XPUSHs (sv_2mortal (newSVpv (hi, 0)));
  int i, status;
  int top_before, top_after;
  char *codestr = "print [[SALVE!]]; return [[salve, munde!]]";

  top_before = marpa_lua_gettop (marpa_L);
  warn("top_before=%d", top_before);
  status = luaL_loadbuffer (marpa_L, codestr, strlen (codestr), codestr);
  if (status != 0)
    {
      const char *error_string = marpa_lua_tostring (marpa_L, -1);
      marpa_lua_pop (marpa_L, 1);
      croak ("Marpa::R3::Lua error in luaL_loadbuffer: %s", error_string);
    }

  status = marpa_lua_pcall (marpa_L, 0, LUA_MULTRET, 0);
  if (status != 0)
    {
      const char *error_string = marpa_lua_tostring (marpa_L, -1);
      marpa_lua_pop (marpa_L, 1);
      croak ("Marpa::R3::Lua error in pcall: %s", error_string);
    }

  /* return args to caller:
   * lua functions appear to push their return values in reverse order */
  top_after = marpa_lua_gettop (marpa_L);
  warn("top_after=%d", top_after);
  for (i = top_before + 1; i <= top_after; i++)
    {
    warn("%s %d\n", __FILE__, __LINE__);
      SV *result = luaval_to_perlsv (marpa_L, i);
    warn("%s %d\n", __FILE__, __LINE__);
      marpa_lua_pop (marpa_L, 1);
    warn("%s %d\n", __FILE__, __LINE__);
      XPUSHs (sv_2mortal (result));
    warn("%s %d\n", __FILE__, __LINE__);
    }
}

BOOT:

    /* Perl threads now discouraged, so we no longer worry about
     * safety
     */
     marpa_L = marpa_luaL_newstate();
     if (!marpa_L) {
      croak ("Marpa::R3 internal error: Lua interpreter failed to start");
       }
    marpa_luaL_openlibs(marpa_L);  /* open libraries */

    /* vim: set expandtab shiftwidth=2: */
