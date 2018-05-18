/*
 * Copyright 2015 Jeffrey Kegler
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
 * OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */


/*
 * DO NOT EDIT DIRECTLY
 * This file is written by the Marpa build process
 * It is not intended to be modified directly
 */

/*1453:*/
#line 17369 "./marpa.w"


#include "config.h"

#ifndef MARPA_DEBUG
#define MARPA_DEBUG 0
#endif

#include "marpa.h"
#include "marpa_ami.h"
#define PRIVATE_NOT_INLINE static
#define PRIVATE static inline \

#define HEADER_VERSION_MISMATCH ( \
MARPA_LIB_MAJOR_VERSION!=MARPA_MAJOR_VERSION \
||MARPA_LIB_MINOR_VERSION!=MARPA_MINOR_VERSION \
||MARPA_LIB_MICRO_VERSION!=MARPA_MICRO_VERSION \
) 
#define ISY_Count_of_G(g) (MARPA_DSTACK_LENGTH((g) ->t_isy_stack) ) 
#define ISY_by_ID(id) (*MARPA_DSTACK_INDEX(g->t_isy_stack,ISY,(id) ) )  \

#define ISYID_is_Malformed(isy_id) ((isy_id) <0) 
#define ISYID_of_G_Exists(isy_id) ((isy_id) <ISY_Count_of_G(g) ) 
#define NSYID_is_Malformed(nsy_id) ((nsy_id) <0) 
#define NSYID_of_G_Exists(nsy_id) ((nsy_id) <NSY_Count_of_G(g) ) 
#define IRL_Count_of_G(g) (MARPA_DSTACK_LENGTH((g) ->t_irl_stack) ) 
#define NRL_Count_of_G(g) (MARPA_DSTACK_LENGTH((g) ->t_nrl_stack) ) 
#define IRL_by_ID(id) (*MARPA_DSTACK_INDEX((g) ->t_irl_stack,IRL,(id) ) ) 
#define NRL_by_ID(id) (*MARPA_DSTACK_INDEX((g) ->t_nrl_stack,NRL,(id) ) )  \

#define IRLID_is_Malformed(rule_id) ((rule_id) <0) 
#define IRLID_of_G_Exists(rule_id) ((rule_id) <IRL_Count_of_G(g) ) 
#define NRLID_of_G_is_Valid(nrl_id)  \
((nrl_id) >=0&&(nrl_id) <NRL_Count_of_G(g) )  \

#define G_is_Trivial(g) (!(g) ->t_start_nrl) 
#define External_Size_of_G(g) ((g) ->t_external_size) 
#define MAXIMUM_RANK (INT_MAX/4) 
#define MINIMUM_RANK (INT_MIN/4+(INT_MIN%4> 0?1:0) ) 
#define Default_Rank_of_G(g) ((g) ->t_default_rank) 
#define G_is_Precomputed(g) ((g) ->t_is_precomputed) 
#define G_EVENT_COUNT(g) MARPA_DSTACK_LENGTH((g) ->t_events) 
#define INITIAL_G_EVENTS_CAPACITY (1024/sizeof(int) ) 
#define G_EVENTS_CLEAR(g) MARPA_DSTACK_CLEAR((g) ->t_events) 
#define G_EVENT_PUSH(g) MARPA_DSTACK_PUSH((g) ->t_events,GEV_Object) 
#define I_AM_OK 0x69734f4b
#define IS_G_OK(g) ((g) ->t_is_ok==I_AM_OK) 
#define ID_of_ISY(isy) ((isy) ->t_symbol_id) 
#define Rank_of_ISY(symbol) ((symbol) ->t_rank) 
#define ISY_is_LHS(isy) ((isy) ->t_is_lhs) 
#define ISY_is_Sequence_LHS(isy) ((isy) ->t_is_sequence_lhs) 
#define ISY_is_Valued(symbol) ((symbol) ->t_is_valued) 
#define ISY_is_Valued_Locked(symbol) ((symbol) ->t_is_valued_locked) 
#define ISY_is_Accessible(isy) ((isy) ->t_is_accessible) 
#define ISY_is_Nulling(sym) ((sym) ->t_is_nulling) 
#define ISY_is_Nullable(isy) ((isy) ->t_is_nullable) 
#define ISYID_is_Nullable(isyid) ISY_is_Nullable(ISY_by_ID(isyid) ) 
#define ISY_is_Terminal(isy) ((isy) ->t_is_terminal) 
#define ISY_is_Locked_Terminal(isy) ((isy) ->t_is_locked_terminal) 
#define ISYID_is_Terminal(id) (ISY_is_Terminal(ISY_by_ID(id) ) ) 
#define ISY_is_Productive(isy) ((isy) ->t_is_productive) 
#define ISY_is_Completion_Event(isy) ((isy) ->t_is_completion_event) 
#define ISYID_is_Completion_Event(isyid) ISY_is_Completion_Event(ISY_by_ID(isyid) ) 
#define ISY_Completion_Event_Starts_Active(isy) ((isy) ->t_completion_event_starts_active) 
#define ISYID_Completion_Event_Starts_Active(isyid) ISY_Completion_Event_Starts_Active(ISY_by_ID(isyid) ) 
#define ISY_is_Nulled_Event(isy) ((isy) ->t_is_nulled_event) 
#define ISYID_is_Nulled_Event(isyid) ISY_is_Nulled_Event(ISY_by_ID(isyid) ) 
#define ISY_Nulled_Event_Starts_Active(isy) ((isy) ->t_nulled_event_starts_active) 
#define ISYID_Nulled_Event_Starts_Active(isyid) ISY_Nulled_Event_Starts_Active(ISY_by_ID(isyid) ) 
#define ISY_is_Prediction_Event(isy) ((isy) ->t_is_prediction_event) 
#define ISYID_is_Prediction_Event(isyid) ISY_is_Prediction_Event(ISY_by_ID(isyid) ) 
#define ISY_Prediction_Event_Starts_Active(isy) ((isy) ->t_prediction_event_starts_active) 
#define ISYID_Prediction_Event_Starts_Active(isyid) ISY_Prediction_Event_Starts_Active(ISY_by_ID(isyid) ) 
#define Nulled_ISYIDs_of_ISY(isy) ((isy) ->t_nulled_event_isyids) 
#define Nulled_ISYIDs_of_ISYID(isyid)  \
Nulled_ISYIDs_of_ISY(ISY_by_ID(isyid) ) 
#define NSY_of_ISY(isy) ((isy) ->t_nsy_equivalent) 
#define NSYID_of_ISY(isy) ID_of_NSY(NSY_of_ISY(isy) ) 
#define NSY_by_ISYID(isy_id) (ISY_by_ID(isy_id) ->t_nsy_equivalent) 
#define NSYID_by_ISYID(isy_id) ID_of_NSY(NSY_of_ISY(ISY_by_ID(isy_id) ) ) 
#define Nulling_NSY_of_ISY(isy) ((isy) ->t_nulling_nsy) 
#define Nulling_NSY_by_ISYID(isy) (ISY_by_ID(isy) ->t_nulling_nsy) 
#define Nulling_NSYID_by_ISYID(isy) ID_of_NSY(ISY_by_ID(isy) ->t_nulling_nsy) 
#define Nulling_OR_by_NSYID(nsyid) ((OR) &NSY_by_ID(nsyid) ->t_nulling_or_node) 
#define Unvalued_OR_by_NSYID(nsyid) ((OR) &NSY_by_ID(nsyid) ->t_unvalued_or_node) 
#define NSY_by_ID(id) (*MARPA_DSTACK_INDEX(g->t_nsy_stack,NSY,(id) ) ) 
#define ID_of_NSY(nsy) ((nsy) ->t_nulling_or_node.t_nsyid)  \

#define NSY_Count_of_G(g) (MARPA_DSTACK_LENGTH((g) ->t_nsy_stack) ) 
#define NSY_is_Start(nsy) ((nsy) ->t_is_start) 
#define NSY_is_LHS(nsy) ((nsy) ->t_is_lhs) 
#define NSY_is_Nulling(nsy) ((nsy) ->t_nsy_is_nulling) 
#define LHS_CIL_of_NSY(nsy) ((nsy) ->t_lhs_cil) 
#define LHS_CIL_of_NSYID(nsyid) LHS_CIL_of_NSY(NSY_by_ID(nsyid) ) 
#define NSY_is_Semantic(nsy) ((nsy) ->t_is_semantic) 
#define NSYID_is_Semantic(nsyid) (NSY_is_Semantic(NSY_by_ID(nsyid) ) ) 
#define Source_ISY_of_NSY(nsy) ((nsy) ->t_source_isy) 
#define Source_ISY_of_NSYID(nsyid) (Source_ISY_of_NSY(NSY_by_ID(nsyid) ) ) 
#define Source_ISYID_of_NSYID(nsyid)  \
ID_of_ISY(Source_ISY_of_NSYID(nsyid) ) 
#define LHS_IRL_of_NSY(nsy) ((nsy) ->t_lhs_irl) 
#define IRL_Offset_of_NSY(nsy) ((nsy) ->t_irl_offset) 
#define NSY_Rank_by_ISY(isy)  \
((isy) ->t_rank*EXTERNAL_RANK_FACTOR+MAXIMUM_CHAF_RANK) 
#define Rank_of_NSY(nsy) ((nsy) ->t_rank) 
#define MAX_RHS_LENGTH (INT_MAX>>(2) ) 
#define Length_of_IRL(xrl) ((xrl) ->t_rhs_length) 
#define LHS_ID_of_RULE(rule) ((rule) ->t_symbols[0]) 
#define LHS_ID_of_IRL(xrl) ((xrl) ->t_symbols[0]) 
#define RHS_ID_of_RULE(rule,position)  \
((rule) ->t_symbols[(position) +1]) 
#define RHS_ID_of_IRL(xrl,position)  \
((xrl) ->t_symbols[(position) +1])  \

#define ID_of_IRL(xrl) ((xrl) ->t_id) 
#define ID_of_RULE(rule) ID_of_IRL(rule) 
#define Rank_of_IRL(rule) ((rule) ->t_rank) 
#define Null_Ranks_High_of_RULE(rule) ((rule) ->t_null_ranks_high) 
#define IRL_is_BNF(rule) ((rule) ->t_is_bnf) 
#define IRL_is_Sequence(rule) ((rule) ->t_is_sequence) 
#define Minimum_of_IRL(rule) ((rule) ->t_minimum) 
#define Separator_of_IRL(rule) ((rule) ->t_separator_id) 
#define IRL_is_Proper_Separation(rule) ((rule) ->t_is_proper_separation) 
#define IRL_is_Nulling(rule) ((rule) ->t_is_nulling) 
#define IRL_is_Nullable(rule) ((rule) ->t_is_nullable) 
#define IRL_is_Accessible(rule) ((rule) ->t_is_accessible) 
#define IRL_is_Productive(rule) ((rule) ->t_is_productive) 
#define IRL_is_Used(rule) ((rule) ->t_is_used) 
#define ID_of_NRL(nrl) ((nrl) ->t_nrl_id) 
#define LHSID_of_NRL(nrlid) ((nrlid) ->t_nsyid_array[0]) 
#define LHS_of_NRL(nrl) (NSY_by_ID(LHSID_of_NRL(nrl) ) )  \

#define RHSID_of_NRL(nrl,position) ((nrl) ->t_nsyid_array[(position) +1]) 
#define RHS_of_NRL(nrl,position) NSY_by_ID(RHSID_of_NRL((nrl) ,(position) ) ) 
#define Length_of_NRL(nrl) ((nrl) ->t_length) 
#define NRL_is_Unit_Rule(nrl) ((nrl) ->t_ahm_count==2) 
#define AHM_Count_of_NRL(nrl) ((nrl) ->t_ahm_count) 
#define NRL_has_Virtual_LHS(nrl) ((nrl) ->t_is_virtual_lhs) 
#define NRL_has_Virtual_RHS(nrl) ((nrl) ->t_is_virtual_rhs) 
#define NRL_is_Right_Recursive(nrl) ((nrl) ->t_is_right_recursive) 
#define NRL_is_Leo(nrl) NRL_is_Right_Recursive(nrl) 
#define Real_SYM_Count_of_NRL(nrl) ((nrl) ->t_real_symbol_count) 
#define Virtual_Start_of_NRL(nrl) ((nrl) ->t_virtual_start) 
#define Virtual_End_of_NRL(nrl) ((nrl) ->t_virtual_end) 
#define Source_IRL_of_NRL(nrl) ((nrl) ->t_source_irl) 
#define EXTERNAL_RANK_FACTOR 4
#define MAXIMUM_CHAF_RANK 3
#define NRL_CHAF_Rank_by_IRL(xrl,chaf_rank) ( \
((xrl) ->t_rank*EXTERNAL_RANK_FACTOR) + \
(((xrl) ->t_null_ranks_high) ?(MAXIMUM_CHAF_RANK- \
(chaf_rank) ) :(chaf_rank) )  \
) 
#define NRL_Rank_by_IRL(xrl) NRL_CHAF_Rank_by_IRL((xrl) ,MAXIMUM_CHAF_RANK) 
#define Rank_of_NRL(nrl) ((nrl) ->t_rank) 
#define First_AHM_of_NRL(nrl) ((nrl) ->t_first_ahm) 
#define First_AHM_of_NRLID(nrlid) (NRL_by_ID(nrlid) ->t_first_ahm) 
#define NRL_is_CHAF(nrl) ((nrl) ->t_is_chaf) 
#define AHM_by_ID(id) (g->t_ahms+(id) ) 
#define ID_of_AHM(ahm) (AHMID) ((ahm) -g->t_ahms) 
#define Next_AHM_of_AHM(ahm) ((ahm) +1) 
#define Prev_AHM_of_AHM(ahm) ((ahm) -1)  \

#define AHM_Count_of_G(g) ((g) ->t_ahm_count) 
#define NRL_of_AHM(ahm) ((ahm) ->t_nrl) 
#define NRLID_of_AHM(item) ID_of_NRL(NRL_of_AHM(item) ) 
#define LHS_NSYID_of_AHM(item) LHSID_of_NRL(NRL_of_AHM(item) ) 
#define LHSID_of_AHM(item) LHS_NSYID_of_AHM(item) 
#define Postdot_NSYID_of_AHM(item) ((item) ->t_postdot_nsyid) 
#define AHM_is_Completion(ahm) (Postdot_NSYID_of_AHM(ahm) <0) 
#define AHM_is_Leo(ahm) (NRL_is_Leo(NRL_of_AHM(ahm) ) ) 
#define AHM_is_Leo_Completion(ahm)  \
(AHM_is_Completion(ahm) &&AHM_is_Leo(ahm) ) 
#define Null_Count_of_AHM(ahm) ((ahm) ->t_leading_nulls) 
#define Position_of_AHM(ahm) ((ahm) ->t_position) 
#define Raw_Position_of_AHM(ahm)  \
(Position_of_AHM(ahm) <0 \
?((Length_of_NRL(NRL_of_AHM(ahm) ) ) +Position_of_AHM(ahm) +1)  \
:Position_of_AHM(ahm) ) 
#define AHM_is_Prediction(ahm) (Quasi_Position_of_AHM(ahm) ==0)  \

#define Quasi_Position_of_AHM(ahm) ((ahm) ->t_quasi_position) 
#define SYMI_of_AHM(ahm) ((ahm) ->t_symbol_instance) 
#define SYMI_Count_of_G(g) ((g) ->t_symbol_instance_count) 
#define SYMI_of_NRL(nrl) ((nrl) ->t_symbol_instance_base) 
#define Last_Proper_SYMI_of_NRL(nrl) ((nrl) ->t_last_proper_symi) 
#define SYMI_of_Completed_NRL(nrl)  \
(SYMI_of_NRL(nrl) +Length_of_NRL(nrl) -1) 
#define Predicted_NRL_CIL_of_AHM(ahm) ((ahm) ->t_predicted_nrl_cil) 
#define LHS_CIL_of_AHM(ahm) ((ahm) ->t_lhs_cil) 
#define ZWA_CIL_of_AHM(ahm) ((ahm) ->t_zwa_cil) 
#define AHM_predicts_ZWA(ahm) ((ahm) ->t_predicts_zwa) 
#define Completion_ISYIDs_of_AHM(ahm) ((ahm) ->t_completion_isyids) 
#define Nulled_ISYIDs_of_AHM(ahm) ((ahm) ->t_nulled_isyids) 
#define Prediction_ISYIDs_of_AHM(ahm) ((ahm) ->t_prediction_isyids) 
#define AHM_was_Predicted(ahm) ((ahm) ->t_was_predicted) 
#define YIM_was_Predicted(yim) AHM_was_Predicted(AHM_of_YIM(yim) ) 
#define AHM_is_Initial(ahm) ((ahm) ->t_is_initial) 
#define YIM_is_Initial(yim) AHM_is_Initial(AHM_of_YIM(yim) ) 
#define IRL_of_AHM(ahm) ((ahm) ->t_irl) 
#define IRL_Position_of_AHM(ahm) ((ahm) ->t_irl_position) 
#define Raw_IRL_Position_of_AHM(ahm) ( \
IRL_Position_of_AHM(ahm) <0 \
?Length_of_IRL(IRL_of_AHM(ahm) )  \
:IRL_Position_of_AHM(ahm)  \
) 
#define Event_Group_Size_of_AHM(ahm) ((ahm) ->t_event_group_size) 
#define Event_AHMIDs_of_AHM(ahm) ((ahm) ->t_event_ahmids) 
#define AHM_has_Event(ahm) (Count_of_CIL(Event_AHMIDs_of_AHM(ahm) ) !=0) 
#define ZWAID_is_Malformed(zwaid) ((zwaid) <0) 
#define ZWAID_of_G_Exists(zwaid) ((zwaid) <ZWA_Count_of_G(g) ) 
#define ZWA_Count_of_G(g) (MARPA_DSTACK_LENGTH((g) ->t_gzwa_stack) ) 
#define GZWA_by_ID(id) (*MARPA_DSTACK_INDEX((g) ->t_gzwa_stack,GZWA,(id) ) ) 
#define ID_of_GZWA(zwa) ((zwa) ->t_id) 
#define Default_Value_of_GZWA(zwa) ((zwa) ->t_default_value) 
#define IRLID_of_ZWP(zwp) ((zwp) ->t_irl_id) 
#define Dot_of_ZWP(zwp) ((zwp) ->t_dot) 
#define ZWAID_of_ZWP(zwp) ((zwp) ->t_zwaid) 
#define G_of_R(r) ((r) ->t_grammar) 
#define R_BEFORE_INPUT 0x1
#define R_DURING_INPUT 0x2
#define R_AFTER_INPUT 0x3
#define Input_Phase_of_R(r) ((r) ->t_input_phase) 
#define First_YS_of_R(r) ((r) ->t_first_earley_set) 
#define Latest_YS_of_R(r) ((r) ->t_latest_earley_set) 
#define Current_Earleme_of_R(r) ((r) ->t_current_earleme) 
#define YS_at_Current_Earleme_of_R(r) ys_at_current_earleme(r) 
#define DEFAULT_YIM_WARNING_THRESHOLD (100) 
#define Furthest_Earleme_of_R(r) ((r) ->t_furthest_earleme) 
#define R_is_Exhausted(r) ((r) ->t_is_exhausted) 
#define First_Inconsistent_YS_of_R(r) ((r) ->t_first_inconsistent_ys) 
#define R_is_Consistent(r) ((r) ->t_first_inconsistent_ys<0) 
#define ID_of_ZWA(zwa) ((zwa) ->t_id) 
#define Memo_YSID_of_ZWA(zwa) ((zwa) ->t_memoized_ysid) 
#define Memo_Value_of_ZWA(zwa) ((zwa) ->t_memoized_value) 
#define Default_Value_of_ZWA(zwa) ((zwa) ->t_default_value) 
#define ZWA_Count_of_R(r) (ZWA_Count_of_G(G_of_R(r) ) ) 
#define RZWA_by_ID(id) (&(r) ->t_zwas[(zwaid) ]) 
#define JEARLEME_THRESHOLD (INT_MAX/4) 
#define Next_YS_of_YS(set) ((set) ->t_next_earley_set) 
#define Postdot_SYM_Count_of_YS(set) ((set) ->t_postdot_sym_count) 
#define First_PIM_of_YS_by_NSYID(set,nsyid) (first_pim_of_ys_by_nsyid((set) ,(nsyid) ) ) 
#define PIM_NSY_P_of_YS_by_NSYID(set,nsyid) (pim_nsy_p_find((set) ,(nsyid) ) ) 
#define YIM_Count_of_YS(set) ((set) ->t_yim_count) 
#define YIMs_of_YS(set) ((set) ->t_earley_items) 
#define YS_Count_of_R(r) ((r) ->t_earley_set_count) 
#define Ord_of_YS(set) ((set) ->t_ordinal) 
#define YS_Ord_is_Valid(r,ordinal)  \
((ordinal) >=0&&(ordinal) <YS_Count_of_R(r) ) 
#define Earleme_of_YS(set) ((set) ->t_key.t_earleme)  \

#define Value_of_YS(set) ((set) ->t_value) 
#define PValue_of_YS(set) ((set) ->t_pvalue) 
#define LHS_NSYID_of_YIM(yim)  \
LHS_NSYID_of_AHM(AHM_of_YIM(yim) ) 
#define YIM_is_Completion(item)  \
(AHM_is_Completion(AHM_of_YIM(item) ) ) 
#define YS_of_YIM(yim) ((yim) ->t_key.t_set) 
#define YS_Ord_of_YIM(yim) (Ord_of_YS(YS_of_YIM(yim) ) ) 
#define Ord_of_YIM(yim) ((yim) ->t_ordinal) 
#define Earleme_of_YIM(yim) Earleme_of_YS(YS_of_YIM(yim) ) 
#define AHM_of_YIM(yim) ((yim) ->t_key.t_ahm) 
#define AHMID_of_YIM(yim) ID_of_AHM(AHM_of_YIM(yim) ) 
#define Postdot_NSYID_of_YIM(yim) Postdot_NSYID_of_AHM(AHM_of_YIM(yim) ) 
#define NRL_of_YIM(yim) NRL_of_AHM(AHM_of_YIM(yim) ) 
#define NRLID_of_YIM(yim) ID_of_NRL(NRL_of_YIM(yim) ) 
#define IRL_of_YIM(yim) IRL_of_AHM(AHM_of_YIM(yim) ) 
#define Origin_Earleme_of_YIM(yim) (Earleme_of_YS(Origin_of_YIM(yim) ) ) 
#define Origin_Ord_of_YIM(yim) (Ord_of_YS(Origin_of_YIM(yim) ) ) 
#define Origin_of_YIM(yim) ((yim) ->t_key.t_origin) 
#define YIM_ORDINAL_WIDTH 16
#define YIM_ORDINAL_CLAMP(x) (((1<<(YIM_ORDINAL_WIDTH) ) -1) &(x) ) 
#define YIM_FATAL_THRESHOLD ((1<<(YIM_ORDINAL_WIDTH) ) -2) 
#define YIM_is_Rejected(yim) ((yim) ->t_is_rejected) 
#define YIM_is_Active(yim) ((yim) ->t_is_active) 
#define YIM_was_Scanned(yim) ((yim) ->t_was_scanned) 
#define YIM_was_Fusion(yim) ((yim) ->t_was_fusion) 
#define NO_SOURCE (0U) 
#define SOURCE_IS_TOKEN (1U) 
#define SOURCE_IS_COMPLETION (2U) 
#define SOURCE_IS_LEO (3U) 
#define SOURCE_IS_AMBIGUOUS (4U) 
#define Source_Type_of_YIM(item) ((item) ->t_source_type) 
#define Earley_Item_has_No_Source(item) ((item) ->t_source_type==NO_SOURCE) 
#define Earley_Item_has_Token_Source(item) ((item) ->t_source_type==SOURCE_IS_TOKEN) 
#define Earley_Item_has_Complete_Source(item) ((item) ->t_source_type==SOURCE_IS_COMPLETION) 
#define Earley_Item_has_Leo_Source(item) ((item) ->t_source_type==SOURCE_IS_LEO) 
#define Earley_Item_is_Ambiguous(item) ((item) ->t_source_type==SOURCE_IS_AMBIGUOUS)  \

#define Next_PIM_of_YIX(yix) ((yix) ->t_next) 
#define YIM_of_YIX(yix) ((yix) ->t_earley_item) 
#define Postdot_NSYID_of_YIX(yix) ((yix) ->t_postdot_nsyid) 
#define YIX_of_LIM(lim) ((YIX) (lim) ) 
#define Postdot_NSYID_of_LIM(leo) (Postdot_NSYID_of_YIX(YIX_of_LIM(leo) ) ) 
#define Next_PIM_of_LIM(leo) (Next_PIM_of_YIX(YIX_of_LIM(leo) ) ) 
#define Origin_of_LIM(leo) ((leo) ->t_origin) 
#define Top_AHM_of_LIM(leo) ((leo) ->t_top_ahm) 
#define Trailhead_AHM_of_LIM(leo) ((leo) ->t_trailhead_ahm) 
#define Predecessor_LIM_of_LIM(leo) ((leo) ->t_predecessor) 
#define Trailhead_YIM_of_LIM(leo) ((leo) ->t_base) 
#define YS_of_LIM(leo) ((leo) ->t_set) 
#define Earleme_of_LIM(lim) Earleme_of_YS(YS_of_LIM(lim) ) 
#define LIM_is_Rejected(lim) ((lim) ->t_is_rejected) 
#define LIM_is_Active(lim) ((lim) ->t_is_active) 
#define CIL_of_LIM(lim) ((lim) ->t_cil) 
#define LIM_of_PIM(pim) ((LIM) (pim) ) 
#define YIX_of_PIM(pim) ((YIX) (pim) ) 
#define Postdot_NSYID_of_PIM(pim) (Postdot_NSYID_of_YIX(YIX_of_PIM(pim) ) ) 
#define YIM_of_PIM(pim) (YIM_of_YIX(YIX_of_PIM(pim) ) ) 
#define Next_PIM_of_PIM(pim) (Next_PIM_of_YIX(YIX_of_PIM(pim) ) )  \

#define PIM_of_LIM(pim) ((PIM) (pim) ) 
#define PIM_is_LIM(pim) (YIM_of_PIM(pim) ==NULL) 
#define Next_SRCL_of_SRCL(link) ((link) ->t_next) 
#define Source_of_SRCL(link) ((link) ->t_source) 
#define SRC_of_SRCL(link) (&Source_of_SRCL(link) ) 
#define SRCL_of_YIM(yim) (&(yim) ->t_container.t_unique) 
#define Source_of_YIM(yim) ((yim) ->t_container.t_unique.t_source) 
#define SRC_of_YIM(yim) (&Source_of_YIM(yim) ) 
#define Predecessor_of_Source(srcd) ((srcd) .t_predecessor) 
#define Predecessor_of_SRC(source) Predecessor_of_Source(*(source) ) 
#define Predecessor_of_YIM(item) Predecessor_of_Source(Source_of_YIM(item) ) 
#define Predecessor_of_SRCL(link) Predecessor_of_Source(Source_of_SRCL(link) ) 
#define LIM_of_SRCL(link) ((LIM) Predecessor_of_SRCL(link) ) 
#define Cause_of_Source(srcd) ((srcd) .t_cause.t_completion) 
#define Cause_of_SRC(source) Cause_of_Source(*(source) ) 
#define Cause_of_YIM(item) Cause_of_Source(Source_of_YIM(item) ) 
#define Cause_of_SRCL(link) Cause_of_Source(Source_of_SRCL(link) ) 
#define TOK_of_Source(srcd) ((srcd) .t_cause.t_token) 
#define TOK_of_SRC(source) TOK_of_Source(*(source) ) 
#define TOK_of_YIM(yim) TOK_of_Source(Source_of_YIM(yim) ) 
#define TOK_of_SRCL(link) TOK_of_Source(Source_of_SRCL(link) ) 
#define NSYID_of_Source(srcd) ((srcd) .t_cause.t_token.t_nsyid) 
#define NSYID_of_SRC(source) NSYID_of_Source(*(source) ) 
#define NSYID_of_YIM(yim) NSYID_of_Source(Source_of_YIM(yim) ) 
#define NSYID_of_SRCL(link) NSYID_of_Source(Source_of_SRCL(link) ) 
#define Value_of_Source(srcd) ((srcd) .t_cause.t_token.t_value) 
#define Value_of_SRC(source) Value_of_Source(*(source) ) 
#define Value_of_SRCL(link) Value_of_Source(Source_of_SRCL(link) )  \

#define SRC_is_Active(src) ((src) ->t_is_active) 
#define SRC_is_Rejected(src) ((src) ->t_is_rejected) 
#define SRCL_is_Active(link) ((link) ->t_source.t_is_active) 
#define SRCL_is_Rejected(link) ((link) ->t_source.t_is_rejected)  \

#define Cause_AHMID_of_SRCL(srcl)  \
AHMID_of_YIM((YIM) Cause_of_SRCL(srcl) ) 
#define Leo_Transition_NSYID_of_SRCL(leo_source_link)  \
Postdot_NSYID_of_LIM(LIM_of_SRCL(leo_source_link) )  \

#define LV_First_Completion_SRCL_of_YIM(item) ((item) ->t_container.t_ambiguous.t_completion) 
#define First_Completion_SRCL_of_YIM(item)  \
(Source_Type_of_YIM(item) ==SOURCE_IS_COMPLETION?(SRCL) SRCL_of_YIM(item) : \
Source_Type_of_YIM(item) ==SOURCE_IS_AMBIGUOUS? \
LV_First_Completion_SRCL_of_YIM(item) :NULL)  \

#define LV_First_Token_SRCL_of_YIM(item) ((item) ->t_container.t_ambiguous.t_token) 
#define First_Token_SRCL_of_YIM(item)  \
(Source_Type_of_YIM(item) ==SOURCE_IS_TOKEN?(SRCL) SRCL_of_YIM(item) : \
Source_Type_of_YIM(item) ==SOURCE_IS_AMBIGUOUS? \
LV_First_Token_SRCL_of_YIM(item) :NULL)  \

#define LV_First_Leo_SRCL_of_YIM(item) ((item) ->t_container.t_ambiguous.t_leo) 
#define First_Leo_SRCL_of_YIM(item)  \
(Source_Type_of_YIM(item) ==SOURCE_IS_LEO?(SRCL) SRCL_of_YIM(item) : \
Source_Type_of_YIM(item) ==SOURCE_IS_AMBIGUOUS? \
LV_First_Leo_SRCL_of_YIM(item) :NULL)  \

#define NSYID_of_ALT(alt) ((alt) ->t_nsyid) 
#define Value_of_ALT(alt) ((alt) ->t_value) 
#define ALT_is_Valued(alt) ((alt) ->t_is_valued) 
#define Start_YS_of_ALT(alt) ((alt) ->t_start_earley_set) 
#define Start_Earleme_of_ALT(alt) Earleme_of_YS(Start_YS_of_ALT(alt) ) 
#define End_Earleme_of_ALT(alt) ((alt) ->t_end_earleme) 
#define Work_YIMs_of_R(r) MARPA_DSTACK_BASE((r) ->t_yim_work_stack,YIM) 
#define Work_YIM_Count_of_R(r) MARPA_DSTACK_LENGTH((r) ->t_yim_work_stack) 
#define WORK_YIMS_CLEAR(r) MARPA_DSTACK_CLEAR((r) ->t_yim_work_stack) 
#define WORK_YIM_PUSH(r) MARPA_DSTACK_PUSH((r) ->t_yim_work_stack,YIM) 
#define WORK_YIM_ITEM(r,ix) (*MARPA_DSTACK_INDEX((r) ->t_yim_work_stack,YIM,ix) ) 
#define P_YS_of_R_by_Ord(r,ord) MARPA_DSTACK_INDEX((r) ->t_earley_set_stack,YS,(ord) ) 
#define YS_of_R_by_Ord(r,ord) (*P_YS_of_R_by_Ord((r) ,(ord) ) ) 
#define LIM_is_Populated(leo) (Origin_of_LIM(leo) !=NULL) 
#define RULEID_of_PROGRESS(report) ((report) ->t_rule_id) 
#define Position_of_PROGRESS(report) ((report) ->t_position) 
#define Origin_of_PROGRESS(report) ((report) ->t_origin)  \

#define Prev_UR_of_UR(ur) ((ur) ->t_prev) 
#define Next_UR_of_UR(ur) ((ur) ->t_next) 
#define YIM_of_UR(ur) ((ur) ->t_earley_item)  \

#define URS_of_R(r) (&(r) ->t_ur_node_stack) 
#define DUMMY_OR_NODE -1
#define MAX_TOKEN_OR_NODE -2
#define VALUED_TOKEN_OR_NODE -2
#define NULLING_TOKEN_OR_NODE -3
#define UNVALUED_TOKEN_OR_NODE -4
#define OR_is_Token(or) (Type_of_OR(or) <=MAX_TOKEN_OR_NODE) 
#define Position_of_OR(or) ((or) ->t_final.t_position) 
#define Type_of_OR(or) ((or) ->t_final.t_position) 
#define NRL_of_OR(or) ((or) ->t_final.t_nrl) 
#define NRLID_of_OR(or) ID_of_NRL(NRL_of_OR(or) ) 
#define Origin_Ord_of_OR(or) ((or) ->t_final.t_start_set_ordinal) 
#define ID_of_OR(or) ((or) ->t_final.t_id) 
#define YS_Ord_of_OR(or) ((or) ->t_draft.t_end_set_ordinal) 
#define DANDs_of_OR(or) ((or) ->t_draft.t_draft_and_node) 
#define First_ANDID_of_OR(or) ((or) ->t_final.t_first_and_node_id) 
#define AND_Count_of_OR(or) ((or) ->t_final.t_and_node_count) 
#define NSYID_of_OR(or) ((or) ->t_token.t_nsyid) 
#define Value_of_OR(or) ((or) ->t_token.t_value) 
#define WHEID_of_NSYID(nsyid) (nrl_count+(nsyid) ) 
#define WHEID_of_NRLID(nrlid) (nrlid) 
#define WHEID_of_NRL(nrl) WHEID_of_NRLID(ID_of_NRL(nrl) ) 
#define WHEID_of_OR(or) ( \
wheid= OR_is_Token(or) ? \
WHEID_of_NSYID(NSYID_of_OR(or) ) : \
WHEID_of_NRL(NRL_of_OR(or) )  \
)  \

#define Next_DAND_of_DAND(dand) ((dand) ->t_next) 
#define Predecessor_OR_of_DAND(dand) ((dand) ->t_predecessor) 
#define Cause_OR_of_DAND(dand) ((dand) ->t_cause) 
#define OR_of_AND(and) ((and) ->t_current) 
#define Predecessor_OR_of_AND(and) ((and) ->t_predecessor) 
#define Cause_OR_of_AND(and) ((and) ->t_cause) 
#define YIM_of_TRV(trv) ((trv) ->t_trv_yim) 
#define YS_of_TRV(trv) (YS_of_YIM(YIM_of_TRV(trv) ) 
#define LEO_SRCL_of_TRV(trv) ((trv) ->t_trv_completion_srcl) 
#define TOKEN_SRCL_of_TRV(trv) ((trv) ->t_trv_token_srcl) 
#define COMPLETION_SRCL_of_TRV(trv) ((trv) ->t_trv_leo_srcl)  \

#define TRV_has_Soft_Error(trv) ((trv) ->t_trv_soft_error) 
#define R_of_TRV(trv) ((trv) ->t_trv_recce) 
#define TRV_is_Trivial(trv) ((trv) ->t_is_trivial) 
#define LIM_of_LTRV(ltrv) ((ltrv) ->t_ltrv_lim) 
#define YS_of_LTRV(ltrv) (YS_of_YIM(LIM_of_LTRV(ltrv) )  \

#define LTRV_has_Soft_Error(ltrv) ((ltrv) ->t_ltrv_soft_error) 
#define R_of_LTRV(ltrv) ((ltrv) ->t_ltrv_recce) 
#define PIM_of_PTRV(ptrv) ((ptrv) ->t_ptrv_pim) 
#define YS_of_PTRV(ptrv) ((ptrv) ->t_ptrv_ys)  \

#define PTRV_has_Soft_Error(ptrv) ((ptrv) ->t_ptrv_soft_error) 
#define R_of_PTRV(ptrv) ((ptrv) ->t_ptrv_recce) 
#define PTRV_is_Trivial(ptrv) ((ptrv) ->t_is_trivial) 
#define ORs_of_B(b) ((b) ->t_or_nodes) 
#define OR_of_B_by_ID(b,id) (ORs_of_B(b) [(id) ]) 
#define OR_Count_of_B(b) ((b) ->t_or_node_count) 
#define OR_Capacity_of_B(b) ((b) ->t_or_node_capacity) 
#define ANDs_of_B(b) ((b) ->t_and_nodes) 
#define AND_Count_of_B(b) ((b) ->t_and_node_count) 
#define Top_ORID_of_B(b) ((b) ->t_top_or_node_id) 
#define G_of_B(b) ((b) ->t_grammar) 
#define OBS_of_B(b) ((b) ->t_obs) 
#define Valued_BV_of_B(b) ((b) ->t_valued_bv) 
#define Valued_Locked_BV_of_B(b) ((b) ->t_valued_locked_bv) 
#define ISYID_is_Valued_in_B(b,isyid)  \
(lbv_bit_test(Valued_BV_of_B(b) ,(isyid) ) ) 
#define NSYID_is_Valued_in_B(b,nsyid)  \
ISYID_is_Valued_in_B((b) ,Source_ISYID_of_NSYID(nsyid) ) 
#define OR_by_PSI(psi_data,set_ordinal,item_ordinal)  \
(((psi_data) [(set_ordinal) ].t_or_node_by_item) [(item_ordinal) ]) 
#define Ambiguity_Metric_of_B(b) ((b) ->t_ambiguity_metric) 
#define B_is_Nulling(b) ((b) ->t_is_nulling) 
#define OBS_of_O(order) ((order) ->t_ordering_obs) 
#define O_is_Default(order) (!OBS_of_O(order) ) 
#define O_is_Frozen(o) ((o) ->t_is_frozen) 
#define B_of_O(b) ((b) ->t_bocage) 
#define Ambiguity_Metric_of_O(o) ((o) ->t_ambiguity_metric) 
#define O_is_Nulling(o) ((o) ->t_is_nulling) 
#define High_Rank_Count_of_O(order) ((order) ->t_high_rank_count) 
#define Size_of_TREE(tree) FSTACK_LENGTH((tree) ->t_nook_stack) 
#define NOOK_of_TREE_by_IX(tree,nook_id)  \
FSTACK_INDEX((tree) ->t_nook_stack,NOOK_Object,nook_id) 
#define O_of_T(t) ((t) ->t_order) 
#define T_Generation(t) ((t) ->t_generation) 
#define T_is_Exhausted(t) ((t) ->t_is_exhausted) 
#define T_is_Nulling(t) ((t) ->t_is_nulling) 
#define Size_of_T(t) FSTACK_LENGTH((t) ->t_nook_stack) 
#define OR_of_NOOK(nook) ((nook) ->t_or_node) 
#define Choice_of_NOOK(nook) ((nook) ->t_choice) 
#define Parent_of_NOOK(nook) ((nook) ->t_parent) 
#define NOOK_Cause_is_Expanded(nook) ((nook) ->t_is_cause_ready) 
#define NOOK_is_Cause(nook) ((nook) ->t_is_cause_of_parent) 
#define NOOK_Predecessor_is_Expanded(nook) ((nook) ->t_is_predecessor_ready) 
#define NOOK_is_Predecessor(nook) ((nook) ->t_is_predecessor_of_parent) 
#define Next_Value_Type_of_V(val) ((val) ->t_next_value_type) 
#define V_is_Active(val) (Next_Value_Type_of_V(val) !=MARPA_STEP_INACTIVE) 
#define T_of_V(v) ((v) ->t_tree) 
#define Step_Type_of_V(val) ((val) ->public.t_step_type) 
#define ISYID_of_V(val) ((val) ->public.t_token_id) 
#define RULEID_of_V(val) ((val) ->public.t_rule_id) 
#define Token_Value_of_V(val) ((val) ->public.t_token_value) 
#define Token_Type_of_V(val) ((val) ->t_token_type) 
#define Arg_0_of_V(val) ((val) ->public.t_arg_0) 
#define Arg_N_of_V(val) ((val) ->public.t_arg_n) 
#define Result_of_V(val) ((val) ->public.t_result) 
#define Rule_Start_of_V(val) ((val) ->public.t_rule_start_ys_id) 
#define Token_Start_of_V(val) ((val) ->public.t_token_start_ys_id) 
#define YS_ID_of_V(val) ((val) ->public.t_ys_id) 
#define VStack_of_V(val) ((val) ->t_virtual_stack) 
#define V_T_Generation(v) ((v) ->t_generation) 
#define V_is_Nulling(v) ((v) ->t_is_nulling) 
#define V_is_Trace(val) ((val) ->t_trace) 
#define NOOK_of_V(val) ((val) ->t_nook) 
#define ISY_is_Valued_BV_of_V(v) ((v) ->t_isy_is_valued) 
#define IRL_is_Valued_BV_of_V(v) ((v) ->t_irl_is_valued) 
#define Valued_Locked_BV_of_V(v) ((v) ->t_valued_locked) 
#define STEP_GET_DATA MARPA_STEP_INTERNAL2 \

#define lbv_wordbits (sizeof(LBW) *8u) 
#define lbv_lsb (1u) 
#define lbv_msb (1u<<(lbv_wordbits-1u) ) 
#define lbv_w(lbv,bit) ((lbv) +((bit) /lbv_wordbits) ) 
#define lbv_b(bit) (lbv_lsb<<((bit) %bv_wordbits) ) 
#define lbv_bit_set(lbv,bit)  \
(*lbv_w((lbv) ,(LBW) (bit) ) |= lbv_b((LBW) (bit) ) ) 
#define lbv_bit_clear(lbv,bit)  \
(*lbv_w((lbv) ,((LBW) (bit) ) ) &= ~lbv_b((LBW) (bit) ) ) 
#define lbv_bit_test(lbv,bit)  \
((*lbv_w((lbv) ,((LBW) (bit) ) ) &lbv_b((LBW) (bit) ) ) !=0U)  \

#define BV_BITS(bv) *(bv-3) 
#define BV_SIZE(bv) *(bv-2) 
#define BV_MASK(bv) *(bv-1) 
#define FSTACK_DECLARE(stack,type) struct{int t_count;type*t_base;}stack;
#define FSTACK_CLEAR(stack) ((stack) .t_count= 0) 
#define FSTACK_INIT(stack,type,n) (FSTACK_CLEAR(stack) , \
((stack) .t_base= marpa_new(type,n) ) ) 
#define FSTACK_SAFE(stack) ((stack) .t_base= NULL) 
#define FSTACK_BASE(stack,type) ((type*) (stack) .t_base) 
#define FSTACK_INDEX(this,type,ix) (FSTACK_BASE((this) ,type) +(ix) ) 
#define FSTACK_TOP(this,type) (FSTACK_LENGTH(this) <=0 \
?NULL \
:FSTACK_INDEX((this) ,type,FSTACK_LENGTH(this) -1) ) 
#define FSTACK_LENGTH(stack) ((stack) .t_count) 
#define FSTACK_PUSH(stack) ((stack) .t_base+stack.t_count++) 
#define FSTACK_POP(stack) ((stack) .t_count<=0?NULL:(stack) .t_base+(--(stack) .t_count) ) 
#define FSTACK_IS_INITIALIZED(stack) ((stack) .t_base) 
#define FSTACK_DESTROY(stack) (my_free((stack) .t_base) )  \

#define DQUEUE_DECLARE(this) struct s_dqueue this
#define DQUEUE_INIT(this,type,initial_size)  \
((this.t_current= 0) ,MARPA_DSTACK_INIT(this.t_stack,type,initial_size) ) 
#define DQUEUE_PUSH(this,type) MARPA_DSTACK_PUSH(this.t_stack,type) 
#define DQUEUE_POP(this,type) MARPA_DSTACK_POP(this.t_stack,type) 
#define DQUEUE_NEXT(this,type) (this.t_current>=MARPA_DSTACK_LENGTH(this.t_stack)  \
?NULL \
:(MARPA_DSTACK_BASE(this.t_stack,type) ) +this.t_current++) 
#define DQUEUE_BASE(this,type) MARPA_DSTACK_BASE(this.t_stack,type) 
#define DQUEUE_END(this) MARPA_DSTACK_LENGTH(this.t_stack) 
#define STOLEN_DQUEUE_DATA_FREE(data) MARPA_STOLEN_DSTACK_DATA_FREE(data)  \

#define Count_of_CIL(cil) (cil[0]) 
#define Item_of_CIL(cil,ix) (cil[1+(ix) ]) 
#define Sizeof_CIL(ix) (sizeof(int) *(1+(ix) ) ) 
#define CAPACITY_OF_CILAR(cilar) (CAPACITY_OF_DSTACK(cilar->t_buffer) -1) 
#define Sizeof_PSL(psar)  \
(sizeof(PSL_Object) +((size_t) psar->t_psl_length-1) *sizeof(void*) ) 
#define PSL_Datum(psl,i) ((psl) ->t_data[(i) ]) 
#define Dot_PSAR_of_R(r) (&(r) ->t_dot_psar_object) 
#define Dot_PSL_of_YS(ys) ((ys) ->t_dot_psl) 
#define FATAL_FLAG (0x1u) 
#define MARPA_DEV_ERROR(message) (set_error(g,MARPA_ERR_DEVELOPMENT,(message) ,0u) ) 
#define MARPA_INTERNAL_ERROR(message) (set_error(g,MARPA_ERR_INTERNAL,(message) ,0u) ) 
#define MARPA_ERROR(code) (set_error(g,(code) ,NULL,0u) ) 
#define MARPA_FATAL(code) (set_error(g,(code) ,NULL,FATAL_FLAG) ) 

#line 17379 "./marpa.w"

#include "marpa_obs.h"
#include "marpa_avl.h"
/*107:*/
#line 1034 "./marpa.w"

struct s_g_event;
typedef struct s_g_event*GEV;
/*:107*//*143:*/
#line 1263 "./marpa.w"

struct s_isy;
typedef struct s_isy*ISY;
typedef const struct s_isy*ISY_Const;

/*:143*//*454:*/
#line 4862 "./marpa.w"

struct s_ahm;
typedef struct s_ahm*AHM;
typedef Marpa_AHM_ID AHMID;

/*:454*//*531:*/
#line 5800 "./marpa.w"

struct s_g_zwa;
struct s_r_zwa;
/*:531*//*538:*/
#line 5837 "./marpa.w"

struct s_zwp;
/*:538*//*631:*/
#line 6731 "./marpa.w"

struct s_earley_set;
typedef struct s_earley_set*YS;
typedef const struct s_earley_set*YS_Const;
struct s_earley_set_key;
typedef struct s_earley_set_key*YSK;
/*:631*//*653:*/
#line 6947 "./marpa.w"

struct s_earley_item;
typedef struct s_earley_item*YIM;
typedef const struct s_earley_item*YIM_Const;
struct s_earley_item_key;
typedef struct s_earley_item_key*YIK;

/*:653*//*663:*/
#line 7121 "./marpa.w"

struct s_earley_ix;
typedef struct s_earley_ix*YIX;
/*:663*//*666:*/
#line 7157 "./marpa.w"

struct s_leo_item;
typedef struct s_leo_item*LIM;
/*:666*//*702:*/
#line 7554 "./marpa.w"

struct s_alternative;
typedef struct s_alternative*ALT;
typedef const struct s_alternative*ALT_Const;
/*:702*//*859:*/
#line 10032 "./marpa.w"

struct s_ur_node_stack;
struct s_ur_node;
typedef struct s_ur_node_stack*URS;
typedef struct s_ur_node*UR;
typedef const struct s_ur_node*UR_Const;
/*:859*//*880:*/
#line 10294 "./marpa.w"

union u_or_node;
typedef union u_or_node*OR;
/*:880*//*902:*/
#line 10659 "./marpa.w"

struct s_draft_and_node;
typedef struct s_draft_and_node*DAND;
/*:902*//*928:*/
#line 11058 "./marpa.w"

struct s_and_node;
typedef struct s_and_node*AND;
/*:928*//*934:*/
#line 11119 "./marpa.w"

typedef struct marpa_traverser*TRAVERSER;
/*:934*//*981:*/
#line 11695 "./marpa.w"

typedef struct marpa_ltraverser*LTRAVERSER;
/*:981*//*1007:*/
#line 11861 "./marpa.w"

typedef struct marpa_ptraverser*PTRAVERSER;
/*:1007*//*1038:*/
#line 12142 "./marpa.w"

typedef struct marpa_bocage*BOCAGE;
/*:1038*//*1054:*/
#line 12292 "./marpa.w"

struct s_bocage_setup_per_ys;
/*:1054*//*1118:*/
#line 13046 "./marpa.w"

typedef Marpa_Tree TREE;
/*:1118*//*1149:*/
#line 13455 "./marpa.w"

struct s_nook;
typedef struct s_nook*NOOK;
/*:1149*//*1153:*/
#line 13500 "./marpa.w"

typedef struct s_value*VALUE;
/*:1153*//*1266:*/
#line 15069 "./marpa.w"

struct s_dqueue;
typedef struct s_dqueue*DQUEUE;
/*:1266*//*1272:*/
#line 15123 "./marpa.w"

struct s_cil_arena;
/*:1272*//*1292:*/
#line 15458 "./marpa.w"

struct s_per_earley_set_list;
typedef struct s_per_earley_set_list*PSL;
/*:1292*//*1294:*/
#line 15473 "./marpa.w"

struct s_per_earley_set_arena;
typedef struct s_per_earley_set_arena*PSAR;
/*:1294*/
#line 17382 "./marpa.w"

/*49:*/
#line 666 "./marpa.w"

typedef struct marpa_g*GRAMMAR;

/*:49*//*142:*/
#line 1261 "./marpa.w"

typedef Marpa_Symbol_ID ISYID;
/*:142*//*216:*/
#line 1904 "./marpa.w"

struct s_nsy;
typedef struct s_nsy*NSY;
typedef Marpa_NSY_ID NSYID;

/*:216*//*255:*/
#line 2189 "./marpa.w"

struct s_irl;
typedef struct s_irl*IRL;
typedef IRL RULE;
typedef Marpa_Rule_ID RULEID;
typedef Marpa_Rule_ID IRLID;

/*:255*//*328:*/
#line 2920 "./marpa.w"

struct s_nrl;
typedef struct s_nrl*NRL;
typedef Marpa_NRL_ID NRLID;

/*:328*//*471:*/
#line 4978 "./marpa.w"
typedef int SYMI;
/*:471*//*532:*/
#line 5809 "./marpa.w"

typedef Marpa_Assertion_ID ZWAID;
typedef struct s_g_zwa*GZWA;
typedef struct s_r_zwa*ZWA;

/*:532*//*539:*/
#line 5840 "./marpa.w"

typedef struct s_zwp*ZWP;
typedef const struct s_zwp*ZWP_Const;
/*:539*//*552:*/
#line 6036 "./marpa.w"

typedef struct marpa_r*RECCE;
/*:552*//*628:*/
#line 6721 "./marpa.w"
typedef Marpa_Earleme JEARLEME;

/*:628*//*630:*/
#line 6725 "./marpa.w"
typedef Marpa_Earley_Set_ID YSID;
/*:630*//*655:*/
#line 6988 "./marpa.w"

typedef int YIMID;

/*:655*//*673:*/
#line 7203 "./marpa.w"

typedef union _Marpa_PIM_Object PIM_Object;
typedef union _Marpa_PIM_Object*PIM;

/*:673*//*682:*/
#line 7283 "./marpa.w"

struct s_source;
typedef struct s_source*SRC;
typedef const struct s_source*SRC_Const;
/*:682*//*686:*/
#line 7311 "./marpa.w"

typedef struct marpa_source_link_s*SRCL;
/*:686*//*827:*/
#line 9630 "./marpa.w"

typedef struct marpa_progress_item*PROGRESS;
/*:827*//*879:*/
#line 10291 "./marpa.w"

typedef Marpa_Or_Node_ID ORID;

/*:879*//*901:*/
#line 10648 "./marpa.w"

typedef int WHEID;

/*:901*//*927:*/
#line 11054 "./marpa.w"

typedef Marpa_And_Node_ID ANDID;

/*:927*//*1148:*/
#line 13451 "./marpa.w"

typedef Marpa_Nook_ID NOOKID;
/*:1148*//*1203:*/
#line 14239 "./marpa.w"

typedef unsigned int LBW;
typedef LBW*LBV;

/*:1203*//*1211:*/
#line 14331 "./marpa.w"

typedef LBW Bit_Vector_Word;
typedef Bit_Vector_Word*Bit_Vector;
/*:1211*//*1269:*/
#line 15090 "./marpa.w"

typedef int*CIL;

/*:1269*//*1273:*/
#line 15126 "./marpa.w"

typedef struct s_cil_arena*CILAR;
/*:1273*/
#line 17383 "./marpa.w"

/*1271:*/
#line 15115 "./marpa.w"

struct s_cil_arena{
struct marpa_obstack*t_obs;
MARPA_AVL_TREE t_avl;
MARPA_DSTACK_DECLARE(t_buffer);
};
typedef struct s_cil_arena CILAR_Object;

/*:1271*/
#line 17384 "./marpa.w"

/*48:*/
#line 660 "./marpa.w"
struct marpa_g{
/*133:*/
#line 1208 "./marpa.w"

int t_is_ok;

/*:133*/
#line 661 "./marpa.w"

/*59:*/
#line 749 "./marpa.w"

MARPA_DSTACK_DECLARE(t_isy_stack);
MARPA_DSTACK_DECLARE(t_nsy_stack);

/*:59*//*68:*/
#line 808 "./marpa.w"

MARPA_DSTACK_DECLARE(t_irl_stack);
MARPA_DSTACK_DECLARE(t_nrl_stack);
/*:68*//*103:*/
#line 1003 "./marpa.w"
Bit_Vector t_bv_nsyid_is_terminal;
/*:103*//*105:*/
#line 1012 "./marpa.w"

Bit_Vector t_lbv_isyid_is_completion_event;
Bit_Vector t_lbv_isyid_completion_event_starts_active;
Bit_Vector t_lbv_isyid_is_nulled_event;
Bit_Vector t_lbv_isyid_nulled_event_starts_active;
Bit_Vector t_lbv_isyid_is_prediction_event;
Bit_Vector t_lbv_isyid_prediction_event_starts_active;
/*:105*//*112:*/
#line 1056 "./marpa.w"

MARPA_DSTACK_DECLARE(t_events);
/*:112*//*120:*/
#line 1130 "./marpa.w"

MARPA_AVL_TREE t_irl_tree;
/*:120*//*124:*/
#line 1160 "./marpa.w"

struct marpa_obstack*t_obs;
struct marpa_obstack*t_irl_obs;
/*:124*//*127:*/
#line 1177 "./marpa.w"

CILAR_Object t_cilar;
/*:127*//*135:*/
#line 1223 "./marpa.w"

const char*t_error_string;
/*:135*//*459:*/
#line 4888 "./marpa.w"

AHM t_ahms;
/*:459*//*533:*/
#line 5816 "./marpa.w"

MARPA_DSTACK_DECLARE(t_gzwa_stack);
/*:533*//*541:*/
#line 5855 "./marpa.w"

MARPA_AVL_TREE t_zwp_tree;
/*:541*/
#line 662 "./marpa.w"

/*53:*/
#line 696 "./marpa.w"
int t_ref_count;
/*:53*//*78:*/
#line 858 "./marpa.w"
ISYID t_start_isy_id;
/*:78*//*82:*/
#line 895 "./marpa.w"

NRL t_start_nrl;
/*:82*//*85:*/
#line 909 "./marpa.w"

int t_external_size;
/*:85*//*88:*/
#line 923 "./marpa.w"
int t_max_rule_length;
/*:88*//*92:*/
#line 936 "./marpa.w"
Marpa_Rank t_default_rank;
/*:92*//*136:*/
#line 1225 "./marpa.w"

Marpa_Error_Code t_error;
/*:136*//*161:*/
#line 1389 "./marpa.w"
int t_force_valued;
/*:161*//*457:*/
#line 4880 "./marpa.w"

int t_ahm_count;
/*:457*//*472:*/
#line 4980 "./marpa.w"

int t_symbol_instance_count;
/*:472*/
#line 663 "./marpa.w"

/*97:*/
#line 971 "./marpa.w"
BITFIELD t_is_precomputed:1;
/*:97*//*100:*/
#line 983 "./marpa.w"
BITFIELD t_has_cycle:1;
/*:100*/
#line 664 "./marpa.w"

};
/*:48*//*111:*/
#line 1049 "./marpa.w"

struct s_g_event{
int t_type;
int t_value;
};
typedef struct s_g_event GEV_Object;
/*:111*//*144:*/
#line 1268 "./marpa.w"

struct s_isy{
/*202:*/
#line 1804 "./marpa.w"

CIL t_nulled_event_isyids;
/*:202*//*205:*/
#line 1831 "./marpa.w"
NSY t_nsy_equivalent;
/*:205*//*209:*/
#line 1863 "./marpa.w"
NSY t_nulling_nsy;
/*:209*/
#line 1270 "./marpa.w"

/*145:*/
#line 1277 "./marpa.w"
ISYID t_symbol_id;

/*:145*//*150:*/
#line 1310 "./marpa.w"

Marpa_Rank t_rank;
/*:150*/
#line 1271 "./marpa.w"

/*154:*/
#line 1357 "./marpa.w"
BITFIELD t_is_lhs:1;
/*:154*//*156:*/
#line 1364 "./marpa.w"
BITFIELD t_is_sequence_lhs:1;
/*:156*//*158:*/
#line 1378 "./marpa.w"

BITFIELD t_is_valued:1;
BITFIELD t_is_valued_locked:1;
/*:158*//*166:*/
#line 1448 "./marpa.w"
BITFIELD t_is_accessible:1;
/*:166*//*169:*/
#line 1469 "./marpa.w"
BITFIELD t_is_counted:1;
/*:169*//*172:*/
#line 1485 "./marpa.w"
BITFIELD t_is_nulling:1;
/*:172*//*175:*/
#line 1502 "./marpa.w"
BITFIELD t_is_nullable:1;
/*:175*//*178:*/
#line 1523 "./marpa.w"

BITFIELD t_is_terminal:1;
BITFIELD t_is_locked_terminal:1;
/*:178*//*183:*/
#line 1570 "./marpa.w"
BITFIELD t_is_productive:1;
/*:183*//*186:*/
#line 1591 "./marpa.w"

BITFIELD t_is_completion_event:1;
BITFIELD t_completion_event_starts_active:1;
/*:186*//*191:*/
#line 1661 "./marpa.w"

BITFIELD t_is_nulled_event:1;
BITFIELD t_nulled_event_starts_active:1;
/*:191*//*196:*/
#line 1734 "./marpa.w"

BITFIELD t_is_prediction_event:1;
BITFIELD t_prediction_event_starts_active:1;
/*:196*/
#line 1272 "./marpa.w"

};

/*:144*//*217:*/
#line 1919 "./marpa.w"

struct s_unvalued_token_or_node{
int t_or_node_type;
NSYID t_nsyid;
};

struct s_nsy{
/*236:*/
#line 2056 "./marpa.w"
CIL t_lhs_cil;
/*:236*//*241:*/
#line 2087 "./marpa.w"
ISY t_source_isy;
/*:241*//*245:*/
#line 2110 "./marpa.w"

IRL t_lhs_irl;
int t_irl_offset;
/*:245*/
#line 1926 "./marpa.w"

/*250:*/
#line 2163 "./marpa.w"
Marpa_Rank t_rank;
/*:250*/
#line 1927 "./marpa.w"

/*227:*/
#line 2011 "./marpa.w"
BITFIELD t_is_start:1;
/*:227*//*230:*/
#line 2025 "./marpa.w"
BITFIELD t_is_lhs:1;
/*:230*//*233:*/
#line 2039 "./marpa.w"
BITFIELD t_nsy_is_nulling:1;
/*:233*//*238:*/
#line 2064 "./marpa.w"
BITFIELD t_is_semantic:1;
/*:238*/
#line 1928 "./marpa.w"

struct s_unvalued_token_or_node t_nulling_or_node;
struct s_unvalued_token_or_node t_unvalued_or_node;
};
/*:217*//*254:*/
#line 2180 "./marpa.w"

struct s_irl{
/*267:*/
#line 2483 "./marpa.w"
int t_rhs_length;
/*:267*//*275:*/
#line 2548 "./marpa.w"
Marpa_Rule_ID t_id;

/*:275*//*276:*/
#line 2551 "./marpa.w"

Marpa_Rank t_rank;
/*:276*/
#line 2182 "./marpa.w"

/*280:*/
#line 2600 "./marpa.w"

BITFIELD t_null_ranks_high:1;
/*:280*//*284:*/
#line 2641 "./marpa.w"
BITFIELD t_is_bnf:1;
/*:284*//*286:*/
#line 2647 "./marpa.w"
BITFIELD t_is_sequence:1;
/*:286*//*288:*/
#line 2661 "./marpa.w"
int t_minimum;
/*:288*//*291:*/
#line 2687 "./marpa.w"
ISYID t_separator_id;
/*:291*//*296:*/
#line 2724 "./marpa.w"
BITFIELD t_is_discard:1;
/*:296*//*300:*/
#line 2764 "./marpa.w"
BITFIELD t_is_proper_separation:1;
/*:300*//*304:*/
#line 2785 "./marpa.w"
BITFIELD t_is_loop:1;
/*:304*//*307:*/
#line 2803 "./marpa.w"
BITFIELD t_is_nulling:1;
/*:307*//*310:*/
#line 2822 "./marpa.w"
BITFIELD t_is_nullable:1;
/*:310*//*314:*/
#line 2841 "./marpa.w"
BITFIELD t_is_accessible:1;
/*:314*//*317:*/
#line 2860 "./marpa.w"
BITFIELD t_is_productive:1;
/*:317*//*320:*/
#line 2878 "./marpa.w"
BITFIELD t_is_used:1;
/*:320*/
#line 2183 "./marpa.w"

/*268:*/
#line 2486 "./marpa.w"
Marpa_Symbol_ID t_symbols[1];


/*:268*/
#line 2184 "./marpa.w"

};
/*:254*//*326:*/
#line 2909 "./marpa.w"

struct s_nrl{
/*359:*/
#line 3122 "./marpa.w"
IRL t_source_irl;
/*:359*//*365:*/
#line 3171 "./marpa.w"
AHM t_first_ahm;
/*:365*/
#line 2911 "./marpa.w"

/*329:*/
#line 2931 "./marpa.w"
NRLID t_nrl_id;

/*:329*//*336:*/
#line 2968 "./marpa.w"
int t_length;
/*:336*//*338:*/
#line 2983 "./marpa.w"
int t_ahm_count;

/*:338*//*350:*/
#line 3062 "./marpa.w"
int t_real_symbol_count;
/*:350*//*353:*/
#line 3080 "./marpa.w"
int t_virtual_start;
/*:353*//*356:*/
#line 3100 "./marpa.w"
int t_virtual_end;
/*:356*//*362:*/
#line 3149 "./marpa.w"
Marpa_Rank t_rank;
/*:362*//*473:*/
#line 4986 "./marpa.w"

int t_symbol_instance_base;
int t_last_proper_symi;
/*:473*/
#line 2912 "./marpa.w"

/*341:*/
#line 3016 "./marpa.w"
BITFIELD t_is_virtual_lhs:1;
/*:341*//*344:*/
#line 3032 "./marpa.w"
BITFIELD t_is_virtual_rhs:1;
/*:344*//*347:*/
#line 3051 "./marpa.w"
BITFIELD t_is_right_recursive:1;
/*:347*//*409:*/
#line 4071 "./marpa.w"
BITFIELD t_is_chaf:1;
/*:409*/
#line 2913 "./marpa.w"

/*331:*/
#line 2936 "./marpa.w"

NSYID t_nsyid_array[1];

/*:331*/
#line 2914 "./marpa.w"

};
typedef struct s_nrl NRL_Object;

/*:326*//*378:*/
#line 3359 "./marpa.w"

struct sym_rule_pair
{
ISYID t_symid;
RULEID t_ruleid;
};

/*:378*//*453:*/
#line 4856 "./marpa.w"

struct s_ahm{
/*463:*/
#line 4908 "./marpa.w"

NRL t_nrl;

/*:463*//*476:*/
#line 5001 "./marpa.w"

CIL t_predicted_nrl_cil;
CIL t_lhs_cil;

/*:476*//*477:*/
#line 5009 "./marpa.w"

CIL t_zwa_cil;

/*:477*//*499:*/
#line 5253 "./marpa.w"

CIL t_completion_isyids;
CIL t_nulled_isyids;
CIL t_prediction_isyids;

/*:499*//*503:*/
#line 5283 "./marpa.w"

IRL t_irl;
/*:503*//*506:*/
#line 5312 "./marpa.w"

CIL t_event_ahmids;
/*:506*/
#line 4858 "./marpa.w"

/*464:*/
#line 4918 "./marpa.w"
NSYID t_postdot_nsyid;

/*:464*//*465:*/
#line 4927 "./marpa.w"

int t_leading_nulls;

/*:465*//*466:*/
#line 4940 "./marpa.w"

int t_position;

/*:466*//*468:*/
#line 4956 "./marpa.w"

int t_quasi_position;

/*:468*//*470:*/
#line 4976 "./marpa.w"

int t_symbol_instance;
/*:470*//*504:*/
#line 5291 "./marpa.w"

int t_irl_position;

/*:504*//*507:*/
#line 5316 "./marpa.w"

int t_event_group_size;
/*:507*/
#line 4859 "./marpa.w"

/*478:*/
#line 5018 "./marpa.w"

BITFIELD t_predicts_zwa:1;

/*:478*//*502:*/
#line 5274 "./marpa.w"

BITFIELD t_was_predicted:1;
BITFIELD t_is_initial:1;

/*:502*/
#line 4860 "./marpa.w"

};
/*:453*//*537:*/
#line 5830 "./marpa.w"

struct s_g_zwa{
ZWAID t_id;
BITFIELD t_default_value:1;
};
typedef struct s_g_zwa GZWA_Object;

/*:537*//*540:*/
#line 5847 "./marpa.w"

struct s_zwp{
IRLID t_irl_id;
int t_dot;
ZWAID t_zwaid;
};
typedef struct s_zwp ZWP_Object;

/*:540*//*621:*/
#line 6667 "./marpa.w"

struct s_r_zwa{
ZWAID t_id;
YSID t_memoized_ysid;
BITFIELD t_default_value:1;
BITFIELD t_memoized_value:1;
};
typedef struct s_r_zwa ZWA_Object;

/*:621*//*632:*/
#line 6737 "./marpa.w"

struct s_earley_set_key{
JEARLEME t_earleme;
};
typedef struct s_earley_set_key YSK_Object;
/*:632*//*633:*/
#line 6742 "./marpa.w"

struct s_earley_set{
YSK_Object t_key;
PIM*t_postdot_ary;
YS t_next_earley_set;
/*635:*/
#line 6758 "./marpa.w"

YIM*t_earley_items;

/*:635*//*1303:*/
#line 15561 "./marpa.w"

PSL t_dot_psl;
/*:1303*/
#line 6747 "./marpa.w"

int t_postdot_sym_count;
/*634:*/
#line 6755 "./marpa.w"

int t_yim_count;
/*:634*//*636:*/
#line 6769 "./marpa.w"

int t_ordinal;
/*:636*//*640:*/
#line 6787 "./marpa.w"

int t_value;
void*t_pvalue;
/*:640*/
#line 6749 "./marpa.w"

};
typedef struct s_earley_set YS_Object;

/*:633*//*664:*/
#line 7124 "./marpa.w"

struct s_earley_ix{
PIM t_next;
NSYID t_postdot_nsyid;
YIM t_earley_item;
};
typedef struct s_earley_ix YIX_Object;

/*:664*//*667:*/
#line 7160 "./marpa.w"

struct s_leo_item{
YIX_Object t_earley_ix;
/*668:*/
#line 7176 "./marpa.w"

CIL t_cil;

/*:668*/
#line 7163 "./marpa.w"

YS t_origin;
AHM t_top_ahm;
AHM t_trailhead_ahm;
LIM t_predecessor;
YIM t_base;
YS t_set;
BITFIELD t_is_rejected:1;
BITFIELD t_is_active:1;
};
typedef struct s_leo_item LIM_Object;

/*:667*//*703:*/
#line 7565 "./marpa.w"

struct s_alternative{
YS t_start_earley_set;
JEARLEME t_end_earleme;
NSYID t_nsyid;
int t_value;
BITFIELD t_is_valued:1;
};
typedef struct s_alternative ALT_Object;

/*:703*//*860:*/
#line 10048 "./marpa.w"

struct s_ur_node_stack{
struct marpa_obstack*t_obs;
UR t_base;
UR t_top;
};

/*:860*//*861:*/
#line 10055 "./marpa.w"

struct s_ur_node{
UR t_prev;
UR t_next;
YIM t_earley_item;
};
typedef struct s_ur_node UR_Object;

/*:861*//*884:*/
#line 10337 "./marpa.w"

struct s_draft_or_node
{
/*883:*/
#line 10330 "./marpa.w"

/*882:*/
#line 10327 "./marpa.w"

int t_position;

/*:882*/
#line 10331 "./marpa.w"

int t_end_set_ordinal;
int t_start_set_ordinal;
ORID t_id;
NRL t_nrl;

/*:883*/
#line 10340 "./marpa.w"

DAND t_draft_and_node;
};

/*:884*//*885:*/
#line 10344 "./marpa.w"

struct s_final_or_node
{
/*883:*/
#line 10330 "./marpa.w"

/*882:*/
#line 10327 "./marpa.w"

int t_position;

/*:882*/
#line 10331 "./marpa.w"

int t_end_set_ordinal;
int t_start_set_ordinal;
ORID t_id;
NRL t_nrl;

/*:883*/
#line 10347 "./marpa.w"

int t_first_and_node_id;
int t_and_node_count;
};

/*:885*//*886:*/
#line 10352 "./marpa.w"

struct s_valued_token_or_node
{
/*882:*/
#line 10327 "./marpa.w"

int t_position;

/*:882*/
#line 10355 "./marpa.w"

NSYID t_nsyid;
int t_value;
};

/*:886*//*887:*/
#line 10363 "./marpa.w"

union u_or_node{
struct s_draft_or_node t_draft;
struct s_final_or_node t_final;
struct s_valued_token_or_node t_token;
};
typedef union u_or_node OR_Object;

/*:887*//*903:*/
#line 10666 "./marpa.w"

struct s_draft_and_node{
DAND t_next;
OR t_predecessor;
OR t_cause;
};
typedef struct s_draft_and_node DAND_Object;

/*:903*//*929:*/
#line 11065 "./marpa.w"

struct s_and_node{
OR t_current;
OR t_predecessor;
OR t_cause;
};
typedef struct s_and_node AND_Object;

/*:929*//*1055:*/
#line 12298 "./marpa.w"

struct s_bocage_setup_per_ys{
OR*t_or_node_by_item;
PSL t_or_psl;
PSL t_and_psl;
};
/*:1055*//*1081:*/
#line 12519 "./marpa.w"

struct marpa_order{
struct marpa_obstack*t_ordering_obs;
ANDID**t_and_node_orderings;
/*1084:*/
#line 12537 "./marpa.w"

BOCAGE t_bocage;

/*:1084*/
#line 12523 "./marpa.w"

/*1087:*/
#line 12557 "./marpa.w"
int t_ref_count;
/*:1087*//*1094:*/
#line 12613 "./marpa.w"
int t_ambiguity_metric;

/*:1094*//*1100:*/
#line 12725 "./marpa.w"
int t_high_rank_count;
/*:1100*/
#line 12524 "./marpa.w"

/*1098:*/
#line 12707 "./marpa.w"

BITFIELD t_is_nulling:1;
/*:1098*/
#line 12525 "./marpa.w"

BITFIELD t_is_frozen:1;
};
/*:1081*//*1119:*/
#line 13058 "./marpa.w"

/*1150:*/
#line 13466 "./marpa.w"

struct s_nook{
OR t_or_node;
int t_choice;
NOOKID t_parent;
BITFIELD t_is_cause_ready:1;
BITFIELD t_is_predecessor_ready:1;
BITFIELD t_is_cause_of_parent:1;
BITFIELD t_is_predecessor_of_parent:1;
};
typedef struct s_nook NOOK_Object;

/*:1150*/
#line 13059 "./marpa.w"

/*1155:*/
#line 13514 "./marpa.w"

struct s_value{
struct marpa_value public;
Marpa_Tree t_tree;
/*1159:*/
#line 13592 "./marpa.w"

struct marpa_obstack*t_obs;
/*:1159*//*1164:*/
#line 13639 "./marpa.w"

MARPA_DSTACK_DECLARE(t_virtual_stack);
/*:1164*//*1189:*/
#line 13812 "./marpa.w"

LBV t_isy_is_valued;
LBV t_irl_is_valued;
LBV t_valued_locked;

/*:1189*/
#line 13518 "./marpa.w"

/*1169:*/
#line 13687 "./marpa.w"

int t_ref_count;
/*:1169*//*1176:*/
#line 13745 "./marpa.w"

unsigned int t_generation;

/*:1176*//*1184:*/
#line 13787 "./marpa.w"

NOOKID t_nook;
/*:1184*/
#line 13519 "./marpa.w"

int t_token_type;
int t_next_value_type;
/*1179:*/
#line 13758 "./marpa.w"

BITFIELD t_is_nulling:1;
/*:1179*//*1181:*/
#line 13765 "./marpa.w"

BITFIELD t_trace:1;
/*:1181*/
#line 13522 "./marpa.w"

};

/*:1155*/
#line 13060 "./marpa.w"

struct marpa_tree{
FSTACK_DECLARE(t_nook_stack,NOOK_Object)
FSTACK_DECLARE(t_nook_worklist,int)
Bit_Vector t_or_node_in_use;
Marpa_Order t_order;
/*1125:*/
#line 13131 "./marpa.w"

int t_ref_count;
/*:1125*//*1130:*/
#line 13184 "./marpa.w"
unsigned int t_generation;
/*:1130*/
#line 13066 "./marpa.w"

/*1134:*/
#line 13244 "./marpa.w"

BITFIELD t_is_exhausted:1;
/*:1134*//*1137:*/
#line 13252 "./marpa.w"

BITFIELD t_is_nulling:1;

/*:1137*/
#line 13067 "./marpa.w"

int t_parse_count;
};

/*:1119*//*1246:*/
#line 14853 "./marpa.w"

struct s_bit_matrix{
int t_row_count;
Bit_Vector_Word t_row_data[1];
};
typedef struct s_bit_matrix*Bit_Matrix;
typedef struct s_bit_matrix Bit_Matrix_Object;

/*:1246*//*1267:*/
#line 15072 "./marpa.w"

struct s_dqueue{int t_current;struct marpa_dstack_s t_stack;};

/*:1267*//*1293:*/
#line 15464 "./marpa.w"

struct s_per_earley_set_list{
PSL t_prev;
PSL t_next;
PSL*t_owner;
void*t_data[1];
};
typedef struct s_per_earley_set_list PSL_Object;
/*:1293*//*1295:*/
#line 15489 "./marpa.w"

struct s_per_earley_set_arena{
int t_psl_length;
PSL t_first_psl;
PSL t_first_free_psl;
};
typedef struct s_per_earley_set_arena PSAR_Object;
/*:1295*/
#line 17385 "./marpa.w"

/*672:*/
#line 7198 "./marpa.w"

union _Marpa_PIM_Object{
LIM_Object t_leo;
YIX_Object t_earley;
};
/*:672*/
#line 17386 "./marpa.w"


/*:1453*//*1454:*/
#line 17391 "./marpa.w"

/*40:*/
#line 570 "./marpa.w"

const int marpa_major_version= MARPA_LIB_MAJOR_VERSION;
const int marpa_minor_version= MARPA_LIB_MINOR_VERSION;
const int marpa_micro_version= MARPA_LIB_MICRO_VERSION;

/*:40*//*833:*/
#line 9656 "./marpa.w"

static const struct marpa_progress_item progress_report_not_ready= {-2,-2,-2};

/*:833*//*888:*/
#line 10371 "./marpa.w"

static const int dummy_or_node_type= DUMMY_OR_NODE;
static const OR dummy_or_node= (OR)&dummy_or_node_type;

/*:888*//*1212:*/
#line 14338 "./marpa.w"

static const unsigned int bv_wordbits= lbv_wordbits;
static const unsigned int bv_modmask= lbv_wordbits-1u;
static const unsigned int bv_hiddenwords= 3;
static const unsigned int bv_lsb= lbv_lsb;
static const unsigned int bv_msb= lbv_msb;

/*:1212*/
#line 17392 "./marpa.w"


/*:1454*//*1455:*/
#line 17394 "./marpa.w"

/*553:*/
#line 6038 "./marpa.w"

struct marpa_r{
/*561:*/
#line 6118 "./marpa.w"

GRAMMAR t_grammar;
/*:561*//*568:*/
#line 6145 "./marpa.w"

YS t_first_earley_set;
YS t_latest_earley_set;
JEARLEME t_current_earleme;
/*:568*//*580:*/
#line 6228 "./marpa.w"

Bit_Vector t_lbv_isyid_completion_event_is_active;
Bit_Vector t_lbv_isyid_nulled_event_is_active;
Bit_Vector t_lbv_isyid_prediction_event_is_active;
/*:580*//*583:*/
#line 6253 "./marpa.w"
Bit_Vector t_bv_nsyid_is_expected;
/*:583*//*587:*/
#line 6330 "./marpa.w"
LBV t_nsy_expected_is_event;
/*:587*//*609:*/
#line 6604 "./marpa.w"

Bit_Vector t_bv_nrl_seen;
MARPA_DSTACK_DECLARE(t_nrl_cil_stack);
/*:609*//*618:*/
#line 6658 "./marpa.w"
struct marpa_obstack*t_obs;
/*:618*//*622:*/
#line 6679 "./marpa.w"

ZWA t_zwas;
/*:622*//*704:*/
#line 7575 "./marpa.w"

MARPA_DSTACK_DECLARE(t_alternatives);
/*:704*//*721:*/
#line 7862 "./marpa.w"

LBV t_valued_terminal;
LBV t_unvalued_terminal;
LBV t_valued;
LBV t_unvalued;
LBV t_valued_locked;

/*:721*//*729:*/
#line 8075 "./marpa.w"
MARPA_DSTACK_DECLARE(t_yim_work_stack);
/*:729*//*733:*/
#line 8090 "./marpa.w"
MARPA_DSTACK_DECLARE(t_completion_stack);
/*:733*//*737:*/
#line 8101 "./marpa.w"
MARPA_DSTACK_DECLARE(t_earley_set_stack);
/*:737*//*774:*/
#line 8731 "./marpa.w"

Bit_Vector t_bv_lim_symbols;
Bit_Vector t_bv_pim_symbols;
void**t_pim_workarea;
/*:774*//*793:*/
#line 9015 "./marpa.w"

void**t_lim_chain;
/*:793*//*828:*/
#line 9632 "./marpa.w"

const struct marpa_progress_item*t_current_report_item;
MARPA_AVL_TRAV t_progress_report_traverser;
/*:828*//*862:*/
#line 10064 "./marpa.w"

struct s_ur_node_stack t_ur_node_stack;
/*:862*//*1296:*/
#line 15497 "./marpa.w"

PSAR_Object t_dot_psar_object;
/*:1296*//*1347:*/
#line 15965 "./marpa.w"

struct s_earley_set*t_trace_earley_set;
/*:1347*//*1354:*/
#line 16041 "./marpa.w"

YIM t_trace_earley_item;
/*:1354*//*1368:*/
#line 16240 "./marpa.w"

PIM*t_trace_pim_nsy_p;
PIM t_trace_postdot_item;
/*:1368*//*1375:*/
#line 16389 "./marpa.w"

SRCL t_trace_source_link;
/*:1375*/
#line 6040 "./marpa.w"

/*556:*/
#line 6068 "./marpa.w"
int t_ref_count;
/*:556*//*572:*/
#line 6182 "./marpa.w"
int t_earley_item_warning_threshold;
/*:572*//*576:*/
#line 6211 "./marpa.w"
JEARLEME t_furthest_earleme;
/*:576*//*581:*/
#line 6232 "./marpa.w"

int t_active_event_count;
/*:581*//*616:*/
#line 6651 "./marpa.w"
YSID t_first_inconsistent_ys;
/*:616*//*637:*/
#line 6773 "./marpa.w"

int t_earley_set_count;
/*:637*/
#line 6041 "./marpa.w"

/*565:*/
#line 6136 "./marpa.w"

BITFIELD t_input_phase:2;
/*:565*//*605:*/
#line 6571 "./marpa.w"

BITFIELD t_use_leo_flag:1;
BITFIELD t_is_using_leo:1;
/*:605*//*612:*/
#line 6623 "./marpa.w"
BITFIELD t_is_exhausted:1;
/*:612*//*1376:*/
#line 16391 "./marpa.w"

BITFIELD t_trace_source_type:3;
/*:1376*/
#line 6042 "./marpa.w"

};

/*:553*/
#line 17395 "./marpa.w"

/*683:*/
#line 7287 "./marpa.w"

struct s_token_source{
NSYID t_nsyid;
int t_value;
};

/*:683*//*684:*/
#line 7296 "./marpa.w"

struct s_source{
void*t_predecessor;
union{
void*t_completion;
struct s_token_source t_token;
}t_cause;
BITFIELD t_is_rejected:1;
BITFIELD t_is_active:1;

};

/*:684*//*687:*/
#line 7313 "./marpa.w"

struct marpa_source_link_s{
SRCL t_next;
struct s_source t_source;
};
typedef struct marpa_source_link_s SRCL_Object;

/*:687*//*688:*/
#line 7320 "./marpa.w"

struct s_ambiguous_source{
SRCL t_leo;
SRCL t_token;
SRCL t_completion;
};

/*:688*//*689:*/
#line 7327 "./marpa.w"

union u_source_container{
struct s_ambiguous_source t_ambiguous;
struct marpa_source_link_s t_unique;
};

/*:689*/
#line 17396 "./marpa.w"

/*654:*/
#line 6967 "./marpa.w"

struct s_earley_item_key{
AHM t_ahm;
YS t_origin;
YS t_set;
};
typedef struct s_earley_item_key YIK_Object;
struct s_earley_item{
YIK_Object t_key;
union u_source_container t_container;
BITFIELD t_ordinal:YIM_ORDINAL_WIDTH;
BITFIELD t_source_type:3;
BITFIELD t_is_rejected:1;
BITFIELD t_is_active:1;
BITFIELD t_was_scanned:1;
BITFIELD t_was_fusion:1;
};
typedef struct s_earley_item YIM_Object;

/*:654*/
#line 17397 "./marpa.w"

/*935:*/
#line 11122 "./marpa.w"

struct marpa_traverser{
/*936:*/
#line 11137 "./marpa.w"

YIM t_trv_yim;
SRCL t_trv_leo_srcl;
SRCL t_trv_token_srcl;
SRCL t_trv_completion_srcl;

/*:936*//*942:*/
#line 11162 "./marpa.w"

RECCE t_trv_recce;
/*:942*/
#line 11124 "./marpa.w"

/*960:*/
#line 11499 "./marpa.w"

int t_ref_count;
/*:960*/
#line 11125 "./marpa.w"

/*938:*/
#line 11150 "./marpa.w"

int t_trv_soft_error;
/*:938*//*967:*/
#line 11555 "./marpa.w"

BITFIELD t_is_trivial:1;
/*:967*/
#line 11126 "./marpa.w"

};
typedef struct marpa_traverser TRAVERSER_Object;

/*:935*/
#line 17398 "./marpa.w"

/*982:*/
#line 11698 "./marpa.w"

struct marpa_ltraverser{
/*983:*/
#line 11710 "./marpa.w"

LIM t_ltrv_lim;

/*:983*//*989:*/
#line 11732 "./marpa.w"

RECCE t_ltrv_recce;
/*:989*/
#line 11700 "./marpa.w"

/*999:*/
#line 11801 "./marpa.w"

int t_ref_count;
/*:999*/
#line 11701 "./marpa.w"

/*985:*/
#line 11720 "./marpa.w"

int t_ltrv_soft_error;
/*:985*/
#line 11702 "./marpa.w"

};
typedef struct marpa_ltraverser LTRAVERSER_Object;

/*:982*/
#line 17399 "./marpa.w"

/*1008:*/
#line 11864 "./marpa.w"

struct marpa_ptraverser{
/*1009:*/
#line 11876 "./marpa.w"

PIM t_ptrv_pim;
YS t_ptrv_ys;

/*:1009*//*1015:*/
#line 11899 "./marpa.w"

RECCE t_ptrv_recce;
/*:1015*/
#line 11866 "./marpa.w"

/*1026:*/
#line 12055 "./marpa.w"

int t_ref_count;
/*:1026*/
#line 11867 "./marpa.w"

/*1011:*/
#line 11887 "./marpa.w"

int t_ptrv_soft_error;
/*:1011*//*1033:*/
#line 12111 "./marpa.w"

BITFIELD t_is_trivial:1;
/*:1033*/
#line 11868 "./marpa.w"

};
typedef struct marpa_ptraverser PTRAVERSER_Object;

/*:1008*/
#line 17400 "./marpa.w"

/*1039:*/
#line 12144 "./marpa.w"

struct marpa_bocage{
/*1040:*/
#line 12158 "./marpa.w"

OR*t_or_nodes;
AND t_and_nodes;
/*:1040*//*1044:*/
#line 12187 "./marpa.w"

GRAMMAR t_grammar;

/*:1044*//*1048:*/
#line 12204 "./marpa.w"

struct marpa_obstack*t_obs;
/*:1048*//*1051:*/
#line 12272 "./marpa.w"

LBV t_valued_bv;
LBV t_valued_locked_bv;

/*:1051*/
#line 12146 "./marpa.w"

/*1041:*/
#line 12161 "./marpa.w"

int t_or_node_capacity;
int t_or_node_count;
int t_and_node_count;
ORID t_top_or_node_id;

/*:1041*//*1065:*/
#line 12420 "./marpa.w"
int t_ambiguity_metric;
/*:1065*//*1069:*/
#line 12434 "./marpa.w"
int t_ref_count;
/*:1069*/
#line 12147 "./marpa.w"

/*1076:*/
#line 12491 "./marpa.w"

BITFIELD t_is_nulling:1;
/*:1076*/
#line 12148 "./marpa.w"

};

/*:1039*/
#line 17401 "./marpa.w"


/*:1455*/

#line 1 "./marpa.c.p40"
static RULE rule_new(GRAMMAR g,
const ISYID lhs, const ISYID *rhs, int length);
static int
duplicate_rule_cmp (const void *ap, const void *bp, void *param  UNUSED);
static int sym_rule_cmp(
    const void* ap,
    const void* bp,
    void *param  UNUSED);
static int zwp_cmp (
    const void* ap,
    const void* bp,
    void *param  UNUSED);
static Marpa_Error_Code invalid_source_type_code(unsigned int type);
static void earley_item_ambiguate (struct marpa_r * r, YIM item);
static void
postdot_items_create (RECCE r,
  Bit_Vector bv_ok_for_chain,
  const YS current_earley_set);
static int report_item_cmp (
    const void* ap,
    const void* bp,
    void *param  UNUSED);
static int bv_scan(Bit_Vector bv, int raw_start, int* raw_min, int* raw_max);
static void transitive_closure(Bit_Matrix matrix);
static int
cil_cmp (const void *ap, const void *bp, void *param  UNUSED);
static void
set_error (GRAMMAR g, Marpa_Error_Code code, const char* message, unsigned int flags);
static void*
marpa__default_out_of_memory(void);
static inline void
grammar_unref (GRAMMAR g);
static inline GRAMMAR
grammar_ref (GRAMMAR g);
static inline void grammar_free(GRAMMAR g);
static inline void symbol_add( GRAMMAR g, ISY symbol);
static inline int isy_id_is_valid(GRAMMAR g, ISYID isy_id);
static inline int nsy_is_valid(GRAMMAR g, NSYID nsyid);
static inline void
rule_add (GRAMMAR g, RULE rule);
static inline void event_new(GRAMMAR g, int type);
static inline void int_event_new(GRAMMAR g, int type, int value);
static inline ISY
symbol_new (GRAMMAR g);
static inline NSY symbol_alias_create(GRAMMAR g, ISY symbol);
static inline NSY
nsy_start(GRAMMAR g);
static inline NSY
nsy_new(GRAMMAR g, ISY source);
static inline NSY
semantic_nsy_new(GRAMMAR g, ISY source);
static inline NSY
nsy_clone(GRAMMAR g, ISY isy);
static inline   IRL irl_start (GRAMMAR g, const ISYID lhs, const ISYID * rhs, int length);
static inline IRL irl_finish(GRAMMAR g, IRL rule);
static inline NRL
nrl_start(GRAMMAR g, int length);
static inline void
nrl_finish( GRAMMAR g, NRL nrl);
static inline Marpa_Symbol_ID rule_lhs_get(RULE rule);
static inline Marpa_Symbol_ID* rule_rhs_get(RULE rule);
static inline int ahm_is_valid(
GRAMMAR g, AHMID item_id);
static inline void
memoize_irl_data_for_AHM(AHM current_item, NRL nrl);
static inline void
recce_unref (RECCE r);
static inline RECCE recce_ref (RECCE r);
static inline void recce_free(struct marpa_r *r);
static inline YS ys_at_current_earleme(RECCE r);
static inline YS
earley_set_new( RECCE r, JEARLEME id);
static inline YIM earley_item_create(const RECCE r,
    const YIK_Object key);
static inline YIM
earley_item_assign (const RECCE r, const YS set, const YS origin,
                    const AHM ahm);
static inline PIM*
pim_nsy_p_find (YS set, NSYID nsyid);
static inline PIM first_pim_of_ys_by_nsyid(YS set, NSYID nsyid);
static inline SRCL unique_srcl_new( struct marpa_obstack* t_obs);
static inline void
completion_link_add (RECCE r,
                YIM item,
                YIM predecessor,
                YIM cause);
static inline void
leo_link_add (RECCE r,
                YIM item,
                LIM predecessor,
                YIM cause);
static inline int
alternative_insertion_point (RECCE r, ALT new_alternative);
static inline int alternative_cmp(const ALT_Const a, const ALT_Const b);
static inline ALT alternative_pop(RECCE r, JEARLEME earleme);
static inline int alternative_insert(RECCE r, ALT new_alternative);
static inline int evaluate_zwas(RECCE r, YSID ysid, AHM ahm);
static inline void trigger_events(RECCE r);
static inline int trigger_trivial_events(RECCE r);
static inline void earley_set_update_items(RECCE r, YS set);
static inline void r_update_earley_sets(RECCE r);
static inline int alternative_is_acceptable(ALT alternative);
static inline void
progress_report_items_insert(MARPA_AVL_TREE report_tree,
  AHM report_ahm,
    YIM origin_yim);
static inline void ur_node_stack_init(URS stack);
static inline void ur_node_stack_reset(URS stack);
static inline void ur_node_stack_destroy(URS stack);
static inline UR ur_node_new(URS stack, UR prev);
static inline void
ur_node_push (URS stack, YIM earley_item);
static inline UR
ur_node_pop (URS stack);
static inline void push_ur_if_new(
    struct s_bocage_setup_per_ys* per_ys_data,
    URS ur_node_stack, YIM yim);
static inline int psi_test_and_set(
    struct s_bocage_setup_per_ys* per_ys_data,
    YIM earley_item
    );
static inline void
Set_boolean_in_PSI_for_initial_nulls (struct s_bocage_setup_per_ys *per_ys_data,
  YIM yim);
static inline OR or_node_new(BOCAGE b);
static inline DAND draft_and_node_new(struct marpa_obstack *obs, OR predecessor, OR cause);
static inline void draft_and_node_add(struct marpa_obstack *obs, OR parent, OR predecessor, OR cause);
static inline OR or_by_origin_and_symi ( struct s_bocage_setup_per_ys *per_ys_data,
    YSID origin,
    SYMI symbol_instance);
static inline int dands_are_equal(OR predecessor_a, OR cause_a,
  OR predecessor_b, OR cause_b);
static inline int dand_is_duplicate(OR parent, OR predecessor, OR cause);
static inline OR set_or_from_yim ( struct s_bocage_setup_per_ys *per_ys_data,
  YIM psi_yim);
static inline OR safe_or_from_yim(
  struct s_bocage_setup_per_ys* per_ys_data,
  YIM yim);
static inline Marpa_Traverser
trv_new(RECCE r, YIM yim);
static inline void
traverser_unref (TRAVERSER trv);
static inline TRAVERSER
traverser_ref (TRAVERSER trv);
static inline void
traverser_free (TRAVERSER trv);
static inline Marpa_LTraverser
ltrv_new(RECCE r, LIM lim);
static inline void
ltraverser_unref (LTRAVERSER ltrv);
static inline LTRAVERSER
ltraverser_ref (LTRAVERSER ltrv);
static inline void
ltraverser_free (LTRAVERSER ltrv);
static inline Marpa_PTraverser
ptrv_new(RECCE r, YS ys, NSYID nsyid);
static inline void
ptraverser_unref (PTRAVERSER ptrv);
static inline PTRAVERSER
ptraverser_ref (PTRAVERSER ptrv);
static inline void
ptraverser_free (PTRAVERSER ptrv);
static inline void
bocage_unref (BOCAGE b);
static inline BOCAGE
bocage_ref (BOCAGE b);
static inline void
bocage_free (BOCAGE b);
static inline void
order_unref (ORDER o);
static inline ORDER
order_ref (ORDER o);
static inline void order_free(ORDER o);
static inline ANDID and_order_ix_is_valid(ORDER o, OR or_node, int ix);
static inline ANDID and_order_get(ORDER o, OR or_node, int ix);
static inline void tree_exhaust(TREE t);
static inline void
tree_unref (TREE t);
static inline TREE
tree_ref (TREE t);
static inline void tree_free(TREE t);
static inline int tree_or_node_try(TREE tree, ORID or_node_id);
static inline void tree_or_node_release(TREE tree, ORID or_node_id);
static inline void
value_unref (VALUE v);
static inline VALUE
value_ref (VALUE v);
static inline void value_free(VALUE v);
static inline int symbol_is_valued(
    VALUE v,
    Marpa_Symbol_ID isy_id);
static inline int symbol_is_valued_set (
    VALUE v, ISYID isy_id, int value);
static inline int lbv_bits_to_size(int bits);
static inline Bit_Vector
lbv_obs_new (struct marpa_obstack *obs, int bits);
static inline Bit_Vector
lbv_zero (Bit_Vector lbv, int bits);
static inline Bit_Vector
lbv_obs_new0 (struct marpa_obstack *obs, int bits);
static inline LBV lbv_clone(
  struct marpa_obstack* obs, LBV old_lbv, int bits);
static inline LBV lbv_fill(
  LBV lbv, int bits);
static inline unsigned int bv_bits_to_size(int bits);
static inline unsigned int bv_bits_to_unused_mask(int bits);
static inline Bit_Vector bv_create(int bits);
static inline Bit_Vector
bv_obs_create (struct marpa_obstack *obs, int bits);
static inline Bit_Vector bv_shadow(Bit_Vector bv);
static inline Bit_Vector bv_obs_shadow(struct marpa_obstack * obs, Bit_Vector bv);
static inline Bit_Vector bv_copy(Bit_Vector bv_to, Bit_Vector bv_from);
static inline Bit_Vector bv_clone(Bit_Vector bv);
static inline Bit_Vector bv_obs_clone(struct marpa_obstack *obs, Bit_Vector bv);
static inline void bv_free(Bit_Vector vector);
static inline void bv_fill(Bit_Vector bv);
static inline void bv_clear(Bit_Vector bv);
static inline void bv_over_clear(Bit_Vector bv, int raw_bit);
static inline void bv_bit_set(Bit_Vector vector, int raw_bit);
static inline void bv_bit_clear(Bit_Vector vector, int raw_bit);
static inline int bv_bit_test(Bit_Vector vector, int raw_bit);
static inline int
bv_bit_test_then_set (Bit_Vector vector, int raw_bit);
static inline int bv_is_empty(Bit_Vector addr);
static inline void bv_not(Bit_Vector X, Bit_Vector Y);
static inline void bv_and(Bit_Vector X, Bit_Vector Y, Bit_Vector Z);
static inline void bv_or(Bit_Vector X, Bit_Vector Y, Bit_Vector Z);
static inline void bv_or_assign(Bit_Vector X, Bit_Vector Y);
static inline int
bv_count (Bit_Vector v);
static inline void
rhs_closure (GRAMMAR g, Bit_Vector bv, IRLID ** irl_list_x_rh_sym);
static inline Bit_Matrix
matrix_buffer_create (void *buffer, int rows, int columns);
static inline size_t matrix_sizeof(int rows, int columns);
static inline Bit_Matrix matrix_obs_create(
  struct marpa_obstack *obs,
  int rows,
  int columns);
static inline void matrix_clear(Bit_Matrix matrix);
static inline int matrix_columns(Bit_Matrix matrix);
static inline Bit_Vector matrix_row(Bit_Matrix matrix, int row);
static inline void matrix_bit_set(Bit_Matrix matrix, int row, int column);
static inline void matrix_bit_clear(Bit_Matrix matrix, int row, int column);
static inline int matrix_bit_test(Bit_Matrix matrix, int row, int column);
static inline void
cilar_init (const CILAR cilar);
static inline void
cilar_buffer_reinit (const CILAR cilar);
static inline void cilar_destroy(const CILAR cilar);
static inline CIL cil_empty(CILAR cilar);
static inline CIL cil_singleton(CILAR cilar, int element);
static inline CIL cil_buffer_add(CILAR cilar);
static inline CIL cil_bv_add(CILAR cilar, Bit_Vector bv);
static inline void cil_buffer_clear(CILAR cilar);
static inline CIL cil_buffer_push(CILAR cilar, int new_item);
static inline CIL cil_buffer_reserve(CILAR cilar, int element_count);
static inline CIL cil_merge(CILAR cilar, CIL cil1, CIL cil2);
static inline CIL cil_merge_one(CILAR cilar, CIL cil, int new_element);
static inline void
psar_safe (const PSAR psar);
static inline void
psar_init (const PSAR psar, int length);
static inline void psar_destroy(const PSAR psar);
static inline PSL psl_new(const PSAR psar);
static inline void psar_reset(const PSAR psar);
static inline void psar_dealloc(const PSAR psar);
static inline void psl_claim(
    PSL* const psl_owner, const PSAR psar);
static inline PSL psl_claim_by_es(
    PSAR or_psar,
    struct s_bocage_setup_per_ys* per_ys_data,
    YSID ysid);
static inline PSL psl_alloc(const PSAR psar);
static inline Marpa_Error_Code
clear_error (GRAMMAR g);
static inline void trace_earley_item_clear(RECCE r);
static inline void trace_source_link_clear(RECCE r);

/*1456:*/
#line 17403 "./marpa.w"

/*1345:*/
#line 15941 "./marpa.w"

extern void*(*const marpa__out_of_memory)(void);

/*:1345*//*1436:*/
#line 17215 "./marpa.w"

extern int marpa__default_debug_handler(const char*format,...);
extern int(*marpa__debug_handler)(const char*,...);
extern int marpa__debug_level;

/*:1436*/
#line 17404 "./marpa.w"

#if MARPA_DEBUG
/*1441:*/
#line 17247 "./marpa.w"

static const char*yim_tag_safe(
char*buffer,GRAMMAR g,YIM yim)UNUSED;
static const char*yim_tag(GRAMMAR g,YIM yim)UNUSED;
/*:1441*//*1443:*/
#line 17273 "./marpa.w"

static char*lim_tag_safe(char*buffer,LIM lim)UNUSED;
static char*lim_tag(LIM lim)UNUSED;
/*:1443*//*1445:*/
#line 17299 "./marpa.w"

static const char*or_tag_safe(char*buffer,OR or)UNUSED;
static const char*or_tag(OR or)UNUSED;
/*:1445*//*1447:*/
#line 17331 "./marpa.w"

static const char*ahm_tag_safe(char*buffer,AHM ahm)UNUSED;
static const char*ahm_tag(AHM ahm)UNUSED;
/*:1447*/
#line 17406 "./marpa.w"

/*1442:*/
#line 17252 "./marpa.w"

static const char*
yim_tag_safe(char*buffer,GRAMMAR g,YIM yim)
{
if(!yim)return"NULL";
sprintf(buffer,"S%d@%d-%d",
AHMID_of_YIM(yim),Origin_Earleme_of_YIM(yim),
Earleme_of_YIM(yim));
return buffer;
}

static char DEBUG_yim_tag_buffer[1000];
static const char*
yim_tag(GRAMMAR g,YIM yim)
{
return yim_tag_safe(DEBUG_yim_tag_buffer,g,yim);
}

/*:1442*//*1444:*/
#line 17278 "./marpa.w"

static char*
lim_tag_safe(char*buffer,LIM lim)
{
sprintf(buffer,"L%d@%d",
Postdot_NSYID_of_LIM(lim),Earleme_of_LIM(lim));
return buffer;
}

static char DEBUG_lim_tag_buffer[1000];
static char*
lim_tag(LIM lim)
{
return lim_tag_safe(DEBUG_lim_tag_buffer,lim);
}

/*:1444*//*1446:*/
#line 17303 "./marpa.w"

static const char*
or_tag_safe(char*buffer,OR or)
{
if(!or)return"NULL";
if(OR_is_Token(or))return"TOKEN";
if(Type_of_OR(or)==DUMMY_OR_NODE)return"DUMMY";
sprintf(buffer,"R%d:%d@%d-%d",
NRLID_of_OR(or),Position_of_OR(or),
Origin_Ord_of_OR(or),
YS_Ord_of_OR(or));
return buffer;
}

static char DEBUG_or_tag_buffer[1000];
static const char*
or_tag(OR or)
{
return or_tag_safe(DEBUG_or_tag_buffer,or);
}

/*:1446*//*1448:*/
#line 17334 "./marpa.w"

static const char*
ahm_tag_safe(char*buffer,AHM ahm)
{
if(!ahm)return"NULL";
const int ahm_position= Position_of_AHM(ahm);
if(ahm_position>=0){
sprintf(buffer,"R%d@%d",NRLID_of_AHM(ahm),Position_of_AHM(ahm));
}else{
sprintf(buffer,"R%d@end",NRLID_of_AHM(ahm));
}
return buffer;
}

static char DEBUG_ahm_tag_buffer[1000];
static const char*
ahm_tag(AHM ahm)
{
return ahm_tag_safe(DEBUG_ahm_tag_buffer,ahm);
}

/*:1448*/
#line 17407 "./marpa.w"

#endif
/*1440:*/
#line 17239 "./marpa.w"

int(*marpa__debug_handler)(const char*,...)= 
marpa__default_debug_handler;
int marpa__debug_level= 0;

/*:1440*/
#line 17409 "./marpa.w"

/*41:*/
#line 581 "./marpa.w"

Marpa_Error_Code
marpa_check_version(int required_major,
int required_minor,
int required_micro)
{
if(required_major!=marpa_major_version)
return MARPA_ERR_MAJOR_VERSION_MISMATCH;
if(required_minor!=marpa_minor_version)
return MARPA_ERR_MINOR_VERSION_MISMATCH;
if(required_micro!=marpa_micro_version)
return MARPA_ERR_MICRO_VERSION_MISMATCH;
return MARPA_ERR_NONE;
}

/*:41*//*42:*/
#line 599 "./marpa.w"

Marpa_Error_Code
marpa_version(int*version)
{
*version++= marpa_major_version;
*version++= marpa_minor_version;
*version= marpa_micro_version;
return 0;
}

/*:42*//*45:*/
#line 622 "./marpa.w"

int marpa_c_init(Marpa_Config*config)
{
MARPA_OFF_DEBUG3("Debugging at level %ld is on: %s\n",
marpa__debug_level,STRLOC);
config->t_is_ok= I_AM_OK;
config->t_error= MARPA_ERR_NONE;
config->t_error_string= NULL;
return 0;
}

/*:45*//*46:*/
#line 633 "./marpa.w"

Marpa_Error_Code marpa_c_error(Marpa_Config*config,const char**p_error_string)
{
const Marpa_Error_Code error_code= config->t_error;
const char*error_string= config->t_error_string;
if(p_error_string){
*p_error_string= error_string;
}
return error_code;
}

const char*_marpa_tag(void)
{
#if defined(MARPA_TAG)
return STRINGIFY(MARPA_TAG);
#elif defined(__GNUC__)
return __DATE__" "__TIME__;
#else
return"[no tag]";
#endif
}

/*:46*//*51:*/
#line 674 "./marpa.w"

Marpa_Grammar marpa_g_new(Marpa_Config*configuration)
{
GRAMMAR g;
MARPA_OFF_DEBUG3("Debugging at level %ld is on: %s\n",
marpa__debug_level,STRLOC);
if(configuration&&configuration->t_is_ok!=I_AM_OK){
configuration->t_error= MARPA_ERR_I_AM_NOT_OK;
return NULL;
}
g= my_malloc(sizeof(struct marpa_g));


g->t_is_ok= 0;
/*54:*/
#line 697 "./marpa.w"

g->t_ref_count= 1;

/*:54*//*60:*/
#line 753 "./marpa.w"

MARPA_DSTACK_INIT2(g->t_isy_stack,ISY);
MARPA_DSTACK_SAFE(g->t_nsy_stack);

/*:60*//*69:*/
#line 811 "./marpa.w"

MARPA_DSTACK_INIT2(g->t_irl_stack,RULE);
MARPA_DSTACK_SAFE(g->t_nrl_stack);

/*:69*//*79:*/
#line 859 "./marpa.w"

g->t_start_isy_id= -1;
/*:79*//*83:*/
#line 897 "./marpa.w"

g->t_start_nrl= NULL;

/*:83*//*86:*/
#line 911 "./marpa.w"

External_Size_of_G(g)= 0;

/*:86*//*89:*/
#line 924 "./marpa.w"

g->t_max_rule_length= 0;

/*:89*//*93:*/
#line 937 "./marpa.w"

g->t_default_rank= 0;
/*:93*//*98:*/
#line 972 "./marpa.w"

g->t_is_precomputed= 0;
/*:98*//*101:*/
#line 984 "./marpa.w"

g->t_has_cycle= 0;
/*:101*//*104:*/
#line 1004 "./marpa.w"
g->t_bv_nsyid_is_terminal= NULL;

/*:104*//*106:*/
#line 1019 "./marpa.w"

g->t_lbv_isyid_is_completion_event= NULL;
g->t_lbv_isyid_completion_event_starts_active= NULL;
g->t_lbv_isyid_is_nulled_event= NULL;
g->t_lbv_isyid_nulled_event_starts_active= NULL;
g->t_lbv_isyid_is_prediction_event= NULL;
g->t_lbv_isyid_prediction_event_starts_active= NULL;

/*:106*//*113:*/
#line 1060 "./marpa.w"

MARPA_DSTACK_INIT(g->t_events,GEV_Object,INITIAL_G_EVENTS_CAPACITY);
/*:113*//*121:*/
#line 1132 "./marpa.w"

(g)->t_irl_tree= _marpa_avl_create(duplicate_rule_cmp,NULL);
/*:121*//*125:*/
#line 1163 "./marpa.w"

g->t_obs= marpa_obs_init;
g->t_irl_obs= marpa_obs_init;
/*:125*//*128:*/
#line 1179 "./marpa.w"

cilar_init(&(g)->t_cilar);
/*:128*//*137:*/
#line 1227 "./marpa.w"

g->t_error= MARPA_ERR_NONE;
g->t_error_string= NULL;
/*:137*//*162:*/
#line 1390 "./marpa.w"

g->t_force_valued= 0;
/*:162*//*458:*/
#line 4882 "./marpa.w"

g->t_ahm_count= 0;

/*:458*//*460:*/
#line 4890 "./marpa.w"

g->t_ahms= NULL;
/*:460*//*534:*/
#line 5818 "./marpa.w"

MARPA_DSTACK_INIT2(g->t_gzwa_stack,GZWA);
/*:534*//*542:*/
#line 5857 "./marpa.w"

(g)->t_zwp_tree= _marpa_avl_create(zwp_cmp,NULL);
/*:542*/
#line 688 "./marpa.w"



g->t_is_ok= I_AM_OK;
return g;
}

/*:51*//*55:*/
#line 707 "./marpa.w"

PRIVATE
void
grammar_unref(GRAMMAR g)
{
MARPA_ASSERT(g->t_ref_count> 0)
g->t_ref_count--;
if(g->t_ref_count<=0)
{
grammar_free(g);
}
}
void
marpa_g_unref(Marpa_Grammar g)
{grammar_unref(g);}

/*:55*//*57:*/
#line 724 "./marpa.w"

PRIVATE GRAMMAR
grammar_ref(GRAMMAR g)
{
MARPA_ASSERT(g->t_ref_count> 0)
g->t_ref_count++;
return g;
}
Marpa_Grammar
marpa_g_ref(Marpa_Grammar g)
{return grammar_ref(g);}

/*:57*//*58:*/
#line 736 "./marpa.w"

PRIVATE
void grammar_free(GRAMMAR g)
{
/*61:*/
#line 757 "./marpa.w"

{
MARPA_DSTACK_DESTROY(g->t_isy_stack);
MARPA_DSTACK_DESTROY(g->t_nsy_stack);
}

/*:61*//*70:*/
#line 815 "./marpa.w"

MARPA_DSTACK_DESTROY(g->t_nrl_stack);
MARPA_DSTACK_DESTROY(g->t_irl_stack);

/*:70*//*114:*/
#line 1062 "./marpa.w"
MARPA_DSTACK_DESTROY(g->t_events);

/*:114*//*123:*/
#line 1139 "./marpa.w"

/*122:*/
#line 1134 "./marpa.w"

{
_marpa_avl_destroy((g)->t_irl_tree);
(g)->t_irl_tree= NULL;
}
/*:122*/
#line 1140 "./marpa.w"


/*:123*//*126:*/
#line 1166 "./marpa.w"

marpa_obs_free(g->t_obs);
marpa_obs_free(g->t_irl_obs);

/*:126*//*129:*/
#line 1181 "./marpa.w"

cilar_destroy(&(g)->t_cilar);

/*:129*//*461:*/
#line 4892 "./marpa.w"

my_free(g->t_ahms);

/*:461*//*535:*/
#line 5820 "./marpa.w"

MARPA_DSTACK_DESTROY(g->t_gzwa_stack);

/*:535*//*543:*/
#line 5859 "./marpa.w"

{
_marpa_avl_destroy((g)->t_zwp_tree);
(g)->t_zwp_tree= NULL;
}

/*:543*//*544:*/
#line 5865 "./marpa.w"

/*122:*/
#line 1134 "./marpa.w"

{
_marpa_avl_destroy((g)->t_irl_tree);
(g)->t_irl_tree= NULL;
}
/*:122*/
#line 5866 "./marpa.w"


/*:544*/
#line 740 "./marpa.w"

my_free(g);
}

/*:58*//*63:*/
#line 765 "./marpa.w"

int marpa_g_highest_symbol_id(Marpa_Grammar g){
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 767 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 768 "./marpa.w"

return ISY_Count_of_G(g)-1;
}

/*:63*//*65:*/
#line 777 "./marpa.w"

PRIVATE
void symbol_add(GRAMMAR g,ISY symbol)
{
const ISYID new_id= MARPA_DSTACK_LENGTH((g)->t_isy_stack);
*MARPA_DSTACK_PUSH((g)->t_isy_stack,ISY)= symbol;
symbol->t_symbol_id= new_id;
}

/*:65*//*66:*/
#line 789 "./marpa.w"

PRIVATE int isy_id_is_valid(GRAMMAR g,ISYID isy_id)
{
return!ISYID_is_Malformed(isy_id)&&ISYID_of_G_Exists(isy_id);
}

/*:66*//*67:*/
#line 798 "./marpa.w"

PRIVATE int nsy_is_valid(GRAMMAR g,NSYID nsyid)
{
return nsyid>=0&&nsyid<NSY_Count_of_G(g);
}

/*:67*//*74:*/
#line 822 "./marpa.w"

int marpa_g_highest_rule_id(Marpa_Grammar g){
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 824 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 825 "./marpa.w"

return IRL_Count_of_G(g)-1;
}
int _marpa_g_nrl_count(Marpa_Grammar g){
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 829 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 830 "./marpa.w"

return NRL_Count_of_G(g);
}

/*:74*//*76:*/
#line 840 "./marpa.w"

PRIVATE void
rule_add(GRAMMAR g,RULE rule)
{
const RULEID new_id= MARPA_DSTACK_LENGTH((g)->t_irl_stack);
*MARPA_DSTACK_PUSH((g)->t_irl_stack,RULE)= rule;
rule->t_id= new_id;
External_Size_of_G(g)+= 1+Length_of_IRL(rule);
g->t_max_rule_length= MAX(Length_of_IRL(rule),g->t_max_rule_length);
}

/*:76*//*80:*/
#line 861 "./marpa.w"

Marpa_Symbol_ID marpa_g_start_symbol(Marpa_Grammar g)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 864 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 865 "./marpa.w"

if(g->t_start_isy_id<0){
MARPA_ERROR(MARPA_ERR_NO_START_SYMBOL);
return-1;
}
return g->t_start_isy_id;
}
/*:80*//*81:*/
#line 878 "./marpa.w"

Marpa_Symbol_ID marpa_g_start_symbol_set(Marpa_Grammar g,Marpa_Symbol_ID isy_id)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 881 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 882 "./marpa.w"

/*1317:*/
#line 15694 "./marpa.w"

if(_MARPA_UNLIKELY(G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_PRECOMPUTED);
return failure_indicator;
}

/*:1317*/
#line 883 "./marpa.w"

/*1319:*/
#line 15705 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1319*/
#line 884 "./marpa.w"

/*1320:*/
#line 15712 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}
/*:1320*/
#line 885 "./marpa.w"

return g->t_start_isy_id= isy_id;
}

/*:81*//*94:*/
#line 939 "./marpa.w"

Marpa_Rank marpa_g_default_rank(Marpa_Grammar g)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 942 "./marpa.w"

clear_error(g);
/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 944 "./marpa.w"

return Default_Rank_of_G(g);
}
/*:94*//*95:*/
#line 949 "./marpa.w"

Marpa_Rank marpa_g_default_rank_set(Marpa_Grammar g,Marpa_Rank rank)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 952 "./marpa.w"

clear_error(g);
/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 954 "./marpa.w"

/*1317:*/
#line 15694 "./marpa.w"

if(_MARPA_UNLIKELY(G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_PRECOMPUTED);
return failure_indicator;
}

/*:1317*/
#line 955 "./marpa.w"

if(_MARPA_UNLIKELY(rank<MINIMUM_RANK))
{
MARPA_ERROR(MARPA_ERR_RANK_TOO_LOW);
return failure_indicator;
}
if(_MARPA_UNLIKELY(rank> MAXIMUM_RANK))
{
MARPA_ERROR(MARPA_ERR_RANK_TOO_HIGH);
return failure_indicator;
}
return Default_Rank_of_G(g)= rank;
}

/*:95*//*99:*/
#line 974 "./marpa.w"

int marpa_g_is_precomputed(Marpa_Grammar g)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 977 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 978 "./marpa.w"

return G_is_Precomputed(g);
}

/*:99*//*102:*/
#line 986 "./marpa.w"

int marpa_g_has_cycle(Marpa_Grammar g)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 989 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 990 "./marpa.w"

return g->t_has_cycle;
}

/*:102*//*116:*/
#line 1072 "./marpa.w"

PRIVATE
void event_new(GRAMMAR g,int type)
{


GEV end_of_stack= G_EVENT_PUSH(g);
end_of_stack->t_type= type;
end_of_stack->t_value= 0;
}
/*:116*//*117:*/
#line 1082 "./marpa.w"

PRIVATE
void int_event_new(GRAMMAR g,int type,int value)
{


GEV end_of_stack= G_EVENT_PUSH(g);
end_of_stack->t_type= type;
end_of_stack->t_value= value;
}

/*:117*//*118:*/
#line 1093 "./marpa.w"

Marpa_Event_Type
marpa_g_event(Marpa_Grammar g,Marpa_Event*public_event,
int ix)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 1098 "./marpa.w"

MARPA_DSTACK events= &g->t_events;
GEV internal_event;
int type;

if(ix<0){
MARPA_ERROR(MARPA_ERR_EVENT_IX_NEGATIVE);
return failure_indicator;
}
if(ix>=MARPA_DSTACK_LENGTH(*events)){
MARPA_ERROR(MARPA_ERR_EVENT_IX_OOB);
return failure_indicator;
}
internal_event= MARPA_DSTACK_INDEX(*events,GEV_Object,ix);
type= internal_event->t_type;
public_event->t_type= type;
public_event->t_value= internal_event->t_value;
return type;
}

/*:118*//*119:*/
#line 1118 "./marpa.w"

Marpa_Event_Type
marpa_g_event_count(Marpa_Grammar g)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 1122 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 1123 "./marpa.w"

return MARPA_DSTACK_LENGTH(g->t_events);
}

/*:119*//*139:*/
#line 1238 "./marpa.w"

Marpa_Error_Code marpa_g_error(Marpa_Grammar g,const char**p_error_string)
{
const Marpa_Error_Code error_code= g->t_error;
const char*error_string= g->t_error_string;
if(p_error_string){
*p_error_string= error_string;
}
return error_code;
}

/*:139*//*140:*/
#line 1249 "./marpa.w"

Marpa_Error_Code
marpa_g_error_clear(Marpa_Grammar g)
{
clear_error(g);
return g->t_error;
}

/*:140*//*146:*/
#line 1279 "./marpa.w"

PRIVATE ISY
symbol_new(GRAMMAR g)
{
ISY isy= marpa_obs_new(g->t_obs,struct s_isy,1);
/*151:*/
#line 1312 "./marpa.w"

isy->t_rank= Default_Rank_of_G(g);
/*:151*//*155:*/
#line 1358 "./marpa.w"

ISY_is_LHS(isy)= 0;

/*:155*//*157:*/
#line 1365 "./marpa.w"

ISY_is_Sequence_LHS(isy)= 0;

/*:157*//*159:*/
#line 1381 "./marpa.w"

ISY_is_Valued(isy)= g->t_force_valued?1:0;
ISY_is_Valued_Locked(isy)= g->t_force_valued?1:0;

/*:159*//*167:*/
#line 1449 "./marpa.w"

isy->t_is_accessible= 0;
/*:167*//*170:*/
#line 1470 "./marpa.w"

isy->t_is_counted= 0;
/*:170*//*173:*/
#line 1486 "./marpa.w"

isy->t_is_nulling= 0;
/*:173*//*176:*/
#line 1503 "./marpa.w"

isy->t_is_nullable= 0;
/*:176*//*179:*/
#line 1526 "./marpa.w"

isy->t_is_terminal= 0;
isy->t_is_locked_terminal= 0;
/*:179*//*184:*/
#line 1571 "./marpa.w"

isy->t_is_productive= 0;
/*:184*//*187:*/
#line 1594 "./marpa.w"

isy->t_is_completion_event= 0;
isy->t_completion_event_starts_active= 0;
/*:187*//*192:*/
#line 1664 "./marpa.w"

isy->t_is_nulled_event= 0;
isy->t_nulled_event_starts_active= 0;
/*:192*//*197:*/
#line 1737 "./marpa.w"

isy->t_is_prediction_event= 0;
isy->t_prediction_event_starts_active= 0;
/*:197*//*203:*/
#line 1816 "./marpa.w"

Nulled_ISYIDs_of_ISY(isy)= NULL;

/*:203*//*206:*/
#line 1832 "./marpa.w"
NSY_of_ISY(isy)= NULL;
/*:206*//*210:*/
#line 1864 "./marpa.w"
Nulling_NSY_of_ISY(isy)= NULL;
/*:210*/
#line 1284 "./marpa.w"

symbol_add(g,isy);
return isy;
}

/*:146*//*147:*/
#line 1289 "./marpa.w"

Marpa_Symbol_ID
marpa_g_symbol_new(Marpa_Grammar g)
{
const ISY symbol= symbol_new(g);
return ID_of_ISY(symbol);
}

/*:147*//*149:*/
#line 1298 "./marpa.w"

int marpa_g_symbol_is_start(Marpa_Grammar g,Marpa_Symbol_ID isy_id)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 1301 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 1302 "./marpa.w"

/*1319:*/
#line 15705 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1319*/
#line 1303 "./marpa.w"

/*1320:*/
#line 15712 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}
/*:1320*/
#line 1304 "./marpa.w"

if(g->t_start_isy_id<0)return 0;
return isy_id==g->t_start_isy_id?1:0;
}

/*:149*//*152:*/
#line 1315 "./marpa.w"

int marpa_g_symbol_rank(Marpa_Grammar g,
Marpa_Symbol_ID isy_id)
{
ISY isy;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 1320 "./marpa.w"

clear_error(g);
/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 1322 "./marpa.w"

/*1319:*/
#line 15705 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1319*/
#line 1323 "./marpa.w"

/*1321:*/
#line 15717 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return failure_indicator;
}

/*:1321*/
#line 1324 "./marpa.w"

isy= ISY_by_ID(isy_id);
return Rank_of_ISY(isy);
}
/*:152*//*153:*/
#line 1328 "./marpa.w"

int marpa_g_symbol_rank_set(
Marpa_Grammar g,Marpa_Symbol_ID isy_id,Marpa_Rank rank)
{
ISY isy;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 1333 "./marpa.w"

clear_error(g);
/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 1335 "./marpa.w"

/*1317:*/
#line 15694 "./marpa.w"

if(_MARPA_UNLIKELY(G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_PRECOMPUTED);
return failure_indicator;
}

/*:1317*/
#line 1336 "./marpa.w"

/*1319:*/
#line 15705 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1319*/
#line 1337 "./marpa.w"

/*1321:*/
#line 15717 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return failure_indicator;
}

/*:1321*/
#line 1338 "./marpa.w"

isy= ISY_by_ID(isy_id);
if(_MARPA_UNLIKELY(rank<MINIMUM_RANK))
{
MARPA_ERROR(MARPA_ERR_RANK_TOO_LOW);
return failure_indicator;
}
if(_MARPA_UNLIKELY(rank> MAXIMUM_RANK))
{
MARPA_ERROR(MARPA_ERR_RANK_TOO_HIGH);
return failure_indicator;
}
return Rank_of_ISY(isy)= rank;
}

/*:153*//*163:*/
#line 1392 "./marpa.w"

int marpa_g_force_valued(Marpa_Grammar g)
{
ISYID isyid;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 1396 "./marpa.w"

for(isyid= 0;isyid<ISY_Count_of_G(g);isyid++){
const ISY isy= ISY_by_ID(isyid);
if(!ISY_is_Valued(isy)&&ISY_is_Valued_Locked(isy))
{
MARPA_ERROR(MARPA_ERR_VALUED_IS_LOCKED);
return failure_indicator;
}
ISY_is_Valued(isy)= 1;
ISY_is_Valued_Locked(isy)= 1;
}
g->t_force_valued= 1;
return 0;
}

/*:163*//*164:*/
#line 1411 "./marpa.w"

int marpa_g_symbol_is_valued(
Marpa_Grammar g,
Marpa_Symbol_ID isy_id)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 1416 "./marpa.w"

/*1319:*/
#line 15705 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1319*/
#line 1417 "./marpa.w"

/*1320:*/
#line 15712 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}
/*:1320*/
#line 1418 "./marpa.w"

return ISY_is_Valued(ISY_by_ID(isy_id));
}

/*:164*//*165:*/
#line 1422 "./marpa.w"

int marpa_g_symbol_is_valued_set(
Marpa_Grammar g,Marpa_Symbol_ID isy_id,int value)
{
ISY symbol;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 1427 "./marpa.w"

/*1319:*/
#line 15705 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1319*/
#line 1428 "./marpa.w"

/*1320:*/
#line 15712 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}
/*:1320*/
#line 1429 "./marpa.w"

symbol= ISY_by_ID(isy_id);
if(_MARPA_UNLIKELY(value<0||value> 1))
{
MARPA_ERROR(MARPA_ERR_INVALID_BOOLEAN);
return failure_indicator;
}
if(_MARPA_UNLIKELY(ISY_is_Valued_Locked(symbol)
&&value!=ISY_is_Valued(symbol)))
{
MARPA_ERROR(MARPA_ERR_VALUED_IS_LOCKED);
return failure_indicator;
}
ISY_is_Valued(symbol)= Boolean(value);
return value;
}

/*:165*//*168:*/
#line 1457 "./marpa.w"

int marpa_g_symbol_is_accessible(Marpa_Grammar g,Marpa_Symbol_ID isy_id)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 1460 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 1461 "./marpa.w"

/*1318:*/
#line 15700 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1318*/
#line 1462 "./marpa.w"

/*1319:*/
#line 15705 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1319*/
#line 1463 "./marpa.w"

/*1320:*/
#line 15712 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}
/*:1320*/
#line 1464 "./marpa.w"

return ISY_is_Accessible(ISY_by_ID(isy_id));
}

/*:168*//*171:*/
#line 1472 "./marpa.w"

int marpa_g_symbol_is_counted(Marpa_Grammar g,
Marpa_Symbol_ID isy_id)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 1476 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 1477 "./marpa.w"

/*1319:*/
#line 15705 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1319*/
#line 1478 "./marpa.w"

/*1320:*/
#line 15712 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}
/*:1320*/
#line 1479 "./marpa.w"

return ISY_by_ID(isy_id)->t_is_counted;
}

/*:171*//*174:*/
#line 1488 "./marpa.w"

int marpa_g_symbol_is_nulling(Marpa_Grammar g,Marpa_Symbol_ID isy_id)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 1491 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 1492 "./marpa.w"

/*1318:*/
#line 15700 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1318*/
#line 1493 "./marpa.w"

/*1319:*/
#line 15705 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1319*/
#line 1494 "./marpa.w"

/*1320:*/
#line 15712 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}
/*:1320*/
#line 1495 "./marpa.w"

return ISY_is_Nulling(ISY_by_ID(isy_id));
}

/*:174*//*177:*/
#line 1505 "./marpa.w"

int marpa_g_symbol_is_nullable(Marpa_Grammar g,Marpa_Symbol_ID isy_id)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 1508 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 1509 "./marpa.w"

/*1318:*/
#line 15700 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1318*/
#line 1510 "./marpa.w"

/*1319:*/
#line 15705 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1319*/
#line 1511 "./marpa.w"

/*1320:*/
#line 15712 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}
/*:1320*/
#line 1512 "./marpa.w"

return ISYID_is_Nullable(isy_id);
}

/*:177*//*181:*/
#line 1532 "./marpa.w"

int marpa_g_symbol_is_terminal(Marpa_Grammar g,
Marpa_Symbol_ID isy_id)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 1536 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 1537 "./marpa.w"

/*1319:*/
#line 15705 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1319*/
#line 1538 "./marpa.w"

/*1320:*/
#line 15712 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}
/*:1320*/
#line 1539 "./marpa.w"

return ISYID_is_Terminal(isy_id);
}
/*:181*//*182:*/
#line 1542 "./marpa.w"

int marpa_g_symbol_is_terminal_set(
Marpa_Grammar g,Marpa_Symbol_ID isy_id,int value)
{
ISY symbol;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 1547 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 1548 "./marpa.w"

/*1317:*/
#line 15694 "./marpa.w"

if(_MARPA_UNLIKELY(G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_PRECOMPUTED);
return failure_indicator;
}

/*:1317*/
#line 1549 "./marpa.w"

/*1319:*/
#line 15705 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1319*/
#line 1550 "./marpa.w"

/*1320:*/
#line 15712 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}
/*:1320*/
#line 1551 "./marpa.w"

symbol= ISY_by_ID(isy_id);
if(_MARPA_UNLIKELY(value<0||value> 1))
{
MARPA_ERROR(MARPA_ERR_INVALID_BOOLEAN);
return failure_indicator;
}
if(_MARPA_UNLIKELY(ISY_is_Locked_Terminal(symbol))
&&ISY_is_Terminal(symbol)!=value)
{
MARPA_ERROR(MARPA_ERR_TERMINAL_IS_LOCKED);
return failure_indicator;
}
ISY_is_Locked_Terminal(symbol)= 1;
return ISY_is_Terminal(symbol)= Boolean(value);
}

/*:182*//*185:*/
#line 1573 "./marpa.w"

int marpa_g_symbol_is_productive(
Marpa_Grammar g,
Marpa_Symbol_ID isy_id)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 1578 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 1579 "./marpa.w"

/*1318:*/
#line 15700 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1318*/
#line 1580 "./marpa.w"

/*1319:*/
#line 15705 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1319*/
#line 1581 "./marpa.w"

/*1320:*/
#line 15712 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}
/*:1320*/
#line 1582 "./marpa.w"

return ISY_is_Productive(ISY_by_ID(isy_id));
}

/*:185*//*188:*/
#line 1597 "./marpa.w"

int marpa_g_symbol_is_completion_event(Marpa_Grammar g,
Marpa_Symbol_ID isy_id)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 1601 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 1602 "./marpa.w"

/*1319:*/
#line 15705 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1319*/
#line 1603 "./marpa.w"

/*1320:*/
#line 15712 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}
/*:1320*/
#line 1604 "./marpa.w"

return ISYID_is_Completion_Event(isy_id);
}
/*:188*//*189:*/
#line 1607 "./marpa.w"

int marpa_g_symbol_is_completion_event_set(
Marpa_Grammar g,Marpa_Symbol_ID isy_id,int value)
{
ISY isy;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 1612 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 1613 "./marpa.w"

/*1317:*/
#line 15694 "./marpa.w"

if(_MARPA_UNLIKELY(G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_PRECOMPUTED);
return failure_indicator;
}

/*:1317*/
#line 1614 "./marpa.w"

/*1319:*/
#line 15705 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1319*/
#line 1615 "./marpa.w"

/*1320:*/
#line 15712 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}
/*:1320*/
#line 1616 "./marpa.w"

isy= ISY_by_ID(isy_id);
switch(value){
case 0:case 1:
ISY_Completion_Event_Starts_Active(isy)= Boolean(value);
return ISY_is_Completion_Event(isy)= Boolean(value);
}
MARPA_ERROR(MARPA_ERR_INVALID_BOOLEAN);
return failure_indicator;
}
/*:189*//*190:*/
#line 1626 "./marpa.w"

int
marpa_g_completion_symbol_activate(Marpa_Grammar g,
Marpa_Symbol_ID isy_id,
int reactivate)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 1632 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 1633 "./marpa.w"

/*1317:*/
#line 15694 "./marpa.w"

if(_MARPA_UNLIKELY(G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_PRECOMPUTED);
return failure_indicator;
}

/*:1317*/
#line 1634 "./marpa.w"

/*1319:*/
#line 15705 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1319*/
#line 1635 "./marpa.w"

/*1320:*/
#line 15712 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}
/*:1320*/
#line 1636 "./marpa.w"

switch(reactivate){
case 0:
ISYID_Completion_Event_Starts_Active(isy_id)
= Boolean(reactivate);
return 0;
case 1:
if(!ISYID_is_Completion_Event(isy_id)){


MARPA_ERROR(MARPA_ERR_SYMBOL_IS_NOT_COMPLETION_EVENT);
}
ISYID_Completion_Event_Starts_Active(isy_id)
= Boolean(reactivate);
return 1;
}
MARPA_ERROR(MARPA_ERR_INVALID_BOOLEAN);
return failure_indicator;
}

/*:190*//*193:*/
#line 1667 "./marpa.w"

int marpa_g_symbol_is_nulled_event(Marpa_Grammar g,
Marpa_Symbol_ID isy_id)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 1671 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 1672 "./marpa.w"

/*1319:*/
#line 15705 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1319*/
#line 1673 "./marpa.w"

/*1320:*/
#line 15712 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}
/*:1320*/
#line 1674 "./marpa.w"

return ISYID_is_Nulled_Event(isy_id);
}

/*:193*//*194:*/
#line 1680 "./marpa.w"

int marpa_g_symbol_is_nulled_event_set(
Marpa_Grammar g,Marpa_Symbol_ID isy_id,int value)
{
ISY isy;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 1685 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 1686 "./marpa.w"

/*1317:*/
#line 15694 "./marpa.w"

if(_MARPA_UNLIKELY(G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_PRECOMPUTED);
return failure_indicator;
}

/*:1317*/
#line 1687 "./marpa.w"

/*1319:*/
#line 15705 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1319*/
#line 1688 "./marpa.w"

/*1320:*/
#line 15712 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}
/*:1320*/
#line 1689 "./marpa.w"

isy= ISY_by_ID(isy_id);
switch(value){
case 0:case 1:
ISY_Nulled_Event_Starts_Active(isy)= Boolean(value);
return ISY_is_Nulled_Event(isy)= Boolean(value);
}
MARPA_ERROR(MARPA_ERR_INVALID_BOOLEAN);
return failure_indicator;
}
/*:194*//*195:*/
#line 1699 "./marpa.w"

int
marpa_g_nulled_symbol_activate(Marpa_Grammar g,
Marpa_Symbol_ID isy_id,
int reactivate)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 1705 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 1706 "./marpa.w"

/*1317:*/
#line 15694 "./marpa.w"

if(_MARPA_UNLIKELY(G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_PRECOMPUTED);
return failure_indicator;
}

/*:1317*/
#line 1707 "./marpa.w"

/*1319:*/
#line 15705 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1319*/
#line 1708 "./marpa.w"

/*1320:*/
#line 15712 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}
/*:1320*/
#line 1709 "./marpa.w"

switch(reactivate){
case 0:
ISYID_Nulled_Event_Starts_Active(isy_id)
= Boolean(reactivate);
return 0;
case 1:
if(!ISYID_is_Nulled_Event(isy_id)){


MARPA_ERROR(MARPA_ERR_SYMBOL_IS_NOT_COMPLETION_EVENT);
}
ISYID_Nulled_Event_Starts_Active(isy_id)
= Boolean(reactivate);
return 1;
}
MARPA_ERROR(MARPA_ERR_INVALID_BOOLEAN);
return failure_indicator;
}

/*:195*//*198:*/
#line 1740 "./marpa.w"

int marpa_g_symbol_is_prediction_event(Marpa_Grammar g,
Marpa_Symbol_ID isy_id)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 1744 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 1745 "./marpa.w"

/*1319:*/
#line 15705 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1319*/
#line 1746 "./marpa.w"

/*1320:*/
#line 15712 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}
/*:1320*/
#line 1747 "./marpa.w"

return ISYID_is_Prediction_Event(isy_id);
}
/*:198*//*199:*/
#line 1750 "./marpa.w"

int marpa_g_symbol_is_prediction_event_set(
Marpa_Grammar g,Marpa_Symbol_ID isy_id,int value)
{
ISY isy;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 1755 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 1756 "./marpa.w"

/*1317:*/
#line 15694 "./marpa.w"

if(_MARPA_UNLIKELY(G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_PRECOMPUTED);
return failure_indicator;
}

/*:1317*/
#line 1757 "./marpa.w"

/*1319:*/
#line 15705 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1319*/
#line 1758 "./marpa.w"

/*1320:*/
#line 15712 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}
/*:1320*/
#line 1759 "./marpa.w"

isy= ISY_by_ID(isy_id);
switch(value){
case 0:case 1:
ISY_Prediction_Event_Starts_Active(isy)= Boolean(value);
return ISY_is_Prediction_Event(isy)= Boolean(value);
}
MARPA_ERROR(MARPA_ERR_INVALID_BOOLEAN);
return failure_indicator;
}
/*:199*//*200:*/
#line 1769 "./marpa.w"

int
marpa_g_prediction_symbol_activate(Marpa_Grammar g,
Marpa_Symbol_ID isy_id,
int reactivate)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 1775 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 1776 "./marpa.w"

/*1317:*/
#line 15694 "./marpa.w"

if(_MARPA_UNLIKELY(G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_PRECOMPUTED);
return failure_indicator;
}

/*:1317*/
#line 1777 "./marpa.w"

/*1319:*/
#line 15705 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1319*/
#line 1778 "./marpa.w"

/*1320:*/
#line 15712 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}
/*:1320*/
#line 1779 "./marpa.w"

switch(reactivate){
case 0:
ISYID_Prediction_Event_Starts_Active(isy_id)
= Boolean(reactivate);
return 0;
case 1:
if(!ISYID_is_Prediction_Event(isy_id)){


MARPA_ERROR(MARPA_ERR_SYMBOL_IS_NOT_COMPLETION_EVENT);
}
ISYID_Prediction_Event_Starts_Active(isy_id)
= Boolean(reactivate);
return 1;
}
MARPA_ERROR(MARPA_ERR_INVALID_BOOLEAN);
return failure_indicator;
}

/*:200*//*201:*/
#line 1799 "./marpa.w"

/*:201*//*207:*/
#line 1833 "./marpa.w"

Marpa_NSY_ID _marpa_g_isy_nsy(
Marpa_Grammar g,
Marpa_Symbol_ID isy_id)
{
ISY isy;
NSY nsy;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 1840 "./marpa.w"

/*1319:*/
#line 15705 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1319*/
#line 1841 "./marpa.w"

/*1320:*/
#line 15712 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}
/*:1320*/
#line 1842 "./marpa.w"

isy= ISY_by_ID(isy_id);
nsy= NSY_of_ISY(isy);
return nsy?ID_of_NSY(nsy):-1;
}

/*:207*//*211:*/
#line 1865 "./marpa.w"

Marpa_NSY_ID _marpa_g_isy_nulling_nsy(
Marpa_Grammar g,
Marpa_Symbol_ID isy_id)
{
ISY isy;
NSY nsy;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 1872 "./marpa.w"

/*1319:*/
#line 15705 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1319*/
#line 1873 "./marpa.w"

/*1320:*/
#line 15712 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}
/*:1320*/
#line 1874 "./marpa.w"

isy= ISY_by_ID(isy_id);
nsy= Nulling_NSY_of_ISY(isy);
return nsy?ID_of_NSY(nsy):-1;
}

/*:211*//*213:*/
#line 1886 "./marpa.w"

PRIVATE
NSY symbol_alias_create(GRAMMAR g,ISY symbol)
{
NSY alias_nsy= semantic_nsy_new(g,symbol);
ISY_is_Nulling(symbol)= 0;
ISY_is_Nullable(symbol)= 1;
NSY_is_Nulling(alias_nsy)= 1;
return alias_nsy;
}

/*:213*//*220:*/
#line 1944 "./marpa.w"

PRIVATE NSY
nsy_start(GRAMMAR g)
{
const NSY nsy= marpa_obs_new(g->t_obs,struct s_nsy,1);
ID_of_NSY(nsy)= MARPA_DSTACK_LENGTH((g)->t_nsy_stack);
*MARPA_DSTACK_PUSH((g)->t_nsy_stack,NSY)= nsy;
/*218:*/
#line 1936 "./marpa.w"

nsy->t_nulling_or_node.t_or_node_type= NULLING_TOKEN_OR_NODE;

nsy->t_unvalued_or_node.t_or_node_type= UNVALUED_TOKEN_OR_NODE;
nsy->t_unvalued_or_node.t_nsyid= ID_of_NSY(nsy);

/*:218*//*228:*/
#line 2012 "./marpa.w"
NSY_is_Start(nsy)= 0;
/*:228*//*231:*/
#line 2026 "./marpa.w"
NSY_is_LHS(nsy)= 0;
/*:231*//*234:*/
#line 2040 "./marpa.w"
NSY_is_Nulling(nsy)= 0;
/*:234*//*237:*/
#line 2057 "./marpa.w"
LHS_CIL_of_NSY(nsy)= NULL;

/*:237*//*239:*/
#line 2065 "./marpa.w"
NSY_is_Semantic(nsy)= 0;
/*:239*//*242:*/
#line 2088 "./marpa.w"
Source_ISY_of_NSY(nsy)= NULL;
/*:242*//*246:*/
#line 2113 "./marpa.w"

LHS_IRL_of_NSY(nsy)= NULL;
IRL_Offset_of_NSY(nsy)= -1;

/*:246*//*251:*/
#line 2164 "./marpa.w"

Rank_of_NSY(nsy)= Default_Rank_of_G(g)*EXTERNAL_RANK_FACTOR+MAXIMUM_CHAF_RANK;
/*:251*/
#line 1951 "./marpa.w"

return nsy;
}

/*:220*//*221:*/
#line 1957 "./marpa.w"

PRIVATE NSY
nsy_new(GRAMMAR g,ISY source)
{
const NSY new_nsy= nsy_start(g);
Source_ISY_of_NSY(new_nsy)= source;
Rank_of_NSY(new_nsy)= NSY_Rank_by_ISY(source);
return new_nsy;
}

/*:221*//*222:*/
#line 1969 "./marpa.w"

PRIVATE NSY
semantic_nsy_new(GRAMMAR g,ISY source)
{
const NSY new_nsy= nsy_new(g,source);
NSY_is_Semantic(new_nsy)= 1;
return new_nsy;
}

/*:222*//*223:*/
#line 1980 "./marpa.w"

PRIVATE NSY
nsy_clone(GRAMMAR g,ISY isy)
{
const NSY new_nsy= nsy_start(g);
Source_ISY_of_NSY(new_nsy)= isy;
NSY_is_Semantic(new_nsy)= 1;
Rank_of_NSY(new_nsy)= NSY_Rank_by_ISY(isy);
NSY_is_Nulling(new_nsy)= ISY_is_Nulling(isy);
return new_nsy;
}

/*:223*//*226:*/
#line 2002 "./marpa.w"

int _marpa_g_nsy_count(Marpa_Grammar g){
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 2004 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 2005 "./marpa.w"

return NSY_Count_of_G(g);
}

/*:226*//*229:*/
#line 2013 "./marpa.w"

int _marpa_g_nsy_is_start(Marpa_Grammar g,Marpa_NSY_ID nsy_id)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 2016 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 2017 "./marpa.w"

/*1318:*/
#line 15700 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1318*/
#line 2018 "./marpa.w"

/*1322:*/
#line 15723 "./marpa.w"

if(_MARPA_UNLIKELY(!nsy_is_valid(g,nsy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_NSYID);
return failure_indicator;
}
/*:1322*/
#line 2019 "./marpa.w"

return NSY_is_Start(NSY_by_ID(nsy_id));
}

/*:229*//*232:*/
#line 2027 "./marpa.w"

int _marpa_g_nsy_is_lhs(Marpa_Grammar g,Marpa_NSY_ID nsy_id)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 2030 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 2031 "./marpa.w"

/*1318:*/
#line 15700 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1318*/
#line 2032 "./marpa.w"

/*1322:*/
#line 15723 "./marpa.w"

if(_MARPA_UNLIKELY(!nsy_is_valid(g,nsy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_NSYID);
return failure_indicator;
}
/*:1322*/
#line 2033 "./marpa.w"

return NSY_is_LHS(NSY_by_ID(nsy_id));
}

/*:232*//*235:*/
#line 2041 "./marpa.w"

int _marpa_g_nsy_is_nulling(Marpa_Grammar g,Marpa_NSY_ID nsy_id)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 2044 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 2045 "./marpa.w"

/*1318:*/
#line 15700 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1318*/
#line 2046 "./marpa.w"

/*1322:*/
#line 15723 "./marpa.w"

if(_MARPA_UNLIKELY(!nsy_is_valid(g,nsy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_NSYID);
return failure_indicator;
}
/*:1322*/
#line 2047 "./marpa.w"

return NSY_is_Nulling(NSY_by_ID(nsy_id));
}

/*:235*//*240:*/
#line 2066 "./marpa.w"

int _marpa_g_nsy_is_semantic(
Marpa_Grammar g,
Marpa_NRL_ID nsy_id)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 2071 "./marpa.w"

/*1322:*/
#line 15723 "./marpa.w"

if(_MARPA_UNLIKELY(!nsy_is_valid(g,nsy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_NSYID);
return failure_indicator;
}
/*:1322*/
#line 2072 "./marpa.w"

return NSYID_is_Semantic(nsy_id);
}

/*:240*//*243:*/
#line 2089 "./marpa.w"

Marpa_Rule_ID _marpa_g_source_isy(
Marpa_Grammar g,
Marpa_NRL_ID nsy_id)
{
ISY source_isy;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 2095 "./marpa.w"

/*1322:*/
#line 15723 "./marpa.w"

if(_MARPA_UNLIKELY(!nsy_is_valid(g,nsy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_NSYID);
return failure_indicator;
}
/*:1322*/
#line 2096 "./marpa.w"

source_isy= Source_ISY_of_NSYID(nsy_id);
return ID_of_ISY(source_isy);
}

/*:243*//*248:*/
#line 2124 "./marpa.w"

Marpa_Rule_ID _marpa_g_nsy_lhs_irl(Marpa_Grammar g,Marpa_NSY_ID nsy_id)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 2127 "./marpa.w"

/*1322:*/
#line 15723 "./marpa.w"

if(_MARPA_UNLIKELY(!nsy_is_valid(g,nsy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_NSYID);
return failure_indicator;
}
/*:1322*/
#line 2128 "./marpa.w"

{
const NSY nsy= NSY_by_ID(nsy_id);
const IRL lhs_irl= LHS_IRL_of_NSY(nsy);
if(lhs_irl)
return ID_of_IRL(lhs_irl);
}
return-1;
}

/*:248*//*249:*/
#line 2148 "./marpa.w"

int _marpa_g_nsy_irl_offset(Marpa_Grammar g,Marpa_NSY_ID nsy_id)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 2151 "./marpa.w"

NSY nsy;
/*1322:*/
#line 15723 "./marpa.w"

if(_MARPA_UNLIKELY(!nsy_is_valid(g,nsy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_NSYID);
return failure_indicator;
}
/*:1322*/
#line 2153 "./marpa.w"

nsy= NSY_by_ID(nsy_id);
return IRL_Offset_of_NSY(nsy);
}

/*:249*//*252:*/
#line 2166 "./marpa.w"

Marpa_Rank _marpa_g_nsy_rank(
Marpa_Grammar g,
Marpa_NSY_ID nsy_id)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 2171 "./marpa.w"

/*1322:*/
#line 15723 "./marpa.w"

if(_MARPA_UNLIKELY(!nsy_is_valid(g,nsy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_NSYID);
return failure_indicator;
}
/*:1322*/
#line 2172 "./marpa.w"

return Rank_of_NSY(NSY_by_ID(nsy_id));
}

/*:252*//*258:*/
#line 2207 "./marpa.w"

PRIVATE
IRL irl_start(GRAMMAR g,const ISYID lhs,const ISYID*rhs,int length)
{
IRL xrl;
const size_t sizeof_irl= offsetof(struct s_irl,t_symbols)+
((size_t)length+1)*sizeof(xrl->t_symbols[0]);
xrl= marpa_obs_start(g->t_irl_obs,sizeof_irl,ALIGNOF(IRL));
Length_of_IRL(xrl)= length;
xrl->t_symbols[0]= lhs;
ISY_is_LHS(ISY_by_ID(lhs))= 1;
{
int i;
for(i= 0;i<length;i++)
{
xrl->t_symbols[i+1]= rhs[i];
}
}
return xrl;
}

PRIVATE
IRL irl_finish(GRAMMAR g,IRL rule)
{
/*277:*/
#line 2553 "./marpa.w"

rule->t_rank= Default_Rank_of_G(g);
/*:277*//*281:*/
#line 2602 "./marpa.w"

rule->t_null_ranks_high= 0;
/*:281*//*285:*/
#line 2642 "./marpa.w"

rule->t_is_bnf= 0;

/*:285*//*287:*/
#line 2648 "./marpa.w"

rule->t_is_sequence= 0;

/*:287*//*289:*/
#line 2662 "./marpa.w"

rule->t_minimum= -1;
/*:289*//*292:*/
#line 2688 "./marpa.w"

Separator_of_IRL(rule)= -1;
/*:292*//*297:*/
#line 2725 "./marpa.w"

rule->t_is_discard= 0;
/*:297*//*301:*/
#line 2765 "./marpa.w"

rule->t_is_proper_separation= 0;
/*:301*//*305:*/
#line 2786 "./marpa.w"

rule->t_is_loop= 0;
/*:305*//*308:*/
#line 2804 "./marpa.w"

IRL_is_Nulling(rule)= 0;
/*:308*//*311:*/
#line 2823 "./marpa.w"

IRL_is_Nullable(rule)= 0;
/*:311*//*315:*/
#line 2842 "./marpa.w"

IRL_is_Accessible(rule)= 1;
/*:315*//*318:*/
#line 2861 "./marpa.w"

IRL_is_Productive(rule)= 1;
/*:318*//*321:*/
#line 2880 "./marpa.w"

IRL_is_Used(rule)= 0;
/*:321*/
#line 2231 "./marpa.w"

rule_add(g,rule);
return rule;
}

PRIVATE_NOT_INLINE
RULE rule_new(GRAMMAR g,
const ISYID lhs,const ISYID*rhs,int length)
{
RULE rule= irl_start(g,lhs,rhs,length);
irl_finish(g,rule);
rule= marpa_obs_finish(g->t_irl_obs);
return rule;
}

/*:258*//*259:*/
#line 2247 "./marpa.w"

PRIVATE NRL
nrl_start(GRAMMAR g,int length)
{
NRL nrl;
const size_t sizeof_nrl= offsetof(struct s_nrl,t_nsyid_array)+
((size_t)length+1)*sizeof(nrl->t_nsyid_array[0]);


nrl= marpa__obs_alloc(g->t_obs,sizeof_nrl,ALIGNOF(NRL_Object));

ID_of_NRL(nrl)= MARPA_DSTACK_LENGTH((g)->t_nrl_stack);
Length_of_NRL(nrl)= length;
/*342:*/
#line 3017 "./marpa.w"

NRL_has_Virtual_LHS(nrl)= 0;
/*:342*//*345:*/
#line 3033 "./marpa.w"

NRL_has_Virtual_RHS(nrl)= 0;
/*:345*//*348:*/
#line 3052 "./marpa.w"

NRL_is_Right_Recursive(nrl)= 0;

/*:348*//*351:*/
#line 3063 "./marpa.w"
Real_SYM_Count_of_NRL(nrl)= 0;
/*:351*//*354:*/
#line 3081 "./marpa.w"
nrl->t_virtual_start= -1;
/*:354*//*357:*/
#line 3101 "./marpa.w"
nrl->t_virtual_end= -1;
/*:357*//*360:*/
#line 3123 "./marpa.w"
Source_IRL_of_NRL(nrl)= NULL;
/*:360*//*363:*/
#line 3150 "./marpa.w"

Rank_of_NRL(nrl)= Default_Rank_of_G(g)*EXTERNAL_RANK_FACTOR+MAXIMUM_CHAF_RANK;
/*:363*//*366:*/
#line 3172 "./marpa.w"

First_AHM_of_NRL(nrl)= NULL;

/*:366*//*410:*/
#line 4072 "./marpa.w"

NRL_is_CHAF(nrl)= 0;
/*:410*//*474:*/
#line 4989 "./marpa.w"

Last_Proper_SYMI_of_NRL(nrl)= -1;

/*:474*/
#line 2260 "./marpa.w"

*MARPA_DSTACK_PUSH((g)->t_nrl_stack,NRL)= nrl;
return nrl;
}

PRIVATE void
nrl_finish(GRAMMAR g,NRL nrl)
{
const NSY lhs_nsy= LHS_of_NRL(nrl);
NSY_is_LHS(lhs_nsy)= 1;
}

/*:259*//*261:*/
#line 2286 "./marpa.w"

Marpa_Rule_ID
marpa_g_rule_new(Marpa_Grammar g,
Marpa_Symbol_ID lhs_id,Marpa_Symbol_ID*rhs_ids,int length)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 2291 "./marpa.w"

Marpa_Rule_ID rule_id;
RULE rule;
/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 2294 "./marpa.w"

/*1317:*/
#line 15694 "./marpa.w"

if(_MARPA_UNLIKELY(G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_PRECOMPUTED);
return failure_indicator;
}

/*:1317*/
#line 2295 "./marpa.w"

if(_MARPA_UNLIKELY(length> MAX_RHS_LENGTH))
{
MARPA_ERROR(MARPA_ERR_RHS_TOO_LONG);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!isy_id_is_valid(g,lhs_id)))
{
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
{
int rh_index;
for(rh_index= 0;rh_index<length;rh_index++)
{
const ISYID rhs_id= rhs_ids[rh_index];
if(_MARPA_UNLIKELY(!isy_id_is_valid(g,rhs_id)))
{
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
}
}
{
const ISY lhs= ISY_by_ID(lhs_id);
if(_MARPA_UNLIKELY(ISY_is_Sequence_LHS(lhs)))
{
MARPA_ERROR(MARPA_ERR_SEQUENCE_LHS_NOT_UNIQUE);
return failure_indicator;
}
}
rule= irl_start(g,lhs_id,rhs_ids,length);
if(_MARPA_UNLIKELY(_marpa_avl_insert(g->t_irl_tree,rule)!=NULL))
{
MARPA_ERROR(MARPA_ERR_DUPLICATE_RULE);
marpa_obs_reject(g->t_irl_obs);
return failure_indicator;
}
rule= irl_finish(g,rule);
rule= marpa_obs_finish(g->t_irl_obs);
IRL_is_BNF(rule)= 1;
rule_id= rule->t_id;
return rule_id;
}

/*:261*//*262:*/
#line 2340 "./marpa.w"

Marpa_Rule_ID marpa_g_sequence_new(Marpa_Grammar g,
Marpa_Symbol_ID lhs_id,Marpa_Symbol_ID rhs_id,Marpa_Symbol_ID separator_id,
int min,int flags)
{
RULE original_rule;
RULEID original_rule_id= -2;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 2347 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 2348 "./marpa.w"

/*1317:*/
#line 15694 "./marpa.w"

if(_MARPA_UNLIKELY(G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_PRECOMPUTED);
return failure_indicator;
}

/*:1317*/
#line 2349 "./marpa.w"

/*264:*/
#line 2380 "./marpa.w"

{
if(separator_id!=-1)
{
if(_MARPA_UNLIKELY(!isy_id_is_valid(g,separator_id)))
{
MARPA_ERROR(MARPA_ERR_BAD_SEPARATOR);
goto FAILURE;
}
}
if(_MARPA_UNLIKELY(!isy_id_is_valid(g,lhs_id)))
{
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
goto FAILURE;
}
{
const ISY lhs= ISY_by_ID(lhs_id);
if(_MARPA_UNLIKELY(ISY_is_LHS(lhs)))
{
MARPA_ERROR(MARPA_ERR_SEQUENCE_LHS_NOT_UNIQUE);
goto FAILURE;
}
}
if(_MARPA_UNLIKELY(!isy_id_is_valid(g,rhs_id)))
{
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
goto FAILURE;
}
}

/*:264*/
#line 2350 "./marpa.w"

/*263:*/
#line 2358 "./marpa.w"

{
original_rule= rule_new(g,lhs_id,&rhs_id,1);
original_rule_id= original_rule->t_id;
if(separator_id>=0)
Separator_of_IRL(original_rule)= separator_id;
Minimum_of_IRL(original_rule)= min;
IRL_is_Sequence(original_rule)= 1;
original_rule->t_is_discard= !(flags&MARPA_KEEP_SEPARATION)
&&separator_id>=0;
if(flags&MARPA_PROPER_SEPARATION)
{
IRL_is_Proper_Separation(original_rule)= 1;
}
ISY_is_Sequence_LHS(ISY_by_ID(lhs_id))= 1;
ISY_by_ID(rhs_id)->t_is_counted= 1;
if(separator_id>=0)
{
ISY_by_ID(separator_id)->t_is_counted= 1;
}
}

/*:263*/
#line 2351 "./marpa.w"

return original_rule_id;
FAILURE:
return failure_indicator;
}

/*:262*//*266:*/
#line 2433 "./marpa.w"

PRIVATE_NOT_INLINE int
duplicate_rule_cmp(const void*ap,const void*bp,void*param UNUSED)
{
IRL xrl1= (IRL)ap;
IRL xrl2= (IRL)bp;
int diff= LHS_ID_of_IRL(xrl2)-LHS_ID_of_IRL(xrl1);
if(diff)
return diff;
{




int ix;
const int length= Length_of_IRL(xrl1);
diff= Length_of_IRL(xrl2)-length;
if(diff)
return diff;
for(ix= 0;ix<length;ix++)
{
diff= RHS_ID_of_IRL(xrl2,ix)-RHS_ID_of_IRL(xrl1,ix);
if(diff)
return diff;
}
}
return 0;
}

/*:266*//*269:*/
#line 2489 "./marpa.w"

PRIVATE Marpa_Symbol_ID rule_lhs_get(RULE rule)
{
return rule->t_symbols[0];}
/*:269*//*270:*/
#line 2493 "./marpa.w"

Marpa_Symbol_ID marpa_g_rule_lhs(Marpa_Grammar g,Marpa_Rule_ID irl_id){
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 2495 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 2496 "./marpa.w"

/*1328:*/
#line 15761 "./marpa.w"

if(_MARPA_UNLIKELY(IRLID_is_Malformed(irl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_RULE_ID);
return failure_indicator;
}

/*:1328*/
#line 2497 "./marpa.w"

/*1326:*/
#line 15749 "./marpa.w"

if(_MARPA_UNLIKELY(!IRLID_of_G_Exists(irl_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_RULE_ID);
return-1;
}

/*:1326*/
#line 2498 "./marpa.w"

return rule_lhs_get(IRL_by_ID(irl_id));
}
/*:270*//*271:*/
#line 2501 "./marpa.w"

PRIVATE Marpa_Symbol_ID*rule_rhs_get(RULE rule)
{
return rule->t_symbols+1;}
/*:271*//*272:*/
#line 2505 "./marpa.w"

Marpa_Symbol_ID marpa_g_rule_rhs(Marpa_Grammar g,Marpa_Rule_ID irl_id,int ix){
RULE rule;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 2508 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 2509 "./marpa.w"

/*1328:*/
#line 15761 "./marpa.w"

if(_MARPA_UNLIKELY(IRLID_is_Malformed(irl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_RULE_ID);
return failure_indicator;
}

/*:1328*/
#line 2510 "./marpa.w"

/*1326:*/
#line 15749 "./marpa.w"

if(_MARPA_UNLIKELY(!IRLID_of_G_Exists(irl_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_RULE_ID);
return-1;
}

/*:1326*/
#line 2511 "./marpa.w"

rule= IRL_by_ID(irl_id);
if(ix<0){
MARPA_ERROR(MARPA_ERR_RHS_IX_NEGATIVE);
return failure_indicator;
}
if(Length_of_IRL(rule)<=ix){
MARPA_ERROR(MARPA_ERR_RHS_IX_OOB);
return failure_indicator;
}
return RHS_ID_of_RULE(rule,ix);
}

/*:272*//*273:*/
#line 2524 "./marpa.w"

int marpa_g_rule_length(Marpa_Grammar g,Marpa_Rule_ID irl_id){
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 2526 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 2527 "./marpa.w"

/*1328:*/
#line 15761 "./marpa.w"

if(_MARPA_UNLIKELY(IRLID_is_Malformed(irl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_RULE_ID);
return failure_indicator;
}

/*:1328*/
#line 2528 "./marpa.w"

/*1326:*/
#line 15749 "./marpa.w"

if(_MARPA_UNLIKELY(!IRLID_of_G_Exists(irl_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_RULE_ID);
return-1;
}

/*:1326*/
#line 2529 "./marpa.w"

return Length_of_IRL(IRL_by_ID(irl_id));
}

/*:273*//*278:*/
#line 2556 "./marpa.w"

int marpa_g_rule_rank(Marpa_Grammar g,
Marpa_Rule_ID irl_id)
{
IRL xrl;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 2561 "./marpa.w"

clear_error(g);
/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 2563 "./marpa.w"

/*1328:*/
#line 15761 "./marpa.w"

if(_MARPA_UNLIKELY(IRLID_is_Malformed(irl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_RULE_ID);
return failure_indicator;
}

/*:1328*/
#line 2564 "./marpa.w"

/*1327:*/
#line 15755 "./marpa.w"

if(_MARPA_UNLIKELY(!IRLID_of_G_Exists(irl_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_RULE_ID);
return failure_indicator;
}
/*:1327*/
#line 2565 "./marpa.w"

clear_error(g);
xrl= IRL_by_ID(irl_id);
return Rank_of_IRL(xrl);
}
/*:278*//*279:*/
#line 2570 "./marpa.w"

int marpa_g_rule_rank_set(
Marpa_Grammar g,Marpa_Rule_ID irl_id,Marpa_Rank rank)
{
IRL xrl;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 2575 "./marpa.w"

clear_error(g);
/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 2577 "./marpa.w"

/*1317:*/
#line 15694 "./marpa.w"

if(_MARPA_UNLIKELY(G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_PRECOMPUTED);
return failure_indicator;
}

/*:1317*/
#line 2578 "./marpa.w"

/*1328:*/
#line 15761 "./marpa.w"

if(_MARPA_UNLIKELY(IRLID_is_Malformed(irl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_RULE_ID);
return failure_indicator;
}

/*:1328*/
#line 2579 "./marpa.w"

/*1327:*/
#line 15755 "./marpa.w"

if(_MARPA_UNLIKELY(!IRLID_of_G_Exists(irl_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_RULE_ID);
return failure_indicator;
}
/*:1327*/
#line 2580 "./marpa.w"

xrl= IRL_by_ID(irl_id);
if(_MARPA_UNLIKELY(rank<MINIMUM_RANK))
{
MARPA_ERROR(MARPA_ERR_RANK_TOO_LOW);
return failure_indicator;
}
if(_MARPA_UNLIKELY(rank> MAXIMUM_RANK))
{
MARPA_ERROR(MARPA_ERR_RANK_TOO_HIGH);
return failure_indicator;
}
return Rank_of_IRL(xrl)= rank;
}

/*:279*//*282:*/
#line 2606 "./marpa.w"

int marpa_g_rule_null_high(Marpa_Grammar g,
Marpa_Rule_ID irl_id)
{
IRL xrl;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 2611 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 2612 "./marpa.w"

/*1328:*/
#line 15761 "./marpa.w"

if(_MARPA_UNLIKELY(IRLID_is_Malformed(irl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_RULE_ID);
return failure_indicator;
}

/*:1328*/
#line 2613 "./marpa.w"

/*1326:*/
#line 15749 "./marpa.w"

if(_MARPA_UNLIKELY(!IRLID_of_G_Exists(irl_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_RULE_ID);
return-1;
}

/*:1326*/
#line 2614 "./marpa.w"

xrl= IRL_by_ID(irl_id);
return Null_Ranks_High_of_RULE(xrl);
}
/*:282*//*283:*/
#line 2618 "./marpa.w"

int marpa_g_rule_null_high_set(
Marpa_Grammar g,Marpa_Rule_ID irl_id,int flag)
{
IRL xrl;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 2623 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 2624 "./marpa.w"

/*1317:*/
#line 15694 "./marpa.w"

if(_MARPA_UNLIKELY(G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_PRECOMPUTED);
return failure_indicator;
}

/*:1317*/
#line 2625 "./marpa.w"

/*1328:*/
#line 15761 "./marpa.w"

if(_MARPA_UNLIKELY(IRLID_is_Malformed(irl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_RULE_ID);
return failure_indicator;
}

/*:1328*/
#line 2626 "./marpa.w"

/*1326:*/
#line 15749 "./marpa.w"

if(_MARPA_UNLIKELY(!IRLID_of_G_Exists(irl_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_RULE_ID);
return-1;
}

/*:1326*/
#line 2627 "./marpa.w"

xrl= IRL_by_ID(irl_id);
if(_MARPA_UNLIKELY(flag<0||flag> 1))
{
MARPA_ERROR(MARPA_ERR_INVALID_BOOLEAN);
return failure_indicator;
}
return Null_Ranks_High_of_RULE(xrl)= Boolean(flag);
}

/*:283*//*290:*/
#line 2664 "./marpa.w"

int marpa_g_sequence_min(
Marpa_Grammar g,
Marpa_Rule_ID irl_id)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 2669 "./marpa.w"

IRL xrl;
/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 2671 "./marpa.w"

/*1328:*/
#line 15761 "./marpa.w"

if(_MARPA_UNLIKELY(IRLID_is_Malformed(irl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_RULE_ID);
return failure_indicator;
}

/*:1328*/
#line 2672 "./marpa.w"

/*1327:*/
#line 15755 "./marpa.w"

if(_MARPA_UNLIKELY(!IRLID_of_G_Exists(irl_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_RULE_ID);
return failure_indicator;
}
/*:1327*/
#line 2673 "./marpa.w"

xrl= IRL_by_ID(irl_id);
if(!IRL_is_Sequence(xrl))
{
MARPA_ERROR(MARPA_ERR_NOT_A_SEQUENCE);
return-1;
}
return Minimum_of_IRL(xrl);
}

/*:290*//*293:*/
#line 2690 "./marpa.w"

Marpa_Symbol_ID marpa_g_sequence_separator(
Marpa_Grammar g,
Marpa_Rule_ID irl_id)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 2695 "./marpa.w"

IRL xrl;
/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 2697 "./marpa.w"

/*1328:*/
#line 15761 "./marpa.w"

if(_MARPA_UNLIKELY(IRLID_is_Malformed(irl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_RULE_ID);
return failure_indicator;
}

/*:1328*/
#line 2698 "./marpa.w"

/*1327:*/
#line 15755 "./marpa.w"

if(_MARPA_UNLIKELY(!IRLID_of_G_Exists(irl_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_RULE_ID);
return failure_indicator;
}
/*:1327*/
#line 2699 "./marpa.w"

xrl= IRL_by_ID(irl_id);
if(!IRL_is_Sequence(xrl))
{
MARPA_ERROR(MARPA_ERR_NOT_A_SEQUENCE);
return failure_indicator;
}
return Separator_of_IRL(xrl);
}

/*:293*//*298:*/
#line 2727 "./marpa.w"

int _marpa_g_rule_is_keep_separation(
Marpa_Grammar g,
Marpa_Rule_ID irl_id)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 2732 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 2733 "./marpa.w"

/*1328:*/
#line 15761 "./marpa.w"

if(_MARPA_UNLIKELY(IRLID_is_Malformed(irl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_RULE_ID);
return failure_indicator;
}

/*:1328*/
#line 2734 "./marpa.w"

/*1326:*/
#line 15749 "./marpa.w"

if(_MARPA_UNLIKELY(!IRLID_of_G_Exists(irl_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_RULE_ID);
return-1;
}

/*:1326*/
#line 2735 "./marpa.w"

return!IRL_by_ID(irl_id)->t_is_discard;
}

/*:298*//*302:*/
#line 2767 "./marpa.w"

int marpa_g_rule_is_proper_separation(
Marpa_Grammar g,
Marpa_Rule_ID irl_id)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 2772 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 2773 "./marpa.w"

/*1328:*/
#line 15761 "./marpa.w"

if(_MARPA_UNLIKELY(IRLID_is_Malformed(irl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_RULE_ID);
return failure_indicator;
}

/*:1328*/
#line 2774 "./marpa.w"

/*1326:*/
#line 15749 "./marpa.w"

if(_MARPA_UNLIKELY(!IRLID_of_G_Exists(irl_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_RULE_ID);
return-1;
}

/*:1326*/
#line 2775 "./marpa.w"

return IRL_is_Proper_Separation(IRL_by_ID(irl_id));
}

/*:302*//*306:*/
#line 2788 "./marpa.w"

int marpa_g_rule_is_loop(Marpa_Grammar g,Marpa_Rule_ID irl_id)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 2791 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 2792 "./marpa.w"

/*1318:*/
#line 15700 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1318*/
#line 2793 "./marpa.w"

/*1328:*/
#line 15761 "./marpa.w"

if(_MARPA_UNLIKELY(IRLID_is_Malformed(irl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_RULE_ID);
return failure_indicator;
}

/*:1328*/
#line 2794 "./marpa.w"

/*1326:*/
#line 15749 "./marpa.w"

if(_MARPA_UNLIKELY(!IRLID_of_G_Exists(irl_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_RULE_ID);
return-1;
}

/*:1326*/
#line 2795 "./marpa.w"

/*1318:*/
#line 15700 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1318*/
#line 2796 "./marpa.w"

return IRL_by_ID(irl_id)->t_is_loop;
}

/*:306*//*309:*/
#line 2806 "./marpa.w"

int marpa_g_rule_is_nulling(Marpa_Grammar g,Marpa_Rule_ID irl_id)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 2809 "./marpa.w"

IRL xrl;
/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 2811 "./marpa.w"

/*1318:*/
#line 15700 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1318*/
#line 2812 "./marpa.w"

/*1328:*/
#line 15761 "./marpa.w"

if(_MARPA_UNLIKELY(IRLID_is_Malformed(irl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_RULE_ID);
return failure_indicator;
}

/*:1328*/
#line 2813 "./marpa.w"

/*1326:*/
#line 15749 "./marpa.w"

if(_MARPA_UNLIKELY(!IRLID_of_G_Exists(irl_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_RULE_ID);
return-1;
}

/*:1326*/
#line 2814 "./marpa.w"

xrl= IRL_by_ID(irl_id);
return IRL_is_Nulling(xrl);
}

/*:309*//*312:*/
#line 2825 "./marpa.w"

int marpa_g_rule_is_nullable(Marpa_Grammar g,Marpa_Rule_ID irl_id)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 2828 "./marpa.w"

IRL xrl;
/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 2830 "./marpa.w"

/*1318:*/
#line 15700 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1318*/
#line 2831 "./marpa.w"

/*1328:*/
#line 15761 "./marpa.w"

if(_MARPA_UNLIKELY(IRLID_is_Malformed(irl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_RULE_ID);
return failure_indicator;
}

/*:1328*/
#line 2832 "./marpa.w"

/*1326:*/
#line 15749 "./marpa.w"

if(_MARPA_UNLIKELY(!IRLID_of_G_Exists(irl_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_RULE_ID);
return-1;
}

/*:1326*/
#line 2833 "./marpa.w"

xrl= IRL_by_ID(irl_id);
return IRL_is_Nullable(xrl);
}

/*:312*//*316:*/
#line 2844 "./marpa.w"

int marpa_g_rule_is_accessible(Marpa_Grammar g,Marpa_Rule_ID irl_id)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 2847 "./marpa.w"

IRL xrl;
/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 2849 "./marpa.w"

/*1318:*/
#line 15700 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1318*/
#line 2850 "./marpa.w"

/*1328:*/
#line 15761 "./marpa.w"

if(_MARPA_UNLIKELY(IRLID_is_Malformed(irl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_RULE_ID);
return failure_indicator;
}

/*:1328*/
#line 2851 "./marpa.w"

/*1326:*/
#line 15749 "./marpa.w"

if(_MARPA_UNLIKELY(!IRLID_of_G_Exists(irl_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_RULE_ID);
return-1;
}

/*:1326*/
#line 2852 "./marpa.w"

xrl= IRL_by_ID(irl_id);
return IRL_is_Accessible(xrl);
}

/*:316*//*319:*/
#line 2863 "./marpa.w"

int marpa_g_rule_is_productive(Marpa_Grammar g,Marpa_Rule_ID irl_id)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 2866 "./marpa.w"

IRL xrl;
/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 2868 "./marpa.w"

/*1318:*/
#line 15700 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1318*/
#line 2869 "./marpa.w"

/*1328:*/
#line 15761 "./marpa.w"

if(_MARPA_UNLIKELY(IRLID_is_Malformed(irl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_RULE_ID);
return failure_indicator;
}

/*:1328*/
#line 2870 "./marpa.w"

/*1326:*/
#line 15749 "./marpa.w"

if(_MARPA_UNLIKELY(!IRLID_of_G_Exists(irl_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_RULE_ID);
return-1;
}

/*:1326*/
#line 2871 "./marpa.w"

xrl= IRL_by_ID(irl_id);
return IRL_is_Productive(xrl);
}

/*:319*//*322:*/
#line 2882 "./marpa.w"

int
_marpa_g_rule_is_used(Marpa_Grammar g,Marpa_Rule_ID irl_id)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 2886 "./marpa.w"

/*1328:*/
#line 15761 "./marpa.w"

if(_MARPA_UNLIKELY(IRLID_is_Malformed(irl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_RULE_ID);
return failure_indicator;
}

/*:1328*/
#line 2887 "./marpa.w"

/*1326:*/
#line 15749 "./marpa.w"

if(_MARPA_UNLIKELY(!IRLID_of_G_Exists(irl_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_RULE_ID);
return-1;
}

/*:1326*/
#line 2888 "./marpa.w"

return IRL_is_Used(IRL_by_ID(irl_id));
}

/*:322*//*324:*/
#line 2895 "./marpa.w"

Marpa_Rule_ID
_marpa_g_nrl_semantic_equivalent(Marpa_Grammar g,Marpa_NRL_ID nrl_id)
{
NRL nrl;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 2900 "./marpa.w"

/*1325:*/
#line 15741 "./marpa.w"

if(_MARPA_UNLIKELY(!NRLID_of_G_is_Valid(nrl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_NRLID);
return failure_indicator;
}
/*:1325*/
#line 2901 "./marpa.w"

nrl= NRL_by_ID(nrl_id);
if(NRL_has_Virtual_LHS(nrl))return-1;
return ID_of_IRL(Source_IRL_of_NRL(nrl));
}

/*:324*//*333:*/
#line 2942 "./marpa.w"

Marpa_NSY_ID _marpa_g_nrl_lhs(Marpa_Grammar g,Marpa_NRL_ID nrl_id){
NRL nrl;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 2945 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 2946 "./marpa.w"

/*1318:*/
#line 15700 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1318*/
#line 2947 "./marpa.w"

/*1325:*/
#line 15741 "./marpa.w"

if(_MARPA_UNLIKELY(!NRLID_of_G_is_Valid(nrl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_NRLID);
return failure_indicator;
}
/*:1325*/
#line 2948 "./marpa.w"

nrl= NRL_by_ID(nrl_id);
return LHSID_of_NRL(nrl);
}

/*:333*//*335:*/
#line 2955 "./marpa.w"

Marpa_NSY_ID _marpa_g_nrl_rhs(Marpa_Grammar g,Marpa_NRL_ID nrl_id,int ix){
NRL nrl;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 2958 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 2959 "./marpa.w"

/*1318:*/
#line 15700 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1318*/
#line 2960 "./marpa.w"

/*1325:*/
#line 15741 "./marpa.w"

if(_MARPA_UNLIKELY(!NRLID_of_G_is_Valid(nrl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_NRLID);
return failure_indicator;
}
/*:1325*/
#line 2961 "./marpa.w"

nrl= NRL_by_ID(nrl_id);
if(Length_of_NRL(nrl)<=ix)return-1;
return RHSID_of_NRL(nrl,ix);
}

/*:335*//*337:*/
#line 2969 "./marpa.w"

int _marpa_g_nrl_length(Marpa_Grammar g,Marpa_NRL_ID nrl_id){
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 2971 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 2972 "./marpa.w"

/*1318:*/
#line 15700 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1318*/
#line 2973 "./marpa.w"

/*1325:*/
#line 15741 "./marpa.w"

if(_MARPA_UNLIKELY(!NRLID_of_G_is_Valid(nrl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_NRLID);
return failure_indicator;
}
/*:1325*/
#line 2974 "./marpa.w"

return Length_of_NRL(NRL_by_ID(nrl_id));
}

/*:337*//*343:*/
#line 3019 "./marpa.w"

int _marpa_g_nrl_is_virtual_lhs(
Marpa_Grammar g,
Marpa_NRL_ID nrl_id)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 3024 "./marpa.w"

/*1318:*/
#line 15700 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1318*/
#line 3025 "./marpa.w"

/*1325:*/
#line 15741 "./marpa.w"

if(_MARPA_UNLIKELY(!NRLID_of_G_is_Valid(nrl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_NRLID);
return failure_indicator;
}
/*:1325*/
#line 3026 "./marpa.w"

return NRL_has_Virtual_LHS(NRL_by_ID(nrl_id));
}

/*:343*//*346:*/
#line 3035 "./marpa.w"

int _marpa_g_nrl_is_virtual_rhs(
Marpa_Grammar g,
Marpa_NRL_ID nrl_id)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 3040 "./marpa.w"

/*1318:*/
#line 15700 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1318*/
#line 3041 "./marpa.w"

/*1325:*/
#line 15741 "./marpa.w"

if(_MARPA_UNLIKELY(!NRLID_of_G_is_Valid(nrl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_NRLID);
return failure_indicator;
}
/*:1325*/
#line 3042 "./marpa.w"

return NRL_has_Virtual_RHS(NRL_by_ID(nrl_id));
}

/*:346*//*352:*/
#line 3064 "./marpa.w"

int _marpa_g_real_symbol_count(
Marpa_Grammar g,
Marpa_NRL_ID nrl_id)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 3069 "./marpa.w"

/*1318:*/
#line 15700 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1318*/
#line 3070 "./marpa.w"

/*1325:*/
#line 15741 "./marpa.w"

if(_MARPA_UNLIKELY(!NRLID_of_G_is_Valid(nrl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_NRLID);
return failure_indicator;
}
/*:1325*/
#line 3071 "./marpa.w"

return Real_SYM_Count_of_NRL(NRL_by_ID(nrl_id));
}

/*:352*//*355:*/
#line 3082 "./marpa.w"

int _marpa_g_virtual_start(
Marpa_Grammar g,
Marpa_NRL_ID nrl_id)
{
NRL nrl;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 3088 "./marpa.w"

/*1318:*/
#line 15700 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1318*/
#line 3089 "./marpa.w"

/*1325:*/
#line 15741 "./marpa.w"

if(_MARPA_UNLIKELY(!NRLID_of_G_is_Valid(nrl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_NRLID);
return failure_indicator;
}
/*:1325*/
#line 3090 "./marpa.w"

nrl= NRL_by_ID(nrl_id);
return Virtual_Start_of_NRL(nrl);
}

/*:355*//*358:*/
#line 3102 "./marpa.w"

int _marpa_g_virtual_end(
Marpa_Grammar g,
Marpa_NRL_ID nrl_id)
{
NRL nrl;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 3108 "./marpa.w"

/*1318:*/
#line 15700 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1318*/
#line 3109 "./marpa.w"

/*1325:*/
#line 15741 "./marpa.w"

if(_MARPA_UNLIKELY(!NRLID_of_G_is_Valid(nrl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_NRLID);
return failure_indicator;
}
/*:1325*/
#line 3110 "./marpa.w"

nrl= NRL_by_ID(nrl_id);
return Virtual_End_of_NRL(nrl);
}

/*:358*//*361:*/
#line 3124 "./marpa.w"

Marpa_Rule_ID _marpa_g_source_irl(
Marpa_Grammar g,
Marpa_NRL_ID nrl_id)
{
IRL source_irl;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 3130 "./marpa.w"

/*1325:*/
#line 15741 "./marpa.w"

if(_MARPA_UNLIKELY(!NRLID_of_G_is_Valid(nrl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_NRLID);
return failure_indicator;
}
/*:1325*/
#line 3131 "./marpa.w"

source_irl= Source_IRL_of_NRL(NRL_by_ID(nrl_id));
return source_irl?ID_of_IRL(source_irl):-1;
}

/*:361*//*364:*/
#line 3152 "./marpa.w"

Marpa_Rank _marpa_g_nrl_rank(
Marpa_Grammar g,
Marpa_NRL_ID nrl_id)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 3157 "./marpa.w"

/*1325:*/
#line 15741 "./marpa.w"

if(_MARPA_UNLIKELY(!NRLID_of_G_is_Valid(nrl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_NRLID);
return failure_indicator;
}
/*:1325*/
#line 3158 "./marpa.w"

return Rank_of_NRL(NRL_by_ID(nrl_id));
}

/*:364*//*368:*/
#line 3192 "./marpa.w"

int marpa_g_precompute(Marpa_Grammar g)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 3195 "./marpa.w"

int return_value= failure_indicator;
struct marpa_obstack*obs_precompute= marpa_obs_init;
/*373:*/
#line 3321 "./marpa.w"

IRLID irl_count= IRL_Count_of_G(g);
ISYID pre_census_isy_count= ISY_Count_of_G(g);
ISYID post_census_isy_count= -1;

/*:373*//*377:*/
#line 3355 "./marpa.w"

ISYID start_isy_id= g->t_start_isy_id;

/*:377*//*390:*/
#line 3658 "./marpa.w"

Bit_Matrix reach_matrix= NULL;

/*:390*/
#line 3198 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 3199 "./marpa.w"

G_EVENTS_CLEAR(g);
/*374:*/
#line 3326 "./marpa.w"

if(_MARPA_UNLIKELY(irl_count<=0)){
MARPA_ERROR(MARPA_ERR_NO_RULES);
goto FAILURE;
}

/*:374*/
#line 3201 "./marpa.w"

/*1317:*/
#line 15694 "./marpa.w"

if(_MARPA_UNLIKELY(G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_PRECOMPUTED);
return failure_indicator;
}

/*:1317*/
#line 3202 "./marpa.w"

/*376:*/
#line 3336 "./marpa.w"

{
if(_MARPA_UNLIKELY(start_isy_id<0))
{
MARPA_ERROR(MARPA_ERR_NO_START_SYMBOL);
goto FAILURE;
}
if(_MARPA_UNLIKELY(!isy_id_is_valid(g,start_isy_id)))
{
MARPA_ERROR(MARPA_ERR_INVALID_START_SYMBOL);
goto FAILURE;
}
if(_MARPA_UNLIKELY(!ISY_is_LHS(ISY_by_ID(start_isy_id))))
{
MARPA_ERROR(MARPA_ERR_START_NOT_LHS);
goto FAILURE;
}
}

/*:376*/
#line 3203 "./marpa.w"





MARPA_OFF_DEBUG3("At %s, ahm count is %ld",STRLOC,(long)(g->t_ahm_count));

/*122:*/
#line 1134 "./marpa.w"

{
_marpa_avl_destroy((g)->t_irl_tree);
(g)->t_irl_tree= NULL;
}
/*:122*/
#line 3210 "./marpa.w"




{
/*382:*/
#line 3537 "./marpa.w"

Bit_Vector terminal_v= NULL;

/*:382*//*383:*/
#line 3540 "./marpa.w"

Bit_Vector lhs_v= NULL;
Bit_Vector empty_lhs_v= NULL;

/*:383*//*384:*/
#line 3545 "./marpa.w"

RULEID**irl_list_x_rh_sym= NULL;
RULEID**irl_list_x_lh_sym= NULL;

/*:384*//*388:*/
#line 3604 "./marpa.w"

Bit_Vector productive_v= NULL;
Bit_Vector nullable_v= NULL;

/*:388*/
#line 3215 "./marpa.w"

/*372:*/
#line 3306 "./marpa.w"

{
/*380:*/
#line 3379 "./marpa.w"

{
Marpa_Rule_ID rule_id;



const MARPA_AVL_TREE rhs_avl_tree= _marpa_avl_create(sym_rule_cmp,NULL);


struct sym_rule_pair*const p_rh_sym_rule_pair_base= 
marpa_obs_new(MARPA_AVL_OBSTACK(rhs_avl_tree),struct sym_rule_pair,
(size_t)External_Size_of_G(g));
struct sym_rule_pair*p_rh_sym_rule_pairs= p_rh_sym_rule_pair_base;



const MARPA_AVL_TREE lhs_avl_tree= _marpa_avl_create(sym_rule_cmp,NULL);
struct sym_rule_pair*const p_lh_sym_rule_pair_base= 
marpa_obs_new(MARPA_AVL_OBSTACK(lhs_avl_tree),struct sym_rule_pair,
(size_t)irl_count);
struct sym_rule_pair*p_lh_sym_rule_pairs= p_lh_sym_rule_pair_base;

lhs_v= bv_obs_create(obs_precompute,pre_census_isy_count);
empty_lhs_v= bv_obs_shadow(obs_precompute,lhs_v);
for(rule_id= 0;rule_id<irl_count;rule_id++)
{
const IRL rule= IRL_by_ID(rule_id);
const Marpa_Symbol_ID lhs_id= LHS_ID_of_RULE(rule);
const int rule_length= Length_of_IRL(rule);
const int is_sequence= IRL_is_Sequence(rule);

bv_bit_set(lhs_v,lhs_id);



p_lh_sym_rule_pairs->t_symid= lhs_id;
p_lh_sym_rule_pairs->t_ruleid= rule_id;
_marpa_avl_insert(lhs_avl_tree,p_lh_sym_rule_pairs);
p_lh_sym_rule_pairs++;

if(is_sequence)
{
const ISYID separator_id= Separator_of_IRL(rule);
if(Minimum_of_IRL(rule)<=0)
{
bv_bit_set(empty_lhs_v,lhs_id);
}
if(separator_id>=0){
p_rh_sym_rule_pairs->t_symid= separator_id;
p_rh_sym_rule_pairs->t_ruleid= rule_id;
_marpa_avl_insert(rhs_avl_tree,p_rh_sym_rule_pairs);
p_rh_sym_rule_pairs++;
}
}

if(rule_length<=0)
{
bv_bit_set(empty_lhs_v,lhs_id);
}
else
{
int rhs_ix;
for(rhs_ix= 0;rhs_ix<rule_length;rhs_ix++)
{
p_rh_sym_rule_pairs->t_symid= RHS_ID_of_RULE(rule,rhs_ix);
p_rh_sym_rule_pairs->t_ruleid= rule_id;
_marpa_avl_insert(rhs_avl_tree,p_rh_sym_rule_pairs);
p_rh_sym_rule_pairs++;
}
}
}
{
MARPA_AVL_TRAV traverser;
struct sym_rule_pair*pair;
ISYID seen_symid= -1;
RULEID*const rule_data_base= 
marpa_obs_new(obs_precompute,RULEID,(size_t)External_Size_of_G(g));
RULEID*p_rule_data= rule_data_base;
traverser= _marpa_avl_t_init(rhs_avl_tree);



irl_list_x_rh_sym= 
marpa_obs_new(obs_precompute,RULEID*,(size_t)pre_census_isy_count+1);
for(pair= _marpa_avl_t_first(traverser);pair;
pair= (struct sym_rule_pair*)_marpa_avl_t_next(traverser))
{
const ISYID current_symid= pair->t_symid;
while(seen_symid<current_symid)
irl_list_x_rh_sym[++seen_symid]= p_rule_data;
*p_rule_data++= pair->t_ruleid;
}
while(++seen_symid<=pre_census_isy_count)
irl_list_x_rh_sym[seen_symid]= p_rule_data;
_marpa_avl_destroy(rhs_avl_tree);
}

{
MARPA_AVL_TRAV traverser;
struct sym_rule_pair*pair;
ISYID seen_symid= -1;
RULEID*const rule_data_base= 
marpa_obs_new(obs_precompute,RULEID,(size_t)irl_count);
RULEID*p_rule_data= rule_data_base;
traverser= _marpa_avl_t_init(lhs_avl_tree);


irl_list_x_lh_sym= 
marpa_obs_new(obs_precompute,RULEID*,(size_t)pre_census_isy_count+1);
for(pair= _marpa_avl_t_first(traverser);pair;
pair= (struct sym_rule_pair*)_marpa_avl_t_next(traverser))
{
const ISYID current_symid= pair->t_symid;
while(seen_symid<current_symid)
irl_list_x_lh_sym[++seen_symid]= p_rule_data;
*p_rule_data++= pair->t_ruleid;
}
while(++seen_symid<=pre_census_isy_count)
irl_list_x_lh_sym[seen_symid]= p_rule_data;
_marpa_avl_destroy(lhs_avl_tree);
}

}

/*:380*/
#line 3308 "./marpa.w"

/*381:*/
#line 3506 "./marpa.w"

{
ISYID symid;
terminal_v= bv_obs_create(obs_precompute,pre_census_isy_count);
bv_not(terminal_v,lhs_v);
for(symid= 0;symid<pre_census_isy_count;symid++)
{
ISY symbol= ISY_by_ID(symid);



if(ISY_is_Locked_Terminal(symbol))
{
if(ISY_is_Terminal(symbol))
{
bv_bit_set(terminal_v,symid);
continue;
}
bv_bit_clear(terminal_v,symid);
continue;
}




if(bv_bit_test(terminal_v,symid))
ISY_is_Terminal(symbol)= 1;
}
}

/*:381*/
#line 3309 "./marpa.w"

/*389:*/
#line 3626 "./marpa.w"

{
IRLID rule_id;
reach_matrix= 
matrix_obs_create(obs_precompute,pre_census_isy_count,
pre_census_isy_count);
for(rule_id= 0;rule_id<irl_count;rule_id++)
{
IRL rule= IRL_by_ID(rule_id);
ISYID lhs_id= LHS_ID_of_RULE(rule);
int rhs_ix;
int rule_length= Length_of_IRL(rule);
for(rhs_ix= 0;rhs_ix<rule_length;rhs_ix++)
{
matrix_bit_set(reach_matrix,
lhs_id,
RHS_ID_of_RULE(rule,rhs_ix));
}
if(IRL_is_Sequence(rule))
{
const ISYID separator_id= Separator_of_IRL(rule);
if(separator_id>=0)
{
matrix_bit_set(reach_matrix,
lhs_id,
separator_id);
}
}
}
transitive_closure(reach_matrix);
}

/*:389*/
#line 3310 "./marpa.w"

/*385:*/
#line 3549 "./marpa.w"

{
int min,max,start;
ISYID isy_id;
int counted_nullables= 0;
nullable_v= bv_obs_clone(obs_precompute,empty_lhs_v);
rhs_closure(g,nullable_v,irl_list_x_rh_sym);
for(start= 0;bv_scan(nullable_v,start,&min,&max);start= max+2)
{
for(isy_id= min;isy_id<=max;
isy_id++)
{
ISY isy= ISY_by_ID(isy_id);
ISY_is_Nullable(isy)= 1;
if(_MARPA_UNLIKELY(isy->t_is_counted))
{
counted_nullables++;
int_event_new(g,MARPA_EVENT_COUNTED_NULLABLE,isy_id);
}
}
}
if(_MARPA_UNLIKELY(counted_nullables))
{
MARPA_ERROR(MARPA_ERR_COUNTED_NULLABLE);
goto FAILURE;
}
}

/*:385*/
#line 3311 "./marpa.w"

/*386:*/
#line 3577 "./marpa.w"

{
productive_v= bv_obs_shadow(obs_precompute,nullable_v);
bv_or(productive_v,nullable_v,terminal_v);
rhs_closure(g,productive_v,irl_list_x_rh_sym);
{
int min,max,start;
ISYID symid;
for(start= 0;bv_scan(productive_v,start,&min,&max);
start= max+2)
{
for(symid= min;
symid<=max;symid++)
{
ISY symbol= ISY_by_ID(symid);
symbol->t_is_productive= 1;
}
}
}
}

/*:386*/
#line 3312 "./marpa.w"

/*387:*/
#line 3598 "./marpa.w"

if(_MARPA_UNLIKELY(!bv_bit_test(productive_v,start_isy_id)))
{
MARPA_ERROR(MARPA_ERR_UNPRODUCTIVE_START);
goto FAILURE;
}
/*:387*/
#line 3313 "./marpa.w"

/*391:*/
#line 3663 "./marpa.w"

{
Bit_Vector accessible_v= 
matrix_row(reach_matrix,start_isy_id);
int min,max,start;
ISYID symid;
for(start= 0;bv_scan(accessible_v,start,&min,&max);start= max+2)
{
for(symid= min;
symid<=max;symid++)
{
ISY symbol= ISY_by_ID(symid);
symbol->t_is_accessible= 1;
}
}
ISY_by_ID(start_isy_id)->t_is_accessible= 1;
}

/*:391*/
#line 3314 "./marpa.w"

/*392:*/
#line 3683 "./marpa.w"

{
Bit_Vector reaches_terminal_v= bv_shadow(terminal_v);
int nulling_terminal_found= 0;
int min,max,start;
for(start= 0;bv_scan(lhs_v,start,&min,&max);start= max+2)
{
ISYID productive_id;
for(productive_id= min;
productive_id<=max;productive_id++)
{
bv_and(reaches_terminal_v,terminal_v,
matrix_row(reach_matrix,productive_id));
if(bv_is_empty(reaches_terminal_v))
{
const ISY symbol= ISY_by_ID(productive_id);
ISY_is_Nulling(symbol)= 1;
if(_MARPA_UNLIKELY(ISY_is_Terminal(symbol)))
{
nulling_terminal_found= 1;
int_event_new(g,MARPA_EVENT_NULLING_TERMINAL,
productive_id);
}
}
}
}
bv_free(reaches_terminal_v);
if(_MARPA_UNLIKELY(nulling_terminal_found))
{
MARPA_ERROR(MARPA_ERR_NULLING_TERMINAL);
goto FAILURE;
}
}

/*:392*/
#line 3315 "./marpa.w"

/*393:*/
#line 3722 "./marpa.w"

{
IRLID irl_id;
for(irl_id= 0;irl_id<irl_count;irl_id++)
{
const IRL xrl= IRL_by_ID(irl_id);
const ISYID lhs_id= LHS_ID_of_IRL(xrl);
const ISY lhs= ISY_by_ID(lhs_id);
IRL_is_Accessible(xrl)= ISY_is_Accessible(lhs);
if(IRL_is_Sequence(xrl))
{
/*395:*/
#line 3773 "./marpa.w"

{
const ISYID rhs_id= RHS_ID_of_IRL(xrl,0);
const ISY rh_isy= ISY_by_ID(rhs_id);
const ISYID separator_id= Separator_of_IRL(xrl);




IRL_is_Nullable(xrl)= Minimum_of_IRL(xrl)<=0
||ISY_is_Nullable(rh_isy);



IRL_is_Nulling(xrl)= ISY_is_Nulling(rh_isy);




IRL_is_Productive(xrl)= IRL_is_Nullable(xrl)||ISY_is_Productive(rh_isy);



IRL_is_Used(xrl)= IRL_is_Accessible(xrl)&&ISY_is_Productive(rh_isy);



if(separator_id>=0)
{
const ISY separator_isy= ISY_by_ID(separator_id);



if(!ISY_is_Nulling(separator_isy))
{
IRL_is_Nulling(xrl)= 0;
}




if(_MARPA_UNLIKELY(!ISY_is_Productive(separator_isy)))
{
IRL_is_Productive(xrl)= IRL_is_Nullable(xrl);



IRL_is_Used(xrl)= 0;
}
}



if(IRL_is_Nulling(xrl))IRL_is_Used(xrl)= 0;
}

/*:395*/
#line 3733 "./marpa.w"

continue;
}
/*394:*/
#line 3742 "./marpa.w"

{
int rh_ix;
int is_nulling= 1;
int is_nullable= 1;
int is_productive= 1;
for(rh_ix= 0;rh_ix<Length_of_IRL(xrl);rh_ix++)
{
const ISYID rhs_id= RHS_ID_of_IRL(xrl,rh_ix);
const ISY rh_isy= ISY_by_ID(rhs_id);
if(_MARPA_LIKELY(!ISY_is_Nulling(rh_isy)))
is_nulling= 0;
if(_MARPA_LIKELY(!ISY_is_Nullable(rh_isy)))
is_nullable= 0;
if(_MARPA_UNLIKELY(!ISY_is_Productive(rh_isy)))
is_productive= 0;
}
IRL_is_Nulling(xrl)= Boolean(is_nulling);
IRL_is_Nullable(xrl)= Boolean(is_nullable);
IRL_is_Productive(xrl)= Boolean(is_productive);
IRL_is_Used(xrl)= IRL_is_Accessible(xrl)&&IRL_is_Productive(xrl)
&&!IRL_is_Nulling(xrl);
}

/*:394*/
#line 3736 "./marpa.w"

}
}

/*:393*/
#line 3316 "./marpa.w"

/*396:*/
#line 3838 "./marpa.w"

if(0)
{




ISYID isy_id;
for(isy_id= 0;isy_id<pre_census_isy_count;isy_id++)
{
if(bv_bit_test(terminal_v,isy_id)&&bv_bit_test(lhs_v,isy_id))
{
const ISY isy= ISY_by_ID(isy_id);
if(ISY_is_Valued_Locked(isy))
continue;
ISY_is_Valued(isy)= 1;
ISY_is_Valued_Locked(isy)= 1;
}
}
}

/*:396*/
#line 3317 "./marpa.w"

/*397:*/
#line 3867 "./marpa.w"

{
ISYID isyid;
IRLID xrlid;


int nullable_isy_count= 0;




void*matrix_buffer= my_malloc(matrix_sizeof(
pre_census_isy_count,
pre_census_isy_count));
Bit_Matrix nullification_matrix= 
matrix_buffer_create(matrix_buffer,pre_census_isy_count,
pre_census_isy_count);

for(isyid= 0;isyid<pre_census_isy_count;isyid++)
{
if(!ISYID_is_Nullable(isyid))
continue;
nullable_isy_count++;
matrix_bit_set(nullification_matrix,isyid,
isyid);
}
for(xrlid= 0;xrlid<irl_count;xrlid++)
{
int rh_ix;
IRL xrl= IRL_by_ID(xrlid);
const ISYID lhs_id= LHS_ID_of_IRL(xrl);
if(IRL_is_Nullable(xrl))
{
for(rh_ix= 0;rh_ix<Length_of_IRL(xrl);rh_ix++)
{
const ISYID rhs_id= RHS_ID_of_IRL(xrl,rh_ix);
matrix_bit_set(nullification_matrix,lhs_id,
rhs_id);
}
}
}
transitive_closure(nullification_matrix);
for(isyid= 0;isyid<pre_census_isy_count;isyid++)
{
Bit_Vector bv_nullifications_by_to_isy= 
matrix_row(nullification_matrix,isyid);
Nulled_ISYIDs_of_ISYID(isyid)= 
cil_bv_add(&g->t_cilar,bv_nullifications_by_to_isy);
}
my_free(matrix_buffer);
}

/*:397*/
#line 3318 "./marpa.w"

}

/*:372*/
#line 3216 "./marpa.w"

/*448:*/
#line 4742 "./marpa.w"

{
int loop_rule_count= 0;
Bit_Matrix unit_transition_matrix= 
matrix_obs_create(obs_precompute,irl_count,
irl_count);
/*449:*/
#line 4763 "./marpa.w"

{
Marpa_Rule_ID rule_id;
for(rule_id= 0;rule_id<irl_count;rule_id++)
{
IRL rule= IRL_by_ID(rule_id);
ISYID nonnullable_id= -1;
int nonnullable_count= 0;
int rhs_ix,rule_length;
rule_length= Length_of_IRL(rule);



for(rhs_ix= 0;rhs_ix<rule_length;rhs_ix++)
{
ISYID isy_id= RHS_ID_of_RULE(rule,rhs_ix);
if(bv_bit_test(nullable_v,isy_id))
continue;
nonnullable_id= isy_id;
nonnullable_count++;
}

if(nonnullable_count==1)
{



/*450:*/
#line 4818 "./marpa.w"

{
RULEID*p_irl= irl_list_x_lh_sym[nonnullable_id];
const RULEID*p_one_past_rules= irl_list_x_lh_sym[nonnullable_id+1];
for(;p_irl<p_one_past_rules;p_irl++)
{


const RULEID to_rule_id= *p_irl;
matrix_bit_set(unit_transition_matrix,rule_id,
to_rule_id);
}
}

/*:450*/
#line 4791 "./marpa.w"

}
else if(nonnullable_count==0)
{
for(rhs_ix= 0;rhs_ix<rule_length;rhs_ix++)
{




nonnullable_id= RHS_ID_of_RULE(rule,rhs_ix);

if(ISY_is_Nulling(ISY_by_ID(nonnullable_id)))
continue;



/*450:*/
#line 4818 "./marpa.w"

{
RULEID*p_irl= irl_list_x_lh_sym[nonnullable_id];
const RULEID*p_one_past_rules= irl_list_x_lh_sym[nonnullable_id+1];
for(;p_irl<p_one_past_rules;p_irl++)
{


const RULEID to_rule_id= *p_irl;
matrix_bit_set(unit_transition_matrix,rule_id,
to_rule_id);
}
}

/*:450*/
#line 4809 "./marpa.w"

}
}
}
}

/*:449*/
#line 4748 "./marpa.w"

transitive_closure(unit_transition_matrix);
/*451:*/
#line 4832 "./marpa.w"

{
IRLID rule_id;
for(rule_id= 0;rule_id<irl_count;rule_id++)
{
IRL rule;
if(!matrix_bit_test
(unit_transition_matrix,rule_id,
rule_id))
continue;
loop_rule_count++;
rule= IRL_by_ID(rule_id);
rule->t_is_loop= 1;
}
}

/*:451*/
#line 4750 "./marpa.w"

if(loop_rule_count)
{
g->t_has_cycle= 1;
int_event_new(g,MARPA_EVENT_LOOP_RULES,loop_rule_count);
}
}

/*:448*/
#line 3217 "./marpa.w"

}



/*515:*/
#line 5430 "./marpa.w"

MARPA_DSTACK_INIT(g->t_nrl_stack,NRL,2*MARPA_DSTACK_CAPACITY(g->t_irl_stack));

/*:515*/
#line 3222 "./marpa.w"

/*516:*/
#line 5438 "./marpa.w"

{
MARPA_DSTACK_INIT(g->t_nsy_stack,NSY,2*MARPA_DSTACK_CAPACITY(g->t_isy_stack));
}

/*:516*/
#line 3223 "./marpa.w"

/*413:*/
#line 4089 "./marpa.w"

{
/*414:*/
#line 4120 "./marpa.w"

Marpa_Rule_ID rule_id;
int pre_chaf_rule_count;

/*:414*//*417:*/
#line 4178 "./marpa.w"

int factor_count;
int*factor_positions;
/*:417*/
#line 4091 "./marpa.w"

/*418:*/
#line 4181 "./marpa.w"

factor_positions= marpa_obs_new(obs_precompute,int,g->t_max_rule_length);

/*:418*/
#line 4092 "./marpa.w"

/*415:*/
#line 4126 "./marpa.w"

{
ISYID isy_id;
for(isy_id= 0;isy_id<pre_census_isy_count;isy_id++)
{
const ISY isy_to_clone= ISY_by_ID(isy_id);
if(_MARPA_UNLIKELY(!isy_to_clone->t_is_accessible))
continue;
if(_MARPA_UNLIKELY(!isy_to_clone->t_is_productive))
continue;
NSY_of_ISY(isy_to_clone)= nsy_clone(g,isy_to_clone);
if(ISY_is_Nulling(isy_to_clone))
{
Nulling_NSY_of_ISY(isy_to_clone)= NSY_of_ISY(isy_to_clone);
continue;
}
if(ISY_is_Nullable(isy_to_clone))
{
Nulling_NSY_of_ISY(isy_to_clone)= symbol_alias_create(g,isy_to_clone);
}
}
}

/*:415*/
#line 4093 "./marpa.w"

pre_chaf_rule_count= IRL_Count_of_G(g);
for(rule_id= 0;rule_id<pre_chaf_rule_count;rule_id++)
{

IRL rule= IRL_by_ID(rule_id);
IRL rewrite_irl= rule;
const int rewrite_irl_length= Length_of_IRL(rewrite_irl);
int nullable_suffix_ix= 0;
if(!IRL_is_Used(rule))
continue;
if(IRL_is_Sequence(rule))
{
/*398:*/
#line 3920 "./marpa.w"

{
const ISYID lhs_id= LHS_ID_of_RULE(rule);
const NSY lhs_nsy= NSY_by_ISYID(lhs_id);
const NSYID lhs_nsyid= ID_of_NSY(lhs_nsy);

const NSY internal_lhs_nsy= nsy_new(g,ISY_by_ID(lhs_id));
const NSYID internal_lhs_nsyid= ID_of_NSY(internal_lhs_nsy);

const ISYID rhs_id= RHS_ID_of_RULE(rule,0);
const NSY rhs_nsy= NSY_by_ISYID(rhs_id);
const NSYID rhs_nsyid= ID_of_NSY(rhs_nsy);

const ISYID separator_id= Separator_of_IRL(rule);
NSYID separator_nsyid= -1;
if(separator_id>=0){
const NSY separator_nsy= NSY_by_ISYID(separator_id);
separator_nsyid= ID_of_NSY(separator_nsy);
}

LHS_IRL_of_NSY(internal_lhs_nsy)= rule;
/*399:*/
#line 3949 "./marpa.w"

{
NRL rewrite_nrl= nrl_start(g,1);
LHSID_of_NRL(rewrite_nrl)= lhs_nsyid;
RHSID_of_NRL(rewrite_nrl,0)= internal_lhs_nsyid;
nrl_finish(g,rewrite_nrl);
Source_IRL_of_NRL(rewrite_nrl)= rule;
Rank_of_NRL(rewrite_nrl)= NRL_Rank_by_IRL(rule);

NRL_has_Virtual_RHS(rewrite_nrl)= 1;
}

/*:399*/
#line 3941 "./marpa.w"

if(separator_nsyid>=0&&!IRL_is_Proper_Separation(rule)){
/*400:*/
#line 3962 "./marpa.w"

{
NRL rewrite_nrl;
rewrite_nrl= nrl_start(g,2);
LHSID_of_NRL(rewrite_nrl)= lhs_nsyid;
RHSID_of_NRL(rewrite_nrl,0)= internal_lhs_nsyid;
RHSID_of_NRL(rewrite_nrl,1)= separator_nsyid;
nrl_finish(g,rewrite_nrl);
Source_IRL_of_NRL(rewrite_nrl)= rule;
Rank_of_NRL(rewrite_nrl)= NRL_Rank_by_IRL(rule);
NRL_has_Virtual_RHS(rewrite_nrl)= 1;
Real_SYM_Count_of_NRL(rewrite_nrl)= 1;
}

/*:400*/
#line 3943 "./marpa.w"

}
/*401:*/
#line 3979 "./marpa.w"

{
const NRL rewrite_nrl= nrl_start(g,1);
LHSID_of_NRL(rewrite_nrl)= internal_lhs_nsyid;
RHSID_of_NRL(rewrite_nrl,0)= rhs_nsyid;
nrl_finish(g,rewrite_nrl);
Source_IRL_of_NRL(rewrite_nrl)= rule;
Rank_of_NRL(rewrite_nrl)= NRL_Rank_by_IRL(rule);
NRL_has_Virtual_LHS(rewrite_nrl)= 1;
Real_SYM_Count_of_NRL(rewrite_nrl)= 1;
}
/*:401*/
#line 3945 "./marpa.w"

/*402:*/
#line 3990 "./marpa.w"

{
NRL rewrite_nrl;
int rhs_ix= 0;
const int length= separator_nsyid>=0?3:2;
rewrite_nrl= nrl_start(g,length);
LHSID_of_NRL(rewrite_nrl)= internal_lhs_nsyid;
RHSID_of_NRL(rewrite_nrl,rhs_ix++)= internal_lhs_nsyid;
if(separator_nsyid>=0)
RHSID_of_NRL(rewrite_nrl,rhs_ix++)= separator_nsyid;
RHSID_of_NRL(rewrite_nrl,rhs_ix)= rhs_nsyid;
nrl_finish(g,rewrite_nrl);
Source_IRL_of_NRL(rewrite_nrl)= rule;
Rank_of_NRL(rewrite_nrl)= NRL_Rank_by_IRL(rule);
NRL_has_Virtual_LHS(rewrite_nrl)= 1;
NRL_has_Virtual_RHS(rewrite_nrl)= 1;
Real_SYM_Count_of_NRL(rewrite_nrl)= length-1;
}

/*:402*/
#line 3946 "./marpa.w"

}

/*:398*/
#line 4106 "./marpa.w"

continue;
}
/*416:*/
#line 4157 "./marpa.w"

{
int rhs_ix;
factor_count= 0;
for(rhs_ix= 0;rhs_ix<rewrite_irl_length;rhs_ix++)
{
Marpa_Symbol_ID symid= RHS_ID_of_RULE(rule,rhs_ix);
ISY symbol= ISY_by_ID(symid);
if(ISY_is_Nulling(symbol))
continue;
if(ISY_is_Nullable(symbol))
{

factor_positions[factor_count++]= rhs_ix;
continue;
}
nullable_suffix_ix= rhs_ix+1;


}
}
/*:416*/
#line 4109 "./marpa.w"


if(factor_count> 0)
{
/*419:*/
#line 4185 "./marpa.w"

{
const IRL chaf_irl= rule;


int unprocessed_factor_count;

int factor_position_ix= 0;
NSY current_lhs_nsy= NSY_by_ISYID(LHS_ID_of_RULE(rule));
NSYID current_lhs_nsyid= ID_of_NSY(current_lhs_nsy);


int piece_end,piece_start= 0;

for(unprocessed_factor_count= factor_count-factor_position_ix;
unprocessed_factor_count>=3;
unprocessed_factor_count= factor_count-factor_position_ix){
/*422:*/
#line 4221 "./marpa.w"

NSY chaf_virtual_nsy;
NSYID chaf_virtual_nsyid;
int first_factor_position= factor_positions[factor_position_ix];
int second_factor_position= factor_positions[factor_position_ix+1];
if(second_factor_position>=nullable_suffix_ix){
piece_end= second_factor_position-1;



/*420:*/
#line 4211 "./marpa.w"

{
const ISYID chaf_irl_lhs_id= LHS_ID_of_IRL(chaf_irl);
chaf_virtual_nsy= nsy_new(g,ISY_by_ID(chaf_irl_lhs_id));
chaf_virtual_nsyid= ID_of_NSY(chaf_virtual_nsy);
}

/*:420*/
#line 4231 "./marpa.w"

/*423:*/
#line 4250 "./marpa.w"

{
{
const int real_symbol_count= piece_end-piece_start+1;
/*428:*/
#line 4348 "./marpa.w"

{
int piece_ix;
const int chaf_nrl_length= (piece_end-piece_start)+2;
NRL chaf_nrl= nrl_start(g,chaf_nrl_length);
LHSID_of_NRL(chaf_nrl)= current_lhs_nsyid;
for(piece_ix= 0;piece_ix<chaf_nrl_length-1;piece_ix++)
{
RHSID_of_NRL(chaf_nrl,piece_ix)= 
NSYID_by_ISYID(RHS_ID_of_RULE(rule,piece_start+piece_ix));
}
RHSID_of_NRL(chaf_nrl,chaf_nrl_length-1)= chaf_virtual_nsyid;
nrl_finish(g,chaf_nrl);
Rank_of_NRL(chaf_nrl)= NRL_CHAF_Rank_by_IRL(rule,3);
/*440:*/
#line 4651 "./marpa.w"

{
const int is_virtual_lhs= (piece_start> 0);
NRL_is_CHAF(chaf_nrl)= 1;
Source_IRL_of_NRL(chaf_nrl)= rule;
NRL_has_Virtual_LHS(chaf_nrl)= Boolean(is_virtual_lhs);
NRL_has_Virtual_RHS(chaf_nrl)= 
Length_of_NRL(chaf_nrl)> real_symbol_count;
Virtual_Start_of_NRL(chaf_nrl)= piece_start;
Virtual_End_of_NRL(chaf_nrl)= piece_start+real_symbol_count-1;
Real_SYM_Count_of_NRL(chaf_nrl)= real_symbol_count;
LHS_IRL_of_NSY(current_lhs_nsy)= chaf_irl;
IRL_Offset_of_NSY(current_lhs_nsy)= piece_start;
}

/*:440*/
#line 4362 "./marpa.w"

}

/*:428*/
#line 4254 "./marpa.w"
;
}
/*424:*/
#line 4264 "./marpa.w"

{
int piece_ix;
const int second_nulling_piece_ix= second_factor_position-piece_start;
const int chaf_nrl_length= rewrite_irl_length-piece_start;
const int real_symbol_count= chaf_nrl_length;

NRL chaf_nrl= nrl_start(g,chaf_nrl_length);
LHSID_of_NRL(chaf_nrl)= current_lhs_nsyid;
for(piece_ix= 0;piece_ix<second_nulling_piece_ix;piece_ix++)
{
RHSID_of_NRL(chaf_nrl,piece_ix)= 
NSYID_by_ISYID(RHS_ID_of_RULE(rule,piece_start+piece_ix));
}
for(piece_ix= second_nulling_piece_ix;piece_ix<chaf_nrl_length;
piece_ix++)
{
RHSID_of_NRL(chaf_nrl,piece_ix)= 
Nulling_NSYID_by_ISYID(RHS_ID_of_RULE(rule,piece_start+piece_ix));
}
nrl_finish(g,chaf_nrl);
Rank_of_NRL(chaf_nrl)= NRL_CHAF_Rank_by_IRL(rule,2);
/*440:*/
#line 4651 "./marpa.w"

{
const int is_virtual_lhs= (piece_start> 0);
NRL_is_CHAF(chaf_nrl)= 1;
Source_IRL_of_NRL(chaf_nrl)= rule;
NRL_has_Virtual_LHS(chaf_nrl)= Boolean(is_virtual_lhs);
NRL_has_Virtual_RHS(chaf_nrl)= 
Length_of_NRL(chaf_nrl)> real_symbol_count;
Virtual_Start_of_NRL(chaf_nrl)= piece_start;
Virtual_End_of_NRL(chaf_nrl)= piece_start+real_symbol_count-1;
Real_SYM_Count_of_NRL(chaf_nrl)= real_symbol_count;
LHS_IRL_of_NSY(current_lhs_nsy)= chaf_irl;
IRL_Offset_of_NSY(current_lhs_nsy)= piece_start;
}

/*:440*/
#line 4286 "./marpa.w"

}

/*:424*/
#line 4256 "./marpa.w"
;
{
const int real_symbol_count= piece_end-piece_start+1;
/*430:*/
#line 4394 "./marpa.w"

{
int piece_ix;
const int first_nulling_piece_ix= first_factor_position-piece_start;
const int chaf_nrl_length= (piece_end-piece_start)+2;
NRL chaf_nrl= nrl_start(g,chaf_nrl_length);
LHSID_of_NRL(chaf_nrl)= current_lhs_nsyid;
for(piece_ix= 0;piece_ix<first_nulling_piece_ix;piece_ix++)
{
RHSID_of_NRL(chaf_nrl,piece_ix)= 
NSYID_by_ISYID(RHS_ID_of_RULE(rule,piece_start+piece_ix));
}
RHSID_of_NRL(chaf_nrl,first_nulling_piece_ix)= 
Nulling_NSYID_by_ISYID(RHS_ID_of_RULE
(rule,piece_start+first_nulling_piece_ix));
for(piece_ix= first_nulling_piece_ix+1;
piece_ix<chaf_nrl_length-1;piece_ix++)
{
RHSID_of_NRL(chaf_nrl,piece_ix)= 
NSYID_by_ISYID(RHS_ID_of_RULE(rule,piece_start+piece_ix));
}
RHSID_of_NRL(chaf_nrl,chaf_nrl_length-1)= chaf_virtual_nsyid;
nrl_finish(g,chaf_nrl);
Rank_of_NRL(chaf_nrl)= NRL_CHAF_Rank_by_IRL(rule,1);
/*440:*/
#line 4651 "./marpa.w"

{
const int is_virtual_lhs= (piece_start> 0);
NRL_is_CHAF(chaf_nrl)= 1;
Source_IRL_of_NRL(chaf_nrl)= rule;
NRL_has_Virtual_LHS(chaf_nrl)= Boolean(is_virtual_lhs);
NRL_has_Virtual_RHS(chaf_nrl)= 
Length_of_NRL(chaf_nrl)> real_symbol_count;
Virtual_Start_of_NRL(chaf_nrl)= piece_start;
Virtual_End_of_NRL(chaf_nrl)= piece_start+real_symbol_count-1;
Real_SYM_Count_of_NRL(chaf_nrl)= real_symbol_count;
LHS_IRL_of_NSY(current_lhs_nsy)= chaf_irl;
IRL_Offset_of_NSY(current_lhs_nsy)= piece_start;
}

/*:440*/
#line 4418 "./marpa.w"

}

/*:430*/
#line 4259 "./marpa.w"
;
}
/*425:*/
#line 4294 "./marpa.w"

{
if(piece_start<nullable_suffix_ix)
{
int piece_ix;
const int first_nulling_piece_ix= first_factor_position-piece_start;
const int second_nulling_piece_ix= 
second_factor_position-piece_start;
const int chaf_nrl_length= rewrite_irl_length-piece_start;
const int real_symbol_count= chaf_nrl_length;

NRL chaf_nrl= nrl_start(g,chaf_nrl_length);
LHSID_of_NRL(chaf_nrl)= current_lhs_nsyid;
for(piece_ix= 0;piece_ix<first_nulling_piece_ix;piece_ix++)
{
RHSID_of_NRL(chaf_nrl,piece_ix)= 
NSYID_by_ISYID(RHS_ID_of_RULE
(rule,piece_start+piece_ix));
}
RHSID_of_NRL(chaf_nrl,first_nulling_piece_ix)= 
Nulling_NSYID_by_ISYID(RHS_ID_of_RULE
(rule,piece_start+first_nulling_piece_ix));
for(piece_ix= first_nulling_piece_ix+1;
piece_ix<second_nulling_piece_ix;piece_ix++)
{
RHSID_of_NRL(chaf_nrl,piece_ix)= 
NSYID_by_ISYID(RHS_ID_of_RULE
(rule,piece_start+piece_ix));
}
for(piece_ix= second_nulling_piece_ix;piece_ix<chaf_nrl_length;
piece_ix++)
{
RHSID_of_NRL(chaf_nrl,piece_ix)= 
Nulling_NSYID_by_ISYID(RHS_ID_of_RULE
(rule,piece_start+piece_ix));
}
nrl_finish(g,chaf_nrl);
Rank_of_NRL(chaf_nrl)= NRL_CHAF_Rank_by_IRL(rule,0);
/*440:*/
#line 4651 "./marpa.w"

{
const int is_virtual_lhs= (piece_start> 0);
NRL_is_CHAF(chaf_nrl)= 1;
Source_IRL_of_NRL(chaf_nrl)= rule;
NRL_has_Virtual_LHS(chaf_nrl)= Boolean(is_virtual_lhs);
NRL_has_Virtual_RHS(chaf_nrl)= 
Length_of_NRL(chaf_nrl)> real_symbol_count;
Virtual_Start_of_NRL(chaf_nrl)= piece_start;
Virtual_End_of_NRL(chaf_nrl)= piece_start+real_symbol_count-1;
Real_SYM_Count_of_NRL(chaf_nrl)= real_symbol_count;
LHS_IRL_of_NSY(current_lhs_nsy)= chaf_irl;
IRL_Offset_of_NSY(current_lhs_nsy)= piece_start;
}

/*:440*/
#line 4332 "./marpa.w"

}
}

/*:425*/
#line 4261 "./marpa.w"
;
}

/*:423*/
#line 4232 "./marpa.w"

factor_position_ix++;
}else{
piece_end= second_factor_position;
/*420:*/
#line 4211 "./marpa.w"

{
const ISYID chaf_irl_lhs_id= LHS_ID_of_IRL(chaf_irl);
chaf_virtual_nsy= nsy_new(g,ISY_by_ID(chaf_irl_lhs_id));
chaf_virtual_nsyid= ID_of_NSY(chaf_virtual_nsy);
}

/*:420*/
#line 4236 "./marpa.w"

/*427:*/
#line 4338 "./marpa.w"

{
const int real_symbol_count= piece_end-piece_start+1;
/*428:*/
#line 4348 "./marpa.w"

{
int piece_ix;
const int chaf_nrl_length= (piece_end-piece_start)+2;
NRL chaf_nrl= nrl_start(g,chaf_nrl_length);
LHSID_of_NRL(chaf_nrl)= current_lhs_nsyid;
for(piece_ix= 0;piece_ix<chaf_nrl_length-1;piece_ix++)
{
RHSID_of_NRL(chaf_nrl,piece_ix)= 
NSYID_by_ISYID(RHS_ID_of_RULE(rule,piece_start+piece_ix));
}
RHSID_of_NRL(chaf_nrl,chaf_nrl_length-1)= chaf_virtual_nsyid;
nrl_finish(g,chaf_nrl);
Rank_of_NRL(chaf_nrl)= NRL_CHAF_Rank_by_IRL(rule,3);
/*440:*/
#line 4651 "./marpa.w"

{
const int is_virtual_lhs= (piece_start> 0);
NRL_is_CHAF(chaf_nrl)= 1;
Source_IRL_of_NRL(chaf_nrl)= rule;
NRL_has_Virtual_LHS(chaf_nrl)= Boolean(is_virtual_lhs);
NRL_has_Virtual_RHS(chaf_nrl)= 
Length_of_NRL(chaf_nrl)> real_symbol_count;
Virtual_Start_of_NRL(chaf_nrl)= piece_start;
Virtual_End_of_NRL(chaf_nrl)= piece_start+real_symbol_count-1;
Real_SYM_Count_of_NRL(chaf_nrl)= real_symbol_count;
LHS_IRL_of_NSY(current_lhs_nsy)= chaf_irl;
IRL_Offset_of_NSY(current_lhs_nsy)= piece_start;
}

/*:440*/
#line 4362 "./marpa.w"

}

/*:428*/
#line 4341 "./marpa.w"

/*429:*/
#line 4366 "./marpa.w"

{
int piece_ix;
const int second_nulling_piece_ix= second_factor_position-piece_start;
const int chaf_nrl_length= (piece_end-piece_start)+2;
NRL chaf_nrl= nrl_start(g,chaf_nrl_length);
LHSID_of_NRL(chaf_nrl)= current_lhs_nsyid;
for(piece_ix= 0;piece_ix<second_nulling_piece_ix;piece_ix++)
{
RHSID_of_NRL(chaf_nrl,piece_ix)= 
NSYID_by_ISYID(RHS_ID_of_RULE(rule,piece_start+piece_ix));
}
RHSID_of_NRL(chaf_nrl,second_nulling_piece_ix)= 
Nulling_NSYID_by_ISYID(RHS_ID_of_RULE
(rule,piece_start+second_nulling_piece_ix));
for(piece_ix= second_nulling_piece_ix+1;
piece_ix<chaf_nrl_length-1;piece_ix++)
{
RHSID_of_NRL(chaf_nrl,piece_ix)= 
NSYID_by_ISYID(RHS_ID_of_RULE(rule,piece_start+piece_ix));
}
RHSID_of_NRL(chaf_nrl,chaf_nrl_length-1)= chaf_virtual_nsyid;
nrl_finish(g,chaf_nrl);
Rank_of_NRL(chaf_nrl)= NRL_CHAF_Rank_by_IRL(rule,2);
/*440:*/
#line 4651 "./marpa.w"

{
const int is_virtual_lhs= (piece_start> 0);
NRL_is_CHAF(chaf_nrl)= 1;
Source_IRL_of_NRL(chaf_nrl)= rule;
NRL_has_Virtual_LHS(chaf_nrl)= Boolean(is_virtual_lhs);
NRL_has_Virtual_RHS(chaf_nrl)= 
Length_of_NRL(chaf_nrl)> real_symbol_count;
Virtual_Start_of_NRL(chaf_nrl)= piece_start;
Virtual_End_of_NRL(chaf_nrl)= piece_start+real_symbol_count-1;
Real_SYM_Count_of_NRL(chaf_nrl)= real_symbol_count;
LHS_IRL_of_NSY(current_lhs_nsy)= chaf_irl;
IRL_Offset_of_NSY(current_lhs_nsy)= piece_start;
}

/*:440*/
#line 4390 "./marpa.w"

}

/*:429*/
#line 4342 "./marpa.w"

/*430:*/
#line 4394 "./marpa.w"

{
int piece_ix;
const int first_nulling_piece_ix= first_factor_position-piece_start;
const int chaf_nrl_length= (piece_end-piece_start)+2;
NRL chaf_nrl= nrl_start(g,chaf_nrl_length);
LHSID_of_NRL(chaf_nrl)= current_lhs_nsyid;
for(piece_ix= 0;piece_ix<first_nulling_piece_ix;piece_ix++)
{
RHSID_of_NRL(chaf_nrl,piece_ix)= 
NSYID_by_ISYID(RHS_ID_of_RULE(rule,piece_start+piece_ix));
}
RHSID_of_NRL(chaf_nrl,first_nulling_piece_ix)= 
Nulling_NSYID_by_ISYID(RHS_ID_of_RULE
(rule,piece_start+first_nulling_piece_ix));
for(piece_ix= first_nulling_piece_ix+1;
piece_ix<chaf_nrl_length-1;piece_ix++)
{
RHSID_of_NRL(chaf_nrl,piece_ix)= 
NSYID_by_ISYID(RHS_ID_of_RULE(rule,piece_start+piece_ix));
}
RHSID_of_NRL(chaf_nrl,chaf_nrl_length-1)= chaf_virtual_nsyid;
nrl_finish(g,chaf_nrl);
Rank_of_NRL(chaf_nrl)= NRL_CHAF_Rank_by_IRL(rule,1);
/*440:*/
#line 4651 "./marpa.w"

{
const int is_virtual_lhs= (piece_start> 0);
NRL_is_CHAF(chaf_nrl)= 1;
Source_IRL_of_NRL(chaf_nrl)= rule;
NRL_has_Virtual_LHS(chaf_nrl)= Boolean(is_virtual_lhs);
NRL_has_Virtual_RHS(chaf_nrl)= 
Length_of_NRL(chaf_nrl)> real_symbol_count;
Virtual_Start_of_NRL(chaf_nrl)= piece_start;
Virtual_End_of_NRL(chaf_nrl)= piece_start+real_symbol_count-1;
Real_SYM_Count_of_NRL(chaf_nrl)= real_symbol_count;
LHS_IRL_of_NSY(current_lhs_nsy)= chaf_irl;
IRL_Offset_of_NSY(current_lhs_nsy)= piece_start;
}

/*:440*/
#line 4418 "./marpa.w"

}

/*:430*/
#line 4343 "./marpa.w"

/*431:*/
#line 4422 "./marpa.w"

{
int piece_ix;
const int first_nulling_piece_ix= first_factor_position-piece_start;
const int second_nulling_piece_ix= second_factor_position-piece_start;
const int chaf_nrl_length= (piece_end-piece_start)+2;
NRL chaf_nrl= nrl_start(g,chaf_nrl_length);
LHSID_of_NRL(chaf_nrl)= current_lhs_nsyid;
for(piece_ix= 0;piece_ix<first_nulling_piece_ix;piece_ix++)
{
RHSID_of_NRL(chaf_nrl,piece_ix)= 
NSYID_by_ISYID(RHS_ID_of_RULE(rule,piece_start+piece_ix));
}
RHSID_of_NRL(chaf_nrl,first_nulling_piece_ix)= 
Nulling_NSYID_by_ISYID(RHS_ID_of_RULE
(rule,piece_start+first_nulling_piece_ix));
for(piece_ix= first_nulling_piece_ix+1;
piece_ix<second_nulling_piece_ix;piece_ix++)
{
RHSID_of_NRL(chaf_nrl,piece_ix)= 
NSYID_by_ISYID(RHS_ID_of_RULE(rule,piece_start+piece_ix));
}
RHSID_of_NRL(chaf_nrl,second_nulling_piece_ix)= 
Nulling_NSYID_by_ISYID(RHS_ID_of_RULE
(rule,piece_start+second_nulling_piece_ix));
for(piece_ix= second_nulling_piece_ix+1;piece_ix<chaf_nrl_length-1;
piece_ix++)
{
RHSID_of_NRL(chaf_nrl,piece_ix)= 
NSYID_by_ISYID(RHS_ID_of_RULE(rule,piece_start+piece_ix));
}
RHSID_of_NRL(chaf_nrl,chaf_nrl_length-1)= chaf_virtual_nsyid;
nrl_finish(g,chaf_nrl);
Rank_of_NRL(chaf_nrl)= NRL_CHAF_Rank_by_IRL(rule,0);
/*440:*/
#line 4651 "./marpa.w"

{
const int is_virtual_lhs= (piece_start> 0);
NRL_is_CHAF(chaf_nrl)= 1;
Source_IRL_of_NRL(chaf_nrl)= rule;
NRL_has_Virtual_LHS(chaf_nrl)= Boolean(is_virtual_lhs);
NRL_has_Virtual_RHS(chaf_nrl)= 
Length_of_NRL(chaf_nrl)> real_symbol_count;
Virtual_Start_of_NRL(chaf_nrl)= piece_start;
Virtual_End_of_NRL(chaf_nrl)= piece_start+real_symbol_count-1;
Real_SYM_Count_of_NRL(chaf_nrl)= real_symbol_count;
LHS_IRL_of_NSY(current_lhs_nsy)= chaf_irl;
IRL_Offset_of_NSY(current_lhs_nsy)= piece_start;
}

/*:440*/
#line 4456 "./marpa.w"

}

/*:431*/
#line 4344 "./marpa.w"

}

/*:427*/
#line 4237 "./marpa.w"

factor_position_ix+= 2;
}
current_lhs_nsy= chaf_virtual_nsy;
current_lhs_nsyid= chaf_virtual_nsyid;
piece_start= piece_end+1;

/*:422*/
#line 4202 "./marpa.w"

}
if(unprocessed_factor_count==2){
/*432:*/
#line 4461 "./marpa.w"

{
const int first_factor_position= factor_positions[factor_position_ix];
const int second_factor_position= factor_positions[factor_position_ix+1];
const int real_symbol_count= Length_of_IRL(rule)-piece_start;
piece_end= Length_of_IRL(rule)-1;
/*433:*/
#line 4474 "./marpa.w"

{
int piece_ix;
const int chaf_nrl_length= (piece_end-piece_start)+1;
NRL chaf_nrl= nrl_start(g,chaf_nrl_length);
LHSID_of_NRL(chaf_nrl)= current_lhs_nsyid;
for(piece_ix= 0;piece_ix<chaf_nrl_length;piece_ix++)
{
RHSID_of_NRL(chaf_nrl,piece_ix)= 
NSYID_by_ISYID(RHS_ID_of_RULE(rule,piece_start+piece_ix));
}
nrl_finish(g,chaf_nrl);
Rank_of_NRL(chaf_nrl)= NRL_CHAF_Rank_by_IRL(rule,3);
/*440:*/
#line 4651 "./marpa.w"

{
const int is_virtual_lhs= (piece_start> 0);
NRL_is_CHAF(chaf_nrl)= 1;
Source_IRL_of_NRL(chaf_nrl)= rule;
NRL_has_Virtual_LHS(chaf_nrl)= Boolean(is_virtual_lhs);
NRL_has_Virtual_RHS(chaf_nrl)= 
Length_of_NRL(chaf_nrl)> real_symbol_count;
Virtual_Start_of_NRL(chaf_nrl)= piece_start;
Virtual_End_of_NRL(chaf_nrl)= piece_start+real_symbol_count-1;
Real_SYM_Count_of_NRL(chaf_nrl)= real_symbol_count;
LHS_IRL_of_NSY(current_lhs_nsy)= chaf_irl;
IRL_Offset_of_NSY(current_lhs_nsy)= piece_start;
}

/*:440*/
#line 4487 "./marpa.w"

}

/*:433*/
#line 4467 "./marpa.w"

/*434:*/
#line 4491 "./marpa.w"

{
int piece_ix;
const int second_nulling_piece_ix= second_factor_position-piece_start;
const int chaf_nrl_length= (piece_end-piece_start)+1;
NRL chaf_nrl= nrl_start(g,chaf_nrl_length);
LHSID_of_NRL(chaf_nrl)= current_lhs_nsyid;
for(piece_ix= 0;piece_ix<second_nulling_piece_ix;piece_ix++)
{
RHSID_of_NRL(chaf_nrl,piece_ix)= 
NSYID_by_ISYID(RHS_ID_of_RULE(rule,piece_start+piece_ix));
}
RHSID_of_NRL(chaf_nrl,second_nulling_piece_ix)= 
Nulling_NSYID_by_ISYID(RHS_ID_of_RULE
(rule,piece_start+second_nulling_piece_ix));
for(piece_ix= second_nulling_piece_ix+1;piece_ix<chaf_nrl_length;
piece_ix++)
{
RHSID_of_NRL(chaf_nrl,piece_ix)= 
NSYID_by_ISYID(RHS_ID_of_RULE(rule,piece_start+piece_ix));
}
nrl_finish(g,chaf_nrl);
Rank_of_NRL(chaf_nrl)= NRL_CHAF_Rank_by_IRL(rule,2);
/*440:*/
#line 4651 "./marpa.w"

{
const int is_virtual_lhs= (piece_start> 0);
NRL_is_CHAF(chaf_nrl)= 1;
Source_IRL_of_NRL(chaf_nrl)= rule;
NRL_has_Virtual_LHS(chaf_nrl)= Boolean(is_virtual_lhs);
NRL_has_Virtual_RHS(chaf_nrl)= 
Length_of_NRL(chaf_nrl)> real_symbol_count;
Virtual_Start_of_NRL(chaf_nrl)= piece_start;
Virtual_End_of_NRL(chaf_nrl)= piece_start+real_symbol_count-1;
Real_SYM_Count_of_NRL(chaf_nrl)= real_symbol_count;
LHS_IRL_of_NSY(current_lhs_nsy)= chaf_irl;
IRL_Offset_of_NSY(current_lhs_nsy)= piece_start;
}

/*:440*/
#line 4514 "./marpa.w"

}

/*:434*/
#line 4468 "./marpa.w"

/*435:*/
#line 4518 "./marpa.w"

{
int piece_ix;
const int first_nulling_piece_ix= first_factor_position-piece_start;
const int chaf_nrl_length= (piece_end-piece_start)+1;
NRL chaf_nrl= nrl_start(g,chaf_nrl_length);
LHSID_of_NRL(chaf_nrl)= current_lhs_nsyid;
for(piece_ix= 0;piece_ix<first_nulling_piece_ix;piece_ix++)
{
RHSID_of_NRL(chaf_nrl,piece_ix)= 
NSYID_by_ISYID(RHS_ID_of_RULE(rule,piece_start+piece_ix));
}
RHSID_of_NRL(chaf_nrl,first_nulling_piece_ix)= 
Nulling_NSYID_by_ISYID(RHS_ID_of_RULE
(rule,piece_start+first_nulling_piece_ix));
for(piece_ix= first_nulling_piece_ix+1;piece_ix<chaf_nrl_length;
piece_ix++)
{
RHSID_of_NRL(chaf_nrl,piece_ix)= 
NSYID_by_ISYID(RHS_ID_of_RULE(rule,piece_start+piece_ix));
}
nrl_finish(g,chaf_nrl);
Rank_of_NRL(chaf_nrl)= NRL_CHAF_Rank_by_IRL(rule,1);
/*440:*/
#line 4651 "./marpa.w"

{
const int is_virtual_lhs= (piece_start> 0);
NRL_is_CHAF(chaf_nrl)= 1;
Source_IRL_of_NRL(chaf_nrl)= rule;
NRL_has_Virtual_LHS(chaf_nrl)= Boolean(is_virtual_lhs);
NRL_has_Virtual_RHS(chaf_nrl)= 
Length_of_NRL(chaf_nrl)> real_symbol_count;
Virtual_Start_of_NRL(chaf_nrl)= piece_start;
Virtual_End_of_NRL(chaf_nrl)= piece_start+real_symbol_count-1;
Real_SYM_Count_of_NRL(chaf_nrl)= real_symbol_count;
LHS_IRL_of_NSY(current_lhs_nsy)= chaf_irl;
IRL_Offset_of_NSY(current_lhs_nsy)= piece_start;
}

/*:440*/
#line 4541 "./marpa.w"

}

/*:435*/
#line 4469 "./marpa.w"

/*436:*/
#line 4546 "./marpa.w"

{
if(piece_start<nullable_suffix_ix){
int piece_ix;
const int first_nulling_piece_ix= first_factor_position-piece_start;
const int second_nulling_piece_ix= second_factor_position-piece_start;
const int chaf_nrl_length= (piece_end-piece_start)+1;
NRL chaf_nrl= nrl_start(g,chaf_nrl_length);
LHSID_of_NRL(chaf_nrl)= current_lhs_nsyid;
for(piece_ix= 0;piece_ix<first_nulling_piece_ix;piece_ix++)
{
RHSID_of_NRL(chaf_nrl,piece_ix)= 
NSYID_by_ISYID(RHS_ID_of_RULE(rule,piece_start+piece_ix));
}

RHSID_of_NRL(chaf_nrl,first_nulling_piece_ix)= 
Nulling_NSYID_by_ISYID(RHS_ID_of_RULE
(rule,piece_start+first_nulling_piece_ix));
for(piece_ix= first_nulling_piece_ix+1;
piece_ix<second_nulling_piece_ix;piece_ix++)
{
RHSID_of_NRL(chaf_nrl,piece_ix)= 
NSYID_by_ISYID(RHS_ID_of_RULE(rule,piece_start+piece_ix));
}

RHSID_of_NRL(chaf_nrl,second_nulling_piece_ix)= 
Nulling_NSYID_by_ISYID(RHS_ID_of_RULE
(rule,piece_start+second_nulling_piece_ix));
for(piece_ix= second_nulling_piece_ix+1;piece_ix<chaf_nrl_length;
piece_ix++)
{
RHSID_of_NRL(chaf_nrl,piece_ix)= 
NSYID_by_ISYID(RHS_ID_of_RULE(rule,piece_start+piece_ix));
}

nrl_finish(g,chaf_nrl);
Rank_of_NRL(chaf_nrl)= NRL_CHAF_Rank_by_IRL(rule,0);
/*440:*/
#line 4651 "./marpa.w"

{
const int is_virtual_lhs= (piece_start> 0);
NRL_is_CHAF(chaf_nrl)= 1;
Source_IRL_of_NRL(chaf_nrl)= rule;
NRL_has_Virtual_LHS(chaf_nrl)= Boolean(is_virtual_lhs);
NRL_has_Virtual_RHS(chaf_nrl)= 
Length_of_NRL(chaf_nrl)> real_symbol_count;
Virtual_Start_of_NRL(chaf_nrl)= piece_start;
Virtual_End_of_NRL(chaf_nrl)= piece_start+real_symbol_count-1;
Real_SYM_Count_of_NRL(chaf_nrl)= real_symbol_count;
LHS_IRL_of_NSY(current_lhs_nsy)= chaf_irl;
IRL_Offset_of_NSY(current_lhs_nsy)= piece_start;
}

/*:440*/
#line 4583 "./marpa.w"

}
}

/*:436*/
#line 4470 "./marpa.w"

}

/*:432*/
#line 4205 "./marpa.w"

}else{
/*437:*/
#line 4588 "./marpa.w"

{
int real_symbol_count;
const int first_factor_position= factor_positions[factor_position_ix];
piece_end= Length_of_IRL(rule)-1;
real_symbol_count= piece_end-piece_start+1;
/*438:*/
#line 4599 "./marpa.w"

{
int piece_ix;
const int chaf_nrl_length= (piece_end-piece_start)+1;
NRL chaf_nrl= nrl_start(g,chaf_nrl_length);
LHSID_of_NRL(chaf_nrl)= current_lhs_nsyid;
for(piece_ix= 0;piece_ix<chaf_nrl_length;piece_ix++)
{
RHSID_of_NRL(chaf_nrl,piece_ix)= 
NSYID_by_ISYID(RHS_ID_of_RULE(rule,piece_start+piece_ix));
}
nrl_finish(g,chaf_nrl);
Rank_of_NRL(chaf_nrl)= NRL_CHAF_Rank_by_IRL(rule,3);
/*440:*/
#line 4651 "./marpa.w"

{
const int is_virtual_lhs= (piece_start> 0);
NRL_is_CHAF(chaf_nrl)= 1;
Source_IRL_of_NRL(chaf_nrl)= rule;
NRL_has_Virtual_LHS(chaf_nrl)= Boolean(is_virtual_lhs);
NRL_has_Virtual_RHS(chaf_nrl)= 
Length_of_NRL(chaf_nrl)> real_symbol_count;
Virtual_Start_of_NRL(chaf_nrl)= piece_start;
Virtual_End_of_NRL(chaf_nrl)= piece_start+real_symbol_count-1;
Real_SYM_Count_of_NRL(chaf_nrl)= real_symbol_count;
LHS_IRL_of_NSY(current_lhs_nsy)= chaf_irl;
IRL_Offset_of_NSY(current_lhs_nsy)= piece_start;
}

/*:440*/
#line 4612 "./marpa.w"

}

/*:438*/
#line 4594 "./marpa.w"

/*439:*/
#line 4617 "./marpa.w"

{
if(piece_start<nullable_suffix_ix)
{
int piece_ix;
const int nulling_piece_ix= first_factor_position-piece_start;
const int chaf_nrl_length= (piece_end-piece_start)+1;
NRL chaf_nrl= nrl_start(g,chaf_nrl_length);
LHSID_of_NRL(chaf_nrl)= current_lhs_nsyid;
for(piece_ix= 0;piece_ix<nulling_piece_ix;piece_ix++)
{
RHSID_of_NRL(chaf_nrl,piece_ix)= 
NSYID_by_ISYID(RHS_ID_of_RULE
(rule,piece_start+piece_ix));
}
RHSID_of_NRL(chaf_nrl,nulling_piece_ix)= 
Nulling_NSYID_by_ISYID(RHS_ID_of_RULE(rule,piece_start+nulling_piece_ix));
for(piece_ix= nulling_piece_ix+1;piece_ix<chaf_nrl_length;
piece_ix++)
{
RHSID_of_NRL(chaf_nrl,piece_ix)= 
NSYID_by_ISYID(RHS_ID_of_RULE
(rule,piece_start+piece_ix));
}
nrl_finish(g,chaf_nrl);
Rank_of_NRL(chaf_nrl)= NRL_CHAF_Rank_by_IRL(rule,0);
/*440:*/
#line 4651 "./marpa.w"

{
const int is_virtual_lhs= (piece_start> 0);
NRL_is_CHAF(chaf_nrl)= 1;
Source_IRL_of_NRL(chaf_nrl)= rule;
NRL_has_Virtual_LHS(chaf_nrl)= Boolean(is_virtual_lhs);
NRL_has_Virtual_RHS(chaf_nrl)= 
Length_of_NRL(chaf_nrl)> real_symbol_count;
Virtual_Start_of_NRL(chaf_nrl)= piece_start;
Virtual_End_of_NRL(chaf_nrl)= piece_start+real_symbol_count-1;
Real_SYM_Count_of_NRL(chaf_nrl)= real_symbol_count;
LHS_IRL_of_NSY(current_lhs_nsy)= chaf_irl;
IRL_Offset_of_NSY(current_lhs_nsy)= piece_start;
}

/*:440*/
#line 4643 "./marpa.w"

}
}

/*:439*/
#line 4595 "./marpa.w"

}

/*:437*/
#line 4207 "./marpa.w"

}
}

/*:419*/
#line 4113 "./marpa.w"

continue;
}
/*260:*/
#line 2272 "./marpa.w"

{
int symbol_ix;
const NRL new_nrl= nrl_start(g,rewrite_irl_length);
Source_IRL_of_NRL(new_nrl)= rule;
Rank_of_NRL(new_nrl)= NRL_Rank_by_IRL(rule);
for(symbol_ix= 0;symbol_ix<=rewrite_irl_length;symbol_ix++)
{
new_nrl->t_nsyid_array[symbol_ix]= 
NSYID_by_ISYID(rule->t_symbols[symbol_ix]);
}
nrl_finish(g,new_nrl);
}

/*:260*/
#line 4116 "./marpa.w"

}
}

/*:413*/
#line 3224 "./marpa.w"

/*442:*/
#line 4669 "./marpa.w"

{
const ISY start_isy= ISY_by_ID(start_isy_id);
if(_MARPA_LIKELY(!ISY_is_Nulling(start_isy))){
/*443:*/
#line 4677 "./marpa.w"
{
NRL new_start_nrl;

const NSY new_start_nsy= nsy_new(g,start_isy);
NSY_is_Start(new_start_nsy)= 1;

new_start_nrl= nrl_start(g,1);
LHSID_of_NRL(new_start_nrl)= ID_of_NSY(new_start_nsy);
RHSID_of_NRL(new_start_nrl,0)= NSYID_of_ISY(start_isy);
nrl_finish(g,new_start_nrl);
NRL_has_Virtual_LHS(new_start_nrl)= 1;
Real_SYM_Count_of_NRL(new_start_nrl)= 1;
g->t_start_nrl= new_start_nrl;

}

/*:443*/
#line 4673 "./marpa.w"

}
}

/*:442*/
#line 3225 "./marpa.w"

post_census_isy_count= ISY_Count_of_G(g);
/*527:*/
#line 5627 "./marpa.w"

{
int isyid;
g->t_lbv_isyid_is_completion_event= 
bv_obs_create(g->t_obs,post_census_isy_count);
g->t_lbv_isyid_completion_event_starts_active= 
bv_obs_create(g->t_obs,post_census_isy_count);
g->t_lbv_isyid_is_nulled_event= 
bv_obs_create(g->t_obs,post_census_isy_count);
g->t_lbv_isyid_nulled_event_starts_active= 
bv_obs_create(g->t_obs,post_census_isy_count);
g->t_lbv_isyid_is_prediction_event= 
bv_obs_create(g->t_obs,post_census_isy_count);
g->t_lbv_isyid_prediction_event_starts_active= 
bv_obs_create(g->t_obs,post_census_isy_count);
for(isyid= 0;isyid<post_census_isy_count;isyid++)
{
if(ISYID_is_Completion_Event(isyid))
{
lbv_bit_set(g->t_lbv_isyid_is_completion_event,isyid);
}
if(ISYID_Completion_Event_Starts_Active(isyid))
{
lbv_bit_set(g->t_lbv_isyid_completion_event_starts_active,isyid);
}
if(ISYID_is_Nulled_Event(isyid))
{
lbv_bit_set(g->t_lbv_isyid_is_nulled_event,isyid);
}
if(ISYID_Nulled_Event_Starts_Active(isyid))
{
lbv_bit_set(g->t_lbv_isyid_nulled_event_starts_active,isyid);
}
if(ISYID_is_Prediction_Event(isyid))
{
lbv_bit_set(g->t_lbv_isyid_is_prediction_event,isyid);
}
if(ISYID_Prediction_Event_Starts_Active(isyid))
{
lbv_bit_set(g->t_lbv_isyid_prediction_event_starts_active,isyid);
}
}
}

/*:527*/
#line 3227 "./marpa.w"




if(!G_is_Trivial(g)){
/*514:*/
#line 5421 "./marpa.w"

const RULEID nrl_count= NRL_Count_of_G(g);
const NSYID nsy_count= NSY_Count_of_G(g);
Bit_Matrix nsy_by_right_nsy_matrix;
Bit_Matrix prediction_nsy_by_nrl_matrix;

/*:514*/
#line 3233 "./marpa.w"

/*517:*/
#line 5443 "./marpa.w"

{
NSYID lhsid;




void*matrix_buffer= my_malloc(matrix_sizeof(
nsy_count,nrl_count));
Bit_Matrix nrl_by_lhs_matrix= 
matrix_buffer_create(matrix_buffer,nsy_count,nrl_count);

NRLID nrl_id;
for(nrl_id= 0;nrl_id<nrl_count;nrl_id++)
{
const NRL nrl= NRL_by_ID(nrl_id);
const NSYID lhs_nsyid= LHSID_of_NRL(nrl);
matrix_bit_set(nrl_by_lhs_matrix,lhs_nsyid,nrl_id);
}




for(lhsid= 0;lhsid<nsy_count;lhsid++)
{
NRLID nrlid;
int min,max,start;
cil_buffer_clear(&g->t_cilar);
for(start= 0;
bv_scan(matrix_row
(nrl_by_lhs_matrix,lhsid),
start,&min,&max);start= max+2)
{
for(nrlid= min;nrlid<=max;nrlid++)
{
cil_buffer_push(&g->t_cilar,nrlid);
}
}
LHS_CIL_of_NSYID(lhsid)= cil_buffer_add(&g->t_cilar);
}

my_free(matrix_buffer);

}

/*:517*/
#line 3234 "./marpa.w"

/*488:*/
#line 5077 "./marpa.w"

{
NRLID nrl_id;
int ahm_count= 0;
AHM base_item;
AHM current_item;
int symbol_instance_of_next_rule= 0;
for(nrl_id= 0;nrl_id<nrl_count;nrl_id++){
const NRL nrl= NRL_by_ID(nrl_id);
/*490:*/
#line 5130 "./marpa.w"

{
int rhs_ix;
for(rhs_ix= 0;rhs_ix<Length_of_NRL(nrl);rhs_ix++)
{
const NSYID rh_nsyid= RHSID_of_NRL(nrl,rhs_ix);
const NSY nsy= NSY_by_ID(rh_nsyid);
if(!NSY_is_Nulling(nsy))ahm_count++;
}
ahm_count++;
}

/*:490*/
#line 5086 "./marpa.w"

}
current_item= base_item= marpa_new(struct s_ahm,ahm_count);
for(nrl_id= 0;nrl_id<nrl_count;nrl_id++){
const NRL nrl= NRL_by_ID(nrl_id);
SYMI_of_NRL(nrl)= symbol_instance_of_next_rule;
/*489:*/
#line 5105 "./marpa.w"

{
int leading_nulls= 0;
int rhs_ix;
const AHM first_ahm_of_nrl= current_item;
for(rhs_ix= 0;rhs_ix<Length_of_NRL(nrl);rhs_ix++)
{
NSYID rh_nsyid= RHSID_of_NRL(nrl,rhs_ix);
if(!NSY_is_Nulling(NSY_by_ID(rh_nsyid)))
{
Last_Proper_SYMI_of_NRL(nrl)= symbol_instance_of_next_rule+rhs_ix;
/*491:*/
#line 5142 "./marpa.w"

{
/*493:*/
#line 5165 "./marpa.w"

{
NRL_of_AHM(current_item)= nrl;
Null_Count_of_AHM(current_item)= leading_nulls;
Quasi_Position_of_AHM(current_item)= (int)(current_item-first_ahm_of_nrl);
if(Quasi_Position_of_AHM(current_item)==0){
if(ID_of_NRL(nrl)==ID_of_NRL(g->t_start_nrl))
{
AHM_was_Predicted(current_item)= 0;
AHM_is_Initial(current_item)= 1;
}else{
AHM_was_Predicted(current_item)= 1;
AHM_is_Initial(current_item)= 0;
}
}else{
AHM_was_Predicted(current_item)= 0;
AHM_is_Initial(current_item)= 0;
}
/*508:*/
#line 5318 "./marpa.w"

Event_AHMIDs_of_AHM(current_item)= NULL;
Event_Group_Size_of_AHM(current_item)= 0;

/*:508*/
#line 5183 "./marpa.w"

}

/*:493*/
#line 5144 "./marpa.w"

AHM_predicts_ZWA(current_item)= 0;

Postdot_NSYID_of_AHM(current_item)= rh_nsyid;
Position_of_AHM(current_item)= rhs_ix;
SYMI_of_AHM(current_item)
= AHM_is_Prediction(current_item)
?-1
:SYMI_of_NRL(nrl)+Position_of_AHM(current_item-1);
memoize_irl_data_for_AHM(current_item,nrl);
}

/*:491*/
#line 5116 "./marpa.w"

current_item++;
leading_nulls= 0;
}
else
{
leading_nulls++;
}
}
/*492:*/
#line 5156 "./marpa.w"

{
/*493:*/
#line 5165 "./marpa.w"

{
NRL_of_AHM(current_item)= nrl;
Null_Count_of_AHM(current_item)= leading_nulls;
Quasi_Position_of_AHM(current_item)= (int)(current_item-first_ahm_of_nrl);
if(Quasi_Position_of_AHM(current_item)==0){
if(ID_of_NRL(nrl)==ID_of_NRL(g->t_start_nrl))
{
AHM_was_Predicted(current_item)= 0;
AHM_is_Initial(current_item)= 1;
}else{
AHM_was_Predicted(current_item)= 1;
AHM_is_Initial(current_item)= 0;
}
}else{
AHM_was_Predicted(current_item)= 0;
AHM_is_Initial(current_item)= 0;
}
/*508:*/
#line 5318 "./marpa.w"

Event_AHMIDs_of_AHM(current_item)= NULL;
Event_Group_Size_of_AHM(current_item)= 0;

/*:508*/
#line 5183 "./marpa.w"

}

/*:493*/
#line 5158 "./marpa.w"

Postdot_NSYID_of_AHM(current_item)= -1;
Position_of_AHM(current_item)= -1;
SYMI_of_AHM(current_item)= SYMI_of_NRL(nrl)+Position_of_AHM(current_item-1);
memoize_irl_data_for_AHM(current_item,nrl);
}

/*:492*/
#line 5125 "./marpa.w"

current_item++;
AHM_Count_of_NRL(nrl)= (int)(current_item-first_ahm_of_nrl);
}

/*:489*/
#line 5092 "./marpa.w"

{
symbol_instance_of_next_rule+= Length_of_NRL(nrl);
}
}
SYMI_Count_of_G(g)= symbol_instance_of_next_rule;
MARPA_ASSERT(ahm_count==current_item-base_item);
AHM_Count_of_G(g)= ahm_count;
MARPA_DEBUG3("At %s, Setting debug count to %ld",STRLOC,(long)ahm_count);
g->t_ahms= marpa_renew(struct s_ahm,base_item,ahm_count);
/*496:*/
#line 5236 "./marpa.w"

{
AHM items= g->t_ahms;
AHMID item_id= (AHMID)ahm_count;
for(item_id--;item_id>=0;item_id--)
{
AHM item= items+item_id;
NRL nrl= NRL_of_AHM(item);
First_AHM_of_NRL(nrl)= item;
}
}

/*:496*/
#line 5102 "./marpa.w"

}

/*:488*/
#line 3235 "./marpa.w"

/*520:*/
#line 5496 "./marpa.w"
{
Bit_Matrix prediction_nsy_by_nsy_matrix= 
matrix_obs_create(obs_precompute,nsy_count,nsy_count);
/*521:*/
#line 5504 "./marpa.w"

{
NRLID nrl_id;
NSYID nsyid;
for(nsyid= 0;nsyid<nsy_count;nsyid++)
{

NSY nsy= NSY_by_ID(nsyid);
if(!NSY_is_LHS(nsy))continue;
matrix_bit_set(prediction_nsy_by_nsy_matrix,nsyid,
nsyid);
}
for(nrl_id= 0;nrl_id<nrl_count;nrl_id++)
{
NSYID from_nsyid,to_nsyid;
const NRL nrl= NRL_by_ID(nrl_id);

const AHM item= First_AHM_of_NRL(nrl);
to_nsyid= Postdot_NSYID_of_AHM(item);

if(to_nsyid<0)
continue;

from_nsyid= LHS_NSYID_of_AHM(item);
matrix_bit_set(prediction_nsy_by_nsy_matrix,
from_nsyid,
to_nsyid);
}
}

/*:521*/
#line 5499 "./marpa.w"

transitive_closure(prediction_nsy_by_nsy_matrix);
/*522:*/
#line 5541 "./marpa.w"
{
/*523:*/
#line 5545 "./marpa.w"

{
NSYID from_nsyid;
prediction_nsy_by_nrl_matrix= 
matrix_obs_create(obs_precompute,nsy_count,
nrl_count);
for(from_nsyid= 0;from_nsyid<nsy_count;from_nsyid++)
{


int min,max,start;
for(start= 0;
bv_scan(matrix_row
(prediction_nsy_by_nsy_matrix,from_nsyid),
start,&min,&max);start= max+2)
{
NSYID to_nsyid;



for(to_nsyid= min;to_nsyid<=max;to_nsyid++)
{
int cil_ix;
const CIL lhs_cil= LHS_CIL_of_NSYID(to_nsyid);
const int cil_count= Count_of_CIL(lhs_cil);
for(cil_ix= 0;cil_ix<cil_count;cil_ix++)
{
const NRLID nrlid= Item_of_CIL(lhs_cil,cil_ix);
matrix_bit_set(prediction_nsy_by_nrl_matrix,
from_nsyid,nrlid);
}
}
}
}
}

/*:523*/
#line 5542 "./marpa.w"

}

/*:522*/
#line 5501 "./marpa.w"

}

/*:520*/
#line 3236 "./marpa.w"

/*510:*/
#line 5331 "./marpa.w"
{
nsy_by_right_nsy_matrix= 
matrix_obs_create(obs_precompute,nsy_count,nsy_count);
/*511:*/
#line 5342 "./marpa.w"

{
NRLID nrl_id;
for(nrl_id= 0;nrl_id<nrl_count;nrl_id++)
{
const NRL nrl= NRL_by_ID(nrl_id);
int rhs_ix;
for(rhs_ix= Length_of_NRL(nrl)-1;
rhs_ix>=0;
rhs_ix--)
{


const NSYID rh_nsyid= RHSID_of_NRL(nrl,rhs_ix);
if(!NSY_is_Nulling(NSY_by_ID(rh_nsyid)))
{
matrix_bit_set(nsy_by_right_nsy_matrix,
LHSID_of_NRL(nrl),
rh_nsyid);
break;
}
}
}
}

/*:511*/
#line 5334 "./marpa.w"

transitive_closure(nsy_by_right_nsy_matrix);
/*512:*/
#line 5367 "./marpa.w"

{
NRLID nrl_id;
for(nrl_id= 0;nrl_id<nrl_count;nrl_id++)
{
const NRL nrl= NRL_by_ID(nrl_id);
int rhs_ix;
for(rhs_ix= Length_of_NRL(nrl)-1;rhs_ix>=0;rhs_ix--)
{
const NSYID rh_nsyid= RHSID_of_NRL(nrl,rhs_ix);
if(!NSY_is_Nulling(NSY_by_ID(rh_nsyid)))
{



if(matrix_bit_test(nsy_by_right_nsy_matrix,
rh_nsyid,
LHSID_of_NRL(nrl)))
{
NRL_is_Right_Recursive(nrl)= 1;
}
break;
}
}
}
}

/*:512*/
#line 5336 "./marpa.w"

matrix_clear(nsy_by_right_nsy_matrix);
/*513:*/
#line 5394 "./marpa.w"

{
NRLID nrl_id;
for(nrl_id= 0;nrl_id<nrl_count;nrl_id++)
{
int rhs_ix;
const NRL nrl= NRL_by_ID(nrl_id);
if(!NRL_is_Right_Recursive(nrl)){continue;}
for(rhs_ix= Length_of_NRL(nrl)-1;
rhs_ix>=0;
rhs_ix--)
{


const NSYID rh_nsyid= RHSID_of_NRL(nrl,rhs_ix);
if(!NSY_is_Nulling(NSY_by_ID(rh_nsyid)))
{
matrix_bit_set(nsy_by_right_nsy_matrix,
LHSID_of_NRL(nrl),
rh_nsyid);
break;
}
}
}
}

/*:513*/
#line 5338 "./marpa.w"

transitive_closure(nsy_by_right_nsy_matrix);
}

/*:510*/
#line 3237 "./marpa.w"

/*525:*/
#line 5582 "./marpa.w"

{
AHMID ahm_id;
const int ahm_count= AHM_Count_of_G(g);
for(ahm_id= 0;ahm_id<ahm_count;ahm_id++)
{
const AHM ahm= AHM_by_ID(ahm_id);
const NSYID postdot_nsyid= Postdot_NSYID_of_AHM(ahm);
if(postdot_nsyid<0)
{
Predicted_NRL_CIL_of_AHM(ahm)= cil_empty(&g->t_cilar);
LHS_CIL_of_AHM(ahm)= cil_empty(&g->t_cilar);
}
else
{
Predicted_NRL_CIL_of_AHM(ahm)= 
cil_bv_add(&g->t_cilar,
matrix_row(prediction_nsy_by_nrl_matrix,postdot_nsyid));
LHS_CIL_of_AHM(ahm)= LHS_CIL_of_NSYID(postdot_nsyid);
}
}
}

/*:525*/
#line 3238 "./marpa.w"

/*526:*/
#line 5606 "./marpa.w"

{
int isy_id;
g->t_bv_nsyid_is_terminal= bv_obs_create(g->t_obs,nsy_count);
for(isy_id= 0;isy_id<post_census_isy_count;isy_id++)
{
if(ISYID_is_Terminal(isy_id))
{


const NSY nsy= NSY_of_ISY(ISY_by_ID(isy_id));
if(nsy)
{
bv_bit_set(g->t_bv_nsyid_is_terminal,
ID_of_NSY(nsy));
}
}
}
}

/*:526*/
#line 3239 "./marpa.w"

/*528:*/
#line 5671 "./marpa.w"

{
AHMID ahm_id;
const int ahm_count_of_g= AHM_Count_of_G(g);
const LBV bv_completion_isyid= bv_create(post_census_isy_count);
const LBV bv_prediction_isyid= bv_create(post_census_isy_count);
const LBV bv_nulled_isyid= bv_create(post_census_isy_count);
const CILAR cilar= &g->t_cilar;
for(ahm_id= 0;ahm_id<ahm_count_of_g;ahm_id++)
{
const AHM ahm= AHM_by_ID(ahm_id);
const NSYID postdot_nsyid= Postdot_NSYID_of_AHM(ahm);
const NRL nrl= NRL_of_AHM(ahm);
bv_clear(bv_completion_isyid);
bv_clear(bv_prediction_isyid);
bv_clear(bv_nulled_isyid);
{
int rhs_ix;
int raw_position= Position_of_AHM(ahm);
if(raw_position<0)
{
raw_position= Length_of_NRL(nrl);
if(!NRL_has_Virtual_LHS(nrl))
{
const NSY lhs= LHS_of_NRL(nrl);
const ISY isy= Source_ISY_of_NSY(lhs);
if(ISY_is_Completion_Event(isy))
{
const ISYID isyid= ID_of_ISY(isy);
bv_bit_set(bv_completion_isyid,isyid);
}
}
}
if(postdot_nsyid>=0)
{
const ISY isy= Source_ISY_of_NSYID(postdot_nsyid);
const ISYID isyid= ID_of_ISY(isy);
bv_bit_set(bv_prediction_isyid,isyid);
}
for(rhs_ix= raw_position-Null_Count_of_AHM(ahm);
rhs_ix<raw_position;rhs_ix++)
{
int cil_ix;
const NSYID rhs_nsyid= RHSID_of_NRL(nrl,rhs_ix);
const ISY isy= Source_ISY_of_NSYID(rhs_nsyid);
const CIL nulled_isyids= Nulled_ISYIDs_of_ISY(isy);
const int cil_count= Count_of_CIL(nulled_isyids);
for(cil_ix= 0;cil_ix<cil_count;cil_ix++)
{
const ISYID nulled_isyid= 
Item_of_CIL(nulled_isyids,cil_ix);
bv_bit_set(bv_nulled_isyid,nulled_isyid);
}
}
}
Completion_ISYIDs_of_AHM(ahm)= 
cil_bv_add(cilar,bv_completion_isyid);
Nulled_ISYIDs_of_AHM(ahm)= cil_bv_add(cilar,bv_nulled_isyid);
Prediction_ISYIDs_of_AHM(ahm)= 
cil_bv_add(cilar,bv_prediction_isyid);
}
bv_free(bv_completion_isyid);
bv_free(bv_prediction_isyid);
bv_free(bv_nulled_isyid);
}

/*:528*/
#line 3241 "./marpa.w"

/*529:*/
#line 5737 "./marpa.w"

{
AHMID ahm_id;
for(ahm_id= 0;ahm_id<AHM_Count_of_G(g);ahm_id++)
{
const CILAR cilar= &g->t_cilar;
const AHM ahm= AHM_by_ID(ahm_id);
const int ahm_is_event= 
Count_of_CIL(Completion_ISYIDs_of_AHM(ahm))
||Count_of_CIL(Nulled_ISYIDs_of_AHM(ahm))
||Count_of_CIL(Prediction_ISYIDs_of_AHM(ahm));
Event_AHMIDs_of_AHM(ahm)= 
ahm_is_event?cil_singleton(cilar,ahm_id):cil_empty(cilar);
}
}

/*:529*/
#line 3242 "./marpa.w"

/*530:*/
#line 5753 "./marpa.w"

{
const int ahm_count_of_g= AHM_Count_of_G(g);
AHMID outer_ahm_id;
for(outer_ahm_id= 0;outer_ahm_id<ahm_count_of_g;outer_ahm_id++)
{
AHMID inner_ahm_id;
const AHM outer_ahm= AHM_by_ID(outer_ahm_id);




NSYID outer_nsyid;
if(!AHM_is_Leo_Completion(outer_ahm)){
if(AHM_has_Event(outer_ahm)){
Event_Group_Size_of_AHM(outer_ahm)= 1;
}
continue;

}
outer_nsyid= LHSID_of_AHM(outer_ahm);
for(inner_ahm_id= 0;inner_ahm_id<ahm_count_of_g;
inner_ahm_id++)
{
NSYID inner_nsyid;
const AHM inner_ahm= AHM_by_ID(inner_ahm_id);
if(!AHM_has_Event(inner_ahm))
continue;

if(!AHM_is_Leo_Completion(inner_ahm))
continue;

inner_nsyid= LHSID_of_AHM(inner_ahm);
if(matrix_bit_test(nsy_by_right_nsy_matrix,
outer_nsyid,
inner_nsyid))
{



Event_Group_Size_of_AHM(outer_ahm)++;
}
}
}
}

/*:530*/
#line 3243 "./marpa.w"

/*549:*/
#line 5958 "./marpa.w"

{
AHMID ahm_id;
const int ahm_count_of_g= AHM_Count_of_G(g);
for(ahm_id= 0;ahm_id<ahm_count_of_g;ahm_id++)
{
ZWP_Object sought_zwp_object;
ZWP sought_zwp= &sought_zwp_object;
ZWP found_zwp;
MARPA_AVL_TRAV traverser;
const AHM ahm= AHM_by_ID(ahm_id);
const IRL ahm_irl= IRL_of_AHM(ahm);
cil_buffer_clear(&g->t_cilar);
if(ahm_irl)
{
const int irl_dot_end= Raw_IRL_Position_of_AHM(ahm);
const int irl_dot_start= irl_dot_end-Null_Count_of_AHM(ahm);


const IRLID sought_irlid= ID_of_IRL(ahm_irl);
IRLID_of_ZWP(sought_zwp)= sought_irlid;
Dot_of_ZWP(sought_zwp)= irl_dot_start;
ZWAID_of_ZWP(sought_zwp)= 0;
traverser= _marpa_avl_t_init((g)->t_zwp_tree);
found_zwp= _marpa_avl_t_at_or_after(traverser,sought_zwp);



while(
found_zwp
&&IRLID_of_ZWP(found_zwp)==sought_irlid
&&Dot_of_ZWP(found_zwp)<=irl_dot_end)
{
cil_buffer_push(&g->t_cilar,ZWAID_of_ZWP(found_zwp));
found_zwp= _marpa_avl_t_next(traverser);
}
}
ZWA_CIL_of_AHM(ahm)= cil_buffer_add(&g->t_cilar);
}
}

/*:549*/
#line 3244 "./marpa.w"

/*550:*/
#line 6003 "./marpa.w"

{
AHMID ahm_id;
const int ahm_count_of_g= AHM_Count_of_G(g);
for(ahm_id= 0;ahm_id<ahm_count_of_g;ahm_id++)
{
const AHM ahm_to_populate= AHM_by_ID(ahm_id);




const CIL prediction_cil= Predicted_NRL_CIL_of_AHM(ahm_to_populate);
const int prediction_count= Count_of_CIL(prediction_cil);

int cil_ix;
for(cil_ix= 0;cil_ix<prediction_count;cil_ix++)
{
const NRLID prediction_nrlid= Item_of_CIL(prediction_cil,cil_ix);
const AHM prediction_ahm_of_nrl= First_AHM_of_NRLID(prediction_nrlid);
const CIL zwaids_of_prediction= ZWA_CIL_of_AHM(prediction_ahm_of_nrl);
if(Count_of_CIL(zwaids_of_prediction)> 0){
AHM_predicts_ZWA(ahm_to_populate)= 1;
break;
}
}
}
}

/*:550*/
#line 3245 "./marpa.w"

}
g->t_is_precomputed= 1;
if(g->t_has_cycle)
{
MARPA_ERROR(MARPA_ERR_GRAMMAR_HAS_CYCLE);
goto FAILURE;
}
/*369:*/
#line 3267 "./marpa.w"

{cilar_buffer_reinit(&g->t_cilar);}
/*:369*/
#line 3253 "./marpa.w"

return_value= 0;
goto CLEANUP;
FAILURE:;
goto CLEANUP;
CLEANUP:;
marpa_obs_free(obs_precompute);
return return_value;
}

/*:368*//*379:*/
#line 3366 "./marpa.w"

PRIVATE_NOT_INLINE int sym_rule_cmp(
const void*ap,
const void*bp,
void*param UNUSED)
{
const struct sym_rule_pair*pair_a= (struct sym_rule_pair*)ap;
const struct sym_rule_pair*pair_b= (struct sym_rule_pair*)bp;
int result= pair_a->t_symid-pair_b->t_symid;
if(result)return result;
return pair_a->t_ruleid-pair_b->t_ruleid;
}

/*:379*//*412:*/
#line 4078 "./marpa.w"

int _marpa_g_nrl_is_chaf(
Marpa_Grammar g,
Marpa_NRL_ID nrl_id)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 4083 "./marpa.w"

/*1318:*/
#line 15700 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1318*/
#line 4084 "./marpa.w"

/*1325:*/
#line 15741 "./marpa.w"

if(_MARPA_UNLIKELY(!NRLID_of_G_is_Valid(nrl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_NRLID);
return failure_indicator;
}
/*:1325*/
#line 4085 "./marpa.w"

return NRL_is_CHAF(NRL_by_ID(nrl_id));
}

/*:412*//*462:*/
#line 4896 "./marpa.w"

PRIVATE int ahm_is_valid(
GRAMMAR g,AHMID item_id)
{
return item_id<(AHMID)AHM_Count_of_G(g)&&item_id>=0;
}

/*:462*//*479:*/
#line 5022 "./marpa.w"

int _marpa_g_ahm_count(Marpa_Grammar g){
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 5024 "./marpa.w"

/*1318:*/
#line 15700 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1318*/
#line 5025 "./marpa.w"

return AHM_Count_of_G(g);
}

/*:479*//*480:*/
#line 5029 "./marpa.w"

Marpa_NRL_ID _marpa_g_ahm_nrl(Marpa_Grammar g,
Marpa_AHM_ID item_id){
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 5032 "./marpa.w"

/*1318:*/
#line 15700 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1318*/
#line 5033 "./marpa.w"

/*1331:*/
#line 15784 "./marpa.w"

if(_MARPA_UNLIKELY(!ahm_is_valid(g,item_id))){
MARPA_ERROR(MARPA_ERR_INVALID_AIMID);
return failure_indicator;
}

/*:1331*/
#line 5034 "./marpa.w"

return NRLID_of_AHM(AHM_by_ID(item_id));
}

/*:480*//*482:*/
#line 5039 "./marpa.w"

int _marpa_g_ahm_position(Marpa_Grammar g,
Marpa_AHM_ID item_id){
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 5042 "./marpa.w"

/*1318:*/
#line 15700 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1318*/
#line 5043 "./marpa.w"

/*1331:*/
#line 15784 "./marpa.w"

if(_MARPA_UNLIKELY(!ahm_is_valid(g,item_id))){
MARPA_ERROR(MARPA_ERR_INVALID_AIMID);
return failure_indicator;
}

/*:1331*/
#line 5044 "./marpa.w"

return Position_of_AHM(AHM_by_ID(item_id));
}

/*:482*//*483:*/
#line 5048 "./marpa.w"

int _marpa_g_ahm_raw_position(Marpa_Grammar g,
Marpa_AHM_ID item_id){
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 5051 "./marpa.w"

/*1318:*/
#line 15700 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1318*/
#line 5052 "./marpa.w"

/*1331:*/
#line 15784 "./marpa.w"

if(_MARPA_UNLIKELY(!ahm_is_valid(g,item_id))){
MARPA_ERROR(MARPA_ERR_INVALID_AIMID);
return failure_indicator;
}

/*:1331*/
#line 5053 "./marpa.w"

return Raw_Position_of_AHM(AHM_by_ID(item_id));
}

/*:483*//*484:*/
#line 5057 "./marpa.w"

int _marpa_g_ahm_null_count(Marpa_Grammar g,
Marpa_AHM_ID item_id){
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 5060 "./marpa.w"

/*1318:*/
#line 15700 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1318*/
#line 5061 "./marpa.w"

/*1331:*/
#line 15784 "./marpa.w"

if(_MARPA_UNLIKELY(!ahm_is_valid(g,item_id))){
MARPA_ERROR(MARPA_ERR_INVALID_AIMID);
return failure_indicator;
}

/*:1331*/
#line 5062 "./marpa.w"

return Null_Count_of_AHM(AHM_by_ID(item_id));
}

/*:484*//*486:*/
#line 5067 "./marpa.w"

Marpa_Symbol_ID _marpa_g_ahm_postdot(Marpa_Grammar g,
Marpa_AHM_ID item_id){
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 5070 "./marpa.w"

/*1318:*/
#line 15700 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1318*/
#line 5071 "./marpa.w"

/*1331:*/
#line 15784 "./marpa.w"

if(_MARPA_UNLIKELY(!ahm_is_valid(g,item_id))){
MARPA_ERROR(MARPA_ERR_INVALID_AIMID);
return failure_indicator;
}

/*:1331*/
#line 5072 "./marpa.w"

return Postdot_NSYID_of_AHM(AHM_by_ID(item_id));
}

/*:486*//*494:*/
#line 5186 "./marpa.w"

PRIVATE void
memoize_irl_data_for_AHM(AHM current_item,NRL nrl)
{
IRL source_irl= Source_IRL_of_NRL(nrl);
IRL_of_AHM(current_item)= source_irl;
if(!source_irl){


IRL_Position_of_AHM(current_item)= -2;
return;
}
{
const int virtual_start= Virtual_Start_of_NRL(nrl);
const int nrl_position= Position_of_AHM(current_item);
if(IRL_is_Sequence(source_irl))
{




IRL_Position_of_AHM(current_item)= nrl_position?-1:0;
return;
}


if(NRL_is_CHAF(nrl)&&
(nrl_position<0||nrl_position>=Length_of_NRL(nrl)))
{
IRL_Position_of_AHM(current_item)= -1;
return;
}
if(virtual_start>=0)
{
IRL_Position_of_AHM(current_item)= nrl_position+virtual_start;
return;
}
IRL_Position_of_AHM(current_item)= nrl_position;
}
return;
}

/*:494*//*545:*/
#line 5868 "./marpa.w"

PRIVATE_NOT_INLINE int zwp_cmp(
const void*ap,
const void*bp,
void*param UNUSED)
{
const ZWP_Const zwp_a= ap;
const ZWP_Const zwp_b= bp;
int subkey= IRLID_of_ZWP(zwp_a)-IRLID_of_ZWP(zwp_b);
if(subkey)return subkey;
subkey= Dot_of_ZWP(zwp_a)-Dot_of_ZWP(zwp_b);
if(subkey)return subkey;
return ZWAID_of_ZWP(zwp_a)-ZWAID_of_ZWP(zwp_b);
}

/*:545*//*546:*/
#line 5883 "./marpa.w"

Marpa_Assertion_ID
marpa_g_zwa_new(Marpa_Grammar g,int default_value)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 5887 "./marpa.w"

ZWAID zwa_id;
GZWA gzwa;
/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 5890 "./marpa.w"

/*1317:*/
#line 15694 "./marpa.w"

if(_MARPA_UNLIKELY(G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_PRECOMPUTED);
return failure_indicator;
}

/*:1317*/
#line 5891 "./marpa.w"

if(_MARPA_UNLIKELY(default_value<0||default_value> 1))
{
MARPA_ERROR(MARPA_ERR_INVALID_BOOLEAN);
return failure_indicator;
}
gzwa= marpa_obs_new(g->t_obs,GZWA_Object,1);
zwa_id= MARPA_DSTACK_LENGTH((g)->t_gzwa_stack);
*MARPA_DSTACK_PUSH((g)->t_gzwa_stack,GZWA)= gzwa;
gzwa->t_id= zwa_id;
gzwa->t_default_value= default_value?1:0;
return zwa_id;
}

/*:546*//*547:*/
#line 5905 "./marpa.w"

Marpa_Assertion_ID
marpa_g_highest_zwa_id(Marpa_Grammar g)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 5909 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 5910 "./marpa.w"

return ZWA_Count_of_G(g)-1;
}

/*:547*//*548:*/
#line 5917 "./marpa.w"

int
marpa_g_zwa_place(Marpa_Grammar g,
Marpa_Assertion_ID zwaid,
Marpa_Rule_ID irl_id,int rhs_ix)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 5923 "./marpa.w"

void*avl_insert_result;
ZWP zwp;
IRL xrl;
int irl_length;
/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 5928 "./marpa.w"

/*1317:*/
#line 15694 "./marpa.w"

if(_MARPA_UNLIKELY(G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_PRECOMPUTED);
return failure_indicator;
}

/*:1317*/
#line 5929 "./marpa.w"

/*1328:*/
#line 15761 "./marpa.w"

if(_MARPA_UNLIKELY(IRLID_is_Malformed(irl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_RULE_ID);
return failure_indicator;
}

/*:1328*/
#line 5930 "./marpa.w"

/*1326:*/
#line 15749 "./marpa.w"

if(_MARPA_UNLIKELY(!IRLID_of_G_Exists(irl_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_RULE_ID);
return-1;
}

/*:1326*/
#line 5931 "./marpa.w"

/*1330:*/
#line 15773 "./marpa.w"

if(_MARPA_UNLIKELY(ZWAID_is_Malformed(zwaid))){
MARPA_ERROR(MARPA_ERR_INVALID_ASSERTION_ID);
return failure_indicator;
}

/*:1330*/
#line 5932 "./marpa.w"

/*1329:*/
#line 15767 "./marpa.w"

if(_MARPA_UNLIKELY(!ZWAID_of_G_Exists(zwaid))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_ASSERTION_ID);
return failure_indicator;
}
/*:1329*/
#line 5933 "./marpa.w"

xrl= IRL_by_ID(irl_id);
if(rhs_ix<-1){
MARPA_ERROR(MARPA_ERR_RHS_IX_NEGATIVE);
return failure_indicator;
}
irl_length= Length_of_IRL(xrl);
if(irl_length<=rhs_ix){
MARPA_ERROR(MARPA_ERR_RHS_IX_OOB);
return failure_indicator;
}
if(rhs_ix==-1){
rhs_ix= IRL_is_Sequence(xrl)?1:irl_length;
}
zwp= marpa_obs_new(g->t_obs,ZWP_Object,1);
IRLID_of_ZWP(zwp)= irl_id;
Dot_of_ZWP(zwp)= rhs_ix;
ZWAID_of_ZWP(zwp)= zwaid;
avl_insert_result= _marpa_avl_insert(g->t_zwp_tree,zwp);
return avl_insert_result?-1:0;
}

/*:548*//*554:*/
#line 6049 "./marpa.w"

Marpa_Recognizer marpa_r_new(Marpa_Grammar g)
{
RECCE r;
int nsy_count;
int nrl_count;
/*1315:*/
#line 15686 "./marpa.w"
void*const failure_indicator= NULL;
/*:1315*/
#line 6055 "./marpa.w"

/*1318:*/
#line 15700 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1318*/
#line 6056 "./marpa.w"

nsy_count= NSY_Count_of_G(g);
nrl_count= NRL_Count_of_G(g);
r= my_malloc(sizeof(struct marpa_r));
/*619:*/
#line 6659 "./marpa.w"
r->t_obs= marpa_obs_init;
/*:619*/
#line 6060 "./marpa.w"

/*557:*/
#line 6069 "./marpa.w"

r->t_ref_count= 1;

/*:557*//*562:*/
#line 6120 "./marpa.w"

{
G_of_R(r)= g;
grammar_ref(g);
}
/*:562*//*567:*/
#line 6139 "./marpa.w"

Input_Phase_of_R(r)= R_BEFORE_INPUT;

/*:567*//*569:*/
#line 6149 "./marpa.w"

r->t_first_earley_set= NULL;
r->t_latest_earley_set= NULL;
r->t_current_earleme= -1;

/*:569*//*573:*/
#line 6183 "./marpa.w"

r->t_earley_item_warning_threshold= 
MAX(DEFAULT_YIM_WARNING_THRESHOLD,AHM_Count_of_G(g)*3);
/*:573*//*577:*/
#line 6212 "./marpa.w"
r->t_furthest_earleme= 0;
/*:577*//*584:*/
#line 6254 "./marpa.w"

r->t_bv_nsyid_is_expected= bv_obs_create(r->t_obs,nsy_count);
/*:584*//*588:*/
#line 6331 "./marpa.w"

r->t_nsy_expected_is_event= lbv_obs_new0(r->t_obs,nsy_count);
/*:588*//*606:*/
#line 6574 "./marpa.w"

r->t_use_leo_flag= 1;
r->t_is_using_leo= 0;
/*:606*//*610:*/
#line 6607 "./marpa.w"

r->t_bv_nrl_seen= bv_obs_create(r->t_obs,nrl_count);
MARPA_DSTACK_INIT2(r->t_nrl_cil_stack,CIL);
/*:610*//*613:*/
#line 6624 "./marpa.w"
r->t_is_exhausted= 0;
/*:613*//*617:*/
#line 6652 "./marpa.w"
r->t_first_inconsistent_ys= -1;

/*:617*//*623:*/
#line 6681 "./marpa.w"

{
ZWAID zwaid;
const int zwa_count= ZWA_Count_of_R(r);
(r)->t_zwas= marpa_obs_new(r->t_obs,ZWA_Object,ZWA_Count_of_R(r));
for(zwaid= 0;zwaid<zwa_count;zwaid++){
const GZWA gzwa= GZWA_by_ID(zwaid);
const ZWA zwa= RZWA_by_ID(zwaid);
ID_of_ZWA(zwa)= ID_of_GZWA(gzwa);
Default_Value_of_ZWA(zwa)= Default_Value_of_GZWA(gzwa);
Memo_Value_of_ZWA(zwa)= Default_Value_of_GZWA(gzwa);
Memo_YSID_of_ZWA(zwa)= -1;
}
}

/*:623*//*638:*/
#line 6775 "./marpa.w"

r->t_earley_set_count= 0;

/*:638*//*705:*/
#line 7578 "./marpa.w"

MARPA_DSTACK_INIT2(r->t_alternatives,ALT_Object);
/*:705*//*730:*/
#line 8076 "./marpa.w"
MARPA_DSTACK_SAFE(r->t_yim_work_stack);
/*:730*//*734:*/
#line 8091 "./marpa.w"
MARPA_DSTACK_SAFE(r->t_completion_stack);
/*:734*//*738:*/
#line 8102 "./marpa.w"
MARPA_DSTACK_SAFE(r->t_earley_set_stack);
/*:738*//*829:*/
#line 9635 "./marpa.w"

r->t_current_report_item= &progress_report_not_ready;
r->t_progress_report_traverser= NULL;
/*:829*//*863:*/
#line 10070 "./marpa.w"

ur_node_stack_init(URS_of_R(r));
/*:863*//*1348:*/
#line 15967 "./marpa.w"

r->t_trace_earley_set= NULL;

/*:1348*//*1355:*/
#line 16043 "./marpa.w"

r->t_trace_earley_item= NULL;

/*:1355*//*1369:*/
#line 16243 "./marpa.w"

r->t_trace_pim_nsy_p= NULL;
r->t_trace_postdot_item= NULL;
/*:1369*//*1377:*/
#line 16393 "./marpa.w"

r->t_trace_source_link= NULL;
r->t_trace_source_type= NO_SOURCE;

/*:1377*/
#line 6061 "./marpa.w"

/*1297:*/
#line 15499 "./marpa.w"

{
if(G_is_Trivial(g)){
psar_safe(Dot_PSAR_of_R(r));
}else{
psar_init(Dot_PSAR_of_R(r),AHM_Count_of_G(g));
}
}
/*:1297*/
#line 6062 "./marpa.w"

/*582:*/
#line 6234 "./marpa.w"

{
NSYID isy_count= ISY_Count_of_G(g);
r->t_lbv_isyid_completion_event_is_active= 
lbv_clone(r->t_obs,g->t_lbv_isyid_completion_event_starts_active,isy_count);
r->t_lbv_isyid_nulled_event_is_active= 
lbv_clone(r->t_obs,g->t_lbv_isyid_nulled_event_starts_active,isy_count);
r->t_lbv_isyid_prediction_event_is_active= 
lbv_clone(r->t_obs,g->t_lbv_isyid_prediction_event_starts_active,isy_count);
r->t_active_event_count= 
bv_count(g->t_lbv_isyid_is_completion_event)
+bv_count(g->t_lbv_isyid_is_nulled_event)
+bv_count(g->t_lbv_isyid_is_prediction_event);
}

/*:582*/
#line 6063 "./marpa.w"

return r;
}

/*:554*//*558:*/
#line 6073 "./marpa.w"

PRIVATE void
recce_unref(RECCE r)
{
MARPA_ASSERT(r->t_ref_count> 0)
r->t_ref_count--;
if(r->t_ref_count<=0)
{
recce_free(r);
}
}
void
marpa_r_unref(Marpa_Recognizer r)
{
recce_unref(r);
}

/*:558*//*559:*/
#line 6091 "./marpa.w"

PRIVATE
RECCE recce_ref(RECCE r)
{
MARPA_ASSERT(r->t_ref_count> 0)
r->t_ref_count++;
return r;
}
Marpa_Recognizer
marpa_r_ref(Marpa_Recognizer r)
{
return recce_ref(r);
}

/*:559*//*560:*/
#line 6105 "./marpa.w"

PRIVATE
void recce_free(struct marpa_r*r)
{
/*563:*/
#line 6125 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:563*/
#line 6109 "./marpa.w"

/*564:*/
#line 6127 "./marpa.w"
grammar_unref(g);

/*:564*//*611:*/
#line 6610 "./marpa.w"

MARPA_DSTACK_DESTROY(r->t_nrl_cil_stack);

/*:611*//*706:*/
#line 7580 "./marpa.w"
MARPA_DSTACK_DESTROY(r->t_alternatives);

/*:706*//*732:*/
#line 8084 "./marpa.w"
MARPA_DSTACK_DESTROY(r->t_yim_work_stack);

/*:732*//*736:*/
#line 8099 "./marpa.w"
MARPA_DSTACK_DESTROY(r->t_completion_stack);

/*:736*//*739:*/
#line 8103 "./marpa.w"
MARPA_DSTACK_DESTROY(r->t_earley_set_stack);

/*:739*//*831:*/
#line 9644 "./marpa.w"

/*830:*/
#line 9638 "./marpa.w"

r->t_current_report_item= &progress_report_not_ready;
if(r->t_progress_report_traverser){
_marpa_avl_destroy(MARPA_TREE_OF_AVL_TRAV(r->t_progress_report_traverser));
}
r->t_progress_report_traverser= NULL;
/*:830*/
#line 9645 "./marpa.w"
;
/*:831*//*864:*/
#line 10072 "./marpa.w"

ur_node_stack_destroy(URS_of_R(r));

/*:864*//*1298:*/
#line 15507 "./marpa.w"

psar_destroy(Dot_PSAR_of_R(r));
/*:1298*/
#line 6110 "./marpa.w"

/*620:*/
#line 6660 "./marpa.w"
marpa_obs_free(r->t_obs);

/*:620*/
#line 6111 "./marpa.w"

my_free(r);
}

/*:560*//*570:*/
#line 6157 "./marpa.w"

Marpa_Earleme marpa_r_current_earleme(Marpa_Recognizer r)
{
/*563:*/
#line 6125 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:563*/
#line 6160 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return-1;
}
return Current_Earleme_of_R(r);
}

/*:570*//*571:*/
#line 6172 "./marpa.w"

PRIVATE YS ys_at_current_earleme(RECCE r)
{
const YS latest= Latest_YS_of_R(r);
if(Earleme_of_YS(latest)==Current_Earleme_of_R(r))return latest;
return NULL;
}

/*:571*//*574:*/
#line 6186 "./marpa.w"

int
marpa_r_earley_item_warning_threshold(Marpa_Recognizer r)
{
return r->t_earley_item_warning_threshold;
}

/*:574*//*575:*/
#line 6195 "./marpa.w"

int
marpa_r_earley_item_warning_threshold_set(Marpa_Recognizer r,int threshold)
{
const int new_threshold= threshold<=0?YIM_FATAL_THRESHOLD:threshold;
r->t_earley_item_warning_threshold= new_threshold;
return new_threshold;
}

/*:575*//*578:*/
#line 6213 "./marpa.w"

unsigned int marpa_r_furthest_earleme(Marpa_Recognizer r)
{return(unsigned int)Furthest_Earleme_of_R(r);}

/*:578*//*585:*/
#line 6262 "./marpa.w"

int marpa_r_terminals_expected(Marpa_Recognizer r,Marpa_Symbol_ID*buffer)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 6265 "./marpa.w"

/*563:*/
#line 6125 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:563*/
#line 6266 "./marpa.w"

NSYID isy_count;
Bit_Vector bv_terminals;
int min,max,start;
int next_buffer_ix= 0;

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 6272 "./marpa.w"

/*1333:*/
#line 15798 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1333*/
#line 6273 "./marpa.w"


isy_count= ISY_Count_of_G(g);
bv_terminals= bv_create(isy_count);
for(start= 0;bv_scan(r->t_bv_nsyid_is_expected,start,&min,&max);
start= max+2)
{
NSYID nsyid;
for(nsyid= min;nsyid<=max;nsyid++)
{
const ISY isy= Source_ISY_of_NSYID(nsyid);
bv_bit_set(bv_terminals,ID_of_ISY(isy));
}
}

for(start= 0;bv_scan(bv_terminals,start,&min,&max);start= max+2)
{
ISYID isyid;
for(isyid= min;isyid<=max;isyid++)
{
buffer[next_buffer_ix++]= isyid;
}
}
bv_free(bv_terminals);
return next_buffer_ix;
}

/*:585*//*586:*/
#line 6300 "./marpa.w"

int marpa_r_terminal_is_expected(Marpa_Recognizer r,
Marpa_Symbol_ID isy_id)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 6304 "./marpa.w"

/*563:*/
#line 6125 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:563*/
#line 6305 "./marpa.w"

ISY isy;
NSY nsy;
/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 6308 "./marpa.w"

/*1333:*/
#line 15798 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1333*/
#line 6309 "./marpa.w"

/*1319:*/
#line 15705 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1319*/
#line 6310 "./marpa.w"

/*1321:*/
#line 15717 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return failure_indicator;
}

/*:1321*/
#line 6311 "./marpa.w"

isy= ISY_by_ID(isy_id);
if(_MARPA_UNLIKELY(!ISY_is_Terminal(isy))){
return 0;
}
nsy= NSY_of_ISY(isy);
if(_MARPA_UNLIKELY(!nsy))return 0;
return bv_bit_test(r->t_bv_nsyid_is_expected,ID_of_NSY(nsy));
}

/*:586*//*589:*/
#line 6334 "./marpa.w"

int
marpa_r_expected_symbol_event_set(Marpa_Recognizer r,Marpa_Symbol_ID isy_id,
int value)
{
ISY isy;
NSY nsy;
NSYID nsyid;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 6342 "./marpa.w"

/*563:*/
#line 6125 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:563*/
#line 6343 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 6344 "./marpa.w"

/*1319:*/
#line 15705 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1319*/
#line 6345 "./marpa.w"

/*1320:*/
#line 15712 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}
/*:1320*/
#line 6346 "./marpa.w"

if(_MARPA_UNLIKELY(value<0||value> 1))
{
MARPA_ERROR(MARPA_ERR_INVALID_BOOLEAN);
return failure_indicator;
}
isy= ISY_by_ID(isy_id);
if(_MARPA_UNLIKELY(ISY_is_Nulling(isy))){
MARPA_ERROR(MARPA_ERR_SYMBOL_IS_NULLING);
return-2;
}
nsy= NSY_of_ISY(isy);
if(_MARPA_UNLIKELY(!nsy)){
MARPA_ERROR(MARPA_ERR_SYMBOL_IS_UNUSED);
return-2;
}
nsyid= ID_of_NSY(nsy);
if(value){
lbv_bit_set(r->t_nsy_expected_is_event,nsyid);
}else{
lbv_bit_clear(r->t_nsy_expected_is_event,nsyid);
}
return value;
}

/*:589*//*591:*/
#line 6385 "./marpa.w"

int
marpa_r_completion_symbol_activate(Marpa_Recognizer r,
Marpa_Symbol_ID isy_id,int reactivate)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 6390 "./marpa.w"

/*563:*/
#line 6125 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:563*/
#line 6391 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 6392 "./marpa.w"

/*1319:*/
#line 15705 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1319*/
#line 6393 "./marpa.w"

/*1320:*/
#line 15712 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}
/*:1320*/
#line 6394 "./marpa.w"

switch(reactivate){
case 0:
if(lbv_bit_test(r->t_lbv_isyid_completion_event_is_active,isy_id)){
lbv_bit_clear(r->t_lbv_isyid_completion_event_is_active,isy_id);
r->t_active_event_count--;
}
return 0;
case 1:
if(!lbv_bit_test(g->t_lbv_isyid_is_completion_event,isy_id)){


MARPA_ERROR(MARPA_ERR_SYMBOL_IS_NOT_COMPLETION_EVENT);
}
if(!lbv_bit_test(r->t_lbv_isyid_completion_event_is_active,isy_id)){
lbv_bit_set(r->t_lbv_isyid_completion_event_is_active,isy_id);
r->t_active_event_count++;
}
return 1;
}
MARPA_ERROR(MARPA_ERR_INVALID_BOOLEAN);
return failure_indicator;
}

/*:591*//*593:*/
#line 6432 "./marpa.w"

int
marpa_r_nulled_symbol_activate(Marpa_Recognizer r,Marpa_Symbol_ID isy_id,
int reactivate)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 6437 "./marpa.w"

/*563:*/
#line 6125 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:563*/
#line 6438 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 6439 "./marpa.w"

/*1319:*/
#line 15705 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1319*/
#line 6440 "./marpa.w"

/*1320:*/
#line 15712 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}
/*:1320*/
#line 6441 "./marpa.w"

switch(reactivate){
case 0:
if(lbv_bit_test(r->t_lbv_isyid_nulled_event_is_active,isy_id)){
lbv_bit_clear(r->t_lbv_isyid_nulled_event_is_active,isy_id);
r->t_active_event_count--;
}
return 0;
case 1:
if(!lbv_bit_test(g->t_lbv_isyid_is_nulled_event,isy_id)){


MARPA_ERROR(MARPA_ERR_SYMBOL_IS_NOT_NULLED_EVENT);
}
if(!lbv_bit_test(r->t_lbv_isyid_nulled_event_is_active,isy_id)){
lbv_bit_set(r->t_lbv_isyid_nulled_event_is_active,isy_id);
r->t_active_event_count++;
}
return 1;
}
MARPA_ERROR(MARPA_ERR_INVALID_BOOLEAN);
return failure_indicator;
}

/*:593*//*595:*/
#line 6479 "./marpa.w"

int
marpa_r_prediction_symbol_activate(Marpa_Recognizer r,
Marpa_Symbol_ID isy_id,int reactivate)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 6484 "./marpa.w"

/*563:*/
#line 6125 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:563*/
#line 6485 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 6486 "./marpa.w"

/*1319:*/
#line 15705 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1319*/
#line 6487 "./marpa.w"

/*1320:*/
#line 15712 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}
/*:1320*/
#line 6488 "./marpa.w"

switch(reactivate){
case 0:
if(lbv_bit_test(r->t_lbv_isyid_prediction_event_is_active,isy_id)){
lbv_bit_clear(r->t_lbv_isyid_prediction_event_is_active,isy_id);
r->t_active_event_count--;
}
return 0;
case 1:
if(!lbv_bit_test(g->t_lbv_isyid_is_prediction_event,isy_id)){


MARPA_ERROR(MARPA_ERR_SYMBOL_IS_NOT_PREDICTION_EVENT);
}
if(!lbv_bit_test(r->t_lbv_isyid_prediction_event_is_active,isy_id)){
lbv_bit_set(r->t_lbv_isyid_prediction_event_is_active,isy_id);
r->t_active_event_count++;
}
return 1;
}
MARPA_ERROR(MARPA_ERR_INVALID_BOOLEAN);
return failure_indicator;
}

/*:595*//*607:*/
#line 6580 "./marpa.w"

int _marpa_r_is_use_leo(Marpa_Recognizer r)
{
/*563:*/
#line 6125 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:563*/
#line 6583 "./marpa.w"

/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 6584 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 6585 "./marpa.w"

return r->t_use_leo_flag;
}
/*:607*//*608:*/
#line 6588 "./marpa.w"

int _marpa_r_is_use_leo_set(
Marpa_Recognizer r,int value)
{
/*563:*/
#line 6125 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:563*/
#line 6592 "./marpa.w"

/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 6593 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 6594 "./marpa.w"

/*1332:*/
#line 15793 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)!=R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_STARTED);
return failure_indicator;
}
/*:1332*/
#line 6595 "./marpa.w"

return r->t_use_leo_flag= value?1:0;
}

/*:608*//*615:*/
#line 6635 "./marpa.w"

int marpa_r_is_exhausted(Marpa_Recognizer r)
{
/*563:*/
#line 6125 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:563*/
#line 6638 "./marpa.w"

/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 6639 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 6640 "./marpa.w"

return R_is_Exhausted(r);
}

/*:615*//*642:*/
#line 6794 "./marpa.w"

int marpa_r_earley_set_value(Marpa_Recognizer r,Marpa_Earley_Set_ID set_id)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 6797 "./marpa.w"

YS earley_set;
/*563:*/
#line 6125 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:563*/
#line 6799 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 6800 "./marpa.w"

/*1333:*/
#line 15798 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1333*/
#line 6801 "./marpa.w"

if(set_id<0)
{
MARPA_ERROR(MARPA_ERR_INVALID_LOCATION);
return failure_indicator;
}
r_update_earley_sets(r);
if(!YS_Ord_is_Valid(r,set_id))
{
MARPA_ERROR(MARPA_ERR_NO_EARLEY_SET_AT_LOCATION);
return failure_indicator;
}
earley_set= YS_of_R_by_Ord(r,set_id);
return Value_of_YS(earley_set);
}

/*:642*//*643:*/
#line 6817 "./marpa.w"

int
marpa_r_earley_set_values(Marpa_Recognizer r,Marpa_Earley_Set_ID set_id,
int*p_value,void**p_pvalue)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 6822 "./marpa.w"

YS earley_set;
/*563:*/
#line 6125 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:563*/
#line 6824 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 6825 "./marpa.w"

/*1333:*/
#line 15798 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1333*/
#line 6826 "./marpa.w"

if(set_id<0)
{
MARPA_ERROR(MARPA_ERR_INVALID_LOCATION);
return failure_indicator;
}
r_update_earley_sets(r);
if(!YS_Ord_is_Valid(r,set_id))
{
MARPA_ERROR(MARPA_ERR_NO_EARLEY_SET_AT_LOCATION);
return failure_indicator;
}
earley_set= YS_of_R_by_Ord(r,set_id);
if(p_value)*p_value= Value_of_YS(earley_set);
if(p_pvalue)*p_pvalue= PValue_of_YS(earley_set);
return 1;
}

/*:643*//*644:*/
#line 6844 "./marpa.w"

int marpa_r_latest_earley_set_value_set(Marpa_Recognizer r,int value)
{
YS earley_set;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 6848 "./marpa.w"

/*563:*/
#line 6125 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:563*/
#line 6849 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 6850 "./marpa.w"

/*1333:*/
#line 15798 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1333*/
#line 6851 "./marpa.w"

earley_set= Latest_YS_of_R(r);
return Value_of_YS(earley_set)= value;
}

/*:644*//*645:*/
#line 6856 "./marpa.w"

int marpa_r_latest_earley_set_values_set(Marpa_Recognizer r,int value,
void*pvalue)
{
YS earley_set;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 6861 "./marpa.w"

/*563:*/
#line 6125 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:563*/
#line 6862 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 6863 "./marpa.w"

/*1333:*/
#line 15798 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1333*/
#line 6864 "./marpa.w"

earley_set= Latest_YS_of_R(r);
Value_of_YS(earley_set)= value;
PValue_of_YS(earley_set)= pvalue;
return 1;
}

/*:645*//*646:*/
#line 6872 "./marpa.w"

PRIVATE YS
earley_set_new(RECCE r,JEARLEME id)
{
YSK_Object key;
YS set;
set= marpa_obs_new(r->t_obs,YS_Object,1);
key.t_earleme= id;
set->t_key= key;
set->t_postdot_ary= NULL;
set->t_postdot_sym_count= 0;
YIM_Count_of_YS(set)= 0;
set->t_ordinal= r->t_earley_set_count++;
YIMs_of_YS(set)= NULL;
Next_YS_of_YS(set)= NULL;
/*641:*/
#line 6790 "./marpa.w"

Value_of_YS(set)= -1;
PValue_of_YS(set)= NULL;

/*:641*//*1304:*/
#line 15563 "./marpa.w"

{set->t_dot_psl= NULL;}

/*:1304*/
#line 6887 "./marpa.w"

return set;
}

/*:646*//*656:*/
#line 6997 "./marpa.w"

PRIVATE YIM earley_item_create(const RECCE r,
const YIK_Object key)
{
/*1315:*/
#line 15686 "./marpa.w"
void*const failure_indicator= NULL;
/*:1315*/
#line 7001 "./marpa.w"

/*563:*/
#line 6125 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:563*/
#line 7002 "./marpa.w"

YIM new_item;
YIM*end_of_work_stack;
const YS set= key.t_set;
const int count= ++YIM_Count_of_YS(set);
/*658:*/
#line 7056 "./marpa.w"

if(_MARPA_UNLIKELY(count>=YIM_FATAL_THRESHOLD))
{
MARPA_FATAL(MARPA_ERR_YIM_COUNT);
return failure_indicator;
}

/*:658*/
#line 7007 "./marpa.w"

new_item= marpa_obs_new(r->t_obs,struct s_earley_item,1);
new_item->t_key= key;
new_item->t_source_type= NO_SOURCE;
YIM_is_Rejected(new_item)= 0;
YIM_is_Active(new_item)= 1;
{
SRC unique_yim_src= SRC_of_YIM(new_item);
SRC_is_Rejected(unique_yim_src)= 0;
SRC_is_Active(unique_yim_src)= 1;
}
Ord_of_YIM(new_item)= YIM_ORDINAL_CLAMP((unsigned int)count-1);
end_of_work_stack= WORK_YIM_PUSH(r);
*end_of_work_stack= new_item;
return new_item;
}

/*:656*//*657:*/
#line 7024 "./marpa.w"

PRIVATE YIM
earley_item_assign(const RECCE r,const YS set,const YS origin,
const AHM ahm)
{
const GRAMMAR g= G_of_R(r);
YIK_Object key;
YIM yim;
PSL psl;
AHMID ahm_id= ID_of_AHM(ahm);
PSL*psl_owner= &Dot_PSL_of_YS(origin);
if(!*psl_owner)
{
psl_claim(psl_owner,Dot_PSAR_of_R(r));
}
psl= *psl_owner;
yim= PSL_Datum(psl,ahm_id);
if(yim
&&Earleme_of_YIM(yim)==Earleme_of_YS(set)
&&Earleme_of_YS(Origin_of_YIM(yim))==Earleme_of_YS(origin))
{
return yim;
}
key.t_origin= origin;
key.t_ahm= ahm;
key.t_set= set;
yim= earley_item_create(r,key);
PSL_Datum(psl,ahm_id)= yim;
return yim;
}

/*:657*//*662:*/
#line 7092 "./marpa.w"

PRIVATE_NOT_INLINE Marpa_Error_Code invalid_source_type_code(unsigned int type)
{
switch(type){
case NO_SOURCE:
return MARPA_ERR_SOURCE_TYPE_IS_NONE;
case SOURCE_IS_TOKEN:
return MARPA_ERR_SOURCE_TYPE_IS_TOKEN;
case SOURCE_IS_COMPLETION:
return MARPA_ERR_SOURCE_TYPE_IS_COMPLETION;
case SOURCE_IS_LEO:
return MARPA_ERR_SOURCE_TYPE_IS_LEO;
case SOURCE_IS_AMBIGUOUS:
return MARPA_ERR_SOURCE_TYPE_IS_AMBIGUOUS;
}
return MARPA_ERR_SOURCE_TYPE_IS_UNKNOWN;
}

/*:662*//*674:*/
#line 7213 "./marpa.w"

PRIVATE PIM*
pim_nsy_p_find(YS set,NSYID nsyid)
{
int lo= 0;
int hi= Postdot_SYM_Count_of_YS(set)-1;
PIM*postdot_array= set->t_postdot_ary;
while(hi>=lo){
int trial= lo+(hi-lo)/2;
PIM trial_pim= postdot_array[trial];
NSYID trial_nsyid= Postdot_NSYID_of_PIM(trial_pim);
if(trial_nsyid==nsyid)return postdot_array+trial;
if(trial_nsyid<nsyid){
lo= trial+1;
}else{
hi= trial-1;
}
}
return NULL;
}
/*:674*//*675:*/
#line 7233 "./marpa.w"

PRIVATE PIM first_pim_of_ys_by_nsyid(YS set,NSYID nsyid)
{
PIM*pim_nsy_p= pim_nsy_p_find(set,nsyid);
return pim_nsy_p?*pim_nsy_p:NULL;
}

/*:675*//*693:*/
#line 7390 "./marpa.w"

PRIVATE
SRCL unique_srcl_new(struct marpa_obstack*t_obs)
{
const SRCL new_srcl= marpa_obs_new(t_obs,SRCL_Object,1);
SRCL_is_Rejected(new_srcl)= 0;
SRCL_is_Active(new_srcl)= 1;
return new_srcl;
}

/*:693*//*694:*/
#line 7400 "./marpa.w"
PRIVATE
void
tkn_link_add(RECCE r,
YIM item,
YIM predecessor,
ALT alternative)
{
SRCL new_link;
unsigned int previous_source_type= Source_Type_of_YIM(item);
if(previous_source_type==NO_SOURCE)
{
const SRCL source_link= SRCL_of_YIM(item);
Source_Type_of_YIM(item)= SOURCE_IS_TOKEN;
Predecessor_of_SRCL(source_link)= predecessor;
NSYID_of_SRCL(source_link)= NSYID_of_ALT(alternative);
Value_of_SRCL(source_link)= Value_of_ALT(alternative);
Next_SRCL_of_SRCL(source_link)= NULL;
return;
}
if(previous_source_type!=SOURCE_IS_AMBIGUOUS)
{
earley_item_ambiguate(r,item);
}
new_link= unique_srcl_new(r->t_obs);
new_link->t_next= LV_First_Token_SRCL_of_YIM(item);
new_link->t_source.t_predecessor= predecessor;
NSYID_of_Source(new_link->t_source)= NSYID_of_ALT(alternative);
Value_of_Source(new_link->t_source)= Value_of_ALT(alternative);
LV_First_Token_SRCL_of_YIM(item)= new_link;
}

/*:694*//*695:*/
#line 7431 "./marpa.w"

PRIVATE
void
completion_link_add(RECCE r,
YIM item,
YIM predecessor,
YIM cause)
{
SRCL new_link;
unsigned int previous_source_type= Source_Type_of_YIM(item);
if(previous_source_type==NO_SOURCE)
{
const SRCL source_link= SRCL_of_YIM(item);
Source_Type_of_YIM(item)= SOURCE_IS_COMPLETION;
Predecessor_of_SRCL(source_link)= predecessor;
Cause_of_SRCL(source_link)= cause;
Next_SRCL_of_SRCL(source_link)= NULL;
return;
}
if(previous_source_type!=SOURCE_IS_AMBIGUOUS)
{
earley_item_ambiguate(r,item);
}
new_link= unique_srcl_new(r->t_obs);
new_link->t_next= LV_First_Completion_SRCL_of_YIM(item);
new_link->t_source.t_predecessor= predecessor;
Cause_of_Source(new_link->t_source)= cause;
LV_First_Completion_SRCL_of_YIM(item)= new_link;
}

/*:695*//*696:*/
#line 7461 "./marpa.w"

PRIVATE void
leo_link_add(RECCE r,
YIM item,
LIM predecessor,
YIM cause)
{
SRCL new_link;
unsigned int previous_source_type= Source_Type_of_YIM(item);
if(previous_source_type==NO_SOURCE)
{
const SRCL source_link= SRCL_of_YIM(item);
Source_Type_of_YIM(item)= SOURCE_IS_LEO;
Predecessor_of_SRCL(source_link)= predecessor;
Cause_of_SRCL(source_link)= cause;
Next_SRCL_of_SRCL(source_link)= NULL;
return;
}
if(previous_source_type!=SOURCE_IS_AMBIGUOUS)
{
earley_item_ambiguate(r,item);
}
new_link= unique_srcl_new(r->t_obs);
new_link->t_next= LV_First_Leo_SRCL_of_YIM(item);
new_link->t_source.t_predecessor= predecessor;
Cause_of_Source(new_link->t_source)= cause;
LV_First_Leo_SRCL_of_YIM(item)= new_link;
}

/*:696*//*698:*/
#line 7510 "./marpa.w"

PRIVATE_NOT_INLINE
void earley_item_ambiguate(struct marpa_r*r,YIM item)
{
unsigned int previous_source_type= Source_Type_of_YIM(item);
Source_Type_of_YIM(item)= SOURCE_IS_AMBIGUOUS;
switch(previous_source_type)
{
case SOURCE_IS_TOKEN:/*699:*/
#line 7527 "./marpa.w"
{
SRCL new_link= marpa_obs_new(r->t_obs,SRCL_Object,1);
*new_link= *SRCL_of_YIM(item);
LV_First_Leo_SRCL_of_YIM(item)= NULL;
LV_First_Completion_SRCL_of_YIM(item)= NULL;
LV_First_Token_SRCL_of_YIM(item)= new_link;
}

/*:699*/
#line 7518 "./marpa.w"

return;
case SOURCE_IS_COMPLETION:/*700:*/
#line 7535 "./marpa.w"
{
SRCL new_link= marpa_obs_new(r->t_obs,SRCL_Object,1);
*new_link= *SRCL_of_YIM(item);
LV_First_Leo_SRCL_of_YIM(item)= NULL;
LV_First_Completion_SRCL_of_YIM(item)= new_link;
LV_First_Token_SRCL_of_YIM(item)= NULL;
}

/*:700*/
#line 7520 "./marpa.w"

return;
case SOURCE_IS_LEO:/*701:*/
#line 7543 "./marpa.w"
{
SRCL new_link= marpa_obs_new(r->t_obs,SRCL_Object,1);
*new_link= *SRCL_of_YIM(item);
LV_First_Leo_SRCL_of_YIM(item)= new_link;
LV_First_Completion_SRCL_of_YIM(item)= NULL;
LV_First_Token_SRCL_of_YIM(item)= NULL;
}

/*:701*/
#line 7522 "./marpa.w"

return;
}
}

/*:698*//*708:*/
#line 7586 "./marpa.w"

PRIVATE int
alternative_insertion_point(RECCE r,ALT new_alternative)
{
MARPA_DSTACK alternatives= &r->t_alternatives;
ALT alternative;
int hi= MARPA_DSTACK_LENGTH(*alternatives)-1;
int lo= 0;
int trial;

if(hi<0)
return 0;
alternative= MARPA_DSTACK_BASE(*alternatives,ALT_Object);
for(;;)
{
int outcome;
trial= lo+(hi-lo)/2;
outcome= alternative_cmp(new_alternative,alternative+trial);
if(outcome==0)
return-1;
if(outcome> 0)
{
lo= trial+1;
}
else
{
hi= trial-1;
}
if(hi<lo)
return outcome> 0?trial+1:trial;
}
}

/*:708*//*710:*/
#line 7630 "./marpa.w"

PRIVATE int alternative_cmp(const ALT_Const a,const ALT_Const b)
{
int subkey= End_Earleme_of_ALT(b)-End_Earleme_of_ALT(a);
if(subkey)return subkey;
subkey= NSYID_of_ALT(a)-NSYID_of_ALT(b);
if(subkey)return subkey;
return Start_Earleme_of_ALT(a)-Start_Earleme_of_ALT(b);
}

/*:710*//*711:*/
#line 7647 "./marpa.w"

PRIVATE ALT alternative_pop(RECCE r,JEARLEME earleme)
{
MARPA_DSTACK alternatives= &r->t_alternatives;
ALT end_of_stack= MARPA_DSTACK_TOP(*alternatives,ALT_Object);

if(!end_of_stack)return NULL;






if(earleme<End_Earleme_of_ALT(end_of_stack))
return NULL;

return MARPA_DSTACK_POP(*alternatives,ALT_Object);
}

/*:711*//*713:*/
#line 7674 "./marpa.w"

PRIVATE int alternative_insert(RECCE r,ALT new_alternative)
{
ALT end_of_stack,base_of_stack;
MARPA_DSTACK alternatives= &r->t_alternatives;
int ix;
int insertion_point= alternative_insertion_point(r,new_alternative);
if(insertion_point<0)
return insertion_point;


end_of_stack= MARPA_DSTACK_PUSH(*alternatives,ALT_Object);


base_of_stack= MARPA_DSTACK_BASE(*alternatives,ALT_Object);
for(ix= (int)(end_of_stack-base_of_stack);ix> insertion_point;ix--){
base_of_stack[ix]= base_of_stack[ix-1];
}
base_of_stack[insertion_point]= *new_alternative;
return insertion_point;
}

/*:713*//*714:*/
#line 7697 "./marpa.w"
int marpa_r_start_input(Marpa_Recognizer r)
{
int return_value= 1;
YS set0;
YIK_Object key;

NRL start_nrl;
AHM start_ahm;

/*563:*/
#line 6125 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:563*/
#line 7706 "./marpa.w"

/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 7707 "./marpa.w"


/*1332:*/
#line 15793 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)!=R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_STARTED);
return failure_indicator;
}
/*:1332*/
#line 7709 "./marpa.w"

{
/*716:*/
#line 7827 "./marpa.w"

const NSYID nsy_count= NSY_Count_of_G(g);
const NSYID isy_count= ISY_Count_of_G(g);
Bit_Vector bv_ok_for_chain= bv_create(nsy_count);
/*:716*/
#line 7711 "./marpa.w"

Current_Earleme_of_R(r)= 0;
/*722:*/
#line 7869 "./marpa.w"

{
ISYID isy_id;
r->t_valued_terminal= lbv_obs_new0(r->t_obs,isy_count);
r->t_unvalued_terminal= lbv_obs_new0(r->t_obs,isy_count);
r->t_valued= lbv_obs_new0(r->t_obs,isy_count);
r->t_unvalued= lbv_obs_new0(r->t_obs,isy_count);
r->t_valued_locked= lbv_obs_new0(r->t_obs,isy_count);
for(isy_id= 0;isy_id<isy_count;isy_id++)
{
const ISY isy= ISY_by_ID(isy_id);
if(ISY_is_Valued_Locked(isy))
{
lbv_bit_set(r->t_valued_locked,isy_id);
}
if(ISY_is_Valued(isy))
{
lbv_bit_set(r->t_valued,isy_id);
if(ISY_is_Terminal(isy))
{
lbv_bit_set(r->t_valued_terminal,isy_id);
}
}
else
{
lbv_bit_set(r->t_unvalued,isy_id);
if(ISY_is_Terminal(isy))
{
lbv_bit_set(r->t_unvalued_terminal,isy_id);
}
}
}
}

/*:722*/
#line 7713 "./marpa.w"

G_EVENTS_CLEAR(g);

set0= earley_set_new(r,0);
Latest_YS_of_R(r)= set0;
First_YS_of_R(r)= set0;

if(G_is_Trivial(g)){
return_value+= trigger_trivial_events(r);
/*614:*/
#line 6625 "./marpa.w"

{
R_is_Exhausted(r)= 1;
Input_Phase_of_R(r)= R_AFTER_INPUT;
event_new(g,MARPA_EVENT_EXHAUSTED);
}

/*:614*/
#line 7722 "./marpa.w"

goto CLEANUP;
}
Input_Phase_of_R(r)= R_DURING_INPUT;
psar_reset(Dot_PSAR_of_R(r));
/*775:*/
#line 8735 "./marpa.w"

r->t_bv_lim_symbols= bv_obs_create(r->t_obs,nsy_count);
r->t_bv_pim_symbols= bv_obs_create(r->t_obs,nsy_count);
r->t_pim_workarea= marpa_obs_new(r->t_obs,void*,nsy_count);
/*:775*//*794:*/
#line 9017 "./marpa.w"

r->t_lim_chain= marpa_obs_new(r->t_obs,void*,2*nsy_count);
/*:794*/
#line 7727 "./marpa.w"

/*731:*/
#line 8077 "./marpa.w"

{
if(!MARPA_DSTACK_IS_INITIALIZED(r->t_yim_work_stack))
{
MARPA_DSTACK_INIT2(r->t_yim_work_stack,YIM);
}
}
/*:731*//*735:*/
#line 8092 "./marpa.w"

{
if(!MARPA_DSTACK_IS_INITIALIZED(r->t_completion_stack))
{
MARPA_DSTACK_INIT2(r->t_completion_stack,YIM);
}
}
/*:735*/
#line 7728 "./marpa.w"


start_nrl= g->t_start_nrl;
start_ahm= First_AHM_of_NRL(start_nrl);



key.t_origin= set0;
key.t_set= set0;

key.t_ahm= start_ahm;
earley_item_create(r,key);

bv_clear(r->t_bv_nrl_seen);
bv_bit_set(r->t_bv_nrl_seen,ID_of_NRL(start_nrl));
MARPA_DSTACK_CLEAR(r->t_nrl_cil_stack);
*MARPA_DSTACK_PUSH(r->t_nrl_cil_stack,CIL)= LHS_CIL_of_AHM(start_ahm);

while(1)
{
const CIL*const p_cil= MARPA_DSTACK_POP(r->t_nrl_cil_stack,CIL);
if(!p_cil)
break;
{
int cil_ix;
const CIL this_cil= *p_cil;
const int prediction_count= Count_of_CIL(this_cil);
for(cil_ix= 0;cil_ix<prediction_count;cil_ix++)
{
const NRLID prediction_nrlid= Item_of_CIL(this_cil,cil_ix);
if(!bv_bit_test_then_set(r->t_bv_nrl_seen,prediction_nrlid))
{
const NRL prediction_nrl= NRL_by_ID(prediction_nrlid);
const AHM prediction_ahm= First_AHM_of_NRL(prediction_nrl);



if(!evaluate_zwas(r,0,prediction_ahm))continue;
key.t_ahm= prediction_ahm;
earley_item_create(r,key);
*MARPA_DSTACK_PUSH(r->t_nrl_cil_stack,CIL)
= LHS_CIL_of_AHM(prediction_ahm);
}
}
}
}

postdot_items_create(r,bv_ok_for_chain,set0);
earley_set_update_items(r,set0);
r->t_is_using_leo= r->t_use_leo_flag;
trigger_events(r);
CLEANUP:;
/*717:*/
#line 7831 "./marpa.w"

bv_free(bv_ok_for_chain);

/*:717*/
#line 7780 "./marpa.w"

}
return return_value;
}

/*:714*//*715:*/
#line 7785 "./marpa.w"

PRIVATE
int evaluate_zwas(RECCE r,YSID ysid,AHM ahm)
{
int cil_ix;
const CIL zwa_cil= ZWA_CIL_of_AHM(ahm);
const int cil_count= Count_of_CIL(zwa_cil);
for(cil_ix= 0;cil_ix<cil_count;cil_ix++)
{
int value;
const ZWAID zwaid= Item_of_CIL(zwa_cil,cil_ix);
const ZWA zwa= RZWA_by_ID(zwaid);


MARPA_OFF_DEBUG3("At %s, evaluating assertion %ld",STRLOC,(long)zwaid);
if(Memo_YSID_of_ZWA(zwa)==ysid){
if(Memo_Value_of_ZWA(zwa))continue;
MARPA_OFF_DEBUG3("At %s: returning 0 for assertion %ld",STRLOC,(long)zwaid);
return 0;
}




value= Memo_Value_of_ZWA(zwa)= Default_Value_of_ZWA(zwa);
Memo_YSID_of_ZWA(zwa)= ysid;





if(!value){
MARPA_OFF_DEBUG3("At %s: returning 0 for assertion %ld",STRLOC,(long)zwaid);
return 0;
}

MARPA_OFF_DEBUG3("At %s: value is 1 for assertion %ld",STRLOC,(long)zwaid);
}
return 1;
}


/*:715*//*723:*/
#line 7909 "./marpa.w"

Marpa_Earleme marpa_r_alternative(
Marpa_Recognizer r,
Marpa_Symbol_ID tkn_isy_id,
int value,
int length)
{
/*563:*/
#line 6125 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:563*/
#line 7916 "./marpa.w"

YS current_earley_set;
const JEARLEME current_earleme= Current_Earleme_of_R(r);
JEARLEME target_earleme;
NSYID tkn_nsyid;
if(_MARPA_UNLIKELY(!R_is_Consistent(r)))
{
MARPA_ERROR(MARPA_ERR_RECCE_IS_INCONSISTENT);
return MARPA_ERR_RECCE_IS_INCONSISTENT;
}
if(_MARPA_UNLIKELY(Input_Phase_of_R(r)!=R_DURING_INPUT))
{
MARPA_ERROR(MARPA_ERR_RECCE_NOT_ACCEPTING_INPUT);
return MARPA_ERR_RECCE_NOT_ACCEPTING_INPUT;
}
if(_MARPA_UNLIKELY(ISYID_is_Malformed(tkn_isy_id)))
{
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return MARPA_ERR_INVALID_SYMBOL_ID;
}
if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(tkn_isy_id)))
{
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return MARPA_ERR_NO_SUCH_SYMBOL_ID;
}
/*724:*/
#line 7948 "./marpa.w"
{
const ISY_Const tkn= ISY_by_ID(tkn_isy_id);
if(length<=0){
MARPA_ERROR(MARPA_ERR_TOKEN_LENGTH_LE_ZERO);
return MARPA_ERR_TOKEN_LENGTH_LE_ZERO;
}
if(length>=JEARLEME_THRESHOLD){
MARPA_ERROR(MARPA_ERR_TOKEN_TOO_LONG);
return MARPA_ERR_TOKEN_TOO_LONG;
}
if(value&&_MARPA_UNLIKELY(!lbv_bit_test(r->t_valued_terminal,tkn_isy_id)))
{
if(!ISY_is_Terminal(tkn)){
MARPA_ERROR(MARPA_ERR_TOKEN_IS_NOT_TERMINAL);
return MARPA_ERR_TOKEN_IS_NOT_TERMINAL;
}
if(lbv_bit_test(r->t_valued_locked,tkn_isy_id)){
MARPA_ERROR(MARPA_ERR_SYMBOL_VALUED_CONFLICT);
return MARPA_ERR_SYMBOL_VALUED_CONFLICT;
}
lbv_bit_set(r->t_valued_locked,tkn_isy_id);
lbv_bit_set(r->t_valued_terminal,tkn_isy_id);
lbv_bit_set(r->t_valued,tkn_isy_id);
}
if(!value&&_MARPA_UNLIKELY(!lbv_bit_test(r->t_unvalued_terminal,tkn_isy_id)))
{
if(!ISY_is_Terminal(tkn)){
MARPA_ERROR(MARPA_ERR_TOKEN_IS_NOT_TERMINAL);
return MARPA_ERR_TOKEN_IS_NOT_TERMINAL;
}
if(lbv_bit_test(r->t_valued_locked,tkn_isy_id)){
MARPA_ERROR(MARPA_ERR_SYMBOL_VALUED_CONFLICT);
return MARPA_ERR_SYMBOL_VALUED_CONFLICT;
}
lbv_bit_set(r->t_valued_locked,tkn_isy_id);
lbv_bit_set(r->t_unvalued_terminal,tkn_isy_id);
lbv_bit_set(r->t_unvalued,tkn_isy_id);
}
}

/*:724*/
#line 7941 "./marpa.w"

/*727:*/
#line 8008 "./marpa.w"

{
NSY tkn_nsy= NSY_by_ISYID(tkn_isy_id);
if(_MARPA_UNLIKELY(!tkn_nsy))
{
MARPA_ERROR(MARPA_ERR_INACCESSIBLE_TOKEN);
return MARPA_ERR_INACCESSIBLE_TOKEN;
}
tkn_nsyid= ID_of_NSY(tkn_nsy);
current_earley_set= YS_at_Current_Earleme_of_R(r);
if(!current_earley_set)
{
MARPA_ERROR(MARPA_ERR_NO_TOKEN_EXPECTED_HERE);
return MARPA_ERR_NO_TOKEN_EXPECTED_HERE;
}
if(!First_PIM_of_YS_by_NSYID(current_earley_set,tkn_nsyid))
{
MARPA_ERROR(MARPA_ERR_UNEXPECTED_TOKEN_ID);
return MARPA_ERR_UNEXPECTED_TOKEN_ID;
}
}

/*:727*/
#line 7942 "./marpa.w"

/*725:*/
#line 7988 "./marpa.w"
{
target_earleme= current_earleme+length;
if(target_earleme>=JEARLEME_THRESHOLD){
MARPA_ERROR(MARPA_ERR_PARSE_TOO_LONG);
return MARPA_ERR_PARSE_TOO_LONG;
}
}

/*:725*/
#line 7943 "./marpa.w"

/*728:*/
#line 8046 "./marpa.w"

{
ALT_Object alternative_object;


const ALT alternative= &alternative_object;
NSYID_of_ALT(alternative)= tkn_nsyid;
Value_of_ALT(alternative)= value;
ALT_is_Valued(alternative)= value?1:0;
if(Furthest_Earleme_of_R(r)<target_earleme)
Furthest_Earleme_of_R(r)= target_earleme;
alternative->t_start_earley_set= current_earley_set;
End_Earleme_of_ALT(alternative)= target_earleme;
if(alternative_insert(r,alternative)<0)
{
MARPA_ERROR(MARPA_ERR_DUPLICATE_TOKEN);
return MARPA_ERR_DUPLICATE_TOKEN;
}
}

/*:728*/
#line 7944 "./marpa.w"

return MARPA_ERR_NONE;
}

/*:723*//*741:*/
#line 8123 "./marpa.w"

int
marpa_r_earleme_complete(Marpa_Recognizer r)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 8127 "./marpa.w"

/*563:*/
#line 6125 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:563*/
#line 8128 "./marpa.w"

YIM*cause_p;
YS current_earley_set;
JEARLEME current_earleme;





JEARLEME return_value= -2;

/*1334:*/
#line 15803 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)!=R_DURING_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_ACCEPTING_INPUT);
return failure_indicator;
}

if(_MARPA_UNLIKELY(!R_is_Consistent(r))){
MARPA_ERROR(MARPA_ERR_RECCE_IS_INCONSISTENT);
return failure_indicator;
}

/*:1334*/
#line 8139 "./marpa.w"

if(_MARPA_UNLIKELY(!R_is_Consistent(r))){
MARPA_ERROR(MARPA_ERR_RECCE_IS_INCONSISTENT);
return failure_indicator;
}

{
int count_of_expected_terminals;
/*742:*/
#line 8189 "./marpa.w"

const NSYID nsy_count= NSY_Count_of_G(g);
Bit_Vector bv_ok_for_chain= bv_create(nsy_count);
struct marpa_obstack*const earleme_complete_obs= marpa_obs_init;
/*:742*/
#line 8147 "./marpa.w"

G_EVENTS_CLEAR(g);
psar_dealloc(Dot_PSAR_of_R(r));
bv_clear(r->t_bv_nsyid_is_expected);
bv_clear(r->t_bv_nrl_seen);
/*744:*/
#line 8197 "./marpa.w"
{
current_earleme= ++(Current_Earleme_of_R(r));
if(current_earleme> Furthest_Earleme_of_R(r))
{
/*614:*/
#line 6625 "./marpa.w"

{
R_is_Exhausted(r)= 1;
Input_Phase_of_R(r)= R_AFTER_INPUT;
event_new(g,MARPA_EVENT_EXHAUSTED);
}

/*:614*/
#line 8201 "./marpa.w"

MARPA_ERROR(MARPA_ERR_PARSE_EXHAUSTED);
return_value= failure_indicator;
goto CLEANUP;
}
}

/*:744*/
#line 8152 "./marpa.w"

/*746:*/
#line 8220 "./marpa.w"
{
ALT end_of_stack= MARPA_DSTACK_TOP(r->t_alternatives,ALT_Object);
if(!end_of_stack||current_earleme!=End_Earleme_of_ALT(end_of_stack))
{
return_value= 0;
goto CLEANUP;
}
}

/*:746*/
#line 8153 "./marpa.w"

/*745:*/
#line 8210 "./marpa.w"
{
current_earley_set= earley_set_new(r,current_earleme);
Next_YS_of_YS(Latest_YS_of_R(r))= current_earley_set;
Latest_YS_of_R(r)= current_earley_set;
}

/*:745*/
#line 8154 "./marpa.w"

/*747:*/
#line 8229 "./marpa.w"

{
ALT alternative;


while((alternative= alternative_pop(r,current_earleme)))
/*749:*/
#line 8248 "./marpa.w"

{
YS start_earley_set= Start_YS_of_ALT(alternative);
PIM pim= First_PIM_of_YS_by_NSYID(start_earley_set,
NSYID_of_ALT(alternative));
for(;pim;pim= Next_PIM_of_PIM(pim))
{


const YIM predecessor= YIM_of_PIM(pim);
if(predecessor&&YIM_is_Active(predecessor))
{
const AHM predecessor_ahm= AHM_of_YIM(predecessor);
const AHM scanned_ahm= Next_AHM_of_AHM(predecessor_ahm);
/*750:*/
#line 8267 "./marpa.w"

{
const YIM scanned_earley_item= earley_item_assign(r,
current_earley_set,
Origin_of_YIM
(predecessor),
scanned_ahm);
YIM_was_Scanned(scanned_earley_item)= 1;
tkn_link_add(r,scanned_earley_item,predecessor,alternative);
}

/*:750*/
#line 8262 "./marpa.w"

}
}
}

/*:749*/
#line 8235 "./marpa.w"

}

/*:747*/
#line 8155 "./marpa.w"

/*751:*/
#line 8283 "./marpa.w"
{


YIM*work_earley_items= MARPA_DSTACK_BASE(r->t_yim_work_stack,YIM);
int no_of_work_earley_items= MARPA_DSTACK_LENGTH(r->t_yim_work_stack);
int ix;
MARPA_DSTACK_CLEAR(r->t_completion_stack);
for(ix= 0;
ix<no_of_work_earley_items;
ix++){
YIM earley_item= work_earley_items[ix];
YIM*end_of_stack;
if(!YIM_is_Completion(earley_item))
continue;
end_of_stack= MARPA_DSTACK_PUSH(r->t_completion_stack,YIM);
*end_of_stack= earley_item;
}
}

/*:751*/
#line 8156 "./marpa.w"

while((cause_p= MARPA_DSTACK_POP(r->t_completion_stack,YIM))){
YIM cause= *cause_p;
/*752:*/
#line 8304 "./marpa.w"

{
if(YIM_is_Active(cause)&&YIM_is_Completion(cause))
{
NSYID complete_nsyid= LHS_NSYID_of_YIM(cause);
const YS middle= Origin_of_YIM(cause);
/*753:*/
#line 8314 "./marpa.w"

{
PIM postdot_item;
for(postdot_item= First_PIM_of_YS_by_NSYID(middle,complete_nsyid);
postdot_item;postdot_item= Next_PIM_of_PIM(postdot_item))
{
const YIM predecessor= YIM_of_PIM(postdot_item);
if(!predecessor){


const LIM leo_item= LIM_of_PIM(postdot_item);








if(!LIM_is_Active(leo_item))goto NEXT_PIM;

/*756:*/
#line 8381 "./marpa.w"
{
const YS origin= Origin_of_LIM(leo_item);
const AHM effect_ahm= Top_AHM_of_LIM(leo_item);
const YIM effect= earley_item_assign(r,current_earley_set,
origin,effect_ahm);
YIM_was_Fusion(effect)= 1;
if(Earley_Item_has_No_Source(effect))
{


/*755:*/
#line 8375 "./marpa.w"
{
YIM*end_of_stack= MARPA_DSTACK_PUSH(r->t_completion_stack,YIM);
*end_of_stack= effect;
}

/*:755*/
#line 8391 "./marpa.w"

}
leo_link_add(r,effect,leo_item,cause);
}

/*:756*/
#line 8335 "./marpa.w"





goto LAST_PIM;
}else{


if(!YIM_is_Active(predecessor))continue;



/*754:*/
#line 8355 "./marpa.w"

{
const AHM predecessor_ahm= AHM_of_YIM(predecessor);
const AHM effect_ahm= Next_AHM_of_AHM(predecessor_ahm);
const YS origin= Origin_of_YIM(predecessor);
const YIM effect= earley_item_assign(r,current_earley_set,
origin,effect_ahm);
YIM_was_Fusion(effect)= 1;
if(Earley_Item_has_No_Source(effect)){


if(YIM_is_Completion(effect)){
/*755:*/
#line 8375 "./marpa.w"
{
YIM*end_of_stack= MARPA_DSTACK_PUSH(r->t_completion_stack,YIM);
*end_of_stack= effect;
}

/*:755*/
#line 8367 "./marpa.w"

}
}
completion_link_add(r,effect,predecessor,cause);
}

/*:754*/
#line 8348 "./marpa.w"

}
NEXT_PIM:;
}
LAST_PIM:;
}

/*:753*/
#line 8310 "./marpa.w"

}
}

/*:752*/
#line 8159 "./marpa.w"

}
/*757:*/
#line 8396 "./marpa.w"

{
int ix;
const int no_of_work_earley_items= 
MARPA_DSTACK_LENGTH(r->t_yim_work_stack);
for(ix= 0;ix<no_of_work_earley_items;ix++)
{
YIM earley_item= WORK_YIM_ITEM(r,ix);

int cil_ix;
const AHM ahm= AHM_of_YIM(earley_item);
const CIL prediction_cil= Predicted_NRL_CIL_of_AHM(ahm);
const int prediction_count= Count_of_CIL(prediction_cil);
for(cil_ix= 0;cil_ix<prediction_count;cil_ix++)
{
const NRLID prediction_nrlid= Item_of_CIL(prediction_cil,cil_ix);
const NRL prediction_nrl= NRL_by_ID(prediction_nrlid);
const AHM prediction_ahm= First_AHM_of_NRL(prediction_nrl);
earley_item_assign(r,current_earley_set,current_earley_set,
prediction_ahm);
}

}
}

/*:757*/
#line 8161 "./marpa.w"

postdot_items_create(r,bv_ok_for_chain,current_earley_set);





count_of_expected_terminals= bv_count(r->t_bv_nsyid_is_expected);
if(count_of_expected_terminals<=0
&&MARPA_DSTACK_LENGTH(r->t_alternatives)<=0)
{
/*614:*/
#line 6625 "./marpa.w"

{
R_is_Exhausted(r)= 1;
Input_Phase_of_R(r)= R_AFTER_INPUT;
event_new(g,MARPA_EVENT_EXHAUSTED);
}

/*:614*/
#line 8172 "./marpa.w"

}
earley_set_update_items(r,current_earley_set);
/*659:*/
#line 7064 "./marpa.w"

{
const int yim_count= YIM_Count_of_YS(current_earley_set);
if(yim_count>=r->t_earley_item_warning_threshold)
{
int_event_new(g,MARPA_EVENT_EARLEY_ITEM_THRESHOLD,yim_count);
}
}

/*:659*/
#line 8175 "./marpa.w"

if(r->t_active_event_count> 0){
trigger_events(r);
}
return_value= G_EVENT_COUNT(g);
CLEANUP:;
/*743:*/
#line 8193 "./marpa.w"

bv_free(bv_ok_for_chain);
marpa_obs_free(earleme_complete_obs);

/*:743*/
#line 8181 "./marpa.w"

}
return return_value;
}

/*:741*//*758:*/
#line 8421 "./marpa.w"

PRIVATE void trigger_events(RECCE r)
{
const GRAMMAR g= G_of_R(r);
const YS current_earley_set= Latest_YS_of_R(r);
int min,max,start;
int yim_ix;
struct marpa_obstack*const trigger_events_obs= marpa_obs_init;
const YIM*yims= YIMs_of_YS(current_earley_set);
const ISYID isy_count= ISY_Count_of_G(g);
const int ahm_count= AHM_Count_of_G(g);
Bit_Vector bv_completion_event_trigger= 
bv_obs_create(trigger_events_obs,isy_count);
Bit_Vector bv_nulled_event_trigger= 
bv_obs_create(trigger_events_obs,isy_count);
Bit_Vector bv_prediction_event_trigger= 
bv_obs_create(trigger_events_obs,isy_count);
Bit_Vector bv_ahm_event_trigger= 
bv_obs_create(trigger_events_obs,ahm_count);
const int working_earley_item_count= YIM_Count_of_YS(current_earley_set);
for(yim_ix= 0;yim_ix<working_earley_item_count;yim_ix++)
{
const YIM yim= yims[yim_ix];
const AHM root_ahm= AHM_of_YIM(yim);
if(AHM_has_Event(root_ahm))
{

bv_bit_set(bv_ahm_event_trigger,ID_of_AHM(root_ahm));
}
{

const SRCL first_leo_source_link= First_Leo_SRCL_of_YIM(yim);
SRCL setup_source_link;
for(setup_source_link= first_leo_source_link;setup_source_link;
setup_source_link= Next_SRCL_of_SRCL(setup_source_link))
{
int cil_ix;
const LIM lim= LIM_of_SRCL(setup_source_link);
const CIL event_ahmids= CIL_of_LIM(lim);
const int event_ahm_count= Count_of_CIL(event_ahmids);
for(cil_ix= 0;cil_ix<event_ahm_count;cil_ix++)
{
const NSYID leo_path_ahmid= 
Item_of_CIL(event_ahmids,cil_ix);
bv_bit_set(bv_ahm_event_trigger,leo_path_ahmid);


}
}
}
}

for(start= 0;bv_scan(bv_ahm_event_trigger,start,&min,&max);
start= max+2)
{
ISYID event_ahmid;
for(event_ahmid= (NSYID)min;event_ahmid<=(NSYID)max;
event_ahmid++)
{
int cil_ix;
const AHM event_ahm= AHM_by_ID(event_ahmid);
{
const CIL completion_isyids= 
Completion_ISYIDs_of_AHM(event_ahm);
const int event_isy_count= Count_of_CIL(completion_isyids);
for(cil_ix= 0;cil_ix<event_isy_count;cil_ix++)
{
ISYID event_isyid= Item_of_CIL(completion_isyids,cil_ix);
bv_bit_set(bv_completion_event_trigger,event_isyid);
}
}
{
const CIL nulled_isyids= Nulled_ISYIDs_of_AHM(event_ahm);
const int event_isy_count= Count_of_CIL(nulled_isyids);
for(cil_ix= 0;cil_ix<event_isy_count;cil_ix++)
{
ISYID event_isyid= Item_of_CIL(nulled_isyids,cil_ix);
bv_bit_set(bv_nulled_event_trigger,event_isyid);
}
}
{
const CIL prediction_isyids= 
Prediction_ISYIDs_of_AHM(event_ahm);
const int event_isy_count= Count_of_CIL(prediction_isyids);
for(cil_ix= 0;cil_ix<event_isy_count;cil_ix++)
{
ISYID event_isyid= Item_of_CIL(prediction_isyids,cil_ix);
bv_bit_set(bv_prediction_event_trigger,event_isyid);
}
}
}
}

if(Ord_of_YS(current_earley_set)<=0)
{








int cil_ix;
const ISY start_isy= ISY_by_ID(g->t_start_isy_id);
const CIL nulled_isyids= Nulled_ISYIDs_of_ISY(start_isy);
const int cil_count= Count_of_CIL(nulled_isyids);
for(cil_ix= 0;cil_ix<cil_count;cil_ix++)
{
const ISYID nulled_isyid= Item_of_CIL(nulled_isyids,cil_ix);
bv_bit_set(bv_nulled_event_trigger,nulled_isyid);
}
}

for(start= 0;bv_scan(bv_completion_event_trigger,start,&min,&max);
start= max+2)
{
ISYID event_isyid;
for(event_isyid= min;event_isyid<=max;
event_isyid++)
{
if(lbv_bit_test
(r->t_lbv_isyid_completion_event_is_active,event_isyid))
{
int_event_new(g,MARPA_EVENT_SYMBOL_COMPLETED,event_isyid);
}
}
}
for(start= 0;bv_scan(bv_nulled_event_trigger,start,&min,&max);
start= max+2)
{
ISYID event_isyid;
for(event_isyid= min;event_isyid<=max;
event_isyid++)
{
if(lbv_bit_test
(r->t_lbv_isyid_nulled_event_is_active,event_isyid))
{
int_event_new(g,MARPA_EVENT_SYMBOL_NULLED,event_isyid);
}

}
}
for(start= 0;bv_scan(bv_prediction_event_trigger,start,&min,&max);
start= max+2)
{
ISYID event_isyid;
for(event_isyid= (NSYID)min;event_isyid<=(NSYID)max;
event_isyid++)
{
if(lbv_bit_test
(r->t_lbv_isyid_prediction_event_is_active,event_isyid))
{
int_event_new(g,MARPA_EVENT_SYMBOL_PREDICTED,event_isyid);
}
}
}
marpa_obs_free(trigger_events_obs);
}

/*:758*//*759:*/
#line 8589 "./marpa.w"

PRIVATE int trigger_trivial_events(RECCE r)
{
int cil_ix;
int event_count= 0;
GRAMMAR g= G_of_R(r);
const ISY start_isy= ISY_by_ID(g->t_start_isy_id);
const CIL nulled_isyids= Nulled_ISYIDs_of_ISY(start_isy);
const int cil_count= Count_of_CIL(nulled_isyids);
for(cil_ix= 0;cil_ix<cil_count;cil_ix++)
{
const ISYID nulled_isyid= Item_of_CIL(nulled_isyids,cil_ix);
if(lbv_bit_test(r->t_lbv_isyid_nulled_event_is_active,nulled_isyid)){
int_event_new(g,MARPA_EVENT_SYMBOL_NULLED,nulled_isyid);
event_count++;
}
}
return event_count;
}

/*:759*//*760:*/
#line 8609 "./marpa.w"

PRIVATE void earley_set_update_items(RECCE r,YS set)
{
YIM*working_earley_items;
YIM*finished_earley_items;
int working_earley_item_count;
int i;
YIMs_of_YS(set)= marpa_obs_new(r->t_obs,YIM,YIM_Count_of_YS(set));
finished_earley_items= YIMs_of_YS(set);

working_earley_items= Work_YIMs_of_R(r);
working_earley_item_count= Work_YIM_Count_of_R(r);
for(i= 0;i<working_earley_item_count;i++){
YIM earley_item= working_earley_items[i];
int ordinal= Ord_of_YIM(earley_item);
finished_earley_items[ordinal]= earley_item;
}
WORK_YIMS_CLEAR(r);
}

/*:760*//*761:*/
#line 8638 "./marpa.w"

PRIVATE void r_update_earley_sets(RECCE r)
{
YS set;
YS first_unstacked_earley_set;
if(!MARPA_DSTACK_IS_INITIALIZED(r->t_earley_set_stack)){
first_unstacked_earley_set= First_YS_of_R(r);
MARPA_DSTACK_INIT(r->t_earley_set_stack,YS,
MAX(1024,YS_Count_of_R(r)));
}else{
YS*end_of_stack= MARPA_DSTACK_TOP(r->t_earley_set_stack,YS);
first_unstacked_earley_set= Next_YS_of_YS(*end_of_stack);
}
for(set= first_unstacked_earley_set;set;set= Next_YS_of_YS(set)){
YS*end_of_stack= MARPA_DSTACK_PUSH(r->t_earley_set_stack,YS);
(*end_of_stack)= set;
}
}

/*:761*//*777:*/
#line 8742 "./marpa.w"

PRIVATE_NOT_INLINE void
postdot_items_create(RECCE r,
Bit_Vector bv_ok_for_chain,
const YS current_earley_set)
{
/*563:*/
#line 6125 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:563*/
#line 8748 "./marpa.w"

/*776:*/
#line 8739 "./marpa.w"

bv_clear(r->t_bv_lim_symbols);
bv_clear(r->t_bv_pim_symbols);
/*:776*/
#line 8749 "./marpa.w"

/*778:*/
#line 8761 "./marpa.w"
{

YIM*work_earley_items= MARPA_DSTACK_BASE(r->t_yim_work_stack,YIM);
int no_of_work_earley_items= MARPA_DSTACK_LENGTH(r->t_yim_work_stack);
int ix;
for(ix= 0;
ix<no_of_work_earley_items;
ix++)
{
YIM earley_item= work_earley_items[ix];
AHM ahm= AHM_of_YIM(earley_item);
const NSYID postdot_nsyid= Postdot_NSYID_of_AHM(ahm);
if(postdot_nsyid<0)continue;
{
PIM old_pim= NULL;
PIM new_pim;


new_pim= marpa__obs_alloc(r->t_obs,
sizeof(YIX_Object),ALIGNOF(PIM_Object));

Postdot_NSYID_of_PIM(new_pim)= postdot_nsyid;
YIM_of_PIM(new_pim)= earley_item;
if(bv_bit_test(r->t_bv_pim_symbols,postdot_nsyid))
old_pim= r->t_pim_workarea[postdot_nsyid];
Next_PIM_of_PIM(new_pim)= old_pim;
if(!old_pim)current_earley_set->t_postdot_sym_count++;
r->t_pim_workarea[postdot_nsyid]= new_pim;
bv_bit_set(r->t_bv_pim_symbols,postdot_nsyid);
}
}
}

/*:778*/
#line 8750 "./marpa.w"

if(r->t_is_using_leo){
/*780:*/
#line 8804 "./marpa.w"

{
int min,max,start;
for(start= 0;bv_scan(r->t_bv_pim_symbols,start,&min,&max);
start= max+2)
{
NSYID nsyid;
for(nsyid= (NSYID)min;nsyid<=(NSYID)max;nsyid++)
{
const PIM this_pim= r->t_pim_workarea[nsyid];
if(Next_PIM_of_PIM(this_pim))
goto NEXT_NSYID;


{
const YIM leo_base= YIM_of_PIM(this_pim);
AHM potential_leo_penult_ahm= NULL;
const AHM leo_base_ahm= AHM_of_YIM(leo_base);
const NRL leo_base_nrl= NRL_of_AHM(leo_base_ahm);

if(!NRL_is_Leo(leo_base_nrl))
goto NEXT_NSYID;
potential_leo_penult_ahm= leo_base_ahm;
MARPA_ASSERT((int)potential_leo_penult_ahm);
{
const AHM trailhead_ahm= 
Next_AHM_of_AHM(potential_leo_penult_ahm);
if(AHM_is_Leo_Completion(trailhead_ahm))
{
/*781:*/
#line 8848 "./marpa.w"
{
LIM new_lim;
new_lim= marpa_obs_new(r->t_obs,LIM_Object,1);
LIM_is_Active(new_lim)= 1;
LIM_is_Rejected(new_lim)= 1;
Postdot_NSYID_of_LIM(new_lim)= nsyid;
YIM_of_PIM(new_lim)= NULL;
Predecessor_LIM_of_LIM(new_lim)= NULL;
Origin_of_LIM(new_lim)= NULL;
CIL_of_LIM(new_lim)= NULL;
Top_AHM_of_LIM(new_lim)= trailhead_ahm;
Trailhead_AHM_of_LIM(new_lim)= trailhead_ahm;
Trailhead_YIM_of_LIM(new_lim)= leo_base;
YS_of_LIM(new_lim)= current_earley_set;
Next_PIM_of_LIM(new_lim)= this_pim;
r->t_pim_workarea[nsyid]= new_lim;
bv_bit_set(r->t_bv_lim_symbols,nsyid);
}

/*:781*/
#line 8833 "./marpa.w"

}
}
}
NEXT_NSYID:;
}
}
}

/*:780*/
#line 8752 "./marpa.w"

/*790:*/
#line 8936 "./marpa.w"
{
int min,max,start;

bv_copy(bv_ok_for_chain,r->t_bv_lim_symbols);
for(start= 0;bv_scan(r->t_bv_lim_symbols,start,&min,&max);
start= max+2)
{

NSYID main_loop_nsyid;
for(main_loop_nsyid= (NSYID)min;
main_loop_nsyid<=(NSYID)max;
main_loop_nsyid++)
{
LIM predecessor_lim;
LIM lim_to_process= r->t_pim_workarea[main_loop_nsyid];
if(LIM_is_Populated(lim_to_process))continue;

/*792:*/
#line 8992 "./marpa.w"

{
const YIM base_yim= Trailhead_YIM_of_LIM(lim_to_process);
const YS predecessor_set= Origin_of_YIM(base_yim);
const AHM trailhead_ahm= Trailhead_AHM_of_LIM(lim_to_process);
const NSYID predecessor_transition_nsyid= 
LHSID_of_AHM(trailhead_ahm);
PIM predecessor_pim;
if(Ord_of_YS(predecessor_set)<Ord_of_YS(current_earley_set))
{
predecessor_pim
= 
First_PIM_of_YS_by_NSYID(predecessor_set,
predecessor_transition_nsyid);
}
else
{
predecessor_pim= r->t_pim_workarea[predecessor_transition_nsyid];
}
predecessor_lim= 
PIM_is_LIM(predecessor_pim)?LIM_of_PIM(predecessor_pim):NULL;
}

/*:792*/
#line 8953 "./marpa.w"

if(predecessor_lim&&LIM_is_Populated(predecessor_lim)){
/*800:*/
#line 9111 "./marpa.w"

{
const AHM new_top_ahm= Top_AHM_of_LIM(predecessor_lim);
const CIL predecessor_cil= CIL_of_LIM(predecessor_lim);



CIL_of_LIM(lim_to_process)= predecessor_cil;
Predecessor_LIM_of_LIM(lim_to_process)= predecessor_lim;
Origin_of_LIM(lim_to_process)= Origin_of_LIM(predecessor_lim);
if(Event_Group_Size_of_AHM(new_top_ahm)> Count_of_CIL(predecessor_cil))
{
const AHM trailhead_ahm= Trailhead_AHM_of_LIM(lim_to_process);
const CIL trailhead_ahm_event_ahmids= 
Event_AHMIDs_of_AHM(trailhead_ahm);
if(Count_of_CIL(trailhead_ahm_event_ahmids))
{
CIL new_cil= cil_merge_one(&g->t_cilar,predecessor_cil,
Item_of_CIL
(trailhead_ahm_event_ahmids,0));
if(new_cil)
{
CIL_of_LIM(lim_to_process)= new_cil;
}
}
}
Top_AHM_of_LIM(lim_to_process)= new_top_ahm;
}

/*:800*/
#line 8955 "./marpa.w"

continue;
}
if(!predecessor_lim){


/*802:*/
#line 9152 "./marpa.w"
{
const AHM trailhead_ahm= Trailhead_AHM_of_LIM(lim_to_process);
const YIM base_yim= Trailhead_YIM_of_LIM(lim_to_process);
Origin_of_LIM(lim_to_process)= Origin_of_YIM(base_yim);
CIL_of_LIM(lim_to_process)= Event_AHMIDs_of_AHM(trailhead_ahm);
}

/*:802*/
#line 8961 "./marpa.w"

continue;
}
/*795:*/
#line 9019 "./marpa.w"
{
int lim_chain_ix;
/*798:*/
#line 9039 "./marpa.w"

{
NSYID postdot_nsyid_of_lim_to_process
= Postdot_NSYID_of_LIM(lim_to_process);
lim_chain_ix= 0;
r->t_lim_chain[lim_chain_ix++]= LIM_of_PIM(lim_to_process);
bv_bit_clear(bv_ok_for_chain,
postdot_nsyid_of_lim_to_process);


while(1)
{








lim_to_process= predecessor_lim;
postdot_nsyid_of_lim_to_process= Postdot_NSYID_of_LIM(lim_to_process);
if(!bv_bit_test
(bv_ok_for_chain,postdot_nsyid_of_lim_to_process))
{





break;
}

/*792:*/
#line 8992 "./marpa.w"

{
const YIM base_yim= Trailhead_YIM_of_LIM(lim_to_process);
const YS predecessor_set= Origin_of_YIM(base_yim);
const AHM trailhead_ahm= Trailhead_AHM_of_LIM(lim_to_process);
const NSYID predecessor_transition_nsyid= 
LHSID_of_AHM(trailhead_ahm);
PIM predecessor_pim;
if(Ord_of_YS(predecessor_set)<Ord_of_YS(current_earley_set))
{
predecessor_pim
= 
First_PIM_of_YS_by_NSYID(predecessor_set,
predecessor_transition_nsyid);
}
else
{
predecessor_pim= r->t_pim_workarea[predecessor_transition_nsyid];
}
predecessor_lim= 
PIM_is_LIM(predecessor_pim)?LIM_of_PIM(predecessor_pim):NULL;
}

/*:792*/
#line 9072 "./marpa.w"


r->t_lim_chain[lim_chain_ix++]= LIM_of_PIM(lim_to_process);


bv_bit_clear(bv_ok_for_chain,
postdot_nsyid_of_lim_to_process);





if(!predecessor_lim)
break;
if(LIM_is_Populated(predecessor_lim))
break;



}
}

/*:798*/
#line 9021 "./marpa.w"

/*799:*/
#line 9094 "./marpa.w"

for(lim_chain_ix--;lim_chain_ix>=0;lim_chain_ix--){
lim_to_process= r->t_lim_chain[lim_chain_ix];
if(predecessor_lim&&LIM_is_Populated(predecessor_lim)){
/*800:*/
#line 9111 "./marpa.w"

{
const AHM new_top_ahm= Top_AHM_of_LIM(predecessor_lim);
const CIL predecessor_cil= CIL_of_LIM(predecessor_lim);



CIL_of_LIM(lim_to_process)= predecessor_cil;
Predecessor_LIM_of_LIM(lim_to_process)= predecessor_lim;
Origin_of_LIM(lim_to_process)= Origin_of_LIM(predecessor_lim);
if(Event_Group_Size_of_AHM(new_top_ahm)> Count_of_CIL(predecessor_cil))
{
const AHM trailhead_ahm= Trailhead_AHM_of_LIM(lim_to_process);
const CIL trailhead_ahm_event_ahmids= 
Event_AHMIDs_of_AHM(trailhead_ahm);
if(Count_of_CIL(trailhead_ahm_event_ahmids))
{
CIL new_cil= cil_merge_one(&g->t_cilar,predecessor_cil,
Item_of_CIL
(trailhead_ahm_event_ahmids,0));
if(new_cil)
{
CIL_of_LIM(lim_to_process)= new_cil;
}
}
}
Top_AHM_of_LIM(lim_to_process)= new_top_ahm;
}

/*:800*/
#line 9098 "./marpa.w"

}else{
/*802:*/
#line 9152 "./marpa.w"
{
const AHM trailhead_ahm= Trailhead_AHM_of_LIM(lim_to_process);
const YIM base_yim= Trailhead_YIM_of_LIM(lim_to_process);
Origin_of_LIM(lim_to_process)= Origin_of_YIM(base_yim);
CIL_of_LIM(lim_to_process)= Event_AHMIDs_of_AHM(trailhead_ahm);
}

/*:802*/
#line 9100 "./marpa.w"

}
predecessor_lim= lim_to_process;
}

/*:799*/
#line 9022 "./marpa.w"

}

/*:795*/
#line 8964 "./marpa.w"

}
}
}

/*:790*/
#line 8753 "./marpa.w"

}
/*803:*/
#line 9159 "./marpa.w"
{
PIM*postdot_array
= current_earley_set->t_postdot_ary
= marpa_obs_new(r->t_obs,PIM,current_earley_set->t_postdot_sym_count);
int min,max,start;
int postdot_array_ix= 0;
for(start= 0;bv_scan(r->t_bv_pim_symbols,start,&min,&max);start= max+2){
NSYID nsyid;
for(nsyid= min;nsyid<=max;nsyid++){
PIM this_pim= r->t_pim_workarea[nsyid];
if(lbv_bit_test(r->t_nsy_expected_is_event,nsyid)){
ISY isy= Source_ISY_of_NSYID(nsyid);
int_event_new(g,MARPA_EVENT_SYMBOL_EXPECTED,ID_of_ISY(isy));
}
if(this_pim)postdot_array[postdot_array_ix++]= this_pim;
}
}
}


/*:803*/
#line 8755 "./marpa.w"

bv_and(r->t_bv_nsyid_is_expected,r->t_bv_pim_symbols,g->t_bv_nsyid_is_terminal);
}

/*:777*//*806:*/
#line 9195 "./marpa.w"

Marpa_Earleme
marpa_r_clean(Marpa_Recognizer r)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 9199 "./marpa.w"

/*563:*/
#line 6125 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:563*/
#line 9200 "./marpa.w"

YSID ysid_to_clean;


const YS current_ys= Latest_YS_of_R(r);
const YSID current_ys_id= Ord_of_YS(current_ys);

int count_of_expected_terminals;
/*807:*/
#line 9256 "./marpa.w"




struct marpa_obstack*const method_obstack= marpa_obs_init;

YIMID*prediction_by_nrl= 
marpa_obs_new(method_obstack,YIMID,NRL_Count_of_G(g));

/*:807*/
#line 9208 "./marpa.w"






const JEARLEME return_value= -2;

/*1334:*/
#line 15803 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)!=R_DURING_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_ACCEPTING_INPUT);
return failure_indicator;
}

if(_MARPA_UNLIKELY(!R_is_Consistent(r))){
MARPA_ERROR(MARPA_ERR_RECCE_IS_INCONSISTENT);
return failure_indicator;
}

/*:1334*/
#line 9216 "./marpa.w"


G_EVENTS_CLEAR(g);



if(R_is_Consistent(r))return 0;





earley_set_update_items(r,current_ys);

for(ysid_to_clean= First_Inconsistent_YS_of_R(r);
ysid_to_clean<=current_ys_id;
ysid_to_clean++){
/*809:*/
#line 9270 "./marpa.w"

{
const YS ys_to_clean= YS_of_R_by_Ord(r,ysid_to_clean);
const YIM*yims_to_clean= YIMs_of_YS(ys_to_clean);
const int yim_to_clean_count= YIM_Count_of_YS(ys_to_clean);
Bit_Matrix acceptance_matrix= matrix_obs_create(method_obstack,
yim_to_clean_count,
yim_to_clean_count);
/*810:*/
#line 9290 "./marpa.w"

{
int yim_ix= yim_to_clean_count-1;
YIM yim= yims_to_clean[yim_ix];






while(YIM_was_Predicted(yim)){
prediction_by_nrl[NRLID_of_YIM(yim)]= yim_ix;
yim= yims_to_clean[--yim_ix];
}
}

/*:810*/
#line 9278 "./marpa.w"

/*811:*/
#line 9306 "./marpa.w"
{
int yim_to_clean_ix;
for(yim_to_clean_ix= 0;
yim_to_clean_ix<yim_to_clean_count;
yim_to_clean_ix++)
{
const YIM yim_to_clean= yims_to_clean[yim_to_clean_ix];




MARPA_ASSERT(!YIM_is_Initial(yim_to_clean)||
(YIM_is_Active(yim_to_clean)&&!YIM_is_Rejected(yim_to_clean)));



if(!YIM_is_Initial(yim_to_clean))YIM_is_Active(yim_to_clean)= 0;






if(YIM_is_Rejected(yim_to_clean))continue;



/*812:*/
#line 9343 "./marpa.w"

{
const NSYID postdot_nsyid= Postdot_NSYID_of_YIM(yim_to_clean);
if(postdot_nsyid>=0)
{
int cil_ix;
const CIL lhs_cil= LHS_CIL_of_NSYID(postdot_nsyid);
const int cil_count= Count_of_CIL(lhs_cil);
for(cil_ix= 0;cil_ix<cil_count;cil_ix++)
{
const NRLID nrlid= Item_of_CIL(lhs_cil,cil_ix);
const int predicted_yim_ix= prediction_by_nrl[nrlid];
const YIM predicted_yim= yims_to_clean[predicted_yim_ix];
if(YIM_is_Rejected(predicted_yim))continue;
matrix_bit_set(acceptance_matrix,yim_to_clean_ix,
predicted_yim_ix);
}
}
}

/*:812*/
#line 9333 "./marpa.w"







}
}

/*:811*/
#line 9279 "./marpa.w"

transitive_closure(acceptance_matrix);
/*817:*/
#line 9403 "./marpa.w"
{
int cause_yim_ix;
for(cause_yim_ix= 0;cause_yim_ix<yim_to_clean_count;cause_yim_ix++){
const YIM cause_yim= yims_to_clean[cause_yim_ix];





if(!YIM_is_Initial(cause_yim)&&
!YIM_was_Scanned(cause_yim))break;





if(YIM_is_Rejected(cause_yim))continue;

{
const Bit_Vector bv_yims_to_accept
= matrix_row(acceptance_matrix,cause_yim_ix);
int min,max,start;
for(start= 0;bv_scan(bv_yims_to_accept,start,&min,&max);
start= max+2)
{
int yim_to_accept_ix;
for(yim_to_accept_ix= min;
yim_to_accept_ix<=max;yim_to_accept_ix++)
{
const YIM yim_to_accept= yims_to_clean[yim_to_accept_ix];
YIM_is_Active(yim_to_accept)= 1;
}
}
}
}
}

/*:817*/
#line 9281 "./marpa.w"

/*818:*/
#line 9444 "./marpa.w"
{
int yim_ix;
for(yim_ix= 0;yim_ix<yim_to_clean_count;yim_ix++){
const YIM yim= yims_to_clean[yim_ix];
if(!YIM_is_Active(yim))continue;
YIM_is_Rejected(yim)= 1;
}
}

/*:818*/
#line 9282 "./marpa.w"

/*820:*/
#line 9458 "./marpa.w"
{}

/*:820*/
#line 9283 "./marpa.w"

/*821:*/
#line 9462 "./marpa.w"

{
int postdot_sym_ix;
const int postdot_sym_count= Postdot_SYM_Count_of_YS(ys_to_clean);
const PIM*postdot_array= ys_to_clean->t_postdot_ary;



for(postdot_sym_ix= 0;postdot_sym_ix<postdot_sym_count;postdot_sym_ix++){



const PIM first_pim= postdot_array[postdot_sym_ix];
if(PIM_is_LIM(first_pim)){
const LIM lim= LIM_of_PIM(first_pim);



LIM_is_Rejected(lim)= 1;
LIM_is_Active(lim)= 0;



if(!YIM_is_Active(Trailhead_YIM_of_LIM(lim)))continue;
{
const LIM predecessor_lim= Predecessor_LIM_of_LIM(lim);


if(predecessor_lim&&!LIM_is_Active(predecessor_lim))continue;
}



LIM_is_Rejected(lim)= 0;
LIM_is_Active(lim)= 1;
}
}
}

/*:821*/
#line 9284 "./marpa.w"

}

/*:809*/
#line 9233 "./marpa.w"

}




/*822:*/
#line 9507 "./marpa.w"
{
int old_alt_ix;
int no_of_alternatives= MARPA_DSTACK_LENGTH(r->t_alternatives);






for(old_alt_ix= 0;
old_alt_ix<no_of_alternatives;
old_alt_ix++)
{
const ALT alternative= MARPA_DSTACK_INDEX(
r->t_alternatives,ALT_Object,old_alt_ix);
if(!alternative_is_acceptable(alternative))break;
}





if(old_alt_ix<no_of_alternatives){



int empty_alt_ix= old_alt_ix;
for(old_alt_ix++;old_alt_ix<no_of_alternatives;old_alt_ix++)
{
const ALT alternative= MARPA_DSTACK_INDEX(
r->t_alternatives,ALT_Object,old_alt_ix);
if(!alternative_is_acceptable(alternative))continue;
*MARPA_DSTACK_INDEX(r->t_alternatives,ALT_Object,empty_alt_ix)
= *alternative;
empty_alt_ix++;
}




MARPA_DSTACK_COUNT_SET(r->t_alternatives,empty_alt_ix);

if(empty_alt_ix){
Furthest_Earleme_of_R(r)= Earleme_of_YS(current_ys);
}else{
const ALT furthest_alternative
= MARPA_DSTACK_INDEX(r->t_alternatives,ALT_Object,0);
Furthest_Earleme_of_R(r)= End_Earleme_of_ALT(furthest_alternative);
}

}

}

/*:822*/
#line 9239 "./marpa.w"


bv_clear(r->t_bv_nsyid_is_expected);
/*824:*/
#line 9587 "./marpa.w"
{}

/*:824*/
#line 9242 "./marpa.w"

count_of_expected_terminals= bv_count(r->t_bv_nsyid_is_expected);
if(count_of_expected_terminals<=0
&&MARPA_DSTACK_LENGTH(r->t_alternatives)<=0)
{
/*614:*/
#line 6625 "./marpa.w"

{
R_is_Exhausted(r)= 1;
Input_Phase_of_R(r)= R_AFTER_INPUT;
event_new(g,MARPA_EVENT_EXHAUSTED);
}

/*:614*/
#line 9247 "./marpa.w"

}

First_Inconsistent_YS_of_R(r)= -1;

/*808:*/
#line 9265 "./marpa.w"

{
marpa_obs_free(method_obstack);
}

/*:808*/
#line 9252 "./marpa.w"

return return_value;
}

/*:806*//*823:*/
#line 9561 "./marpa.w"

PRIVATE int alternative_is_acceptable(ALT alternative)
{
PIM pim;
const NSYID token_symbol_id= NSYID_of_ALT(alternative);
const YS start_ys= Start_YS_of_ALT(alternative);
for(pim= First_PIM_of_YS_by_NSYID(start_ys,token_symbol_id);
pim;
pim= Next_PIM_of_PIM(pim))
{
YIM predecessor_yim= YIM_of_PIM(pim);






if(!predecessor_yim)continue;



if(YIM_is_Active(predecessor_yim))return 1;
}
return 0;
}

/*:823*//*825:*/
#line 9590 "./marpa.w"

int
marpa_r_zwa_default_set(Marpa_Recognizer r,
Marpa_Assertion_ID zwaid,
int default_value)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 9596 "./marpa.w"

/*563:*/
#line 6125 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:563*/
#line 9597 "./marpa.w"

ZWA zwa;
int old_default_value;
/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 9600 "./marpa.w"

/*1330:*/
#line 15773 "./marpa.w"

if(_MARPA_UNLIKELY(ZWAID_is_Malformed(zwaid))){
MARPA_ERROR(MARPA_ERR_INVALID_ASSERTION_ID);
return failure_indicator;
}

/*:1330*/
#line 9601 "./marpa.w"

/*1329:*/
#line 15767 "./marpa.w"

if(_MARPA_UNLIKELY(!ZWAID_of_G_Exists(zwaid))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_ASSERTION_ID);
return failure_indicator;
}
/*:1329*/
#line 9602 "./marpa.w"

if(_MARPA_UNLIKELY(default_value<0||default_value> 1))
{
MARPA_ERROR(MARPA_ERR_INVALID_BOOLEAN);
return failure_indicator;
}
zwa= RZWA_by_ID(zwaid);
old_default_value= Default_Value_of_ZWA(zwa);
Default_Value_of_ZWA(zwa)= default_value?1:0;
return old_default_value;
}

/*:825*//*826:*/
#line 9614 "./marpa.w"

int
marpa_r_zwa_default(Marpa_Recognizer r,
Marpa_Assertion_ID zwaid)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 9619 "./marpa.w"

/*563:*/
#line 6125 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:563*/
#line 9620 "./marpa.w"

ZWA zwa;
/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 9622 "./marpa.w"

/*1330:*/
#line 15773 "./marpa.w"

if(_MARPA_UNLIKELY(ZWAID_is_Malformed(zwaid))){
MARPA_ERROR(MARPA_ERR_INVALID_ASSERTION_ID);
return failure_indicator;
}

/*:1330*/
#line 9623 "./marpa.w"

/*1329:*/
#line 15767 "./marpa.w"

if(_MARPA_UNLIKELY(!ZWAID_of_G_Exists(zwaid))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_ASSERTION_ID);
return failure_indicator;
}
/*:1329*/
#line 9624 "./marpa.w"

zwa= RZWA_by_ID(zwaid);
return Default_Value_of_ZWA(zwa);
}

/*:826*//*835:*/
#line 9664 "./marpa.w"

PRIVATE_NOT_INLINE int report_item_cmp(
const void*ap,
const void*bp,
void*param UNUSED)
{
const struct marpa_progress_item*const report_a= ap;
const struct marpa_progress_item*const report_b= bp;
if(Position_of_PROGRESS(report_a)> Position_of_PROGRESS(report_b))return 1;
if(Position_of_PROGRESS(report_a)<Position_of_PROGRESS(report_b))return-1;
if(RULEID_of_PROGRESS(report_a)> RULEID_of_PROGRESS(report_b))return 1;
if(RULEID_of_PROGRESS(report_a)<RULEID_of_PROGRESS(report_b))return-1;
if(Origin_of_PROGRESS(report_a)> Origin_of_PROGRESS(report_b))return 1;
if(Origin_of_PROGRESS(report_a)<Origin_of_PROGRESS(report_b))return-1;
return 0;
}

/*:835*//*836:*/
#line 9681 "./marpa.w"

int marpa_r_progress_report_start(
Marpa_Recognizer r,
Marpa_Earley_Set_ID set_id)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 9686 "./marpa.w"

YS earley_set;
/*563:*/
#line 6125 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:563*/
#line 9688 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 9689 "./marpa.w"

/*1333:*/
#line 15798 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1333*/
#line 9690 "./marpa.w"

if(set_id<0)
{
MARPA_ERROR(MARPA_ERR_INVALID_LOCATION);
return failure_indicator;
}
r_update_earley_sets(r);
if(!YS_Ord_is_Valid(r,set_id))
{
MARPA_ERROR(MARPA_ERR_NO_EARLEY_SET_AT_LOCATION);
return failure_indicator;
}
earley_set= YS_of_R_by_Ord(r,set_id);

MARPA_OFF_DEBUG3("At %s, starting progress report Earley set %ld",
STRLOC,(long)set_id);

/*830:*/
#line 9638 "./marpa.w"

r->t_current_report_item= &progress_report_not_ready;
if(r->t_progress_report_traverser){
_marpa_avl_destroy(MARPA_TREE_OF_AVL_TRAV(r->t_progress_report_traverser));
}
r->t_progress_report_traverser= NULL;
/*:830*/
#line 9707 "./marpa.w"

{
const MARPA_AVL_TREE report_tree= 
_marpa_avl_create(report_item_cmp,NULL);
const YIM*const earley_items= YIMs_of_YS(earley_set);
const int earley_item_count= YIM_Count_of_YS(earley_set);
int earley_item_id;
for(earley_item_id= 0;earley_item_id<earley_item_count;
earley_item_id++)
{
const YIM earley_item= earley_items[earley_item_id];
if(!YIM_is_Active(earley_item))continue;
/*838:*/
#line 9740 "./marpa.w"

{
SRCL leo_source_link= NULL;

MARPA_OFF_DEBUG2("At %s, Do the progress report",STRLOC);

progress_report_items_insert(report_tree,AHM_of_YIM(earley_item),
earley_item);
for(leo_source_link= First_Leo_SRCL_of_YIM(earley_item);
leo_source_link;leo_source_link= Next_SRCL_of_SRCL(leo_source_link))
{
LIM leo_item;
MARPA_OFF_DEBUG3("At %s, Leo source link %p",STRLOC,leo_source_link);

if(!SRCL_is_Active(leo_source_link))continue;

MARPA_OFF_DEBUG3("At %s, active Leo source link %p",STRLOC,leo_source_link);




for(leo_item= LIM_of_SRCL(leo_source_link);
leo_item;leo_item= Predecessor_LIM_of_LIM(leo_item))
{
const YIM trailhead_yim= Trailhead_YIM_of_LIM(leo_item);
const AHM trailhead_ahm= Trailhead_AHM_of_LIM(leo_item);
progress_report_items_insert(report_tree,trailhead_ahm,
trailhead_yim);
}

MARPA_OFF_DEBUG3("At %s, finished Leo source link %p",STRLOC,leo_source_link);
}
}

/*:838*/
#line 9719 "./marpa.w"

}
r->t_progress_report_traverser= _marpa_avl_t_init(report_tree);
return(int)marpa_avl_count(report_tree);
}
}
/*:836*//*837:*/
#line 9726 "./marpa.w"

int marpa_r_progress_report_reset(Marpa_Recognizer r)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 9729 "./marpa.w"

MARPA_AVL_TRAV traverser= r->t_progress_report_traverser;
/*563:*/
#line 6125 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:563*/
#line 9731 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 9732 "./marpa.w"

/*1333:*/
#line 15798 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1333*/
#line 9733 "./marpa.w"

/*842:*/
#line 9890 "./marpa.w"

{
if(!traverser)
{
MARPA_ERROR(MARPA_ERR_PROGRESS_REPORT_NOT_STARTED);
return failure_indicator;
}
}

/*:842*/
#line 9734 "./marpa.w"

_marpa_avl_t_reset(traverser);
return 1;
}

/*:837*//*839:*/
#line 9774 "./marpa.w"

PRIVATE void
progress_report_items_insert(MARPA_AVL_TREE report_tree,
AHM report_ahm,
YIM origin_yim)
{
const IRL source_irl= IRL_of_AHM(report_ahm);

MARPA_OFF_DEBUG5(
"%s Calling progress_report_items_insert(%p, %p, %p)",
STRLOC,report_tree,report_ahm,origin_yim);

if(!source_irl)return;





if(!NRL_has_Virtual_LHS(NRL_of_YIM(origin_yim))){
int irl_position= IRL_Position_of_AHM(report_ahm);
int origin_of_irl= Origin_Ord_of_YIM(origin_yim);
IRLID irl_id= ID_of_IRL(source_irl);

PROGRESS new_report_item= 
marpa_obs_new(MARPA_AVL_OBSTACK(report_tree),
struct marpa_progress_item,1);

MARPA_OFF_DEBUG2("%s, === Adding report item ===",STRLOC);
MARPA_OFF_DEBUG3("%s, report nrl = %d",STRLOC,NRLID_of_AHM(report_ahm));
MARPA_OFF_DEBUG3("%s, report nrl position = %d",STRLOC,Position_of_AHM(report_ahm));

MARPA_OFF_DEBUG3("%s, xrl = %d",STRLOC,ID_of_IRL(source_irl));
MARPA_OFF_DEBUG3("%s, xrl dot = %d",STRLOC,IRL_Position_of_AHM(report_ahm));
MARPA_OFF_DEBUG3("%s, origin ord = %d",STRLOC,Origin_Ord_of_YIM(origin_yim));

Position_of_PROGRESS(new_report_item)= irl_position;
Origin_of_PROGRESS(new_report_item)= origin_of_irl;
RULEID_of_PROGRESS(new_report_item)= irl_id;
_marpa_avl_insert(report_tree,new_report_item);

return;
}







if(IRL_is_Sequence(source_irl))return;








{
const NSYID lhs_nsyid= LHS_NSYID_of_YIM(origin_yim);
const YS origin_of_origin_ys= Origin_of_YIM(origin_yim);
PIM pim= First_PIM_of_YS_by_NSYID(origin_of_origin_ys,lhs_nsyid);
for(;pim;pim= Next_PIM_of_PIM(pim))
{
const YIM predecessor= YIM_of_PIM(pim);




if(!predecessor)return;
if(YIM_is_Active(predecessor)){
progress_report_items_insert(report_tree,
report_ahm,predecessor);
}
}
}
}

/*:839*//*840:*/
#line 9852 "./marpa.w"

int marpa_r_progress_report_finish(Marpa_Recognizer r){
const int success= 1;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 9855 "./marpa.w"

/*563:*/
#line 6125 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:563*/
#line 9856 "./marpa.w"

const MARPA_AVL_TRAV traverser= r->t_progress_report_traverser;
/*1333:*/
#line 15798 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1333*/
#line 9858 "./marpa.w"

/*842:*/
#line 9890 "./marpa.w"

{
if(!traverser)
{
MARPA_ERROR(MARPA_ERR_PROGRESS_REPORT_NOT_STARTED);
return failure_indicator;
}
}

/*:842*/
#line 9859 "./marpa.w"

/*830:*/
#line 9638 "./marpa.w"

r->t_current_report_item= &progress_report_not_ready;
if(r->t_progress_report_traverser){
_marpa_avl_destroy(MARPA_TREE_OF_AVL_TRAV(r->t_progress_report_traverser));
}
r->t_progress_report_traverser= NULL;
/*:830*/
#line 9860 "./marpa.w"

return success;
}

/*:840*//*841:*/
#line 9864 "./marpa.w"

Marpa_Rule_ID marpa_r_progress_item(
Marpa_Recognizer r,int*position,Marpa_Earley_Set_ID*origin
){
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 9868 "./marpa.w"

PROGRESS report_item;
MARPA_AVL_TRAV traverser;
/*563:*/
#line 6125 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:563*/
#line 9871 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 9872 "./marpa.w"

/*1333:*/
#line 15798 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1333*/
#line 9873 "./marpa.w"

traverser= r->t_progress_report_traverser;
if(_MARPA_UNLIKELY(!position||!origin)){
MARPA_ERROR(MARPA_ERR_POINTER_ARG_NULL);
return failure_indicator;
}
/*842:*/
#line 9890 "./marpa.w"

{
if(!traverser)
{
MARPA_ERROR(MARPA_ERR_PROGRESS_REPORT_NOT_STARTED);
return failure_indicator;
}
}

/*:842*/
#line 9879 "./marpa.w"

report_item= _marpa_avl_t_next(traverser);
if(!report_item){
MARPA_ERROR(MARPA_ERR_PROGRESS_REPORT_EXHAUSTED);
return-1;
}
*position= Position_of_PROGRESS(report_item);
*origin= Origin_of_PROGRESS(report_item);
return RULEID_of_PROGRESS(report_item);
}

/*:841*//*865:*/
#line 10075 "./marpa.w"

PRIVATE void ur_node_stack_init(URS stack)
{
stack->t_obs= marpa_obs_init;
stack->t_base= ur_node_new(stack,0);
ur_node_stack_reset(stack);
}

/*:865*//*866:*/
#line 10083 "./marpa.w"

PRIVATE void ur_node_stack_reset(URS stack)
{
stack->t_top= stack->t_base;
}

/*:866*//*867:*/
#line 10089 "./marpa.w"

PRIVATE void ur_node_stack_destroy(URS stack)
{
if(stack->t_base)marpa_obs_free(stack->t_obs);
stack->t_base= NULL;
}

/*:867*//*868:*/
#line 10096 "./marpa.w"

PRIVATE UR ur_node_new(URS stack,UR prev)
{
UR new_ur_node;
new_ur_node= marpa_obs_new(stack->t_obs,UR_Object,1);
Next_UR_of_UR(new_ur_node)= 0;
Prev_UR_of_UR(new_ur_node)= prev;
return new_ur_node;
}

/*:868*//*869:*/
#line 10106 "./marpa.w"

PRIVATE void
ur_node_push(URS stack,YIM earley_item)
{
UR old_top= stack->t_top;
UR new_top= Next_UR_of_UR(old_top);
YIM_of_UR(old_top)= earley_item;
if(!new_top)
{
new_top= ur_node_new(stack,old_top);
Next_UR_of_UR(old_top)= new_top;
}
stack->t_top= new_top;
}

/*:869*//*870:*/
#line 10121 "./marpa.w"

PRIVATE UR
ur_node_pop(URS stack)
{
UR new_top= Prev_UR_of_UR(stack->t_top);
if(!new_top)return NULL;
stack->t_top= new_top;
return new_top;
}

/*:870*//*872:*/
#line 10158 "./marpa.w"

PRIVATE void push_ur_if_new(
struct s_bocage_setup_per_ys*per_ys_data,
URS ur_node_stack,YIM yim)
{
if(!psi_test_and_set(per_ys_data,yim))
{
ur_node_push(ur_node_stack,yim);
}
}

/*:872*//*873:*/
#line 10174 "./marpa.w"

PRIVATE int psi_test_and_set(
struct s_bocage_setup_per_ys*per_ys_data,
YIM earley_item
)
{
const YSID set_ordinal= YS_Ord_of_YIM(earley_item);
const int item_ordinal= Ord_of_YIM(earley_item);
const OR previous_or_node= 
OR_by_PSI(per_ys_data,set_ordinal,item_ordinal);
if(!previous_or_node)
{
OR_by_PSI(per_ys_data,set_ordinal,item_ordinal)= dummy_or_node;
return 0;
}
return 1;
}

/*:873*//*875:*/
#line 10216 "./marpa.w"

PRIVATE void
Set_boolean_in_PSI_for_initial_nulls(struct s_bocage_setup_per_ys*per_ys_data,
YIM yim)
{
const AHM ahm= AHM_of_YIM(yim);
if(Null_Count_of_AHM(ahm))
psi_test_and_set(per_ys_data,(yim));
}

/*:875*//*894:*/
#line 10474 "./marpa.w"

PRIVATE OR or_node_new(BOCAGE b)
{
const int or_node_id= OR_Count_of_B(b)++;
const OR new_or_node= (OR)marpa_obs_new(OBS_of_B(b),OR_Object,1);
ID_of_OR(new_or_node)= or_node_id;
DANDs_of_OR(new_or_node)= NULL;
if(_MARPA_UNLIKELY(or_node_id>=OR_Capacity_of_B(b)))
{
OR_Capacity_of_B(b)*= 2;
ORs_of_B(b)= 
marpa_renew(OR,ORs_of_B(b),OR_Capacity_of_B(b));
}
OR_of_B_by_ID(b,or_node_id)= new_or_node;
return new_or_node;
}

/*:894*//*904:*/
#line 10674 "./marpa.w"

PRIVATE
DAND draft_and_node_new(struct marpa_obstack*obs,OR predecessor,OR cause)
{
DAND draft_and_node= marpa_obs_new(obs,DAND_Object,1);
Predecessor_OR_of_DAND(draft_and_node)= predecessor;
Cause_OR_of_DAND(draft_and_node)= cause;
MARPA_ASSERT(cause!=NULL);
return draft_and_node;
}

/*:904*//*905:*/
#line 10685 "./marpa.w"

PRIVATE
void draft_and_node_add(struct marpa_obstack*obs,OR parent,OR predecessor,OR cause)
{
MARPA_OFF_ASSERT(Position_of_OR(parent)<=1||predecessor)
const DAND new= draft_and_node_new(obs,predecessor,cause);
Next_DAND_of_DAND(new)= DANDs_of_OR(parent);
DANDs_of_OR(parent)= new;
}

/*:905*//*913:*/
#line 10825 "./marpa.w"

PRIVATE
OR or_by_origin_and_symi(struct s_bocage_setup_per_ys*per_ys_data,
YSID origin,
SYMI symbol_instance)
{
const PSL or_psl_at_origin= per_ys_data[(origin)].t_or_psl;
return PSL_Datum(or_psl_at_origin,(symbol_instance));
}

/*:913*//*918:*/
#line 10884 "./marpa.w"

PRIVATE
int dands_are_equal(OR predecessor_a,OR cause_a,
OR predecessor_b,OR cause_b)
{
const int a_is_token= OR_is_Token(cause_a);
const int b_is_token= OR_is_Token(cause_b);
if(a_is_token!=b_is_token)return 0;
{


const int middle_of_a= predecessor_a?YS_Ord_of_OR(predecessor_a):-1;
const int middle_of_b= predecessor_b?YS_Ord_of_OR(predecessor_b):-1;
if(middle_of_a!=middle_of_b)
return 0;
}
if(a_is_token)
{
const NSYID nsyid_of_a= NSYID_of_OR(cause_a);
const NSYID nsyid_of_b= NSYID_of_OR(cause_b);
return nsyid_of_a==nsyid_of_b;
}
{

const NRLID nrlid_of_a= NRLID_of_OR(cause_a);
const NRLID nrlid_of_b= NRLID_of_OR(cause_b);
return nrlid_of_a==nrlid_of_b;
}

}

/*:918*//*919:*/
#line 10918 "./marpa.w"

PRIVATE
int dand_is_duplicate(OR parent,OR predecessor,OR cause)
{
DAND dand;
for(dand= DANDs_of_OR(parent);dand;dand= Next_DAND_of_DAND(dand)){
if(dands_are_equal(predecessor,cause,
Predecessor_OR_of_DAND(dand),Cause_OR_of_DAND(dand)))
{
return 1;
}
}
return 0;
}

/*:919*//*920:*/
#line 10933 "./marpa.w"

PRIVATE
OR set_or_from_yim(struct s_bocage_setup_per_ys*per_ys_data,
YIM psi_yim)
{
const YIM psi_earley_item= psi_yim;
const int psi_earley_set_ordinal= YS_Ord_of_YIM(psi_earley_item);
const int psi_item_ordinal= Ord_of_YIM(psi_earley_item);
return OR_by_PSI(per_ys_data,psi_earley_set_ordinal,psi_item_ordinal);
}

/*:920*//*923:*/
#line 10991 "./marpa.w"

PRIVATE
OR safe_or_from_yim(
struct s_bocage_setup_per_ys*per_ys_data,
YIM yim)
{
if(Position_of_AHM(AHM_of_YIM(yim))<1)return NULL;
return set_or_from_yim(per_ys_data,yim);
}

/*:923*//*941:*/
#line 11155 "./marpa.w"

int marpa_trv_soft_error(Marpa_Traverser trv)
{
return TRV_has_Soft_Error(trv);
}

/*:941*//*946:*/
#line 11176 "./marpa.w"

PRIVATE Marpa_Traverser
trv_new(RECCE r,YIM yim)
{
TRAVERSER trv;

trv= my_malloc(sizeof(*trv));
/*940:*/
#line 11153 "./marpa.w"

TRV_has_Soft_Error(trv)= 0;
/*:940*//*943:*/
#line 11164 "./marpa.w"

R_of_TRV(trv)= r;

/*:943*//*961:*/
#line 11501 "./marpa.w"

trv->t_ref_count= 1;
/*:961*/
#line 11183 "./marpa.w"

recce_ref(r);
if(!yim){
TRV_is_Trivial(trv)= 1;
return trv;
}
TRV_is_Trivial(trv)= 0;
YIM_of_TRV(trv)= yim;
TOKEN_SRCL_of_TRV(trv)= First_Token_SRCL_of_YIM(yim);
COMPLETION_SRCL_of_TRV(trv)= First_Completion_SRCL_of_YIM(yim);
LEO_SRCL_of_TRV(trv)= First_Leo_SRCL_of_YIM(yim);
return trv;
}

/*:946*//*947:*/
#line 11201 "./marpa.w"

Marpa_Traverser marpa_trv_new(Marpa_Recognizer r,
Marpa_Earley_Set_ID es_arg,
Marpa_Earley_Item_ID eim_arg
)
{
/*1315:*/
#line 15686 "./marpa.w"
void*const failure_indicator= NULL;
/*:1315*/
#line 11207 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 11209 "./marpa.w"


if(_MARPA_UNLIKELY(es_arg<=-2))
{
MARPA_ERROR(MARPA_ERR_INVALID_LOCATION);
return failure_indicator;
}
if(_MARPA_UNLIKELY(eim_arg<0))
{
MARPA_ERROR(MARPA_ERR_YIM_ID_INVALID);
return failure_indicator;
}

/*1333:*/
#line 15798 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1333*/
#line 11222 "./marpa.w"


if(G_is_Trivial(g)){
if(es_arg> 0){
MARPA_ERROR(MARPA_ERR_INVALID_LOCATION);
return failure_indicator;
}
if(eim_arg!=0){
MARPA_ERROR(MARPA_ERR_YIM_ID_INVALID);
return failure_indicator;
}
return trv_new(r,NULL);
}

r_update_earley_sets(r);

{
YIM*earley_items;
YIM yim;
YS ys;
int item_count;

if(es_arg==-1)
{
ys= YS_at_Current_Earleme_of_R(r);
}
else
{
if(!YS_Ord_is_Valid(r,es_arg))
{
MARPA_ERROR(MARPA_ERR_INVALID_LOCATION);
return failure_indicator;
}
ys= YS_of_R_by_Ord(r,es_arg);
}

item_count= YIM_Count_of_YS(ys);
if(eim_arg>=item_count){
MARPA_ERROR(MARPA_ERR_YIM_ID_INVALID);
return failure_indicator;
}

earley_items= YIMs_of_YS(ys);
yim= earley_items[eim_arg];
return trv_new(r,yim);
}
}

/*:947*//*948:*/
#line 11271 "./marpa.w"

int marpa_trv_at_completion(Marpa_Traverser trv)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 11274 "./marpa.w"

/*944:*/
#line 11167 "./marpa.w"

const RECCE r UNUSED= R_of_TRV(trv);
const GRAMMAR g UNUSED= G_of_R(r);

/*:944*/
#line 11275 "./marpa.w"

SRCL srcl;
/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 11277 "./marpa.w"


if(G_is_Trivial(g))return 0;
srcl= COMPLETION_SRCL_of_TRV(trv);
return srcl?1:0;
}

/*:948*//*949:*/
#line 11285 "./marpa.w"

int marpa_trv_at_token(Marpa_Traverser trv)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 11288 "./marpa.w"

/*944:*/
#line 11167 "./marpa.w"

const RECCE r UNUSED= R_of_TRV(trv);
const GRAMMAR g UNUSED= G_of_R(r);

/*:944*/
#line 11289 "./marpa.w"

SRCL srcl;
/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 11291 "./marpa.w"


if(G_is_Trivial(g))return 0;
srcl= TOKEN_SRCL_of_TRV(trv);
return srcl?1:0;
}

/*:949*//*950:*/
#line 11299 "./marpa.w"

int marpa_trv_at_leo(Marpa_Traverser trv)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 11302 "./marpa.w"

/*944:*/
#line 11167 "./marpa.w"

const RECCE r UNUSED= R_of_TRV(trv);
const GRAMMAR g UNUSED= G_of_R(r);

/*:944*/
#line 11303 "./marpa.w"

SRCL srcl;
/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 11305 "./marpa.w"


if(G_is_Trivial(g))return 0;
srcl= LEO_SRCL_of_TRV(trv);
return srcl?1:0;
}

/*:950*//*951:*/
#line 11315 "./marpa.w"

Marpa_Traverser marpa_trv_completion_cause(Marpa_Traverser trv)
{
/*1315:*/
#line 15686 "./marpa.w"
void*const failure_indicator= NULL;
/*:1315*/
#line 11318 "./marpa.w"

/*944:*/
#line 11167 "./marpa.w"

const RECCE r UNUSED= R_of_TRV(trv);
const GRAMMAR g UNUSED= G_of_R(r);

/*:944*/
#line 11319 "./marpa.w"

SRCL srcl;
YIM cause;
/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 11322 "./marpa.w"

TRV_has_Soft_Error(trv)= 0;

if(G_is_Trivial(g)){
TRV_has_Soft_Error(trv)= 1;
MARPA_ERROR(MARPA_ERR_GRAMMAR_IS_TRIVIAL);
return NULL;
}
srcl= COMPLETION_SRCL_of_TRV(trv);
if(!srcl){
MARPA_ERROR(MARPA_ERR_DEVELOPMENT);
TRV_has_Soft_Error(trv)= 1;
return NULL;
}
cause= Cause_of_SRCL(srcl);
if(!cause){
TRV_has_Soft_Error(trv)= 1;
return NULL;
}
return trv_new(r,cause);
}

/*:951*//*952:*/
#line 11348 "./marpa.w"

Marpa_Traverser marpa_trv_completion_predecessor(Marpa_Traverser trv)
{
/*1315:*/
#line 15686 "./marpa.w"
void*const failure_indicator= NULL;
/*:1315*/
#line 11351 "./marpa.w"

/*944:*/
#line 11167 "./marpa.w"

const RECCE r UNUSED= R_of_TRV(trv);
const GRAMMAR g UNUSED= G_of_R(r);

/*:944*/
#line 11352 "./marpa.w"

SRCL srcl;
YIM predecessor;
/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 11355 "./marpa.w"

TRV_has_Soft_Error(trv)= 0;

if(G_is_Trivial(g)){
TRV_has_Soft_Error(trv)= 1;
MARPA_ERROR(MARPA_ERR_GRAMMAR_IS_TRIVIAL);
return NULL;
}
srcl= COMPLETION_SRCL_of_TRV(trv);
if(!srcl){
MARPA_ERROR(MARPA_ERR_DEVELOPMENT);
TRV_has_Soft_Error(trv)= 1;
return NULL;
}
predecessor= Predecessor_of_SRCL(srcl);
if(!predecessor){
TRV_has_Soft_Error(trv)= 1;
return NULL;
}
return trv_new(r,predecessor);
}

/*:952*//*953:*/
#line 11381 "./marpa.w"

Marpa_LTraverser marpa_trv_lim(Marpa_Traverser trv)
{
/*1315:*/
#line 15686 "./marpa.w"
void*const failure_indicator= NULL;
/*:1315*/
#line 11384 "./marpa.w"

/*944:*/
#line 11167 "./marpa.w"

const RECCE r UNUSED= R_of_TRV(trv);
const GRAMMAR g UNUSED= G_of_R(r);

/*:944*/
#line 11385 "./marpa.w"

SRCL srcl;
LIM predecessor;
/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 11388 "./marpa.w"

TRV_has_Soft_Error(trv)= 0;

if(G_is_Trivial(g)){
TRV_has_Soft_Error(trv)= 1;
MARPA_ERROR(MARPA_ERR_GRAMMAR_IS_TRIVIAL);
return NULL;
}
srcl= LEO_SRCL_of_TRV(trv);
if(!srcl){
MARPA_ERROR(MARPA_ERR_DEVELOPMENT);
TRV_has_Soft_Error(trv)= 1;
return NULL;
}
predecessor= LIM_of_SRCL(srcl);
if(!predecessor){
TRV_has_Soft_Error(trv)= 1;
return NULL;
}
return ltrv_new(r,predecessor);
}

/*:953*//*954:*/
#line 11414 "./marpa.w"

Marpa_Traverser marpa_trv_token_predecessor(Marpa_Traverser trv)
{
/*1315:*/
#line 15686 "./marpa.w"
void*const failure_indicator= NULL;
/*:1315*/
#line 11417 "./marpa.w"

/*944:*/
#line 11167 "./marpa.w"

const RECCE r UNUSED= R_of_TRV(trv);
const GRAMMAR g UNUSED= G_of_R(r);

/*:944*/
#line 11418 "./marpa.w"

SRCL srcl;
YIM predecessor;
/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 11421 "./marpa.w"

TRV_has_Soft_Error(trv)= 0;

if(G_is_Trivial(g)){
TRV_has_Soft_Error(trv)= 1;
MARPA_ERROR(MARPA_ERR_GRAMMAR_IS_TRIVIAL);
return NULL;
}
srcl= TOKEN_SRCL_of_TRV(trv);
if(!srcl){
MARPA_ERROR(MARPA_ERR_DEVELOPMENT);
TRV_has_Soft_Error(trv)= 1;
return NULL;
}
predecessor= Predecessor_of_SRCL(srcl);
if(!predecessor){
TRV_has_Soft_Error(trv)= 1;
return NULL;
}
return trv_new(r,predecessor);
}

/*:954*//*956:*/
#line 11445 "./marpa.w"

int marpa_trv_completion_next(Marpa_Traverser trv)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 11448 "./marpa.w"

/*944:*/
#line 11167 "./marpa.w"

const RECCE r UNUSED= R_of_TRV(trv);
const GRAMMAR g UNUSED= G_of_R(r);

/*:944*/
#line 11449 "./marpa.w"

SRCL srcl;
/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 11451 "./marpa.w"

if(G_is_Trivial(g)){
return 0;
}
srcl= COMPLETION_SRCL_of_TRV(trv);
if(!srcl)return 0;
srcl= COMPLETION_SRCL_of_TRV(trv)= Next_SRCL_of_SRCL(srcl);
if(!srcl)return 0;
return 1;
}

/*:956*//*957:*/
#line 11463 "./marpa.w"

int marpa_trv_leo_next(Marpa_Traverser trv)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 11466 "./marpa.w"

/*944:*/
#line 11167 "./marpa.w"

const RECCE r UNUSED= R_of_TRV(trv);
const GRAMMAR g UNUSED= G_of_R(r);

/*:944*/
#line 11467 "./marpa.w"

SRCL srcl;
/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 11469 "./marpa.w"

if(G_is_Trivial(g)){
return 0;
}
srcl= LEO_SRCL_of_TRV(trv);
if(!srcl)return 0;
srcl= LEO_SRCL_of_TRV(trv)= Next_SRCL_of_SRCL(srcl);
if(!srcl)return 0;
return 1;
}

/*:957*//*958:*/
#line 11481 "./marpa.w"

int marpa_trv_token_next(Marpa_Traverser trv)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 11484 "./marpa.w"

/*944:*/
#line 11167 "./marpa.w"

const RECCE r UNUSED= R_of_TRV(trv);
const GRAMMAR g UNUSED= G_of_R(r);

/*:944*/
#line 11485 "./marpa.w"

SRCL srcl;
/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 11487 "./marpa.w"

if(G_is_Trivial(g)){
return 0;
}
srcl= TOKEN_SRCL_of_TRV(trv);
if(!srcl)return 0;
srcl= TOKEN_SRCL_of_TRV(trv)= Next_SRCL_of_SRCL(srcl);
if(!srcl)return 0;
return 1;
}

/*:958*//*962:*/
#line 11504 "./marpa.w"

PRIVATE void
traverser_unref(TRAVERSER trv)
{
MARPA_ASSERT(trv->t_ref_count> 0)
trv->t_ref_count--;
if(trv->t_ref_count<=0)
{
traverser_free(trv);
}
}
void
marpa_trv_unref(Marpa_Traverser trv)
{
traverser_unref(trv);
}

/*:962*//*963:*/
#line 11522 "./marpa.w"

PRIVATE TRAVERSER
traverser_ref(TRAVERSER trv)
{
MARPA_ASSERT(trv->t_ref_count> 0)
trv->t_ref_count++;
return trv;
}
Marpa_Traverser
marpa_trv_ref(Marpa_Traverser trv)
{
return traverser_ref(trv);
}

/*:963*//*965:*/
#line 11540 "./marpa.w"

PRIVATE void
traverser_free(TRAVERSER trv)
{
/*944:*/
#line 11167 "./marpa.w"

const RECCE r UNUSED= R_of_TRV(trv);
const GRAMMAR g UNUSED= G_of_R(r);

/*:944*/
#line 11544 "./marpa.w"

if(trv)
{
/*937:*/
#line 11145 "./marpa.w"

{
recce_unref(R_of_TRV(trv));
}

/*:937*/
#line 11547 "./marpa.w"
;
}
my_free(trv);
}

/*:965*//*969:*/
#line 11562 "./marpa.w"

int marpa_trv_is_trivial(Marpa_Traverser trv)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 11565 "./marpa.w"

/*944:*/
#line 11167 "./marpa.w"

const RECCE r UNUSED= R_of_TRV(trv);
const GRAMMAR g UNUSED= G_of_R(r);

/*:944*/
#line 11566 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 11567 "./marpa.w"

return TRV_is_Trivial(trv);
}
/*:969*//*972:*/
#line 11579 "./marpa.w"

int marpa_trv_ahm_id(Marpa_Traverser trv)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 11582 "./marpa.w"

/*944:*/
#line 11167 "./marpa.w"

const RECCE r UNUSED= R_of_TRV(trv);
const GRAMMAR g UNUSED= G_of_R(r);

/*:944*/
#line 11583 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 11584 "./marpa.w"

/*970:*/
#line 11570 "./marpa.w"

if(TRV_is_Trivial(trv)){
MARPA_ERROR(MARPA_ERR_GRAMMAR_IS_TRIVIAL);
return failure_indicator;
}

/*:970*/
#line 11585 "./marpa.w"

{
const YIM yim= YIM_of_TRV(trv);
return AHMID_of_YIM(yim);
}
}

/*:972*//*973:*/
#line 11593 "./marpa.w"

Marpa_Rule_ID marpa_trv_rule_id(Marpa_Traverser trv)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 11596 "./marpa.w"

/*944:*/
#line 11167 "./marpa.w"

const RECCE r UNUSED= R_of_TRV(trv);
const GRAMMAR g UNUSED= G_of_R(r);

/*:944*/
#line 11597 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 11598 "./marpa.w"

/*970:*/
#line 11570 "./marpa.w"

if(TRV_is_Trivial(trv)){
MARPA_ERROR(MARPA_ERR_GRAMMAR_IS_TRIVIAL);
return failure_indicator;
}

/*:970*/
#line 11599 "./marpa.w"

{
const YIM yim= YIM_of_TRV(trv);
const AHM ahm= AHM_of_YIM(yim);
const IRL xrl= IRL_of_AHM(ahm);
if(xrl)return ID_of_IRL(xrl);
}
return-1;
}

/*:973*//*974:*/
#line 11610 "./marpa.w"

int marpa_trv_dot(Marpa_Traverser trv)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 11613 "./marpa.w"

/*944:*/
#line 11167 "./marpa.w"

const RECCE r UNUSED= R_of_TRV(trv);
const GRAMMAR g UNUSED= G_of_R(r);

/*:944*/
#line 11614 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 11615 "./marpa.w"

/*970:*/
#line 11570 "./marpa.w"

if(TRV_is_Trivial(trv)){
MARPA_ERROR(MARPA_ERR_GRAMMAR_IS_TRIVIAL);
return failure_indicator;
}

/*:970*/
#line 11616 "./marpa.w"

{
const YIM yim= YIM_of_TRV(trv);
const AHM ahm= AHM_of_YIM(yim);
const int irl_position= IRL_Position_of_AHM(ahm);
if(irl_position<-1){
MARPA_ERROR(MARPA_ERR_NO_SUCH_RULE_ID);
return failure_indicator;
}
return irl_position;
}
}

/*:974*//*975:*/
#line 11630 "./marpa.w"

int marpa_trv_current(Marpa_Traverser trv)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 11633 "./marpa.w"

/*944:*/
#line 11167 "./marpa.w"

const RECCE r UNUSED= R_of_TRV(trv);
const GRAMMAR g UNUSED= G_of_R(r);

/*:944*/
#line 11634 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 11635 "./marpa.w"

/*970:*/
#line 11570 "./marpa.w"

if(TRV_is_Trivial(trv)){
MARPA_ERROR(MARPA_ERR_GRAMMAR_IS_TRIVIAL);
return failure_indicator;
}

/*:970*/
#line 11636 "./marpa.w"

{
const YIM yim= YIM_of_TRV(trv);
return YS_Ord_of_YIM(yim);
}
}

/*:975*//*976:*/
#line 11644 "./marpa.w"

int marpa_trv_origin(Marpa_Traverser trv)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 11647 "./marpa.w"

/*944:*/
#line 11167 "./marpa.w"

const RECCE r UNUSED= R_of_TRV(trv);
const GRAMMAR g UNUSED= G_of_R(r);

/*:944*/
#line 11648 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 11649 "./marpa.w"

/*970:*/
#line 11570 "./marpa.w"

if(TRV_is_Trivial(trv)){
MARPA_ERROR(MARPA_ERR_GRAMMAR_IS_TRIVIAL);
return failure_indicator;
}

/*:970*/
#line 11650 "./marpa.w"

{
const YIM yim= YIM_of_TRV(trv);
return Origin_Ord_of_YIM(yim);
}
}

/*:976*//*977:*/
#line 11658 "./marpa.w"

Marpa_NRL_ID marpa_trv_nrl_id(Marpa_Traverser trv)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 11661 "./marpa.w"

/*944:*/
#line 11167 "./marpa.w"

const RECCE r UNUSED= R_of_TRV(trv);
const GRAMMAR g UNUSED= G_of_R(r);

/*:944*/
#line 11662 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 11663 "./marpa.w"

/*970:*/
#line 11570 "./marpa.w"

if(TRV_is_Trivial(trv)){
MARPA_ERROR(MARPA_ERR_GRAMMAR_IS_TRIVIAL);
return failure_indicator;
}

/*:970*/
#line 11664 "./marpa.w"

{
const YIM yim= YIM_of_TRV(trv);
const AHM ahm= AHM_of_YIM(yim);
const NRL nrl= NRL_of_AHM(ahm);
if(nrl)return ID_of_NRL(nrl);
}
return-1;
}

/*:977*//*978:*/
#line 11675 "./marpa.w"

int marpa_trv_nrl_dot(Marpa_Traverser trv)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 11678 "./marpa.w"

/*944:*/
#line 11167 "./marpa.w"

const RECCE r UNUSED= R_of_TRV(trv);
const GRAMMAR g UNUSED= G_of_R(r);

/*:944*/
#line 11679 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 11680 "./marpa.w"

/*970:*/
#line 11570 "./marpa.w"

if(TRV_is_Trivial(trv)){
MARPA_ERROR(MARPA_ERR_GRAMMAR_IS_TRIVIAL);
return failure_indicator;
}

/*:970*/
#line 11681 "./marpa.w"

{
const YIM yim= YIM_of_TRV(trv);
const AHM ahm= AHM_of_YIM(yim);
return Position_of_AHM(ahm);
}
}

/*:978*//*988:*/
#line 11725 "./marpa.w"

int marpa_ltrv_soft_error(Marpa_LTraverser ltrv)
{
return LTRV_has_Soft_Error(ltrv);
}

/*:988*//*993:*/
#line 11743 "./marpa.w"

PRIVATE Marpa_LTraverser
ltrv_new(RECCE r,LIM lim)
{
LTRAVERSER ltrv;

ltrv= my_malloc(sizeof(*ltrv));
/*987:*/
#line 11723 "./marpa.w"

LTRV_has_Soft_Error(ltrv)= 0;
/*:987*//*990:*/
#line 11734 "./marpa.w"

R_of_LTRV(ltrv)= r;

/*:990*//*1000:*/
#line 11803 "./marpa.w"

ltrv->t_ref_count= 1;
/*:1000*/
#line 11750 "./marpa.w"

recce_ref(r);
LIM_of_LTRV(ltrv)= lim;
return ltrv;
}

/*:993*//*994:*/
#line 11757 "./marpa.w"

Marpa_LTraverser marpa_ltrv_predecessor(Marpa_LTraverser ltrv)
{
/*1315:*/
#line 15686 "./marpa.w"
void*const failure_indicator= NULL;
/*:1315*/
#line 11760 "./marpa.w"

/*991:*/
#line 11737 "./marpa.w"

const RECCE r UNUSED= R_of_LTRV(ltrv);
const GRAMMAR g UNUSED= G_of_R(r);

/*:991*/
#line 11761 "./marpa.w"

LIM predecessor;
/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 11763 "./marpa.w"

LTRV_has_Soft_Error(ltrv)= 0;
predecessor= Predecessor_LIM_of_LIM(LIM_of_LTRV(ltrv));
if(!predecessor){
LTRV_has_Soft_Error(ltrv)= 1;
return NULL;
}
return ltrv_new(r,predecessor);
}

/*:994*//*996:*/
#line 11775 "./marpa.w"

Marpa_Rule_ID
marpa_ltrv_trailhead_eim(Marpa_LTraverser ltrv,int*p_dot,Marpa_Earley_Set_ID*p_origin)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 11779 "./marpa.w"

/*991:*/
#line 11737 "./marpa.w"

const RECCE r UNUSED= R_of_LTRV(ltrv);
const GRAMMAR g UNUSED= G_of_R(r);

/*:991*/
#line 11780 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 11781 "./marpa.w"

{
const LIM lim= LIM_of_LTRV(ltrv);
const AHM ahm= Trailhead_AHM_of_LIM(lim);
const YIM yim= Trailhead_YIM_of_LIM(lim);
const IRL xrl= IRL_of_AHM(ahm);
if(xrl){
if(p_dot)
*p_dot= IRL_Position_of_AHM(ahm);
if(p_origin)
*p_origin= Origin_Ord_of_YIM(yim);
return ID_of_IRL(xrl);
}
}
return-1;
}

/*:996*//*1001:*/
#line 11806 "./marpa.w"

PRIVATE void
ltraverser_unref(LTRAVERSER ltrv)
{
MARPA_ASSERT(ltrv->t_ref_count> 0)
ltrv->t_ref_count--;
if(ltrv->t_ref_count<=0)
{
ltraverser_free(ltrv);
}
}
void
marpa_ltrv_unref(Marpa_LTraverser ltrv)
{
ltraverser_unref(ltrv);
}

/*:1001*//*1002:*/
#line 11824 "./marpa.w"

PRIVATE LTRAVERSER
ltraverser_ref(LTRAVERSER ltrv)
{
MARPA_ASSERT(ltrv->t_ref_count> 0)
ltrv->t_ref_count++;
return ltrv;
}
Marpa_LTraverser
marpa_ltrv_ref(Marpa_LTraverser ltrv)
{
return ltraverser_ref(ltrv);
}

/*:1002*//*1004:*/
#line 11841 "./marpa.w"

PRIVATE void
ltraverser_free(LTRAVERSER ltrv)
{
/*991:*/
#line 11737 "./marpa.w"

const RECCE r UNUSED= R_of_LTRV(ltrv);
const GRAMMAR g UNUSED= G_of_R(r);

/*:991*/
#line 11845 "./marpa.w"

if(ltrv)
{
/*984:*/
#line 11715 "./marpa.w"

{
recce_unref(R_of_LTRV(ltrv));
}

/*:984*/
#line 11848 "./marpa.w"
;
}
my_free(ltrv);
}

/*:1004*//*1014:*/
#line 11892 "./marpa.w"

int marpa_ptrv_soft_error(Marpa_PTraverser ptrv)
{
return PTRV_has_Soft_Error(ptrv);
}

/*:1014*//*1019:*/
#line 11913 "./marpa.w"

PRIVATE Marpa_PTraverser
ptrv_new(RECCE r,YS ys,NSYID nsyid)
{
PTRAVERSER ptrv;
const PIM pim= First_PIM_of_YS_by_NSYID(ys,nsyid);

if(!pim)return NULL;
ptrv= my_malloc(sizeof(*ptrv));
/*1013:*/
#line 11890 "./marpa.w"

PTRV_has_Soft_Error(ptrv)= 0;
/*:1013*//*1016:*/
#line 11901 "./marpa.w"

R_of_PTRV(ptrv)= r;

/*:1016*//*1027:*/
#line 12057 "./marpa.w"

ptrv->t_ref_count= 1;
/*:1027*/
#line 11922 "./marpa.w"

recce_ref(r);
PIM_of_PTRV(ptrv)= pim;
PTRV_is_Trivial(ptrv)= 0;
YS_of_PTRV(ptrv)= ys;
return ptrv;
}

/*:1019*//*1020:*/
#line 11934 "./marpa.w"

Marpa_PTraverser marpa_ptrv_new(Marpa_Recognizer r,
Marpa_Earley_Set_ID es_arg,
Marpa_NSY_ID nsyid
)
{
/*1315:*/
#line 15686 "./marpa.w"
void*const failure_indicator= NULL;
/*:1315*/
#line 11940 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 11942 "./marpa.w"


if(_MARPA_UNLIKELY(es_arg<=-2))
{
MARPA_ERROR(MARPA_ERR_INVALID_LOCATION);
return failure_indicator;
}
if(_MARPA_UNLIKELY(nsyid<0))
{
MARPA_ERROR(MARPA_ERR_YIM_ID_INVALID);
return failure_indicator;
}

/*1333:*/
#line 15798 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1333*/
#line 11955 "./marpa.w"


if(G_is_Trivial(g)){
if(es_arg> 0){
MARPA_ERROR(MARPA_ERR_INVALID_LOCATION);
return failure_indicator;
}
return NULL;
}

r_update_earley_sets(r);

{
YS ys;

if(es_arg==-1)
{
ys= YS_at_Current_Earleme_of_R(r);
}
else
{
if(!YS_Ord_is_Valid(r,es_arg))
{
MARPA_ERROR(MARPA_ERR_INVALID_LOCATION);
return failure_indicator;
}
ys= YS_of_R_by_Ord(r,es_arg);
}

return ptrv_new(r,ys,nsyid);
}
}

/*:1020*//*1021:*/
#line 11989 "./marpa.w"

int marpa_ptrv_at_lim(Marpa_PTraverser ptrv)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 11992 "./marpa.w"

/*1017:*/
#line 11904 "./marpa.w"

const RECCE r UNUSED= R_of_PTRV(ptrv);
const GRAMMAR g UNUSED= G_of_R(r);

/*:1017*/
#line 11993 "./marpa.w"

PIM pim;
/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 11995 "./marpa.w"


if(G_is_Trivial(g))return 0;
pim= PIM_of_PTRV(ptrv);
if(!pim)return 0;
return PIM_is_LIM(pim);
}

/*:1021*//*1022:*/
#line 12004 "./marpa.w"

int marpa_ptrv_at_eim(Marpa_PTraverser ptrv)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 12007 "./marpa.w"

/*1017:*/
#line 11904 "./marpa.w"

const RECCE r UNUSED= R_of_PTRV(ptrv);
const GRAMMAR g UNUSED= G_of_R(r);

/*:1017*/
#line 12008 "./marpa.w"

PIM pim;
/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 12010 "./marpa.w"


if(G_is_Trivial(g))return 0;
pim= PIM_of_PTRV(ptrv);
if(!pim)return 0;
return!PIM_is_LIM(pim);
}

/*:1022*//*1024:*/
#line 12023 "./marpa.w"

Marpa_Traverser marpa_ptrv_eim_iter(Marpa_PTraverser ptrv)
{
/*1315:*/
#line 15686 "./marpa.w"
void*const failure_indicator= NULL;
/*:1315*/
#line 12026 "./marpa.w"

/*1017:*/
#line 11904 "./marpa.w"

const RECCE r UNUSED= R_of_PTRV(ptrv);
const GRAMMAR g UNUSED= G_of_R(r);

/*:1017*/
#line 12027 "./marpa.w"

PIM pim;
YIM yim;
/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 12030 "./marpa.w"

PTRV_has_Soft_Error(ptrv)= 0;

if(G_is_Trivial(g)){
PTRV_has_Soft_Error(ptrv)= 1;
MARPA_ERROR(MARPA_ERR_GRAMMAR_IS_TRIVIAL);
return NULL;
}
pim= PIM_of_PTRV(ptrv);
if(!pim){
MARPA_ERROR(MARPA_ERR_NO_TRACE_PIM);
PTRV_has_Soft_Error(ptrv)= 1;
return NULL;
}
if(PIM_is_LIM(pim)){
MARPA_ERROR(MARPA_ERR_NO_TRACE_YIM);
PTRV_has_Soft_Error(ptrv)= 1;
return NULL;
}
yim= YIM_of_PIM(pim);
PIM_of_PTRV(ptrv)= Next_PIM_of_PIM(pim);
return trv_new(r,yim);
}

/*:1024*//*1028:*/
#line 12060 "./marpa.w"

PRIVATE void
ptraverser_unref(PTRAVERSER ptrv)
{
MARPA_ASSERT(ptrv->t_ref_count> 0)
ptrv->t_ref_count--;
if(ptrv->t_ref_count<=0)
{
ptraverser_free(ptrv);
}
}
void
marpa_ptrv_unref(Marpa_PTraverser ptrv)
{
ptraverser_unref(ptrv);
}

/*:1028*//*1029:*/
#line 12078 "./marpa.w"

PRIVATE PTRAVERSER
ptraverser_ref(PTRAVERSER ptrv)
{
MARPA_ASSERT(ptrv->t_ref_count> 0)
ptrv->t_ref_count++;
return ptrv;
}
Marpa_PTraverser
marpa_ptrv_ref(Marpa_PTraverser ptrv)
{
return ptraverser_ref(ptrv);
}

/*:1029*//*1031:*/
#line 12096 "./marpa.w"

PRIVATE void
ptraverser_free(PTRAVERSER ptrv)
{
/*1017:*/
#line 11904 "./marpa.w"

const RECCE r UNUSED= R_of_PTRV(ptrv);
const GRAMMAR g UNUSED= G_of_R(r);

/*:1017*/
#line 12100 "./marpa.w"

if(ptrv)
{
/*1010:*/
#line 11882 "./marpa.w"

{
recce_unref(R_of_PTRV(ptrv));
}

/*:1010*/
#line 12103 "./marpa.w"
;
}
my_free(ptrv);
}

/*:1031*//*1035:*/
#line 12118 "./marpa.w"

int marpa_ptrv_is_trivial(Marpa_PTraverser ptrv)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 12121 "./marpa.w"

/*1017:*/
#line 11904 "./marpa.w"

const RECCE r UNUSED= R_of_PTRV(ptrv);
const GRAMMAR g UNUSED= G_of_R(r);

/*:1017*/
#line 12122 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 12123 "./marpa.w"

return PTRV_is_Trivial(ptrv);
}








/*:1035*//*1050:*/
#line 12210 "./marpa.w"

Marpa_Bocage marpa_b_new(Marpa_Recognizer r,
Marpa_Earley_Set_ID ordinal_arg)
{
/*1315:*/
#line 15686 "./marpa.w"
void*const failure_indicator= NULL;
/*:1315*/
#line 12214 "./marpa.w"

/*1053:*/
#line 12281 "./marpa.w"

const GRAMMAR g= G_of_R(r);
const int isy_count= ISY_Count_of_G(g);
BOCAGE b= NULL;
YS end_of_parse_earley_set;
JEARLEME end_of_parse_earleme;
YIM start_yim= NULL;
struct marpa_obstack*bocage_setup_obs= NULL;
int count_of_earley_items_in_parse;
const int earley_set_count_of_r= YS_Count_of_R(r);

/*:1053*//*1056:*/
#line 12304 "./marpa.w"

struct s_bocage_setup_per_ys*per_ys_data= NULL;

/*:1056*/
#line 12215 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 12216 "./marpa.w"

if(_MARPA_UNLIKELY(ordinal_arg<=-2))
{
MARPA_ERROR(MARPA_ERR_INVALID_LOCATION);
return failure_indicator;
}

/*1333:*/
#line 15798 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1333*/
#line 12223 "./marpa.w"

{
struct marpa_obstack*const obstack= marpa_obs_init;
b= marpa_obs_new(obstack,struct marpa_bocage,1);
OBS_of_B(b)= obstack;
}
/*1042:*/
#line 12167 "./marpa.w"

ORs_of_B(b)= NULL;
OR_Count_of_B(b)= 0;
ANDs_of_B(b)= NULL;
AND_Count_of_B(b)= 0;
Top_ORID_of_B(b)= -1;

/*:1042*//*1045:*/
#line 12190 "./marpa.w"

{
G_of_B(b)= G_of_R(r);
grammar_ref(g);
}

/*:1045*//*1052:*/
#line 12276 "./marpa.w"

Valued_BV_of_B(b)= lbv_clone(b->t_obs,r->t_valued,isy_count);
Valued_Locked_BV_of_B(b)= 
lbv_clone(b->t_obs,r->t_valued_locked,isy_count);

/*:1052*//*1066:*/
#line 12421 "./marpa.w"

Ambiguity_Metric_of_B(b)= 1;

/*:1066*//*1070:*/
#line 12435 "./marpa.w"

b->t_ref_count= 1;
/*:1070*//*1077:*/
#line 12493 "./marpa.w"

B_is_Nulling(b)= 0;
/*:1077*/
#line 12229 "./marpa.w"


if(G_is_Trivial(g)){
switch(ordinal_arg){
default:goto NO_PARSE;
case 0:case-1:break;
}
B_is_Nulling(b)= 1;
return b;
}
r_update_earley_sets(r);
/*1057:*/
#line 12307 "./marpa.w"

{
if(ordinal_arg==-1)
{
end_of_parse_earley_set= YS_at_Current_Earleme_of_R(r);
}
else
{
if(!YS_Ord_is_Valid(r,ordinal_arg))
{
MARPA_ERROR(MARPA_ERR_INVALID_LOCATION);
return failure_indicator;
}
end_of_parse_earley_set= YS_of_R_by_Ord(r,ordinal_arg);
}

if(!end_of_parse_earley_set)
goto NO_PARSE;
end_of_parse_earleme= Earleme_of_YS(end_of_parse_earley_set);
}

/*:1057*/
#line 12240 "./marpa.w"

if(end_of_parse_earleme==0)
{
if(!ISY_is_Nullable(ISY_by_ID(g->t_start_isy_id)))
goto NO_PARSE;
B_is_Nulling(b)= 1;
return b;
}
/*1060:*/
#line 12373 "./marpa.w"

{
int yim_ix;
YIM*const earley_items= YIMs_of_YS(end_of_parse_earley_set);
const NRL start_nrl= g->t_start_nrl;
const NRLID sought_nrl_id= ID_of_NRL(start_nrl);
const int earley_item_count= YIM_Count_of_YS(end_of_parse_earley_set);
for(yim_ix= 0;yim_ix<earley_item_count;yim_ix++){
const YIM earley_item= earley_items[yim_ix];
if(Origin_Earleme_of_YIM(earley_item)> 0)continue;
if(YIM_was_Predicted(earley_item))continue;
{
const AHM ahm= AHM_of_YIM(earley_item);
if(NRLID_of_AHM(ahm)==sought_nrl_id){
start_yim= earley_item;
break;
}
}
}
}

/*:1060*/
#line 12248 "./marpa.w"

if(!start_yim)goto NO_PARSE;
bocage_setup_obs= marpa_obs_init;
/*1058:*/
#line 12329 "./marpa.w"

{
int earley_set_ordinal;
int earley_set_count= YS_Count_of_R(r);
count_of_earley_items_in_parse= 0;
per_ys_data= marpa_obs_new(
bocage_setup_obs,struct s_bocage_setup_per_ys,earley_set_count);
for(earley_set_ordinal= 0;earley_set_ordinal<earley_set_count;
earley_set_ordinal++)
{
const YS_Const earley_set= YS_of_R_by_Ord(r,earley_set_ordinal);
const int item_count= YIM_Count_of_YS(earley_set);
count_of_earley_items_in_parse+= item_count;
{
int item_ordinal;
struct s_bocage_setup_per_ys*per_ys= per_ys_data+earley_set_ordinal;
per_ys->t_or_node_by_item= 
marpa_obs_new(bocage_setup_obs,OR,item_count);
per_ys->t_or_psl= NULL;
per_ys->t_and_psl= NULL;
for(item_ordinal= 0;item_ordinal<item_count;item_ordinal++)
{
OR_by_PSI(per_ys_data,earley_set_ordinal,item_ordinal)= NULL;
}
}
}
}

/*:1058*/
#line 12251 "./marpa.w"

/*871:*/
#line 10139 "./marpa.w"

{
UR_Const ur_node;
const URS ur_node_stack= URS_of_R(r);
ur_node_stack_reset(ur_node_stack);


push_ur_if_new(per_ys_data,ur_node_stack,start_yim);
while((ur_node= ur_node_pop(ur_node_stack)))
{

const YIM parent_earley_item= YIM_of_UR(ur_node);
MARPA_ASSERT(!YIM_was_Predicted(parent_earley_item))
/*874:*/
#line 10192 "./marpa.w"

{
SRCL source_link;
for(source_link= First_Token_SRCL_of_YIM(parent_earley_item);
source_link;source_link= Next_SRCL_of_SRCL(source_link))
{
YIM predecessor_earley_item;
if(!SRCL_is_Active(source_link))continue;
predecessor_earley_item= Predecessor_of_SRCL(source_link);
if(!predecessor_earley_item)continue;
if(YIM_was_Predicted(predecessor_earley_item))
{
Set_boolean_in_PSI_for_initial_nulls(per_ys_data,
predecessor_earley_item);
continue;
}
push_ur_if_new(per_ys_data,ur_node_stack,predecessor_earley_item);
}
}

/*:874*/
#line 10152 "./marpa.w"

/*876:*/
#line 10226 "./marpa.w"

{
SRCL source_link;
for(source_link= First_Completion_SRCL_of_YIM(parent_earley_item);
source_link;source_link= Next_SRCL_of_SRCL(source_link))
{
YIM predecessor_earley_item;
YIM cause_earley_item;
if(!SRCL_is_Active(source_link))continue;
cause_earley_item= Cause_of_SRCL(source_link);
push_ur_if_new(per_ys_data,ur_node_stack,cause_earley_item);
predecessor_earley_item= Predecessor_of_SRCL(source_link);
if(!predecessor_earley_item)continue;
if(YIM_was_Predicted(predecessor_earley_item))
{
Set_boolean_in_PSI_for_initial_nulls(per_ys_data,
predecessor_earley_item);
continue;
}
push_ur_if_new(per_ys_data,ur_node_stack,predecessor_earley_item);
}
}

/*:876*/
#line 10153 "./marpa.w"

/*877:*/
#line 10249 "./marpa.w"

{
SRCL source_link;

for(source_link= First_Leo_SRCL_of_YIM(parent_earley_item);
source_link;source_link= Next_SRCL_of_SRCL(source_link))
{
LIM leo_predecessor;
YIM cause_earley_item;



if(!SRCL_is_Active(source_link))
continue;
cause_earley_item= Cause_of_SRCL(source_link);
push_ur_if_new(per_ys_data,ur_node_stack,cause_earley_item);
for(leo_predecessor= LIM_of_SRCL(source_link);leo_predecessor;

leo_predecessor= Predecessor_LIM_of_LIM(leo_predecessor))
{
const YIM leo_base_yim= Trailhead_YIM_of_LIM(leo_predecessor);
if(YIM_was_Predicted(leo_base_yim))
{
Set_boolean_in_PSI_for_initial_nulls(per_ys_data,
leo_base_yim);
}
else
{
push_ur_if_new(per_ys_data,ur_node_stack,leo_base_yim);
}
}
}
}

/*:877*/
#line 10154 "./marpa.w"

}
}

/*:871*/
#line 12252 "./marpa.w"

/*889:*/
#line 10376 "./marpa.w"

{
PSAR_Object or_per_ys_arena;
const PSAR or_psar= &or_per_ys_arena;
int work_earley_set_ordinal;
OR_Capacity_of_B(b)= count_of_earley_items_in_parse;
ORs_of_B(b)= marpa_new(OR,OR_Capacity_of_B(b));
psar_init(or_psar,SYMI_Count_of_G(g));
for(work_earley_set_ordinal= 0;
work_earley_set_ordinal<earley_set_count_of_r;
work_earley_set_ordinal++)
{
const YS_Const earley_set= YS_of_R_by_Ord(r,work_earley_set_ordinal);
YIM*const yims_of_ys= YIMs_of_YS(earley_set);
const int item_count= YIM_Count_of_YS(earley_set);
PSL this_earley_set_psl;
psar_dealloc(or_psar);
this_earley_set_psl
= psl_claim_by_es(or_psar,per_ys_data,work_earley_set_ordinal);
/*890:*/
#line 10402 "./marpa.w"

{
int item_ordinal;
for(item_ordinal= 0;item_ordinal<item_count;
item_ordinal++)
{
if(OR_by_PSI(per_ys_data,work_earley_set_ordinal,item_ordinal))
{
const YIM work_earley_item= yims_of_ys[item_ordinal];
{
/*891:*/
#line 10418 "./marpa.w"

{
AHM ahm= AHM_of_YIM(work_earley_item);
const int working_ys_ordinal= YS_Ord_of_YIM(work_earley_item);
const int working_yim_ordinal= Ord_of_YIM(work_earley_item);
const int work_origin_ordinal= 
Ord_of_YS(Origin_of_YIM(work_earley_item));
SYMI ahm_symbol_instance;
OR psi_or_node= NULL;
ahm_symbol_instance= SYMI_of_AHM(ahm);
{
PSL or_psl= psl_claim_by_es(or_psar,per_ys_data,work_origin_ordinal);
OR last_or_node= NULL;
/*893:*/
#line 10452 "./marpa.w"

{
if(ahm_symbol_instance>=0)
{
OR or_node;
MARPA_ASSERT(ahm_symbol_instance<SYMI_Count_of_G(g))
or_node= PSL_Datum(or_psl,ahm_symbol_instance);
if(!or_node||YS_Ord_of_OR(or_node)!=work_earley_set_ordinal)
{
const NRL nrl= NRL_of_AHM(ahm);
or_node= last_or_node= or_node_new(b);
PSL_Datum(or_psl,ahm_symbol_instance)= last_or_node;
Origin_Ord_of_OR(or_node)= Origin_Ord_of_YIM(work_earley_item);
YS_Ord_of_OR(or_node)= work_earley_set_ordinal;
NRL_of_OR(or_node)= nrl;
Position_of_OR(or_node)= 
ahm_symbol_instance-SYMI_of_NRL(nrl)+1;
}
psi_or_node= or_node;
}
}

/*:893*/
#line 10431 "./marpa.w"

/*896:*/
#line 10500 "./marpa.w"

{
const int null_count= Null_Count_of_AHM(ahm);
if(null_count> 0)
{
const NRL nrl= NRL_of_AHM(ahm);
const int symbol_instance_of_rule= SYMI_of_NRL(nrl);
const int first_null_symbol_instance= 
ahm_symbol_instance<
0?symbol_instance_of_rule:ahm_symbol_instance+1;
int i;
for(i= 0;i<null_count;i++)
{
const int symbol_instance= first_null_symbol_instance+i;
OR or_node= PSL_Datum(or_psl,symbol_instance);
if(!or_node||YS_Ord_of_OR(or_node)!=work_earley_set_ordinal){
const int rhs_ix= symbol_instance-symbol_instance_of_rule;
const OR predecessor= rhs_ix?last_or_node:NULL;
const OR cause= Nulling_OR_by_NSYID(RHSID_of_NRL(nrl,rhs_ix));
or_node= PSL_Datum(or_psl,symbol_instance)
= last_or_node= or_node_new(b);
Origin_Ord_of_OR(or_node)= work_origin_ordinal;
YS_Ord_of_OR(or_node)= work_earley_set_ordinal;
NRL_of_OR(or_node)= nrl;
Position_of_OR(or_node)= rhs_ix+1;
MARPA_ASSERT(Position_of_OR(or_node)<=1||predecessor);
draft_and_node_add(bocage_setup_obs,or_node,predecessor,
cause);
}
psi_or_node= or_node;
}
}
}

/*:896*/
#line 10432 "./marpa.w"

}



MARPA_OFF_ASSERT(psi_or_node)




OR_by_PSI(per_ys_data,working_ys_ordinal,working_yim_ordinal)
= psi_or_node;
/*897:*/
#line 10535 "./marpa.w"

{
SRCL source_link;
for(source_link= First_Leo_SRCL_of_YIM(work_earley_item);
source_link;source_link= Next_SRCL_of_SRCL(source_link))
{
LIM leo_predecessor= LIM_of_SRCL(source_link);
if(leo_predecessor){
/*898:*/
#line 10552 "./marpa.w"

{
LIM this_leo_item= leo_predecessor;
LIM previous_leo_item= this_leo_item;
while((this_leo_item= Predecessor_LIM_of_LIM(this_leo_item)))
{
const int ordinal_of_set_of_this_leo_item= Ord_of_YS(YS_of_LIM(this_leo_item));
const AHM path_ahm= Trailhead_AHM_of_LIM(previous_leo_item);
const NRL path_nrl= NRL_of_AHM(path_ahm);
const int symbol_instance_of_path_ahm= SYMI_of_AHM(path_ahm);
{
OR last_or_node= NULL;
/*899:*/
#line 10574 "./marpa.w"

{
{
OR or_node;
PSL leo_psl
= psl_claim_by_es(or_psar,per_ys_data,ordinal_of_set_of_this_leo_item);
or_node= PSL_Datum(leo_psl,symbol_instance_of_path_ahm);
if(!or_node||YS_Ord_of_OR(or_node)!=work_earley_set_ordinal)
{
last_or_node= or_node_new(b);
PSL_Datum(leo_psl,symbol_instance_of_path_ahm)= or_node= 
last_or_node;
Origin_Ord_of_OR(or_node)= ordinal_of_set_of_this_leo_item;
YS_Ord_of_OR(or_node)= work_earley_set_ordinal;
NRL_of_OR(or_node)= path_nrl;
Position_of_OR(or_node)= 
symbol_instance_of_path_ahm-SYMI_of_NRL(path_nrl)+1;
}
}
}

/*:899*/
#line 10564 "./marpa.w"

/*900:*/
#line 10599 "./marpa.w"

{
int i;
const int null_count= Null_Count_of_AHM(path_ahm);
for(i= 1;i<=null_count;i++)
{
const int symbol_instance= symbol_instance_of_path_ahm+i;
OR or_node= PSL_Datum(this_earley_set_psl,symbol_instance);
MARPA_ASSERT(symbol_instance<SYMI_Count_of_G(g))
if(!or_node||YS_Ord_of_OR(or_node)!=work_earley_set_ordinal)
{
const int rhs_ix= symbol_instance-SYMI_of_NRL(path_nrl);
MARPA_ASSERT(rhs_ix<Length_of_NRL(path_nrl))
const OR predecessor= rhs_ix?last_or_node:NULL;
const OR cause= Nulling_OR_by_NSYID(RHSID_of_NRL(path_nrl,rhs_ix));
MARPA_ASSERT(symbol_instance<Length_of_NRL(path_nrl))
MARPA_ASSERT(symbol_instance>=0)
or_node= last_or_node= or_node_new(b);
PSL_Datum(this_earley_set_psl,symbol_instance)= or_node;
Origin_Ord_of_OR(or_node)= ordinal_of_set_of_this_leo_item;
YS_Ord_of_OR(or_node)= work_earley_set_ordinal;
NRL_of_OR(or_node)= path_nrl;
Position_of_OR(or_node)= rhs_ix+1;
MARPA_ASSERT(Position_of_OR(or_node)<=1||predecessor);
draft_and_node_add(bocage_setup_obs,or_node,predecessor,cause);
}
MARPA_ASSERT(Position_of_OR(or_node)<=
SYMI_of_NRL(path_nrl)+Length_of_NRL(path_nrl))
MARPA_ASSERT(Position_of_OR(or_node)>=SYMI_of_NRL(path_nrl))
}
}

/*:900*/
#line 10565 "./marpa.w"

}
previous_leo_item= this_leo_item;
}
}

/*:898*/
#line 10543 "./marpa.w"

}
}
}

/*:897*/
#line 10444 "./marpa.w"

}

/*:891*/
#line 10412 "./marpa.w"

}
}
}
}

/*:890*/
#line 10395 "./marpa.w"

/*906:*/
#line 10695 "./marpa.w"

{
int item_ordinal;
for(item_ordinal= 0;item_ordinal<item_count;item_ordinal++)
{
OR or_node= OR_by_PSI(per_ys_data,work_earley_set_ordinal,item_ordinal);
const YIM work_earley_item= yims_of_ys[item_ordinal];
const int work_origin_ordinal= Ord_of_YS(Origin_of_YIM(work_earley_item));
/*907:*/
#line 10712 "./marpa.w"

{
while(or_node){
DAND draft_and_node= DANDs_of_OR(or_node);
OR predecessor_or;
if(!draft_and_node)break;
predecessor_or= Predecessor_OR_of_DAND(draft_and_node);
if(predecessor_or&&
YS_Ord_of_OR(predecessor_or)!=work_earley_set_ordinal)
break;
or_node= predecessor_or;
}
}

/*:907*/
#line 10703 "./marpa.w"

if(or_node){
/*908:*/
#line 10726 "./marpa.w"

{
const AHM work_ahm= AHM_of_YIM(work_earley_item);
MARPA_ASSERT(work_ahm>=AHM_by_ID(1))
const int work_symbol_instance= SYMI_of_AHM(work_ahm);
const OR work_proper_or_node= or_by_origin_and_symi(per_ys_data,
work_origin_ordinal,work_symbol_instance);
/*910:*/
#line 10768 "./marpa.w"

{
SRCL source_link;
for(source_link= First_Leo_SRCL_of_YIM(work_earley_item);
source_link;source_link= Next_SRCL_of_SRCL(source_link))
{
YIM cause_earley_item;
LIM leo_predecessor;



if(!SRCL_is_Active(source_link))continue;
cause_earley_item= Cause_of_SRCL(source_link);
leo_predecessor= LIM_of_SRCL(source_link);
if(leo_predecessor){
/*911:*/
#line 10789 "./marpa.w"

{

NRL path_nrl= NULL;

NRL previous_path_nrl;
LIM path_leo_item= leo_predecessor;
LIM higher_path_leo_item= Predecessor_LIM_of_LIM(path_leo_item);
OR dand_predecessor;
OR path_or_node;
YIM base_earley_item= Trailhead_YIM_of_LIM(path_leo_item);
dand_predecessor= set_or_from_yim(per_ys_data,base_earley_item);
/*912:*/
#line 10816 "./marpa.w"

{
if(higher_path_leo_item){
/*921:*/
#line 10944 "./marpa.w"

{
int symbol_instance;
const int origin_ordinal= Origin_Ord_of_YIM(base_earley_item);
const AHM ahm= AHM_of_YIM(base_earley_item);
path_nrl= NRL_of_AHM(ahm);
symbol_instance= Last_Proper_SYMI_of_NRL(path_nrl);
path_or_node= or_by_origin_and_symi(per_ys_data,origin_ordinal,symbol_instance);
}


/*:921*/
#line 10819 "./marpa.w"

}else{
path_or_node= work_proper_or_node;
}
}

/*:912*/
#line 10801 "./marpa.w"

/*914:*/
#line 10835 "./marpa.w"

{
const OR dand_cause
= set_or_from_yim(per_ys_data,cause_earley_item);
if(!dand_is_duplicate(path_or_node,dand_predecessor,dand_cause)){
draft_and_node_add(bocage_setup_obs,path_or_node,
dand_predecessor,dand_cause);
}
}

/*:914*/
#line 10802 "./marpa.w"

previous_path_nrl= path_nrl;
while(higher_path_leo_item){
path_leo_item= higher_path_leo_item;
higher_path_leo_item= Predecessor_LIM_of_LIM(path_leo_item);
base_earley_item= Trailhead_YIM_of_LIM(path_leo_item);
dand_predecessor
= set_or_from_yim(per_ys_data,base_earley_item);
/*912:*/
#line 10816 "./marpa.w"

{
if(higher_path_leo_item){
/*921:*/
#line 10944 "./marpa.w"

{
int symbol_instance;
const int origin_ordinal= Origin_Ord_of_YIM(base_earley_item);
const AHM ahm= AHM_of_YIM(base_earley_item);
path_nrl= NRL_of_AHM(ahm);
symbol_instance= Last_Proper_SYMI_of_NRL(path_nrl);
path_or_node= or_by_origin_and_symi(per_ys_data,origin_ordinal,symbol_instance);
}


/*:921*/
#line 10819 "./marpa.w"

}else{
path_or_node= work_proper_or_node;
}
}

/*:912*/
#line 10810 "./marpa.w"

/*917:*/
#line 10861 "./marpa.w"

{
const SYMI symbol_instance= SYMI_of_Completed_NRL(previous_path_nrl);
const int origin= Ord_of_YS(YS_of_LIM(path_leo_item));
const OR dand_cause= or_by_origin_and_symi(per_ys_data,origin,symbol_instance);
if(!dand_is_duplicate(path_or_node,dand_predecessor,dand_cause)){
draft_and_node_add(bocage_setup_obs,path_or_node,
dand_predecessor,dand_cause);
}
}

/*:917*/
#line 10811 "./marpa.w"

previous_path_nrl= path_nrl;
}
}

/*:911*/
#line 10783 "./marpa.w"

}
}
}

/*:910*/
#line 10733 "./marpa.w"

/*922:*/
#line 10959 "./marpa.w"

{
SRCL tkn_source_link;
for(tkn_source_link= First_Token_SRCL_of_YIM(work_earley_item);
tkn_source_link;tkn_source_link= Next_SRCL_of_SRCL(tkn_source_link))
{
OR new_token_or_node;
const NSYID token_nsyid= NSYID_of_SRCL(tkn_source_link);
const YIM predecessor_earley_item= Predecessor_of_SRCL(tkn_source_link);
const OR dand_predecessor= safe_or_from_yim(per_ys_data,
predecessor_earley_item);
if(NSYID_is_Valued_in_B(b,token_nsyid))
{



new_token_or_node= (OR)marpa_obs_new(OBS_of_B(b),OR_Object,1);
Type_of_OR(new_token_or_node)= VALUED_TOKEN_OR_NODE;
NSYID_of_OR(new_token_or_node)= token_nsyid;
Value_of_OR(new_token_or_node)= Value_of_SRCL(tkn_source_link);
}
else
{
new_token_or_node= Unvalued_OR_by_NSYID(token_nsyid);
}
draft_and_node_add(bocage_setup_obs,work_proper_or_node,
dand_predecessor,new_token_or_node);
}
}

/*:922*/
#line 10734 "./marpa.w"

/*924:*/
#line 11001 "./marpa.w"

{
SRCL source_link;
for(source_link= First_Completion_SRCL_of_YIM(work_earley_item);
source_link;source_link= Next_SRCL_of_SRCL(source_link))
{
YIM predecessor_earley_item= Predecessor_of_SRCL(source_link);
YIM cause_earley_item= Cause_of_SRCL(source_link);
const int middle_ordinal= Origin_Ord_of_YIM(cause_earley_item);
const AHM cause_ahm= AHM_of_YIM(cause_earley_item);
const SYMI cause_symbol_instance= 
SYMI_of_Completed_NRL(NRL_of_AHM(cause_ahm));
OR dand_predecessor= safe_or_from_yim(per_ys_data,
predecessor_earley_item);
const OR dand_cause= 
or_by_origin_and_symi(per_ys_data,middle_ordinal,
cause_symbol_instance);
draft_and_node_add(bocage_setup_obs,work_proper_or_node,
dand_predecessor,dand_cause);
}
}

/*:924*/
#line 10735 "./marpa.w"

}

/*:908*/
#line 10705 "./marpa.w"

}
}
}

/*:906*/
#line 10396 "./marpa.w"

}
psar_destroy(or_psar);
ORs_of_B(b)= marpa_renew(OR,ORs_of_B(b),OR_Count_of_B(b));
}

/*:889*/
#line 12253 "./marpa.w"

/*930:*/
#line 11073 "./marpa.w"

{
int unique_draft_and_node_count= 0;
/*925:*/
#line 11026 "./marpa.w"

{
const int or_node_count_of_b= OR_Count_of_B(b);
int or_node_id= 0;
while(or_node_id<or_node_count_of_b)
{
const OR work_or_node= OR_of_B_by_ID(b,or_node_id);
DAND dand= DANDs_of_OR(work_or_node);
while(dand)
{
unique_draft_and_node_count++;
dand= Next_DAND_of_DAND(dand);
}
or_node_id++;
}
}

/*:925*/
#line 11076 "./marpa.w"

/*931:*/
#line 11080 "./marpa.w"

{
const int or_count_of_b= OR_Count_of_B(b);
int or_node_id;
int and_node_id= 0;
const AND ands_of_b= ANDs_of_B(b)= 
marpa_new(AND_Object,unique_draft_and_node_count);
for(or_node_id= 0;or_node_id<or_count_of_b;or_node_id++)
{
int and_count_of_parent_or= 0;
const OR or_node= OR_of_B_by_ID(b,or_node_id);
DAND dand= DANDs_of_OR(or_node);
First_ANDID_of_OR(or_node)= and_node_id;
while(dand)
{
const OR cause_or_node= Cause_OR_of_DAND(dand);
const AND and_node= ands_of_b+and_node_id;
OR_of_AND(and_node)= or_node;
Predecessor_OR_of_AND(and_node)= Predecessor_OR_of_DAND(dand);
Cause_OR_of_AND(and_node)= cause_or_node;
and_node_id++;
and_count_of_parent_or++;
dand= Next_DAND_of_DAND(dand);
}
AND_Count_of_OR(or_node)= and_count_of_parent_or;
if(and_count_of_parent_or> 1)Ambiguity_Metric_of_B(b)= 2;
}
AND_Count_of_B(b)= and_node_id;
MARPA_ASSERT(and_node_id==unique_draft_and_node_count);
}

/*:931*/
#line 11077 "./marpa.w"

}

/*:930*/
#line 12254 "./marpa.w"

/*1061:*/
#line 12394 "./marpa.w"

{
const YSID end_of_parse_ordinal= Ord_of_YS(end_of_parse_earley_set);
const int start_earley_item_ordinal= Ord_of_YIM(start_yim);
const OR root_or_node= 
OR_by_PSI(per_ys_data,end_of_parse_ordinal,start_earley_item_ordinal);
Top_ORID_of_B(b)= ID_of_OR(root_or_node);
}

/*:1061*/
#line 12255 "./marpa.w"
;
marpa_obs_free(bocage_setup_obs);
return b;
NO_PARSE:;
MARPA_ERROR(MARPA_ERR_NO_PARSE);
if(b){
/*1073:*/
#line 12471 "./marpa.w"

/*1043:*/
#line 12174 "./marpa.w"

{
OR*or_nodes= ORs_of_B(b);
AND and_nodes= ANDs_of_B(b);

grammar_unref(G_of_B(b));
my_free(or_nodes);
ORs_of_B(b)= NULL;
my_free(and_nodes);
ANDs_of_B(b)= NULL;
}

/*:1043*/
#line 12472 "./marpa.w"
;
/*1049:*/
#line 12206 "./marpa.w"

marpa_obs_free(OBS_of_B(b));

/*:1049*/
#line 12473 "./marpa.w"
;

/*:1073*/
#line 12261 "./marpa.w"
;
}
return NULL;
}

/*:1050*//*1063:*/
#line 12405 "./marpa.w"

Marpa_Or_Node_ID _marpa_b_top_or_node(Marpa_Bocage b)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 12408 "./marpa.w"

/*1047:*/
#line 12198 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1047*/
#line 12409 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 12410 "./marpa.w"

return Top_ORID_of_B(b);
}

/*:1063*//*1067:*/
#line 12424 "./marpa.w"

int marpa_b_ambiguity_metric(Marpa_Bocage b)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 12427 "./marpa.w"

/*1047:*/
#line 12198 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1047*/
#line 12428 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 12429 "./marpa.w"

return Ambiguity_Metric_of_B(b);
}

/*:1067*//*1071:*/
#line 12438 "./marpa.w"

PRIVATE void
bocage_unref(BOCAGE b)
{
MARPA_ASSERT(b->t_ref_count> 0)
b->t_ref_count--;
if(b->t_ref_count<=0)
{
bocage_free(b);
}
}
void
marpa_b_unref(Marpa_Bocage b)
{
bocage_unref(b);
}

/*:1071*//*1072:*/
#line 12456 "./marpa.w"

PRIVATE BOCAGE
bocage_ref(BOCAGE b)
{
MARPA_ASSERT(b->t_ref_count> 0)
b->t_ref_count++;
return b;
}
Marpa_Bocage
marpa_b_ref(Marpa_Bocage b)
{
return bocage_ref(b);
}

/*:1072*//*1074:*/
#line 12477 "./marpa.w"

PRIVATE void
bocage_free(BOCAGE b)
{
/*1047:*/
#line 12198 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1047*/
#line 12481 "./marpa.w"

if(b)
{
/*1073:*/
#line 12471 "./marpa.w"

/*1043:*/
#line 12174 "./marpa.w"

{
OR*or_nodes= ORs_of_B(b);
AND and_nodes= ANDs_of_B(b);

grammar_unref(G_of_B(b));
my_free(or_nodes);
ORs_of_B(b)= NULL;
my_free(and_nodes);
ANDs_of_B(b)= NULL;
}

/*:1043*/
#line 12472 "./marpa.w"
;
/*1049:*/
#line 12206 "./marpa.w"

marpa_obs_free(OBS_of_B(b));

/*:1049*/
#line 12473 "./marpa.w"
;

/*:1073*/
#line 12484 "./marpa.w"
;
}
}

/*:1074*//*1078:*/
#line 12495 "./marpa.w"

int marpa_b_is_null(Marpa_Bocage b)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 12498 "./marpa.w"

/*1047:*/
#line 12198 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1047*/
#line 12499 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 12500 "./marpa.w"

return B_is_Nulling(b);
}

/*:1078*//*1085:*/
#line 12540 "./marpa.w"

Marpa_Order marpa_o_new(Marpa_Bocage b)
{
/*1315:*/
#line 15686 "./marpa.w"
void*const failure_indicator= NULL;
/*:1315*/
#line 12543 "./marpa.w"

/*1047:*/
#line 12198 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1047*/
#line 12544 "./marpa.w"

ORDER o;
/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 12546 "./marpa.w"

o= my_malloc(sizeof(*o));
B_of_O(o)= b;
bocage_ref(b);
/*1082:*/
#line 12528 "./marpa.w"

{
o->t_and_node_orderings= NULL;
o->t_is_frozen= 0;
OBS_of_O(o)= NULL;
}

/*:1082*//*1088:*/
#line 12558 "./marpa.w"

o->t_ref_count= 1;

/*:1088*//*1101:*/
#line 12726 "./marpa.w"

High_Rank_Count_of_O(o)= 1;
/*:1101*/
#line 12550 "./marpa.w"

O_is_Nulling(o)= B_is_Nulling(b);
Ambiguity_Metric_of_O(o)= -1;
return o;
}

/*:1085*//*1089:*/
#line 12562 "./marpa.w"

PRIVATE void
order_unref(ORDER o)
{
MARPA_ASSERT(o->t_ref_count> 0)
o->t_ref_count--;
if(o->t_ref_count<=0)
{
order_free(o);
}
}
void
marpa_o_unref(Marpa_Order o)
{
order_unref(o);
}

/*:1089*//*1090:*/
#line 12580 "./marpa.w"

PRIVATE ORDER
order_ref(ORDER o)
{
MARPA_ASSERT(o->t_ref_count> 0)
o->t_ref_count++;
return o;
}
Marpa_Order
marpa_o_ref(Marpa_Order o)
{
return order_ref(o);
}

/*:1090*//*1091:*/
#line 12594 "./marpa.w"

PRIVATE void order_free(ORDER o)
{
/*1092:*/
#line 12603 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1047:*/
#line 12198 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1047*/
#line 12605 "./marpa.w"


/*:1092*/
#line 12597 "./marpa.w"

bocage_unref(b);
marpa_obs_free(OBS_of_O(o));
my_free(o);
}

/*:1091*//*1095:*/
#line 12615 "./marpa.w"

int marpa_o_ambiguity_metric(Marpa_Order o)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 12618 "./marpa.w"

/*1092:*/
#line 12603 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1047:*/
#line 12198 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1047*/
#line 12605 "./marpa.w"


/*:1092*/
#line 12619 "./marpa.w"

const int old_ambiguity_metric_of_o
= Ambiguity_Metric_of_O(o);
const int ambiguity_metric_of_b
= (Ambiguity_Metric_of_B(b)<=1?1:2);
/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 12624 "./marpa.w"

O_is_Frozen(o)= 1;
if(old_ambiguity_metric_of_o>=0)
return old_ambiguity_metric_of_o;
if(ambiguity_metric_of_b<2
||O_is_Default(o)
||High_Rank_Count_of_O(o)<=0
){
Ambiguity_Metric_of_O(o)= ambiguity_metric_of_b;
return ambiguity_metric_of_b;
}
/*1096:*/
#line 12643 "./marpa.w"

{
ANDID**const and_node_orderings= o->t_and_node_orderings;
const AND and_nodes= ANDs_of_B(b);
ORID*top_of_stack;
const ORID root_or_id= Top_ORID_of_B(b);
FSTACK_DECLARE(or_node_stack,ORID)
const int or_count= OR_Count_of_B(b);
Bit_Vector bv_orid_was_stacked;
Ambiguity_Metric_of_O(o)= 1;


bv_orid_was_stacked= bv_create(or_count);
FSTACK_INIT(or_node_stack,ORID,or_count);
*(FSTACK_PUSH(or_node_stack))= root_or_id;
bv_bit_set(bv_orid_was_stacked,root_or_id);
while((top_of_stack= FSTACK_POP(or_node_stack)))
{
const ORID or_id= *top_of_stack;
const OR or_node= OR_of_B_by_ID(b,or_id);
ANDID*ordering= and_node_orderings[or_id];
int and_count= ordering?ordering[0]:AND_Count_of_OR(or_node);
if(and_count> 1)
{



Ambiguity_Metric_of_O(o)= 2;

goto END_OR_NODE_LOOP;

}
{
const ANDID and_id= ordering?ordering[1]:First_ANDID_of_OR(or_node);
const AND and_node= and_nodes+and_id;
const OR predecessor_or= Predecessor_OR_of_AND(and_node);
const OR cause_or= Cause_OR_of_AND(and_node);
if(predecessor_or)
{
const ORID predecessor_or_id= ID_of_OR(predecessor_or);
if(!bv_bit_test_then_set(bv_orid_was_stacked,predecessor_or_id))
{
*(FSTACK_PUSH(or_node_stack))= predecessor_or_id;
}
}
if(cause_or&&!OR_is_Token(cause_or))
{
const ORID cause_or_id= ID_of_OR(cause_or);
if(!bv_bit_test_then_set(bv_orid_was_stacked,cause_or_id))
{
*(FSTACK_PUSH(or_node_stack))= cause_or_id;
}
}
}
}
END_OR_NODE_LOOP:;
FSTACK_DESTROY(or_node_stack);
bv_free(bv_orid_was_stacked);

}

/*:1096*/
#line 12635 "./marpa.w"

return Ambiguity_Metric_of_O(o);
}

/*:1095*//*1099:*/
#line 12709 "./marpa.w"

int marpa_o_is_null(Marpa_Order o)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 12712 "./marpa.w"

/*1092:*/
#line 12603 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1047:*/
#line 12198 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1047*/
#line 12605 "./marpa.w"


/*:1092*/
#line 12713 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 12714 "./marpa.w"

return O_is_Nulling(o);
}

/*:1099*//*1102:*/
#line 12728 "./marpa.w"

int marpa_o_high_rank_only_set(
Marpa_Order o,
int count)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 12733 "./marpa.w"

/*1092:*/
#line 12603 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1047:*/
#line 12198 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1047*/
#line 12605 "./marpa.w"


/*:1092*/
#line 12734 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 12735 "./marpa.w"

if(O_is_Frozen(o))
{
MARPA_ERROR(MARPA_ERR_ORDER_FROZEN);
return failure_indicator;
}
if(_MARPA_UNLIKELY(count<0||count> 1))
{
MARPA_ERROR(MARPA_ERR_INVALID_BOOLEAN);
return failure_indicator;
}
return High_Rank_Count_of_O(o)= count;
}

/*:1102*//*1103:*/
#line 12750 "./marpa.w"

int marpa_o_high_rank_only(Marpa_Order o)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 12753 "./marpa.w"

/*1092:*/
#line 12603 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1047:*/
#line 12198 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1047*/
#line 12605 "./marpa.w"


/*:1092*/
#line 12754 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 12755 "./marpa.w"

return High_Rank_Count_of_O(o);
}

/*:1103*//*1107:*/
#line 12792 "./marpa.w"

int marpa_o_rank(Marpa_Order o)
{
ANDID**and_node_orderings;
struct marpa_obstack*obs;
int bocage_was_reordered= 0;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 12798 "./marpa.w"

/*1092:*/
#line 12603 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1047:*/
#line 12198 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1047*/
#line 12605 "./marpa.w"


/*:1092*/
#line 12799 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 12800 "./marpa.w"

if(O_is_Frozen(o))
{
MARPA_ERROR(MARPA_ERR_ORDER_FROZEN);
return failure_indicator;
}
/*1113:*/
#line 12961 "./marpa.w"

{
int and_id;
const int and_count_of_r= AND_Count_of_B(b);
obs= OBS_of_O(o)= marpa_obs_init;
o->t_and_node_orderings= 
and_node_orderings= 
marpa_obs_new(obs,ANDID*,and_count_of_r);
for(and_id= 0;and_id<and_count_of_r;and_id++)
{
and_node_orderings[and_id]= (ANDID*)NULL;
}
}

/*:1113*/
#line 12806 "./marpa.w"

if(High_Rank_Count_of_O(o)){
/*1108:*/
#line 12821 "./marpa.w"

{
const AND and_nodes= ANDs_of_B(b);
const int or_node_count_of_b= OR_Count_of_B(b);
int or_node_id= 0;

while(or_node_id<or_node_count_of_b)
{
const OR work_or_node= OR_of_B_by_ID(b,or_node_id);
const ANDID and_count_of_or= AND_Count_of_OR(work_or_node);
/*1109:*/
#line 12836 "./marpa.w"

{
if(and_count_of_or> 1)
{
int high_rank_so_far= INT_MIN;
const ANDID first_and_node_id= First_ANDID_of_OR(work_or_node);
const ANDID last_and_node_id= 
(first_and_node_id+and_count_of_or)-1;
ANDID*const order_base= 
marpa_obs_start(obs,
sizeof(ANDID)*((size_t)and_count_of_or+1),
ALIGNOF(ANDID));
ANDID*order= order_base+1;
ANDID and_node_id;
bocage_was_reordered= 1;
for(and_node_id= first_and_node_id;and_node_id<=last_and_node_id;
and_node_id++)
{
const AND and_node= and_nodes+and_node_id;
int and_node_rank;
/*1110:*/
#line 12874 "./marpa.w"

{
const OR cause_or= Cause_OR_of_AND(and_node);
if(OR_is_Token(cause_or)){
const NSYID nsy_id= NSYID_of_OR(cause_or);
and_node_rank= Rank_of_NSY(NSY_by_ID(nsy_id));
}else{
and_node_rank= Rank_of_NRL(NRL_of_OR(cause_or));
}
}

/*:1110*/
#line 12856 "./marpa.w"

if(and_node_rank> high_rank_so_far)
{
order= order_base+1;
high_rank_so_far= and_node_rank;
}
if(and_node_rank>=high_rank_so_far)
*order++= and_node_id;
}
{
int final_count= (int)(order-order_base)-1;
*order_base= final_count;
marpa_obs_confirm_fast(obs,(int)sizeof(ANDID)*(final_count+1));
and_node_orderings[or_node_id]= marpa_obs_finish(obs);
}
}
}

/*:1109*/
#line 12831 "./marpa.w"

or_node_id++;
}
}

/*:1108*/
#line 12808 "./marpa.w"

}else{
/*1111:*/
#line 12885 "./marpa.w"

{
const AND and_nodes= ANDs_of_B(b);
const int or_node_count_of_b= OR_Count_of_B(b);
const int and_node_count_of_b= AND_Count_of_B(b);
int or_node_id= 0;
int*rank_by_and_id= marpa_new(int,and_node_count_of_b);
int and_node_id;
for(and_node_id= 0;and_node_id<and_node_count_of_b;and_node_id++)
{
const AND and_node= and_nodes+and_node_id;
int and_node_rank;
/*1110:*/
#line 12874 "./marpa.w"

{
const OR cause_or= Cause_OR_of_AND(and_node);
if(OR_is_Token(cause_or)){
const NSYID nsy_id= NSYID_of_OR(cause_or);
and_node_rank= Rank_of_NSY(NSY_by_ID(nsy_id));
}else{
and_node_rank= Rank_of_NRL(NRL_of_OR(cause_or));
}
}

/*:1110*/
#line 12897 "./marpa.w"

rank_by_and_id[and_node_id]= and_node_rank;
}
while(or_node_id<or_node_count_of_b)
{
const OR work_or_node= OR_of_B_by_ID(b,or_node_id);
const ANDID and_count_of_or= AND_Count_of_OR(work_or_node);
/*1112:*/
#line 12930 "./marpa.w"

{
if(and_count_of_or> 1)
{
const ANDID first_and_node_id= First_ANDID_of_OR(work_or_node);
ANDID*const order_base= 
marpa_obs_new(obs,ANDID,and_count_of_or+1);
ANDID*order= order_base+1;
int nodes_inserted_so_far;
bocage_was_reordered= 1;
and_node_orderings[or_node_id]= order_base;
*order_base= and_count_of_or;
for(nodes_inserted_so_far= 0;nodes_inserted_so_far<and_count_of_or;
nodes_inserted_so_far++)
{
const ANDID new_and_node_id= 
first_and_node_id+nodes_inserted_so_far;
int pre_insertion_ix= nodes_inserted_so_far-1;
while(pre_insertion_ix>=0)
{
if(rank_by_and_id[new_and_node_id]<=
rank_by_and_id[order[pre_insertion_ix]])
break;
order[pre_insertion_ix+1]= order[pre_insertion_ix];
pre_insertion_ix--;
}
order[pre_insertion_ix+1]= new_and_node_id;
}
}
}

/*:1112*/
#line 12904 "./marpa.w"

or_node_id++;
}
my_free(rank_by_and_id);
}

/*:1111*/
#line 12810 "./marpa.w"

}
if(!bocage_was_reordered){
marpa_obs_free(obs);
OBS_of_O(o)= NULL;
o->t_and_node_orderings= NULL;
}
O_is_Frozen(o)= 1;
return 1;
}

/*:1107*//*1114:*/
#line 12978 "./marpa.w"

PRIVATE ANDID and_order_ix_is_valid(ORDER o,OR or_node,int ix)
{
if(ix>=AND_Count_of_OR(or_node))return 0;
if(!O_is_Default(o))
{
ANDID**const and_node_orderings= o->t_and_node_orderings;
ORID or_node_id= ID_of_OR(or_node);
ANDID*ordering= and_node_orderings[or_node_id];
if(ordering)
{
int length= ordering[0];
if(ix>=length)return 0;
}
}
return 1;
}

/*:1114*//*1115:*/
#line 12999 "./marpa.w"

PRIVATE ANDID and_order_get(ORDER o,OR or_node,int ix)
{
if(!O_is_Default(o))
{
ANDID**const and_node_orderings= o->t_and_node_orderings;
ORID or_node_id= ID_of_OR(or_node);
ANDID*ordering= and_node_orderings[or_node_id];
if(ordering)
return ordering[1+ix];
}
return First_ANDID_of_OR(or_node)+ix;
}

/*:1115*//*1116:*/
#line 13013 "./marpa.w"

Marpa_And_Node_ID _marpa_o_and_order_get(Marpa_Order o,
Marpa_Or_Node_ID or_node_id,int ix)
{
OR or_node;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 13018 "./marpa.w"

/*1092:*/
#line 12603 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1047:*/
#line 12198 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1047*/
#line 12605 "./marpa.w"


/*:1092*/
#line 13019 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 13020 "./marpa.w"

/*1403:*/
#line 16792 "./marpa.w"

{
if(_MARPA_UNLIKELY(or_node_id>=OR_Count_of_B(b)))
{
return-1;
}
if(_MARPA_UNLIKELY(or_node_id<0))
{
MARPA_ERROR(MARPA_ERR_ORID_NEGATIVE);
return failure_indicator;
}
}
/*:1403*/
#line 13021 "./marpa.w"

/*1404:*/
#line 16804 "./marpa.w"

{
if(_MARPA_UNLIKELY(!ORs_of_B(b)))
{
MARPA_ERROR(MARPA_ERR_NO_OR_NODES);
return failure_indicator;
}
or_node= OR_of_B_by_ID(b,or_node_id);
}

/*:1404*/
#line 13022 "./marpa.w"

if(ix<0){
MARPA_ERROR(MARPA_ERR_ANDIX_NEGATIVE);
return failure_indicator;
}
if(!and_order_ix_is_valid(o,or_node,ix))return-1;
return and_order_get(o,or_node,ix);
}

/*:1116*//*1121:*/
#line 13075 "./marpa.w"

PRIVATE void tree_exhaust(TREE t)
{
if(FSTACK_IS_INITIALIZED(t->t_nook_stack))
{
FSTACK_DESTROY(t->t_nook_stack);
FSTACK_SAFE(t->t_nook_stack);
}
if(FSTACK_IS_INITIALIZED(t->t_nook_worklist))
{
FSTACK_DESTROY(t->t_nook_worklist);
FSTACK_SAFE(t->t_nook_worklist);
}
bv_free(t->t_or_node_in_use);
t->t_or_node_in_use= NULL;
T_is_Exhausted(t)= 1;
}

/*:1121*//*1122:*/
#line 13093 "./marpa.w"

Marpa_Tree marpa_t_new(Marpa_Order o)
{
/*1315:*/
#line 15686 "./marpa.w"
void*const failure_indicator= NULL;
/*:1315*/
#line 13096 "./marpa.w"

TREE t;
/*1092:*/
#line 12603 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1047:*/
#line 12198 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1047*/
#line 12605 "./marpa.w"


/*:1092*/
#line 13098 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 13099 "./marpa.w"

t= my_malloc(sizeof(*t));
O_of_T(t)= o;
order_ref(o);
O_is_Frozen(o)= 1;
/*1135:*/
#line 13246 "./marpa.w"

T_is_Exhausted(t)= 0;

/*:1135*/
#line 13104 "./marpa.w"

/*1123:*/
#line 13109 "./marpa.w"

{
t->t_parse_count= 0;
if(O_is_Nulling(o))
{
T_is_Nulling(t)= 1;
t->t_or_node_in_use= NULL;
FSTACK_SAFE(t->t_nook_stack);
FSTACK_SAFE(t->t_nook_worklist);
}
else
{
const int and_count= AND_Count_of_B(b);
const int or_count= OR_Count_of_B(b);
T_is_Nulling(t)= 0;
t->t_or_node_in_use= bv_create(or_count);
FSTACK_INIT(t->t_nook_stack,NOOK_Object,and_count);
FSTACK_INIT(t->t_nook_worklist,int,and_count);
}
}

/*:1123*//*1126:*/
#line 13133 "./marpa.w"

t->t_ref_count= 1;

/*:1126*//*1131:*/
#line 13185 "./marpa.w"
t->t_generation= 0;

/*:1131*/
#line 13105 "./marpa.w"

return t;
}

/*:1122*//*1127:*/
#line 13137 "./marpa.w"

PRIVATE void
tree_unref(TREE t)
{
MARPA_ASSERT(t->t_ref_count> 0)
t->t_ref_count--;
if(t->t_ref_count<=0)
{
tree_free(t);
}
}
void
marpa_t_unref(Marpa_Tree t)
{
tree_unref(t);
}

/*:1127*//*1128:*/
#line 13155 "./marpa.w"

PRIVATE TREE
tree_ref(TREE t)
{
MARPA_ASSERT(t->t_ref_count> 0)
t->t_ref_count++;
return t;
}
Marpa_Tree
marpa_t_ref(Marpa_Tree t)
{
return tree_ref(t);
}

/*:1128*//*1129:*/
#line 13169 "./marpa.w"

PRIVATE void tree_free(TREE t)
{
order_unref(O_of_T(t));
tree_exhaust(t);
my_free(t);
}

/*:1129*//*1132:*/
#line 13188 "./marpa.w"

int marpa_t_next(Marpa_Tree t)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 13191 "./marpa.w"

const int termination_indicator= -1;
int is_first_tree_attempt= (t->t_parse_count<1);
/*1120:*/
#line 13071 "./marpa.w"

ORDER o= O_of_T(t);
/*1092:*/
#line 12603 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1047:*/
#line 12198 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1047*/
#line 12605 "./marpa.w"


/*:1092*/
#line 13073 "./marpa.w"
;

/*:1120*/
#line 13194 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 13195 "./marpa.w"

{
const unsigned int next_generation= T_Generation(t)+1;
if(next_generation> UINT_MAX-42)
{
MARPA_ERROR(MARPA_ERR_DEVELOPMENT);
return termination_indicator;
}
T_Generation(t)= next_generation;
}

if(T_is_Exhausted(t))
{
MARPA_ERROR(MARPA_ERR_TREE_EXHAUSTED);
return termination_indicator;
}

if(T_is_Nulling(t)){
if(is_first_tree_attempt){
t->t_parse_count++;
return 0;
}else{
goto TREE_IS_EXHAUSTED;
}
}

while(1){
const AND ands_of_b= ANDs_of_B(b);
if(is_first_tree_attempt){
is_first_tree_attempt= 0;
/*1141:*/
#line 13275 "./marpa.w"

{
ORID root_or_id= Top_ORID_of_B(b);
OR root_or_node= OR_of_B_by_ID(b,root_or_id);
NOOK nook;



const int choice= 0;
if(!and_order_ix_is_valid(o,root_or_node,choice))
goto TREE_IS_EXHAUSTED;
nook= FSTACK_PUSH(t->t_nook_stack);
tree_or_node_try(t,root_or_id);
OR_of_NOOK(nook)= root_or_node;
Choice_of_NOOK(nook)= choice;
Parent_of_NOOK(nook)= -1;
NOOK_Cause_is_Expanded(nook)= 0;
NOOK_is_Cause(nook)= 0;
NOOK_Predecessor_is_Expanded(nook)= 0;
NOOK_is_Predecessor(nook)= 0;
}

/*:1141*/
#line 13225 "./marpa.w"

}else{
/*1142:*/
#line 13300 "./marpa.w"
{
while(1){
OR iteration_candidate_or_node;
const NOOK iteration_candidate= FSTACK_TOP(t->t_nook_stack,NOOK_Object);
int choice;
if(!iteration_candidate)break;
iteration_candidate_or_node= OR_of_NOOK(iteration_candidate);
choice= Choice_of_NOOK(iteration_candidate)+1;
MARPA_ASSERT(choice> 0);
if(and_order_ix_is_valid(o,iteration_candidate_or_node,choice)){





Choice_of_NOOK(iteration_candidate)= choice;
NOOK_Cause_is_Expanded(iteration_candidate)= 0;
NOOK_Predecessor_is_Expanded(iteration_candidate)= 0;
break;
}
{


const int parent_nook_ix= Parent_of_NOOK(iteration_candidate);
if(parent_nook_ix>=0){
NOOK parent_nook= NOOK_of_TREE_by_IX(t,parent_nook_ix);
if(NOOK_is_Cause(iteration_candidate)){
NOOK_Cause_is_Expanded(parent_nook)= 0;
}
if(NOOK_is_Predecessor(iteration_candidate)){
NOOK_Predecessor_is_Expanded(parent_nook)= 0;
}
}


tree_or_node_release(t,ID_of_OR(iteration_candidate_or_node));
FSTACK_POP(t->t_nook_stack);
}
}
if(Size_of_T(t)<=0)goto TREE_IS_EXHAUSTED;
}

/*:1142*/
#line 13227 "./marpa.w"

}
/*1143:*/
#line 13342 "./marpa.w"
{
{
const int stack_length= Size_of_T(t);
int i;


FSTACK_CLEAR(t->t_nook_worklist);
for(i= 0;i<stack_length;i++){
*(FSTACK_PUSH(t->t_nook_worklist))= i;
}
}
while(1){
NOOKID*p_work_nook_id;
NOOK work_nook;
ANDID work_and_node_id;
AND work_and_node;
OR work_or_node;
OR child_or_node= NULL;
int choice;
int child_is_cause= 0;
int child_is_predecessor= 0;
if(FSTACK_LENGTH(t->t_nook_worklist)<=0){goto TREE_IS_FINISHED;}
p_work_nook_id= FSTACK_TOP(t->t_nook_worklist,NOOKID);
work_nook= NOOK_of_TREE_by_IX(t,*p_work_nook_id);
work_or_node= OR_of_NOOK(work_nook);
work_and_node_id= and_order_get(o,work_or_node,Choice_of_NOOK(work_nook));
work_and_node= ands_of_b+work_and_node_id;
do
{
if(!NOOK_Cause_is_Expanded(work_nook))
{
const OR cause_or_node= Cause_OR_of_AND(work_and_node);
if(!OR_is_Token(cause_or_node))
{
child_or_node= cause_or_node;
child_is_cause= 1;
break;
}
}
NOOK_Cause_is_Expanded(work_nook)= 1;
if(!NOOK_Predecessor_is_Expanded(work_nook))
{
child_or_node= Predecessor_OR_of_AND(work_and_node);
if(child_or_node)
{
child_is_predecessor= 1;
break;
}
}
NOOK_Predecessor_is_Expanded(work_nook)= 1;
FSTACK_POP(t->t_nook_worklist);
goto NEXT_NOOK_ON_WORKLIST;
}
while(0);
if(!tree_or_node_try(t,ID_of_OR(child_or_node)))goto NEXT_TREE;
choice= 0;
if(!and_order_ix_is_valid(o,child_or_node,choice))goto NEXT_TREE;
/*1144:*/
#line 13405 "./marpa.w"

{
NOOKID new_nook_id= Size_of_T(t);
NOOK new_nook= FSTACK_PUSH(t->t_nook_stack);
*(FSTACK_PUSH(t->t_nook_worklist))= new_nook_id;
Parent_of_NOOK(new_nook)= *p_work_nook_id;
Choice_of_NOOK(new_nook)= choice;
OR_of_NOOK(new_nook)= child_or_node;
NOOK_Cause_is_Expanded(new_nook)= 0;
if((NOOK_is_Cause(new_nook)= Boolean(child_is_cause)))
{
NOOK_Cause_is_Expanded(work_nook)= 1;
}
NOOK_Predecessor_is_Expanded(new_nook)= 0;
if((NOOK_is_Predecessor(new_nook)= Boolean(child_is_predecessor)))
{
NOOK_Predecessor_is_Expanded(work_nook)= 1;
}
}

/*:1144*/
#line 13399 "./marpa.w"
;
NEXT_NOOK_ON_WORKLIST:;
}
NEXT_TREE:;
}

/*:1143*/
#line 13229 "./marpa.w"

}
TREE_IS_FINISHED:;
t->t_parse_count++;
return FSTACK_LENGTH(t->t_nook_stack);
TREE_IS_EXHAUSTED:;
tree_exhaust(t);
MARPA_ERROR(MARPA_ERR_TREE_EXHAUSTED);
return termination_indicator;

}

/*:1132*//*1139:*/
#line 13262 "./marpa.w"

PRIVATE int tree_or_node_try(TREE tree,ORID or_node_id)
{
return!bv_bit_test_then_set(tree->t_or_node_in_use,or_node_id);
}
/*:1139*//*1140:*/
#line 13268 "./marpa.w"

PRIVATE void tree_or_node_release(TREE tree,ORID or_node_id)
{
bv_bit_clear(tree->t_or_node_in_use,or_node_id);
}

/*:1140*//*1145:*/
#line 13426 "./marpa.w"

int marpa_t_parse_count(Marpa_Tree t)
{
return t->t_parse_count;
}

/*:1145*//*1146:*/
#line 13434 "./marpa.w"

int _marpa_t_size(Marpa_Tree t)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 13437 "./marpa.w"

/*1120:*/
#line 13071 "./marpa.w"

ORDER o= O_of_T(t);
/*1092:*/
#line 12603 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1047:*/
#line 12198 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1047*/
#line 12605 "./marpa.w"


/*:1092*/
#line 13073 "./marpa.w"
;

/*:1120*/
#line 13438 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 13439 "./marpa.w"

if(T_is_Exhausted(t)){
MARPA_ERROR(MARPA_ERR_TREE_EXHAUSTED);
return failure_indicator;
}
if(T_is_Nulling(t))return 0;
return Size_of_T(t);
}

/*:1146*//*1167:*/
#line 13652 "./marpa.w"

Marpa_Value marpa_v_new(Marpa_Tree t)
{
/*1315:*/
#line 15686 "./marpa.w"
void*const failure_indicator= NULL;
/*:1315*/
#line 13655 "./marpa.w"

/*1120:*/
#line 13071 "./marpa.w"

ORDER o= O_of_T(t);
/*1092:*/
#line 12603 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1047:*/
#line 12198 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1047*/
#line 12605 "./marpa.w"


/*:1092*/
#line 13073 "./marpa.w"
;

/*:1120*/
#line 13656 "./marpa.w"
;
/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 13657 "./marpa.w"

if(t->t_parse_count<=0){
MARPA_ERROR(MARPA_ERR_BEFORE_FIRST_TREE);
return NULL;
}
if(!T_is_Exhausted(t))
{
const ISYID isy_count= ISY_Count_of_G(g);
struct marpa_obstack*const obstack= marpa_obs_init;
const VALUE v= marpa_obs_new(obstack,struct s_value,1);
v->t_obs= obstack;
Step_Type_of_V(v)= Next_Value_Type_of_V(v)= MARPA_STEP_INITIAL;
V_T_Generation(v)= T_Generation(t);
/*1158:*/
#line 13578 "./marpa.w"

ISYID_of_V(v)= -1;
RULEID_of_V(v)= -1;
Token_Value_of_V(v)= -1;
Token_Type_of_V(v)= DUMMY_OR_NODE;
Arg_0_of_V(v)= -1;
Arg_N_of_V(v)= -1;
Result_of_V(v)= -1;
Rule_Start_of_V(v)= -1;
Token_Start_of_V(v)= -1;
YS_ID_of_V(v)= -1;

/*:1158*//*1165:*/
#line 13641 "./marpa.w"

MARPA_DSTACK_SAFE(VStack_of_V(v));
/*:1165*//*1170:*/
#line 13689 "./marpa.w"

v->t_ref_count= 1;

/*:1170*//*1180:*/
#line 13760 "./marpa.w"

V_is_Nulling(v)= 0;

/*:1180*//*1182:*/
#line 13767 "./marpa.w"

V_is_Trace(v)= 0;
/*:1182*//*1185:*/
#line 13789 "./marpa.w"

NOOK_of_V(v)= -1;
/*:1185*//*1190:*/
#line 13817 "./marpa.w"

{
ISY_is_Valued_BV_of_V(v)= lbv_clone(v->t_obs,Valued_BV_of_B(b),isy_count);
Valued_Locked_BV_of_V(v)= 
lbv_clone(v->t_obs,Valued_Locked_BV_of_B(b),isy_count);
}


/*:1190*/
#line 13670 "./marpa.w"

T_of_V(v)= t;
if(T_is_Nulling(o)){
V_is_Nulling(v)= 1;
}else{
const int minimum_stack_size= (8192/sizeof(int));
const int initial_stack_size= 
MAX(Size_of_TREE(t)/1024,minimum_stack_size);
MARPA_DSTACK_INIT(VStack_of_V(v),int,initial_stack_size);
}
return(Marpa_Value)v;
}
MARPA_ERROR(MARPA_ERR_TREE_EXHAUSTED);
return NULL;
}

/*:1167*//*1171:*/
#line 13693 "./marpa.w"

PRIVATE void
value_unref(VALUE v)
{
MARPA_ASSERT(v->t_ref_count> 0)
v->t_ref_count--;
if(v->t_ref_count<=0)
{
value_free(v);
}
}
void
marpa_v_unref(Marpa_Value public_v)
{
value_unref((VALUE)public_v);
}

/*:1171*//*1172:*/
#line 13711 "./marpa.w"

PRIVATE VALUE
value_ref(VALUE v)
{
MARPA_ASSERT(v->t_ref_count> 0)
v->t_ref_count++;
return v;
}
Marpa_Value
marpa_v_ref(Marpa_Value public_v)
{
/*1315:*/
#line 15686 "./marpa.w"
void*const failure_indicator= NULL;
/*:1315*/
#line 13722 "./marpa.w"

const VALUE v= (VALUE)public_v;
/*1174:*/
#line 13737 "./marpa.w"

TREE t= T_of_V(v);
/*1120:*/
#line 13071 "./marpa.w"

ORDER o= O_of_T(t);
/*1092:*/
#line 12603 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1047:*/
#line 12198 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1047*/
#line 12605 "./marpa.w"


/*:1092*/
#line 13073 "./marpa.w"
;

/*:1120*/
#line 13739 "./marpa.w"


/*:1174*/
#line 13724 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 13725 "./marpa.w"

/*1177:*/
#line 13749 "./marpa.w"

if(_MARPA_UNLIKELY(V_T_Generation(v)!=T_Generation(t))){
MARPA_ERROR(MARPA_ERR_BASE_GENERATION_MISMATCH);
return failure_indicator;
}

/*:1177*/
#line 13726 "./marpa.w"

return(Marpa_Value)value_ref(v);
}

/*:1172*//*1173:*/
#line 13730 "./marpa.w"

PRIVATE void value_free(VALUE v)
{
/*1166:*/
#line 13643 "./marpa.w"

{
if(_MARPA_LIKELY(MARPA_DSTACK_IS_INITIALIZED(VStack_of_V(v))!=NULL))
{
MARPA_DSTACK_DESTROY(VStack_of_V(v));
}
}

/*:1166*/
#line 13733 "./marpa.w"

/*1160:*/
#line 13594 "./marpa.w"

marpa_obs_free(v->t_obs);

/*:1160*/
#line 13734 "./marpa.w"

}

/*:1173*//*1183:*/
#line 13769 "./marpa.w"

int _marpa_v_trace(Marpa_Value public_v,int flag)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 13772 "./marpa.w"

const VALUE v= (VALUE)public_v;
/*1174:*/
#line 13737 "./marpa.w"

TREE t= T_of_V(v);
/*1120:*/
#line 13071 "./marpa.w"

ORDER o= O_of_T(t);
/*1092:*/
#line 12603 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1047:*/
#line 12198 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1047*/
#line 12605 "./marpa.w"


/*:1092*/
#line 13073 "./marpa.w"
;

/*:1120*/
#line 13739 "./marpa.w"


/*:1174*/
#line 13774 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 13775 "./marpa.w"

/*1177:*/
#line 13749 "./marpa.w"

if(_MARPA_UNLIKELY(V_T_Generation(v)!=T_Generation(t))){
MARPA_ERROR(MARPA_ERR_BASE_GENERATION_MISMATCH);
return failure_indicator;
}

/*:1177*/
#line 13776 "./marpa.w"

if(_MARPA_UNLIKELY(!V_is_Active(v))){
MARPA_ERROR(MARPA_ERR_VALUATOR_INACTIVE);
return failure_indicator;
}
V_is_Trace(v)= Boolean(flag);
return 1;
}

/*:1183*//*1186:*/
#line 13792 "./marpa.w"

Marpa_Nook_ID _marpa_v_nook(Marpa_Value public_v)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 13795 "./marpa.w"

const VALUE v= (VALUE)public_v;
/*1174:*/
#line 13737 "./marpa.w"

TREE t= T_of_V(v);
/*1120:*/
#line 13071 "./marpa.w"

ORDER o= O_of_T(t);
/*1092:*/
#line 12603 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1047:*/
#line 12198 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1047*/
#line 12605 "./marpa.w"


/*:1092*/
#line 13073 "./marpa.w"
;

/*:1120*/
#line 13739 "./marpa.w"


/*:1174*/
#line 13797 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 13798 "./marpa.w"

/*1177:*/
#line 13749 "./marpa.w"

if(_MARPA_UNLIKELY(V_T_Generation(v)!=T_Generation(t))){
MARPA_ERROR(MARPA_ERR_BASE_GENERATION_MISMATCH);
return failure_indicator;
}

/*:1177*/
#line 13799 "./marpa.w"

if(_MARPA_UNLIKELY(V_is_Nulling(v)))return-1;
if(_MARPA_UNLIKELY(!V_is_Active(v))){
MARPA_ERROR(MARPA_ERR_VALUATOR_INACTIVE);
return failure_indicator;
}
return NOOK_of_V(v);
}

/*:1186*//*1191:*/
#line 13826 "./marpa.w"

PRIVATE int symbol_is_valued(
VALUE v,
Marpa_Symbol_ID isy_id)
{
return lbv_bit_test(ISY_is_Valued_BV_of_V(v),isy_id);
}

/*:1191*//*1192:*/
#line 13835 "./marpa.w"

int marpa_v_symbol_is_valued(
Marpa_Value public_v,
Marpa_Symbol_ID isy_id)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 13840 "./marpa.w"

const VALUE v= (VALUE)public_v;
/*1174:*/
#line 13737 "./marpa.w"

TREE t= T_of_V(v);
/*1120:*/
#line 13071 "./marpa.w"

ORDER o= O_of_T(t);
/*1092:*/
#line 12603 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1047:*/
#line 12198 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1047*/
#line 12605 "./marpa.w"


/*:1092*/
#line 13073 "./marpa.w"
;

/*:1120*/
#line 13739 "./marpa.w"


/*:1174*/
#line 13842 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 13843 "./marpa.w"

/*1177:*/
#line 13749 "./marpa.w"

if(_MARPA_UNLIKELY(V_T_Generation(v)!=T_Generation(t))){
MARPA_ERROR(MARPA_ERR_BASE_GENERATION_MISMATCH);
return failure_indicator;
}

/*:1177*/
#line 13844 "./marpa.w"

/*1319:*/
#line 15705 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1319*/
#line 13845 "./marpa.w"

/*1320:*/
#line 15712 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}
/*:1320*/
#line 13846 "./marpa.w"

return lbv_bit_test(ISY_is_Valued_BV_of_V(v),isy_id);
}

/*:1192*//*1193:*/
#line 13852 "./marpa.w"

PRIVATE int symbol_is_valued_set(
VALUE v,ISYID isy_id,int value)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 13856 "./marpa.w"

const int old_value= lbv_bit_test(ISY_is_Valued_BV_of_V(v),isy_id);
if(old_value==value){
lbv_bit_set(Valued_Locked_BV_of_V(v),isy_id);
return value;
}

if(_MARPA_UNLIKELY(lbv_bit_test(Valued_Locked_BV_of_V(v),isy_id))){
return failure_indicator;
}
lbv_bit_set(Valued_Locked_BV_of_V(v),isy_id);
if(value){
lbv_bit_set(ISY_is_Valued_BV_of_V(v),isy_id);
}else{
lbv_bit_clear(ISY_is_Valued_BV_of_V(v),isy_id);
}
return value;
}

/*:1193*//*1194:*/
#line 13875 "./marpa.w"

int marpa_v_symbol_is_valued_set(
Marpa_Value public_v,Marpa_Symbol_ID isy_id,int value)
{
const VALUE v= (VALUE)public_v;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 13880 "./marpa.w"

/*1174:*/
#line 13737 "./marpa.w"

TREE t= T_of_V(v);
/*1120:*/
#line 13071 "./marpa.w"

ORDER o= O_of_T(t);
/*1092:*/
#line 12603 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1047:*/
#line 12198 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1047*/
#line 12605 "./marpa.w"


/*:1092*/
#line 13073 "./marpa.w"
;

/*:1120*/
#line 13739 "./marpa.w"


/*:1174*/
#line 13881 "./marpa.w"

/*1177:*/
#line 13749 "./marpa.w"

if(_MARPA_UNLIKELY(V_T_Generation(v)!=T_Generation(t))){
MARPA_ERROR(MARPA_ERR_BASE_GENERATION_MISMATCH);
return failure_indicator;
}

/*:1177*/
#line 13882 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 13883 "./marpa.w"

if(_MARPA_UNLIKELY(value<0||value> 1))
{
MARPA_ERROR(MARPA_ERR_INVALID_BOOLEAN);
return failure_indicator;
}
/*1319:*/
#line 15705 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1319*/
#line 13889 "./marpa.w"

/*1320:*/
#line 15712 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}
/*:1320*/
#line 13890 "./marpa.w"

return symbol_is_valued_set(v,isy_id,value);
}

/*:1194*//*1195:*/
#line 13896 "./marpa.w"

int
marpa_v_valued_force(Marpa_Value public_v)
{
const VALUE v= (VALUE)public_v;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 13901 "./marpa.w"

ISYID isy_count;
ISYID isy_id;
/*1174:*/
#line 13737 "./marpa.w"

TREE t= T_of_V(v);
/*1120:*/
#line 13071 "./marpa.w"

ORDER o= O_of_T(t);
/*1092:*/
#line 12603 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1047:*/
#line 12198 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1047*/
#line 12605 "./marpa.w"


/*:1092*/
#line 13073 "./marpa.w"
;

/*:1120*/
#line 13739 "./marpa.w"


/*:1174*/
#line 13904 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 13905 "./marpa.w"

/*1177:*/
#line 13749 "./marpa.w"

if(_MARPA_UNLIKELY(V_T_Generation(v)!=T_Generation(t))){
MARPA_ERROR(MARPA_ERR_BASE_GENERATION_MISMATCH);
return failure_indicator;
}

/*:1177*/
#line 13906 "./marpa.w"

isy_count= ISY_Count_of_G(g);
for(isy_id= 0;isy_id<isy_count;isy_id++)
{
if(_MARPA_UNLIKELY(!lbv_bit_test(ISY_is_Valued_BV_of_V(v),isy_id)&&
lbv_bit_test(Valued_Locked_BV_of_V(v),isy_id)))
{
return failure_indicator;
}
lbv_bit_set(Valued_Locked_BV_of_V(v),isy_id);
lbv_bit_set(ISY_is_Valued_BV_of_V(v),isy_id);
}
return isy_count;
}

/*:1195*//*1196:*/
#line 13921 "./marpa.w"

int marpa_v_rule_is_valued_set(
Marpa_Value public_v,Marpa_Rule_ID irl_id,int value)
{
const VALUE v= (VALUE)public_v;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 13926 "./marpa.w"

/*1174:*/
#line 13737 "./marpa.w"

TREE t= T_of_V(v);
/*1120:*/
#line 13071 "./marpa.w"

ORDER o= O_of_T(t);
/*1092:*/
#line 12603 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1047:*/
#line 12198 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1047*/
#line 12605 "./marpa.w"


/*:1092*/
#line 13073 "./marpa.w"
;

/*:1120*/
#line 13739 "./marpa.w"


/*:1174*/
#line 13927 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 13928 "./marpa.w"

/*1177:*/
#line 13749 "./marpa.w"

if(_MARPA_UNLIKELY(V_T_Generation(v)!=T_Generation(t))){
MARPA_ERROR(MARPA_ERR_BASE_GENERATION_MISMATCH);
return failure_indicator;
}

/*:1177*/
#line 13929 "./marpa.w"

if(_MARPA_UNLIKELY(value<0||value> 1))
{
MARPA_ERROR(MARPA_ERR_INVALID_BOOLEAN);
return failure_indicator;
}
/*1328:*/
#line 15761 "./marpa.w"

if(_MARPA_UNLIKELY(IRLID_is_Malformed(irl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_RULE_ID);
return failure_indicator;
}

/*:1328*/
#line 13935 "./marpa.w"

/*1326:*/
#line 15749 "./marpa.w"

if(_MARPA_UNLIKELY(!IRLID_of_G_Exists(irl_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_RULE_ID);
return-1;
}

/*:1326*/
#line 13936 "./marpa.w"

{
const IRL xrl= IRL_by_ID(irl_id);
const ISYID isy_id= LHS_ID_of_IRL(xrl);
return symbol_is_valued_set(v,isy_id,value);
}
}

/*:1196*//*1197:*/
#line 13944 "./marpa.w"

int marpa_v_rule_is_valued(
Marpa_Value public_v,Marpa_Rule_ID irl_id)
{
const VALUE v= (VALUE)public_v;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 13949 "./marpa.w"

/*1174:*/
#line 13737 "./marpa.w"

TREE t= T_of_V(v);
/*1120:*/
#line 13071 "./marpa.w"

ORDER o= O_of_T(t);
/*1092:*/
#line 12603 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1047:*/
#line 12198 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1047*/
#line 12605 "./marpa.w"


/*:1092*/
#line 13073 "./marpa.w"
;

/*:1120*/
#line 13739 "./marpa.w"


/*:1174*/
#line 13950 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 13951 "./marpa.w"

/*1177:*/
#line 13749 "./marpa.w"

if(_MARPA_UNLIKELY(V_T_Generation(v)!=T_Generation(t))){
MARPA_ERROR(MARPA_ERR_BASE_GENERATION_MISMATCH);
return failure_indicator;
}

/*:1177*/
#line 13952 "./marpa.w"

/*1328:*/
#line 15761 "./marpa.w"

if(_MARPA_UNLIKELY(IRLID_is_Malformed(irl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_RULE_ID);
return failure_indicator;
}

/*:1328*/
#line 13953 "./marpa.w"

/*1326:*/
#line 15749 "./marpa.w"

if(_MARPA_UNLIKELY(!IRLID_of_G_Exists(irl_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_RULE_ID);
return-1;
}

/*:1326*/
#line 13954 "./marpa.w"

{
const IRL xrl= IRL_by_ID(irl_id);
const ISYID isy_id= LHS_ID_of_IRL(xrl);
return symbol_is_valued(v,isy_id);
}
}

/*:1197*//*1199:*/
#line 13969 "./marpa.w"

Marpa_Step_Type marpa_v_step(Marpa_Value public_v)
{
const VALUE v= (VALUE)public_v;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 13973 "./marpa.w"

/*1174:*/
#line 13737 "./marpa.w"

TREE t= T_of_V(v);
/*1120:*/
#line 13071 "./marpa.w"

ORDER o= O_of_T(t);
/*1092:*/
#line 12603 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1047:*/
#line 12198 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1047*/
#line 12605 "./marpa.w"


/*:1092*/
#line 13073 "./marpa.w"
;

/*:1120*/
#line 13739 "./marpa.w"


/*:1174*/
#line 13974 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 13975 "./marpa.w"

/*1177:*/
#line 13749 "./marpa.w"

if(_MARPA_UNLIKELY(V_T_Generation(v)!=T_Generation(t))){
MARPA_ERROR(MARPA_ERR_BASE_GENERATION_MISMATCH);
return failure_indicator;
}

/*:1177*/
#line 13976 "./marpa.w"


if(V_is_Nulling(v)){
/*1201:*/
#line 14058 "./marpa.w"

{
while(V_is_Active(v))
{
Marpa_Step_Type current_value_type= Next_Value_Type_of_V(v);
switch(current_value_type)
{
case MARPA_STEP_INITIAL:
case STEP_GET_DATA:
{
Next_Value_Type_of_V(v)= MARPA_STEP_INACTIVE;
ISYID_of_V(v)= g->t_start_isy_id;
Result_of_V(v)= Arg_0_of_V(v)= Arg_N_of_V(v)= 0;
if(lbv_bit_test(ISY_is_Valued_BV_of_V(v),ISYID_of_V(v)))
return Step_Type_of_V(v)= MARPA_STEP_NULLING_SYMBOL;
}





}
}
}

/*:1201*/
#line 13979 "./marpa.w"

return Step_Type_of_V(v)= MARPA_STEP_INACTIVE;
}

while(V_is_Active(v)){
Marpa_Step_Type current_value_type= Next_Value_Type_of_V(v);
switch(current_value_type)
{
case MARPA_STEP_INITIAL:
{
ISYID isy_count;
isy_count= ISY_Count_of_G(g);
lbv_fill(Valued_Locked_BV_of_V(v),isy_count);
/*1200:*/
#line 14042 "./marpa.w"

{
const LBV isy_bv= ISY_is_Valued_BV_of_V(v);
const IRLID irl_count= IRL_Count_of_G(g);
const LBV irl_bv= lbv_obs_new0(v->t_obs,irl_count);
IRLID xrlid;
IRL_is_Valued_BV_of_V(v)= irl_bv;
for(xrlid= 0;xrlid<irl_count;xrlid++){
const IRL xrl= IRL_by_ID(xrlid);
const ISYID lhs_isy_id= LHS_ID_of_IRL(xrl);
if(lbv_bit_test(isy_bv,lhs_isy_id)){
lbv_bit_set(irl_bv,xrlid);
}
}
}

/*:1200*/
#line 13992 "./marpa.w"

}

case STEP_GET_DATA:
/*1202:*/
#line 14083 "./marpa.w"

{
AND and_nodes;






int pop_arguments= 1;
and_nodes= ANDs_of_B(B_of_O(o));

if(NOOK_of_V(v)<0){
NOOK_of_V(v)= Size_of_TREE(t);
}

while(1)
{
OR or;
NRL nook_nrl;
Token_Value_of_V(v)= -1;
RULEID_of_V(v)= -1;
NOOK_of_V(v)--;
if(NOOK_of_V(v)<0)
{
Next_Value_Type_of_V(v)= MARPA_STEP_INACTIVE;
break;
}
if(pop_arguments)
{


Arg_N_of_V(v)= Arg_0_of_V(v);
pop_arguments= 0;
}
{
ANDID and_node_id;
AND and_node;
int cause_or_node_type;
OR cause_or_node;
const NOOK nook= NOOK_of_TREE_by_IX(t,NOOK_of_V(v));
const int choice= Choice_of_NOOK(nook);
or= OR_of_NOOK(nook);
YS_ID_of_V(v)= YS_Ord_of_OR(or);
and_node_id= and_order_get(o,or,choice);
and_node= and_nodes+and_node_id;
cause_or_node= Cause_OR_of_AND(and_node);
cause_or_node_type= Type_of_OR(cause_or_node);
switch(cause_or_node_type)
{
case VALUED_TOKEN_OR_NODE:
Token_Type_of_V(v)= cause_or_node_type;
Arg_0_of_V(v)= ++Arg_N_of_V(v);
{
const OR predecessor= Predecessor_OR_of_AND(and_node);
ISYID_of_V(v)= 
ID_of_ISY(Source_ISY_of_NSYID(NSYID_of_OR(cause_or_node)));
Token_Start_of_V(v)= 
predecessor?YS_Ord_of_OR(predecessor):Origin_Ord_of_OR(or);
Token_Value_of_V(v)= Value_of_OR(cause_or_node);
}

break;
case NULLING_TOKEN_OR_NODE:
Token_Type_of_V(v)= cause_or_node_type;
Arg_0_of_V(v)= ++Arg_N_of_V(v);
{
const ISY source_isy= 
Source_ISY_of_NSYID(NSYID_of_OR(cause_or_node));
const ISYID source_isy_id= ID_of_ISY(source_isy);
if(bv_bit_test(ISY_is_Valued_BV_of_V(v),source_isy_id))
{
ISYID_of_V(v)= source_isy_id;
Token_Start_of_V(v)= YS_ID_of_V(v);
}
else
{
Token_Type_of_V(v)= DUMMY_OR_NODE;


}
}

break;
default:
Token_Type_of_V(v)= DUMMY_OR_NODE;
}
}
nook_nrl= NRL_of_OR(or);
if(Position_of_OR(or)==Length_of_NRL(nook_nrl))
{
int virtual_rhs= NRL_has_Virtual_RHS(nook_nrl);
int virtual_lhs= NRL_has_Virtual_LHS(nook_nrl);
int real_symbol_count;
const MARPA_DSTACK virtual_stack= &VStack_of_V(v);
if(virtual_lhs)
{
real_symbol_count= Real_SYM_Count_of_NRL(nook_nrl);
if(virtual_rhs)
{
*(MARPA_DSTACK_TOP(*virtual_stack,int))+= real_symbol_count;
}
else
{
*MARPA_DSTACK_PUSH(*virtual_stack,int)= real_symbol_count;
}
}
else
{

if(virtual_rhs)
{
real_symbol_count= Real_SYM_Count_of_NRL(nook_nrl);
real_symbol_count+= *MARPA_DSTACK_POP(*virtual_stack,int);
}
else
{
real_symbol_count= Length_of_NRL(nook_nrl);
}
{


IRLID original_rule_id= ID_of_IRL(Source_IRL_of_NRL(nook_nrl));
Arg_0_of_V(v)= Arg_N_of_V(v)-real_symbol_count+1;
pop_arguments= 1;
if(lbv_bit_test(IRL_is_Valued_BV_of_V(v),original_rule_id))
{
RULEID_of_V(v)= original_rule_id;
Rule_Start_of_V(v)= Origin_Ord_of_OR(or);
}
}

}
}
if(RULEID_of_V(v)>=0)
break;
if(Token_Type_of_V(v)!=DUMMY_OR_NODE)
break;
if(V_is_Trace(v))
break;
}
}

/*:1202*/
#line 13996 "./marpa.w"

if(!V_is_Active(v))break;

case MARPA_STEP_TOKEN:
{
int tkn_type= Token_Type_of_V(v);
Next_Value_Type_of_V(v)= MARPA_STEP_RULE;
if(tkn_type==NULLING_TOKEN_OR_NODE)
{
if(lbv_bit_test(ISY_is_Valued_BV_of_V(v),ISYID_of_V(v))){
Result_of_V(v)= Arg_N_of_V(v);
return Step_Type_of_V(v)= MARPA_STEP_NULLING_SYMBOL;
}
}
else if(tkn_type!=DUMMY_OR_NODE)
{
Result_of_V(v)= Arg_N_of_V(v);
return Step_Type_of_V(v)= MARPA_STEP_TOKEN;
}
}

case MARPA_STEP_RULE:
if(RULEID_of_V(v)>=0)
{
Next_Value_Type_of_V(v)= MARPA_STEP_TRACE;
Result_of_V(v)= Arg_0_of_V(v);
return Step_Type_of_V(v)= MARPA_STEP_RULE;
}

case MARPA_STEP_TRACE:
Next_Value_Type_of_V(v)= STEP_GET_DATA;
if(V_is_Trace(v))
{
return Step_Type_of_V(v)= MARPA_STEP_TRACE;
}
}
}

Next_Value_Type_of_V(v)= MARPA_STEP_INACTIVE;
return Step_Type_of_V(v)= MARPA_STEP_INACTIVE;
}

/*:1199*//*1204:*/
#line 14244 "./marpa.w"

PRIVATE int lbv_bits_to_size(int bits)
{
const LBW result= (LBW)(((unsigned int)bits+(lbv_wordbits-1))/lbv_wordbits);
return(int)result;
}

/*:1204*//*1205:*/
#line 14252 "./marpa.w"

PRIVATE Bit_Vector
lbv_obs_new(struct marpa_obstack*obs,int bits)
{
int size= lbv_bits_to_size(bits);
LBV lbv= marpa_obs_new(obs,LBW,size);
return lbv;
}

/*:1205*//*1206:*/
#line 14262 "./marpa.w"

PRIVATE Bit_Vector
lbv_zero(Bit_Vector lbv,int bits)
{
int size= lbv_bits_to_size(bits);
if(size> 0){
LBW*addr= lbv;
while(size--)*addr++= 0u;
}
return lbv;
}

/*:1206*//*1207:*/
#line 14275 "./marpa.w"

PRIVATE Bit_Vector
lbv_obs_new0(struct marpa_obstack*obs,int bits)
{
LBV lbv= lbv_obs_new(obs,bits);
return lbv_zero(lbv,bits);
}

/*:1207*//*1209:*/
#line 14294 "./marpa.w"

PRIVATE LBV lbv_clone(
struct marpa_obstack*obs,LBV old_lbv,int bits)
{
int size= lbv_bits_to_size(bits);
const LBV new_lbv= marpa_obs_new(obs,LBW,size);
if(size> 0){
LBW*from_addr= old_lbv;
LBW*to_addr= new_lbv;
while(size--)*to_addr++= *from_addr++;
}
return new_lbv;
}

/*:1209*//*1210:*/
#line 14310 "./marpa.w"

PRIVATE LBV lbv_fill(
LBV lbv,int bits)
{
int size= lbv_bits_to_size(bits);
if(size> 0){
LBW*to_addr= lbv;
while(size--)*to_addr++= ~((LBW)0);
}
return lbv;
}

/*:1210*//*1213:*/
#line 14346 "./marpa.w"

PRIVATE unsigned int bv_bits_to_size(int bits)
{
return((LBW)bits+bv_modmask)/bv_wordbits;
}
/*:1213*//*1214:*/
#line 14352 "./marpa.w"

PRIVATE unsigned int bv_bits_to_unused_mask(int bits)
{
LBW mask= (LBW)bits&bv_modmask;
if(mask)mask= (LBW)~(~0uL<<mask);else mask= (LBW)~0uL;
return(mask);
}

/*:1214*//*1216:*/
#line 14366 "./marpa.w"

PRIVATE Bit_Vector bv_create(int bits)
{
LBW size= bv_bits_to_size(bits);
LBW bytes= (size+(LBW)bv_hiddenwords)*(LBW)sizeof(Bit_Vector_Word);
LBW*addr= (Bit_Vector)my_malloc0((size_t)bytes);
*addr++= (LBW)bits;
*addr++= size;
*addr++= bv_bits_to_unused_mask(bits);
return addr;
}

/*:1216*//*1218:*/
#line 14384 "./marpa.w"

PRIVATE Bit_Vector
bv_obs_create(struct marpa_obstack*obs,int bits)
{
LBW size= bv_bits_to_size(bits);
LBW bytes= (size+(LBW)bv_hiddenwords)*(LBW)sizeof(Bit_Vector_Word);
LBW*addr= (Bit_Vector)marpa__obs_alloc(obs,(size_t)bytes,ALIGNOF(LBW));
*addr++= (LBW)bits;
*addr++= size;
*addr++= bv_bits_to_unused_mask(bits);
if(size> 0){
Bit_Vector bv= addr;
while(size--)*bv++= 0u;
}
return addr;
}


/*:1218*//*1219:*/
#line 14405 "./marpa.w"

PRIVATE Bit_Vector bv_shadow(Bit_Vector bv)
{
return bv_create((int)BV_BITS(bv));
}
PRIVATE Bit_Vector bv_obs_shadow(struct marpa_obstack*obs,Bit_Vector bv)
{
return bv_obs_create(obs,(int)BV_BITS(bv));
}

/*:1219*//*1220:*/
#line 14419 "./marpa.w"

PRIVATE
Bit_Vector bv_copy(Bit_Vector bv_to,Bit_Vector bv_from)
{
LBW*p_to= bv_to;
const LBW bits= BV_BITS(bv_to);
if(bits> 0)
{
LBW count= BV_SIZE(bv_to);
while(count--)*p_to++= *bv_from++;
}
return(bv_to);
}

/*:1220*//*1221:*/
#line 14437 "./marpa.w"

PRIVATE
Bit_Vector bv_clone(Bit_Vector bv)
{
return bv_copy(bv_shadow(bv),bv);
}

PRIVATE
Bit_Vector bv_obs_clone(struct marpa_obstack*obs,Bit_Vector bv)
{
return bv_copy(bv_obs_shadow(obs,bv),bv);
}

/*:1221*//*1222:*/
#line 14451 "./marpa.w"

PRIVATE void bv_free(Bit_Vector vector)
{
if(_MARPA_LIKELY(vector!=NULL))
{
vector-= bv_hiddenwords;
my_free(vector);
}
}

/*:1222*//*1223:*/
#line 14462 "./marpa.w"

PRIVATE void bv_fill(Bit_Vector bv)
{
LBW size= BV_SIZE(bv);
if(size<=0)return;
while(size--)*bv++= ~0u;
--bv;
*bv&= BV_MASK(bv);
}

/*:1223*//*1224:*/
#line 14473 "./marpa.w"

PRIVATE void bv_clear(Bit_Vector bv)
{
LBW size= BV_SIZE(bv);
if(size<=0)return;
while(size--)*bv++= 0u;
}

/*:1224*//*1226:*/
#line 14487 "./marpa.w"

PRIVATE void bv_over_clear(Bit_Vector bv,int raw_bit)
{
const LBW bit= (LBW)raw_bit;
LBW length= bit/bv_wordbits+1;
while(length--)*bv++= 0u;
}

/*:1226*//*1228:*/
#line 14496 "./marpa.w"

PRIVATE void bv_bit_set(Bit_Vector vector,int raw_bit)
{
const LBW bit= (LBW)raw_bit;
*(vector+(bit/bv_wordbits))|= (bv_lsb<<(bit%bv_wordbits));
}

/*:1228*//*1229:*/
#line 14504 "./marpa.w"

PRIVATE void bv_bit_clear(Bit_Vector vector,int raw_bit)
{
const LBW bit= (LBW)raw_bit;
*(vector+(bit/bv_wordbits))&= ~(bv_lsb<<(bit%bv_wordbits));
}

/*:1229*//*1230:*/
#line 14512 "./marpa.w"

PRIVATE int bv_bit_test(Bit_Vector vector,int raw_bit)
{
const LBW bit= (LBW)raw_bit;
return(*(vector+(bit/bv_wordbits))&(bv_lsb<<(bit%bv_wordbits)))!=0u;
}

/*:1230*//*1231:*/
#line 14524 "./marpa.w"

PRIVATE int
bv_bit_test_then_set(Bit_Vector vector,int raw_bit)
{
const LBW bit= (LBW)raw_bit;
Bit_Vector addr= vector+(bit/bv_wordbits);
LBW mask= bv_lsb<<(bit%bv_wordbits);
if((*addr&mask)!=0u)
return 1;
*addr|= mask;
return 0;
}

/*:1231*//*1232:*/
#line 14538 "./marpa.w"

PRIVATE
int bv_is_empty(Bit_Vector addr)
{
LBW size= BV_SIZE(addr);
int r= 1;
if(size> 0){
*(addr+size-1)&= BV_MASK(addr);
while(r&&(size--> 0))r= (*addr++==0);
}
return(r);
}

/*:1232*//*1233:*/
#line 14552 "./marpa.w"

PRIVATE void bv_not(Bit_Vector X,Bit_Vector Y)
{
LBW size= BV_SIZE(X);
LBW mask= BV_MASK(X);
while(size--> 0)*X++= ~*Y++;
*(--X)&= mask;
}

/*:1233*//*1234:*/
#line 14562 "./marpa.w"

PRIVATE void bv_and(Bit_Vector X,Bit_Vector Y,Bit_Vector Z)
{
LBW size= BV_SIZE(X);
LBW mask= BV_MASK(X);
while(size--> 0)*X++= *Y++&*Z++;
*(--X)&= mask;
}

/*:1234*//*1235:*/
#line 14572 "./marpa.w"

PRIVATE void bv_or(Bit_Vector X,Bit_Vector Y,Bit_Vector Z)
{
LBW size= BV_SIZE(X);
LBW mask= BV_MASK(X);
while(size--> 0)*X++= *Y++|*Z++;
*(--X)&= mask;
}

/*:1235*//*1236:*/
#line 14582 "./marpa.w"

PRIVATE void bv_or_assign(Bit_Vector X,Bit_Vector Y)
{
LBW size= BV_SIZE(X);
LBW mask= BV_MASK(X);
while(size--> 0)*X++|= *Y++;
*(--X)&= mask;
}

/*:1236*//*1237:*/
#line 14592 "./marpa.w"

PRIVATE_NOT_INLINE
int bv_scan(Bit_Vector bv,int raw_start,int*raw_min,int*raw_max)
{
LBW start= (LBW)raw_start;
LBW min;
LBW max;
LBW size= BV_SIZE(bv);
LBW mask= BV_MASK(bv);
LBW offset;
LBW bitmask;
LBW value;
int empty;

if(size==0)return 0;
if(start>=BV_BITS(bv))return 0;
min= start;
max= start;
offset= start/bv_wordbits;
*(bv+size-1)&= mask;
bv+= offset;
size-= offset;
bitmask= (LBW)1<<(start&bv_modmask);
mask= ~(bitmask|(bitmask-(LBW)1));
value= *bv++;
if((value&bitmask)==0)
{
value&= mask;
if(value==0)
{
offset++;
empty= 1;
while(empty&&(--size> 0))
{
if((value= *bv++))empty= 0;else offset++;
}
if(empty){
*raw_min= (int)min;
*raw_max= (int)max;
return 0;
}
}
start= offset*bv_wordbits;
bitmask= bv_lsb;
mask= value;
while(!(mask&bv_lsb))
{
bitmask<<= 1;
mask>>= 1;
start++;
}
mask= ~(bitmask|(bitmask-1));
min= start;
max= start;
}
value= ~value;
value&= mask;
if(value==0)
{
offset++;
empty= 1;
while(empty&&(--size> 0))
{
if((value= ~*bv++))empty= 0;else offset++;
}
if(empty)value= bv_lsb;
}
start= offset*bv_wordbits;
while(!(value&bv_lsb))
{
value>>= 1;
start++;
}
max= --start;
*raw_min= (int)min;
*raw_max= (int)max;
return 1;
}

/*:1237*//*1238:*/
#line 14672 "./marpa.w"

PRIVATE int
bv_count(Bit_Vector v)
{
int start,min,max;
int count= 0;
for(start= 0;bv_scan(v,start,&min,&max);start= max+2)
{
count+= max-min+1;
}
return count;
}

/*:1238*//*1243:*/
#line 14719 "./marpa.w"

PRIVATE void
rhs_closure(GRAMMAR g,Bit_Vector bv,IRLID**irl_list_x_rh_sym)
{
int min,max,start= 0;
Marpa_Symbol_ID*end_of_stack= NULL;



FSTACK_DECLARE(stack,ISYID)
FSTACK_INIT(stack,ISYID,ISY_Count_of_G(g));










while(bv_scan(bv,start,&min,&max))
{
ISYID isy_id;
for(isy_id= min;isy_id<=max;isy_id++)
{
*(FSTACK_PUSH(stack))= isy_id;
}
start= max+2;
}



while((end_of_stack= FSTACK_POP(stack)))
{


const ISYID isy_id= *end_of_stack;
IRLID*p_irl= irl_list_x_rh_sym[isy_id];
const IRLID*p_one_past_rules= irl_list_x_rh_sym[isy_id+1];

for(;p_irl<p_one_past_rules;p_irl++)
{


const IRLID rule_id= *p_irl;
const IRL rule= IRL_by_ID(rule_id);
int rule_length;
int rh_ix;
const ISYID lhs_id= LHS_ID_of_IRL(rule);

const int is_sequence= IRL_is_Sequence(rule);




if(bv_bit_test(bv,lhs_id))
goto NEXT_RULE;

rule_length= Length_of_IRL(rule);













for(rh_ix= 0;rh_ix<rule_length;rh_ix++)
{
if(!bv_bit_test
(bv,RHS_ID_of_IRL(rule,rh_ix)))
goto NEXT_RULE;
}










if(is_sequence&&Minimum_of_IRL(rule)>=2)
{
ISYID separator_id= Separator_of_IRL(rule);
if(separator_id>=0)
{
if(!bv_bit_test(bv,separator_id))
goto NEXT_RULE;
}
}







bv_bit_set(bv,lhs_id);
*(FSTACK_PUSH(stack))= lhs_id;
NEXT_RULE:;
}
}
FSTACK_DESTROY(stack);
}

/*:1243*//*1248:*/
#line 14866 "./marpa.w"

PRIVATE Bit_Matrix
matrix_buffer_create(void*buffer,int rows,int columns)
{
int row;
const LBW bv_data_words= bv_bits_to_size(columns);
const LBW bv_mask= bv_bits_to_unused_mask(columns);

Bit_Matrix matrix_addr= buffer;
matrix_addr->t_row_count= rows;
for(row= 0;row<rows;row++){
const LBW row_start= (LBW)row*(bv_data_words+bv_hiddenwords);
LBW*p_current_word= matrix_addr->t_row_data+row_start;
LBW data_word_counter= bv_data_words;
*p_current_word++= (LBW)columns;
*p_current_word++= bv_data_words;
*p_current_word++= bv_mask;
while(data_word_counter--)*p_current_word++= 0;
}
return matrix_addr;
}

/*:1248*//*1250:*/
#line 14889 "./marpa.w"

PRIVATE size_t matrix_sizeof(int rows,int columns)
{
const LBW bv_data_words= bv_bits_to_size(columns);
const LBW row_bytes= 
(LBW)(bv_data_words+bv_hiddenwords)*(LBW)sizeof(Bit_Vector_Word);
return offsetof(struct s_bit_matrix,
t_row_data)+((size_t)rows)*row_bytes;
}

/*:1250*//*1252:*/
#line 14900 "./marpa.w"

PRIVATE Bit_Matrix matrix_obs_create(
struct marpa_obstack*obs,
int rows,
int columns)
{

Bit_Matrix matrix_addr= 
marpa__obs_alloc(obs,matrix_sizeof(rows,columns),ALIGNOF(Bit_Matrix_Object));
return matrix_buffer_create(matrix_addr,rows,columns);
}

/*:1252*//*1253:*/
#line 14913 "./marpa.w"

PRIVATE void matrix_clear(Bit_Matrix matrix)
{
Bit_Vector row;
int row_ix;
const int row_count= matrix->t_row_count;
Bit_Vector row0= matrix->t_row_data+bv_hiddenwords;
LBW words_per_row= BV_SIZE(row0)+bv_hiddenwords;
row_ix= 0;row= row0;
while(row_ix<row_count){
bv_clear(row);
row_ix++;
row+= words_per_row;
}
}

/*:1253*//*1254:*/
#line 14935 "./marpa.w"

PRIVATE int matrix_columns(Bit_Matrix matrix)
{
Bit_Vector row0= matrix->t_row_data+bv_hiddenwords;
return(int)BV_BITS(row0);
}

/*:1254*//*1255:*/
#line 14951 "./marpa.w"

PRIVATE Bit_Vector matrix_row(Bit_Matrix matrix,int row)
{
Bit_Vector row0= matrix->t_row_data+bv_hiddenwords;
LBW words_per_row= BV_SIZE(row0)+bv_hiddenwords;
return row0+(LBW)row*words_per_row;
}

/*:1255*//*1257:*/
#line 14960 "./marpa.w"

PRIVATE void matrix_bit_set(Bit_Matrix matrix,int row,int column)
{
Bit_Vector vector= matrix_row(matrix,row);
bv_bit_set(vector,column);
}

/*:1257*//*1259:*/
#line 14968 "./marpa.w"

PRIVATE void matrix_bit_clear(Bit_Matrix matrix,int row,int column)
{
Bit_Vector vector= matrix_row(matrix,row);
bv_bit_clear(vector,column);
}

/*:1259*//*1261:*/
#line 14976 "./marpa.w"

PRIVATE int matrix_bit_test(Bit_Matrix matrix,int row,int column)
{
Bit_Vector vector= matrix_row(matrix,row);
return bv_bit_test(vector,column);
}

/*:1261*//*1262:*/
#line 14993 "./marpa.w"

PRIVATE_NOT_INLINE void transitive_closure(Bit_Matrix matrix)
{
int size= matrix_columns(matrix);
int outer_row;
for(outer_row= 0;outer_row<size;outer_row++)
{
Bit_Vector outer_row_v= matrix_row(matrix,outer_row);
int column;
for(column= 0;column<size;column++)
{
Bit_Vector inner_row_v= matrix_row(matrix,column);
if(bv_bit_test(inner_row_v,outer_row))
{
bv_or_assign(inner_row_v,outer_row_v);
}
}
}
}

/*:1262*//*1274:*/
#line 15134 "./marpa.w"

PRIVATE void
cilar_init(const CILAR cilar)
{
cilar->t_obs= marpa_obs_init;
cilar->t_avl= _marpa_avl_create(cil_cmp,NULL);
MARPA_DSTACK_INIT(cilar->t_buffer,int,2);
*MARPA_DSTACK_INDEX(cilar->t_buffer,int,0)= 0;
}
/*:1274*//*1275:*/
#line 15148 "./marpa.w"

PRIVATE void
cilar_buffer_reinit(const CILAR cilar)
{
MARPA_DSTACK_DESTROY(cilar->t_buffer);
MARPA_DSTACK_INIT(cilar->t_buffer,int,2);
*MARPA_DSTACK_INDEX(cilar->t_buffer,int,0)= 0;
}

/*:1275*//*1276:*/
#line 15157 "./marpa.w"

PRIVATE void cilar_destroy(const CILAR cilar)
{
_marpa_avl_destroy(cilar->t_avl);
marpa_obs_free(cilar->t_obs);
MARPA_DSTACK_DESTROY((cilar->t_buffer));
}

/*:1276*//*1277:*/
#line 15166 "./marpa.w"

PRIVATE CIL cil_empty(CILAR cilar)
{
CIL cil= MARPA_DSTACK_BASE(cilar->t_buffer,int);

Count_of_CIL(cil)= 0;
return cil_buffer_add(cilar);
}

/*:1277*//*1278:*/
#line 15176 "./marpa.w"

PRIVATE CIL cil_singleton(CILAR cilar,int element)
{
CIL cil= MARPA_DSTACK_BASE(cilar->t_buffer,int);
Count_of_CIL(cil)= 1;
Item_of_CIL(cil,0)= element;

return cil_buffer_add(cilar);
}

/*:1278*//*1279:*/
#line 15192 "./marpa.w"

PRIVATE CIL cil_buffer_add(CILAR cilar)
{

CIL cil_in_buffer= MARPA_DSTACK_BASE(cilar->t_buffer,int);
CIL found_cil= _marpa_avl_find(cilar->t_avl,cil_in_buffer);
if(!found_cil)
{
int i;
const int cil_size_in_ints= Count_of_CIL(cil_in_buffer)+1;
found_cil= marpa_obs_new(cilar->t_obs,int,cil_size_in_ints);
for(i= 0;i<cil_size_in_ints;i++)
{
found_cil[i]= cil_in_buffer[i];
}
_marpa_avl_insert(cilar->t_avl,found_cil);
}
return found_cil;
}

/*:1279*//*1280:*/
#line 15220 "./marpa.w"

PRIVATE CIL cil_bv_add(CILAR cilar,Bit_Vector bv)
{
int min,max,start= 0;
cil_buffer_clear(cilar);
for(start= 0;bv_scan(bv,start,&min,&max);start= max+2)
{
int new_item;
for(new_item= min;new_item<=max;new_item++)
{
cil_buffer_push(cilar,new_item);
}
}
return cil_buffer_add(cilar);
}

/*:1280*//*1281:*/
#line 15237 "./marpa.w"

PRIVATE void cil_buffer_clear(CILAR cilar)
{
const MARPA_DSTACK dstack= &cilar->t_buffer;
MARPA_DSTACK_CLEAR(*dstack);




*MARPA_DSTACK_PUSH(*dstack,int)= 0;
}

/*:1281*//*1282:*/
#line 15252 "./marpa.w"

PRIVATE CIL cil_buffer_push(CILAR cilar,int new_item)
{
CIL cil_in_buffer;
MARPA_DSTACK dstack= &cilar->t_buffer;
*MARPA_DSTACK_PUSH(*dstack,int)= new_item;



cil_in_buffer= MARPA_DSTACK_BASE(*dstack,int);
Count_of_CIL(cil_in_buffer)++;
return cil_in_buffer;
}

/*:1282*//*1283:*/
#line 15268 "./marpa.w"

PRIVATE CIL cil_buffer_reserve(CILAR cilar,int element_count)
{
const int desired_dstack_capacity= element_count+1;

const int old_dstack_capacity= MARPA_DSTACK_CAPACITY(cilar->t_buffer);
if(old_dstack_capacity<desired_dstack_capacity)
{
const int target_capacity= 
MAX(old_dstack_capacity*2,desired_dstack_capacity);
MARPA_DSTACK_RESIZE(&(cilar->t_buffer),int,target_capacity);
}
return MARPA_DSTACK_BASE(cilar->t_buffer,int);
}

/*:1283*//*1284:*/
#line 15287 "./marpa.w"

PRIVATE CIL cil_merge(CILAR cilar,CIL cil1,CIL cil2)
{
const int cil1_count= Count_of_CIL(cil1);
const int cil2_count= Count_of_CIL(cil2);
CIL new_cil= cil_buffer_reserve(cilar,cil1_count+cil2_count);
int new_cil_ix= 0;
int cil1_ix= 0;
int cil2_ix= 0;
while(cil1_ix<cil1_count&&cil2_ix<cil2_count)
{
const int item1= Item_of_CIL(cil1,cil1_ix);
const int item2= Item_of_CIL(cil2,cil2_ix);
if(item1<item2)
{
Item_of_CIL(new_cil,new_cil_ix)= item1;
cil1_ix++;
new_cil_ix++;
continue;
}
if(item2<item1)
{
Item_of_CIL(new_cil,new_cil_ix)= item2;
cil2_ix++;
new_cil_ix++;
continue;
}
Item_of_CIL(new_cil,new_cil_ix)= item1;
cil1_ix++;
cil2_ix++;
new_cil_ix++;
}
while(cil1_ix<cil1_count){
const int item1= Item_of_CIL(cil1,cil1_ix);
Item_of_CIL(new_cil,new_cil_ix)= item1;
cil1_ix++;
new_cil_ix++;
}
while(cil2_ix<cil2_count){
const int item2= Item_of_CIL(cil2,cil2_ix);
Item_of_CIL(new_cil,new_cil_ix)= item2;
cil2_ix++;
new_cil_ix++;
}
Count_of_CIL(new_cil)= new_cil_ix;
return cil_buffer_add(cilar);
}

/*:1284*//*1285:*/
#line 15340 "./marpa.w"

PRIVATE CIL cil_merge_one(CILAR cilar,CIL cil,int new_element)
{
const int cil_count= Count_of_CIL(cil);
CIL new_cil= cil_buffer_reserve(cilar,cil_count+1);
int new_cil_ix= 0;
int cil_ix= 0;
while(cil_ix<cil_count)
{
const int cil_item= Item_of_CIL(cil,cil_ix);
if(cil_item==new_element)
{


return NULL;
}
if(cil_item> new_element)
break;
Item_of_CIL(new_cil,new_cil_ix)= cil_item;
cil_ix++;
new_cil_ix++;
}
Item_of_CIL(new_cil,new_cil_ix)= new_element;
new_cil_ix++;
while(cil_ix<cil_count)
{
const int cil_item= Item_of_CIL(cil,cil_ix);
Item_of_CIL(new_cil,new_cil_ix)= cil_item;
cil_ix++;
new_cil_ix++;
}
Count_of_CIL(new_cil)= new_cil_ix;
return cil_buffer_add(cilar);
}

/*:1285*//*1286:*/
#line 15375 "./marpa.w"

PRIVATE_NOT_INLINE int
cil_cmp(const void*ap,const void*bp,void*param UNUSED)
{
int ix;
CIL cil1= (CIL)ap;
CIL cil2= (CIL)bp;
int count1= Count_of_CIL(cil1);
int count2= Count_of_CIL(cil2);
if(count1!=count2)
{
return count1> count2?1:-1;
}
for(ix= 0;ix<count1;ix++)
{
const int item1= Item_of_CIL(cil1,ix);
const int item2= Item_of_CIL(cil2,ix);
if(item1==item2)
continue;
return item1> item2?1:-1;
}
return 0;
}

/*:1286*//*1299:*/
#line 15514 "./marpa.w"

PRIVATE void
psar_safe(const PSAR psar)
{
psar->t_psl_length= 0;
psar->t_first_psl= psar->t_first_free_psl= NULL;
}
/*:1299*//*1300:*/
#line 15521 "./marpa.w"

PRIVATE void
psar_init(const PSAR psar,int length)
{
psar->t_psl_length= length;
psar->t_first_psl= psar->t_first_free_psl= psl_new(psar);
}
/*:1300*//*1301:*/
#line 15528 "./marpa.w"

PRIVATE void psar_destroy(const PSAR psar)
{
PSL psl= psar->t_first_psl;
while(psl)
{
PSL next_psl= psl->t_next;
PSL*owner= psl->t_owner;
if(owner)
*owner= NULL;
my_free(psl);
psl= next_psl;
}
}
/*:1301*//*1302:*/
#line 15542 "./marpa.w"

PRIVATE PSL psl_new(const PSAR psar)
{
int i;
PSL new_psl= my_malloc(Sizeof_PSL(psar));
new_psl->t_next= NULL;
new_psl->t_prev= NULL;
new_psl->t_owner= NULL;
for(i= 0;i<psar->t_psl_length;i++){
PSL_Datum(new_psl,i)= NULL;
}
return new_psl;
}
/*:1302*//*1305:*/
#line 15573 "./marpa.w"

PRIVATE void psar_reset(const PSAR psar)
{
PSL psl= psar->t_first_psl;
while(psl&&psl->t_owner){
int i;
for(i= 0;i<psar->t_psl_length;i++){
PSL_Datum(psl,i)= NULL;
}
psl= psl->t_next;
}
psar_dealloc(psar);
}

/*:1305*//*1307:*/
#line 15591 "./marpa.w"

PRIVATE void psar_dealloc(const PSAR psar)
{
PSL psl= psar->t_first_psl;
while(psl){
PSL*owner= psl->t_owner;
if(!owner)break;
(*owner)= NULL;
psl->t_owner= NULL;
psl= psl->t_next;
}
psar->t_first_free_psl= psar->t_first_psl;
}

/*:1307*//*1309:*/
#line 15611 "./marpa.w"

PRIVATE void psl_claim(
PSL*const psl_owner,const PSAR psar)
{
PSL new_psl= psl_alloc(psar);
(*psl_owner)= new_psl;
new_psl->t_owner= psl_owner;
}


/*:1309*//*1310:*/
#line 15621 "./marpa.w"

PRIVATE PSL psl_claim_by_es(
PSAR or_psar,
struct s_bocage_setup_per_ys*per_ys_data,
YSID ysid)
{
PSL*psl_owner= &(per_ys_data[ysid].t_or_psl);
if(!*psl_owner)
psl_claim(psl_owner,or_psar);
return*psl_owner;
}

/*:1310*//*1311:*/
#line 15638 "./marpa.w"

PRIVATE PSL psl_alloc(const PSAR psar)
{
PSL free_psl= psar->t_first_free_psl;
PSL next_psl= free_psl->t_next;
if(!next_psl){
next_psl= free_psl->t_next= psl_new(psar);
next_psl->t_prev= free_psl;
}
psar->t_first_free_psl= next_psl;
return free_psl;
}

/*:1311*//*1339:*/
#line 15870 "./marpa.w"

PRIVATE_NOT_INLINE void
set_error(GRAMMAR g,Marpa_Error_Code code,const char*message,unsigned int flags)
{
g->t_error= code;
g->t_error_string= message;
if(flags&FATAL_FLAG)
g->t_is_ok= 0;
}
/*:1339*//*1340:*/
#line 15889 "./marpa.w"

PRIVATE Marpa_Error_Code
clear_error(GRAMMAR g)
{
if(!IS_G_OK(g))
{
if(g->t_error==MARPA_ERR_NONE)
g->t_error= MARPA_ERR_I_AM_NOT_OK;
return g->t_error;
}
g->t_error= MARPA_ERR_NONE;
g->t_error_string= NULL;
return MARPA_ERR_NONE;
}

/*:1340*//*1344:*/
#line 15932 "./marpa.w"

PRIVATE_NOT_INLINE void*
marpa__default_out_of_memory(void)
{
abort();
return NULL;
}
void*(*const marpa__out_of_memory)(void)= marpa__default_out_of_memory;

/*:1344*//*1349:*/
#line 15970 "./marpa.w"

Marpa_Earley_Set_ID _marpa_r_trace_earley_set(Marpa_Recognizer r)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 15973 "./marpa.w"

/*563:*/
#line 6125 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:563*/
#line 15974 "./marpa.w"

YS trace_earley_set= r->t_trace_earley_set;
/*1335:*/
#line 15814 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 15815 "./marpa.w"

/*1333:*/
#line 15798 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1333*/
#line 15816 "./marpa.w"


/*:1335*/
#line 15976 "./marpa.w"

if(!trace_earley_set){
MARPA_ERROR(MARPA_ERR_NO_TRACE_YS);
return failure_indicator;
}
return Ord_of_YS(trace_earley_set);
}

/*:1349*//*1350:*/
#line 15984 "./marpa.w"

Marpa_Earley_Set_ID marpa_r_latest_earley_set(Marpa_Recognizer r)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 15987 "./marpa.w"

/*563:*/
#line 6125 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:563*/
#line 15988 "./marpa.w"

/*1335:*/
#line 15814 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 15815 "./marpa.w"

/*1333:*/
#line 15798 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1333*/
#line 15816 "./marpa.w"


/*:1335*/
#line 15989 "./marpa.w"

if(G_is_Trivial(g))return 0;
return Ord_of_YS(Latest_YS_of_R(r));
}

/*:1350*//*1351:*/
#line 15994 "./marpa.w"

Marpa_Earleme marpa_r_earleme(Marpa_Recognizer r,Marpa_Earley_Set_ID set_id)
{
/*563:*/
#line 6125 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:563*/
#line 15997 "./marpa.w"

/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 15998 "./marpa.w"

YS earley_set;
/*1333:*/
#line 15798 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1333*/
#line 16000 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 16001 "./marpa.w"

if(set_id<0){
MARPA_ERROR(MARPA_ERR_INVALID_LOCATION);
return failure_indicator;
}
r_update_earley_sets(r);
if(!YS_Ord_is_Valid(r,set_id))
{
MARPA_ERROR(MARPA_ERR_NO_EARLEY_SET_AT_LOCATION);
return failure_indicator;
}
earley_set= YS_of_R_by_Ord(r,set_id);
return Earleme_of_YS(earley_set);
}

/*:1351*//*1353:*/
#line 16019 "./marpa.w"

int _marpa_r_earley_set_size(Marpa_Recognizer r,Marpa_Earley_Set_ID set_id)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 16022 "./marpa.w"

YS earley_set;
/*563:*/
#line 6125 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:563*/
#line 16024 "./marpa.w"

/*1333:*/
#line 15798 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1333*/
#line 16025 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 16026 "./marpa.w"

r_update_earley_sets(r);
if(!YS_Ord_is_Valid(r,set_id))
{
MARPA_ERROR(MARPA_ERR_INVALID_LOCATION);
return failure_indicator;
}
earley_set= YS_of_R_by_Ord(r,set_id);
return YIM_Count_of_YS(earley_set);
}

/*:1353*//*1358:*/
#line 16068 "./marpa.w"

Marpa_Earleme
_marpa_r_earley_set_trace(Marpa_Recognizer r,Marpa_Earley_Set_ID set_id)
{
YS earley_set;
const int es_does_not_exist= -1;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 16074 "./marpa.w"

/*563:*/
#line 6125 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:563*/
#line 16075 "./marpa.w"

/*1335:*/
#line 15814 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 15815 "./marpa.w"

/*1333:*/
#line 15798 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1333*/
#line 15816 "./marpa.w"


/*:1335*/
#line 16076 "./marpa.w"

if(r->t_trace_earley_set&&Ord_of_YS(r->t_trace_earley_set)==set_id)
{


return Earleme_of_YS(r->t_trace_earley_set);
}
/*1359:*/
#line 16099 "./marpa.w"
{
r->t_trace_earley_set= NULL;
trace_earley_item_clear(r);
/*1371:*/
#line 16288 "./marpa.w"

r->t_trace_pim_nsy_p= NULL;
r->t_trace_postdot_item= NULL;

/*:1371*/
#line 16102 "./marpa.w"

}

/*:1359*/
#line 16083 "./marpa.w"

if(set_id<0)
{
MARPA_ERROR(MARPA_ERR_INVALID_LOCATION);
return failure_indicator;
}
r_update_earley_sets(r);
if(set_id>=MARPA_DSTACK_LENGTH(r->t_earley_set_stack))
{
return es_does_not_exist;
}
earley_set= YS_of_R_by_Ord(r,set_id);
r->t_trace_earley_set= earley_set;
return Earleme_of_YS(earley_set);
}

/*:1358*//*1360:*/
#line 16105 "./marpa.w"

Marpa_AHM_ID
_marpa_r_earley_item_trace(Marpa_Recognizer r,Marpa_Earley_Item_ID item_id)
{
const int yim_does_not_exist= -1;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 16110 "./marpa.w"

YS trace_earley_set;
YIM earley_item;
YIM*earley_items;
/*563:*/
#line 6125 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:563*/
#line 16114 "./marpa.w"

/*1335:*/
#line 15814 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 15815 "./marpa.w"

/*1333:*/
#line 15798 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1333*/
#line 15816 "./marpa.w"


/*:1335*/
#line 16115 "./marpa.w"

trace_earley_set= r->t_trace_earley_set;
if(!trace_earley_set)
{
/*1359:*/
#line 16099 "./marpa.w"
{
r->t_trace_earley_set= NULL;
trace_earley_item_clear(r);
/*1371:*/
#line 16288 "./marpa.w"

r->t_trace_pim_nsy_p= NULL;
r->t_trace_postdot_item= NULL;

/*:1371*/
#line 16102 "./marpa.w"

}

/*:1359*/
#line 16119 "./marpa.w"

MARPA_ERROR(MARPA_ERR_NO_TRACE_YS);
return failure_indicator;
}
trace_earley_item_clear(r);
if(item_id<0)
{
MARPA_ERROR(MARPA_ERR_YIM_ID_INVALID);
return failure_indicator;
}
if(item_id>=YIM_Count_of_YS(trace_earley_set))
{
return yim_does_not_exist;
}
earley_items= YIMs_of_YS(trace_earley_set);
earley_item= earley_items[item_id];
r->t_trace_earley_item= earley_item;
return AHMID_of_YIM(earley_item);
}

/*:1360*//*1362:*/
#line 16148 "./marpa.w"

PRIVATE void trace_earley_item_clear(RECCE r)
{
/*1361:*/
#line 16145 "./marpa.w"

r->t_trace_earley_item= NULL;

/*:1361*/
#line 16151 "./marpa.w"

trace_source_link_clear(r);
}

/*:1362*//*1363:*/
#line 16155 "./marpa.w"

Marpa_Earley_Set_ID _marpa_r_earley_item_origin(Marpa_Recognizer r)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 16158 "./marpa.w"

YIM item= r->t_trace_earley_item;
/*563:*/
#line 6125 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:563*/
#line 16160 "./marpa.w"

/*1335:*/
#line 15814 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 15815 "./marpa.w"

/*1333:*/
#line 15798 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1333*/
#line 15816 "./marpa.w"


/*:1335*/
#line 16161 "./marpa.w"

if(!item){
/*1361:*/
#line 16145 "./marpa.w"

r->t_trace_earley_item= NULL;

/*:1361*/
#line 16163 "./marpa.w"

MARPA_ERROR(MARPA_ERR_NO_TRACE_YIM);
return failure_indicator;
}
return Origin_Ord_of_YIM(item);
}

/*:1363*//*1365:*/
#line 16175 "./marpa.w"

Marpa_Symbol_ID _marpa_r_leo_predecessor_symbol(Marpa_Recognizer r)
{
const Marpa_Symbol_ID no_predecessor= -1;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 16179 "./marpa.w"

PIM postdot_item= r->t_trace_postdot_item;
LIM predecessor_leo_item;
/*563:*/
#line 6125 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:563*/
#line 16182 "./marpa.w"

/*1335:*/
#line 15814 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 15815 "./marpa.w"

/*1333:*/
#line 15798 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1333*/
#line 15816 "./marpa.w"


/*:1335*/
#line 16183 "./marpa.w"

if(!postdot_item){
MARPA_ERROR(MARPA_ERR_NO_TRACE_PIM);
return failure_indicator;
}
if(YIM_of_PIM(postdot_item)){
MARPA_ERROR(MARPA_ERR_PIM_IS_NOT_LIM);
return failure_indicator;
}
predecessor_leo_item= Predecessor_LIM_of_LIM(LIM_of_PIM(postdot_item));
if(!predecessor_leo_item)return no_predecessor;
return Postdot_NSYID_of_LIM(predecessor_leo_item);
}

/*:1365*//*1366:*/
#line 16197 "./marpa.w"

Marpa_Earley_Set_ID _marpa_r_leo_base_origin(Marpa_Recognizer r)
{
const JEARLEME pim_is_not_a_leo_item= -1;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 16201 "./marpa.w"

PIM postdot_item= r->t_trace_postdot_item;
/*563:*/
#line 6125 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:563*/
#line 16203 "./marpa.w"

YIM base_earley_item;
/*1335:*/
#line 15814 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 15815 "./marpa.w"

/*1333:*/
#line 15798 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1333*/
#line 15816 "./marpa.w"


/*:1335*/
#line 16205 "./marpa.w"

if(!postdot_item){
MARPA_ERROR(MARPA_ERR_NO_TRACE_PIM);
return failure_indicator;
}
if(YIM_of_PIM(postdot_item))return pim_is_not_a_leo_item;
base_earley_item= Trailhead_YIM_of_LIM(LIM_of_PIM(postdot_item));
return Origin_Ord_of_YIM(base_earley_item);
}

/*:1366*//*1367:*/
#line 16216 "./marpa.w"

Marpa_AHM_ID _marpa_r_leo_base_state(Marpa_Recognizer r)
{
const JEARLEME pim_is_not_a_leo_item= -1;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 16220 "./marpa.w"

PIM postdot_item= r->t_trace_postdot_item;
YIM base_earley_item;
/*563:*/
#line 6125 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:563*/
#line 16223 "./marpa.w"

/*1335:*/
#line 15814 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 15815 "./marpa.w"

/*1333:*/
#line 15798 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1333*/
#line 15816 "./marpa.w"


/*:1335*/
#line 16224 "./marpa.w"

if(!postdot_item){
MARPA_ERROR(MARPA_ERR_NO_TRACE_PIM);
return failure_indicator;
}
if(YIM_of_PIM(postdot_item))return pim_is_not_a_leo_item;
base_earley_item= Trailhead_YIM_of_LIM(LIM_of_PIM(postdot_item));
return AHMID_of_YIM(base_earley_item);
}

/*:1367*//*1370:*/
#line 16262 "./marpa.w"

Marpa_Symbol_ID
_marpa_r_postdot_symbol_trace(Marpa_Recognizer r,
Marpa_Symbol_ID nsy_id)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 16267 "./marpa.w"

YS current_ys= r->t_trace_earley_set;
PIM*pim_nsy_p;
PIM pim;
/*563:*/
#line 6125 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:563*/
#line 16271 "./marpa.w"

/*1371:*/
#line 16288 "./marpa.w"

r->t_trace_pim_nsy_p= NULL;
r->t_trace_postdot_item= NULL;

/*:1371*/
#line 16272 "./marpa.w"

/*1335:*/
#line 15814 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 15815 "./marpa.w"

/*1333:*/
#line 15798 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1333*/
#line 15816 "./marpa.w"


/*:1335*/
#line 16273 "./marpa.w"

/*1323:*/
#line 15728 "./marpa.w"

if(_MARPA_UNLIKELY(NSYID_is_Malformed(nsy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1323*/
#line 16274 "./marpa.w"

/*1324:*/
#line 15735 "./marpa.w"

if(_MARPA_UNLIKELY(!NSYID_of_G_Exists(nsy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}

/*:1324*/
#line 16275 "./marpa.w"

if(!current_ys){
MARPA_ERROR(MARPA_ERR_NO_TRACE_YS);
return failure_indicator;
}
pim_nsy_p= PIM_NSY_P_of_YS_by_NSYID(current_ys,nsy_id);
pim= *pim_nsy_p;
if(!pim)return-1;
r->t_trace_pim_nsy_p= pim_nsy_p;
r->t_trace_postdot_item= pim;
return nsy_id;
}

/*:1370*//*1372:*/
#line 16298 "./marpa.w"

Marpa_Symbol_ID
_marpa_r_first_postdot_item_trace(Marpa_Recognizer r)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 16302 "./marpa.w"

YS current_earley_set= r->t_trace_earley_set;
PIM pim;
/*563:*/
#line 6125 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:563*/
#line 16305 "./marpa.w"

PIM*pim_nsy_p;
/*1371:*/
#line 16288 "./marpa.w"

r->t_trace_pim_nsy_p= NULL;
r->t_trace_postdot_item= NULL;

/*:1371*/
#line 16307 "./marpa.w"

/*1335:*/
#line 15814 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 15815 "./marpa.w"

/*1333:*/
#line 15798 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1333*/
#line 15816 "./marpa.w"


/*:1335*/
#line 16308 "./marpa.w"

if(!current_earley_set){
/*1361:*/
#line 16145 "./marpa.w"

r->t_trace_earley_item= NULL;

/*:1361*/
#line 16310 "./marpa.w"

MARPA_ERROR(MARPA_ERR_NO_TRACE_YS);
return failure_indicator;
}
if(current_earley_set->t_postdot_sym_count<=0)return-1;
pim_nsy_p= current_earley_set->t_postdot_ary+0;
pim= pim_nsy_p[0];
r->t_trace_pim_nsy_p= pim_nsy_p;
r->t_trace_postdot_item= pim;
return Postdot_NSYID_of_PIM(pim);
}

/*:1372*//*1373:*/
#line 16329 "./marpa.w"

Marpa_Symbol_ID
_marpa_r_next_postdot_item_trace(Marpa_Recognizer r)
{
const ISYID no_more_postdot_symbols= -1;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 16334 "./marpa.w"

YS current_set= r->t_trace_earley_set;
PIM pim;
PIM*pim_nsy_p;
/*563:*/
#line 6125 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:563*/
#line 16338 "./marpa.w"


pim_nsy_p= r->t_trace_pim_nsy_p;
pim= r->t_trace_postdot_item;
/*1371:*/
#line 16288 "./marpa.w"

r->t_trace_pim_nsy_p= NULL;
r->t_trace_postdot_item= NULL;

/*:1371*/
#line 16342 "./marpa.w"

if(!pim_nsy_p||!pim){
MARPA_ERROR(MARPA_ERR_NO_TRACE_PIM);
return failure_indicator;
}
/*1335:*/
#line 15814 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 15815 "./marpa.w"

/*1333:*/
#line 15798 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1333*/
#line 15816 "./marpa.w"


/*:1335*/
#line 16347 "./marpa.w"

if(!current_set){
MARPA_ERROR(MARPA_ERR_NO_TRACE_YS);
return failure_indicator;
}
pim= Next_PIM_of_PIM(pim);
if(!pim){

pim_nsy_p++;
if(pim_nsy_p-current_set->t_postdot_ary
>=current_set->t_postdot_sym_count){
return no_more_postdot_symbols;
}
pim= *pim_nsy_p;
}
r->t_trace_pim_nsy_p= pim_nsy_p;
r->t_trace_postdot_item= pim;
return Postdot_NSYID_of_PIM(pim);
}

/*:1373*//*1374:*/
#line 16367 "./marpa.w"

Marpa_Symbol_ID _marpa_r_postdot_item_symbol(Marpa_Recognizer r)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 16370 "./marpa.w"

PIM postdot_item= r->t_trace_postdot_item;
/*563:*/
#line 6125 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:563*/
#line 16372 "./marpa.w"

/*1335:*/
#line 15814 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 15815 "./marpa.w"

/*1333:*/
#line 15798 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1333*/
#line 15816 "./marpa.w"


/*:1335*/
#line 16373 "./marpa.w"

if(!postdot_item){
MARPA_ERROR(MARPA_ERR_NO_TRACE_PIM);
return failure_indicator;
}
return Postdot_NSYID_of_PIM(postdot_item);
}

/*:1374*//*1379:*/
#line 16403 "./marpa.w"

Marpa_Symbol_ID _marpa_r_first_token_link_trace(Marpa_Recognizer r)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 16406 "./marpa.w"

SRCL source_link;
unsigned int source_type;
YIM item= r->t_trace_earley_item;
/*563:*/
#line 6125 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:563*/
#line 16410 "./marpa.w"

/*1335:*/
#line 15814 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 15815 "./marpa.w"

/*1333:*/
#line 15798 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1333*/
#line 15816 "./marpa.w"


/*:1335*/
#line 16411 "./marpa.w"

/*1393:*/
#line 16600 "./marpa.w"

item= r->t_trace_earley_item;
if(!item){
trace_source_link_clear(r);
MARPA_ERROR(MARPA_ERR_NO_TRACE_YIM);
return failure_indicator;
}

/*:1393*/
#line 16412 "./marpa.w"

source_type= Source_Type_of_YIM(item);
switch(source_type)
{
case SOURCE_IS_TOKEN:
r->t_trace_source_type= SOURCE_IS_TOKEN;
source_link= SRCL_of_YIM(item);
r->t_trace_source_link= source_link;
return NSYID_of_SRCL(source_link);
case SOURCE_IS_AMBIGUOUS:
{
source_link= LV_First_Token_SRCL_of_YIM(item);
if(source_link)
{
r->t_trace_source_type= SOURCE_IS_TOKEN;
r->t_trace_source_link= source_link;
return NSYID_of_SRCL(source_link);
}
}
}
trace_source_link_clear(r);
return-1;
}

/*:1379*//*1382:*/
#line 16444 "./marpa.w"

Marpa_Symbol_ID _marpa_r_next_token_link_trace(Marpa_Recognizer r)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 16447 "./marpa.w"

SRCL source_link;
YIM item;
/*563:*/
#line 6125 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:563*/
#line 16450 "./marpa.w"

/*1335:*/
#line 15814 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 15815 "./marpa.w"

/*1333:*/
#line 15798 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1333*/
#line 15816 "./marpa.w"


/*:1335*/
#line 16451 "./marpa.w"

/*1393:*/
#line 16600 "./marpa.w"

item= r->t_trace_earley_item;
if(!item){
trace_source_link_clear(r);
MARPA_ERROR(MARPA_ERR_NO_TRACE_YIM);
return failure_indicator;
}

/*:1393*/
#line 16452 "./marpa.w"

if(r->t_trace_source_type!=SOURCE_IS_TOKEN){
trace_source_link_clear(r);
MARPA_ERROR(MARPA_ERR_NOT_TRACING_TOKEN_LINKS);
return failure_indicator;
}
source_link= Next_SRCL_of_SRCL(r->t_trace_source_link);
if(!source_link){
trace_source_link_clear(r);
return-1;
}
r->t_trace_source_link= source_link;
return NSYID_of_SRCL(source_link);
}

/*:1382*//*1384:*/
#line 16475 "./marpa.w"

Marpa_Symbol_ID _marpa_r_first_completion_link_trace(Marpa_Recognizer r)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 16478 "./marpa.w"

SRCL source_link;
unsigned int source_type;
YIM item= r->t_trace_earley_item;
/*563:*/
#line 6125 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:563*/
#line 16482 "./marpa.w"

/*1335:*/
#line 15814 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 15815 "./marpa.w"

/*1333:*/
#line 15798 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1333*/
#line 15816 "./marpa.w"


/*:1335*/
#line 16483 "./marpa.w"

/*1393:*/
#line 16600 "./marpa.w"

item= r->t_trace_earley_item;
if(!item){
trace_source_link_clear(r);
MARPA_ERROR(MARPA_ERR_NO_TRACE_YIM);
return failure_indicator;
}

/*:1393*/
#line 16484 "./marpa.w"

switch((source_type= Source_Type_of_YIM(item)))
{
case SOURCE_IS_COMPLETION:
r->t_trace_source_type= SOURCE_IS_COMPLETION;
source_link= SRCL_of_YIM(item);
r->t_trace_source_link= source_link;
return Cause_AHMID_of_SRCL(source_link);
case SOURCE_IS_AMBIGUOUS:
{
source_link= LV_First_Completion_SRCL_of_YIM(item);
if(source_link)
{
r->t_trace_source_type= SOURCE_IS_COMPLETION;
r->t_trace_source_link= source_link;
return Cause_AHMID_of_SRCL(source_link);
}
}
}
trace_source_link_clear(r);
return-1;
}

/*:1384*//*1387:*/
#line 16515 "./marpa.w"

Marpa_Symbol_ID _marpa_r_next_completion_link_trace(Marpa_Recognizer r)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 16518 "./marpa.w"

SRCL source_link;
YIM item;
/*563:*/
#line 6125 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:563*/
#line 16521 "./marpa.w"

/*1335:*/
#line 15814 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 15815 "./marpa.w"

/*1333:*/
#line 15798 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1333*/
#line 15816 "./marpa.w"


/*:1335*/
#line 16522 "./marpa.w"

/*1393:*/
#line 16600 "./marpa.w"

item= r->t_trace_earley_item;
if(!item){
trace_source_link_clear(r);
MARPA_ERROR(MARPA_ERR_NO_TRACE_YIM);
return failure_indicator;
}

/*:1393*/
#line 16523 "./marpa.w"

if(r->t_trace_source_type!=SOURCE_IS_COMPLETION){
trace_source_link_clear(r);
MARPA_ERROR(MARPA_ERR_NOT_TRACING_COMPLETION_LINKS);
return failure_indicator;
}
source_link= Next_SRCL_of_SRCL(r->t_trace_source_link);
if(!source_link){
trace_source_link_clear(r);
return-1;
}
r->t_trace_source_link= source_link;
return Cause_AHMID_of_SRCL(source_link);
}

/*:1387*//*1389:*/
#line 16546 "./marpa.w"

Marpa_Symbol_ID
_marpa_r_first_leo_link_trace(Marpa_Recognizer r)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 16550 "./marpa.w"

SRCL source_link;
YIM item= r->t_trace_earley_item;
/*563:*/
#line 6125 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:563*/
#line 16553 "./marpa.w"

/*1335:*/
#line 15814 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 15815 "./marpa.w"

/*1333:*/
#line 15798 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1333*/
#line 15816 "./marpa.w"


/*:1335*/
#line 16554 "./marpa.w"

/*1393:*/
#line 16600 "./marpa.w"

item= r->t_trace_earley_item;
if(!item){
trace_source_link_clear(r);
MARPA_ERROR(MARPA_ERR_NO_TRACE_YIM);
return failure_indicator;
}

/*:1393*/
#line 16555 "./marpa.w"

source_link= First_Leo_SRCL_of_YIM(item);
if(source_link){
r->t_trace_source_type= SOURCE_IS_LEO;
r->t_trace_source_link= source_link;
return Cause_AHMID_of_SRCL(source_link);
}
trace_source_link_clear(r);
return-1;
}

/*:1389*//*1392:*/
#line 16574 "./marpa.w"

Marpa_Symbol_ID
_marpa_r_next_leo_link_trace(Marpa_Recognizer r)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 16578 "./marpa.w"

SRCL source_link;
YIM item;
/*563:*/
#line 6125 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:563*/
#line 16581 "./marpa.w"

/*1335:*/
#line 15814 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 15815 "./marpa.w"

/*1333:*/
#line 15798 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1333*/
#line 15816 "./marpa.w"


/*:1335*/
#line 16582 "./marpa.w"

/*1393:*/
#line 16600 "./marpa.w"

item= r->t_trace_earley_item;
if(!item){
trace_source_link_clear(r);
MARPA_ERROR(MARPA_ERR_NO_TRACE_YIM);
return failure_indicator;
}

/*:1393*/
#line 16583 "./marpa.w"

if(r->t_trace_source_type!=SOURCE_IS_LEO)
{
trace_source_link_clear(r);
MARPA_ERROR(MARPA_ERR_NOT_TRACING_LEO_LINKS);
return failure_indicator;
}
source_link= Next_SRCL_of_SRCL(r->t_trace_source_link);
if(!source_link)
{
trace_source_link_clear(r);
return-1;
}
r->t_trace_source_link= source_link;
return Cause_AHMID_of_SRCL(source_link);
}

/*:1392*//*1394:*/
#line 16609 "./marpa.w"

PRIVATE void trace_source_link_clear(RECCE r)
{
r->t_trace_source_link= NULL;
r->t_trace_source_type= NO_SOURCE;
}

/*:1394*//*1395:*/
#line 16624 "./marpa.w"

AHMID _marpa_r_source_predecessor_state(Marpa_Recognizer r)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 16627 "./marpa.w"

unsigned int source_type;
SRCL source_link;
/*563:*/
#line 6125 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:563*/
#line 16630 "./marpa.w"

/*1335:*/
#line 15814 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 15815 "./marpa.w"

/*1333:*/
#line 15798 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1333*/
#line 15816 "./marpa.w"


/*:1335*/
#line 16631 "./marpa.w"

source_type= r->t_trace_source_type;
/*1401:*/
#line 16776 "./marpa.w"

source_link= r->t_trace_source_link;
if(!source_link){
MARPA_ERROR(MARPA_ERR_NO_TRACE_SRCL);
return failure_indicator;
}

/*:1401*/
#line 16633 "./marpa.w"

switch(source_type)
{
case SOURCE_IS_TOKEN:
case SOURCE_IS_COMPLETION:{
YIM predecessor= Predecessor_of_SRCL(source_link);
if(!predecessor)return-1;
return AHMID_of_YIM(predecessor);
}
}
MARPA_ERROR(invalid_source_type_code(source_type));
return failure_indicator;
}

/*:1395*//*1396:*/
#line 16665 "./marpa.w"

Marpa_Symbol_ID _marpa_r_source_token(Marpa_Recognizer r,int*value_p)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 16668 "./marpa.w"

unsigned int source_type;
SRCL source_link;
/*563:*/
#line 6125 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:563*/
#line 16671 "./marpa.w"

/*1335:*/
#line 15814 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 15815 "./marpa.w"

/*1333:*/
#line 15798 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1333*/
#line 15816 "./marpa.w"


/*:1335*/
#line 16672 "./marpa.w"

source_type= r->t_trace_source_type;
/*1401:*/
#line 16776 "./marpa.w"

source_link= r->t_trace_source_link;
if(!source_link){
MARPA_ERROR(MARPA_ERR_NO_TRACE_SRCL);
return failure_indicator;
}

/*:1401*/
#line 16674 "./marpa.w"

if(source_type==SOURCE_IS_TOKEN){
if(value_p)*value_p= Value_of_SRCL(source_link);
return NSYID_of_SRCL(source_link);
}
MARPA_ERROR(invalid_source_type_code(source_type));
return failure_indicator;
}

/*:1396*//*1398:*/
#line 16696 "./marpa.w"

Marpa_Symbol_ID _marpa_r_source_leo_transition_symbol(Marpa_Recognizer r)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 16699 "./marpa.w"

unsigned int source_type;
SRCL source_link;
/*563:*/
#line 6125 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:563*/
#line 16702 "./marpa.w"

/*1335:*/
#line 15814 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 15815 "./marpa.w"

/*1333:*/
#line 15798 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1333*/
#line 15816 "./marpa.w"


/*:1335*/
#line 16703 "./marpa.w"

source_type= r->t_trace_source_type;
/*1401:*/
#line 16776 "./marpa.w"

source_link= r->t_trace_source_link;
if(!source_link){
MARPA_ERROR(MARPA_ERR_NO_TRACE_SRCL);
return failure_indicator;
}

/*:1401*/
#line 16705 "./marpa.w"

switch(source_type)
{
case SOURCE_IS_LEO:
return Leo_Transition_NSYID_of_SRCL(source_link);
}
MARPA_ERROR(invalid_source_type_code(source_type));
return failure_indicator;
}

/*:1398*//*1400:*/
#line 16739 "./marpa.w"

Marpa_Earley_Set_ID _marpa_r_source_middle(Marpa_Recognizer r)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 16742 "./marpa.w"

YIM predecessor_yim= NULL;
unsigned int source_type;
SRCL source_link;
/*563:*/
#line 6125 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:563*/
#line 16746 "./marpa.w"

/*1335:*/
#line 15814 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 15815 "./marpa.w"

/*1333:*/
#line 15798 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1333*/
#line 15816 "./marpa.w"


/*:1335*/
#line 16747 "./marpa.w"

source_type= r->t_trace_source_type;
/*1401:*/
#line 16776 "./marpa.w"

source_link= r->t_trace_source_link;
if(!source_link){
MARPA_ERROR(MARPA_ERR_NO_TRACE_SRCL);
return failure_indicator;
}

/*:1401*/
#line 16749 "./marpa.w"


switch(source_type)
{
case SOURCE_IS_LEO:
{
LIM predecessor= LIM_of_SRCL(source_link);
if(predecessor)
predecessor_yim= Trailhead_YIM_of_LIM(predecessor);
break;
}
case SOURCE_IS_TOKEN:
case SOURCE_IS_COMPLETION:
{
predecessor_yim= Predecessor_of_SRCL(source_link);
break;
}
default:
MARPA_ERROR(invalid_source_type_code(source_type));
return failure_indicator;
}

if(predecessor_yim)
return YS_Ord_of_YIM(predecessor_yim);
return Origin_Ord_of_YIM(r->t_trace_earley_item);
}

/*:1400*//*1405:*/
#line 16814 "./marpa.w"

int _marpa_b_or_node_set(Marpa_Bocage b,
Marpa_Or_Node_ID or_node_id)
{
OR or_node;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 16819 "./marpa.w"

/*1047:*/
#line 12198 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1047*/
#line 16820 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 16821 "./marpa.w"

/*1403:*/
#line 16792 "./marpa.w"

{
if(_MARPA_UNLIKELY(or_node_id>=OR_Count_of_B(b)))
{
return-1;
}
if(_MARPA_UNLIKELY(or_node_id<0))
{
MARPA_ERROR(MARPA_ERR_ORID_NEGATIVE);
return failure_indicator;
}
}
/*:1403*/
#line 16822 "./marpa.w"

/*1404:*/
#line 16804 "./marpa.w"

{
if(_MARPA_UNLIKELY(!ORs_of_B(b)))
{
MARPA_ERROR(MARPA_ERR_NO_OR_NODES);
return failure_indicator;
}
or_node= OR_of_B_by_ID(b,or_node_id);
}

/*:1404*/
#line 16823 "./marpa.w"

return YS_Ord_of_OR(or_node);
}

/*:1405*//*1406:*/
#line 16827 "./marpa.w"

int _marpa_b_or_node_origin(Marpa_Bocage b,
Marpa_Or_Node_ID or_node_id)
{
OR or_node;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 16832 "./marpa.w"

/*1047:*/
#line 12198 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1047*/
#line 16833 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 16834 "./marpa.w"

/*1403:*/
#line 16792 "./marpa.w"

{
if(_MARPA_UNLIKELY(or_node_id>=OR_Count_of_B(b)))
{
return-1;
}
if(_MARPA_UNLIKELY(or_node_id<0))
{
MARPA_ERROR(MARPA_ERR_ORID_NEGATIVE);
return failure_indicator;
}
}
/*:1403*/
#line 16835 "./marpa.w"

/*1404:*/
#line 16804 "./marpa.w"

{
if(_MARPA_UNLIKELY(!ORs_of_B(b)))
{
MARPA_ERROR(MARPA_ERR_NO_OR_NODES);
return failure_indicator;
}
or_node= OR_of_B_by_ID(b,or_node_id);
}

/*:1404*/
#line 16836 "./marpa.w"

return Origin_Ord_of_OR(or_node);
}

/*:1406*//*1407:*/
#line 16840 "./marpa.w"

Marpa_NRL_ID _marpa_b_or_node_nrl(Marpa_Bocage b,
Marpa_Or_Node_ID or_node_id)
{
OR or_node;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 16845 "./marpa.w"

/*1047:*/
#line 12198 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1047*/
#line 16846 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 16847 "./marpa.w"

/*1403:*/
#line 16792 "./marpa.w"

{
if(_MARPA_UNLIKELY(or_node_id>=OR_Count_of_B(b)))
{
return-1;
}
if(_MARPA_UNLIKELY(or_node_id<0))
{
MARPA_ERROR(MARPA_ERR_ORID_NEGATIVE);
return failure_indicator;
}
}
/*:1403*/
#line 16848 "./marpa.w"

/*1404:*/
#line 16804 "./marpa.w"

{
if(_MARPA_UNLIKELY(!ORs_of_B(b)))
{
MARPA_ERROR(MARPA_ERR_NO_OR_NODES);
return failure_indicator;
}
or_node= OR_of_B_by_ID(b,or_node_id);
}

/*:1404*/
#line 16849 "./marpa.w"

return NRLID_of_OR(or_node);
}

/*:1407*//*1408:*/
#line 16853 "./marpa.w"

int _marpa_b_or_node_position(Marpa_Bocage b,
Marpa_Or_Node_ID or_node_id)
{
OR or_node;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 16858 "./marpa.w"

/*1047:*/
#line 12198 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1047*/
#line 16859 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 16860 "./marpa.w"

/*1403:*/
#line 16792 "./marpa.w"

{
if(_MARPA_UNLIKELY(or_node_id>=OR_Count_of_B(b)))
{
return-1;
}
if(_MARPA_UNLIKELY(or_node_id<0))
{
MARPA_ERROR(MARPA_ERR_ORID_NEGATIVE);
return failure_indicator;
}
}
/*:1403*/
#line 16861 "./marpa.w"

/*1404:*/
#line 16804 "./marpa.w"

{
if(_MARPA_UNLIKELY(!ORs_of_B(b)))
{
MARPA_ERROR(MARPA_ERR_NO_OR_NODES);
return failure_indicator;
}
or_node= OR_of_B_by_ID(b,or_node_id);
}

/*:1404*/
#line 16862 "./marpa.w"

return Position_of_OR(or_node);
}

/*:1408*//*1409:*/
#line 16866 "./marpa.w"

int _marpa_b_or_node_is_whole(Marpa_Bocage b,
Marpa_Or_Node_ID or_node_id)
{
OR or_node;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 16871 "./marpa.w"

/*1047:*/
#line 12198 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1047*/
#line 16872 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 16873 "./marpa.w"

/*1403:*/
#line 16792 "./marpa.w"

{
if(_MARPA_UNLIKELY(or_node_id>=OR_Count_of_B(b)))
{
return-1;
}
if(_MARPA_UNLIKELY(or_node_id<0))
{
MARPA_ERROR(MARPA_ERR_ORID_NEGATIVE);
return failure_indicator;
}
}
/*:1403*/
#line 16874 "./marpa.w"

/*1404:*/
#line 16804 "./marpa.w"

{
if(_MARPA_UNLIKELY(!ORs_of_B(b)))
{
MARPA_ERROR(MARPA_ERR_NO_OR_NODES);
return failure_indicator;
}
or_node= OR_of_B_by_ID(b,or_node_id);
}

/*:1404*/
#line 16875 "./marpa.w"

return Position_of_OR(or_node)>=Length_of_NRL(NRL_of_OR(or_node))?1:0;
}

/*:1409*//*1410:*/
#line 16879 "./marpa.w"

int _marpa_b_or_node_is_semantic(Marpa_Bocage b,
Marpa_Or_Node_ID or_node_id)
{
OR or_node;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 16884 "./marpa.w"

/*1047:*/
#line 12198 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1047*/
#line 16885 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 16886 "./marpa.w"

/*1403:*/
#line 16792 "./marpa.w"

{
if(_MARPA_UNLIKELY(or_node_id>=OR_Count_of_B(b)))
{
return-1;
}
if(_MARPA_UNLIKELY(or_node_id<0))
{
MARPA_ERROR(MARPA_ERR_ORID_NEGATIVE);
return failure_indicator;
}
}
/*:1403*/
#line 16887 "./marpa.w"

/*1404:*/
#line 16804 "./marpa.w"

{
if(_MARPA_UNLIKELY(!ORs_of_B(b)))
{
MARPA_ERROR(MARPA_ERR_NO_OR_NODES);
return failure_indicator;
}
or_node= OR_of_B_by_ID(b,or_node_id);
}

/*:1404*/
#line 16888 "./marpa.w"

return!NRL_has_Virtual_LHS(NRL_of_OR(or_node));
}

/*:1410*//*1411:*/
#line 16892 "./marpa.w"

int _marpa_b_or_node_first_and(Marpa_Bocage b,
Marpa_Or_Node_ID or_node_id)
{
OR or_node;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 16897 "./marpa.w"

/*1047:*/
#line 12198 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1047*/
#line 16898 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 16899 "./marpa.w"

/*1403:*/
#line 16792 "./marpa.w"

{
if(_MARPA_UNLIKELY(or_node_id>=OR_Count_of_B(b)))
{
return-1;
}
if(_MARPA_UNLIKELY(or_node_id<0))
{
MARPA_ERROR(MARPA_ERR_ORID_NEGATIVE);
return failure_indicator;
}
}
/*:1403*/
#line 16900 "./marpa.w"

/*1404:*/
#line 16804 "./marpa.w"

{
if(_MARPA_UNLIKELY(!ORs_of_B(b)))
{
MARPA_ERROR(MARPA_ERR_NO_OR_NODES);
return failure_indicator;
}
or_node= OR_of_B_by_ID(b,or_node_id);
}

/*:1404*/
#line 16901 "./marpa.w"

return First_ANDID_of_OR(or_node);
}

/*:1411*//*1412:*/
#line 16905 "./marpa.w"

int _marpa_b_or_node_last_and(Marpa_Bocage b,
Marpa_Or_Node_ID or_node_id)
{
OR or_node;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 16910 "./marpa.w"

/*1047:*/
#line 12198 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1047*/
#line 16911 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 16912 "./marpa.w"

/*1403:*/
#line 16792 "./marpa.w"

{
if(_MARPA_UNLIKELY(or_node_id>=OR_Count_of_B(b)))
{
return-1;
}
if(_MARPA_UNLIKELY(or_node_id<0))
{
MARPA_ERROR(MARPA_ERR_ORID_NEGATIVE);
return failure_indicator;
}
}
/*:1403*/
#line 16913 "./marpa.w"

/*1404:*/
#line 16804 "./marpa.w"

{
if(_MARPA_UNLIKELY(!ORs_of_B(b)))
{
MARPA_ERROR(MARPA_ERR_NO_OR_NODES);
return failure_indicator;
}
or_node= OR_of_B_by_ID(b,or_node_id);
}

/*:1404*/
#line 16914 "./marpa.w"

return First_ANDID_of_OR(or_node)
+AND_Count_of_OR(or_node)-1;
}

/*:1412*//*1413:*/
#line 16919 "./marpa.w"

int _marpa_b_or_node_and_count(Marpa_Bocage b,
Marpa_Or_Node_ID or_node_id)
{
OR or_node;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 16924 "./marpa.w"

/*1047:*/
#line 12198 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1047*/
#line 16925 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 16926 "./marpa.w"

/*1403:*/
#line 16792 "./marpa.w"

{
if(_MARPA_UNLIKELY(or_node_id>=OR_Count_of_B(b)))
{
return-1;
}
if(_MARPA_UNLIKELY(or_node_id<0))
{
MARPA_ERROR(MARPA_ERR_ORID_NEGATIVE);
return failure_indicator;
}
}
/*:1403*/
#line 16927 "./marpa.w"

/*1404:*/
#line 16804 "./marpa.w"

{
if(_MARPA_UNLIKELY(!ORs_of_B(b)))
{
MARPA_ERROR(MARPA_ERR_NO_OR_NODES);
return failure_indicator;
}
or_node= OR_of_B_by_ID(b,or_node_id);
}

/*:1404*/
#line 16928 "./marpa.w"

return AND_Count_of_OR(or_node);
}

/*:1413*//*1416:*/
#line 16942 "./marpa.w"

int _marpa_o_or_node_and_node_count(Marpa_Order o,
Marpa_Or_Node_ID or_node_id)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 16946 "./marpa.w"

/*1092:*/
#line 12603 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1047:*/
#line 12198 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1047*/
#line 12605 "./marpa.w"


/*:1092*/
#line 16947 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 16948 "./marpa.w"

/*1403:*/
#line 16792 "./marpa.w"

{
if(_MARPA_UNLIKELY(or_node_id>=OR_Count_of_B(b)))
{
return-1;
}
if(_MARPA_UNLIKELY(or_node_id<0))
{
MARPA_ERROR(MARPA_ERR_ORID_NEGATIVE);
return failure_indicator;
}
}
/*:1403*/
#line 16949 "./marpa.w"

if(!O_is_Default(o))
{
ANDID**const and_node_orderings= o->t_and_node_orderings;
ANDID*ordering= and_node_orderings[or_node_id];
if(ordering)return ordering[0];
}
{
OR or_node;
/*1404:*/
#line 16804 "./marpa.w"

{
if(_MARPA_UNLIKELY(!ORs_of_B(b)))
{
MARPA_ERROR(MARPA_ERR_NO_OR_NODES);
return failure_indicator;
}
or_node= OR_of_B_by_ID(b,or_node_id);
}

/*:1404*/
#line 16958 "./marpa.w"

return AND_Count_of_OR(or_node);
}
}

/*:1416*//*1417:*/
#line 16963 "./marpa.w"

int _marpa_o_or_node_and_node_id_by_ix(Marpa_Order o,
Marpa_Or_Node_ID or_node_id,int ix)
{
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 16967 "./marpa.w"

/*1092:*/
#line 12603 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1047:*/
#line 12198 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1047*/
#line 12605 "./marpa.w"


/*:1092*/
#line 16968 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 16969 "./marpa.w"

/*1403:*/
#line 16792 "./marpa.w"

{
if(_MARPA_UNLIKELY(or_node_id>=OR_Count_of_B(b)))
{
return-1;
}
if(_MARPA_UNLIKELY(or_node_id<0))
{
MARPA_ERROR(MARPA_ERR_ORID_NEGATIVE);
return failure_indicator;
}
}
/*:1403*/
#line 16970 "./marpa.w"

if(!O_is_Default(o))
{
ANDID**const and_node_orderings= o->t_and_node_orderings;
ANDID*ordering= and_node_orderings[or_node_id];
if(ordering)return ordering[1+ix];
}
{
OR or_node;
/*1404:*/
#line 16804 "./marpa.w"

{
if(_MARPA_UNLIKELY(!ORs_of_B(b)))
{
MARPA_ERROR(MARPA_ERR_NO_OR_NODES);
return failure_indicator;
}
or_node= OR_of_B_by_ID(b,or_node_id);
}

/*:1404*/
#line 16979 "./marpa.w"

return First_ANDID_of_OR(or_node)+ix;
}
}

/*:1417*//*1419:*/
#line 16986 "./marpa.w"

int _marpa_b_and_node_count(Marpa_Bocage b)
{
/*1047:*/
#line 12198 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1047*/
#line 16989 "./marpa.w"

/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 16990 "./marpa.w"

/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 16991 "./marpa.w"

return AND_Count_of_B(b);
}

/*:1419*//*1421:*/
#line 17017 "./marpa.w"

int _marpa_b_and_node_parent(Marpa_Bocage b,
Marpa_And_Node_ID and_node_id)
{
AND and_node;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 17022 "./marpa.w"

/*1047:*/
#line 12198 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1047*/
#line 17023 "./marpa.w"

/*1420:*/
#line 16995 "./marpa.w"

{
if(and_node_id>=AND_Count_of_B(b))
{
return-1;
}
if(and_node_id<0)
{
MARPA_ERROR(MARPA_ERR_ANDID_NEGATIVE);
return failure_indicator;
}
{
AND and_nodes= ANDs_of_B(b);
if(!and_nodes)
{
MARPA_ERROR(MARPA_ERR_NO_AND_NODES);
return failure_indicator;
}
and_node= and_nodes+and_node_id;
}
}

/*:1420*/
#line 17024 "./marpa.w"

return ID_of_OR(OR_of_AND(and_node));
}

/*:1421*//*1422:*/
#line 17028 "./marpa.w"

int _marpa_b_and_node_predecessor(Marpa_Bocage b,
Marpa_And_Node_ID and_node_id)
{
AND and_node;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 17033 "./marpa.w"

/*1047:*/
#line 12198 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1047*/
#line 17034 "./marpa.w"

/*1420:*/
#line 16995 "./marpa.w"

{
if(and_node_id>=AND_Count_of_B(b))
{
return-1;
}
if(and_node_id<0)
{
MARPA_ERROR(MARPA_ERR_ANDID_NEGATIVE);
return failure_indicator;
}
{
AND and_nodes= ANDs_of_B(b);
if(!and_nodes)
{
MARPA_ERROR(MARPA_ERR_NO_AND_NODES);
return failure_indicator;
}
and_node= and_nodes+and_node_id;
}
}

/*:1420*/
#line 17035 "./marpa.w"

{
const OR predecessor_or= Predecessor_OR_of_AND(and_node);
const ORID predecessor_or_id= 
predecessor_or?ID_of_OR(predecessor_or):-1;
return predecessor_or_id;
}
}

/*:1422*//*1423:*/
#line 17044 "./marpa.w"

int _marpa_b_and_node_cause(Marpa_Bocage b,
Marpa_And_Node_ID and_node_id)
{
AND and_node;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 17049 "./marpa.w"

/*1047:*/
#line 12198 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1047*/
#line 17050 "./marpa.w"

/*1420:*/
#line 16995 "./marpa.w"

{
if(and_node_id>=AND_Count_of_B(b))
{
return-1;
}
if(and_node_id<0)
{
MARPA_ERROR(MARPA_ERR_ANDID_NEGATIVE);
return failure_indicator;
}
{
AND and_nodes= ANDs_of_B(b);
if(!and_nodes)
{
MARPA_ERROR(MARPA_ERR_NO_AND_NODES);
return failure_indicator;
}
and_node= and_nodes+and_node_id;
}
}

/*:1420*/
#line 17051 "./marpa.w"

{
const OR cause_or= Cause_OR_of_AND(and_node);
const ORID cause_or_id= 
OR_is_Token(cause_or)?-1:ID_of_OR(cause_or);
return cause_or_id;
}
}

/*:1423*//*1424:*/
#line 17060 "./marpa.w"

int _marpa_b_and_node_symbol(Marpa_Bocage b,
Marpa_And_Node_ID and_node_id)
{
AND and_node;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 17065 "./marpa.w"

/*1047:*/
#line 12198 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1047*/
#line 17066 "./marpa.w"

/*1420:*/
#line 16995 "./marpa.w"

{
if(and_node_id>=AND_Count_of_B(b))
{
return-1;
}
if(and_node_id<0)
{
MARPA_ERROR(MARPA_ERR_ANDID_NEGATIVE);
return failure_indicator;
}
{
AND and_nodes= ANDs_of_B(b);
if(!and_nodes)
{
MARPA_ERROR(MARPA_ERR_NO_AND_NODES);
return failure_indicator;
}
and_node= and_nodes+and_node_id;
}
}

/*:1420*/
#line 17067 "./marpa.w"

{
const OR cause_or= Cause_OR_of_AND(and_node);
const ISYID symbol_id= 
OR_is_Token(cause_or)?NSYID_of_OR(cause_or):-1;
return symbol_id;
}
}

/*:1424*//*1425:*/
#line 17076 "./marpa.w"

Marpa_Symbol_ID _marpa_b_and_node_token(Marpa_Bocage b,
Marpa_And_Node_ID and_node_id,int*value_p)
{
AND and_node;
OR cause_or;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 17082 "./marpa.w"

/*1047:*/
#line 12198 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1047*/
#line 17083 "./marpa.w"

/*1420:*/
#line 16995 "./marpa.w"

{
if(and_node_id>=AND_Count_of_B(b))
{
return-1;
}
if(and_node_id<0)
{
MARPA_ERROR(MARPA_ERR_ANDID_NEGATIVE);
return failure_indicator;
}
{
AND and_nodes= ANDs_of_B(b);
if(!and_nodes)
{
MARPA_ERROR(MARPA_ERR_NO_AND_NODES);
return failure_indicator;
}
and_node= and_nodes+and_node_id;
}
}

/*:1420*/
#line 17084 "./marpa.w"


cause_or= Cause_OR_of_AND(and_node);
if(!OR_is_Token(cause_or))return-1;
if(value_p)*value_p= Value_of_OR(cause_or);
return NSYID_of_OR(cause_or);
}

/*:1425*//*1426:*/
#line 17099 "./marpa.w"

Marpa_Earley_Set_ID _marpa_b_and_node_middle(Marpa_Bocage b,
Marpa_And_Node_ID and_node_id)
{
AND and_node;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 17104 "./marpa.w"

/*1047:*/
#line 12198 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1047*/
#line 17105 "./marpa.w"

/*1420:*/
#line 16995 "./marpa.w"

{
if(and_node_id>=AND_Count_of_B(b))
{
return-1;
}
if(and_node_id<0)
{
MARPA_ERROR(MARPA_ERR_ANDID_NEGATIVE);
return failure_indicator;
}
{
AND and_nodes= ANDs_of_B(b);
if(!and_nodes)
{
MARPA_ERROR(MARPA_ERR_NO_AND_NODES);
return failure_indicator;
}
and_node= and_nodes+and_node_id;
}
}

/*:1420*/
#line 17106 "./marpa.w"

{
const OR predecessor_or= Predecessor_OR_of_AND(and_node);
if(predecessor_or)
{
return YS_Ord_of_OR(predecessor_or);
}
}
return Origin_Ord_of_OR(OR_of_AND(and_node));
}

/*:1426*//*1429:*/
#line 17139 "./marpa.w"

int _marpa_t_nook_or_node(Marpa_Tree t,int nook_id)
{
NOOK nook;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 17143 "./marpa.w"

/*1120:*/
#line 13071 "./marpa.w"

ORDER o= O_of_T(t);
/*1092:*/
#line 12603 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1047:*/
#line 12198 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1047*/
#line 12605 "./marpa.w"


/*:1092*/
#line 13073 "./marpa.w"
;

/*:1120*/
#line 17144 "./marpa.w"

/*1428:*/
#line 17121 "./marpa.w"
{
NOOK base_nook;
/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 17123 "./marpa.w"

if(T_is_Exhausted(t)){
MARPA_ERROR(MARPA_ERR_BOCAGE_ITERATION_EXHAUSTED);
return failure_indicator;
}
if(nook_id<0){
MARPA_ERROR(MARPA_ERR_NOOKID_NEGATIVE);
return failure_indicator;
}
if(nook_id>=Size_of_T(t)){
return-1;
}
base_nook= FSTACK_BASE(t->t_nook_stack,NOOK_Object);
nook= base_nook+nook_id;
}

/*:1428*/
#line 17145 "./marpa.w"

return ID_of_OR(OR_of_NOOK(nook));
}

/*:1429*//*1430:*/
#line 17149 "./marpa.w"

int _marpa_t_nook_choice(Marpa_Tree t,int nook_id)
{
NOOK nook;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 17153 "./marpa.w"

/*1120:*/
#line 13071 "./marpa.w"

ORDER o= O_of_T(t);
/*1092:*/
#line 12603 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1047:*/
#line 12198 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1047*/
#line 12605 "./marpa.w"


/*:1092*/
#line 13073 "./marpa.w"
;

/*:1120*/
#line 17154 "./marpa.w"

/*1428:*/
#line 17121 "./marpa.w"
{
NOOK base_nook;
/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 17123 "./marpa.w"

if(T_is_Exhausted(t)){
MARPA_ERROR(MARPA_ERR_BOCAGE_ITERATION_EXHAUSTED);
return failure_indicator;
}
if(nook_id<0){
MARPA_ERROR(MARPA_ERR_NOOKID_NEGATIVE);
return failure_indicator;
}
if(nook_id>=Size_of_T(t)){
return-1;
}
base_nook= FSTACK_BASE(t->t_nook_stack,NOOK_Object);
nook= base_nook+nook_id;
}

/*:1428*/
#line 17155 "./marpa.w"

return Choice_of_NOOK(nook);
}

/*:1430*//*1431:*/
#line 17159 "./marpa.w"

int _marpa_t_nook_parent(Marpa_Tree t,int nook_id)
{
NOOK nook;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 17163 "./marpa.w"

/*1120:*/
#line 13071 "./marpa.w"

ORDER o= O_of_T(t);
/*1092:*/
#line 12603 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1047:*/
#line 12198 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1047*/
#line 12605 "./marpa.w"


/*:1092*/
#line 13073 "./marpa.w"
;

/*:1120*/
#line 17164 "./marpa.w"

/*1428:*/
#line 17121 "./marpa.w"
{
NOOK base_nook;
/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 17123 "./marpa.w"

if(T_is_Exhausted(t)){
MARPA_ERROR(MARPA_ERR_BOCAGE_ITERATION_EXHAUSTED);
return failure_indicator;
}
if(nook_id<0){
MARPA_ERROR(MARPA_ERR_NOOKID_NEGATIVE);
return failure_indicator;
}
if(nook_id>=Size_of_T(t)){
return-1;
}
base_nook= FSTACK_BASE(t->t_nook_stack,NOOK_Object);
nook= base_nook+nook_id;
}

/*:1428*/
#line 17165 "./marpa.w"

return Parent_of_NOOK(nook);
}

/*:1431*//*1432:*/
#line 17169 "./marpa.w"

int _marpa_t_nook_cause_is_ready(Marpa_Tree t,int nook_id)
{
NOOK nook;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 17173 "./marpa.w"

/*1120:*/
#line 13071 "./marpa.w"

ORDER o= O_of_T(t);
/*1092:*/
#line 12603 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1047:*/
#line 12198 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1047*/
#line 12605 "./marpa.w"


/*:1092*/
#line 13073 "./marpa.w"
;

/*:1120*/
#line 17174 "./marpa.w"

/*1428:*/
#line 17121 "./marpa.w"
{
NOOK base_nook;
/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 17123 "./marpa.w"

if(T_is_Exhausted(t)){
MARPA_ERROR(MARPA_ERR_BOCAGE_ITERATION_EXHAUSTED);
return failure_indicator;
}
if(nook_id<0){
MARPA_ERROR(MARPA_ERR_NOOKID_NEGATIVE);
return failure_indicator;
}
if(nook_id>=Size_of_T(t)){
return-1;
}
base_nook= FSTACK_BASE(t->t_nook_stack,NOOK_Object);
nook= base_nook+nook_id;
}

/*:1428*/
#line 17175 "./marpa.w"

return NOOK_Cause_is_Expanded(nook);
}

/*:1432*//*1433:*/
#line 17179 "./marpa.w"

int _marpa_t_nook_predecessor_is_ready(Marpa_Tree t,int nook_id)
{
NOOK nook;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 17183 "./marpa.w"

/*1120:*/
#line 13071 "./marpa.w"

ORDER o= O_of_T(t);
/*1092:*/
#line 12603 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1047:*/
#line 12198 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1047*/
#line 12605 "./marpa.w"


/*:1092*/
#line 13073 "./marpa.w"
;

/*:1120*/
#line 17184 "./marpa.w"

/*1428:*/
#line 17121 "./marpa.w"
{
NOOK base_nook;
/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 17123 "./marpa.w"

if(T_is_Exhausted(t)){
MARPA_ERROR(MARPA_ERR_BOCAGE_ITERATION_EXHAUSTED);
return failure_indicator;
}
if(nook_id<0){
MARPA_ERROR(MARPA_ERR_NOOKID_NEGATIVE);
return failure_indicator;
}
if(nook_id>=Size_of_T(t)){
return-1;
}
base_nook= FSTACK_BASE(t->t_nook_stack,NOOK_Object);
nook= base_nook+nook_id;
}

/*:1428*/
#line 17185 "./marpa.w"

return NOOK_Predecessor_is_Expanded(nook);
}

/*:1433*//*1434:*/
#line 17189 "./marpa.w"

int _marpa_t_nook_is_cause(Marpa_Tree t,int nook_id)
{
NOOK nook;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 17193 "./marpa.w"

/*1120:*/
#line 13071 "./marpa.w"

ORDER o= O_of_T(t);
/*1092:*/
#line 12603 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1047:*/
#line 12198 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1047*/
#line 12605 "./marpa.w"


/*:1092*/
#line 13073 "./marpa.w"
;

/*:1120*/
#line 17194 "./marpa.w"

/*1428:*/
#line 17121 "./marpa.w"
{
NOOK base_nook;
/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 17123 "./marpa.w"

if(T_is_Exhausted(t)){
MARPA_ERROR(MARPA_ERR_BOCAGE_ITERATION_EXHAUSTED);
return failure_indicator;
}
if(nook_id<0){
MARPA_ERROR(MARPA_ERR_NOOKID_NEGATIVE);
return failure_indicator;
}
if(nook_id>=Size_of_T(t)){
return-1;
}
base_nook= FSTACK_BASE(t->t_nook_stack,NOOK_Object);
nook= base_nook+nook_id;
}

/*:1428*/
#line 17195 "./marpa.w"

return NOOK_is_Cause(nook);
}

/*:1434*//*1435:*/
#line 17199 "./marpa.w"

int _marpa_t_nook_is_predecessor(Marpa_Tree t,int nook_id)
{
NOOK nook;
/*1316:*/
#line 15689 "./marpa.w"
const int failure_indicator= -2;

/*:1316*/
#line 17203 "./marpa.w"

/*1120:*/
#line 13071 "./marpa.w"

ORDER o= O_of_T(t);
/*1092:*/
#line 12603 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1047:*/
#line 12198 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1047*/
#line 12605 "./marpa.w"


/*:1092*/
#line 13073 "./marpa.w"
;

/*:1120*/
#line 17204 "./marpa.w"

/*1428:*/
#line 17121 "./marpa.w"
{
NOOK base_nook;
/*1336:*/
#line 15822 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1336*/
#line 17123 "./marpa.w"

if(T_is_Exhausted(t)){
MARPA_ERROR(MARPA_ERR_BOCAGE_ITERATION_EXHAUSTED);
return failure_indicator;
}
if(nook_id<0){
MARPA_ERROR(MARPA_ERR_NOOKID_NEGATIVE);
return failure_indicator;
}
if(nook_id>=Size_of_T(t)){
return-1;
}
base_nook= FSTACK_BASE(t->t_nook_stack,NOOK_Object);
nook= base_nook+nook_id;
}

/*:1428*/
#line 17205 "./marpa.w"

return NOOK_is_Predecessor(nook);
}

/*:1435*//*1437:*/
#line 17220 "./marpa.w"

void marpa_debug_handler_set(int(*debug_handler)(const char*,...))
{
marpa__debug_handler= debug_handler;
}

/*:1437*//*1438:*/
#line 17226 "./marpa.w"

int marpa_debug_level_set(int new_level)
{
const int old_level= marpa__debug_level;
marpa__debug_level= new_level;
return old_level;
}


/*:1438*/
#line 17410 "./marpa.w"


/*:1456*/
