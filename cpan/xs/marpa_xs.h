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
#include "ppport.h"

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

typedef unsigned int Marpa_Codepoint;

extern const struct marpa_error_description_s marpa_error_description[];
extern const struct marpa_event_description_s marpa_event_description[];
extern const struct marpa_step_type_description_s
  marpa_step_type_description[];

typedef struct {
    int next_offset; /* Offset of *NEXT* codepoint */
    int linecol;
    /* Lines are 1-based, columns are zero-based and negated.
     * In the first column (column 0), linecol is the 1-based line number.
     * In subsequent columns, linecol is -n, where n is the 0-based column
     * number.
     */
} Pos_Entry;

struct symbol_g_properties {
     int priority;
     unsigned int latm:1;
     unsigned int is_lexeme:1;
     unsigned int t_pause_before:1;
     unsigned int t_pause_before_active:1;
     unsigned int t_pause_after:1;
     unsigned int t_pause_after_active:1;
};

struct l0_rule_g_properties {
     Marpa_Symbol_ID g1_lexeme;
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

typedef struct {
     Marpa_Recce r;
     Marpa_Symbol_ID* terminals_buffer;
     SV* base_sv;
     AV* event_queue;
     G_Wrapper* base;
     unsigned int ruby_slippers:1;
} R_Wrapper;

union marpa_slr_event_s;

#define MARPA_SLREV_AFTER_LEXEME 1
#define MARPA_SLREV_BEFORE_LEXEME 2
#define MARPA_SLREV_LEXEME_DISCARDED 3
#define MARPA_SLREV_LEXER_RESTARTED_RECCE 4
#define MARPA_SLREV_MARPA_R_UNKNOWN 5
#define MARPA_SLREV_NO_ACCEPTABLE_INPUT 6
#define MARPA_SLREV_SYMBOL_COMPLETED 7
#define MARPA_SLREV_SYMBOL_NULLED 8
#define MARPA_SLREV_SYMBOL_PREDICTED 9
#define MARPA_SLRTR_AFTER_LEXEME 10
#define MARPA_SLRTR_BEFORE_LEXEME 11
/* #define MARPA_SLRTR_CHANGE_LEXERS 12 */
#define MARPA_SLRTR_CODEPOINT_ACCEPTED 13
#define MARPA_SLRTR_CODEPOINT_READ 14
#define MARPA_SLRTR_CODEPOINT_REJECTED 15
#define MARPA_SLRTR_LEXEME_DISCARDED 16
#define MARPA_SLRTR_G1_ACCEPTED_LEXEME 17
#define MARPA_SLRTR_G1_ATTEMPTING_LEXEME 18
#define MARPA_SLRTR_G1_DUPLICATE_LEXEME 19
#define MARPA_SLRTR_LEXEME_REJECTED 20
#define MARPA_SLRTR_LEXEME_IGNORED 21
#define MARPA_SLREV_DELETED 22
#define MARPA_SLRTR_LEXEME_ACCEPTABLE 23
#define MARPA_SLRTR_LEXEME_OUTPRIORITIZED 24

/* This one is strange -- only invoked at position 0.
 * Compare MARPA_SLRTR_LEXEME_ACCEPTABLE
 * Do I need MARPA_SLRTR_LEXEME_EXPECTED?
 */
#define MARPA_SLRTR_LEXEME_EXPECTED 26

#define MARPA_SLREV_L0_YIM_THRESHOLD_EXCEEDED 27
#define MARPA_SLREV_G1_YIM_THRESHOLD_EXCEEDED 28

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
    int t_codepoint;
    int t_perl_pos;
  } t_trace_codepoint_read;

  struct
  {
    int event_type;
    int t_codepoint;
    int t_perl_pos;
    int t_symbol_id;
  } t_trace_codepoint_rejected;

  struct
  {
    int event_type;
    int t_codepoint;
    int t_perl_pos;
    int t_symbol_id;
  } t_trace_codepoint_accepted;

  struct
  {
    int event_type;
    int t_event_type;
    int t_lexeme;
    int t_start_of_lexeme;
    int t_end_of_lexeme;
  } t_trace_lexeme_ignored;

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
    int t_symbol;
  } t_symbol_completed;

  struct
  {
    int event_type;
    int t_symbol;
  } t_symbol_nulled;

  struct
  {
    int event_type;
    int t_symbol;
  } t_symbol_predicted;

  struct
  {
    int event_type;
    int t_event;
  } t_marpa_r_unknown;

  struct
  {
    int event_type;
    int t_start_of_lexeme;
    int t_end_of_lexeme;
    int t_lexeme;
  }
  t_trace_lexeme_rejected;

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
    int t_start_of_pause_lexeme;
    int t_end_of_pause_lexeme;
    int t_pause_lexeme;
  } t_trace_before_lexeme;

  struct
  {
    int event_type;
    int t_pause_lexeme;
  } t_before_lexeme;

  struct
  {
    int event_type;
    int t_start_of_lexeme;
    int t_end_of_lexeme;
    int t_lexeme;
  } t_trace_after_lexeme;

  struct
  {
    int event_type;
    int t_lexeme;
  } t_after_lexeme;

  struct
  {
    int event_type;
    int t_start_of_lexeme;
    int t_end_of_lexeme;
    int t_lexeme;
  }
  t_trace_attempting_lexeme;

  struct
  {
    int event_type;
    int t_start_of_lexeme;
    int t_end_of_lexeme;
    int t_lexeme;
  }
  t_trace_duplicate_lexeme;

  struct
  {
    int event_type;
    int t_start_of_lexeme;
    int t_end_of_lexeme;
    int t_lexeme;
  }
  t_trace_accepted_lexeme;

  struct
  {
    int event_type;
    int t_start_of_lexeme;
    int t_end_of_lexeme;
    int t_lexeme;
    int t_priority;
    int t_required_priority;
  } t_lexeme_acceptable;
  struct
  {
    int event_type;
  } t_no_acceptable_input;
  struct
  {
    int event_type;
    int t_perl_pos;
  } t_lexer_restarted_recce;
  struct
  {
    int event_type;
    int t_perl_pos;
    Marpa_Symbol_ID t_lexeme;
    Marpa_Assertion_ID t_assertion;
  } t_trace_lexeme_expected;
  struct
  {
    int event_type;
    int t_perl_pos;
    int t_yim_count;
  } t_l0_yim_threshold_exceeded;
  struct
  {
    int event_type;
    int t_perl_pos;
    int t_yim_count;
  } t_g1_yim_threshold_exceeded;

};

typedef struct
{
  Marpa_Grammar g1;
  SV *g1_sv;
  G_Wrapper *g1_wrapper;

  SV *l0_sv;
  G_Wrapper *l0_wrapper;
  Marpa_Assertion_ID *g1_lexeme_to_assertion;
  HV *per_codepoint_hash;
  IV *per_codepoint_array[128];
  int precomputed;
  struct symbol_g_properties *symbol_g_properties;
  struct l0_rule_g_properties *l0_rule_g_properties;

  int lua_ref;
  lua_State* L;

} Scanless_G;

struct v_wrapper_s;

typedef struct
{
  SV *slg_sv;
  SV *r1_sv;

  Scanless_G *slg;
  R_Wrapper *r1_wrapper;
  Marpa_Recce r1;
  G_Wrapper *g1_wrapper;
  AV *token_values;
  IV trace_lexers;
  int trace_terminals;
  STRLEN start_of_lexeme;
  STRLEN end_of_lexeme;

  /* Input position at which to start the lexer.
     -1 means no restart.
   */
  int lexer_start_pos;
  int lexer_read_result;
  int r1_earleme_complete_result;

  /* A boolean to prevent the inappropriate mixing
   * of internal and external scanning
   */
  int is_external_scanning;

  int last_perl_pos;
  int perl_pos;

  Marpa_Recce r0;
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
  Pos_Entry *pos_db;
  int pos_db_logical_size;
  int pos_db_physical_size;

  Marpa_Symbol_ID input_symbol_id;
  UV codepoint;                 /* For error returns */
  int end_pos;
  SV* input;
  int too_many_earley_items;

  /* Lua "reference" to this object */
  int lua_ref;

  /* A "weak" reference to the v_wrapper.
   * See the explanation under the v_wrapper destructor
   */
  struct v_wrapper_s* v_wrapper;

  union marpa_slr_event_s* t_lexemes;
  int t_lexeme_capacity;
  int t_lexeme_count;

  union marpa_slr_event_s* t_events;
  int t_event_capacity;
  int t_event_count;
  int t_count_of_deleted_events;

  lua_State* L;

} Scanless_R;

#undef POS_TO_OFFSET
#define POS_TO_OFFSET(slr, pos) \
  ((pos) > 0 ? (slr)->pos_db[(pos) - 1].next_offset : 0)
#undef OFFSET_IN_INPUT
#define OFFSET_IN_INPUT(slr) POS_TO_OFFSET((slr), (slr)->perl_pos)

typedef struct {
     Marpa_Bocage b;
     SV* base_sv;
     G_Wrapper* base;
} B_Wrapper;

typedef struct {
     Marpa_Order o;
     SV* base_sv;
     G_Wrapper* base;
} O_Wrapper;

typedef struct {
     Marpa_Tree t;
     SV* base_sv;
     G_Wrapper* base;
} T_Wrapper;

struct v_wrapper_s
{
  Marpa_Value v;
  SV *base_sv;
  G_Wrapper *base;
  AV *event_queue;
  AV *stack;
  IV trace_values;
  int mode;                     /* 'raw' or 'stack' */
  int result;                   /* stack location to which to write result */
  AV *constants;
  AV *rule_semantics;
  AV *token_semantics;
  AV *nulling_semantics;
  Scanless_R* slr;
};
typedef struct v_wrapper_s V_Wrapper;

typedef struct
{
  lua_State* L;
} Marpa_Lua;

