/*
** $Id: ltablib.c,v 1.38.1.3 2008/02/14 16:46:58 roberto Exp $
** Library for Table Manipulation
** See Copyright Notice in lua.h
*/


#include <stddef.h>

#define ltablib_c
#define LUA_LIB

#include "lua.h"

#include "lauxlib.h"
#include "lualib.h"


#define aux_getn(L,n)	(marpa_luaL_checktype(L, n, LUA_TTABLE), marpa_luaL_getn(L, n))


static int foreachi (lua_State *L) {
  int i;
  int n = aux_getn(L, 1);
  marpa_luaL_checktype(L, 2, LUA_TFUNCTION);
  for (i=1; i <= n; i++) {
    marpa_lua_pushvalue(L, 2);  /* function */
    marpa_lua_pushinteger(L, i);  /* 1st argument */
    marpa_lua_rawgeti(L, 1, i);  /* 2nd argument */
    marpa_lua_call(L, 2, 1);
    if (!lua_isnil(L, -1))
      return 1;
    lua_pop(L, 1);  /* remove nil result */
  }
  return 0;
}


static int foreach (lua_State *L) {
  marpa_luaL_checktype(L, 1, LUA_TTABLE);
  marpa_luaL_checktype(L, 2, LUA_TFUNCTION);
  marpa_lua_pushnil(L);  /* first key */
  while (marpa_lua_next(L, 1)) {
    marpa_lua_pushvalue(L, 2);  /* function */
    marpa_lua_pushvalue(L, -3);  /* key */
    marpa_lua_pushvalue(L, -3);  /* value */
    marpa_lua_call(L, 2, 1);
    if (!lua_isnil(L, -1))
      return 1;
    lua_pop(L, 2);  /* remove value and result */
  }
  return 0;
}


static int maxn (lua_State *L) {
  lua_Number max = 0;
  marpa_luaL_checktype(L, 1, LUA_TTABLE);
  marpa_lua_pushnil(L);  /* first key */
  while (marpa_lua_next(L, 1)) {
    lua_pop(L, 1);  /* remove value */
    if (marpa_lua_type(L, -1) == LUA_TNUMBER) {
      lua_Number v = marpa_lua_tonumber(L, -1);
      if (v > max) max = v;
    }
  }
  marpa_lua_pushnumber(L, max);
  return 1;
}


static int getn (lua_State *L) {
  marpa_lua_pushinteger(L, aux_getn(L, 1));
  return 1;
}


static int setn (lua_State *L) {
  marpa_luaL_checktype(L, 1, LUA_TTABLE);
#ifndef marpa_luaL_setn
  marpa_luaL_setn(L, 1, luaL_checkint(L, 2));
#else
  marpa_luaL_error(L, LUA_QL("setn") " is obsolete");
#endif
  marpa_lua_pushvalue(L, 1);
  return 1;
}


static int tinsert (lua_State *L) {
  int e = aux_getn(L, 1) + 1;  /* first empty element */
  int pos;  /* where to insert new element */
  switch (marpa_lua_gettop(L)) {
    case 2: {  /* called with only 2 arguments */
      pos = e;  /* insert new element at the end */
      break;
    }
    case 3: {
      int i;
      pos = luaL_checkint(L, 2);  /* 2nd argument is the position */
      if (pos > e) e = pos;  /* `grow' array if necessary */
      for (i = e; i > pos; i--) {  /* move up elements */
        marpa_lua_rawgeti(L, 1, i-1);
        marpa_lua_rawseti(L, 1, i);  /* t[i] = t[i-1] */
      }
      break;
    }
    default: {
      return marpa_luaL_error(L, "wrong number of arguments to " LUA_QL("insert"));
    }
  }
  marpa_luaL_setn(L, 1, e);  /* new size */
  marpa_lua_rawseti(L, 1, pos);  /* t[pos] = v */
  return 0;
}


static int tremove (lua_State *L) {
  int e = aux_getn(L, 1);
  int pos = luaL_optint(L, 2, e);
  if (!(1 <= pos && pos <= e))  /* position is outside bounds? */
   return 0;  /* nothing to remove */
  marpa_luaL_setn(L, 1, e - 1);  /* t.n = n-1 */
  marpa_lua_rawgeti(L, 1, pos);  /* result = t[pos] */
  for ( ;pos<e; pos++) {
    marpa_lua_rawgeti(L, 1, pos+1);
    marpa_lua_rawseti(L, 1, pos);  /* t[pos] = t[pos+1] */
  }
  marpa_lua_pushnil(L);
  marpa_lua_rawseti(L, 1, e);  /* t[e] = nil */
  return 1;
}


static void addfield (lua_State *L, luaL_Buffer *b, int i) {
  marpa_lua_rawgeti(L, 1, i);
  if (!marpa_lua_isstring(L, -1))
    marpa_luaL_error(L, "invalid value (%s) at index %d in table for "
                  LUA_QL("concat"), luaL_typename(L, -1), i);
    marpa_luaL_addvalue(b);
}


static int tconcat (lua_State *L) {
  luaL_Buffer b;
  size_t lsep;
  int i, last;
  const char *sep = marpa_luaL_optlstring(L, 2, "", &lsep);
  marpa_luaL_checktype(L, 1, LUA_TTABLE);
  i = luaL_optint(L, 3, 1);
  last = luaL_opt(L, luaL_checkint, 4, marpa_luaL_getn(L, 1));
  marpa_luaL_buffinit(L, &b);
  for (; i < last; i++) {
    addfield(L, &b, i);
    marpa_luaL_addlstring(&b, sep, lsep);
  }
  if (i == last)  /* add last value (if interval was not empty) */
    addfield(L, &b, i);
  marpa_luaL_pushresult(&b);
  return 1;
}



/*
** {======================================================
** Quicksort
** (based on `Algorithms in MODULA-3', Robert Sedgewick;
**  Addison-Wesley, 1993.)
*/


static void set2 (lua_State *L, int i, int j) {
  marpa_lua_rawseti(L, 1, i);
  marpa_lua_rawseti(L, 1, j);
}

static int sort_comp (lua_State *L, int a, int b) {
  if (!lua_isnil(L, 2)) {  /* function? */
    int res;
    marpa_lua_pushvalue(L, 2);
    marpa_lua_pushvalue(L, a-1);  /* -1 to compensate function */
    marpa_lua_pushvalue(L, b-2);  /* -2 to compensate function and `a' */
    marpa_lua_call(L, 2, 1);
    res = marpa_lua_toboolean(L, -1);
    lua_pop(L, 1);
    return res;
  }
  else  /* a < b? */
    return marpa_lua_lessthan(L, a, b);
}

static void auxsort (lua_State *L, int l, int u) {
  while (l < u) {  /* for tail recursion */
    int i, j;
    /* sort elements a[l], a[(l+u)/2] and a[u] */
    marpa_lua_rawgeti(L, 1, l);
    marpa_lua_rawgeti(L, 1, u);
    if (sort_comp(L, -1, -2))  /* a[u] < a[l]? */
      set2(L, l, u);  /* swap a[l] - a[u] */
    else
      lua_pop(L, 2);
    if (u-l == 1) break;  /* only 2 elements */
    i = (l+u)/2;
    marpa_lua_rawgeti(L, 1, i);
    marpa_lua_rawgeti(L, 1, l);
    if (sort_comp(L, -2, -1))  /* a[i]<a[l]? */
      set2(L, i, l);
    else {
      lua_pop(L, 1);  /* remove a[l] */
      marpa_lua_rawgeti(L, 1, u);
      if (sort_comp(L, -1, -2))  /* a[u]<a[i]? */
        set2(L, i, u);
      else
        lua_pop(L, 2);
    }
    if (u-l == 2) break;  /* only 3 elements */
    marpa_lua_rawgeti(L, 1, i);  /* Pivot */
    marpa_lua_pushvalue(L, -1);
    marpa_lua_rawgeti(L, 1, u-1);
    set2(L, i, u-1);
    /* a[l] <= P == a[u-1] <= a[u], only need to sort from l+1 to u-2 */
    i = l; j = u-1;
    for (;;) {  /* invariant: a[l..i] <= P <= a[j..u] */
      /* repeat ++i until a[i] >= P */
      while (marpa_lua_rawgeti(L, 1, ++i), sort_comp(L, -1, -2)) {
        if (i>u) marpa_luaL_error(L, "invalid order function for sorting");
        lua_pop(L, 1);  /* remove a[i] */
      }
      /* repeat --j until a[j] <= P */
      while (marpa_lua_rawgeti(L, 1, --j), sort_comp(L, -3, -1)) {
        if (j<l) marpa_luaL_error(L, "invalid order function for sorting");
        lua_pop(L, 1);  /* remove a[j] */
      }
      if (j<i) {
        lua_pop(L, 3);  /* pop pivot, a[i], a[j] */
        break;
      }
      set2(L, i, j);
    }
    marpa_lua_rawgeti(L, 1, u-1);
    marpa_lua_rawgeti(L, 1, i);
    set2(L, u-1, i);  /* swap pivot (a[u-1]) with a[i] */
    /* a[l..i-1] <= a[i] == P <= a[i+1..u] */
    /* adjust so that smaller half is in [j..i] and larger one in [l..u] */
    if (i-l < u-i) {
      j=l; i=i-1; l=i+2;
    }
    else {
      j=i+1; i=u; u=j-2;
    }
    auxsort(L, j, i);  /* call recursively the smaller one */
  }  /* repeat the routine for the larger one */
}

static int sort (lua_State *L) {
  int n = aux_getn(L, 1);
  marpa_luaL_checkstack(L, 40, "");  /* assume array is smaller than 2^40 */
  if (!lua_isnoneornil(L, 2))  /* is there a 2nd argument? */
    marpa_luaL_checktype(L, 2, LUA_TFUNCTION);
  marpa_lua_settop(L, 2);  /* make sure there is two arguments */
  auxsort(L, 1, n);
  return 0;
}

/* }====================================================== */


static const luaL_Reg tab_funcs[] = {
  {"concat", tconcat},
  {"foreach", foreach},
  {"foreachi", foreachi},
  {"getn", getn},
  {"maxn", maxn},
  {"insert", tinsert},
  {"remove", tremove},
  {"setn", setn},
  {"sort", sort},
  {NULL, NULL}
};


LUALIB_API int marpa_luaopen_table (lua_State *L) {
  marpa_luaL_register(L, LUA_TABLIBNAME, tab_funcs);
  return 1;
}

