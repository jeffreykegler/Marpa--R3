/*
** $Id: linit.c,v 1.14.1.1 2007/12/27 13:02:25 roberto Exp $
** Initialization of libraries for lua.c
** See Copyright Notice in lua.h
*/


#define linit_c
#define LUA_LIB

#include "lua.h"

#include "lualib.h"
#include "lauxlib.h"


static const luaL_Reg lualibs[] = {
  {"", marpa_luaopen_base},
  {LUA_LOADLIBNAME, marpa_luaopen_package},
  {LUA_TABLIBNAME, marpa_luaopen_table},
  {LUA_IOLIBNAME, marpa_luaopen_io},
  {LUA_OSLIBNAME, marpa_luaopen_os},
  {LUA_STRLIBNAME, marpa_luaopen_string},
  {LUA_MATHLIBNAME, marpa_luaopen_math},
  {LUA_DBLIBNAME, marpa_luaopen_debug},
  {NULL, NULL}
};


LUALIB_API void marpa_luaL_openlibs (lua_State *L) {
  const luaL_Reg *lib = lualibs;
  for (; lib->func; lib++) {
    lua_pushcfunction(L, lib->func);
    marpa_lua_pushstring(L, lib->name);
    marpa_lua_call(L, 1, 0);
  }
}

