/*
** $Id: lauxlib.h,v 1.129 2015/11/23 11:29:43 roberto Exp $
** Auxiliary functions for building Lua libraries
** See Copyright Notice in lua.h
*/


#ifndef lauxlib_h
#define lauxlib_h


#include <stddef.h>
#include <stdio.h>

#include "lua.h"



/* extra error code for 'luaL_load' */
#define LUA_ERRFILE     (LUA_ERRERR+1)


typedef struct luaL_Reg {
  const char *name;
  lua_CFunction func;
} luaL_Reg;


#define LUAL_NUMSIZES	(sizeof(lua_Integer)*16 + sizeof(lua_Number))

LUALIB_API void (marpa_luaL_checkversion_) (lua_State *L, lua_Number ver, size_t sz);
#define luaL_checkversion(L)  \
	  marpa_luaL_checkversion_(L, LUA_VERSION_NUM, LUAL_NUMSIZES)

LUALIB_API int (marpa_luaL_getmetafield) (lua_State *L, int obj, const char *e);
LUALIB_API int (marpa_luaL_callmeta) (lua_State *L, int obj, const char *e);
LUALIB_API const char *(marpa_luaL_tolstring) (lua_State *L, int idx, size_t *len);
LUALIB_API int (marpa_luaL_argerror) (lua_State *L, int arg, const char *extramsg);
LUALIB_API const char *(marpa_luaL_checklstring) (lua_State *L, int arg,
                                                          size_t *l);
LUALIB_API const char *(marpa_luaL_optlstring) (lua_State *L, int arg,
                                          const char *def, size_t *l);
LUALIB_API lua_Number (marpa_luaL_checknumber) (lua_State *L, int arg);
LUALIB_API lua_Number (marpa_luaL_optnumber) (lua_State *L, int arg, lua_Number def);

LUALIB_API lua_Integer (marpa_luaL_checkinteger) (lua_State *L, int arg);
LUALIB_API lua_Integer (marpa_luaL_optinteger) (lua_State *L, int arg,
                                          lua_Integer def);

LUALIB_API void (marpa_luaL_checkstack) (lua_State *L, int sz, const char *msg);
LUALIB_API void (marpa_luaL_checktype) (lua_State *L, int arg, int t);
LUALIB_API void (marpa_luaL_checkany) (lua_State *L, int arg);

LUALIB_API int   (marpa_luaL_newmetatable) (lua_State *L, const char *tname);
LUALIB_API void  (marpa_luaL_setmetatable) (lua_State *L, const char *tname);
LUALIB_API void *(marpa_luaL_testudata) (lua_State *L, int ud, const char *tname);
LUALIB_API void *(marpa_luaL_checkudata) (lua_State *L, int ud, const char *tname);

LUALIB_API void (marpa_luaL_where) (lua_State *L, int lvl);
LUALIB_API int (marpa_luaL_error) (lua_State *L, const char *fmt, ...);

LUALIB_API int (marpa_luaL_checkoption) (lua_State *L, int arg, const char *def,
                                   const char *const lst[]);

LUALIB_API int (marpa_luaL_fileresult) (lua_State *L, int stat, const char *fname);
LUALIB_API int (marpa_luaL_execresult) (lua_State *L, int stat);

/* predefined references */
#define LUA_NOREF       (-2)
#define LUA_REFNIL      (-1)

LUALIB_API int (marpa_luaL_ref) (lua_State *L, int t);
LUALIB_API void (marpa_luaL_unref) (lua_State *L, int t, int ref);

LUALIB_API int (marpa_luaL_loadfilex) (lua_State *L, const char *filename,
                                               const char *mode);

#define luaL_loadfile(L,f)	marpa_luaL_loadfilex(L,f,NULL)

LUALIB_API int (marpa_luaL_loadbufferx) (lua_State *L, const char *buff, size_t sz,
                                   const char *name, const char *mode);
LUALIB_API int (marpa_luaL_loadstring) (lua_State *L, const char *s);

LUALIB_API lua_State *(marpa_luaL_newstate) (void);

LUALIB_API lua_Integer (marpa_luaL_len) (lua_State *L, int idx);

LUALIB_API const char *(marpa_luaL_gsub) (lua_State *L, const char *s, const char *p,
                                                  const char *r);

LUALIB_API void (marpa_luaL_setfuncs) (lua_State *L, const luaL_Reg *l, int nup);

LUALIB_API int (marpa_luaL_getsubtable) (lua_State *L, int idx, const char *fname);

LUALIB_API void (marpa_luaL_traceback) (lua_State *L, lua_State *L1,
                                  const char *msg, int level);

LUALIB_API void (marpa_luaL_requiref) (lua_State *L, const char *modname,
                                 lua_CFunction openf, int glb);

/*
** ===============================================================
** some useful macros
** ===============================================================
*/


#define luaL_newlibtable(L,l)	\
  marpa_lua_createtable(L, 0, sizeof(l)/sizeof((l)[0]) - 1)

#define luaL_newlib(L,l)  \
  (luaL_checkversion(L), luaL_newlibtable(L,l), marpa_luaL_setfuncs(L,l,0))

#define luaL_argcheck(L, cond,arg,extramsg)	\
		((void)((cond) || marpa_luaL_argerror(L, (arg), (extramsg))))
#define luaL_checkstring(L,n)	(marpa_luaL_checklstring(L, (n), NULL))
#define luaL_optstring(L,n,d)	(marpa_luaL_optlstring(L, (n), (d), NULL))

#define luaL_typename(L,i)	marpa_lua_typename(L, marpa_lua_type(L,(i)))

#define luaL_dofile(L, fn) \
	(luaL_loadfile(L, fn) || marpa_lua_pcall(L, 0, LUA_MULTRET, 0))

#define luaL_dostring(L, s) \
	(marpa_luaL_loadstring(L, s) || marpa_lua_pcall(L, 0, LUA_MULTRET, 0))

#define luaL_getmetatable(L,n)	(marpa_lua_getfield(L, LUA_REGISTRYINDEX, (n)))

#define luaL_opt(L,f,n,d)	(marpa_lua_isnoneornil(L,(n)) ? (d) : f(L,(n)))

#define luaL_loadbuffer(L,s,sz,n)	marpa_luaL_loadbufferx(L,s,sz,n,NULL)


/*
** {======================================================
** Generic Buffer manipulation
** =======================================================
*/

typedef struct luaL_Buffer {
  char *b;  /* buffer address */
  size_t size;  /* buffer size */
  size_t n;  /* number of characters in buffer */
  lua_State *L;
  char initb[LUAL_BUFFERSIZE];  /* initial buffer */
} luaL_Buffer;


#define luaL_addchar(B,c) \
  ((void)((B)->n < (B)->size || marpa_luaL_prepbuffsize((B), 1)), \
   ((B)->b[(B)->n++] = (c)))

#define luaL_addsize(B,s)	((B)->n += (s))

LUALIB_API void (marpa_luaL_buffinit) (lua_State *L, luaL_Buffer *B);
LUALIB_API char *(marpa_luaL_prepbuffsize) (luaL_Buffer *B, size_t sz);
LUALIB_API void (marpa_luaL_addlstring) (luaL_Buffer *B, const char *s, size_t l);
LUALIB_API void (marpa_luaL_addstring) (luaL_Buffer *B, const char *s);
LUALIB_API void (marpa_luaL_addvalue) (luaL_Buffer *B);
LUALIB_API void (marpa_luaL_pushresult) (luaL_Buffer *B);
LUALIB_API void (marpa_luaL_pushresultsize) (luaL_Buffer *B, size_t sz);
LUALIB_API char *(marpa_luaL_buffinitsize) (lua_State *L, luaL_Buffer *B, size_t sz);

#define luaL_prepbuffer(B)	marpa_luaL_prepbuffsize(B, LUAL_BUFFERSIZE)

/* }====================================================== */



/*
** {======================================================
** File handles for IO library
** =======================================================
*/

/*
** A file handle is a userdata with metatable 'LUA_FILEHANDLE' and
** initial structure 'luaL_Stream' (it may contain other fields
** after that initial structure).
*/

#define LUA_FILEHANDLE          "FILE*"


typedef struct luaL_Stream {
  FILE *f;  /* stream (NULL for incompletely created streams) */
  lua_CFunction closef;  /* to close stream (NULL for closed streams) */
} luaL_Stream;

/* }====================================================== */



/* compatibility with old module system */
#if defined(LUA_COMPAT_MODULE)

LUALIB_API void (luaL_pushmodule) (lua_State *L, const char *modname,
                                   int sizehint);
LUALIB_API void (luaL_openlib) (lua_State *L, const char *libname,
                                const luaL_Reg *l, int nup);

#define luaL_register(L,n,l)	(luaL_openlib(L,(n),(l),0))

#endif


/*
** {==================================================================
** "Abstraction Layer" for basic report of messages and errors
** ===================================================================
*/

/* print a string */
#if !defined(marpa_lua_writestring)
#define marpa_lua_writestring(s,l)   fwrite((s), sizeof(char), (l), stdout)
#endif

/* print a newline and flush the output */
#if !defined(marpa_lua_writeline)
#define marpa_lua_writeline()        (marpa_lua_writestring("\n", 1), fflush(stdout))
#endif

/* print an error message */
#if !defined(marpa_lua_writestringerror)
#define marpa_lua_writestringerror(s,p) \
        (fprintf(stderr, (s), (p)), fflush(stderr))
#endif

/* }================================================================== */


/*
** {============================================================
** Compatibility with deprecated conversions
** =============================================================
*/
#if defined(LUA_COMPAT_APIINTCASTS)

#define luaL_checkunsigned(L,a)	((lua_Unsigned)marpa_luaL_checkinteger(L,a))
#define luaL_optunsigned(L,a,d)	\
	((lua_Unsigned)marpa_luaL_optinteger(L,a,(lua_Integer)(d)))

#define luaL_checkint(L,n)	((int)marpa_luaL_checkinteger(L, (n)))
#define luaL_optint(L,n,d)	((int)marpa_luaL_optinteger(L, (n), (d)))

#define luaL_checklong(L,n)	((long)marpa_luaL_checkinteger(L, (n)))
#define luaL_optlong(L,n,d)	((long)marpa_luaL_optinteger(L, (n), (d)))

#endif
/* }============================================================ */



#endif


