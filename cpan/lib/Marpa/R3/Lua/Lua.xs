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

static SV* bool_ref            (lua_State *, int);
static SV* luaval_to_perlsv  (lua_State *, int);

static SV*
luaval_to_perlsv (lua_State * L, int idx)
{
  const int type = marpa_lua_type (L, idx);
  SV *result;
    // warn("%s %d\n", __FILE__, __LINE__);
  switch (type)
    {
    case LUA_TNIL:
    // warn("%s %d\n", __FILE__, __LINE__);
      result = newSV (0);
      break;
    case LUA_TBOOLEAN:
    // warn("%s %d\n", __FILE__, __LINE__);
      result = bool_ref (L, marpa_lua_toboolean (L, idx));
      break;
    case LUA_TNUMBER:
    // warn("%s %d\n", __FILE__, __LINE__);
      result = newSVnv (marpa_lua_tonumber (L, idx));
      break;
    case LUA_TSTRING:
      // warn("%s %d: %s len=%d\n", __FILE__, __LINE__, marpa_lua_tostring (L, idx), marpa_lua_rawlen (L, idx));
      result = newSVpvn (marpa_lua_tostring (L, idx), marpa_lua_rawlen (L, idx));
      break;
    case LUA_TTABLE:
    case LUA_TFUNCTION:
    default:
    // warn("%s %d\n", __FILE__, __LINE__);
      result = newSVpvf ("Lua type %d at index %d not yet implemented", type, idx);
      break;
    }
    // warn("%s %d\n", __FILE__, __LINE__);
  return result;
}

static SV*
bool_ref (lua_State *L, int b) {
    return b ? newSViv(1) : newSV(0);
}

/* push a Perl value onto the Lua stack:
 * does the right thing for any Perl type
 * handled by Inline::Lua */
static void
push_val (lua_State * L, SV * val)
{
  if (SvTYPE (val) == SVt_NULL)
    {
      // warn("%s %d\n", __FILE__, __LINE__);
      marpa_lua_pushnil (marpa_L);
      return;
    }
  if (SvPOK (val))
    {
      STRLEN n_a;
      // warn("%s %d\n", __FILE__, __LINE__);
      char *cval = SvPV (val, n_a);
      marpa_lua_pushlstring (marpa_L, cval, n_a);
      return;
    }
  if (SvNOK (val))
    {
      // warn("%s %d\n", __FILE__, __LINE__);
      marpa_lua_pushnumber (marpa_L, (lua_Number) SvNV (val));
      return;
    }
  if (SvIOK (val))
    {
      // warn("%s %d\n", __FILE__, __LINE__);
      marpa_lua_pushnumber (marpa_L, (lua_Number) SvIV (val));
      return;
    }
  if (SvROK (val))
    {
      // warn("%s %d\n", __FILE__, __LINE__);
      marpa_lua_pushfstring (marpa_L,
                             "!!!Argument unsupported: Perl reference type (%s)",
                             sv_reftype (SvRV (val), 0));
      return;
    }
      // warn("%s %d\n", __FILE__, __LINE__);
  marpa_lua_pushfstring (marpa_L, "!!!Argument unsupported: Perl type (%d)",
                         SvTYPE (val));
  return;
}

/* Register a "time object", a grammar, recce, etc. */
int marpa_xlua_time_ref()
{
    marpa_lua_newtable(marpa_L);
    return marpa_luaL_ref(marpa_L, LUA_REGISTRYINDEX);
}

void marpa_xlua_time_unref()
{
    marpa_luaL_ref(marpa_L, LUA_REGISTRYINDEX);
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
  char *codestr = "print [[SALVE!]]; return [[salve, munde!]], ...";

  top_before = marpa_lua_gettop (marpa_L);
  // warn("top_before=%d", top_before);

  /* push arguments */
  for (i = 0; i < items; i++) {
      // warn("%s %d: pushing Perl arg %d\n", __FILE__, __LINE__, i);
      push_val(marpa_L, ST(i));
      // warn("%s %d\n", __FILE__, __LINE__);
  }

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
  // warn("top_after=%d", top_after);
  for (i = top_before + 1; i <= top_after; i++)
    {
    // warn("%s %d\n", __FILE__, __LINE__);
      SV *result = luaval_to_perlsv (marpa_L, i);
    // warn("%s %d\n", __FILE__, __LINE__);
    // warn("%s %d\n", __FILE__, __LINE__);
      XPUSHs (sv_2mortal (result));
    // warn("%s %d\n", __FILE__, __LINE__);
    }
      if (top_after > top_before) {
      marpa_lua_pop (marpa_L, top_after - top_before);
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
