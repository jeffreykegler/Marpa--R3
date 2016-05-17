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

#include "config.h"
#include "marpa.h"
#include "marpa_codes.h"

#define PERL_NO_GET_CONTEXT
#include <EXTERN.h>
#include <perl.h>
#include <XSUB.h>
#include "ppport.h"

#undef IS_PERL_UNDEF
#define IS_PERL_UNDEF(x) (SvTYPE(x) == SVt_NULL)

#undef STRINGIFY_ARG
#undef STRINGIFY
#undef STRLOC
#define STRINGIFY_ARG(contents)       #contents
#define STRINGIFY(macro_or_string)        STRINGIFY_ARG (macro_or_string)
#define STRLOC        __FILE__ ":" STRINGIFY (__LINE__)

#undef MAX
#define MAX(a, b) ((a) > (b) ? (a) : (b))

/* utf8_to_uvchr is deprecated in 5.16, but
 * utf8_to_uvchr_buf is not available before 5.16
 * If I need to get fancier, I should look at Dumper.xs
 * in Data::Dumper
 */
#if PERL_VERSION <= 15 && ! defined(utf8_to_uvchr_buf)
#define utf8_to_uvchr_buf(s, send, p_length) (utf8_to_uvchr(s, p_length))
#endif

typedef SV* SVREF;

#undef Dim
#define Dim(x) (sizeof(x)/sizeof(*x))

typedef unsigned int Marpa_Codepoint;

extern const struct marpa_error_description_s marpa_error_description[];
extern const struct marpa_event_description_s marpa_event_description[];
extern const struct marpa_step_type_description_s
  marpa_step_type_description[];

struct marpa_slr_s;
typedef struct marpa_slr_s* Marpa_SLR;
struct marpa_slr_s {

  union marpa_slr_event_s* t_events;
  int t_event_capacity;
  int t_event_count;

  union marpa_slr_event_s* t_lexemes;
  int t_lexeme_capacity;
  int t_lexeme_count;

  int t_ref_count;
  int t_count_of_deleted_events;

};
typedef Marpa_SLR SLR;

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

static Marpa_SLR marpa__slr_new(void)
{
  SLR slr;
  Newx (slr, 1, struct marpa_slr_s);
  slr->t_ref_count = 1;

  slr->t_count_of_deleted_events = 0;
  slr->t_event_count = 0;
  slr->t_event_capacity = MAX (1024 / sizeof (union marpa_slr_event_s), 16);
  Newx (slr->t_events, slr->t_event_capacity, union marpa_slr_event_s);

  slr->t_lexeme_count = 0;
  slr->t_lexeme_capacity = MAX (1024 / sizeof (union marpa_slr_event_s), 16);
  Newx (slr->t_lexemes, slr->t_lexeme_capacity, union marpa_slr_event_s);

  return slr;
}

static void slr_free(SLR slr)
{
   Safefree(slr->t_events);
   Safefree(slr->t_lexemes);
  Safefree( slr);
}

static void
slr_unref (Marpa_SLR slr)
{
  /* MARPA_ASSERT (slr->t_ref_count > 0) */
  slr->t_ref_count--;
  if (slr->t_ref_count <= 0)
    {
      slr_free(slr);
    }
}

static void
marpa__slr_unref (Marpa_SLR slr)
{
   slr_unref(slr);
}

typedef int Marpa_Op;

struct op_data_s { const char *name; Marpa_Op op; };

#include "marpa_slifop.h"

static const char*
marpa__slif_op_name (Marpa_Op op_id)
{
  if (op_id >= (int)Dim(op_name_by_id_object)) return "unknown";
  return op_name_by_id_object[op_id];
}

static Marpa_Op
marpa__slif_op_id (const char *name)
{
  int lo = 0;
  int hi = Dim (op_by_name_object) - 1;
  while (hi >= lo)
    {
      const int trial = lo + (hi - lo) / 2;
      const char *trial_name = op_by_name_object[trial].name;
      int cmp = strcmp (name, trial_name);
      if (!cmp)
	return op_by_name_object[trial].op;
      if (cmp < 0)
	{
	  hi = trial - 1;
	}
      else
	{
	  lo = trial + 1;
	}
    }
  return -1;
}

static void marpa__slr_event_clear( Marpa_SLR slr )
{
  slr->t_event_count = 0;
  slr->t_count_of_deleted_events = 0;
}

static int marpa__slr_event_count( Marpa_SLR slr )
{
  const int event_count = slr->t_event_count;
  return event_count - slr->t_count_of_deleted_events;
}

static union marpa_slr_event_s * marpa__slr_event_push( Marpa_SLR slr )
{
  if (slr->t_event_count >= slr->t_event_capacity)
    {
      slr->t_event_capacity *= 2;
      Renew (slr->t_events, slr->t_event_capacity, union marpa_slr_event_s);
    }
  return slr->t_events + (slr->t_event_count++);
}

static void marpa__slr_lexeme_clear( Marpa_SLR slr )
{
  slr->t_lexeme_count = 0;
}

static union marpa_slr_event_s * marpa__slr_lexeme_push( Marpa_SLR slr )
{
  if (slr->t_lexeme_count >= slr->t_lexeme_capacity)
    {
      slr->t_lexeme_capacity *= 2;
      Renew (slr->t_lexemes, slr->t_lexeme_capacity, union marpa_slr_event_s);
    }
  return slr->t_lexemes + (slr->t_lexeme_count++);
}


typedef struct marpa_g Grammar;
/* The error_code member should usually be ignored in favor of
 * getting a fresh error code from Libmarpa.  Essentially it
 * acts as an optional return value for marpa_g_error()
 */
typedef struct {
     Marpa_Grammar g;
     char *message_buffer;
     int libmarpa_error_code;
     const char *libmarpa_error_string;
     unsigned int throw:1;
     unsigned int message_is_marpa_thin_error:1;
} G_Wrapper;

typedef struct marpa_r Recce;
typedef struct {
     Marpa_Recce r;
     Marpa_Symbol_ID* terminals_buffer;
     SV* base_sv;
     AV* event_queue;
     G_Wrapper* base;
     unsigned int ruby_slippers:1;
} R_Wrapper;

typedef struct {
    int next_offset; /* Offset of *NEXT* codepoint */
    int linecol;
    /* Lines are 1-based, columns are zero-based and negated.
     * In the first column (column 0), linecol is the 1-based line number.
     * In subsequent columns, linecol is -n, where n is the 0-based column
     * number.
     */
} Pos_Entry;

#undef POS_TO_OFFSET
#define POS_TO_OFFSET(slr, pos) \
  ((pos) > 0 ? (slr)->pos_db[(pos) - 1].next_offset : 0)
#undef OFFSET_IN_INPUT
#define OFFSET_IN_INPUT(slr) POS_TO_OFFSET((slr), (slr)->perl_pos)

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
} Scanless_G;

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

  /* A "Gift" because it is something that is "wrapped". */
  Marpa_SLR gift;

} Scanless_R;
#define TOKEN_VALUE_IS_UNDEF (1)
#define TOKEN_VALUE_IS_LITERAL (2)

typedef struct marpa_b Bocage;
typedef struct {
     Marpa_Bocage b;
     SV* base_sv;
     G_Wrapper* base;
} B_Wrapper;

typedef struct marpa_o Order;
typedef struct {
     Marpa_Order o;
     SV* base_sv;
     G_Wrapper* base;
} O_Wrapper;

typedef struct marpa_t Tree;
typedef struct {
     Marpa_Tree t;
     SV* base_sv;
     G_Wrapper* base;
} T_Wrapper;

typedef struct marpa_v Value;
typedef struct
{
  Marpa_Value v;
  SV *base_sv;
  G_Wrapper *base;
  AV *event_queue;
  AV *token_values;
  AV *stack;
  IV trace_values;
  int mode;                     /* 'raw' or 'stack' */
  int result;                   /* stack location to which to write result */
  AV *constants;
  AV *rule_semantics;
  AV *token_semantics;
  AV *nulling_semantics;
  Scanless_R* slr;
} V_Wrapper;

#define MARPA_XS_V_MODE_IS_INITIAL 0
#define MARPA_XS_V_MODE_IS_RAW 1
#define MARPA_XS_V_MODE_IS_STACK 2

static const char grammar_c_class_name[] = "Marpa::R3::Thin::G";
static const char recce_c_class_name[] = "Marpa::R3::Thin::R";
static const char bocage_c_class_name[] = "Marpa::R3::Thin::B";
static const char order_c_class_name[] = "Marpa::R3::Thin::O";
static const char tree_c_class_name[] = "Marpa::R3::Thin::T";
static const char value_c_class_name[] = "Marpa::R3::Thin::V";
static const char scanless_g_class_name[] = "Marpa::R3::Thin::SLG";
static const char scanless_r_class_name[] = "Marpa::R3::Thin::SLR";

static const char *
event_type_to_string (Marpa_Event_Type event_code)
{
  const char *event_name = NULL;
  if (event_code >= 0 && event_code < MARPA_ERROR_COUNT) {
      event_name = marpa_event_description[event_code].name;
  }
  return event_name;
}

static const char *
step_type_to_string (const Marpa_Step_Type step_type)
{
  const char *step_type_name = NULL;
  if (step_type >= 0 && step_type < MARPA_STEP_COUNT) {
      step_type_name = marpa_step_type_description[step_type].name;
  }
  return step_type_name;
}

/* This routine is for the handling exceptions
   from libmarpa.  It is used when in the general
   cases, for those exception which are not singled
   out for special handling by the XS logic.
   It returns a buffer which must be Safefree()'d.
*/
static char *
error_description_generate (G_Wrapper *g_wrapper)
{
  dTHX;
  const int error_code = g_wrapper->libmarpa_error_code;
  const char *error_string = g_wrapper->libmarpa_error_string;
  const char *suggested_description = NULL;
  /*
   * error_name should always be set when suggested_description is,
   * so this initialization should never be used.
   */
  const char *error_name = "not libmarpa error";
  const char *output_string;
  switch (error_code)
    {
    case MARPA_ERR_DEVELOPMENT:
      output_string = form ("(development) %s",
                              (error_string ? error_string : "(null)"));
                            goto COPY_STRING;
    case MARPA_ERR_INTERNAL:
      output_string = form ("Internal error (%s)",
                              (error_string ? error_string : "(null)"));
                            goto COPY_STRING;
    }
  if (error_code >= 0 && error_code < MARPA_ERROR_COUNT) {
      suggested_description = marpa_error_description[error_code].suggested;
      error_name = marpa_error_description[error_code].name;
  }
  if (!suggested_description)
    {
      if (error_string)
        {
          output_string = form ("libmarpa error %d %s: %s",
          error_code, error_name, error_string);
          goto COPY_STRING;
        }
      output_string = form ("libmarpa error %d %s", error_code, error_name);
          goto COPY_STRING;
    }
  if (error_string)
    {
      output_string = form ("%s%s%s", suggested_description, "; ", error_string);
          goto COPY_STRING;
    }
  output_string = suggested_description;
  COPY_STRING:
  {
      char* buffer = g_wrapper->message_buffer;
      if (buffer) Safefree(buffer);
      return g_wrapper->message_buffer = savepv(output_string);
    }
}

/* Argument must be something that can be Safefree()'d */
static const char *
set_error_from_string (G_Wrapper * g_wrapper, char *string)
{
  dTHX;
  Marpa_Grammar g = g_wrapper->g;
  char *buffer = g_wrapper->message_buffer;
  if (buffer) Safefree(buffer);
  g_wrapper->message_buffer = string;
  g_wrapper->message_is_marpa_thin_error = 1;
  marpa_g_error_clear(g);
  g_wrapper->libmarpa_error_code = MARPA_ERR_NONE;
  g_wrapper->libmarpa_error_string = NULL;
  return buffer;
}

/* Return value must be Safefree()'d */
static const char *
xs_g_error (G_Wrapper * g_wrapper)
{
  Marpa_Grammar g = g_wrapper->g;
  g_wrapper->libmarpa_error_code =
    marpa_g_error (g, &g_wrapper->libmarpa_error_string);
  g_wrapper->message_is_marpa_thin_error = 0;
  return error_description_generate (g_wrapper);
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

INCLUDE: general_pattern.xsh
