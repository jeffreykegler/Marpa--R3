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
static SV* table_ref	    (lua_State *, int);
static SV* luaval_to_perlsv  (lua_State *, int);

/* Non-destructively translate a a number to a string.
 * lua_tostring() can't be used as it turns the value
 * on the stack into a string. */
static char *
num2string (lua_Number n, I32 *klen) {
    char s[32];
    char *str;
    STRLEN len;
    sprintf(s, LUA_NUMBER_FMT, n);
    len = *klen = strlen(s)+1;
    New(0, str, len, char);
    Copy(s, str, len, char);
    return str;
}

/* Lua tables are both an array and a hash but this can't be known in advance.
 * Initially it is assumed that the Lua table can be turned into a plain Perl
 * array. However, once a stringy key is found the strategy has to be switched
 * and the array populated so far is converted into a hash */
static HV *
ary_to_hash (AV *ary) {
    int i;
    int len = av_len(ary);
    HV *hv = newHV();
    SV *key = newSViv(0);
    for (i = 0; i <= len; i++) {
	if (!av_exists(ary, i))
	    continue;
	sv_setiv(key, i+1);	/* +1 because Lua tables start at 1 */
	hv_store_ent(hv, key, *av_fetch(ary, i, FALSE), 0);
    }
    SvREFCNT_dec(key);
    return hv;
}

static SV*
luaval_to_perlsv (lua_State * L, int idx)
{
  const int type = marpa_lua_type (L, idx);
  SV *result;
  switch (type)
    {
    case LUA_TNIL:
      result = newSV (0);
    case LUA_TBOOLEAN:
      result = bool_ref (L, marpa_lua_toboolean (L, idx));
    case LUA_TNUMBER:
      result = newSVnv (marpa_lua_tonumber (L, idx));
    case LUA_TSTRING:
      result = newSVpvn (marpa_lua_tostring (L, idx), marpa_lua_rawlen (L, idx));
    case LUA_TTABLE:
      result = table_ref (L, idx);
    case LUA_TFUNCTION:
    default:
      result = newSVpvf ("Lua type %s not yet implemented", type);
      break;
    }
  marpa_lua_pop (L, 1);
  return result;
}

static int
add_pair (lua_State *L, SV **any, int *isary) {
#define KEY -2
#define VAL -1

    if (*isary && marpa_lua_type(L, KEY) != LUA_TNUMBER) {
	HV *tbl = ary_to_hash((AV*)*any);
	*isary = 0;
	*any = (SV*)tbl;
    }

    if (*isary) {
	int idx = marpa_lua_tonumber(L, KEY);
	SV *val = luaval_to_perlsv(L, marpa_lua_gettop(L));
	SvREFCNT_inc(val);
	if (!av_store((AV*)*any, idx-1, val))
	    SvREFCNT_dec(val);
    }
    else {
	const char *key;
	I32 klen;
	SV *val;
	int free = 0;
	switch (marpa_lua_type(L, KEY)) {
	    case LUA_TNUMBER:
		{
		lua_Number n = marpa_lua_tonumber(L, KEY);
		key = (const char*)num2string(n, &klen);
		free = 1;
		break;
		}
	    case LUA_TSTRING:
		key = marpa_lua_tostring(L, KEY);
		klen = marpa_lua_rawlen(L, KEY);
		break;
	    default:
		croak("Illegal type (%s) in table subscript", marpa_lua_typename(L, marpa_lua_type(L, KEY)));
	}
	val = luaval_to_perlsv(L, marpa_lua_gettop(L));
	SvREFCNT_inc(val);
	if (!hv_store((HV*)*any, key, klen, val, 0))
	    SvREFCNT_dec(val);
	if (free)
	    Safefree(key);
    }

}

static SV*
bool_ref (lua_State *L, int b) {
    return b ? newSViv(1) : newSV(0);
}

/* The Lua table being in the stack at 'idx' is turned into a
 * Perl AV _or_ HV (depending on whether the lua table has a stringy
 * key in it and a reference to that is returned
 */
static SV*
table_ref (lua_State * L, int idx)
{
  int isary = 1;		// initially we always assume it's an array
  AV *tbl = newAV ();

  assert (idx >= 1);

  marpa_lua_pushnil (L);
  while (marpa_lua_next (L, idx) != 0)
    {
      add_pair (L, (SV **) & tbl, &isary);
      marpa_lua_pop (L, 1);
    }
  return newRV_noinc ((SV *) tbl);
}

MODULE = Marpa::R3::Lua        PACKAGE = Marpa::R3::Lua

PROTOTYPES: DISABLE

void
exec( ... )
PPCODE:
{
  // const char* hi = "salve, munde";
  // XPUSHs (sv_2mortal (newSVpv (hi, 0)));
  int i = 0, j, status;
  int nargs;

  status = marpa_lua_pcall (marpa_L, 0, LUA_MULTRET, 0);

  if (status != 0)
    {
      const char * error_string = marpa_lua_tostring (marpa_L, -1);
      marpa_lua_pop (marpa_L, 1);
      croak ("Marpa::R3::Lua error in pcall: %s", error_string);
    }

  /* return args to caller:
   * lua functions appear to push their return values in reverse order */
  nargs = marpa_lua_gettop (marpa_L);
  EXTEND (SP, nargs);
  j = 1;
  while (i = marpa_lua_gettop (marpa_L))
    {
      ST (nargs - j++) = sv_2mortal (luaval_to_perlsv (marpa_L, i));
    }
  XSRETURN (j - 1);
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
