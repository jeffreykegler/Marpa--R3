/*
** $Id: linit.c,v 1.38 2015/01/05 13:48:33 roberto Exp $
** Initialization of libraries for lua.c and other clients
** See Copyright Notice in lua.h
*/


#define linit_c
#define LUA_LIB

/*
** If you embed Lua in your program and need to open the standard
** libraries, call marpa_luaL_openlibs in your program. If you need a
** different set of libraries, copy this file to your project and edit
** it to suit your needs.
**
** You can also *preload* libraries, so that a later 'require' can
** open the library, which is already linked to the application.
** For that, do the following code:
**
**  marpa_luaL_getsubtable(L, LUA_REGISTRYINDEX, "_PRELOAD");
**  lua_pushcfunction(L, luaopen_modname);
**  marpa_lua_setfield(L, -2, modname);
**  lua_pop(L, 1);  // remove _PRELOAD table
*/

#include "lprefix.h"


#include <stddef.h>

#include "lua.h"

#include "lualib.h"
#include "lauxlib.h"


/*
** these libs are loaded by lua.c and are readily available to any Lua
** program
*/
static const luaL_Reg loadedlibs[] = {
  {"_G", marpa_luaopen_base},
  {LUA_LOADLIBNAME, marpa_luaopen_package},
  {LUA_COLIBNAME, marpa_luaopen_coroutine},
  {LUA_TABLIBNAME, marpa_luaopen_table},
  {LUA_IOLIBNAME, marpa_luaopen_io},
  {LUA_OSLIBNAME, marpa_luaopen_os},
  {LUA_STRLIBNAME, marpa_luaopen_string},
  {LUA_MATHLIBNAME, marpa_luaopen_math},
  {LUA_UTF8LIBNAME, marpa_luaopen_utf8},
  {LUA_DBLIBNAME, marpa_luaopen_debug},
#if defined(LUA_COMPAT_BITLIB)
  {LUA_BITLIBNAME, marpa_luaopen_bit32},
#endif
  {NULL, NULL}
};


LUALIB_API void marpa_luaL_openlibs (lua_State *L) {
  const luaL_Reg *lib;
  /* "require" functions from 'loadedlibs' and set results to global table */
  for (lib = loadedlibs; lib->func; lib++) {
    marpa_luaL_requiref(L, lib->name, lib->func, 1);
    lua_pop(L, 1);  /* remove lib */
  }
}

