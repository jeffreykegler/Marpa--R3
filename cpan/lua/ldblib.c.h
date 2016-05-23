/*
** $Id: ldblib.c,v 1.151 2015/11/23 11:29:43 roberto Exp $
** Interface from Lua to its debug API
** See Copyright Notice in lua.h
*/

#define ldblib_c
#define LUA_LIB

#include "lprefix.h"


#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "lua.h"

#include "lauxlib.h"
#include "lualib.h"


/*
** The hook table at registry[&HOOKKEY] maps threads to their current
** hook function. (We only need the unique address of 'HOOKKEY'.)
*/
static const int HOOKKEY = 0;


/*
** If L1 != L, L1 can be in any state, and therefore there are no
** guarantees about its stack space; any push in L1 must be
** checked.
*/
static void checkstack (lua_State *L, lua_State *L1, int n) {
  if (L != L1 && !marpa_lua_checkstack(L1, n))
    marpa_luaL_error(L, "stack overflow");
}


static int db_getregistry (lua_State *L) {
  marpa_lua_pushvalue(L, LUA_REGISTRYINDEX);
  return 1;
}


static int db_getmetatable (lua_State *L) {
  marpa_luaL_checkany(L, 1);
  if (!marpa_lua_getmetatable(L, 1)) {
    marpa_lua_pushnil(L);  /* no metatable */
  }
  return 1;
}


static int db_setmetatable (lua_State *L) {
  int t = marpa_lua_type(L, 2);
  marpa_luaL_argcheck(L, t == LUA_TNIL || t == LUA_TTABLE, 2,
                    "nil or table expected");
  marpa_lua_settop(L, 2);
  marpa_lua_setmetatable(L, 1);
  return 1;  /* return 1st argument */
}


static int db_getuservalue (lua_State *L) {
  if (marpa_lua_type(L, 1) != LUA_TUSERDATA)
    marpa_lua_pushnil(L);
  else
    marpa_lua_getuservalue(L, 1);
  return 1;
}


static int db_setuservalue (lua_State *L) {
  marpa_luaL_checktype(L, 1, LUA_TUSERDATA);
  marpa_luaL_checkany(L, 2);
  marpa_lua_settop(L, 2);
  marpa_lua_setuservalue(L, 1);
  return 1;
}


/*
** Auxiliary function used by several library functions: check for
** an optional thread as function's first argument and set 'arg' with
** 1 if this argument is present (so that functions can skip it to
** access their other arguments)
*/
static lua_State *getthread (lua_State *L, int *arg) {
  if (marpa_lua_isthread(L, 1)) {
    *arg = 1;
    return marpa_lua_tothread(L, 1);
  }
  else {
    *arg = 0;
    return L;  /* function will operate over current thread */
  }
}


/*
** Variations of 'marpa_lua_settable', used by 'db_getinfo' to put results
** from 'marpa_lua_getinfo' into result table. Key is always a string;
** value can be a string, an int, or a boolean.
*/
static void settabss (lua_State *L, const char *k, const char *v) {
  marpa_lua_pushstring(L, v);
  marpa_lua_setfield(L, -2, k);
}

static void settabsi (lua_State *L, const char *k, int v) {
  marpa_lua_pushinteger(L, v);
  marpa_lua_setfield(L, -2, k);
}

static void settabsb (lua_State *L, const char *k, int v) {
  marpa_lua_pushboolean(L, v);
  marpa_lua_setfield(L, -2, k);
}


/*
** In function 'db_getinfo', the call to 'marpa_lua_getinfo' may push
** results on the stack; later it creates the result table to put
** these objects. Function 'treatstackoption' puts the result from
** 'marpa_lua_getinfo' on top of the result table so that it can call
** 'marpa_lua_setfield'.
*/
static void treatstackoption (lua_State *L, lua_State *L1, const char *fname) {
  if (L == L1)
    marpa_lua_rotate(L, -2, 1);  /* exchange object and table */
  else
    marpa_lua_xmove(L1, L, 1);  /* move object to the "main" stack */
  marpa_lua_setfield(L, -2, fname);  /* put object into table */
}


/*
** Calls 'marpa_lua_getinfo' and collects all results in a new table.
** L1 needs stack space for an optional input (function) plus
** two optional outputs (function and line table) from function
** 'marpa_lua_getinfo'.
*/
static int db_getinfo (lua_State *L) {
  lua_Debug ar;
  int arg;
  lua_State *L1 = getthread(L, &arg);
  const char *options = marpa_luaL_optstring(L, arg+2, "flnStu");
  checkstack(L, L1, 3);
  if (marpa_lua_isfunction(L, arg + 1)) {  /* info about a function? */
    options = marpa_lua_pushfstring(L, ">%s", options);  /* add '>' to 'options' */
    marpa_lua_pushvalue(L, arg + 1);  /* move function to 'L1' stack */
    marpa_lua_xmove(L, L1, 1);
  }
  else {  /* stack level */
    if (!marpa_lua_getstack(L1, (int)marpa_luaL_checkinteger(L, arg + 1), &ar)) {
      marpa_lua_pushnil(L);  /* level out of range */
      return 1;
    }
  }
  if (!marpa_lua_getinfo(L1, options, &ar))
    return marpa_luaL_argerror(L, arg+2, "invalid option");
  marpa_lua_newtable(L);  /* table to collect results */
  if (strchr(options, 'S')) {
    settabss(L, "source", ar.source);
    settabss(L, "short_src", ar.short_src);
    settabsi(L, "linedefined", ar.linedefined);
    settabsi(L, "lastlinedefined", ar.lastlinedefined);
    settabss(L, "what", ar.what);
  }
  if (strchr(options, 'l'))
    settabsi(L, "currentline", ar.currentline);
  if (strchr(options, 'u')) {
    settabsi(L, "nups", ar.nups);
    settabsi(L, "nparams", ar.nparams);
    settabsb(L, "isvararg", ar.isvararg);
  }
  if (strchr(options, 'n')) {
    settabss(L, "name", ar.name);
    settabss(L, "namewhat", ar.namewhat);
  }
  if (strchr(options, 't'))
    settabsb(L, "istailcall", ar.istailcall);
  if (strchr(options, 'L'))
    treatstackoption(L, L1, "activelines");
  if (strchr(options, 'f'))
    treatstackoption(L, L1, "func");
  return 1;  /* return table */
}


static int db_getlocal (lua_State *L) {
  int arg;
  lua_State *L1 = getthread(L, &arg);
  lua_Debug ar;
  const char *name;
  int nvar = (int)marpa_luaL_checkinteger(L, arg + 2);  /* local-variable index */
  if (marpa_lua_isfunction(L, arg + 1)) {  /* function argument? */
    marpa_lua_pushvalue(L, arg + 1);  /* push function */
    marpa_lua_pushstring(L, marpa_lua_getlocal(L, NULL, nvar));  /* push local name */
    return 1;  /* return only name (there is no value) */
  }
  else {  /* stack-level argument */
    int level = (int)marpa_luaL_checkinteger(L, arg + 1);
    if (!marpa_lua_getstack(L1, level, &ar))  /* out of range? */
      return marpa_luaL_argerror(L, arg+1, "level out of range");
    checkstack(L, L1, 1);
    name = marpa_lua_getlocal(L1, &ar, nvar);
    if (name) {
      marpa_lua_xmove(L1, L, 1);  /* move local value */
      marpa_lua_pushstring(L, name);  /* push name */
      marpa_lua_rotate(L, -2, 1);  /* re-order */
      return 2;
    }
    else {
      marpa_lua_pushnil(L);  /* no name (nor value) */
      return 1;
    }
  }
}


static int db_setlocal (lua_State *L) {
  int arg;
  const char *name;
  lua_State *L1 = getthread(L, &arg);
  lua_Debug ar;
  int level = (int)marpa_luaL_checkinteger(L, arg + 1);
  int nvar = (int)marpa_luaL_checkinteger(L, arg + 2);
  if (!marpa_lua_getstack(L1, level, &ar))  /* out of range? */
    return marpa_luaL_argerror(L, arg+1, "level out of range");
  marpa_luaL_checkany(L, arg+3);
  marpa_lua_settop(L, arg+3);
  checkstack(L, L1, 1);
  marpa_lua_xmove(L, L1, 1);
  name = marpa_lua_setlocal(L1, &ar, nvar);
  if (name == NULL)
    marpa_lua_pop(L1, 1);  /* pop value (if not popped by 'marpa_lua_setlocal') */
  marpa_lua_pushstring(L, name);
  return 1;
}


/*
** get (if 'get' is true) or set an upvalue from a closure
*/
static int auxupvalue (lua_State *L, int get) {
  const char *name;
  int n = (int)marpa_luaL_checkinteger(L, 2);  /* upvalue index */
  marpa_luaL_checktype(L, 1, LUA_TFUNCTION);  /* closure */
  name = get ? marpa_lua_getupvalue(L, 1, n) : marpa_lua_setupvalue(L, 1, n);
  if (name == NULL) return 0;
  marpa_lua_pushstring(L, name);
  marpa_lua_insert(L, -(get+1));  /* no-op if get is false */
  return get + 1;
}


static int db_getupvalue (lua_State *L) {
  return auxupvalue(L, 1);
}


static int db_setupvalue (lua_State *L) {
  marpa_luaL_checkany(L, 3);
  return auxupvalue(L, 0);
}


/*
** Check whether a given upvalue from a given closure exists and
** returns its index
*/
static int checkupval (lua_State *L, int argf, int argnup) {
  int nup = (int)marpa_luaL_checkinteger(L, argnup);  /* upvalue index */
  marpa_luaL_checktype(L, argf, LUA_TFUNCTION);  /* closure */
  marpa_luaL_argcheck(L, (marpa_lua_getupvalue(L, argf, nup) != NULL), argnup,
                   "invalid upvalue index");
  return nup;
}


static int db_upvalueid (lua_State *L) {
  int n = checkupval(L, 1, 2);
  marpa_lua_pushlightuserdata(L, marpa_lua_upvalueid(L, 1, n));
  return 1;
}


static int db_upvaluejoin (lua_State *L) {
  int n1 = checkupval(L, 1, 2);
  int n2 = checkupval(L, 3, 4);
  marpa_luaL_argcheck(L, !marpa_lua_iscfunction(L, 1), 1, "Lua function expected");
  marpa_luaL_argcheck(L, !marpa_lua_iscfunction(L, 3), 3, "Lua function expected");
  marpa_lua_upvaluejoin(L, 1, n1, 3, n2);
  return 0;
}


/*
** Call hook function registered at hook table for the current
** thread (if there is one)
*/
static void hookf (lua_State *L, lua_Debug *ar) {
  static const char *const hooknames[] =
    {"call", "return", "line", "count", "tail call"};
  marpa_lua_rawgetp(L, LUA_REGISTRYINDEX, &HOOKKEY);
  marpa_lua_pushthread(L);
  if (marpa_lua_rawget(L, -2) == LUA_TFUNCTION) {  /* is there a hook function? */
    marpa_lua_pushstring(L, hooknames[(int)ar->event]);  /* push event name */
    if (ar->currentline >= 0)
      marpa_lua_pushinteger(L, ar->currentline);  /* push current line */
    else marpa_lua_pushnil(L);
    lua_assert(marpa_lua_getinfo(L, "lS", ar));
    marpa_lua_call(L, 2, 0);  /* call hook function */
  }
}


/*
** Convert a string mask (for 'sethook') into a bit mask
*/
static int makemask (const char *smask, int count) {
  int mask = 0;
  if (strchr(smask, 'c')) mask |= LUA_MASKCALL;
  if (strchr(smask, 'r')) mask |= LUA_MASKRET;
  if (strchr(smask, 'l')) mask |= LUA_MASKLINE;
  if (count > 0) mask |= LUA_MASKCOUNT;
  return mask;
}


/*
** Convert a bit mask (for 'gethook') into a string mask
*/
static char *unmakemask (int mask, char *smask) {
  int i = 0;
  if (mask & LUA_MASKCALL) smask[i++] = 'c';
  if (mask & LUA_MASKRET) smask[i++] = 'r';
  if (mask & LUA_MASKLINE) smask[i++] = 'l';
  smask[i] = '\0';
  return smask;
}


static int db_sethook (lua_State *L) {
  int arg, mask, count;
  lua_Hook func;
  lua_State *L1 = getthread(L, &arg);
  if (marpa_lua_isnoneornil(L, arg+1)) {  /* no hook? */
    marpa_lua_settop(L, arg+1);
    func = NULL; mask = 0; count = 0;  /* turn off hooks */
  }
  else {
    const char *smask = marpa_luaL_checkstring(L, arg+2);
    marpa_luaL_checktype(L, arg+1, LUA_TFUNCTION);
    count = (int)marpa_luaL_optinteger(L, arg + 3, 0);
    func = hookf; mask = makemask(smask, count);
  }
  if (marpa_lua_rawgetp(L, LUA_REGISTRYINDEX, &HOOKKEY) == LUA_TNIL) {
    marpa_lua_createtable(L, 0, 2);  /* create a hook table */
    marpa_lua_pushvalue(L, -1);
    marpa_lua_rawsetp(L, LUA_REGISTRYINDEX, &HOOKKEY);  /* set it in position */
    marpa_lua_pushstring(L, "k");
    marpa_lua_setfield(L, -2, "__mode");  /** hooktable.__mode = "k" */
    marpa_lua_pushvalue(L, -1);
    marpa_lua_setmetatable(L, -2);  /* setmetatable(hooktable) = hooktable */
  }
  checkstack(L, L1, 1);
  marpa_lua_pushthread(L1); marpa_lua_xmove(L1, L, 1);  /* key (thread) */
  marpa_lua_pushvalue(L, arg + 1);  /* value (hook function) */
  marpa_lua_rawset(L, -3);  /* hooktable[L1] = new Lua hook */
  marpa_lua_sethook(L1, func, mask, count);
  return 0;
}


static int db_gethook (lua_State *L) {
  int arg;
  lua_State *L1 = getthread(L, &arg);
  char buff[5];
  int mask = marpa_lua_gethookmask(L1);
  lua_Hook hook = marpa_lua_gethook(L1);
  if (hook == NULL)  /* no hook? */
    marpa_lua_pushnil(L);
  else if (hook != hookf)  /* external hook? */
    marpa_lua_pushliteral(L, "external hook");
  else {  /* hook table must exist */
    marpa_lua_rawgetp(L, LUA_REGISTRYINDEX, &HOOKKEY);
    checkstack(L, L1, 1);
    marpa_lua_pushthread(L1); marpa_lua_xmove(L1, L, 1);
    marpa_lua_rawget(L, -2);   /* 1st result = hooktable[L1] */
    marpa_lua_remove(L, -2);  /* remove hook table */
  }
  marpa_lua_pushstring(L, unmakemask(mask, buff));  /* 2nd result = mask */
  marpa_lua_pushinteger(L, marpa_lua_gethookcount(L1));  /* 3rd result = count */
  return 3;
}


static int db_debug (lua_State *L) {
  for (;;) {
    char buffer[250];
    marpa_lua_writestringerror("%s", "lua_debug> ");
    if (fgets(buffer, sizeof(buffer), stdin) == 0 ||
        strcmp(buffer, "cont\n") == 0)
      return 0;
    if (marpa_luaL_loadbuffer(L, buffer, strlen(buffer), "=(debug command)") ||
        marpa_lua_pcall(L, 0, 0, 0))
      marpa_lua_writestringerror("%s\n", marpa_lua_tostring(L, -1));
    marpa_lua_settop(L, 0);  /* remove eventual returns */
  }
}


static int db_traceback (lua_State *L) {
  int arg;
  lua_State *L1 = getthread(L, &arg);
  const char *msg = marpa_lua_tostring(L, arg + 1);
  if (msg == NULL && !marpa_lua_isnoneornil(L, arg + 1))  /* non-string 'msg'? */
    marpa_lua_pushvalue(L, arg + 1);  /* return it untouched */
  else {
    int level = (int)marpa_luaL_optinteger(L, arg + 2, (L == L1) ? 1 : 0);
    marpa_luaL_traceback(L, L1, msg, level);
  }
  return 1;
}


static const luaL_Reg dblib[] = {
  {"debug", db_debug},
  {"getuservalue", db_getuservalue},
  {"gethook", db_gethook},
  {"getinfo", db_getinfo},
  {"getlocal", db_getlocal},
  {"getregistry", db_getregistry},
  {"getmetatable", db_getmetatable},
  {"getupvalue", db_getupvalue},
  {"upvaluejoin", db_upvaluejoin},
  {"upvalueid", db_upvalueid},
  {"setuservalue", db_setuservalue},
  {"sethook", db_sethook},
  {"setlocal", db_setlocal},
  {"setmetatable", db_setmetatable},
  {"setupvalue", db_setupvalue},
  {"traceback", db_traceback},
  {NULL, NULL}
};


LUAMOD_API int marpa_luaopen_debug (lua_State *L) {
  marpa_luaL_newlib(L, dblib);
  return 1;
}

