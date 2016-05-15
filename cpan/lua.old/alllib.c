/*
* all.c.h -- Lua core and libraries in a single file
* library only -- no interpreter
*/

#define luaall_c

#include "lapi.c.h"
#include "lcode.c.h"
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

#include "lauxlib.c.h"
#include "lbaselib.c.h"
#include "ldblib.c.h"
#include "liolib.c.h"
#include "linit.c.h"
#include "lmathlib.c.h"
#include "loadlib.c.h"
#include "loslib.c.h"
#include "lstrlib.c.h"
#include "ltablib.c.h"

