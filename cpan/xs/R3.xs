/*
 * Marpa::R3 is Copyright (C) 2017, Jeffrey Kegler.
 *
 * This module is free software; you can redistribute it and/or modify it
 * under the same terms as Perl 5.10.1. For more details, see the full text
 * of the licenses in the directory LICENSES.
 *
 * This program is distributed in the hope that it will be
 * useful, but it is provided "as is" and without any express
 * or implied warranties. For details, see the full text of
 * of the licenses in the directory LICENSES.
 */

#include "marpa.h"
#include "marpa_codes.h"

#define PERL_NO_GET_CONTEXT
#include <EXTERN.h>
#include <perl.h>
#include <XSUB.h>
#include "ppport.h"

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

#undef LUAOPEN_KOLLOS_METAL
#define LUAOPEN_KOLLOS_METAL kollos_metal_loader
#include <kollos.h>

typedef unsigned int Marpa_Codepoint;

extern const struct marpa_error_description_s marpa_error_description[];
extern const struct marpa_event_description_s marpa_event_description[];
extern const struct marpa_step_type_description_s
  marpa_step_type_description[];

typedef struct
{
  lua_State* L;
} Marpa_Lua;

#undef IS_PERL_UNDEF
#define IS_PERL_UNDEF(x) (SvTYPE(x) == SVt_NULL)

#undef STRINGIFY_ARG
#undef STRINGIFY
#undef STRLOC
#define STRINGIFY_ARG(contents)       #contents
#define STRINGIFY(macro_or_string)        STRINGIFY_ARG (macro_or_string)
#define STRLOC        __FILE__ ":" STRINGIFY (__LINE__)

#undef MYLUA_TAG
#define MYLUA_TAG "@" STRLOC

/* The usual lua_checkstack argument.
 * It's generous so I can defer stack hygiene --
 * that is, not clean up the stack immediately,
 * but leave things that I know will be cleaned up
 * shortly.
 *
 * If you're counting, don't forget that the error
 * handlers will want a few extra stack slots, if
 * invoked.
 */
#undef MYLUA_STACK_INCR
#define MYLUA_STACK_INCR 30

/* Start all Marpa::R3 internal errors with the same string */
#undef R3ERR
#define R3ERR "Marpa::R3 internal error: "

#undef MAX
#define MAX(a, b) ((a) > (b) ? (a) : (b))

typedef SV* SVREF;

#undef Dim
#define Dim(x) (sizeof(x)/sizeof(*x))

struct lua_extraspace {
    int ref_count;
};

/* I assume this will be inlined by the compiler */
static struct lua_extraspace *extraspace_get(lua_State* L)
{
    return *(struct lua_extraspace **)marpa_lua_getextraspace(L);
}

static void lua_refinc(lua_State* L) PERL_UNUSED_DECL;
static void lua_refinc(lua_State* L)
{
    struct lua_extraspace *p_extra = extraspace_get(L);
    p_extra->ref_count++;
}

static void lua_refdec(lua_State* L)
{
    struct lua_extraspace *p_extra = extraspace_get(L);
    p_extra->ref_count--;
    if (p_extra->ref_count <= 0) {
       marpa_lua_close(L);
       free(p_extra);
    }
}

static const char marpa_lua_class_name[] = "Marpa::R3::Lua";

/* Wrapper to use vwarn with libmarpa */
static int marpa_r3_warn(const char* format, ...)
{
  dTHX;
   va_list args;
   va_start (args, format);
   vwarn (format, &args);
   va_end (args);
   return 1;
}

/* Xlua, that is, the eXtension of Lua for Marpa::XS.
 * Portions of this code adopted from Inline::Lua
 */

#define MT_NAME_SV "Marpa_sv"
#define MT_NAME_AV "Marpa_av"
#define MT_NAME_ARRAY "Marpa_array"

/* Returns 0 if visitee_ix "thing" is already "seen",
 * otherwise, sets it "seen" and returns 1.
 * A small fixed number of stack entries are used
 * -- stack hygiene is left to the caller.
 */
static int visitee_on(
  lua_State* L, int seen_ix, int visitee_ix)
{
    marpa_lua_pushvalue(L, visitee_ix);
    if (marpa_lua_gettable(L, seen_ix) != LUA_TNIL) {
        return 0;
    }
    marpa_lua_pushvalue(L, visitee_ix);
    marpa_lua_pushboolean(L, 1);
    marpa_lua_settable(L, seen_ix);
    return 1;
}

/* Unsets "seen" for Lua "thing" at visitee_ix in
 * the table at seen_ix.
 * A small fixed number of stack entries are used
 * -- stack hygiene is left to the caller.
 */
static void visitee_off(
  lua_State* L, int seen_ix, int visitee_ix)
{
    marpa_lua_pushvalue(L, visitee_ix);
    marpa_lua_pushnil(L);
    marpa_lua_settable(L, seen_ix);
}

static SV*
recursive_coerce_to_sv (lua_State * L, int visited_ix, int idx, char sig);
static SV*
coerce_to_av (lua_State * L, int visited_ix, int table_ix, char signature);
static SV*
coerce_to_pairs (lua_State * L, int visited_ix, int table_ix);

/* Coerce a Lua value to a Perl SV, if necessary one that
 * is simply a string with an error message.
 * The caller gets ownership of one of the SV's reference
 * counts.
 * The Lua stack is left as is.
 */
static SV*
coerce_to_sv (lua_State * L, int idx, char sig)
{
   dTHX;
   SV *result;
   int visited_ix;
   int absolute_index = marpa_lua_absindex(L, idx);

   marpa_lua_newtable(L);
   visited_ix = marpa_lua_gettop(L);
   /* The tree op metatable is at visited_ix + 1 */
   marpa_lua_rawgetp (L, LUA_REGISTRYINDEX, (void*)&kollos_tree_op_mt_key);
   result = recursive_coerce_to_sv(L, visited_ix, absolute_index, sig);
   marpa_lua_settop(L, visited_ix-1);
   return result;
}

/* Stack hygiene is left to the caller and to coerce_to_av()
 */
static SV*
do_lua_tree_op (lua_State * L, int visited_ix, int idx, char signature)
{
    dTHX;
    const char *lua_tree_op;
    marpa_lua_geti (L, idx, 1);
    if (marpa_lua_type (L, -1) != LUA_TSTRING) {
        croak (R3ERR "Lua tree op is not a string; " MYLUA_TAG);
    }
    lua_tree_op = marpa_lua_tostring (L, -1);
    if (!strcmp (lua_tree_op, "perl")) {
        SV *av_ref = coerce_to_av (L, visited_ix, idx, signature);
        sv_bless (av_ref, gv_stashpv ("Marpa::R3::Tree_Op", 1));
        return av_ref;
    }
    croak (R3ERR "tree op (%s) not implemented; " MYLUA_TAG, lua_tree_op);
    /* NOTREACHED */
    return 0;
}

/* Reworked from Lua's utf8_decode.
 * We cannot use the XS Unicode routines, because
 * we are checking for standard Unicode, which Lua
 * uses, and Perl extends UTF-8.
 */
static const char *utf8_validate (const char *o, int max_size) {
  const lua_Integer maxunicode= 0x10FFFF;
  static const unsigned int limits[] = {0xFF, 0x7F, 0x7FF, 0xFFFF};
  const unsigned char *s = (const unsigned char *)o;
  unsigned int c = (unsigned int)s[0];
  unsigned int res = 0;  /* final result */
  if (max_size <= 0) return NULL;
  if (c <= 0x7F)  /* ascii? */
    res = c;
  else {
    int count = 0;  /* to count number of continuation bytes */
    while (c & 0x40) {  /* still have continuation bytes? */
      int cc;
      ++count;
      if (count + 1 > max_size) return NULL;
      cc = s[count];  /* read next byte */
      if ((cc & 0xC0) != 0x80)  /* not a continuation byte? */
        return NULL;  /* invalid byte sequence */
      res = (res << 6) | (cc & 0x3F);  /* add lower 6 bits from cont. byte */
      c <<= 1;  /* to test next bit */
    }
    res |= ((c & 0x7F) << (count * 5));  /* add first byte */
    if (count > 3 || res > maxunicode || res <= limits[count])
      return NULL;  /* invalid byte sequence */
    s += count;  /* skip continuation bytes read */
  }
  return (const char *)s + 1;  /* +1 to include first byte */
}

static int find_utf8_error (const char *s, const char *end) {
  const char *s1 = s;
  while (s1 < end) {
    /* warn("%s %d before s1=%p\n", __FILE__, __LINE__, s1); */
    s1 = utf8_validate(s1, (int)(end - s1));
    /* warn("%s %d after s1=%p\n", __FILE__, __LINE__, s1); */
    if (s1 == NULL) return (int)(s1 - s);
  }
  return -1;
}

static int is_ascii7 (const char *s, size_t length) {
    size_t i;
    for (i = 0; i < length; i++) {
        if (s[i] & 0x80) return 0;
    }
    return 1;
}

static SV*
recursive_coerce_to_sv (lua_State * L, int visited_ix, int idx, char signature)
{
    dTHX;
    SV *result;
    const int type = marpa_lua_type (L, idx);

    /* warn("%s %d\n", __FILE__, __LINE__); */
    switch (type) {
    case LUA_TNIL:
        /* warn("%s %d\n", __FILE__, __LINE__); */
        result = newSV (0);
        break;
    case LUA_TBOOLEAN:
        /* warn("%s %d\n", __FILE__, __LINE__); */
        result = marpa_lua_toboolean (L, idx) ? newSViv (1) : newSV (0);
        break;
    case LUA_TNUMBER:
        if (marpa_lua_isinteger (L, idx)) {
            lua_Integer int_v = marpa_lua_tointeger (L, idx);
            if (int_v <= IV_MAX && int_v >= IV_MIN) {
                result = newSViv ((IV) marpa_lua_tointeger (L, idx));
                break;
            }
        }
        result = newSVnv (marpa_lua_tonumber (L, idx));
        break;
    case LUA_TSTRING:
        /* warn("%s %d: %s len=%d\n", __FILE__, __LINE__, marpa_lua_tostring (L, idx), marpa_lua_rawlen (L, idx)); */
        {
            size_t str_length;
            const char *str = marpa_lua_tolstring (L, idx, &str_length);
            result = newSVpvn (str, (STRLEN)str_length);
            if (!is_ascii7(str, str_length)) SvUTF8_on(result);
        }
        break;
    case LUA_TTABLE:
        {
          /* If table at idx has a metatable, compare it with the
           * tree op metatable.  If equal, do the tree ops.
           */
          if (marpa_lua_getmetatable (L, idx)
              && marpa_lua_compare (L, visited_ix + 1, -1, LUA_OPEQ))
            {
              result = do_lua_tree_op (L, visited_ix, idx, signature);
            }
          else
            {
              switch (signature)
                {
                default:
                case '0':
                case '1':
                  result = coerce_to_av (L, visited_ix, idx, signature);
                  break;
                case '2':
                  result = coerce_to_pairs (L, visited_ix, idx);
	  break;
	}
    }
}
        break;
    case LUA_TUSERDATA:
        {
            SV **p_result = marpa_luaL_testudata (L, idx, MT_NAME_SV);
            if (!p_result) {
                result =
                    newSVpvf
                    ("Coercion not implemented for Lua userdata at index %d in coerce_to_sv",
                    idx);
            } else {
                result = *p_result;
                SvREFCNT_inc_simple_void_NN (result);
            }
        };
        break;

    default:
        /* warn("%s %d\n", __FILE__, __LINE__); */
        result =
            newSVpvf
            ("Lua type %s at index %d in coerce_to_sv: coercion not implemented",
            marpa_luaL_typename (L, idx), idx);
        break;
    }
    /* warn("%s %d\n", __FILE__, __LINE__); */
    return result;
}

/* Coerce a Lua table to an AV.  Cycles are checked for
 * and cut off with a string marking the cutoff point.
 * Only numeric keys in a Lua "sequence" are considered:
 * that is, keys 1 .. N where N is the length of the sequence
 * and none of the values are nil.  If the signature is '0',
 * the sequence will converted to a zero-based Perl array,
 * so that a conventional Lua sequence is converted to a
 * convention-compliant Perl array.  If the signature is '1'
 * the keys in the Perl array will be exactly those of the
 * Lua sequence.
 */
static SV*
coerce_to_av (lua_State * L, int visited_ix, int table_ix, char signature)
{
    dTHX;
    SV *result;
    AV *av;
    int seq_ix;
    const int base_of_stack = marpa_lua_gettop(L);
    const int ix_offset = signature == '1' ? 0 : -1;

    /* warn("%s %d table_ix=%ld signature=%c\n", __FILE__, __LINE__, table_ix, signature); */

    marpa_lua_pushvalue(L, table_ix);
    if (!visitee_on(L, visited_ix, table_ix)) {
        result = newSVpvs ("[cycle in lua table]");
        goto RESET_STACK;
    }

    /* Below we will call this recursively,
     * so we need to make sure we have enough stack
     */
    marpa_luaL_checkstack(L, MYLUA_STACK_INCR, MYLUA_TAG);

    av = newAV();
    /* mortalize it, so it is garbage collected if we abend */
    result = sv_2mortal (newRV_noinc ((SV *) av));

    for (seq_ix = 1; 1; seq_ix++)
    {
        int value_ix;
	SV *entry_value;
	SV** ownership_taken;
        const int type_pushed = marpa_lua_geti(L, table_ix, seq_ix);
        /* warn("%s %d seq_ix=%ld\n", __FILE__, __LINE__, seq_ix); */

        if (type_pushed == LUA_TNIL) { break; }
        value_ix = marpa_lua_gettop(L); /* We need an absolute index, not -1 */
        /* warn("%s %d value_ix=%ld\n", __FILE__, __LINE__, value_ix); */
	entry_value = recursive_coerce_to_sv(L, visited_ix, value_ix, signature);
	ownership_taken = av_store(av, (int)seq_ix + ix_offset, entry_value);
        marpa_lua_settop(L, value_ix - 1);
	if (!ownership_taken) {
	  SvREFCNT_dec (entry_value);
          croak (R3ERR "av_store failed; " MYLUA_TAG);
	}
    }

    /* Demortalize the result, now that we know we will not
     * abend.
     */
    SvREFCNT_inc_simple_void_NN (result);
    visitee_off(L, visited_ix, table_ix);

    RESET_STACK:
    marpa_lua_settop(L, base_of_stack);
    return result;
}

/* Coerce a Lua table to an AV of key-value pairs.
 * Cycles are checked for
 * and cut off with a string marking the cutoff point.
 * The numeric keys in a Lua "sequence" are put first.
 * Other key-value pairs follow in random order.
 * The result will be a zero-based Perl array,
 */
static SV*
coerce_to_pairs (lua_State * L, int visited_ix, int table_ix)
{
    dTHX;
    SV *result;
    AV *av;
    lua_Integer seq_length;
    int av_ix = 0;
    const int base_of_stack = marpa_lua_gettop(L);


    marpa_lua_pushvalue(L, table_ix);
    if (!visitee_on(L, visited_ix, table_ix)) {
        result = newSVpvs ("[cycle in lua table]");
        goto RESET_STACK;
    }

    /* We call this recursively, so we need to make sure we have enough stack */
    marpa_luaL_checkstack(L, MYLUA_STACK_INCR, MYLUA_TAG);

    av = newAV();
    /* mortalize it, so it is garbage collected if we abend */
    result = sv_2mortal (newRV_noinc ((SV *) av));

    {
        const int base_of_loop_stack = marpa_lua_gettop (L);
        const int loop_value_ix = base_of_loop_stack + 1;
        int seq_ix;
        for (seq_ix = 1; 1; seq_ix++) {
            SV *entry_value;
            SV **ownership_taken;

            const int type_pushed = marpa_lua_geti (L, table_ix, seq_ix);

            if (type_pushed == LUA_TNIL) {
                break;
            }


            entry_value = newSViv (seq_ix);
            ownership_taken = av_store (av, (int) av_ix, entry_value);
            if (!ownership_taken) {
                SvREFCNT_dec (entry_value);
                croak (R3ERR "av_store failed; " MYLUA_TAG);
            }
            av_ix++;

            entry_value =
                recursive_coerce_to_sv (L, visited_ix, loop_value_ix, '2');
            ownership_taken = av_store (av, (int) av_ix, entry_value);
            if (!ownership_taken) {
                SvREFCNT_dec (entry_value);
                croak (R3ERR "av_store failed; " MYLUA_TAG);
            }
            av_ix++;
            marpa_lua_settop (L, base_of_loop_stack);
        }
        seq_length = seq_ix - 1;
    }

    /* Now do the key-value pairs that were *NOT* part
     * of the sequence
     */
    marpa_lua_pushnil(L);
    while (marpa_lua_next(L, table_ix) != 0) {
        SV** ownership_taken;
        SV *entry_value;
        const int value_ix = marpa_lua_gettop(L);
        const int key_ix = value_ix - 1;
        int key_type = marpa_lua_type(L, key_ix);

        /* Sequence elements have already been entered, so skip
         * them
         */
        if (key_type == LUA_TNUMBER) {
            int isnum;
            lua_Integer key_value = marpa_lua_tointegerx(L, key_ix, &isnum);
            if (!isnum) goto NEXT_ELEMENT;
            if (key_value >= 1 && key_value <= seq_length) goto NEXT_ELEMENT;
        }

	entry_value = recursive_coerce_to_sv(L, visited_ix, key_ix, '2');
	ownership_taken = av_store(av, (int)av_ix, entry_value);
	if (!ownership_taken) {
	  SvREFCNT_dec (entry_value);
          croak (R3ERR "av_store failed; " MYLUA_TAG);
	}
        av_ix ++;

	entry_value = recursive_coerce_to_sv(L, visited_ix, value_ix, '2');
	ownership_taken = av_store(av, (int)av_ix, entry_value);
	if (!ownership_taken) {
	  SvREFCNT_dec (entry_value);
          croak (R3ERR "av_store failed; " MYLUA_TAG);
	}
        av_ix ++;

        NEXT_ELEMENT: ;
        marpa_lua_settop(L, key_ix);
    }

    /* Demortalize the result, now that we know we will not
     * abend.
     */
    SvREFCNT_inc_simple_void_NN (result);
    visitee_off(L, visited_ix, table_ix);

    RESET_STACK:
    marpa_lua_settop(L, base_of_stack);
    return result;
}

/* [ -1, +1 ]
 * Wraps the object on top of the stack in an
 * X_fallback object.  Removes the original object
 * from the stack, and leaves the wrapper on top
 * of the stack.  Obeys stack hygiene.
 */
static void X_fallback_wrap(lua_State* L)
{
     /* [ object ] */
     marpa_lua_newtable(L);
     /* [ object, wrapper ] */
     marpa_lua_rawgetp (L, LUA_REGISTRYINDEX, (void*)&kollos_X_fallback_mt_key);
     marpa_lua_setmetatable(L, -2);
     /* [ object, wrapper ] */
     marpa_lua_rotate(L, -2, 1);
     /* [ wrapper, object ] */
     marpa_lua_setfield(L, -2, "object");
     /* [ wrapper ] */
}

/* Called after pcall error -- assumes that "status" is
 * the non-zero return value of lua_pcall() and that the
 * error object is on top of the stack.  Leaves an
 * "exception object" on top of the stack, and in
 * a global.  At this point, the "exception object"
 * might simply be a string.
 *
 * Does *NOT* do stack hygiene.
 */
static void coerce_pcall_error (lua_State* L, int status) {
    switch (status) {
    case LUA_ERRERR:
        marpa_lua_pushliteral(L, R3ERR "pcall(); error running the message handler");
        break;
    case LUA_ERRMEM:
        marpa_lua_pushliteral(L, R3ERR "pcall(); error running the message handler");
        break;
    case LUA_ERRGCMM:
        marpa_lua_pushliteral(L, R3ERR "pcall(); error running a gc_ metamethod");
        break;
    default:
        marpa_lua_pushfstring(L, R3ERR "pcall(); bad status %d", status);
        break;
    case LUA_ERRRUN:
        /* Just leave the original object on top of the stack */
        break;
    }
    return;
}

/* Called after pcall error -- assumes that "status" is
 * the non-zero return value of lua_pcall() and that the
 * error object is on top of the stack.  Leaves the exception
 * object on top of the stack.  Does stack hygiene.
 *
 * The return value is a string which is either a C constant string
 * in static space, or in Perl mortal space.
 */
static const char* handle_pcall_error (lua_State* L, int status) {
    dTHX;
    /* Lua stack: [ exception_object ] */
    const int exception_object_ix = marpa_lua_gettop(L);

    /* The best way to get a self-expanding sprintf buffer is to use a
     * Perl SV.  We set it mortal, so that Perl makes sure that it is
     * garbage collected after the next context switch.
     */
    SV* temp_sv = sv_newmortal();

    /* This is in the context of an error, so we have to be careful
     * about having enough Lua stack.
     */
    marpa_luaL_checkstack(L, MYLUA_STACK_INCR, MYLUA_TAG);

    coerce_pcall_error(L, status);
    marpa_lua_pushvalue(L, -1);
    marpa_lua_setglobal(L, "last_exception");

    {
        size_t len;
        const char *lua_exception_string = marpa_luaL_tolstring(L, -1, &len);
        sv_setpvn(temp_sv, lua_exception_string, (STRLEN)len);
    }

    marpa_lua_settop(L, exception_object_ix-1);
    return SvPV_nolen(temp_sv);
}

/* Push a Perl value onto the Lua stack. */
static void
push_val (lua_State * L, SV * val)
{
  dTHX;
  if (SvTYPE (val) == SVt_NULL)
    {
      /* warn("%s %d\n", __FILE__, __LINE__); */
      marpa_lua_pushnil (L);
      return;
    }
  if (SvPOK (val))
    {
      STRLEN n_a;
      /* warn("%s %d\n", __FILE__, __LINE__); */
      char *cval = SvPV (val, n_a);
      marpa_lua_pushlstring (L, cval, n_a);
      return;
    }
  if (SvNOK (val))
    {
      /* warn("%s %d\n", __FILE__, __LINE__); */
      marpa_lua_pushnumber (L, (lua_Number) SvNV (val));
      return;
    }
  if (SvIOK (val))
    {
      /* warn("%s %d\n", __FILE__, __LINE__); */
      marpa_lua_pushnumber (L, (lua_Number) SvIV (val));
      return;
    }
  if (SvROK (val))
    {
      /* warn("%s %d\n", __FILE__, __LINE__); */
      marpa_lua_pushfstring (L,
                             "[Perl ref to type %s]",
                             sv_reftype (SvRV (val), 0));
      return;
    }
      /* warn("%s %d\n", __FILE__, __LINE__); */
  marpa_lua_pushfstring (L, "[Perl type %d]",
                         SvTYPE (val));
  return;
}

/* [0, +1] */
/* Creates a userdata containing a Perl SV, and
 * leaves the new userdata on top of the stack.
 * The new Lua userdata takes ownership of one reference count.
 * The caller must have a reference count whose ownership
 * the caller is prepared to transfer to the Lua userdata.
 */
static void glue_sv_sv_noinc (lua_State* L, SV* sv) {
    SV** p_sv = (SV**)marpa_lua_newuserdata(L, sizeof(SV*));
    *p_sv = sv;
    /* warn("new ud %p, SV %p %s %d\n", p_sv, sv, __FILE__, __LINE__); */
    marpa_luaL_getmetatable(L, MT_NAME_SV);
    marpa_lua_setmetatable(L, -2);
    /* [sv_userdata] */
}

#define MARPA_SV_SV(L, sv) \
    (glue_sv_sv_noinc((L), (sv)), SvREFCNT_inc_simple_void_NN (sv))

/* Creates a userdata containing a reference to a Perl AV, and
 * leaves the new userdata on top of the stack.
 * The new Lua userdata takes ownership of one reference count.
 * The caller must have a reference count whose ownership
 * the caller is prepared to transfer to the Lua userdata.
 */
/* TODO: Will I need this? */
static void glue_sv_av_noinc (lua_State* L, AV* av) PERL_UNUSED_DECL;
static void glue_sv_av_noinc (lua_State* L, AV* av) {
    dTHX;
    SV* av_ref = newRV_noinc((SV*)av);
    SV** p_sv = (SV**)marpa_lua_newuserdata(L, sizeof(SV*));
    *p_sv = av_ref;
    /* warn("new ud %p, SV %p %s %d\n", p_sv, av_ref, __FILE__, __LINE__); */
    marpa_luaL_getmetatable(L, MT_NAME_SV);
    marpa_lua_setmetatable(L, -2);
    /* [sv_userdata] */
}

#define MARPA_SV_AV(L, av) \
    (SvREFCNT_inc_simple_void_NN (av), glue_sv_av_noinc((L), (av)))

static int glue_sv_undef (lua_State* L) {
    dTHX;
    /* [] */
    glue_sv_sv_noinc( L, newSV(0) );
    /* [sv_userdata] */
    return 1;
}

static int glue_sv_finalize_meth (lua_State* L) {
    dTHX;
    /* Is this check necessary after development? */
    SV** p_sv = (SV**)marpa_luaL_checkudata(L, 1, MT_NAME_SV);
    SV* sv = *p_sv;
    /* warn("decrementing ud %p, SV %p, %s %d\n", p_sv, sv, __FILE__, __LINE__); */
    SvREFCNT_dec (sv);
    return 0;
}

/* Convert Lua object to number, including our custom Marpa userdata's
 */
static lua_Number marpa_xlua_tonumber (lua_State* L, int idx, int* pisnum) {
    dTHX;
    void* ud;
    int pisnum2;
    lua_Number n;
    if (pisnum) *pisnum = 1;
    n = marpa_lua_tonumberx(L, idx, &pisnum2);
    if (pisnum2) return n;
    ud = marpa_luaL_testudata(L, idx, MT_NAME_SV);
    if (!ud) {
        if (pisnum) *pisnum = 0;
        return 0;
    }
    return (lua_Number) SvNV (*(SV**)ud);
}

static int glue_sv_add_meth (lua_State* L) {
    lua_Number num1 = marpa_xlua_tonumber(L, 1, NULL);
    lua_Number num2 = marpa_xlua_tonumber(L, 2, NULL);
    marpa_lua_pushnumber(L, num1+num2);
    return 1;
}

/* Fetch from table at index key.
 * The reference count is not changed, the caller must use this
 * SV immediately, or increment the reference count.
 * Will return 0, if there is no SV at that index.
 */
static SV** glue_av_fetch(SV* table, lua_Integer key) {
     dTHX;
     AV* av;
     if ( !SvROK(table) ) {
        croak ("Attempt to fetch from an SV which is not a ref");
     }
     if ( SvTYPE(SvRV(table)) != SVt_PVAV) {
        croak ("Attempt to fetch from an SV which is not an AV ref");
     }
     av = (AV*)SvRV(table);
     return av_fetch(av, (int)key, 0);
}

static int glue_av_fetch_meth(lua_State* L) {
    SV** p_result_sv;
    SV** p_table_sv = (SV**)marpa_luaL_checkudata(L, 1, MT_NAME_SV);
    lua_Integer key = marpa_luaL_checkinteger(L, 2);

    p_result_sv = glue_av_fetch(*p_table_sv, key);
    if (p_result_sv) {
        SV* const sv = *p_result_sv;
        /* Increment the reference count and put this SV on top of the stack */
        MARPA_SV_SV(L, sv);
    } else {
        /* Put a new nil SV on top of the stack */
        glue_sv_undef(L);
    }
    return 1;
}

/* Basically a Lua wrapper for Perl's av_len()
 */
static int
glue_av_len_meth (lua_State * L)
{
    dTHX;
    AV *av;
    SV **const p_table_sv = (SV **) marpa_luaL_checkudata (L, 1, MT_NAME_SV);
    SV* const table = *p_table_sv;

    if (!SvROK (table))
      {
          croak ("Attempt to fetch from an SV which is not a ref");
      }
    if (SvTYPE (SvRV (table)) != SVt_PVAV)
      {
          croak ("Attempt to fetch from an SV which is not an AV ref");
      }
    av = (AV *) SvRV (table);
    marpa_lua_pushinteger (L, av_len (av));
    return 1;
}

static void glue_av_store(SV* table, lua_Integer key, SV*value) {
     dTHX;
     AV* av;
     if ( !SvROK(table) ) {
        croak ("Attempt to index an SV which is not ref");
     }
     if ( SvTYPE(SvRV(table)) != SVt_PVAV) {
        croak ("Attempt to index an SV which is not an AV ref");
     }
     av = (AV*)SvRV(table);
     av_store(av, (int)key, value);
}

static int glue_av_store_meth(lua_State* L) {
    SV** p_table_sv = (SV**)marpa_luaL_checkudata(L, 1, MT_NAME_SV);
    lua_Integer key = marpa_luaL_checkinteger(L, 2);
    SV* value_sv = coerce_to_sv(L, 3, '-');

    /* coerce_to_sv transfered a reference count to us, which we
     * pass on to the AV.
     */
    glue_av_store(*p_table_sv, key, value_sv);
    return 0;
}

static void
glue_av_fill (lua_State * L, SV * sv, int x)
{
  dTHX;
  AV *av;
  SV **p_sv = (SV **) marpa_lua_newuserdata (L, sizeof (SV *));
     /* warn("%s %d\n", __FILE__, __LINE__); */
  *p_sv = sv;
     /* warn("%s %d\n", __FILE__, __LINE__); */
  if (!SvROK (sv))
    {
      croak ("Attempt to fetch from an SV which is not a ref");
    }
     /* warn("%s %d\n", __FILE__, __LINE__); */
  if (SvTYPE (SvRV (sv)) != SVt_PVAV)
    {
      croak ("Attempt to fill an SV which is not an AV ref");
    }
     /* warn("%s %d\n", __FILE__, __LINE__); */
  av = (AV *) SvRV (sv);
     /* warn("%s %d about to call av_file(..., %d)\n", __FILE__, __LINE__, x); */
  av_fill (av, x);
     /* warn("%s %d\n", __FILE__, __LINE__); */
}

static int glue_av_fill_meth (lua_State* L) {
    /* After development, check not needed */
    /* I think this call is not used anywhere in the test suite */
    SV** p_table_sv = (SV**)marpa_luaL_checkudata(L, 1, MT_NAME_SV);
    /* warn("%s %d\n", __FILE__, __LINE__); */
    lua_Integer index = marpa_luaL_checkinteger(L, 2);
    /* warn("%s %d\n", __FILE__, __LINE__); */
    glue_av_fill(L, *p_table_sv, (int)index);
    /* warn("%s %d\n", __FILE__, __LINE__); */
    return 0;
}

static int glue_sv_tostring_meth(lua_State* L) {
    /* Lua stack: [ sv_userdata ] */
    /* After development, check not needed */
    SV** p_table_sv = (SV**)marpa_luaL_checkudata(L, 1, MT_NAME_SV);
    marpa_lua_getglobal(L, "tostring");
    /* Lua stack: [ sv_userdata, to_string_fn ] */
    push_val (L, *p_table_sv);
    /* Lua stack: [ sv_userdata, to_string_fn, lua_equiv_of_sv ] */
    marpa_lua_call(L, 1, 1);
    /* Lua stack: [ sv_userdata, string_equiv_of_sv ] */
    if (!marpa_lua_isstring(L, -1)) {
       croak("sv could not be converted to string");
    }
    return 1;
}

static int glue_sv_svaddr_meth(lua_State* L) {
    /* Lua stack: [ sv_userdata ] */
    /* For debugging, so keep the check even after development */
    SV** p_table_sv = (SV**)marpa_luaL_checkudata(L, 1, MT_NAME_SV);
    marpa_lua_pushinteger (L, (lua_Integer)PTR2nat(*p_table_sv));
    return 1;
}

static int glue_sv_addr_meth(lua_State* L) {
    /* Lua stack: [ sv_userdata ] */
    /* For debugging, so keep the check even after development */
    SV** p_table_sv = (SV**)marpa_luaL_checkudata(L, 1, MT_NAME_SV);
    marpa_lua_pushinteger (L, (lua_Integer)PTR2nat(p_table_sv));
    return 1;
}

static const struct luaL_Reg glue_sv_meths[] = {
    {"__add", glue_sv_add_meth},
    {"__gc", glue_sv_finalize_meth},
    {"__index", glue_av_fetch_meth},
    {"__newindex", glue_av_store_meth},
    {"__tostring", glue_sv_tostring_meth},
    {NULL, NULL},
};

static const struct luaL_Reg glue_sv_funcs[] = {
    {"fill", glue_av_fill_meth},
    {"top_index", glue_av_len_meth},
    {"undef", glue_sv_undef},
    {"svaddr", glue_sv_svaddr_meth},
    {"addr", glue_sv_addr_meth},
    {NULL, NULL},
};

/* create SV metatable */
static void create_sv_mt (lua_State* L) {
    int base_of_stack = marpa_lua_gettop(L);
    marpa_luaL_newmetatable(L, MT_NAME_SV);
    /* Lua stack: [mt] */
    /* register methods */
    marpa_luaL_setfuncs(L, glue_sv_meths, 0);
    /* Lua stack: [mt] */
    marpa_lua_settop(L, base_of_stack);
}

static const struct luaL_Reg marpa_funcs[] = {
    {NULL, NULL},
};

/*
 * Message handler used to run all chunks
 * The message processing can be significant.
 * Here I try to do the minimum necessary to grab the traceback
 * data.
 */
static int glue_msghandler (lua_State *L) {
  const int original_type = marpa_lua_type(L, -1);
  int traceback_type;
  int result_ix;
  int is_X = 0;
  if (original_type == LUA_TSTRING) {
    const char *msg = marpa_lua_tolstring(L, 1, NULL);
    marpa_luaL_traceback(L, L, msg, 1);  /* append a standard traceback */
    return 1;
  }
  result_ix = marpa_lua_gettop(L);
  /* Is this an exception object table */
  if (original_type == LUA_TTABLE) {
     marpa_lua_getmetatable(L, -1);
     marpa_lua_rawgetp (L, LUA_REGISTRYINDEX, &kollos_X_mt_key);
     is_X = marpa_lua_compare (L, -2, -1, LUA_OPEQ);
  }
  if (!is_X) {
    X_fallback_wrap(L);
    result_ix = marpa_lua_gettop(L);
  }
  /* At this point the exception table that will be
   * the result is the top of stack
   */
  traceback_type = marpa_lua_getfield(L, result_ix, "traceback");
  /* Default (i.e, nil) is "true" */
  if (traceback_type == LUA_TNIL || marpa_lua_toboolean(L, -1)) {
    /* result.where = debug.traceback() */
    marpa_luaL_traceback(L, L, NULL, 1);
    marpa_lua_setfield(L, result_ix, "where");
  }
  marpa_lua_settop(L, result_ix);
  return 1;
}

static void recursive_coerce_to_lua(
  lua_State* L, int visited_ix, SV *sv, char sig);

static void
coerce_to_lua (lua_State * L, SV *sv, char sig)
{
   dTHX;
   int visited_ix;

   marpa_lua_newtable(L);
   visited_ix = marpa_lua_gettop(L);
   recursive_coerce_to_lua(L, visited_ix, sv, sig);
   /* Replaces the visited table with the result */
   marpa_lua_copy(L, -1, visited_ix);
   /* Leaves the result on top of the stack */
   marpa_lua_settop(L, visited_ix);
   return;
}

/* Caller must ensure that `av` is in fact
 * an AV.
 */
static void coerce_to_lua_sequence(
  lua_State* L, int visited_ix, AV *av, char sig)
{
    dTHX;
    SSize_t last_perl_ix;
    I32 perl_ix;
    int lud_ix;
    int result_ix;

    /* A light user data is used to provide a unique
     * value for the "visited table".  This address is
     * TOS+1, where TOS is the top of stack when this
     * function was called.  This location will also
     * contain the return value
     */

    marpa_lua_pushlightuserdata(L, (void*)av);
    lud_ix = marpa_lua_gettop(L);
    if (!visitee_on(L, visited_ix, lud_ix)) {
        marpa_lua_pushliteral(L, "[cycle in Perl array]");
        result_ix = marpa_lua_gettop (L);
        goto RESET_STACK;
    }

    /* Below we will call this recursively,
     * so we need to make sure we have enough stack
     */
    marpa_luaL_checkstack(L, MYLUA_STACK_INCR, MYLUA_TAG);

    marpa_lua_newtable(L);
    result_ix = marpa_lua_gettop(L);
    last_perl_ix = av_len(av);
    for (perl_ix = 0; perl_ix <= last_perl_ix; perl_ix++) {
       /* warn("%s %d fetching perl array index %ld\n", __FILE__, __LINE__, (long)(perl_ix)); */
       SV** p_sv = av_fetch(av, perl_ix, 0);
       if (p_sv) {
           recursive_coerce_to_lua(L, visited_ix, *p_sv, sig);
       } else {
           marpa_lua_pushboolean(L, 0);
       }
       /* warn("%s %d setting lua array index %ld\n", __FILE__, __LINE__, (long)(perl_ix+1)); */
       marpa_lua_seti(L, result_ix, perl_ix+1);
    }

    visitee_off(L, visited_ix, lud_ix);

    RESET_STACK:

    /* Replaces the lud with the result */
    marpa_lua_copy(L, result_ix, lud_ix);
    marpa_lua_settop(L, lud_ix);
}

/* [0, +1] */
/* Caller must ensure that `hv` is in fact
 * an HV.
 * All Perl hash keys are converted to Lua
 * string keys, and the values are converted
 * recursively according to "sig".
 */
static void coerce_to_lua_table(
  lua_State* L, int visited_ix, HV *hv, char sig)
{
    dTHX;
    int lud_ix;
    int result_ix;

    /* A light user data is used to provide a unique
     * value for the "visited table".  This address is
     * TOS+1, where TOS is the top of stack when this
     * function was called.  This location will also
     * contain the return value
     */
    marpa_lua_pushlightuserdata (L, (void *) hv);
    lud_ix = marpa_lua_gettop (L);
    if (!visitee_on (L, visited_ix, lud_ix)) {
        marpa_lua_pushliteral (L, "[cycle in Perl hash]");
        result_ix = marpa_lua_gettop (L);
        goto RESET_STACK;
    }

    /* Below we will call this recursively,
     * so we need to make sure we have enough stack
     */
    marpa_luaL_checkstack (L, MYLUA_STACK_INCR, MYLUA_TAG);

    marpa_lua_newtable (L);
    result_ix = marpa_lua_gettop (L);
    hv_iterinit (hv);
    {
        HE *entry;
        while ((entry = hv_iternext (hv))) {

            SV *val = hv_iterval(hv, entry);

            /* We must use hv_iterkeysv() because hv_iterkey() fails
             * for certain Unicode keys -- U+00C1 being one.
             */
            SV* keysv = hv_iterkeysv(entry);
            STRLEN keylen;
            const char *key = SvPV (keysv, keylen);

            int error_pos = find_utf8_error(key, key+keylen);
            if (error_pos >= 0) {
               croak("Non-UTF-8 string ('%.10s') passed to Marpa, problem at pos=%ld, '%.10s'",
                    key, (long)error_pos, key+error_pos);
            }

            /* warn("%s %d pushing Perl hash key as lua string %.10s klen=%ld", __FILE__, __LINE__, key, (long)klen); */
            /* warn("%s %d 1-length Perl hash key %lx", __FILE__, __LINE__, (long)*key); */
            /* warn("from hv_iterkeysv(): length=%ld, key[0]=%lx key[1]=%lx", (long)len, (long)s[0], (long)s[1]); */

            marpa_lua_pushlstring (L, key, (size_t)keylen);

            recursive_coerce_to_lua (L, visited_ix, val, sig);
            marpa_lua_settable (L, result_ix);
        }
    }

    visitee_off (L, visited_ix, lud_ix);

  RESET_STACK:

    /* Replaces the lud with the result */
    marpa_lua_copy (L, result_ix, lud_ix);
    marpa_lua_settop (L, lud_ix);
}

/* Coerce an SV to Lua, leaving it on the stack */
static void recursive_coerce_to_lua(
  lua_State* L, int visited_ix, SV *sv, char sig)
{
    dTHX;

    if (sig == 'S') {
        SvREFCNT_inc_simple_void_NN (sv);
        glue_sv_sv_noinc (L, sv);
        return;
    }

    if (!SvOK(sv)) {
        marpa_lua_pushnil (L);
        return;
    }

    if (SvROK(sv)) {
        SV* referent = SvRV(sv);
        if (SvTYPE(referent) == SVt_PVAV) {
            coerce_to_lua_sequence(L, visited_ix, (AV*)referent, sig);
            return;
        }
        if (SvTYPE(referent) == SVt_PVHV) {
            coerce_to_lua_table(L, visited_ix, (HV*)referent, sig);
            return;
        }
        goto DEFAULT_TO_STRING;
    }

    switch(sig) {
    case 'i':
        if (SvIOK(sv)) {
          marpa_lua_pushinteger (L, (lua_Integer) SvIV (sv));
          return;
        }
        break;
    case 'n':
        if (SvNIOK(sv)) {
          marpa_lua_pushnumber (L, (lua_Number) SvNV (sv));
          return;
        }
        break;
    case 's': break;
    default:
        croak
            ("Internal error: invalid sig option %c in xlua EXEC_SIG_BODY", sig);
    }

    DEFAULT_TO_STRING:
    /* If here, we are coercing to a string */
    {
      STRLEN len;
      const char *s = SvPV (sv, len);
      int error_pos = find_utf8_error(s, s+len);
      if (error_pos >= 0) {
         croak("Non-UTF-8 string ('%.10s') passed to Marpa, problem at pos=%ld, '%.10s'",
              s, (long)error_pos, s+error_pos);
      }
      /* warn("%s %d pushing 2-length lua string %lx %lx", __FILE__, __LINE__, (long)s[0], (long)s[1]); */
      marpa_lua_pushlstring (L, s, (size_t)len);
    }
    return;
}

#define EXPECTED_LIBMARPA_MAJOR 8
#define EXPECTED_LIBMARPA_MINOR 6
#define EXPECTED_LIBMARPA_MICRO 0

#include "inspect_inc.c"
#include "kollos_inc.c"
#include "glue_inc.c"

MODULE = Marpa::R3        PACKAGE = Marpa::R3::Thin

PROTOTYPES: DISABLE

void
debug_level_set(new_level)
    int new_level;
PPCODE:
{
  const int old_level = marpa_debug_level_set (new_level);
  if (old_level || new_level)
    marpa_r3_warn ("libmarpa debug level set to %d, was %d", new_level,
                   old_level);
  XSRETURN_YES;
}

void
error_names()
PPCODE:
{
  int error_code;
  for (error_code = 0; error_code < MARPA_ERROR_COUNT; error_code++)
    {
      const char *error_name = marpa_error_description[error_code].name;
      XPUSHs (sv_2mortal (newSVpv (error_name, 0)));
    }
}

void
version()
PPCODE:
{
    int version[3];
    int result = marpa_version(version);
    if (result < 0) { XSRETURN_UNDEF; }
    XPUSHs (sv_2mortal (newSViv (version[0])));
    XPUSHs (sv_2mortal (newSViv (version[1])));
    XPUSHs (sv_2mortal (newSViv (version[2])));
}

void
tag()
PPCODE:
{
   const char* tag = _marpa_tag();
   XSRETURN_PV(tag);
}

MODULE = Marpa::R3            PACKAGE = Marpa::R3::Lua

void
new(class )
PPCODE:
{
    SV *new_sv;
    Marpa_Lua *lua_wrapper;
    int marpa_table;
    int base_of_stack;
    lua_State *L;
    struct lua_extraspace *p_extra;
    int preload_ix;
    int package_ix;
    int loaded_ix;
    int msghandler_ix;
    int status;

    Newx (lua_wrapper, 1, Marpa_Lua);

    L = marpa_luaL_newstate ();
    if (!L)
      {
          croak
              ("Marpa::R3 internal error: Lua interpreter failed to start");
      }

    base_of_stack = marpa_lua_gettop(L);

    /* Get lots of stack,
     * 1.) to avoid a lot of minor lua_pop()'s
     * 2.) to allow us to freely store things in fixed locations
     *     on the stack.
     */
    if (!marpa_lua_checkstack(L, 50))
    {
        croak ("Internal Marpa::R3 error; could not grow stack: " MYLUA_TAG);
    }

    marpa_lua_pushcfunction (L, glue_msghandler);
    msghandler_ix = marpa_lua_gettop(L);

    Newx( p_extra, 1, struct lua_extraspace);
    *(struct lua_extraspace **)marpa_lua_getextraspace(L) = p_extra;
    p_extra->ref_count = 1;

    marpa_luaL_openlibs (L);    /* open libraries */

    /* Get the preload table and leave it on the stack */
    marpa_lua_getglobal(L, "package");
    package_ix = marpa_lua_gettop(L);
    marpa_lua_getfield(L, package_ix, "preload");
    preload_ix = marpa_lua_gettop(L);
    marpa_lua_getfield(L, package_ix, "loaded");
    loaded_ix = marpa_lua_gettop(L);

    /* Set up preload of inspect package */
    if (marpa_luaL_loadbuffer(L, inspect_loader, inspect_loader_length, MYLUA_TAG)
      != LUA_OK) {
      const char* msg = marpa_lua_tostring(L, -1);
      croak(msg);
    }
    marpa_lua_setfield(L, preload_ix, "inspect");

    /* Set up preload of kollos metal package */
    marpa_lua_pushcfunction(L, kollos_metal_loader);
    marpa_lua_setfield(L, preload_ix, "kollos.metal");

    /* Set up preload of kollos package */
    if (marpa_luaL_loadbuffer(L, kollos_loader, kollos_loader_length, MYLUA_TAG)
      != LUA_OK) {
      const char* msg = marpa_lua_tostring(L, -1);
      croak(msg);
    }
    marpa_lua_setfield(L, preload_ix, "kollos");

    /* Actually load glue package
     * This will load the inspect, kollos.metal and kollos
     * packages.
     */
    if (marpa_luaL_loadbuffer(L, glue_loader, glue_loader_length, MYLUA_TAG)
      != LUA_OK) {
      const char* msg = marpa_lua_tostring(L, -1);
      croak(msg);
    }
    status = marpa_lua_pcall (L, 0, 1, msghandler_ix);
    if (status != 0) {
        const char *exception_string = handle_pcall_error (L, status);
        marpa_lua_settop (L, base_of_stack);
        croak (exception_string);
    }
    /* Dup the module on top of the stack */
    marpa_lua_pushvalue(L, -1);
    marpa_lua_setfield(L, loaded_ix, "glue");
    marpa_lua_setglobal(L, "glue");

    /* create metatables */
    create_sv_mt(L);

    marpa_luaL_newlib(L, marpa_funcs);
    /* Lua stack: [ marpa_table ] */
    marpa_table = marpa_lua_gettop (L);
    /* Lua stack: [ marpa_table ] */
    marpa_lua_pushvalue (L, -1);
    /* Lua stack: [ marpa_table, marpa_table ] */
    marpa_lua_setglobal (L, "marpa");
    /* Lua stack: [ marpa_table ] */

    marpa_luaL_newlib(L, glue_sv_funcs);
    /* Lua stack: [ marpa_table, sv_table ] */
    marpa_lua_setfield (L, marpa_table, "sv");
    /* Lua stack: [ marpa_table ] */

    marpa_lua_settop (L, base_of_stack);
    /* Lua stack: [] */
    lua_wrapper->L = L;

    new_sv = sv_newmortal ();
    sv_setref_pv (new_sv, marpa_lua_class_name, (void *) lua_wrapper);
    XPUSHs (new_sv);
}

void
DESTROY( lua_wrapper )
    Marpa_Lua *lua_wrapper;
PPCODE:
{
  lua_refdec(lua_wrapper->L);
  Safefree (lua_wrapper);
}

void
call_by_tag( lua_wrapper, lua_ref, tag, codestr, signature, ... )
   Marpa_Lua* lua_wrapper;
   int lua_ref;
   const char* tag;
   const char* codestr;
   const char *signature;
PPCODE:
{
    const char * const error_tag = tag;

    /* 0 is never an acceptable index,
     * but this suppresses the GCC warning
     */
    int object_stack_ix = 0;

    const int first_optional_arg = 5;
    const int is_method = (lua_ref > 0);
    lua_State *const L = lua_wrapper->L;
    const int base_of_stack = marpa_lua_gettop (L);
    int msghandler_ix;
    int cache_ix;
    int top_after;
    int type;

    /* warn("%s %d is_method=%ld lua_ref=%ld", __FILE__, __LINE__,
     *  (long)is_method, (long)lua_ref);
     */

    marpa_lua_pushcfunction(L, glue_msghandler);
    msghandler_ix = marpa_lua_gettop(L);

    if (lua_ref > 0) {
        marpa_lua_rawgeti (L, LUA_REGISTRYINDEX, lua_ref);
        /* Lua stack: [ recce_table ] */
        object_stack_ix = marpa_lua_gettop (L);
    }

    marpa_lua_getglobal (L, "glue");
    marpa_lua_getfield (L, -1, "code_by_tag");
    cache_ix = marpa_lua_gettop(L);
    type = marpa_lua_getfield (L, cache_ix, tag);

    /*    warn("%s %d", __FILE__, __LINE__); */
    if (type != LUA_TFUNCTION) {

        const int status =
            marpa_luaL_loadbuffer (L, codestr, strlen (codestr), tag);
        if (status != 0) {
            const char *error_string = marpa_lua_tostring (L, -1);
            marpa_lua_pop (L, 1);
            croak ("Marpa::R3 error in call_by_tag(): %s", error_string);
        }
        marpa_lua_pushvalue (L, -1);
        marpa_lua_setfield (L, cache_ix, tag);
    }

    /* [ recce_table, function ] */

    {
        const int function_stack_ix = marpa_lua_gettop (L);
        int i, status;
        int arg_count;
        const int args_supplied = items - first_optional_arg;
        char default_return_sig[] = "*";
        const char* return_signature = default_return_sig;

        marpa_luaL_checkstack(L, items+20, "xlua EXEC_SIG_BODY");

        if (is_method) {
            /* first argument is table for object */
            marpa_lua_pushvalue (L, object_stack_ix);
            /* [ object_table, function, object_table ] */
        }

        /* the remaining arguments are those passed to the Perl call */
        for (i = 0; ; i++) {
            const char this_sig = signature[i];
            const int arg_ix = first_optional_arg + i;
            SV *arg_sv;

            switch (this_sig) {
            case '>':              /* end of arguments */
                return_signature = signature+i+1;
                goto endargs;
            case 0:              /* end of arguments */
                goto endargs;
            }

            if ((size_t)arg_ix >= (size_t)items) {
                croak
                    ("Internal error: signature ('%s') wants %ld items, but only %ld arguments in call_by_tag()",
                        signature, (long)(i + 1), (long)(items - first_optional_arg));
            }

            arg_sv = ST (arg_ix);
            coerce_to_lua(L, arg_sv, this_sig);
        }
      endargs:;

       arg_count = marpa_lua_gettop(L) - function_stack_ix;

       if (arg_count - is_method != args_supplied) {
                croak
                    ("Internal error: signature ('%s') wants %ld items, but %ld arguments in call_by_tag()\n"
                        "    Problem was at %s\n",
                        signature, (long)(arg_count - is_method), (long)(args_supplied),
                        error_tag);
       }

        status = marpa_lua_pcall (L, arg_count, LUA_MULTRET, msghandler_ix);
        if (status != 0) {
            const char *exception_string = handle_pcall_error(L, status);
            marpa_lua_settop (L, base_of_stack);
            croak(exception_string);
        }

        marpa_luaL_checkstack(L, 20, "xlua EXEC_SIG_BODY");
        
        top_after = marpa_lua_gettop (L);

        {
            /* check count of return values */
            int i;
            const int actual_return_count
              = top_after - function_stack_ix + 1;
            int desired_return_count = 0;
            int wanted_is_exact = 1;
            for (i = 0; ; i++) {
                const char this_sig = return_signature[i];
                if (!this_sig) break;
                if (!wanted_is_exact) {
                  /* If here, we've seen a '*', which has trailing
                   * signature items.
                   */
                  croak
                      ("Internal error: poorly formed return signature ('%s')", signature);
                }
                switch(this_sig) {
                case '*':
                     wanted_is_exact = 0;
                     break;
                case '-':
                case '0':
                case '1':
                case '2':
                     desired_return_count++;
                     break;
                default:
                    croak
                        ("Internal error: invalid return sig option '%c', signature=%s",
                        this_sig, signature);
                }
            }
            if (wanted_is_exact && actual_return_count > desired_return_count) {
                croak
                    ("Internal error; too many return items for signature ('%s'); actual=%ld; desired=%ld\n"
                        "    Problem was at %s\n",
                        signature, (long)actual_return_count, (long)desired_return_count,
                        error_tag
                        );
            }
            if (actual_return_count < desired_return_count) {
                croak
                    ("Internal error; too few return items for signature ('%s'); actual=%ld; desired=%ld\n"
                        "    Problem was at %s\n",
                        signature, (long)actual_return_count, (long)desired_return_count,
                        error_tag
                        );
            }
        }

        /* return args to caller */
        {
            SV *sv_result;
            int stack_ix;
            int signature_ix = 0;
            for (stack_ix = function_stack_ix;
                    stack_ix <= top_after;
                    stack_ix++) {
                const char this_sig = return_signature[signature_ix];
                switch (this_sig) {
                    case '*':
                        sv_result = coerce_to_sv (L, stack_ix, '-');
                        /* Took ownership of sv_result, we now need to mortalize it */
                        XPUSHs (sv_2mortal (sv_result));
                        break;
                    case '-':
                    case '0':
                    case '2':
                        sv_result = coerce_to_sv (L, stack_ix, this_sig);
                        /* Took ownership of sv_result, we now need to mortalize it */
                        XPUSHs (sv_2mortal (sv_result));
                        signature_ix++;
                        break;
                    default:
                        croak
                            ("Internal error: invalid return sig option %c in xlua EXEC_SIG_BODY",
                            this_sig);
                    case 0:
                        croak
                            ("Internal error: return sig too short ('%s') in xlua EXEC_SIG_BODY",
                            signature);
                }
            }
        }

        marpa_lua_settop (L, base_of_stack);
    }
}

void
exec( lua_wrapper, codestr, ... )
   Marpa_Lua* lua_wrapper;
   char* codestr;
PPCODE:
{
    const char * const error_tag = "Marpa::R3::Lua exec()";
    lua_State *const L = lua_wrapper->L;
    const int base_of_stack = marpa_lua_gettop (L);
    int arg_count;
    int msghandler_ix;
    int kollos_ix;

    marpa_lua_pushcfunction(L, glue_msghandler);
    msghandler_ix = marpa_lua_gettop(L);
    marpa_lua_getglobal (L, "kollos");
    kollos_ix = marpa_lua_gettop(L);

    {
        const int load_status = marpa_luaL_loadstring (L, codestr);
        if (load_status != 0) {
            /* The following is complex, because the error string
             * must be copied before it is removed from the Lua stack.
             * This is done with a Perl mortal SV.
             */
            const char *error_string = marpa_lua_tostring (L, -1);
            SV *temp_sv = sv_newmortal ();
            sv_setpvf (temp_sv, "Marpa::R3::Lua error in luaL_loadstring for %s: %s",
                error_tag, error_string);
            marpa_lua_settop (L, base_of_stack);
            croak ("%s", SvPV_nolen (temp_sv));
        }
    }

    /* At this point, the Lua function is on the top of the stack:
     * [func]
     * Set its first up value to the sandbox table.
     */
    marpa_lua_getfield (L, kollos_ix, "sandbox");
    if (!marpa_lua_setupvalue (L, -2, 1)) {
        marpa_lua_settop (L, base_of_stack);
        croak ("Marpa::R3::Lua error -- lua_setupvalue() failed");
    }
    /* [func] */

    {
        const int function_stack_ix = marpa_lua_gettop (L);
        int i, status;
        int top_after;

        marpa_luaL_checkstack(L, items+20, "xlua EXEC_BODY");

        /* the remaining arguments are those passed to the Perl call */
        for (i = 2; i < items; i++) {
            SV *arg_sv = ST (i);
            if (!SvOK (arg_sv)) {
                croak ("Marpa::R3::Lua::exec arg %d is not an SV", i);
            }
            MARPA_SV_SV (L, arg_sv);
        }

       arg_count = marpa_lua_gettop(L) - function_stack_ix;

        status = marpa_lua_pcall (L, arg_count, LUA_MULTRET, msghandler_ix);
        if (status != 0) {
            const char *exception_string = handle_pcall_error(L, status);
            marpa_lua_settop (L, base_of_stack);
            croak(exception_string);
        }

        marpa_luaL_checkstack(L, 20, "xlua EXEC_BODY");

        /* return args to caller */
        top_after = marpa_lua_gettop (L);
        for (i = function_stack_ix; i <= top_after; i++) {
            SV *sv_result = coerce_to_sv (L, i, '-');
            /* Took ownership of sv_result, we now need to mortalize it */
            XPUSHs (sv_2mortal (sv_result));
        }

        marpa_lua_settop (L, base_of_stack);
    }
}

BOOT:

    marpa_debug_handler_set(marpa_r3_warn);

    /* vim: set expandtab shiftwidth=2: */
