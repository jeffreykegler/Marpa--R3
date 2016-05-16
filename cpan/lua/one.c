/*
* one.c -- Lua core, libraries, and interpreter in a single file
*/

/* default is to build the library */
#ifndef MAKE_LIB
#ifndef MAKE_LUAC
#ifndef MAKE_LUA
#define MAKE_LIB
#endif
#endif
#endif

/* no need to change anything below this line ----------------------------- */

/* setup for luaconf.h */
#define LUA_CORE
#define LUA_LIB
#define ltable_c
#define lvm_c
#include "luaconf.h"

/* do not export internal symbols */
#undef LUAI_FUNC
#undef LUAI_DDEC
#undef LUAI_DDEF
#define LUAI_FUNC	static
#define LUAI_DDEC	static
#define LUAI_DDEF	static

/* core -- used by all */
#include "lapi.c.h"
#include "lcode.c.h"
#include "lctype.c.h"
#include "ldebug.c.h"
#include "ldo.c.h"
#include "ldump.c.h"
#include "lfunc.c.h"
#include "lgc.c.h"
#include "llex.c.h"
#include "lmem.c.h"
#include "lobject.c.h"
#include "lopcodes.c.h"
#include "lparser.c.h"
#include "lstate.c.h"
#include "lstring.c.h"
#include "ltable.c.h"
#include "ltm.c.h"
#include "lundump.c.h"
#include "lvm.c.h"
#include "lzio.c.h"

/* auxiliary library -- used by all */
#include "lauxlib.c.h"

/* standard library  -- not used by luac */
#ifndef MAKE_LUAC
#include "lbaselib.c.h"
#include "lbitlib.c.h"
#include "lcorolib.c.h"
#include "ldblib.c.h"
#include "liolib.c.h"
#include "lmathlib.c.h"
#include "loadlib.c.h"
#include "loslib.c.h"
#include "lstrlib.c.h"
#include "ltablib.c.h"
#include "lutf8lib.c.h"
#include "linit.c.h"
#endif

/* lua */
#ifdef MAKE_LUA
#include "lua.c.h"
#endif

/* luac */
#ifdef MAKE_LUAC
#include "luac.c.h"
#endif
