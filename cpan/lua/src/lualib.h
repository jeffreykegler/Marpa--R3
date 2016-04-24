/*
** $Id: lualib.h,v 1.36.1.1 2007/12/27 13:02:25 roberto Exp $
** Lua standard libraries
** See Copyright Notice in lua.h
*/


#ifndef lualib_h
#define lualib_h

#include "lua.h"


/* Key to file-handle type */
#define LUA_FILEHANDLE		"FILE*"


#define LUA_COLIBNAME	"coroutine"
LUALIB_API int (marpa_luaopen_base) (lua_State *L);

#define LUA_TABLIBNAME	"table"
LUALIB_API int (marpa_luaopen_table) (lua_State *L);

#define LUA_IOLIBNAME	"io"
LUALIB_API int (marpa_luaopen_io) (lua_State *L);

#define LUA_OSLIBNAME	"os"
LUALIB_API int (marpa_luaopen_os) (lua_State *L);

#define LUA_STRLIBNAME	"string"
LUALIB_API int (marpa_luaopen_string) (lua_State *L);

#define LUA_MATHLIBNAME	"math"
LUALIB_API int (marpa_luaopen_math) (lua_State *L);

#define LUA_DBLIBNAME	"debug"
LUALIB_API int (marpa_luaopen_debug) (lua_State *L);

#define LUA_LOADLIBNAME	"package"
LUALIB_API int (marpa_luaopen_package) (lua_State *L);


/* open all previous libraries */
LUALIB_API void (marpa_luaL_openlibs) (lua_State *L); 



#ifndef lua_assert
#define lua_assert(x)	((void)0)
#endif


#endif
