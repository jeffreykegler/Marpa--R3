/*
 * Marpa::R3 is Copyright (C) 2016, Jeffrey Kegler.
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
     int priority;
     unsigned int is_lexeme:1;
     unsigned int t_pause_before:1;
     unsigned int t_pause_before_active:1;
     unsigned int t_pause_after:1;
     unsigned int t_pause_after_active:1;
};

struct l0_rule_g_properties {
     unsigned int t_event_on_discard:1;
     unsigned int t_event_on_discard_active:1;
};

struct symbol_r_properties {
     int lexeme_priority;
     unsigned int t_pause_before_active:1;
     unsigned int t_pause_after_active:1;
};

struct l0_rule_r_properties {
     unsigned int t_event_on_discard_active:1;
};

typedef struct {
     Marpa_Grammar g;
     char *message_buffer;
     int libmarpa_error_code;
     const char *libmarpa_error_string;
     unsigned int throw:1;
     unsigned int message_is_marpa_thin_error:1;
} G_Wrapper;

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
  Marpa_Grammar g1;
  SV *g1_sv;
  G_Wrapper *g1_wrapper;

  SV *l0_sv;
  G_Wrapper *l0_wrapper;
  HV *per_codepoint_hash;
  UV *per_codepoint_array[128];
  int precomputed;
  struct symbol_g_properties *symbol_g_properties;
  struct l0_rule_g_properties *l0_rule_g_properties;
  AV *constants;

  /* Does it have L0 and G1 yet? */
  int is_associated;

} Scanless_G;

typedef struct {
  lua_Integer lua_ref;
  lua_State* L;
  Scanless_G* inner;
} Outer_G;

typedef struct
{
  SV *g1g_sv;

  Scanless_G *slg;
  G_Wrapper *g1_wrapper;
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
  struct l0_rule_r_properties *l0_rule_r_properties;

  Marpa_Symbol_ID input_symbol_id;
  lua_Integer codepoint;                 /* For error returns */
  int end_pos;

  union marpa_slr_event_s* t_lexemes;
  int t_lexeme_capacity;
  int t_lexeme_count;

  /* We need a copy of the outer_slr lua_ref,
   * but hopefully only while refactoring
   */
  lua_Integer outer_slr_lua_ref;

} Scanless_R;

typedef struct
{
  /* Lua "reference" to this object */
  lua_Integer lua_ref;
  lua_State* L;
  Outer_G* outer_slg;
  SV *slg_sv;
} Outer_R;

typedef struct
{
  lua_State* L;
} Marpa_Lua;

