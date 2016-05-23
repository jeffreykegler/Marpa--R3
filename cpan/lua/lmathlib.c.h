/*
** $Id: lmathlib.c,v 1.117 2015/10/02 15:39:23 roberto Exp $
** Standard mathematical library
** See Copyright Notice in lua.h
*/

#define lmathlib_c
#define LUA_LIB

#include "lprefix.h"


#include <stdlib.h>
#include <math.h>

#include "lua.h"

#include "lauxlib.h"
#include "lualib.h"


#undef PI
#define PI	(l_mathop(3.141592653589793238462643383279502884))


#if !defined(l_rand)		/* { */
#if defined(LUA_USE_POSIX)
#define l_rand()	random()
#define l_srand(x)	srandom(x)
#define L_RANDMAX	2147483647	/* (2^31 - 1), following POSIX */
#else
#define l_rand()	rand()
#define l_srand(x)	srand(x)
#define L_RANDMAX	RAND_MAX
#endif
#endif				/* } */


static int math_abs (lua_State *L) {
  if (marpa_lua_isinteger(L, 1)) {
    lua_Integer n = marpa_lua_tointeger(L, 1);
    if (n < 0) n = (lua_Integer)(0u - (lua_Unsigned)n);
    marpa_lua_pushinteger(L, n);
  }
  else
    marpa_lua_pushnumber(L, l_mathop(fabs)(marpa_luaL_checknumber(L, 1)));
  return 1;
}

static int math_sin (lua_State *L) {
  marpa_lua_pushnumber(L, l_mathop(sin)(marpa_luaL_checknumber(L, 1)));
  return 1;
}

static int math_cos (lua_State *L) {
  marpa_lua_pushnumber(L, l_mathop(cos)(marpa_luaL_checknumber(L, 1)));
  return 1;
}

static int math_tan (lua_State *L) {
  marpa_lua_pushnumber(L, l_mathop(tan)(marpa_luaL_checknumber(L, 1)));
  return 1;
}

static int math_asin (lua_State *L) {
  marpa_lua_pushnumber(L, l_mathop(asin)(marpa_luaL_checknumber(L, 1)));
  return 1;
}

static int math_acos (lua_State *L) {
  marpa_lua_pushnumber(L, l_mathop(acos)(marpa_luaL_checknumber(L, 1)));
  return 1;
}

static int math_atan (lua_State *L) {
  lua_Number y = marpa_luaL_checknumber(L, 1);
  lua_Number x = marpa_luaL_optnumber(L, 2, 1);
  marpa_lua_pushnumber(L, l_mathop(atan2)(y, x));
  return 1;
}


static int math_toint (lua_State *L) {
  int valid;
  lua_Integer n = marpa_lua_tointegerx(L, 1, &valid);
  if (valid)
    marpa_lua_pushinteger(L, n);
  else {
    marpa_luaL_checkany(L, 1);
    marpa_lua_pushnil(L);  /* value is not convertible to integer */
  }
  return 1;
}


static void pushnumint (lua_State *L, lua_Number d) {
  lua_Integer n;
  if (marpa_lua_numbertointeger(d, &n))  /* does 'd' fit in an integer? */
    marpa_lua_pushinteger(L, n);  /* result is integer */
  else
    marpa_lua_pushnumber(L, d);  /* result is float */
}


static int math_floor (lua_State *L) {
  if (marpa_lua_isinteger(L, 1))
    marpa_lua_settop(L, 1);  /* integer is its own floor */
  else {
    lua_Number d = l_mathop(floor)(marpa_luaL_checknumber(L, 1));
    pushnumint(L, d);
  }
  return 1;
}


static int math_ceil (lua_State *L) {
  if (marpa_lua_isinteger(L, 1))
    marpa_lua_settop(L, 1);  /* integer is its own ceil */
  else {
    lua_Number d = l_mathop(ceil)(marpa_luaL_checknumber(L, 1));
    pushnumint(L, d);
  }
  return 1;
}


static int math_fmod (lua_State *L) {
  if (marpa_lua_isinteger(L, 1) && marpa_lua_isinteger(L, 2)) {
    lua_Integer d = marpa_lua_tointeger(L, 2);
    if ((lua_Unsigned)d + 1u <= 1u) {  /* special cases: -1 or 0 */
      marpa_luaL_argcheck(L, d != 0, 2, "zero");
      marpa_lua_pushinteger(L, 0);  /* avoid overflow with 0x80000... / -1 */
    }
    else
      marpa_lua_pushinteger(L, marpa_lua_tointeger(L, 1) % d);
  }
  else
    marpa_lua_pushnumber(L, l_mathop(fmod)(marpa_luaL_checknumber(L, 1),
                                     marpa_luaL_checknumber(L, 2)));
  return 1;
}


/*
** next function does not use 'modf', avoiding problems with 'double*'
** (which is not compatible with 'float*') when lua_Number is not
** 'double'.
*/
static int math_modf (lua_State *L) {
  if (marpa_lua_isinteger(L ,1)) {
    marpa_lua_settop(L, 1);  /* number is its own integer part */
    marpa_lua_pushnumber(L, 0);  /* no fractional part */
  }
  else {
    lua_Number n = marpa_luaL_checknumber(L, 1);
    /* integer part (rounds toward zero) */
    lua_Number ip = (n < 0) ? l_mathop(ceil)(n) : l_mathop(floor)(n);
    pushnumint(L, ip);
    /* fractional part (test needed for inf/-inf) */
    marpa_lua_pushnumber(L, (n == ip) ? l_mathop(0.0) : (n - ip));
  }
  return 2;
}


static int math_sqrt (lua_State *L) {
  marpa_lua_pushnumber(L, l_mathop(sqrt)(marpa_luaL_checknumber(L, 1)));
  return 1;
}


static int math_ult (lua_State *L) {
  lua_Integer a = marpa_luaL_checkinteger(L, 1);
  lua_Integer b = marpa_luaL_checkinteger(L, 2);
  marpa_lua_pushboolean(L, (lua_Unsigned)a < (lua_Unsigned)b);
  return 1;
}

static int math_log (lua_State *L) {
  lua_Number x = marpa_luaL_checknumber(L, 1);
  lua_Number res;
  if (marpa_lua_isnoneornil(L, 2))
    res = l_mathop(log)(x);
  else {
    lua_Number base = marpa_luaL_checknumber(L, 2);
#if !defined(LUA_USE_C89)
    if (base == 2.0) res = l_mathop(log2)(x); else
#endif
    if (base == 10.0) res = l_mathop(log10)(x);
    else res = l_mathop(log)(x)/l_mathop(log)(base);
  }
  marpa_lua_pushnumber(L, res);
  return 1;
}

static int math_exp (lua_State *L) {
  marpa_lua_pushnumber(L, l_mathop(exp)(marpa_luaL_checknumber(L, 1)));
  return 1;
}

static int math_deg (lua_State *L) {
  marpa_lua_pushnumber(L, marpa_luaL_checknumber(L, 1) * (l_mathop(180.0) / PI));
  return 1;
}

static int math_rad (lua_State *L) {
  marpa_lua_pushnumber(L, marpa_luaL_checknumber(L, 1) * (PI / l_mathop(180.0)));
  return 1;
}


static int math_min (lua_State *L) {
  int n = marpa_lua_gettop(L);  /* number of arguments */
  int imin = 1;  /* index of current minimum value */
  int i;
  marpa_luaL_argcheck(L, n >= 1, 1, "value expected");
  for (i = 2; i <= n; i++) {
    if (marpa_lua_compare(L, i, imin, LUA_OPLT))
      imin = i;
  }
  marpa_lua_pushvalue(L, imin);
  return 1;
}


static int math_max (lua_State *L) {
  int n = marpa_lua_gettop(L);  /* number of arguments */
  int imax = 1;  /* index of current maximum value */
  int i;
  marpa_luaL_argcheck(L, n >= 1, 1, "value expected");
  for (i = 2; i <= n; i++) {
    if (marpa_lua_compare(L, imax, i, LUA_OPLT))
      imax = i;
  }
  marpa_lua_pushvalue(L, imax);
  return 1;
}

/*
** This function uses 'double' (instead of 'lua_Number') to ensure that
** all bits from 'l_rand' can be represented, and that 'RANDMAX + 1.0'
** will keep full precision (ensuring that 'r' is always less than 1.0.)
*/
static int math_random (lua_State *L) {
  lua_Integer low, up;
  double r = (double)l_rand() * (1.0 / ((double)L_RANDMAX + 1.0));
  switch (marpa_lua_gettop(L)) {  /* check number of arguments */
    case 0: {  /* no arguments */
      marpa_lua_pushnumber(L, (lua_Number)r);  /* Number between 0 and 1 */
      return 1;
    }
    case 1: {  /* only upper limit */
      low = 1;
      up = marpa_luaL_checkinteger(L, 1);
      break;
    }
    case 2: {  /* lower and upper limits */
      low = marpa_luaL_checkinteger(L, 1);
      up = marpa_luaL_checkinteger(L, 2);
      break;
    }
    default: return marpa_luaL_error(L, "wrong number of arguments");
  }
  /* random integer in the interval [low, up] */
  marpa_luaL_argcheck(L, low <= up, 1, "interval is empty"); 
  marpa_luaL_argcheck(L, low >= 0 || up <= LUA_MAXINTEGER + low, 1,
                   "interval too large");
  r *= (double)(up - low) + 1.0;
  marpa_lua_pushinteger(L, (lua_Integer)r + low);
  return 1;
}


static int math_randomseed (lua_State *L) {
  l_srand((unsigned int)(lua_Integer)marpa_luaL_checknumber(L, 1));
  (void)l_rand(); /* discard first value to avoid undesirable correlations */
  return 0;
}


static int math_type (lua_State *L) {
  if (marpa_lua_type(L, 1) == LUA_TNUMBER) {
      if (marpa_lua_isinteger(L, 1))
        marpa_lua_pushliteral(L, "integer"); 
      else
        marpa_lua_pushliteral(L, "float"); 
  }
  else {
    marpa_luaL_checkany(L, 1);
    marpa_lua_pushnil(L);
  }
  return 1;
}


/*
** {==================================================================
** Deprecated functions (for compatibility only)
** ===================================================================
*/
#if defined(LUA_COMPAT_MATHLIB)

static int math_cosh (lua_State *L) {
  marpa_lua_pushnumber(L, l_mathop(cosh)(marpa_luaL_checknumber(L, 1)));
  return 1;
}

static int math_sinh (lua_State *L) {
  marpa_lua_pushnumber(L, l_mathop(sinh)(marpa_luaL_checknumber(L, 1)));
  return 1;
}

static int math_tanh (lua_State *L) {
  marpa_lua_pushnumber(L, l_mathop(tanh)(marpa_luaL_checknumber(L, 1)));
  return 1;
}

static int math_pow (lua_State *L) {
  lua_Number x = marpa_luaL_checknumber(L, 1);
  lua_Number y = marpa_luaL_checknumber(L, 2);
  marpa_lua_pushnumber(L, l_mathop(pow)(x, y));
  return 1;
}

static int math_frexp (lua_State *L) {
  int e;
  marpa_lua_pushnumber(L, l_mathop(frexp)(marpa_luaL_checknumber(L, 1), &e));
  marpa_lua_pushinteger(L, e);
  return 2;
}

static int math_ldexp (lua_State *L) {
  lua_Number x = marpa_luaL_checknumber(L, 1);
  int ep = (int)marpa_luaL_checkinteger(L, 2);
  marpa_lua_pushnumber(L, l_mathop(ldexp)(x, ep));
  return 1;
}

static int math_log10 (lua_State *L) {
  marpa_lua_pushnumber(L, l_mathop(log10)(marpa_luaL_checknumber(L, 1)));
  return 1;
}

#endif
/* }================================================================== */



static const luaL_Reg mathlib[] = {
  {"abs",   math_abs},
  {"acos",  math_acos},
  {"asin",  math_asin},
  {"atan",  math_atan},
  {"ceil",  math_ceil},
  {"cos",   math_cos},
  {"deg",   math_deg},
  {"exp",   math_exp},
  {"tointeger", math_toint},
  {"floor", math_floor},
  {"fmod",   math_fmod},
  {"ult",   math_ult},
  {"log",   math_log},
  {"max",   math_max},
  {"min",   math_min},
  {"modf",   math_modf},
  {"rad",   math_rad},
  {"random",     math_random},
  {"randomseed", math_randomseed},
  {"sin",   math_sin},
  {"sqrt",  math_sqrt},
  {"tan",   math_tan},
  {"type", math_type},
#if defined(LUA_COMPAT_MATHLIB)
  {"atan2", math_atan},
  {"cosh",   math_cosh},
  {"sinh",   math_sinh},
  {"tanh",   math_tanh},
  {"pow",   math_pow},
  {"frexp", math_frexp},
  {"ldexp", math_ldexp},
  {"log10", math_log10},
#endif
  /* placeholders */
  {"pi", NULL},
  {"huge", NULL},
  {"maxinteger", NULL},
  {"mininteger", NULL},
  {NULL, NULL}
};


/*
** Open math library
*/
LUAMOD_API int marpa_luaopen_math (lua_State *L) {
  marpa_luaL_newlib(L, mathlib);
  marpa_lua_pushnumber(L, PI);
  marpa_lua_setfield(L, -2, "pi");
  marpa_lua_pushnumber(L, (lua_Number)HUGE_VAL);
  marpa_lua_setfield(L, -2, "huge");
  marpa_lua_pushinteger(L, LUA_MAXINTEGER);
  marpa_lua_setfield(L, -2, "maxinteger");
  marpa_lua_pushinteger(L, LUA_MININTEGER);
  marpa_lua_setfield(L, -2, "mininteger");
  return 1;
}

