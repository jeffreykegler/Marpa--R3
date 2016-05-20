/*
** $Id: lcorolib.c,v 1.9 2014/11/02 19:19:04 roberto Exp $
** Coroutine Library
** See Copyright Notice in lua.h
*/

#define lcorolib_c
#define LUA_LIB

#include "lprefix.h"


#include <stdlib.h>

#include "lua.h"

#include "lauxlib.h"
#include "lualib.h"


static lua_State *getco (lua_State *L) {
  lua_State *co = marpa_lua_tothread(L, 1);
  luaL_argcheck(L, co, 1, "thread expected");
  return co;
}


static int auxresume (lua_State *L, lua_State *co, int narg) {
  int status;
  if (!marpa_lua_checkstack(co, narg)) {
    marpa_lua_pushliteral(L, "too many arguments to resume");
    return -1;  /* error flag */
  }
  if (marpa_lua_status(co) == LUA_OK && marpa_lua_gettop(co) == 0) {
    marpa_lua_pushliteral(L, "cannot resume dead coroutine");
    return -1;  /* error flag */
  }
  marpa_lua_xmove(L, co, narg);
  status = marpa_lua_resume(co, L, narg);
  if (status == LUA_OK || status == LUA_YIELD) {
    int nres = marpa_lua_gettop(co);
    if (!marpa_lua_checkstack(L, nres + 1)) {
      marpa_lua_pop(co, nres);  /* remove results anyway */
      marpa_lua_pushliteral(L, "too many results to resume");
      return -1;  /* error flag */
    }
    marpa_lua_xmove(co, L, nres);  /* move yielded values */
    return nres;
  }
  else {
    marpa_lua_xmove(co, L, 1);  /* move error message */
    return -1;  /* error flag */
  }
}


static int luaB_coresume (lua_State *L) {
  lua_State *co = getco(L);
  int r;
  r = auxresume(L, co, marpa_lua_gettop(L) - 1);
  if (r < 0) {
    marpa_lua_pushboolean(L, 0);
    marpa_lua_insert(L, -2);
    return 2;  /* return false + error message */
  }
  else {
    marpa_lua_pushboolean(L, 1);
    marpa_lua_insert(L, -(r + 1));
    return r + 1;  /* return true + 'resume' returns */
  }
}


static int luaB_auxwrap (lua_State *L) {
  lua_State *co = marpa_lua_tothread(L, marpa_lua_upvalueindex(1));
  int r = auxresume(L, co, marpa_lua_gettop(L));
  if (r < 0) {
    if (marpa_lua_isstring(L, -1)) {  /* error object is a string? */
      marpa_luaL_where(L, 1);  /* add extra info */
      marpa_lua_insert(L, -2);
      marpa_lua_concat(L, 2);
    }
    return marpa_lua_error(L);  /* propagate error */
  }
  return r;
}


static int luaB_cocreate (lua_State *L) {
  lua_State *NL;
  marpa_luaL_checktype(L, 1, LUA_TFUNCTION);
  NL = marpa_lua_newthread(L);
  marpa_lua_pushvalue(L, 1);  /* move function to top */
  marpa_lua_xmove(L, NL, 1);  /* move function from L to NL */
  return 1;
}


static int luaB_cowrap (lua_State *L) {
  luaB_cocreate(L);
  marpa_lua_pushcclosure(L, luaB_auxwrap, 1);
  return 1;
}


static int luaB_yield (lua_State *L) {
  return marpa_lua_yield(L, marpa_lua_gettop(L));
}


static int luaB_costatus (lua_State *L) {
  lua_State *co = getco(L);
  if (L == co) marpa_lua_pushliteral(L, "running");
  else {
    switch (marpa_lua_status(co)) {
      case LUA_YIELD:
        marpa_lua_pushliteral(L, "suspended");
        break;
      case LUA_OK: {
        lua_Debug ar;
        if (marpa_lua_getstack(co, 0, &ar) > 0)  /* does it have frames? */
          marpa_lua_pushliteral(L, "normal");  /* it is running */
        else if (marpa_lua_gettop(co) == 0)
            marpa_lua_pushliteral(L, "dead");
        else
          marpa_lua_pushliteral(L, "suspended");  /* initial state */
        break;
      }
      default:  /* some error occurred */
        marpa_lua_pushliteral(L, "dead");
        break;
    }
  }
  return 1;
}


static int luaB_yieldable (lua_State *L) {
  marpa_lua_pushboolean(L, marpa_lua_isyieldable(L));
  return 1;
}


static int luaB_corunning (lua_State *L) {
  int ismain = marpa_lua_pushthread(L);
  marpa_lua_pushboolean(L, ismain);
  return 2;
}


static const luaL_Reg co_funcs[] = {
  {"create", luaB_cocreate},
  {"resume", luaB_coresume},
  {"running", luaB_corunning},
  {"status", luaB_costatus},
  {"wrap", luaB_cowrap},
  {"yield", luaB_yield},
  {"isyieldable", luaB_yieldable},
  {NULL, NULL}
};



LUAMOD_API int marpa_luaopen_coroutine (lua_State *L) {
  luaL_newlib(L, co_funcs);
  return 1;
}

