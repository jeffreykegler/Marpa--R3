/*
** $Id: ltablib.c,v 1.90 2015/11/25 12:48:57 roberto Exp $
** Library for Table Manipulation
** See Copyright Notice in lua.h
*/

#define ltablib_c
#define LUA_LIB

#include "lprefix.h"


#include <limits.h>
#include <stddef.h>
#include <string.h>

#include "lua.h"

#include "lauxlib.h"
#include "lualib.h"


/*
** Operations that an object must define to mimic a table
** (some functions only need some of them)
*/
#define TAB_R	1			/* read */
#define TAB_W	2			/* write */
#define TAB_L	4			/* length */
#define TAB_RW	(TAB_R | TAB_W)		/* read/write */


#define aux_getn(L,n,w)	(checktab(L, n, (w) | TAB_L), marpa_luaL_len(L, n))


static int checkfield (lua_State *L, const char *key, int n) {
  marpa_lua_pushstring(L, key);
  return (marpa_lua_rawget(L, -n) != LUA_TNIL);
}


/*
** Check that 'arg' either is a table or can behave like one (that is,
** has a metatable with the required metamethods)
*/
static void checktab (lua_State *L, int arg, int what) {
  if (marpa_lua_type(L, arg) != LUA_TTABLE) {  /* is it not a table? */
    int n = 1;  /* number of elements to pop */
    if (marpa_lua_getmetatable(L, arg) &&  /* must have metatable */
        (!(what & TAB_R) || checkfield(L, "__index", ++n)) &&
        (!(what & TAB_W) || checkfield(L, "__newindex", ++n)) &&
        (!(what & TAB_L) || checkfield(L, "__len", ++n))) {
      marpa_lua_pop(L, n);  /* pop metatable and tested metamethods */
    }
    else
      marpa_luaL_argerror(L, arg, "table expected");  /* force an error */
  }
}


#if defined(LUA_COMPAT_MAXN)
static int maxn (lua_State *L) {
  lua_Number max = 0;
  marpa_luaL_checktype(L, 1, LUA_TTABLE);
  marpa_lua_pushnil(L);  /* first key */
  while (marpa_lua_next(L, 1)) {
    marpa_lua_pop(L, 1);  /* remove value */
    if (marpa_lua_type(L, -1) == LUA_TNUMBER) {
      lua_Number v = marpa_lua_tonumber(L, -1);
      if (v > max) max = v;
    }
  }
  marpa_lua_pushnumber(L, max);
  return 1;
}
#endif


static int tinsert (lua_State *L) {
  lua_Integer e = aux_getn(L, 1, TAB_RW) + 1;  /* first empty element */
  lua_Integer pos;  /* where to insert new element */
  switch (marpa_lua_gettop(L)) {
    case 2: {  /* called with only 2 arguments */
      pos = e;  /* insert new element at the end */
      break;
    }
    case 3: {
      lua_Integer i;
      pos = marpa_luaL_checkinteger(L, 2);  /* 2nd argument is the position */
      marpa_luaL_argcheck(L, 1 <= pos && pos <= e, 2, "position out of bounds");
      for (i = e; i > pos; i--) {  /* move up elements */
        marpa_lua_geti(L, 1, i - 1);
        marpa_lua_seti(L, 1, i);  /* t[i] = t[i - 1] */
      }
      break;
    }
    default: {
      return marpa_luaL_error(L, "wrong number of arguments to 'insert'");
    }
  }
  marpa_lua_seti(L, 1, pos);  /* t[pos] = v */
  return 0;
}


static int tremove (lua_State *L) {
  lua_Integer size = aux_getn(L, 1, TAB_RW);
  lua_Integer pos = marpa_luaL_optinteger(L, 2, size);
  if (pos != size)  /* validate 'pos' if given */
    marpa_luaL_argcheck(L, 1 <= pos && pos <= size + 1, 1, "position out of bounds");
  marpa_lua_geti(L, 1, pos);  /* result = t[pos] */
  for ( ; pos < size; pos++) {
    marpa_lua_geti(L, 1, pos + 1);
    marpa_lua_seti(L, 1, pos);  /* t[pos] = t[pos + 1] */
  }
  marpa_lua_pushnil(L);
  marpa_lua_seti(L, 1, pos);  /* t[pos] = nil */
  return 1;
}


/*
** Copy elements (1[f], ..., 1[e]) into (tt[t], tt[t+1], ...). Whenever
** possible, copy in increasing order, which is better for rehashing.
** "possible" means destination after original range, or smaller
** than origin, or copying to another table.
*/
static int tmove (lua_State *L) {
  lua_Integer f = marpa_luaL_checkinteger(L, 2);
  lua_Integer e = marpa_luaL_checkinteger(L, 3);
  lua_Integer t = marpa_luaL_checkinteger(L, 4);
  int tt = !marpa_lua_isnoneornil(L, 5) ? 5 : 1;  /* destination table */
  checktab(L, 1, TAB_R);
  checktab(L, tt, TAB_W);
  if (e >= f) {  /* otherwise, nothing to move */
    lua_Integer n, i;
    marpa_luaL_argcheck(L, f > 0 || e < LUA_MAXINTEGER + f, 3,
                  "too many elements to move");
    n = e - f + 1;  /* number of elements to move */
    marpa_luaL_argcheck(L, t <= LUA_MAXINTEGER - n + 1, 4,
                  "destination wrap around");
    if (t > e || t <= f || tt != 1) {
      for (i = 0; i < n; i++) {
        marpa_lua_geti(L, 1, f + i);
        marpa_lua_seti(L, tt, t + i);
      }
    }
    else {
      for (i = n - 1; i >= 0; i--) {
        marpa_lua_geti(L, 1, f + i);
        marpa_lua_seti(L, tt, t + i);
      }
    }
  }
  marpa_lua_pushvalue(L, tt);  /* return "to table" */
  return 1;
}


static void addfield (lua_State *L, luaL_Buffer *b, lua_Integer i) {
  marpa_lua_geti(L, 1, i);
  if (!marpa_lua_isstring(L, -1))
    marpa_luaL_error(L, "invalid value (%s) at index %d in table for 'concat'",
                  marpa_luaL_typename(L, -1), i);
  marpa_luaL_addvalue(b);
}


static int tconcat (lua_State *L) {
  luaL_Buffer b;
  lua_Integer last = aux_getn(L, 1, TAB_R);
  size_t lsep;
  const char *sep = marpa_luaL_optlstring(L, 2, "", &lsep);
  lua_Integer i = marpa_luaL_optinteger(L, 3, 1);
  last = marpa_luaL_opt(L, marpa_luaL_checkinteger, 4, last);
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
** Pack/unpack
** =======================================================
*/

static int pack (lua_State *L) {
  int i;
  int n = marpa_lua_gettop(L);  /* number of elements to pack */
  marpa_lua_createtable(L, n, 1);  /* create result table */
  marpa_lua_insert(L, 1);  /* put it at index 1 */
  for (i = n; i >= 1; i--)  /* assign elements */
    marpa_lua_seti(L, 1, i);
  marpa_lua_pushinteger(L, n);
  marpa_lua_setfield(L, 1, "n");  /* t.n = number of elements */
  return 1;  /* return table */
}


static int unpack (lua_State *L) {
  lua_Unsigned n;
  lua_Integer i = marpa_luaL_optinteger(L, 2, 1);
  lua_Integer e = marpa_luaL_opt(L, marpa_luaL_checkinteger, 3, marpa_luaL_len(L, 1));
  if (i > e) return 0;  /* empty range */
  n = (lua_Unsigned)e - i;  /* number of elements minus 1 (avoid overflows) */
  if (n >= (unsigned int)INT_MAX  || !marpa_lua_checkstack(L, (int)(++n)))
    return marpa_luaL_error(L, "too many results to unpack");
  for (; i < e; i++) {  /* push arg[i..e - 1] (to avoid overflows) */
    marpa_lua_geti(L, 1, i);
  }
  marpa_lua_geti(L, 1, e);  /* push last element */
  return (int)n;
}

/* }====================================================== */



/*
** {======================================================
** Quicksort
** (based on 'Algorithms in MODULA-3', Robert Sedgewick;
**  Addison-Wesley, 1993.)
** =======================================================
*/


/*
** Produce a "random" 'unsigned int' to randomize pivot choice. This
** macro is used only when 'sort' detects a big imbalance in the result
** of a partition. (If you don't want/need this "randomness", ~0 is a
** good choice.)
*/
#if !defined(l_randomizePivot)		/* { */

#include <time.h>

/* size of 'e' measured in number of 'unsigned int's */
#define sof(e)		(sizeof(e) / sizeof(unsigned int))

/*
** Use 'time' and 'clock' as sources of "randomness". Because we don't
** know the types 'clock_t' and 'time_t', we cannot cast them to
** anything without risking overflows. A safe way to use their values
** is to copy them to an array of a known type and use the array values.
*/
static unsigned int l_randomizePivot (void) {
  clock_t c = clock();
  time_t t = time(NULL);
  unsigned int buff[sof(c) + sof(t)];
  unsigned int i, rnd = 0;
  memcpy(buff, &c, sof(c) * sizeof(unsigned int));
  memcpy(buff + sof(c), &t, sof(t) * sizeof(unsigned int));
  for (i = 0; i < sof(buff); i++)
    rnd += buff[i];
  return rnd;
}

#endif					/* } */


/* arrays larger than 'RANLIMIT' may use randomized pivots */
#define RANLIMIT	100u


static void set2 (lua_State *L, unsigned int i, unsigned int j) {
  marpa_lua_seti(L, 1, i);
  marpa_lua_seti(L, 1, j);
}


/*
** Return true iff value at stack index 'a' is less than the value at
** index 'b' (according to the order of the sort).
*/
static int sort_comp (lua_State *L, int a, int b) {
  if (marpa_lua_isnil(L, 2))  /* no function? */
    return marpa_lua_compare(L, a, b, LUA_OPLT);  /* a < b */
  else {  /* function */
    int res;
    marpa_lua_pushvalue(L, 2);    /* push function */
    marpa_lua_pushvalue(L, a-1);  /* -1 to compensate function */
    marpa_lua_pushvalue(L, b-2);  /* -2 to compensate function and 'a' */
    marpa_lua_call(L, 2, 1);      /* call function */
    res = marpa_lua_toboolean(L, -1);  /* get result */
    marpa_lua_pop(L, 1);          /* pop result */
    return res;
  }
}


/*
** Does the partition: Pivot P is at the top of the stack.
** precondition: a[lo] <= P == a[up-1] <= a[up],
** so it only needs to do the partition from lo + 1 to up - 2.
** Pos-condition: a[lo .. i - 1] <= a[i] == P <= a[i + 1 .. up]
** returns 'i'.
*/
static unsigned int partition (lua_State *L, unsigned int lo,
                                             unsigned int up) {
  unsigned int i = lo;  /* will be incremented before first use */
  unsigned int j = up - 1;  /* will be decremented before first use */
  /* loop invariant: a[lo .. i] <= P <= a[j .. up] */
  for (;;) {
    /* next loop: repeat ++i while a[i] < P */
    while (marpa_lua_geti(L, 1, ++i), sort_comp(L, -1, -2)) {
      if (i == up - 1)  /* a[i] < P  but a[up - 1] == P  ?? */
        marpa_luaL_error(L, "invalid order function for sorting");
      marpa_lua_pop(L, 1);  /* remove a[i] */
    }
    /* after the loop, a[i] >= P and a[lo .. i - 1] < P */
    /* next loop: repeat --j while P < a[j] */
    while (marpa_lua_geti(L, 1, --j), sort_comp(L, -3, -1)) {
      if (j < i)  /* j < i  but  a[j] > P ?? */
        marpa_luaL_error(L, "invalid order function for sorting");
      marpa_lua_pop(L, 1);  /* remove a[j] */
    }
    /* after the loop, a[j] <= P and a[j + 1 .. up] >= P */
    if (j < i) {  /* no elements out of place? */
      /* a[lo .. i - 1] <= P <= a[j + 1 .. i .. up] */
      marpa_lua_pop(L, 1);  /* pop a[j] */
      /* swap pivot (a[up - 1]) with a[i] to satisfy pos-condition */
      set2(L, up - 1, i);
      return i;
    }
    /* otherwise, swap a[i] - a[j] to restore invariant and repeat */
    set2(L, i, j);
  }
}


/*
** Choose an element in the middle (2nd-3th quarters) of [lo,up]
** "randomized" by 'rnd'
*/
static unsigned int choosePivot (unsigned int lo, unsigned int up,
                                 unsigned int rnd) {
  unsigned int r4 = (unsigned int)(up - lo) / 4u;  /* range/4 */
  unsigned int p = rnd % (r4 * 2) + (lo + r4);
  lua_assert(lo + r4 <= p && p <= up - r4);
  return p;
}


/*
** QuickSort algorithm (recursive function)
*/
static void auxsort (lua_State *L, unsigned int lo, unsigned int up,
                                   unsigned int rnd) {
  while (lo < up) {  /* loop for tail recursion */
    unsigned int p;  /* Pivot index */
    unsigned int n;  /* to be used later */
    /* sort elements 'lo', 'p', and 'up' */
    marpa_lua_geti(L, 1, lo);
    marpa_lua_geti(L, 1, up);
    if (sort_comp(L, -1, -2))  /* a[up] < a[lo]? */
      set2(L, lo, up);  /* swap a[lo] - a[up] */
    else
      marpa_lua_pop(L, 2);  /* remove both values */
    if (up - lo == 1)  /* only 2 elements? */
      return;  /* already sorted */
    if (up - lo < RANLIMIT || rnd == 0)  /* small interval or no randomize? */
      p = (lo + up)/2;  /* middle element is a good pivot */
    else  /* for larger intervals, it is worth a random pivot */
      p = choosePivot(lo, up, rnd);
    marpa_lua_geti(L, 1, p);
    marpa_lua_geti(L, 1, lo);
    if (sort_comp(L, -2, -1))  /* a[p] < a[lo]? */
      set2(L, p, lo);  /* swap a[p] - a[lo] */
    else {
      marpa_lua_pop(L, 1);  /* remove a[lo] */
      marpa_lua_geti(L, 1, up);
      if (sort_comp(L, -1, -2))  /* a[up] < a[p]? */
        set2(L, p, up);  /* swap a[up] - a[p] */
      else
        marpa_lua_pop(L, 2);
    }
    if (up - lo == 2)  /* only 3 elements? */
      return;  /* already sorted */
    marpa_lua_geti(L, 1, p);  /* get middle element (Pivot) */
    marpa_lua_pushvalue(L, -1);  /* push Pivot */
    marpa_lua_geti(L, 1, up - 1);  /* push a[up - 1] */
    set2(L, p, up - 1);  /* swap Pivot (a[p]) with a[up - 1] */
    p = partition(L, lo, up);
    /* a[lo .. p - 1] <= a[p] == P <= a[p + 1 .. up] */
    if (p - lo < up - p) {  /* lower interval is smaller? */
      auxsort(L, lo, p - 1, rnd);  /* call recursively for lower interval */
      n = p - lo;  /* size of smaller interval */
      lo = p + 1;  /* tail call for [p + 1 .. up] (upper interval) */
    }
    else {
      auxsort(L, p + 1, up, rnd);  /* call recursively for upper interval */
      n = up - p;  /* size of smaller interval */
      up = p - 1;  /* tail call for [lo .. p - 1]  (lower interval) */
    }
    if ((up - lo) / 128u > n) /* partition too imbalanced? */
      rnd = l_randomizePivot();  /* try a new randomization */
  }  /* tail call auxsort(L, lo, up, rnd) */
}


static int sort (lua_State *L) {
  lua_Integer n = aux_getn(L, 1, TAB_RW);
  if (n > 1) {  /* non-trivial interval? */
    marpa_luaL_argcheck(L, n < INT_MAX, 1, "array too big");
    marpa_luaL_checkstack(L, 40, "");  /* assume array is smaller than 2^40 */
    if (!marpa_lua_isnoneornil(L, 2))  /* is there a 2nd argument? */
      marpa_luaL_checktype(L, 2, LUA_TFUNCTION);  /* must be a function */
    marpa_lua_settop(L, 2);  /* make sure there are two arguments */
    auxsort(L, 1, (unsigned int)n, 0u);
  }
  return 0;
}

/* }====================================================== */


static const luaL_Reg tab_funcs[] = {
  {"concat", tconcat},
#if defined(LUA_COMPAT_MAXN)
  {"maxn", maxn},
#endif
  {"insert", tinsert},
  {"pack", pack},
  {"unpack", unpack},
  {"remove", tremove},
  {"move", tmove},
  {"sort", sort},
  {NULL, NULL}
};


LUAMOD_API int marpa_luaopen_table (lua_State *L) {
  marpa_luaL_newlib(L, tab_funcs);
#if defined(LUA_COMPAT_UNPACK)
  /* _G.unpack = table.unpack */
  marpa_lua_getfield(L, -1, "unpack");
  marpa_lua_setglobal(L, "unpack");
#endif
  return 1;
}

