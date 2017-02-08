/*
 * Marpa::R3 is Copyright (C) 2017, Jeffrey Kegler.
 *
 * This module is free software; you can redistribute it and/or modify it
 * under the same terms as Perl 5.10.1. For more details, see the full text
 * of the licenses in the directory LICENSES.
 *
 * This program is distributed in the hope that it will be
 * useful, but it is provided “as is” and without any express
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

struct symbol_g_properties {
     lua_Integer priority;
     unsigned int is_lexeme:1;
     unsigned int t_pause_before:1;
     unsigned int t_pause_before_active:1;
     unsigned int t_pause_after:1;
     unsigned int t_pause_after_active:1;
};

struct symbol_r_properties {
     lua_Integer lexeme_priority;
     unsigned int t_pause_before_active:1;
     unsigned int t_pause_after_active:1;
};

union marpa_slr_event_s;

#define MARPA_SLREV_LEXEME_DISCARDED 3
#define MARPA_SLRTR_LEXEME_DISCARDED 16
#define MARPA_SLRTR_LEXEME_ACCEPTABLE 23
#define MARPA_SLRTR_LEXEME_OUTPRIORITIZED 24

#define MARPA_SLREV_TYPE(event) ((event)->t_header.t_event_type)

union marpa_slr_event_s
{
  struct
  {
    int t_event_type;
  } t_header;

  struct
  {
    int event_type;
    int t_rule_id;
    int t_start_of_lexeme;
    int t_end_of_lexeme;
  } t_trace_lexeme_discarded;

  struct
  {
    int event_type;
    int t_rule_id;
    int t_start_of_lexeme;
    int t_end_of_lexeme;
    int t_last_g1_location;
  } t_lexeme_discarded;

  struct
  {
    int event_type;
    int t_start_of_lexeme;
    int t_end_of_lexeme;
    int t_lexeme;
    int t_priority;
    int t_required_priority;
  } t_trace_lexeme_acceptable;


  struct
  {
    int event_type;
    int t_start_of_lexeme;
    int t_end_of_lexeme;
    int t_lexeme;
    int t_priority;
    int t_required_priority;
  } t_lexeme_acceptable;

};

typedef struct
{
  struct symbol_g_properties *symbol_g_properties;
} Scanless_G;

typedef struct {
  lua_Integer lua_ref;
  lua_State* L;
  Scanless_G* inner;
} Outer_G;

typedef struct
{
  Scanless_G *slg;
  AV *token_values;
  int start_of_lexeme;
  int end_of_lexeme;

  /* Input position at which to start the lexer.
     -1 means no restart.
   */
  int lexer_start_pos;
  int lexer_read_result;

  /* A boolean to prevent the inappropriate mixing
   * of internal and external scanning
   */
  int is_external_scanning;

  int last_perl_pos;
  int perl_pos;

  /* character position, taking into account Unicode
     Equivalent to Perl pos()
     One past last actual position indicates past-end-of-string
   */
  /* Position of problem -- unspecifed if not returning a problem */
  int problem_pos;
  int throw;
  int start_of_pause_lexeme;
  int end_of_pause_lexeme;
  struct symbol_r_properties *symbol_r_properties;

  Marpa_Symbol_ID input_symbol_id;
  lua_Integer codepoint;                 /* For error returns */
  int end_pos;

  union marpa_slr_event_s* t_lexemes;
  int t_lexeme_capacity;
  int t_lexeme_count;

  /* We need a copy of the outer_slr lua_ref,
   * but hopefully only while refactoring
   */

} Scanless_R;

typedef struct
{
  /* Lua "reference" to this object */
  lua_Integer lua_ref;
  lua_State* L;
  SV *slg_sv;
} Outer_R;

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

static void marpa_slr_lexeme_clear( Scanless_R* slr )
{
  slr->t_lexeme_count = 0;
}

static union marpa_slr_event_s * marpa_slr_lexeme_push( Scanless_R* slr )
{
  if (slr->t_lexeme_count >= slr->t_lexeme_capacity)
    {
      slr->t_lexeme_capacity *= 2;
      Renew (slr->t_lexemes, (unsigned int)slr->t_lexeme_capacity, union marpa_slr_event_s);
    }
  return slr->t_lexemes + (slr->t_lexeme_count++);
}


typedef struct marpa_g Grammar;
/* The error_code member should usually be ignored in favor of
 * getting a fresh error code from Libmarpa.  Essentially it
 * acts as an optional return value for marpa_g_error()
 */

typedef struct marpa_r Recce;

typedef struct marpa_b Bocage;

typedef struct marpa_o Order;

typedef struct marpa_t Tree;

typedef struct marpa_v Value;

#define MARPA_XS_V_MODE_IS_INITIAL 0
#define MARPA_XS_V_MODE_IS_RAW 1
#define MARPA_XS_V_MODE_IS_STACK 2

static const char grammar_c_class_name[] = "Marpa::R3::Thin::G";
static const char recce_c_class_name[] = "Marpa::R3::Thin::R";
static const char scanless_g_class_name[] = "Marpa::R3::Thin::SLG";
static const char scanless_r_class_name[] = "Marpa::R3::Thin::SLR";
static const char marpa_lua_class_name[] = "Marpa::R3::Lua";

static const char *
step_type_to_string (const lua_Integer step_type)
{
  const char *step_type_name = NULL;
  if (step_type >= 0 && step_type < MARPA_STEP_COUNT) {
      step_type_name = marpa_step_type_description[step_type].name;
  }
  return step_type_name;
}

static void
call_by_tag (lua_State * L, const char* tag, const char *codestr,
  const char *sig, ...);

/* Note: returned string is in a mortal SV --
 * copy it if you want want to save it.
 */
static const char *
slg_l0_error (Outer_G * outer_slg) PERL_UNUSED_DECL;
static const char *
slg_l0_error (Outer_G * outer_slg)
{
    dTHX;
    SV *error_description;
    call_by_tag (outer_slg->L, MYLUA_TAG,
        "slg = ...\n"
        "local l0g = slg.lmw_l0g\n"
        "return l0g:error_description()\n", "G>C",
        outer_slg->lua_ref, &error_description);
    return SvPV_nolen (error_description);
}

/* Note: returned string is in a mortal SV --
 * copy it if you want want to save it.
 */
static const char *
slr_l0_error (Outer_R * outer_slr)
{
    dTHX;
    SV *error_description;
    call_by_tag (outer_slr->L, MYLUA_TAG,
        "recce = ...\n"
        "local l0g = recce.slg.lmw_l0g\n"
        "return l0g:error_description()\n", "R>C",
        outer_slr->lua_ref, &error_description);
    return SvPV_nolen (error_description);
}

/* Note: returned string is in a mortal SV --
 * copy it if you want want to save it.
 */
static const char *
slg_g1_error (Outer_G * outer_slg) PERL_UNUSED_DECL;
static const char *
slg_g1_error (Outer_G * outer_slg)
{
    dTHX;
    SV *error_description;
    call_by_tag (outer_slg->L, MYLUA_TAG,
        "slg = ...\n"
        "local g1g = slg.lmw_g1g\n"
        "return g1g:error_description()\n", "G>C",
        outer_slg->lua_ref, &error_description);
    return SvPV_nolen (error_description);
}

/* Note: returned string is in a mortal SV --
 * copy it if you want want to save it.
 */
static const char *
slr_g1_error (Outer_R * outer_slr)
{
    dTHX;
    SV *error_description;
    call_by_tag (outer_slr->L, MYLUA_TAG,
        "recce = ...\n"
        "local g1g = recce.slg.lmw_g1g\n"
        "return g1g:error_description()\n", "R>C",
        outer_slr->lua_ref, &error_description);
    return SvPV_nolen (error_description);
}

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

/* Make the Lua reference facility available from
 * Lua itself
 */
static int
xlua_ref(lua_State* L)
{
    marpa_luaL_checktype(L, 1, LUA_TTABLE);
    marpa_luaL_checkany(L, 2);
    marpa_lua_pushinteger(L, marpa_luaL_ref(L, 1));
    return 1;
}

static int
xlua_unref(lua_State* L)
{
    marpa_luaL_checktype(L, 1, LUA_TTABLE);
    marpa_luaL_checkinteger(L, 2);
    marpa_luaL_unref(L, 1, (int)marpa_lua_tointeger(L, 2));
    return 0;
}

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
        result =
            newSVpvn (marpa_lua_tostring (L, idx), marpa_lua_rawlen (L,
                idx));
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

        if (type_pushed == LUA_TNIL) { break; }
        value_ix = marpa_lua_gettop(L); /* We need an absolute index, not -1 */
	entry_value = recursive_coerce_to_sv(L, visited_ix, value_ix, signature);
	ownership_taken = av_store(av, (int)seq_ix + ix_offset, entry_value);
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
push_val (lua_State * L, SV * val) PERL_UNUSED_DECL;
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
static void marpa_sv_sv_noinc (lua_State* L, SV* sv) {
    SV** p_sv = (SV**)marpa_lua_newuserdata(L, sizeof(SV*));
    *p_sv = sv;
    /* warn("new ud %p, SV %p %s %d\n", p_sv, sv, __FILE__, __LINE__); */
    marpa_luaL_getmetatable(L, MT_NAME_SV);
    marpa_lua_setmetatable(L, -2);
    /* [sv_userdata] */
}

#define MARPA_SV_SV(L, sv) \
    (marpa_sv_sv_noinc((L), (sv)), SvREFCNT_inc_simple_void_NN (sv))

/* Creates a userdata containing a reference to a Perl AV, and
 * leaves the new userdata on top of the stack.
 * The new Lua userdata takes ownership of one reference count.
 * The caller must have a reference count whose ownership
 * the caller is prepared to transfer to the Lua userdata.
 */
static void marpa_sv_av_noinc (lua_State* L, AV* av) {
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
    (SvREFCNT_inc_simple_void_NN (av), marpa_sv_av_noinc((L), (av)))

static int marpa_sv_undef (lua_State* L) {
    dTHX;
    /* [] */
    marpa_sv_sv_noinc( L, newSV(0) );
    /* [sv_userdata] */
    return 1;
}

static int marpa_sv_finalize_meth (lua_State* L) {
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

static int marpa_sv_add_meth (lua_State* L) {
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
static SV** marpa_av_fetch(SV* table, lua_Integer key) {
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

static int marpa_av_fetch_meth(lua_State* L) {
    SV** p_result_sv;
    SV** p_table_sv = (SV**)marpa_luaL_checkudata(L, 1, MT_NAME_SV);
    lua_Integer key = marpa_luaL_checkinteger(L, 2);

    p_result_sv = marpa_av_fetch(*p_table_sv, key);
    if (p_result_sv) {
        SV* const sv = *p_result_sv;
        /* Increment the reference count and put this SV on top of the stack */
        MARPA_SV_SV(L, sv);
    } else {
        /* Put a new nil SV on top of the stack */
        marpa_sv_undef(L);
    }
    return 1;
}

/* Basically a Lua wrapper for Perl's av_len()
 */
static int
marpa_av_len_meth (lua_State * L)
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

static void marpa_av_store(SV* table, lua_Integer key, SV*value) {
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

static int marpa_av_store_meth(lua_State* L) {
    SV** p_table_sv = (SV**)marpa_luaL_checkudata(L, 1, MT_NAME_SV);
    lua_Integer key = marpa_luaL_checkinteger(L, 2);
    SV* value_sv = coerce_to_sv(L, 3, '-');

    /* coerce_to_sv transfered a reference count to us, which we
     * pass on to the AV.
     */
    marpa_av_store(*p_table_sv, key, value_sv);
    return 0;
}

static void
marpa_av_fill (lua_State * L, SV * sv, int x)
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

static int marpa_av_fill_meth (lua_State* L) {
    /* After development, check not needed */
    /* I think this call is not used anywhere in the test suite */
    SV** p_table_sv = (SV**)marpa_luaL_checkudata(L, 1, MT_NAME_SV);
    /* warn("%s %d\n", __FILE__, __LINE__); */
    lua_Integer index = marpa_luaL_checkinteger(L, 2);
    /* warn("%s %d\n", __FILE__, __LINE__); */
    marpa_av_fill(L, *p_table_sv, (int)index);
    /* warn("%s %d\n", __FILE__, __LINE__); */
    return 0;
}

static int marpa_sv_tostring_meth(lua_State* L) {
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

static int marpa_sv_svaddr_meth(lua_State* L) {
    /* Lua stack: [ sv_userdata ] */
    /* For debugging, so keep the check even after development */
    SV** p_table_sv = (SV**)marpa_luaL_checkudata(L, 1, MT_NAME_SV);
    marpa_lua_pushinteger (L, (lua_Integer)PTR2nat(*p_table_sv));
    return 1;
}

static int marpa_sv_addr_meth(lua_State* L) {
    /* Lua stack: [ sv_userdata ] */
    /* For debugging, so keep the check even after development */
    SV** p_table_sv = (SV**)marpa_luaL_checkudata(L, 1, MT_NAME_SV);
    marpa_lua_pushinteger (L, (lua_Integer)PTR2nat(p_table_sv));
    return 1;
}

static const struct luaL_Reg marpa_sv_meths[] = {
    {"__add", marpa_sv_add_meth},
    {"__gc", marpa_sv_finalize_meth},
    {"__index", marpa_av_fetch_meth},
    {"__newindex", marpa_av_store_meth},
    {"__tostring", marpa_sv_tostring_meth},
    {NULL, NULL},
};

static const struct luaL_Reg marpa_sv_funcs[] = {
    {"fill", marpa_av_fill_meth},
    {"top_index", marpa_av_len_meth},
    {"undef", marpa_sv_undef},
    {"svaddr", marpa_sv_svaddr_meth},
    {"addr", marpa_sv_addr_meth},
    {NULL, NULL},
};

/* create SV metatable */
static void create_sv_mt (lua_State* L) {
    int base_of_stack = marpa_lua_gettop(L);
    marpa_luaL_newmetatable(L, MT_NAME_SV);
    /* Lua stack: [mt] */

    /* metatable.__index = metatable */
    marpa_lua_pushvalue(L, -1);
    marpa_lua_setfield(L, -2, "__index");
    /* Lua stack: [mt] */

    /* register methods */
    marpa_luaL_setfuncs(L, marpa_sv_meths, 0);
    /* Lua stack: [mt] */
    marpa_lua_settop(L, base_of_stack);
}

static int
xlua_recce_step_meth (lua_State * L)
{
    Marpa_Value v;
    lua_Integer step_type;
    const int recce_table = marpa_lua_gettop (L);
    int step_table;

    marpa_luaL_checktype (L, 1, LUA_TTABLE);
    /* Lua stack: [ recce_table ] */
    marpa_lua_getfield(L, recce_table, "lmw_v");
    /* Lua stack: [ recce_table, lmw_v ] */
    marpa_luaL_argcheck (L, (LUA_TUSERDATA == marpa_lua_getfield (L,
                -1, "_libmarpa")), 1,
        "Internal error: recce.lud userdata not set");
    /* Lua stack: [ recce_table, lmw_v, v_ud ] */
    v = *(Marpa_Value *) marpa_lua_touserdata (L, -1);
    /* Lua stack: [ recce_table, lmw_v, v_ud ] */
    marpa_lua_settop (L, recce_table);
    /* Lua stack: [ recce_table ] */
    marpa_lua_newtable (L);
    /* Lua stack: [ recce_table, step_table ] */
    step_table = marpa_lua_gettop (L);
    marpa_lua_pushvalue (L, -1);
    marpa_lua_setfield (L, recce_table, "this_step");
    /* Lua stack: [ recce_table, step_table ] */

    step_type = (lua_Integer) marpa_v_step (v);
    marpa_lua_pushstring (L, step_type_to_string (step_type));
    marpa_lua_setfield (L, step_table, "type");

    /* Stack indexes adjusted up by 1, because Lua arrays
     * are 1-based.
     */
    switch (step_type) {
    case MARPA_STEP_RULE:
        marpa_lua_pushinteger (L, marpa_v_result (v)+1);
        marpa_lua_setfield (L, step_table, "result");
        marpa_lua_pushinteger (L, marpa_v_arg_n (v)+1);
        marpa_lua_setfield (L, step_table, "arg_n");
        marpa_lua_pushinteger (L, marpa_v_rule (v));
        marpa_lua_setfield (L, step_table, "rule");
        marpa_lua_pushinteger (L, marpa_v_rule_start_es_id (v));
        marpa_lua_setfield (L, step_table, "start_es_id");
        marpa_lua_pushinteger (L, marpa_v_es_id (v));
        marpa_lua_setfield (L, step_table, "es_id");
        break;
    case MARPA_STEP_TOKEN:
        marpa_lua_pushinteger (L, marpa_v_result (v)+1);
        marpa_lua_setfield (L, step_table, "result");
        marpa_lua_pushinteger (L, marpa_v_token (v));
        marpa_lua_setfield (L, step_table, "symbol");
        marpa_lua_pushinteger (L, marpa_v_token_value (v));
        marpa_lua_setfield (L, step_table, "value");
        marpa_lua_pushinteger (L, marpa_v_token_start_es_id (v));
        marpa_lua_setfield (L, step_table, "start_es_id");
        marpa_lua_pushinteger (L, marpa_v_es_id (v));
        marpa_lua_setfield (L, step_table, "es_id");
        break;
    case MARPA_STEP_NULLING_SYMBOL:
        marpa_lua_pushinteger (L, marpa_v_result (v)+1);
        marpa_lua_setfield (L, step_table, "result");
        marpa_lua_pushinteger (L, marpa_v_token (v));
        marpa_lua_setfield (L, step_table, "symbol");
        marpa_lua_pushinteger (L, marpa_v_token_start_es_id (v));
        marpa_lua_setfield (L, step_table, "start_es_id");
        marpa_lua_pushinteger (L, marpa_v_es_id (v));
        marpa_lua_setfield (L, step_table, "es_id");
        break;
    }

    return 0;
}

static void slr_inner_destroy(lua_State* L, Scanless_R* slr);

static int
xlua_recce_gc (lua_State * L)
{
    Scanless_R *slr;
    int lud_type;

    /* marpa_r3_warn("xlua_recce_gc"); */
    /* Checks needed after development ?? */
    marpa_luaL_checktype (L, 1, LUA_TTABLE);
    lud_type = marpa_lua_getfield (L, 1, "lud");
    marpa_luaL_argcheck (L, (lud_type == LUA_TLIGHTUSERDATA), 1,
        "recce userdata not set");
    slr = (Scanless_R *) marpa_lua_touserdata (L, -1);
    slr_inner_destroy(L, slr);
    return 0;
}

static const struct luaL_Reg marpa_slr_meths[] = {
    {"step", xlua_recce_step_meth},
    {"ref", xlua_ref},
    {"unref", xlua_unref},
    {"__gc", xlua_recce_gc},
    {NULL, NULL},
};

/* create SV metatable */
static void slg_inner_destroy(Scanless_G* slg);

static int slg_gc (lua_State * L)
{
    Scanless_G *slg;
    int lud_type;

    /* marpa_r3_warn("xlua_grammar_gc"); */
    /* Checks needed after development ?? */
    marpa_luaL_checktype (L, 1, LUA_TTABLE);
    lud_type = marpa_lua_getfield (L, 1, "lud");
    marpa_luaL_argcheck (L, (lud_type == LUA_TLIGHTUSERDATA), 1,
        "grammar userdata not set");
    slg = (Scanless_G *) marpa_lua_touserdata (L, -1);
    slg_inner_destroy(slg);
    return 0;
}

static const struct luaL_Reg marpa_slg_meths[] = {
    {"__gc", slg_gc},
    {NULL, NULL},
};

static int xlua_recce_func(lua_State* L)
{
  /* Lua stack [ recce_ref ] */
  lua_Integer recce_ref = marpa_luaL_checkinteger(L, 1);
  marpa_lua_rawgeti (L, LUA_REGISTRYINDEX, recce_ref);
  /* Lua stack [ recce_ref, recce_table ] */
  return 1;
}

static const struct luaL_Reg marpa_funcs[] = {
    {"recce", xlua_recce_func},
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

static void
call_by_tag (lua_State * L, const char* tag, const char *codestr,
  const char *sig, ...)
{
    va_list vl;
    int narg, nres;
    int status;
    int type;
    const int base_of_stack = marpa_lua_gettop (L);
    const int msghandler_ix = base_of_stack + 1;
    int cache_ix;
    dTHX;

    marpa_lua_pushcfunction (L, glue_msghandler);

    marpa_lua_getglobal (L, "glue");
    marpa_lua_getfield (L, -1, "code_by_tag");
    cache_ix = marpa_lua_gettop (L);
    type = marpa_lua_getfield (L, cache_ix, tag);

    if (type != LUA_TFUNCTION) {

        /* warn("%s %d", __FILE__, __LINE__); */
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

    /* Lua stack: [ function ] */

    va_start (vl, sig);

    for (narg = 0; *sig; narg++) {
        const char this_sig = *sig++;
        /* warn("%s %d narg=%d", __FILE__, __LINE__, narg); */
        if (!marpa_lua_checkstack (L, LUA_MINSTACK + 1)) {
            /* This error is not considered recoverable */
            croak ("Internal Marpa::R3 error; could not grow stack: " MYLUA_TAG);
        }
        /* warn("%s %d narg=%d *sig=%c", __FILE__, __LINE__, narg, *sig); */
        switch (this_sig) {
        case 'd':
            marpa_lua_pushnumber (L, (lua_Number) va_arg (vl, double));
            break;
        case 'i':
            marpa_lua_pushinteger (L, va_arg (vl, lua_Integer));
            break;
        case 's':
            marpa_lua_pushstring (L, va_arg (vl, char *));
            break;
        case 'S':              /* argument is SV -- ownership is taken of
                                 * a reference count, so caller is responsible
                                 * for making sure a reference count is
                                 * available for the taking.
                                 */
            /* warn("%s %d narg=%d", __FILE__, __LINE__, narg, *sig); */
            marpa_sv_sv_noinc (L, va_arg (vl, SV *));
            /* warn("%s %d narg=%d", __FILE__, __LINE__, narg, *sig); */
            break;
        case 'R':              /* argument is ref key of recce table */
        case 'G':
            marpa_lua_rawgeti (L, LUA_REGISTRYINDEX,
                (lua_Integer) va_arg (vl, lua_Integer));
            break;
        case '>':              /* end of arguments */
            goto endargs;
        default:
            croak
                ("Internal error: invalid sig option %c in call_by_tag()",
                this_sig);
        }
        /* warn("%s %d narg=%d *sig=%c", __FILE__, __LINE__, narg, *sig); */
    }
  endargs:;

    nres = (int) strlen (sig);

    /* warn("%s %d", __FILE__, __LINE__); */
    status = marpa_lua_pcall (L, narg, nres, msghandler_ix);
    if (status != 0) {
        const char *exception_string = handle_pcall_error (L, status);
        marpa_lua_settop (L, base_of_stack);
        croak (exception_string);
    }

    for (nres = -nres; *sig; nres++) {
        const char this_sig = *sig++;
        switch (this_sig) {
        case 'd':
            {
                int isnum;
                const double n = marpa_lua_tonumberx (L, nres, &isnum);
                if (!isnum)
                    croak
                        ("Internal error: call_by_tag(%s ...): result type is not double",
                        tag);
                *va_arg (vl, double *) = n;
                break;
            }
        case 'i':
            {
                int isnum;
                const lua_Integer n = marpa_lua_tointegerx (L, nres, &isnum);
                if (!isnum)
                    croak
                        ("Internal error: call_by_tag(%s ...): result type is not integer",
                        tag);
                *va_arg (vl, lua_Integer *) = n;
                break;
            }
        case 'M':                  /* SV -- caller becomes owner of 1 mortal ref count. */
            {
                SV **av_ref_p = (SV **) marpa_lua_touserdata (L, nres);
                *va_arg (vl, SV **) = sv_mortalcopy (*av_ref_p);
                break;
            }
        case 'C':                  /* SV -- caller becomes owner of 1 mortal ref count. */
            {
                SV *sv = sv_2mortal (coerce_to_sv (L, nres, '-'));
                *va_arg (vl, SV **) = sv;
                break;
            }
        default:
            croak
                ("Internal error: invalid sig option %c in call_by_tag()",
                this_sig);
        }
    }

    /* Results *must* be copied at this point, because
     * now we expose them to Lua GC
     */
    marpa_lua_settop (L, base_of_stack);
    /* warn("%s %d", __FILE__, __LINE__); */
    va_end (vl);
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
       SV** p_sv = av_fetch(av, perl_ix, 0);
       if (p_sv) {
           recursive_coerce_to_lua(L, visited_ix, *p_sv, sig);
       } else {
           marpa_lua_pushboolean(L, 0);
       }
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
        char *key;
        I32 klen;
        SV *val;
        while ((val = hv_iternextsv (hv, (char **) &key, &klen))) {
            marpa_lua_pushlstring (L, key, (size_t)klen);
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
        marpa_sv_sv_noinc (L, sv);
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
    marpa_lua_pushstring (L, SvPV_nolen (sv));
    return;
}

/* Static recognizer methods */

/* Maybe inline some of these */

static Scanless_R* slr_inner_get(Outer_R* outer_slr);

#define U_READ_OK 0
#define U_READ_REJECTED_CHAR -1
#define U_READ_UNREGISTERED_CHAR -2
#define U_READ_EXHAUSTED_ON_FAILURE -3
#define U_READ_TRACING -4
#define U_READ_EXHAUSTED_ON_SUCCESS -5
#define U_READ_INVALID_CHAR -6

/* Return values:
 * 1 or greater: reserved for an event count, to deal with multiple events
 *   when and if necessary
 * 0: success: a full reading of the input, with nothing to report.
 * -1: a character was rejected
 * -2: an unregistered character was found
 * -3: earleme_complete() reported an exhausted parse on failure
 * -4: we are tracing, character by character
 * -5: earleme_complete() reported an exhausted parse on success
 */
static int
u_read (Outer_R * outer_slr)
{
    dTHX;
    Scanless_R *slr = slr_inner_get (outer_slr);

  call_by_tag (outer_slr->L,
    MYLUA_TAG,
    "local recce, perl_pos = ...\n"
    "if not recce.lmw_l0r then\n"
    "    recce:l0r_new(perl_pos)\n"    
    "end\n"
    ,
    "Ri>", outer_slr->lua_ref, (lua_Integer)slr->perl_pos);

    for (;;) {
        lua_Integer codepoint;
        lua_Integer op_count;
        lua_Integer op_ix;
        int tokens_accepted = 0;
        if (slr->perl_pos >= slr->end_pos)
            break;

  call_by_tag (outer_slr->L,
    MYLUA_TAG,
    "local recce, perl_pos = ...\n"
    "-- print('codepoints:', inspect(recce.codepoints))\n"
    "-- print('perl_pos:', inspect(perl_pos))\n"
    "local codepoint = recce.codepoints[perl_pos+1]\n"
    "local ops = recce.per_codepoint[codepoint]\n"
    "local op_count = -1\n"
    "if ops then\n"
    "    op_count = #ops\n"
    "end\n"
    "return codepoint, op_count\n"
    ,
    "Ri>ii", outer_slr->lua_ref,
    (lua_Integer)slr->perl_pos, &codepoint, &op_count);

    if (op_count < 0) {
                slr->codepoint = codepoint;
                return U_READ_UNREGISTERED_CHAR;
    }

        call_by_tag (outer_slr->L, MYLUA_TAG,
            "local recce, codepoint, perl_pos = ...\n"
            "if recce.trace_terminals >= 1 then\n"
            "   local q = recce.event_queue\n"
            "   q[#q+1] = { '!trace', 'lexer reading codepoint', codepoint, perl_pos}\n"
            "end\n",
            "Rii>", outer_slr->lua_ref, (lua_Integer)codepoint,
            (lua_Integer) slr->perl_pos);

        /* ops[0] is codepoint */
        for (op_ix = 1; op_ix <= op_count; op_ix++) {
            lua_Integer op_code;

                    call_by_tag (outer_slr->L, MYLUA_TAG,
                            "recce, codepoint, op_ix = ...\n"
                            "-- print(inspect(recce.per_codepoint[codepoint]))\n"
                            "-- print('op_ix: ', inspect(op_ix))\n"
                            "local op_code = recce.per_codepoint[codepoint][op_ix]\n"
                            "return op_code\n"
                            ,
                            "Rii>i",
                            outer_slr->lua_ref,
                            codepoint, op_ix, &op_code
                    );

            switch (op_code) {
            case MARPA_OP_ALTERNATIVE:
                {
                    lua_Integer result;
                    lua_Integer symbol_id;
                    lua_Integer length;
                    lua_Integer value;

                    call_by_tag (outer_slr->L, MYLUA_TAG,
                            "recce, op_ix = ...\n"
                            "local ops = recce.per_codepoint[codepoint]\n"
                            "local symbol_id = ops[op_ix+1]\n"
                            "local value = ops[op_ix+2]\n"
                            "local length = ops[op_ix+3]\n"
                            "if not length then\n"
                            "    error(string.format(\n"
                            "        'Missing OP_ALTERNATIVE operands, codepoint=%d, op_ix=%d',\n"
                            "        codepoint, op_ix\n"
                            "    ))\n"
                            "end\n"
                            "return symbol_id, value, length,\n"
                            "    recce.lmw_l0r:alternative(symbol_id, value, length)\n"
                            ,
                            "Ri>iiii",
                            outer_slr->lua_ref, op_ix,
                            &symbol_id, &value, &length, &result
                    );
                    op_ix+=3;
                    switch (result) {
                    case MARPA_ERR_UNEXPECTED_TOKEN_ID:
                        /* This guarantees that later, if we fall below
                         * the minimum number of tokens accepted,
                         * we have one of them as an example
                         */
                        slr->input_symbol_id = symbol_id;

                        call_by_tag (outer_slr->L, MYLUA_TAG,
                            "recce, codepoint, perl_pos, symbol_id = ...\n"
                            "if recce.trace_terminals >= 1 then\n"
                            "    local q = recce.event_queue\n"
                            "    q[#q+1] = { '!trace', 'lexer rejected codepoint', codepoint, perl_pos, symbol_id}\n"
                            "end\n",
                            "Riii>",
                            outer_slr->lua_ref,
                            (lua_Integer)codepoint, (lua_Integer)slr->perl_pos, (lua_Integer)symbol_id);

                        break;
                    case MARPA_ERR_NONE:

                        call_by_tag (outer_slr->L, MYLUA_TAG,
                            "recce, codepoint, perl_pos, symbol_id = ...\n"
                            "if recce.trace_terminals >= 1 then\n"
                            "   local q = recce.event_queue\n"
                            "   q[#q+1] = { '!trace', 'lexer accepted codepoint', codepoint, perl_pos, symbol_id}\n"
                            "end\n",
                            "Riii>",
                            outer_slr->lua_ref,
                            (lua_Integer)codepoint, (lua_Integer)slr->perl_pos, (lua_Integer)symbol_id);

                        tokens_accepted++;
                        break;
                    default:
                        slr->codepoint = codepoint;
                        slr->input_symbol_id = symbol_id;
                        croak
                            ("Problem alternative() failed at char ix %ld; symbol id %ld; codepoint 0x%lx value %ld\n"
                            "Problem in u_read(), alternative() failed: %s",
                            (long) slr->perl_pos, (long) symbol_id,
                            (unsigned long) codepoint,
                            (long) value,
                            slr_l0_error (outer_slr));
                    }
                }
                break;

            case MARPA_OP_INVALID_CHAR:
                slr->codepoint = codepoint;
                return U_READ_INVALID_CHAR;

            case MARPA_OP_EARLEME_COMPLETE:
                {
                    lua_Integer result;
                    if (tokens_accepted < 1) {
                        slr->codepoint = codepoint;
                        return U_READ_REJECTED_CHAR;
                    }

                    call_by_tag (outer_slr->L, MYLUA_TAG,
                        "recce = ...\n"
                        "return recce.lmw_l0r:earleme_complete()\n",
                        "R>i",
                        outer_slr->lua_ref, &result);

                    if (result > 0) {
                        lua_Integer is_exhausted;

                        /* Advance one character before returning */

                      call_by_tag (outer_slr->L, MYLUA_TAG,
                          "recce, perl_pos = ...\n"
                          "recce:l0_convert_events(perl_pos)\n"
                          "return recce.lmw_l0r:is_exhausted()\n",
                          "Ri>i",
                          outer_slr->lua_ref, (lua_Integer)slr->perl_pos, &is_exhausted);

                        if (is_exhausted) {
                            return U_READ_EXHAUSTED_ON_SUCCESS;
                        }
                        goto ADVANCE_ONE_CHAR;
                    }
                    if (result == -2) {
                        lua_Integer error_code;
                      call_by_tag (outer_slr->L, MYLUA_TAG,
                          "recce = ...\n"
                          "return recce.slg.lmw_l0g:error_code()\n",
                          "R>i",
                          outer_slr->lua_ref, &error_code);

                        if (error_code == MARPA_ERR_PARSE_EXHAUSTED) {
                            return U_READ_EXHAUSTED_ON_FAILURE;
                        }
                    }
                    if (result < 0) {
                        croak
                            ("Problem in r->u_read(), earleme_complete() failed: %s",
                            slr_l0_error (outer_slr));
                    }
                }
                break;
            default:
                croak
                    ("Unknown op code (0x%lx); codepoint=0x%lx, op_ix=0x%lx",
                    (unsigned long) op_code, (unsigned long) codepoint,
                    (unsigned long) op_ix);
            }
        }
      ADVANCE_ONE_CHAR:;
        {
            lua_Integer trace_terminals;
            slr->perl_pos++;
            call_by_tag (outer_slr->L, MYLUA_TAG,
                "recce = ...\n"
                "return recce.trace_terminals\n",
                "R>i", outer_slr->lua_ref, &trace_terminals);
            if (trace_terminals) {
                return U_READ_TRACING;
            }
        }
    }
    return U_READ_OK;
}

/* It is OK to set pos to last codepoint + 1 */
static void
u_pos_set (Outer_R * outer_slr, const char* name, int start_pos_arg, int length_arg)
{
  dTHX;
  Scanless_R *slr = slr_inner_get(outer_slr);
  lua_Integer input_length;
  int new_perl_pos;
  int new_end_pos;

  call_by_tag (outer_slr->L, MYLUA_TAG,
      "recce = ...\n"
      "return #recce.codepoints\n",
      "R>i", outer_slr->lua_ref, &input_length);

  if (start_pos_arg < 0) {
      new_perl_pos = (int)input_length + start_pos_arg;
  } else {
      new_perl_pos = start_pos_arg;
  }
  if (new_perl_pos < 0 || new_perl_pos > input_length)
  {
      croak ("Bad start position in %s(): %ld", name, (long)start_pos_arg);
  }

  if (length_arg < 0) {
      new_end_pos = (int)input_length + length_arg + 1;
  } else {
    new_end_pos = new_perl_pos + length_arg;
  }
  if (new_end_pos < 0 || new_end_pos > input_length)
  {
      croak ("Bad length in %s(): %ld", name, (long)length_arg);
  }

  /* Application level intervention resets |perl_pos| */
  slr->last_perl_pos = -1;
  new_perl_pos = new_perl_pos;
  slr->perl_pos = new_perl_pos;
  new_end_pos = new_end_pos;
  slr->end_pos = new_end_pos;
}

/* Static SLG methods */

static Scanless_G* slg_inner_get(Outer_G* outer_slg) {
    return outer_slg->inner;
}

static Scanless_G* slg_inner_new (void)
{
    Scanless_G *slg;
    dTHX;

    Newx (slg, 1, Scanless_G);

    slg->symbol_g_properties = NULL;

    return slg;
}

static void slg_inner_init_properties (
  Outer_G* outer_slg)
{
    dTHX;
    Scanless_G *slg = slg_inner_get (outer_slg);

    {
        Marpa_Symbol_ID symbol_id;
        lua_Integer g1_symbol_count;

        call_by_tag (outer_slg->L, MYLUA_TAG,
            "grammar = ...\n"
            "local g1g = grammar.lmw_g1g\n"
            "return g1g:highest_symbol_id()+1\n",
            "G>i", outer_slg->lua_ref, &g1_symbol_count);

        Newx (slg->symbol_g_properties, (unsigned int) g1_symbol_count,
            struct symbol_g_properties);
        for (symbol_id = 0; symbol_id < g1_symbol_count; symbol_id++) {
            slg->symbol_g_properties[symbol_id].priority = 0;
            slg->symbol_g_properties[symbol_id].is_lexeme = 0;
            slg->symbol_g_properties[symbol_id].t_pause_before = 0;
            slg->symbol_g_properties[symbol_id].t_pause_before_active = 0;
            slg->symbol_g_properties[symbol_id].t_pause_after = 0;
            slg->symbol_g_properties[symbol_id].t_pause_after_active = 0;
        }
    }

}

static void slg_inner_destroy(Scanless_G* slg) {
  dTHX;
  Safefree (slg->symbol_g_properties);
  Safefree (slg);
}

/* Static SLR methods */

static Scanless_R *
marpa_inner_slr_new (Outer_G* outer_slg)
{
    dTHX;
    Scanless_R *slr;
    Scanless_G *slg = slg_inner_get (outer_slg);
    lua_Integer value_is_literal;

    Newx (slr, 1, Scanless_R);

    slr->throw = 1;

    /* These do not need references, because parent objects
     * hold references to them
     */
    slr->slg = slg;

    slr->start_of_lexeme = 0;
    slr->end_of_lexeme = 0;
    slr->is_external_scanning = 0;

    slr->perl_pos = 0;
    slr->last_perl_pos = -1;
    slr->problem_pos = -1;

    slr->token_values = newAV ();

    call_by_tag (outer_slg->L, MYLUA_TAG,
        "grammar = ...\n"
        "local g1g = grammar.lmw_g1g\n"
        "local kollos = getmetatable(g1g).kollos\n"
        "local defines = kollos.defines\n"
        "return defines.TOKEN_VALUE_IS_LITERAL\n"
        ,
        "G>i", outer_slg->lua_ref, &value_is_literal);

    av_fill (slr->token_values, (I32)value_is_literal);

    {
        /* Delete this once g_properties are converted to Lua.
         * The Lua values must be init'd after the SLR lua_ref
         * is created.
         */ 
        Marpa_Symbol_ID symbol_id;
        lua_Integer g1_symbol_count;
    call_by_tag (outer_slg->L, MYLUA_TAG,
        "grammar = ...\n"
        "local g1g = grammar.lmw_g1g\n"
        "return g1g:highest_symbol_id()+1\n"
        ,
        "G>i", outer_slg->lua_ref, &g1_symbol_count);

        Newx (slr->symbol_r_properties, ((unsigned int) g1_symbol_count),
            struct symbol_r_properties);
        for (symbol_id = 0; symbol_id < g1_symbol_count; symbol_id++) {
            const struct symbol_g_properties *g_properties =
                slg->symbol_g_properties + symbol_id;
            slr->symbol_r_properties[symbol_id].lexeme_priority =
                g_properties->priority;
            slr->symbol_r_properties[symbol_id].t_pause_before_active =
                g_properties->t_pause_before_active;
            slr->symbol_r_properties[symbol_id].t_pause_after_active =
                g_properties->t_pause_after_active;
        }
    }

    slr->lexer_start_pos = slr->perl_pos;
    slr->lexer_read_result = 0;
    slr->start_of_pause_lexeme = -1;
    slr->end_of_pause_lexeme = -1;

    slr->input_symbol_id = -1;
    slr->end_pos = 0;

    slr->t_lexeme_count = 0;
    slr->t_lexeme_capacity =
        (int) MAX (1024 / sizeof (union marpa_slr_event_s), 16);
    Newx (slr->t_lexemes, (unsigned int) slr->t_lexeme_capacity,
        union marpa_slr_event_s);

    return slr;
}

static Scanless_R* slr_inner_get(Outer_R* outer_slr) {
    lua_State* const L = outer_slr->L;
    const lua_Integer lua_ref = outer_slr->lua_ref;
    const int base_of_stack = marpa_lua_gettop(L);
    Scanless_R *slr;
    /* Necessary every time to check stack ?? */
    if (!marpa_lua_checkstack(L, MYLUA_STACK_INCR)) {
        croak ("Internal Marpa::R3 error; could not grow stack: " MYLUA_TAG);
    }
    marpa_lua_rawgeti (L, LUA_REGISTRYINDEX, lua_ref);
    /* Lua stack: [ recce_table ] */
    marpa_lua_getfield(L, -1, "lud");
    /* Lua stack: [ recce_table, lud ] */
    slr = marpa_lua_touserdata(L, -1);
    marpa_lua_settop(L, base_of_stack);
    return slr;
}

static void slr_inner_destroy(lua_State* L, Scanless_R* slr)
{
  dTHX;
    PERL_UNUSED_ARG(L);

   Safefree(slr->t_lexemes);

  Safefree(slr->symbol_r_properties);
  if (slr->token_values)
    {
      SvREFCNT_dec ((SV *) slr->token_values);
    }
  Safefree (slr);
}

/*
 * Return values:
 * NULL OK.
 * Otherwise, a string containing the error.
 * The string must be a constant in static space.
 */
static const char *
slr_alternatives ( Outer_R *outer_slr, lua_Integer discard_mode)
{
    dTHX;
    Scanless_R *slr = slr_inner_get (outer_slr);
    lua_Integer earley_set;

    /* |high_lexeme_priority| is not valid unless |is_priority_set| is set. */
    int is_priority_set = 0;
    lua_Integer high_lexeme_priority = 0;

    int discarded = 0;
    int rejected = 0;
    int working_pos = slr->start_of_lexeme;
    enum pass1_result_type
    { none, discard, no_lexeme, accept };
    enum pass1_result_type pass1_result = none;

    call_by_tag (outer_slr->L,
        MYLUA_TAG,
        "recce=...\n"
        "local l0r = recce.lmw_l0r\n"
        "if not l0r then\n"
        "    error('Internal error: No l0r in slr_alternatives(): %s',\n"
        "        recce.slg.lmw_l0g:error_description())\n"
        "end\n", "R>", outer_slr->lua_ref);

    marpa_slr_lexeme_clear (slr);


    call_by_tag (outer_slr->L, MYLUA_TAG,
        "recce = ...\n"
        "return recce.lmw_l0r:latest_earley_set()\n",
        "R>i", outer_slr->lua_ref, &earley_set);

    /* Zero length lexemes are not of interest, so we do NOT
     * search the 0'th Earley set.
     */
    for (; earley_set > 0; earley_set--) {
        lua_Integer return_value;
        int end_of_earley_items = 0;
        working_pos = slr->start_of_lexeme + (int)earley_set;

        call_by_tag (outer_slr->L, MYLUA_TAG,
            "recce, earley_set = ...\n"
            "local return_value = recce.lmw_l0r:progress_report_start(earley_set)\n"
            "if return_value < 0 then\n"
            "    error(string.format('Problem in recce:progress_report_start(...,%d): %s'),\n"
            "        earley_set, recce.lmw_l0r:error_description())\n"
            "end\n"
            "return return_value\n",
            "Ri>i",
            outer_slr->lua_ref, (lua_Integer) earley_set, &return_value);

        while (!end_of_earley_items) {
            struct symbol_r_properties *symbol_r_properties;
            lua_Integer g1_lexeme;
            lua_Integer this_lexeme_priority;
            lua_Integer dot_position;
            lua_Integer origin;
            lua_Integer rule_id;

            call_by_tag (outer_slr->L, MYLUA_TAG,
                "recce = ...\n"
                "local rule_id, dot_position, origin = recce.lmw_l0r:progress_item()\n"
                "if not rule_id then return -1, 0, 0 end\n"
                "if rule_id <= -2 then\n"
                "    error(string.format('Problem in recce:progress_item(): %s'),\n"
                "        recce.lmw_l0r:error_description())\n"
                "end\n"
                "return rule_id, dot_position, origin\n",
                "R>iii",
                outer_slr->lua_ref, &rule_id, &dot_position, &origin);

            if (rule_id == -1) {
                end_of_earley_items = 1;
                goto NEXT_PASS1_REPORT_ITEM;
            }
            if (origin != 0)
                goto NEXT_PASS1_REPORT_ITEM;
            if (dot_position != -1)
                goto NEXT_PASS1_REPORT_ITEM;

            call_by_tag (outer_slr->L,
                MYLUA_TAG,
                "local recce, rule_id = ...\n"
                "local g1_lexeme = recce.slg.l0_rules[rule_id].g1_lexeme\n"
                "g1_lexeme = g1_lexeme or -1\n"
                "return g1_lexeme\n",
                "Ri>i", outer_slr->lua_ref, (lua_Integer) rule_id,
                &g1_lexeme);

            if (g1_lexeme == -1)
                goto NEXT_PASS1_REPORT_ITEM;
            slr->end_of_lexeme = working_pos;
            /* -2 means a discarded item */
            if (g1_lexeme <= -2) {
                union marpa_slr_event_s *lexeme_entry =
                    marpa_slr_lexeme_push (slr);
                MARPA_SLREV_TYPE (lexeme_entry) =
                    MARPA_SLRTR_LEXEME_DISCARDED;
                lexeme_entry->t_trace_lexeme_discarded.t_rule_id = (int)rule_id;
                lexeme_entry->t_trace_lexeme_discarded.t_start_of_lexeme =
                    slr->start_of_lexeme;
                lexeme_entry->t_trace_lexeme_discarded.t_end_of_lexeme =
                    slr->end_of_lexeme;
                discarded++;

                goto NEXT_PASS1_REPORT_ITEM;
            }
            symbol_r_properties = slr->symbol_r_properties + g1_lexeme;

            call_by_tag (outer_slr->L, MYLUA_TAG,
                "recce, g1_lexeme, start_of_lexeme, end_of_lexeme = ...\n"
                "local is_expected = recce.lmw_g1r:terminal_is_expected(g1_lexeme)\n"
                "if not is_expected then\n"
                "    error(string.format('Internnal error: Marpa recognized unexpected token @%d-%d: lexme=%d',\n"
                "        start_of_lexeme, end_of_lexeme, g1_lexeme))\n"
                "end\n"
                "return recce.g1_symbols[g1_lexeme].lexeme_priority\n"
                ,
                "Riii>i",
                outer_slr->lua_ref, (lua_Integer) g1_lexeme,
                (lua_Integer) slr->start_of_lexeme,
                (lua_Integer) slr->end_of_lexeme,
                &this_lexeme_priority
                );

            /* If we are here, the lexeme will be accepted  by the grammar,
             * but we do not yet know about priority
             */

            /* this_lexeme_priority = symbol_r_properties->lexeme_priority; */
            if (!is_priority_set
                || this_lexeme_priority > high_lexeme_priority) {
                high_lexeme_priority = this_lexeme_priority;
                is_priority_set = 1;
            }

            {
                union marpa_slr_event_s *lexeme_entry =
                    marpa_slr_lexeme_push (slr);
                MARPA_SLREV_TYPE (lexeme_entry) =
                    MARPA_SLRTR_LEXEME_ACCEPTABLE;
                lexeme_entry->t_lexeme_acceptable.t_start_of_lexeme =
                    slr->start_of_lexeme;
                lexeme_entry->t_lexeme_acceptable.t_end_of_lexeme =
                    slr->end_of_lexeme;
                lexeme_entry->t_lexeme_acceptable.t_lexeme = (int)g1_lexeme;
                lexeme_entry->t_lexeme_acceptable.t_priority =
                    this_lexeme_priority;
                /* Default to this symbol's priority, since we don't
                   yet know what the required priority will be */
                lexeme_entry->t_lexeme_acceptable.t_required_priority =
                    this_lexeme_priority;
            }

          NEXT_PASS1_REPORT_ITEM:      /* Clearer, I think, using this label than long distance
                                           break and continue */ ;
        }

        if (discarded || rejected || is_priority_set)
            break;

    }

    /* Figure out what the result of pass 1 was */
    if (is_priority_set) {
        pass1_result = accept;
    } else if (discarded) {
        pass1_result = discard;
    } else {
        pass1_result = no_lexeme;
    }

    {
        /* In pass 1, we used a stack of tentative
         * trace events to record which lexemes
         * are acceptable, to be discarded, etc.
         * At this point, if we are tracing,
         * we convert the tentative trace
         * events into real trace events.
         */
        int i;
        for (i = 0; i < slr->t_lexeme_count; i++) {
            union marpa_slr_event_s *const lexeme_stack_event =
                slr->t_lexemes + i;
            const int event_type = MARPA_SLREV_TYPE (lexeme_stack_event);
            switch (event_type) {
            case MARPA_SLRTR_LEXEME_ACCEPTABLE:
                if (lexeme_stack_event->t_lexeme_acceptable.t_priority <
                    high_lexeme_priority) {
                    MARPA_SLREV_TYPE (lexeme_stack_event) =
                        MARPA_SLRTR_LEXEME_OUTPRIORITIZED;
                    lexeme_stack_event->t_lexeme_acceptable.
                        t_required_priority = high_lexeme_priority;
                    call_by_tag (outer_slr->L, MYLUA_TAG,
                        "recce, lexeme_start, lexeme_end,\n"
                        "    g1_lexeme, priority, required_priority = ...\n"
                        "if recce.trace_terminals > 0 then\n"
                        "    local q = recce.event_queue\n"
                        "    q[#q+1] = { '!trace', 'outprioritized lexeme',\n"
                        "   lexeme_start, lexeme_end, g1_lexeme, priority, required_priority}\n"
                        "end\n", "Riiiii>", outer_slr->lua_ref,
                        (lua_Integer) lexeme_stack_event->
                        t_trace_lexeme_acceptable.t_start_of_lexeme,
                        (lua_Integer) lexeme_stack_event->
                        t_trace_lexeme_acceptable.t_end_of_lexeme,
                        (lua_Integer) lexeme_stack_event->
                        t_trace_lexeme_acceptable.t_lexeme,
                        (lua_Integer) lexeme_stack_event->
                        t_trace_lexeme_acceptable.t_priority,
                        (lua_Integer) lexeme_stack_event->
                        t_trace_lexeme_acceptable.t_required_priority);
                }
                goto NEXT_LEXEME_EVENT;
            case MARPA_SLRTR_LEXEME_DISCARDED:
                /* We do not have the lexeme, but we have the
                 * lexer rule.
                 * The upper level will have to figure things out.
                 */
                call_by_tag (outer_slr->L, MYLUA_TAG,
                    "recce, rule_id, lexeme_start, lexeme_end = ...\n"
                    "if recce.trace_terminals > 0 then\n"
                    "local q = recce.event_queue\n"
                    "q[#q+1] = { '!trace', 'discarded lexeme',\n"
                    "    rule_id, lexeme_start, lexeme_end}\n"
                    "end\n",
                    "Riii>",
                    outer_slr->lua_ref,
                    (lua_Integer) lexeme_stack_event->
                    t_trace_lexeme_discarded.t_rule_id,
                    (lua_Integer) lexeme_stack_event->
                    t_trace_lexeme_discarded.t_start_of_lexeme,
                    (lua_Integer) lexeme_stack_event->
                    t_trace_lexeme_discarded.t_end_of_lexeme);

                if (pass1_result == discard) {
                    const Marpa_Rule_ID l0_rule_id =
                        lexeme_stack_event->t_trace_lexeme_discarded.
                        t_rule_id;
                    call_by_tag (outer_slr->L, MYLUA_TAG,
                        "recce, rule_id, lexeme_start, lexeme_end = ...\n"
                        "local q = recce.event_queue\n"
                        "local g1r = recce.lmw_g1r\n"
                        "local event_on_discard_active =\n"
                        "    recce.l0_rules[rule_id].event_on_discard_active\n"
                        "if event_on_discard_active then\n"
                        "   local last_g1_location = g1r:latest_earley_set()\n"
                        "   q[#q+1] = { 'discarded lexeme',\n"
                        "      rule_id, lexeme_start, lexeme_end, last_g1_location}\n"
                        "end\n"
                        ,
                        "Riiii>",
                        outer_slr->lua_ref,
                        (lua_Integer) l0_rule_id,
                        (lua_Integer) lexeme_stack_event->
                        t_trace_lexeme_discarded.t_start_of_lexeme,
                        (lua_Integer) lexeme_stack_event->
                        t_trace_lexeme_discarded.t_end_of_lexeme
                    );
                }
                goto NEXT_LEXEME_EVENT;
            }
          NEXT_LEXEME_EVENT:;
        }
    }

    if (pass1_result == discard) {
        /* slr->problem_pos? */
        slr->perl_pos = slr->lexer_start_pos = working_pos;
        return 0;
    }

    if (discard_mode) {
        return "R1 exhausted before end";
    }

    if (pass1_result != accept) {
        slr->perl_pos = slr->problem_pos = slr->lexer_start_pos =
            slr->start_of_lexeme;
        return "no lexeme";
    }

    /* If here, a lexeme has been accepted and priority is set
     */

    {                           /* Check for a "pause before" lexeme */
        /* A legacy implement allowed only one pause-before lexeme, and used elements of
           the SLR structure to hold the data.  The new mechanism uses events and allows
           multiple pause-before lexemes, but the legacy mechanism must be supported. */
        Marpa_Symbol_ID g1_lexeme = -1;
        int i;
        for (i = 0; i < slr->t_lexeme_count; i++) {
            union marpa_slr_event_s *const lexeme_entry =
                slr->t_lexemes + i;
            const int event_type = MARPA_SLREV_TYPE (lexeme_entry);
            if (event_type == MARPA_SLRTR_LEXEME_ACCEPTABLE) {
                const Marpa_Symbol_ID lexeme_id =
                    lexeme_entry->t_lexeme_acceptable.t_lexeme;
                const struct symbol_r_properties *symbol_r_properties =
                    slr->symbol_r_properties + lexeme_id;
                if (symbol_r_properties->t_pause_before_active) {
                    g1_lexeme = lexeme_id;
                    slr->start_of_pause_lexeme =
                        lexeme_entry->t_lexeme_acceptable.
                        t_start_of_lexeme;
                    slr->end_of_pause_lexeme =
                        lexeme_entry->t_lexeme_acceptable.t_end_of_lexeme;
                    call_by_tag (outer_slr->L, MYLUA_TAG,
                        "recce, lexeme_start, lexeme_end, g1_lexeme = ...\n"
                        "local q = recce.event_queue\n"
                        "if recce.trace_terminals > 2 then\n"
                        "    q[#q+1] = { '!trace', 'g1 before lexeme event', g1_lexeme}\n"
                        "end\n"
                        "q[#q+1] = { 'before lexeme', g1_lexeme}\n",
                        "Riii>", outer_slr->lua_ref,
                        (lua_Integer) slr->start_of_pause_lexeme,
                        (lua_Integer) slr->end_of_pause_lexeme,
                        (lua_Integer) g1_lexeme);
                }
            }
        }

        if (g1_lexeme >= 0) {
            slr->lexer_start_pos = slr->perl_pos = slr->start_of_lexeme;
            return 0;
        }
    }

    {
        lua_Integer return_value;
        int i;
        for (i = 0; i < slr->t_lexeme_count; i++) {
            union marpa_slr_event_s *const event = slr->t_lexemes + i;
            const int event_type = MARPA_SLREV_TYPE (event);
            if (event_type == MARPA_SLRTR_LEXEME_ACCEPTABLE) {
                const Marpa_Symbol_ID g1_lexeme =
                    event->t_lexeme_acceptable.t_lexeme;
                const struct symbol_r_properties *symbol_r_properties =
                    slr->symbol_r_properties + g1_lexeme;

                call_by_tag (outer_slr->L, MYLUA_TAG,
                    "recce, lexeme_start, lexeme_end, g1_lexeme = ...\n"
                    "if recce.trace_terminals > 2 then\n"
                    "    local q = recce.event_queue\n"
                    "    q[#q+1] = { '!trace', 'g1 attempting lexeme', lexeme_start, lexeme_end, g1_lexeme}\n"
                    "end\n"
                    "local g1r = recce.lmw_g1r\n"
                    "local kollos = getmetatable(g1r).kollos\n"
                    "local value_is_literal = kollos.defines.TOKEN_VALUE_IS_LITERAL\n"
                    "local return_value = g1r:alternative(g1_lexeme, value_is_literal, 1)\n"
                    "-- print('return value = ', inspect(return_value))\n"
                    "return return_value\n",
                    "Riii>i",
                    outer_slr->lua_ref,
                    (lua_Integer) slr->start_of_lexeme,
                    (lua_Integer) slr->end_of_lexeme,
                    (lua_Integer) g1_lexeme, &return_value);

                switch (return_value) {

                case MARPA_ERR_UNEXPECTED_TOKEN_ID:
                    croak
                        ("Internal error: Marpa rejected expected token");
                    break;

                case MARPA_ERR_DUPLICATE_TOKEN:
                    call_by_tag (outer_slr->L, MYLUA_TAG,
                        "recce, lexeme_start, lexeme_end, lexeme = ...\n"
                        "if recce.trace_terminals > 0 then\n"
                        "    local q = recce.event_queue\n"
                        "    q[#q+1] = { '!trace', 'g1 duplicate lexeme', lexeme_start, lexeme_end, lexeme}\n"
                        "end\n",
                        "Riii>",
                        outer_slr->lua_ref,
                        (lua_Integer) slr->start_of_lexeme,
                        (lua_Integer) slr->end_of_lexeme,
                        (lua_Integer) g1_lexeme);
                    break;

                case MARPA_ERR_NONE:
                    call_by_tag (outer_slr->L, MYLUA_TAG,
                        "recce, lexeme_start, lexeme_end, lexeme = ...\n"
                        "if recce.trace_terminals > 0 then\n"
                        "    local q = recce.event_queue\n"
                        "    q[#q+1] = { '!trace', 'g1 accepted lexeme', lexeme_start, lexeme_end, lexeme}\n"
                        "end\n",
                        "Riii>",
                        outer_slr->lua_ref,
                        (lua_Integer) slr->start_of_lexeme,
                        (lua_Integer) slr->end_of_lexeme,
                        (lua_Integer) g1_lexeme);
                    if (symbol_r_properties->t_pause_after_active) {
                        slr->start_of_pause_lexeme =
                            event->t_lexeme_acceptable.t_start_of_lexeme;
                        slr->end_of_pause_lexeme =
                            event->t_lexeme_acceptable.t_end_of_lexeme;

                        call_by_tag (outer_slr->L, MYLUA_TAG,
                            "recce, lexeme_start, lexeme_end, lexeme = ...\n"
                            "local q = recce.event_queue\n"
                            "if recce.trace_terminals > 2 then\n"
                            "    q[#q+1] = { '!trace', 'g1 pausing after lexeme', lexeme_start, lexeme_end, lexeme}\n"
                            "end\n"
                            "q[#q+1] = { 'after lexeme', lexeme}\n",
                            "Riii>",
                            outer_slr->lua_ref,
                            (lua_Integer) slr->start_of_pause_lexeme,
                            (lua_Integer) slr->end_of_pause_lexeme,
                            (lua_Integer) g1_lexeme);
                    }
                    break;

                default:
                    croak
                        ("Problem SLR->read() failed on symbol id %d at position %d: %s",
                        g1_lexeme, (int) slr->perl_pos,
                        slr_g1_error (outer_slr));
                    /* NOTREACHED */

                }

            }
        }



        call_by_tag (outer_slr->L, MYLUA_TAG,
            "local recce = ...\n"
            "local g1r = recce.lmw_g1r\n"
            "return g1r:earleme_complete()\n",
            "R>i", outer_slr->lua_ref, &return_value);

        if (return_value < 0) {
            croak ("Problem in marpa_r_earleme_complete(): %s",
                slr_g1_error (outer_slr));
        }
        slr->lexer_start_pos = slr->perl_pos = slr->end_of_lexeme;
        if (return_value > 0) {
            call_by_tag (outer_slr->L, MYLUA_TAG,
                "local recce, perl_pos = ...\n"
                "recce:g1_convert_events(perl_pos)\n",
                "Ri>", outer_slr->lua_ref, slr->perl_pos);
        }

        call_by_tag (outer_slr->L, MYLUA_TAG,
            "local recce, start_pos, lexeme_length = ...\n"
            "local g1r = recce.lmw_g1r\n"
            "local latest_earley_set = g1r:latest_earley_set()\n"
            "recce.es_data[latest_earley_set] = { start_pos, lexeme_length }\n",
            "Rii>", outer_slr->lua_ref, (lua_Integer) slr->start_of_lexeme,
            (lua_Integer) (slr->end_of_lexeme - slr->start_of_lexeme)
            );

    }

    return 0;

}

#define EXPECTED_LIBMARPA_MAJOR 8
#define EXPECTED_LIBMARPA_MINOR 4
#define EXPECTED_LIBMARPA_MICRO 0

/* get_mortalspace comes from "Extending and Embedding Perl"
   by Jenness and Cozens, p. 242 */
static void *
get_mortalspace (size_t nbytes) PERL_UNUSED_DECL;

static void *
get_mortalspace (size_t nbytes)
{
    dTHX;
    SV *mortal;
    mortal = sv_2mortal (NEWSV (0, nbytes));
    return (void *) SvPVX (mortal);
}

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

MODULE = Marpa::R3        PACKAGE = Marpa::R3::Thin::SLG

void
new( class, lua_wrapper )
    char * class;
    Marpa_Lua* lua_wrapper;
PPCODE:
{
    SV *new_sv;
    Outer_G *outer_slg;
    Scanless_G *slg;
    lua_State *L = lua_wrapper->L;
    int base_of_stack;
    int grammar_ix;
    PERL_UNUSED_ARG (class);

    Newx (outer_slg, 1, Outer_G);
    slg = slg_inner_new ();

    outer_slg->inner = slg;
    outer_slg->L = L;
    base_of_stack = marpa_lua_gettop(L);
    lua_refinc (L);

    /* No lock held -- SLG must delete grammar table in its */
    /*   destructor. */
    marpa_lua_newtable (L);
    grammar_ix = marpa_lua_gettop(L);

    /* When this moves into the kollos library, we
     * *CANNOT* use the "kollos" global.
     */
    marpa_lua_getglobal(L, "kollos");
    marpa_lua_getfield(L, -1, "class_slg");
    marpa_lua_setmetatable (L, grammar_ix);
    marpa_lua_pushlightuserdata (L, slg);
    marpa_lua_setfield (L, grammar_ix, "lud");
    marpa_lua_pushinteger(L, 1);
    marpa_lua_setfield (L, grammar_ix, "ref_count");
    marpa_lua_pushvalue (L, grammar_ix);
    outer_slg->lua_ref = marpa_luaL_ref (L, LUA_REGISTRYINDEX);
    marpa_lua_settop(L, base_of_stack);


    call_by_tag (outer_slg->L, MYLUA_TAG,
        "slg = ...\n"
        "slg:post_new()\n"
        ,
        "G>", outer_slg->lua_ref);

    new_sv = sv_newmortal ();
    sv_setref_pv (new_sv, scanless_g_class_name, (void *) outer_slg);
    XPUSHs (new_sv);
}

void
DESTROY( outer_slg )
    Outer_G *outer_slg;
PPCODE:
{
  /* This is unnecessary at the moment, since the next statement
   * will destroy the Lua state.  But someday grammars may share
   * Lua states, and then this will be necessary.
   */
  kollos_robrefdec(outer_slg->L, outer_slg->lua_ref);
  lua_refdec(outer_slg->L);
  Safefree (outer_slg);
}

void
init_properties( outer_slg)
    Outer_G *outer_slg;
PPCODE:
{
    slg_inner_init_properties (outer_slg);
    XSRETURN_YES;
}

 # Mark the symbol as a lexeme.
 # A priority is required.
 #
void
g1_lexeme_set( outer_slg, g1_lexeme, priority )
    Outer_G *outer_slg;
    Marpa_Symbol_ID g1_lexeme;
    int priority;
PPCODE:
{
  Scanless_G* slg = slg_inner_get(outer_slg);
  lua_Integer highest_g1_symbol_id;

    call_by_tag (outer_slg->L, MYLUA_TAG,
        "grammar = ...\n"
        "local g1g = grammar.lmw_g1g\n"
        "return g1g:highest_symbol_id()\n"
        ,
        "G>i", outer_slg->lua_ref, &highest_g1_symbol_id);

    if (g1_lexeme > highest_g1_symbol_id)
    {
      croak
        ("Problem in slg->g1_lexeme_priority_set(%ld, %ld): symbol ID was %ld, but highest G1 symbol ID = %ld",
         (long) g1_lexeme,
         (long) priority,
         (long) g1_lexeme,
         (long) highest_g1_symbol_id
         );
    }
    if (g1_lexeme < 0) {
      croak
        ("Problem in slg->g1_lexeme_priority(%ld, %ld): symbol ID was %ld, a disallowed value",
         (long) g1_lexeme,
         (long) priority,
         (long) g1_lexeme);
    }
  slg->symbol_g_properties[g1_lexeme].priority = priority;
  slg->symbol_g_properties[g1_lexeme].is_lexeme = 1;
  XSRETURN_YES;
}

void
g1_lexeme_pause_set( outer_slg, g1_lexeme, pause )
    Outer_G *outer_slg;
    Marpa_Symbol_ID g1_lexeme;
    int pause;
PPCODE:
{
  Scanless_G* slg = slg_inner_get(outer_slg);
  lua_Integer highest_g1_symbol_id;
    struct symbol_g_properties * g_properties = slg->symbol_g_properties + g1_lexeme;
    call_by_tag (outer_slg->L, MYLUA_TAG,
        "grammar = ...\n"
        "local g1g = grammar.lmw_g1g\n"
        "return g1g:highest_symbol_id()\n"
        ,
        "G>i", outer_slg->lua_ref, &highest_g1_symbol_id);

    if (g1_lexeme > highest_g1_symbol_id)
    {
      croak
        ("Problem in slg->g1_lexeme_pause_set(%ld, %ld): symbol ID was %ld, but highest G1 symbol ID = %ld",
         (long) g1_lexeme,
         (long) pause,
         (long) g1_lexeme,
         (long) highest_g1_symbol_id
         );
    }
    if (g1_lexeme < 0) {
      croak
        ("Problem in slg->lexeme_pause_set(%ld, %ld): symbol ID was %ld, a disallowed value",
         (long) g1_lexeme,
         (long) pause,
         (long) g1_lexeme);
    }
    switch (pause) {
    case 0: /* No pause */
        g_properties->t_pause_after = 0;
        g_properties->t_pause_before = 0;
        break;
    case 1: /* Pause after */
        g_properties->t_pause_after = 1;
        g_properties->t_pause_before = 0;
        break;
    case -1: /* Pause before */
        g_properties->t_pause_after = 0;
        g_properties->t_pause_before = 1;
        break;
    default:
      croak
        ("Problem in slg->lexeme_pause_set(%ld, %ld): value of pause must be -1,0 or 1",
         (long) g1_lexeme,
         (long) pause);
    }
  XSRETURN_YES;
}

void
g1_lexeme_pause_activate( outer_slg, g1_lexeme, activate )
    Outer_G *outer_slg;
    Marpa_Symbol_ID g1_lexeme;
    int activate;
PPCODE:
{
  Scanless_G* slg = slg_inner_get(outer_slg);
  lua_Integer highest_g1_symbol_id;
  struct symbol_g_properties *g_properties =
    slg->symbol_g_properties + g1_lexeme;

    call_by_tag (outer_slg->L, MYLUA_TAG,
        "grammar = ...\n"
        "local g1g = grammar.lmw_g1g\n"
        "return g1g:highest_symbol_id()\n"
        ,
        "G>i", outer_slg->lua_ref, &highest_g1_symbol_id);

  if (g1_lexeme > highest_g1_symbol_id)
    {
      croak
        ("Problem in slg->g1_lexeme_pause_activate(%ld, %ld): symbol ID was %ld, but highest G1 symbol ID = %ld",
         (long) g1_lexeme,
         (long) activate, (long) g1_lexeme, (long) highest_g1_symbol_id);
    }
  if (g1_lexeme < 0)
    {
      croak
        ("Problem in slg->lexeme_pause_activate(%ld, %ld): symbol ID was %ld, a disallowed value",
         (long) g1_lexeme, (long) activate, (long) g1_lexeme);
    }

  if (activate != 0 && activate != 1)
    {
      croak
        ("Problem in slg->lexeme_pause_activate(%ld, %ld): value of activate must be 0 or 1",
         (long) g1_lexeme, (long) activate);
    }

  if (g_properties->t_pause_before)
    {
      g_properties->t_pause_before_active = activate ? 1 : 0;
    }
  else if (g_properties->t_pause_after)
    {
      g_properties->t_pause_after_active = activate ? 1 : 0;
    }
  else
    {
      croak
        ("Problem in slg->lexeme_pause_activate(%ld, %ld): no pause event is enabled",
         (long) g1_lexeme, (long) activate);
    }
  XSRETURN_YES;
}

MODULE = Marpa::R3        PACKAGE = Marpa::R3::Thin::SLR

void
new( class, slg_sv )
    char * class;
    SV *slg_sv;
PPCODE:
{
  lua_State* L;
  SV *new_sv;
  Outer_G *outer_slg;
  Outer_R *outer_slr;
  Scanless_R *slr;
  PERL_UNUSED_ARG(class);

  if (!sv_isa (slg_sv, "Marpa::R3::Thin::SLG"))
    {
      croak
        ("Problem in u->new(): slg arg is not of type Marpa::R3::Thin::SLG");
    }
  Newx (outer_slr, 1, Outer_R);
  /* Set slg and outer_slg from the SLG SV */
  {
    IV tmp = SvIV ((SV *) SvRV (slg_sv));
    outer_slg = INT2PTR (Outer_G *, tmp);
  }
  L = outer_slg->L;

  slg_inner_get(outer_slg);

  slr = marpa_inner_slr_new(outer_slg);
  /* Copy and take references to the "parent objects",
   * the ones responsible for holding references.
   */

  outer_slr->slg_sv = slg_sv;
  SvREFCNT_inc (slg_sv);

  {
    const int base_of_stack = marpa_lua_gettop(L);
    int slr_ix;

    if (!marpa_lua_checkstack(L, MYLUA_STACK_INCR))
    {
        croak ("Internal Marpa::R3 error; could not grow stack: " MYLUA_TAG);
    }
    outer_slr->L = L;
    /* Take ownership of a new reference to the Lua state */
    lua_refinc(L);

    marpa_lua_newtable (L);
    slr_ix = marpa_lua_gettop(L);

    /* When this moves into the kollos library, we
     * *CANNOT* use the "kollos" global.
     */
    marpa_lua_getglobal(L, "kollos");
    marpa_lua_getfield(L, -1, "class_slr");
    marpa_lua_setmetatable (L, slr_ix);
    marpa_lua_pushlightuserdata (L, slr);
    marpa_lua_setfield (L, slr_ix, "lud");
    marpa_lua_pushinteger(L, 1);
    marpa_lua_setfield (L, slr_ix, "ref_count");
    marpa_lua_pushvalue (L, slr_ix);
    marpa_lua_rawgeti (L, LUA_REGISTRYINDEX, outer_slg->lua_ref);
    marpa_lua_setfield(L, slr_ix, "slg");
    outer_slr->lua_ref = marpa_luaL_ref (L, LUA_REGISTRYINDEX);
    marpa_lua_settop(L, base_of_stack);
  }

  call_by_tag (outer_slr->L, MYLUA_TAG,
      "local recce = ...\n"
      "local grammar = recce.slg\n"
      "local l0g = grammar.lmw_l0g\n"
      "local g1g = grammar.lmw_g1g\n"
      "recce.lmw_g1r = kollos.recce_new(g1g)\n"
      "recce.too_many_earley_items = -1\n"
      "recce.event_queue = {}\n"
      "recce.es_data = {}\n"
      "recce.lmw_g1r.lmw_g = g1g\n"
      "recce.trace_terminals = 0\n"
      "recce.per_codepoint = {}\n"
      "recce.l0_rules = {}\n"
      "local r_l0_rules = recce.l0_rules\n"
      "local g_l0_rules = grammar.l0_rules\n"
      "-- print('g_l0_rules: ', inspect(g_l0_rules))\n"
      "local max_l0_rule_id = l0g:highest_rule_id()\n"
      "for rule_id = 0, max_l0_rule_id do\n"
      "    r_l0_rules[rule_id] = {\n"
      "        event_on_discard_active =\n"
      "            g_l0_rules[rule_id].event_on_discard_active\n"
      "    }\n"
      "end\n"
      "recce.g1_symbols = {}\n"
      "local g_g1_symbols = grammar.g1_symbols\n"
      "local r_g1_symbols = recce.g1_symbols\n"
      "local max_g1_symbol_id = g1g:highest_symbol_id()\n"
      "for symbol_id = 0, max_g1_symbol_id do\n"
      "    r_g1_symbols[symbol_id] = {\n"
      "        lexeme_priority =\n"
      "            g_g1_symbols[symbol_id].priority,\n"
      "        pause_before_active =\n"
      "            g_g1_symbols[symbol_id].pause_before_active,\n"
      "        pause_after_active =\n"
      "            g_g1_symbols[symbol_id].pause_after_active\n"
      "    }\n"
      "end\n"
      ,
      "R>", outer_slr->lua_ref);

  new_sv = sv_newmortal ();
  sv_setref_pv (new_sv, scanless_r_class_name, (void *) outer_slr);
  XPUSHs (new_sv);
}

void
DESTROY( outer_slr )
    Outer_R *outer_slr;
PPCODE:
{
  call_by_tag (outer_slr->L, MYLUA_TAG,
      "local recce = ...\n"
      "valuation_reset(recce)\n"
      "return 0\n",
      "R>", outer_slr->lua_ref);
  lua_refdec(outer_slr->L);
  SvREFCNT_dec (outer_slr->slg_sv);
  Safefree (outer_slr);
}

void throw_set(outer_slr, throw_setting)
    Outer_R *outer_slr;
    int throw_setting;
PPCODE:
{
  Scanless_R *slr = slr_inner_get(outer_slr);
  slr->throw = throw_setting;
}

void
pos( outer_slr )
    Outer_R *outer_slr;
PPCODE:
{
  Scanless_R *slr = slr_inner_get(outer_slr);
  XSRETURN_IV(slr->perl_pos);
}

void
pos_set( outer_slr, start_pos_sv, length_sv )
    Outer_R *outer_slr;
     SV* start_pos_sv;
     SV* length_sv;
PPCODE:
{
  Scanless_R *slr = slr_inner_get(outer_slr);
  int start_pos = SvIOK(start_pos_sv) ? (int)SvIV(start_pos_sv) : slr->perl_pos;
  int length = SvIOK(length_sv) ? (int)SvIV(length_sv) : -1;
  u_pos_set(outer_slr, "slr->pos_set", start_pos, length);
  slr->lexer_start_pos = slr->perl_pos;
  XSRETURN_YES;
}

void
read(outer_slr)
    Outer_R *outer_slr;
PPCODE:
{
  Scanless_R *slr = slr_inner_get(outer_slr);
  int lexer_read_result = 0;

  if (slr->is_external_scanning)
    {
      XSRETURN_PV ("unpermitted mix of external and internal scanning");
    }

  slr->lexer_read_result = 0;
  slr->start_of_pause_lexeme = -1;
  slr->end_of_pause_lexeme = -1;

  /* Clear event queue */
  call_by_tag (outer_slr->L, MYLUA_TAG,
      "local recce = ...\n"
      "recce.event_queue = {}\n",
      "R>", outer_slr->lua_ref);

  /* Application intervention resets perl_pos */
  slr->last_perl_pos = -1;

  while (1)
    {
      if (slr->lexer_start_pos >= 0)
        {
          if (slr->lexer_start_pos >= slr->end_pos)
            {
              XSRETURN_PV ("");
            }

          slr->start_of_lexeme = slr->perl_pos = slr->lexer_start_pos;
          slr->lexer_start_pos = -1;
                            call_by_tag (outer_slr->L, MYLUA_TAG,
                                "local recce, perl_pos = ...\n"
                                "recce.lmw_l0r = nil\n"
                                "if recce.trace_terminals >= 1 then\n"
                                "    local q = recce.event_queue\n"
                                "    q[#q+1] = { '!trace', 'lexer restarted recognizer', perl_pos}\n"
                                "end\n",
                                "Ri>",
                                outer_slr->lua_ref,
                                (lua_Integer)slr->perl_pos
                            );

        }

      lexer_read_result = slr->lexer_read_result = u_read (outer_slr);
      switch (lexer_read_result)
        {
        case U_READ_TRACING:
          XSRETURN_PV ("trace");
        case U_READ_UNREGISTERED_CHAR:
          XSRETURN_PV ("unregistered char");
        default:
          if (lexer_read_result < 0)
            {
              croak
                ("Internal Marpa SLIF error: u_read returned unknown code: %ld",
                 (long) lexer_read_result);
            }
          break;
        case U_READ_OK:
        case U_READ_INVALID_CHAR:
        case U_READ_REJECTED_CHAR:
        case U_READ_EXHAUSTED_ON_FAILURE:
        case U_READ_EXHAUSTED_ON_SUCCESS:
          break;
        }


        {
          lua_Integer discard_mode;
          const char *result_string;

          call_by_tag (outer_slr->L, MYLUA_TAG,
              "local recce = ...\n"
              "local g1r = recce.lmw_g1r\n"
              "return g1r:is_exhausted()\n"
              ,
              "R>i", outer_slr->lua_ref, &discard_mode);

          result_string = slr_alternatives (outer_slr, discard_mode);
          if (result_string)
            {
              XSRETURN_PV (result_string);
            }
        }

      {
        lua_Integer event_count;
        call_by_tag (outer_slr->L, MYLUA_TAG,
            "local recce = ...\n"
            "return #recce.event_queue\n",
            "R>i", outer_slr->lua_ref, &event_count);
        if (event_count)
          {
            XSRETURN_PV ("event");
          }
      }

        {
            lua_Integer trace_terminals;
            call_by_tag (outer_slr->L, MYLUA_TAG,
                "recce = ...\n"
                "return recce.trace_terminals\n",
                "R>i", outer_slr->lua_ref, &trace_terminals);
            if (trace_terminals)
              {
                XSRETURN_PV ("trace");
              }
        }

    }

  /* Never reached */
  XSRETURN_PV ("");
}

void
lexer_read_result (outer_slr)
    Outer_R *outer_slr;
PPCODE:
{
  Scanless_R *slr = slr_inner_get(outer_slr);
  XPUSHs (sv_2mortal (newSViv ((IV) slr->lexer_read_result)));
}

void
pause_span (outer_slr)
    Outer_R *outer_slr;
PPCODE:
{
  Scanless_R *slr = slr_inner_get(outer_slr);
  if (slr->end_of_pause_lexeme < 0)
    {
      XSRETURN_UNDEF;
    }
  XPUSHs (sv_2mortal (newSViv ((IV) slr->start_of_pause_lexeme)));
  XPUSHs (sv_2mortal
          (newSViv
           ((IV) slr->end_of_pause_lexeme - slr->start_of_pause_lexeme)));
}

void
lexeme_span (outer_slr)
    Outer_R *outer_slr;
PPCODE:
{
  Scanless_R *slr = slr_inner_get(outer_slr);
  int length = slr->end_of_lexeme - slr->start_of_lexeme;
  XPUSHs (sv_2mortal (newSViv ((IV) slr->start_of_lexeme)));
  XPUSHs (sv_2mortal (newSViv ((IV) length)));
}

 # TODO: Currently end location is not known at this
 # point.  Once it is, add tracing:
 # Don't bother with lexeme events as unnecessary
 # and counter-productive for this call, which often
 # is used to override them
 #
 # { '!trace', 'g1 pausing after lexeme', lexeme_start, lexeme_end, lexeme}
 # { '!trace', 'g1 before lexeme event', g1_lexeme}
 #
 # Yes, at trace level > 0
 # { "!trace", "g1 duplicate lexeme" ...
 # { '!trace', 'g1 accepted lexeme', lexeme_start, lexeme_end, lexeme}
 #
 # Yes, at trace level > 0
 # { '!trace', 'g1 attempting lexeme', lexeme_start, lexeme_end, lexeme}
 #
 # Irrelevant, cannot happen
 # { "!trace", "discarded lexeme" }
 #
 # Irrelevant?  Need to investigate.
 # { '!trace', 'ignored lexeme', g1_lexeme, lexeme_start, lexeme_end}
 #
 # Irrelevant, because this call overrides priorities
 # { "!trace", "outprioritized lexeme" }
 #
 # These are about lexeme expectations, which are
 # regarded as known before this call (or alternatively non-
 # acceptance is caught here via rejection).  Ignore
 # { '!trace', 'expected lexeme', perl_pos, lexeme, assertion }

 # Variable arg as opposed to a ref,
 # because there seems to be no
 # easy, forward-compatible way
 # to determine whether the de-referenced value will cause
 # a "bizarre copy" error.
 #
 # All errors are returned, not thrown
void
g1_alternative (outer_slr, symbol_id, ...)
    Outer_R *outer_slr;
    Marpa_Symbol_ID symbol_id;
PPCODE:
{
  Scanless_R *slr = slr_inner_get(outer_slr);
  lua_Integer result;
  lua_Integer token_ix;
  switch (items)
    {
    case 2:
    { lua_Integer value_is_literal;
            call_by_tag (outer_slr->L, MYLUA_TAG,
                "recce = ...\n"
                "local g1r = recce.lmw_g1r\n"
                "local kollos = getmetatable(g1r).kollos\n"
                "local defines = kollos.defines\n"
                "return defines.TOKEN_VALUE_IS_LITERAL\n",
                "R>i",
                outer_slr->lua_ref,
                &value_is_literal
            );

      token_ix = value_is_literal;        /* default */
      }
      break;
    case 3:
      {
        SV *token_value = ST (2);
        if (IS_PERL_UNDEF (token_value))
          { lua_Integer value_is_undef;
            call_by_tag (outer_slr->L, MYLUA_TAG,
                "recce = ...\n"
                "local g1r = recce.lmw_g1r\n"
                "local kollos = getmetatable(g1r).kollos\n"
                "local defines = kollos.defines\n"
                "return defines.TOKEN_VALUE_IS_UNDEF\n",
                "R>i",
                outer_slr->lua_ref,
                &value_is_undef
            );


            token_ix = value_is_undef;    /* default */
            break;
          }

        /* Fail fast with a tainted input token value */
        if (SvTAINTED(token_value)) {
            croak
              ("Problem in Marpa::R3: Attempt to use a tainted token value\n"
              "Marpa::R3 is insecure for use with tainted data\n");
        }
        av_push (slr->token_values, newSVsv (token_value));
        token_ix = av_len (slr->token_values);
        call_by_tag (outer_slr->L, MYLUA_TAG,
            "local recce, token_sv = ...;\n"
            "local new_token_ix = #recce.token_values + 1\n"
            "recce.token_values[new_token_ix] = token_sv\n"
            "return new_token_ix\n",
            "RS>i",
            outer_slr->lua_ref, newSVsv(token_value), &token_ix);
      }
      break;
    default:
      croak
        ("Usage: Marpa::R3::Thin::SLR::g1_alternative(slr, symbol_id, [value])");
    }


    call_by_tag (outer_slr->L, MYLUA_TAG,
        "recce, symbol_id, token_ix = ...\n"
        "local g1r = recce.lmw_g1r\n"
        "local return_value = g1r:alternative(symbol_id, token_ix, 1)\n"
        "return return_value\n"
        ,
        "Rii>i",
        outer_slr->lua_ref,
        (lua_Integer)symbol_id,
        (lua_Integer)token_ix,
        &result
    );

  if (result >= MARPA_ERR_NONE) {
    slr->is_external_scanning = 1;
  }
  XSRETURN_IV ((IV)result);
}

 # Returns current position on success, 0 on unthrown failure
void
g1_lexeme_complete (outer_slr, start_pos_sv, length_sv)
     Outer_R *outer_slr;
     SV* start_pos_sv;
     SV* length_sv;
PPCODE:
{
    Scanless_R *slr = slr_inner_get (outer_slr);
    lua_Integer result;
    lua_Integer input_length;
    int start_pos =
        SvIOK (start_pos_sv) ? (int)SvIV (start_pos_sv) : slr->perl_pos;

    int lexeme_length = SvIOK (length_sv) ? (int)SvIV (length_sv)
        : slr->perl_pos ==
        slr->start_of_pause_lexeme ? (slr->end_of_pause_lexeme -
        slr->start_of_pause_lexeme) : -1;

    call_by_tag (outer_slr->L, MYLUA_TAG,
        "recce = ...\n"
        "return #recce.codepoints\n",
        "R>i", outer_slr->lua_ref, &input_length);

    /* User intervention resets last |perl_pos| */
    slr->last_perl_pos = -1;

    start_pos = start_pos < 0 ? (int)input_length + start_pos : start_pos;
    if (start_pos < 0 || start_pos > input_length) {
        /* Undef start_pos_sv should not cause error */
        croak ("Bad start position in slr->g1_lexeme_complete(): %ld",
            (long) (SvIOK (start_pos_sv) ? SvIV (start_pos_sv) : -1));
    }
    slr->perl_pos = start_pos;

    {
        const int end_pos =
            lexeme_length <
            0 ? (int)input_length + lexeme_length + 1 : start_pos +
            lexeme_length;
        if (end_pos < 0 || end_pos > input_length) {
            /* Undef length_sv should not cause error */
            croak ("Bad length in slr->g1_lexeme_complete(): %ld",
                (long) (SvIOK (length_sv) ? SvIV (length_sv) : -1));
        }
        lexeme_length = end_pos - start_pos;
    }

    call_by_tag (outer_slr->L, MYLUA_TAG,
        "local recce = ...\n"
        "local g1r = recce.lmw_g1r\n"
        "recce.event_queue = {}\n"
        "local result = g1r:earleme_complete()\n"
        "return result\n", "R>i", outer_slr->lua_ref, &result);

    slr->is_external_scanning = 0;
    if (result >= 0) {
        call_by_tag (outer_slr->L, MYLUA_TAG,
            "local recce, start_pos, lexeme_length, perl_pos = ...\n"
            "recce:g1_convert_events(perl_pos)\n"
            "local g1r = recce.lmw_g1r\n"
            "local latest_earley_set = g1r:latest_earley_set()\n"
            "recce.es_data[latest_earley_set] = { start_pos, lexeme_length }\n",
            "Riii>", outer_slr->lua_ref, (lua_Integer) start_pos,
            (lua_Integer) lexeme_length, slr->perl_pos);

        slr->perl_pos = start_pos + lexeme_length;
        XSRETURN_IV (slr->perl_pos);
    }
    if (result == -2) {
        call_by_tag (outer_slr->L, MYLUA_TAG,
            "recce = ...\n"
            "local error_code = recce.slg.lmw_g1g:error_code()\n"
            "if error_code == kollos.err.PARSE_EXHAUSTED then\n"
            "    local q = recce.event_queue\n"
            "    q[#q+1] = { 'no acceptable input' }\n"
            "end\n", "R>", outer_slr->lua_ref);

        XSRETURN_IV (0);
    }
    if (slr->throw) {
        croak ("Problem in slr->g1_lexeme_complete(): %s",
            slr_g1_error (outer_slr));
    }
    XSRETURN_IV (0);
}

void
lexeme_event_activate( outer_slr, g1_lexeme_id, reactivate )
    Outer_R *outer_slr;
    Marpa_Symbol_ID g1_lexeme_id;
    int reactivate;
PPCODE:
{
  Scanless_R *slr = slr_inner_get(outer_slr);
  struct symbol_r_properties *symbol_r_properties;
  const Scanless_G *slg = slr->slg;
  lua_Integer highest_g1_symbol_id;

    call_by_tag (outer_slr->L, MYLUA_TAG,
        "recce = ...\n"
        "grammar = recce.slg\n"
        "local g1g = grammar.lmw_g1g\n"
        "return g1g:highest_symbol_id()\n"
        ,
        "R>i", outer_slr->lua_ref, &highest_g1_symbol_id);

  if (g1_lexeme_id > highest_g1_symbol_id)
    {
      croak
        ("Problem in slr->lexeme_event_activate(..., %ld, %ld): symbol ID was %ld, but highest G1 symbol ID = %ld",
         (long) g1_lexeme_id, (long) reactivate,
         (long) g1_lexeme_id, (long) highest_g1_symbol_id);
    }
  if (g1_lexeme_id < 0)
    {
      croak
        ("Problem in slr->lexeme_event_activate(..., %ld, %ld): symbol ID was %ld, a disallowed value",
         (long) g1_lexeme_id, (long) reactivate, (long) g1_lexeme_id);
    }
  symbol_r_properties = slr->symbol_r_properties + g1_lexeme_id;
  switch (reactivate)
    {
    case 0:
      symbol_r_properties->t_pause_after_active = 0;
      symbol_r_properties->t_pause_before_active = 0;
      break;
    case 1:
      {
        const struct symbol_g_properties* g_properties = slg->symbol_g_properties + g1_lexeme_id;
        /* Only activate events which are enabled */
        symbol_r_properties->t_pause_after_active = g_properties->t_pause_after;
        symbol_r_properties->t_pause_before_active = g_properties->t_pause_before;
      }
      break;
    default:
      croak
        ("Problem in slr->lexeme_event_activate(..., %ld, %ld): reactivate flag is %ld, a disallowed value",
         (long) g1_lexeme_id, (long) reactivate, (long) reactivate);
    }
  XPUSHs (sv_2mortal (newSViv (reactivate)));
}

void
problem_pos( outer_slr )
    Outer_R *outer_slr;
PPCODE:
{
  Scanless_R *slr = slr_inner_get(outer_slr);
  if (slr->problem_pos < 0) {
     XSRETURN_UNDEF;
  }
  XSRETURN_IV(slr->problem_pos);
}

void
codepoint( outer_slr )
    Outer_R *outer_slr;
PPCODE:
{
  Scanless_R *slr = slr_inner_get(outer_slr);
  XSRETURN_UV((UV)slr->codepoint);
}

void
symbol_id( outer_slr )
    Outer_R *outer_slr;
PPCODE:
{
  Scanless_R *slr = slr_inner_get(outer_slr);
  XSRETURN_IV(slr->input_symbol_id);
}

void
lexeme_priority_set( outer_slr, g1_lexeme, new_priority )
    Outer_R *outer_slr;
    Marpa_Symbol_ID g1_lexeme;
    int new_priority;
PPCODE:
{
  Scanless_R *slr = slr_inner_get(outer_slr);
  int old_priority;
  const Scanless_G *slg = slr->slg;
  lua_Integer highest_g1_symbol_id;

    call_by_tag (outer_slr->L, MYLUA_TAG,
        "recce = ...\n"
        "grammar = recce.slg\n"
        "local g1g = grammar.lmw_g1g\n"
        "return g1g:highest_symbol_id()\n"
        ,
        "R>i", outer_slr->lua_ref, &highest_g1_symbol_id);

    if (g1_lexeme > highest_g1_symbol_id)
    {
      croak
        ("Problem in slr->g1_lexeme_priority(%ld): symbol ID was %ld, but highest G1 symbol ID = %ld",
         (long) g1_lexeme,
         (long) g1_lexeme,
         (long) highest_g1_symbol_id
         );
    }
    if (g1_lexeme < 0) {
      croak
        ("Problem in slr->g1_lexeme_priority(%ld): symbol ID was %ld, a disallowed value",
         (long) g1_lexeme,
         (long) g1_lexeme);
    }
  if ( ! slg->symbol_g_properties[g1_lexeme].is_lexeme ) {
      croak
        ("Problem in slr->g1_lexeme_priority(%ld): symbol ID %ld is not a lexeme",
         (long) g1_lexeme,
         (long) g1_lexeme);
  }
  old_priority = slr->symbol_r_properties[g1_lexeme].lexeme_priority;
  slr->symbol_r_properties[g1_lexeme].lexeme_priority = new_priority;
  XSRETURN_IV( old_priority );
}


void
stack_step( outer_slr )
    Outer_R *outer_slr;
PPCODE:
{
    lua_Integer result;
    SV *new_values;

    call_by_tag (outer_slr->L, MYLUA_TAG,
        "local recce = ...; return recce:find_and_do_ops()\n",
        "R>iC", outer_slr->lua_ref, &result, &new_values);

    switch (result) {
    case 3:
        {
            SV* step_type;
            lua_Integer parm2;
            call_by_tag (outer_slr->L, MYLUA_TAG,
              "local recce = ...\n"
              "local this = recce.this_step\n"
              "local step_type = this.type\n"
              "local parm2 = step_type == 'MARPA_STEP_RULE' and this.rule or this.symbol\n"
              "return step_type, parm2\n",
              "R>Ci", outer_slr->lua_ref, &step_type, &parm2);
            XPUSHs (step_type); /* already mortal */
            XPUSHs (sv_2mortal (newSViv ((IV)parm2)));
            XPUSHs (new_values);      /* already mortal */
            XSRETURN (3);
        }
    default:
    case 1:
        {
            SV* step_type;
            call_by_tag (outer_slr->L, MYLUA_TAG,
              "local recce = ...\n"
              "return recce.this_step.type\n",
              "R>C", outer_slr->lua_ref, &step_type);
            XPUSHs (step_type); /* already mortal */
            XSRETURN (1);
        }
    case 0:
        XSRETURN_EMPTY;
    case -1:
        XSRETURN_PV ("trace");
    }
}

void
start_input( outer_slr )
    Outer_R *outer_slr;
PPCODE:
{
  Scanless_R *slr = slr_inner_get(outer_slr);
  lua_Integer gp_result;

    call_by_tag (outer_slr->L, MYLUA_TAG,
        "recce = ...\n"
        "local g1r = recce.lmw_g1r\n"
        "local return_value = g1r:start_input()\n"
        "return return_value\n"
        ,
        "R>i",
        outer_slr->lua_ref,
        &gp_result
    );

  if ( gp_result == -1 ) { XSRETURN_UNDEF; }
  if ( gp_result < 0 ) {
    croak( "Problem in r->start_input(): %s",
      slr_g1_error (outer_slr));
  }

    call_by_tag (outer_slr->L, MYLUA_TAG,
        "recce, perl_pos = ...\n"
        "recce:g1_convert_events(perl_pos)\n"
        ,
        "Ri>",
        outer_slr->lua_ref,
        slr->perl_pos
    );

  XPUSHs (sv_2mortal (newSViv ((IV)gp_result)));
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
    int kollos_ix;
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

    /* We will need the kollos table in what follows,
     * so get it from the global.
     */
    marpa_lua_getglobal(L, "kollos");
    kollos_ix = marpa_lua_gettop(L);

    marpa_lua_getfield(L, kollos_ix, "class_slg");
    marpa_lua_getfield(L, kollos_ix, "upvalues");
    marpa_luaL_setfuncs(L, marpa_slg_meths, 1);

    marpa_lua_getfield(L, kollos_ix, "class_slr");
    marpa_lua_getfield(L, kollos_ix, "upvalues");
    marpa_luaL_setfuncs(L, marpa_slr_meths, 1);

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

    marpa_luaL_newlib(L, marpa_sv_funcs);
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

INCLUDE: exec_lua.xs

BOOT:

    marpa_debug_handler_set(marpa_r3_warn);

    /* vim: set expandtab shiftwidth=2: */
