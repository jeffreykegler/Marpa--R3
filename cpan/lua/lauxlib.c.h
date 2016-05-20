/*
** $Id: lauxlib.c,v 1.284 2015/11/19 19:16:22 roberto Exp $
** Auxiliary functions for building Lua libraries
** See Copyright Notice in lua.h
*/

#define lauxlib_c
#define LUA_LIB

#include "lprefix.h"


#include <errno.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


/* This file uses only the official API of Lua.
** Any function declared here could be written as an application function.
*/

#include "lua.h"

#include "lauxlib.h"


/*
** {======================================================
** Traceback
** =======================================================
*/


#define LEVELS1	10	/* size of the first part of the stack */
#define LEVELS2	11	/* size of the second part of the stack */



/*
** search for 'objidx' in table at index -1.
** return 1 + string at top if find a good name.
*/
static int findfield (lua_State *L, int objidx, int level) {
  if (level == 0 || !marpa_lua_istable(L, -1))
    return 0;  /* not found */
  marpa_lua_pushnil(L);  /* start 'next' loop */
  while (marpa_lua_next(L, -2)) {  /* for each pair in table */
    if (marpa_lua_type(L, -2) == LUA_TSTRING) {  /* ignore non-string keys */
      if (marpa_lua_rawequal(L, objidx, -1)) {  /* found object? */
        marpa_lua_pop(L, 1);  /* remove value (but keep name) */
        return 1;
      }
      else if (findfield(L, objidx, level - 1)) {  /* try recursively */
        marpa_lua_remove(L, -2);  /* remove table (but keep name) */
        marpa_lua_pushliteral(L, ".");
        marpa_lua_insert(L, -2);  /* place '.' between the two names */
        marpa_lua_concat(L, 3);
        return 1;
      }
    }
    marpa_lua_pop(L, 1);  /* remove value */
  }
  return 0;  /* not found */
}


/*
** Search for a name for a function in all loaded modules
** (registry._LOADED).
*/
static int pushglobalfuncname (lua_State *L, lua_Debug *ar) {
  int top = marpa_lua_gettop(L);
  marpa_lua_getinfo(L, "f", ar);  /* push function */
  marpa_lua_getfield(L, LUA_REGISTRYINDEX, "_LOADED");
  if (findfield(L, top + 1, 2)) {
    const char *name = marpa_lua_tostring(L, -1);
    if (strncmp(name, "_G.", 3) == 0) {  /* name start with '_G.'? */
      marpa_lua_pushstring(L, name + 3);  /* push name without prefix */
      marpa_lua_remove(L, -2);  /* remove original name */
    }
    marpa_lua_copy(L, -1, top + 1);  /* move name to proper place */
    marpa_lua_pop(L, 2);  /* remove pushed values */
    return 1;
  }
  else {
    marpa_lua_settop(L, top);  /* remove function and global table */
    return 0;
  }
}


static void pushfuncname (lua_State *L, lua_Debug *ar) {
  if (pushglobalfuncname(L, ar)) {  /* try first a global name */
    marpa_lua_pushfstring(L, "function '%s'", marpa_lua_tostring(L, -1));
    marpa_lua_remove(L, -2);  /* remove name */
  }
  else if (*ar->namewhat != '\0')  /* is there a name from code? */
    marpa_lua_pushfstring(L, "%s '%s'", ar->namewhat, ar->name);  /* use it */
  else if (*ar->what == 'm')  /* main? */
      marpa_lua_pushliteral(L, "main chunk");
  else if (*ar->what != 'C')  /* for Lua functions, use <file:line> */
    marpa_lua_pushfstring(L, "function <%s:%d>", ar->short_src, ar->linedefined);
  else  /* nothing left... */
    marpa_lua_pushliteral(L, "?");
}


static int lastlevel (lua_State *L) {
  lua_Debug ar;
  int li = 1, le = 1;
  /* find an upper bound */
  while (marpa_lua_getstack(L, le, &ar)) { li = le; le *= 2; }
  /* do a binary search */
  while (li < le) {
    int m = (li + le)/2;
    if (marpa_lua_getstack(L, m, &ar)) li = m + 1;
    else le = m;
  }
  return le - 1;
}


LUALIB_API void marpa_luaL_traceback (lua_State *L, lua_State *L1,
                                const char *msg, int level) {
  lua_Debug ar;
  int top = marpa_lua_gettop(L);
  int last = lastlevel(L1);
  int n1 = (last - level > LEVELS1 + LEVELS2) ? LEVELS1 : -1;
  if (msg)
    marpa_lua_pushfstring(L, "%s\n", msg);
  marpa_luaL_checkstack(L, 10, NULL);
  marpa_lua_pushliteral(L, "stack traceback:");
  while (marpa_lua_getstack(L1, level++, &ar)) {
    if (n1-- == 0) {  /* too many levels? */
      marpa_lua_pushliteral(L, "\n\t...");  /* add a '...' */
      level = last - LEVELS2 + 1;  /* and skip to last ones */
    }
    else {
      marpa_lua_getinfo(L1, "Slnt", &ar);
      marpa_lua_pushfstring(L, "\n\t%s:", ar.short_src);
      if (ar.currentline > 0)
        marpa_lua_pushfstring(L, "%d:", ar.currentline);
      marpa_lua_pushliteral(L, " in ");
      pushfuncname(L, &ar);
      if (ar.istailcall)
        marpa_lua_pushliteral(L, "\n\t(...tail calls...)");
      marpa_lua_concat(L, marpa_lua_gettop(L) - top);
    }
  }
  marpa_lua_concat(L, marpa_lua_gettop(L) - top);
}

/* }====================================================== */


/*
** {======================================================
** Error-report functions
** =======================================================
*/

LUALIB_API int marpa_luaL_argerror (lua_State *L, int arg, const char *extramsg) {
  lua_Debug ar;
  if (!marpa_lua_getstack(L, 0, &ar))  /* no stack frame? */
    return marpa_luaL_error(L, "bad argument #%d (%s)", arg, extramsg);
  marpa_lua_getinfo(L, "n", &ar);
  if (strcmp(ar.namewhat, "method") == 0) {
    arg--;  /* do not count 'self' */
    if (arg == 0)  /* error is in the self argument itself? */
      return marpa_luaL_error(L, "calling '%s' on bad self (%s)",
                           ar.name, extramsg);
  }
  if (ar.name == NULL)
    ar.name = (pushglobalfuncname(L, &ar)) ? marpa_lua_tostring(L, -1) : "?";
  return marpa_luaL_error(L, "bad argument #%d to '%s' (%s)",
                        arg, ar.name, extramsg);
}


static int typeerror (lua_State *L, int arg, const char *tname) {
  const char *msg;
  const char *typearg;  /* name for the type of the actual argument */
  if (marpa_luaL_getmetafield(L, arg, "__name") == LUA_TSTRING)
    typearg = marpa_lua_tostring(L, -1);  /* use the given type name */
  else if (marpa_lua_type(L, arg) == LUA_TLIGHTUSERDATA)
    typearg = "light userdata";  /* special name for messages */
  else
    typearg = luaL_typename(L, arg);  /* standard name */
  msg = marpa_lua_pushfstring(L, "%s expected, got %s", tname, typearg);
  return marpa_luaL_argerror(L, arg, msg);
}


static void tag_error (lua_State *L, int arg, int tag) {
  typeerror(L, arg, marpa_lua_typename(L, tag));
}


LUALIB_API void marpa_luaL_where (lua_State *L, int level) {
  lua_Debug ar;
  if (marpa_lua_getstack(L, level, &ar)) {  /* check function at level */
    marpa_lua_getinfo(L, "Sl", &ar);  /* get info about it */
    if (ar.currentline > 0) {  /* is there info? */
      marpa_lua_pushfstring(L, "%s:%d: ", ar.short_src, ar.currentline);
      return;
    }
  }
  marpa_lua_pushliteral(L, "");  /* else, no information available... */
}


LUALIB_API int marpa_luaL_error (lua_State *L, const char *fmt, ...) {
  va_list argp;
  va_start(argp, fmt);
  marpa_luaL_where(L, 1);
  marpa_lua_pushvfstring(L, fmt, argp);
  va_end(argp);
  marpa_lua_concat(L, 2);
  return marpa_lua_error(L);
}


LUALIB_API int marpa_luaL_fileresult (lua_State *L, int stat, const char *fname) {
  int en = errno;  /* calls to Lua API may change this value */
  if (stat) {
    marpa_lua_pushboolean(L, 1);
    return 1;
  }
  else {
    marpa_lua_pushnil(L);
    if (fname)
      marpa_lua_pushfstring(L, "%s: %s", fname, strerror(en));
    else
      marpa_lua_pushstring(L, strerror(en));
    marpa_lua_pushinteger(L, en);
    return 3;
  }
}


#if !defined(l_inspectstat)	/* { */

#if defined(LUA_USE_POSIX)

#include <sys/wait.h>

/*
** use appropriate macros to interpret 'pclose' return status
*/
#define l_inspectstat(stat,what)  \
   if (WIFEXITED(stat)) { stat = WEXITSTATUS(stat); } \
   else if (WIFSIGNALED(stat)) { stat = WTERMSIG(stat); what = "signal"; }

#else

#define l_inspectstat(stat,what)  /* no op */

#endif

#endif				/* } */


LUALIB_API int marpa_luaL_execresult (lua_State *L, int stat) {
  const char *what = "exit";  /* type of termination */
  if (stat == -1)  /* error? */
    return marpa_luaL_fileresult(L, 0, NULL);
  else {
    l_inspectstat(stat, what);  /* interpret result */
    if (*what == 'e' && stat == 0)  /* successful termination? */
      marpa_lua_pushboolean(L, 1);
    else
      marpa_lua_pushnil(L);
    marpa_lua_pushstring(L, what);
    marpa_lua_pushinteger(L, stat);
    return 3;  /* return true/nil,what,code */
  }
}

/* }====================================================== */


/*
** {======================================================
** Userdata's metatable manipulation
** =======================================================
*/

LUALIB_API int marpa_luaL_newmetatable (lua_State *L, const char *tname) {
  if (luaL_getmetatable(L, tname) != LUA_TNIL)  /* name already in use? */
    return 0;  /* leave previous value on top, but return 0 */
  marpa_lua_pop(L, 1);
  marpa_lua_createtable(L, 0, 2);  /* create metatable */
  marpa_lua_pushstring(L, tname);
  marpa_lua_setfield(L, -2, "__name");  /* metatable.__name = tname */
  marpa_lua_pushvalue(L, -1);
  marpa_lua_setfield(L, LUA_REGISTRYINDEX, tname);  /* registry.name = metatable */
  return 1;
}


LUALIB_API void marpa_luaL_setmetatable (lua_State *L, const char *tname) {
  luaL_getmetatable(L, tname);
  marpa_lua_setmetatable(L, -2);
}


LUALIB_API void *marpa_luaL_testudata (lua_State *L, int ud, const char *tname) {
  void *p = marpa_lua_touserdata(L, ud);
  if (p != NULL) {  /* value is a userdata? */
    if (marpa_lua_getmetatable(L, ud)) {  /* does it have a metatable? */
      luaL_getmetatable(L, tname);  /* get correct metatable */
      if (!marpa_lua_rawequal(L, -1, -2))  /* not the same? */
        p = NULL;  /* value is a userdata with wrong metatable */
      marpa_lua_pop(L, 2);  /* remove both metatables */
      return p;
    }
  }
  return NULL;  /* value is not a userdata with a metatable */
}


LUALIB_API void *marpa_luaL_checkudata (lua_State *L, int ud, const char *tname) {
  void *p = marpa_luaL_testudata(L, ud, tname);
  if (p == NULL) typeerror(L, ud, tname);
  return p;
}

/* }====================================================== */


/*
** {======================================================
** Argument check functions
** =======================================================
*/

LUALIB_API int marpa_luaL_checkoption (lua_State *L, int arg, const char *def,
                                 const char *const lst[]) {
  const char *name = (def) ? luaL_optstring(L, arg, def) :
                             luaL_checkstring(L, arg);
  int i;
  for (i=0; lst[i]; i++)
    if (strcmp(lst[i], name) == 0)
      return i;
  return marpa_luaL_argerror(L, arg,
                       marpa_lua_pushfstring(L, "invalid option '%s'", name));
}


LUALIB_API void marpa_luaL_checkstack (lua_State *L, int space, const char *msg) {
  /* keep some extra space to run error routines, if needed */
  const int extra = LUA_MINSTACK;
  if (!marpa_lua_checkstack(L, space + extra)) {
    if (msg)
      marpa_luaL_error(L, "stack overflow (%s)", msg);
    else
      marpa_luaL_error(L, "stack overflow");
  }
}


LUALIB_API void marpa_luaL_checktype (lua_State *L, int arg, int t) {
  if (marpa_lua_type(L, arg) != t)
    tag_error(L, arg, t);
}


LUALIB_API void marpa_luaL_checkany (lua_State *L, int arg) {
  if (marpa_lua_type(L, arg) == LUA_TNONE)
    marpa_luaL_argerror(L, arg, "value expected");
}


LUALIB_API const char *marpa_luaL_checklstring (lua_State *L, int arg, size_t *len) {
  const char *s = marpa_lua_tolstring(L, arg, len);
  if (!s) tag_error(L, arg, LUA_TSTRING);
  return s;
}


LUALIB_API const char *marpa_luaL_optlstring (lua_State *L, int arg,
                                        const char *def, size_t *len) {
  if (marpa_lua_isnoneornil(L, arg)) {
    if (len)
      *len = (def ? strlen(def) : 0);
    return def;
  }
  else return marpa_luaL_checklstring(L, arg, len);
}


LUALIB_API lua_Number marpa_luaL_checknumber (lua_State *L, int arg) {
  int isnum;
  lua_Number d = marpa_lua_tonumberx(L, arg, &isnum);
  if (!isnum)
    tag_error(L, arg, LUA_TNUMBER);
  return d;
}


LUALIB_API lua_Number marpa_luaL_optnumber (lua_State *L, int arg, lua_Number def) {
  return luaL_opt(L, marpa_luaL_checknumber, arg, def);
}


static void interror (lua_State *L, int arg) {
  if (marpa_lua_isnumber(L, arg))
    marpa_luaL_argerror(L, arg, "number has no integer representation");
  else
    tag_error(L, arg, LUA_TNUMBER);
}


LUALIB_API lua_Integer marpa_luaL_checkinteger (lua_State *L, int arg) {
  int isnum;
  lua_Integer d = marpa_lua_tointegerx(L, arg, &isnum);
  if (!isnum) {
    interror(L, arg);
  }
  return d;
}


LUALIB_API lua_Integer marpa_luaL_optinteger (lua_State *L, int arg,
                                                      lua_Integer def) {
  return luaL_opt(L, marpa_luaL_checkinteger, arg, def);
}

/* }====================================================== */


/*
** {======================================================
** Generic Buffer manipulation
** =======================================================
*/

/* userdata to box arbitrary data */
typedef struct UBox {
  void *box;
  size_t bsize;
} UBox;


static void *resizebox (lua_State *L, int idx, size_t newsize) {
  void *ud;
  lua_Alloc allocf = marpa_lua_getallocf(L, &ud);
  UBox *box = (UBox *)marpa_lua_touserdata(L, idx);
  void *temp = allocf(ud, box->box, box->bsize, newsize);
  if (temp == NULL && newsize > 0) {  /* allocation error? */
    resizebox(L, idx, 0);  /* free buffer */
    marpa_luaL_error(L, "not enough memory for buffer allocation");
  }
  box->box = temp;
  box->bsize = newsize;
  return temp;
}


static int boxgc (lua_State *L) {
  resizebox(L, 1, 0);
  return 0;
}


static void *newbox (lua_State *L, size_t newsize) {
  UBox *box = (UBox *)marpa_lua_newuserdata(L, sizeof(UBox));
  box->box = NULL;
  box->bsize = 0;
  if (marpa_luaL_newmetatable(L, "LUABOX")) {  /* creating metatable? */
    marpa_lua_pushcfunction(L, boxgc);
    marpa_lua_setfield(L, -2, "__gc");  /* metatable.__gc = boxgc */
  }
  marpa_lua_setmetatable(L, -2);
  return resizebox(L, -1, newsize);
}


/*
** check whether buffer is using a userdata on the stack as a temporary
** buffer
*/
#define buffonstack(B)	((B)->b != (B)->initb)


/*
** returns a pointer to a free area with at least 'sz' bytes
*/
LUALIB_API char *marpa_luaL_prepbuffsize (luaL_Buffer *B, size_t sz) {
  lua_State *L = B->L;
  if (B->size - B->n < sz) {  /* not enough space? */
    char *newbuff;
    size_t newsize = B->size * 2;  /* double buffer size */
    if (newsize - B->n < sz)  /* not big enough? */
      newsize = B->n + sz;
    if (newsize < B->n || newsize - B->n < sz)
      marpa_luaL_error(L, "buffer too large");
    /* create larger buffer */
    if (buffonstack(B))
      newbuff = (char *)resizebox(L, -1, newsize);
    else {  /* no buffer yet */
      newbuff = (char *)newbox(L, newsize);
      memcpy(newbuff, B->b, B->n * sizeof(char));  /* copy original content */
    }
    B->b = newbuff;
    B->size = newsize;
  }
  return &B->b[B->n];
}


LUALIB_API void marpa_luaL_addlstring (luaL_Buffer *B, const char *s, size_t l) {
  if (l > 0) {  /* avoid 'memcpy' when 's' can be NULL */
    char *b = marpa_luaL_prepbuffsize(B, l);
    memcpy(b, s, l * sizeof(char));
    luaL_addsize(B, l);
  }
}


LUALIB_API void marpa_luaL_addstring (luaL_Buffer *B, const char *s) {
  marpa_luaL_addlstring(B, s, strlen(s));
}


LUALIB_API void marpa_luaL_pushresult (luaL_Buffer *B) {
  lua_State *L = B->L;
  marpa_lua_pushlstring(L, B->b, B->n);
  if (buffonstack(B)) {
    resizebox(L, -2, 0);  /* delete old buffer */
    marpa_lua_remove(L, -2);  /* remove its header from the stack */
  }
}


LUALIB_API void marpa_luaL_pushresultsize (luaL_Buffer *B, size_t sz) {
  luaL_addsize(B, sz);
  marpa_luaL_pushresult(B);
}


LUALIB_API void marpa_luaL_addvalue (luaL_Buffer *B) {
  lua_State *L = B->L;
  size_t l;
  const char *s = marpa_lua_tolstring(L, -1, &l);
  if (buffonstack(B))
    marpa_lua_insert(L, -2);  /* put value below buffer */
  marpa_luaL_addlstring(B, s, l);
  marpa_lua_remove(L, (buffonstack(B)) ? -2 : -1);  /* remove value */
}


LUALIB_API void marpa_luaL_buffinit (lua_State *L, luaL_Buffer *B) {
  B->L = L;
  B->b = B->initb;
  B->n = 0;
  B->size = LUAL_BUFFERSIZE;
}


LUALIB_API char *marpa_luaL_buffinitsize (lua_State *L, luaL_Buffer *B, size_t sz) {
  marpa_luaL_buffinit(L, B);
  return marpa_luaL_prepbuffsize(B, sz);
}

/* }====================================================== */


/*
** {======================================================
** Reference system
** =======================================================
*/

/* index of free-list header */
#define freelist	0


LUALIB_API int marpa_luaL_ref (lua_State *L, int t) {
  int ref;
  if (marpa_lua_isnil(L, -1)) {
    marpa_lua_pop(L, 1);  /* remove from stack */
    return LUA_REFNIL;  /* 'nil' has a unique fixed reference */
  }
  t = marpa_lua_absindex(L, t);
  marpa_lua_rawgeti(L, t, freelist);  /* get first free element */
  ref = (int)marpa_lua_tointeger(L, -1);  /* ref = t[freelist] */
  marpa_lua_pop(L, 1);  /* remove it from stack */
  if (ref != 0) {  /* any free element? */
    marpa_lua_rawgeti(L, t, ref);  /* remove it from list */
    marpa_lua_rawseti(L, t, freelist);  /* (t[freelist] = t[ref]) */
  }
  else  /* no free elements */
    ref = (int)marpa_lua_rawlen(L, t) + 1;  /* get a new reference */
  marpa_lua_rawseti(L, t, ref);
  return ref;
}


LUALIB_API void marpa_luaL_unref (lua_State *L, int t, int ref) {
  if (ref >= 0) {
    t = marpa_lua_absindex(L, t);
    marpa_lua_rawgeti(L, t, freelist);
    marpa_lua_rawseti(L, t, ref);  /* t[ref] = t[freelist] */
    marpa_lua_pushinteger(L, ref);
    marpa_lua_rawseti(L, t, freelist);  /* t[freelist] = ref */
  }
}

/* }====================================================== */


/*
** {======================================================
** Load functions
** =======================================================
*/

typedef struct LoadF {
  int n;  /* number of pre-read characters */
  FILE *f;  /* file being read */
  char buff[BUFSIZ];  /* area for reading file */
} LoadF;


static const char *getF (lua_State *L, void *ud, size_t *size) {
  LoadF *lf = (LoadF *)ud;
  (void)L;  /* not used */
  if (lf->n > 0) {  /* are there pre-read characters to be read? */
    *size = lf->n;  /* return them (chars already in buffer) */
    lf->n = 0;  /* no more pre-read characters */
  }
  else {  /* read a block from file */
    /* 'fread' can return > 0 *and* set the EOF flag. If next call to
       'getF' called 'fread', it might still wait for user input.
       The next check avoids this problem. */
    if (feof(lf->f)) return NULL;
    *size = fread(lf->buff, 1, sizeof(lf->buff), lf->f);  /* read block */
  }
  return lf->buff;
}


static int errfile (lua_State *L, const char *what, int fnameindex) {
  const char *serr = strerror(errno);
  const char *filename = marpa_lua_tostring(L, fnameindex) + 1;
  marpa_lua_pushfstring(L, "cannot %s %s: %s", what, filename, serr);
  marpa_lua_remove(L, fnameindex);
  return LUA_ERRFILE;
}


static int skipBOM (LoadF *lf) {
  const char *p = "\xEF\xBB\xBF";  /* UTF-8 BOM mark */
  int c;
  lf->n = 0;
  do {
    c = getc(lf->f);
    if (c == EOF || c != *(const unsigned char *)p++) return c;
    lf->buff[lf->n++] = c;  /* to be read by the parser */
  } while (*p != '\0');
  lf->n = 0;  /* prefix matched; discard it */
  return getc(lf->f);  /* return next character */
}


/*
** reads the first character of file 'f' and skips an optional BOM mark
** in its beginning plus its first line if it starts with '#'. Returns
** true if it skipped the first line.  In any case, '*cp' has the
** first "valid" character of the file (after the optional BOM and
** a first-line comment).
*/
static int skipcomment (LoadF *lf, int *cp) {
  int c = *cp = skipBOM(lf);
  if (c == '#') {  /* first line is a comment (Unix exec. file)? */
    do {  /* skip first line */
      c = getc(lf->f);
    } while (c != EOF && c != '\n') ;
    *cp = getc(lf->f);  /* skip end-of-line, if present */
    return 1;  /* there was a comment */
  }
  else return 0;  /* no comment */
}


LUALIB_API int marpa_luaL_loadfilex (lua_State *L, const char *filename,
                                             const char *mode) {
  LoadF lf;
  int status, readstatus;
  int c;
  int fnameindex = marpa_lua_gettop(L) + 1;  /* index of filename on the stack */
  if (filename == NULL) {
    marpa_lua_pushliteral(L, "=stdin");
    lf.f = stdin;
  }
  else {
    marpa_lua_pushfstring(L, "@%s", filename);
    lf.f = fopen(filename, "r");
    if (lf.f == NULL) return errfile(L, "open", fnameindex);
  }
  if (skipcomment(&lf, &c))  /* read initial portion */
    lf.buff[lf.n++] = '\n';  /* add line to correct line numbers */
  if (c == LUA_SIGNATURE[0] && filename) {  /* binary file? */
    lf.f = freopen(filename, "rb", lf.f);  /* reopen in binary mode */
    if (lf.f == NULL) return errfile(L, "reopen", fnameindex);
    skipcomment(&lf, &c);  /* re-read initial portion */
  }
  if (c != EOF)
    lf.buff[lf.n++] = c;  /* 'c' is the first character of the stream */
  status = marpa_lua_load(L, getF, &lf, marpa_lua_tostring(L, -1), mode);
  readstatus = ferror(lf.f);
  if (filename) fclose(lf.f);  /* close file (even in case of errors) */
  if (readstatus) {
    marpa_lua_settop(L, fnameindex);  /* ignore results from 'marpa_lua_load' */
    return errfile(L, "read", fnameindex);
  }
  marpa_lua_remove(L, fnameindex);
  return status;
}


typedef struct LoadS {
  const char *s;
  size_t size;
} LoadS;


static const char *getS (lua_State *L, void *ud, size_t *size) {
  LoadS *ls = (LoadS *)ud;
  (void)L;  /* not used */
  if (ls->size == 0) return NULL;
  *size = ls->size;
  ls->size = 0;
  return ls->s;
}


LUALIB_API int marpa_luaL_loadbufferx (lua_State *L, const char *buff, size_t size,
                                 const char *name, const char *mode) {
  LoadS ls;
  ls.s = buff;
  ls.size = size;
  return marpa_lua_load(L, getS, &ls, name, mode);
}


LUALIB_API int marpa_luaL_loadstring (lua_State *L, const char *s) {
  return luaL_loadbuffer(L, s, strlen(s), s);
}

/* }====================================================== */



LUALIB_API int marpa_luaL_getmetafield (lua_State *L, int obj, const char *event) {
  if (!marpa_lua_getmetatable(L, obj))  /* no metatable? */
    return LUA_TNIL;
  else {
    int tt;
    marpa_lua_pushstring(L, event);
    tt = marpa_lua_rawget(L, -2);
    if (tt == LUA_TNIL)  /* is metafield nil? */
      marpa_lua_pop(L, 2);  /* remove metatable and metafield */
    else
      marpa_lua_remove(L, -2);  /* remove only metatable */
    return tt;  /* return metafield type */
  }
}


LUALIB_API int marpa_luaL_callmeta (lua_State *L, int obj, const char *event) {
  obj = marpa_lua_absindex(L, obj);
  if (marpa_luaL_getmetafield(L, obj, event) == LUA_TNIL)  /* no metafield? */
    return 0;
  marpa_lua_pushvalue(L, obj);
  marpa_lua_call(L, 1, 1);
  return 1;
}


LUALIB_API lua_Integer marpa_luaL_len (lua_State *L, int idx) {
  lua_Integer l;
  int isnum;
  marpa_lua_len(L, idx);
  l = marpa_lua_tointegerx(L, -1, &isnum);
  if (!isnum)
    marpa_luaL_error(L, "object length is not an integer");
  marpa_lua_pop(L, 1);  /* remove object */
  return l;
}


LUALIB_API const char *marpa_luaL_tolstring (lua_State *L, int idx, size_t *len) {
  if (!marpa_luaL_callmeta(L, idx, "__tostring")) {  /* no metafield? */
    switch (marpa_lua_type(L, idx)) {
      case LUA_TNUMBER: {
        if (marpa_lua_isinteger(L, idx))
          marpa_lua_pushfstring(L, "%I", marpa_lua_tointeger(L, idx));
        else
          marpa_lua_pushfstring(L, "%f", marpa_lua_tonumber(L, idx));
        break;
      }
      case LUA_TSTRING:
        marpa_lua_pushvalue(L, idx);
        break;
      case LUA_TBOOLEAN:
        marpa_lua_pushstring(L, (marpa_lua_toboolean(L, idx) ? "true" : "false"));
        break;
      case LUA_TNIL:
        marpa_lua_pushliteral(L, "nil");
        break;
      default:
        marpa_lua_pushfstring(L, "%s: %p", luaL_typename(L, idx),
                                            marpa_lua_topointer(L, idx));
        break;
    }
  }
  return marpa_lua_tolstring(L, -1, len);
}


/*
** {======================================================
** Compatibility with 5.1 module functions
** =======================================================
*/
#if defined(LUA_COMPAT_MODULE)

static const char *luaL_findtable (lua_State *L, int idx,
                                   const char *fname, int szhint) {
  const char *e;
  if (idx) marpa_lua_pushvalue(L, idx);
  do {
    e = strchr(fname, '.');
    if (e == NULL) e = fname + strlen(fname);
    marpa_lua_pushlstring(L, fname, e - fname);
    if (marpa_lua_rawget(L, -2) == LUA_TNIL) {  /* no such field? */
      marpa_lua_pop(L, 1);  /* remove this nil */
      marpa_lua_createtable(L, 0, (*e == '.' ? 1 : szhint)); /* new table for field */
      marpa_lua_pushlstring(L, fname, e - fname);
      marpa_lua_pushvalue(L, -2);
      marpa_lua_settable(L, -4);  /* set new table into field */
    }
    else if (!marpa_lua_istable(L, -1)) {  /* field has a non-table value? */
      marpa_lua_pop(L, 2);  /* remove table and value */
      return fname;  /* return problematic part of the name */
    }
    marpa_lua_remove(L, -2);  /* remove previous table */
    fname = e + 1;
  } while (*e == '.');
  return NULL;
}


/*
** Count number of elements in a luaL_Reg list.
*/
static int libsize (const luaL_Reg *l) {
  int size = 0;
  for (; l && l->name; l++) size++;
  return size;
}


/*
** Find or create a module table with a given name. The function
** first looks at the _LOADED table and, if that fails, try a
** global variable with that name. In any case, leaves on the stack
** the module table.
*/
LUALIB_API void luaL_pushmodule (lua_State *L, const char *modname,
                                 int sizehint) {
  luaL_findtable(L, LUA_REGISTRYINDEX, "_LOADED", 1);  /* get _LOADED table */
  if (marpa_lua_getfield(L, -1, modname) != LUA_TTABLE) {  /* no _LOADED[modname]? */
    marpa_lua_pop(L, 1);  /* remove previous result */
    /* try global variable (and create one if it does not exist) */
    marpa_lua_pushglobaltable(L);
    if (luaL_findtable(L, 0, modname, sizehint) != NULL)
      marpa_luaL_error(L, "name conflict for module '%s'", modname);
    marpa_lua_pushvalue(L, -1);
    marpa_lua_setfield(L, -3, modname);  /* _LOADED[modname] = new table */
  }
  marpa_lua_remove(L, -2);  /* remove _LOADED table */
}


LUALIB_API void luaL_openlib (lua_State *L, const char *libname,
                               const luaL_Reg *l, int nup) {
  luaL_checkversion(L);
  if (libname) {
    luaL_pushmodule(L, libname, libsize(l));  /* get/create library table */
    marpa_lua_insert(L, -(nup + 1));  /* move library table to below upvalues */
  }
  if (l)
    marpa_luaL_setfuncs(L, l, nup);
  else
    marpa_lua_pop(L, nup);  /* remove upvalues */
}

#endif
/* }====================================================== */

/*
** set functions from list 'l' into table at top - 'nup'; each
** function gets the 'nup' elements at the top as upvalues.
** Returns with only the table at the stack.
*/
LUALIB_API void marpa_luaL_setfuncs (lua_State *L, const luaL_Reg *l, int nup) {
  marpa_luaL_checkstack(L, nup, "too many upvalues");
  for (; l->name != NULL; l++) {  /* fill the table with given functions */
    int i;
    for (i = 0; i < nup; i++)  /* copy upvalues to the top */
      marpa_lua_pushvalue(L, -nup);
    marpa_lua_pushcclosure(L, l->func, nup);  /* closure with those upvalues */
    marpa_lua_setfield(L, -(nup + 2), l->name);
  }
  marpa_lua_pop(L, nup);  /* remove upvalues */
}


/*
** ensure that stack[idx][fname] has a table and push that table
** into the stack
*/
LUALIB_API int marpa_luaL_getsubtable (lua_State *L, int idx, const char *fname) {
  if (marpa_lua_getfield(L, idx, fname) == LUA_TTABLE)
    return 1;  /* table already there */
  else {
    marpa_lua_pop(L, 1);  /* remove previous result */
    idx = marpa_lua_absindex(L, idx);
    marpa_lua_newtable(L);
    marpa_lua_pushvalue(L, -1);  /* copy to be left at top */
    marpa_lua_setfield(L, idx, fname);  /* assign new table to field */
    return 0;  /* false, because did not find table there */
  }
}


/*
** Stripped-down 'require': After checking "loaded" table, calls 'openf'
** to open a module, registers the result in 'package.loaded' table and,
** if 'glb' is true, also registers the result in the global table.
** Leaves resulting module on the top.
*/
LUALIB_API void marpa_luaL_requiref (lua_State *L, const char *modname,
                               lua_CFunction openf, int glb) {
  marpa_luaL_getsubtable(L, LUA_REGISTRYINDEX, "_LOADED");
  marpa_lua_getfield(L, -1, modname);  /* _LOADED[modname] */
  if (!marpa_lua_toboolean(L, -1)) {  /* package not already loaded? */
    marpa_lua_pop(L, 1);  /* remove field */
    marpa_lua_pushcfunction(L, openf);
    marpa_lua_pushstring(L, modname);  /* argument to open function */
    marpa_lua_call(L, 1, 1);  /* call 'openf' to open module */
    marpa_lua_pushvalue(L, -1);  /* make copy of module (call result) */
    marpa_lua_setfield(L, -3, modname);  /* _LOADED[modname] = module */
  }
  marpa_lua_remove(L, -2);  /* remove _LOADED table */
  if (glb) {
    marpa_lua_pushvalue(L, -1);  /* copy of module */
    marpa_lua_setglobal(L, modname);  /* _G[modname] = module */
  }
}


LUALIB_API const char *marpa_luaL_gsub (lua_State *L, const char *s, const char *p,
                                                               const char *r) {
  const char *wild;
  size_t l = strlen(p);
  luaL_Buffer b;
  marpa_luaL_buffinit(L, &b);
  while ((wild = strstr(s, p)) != NULL) {
    marpa_luaL_addlstring(&b, s, wild - s);  /* push prefix */
    marpa_luaL_addstring(&b, r);  /* push replacement in place of pattern */
    s = wild + l;  /* continue after 'p' */
  }
  marpa_luaL_addstring(&b, s);  /* push last suffix */
  marpa_luaL_pushresult(&b);
  return marpa_lua_tostring(L, -1);
}


static void *l_alloc (void *ud, void *ptr, size_t osize, size_t nsize) {
  (void)ud; (void)osize;  /* not used */
  if (nsize == 0) {
    free(ptr);
    return NULL;
  }
  else
    return realloc(ptr, nsize);
}


static int panic (lua_State *L) {
  marpa_lua_writestringerror("PANIC: unprotected error in call to Lua API (%s)\n",
                        marpa_lua_tostring(L, -1));
  return 0;  /* return to Lua to abort */
}


LUALIB_API lua_State *marpa_luaL_newstate (void) {
  lua_State *L = marpa_lua_newstate(l_alloc, NULL);
  if (L) marpa_lua_atpanic(L, &panic);
  return L;
}


LUALIB_API void marpa_luaL_checkversion_ (lua_State *L, lua_Number ver, size_t sz) {
  const lua_Number *v = marpa_lua_version(L);
  if (sz != LUAL_NUMSIZES)  /* check numeric types */
    marpa_luaL_error(L, "core and library have incompatible numeric types");
  if (v != marpa_lua_version(NULL))
    marpa_luaL_error(L, "multiple Lua VMs detected");
  else if (*v != ver)
    marpa_luaL_error(L, "version mismatch: app. needs %f, Lua core provides %f",
                  ver, *v);
}

