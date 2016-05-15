/*
** $Id: ldblib.c,v 1.104.1.4 2009/08/04 18:50:18 roberto Exp $
** Interface from Lua to its debug API
** See Copyright Notice in lua.h
*/


#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define ldblib_c
#define LUA_LIB

#include "lua.h"

#include "lauxlib.h"
#include "lualib.h"



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
  luaL_argcheck(L, t == LUA_TNIL || t == LUA_TTABLE, 2,
                    "nil or table expected");
  marpa_lua_settop(L, 2);
  marpa_lua_pushboolean(L, marpa_lua_setmetatable(L, 1));
  return 1;
}


static int db_getfenv (lua_State *L) {
  marpa_luaL_checkany(L, 1);
  marpa_lua_getfenv(L, 1);
  return 1;
}


static int db_setfenv (lua_State *L) {
  marpa_luaL_checktype(L, 2, LUA_TTABLE);
  marpa_lua_settop(L, 2);
  if (marpa_lua_setfenv(L, 1) == 0)
    marpa_luaL_error(L, LUA_QL("setfenv")
                  " cannot change environment of given object");
  return 1;
}


static void settabss (lua_State *L, const char *i, const char *v) {
  marpa_lua_pushstring(L, v);
  marpa_lua_setfield(L, -2, i);
}


static void settabsi (lua_State *L, const char *i, int v) {
  marpa_lua_pushinteger(L, v);
  marpa_lua_setfield(L, -2, i);
}


static lua_State *getthread (lua_State *L, int *arg) {
  if (lua_isthread(L, 1)) {
    *arg = 1;
    return marpa_lua_tothread(L, 1);
  }
  else {
    *arg = 0;
    return L;
  }
}


static void treatstackoption (lua_State *L, lua_State *L1, const char *fname) {
  if (L == L1) {
    marpa_lua_pushvalue(L, -2);
    marpa_lua_remove(L, -3);
  }
  else
    marpa_lua_xmove(L1, L, 1);
  marpa_lua_setfield(L, -2, fname);
}


static int db_getinfo (lua_State *L) {
  lua_Debug ar;
  int arg;
  lua_State *L1 = getthread(L, &arg);
  const char *options = luaL_optstring(L, arg+2, "flnSu");
  if (marpa_lua_isnumber(L, arg+1)) {
    if (!marpa_lua_getstack(L1, (int)marpa_lua_tointeger(L, arg+1), &ar)) {
      marpa_lua_pushnil(L);  /* level out of range */
      return 1;
    }
  }
  else if (lua_isfunction(L, arg+1)) {
    marpa_lua_pushfstring(L, ">%s", options);
    options = lua_tostring(L, -1);
    marpa_lua_pushvalue(L, arg+1);
    marpa_lua_xmove(L, L1, 1);
  }
  else
    return marpa_luaL_argerror(L, arg+1, "function or level expected");
  if (!marpa_lua_getinfo(L1, options, &ar))
    return marpa_luaL_argerror(L, arg+2, "invalid option");
  marpa_lua_createtable(L, 0, 2);
  if (strchr(options, 'S')) {
    settabss(L, "source", ar.source);
    settabss(L, "short_src", ar.short_src);
    settabsi(L, "linedefined", ar.linedefined);
    settabsi(L, "lastlinedefined", ar.lastlinedefined);
    settabss(L, "what", ar.what);
  }
  if (strchr(options, 'l'))
    settabsi(L, "currentline", ar.currentline);
  if (strchr(options, 'u'))
    settabsi(L, "nups", ar.nups);
  if (strchr(options, 'n')) {
    settabss(L, "name", ar.name);
    settabss(L, "namewhat", ar.namewhat);
  }
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
  if (!marpa_lua_getstack(L1, luaL_checkint(L, arg+1), &ar))  /* out of range? */
    return marpa_luaL_argerror(L, arg+1, "level out of range");
  name = marpa_lua_getlocal(L1, &ar, luaL_checkint(L, arg+2));
  if (name) {
    marpa_lua_xmove(L1, L, 1);
    marpa_lua_pushstring(L, name);
    marpa_lua_pushvalue(L, -2);
    return 2;
  }
  else {
    marpa_lua_pushnil(L);
    return 1;
  }
}


static int db_setlocal (lua_State *L) {
  int arg;
  lua_State *L1 = getthread(L, &arg);
  lua_Debug ar;
  if (!marpa_lua_getstack(L1, luaL_checkint(L, arg+1), &ar))  /* out of range? */
    return marpa_luaL_argerror(L, arg+1, "level out of range");
  marpa_luaL_checkany(L, arg+3);
  marpa_lua_settop(L, arg+3);
  marpa_lua_xmove(L, L1, 1);
  marpa_lua_pushstring(L, marpa_lua_setlocal(L1, &ar, luaL_checkint(L, arg+2)));
  return 1;
}


static int auxupvalue (lua_State *L, int get) {
  const char *name;
  int n = luaL_checkint(L, 2);
  marpa_luaL_checktype(L, 1, LUA_TFUNCTION);
  if (marpa_lua_iscfunction(L, 1)) return 0;  /* cannot touch C upvalues from Lua */
  name = get ? marpa_lua_getupvalue(L, 1, n) : marpa_lua_setupvalue(L, 1, n);
  if (name == NULL) return 0;
  marpa_lua_pushstring(L, name);
  marpa_lua_insert(L, -(get+1));
  return get + 1;
}


static int db_getupvalue (lua_State *L) {
  return auxupvalue(L, 1);
}


static int db_setupvalue (lua_State *L) {
  marpa_luaL_checkany(L, 3);
  return auxupvalue(L, 0);
}



static const char KEY_HOOK = 'h';


static void hookf (lua_State *L, lua_Debug *ar) {
  static const char *const hooknames[] =
    {"call", "return", "line", "count", "tail return"};
  marpa_lua_pushlightuserdata(L, (void *)&KEY_HOOK);
  marpa_lua_rawget(L, LUA_REGISTRYINDEX);
  marpa_lua_pushlightuserdata(L, L);
  marpa_lua_rawget(L, -2);
  if (lua_isfunction(L, -1)) {
    marpa_lua_pushstring(L, hooknames[(int)ar->event]);
    if (ar->currentline >= 0)
      marpa_lua_pushinteger(L, ar->currentline);
    else marpa_lua_pushnil(L);
    lua_assert(marpa_lua_getinfo(L, "lS", ar));
    marpa_lua_call(L, 2, 0);
  }
}


static int makemask (const char *smask, int count) {
  int mask = 0;
  if (strchr(smask, 'c')) mask |= LUA_MASKCALL;
  if (strchr(smask, 'r')) mask |= LUA_MASKRET;
  if (strchr(smask, 'l')) mask |= LUA_MASKLINE;
  if (count > 0) mask |= LUA_MASKCOUNT;
  return mask;
}


static char *unmakemask (int mask, char *smask) {
  int i = 0;
  if (mask & LUA_MASKCALL) smask[i++] = 'c';
  if (mask & LUA_MASKRET) smask[i++] = 'r';
  if (mask & LUA_MASKLINE) smask[i++] = 'l';
  smask[i] = '\0';
  return smask;
}


static void gethooktable (lua_State *L) {
  marpa_lua_pushlightuserdata(L, (void *)&KEY_HOOK);
  marpa_lua_rawget(L, LUA_REGISTRYINDEX);
  if (!lua_istable(L, -1)) {
    lua_pop(L, 1);
    marpa_lua_createtable(L, 0, 1);
    marpa_lua_pushlightuserdata(L, (void *)&KEY_HOOK);
    marpa_lua_pushvalue(L, -2);
    marpa_lua_rawset(L, LUA_REGISTRYINDEX);
  }
}


static int db_sethook (lua_State *L) {
  int arg, mask, count;
  lua_Hook func;
  lua_State *L1 = getthread(L, &arg);
  if (lua_isnoneornil(L, arg+1)) {
    marpa_lua_settop(L, arg+1);
    func = NULL; mask = 0; count = 0;  /* turn off hooks */
  }
  else {
    const char *smask = luaL_checkstring(L, arg+2);
    marpa_luaL_checktype(L, arg+1, LUA_TFUNCTION);
    count = luaL_optint(L, arg+3, 0);
    func = hookf; mask = makemask(smask, count);
  }
  gethooktable(L);
  marpa_lua_pushlightuserdata(L, L1);
  marpa_lua_pushvalue(L, arg+1);
  marpa_lua_rawset(L, -3);  /* set new hook */
  lua_pop(L, 1);  /* remove hook table */
  marpa_lua_sethook(L1, func, mask, count);  /* set hooks */
  return 0;
}


static int db_gethook (lua_State *L) {
  int arg;
  lua_State *L1 = getthread(L, &arg);
  char buff[5];
  int mask = marpa_lua_gethookmask(L1);
  lua_Hook hook = marpa_lua_gethook(L1);
  if (hook != NULL && hook != hookf)  /* external hook? */
    lua_pushliteral(L, "external hook");
  else {
    gethooktable(L);
    marpa_lua_pushlightuserdata(L, L1);
    marpa_lua_rawget(L, -2);   /* get hook */
    marpa_lua_remove(L, -2);  /* remove hook table */
  }
  marpa_lua_pushstring(L, unmakemask(mask, buff));
  marpa_lua_pushinteger(L, marpa_lua_gethookcount(L1));
  return 3;
}


static int db_debug (lua_State *L) {
  for (;;) {
    char buffer[250];
    fputs("lua_debug> ", stderr);
    if (fgets(buffer, sizeof(buffer), stdin) == 0 ||
        strcmp(buffer, "cont\n") == 0)
      return 0;
    if (marpa_luaL_loadbuffer(L, buffer, strlen(buffer), "=(debug command)") ||
        marpa_lua_pcall(L, 0, 0, 0)) {
      fputs(lua_tostring(L, -1), stderr);
      fputs("\n", stderr);
    }
    marpa_lua_settop(L, 0);  /* remove eventual returns */
  }
}


#define LEVELS1	12	/* size of the first part of the stack */
#define LEVELS2	10	/* size of the second part of the stack */

static int db_errorfb (lua_State *L) {
  int level;
  int firstpart = 1;  /* still before eventual `...' */
  int arg;
  lua_State *L1 = getthread(L, &arg);
  lua_Debug ar;
  if (marpa_lua_isnumber(L, arg+2)) {
    level = (int)marpa_lua_tointeger(L, arg+2);
    lua_pop(L, 1);
  }
  else
    level = (L == L1) ? 1 : 0;  /* level 0 may be this own function */
  if (marpa_lua_gettop(L) == arg)
    lua_pushliteral(L, "");
  else if (!marpa_lua_isstring(L, arg+1)) return 1;  /* message is not a string */
  else lua_pushliteral(L, "\n");
  lua_pushliteral(L, "stack traceback:");
  while (marpa_lua_getstack(L1, level++, &ar)) {
    if (level > LEVELS1 && firstpart) {
      /* no more than `LEVELS2' more levels? */
      if (!marpa_lua_getstack(L1, level+LEVELS2, &ar))
        level--;  /* keep going */
      else {
        lua_pushliteral(L, "\n\t...");  /* too many levels */
        while (marpa_lua_getstack(L1, level+LEVELS2, &ar))  /* find last levels */
          level++;
      }
      firstpart = 0;
      continue;
    }
    lua_pushliteral(L, "\n\t");
    marpa_lua_getinfo(L1, "Snl", &ar);
    marpa_lua_pushfstring(L, "%s:", ar.short_src);
    if (ar.currentline > 0)
      marpa_lua_pushfstring(L, "%d:", ar.currentline);
    if (*ar.namewhat != '\0')  /* is there a name? */
        marpa_lua_pushfstring(L, " in function " LUA_QS, ar.name);
    else {
      if (*ar.what == 'm')  /* main? */
        marpa_lua_pushfstring(L, " in main chunk");
      else if (*ar.what == 'C' || *ar.what == 't')
        lua_pushliteral(L, " ?");  /* C function or tail call */
      else
        marpa_lua_pushfstring(L, " in function <%s:%d>",
                           ar.short_src, ar.linedefined);
    }
    marpa_lua_concat(L, marpa_lua_gettop(L) - arg);
  }
  marpa_lua_concat(L, marpa_lua_gettop(L) - arg);
  return 1;
}


static const luaL_Reg dblib[] = {
  {"debug", db_debug},
  {"getfenv", db_getfenv},
  {"gethook", db_gethook},
  {"getinfo", db_getinfo},
  {"getlocal", db_getlocal},
  {"getregistry", db_getregistry},
  {"getmetatable", db_getmetatable},
  {"getupvalue", db_getupvalue},
  {"setfenv", db_setfenv},
  {"sethook", db_sethook},
  {"setlocal", db_setlocal},
  {"setmetatable", db_setmetatable},
  {"setupvalue", db_setupvalue},
  {"traceback", db_errorfb},
  {NULL, NULL}
};


LUALIB_API int marpa_luaopen_debug (lua_State *L) {
  marpa_luaL_register(L, LUA_DBLIBNAME, dblib);
  return 1;
}

