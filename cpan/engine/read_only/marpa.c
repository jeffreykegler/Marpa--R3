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

/*1455:*/
#line 17406 "./marpa.w"


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
#define Length_of_IRL(irl) ((irl) ->t_rhs_length) 
#define LHS_ID_of_RULE(rule) ((rule) ->t_symbols[0]) 
#define LHS_ID_of_IRL(irl) ((irl) ->t_symbols[0]) 
#define RHS_ID_of_RULE(rule,position)  \
((rule) ->t_symbols[(position) +1]) 
#define RHS_ID_of_IRL(irl,position)  \
((irl) ->t_symbols[(position) +1])  \

#define ID_of_IRL(irl) ((irl) ->t_id) 
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
#define NRL_CHAF_Rank_by_IRL(irl,chaf_rank) ( \
((irl) ->t_rank*EXTERNAL_RANK_FACTOR) + \
(((irl) ->t_null_ranks_high) ?(MAXIMUM_CHAF_RANK- \
(chaf_rank) ) :(chaf_rank) )  \
) 
#define NRL_Rank_by_IRL(irl) NRL_CHAF_Rank_by_IRL((irl) ,MAXIMUM_CHAF_RANK) 
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

#line 17416 "./marpa.w"

#include "marpa_obs.h"
#include "marpa_avl.h"
/*109:*/
#line 1039 "./marpa.w"

struct s_g_event;
typedef struct s_g_event*GEV;
/*:109*//*145:*/
#line 1268 "./marpa.w"

struct s_isy;
typedef struct s_isy*ISY;
typedef const struct s_isy*ISY_Const;

/*:145*//*456:*/
#line 4899 "./marpa.w"

struct s_ahm;
typedef struct s_ahm*AHM;
typedef Marpa_AHM_ID AHMID;

/*:456*//*533:*/
#line 5837 "./marpa.w"

struct s_g_zwa;
struct s_r_zwa;
/*:533*//*540:*/
#line 5874 "./marpa.w"

struct s_zwp;
/*:540*//*633:*/
#line 6768 "./marpa.w"

struct s_earley_set;
typedef struct s_earley_set*YS;
typedef const struct s_earley_set*YS_Const;
struct s_earley_set_key;
typedef struct s_earley_set_key*YSK;
/*:633*//*655:*/
#line 6984 "./marpa.w"

struct s_earley_item;
typedef struct s_earley_item*YIM;
typedef const struct s_earley_item*YIM_Const;
struct s_earley_item_key;
typedef struct s_earley_item_key*YIK;

/*:655*//*665:*/
#line 7158 "./marpa.w"

struct s_earley_ix;
typedef struct s_earley_ix*YIX;
/*:665*//*668:*/
#line 7194 "./marpa.w"

struct s_leo_item;
typedef struct s_leo_item*LIM;
/*:668*//*704:*/
#line 7591 "./marpa.w"

struct s_alternative;
typedef struct s_alternative*ALT;
typedef const struct s_alternative*ALT_Const;
/*:704*//*861:*/
#line 10069 "./marpa.w"

struct s_ur_node_stack;
struct s_ur_node;
typedef struct s_ur_node_stack*URS;
typedef struct s_ur_node*UR;
typedef const struct s_ur_node*UR_Const;
/*:861*//*882:*/
#line 10331 "./marpa.w"

union u_or_node;
typedef union u_or_node*OR;
/*:882*//*904:*/
#line 10696 "./marpa.w"

struct s_draft_and_node;
typedef struct s_draft_and_node*DAND;
/*:904*//*930:*/
#line 11095 "./marpa.w"

struct s_and_node;
typedef struct s_and_node*AND;
/*:930*//*936:*/
#line 11156 "./marpa.w"

typedef struct marpa_traverser*TRAVERSER;
/*:936*//*983:*/
#line 11732 "./marpa.w"

typedef struct marpa_ltraverser*LTRAVERSER;
/*:983*//*1009:*/
#line 11898 "./marpa.w"

typedef struct marpa_ptraverser*PTRAVERSER;
/*:1009*//*1040:*/
#line 12179 "./marpa.w"

typedef struct marpa_bocage*BOCAGE;
/*:1040*//*1056:*/
#line 12329 "./marpa.w"

struct s_bocage_setup_per_ys;
/*:1056*//*1120:*/
#line 13083 "./marpa.w"

typedef Marpa_Tree TREE;
/*:1120*//*1151:*/
#line 13492 "./marpa.w"

struct s_nook;
typedef struct s_nook*NOOK;
/*:1151*//*1155:*/
#line 13537 "./marpa.w"

typedef struct s_value*VALUE;
/*:1155*//*1268:*/
#line 15106 "./marpa.w"

struct s_dqueue;
typedef struct s_dqueue*DQUEUE;
/*:1268*//*1274:*/
#line 15160 "./marpa.w"

struct s_cil_arena;
/*:1274*//*1294:*/
#line 15495 "./marpa.w"

struct s_per_earley_set_list;
typedef struct s_per_earley_set_list*PSL;
/*:1294*//*1296:*/
#line 15510 "./marpa.w"

struct s_per_earley_set_arena;
typedef struct s_per_earley_set_arena*PSAR;
/*:1296*/
#line 17419 "./marpa.w"

/*49:*/
#line 666 "./marpa.w"

typedef struct marpa_g*GRAMMAR;

/*:49*//*144:*/
#line 1266 "./marpa.w"

typedef Marpa_Symbol_ID ISYID;
/*:144*//*218:*/
#line 1909 "./marpa.w"

struct s_nsy;
typedef struct s_nsy*NSY;
typedef Marpa_NSY_ID NSYID;

/*:218*//*256:*/
#line 2190 "./marpa.w"

struct s_irl;
typedef struct s_irl*IRL;
typedef IRL RULE;
typedef Marpa_Rule_ID RULEID;
typedef Marpa_Rule_ID IRLID;

/*:256*//*329:*/
#line 2921 "./marpa.w"

struct s_nrl;
typedef struct s_nrl*NRL;
typedef Marpa_NRL_ID NRLID;

/*:329*//*473:*/
#line 5015 "./marpa.w"
typedef int SYMI;
/*:473*//*534:*/
#line 5846 "./marpa.w"

typedef Marpa_Assertion_ID ZWAID;
typedef struct s_g_zwa*GZWA;
typedef struct s_r_zwa*ZWA;

/*:534*//*541:*/
#line 5877 "./marpa.w"

typedef struct s_zwp*ZWP;
typedef const struct s_zwp*ZWP_Const;
/*:541*//*554:*/
#line 6073 "./marpa.w"

typedef struct marpa_r*RECCE;
/*:554*//*630:*/
#line 6758 "./marpa.w"
typedef Marpa_Earleme JEARLEME;

/*:630*//*632:*/
#line 6762 "./marpa.w"
typedef Marpa_Earley_Set_ID YSID;
/*:632*//*657:*/
#line 7025 "./marpa.w"

typedef int YIMID;

/*:657*//*675:*/
#line 7240 "./marpa.w"

typedef union _Marpa_PIM_Object PIM_Object;
typedef union _Marpa_PIM_Object*PIM;

/*:675*//*684:*/
#line 7320 "./marpa.w"

struct s_source;
typedef struct s_source*SRC;
typedef const struct s_source*SRC_Const;
/*:684*//*688:*/
#line 7348 "./marpa.w"

typedef struct marpa_source_link_s*SRCL;
/*:688*//*829:*/
#line 9667 "./marpa.w"

typedef struct marpa_progress_item*PROGRESS;
/*:829*//*881:*/
#line 10328 "./marpa.w"

typedef Marpa_Or_Node_ID ORID;

/*:881*//*903:*/
#line 10685 "./marpa.w"

typedef int WHEID;

/*:903*//*929:*/
#line 11091 "./marpa.w"

typedef Marpa_And_Node_ID ANDID;

/*:929*//*1150:*/
#line 13488 "./marpa.w"

typedef Marpa_Nook_ID NOOKID;
/*:1150*//*1205:*/
#line 14276 "./marpa.w"

typedef unsigned int LBW;
typedef LBW*LBV;

/*:1205*//*1213:*/
#line 14368 "./marpa.w"

typedef LBW Bit_Vector_Word;
typedef Bit_Vector_Word*Bit_Vector;
/*:1213*//*1271:*/
#line 15127 "./marpa.w"

typedef int*CIL;

/*:1271*//*1275:*/
#line 15163 "./marpa.w"

typedef struct s_cil_arena*CILAR;
/*:1275*/
#line 17420 "./marpa.w"

/*1273:*/
#line 15152 "./marpa.w"

struct s_cil_arena{
struct marpa_obstack*t_obs;
MARPA_AVL_TREE t_avl;
MARPA_DSTACK_DECLARE(t_buffer);
};
typedef struct s_cil_arena CILAR_Object;

/*:1273*/
#line 17421 "./marpa.w"

/*48:*/
#line 660 "./marpa.w"
struct marpa_g{
/*135:*/
#line 1213 "./marpa.w"

int t_is_ok;

/*:135*/
#line 661 "./marpa.w"

/*59:*/
#line 749 "./marpa.w"

MARPA_DSTACK_DECLARE(t_isy_stack);
MARPA_DSTACK_DECLARE(t_nsy_stack);

/*:59*//*68:*/
#line 808 "./marpa.w"

MARPA_DSTACK_DECLARE(t_irl_stack);
MARPA_DSTACK_DECLARE(t_nrl_stack);
/*:68*//*105:*/
#line 1008 "./marpa.w"
Bit_Vector t_bv_nsyid_is_terminal;
/*:105*//*107:*/
#line 1017 "./marpa.w"

Bit_Vector t_lbv_isyid_is_completion_event;
Bit_Vector t_lbv_isyid_completion_event_starts_active;
Bit_Vector t_lbv_isyid_is_nulled_event;
Bit_Vector t_lbv_isyid_nulled_event_starts_active;
Bit_Vector t_lbv_isyid_is_prediction_event;
Bit_Vector t_lbv_isyid_prediction_event_starts_active;
/*:107*//*114:*/
#line 1061 "./marpa.w"

MARPA_DSTACK_DECLARE(t_events);
/*:114*//*122:*/
#line 1135 "./marpa.w"

MARPA_AVL_TREE t_irl_tree;
/*:122*//*126:*/
#line 1165 "./marpa.w"

struct marpa_obstack*t_obs;
struct marpa_obstack*t_irl_obs;
/*:126*//*129:*/
#line 1182 "./marpa.w"

CILAR_Object t_cilar;
/*:129*//*137:*/
#line 1228 "./marpa.w"

const char*t_error_string;
/*:137*//*461:*/
#line 4925 "./marpa.w"

AHM t_ahms;
/*:461*//*535:*/
#line 5853 "./marpa.w"

MARPA_DSTACK_DECLARE(t_gzwa_stack);
/*:535*//*543:*/
#line 5892 "./marpa.w"

MARPA_AVL_TREE t_zwp_tree;
/*:543*/
#line 662 "./marpa.w"

/*53:*/
#line 696 "./marpa.w"
int t_ref_count;
/*:53*//*78:*/
#line 858 "./marpa.w"
ISYID t_start_isy_id;
/*:78*//*80:*/
#line 861 "./marpa.w"
NSYID t_start_nsyid;
/*:80*//*84:*/
#line 898 "./marpa.w"

NRL t_start_nrl;
IRL t_start_irl;
/*:84*//*87:*/
#line 914 "./marpa.w"

int t_external_size;
/*:87*//*90:*/
#line 928 "./marpa.w"
int t_max_rule_length;
/*:90*//*94:*/
#line 941 "./marpa.w"
Marpa_Rank t_default_rank;
/*:94*//*138:*/
#line 1230 "./marpa.w"

Marpa_Error_Code t_error;
/*:138*//*163:*/
#line 1394 "./marpa.w"
int t_force_valued;
/*:163*//*459:*/
#line 4917 "./marpa.w"

int t_ahm_count;
/*:459*//*474:*/
#line 5017 "./marpa.w"

int t_symbol_instance_count;
/*:474*/
#line 663 "./marpa.w"

/*99:*/
#line 976 "./marpa.w"
BITFIELD t_is_precomputed:1;
/*:99*//*102:*/
#line 988 "./marpa.w"
BITFIELD t_has_cycle:1;
/*:102*/
#line 664 "./marpa.w"

};
/*:48*//*113:*/
#line 1054 "./marpa.w"

struct s_g_event{
int t_type;
int t_value;
};
typedef struct s_g_event GEV_Object;
/*:113*//*146:*/
#line 1273 "./marpa.w"

struct s_isy{
/*204:*/
#line 1809 "./marpa.w"

CIL t_nulled_event_isyids;
/*:204*//*207:*/
#line 1836 "./marpa.w"
NSY t_nsy_equivalent;
/*:207*//*211:*/
#line 1868 "./marpa.w"
NSY t_nulling_nsy;
/*:211*/
#line 1275 "./marpa.w"

/*147:*/
#line 1282 "./marpa.w"
ISYID t_symbol_id;

/*:147*//*152:*/
#line 1315 "./marpa.w"

Marpa_Rank t_rank;
/*:152*/
#line 1276 "./marpa.w"

/*156:*/
#line 1362 "./marpa.w"
BITFIELD t_is_lhs:1;
/*:156*//*158:*/
#line 1369 "./marpa.w"
BITFIELD t_is_sequence_lhs:1;
/*:158*//*160:*/
#line 1383 "./marpa.w"

BITFIELD t_is_valued:1;
BITFIELD t_is_valued_locked:1;
/*:160*//*168:*/
#line 1453 "./marpa.w"
BITFIELD t_is_accessible:1;
/*:168*//*171:*/
#line 1474 "./marpa.w"
BITFIELD t_is_counted:1;
/*:171*//*174:*/
#line 1490 "./marpa.w"
BITFIELD t_is_nulling:1;
/*:174*//*177:*/
#line 1507 "./marpa.w"
BITFIELD t_is_nullable:1;
/*:177*//*180:*/
#line 1528 "./marpa.w"

BITFIELD t_is_terminal:1;
BITFIELD t_is_locked_terminal:1;
/*:180*//*185:*/
#line 1575 "./marpa.w"
BITFIELD t_is_productive:1;
/*:185*//*188:*/
#line 1596 "./marpa.w"

BITFIELD t_is_completion_event:1;
BITFIELD t_completion_event_starts_active:1;
/*:188*//*193:*/
#line 1666 "./marpa.w"

BITFIELD t_is_nulled_event:1;
BITFIELD t_nulled_event_starts_active:1;
/*:193*//*198:*/
#line 1739 "./marpa.w"

BITFIELD t_is_prediction_event:1;
BITFIELD t_prediction_event_starts_active:1;
/*:198*/
#line 1277 "./marpa.w"

};

/*:146*//*219:*/
#line 1924 "./marpa.w"

struct s_unvalued_token_or_node{
int t_or_node_type;
NSYID t_nsyid;
};

struct s_nsy{
/*237:*/
#line 2057 "./marpa.w"
CIL t_lhs_cil;
/*:237*//*242:*/
#line 2088 "./marpa.w"
ISY t_source_isy;
/*:242*//*246:*/
#line 2111 "./marpa.w"

IRL t_lhs_irl;
int t_irl_offset;
/*:246*/
#line 1931 "./marpa.w"

/*251:*/
#line 2164 "./marpa.w"
Marpa_Rank t_rank;
/*:251*/
#line 1932 "./marpa.w"

/*231:*/
#line 2026 "./marpa.w"
BITFIELD t_is_lhs:1;
/*:231*//*234:*/
#line 2040 "./marpa.w"
BITFIELD t_nsy_is_nulling:1;
/*:234*//*239:*/
#line 2065 "./marpa.w"
BITFIELD t_is_semantic:1;
/*:239*/
#line 1933 "./marpa.w"

struct s_unvalued_token_or_node t_nulling_or_node;
struct s_unvalued_token_or_node t_unvalued_or_node;
};
/*:219*//*255:*/
#line 2181 "./marpa.w"

struct s_irl{
/*268:*/
#line 2484 "./marpa.w"
int t_rhs_length;
/*:268*//*276:*/
#line 2549 "./marpa.w"
Marpa_Rule_ID t_id;

/*:276*//*277:*/
#line 2552 "./marpa.w"

Marpa_Rank t_rank;
/*:277*/
#line 2183 "./marpa.w"

/*281:*/
#line 2601 "./marpa.w"

BITFIELD t_null_ranks_high:1;
/*:281*//*285:*/
#line 2642 "./marpa.w"
BITFIELD t_is_bnf:1;
/*:285*//*287:*/
#line 2648 "./marpa.w"
BITFIELD t_is_sequence:1;
/*:287*//*289:*/
#line 2662 "./marpa.w"
int t_minimum;
/*:289*//*292:*/
#line 2688 "./marpa.w"
ISYID t_separator_id;
/*:292*//*297:*/
#line 2725 "./marpa.w"
BITFIELD t_is_discard:1;
/*:297*//*301:*/
#line 2765 "./marpa.w"
BITFIELD t_is_proper_separation:1;
/*:301*//*305:*/
#line 2786 "./marpa.w"
BITFIELD t_is_loop:1;
/*:305*//*308:*/
#line 2804 "./marpa.w"
BITFIELD t_is_nulling:1;
/*:308*//*311:*/
#line 2823 "./marpa.w"
BITFIELD t_is_nullable:1;
/*:311*//*315:*/
#line 2842 "./marpa.w"
BITFIELD t_is_accessible:1;
/*:315*//*318:*/
#line 2861 "./marpa.w"
BITFIELD t_is_productive:1;
/*:318*//*321:*/
#line 2879 "./marpa.w"
BITFIELD t_is_used:1;
/*:321*/
#line 2184 "./marpa.w"

/*269:*/
#line 2487 "./marpa.w"
Marpa_Symbol_ID t_symbols[1];


/*:269*/
#line 2185 "./marpa.w"

};
/*:255*//*327:*/
#line 2910 "./marpa.w"

struct s_nrl{
/*360:*/
#line 3123 "./marpa.w"
IRL t_source_irl;
/*:360*//*366:*/
#line 3172 "./marpa.w"
AHM t_first_ahm;
/*:366*/
#line 2912 "./marpa.w"

/*330:*/
#line 2932 "./marpa.w"
NRLID t_nrl_id;

/*:330*//*337:*/
#line 2969 "./marpa.w"
int t_length;
/*:337*//*339:*/
#line 2984 "./marpa.w"
int t_ahm_count;

/*:339*//*351:*/
#line 3063 "./marpa.w"
int t_real_symbol_count;
/*:351*//*354:*/
#line 3081 "./marpa.w"
int t_virtual_start;
/*:354*//*357:*/
#line 3101 "./marpa.w"
int t_virtual_end;
/*:357*//*363:*/
#line 3150 "./marpa.w"
Marpa_Rank t_rank;
/*:363*//*475:*/
#line 5023 "./marpa.w"

int t_symbol_instance_base;
int t_last_proper_symi;
/*:475*/
#line 2913 "./marpa.w"

/*342:*/
#line 3017 "./marpa.w"
BITFIELD t_is_virtual_lhs:1;
/*:342*//*345:*/
#line 3033 "./marpa.w"
BITFIELD t_is_virtual_rhs:1;
/*:345*//*348:*/
#line 3052 "./marpa.w"
BITFIELD t_is_right_recursive:1;
/*:348*//*411:*/
#line 4105 "./marpa.w"
BITFIELD t_is_chaf:1;
/*:411*/
#line 2914 "./marpa.w"

/*332:*/
#line 2937 "./marpa.w"

NSYID t_nsyid_array[1];

/*:332*/
#line 2915 "./marpa.w"

};
typedef struct s_nrl NRL_Object;

/*:327*//*379:*/
#line 3361 "./marpa.w"

struct sym_rule_pair
{
ISYID t_symid;
RULEID t_ruleid;
};

/*:379*//*455:*/
#line 4893 "./marpa.w"

struct s_ahm{
/*465:*/
#line 4945 "./marpa.w"

NRL t_nrl;

/*:465*//*478:*/
#line 5038 "./marpa.w"

CIL t_predicted_nrl_cil;
CIL t_lhs_cil;

/*:478*//*479:*/
#line 5046 "./marpa.w"

CIL t_zwa_cil;

/*:479*//*501:*/
#line 5290 "./marpa.w"

CIL t_completion_isyids;
CIL t_nulled_isyids;
CIL t_prediction_isyids;

/*:501*//*505:*/
#line 5320 "./marpa.w"

IRL t_irl;
/*:505*//*508:*/
#line 5349 "./marpa.w"

CIL t_event_ahmids;
/*:508*/
#line 4895 "./marpa.w"

/*466:*/
#line 4955 "./marpa.w"
NSYID t_postdot_nsyid;

/*:466*//*467:*/
#line 4964 "./marpa.w"

int t_leading_nulls;

/*:467*//*468:*/
#line 4977 "./marpa.w"

int t_position;

/*:468*//*470:*/
#line 4993 "./marpa.w"

int t_quasi_position;

/*:470*//*472:*/
#line 5013 "./marpa.w"

int t_symbol_instance;
/*:472*//*506:*/
#line 5328 "./marpa.w"

int t_irl_position;

/*:506*//*509:*/
#line 5353 "./marpa.w"

int t_event_group_size;
/*:509*/
#line 4896 "./marpa.w"

/*480:*/
#line 5055 "./marpa.w"

BITFIELD t_predicts_zwa:1;

/*:480*//*504:*/
#line 5311 "./marpa.w"

BITFIELD t_was_predicted:1;
BITFIELD t_is_initial:1;

/*:504*/
#line 4897 "./marpa.w"

};
/*:455*//*539:*/
#line 5867 "./marpa.w"

struct s_g_zwa{
ZWAID t_id;
BITFIELD t_default_value:1;
};
typedef struct s_g_zwa GZWA_Object;

/*:539*//*542:*/
#line 5884 "./marpa.w"

struct s_zwp{
IRLID t_irl_id;
int t_dot;
ZWAID t_zwaid;
};
typedef struct s_zwp ZWP_Object;

/*:542*//*623:*/
#line 6704 "./marpa.w"

struct s_r_zwa{
ZWAID t_id;
YSID t_memoized_ysid;
BITFIELD t_default_value:1;
BITFIELD t_memoized_value:1;
};
typedef struct s_r_zwa ZWA_Object;

/*:623*//*634:*/
#line 6774 "./marpa.w"

struct s_earley_set_key{
JEARLEME t_earleme;
};
typedef struct s_earley_set_key YSK_Object;
/*:634*//*635:*/
#line 6779 "./marpa.w"

struct s_earley_set{
YSK_Object t_key;
PIM*t_postdot_ary;
YS t_next_earley_set;
/*637:*/
#line 6795 "./marpa.w"

YIM*t_earley_items;

/*:637*//*1305:*/
#line 15598 "./marpa.w"

PSL t_dot_psl;
/*:1305*/
#line 6784 "./marpa.w"

int t_postdot_sym_count;
/*636:*/
#line 6792 "./marpa.w"

int t_yim_count;
/*:636*//*638:*/
#line 6806 "./marpa.w"

int t_ordinal;
/*:638*//*642:*/
#line 6824 "./marpa.w"

int t_value;
void*t_pvalue;
/*:642*/
#line 6786 "./marpa.w"

};
typedef struct s_earley_set YS_Object;

/*:635*//*666:*/
#line 7161 "./marpa.w"

struct s_earley_ix{
PIM t_next;
NSYID t_postdot_nsyid;
YIM t_earley_item;
};
typedef struct s_earley_ix YIX_Object;

/*:666*//*669:*/
#line 7197 "./marpa.w"

struct s_leo_item{
YIX_Object t_earley_ix;
/*670:*/
#line 7213 "./marpa.w"

CIL t_cil;

/*:670*/
#line 7200 "./marpa.w"

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

/*:669*//*705:*/
#line 7602 "./marpa.w"

struct s_alternative{
YS t_start_earley_set;
JEARLEME t_end_earleme;
NSYID t_nsyid;
int t_value;
BITFIELD t_is_valued:1;
};
typedef struct s_alternative ALT_Object;

/*:705*//*862:*/
#line 10085 "./marpa.w"

struct s_ur_node_stack{
struct marpa_obstack*t_obs;
UR t_base;
UR t_top;
};

/*:862*//*863:*/
#line 10092 "./marpa.w"

struct s_ur_node{
UR t_prev;
UR t_next;
YIM t_earley_item;
};
typedef struct s_ur_node UR_Object;

/*:863*//*886:*/
#line 10374 "./marpa.w"

struct s_draft_or_node
{
/*885:*/
#line 10367 "./marpa.w"

/*884:*/
#line 10364 "./marpa.w"

int t_position;

/*:884*/
#line 10368 "./marpa.w"

int t_end_set_ordinal;
int t_start_set_ordinal;
ORID t_id;
NRL t_nrl;

/*:885*/
#line 10377 "./marpa.w"

DAND t_draft_and_node;
};

/*:886*//*887:*/
#line 10381 "./marpa.w"

struct s_final_or_node
{
/*885:*/
#line 10367 "./marpa.w"

/*884:*/
#line 10364 "./marpa.w"

int t_position;

/*:884*/
#line 10368 "./marpa.w"

int t_end_set_ordinal;
int t_start_set_ordinal;
ORID t_id;
NRL t_nrl;

/*:885*/
#line 10384 "./marpa.w"

int t_first_and_node_id;
int t_and_node_count;
};

/*:887*//*888:*/
#line 10389 "./marpa.w"

struct s_valued_token_or_node
{
/*884:*/
#line 10364 "./marpa.w"

int t_position;

/*:884*/
#line 10392 "./marpa.w"

NSYID t_nsyid;
int t_value;
};

/*:888*//*889:*/
#line 10400 "./marpa.w"

union u_or_node{
struct s_draft_or_node t_draft;
struct s_final_or_node t_final;
struct s_valued_token_or_node t_token;
};
typedef union u_or_node OR_Object;

/*:889*//*905:*/
#line 10703 "./marpa.w"

struct s_draft_and_node{
DAND t_next;
OR t_predecessor;
OR t_cause;
};
typedef struct s_draft_and_node DAND_Object;

/*:905*//*931:*/
#line 11102 "./marpa.w"

struct s_and_node{
OR t_current;
OR t_predecessor;
OR t_cause;
};
typedef struct s_and_node AND_Object;

/*:931*//*1057:*/
#line 12335 "./marpa.w"

struct s_bocage_setup_per_ys{
OR*t_or_node_by_item;
PSL t_or_psl;
PSL t_and_psl;
};
/*:1057*//*1083:*/
#line 12556 "./marpa.w"

struct marpa_order{
struct marpa_obstack*t_ordering_obs;
ANDID**t_and_node_orderings;
/*1086:*/
#line 12574 "./marpa.w"

BOCAGE t_bocage;

/*:1086*/
#line 12560 "./marpa.w"

/*1089:*/
#line 12594 "./marpa.w"
int t_ref_count;
/*:1089*//*1096:*/
#line 12650 "./marpa.w"
int t_ambiguity_metric;

/*:1096*//*1102:*/
#line 12762 "./marpa.w"
int t_high_rank_count;
/*:1102*/
#line 12561 "./marpa.w"

/*1100:*/
#line 12744 "./marpa.w"

BITFIELD t_is_nulling:1;
/*:1100*/
#line 12562 "./marpa.w"

BITFIELD t_is_frozen:1;
};
/*:1083*//*1121:*/
#line 13095 "./marpa.w"

/*1152:*/
#line 13503 "./marpa.w"

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

/*:1152*/
#line 13096 "./marpa.w"

/*1157:*/
#line 13551 "./marpa.w"

struct s_value{
struct marpa_value public;
Marpa_Tree t_tree;
/*1161:*/
#line 13629 "./marpa.w"

struct marpa_obstack*t_obs;
/*:1161*//*1166:*/
#line 13676 "./marpa.w"

MARPA_DSTACK_DECLARE(t_virtual_stack);
/*:1166*//*1191:*/
#line 13849 "./marpa.w"

LBV t_isy_is_valued;
LBV t_irl_is_valued;
LBV t_valued_locked;

/*:1191*/
#line 13555 "./marpa.w"

/*1171:*/
#line 13724 "./marpa.w"

int t_ref_count;
/*:1171*//*1178:*/
#line 13782 "./marpa.w"

unsigned int t_generation;

/*:1178*//*1186:*/
#line 13824 "./marpa.w"

NOOKID t_nook;
/*:1186*/
#line 13556 "./marpa.w"

int t_token_type;
int t_next_value_type;
/*1181:*/
#line 13795 "./marpa.w"

BITFIELD t_is_nulling:1;
/*:1181*//*1183:*/
#line 13802 "./marpa.w"

BITFIELD t_trace:1;
/*:1183*/
#line 13559 "./marpa.w"

};

/*:1157*/
#line 13097 "./marpa.w"

struct marpa_tree{
FSTACK_DECLARE(t_nook_stack,NOOK_Object)
FSTACK_DECLARE(t_nook_worklist,int)
Bit_Vector t_or_node_in_use;
Marpa_Order t_order;
/*1127:*/
#line 13168 "./marpa.w"

int t_ref_count;
/*:1127*//*1132:*/
#line 13221 "./marpa.w"
unsigned int t_generation;
/*:1132*/
#line 13103 "./marpa.w"

/*1136:*/
#line 13281 "./marpa.w"

BITFIELD t_is_exhausted:1;
/*:1136*//*1139:*/
#line 13289 "./marpa.w"

BITFIELD t_is_nulling:1;

/*:1139*/
#line 13104 "./marpa.w"

int t_parse_count;
};

/*:1121*//*1248:*/
#line 14890 "./marpa.w"

struct s_bit_matrix{
int t_row_count;
Bit_Vector_Word t_row_data[1];
};
typedef struct s_bit_matrix*Bit_Matrix;
typedef struct s_bit_matrix Bit_Matrix_Object;

/*:1248*//*1269:*/
#line 15109 "./marpa.w"

struct s_dqueue{int t_current;struct marpa_dstack_s t_stack;};

/*:1269*//*1295:*/
#line 15501 "./marpa.w"

struct s_per_earley_set_list{
PSL t_prev;
PSL t_next;
PSL*t_owner;
void*t_data[1];
};
typedef struct s_per_earley_set_list PSL_Object;
/*:1295*//*1297:*/
#line 15526 "./marpa.w"

struct s_per_earley_set_arena{
int t_psl_length;
PSL t_first_psl;
PSL t_first_free_psl;
};
typedef struct s_per_earley_set_arena PSAR_Object;
/*:1297*/
#line 17422 "./marpa.w"

/*674:*/
#line 7235 "./marpa.w"

union _Marpa_PIM_Object{
LIM_Object t_leo;
YIX_Object t_earley;
};
/*:674*/
#line 17423 "./marpa.w"


/*:1455*//*1456:*/
#line 17428 "./marpa.w"

/*40:*/
#line 570 "./marpa.w"

const int marpa_major_version= MARPA_LIB_MAJOR_VERSION;
const int marpa_minor_version= MARPA_LIB_MINOR_VERSION;
const int marpa_micro_version= MARPA_LIB_MICRO_VERSION;

/*:40*//*835:*/
#line 9693 "./marpa.w"

static const struct marpa_progress_item progress_report_not_ready= {-2,-2,-2};

/*:835*//*890:*/
#line 10408 "./marpa.w"

static const int dummy_or_node_type= DUMMY_OR_NODE;
static const OR dummy_or_node= (OR)&dummy_or_node_type;

/*:890*//*1214:*/
#line 14375 "./marpa.w"

static const unsigned int bv_wordbits= lbv_wordbits;
static const unsigned int bv_modmask= lbv_wordbits-1u;
static const unsigned int bv_hiddenwords= 3;
static const unsigned int bv_lsb= lbv_lsb;
static const unsigned int bv_msb= lbv_msb;

/*:1214*/
#line 17429 "./marpa.w"


/*:1456*//*1457:*/
#line 17431 "./marpa.w"

/*555:*/
#line 6075 "./marpa.w"

struct marpa_r{
/*563:*/
#line 6155 "./marpa.w"

GRAMMAR t_grammar;
/*:563*//*570:*/
#line 6182 "./marpa.w"

YS t_first_earley_set;
YS t_latest_earley_set;
JEARLEME t_current_earleme;
/*:570*//*582:*/
#line 6265 "./marpa.w"

Bit_Vector t_lbv_isyid_completion_event_is_active;
Bit_Vector t_lbv_isyid_nulled_event_is_active;
Bit_Vector t_lbv_isyid_prediction_event_is_active;
/*:582*//*585:*/
#line 6290 "./marpa.w"
Bit_Vector t_bv_nsyid_is_expected;
/*:585*//*589:*/
#line 6367 "./marpa.w"
LBV t_nsy_expected_is_event;
/*:589*//*611:*/
#line 6641 "./marpa.w"

Bit_Vector t_bv_nrl_seen;
MARPA_DSTACK_DECLARE(t_nrl_cil_stack);
/*:611*//*620:*/
#line 6695 "./marpa.w"
struct marpa_obstack*t_obs;
/*:620*//*624:*/
#line 6716 "./marpa.w"

ZWA t_zwas;
/*:624*//*706:*/
#line 7612 "./marpa.w"

MARPA_DSTACK_DECLARE(t_alternatives);
/*:706*//*723:*/
#line 7899 "./marpa.w"

LBV t_valued_terminal;
LBV t_unvalued_terminal;
LBV t_valued;
LBV t_unvalued;
LBV t_valued_locked;

/*:723*//*731:*/
#line 8112 "./marpa.w"
MARPA_DSTACK_DECLARE(t_yim_work_stack);
/*:731*//*735:*/
#line 8127 "./marpa.w"
MARPA_DSTACK_DECLARE(t_completion_stack);
/*:735*//*739:*/
#line 8138 "./marpa.w"
MARPA_DSTACK_DECLARE(t_earley_set_stack);
/*:739*//*776:*/
#line 8768 "./marpa.w"

Bit_Vector t_bv_lim_symbols;
Bit_Vector t_bv_pim_symbols;
void**t_pim_workarea;
/*:776*//*795:*/
#line 9052 "./marpa.w"

void**t_lim_chain;
/*:795*//*830:*/
#line 9669 "./marpa.w"

const struct marpa_progress_item*t_current_report_item;
MARPA_AVL_TRAV t_progress_report_traverser;
/*:830*//*864:*/
#line 10101 "./marpa.w"

struct s_ur_node_stack t_ur_node_stack;
/*:864*//*1298:*/
#line 15534 "./marpa.w"

PSAR_Object t_dot_psar_object;
/*:1298*//*1349:*/
#line 16002 "./marpa.w"

struct s_earley_set*t_trace_earley_set;
/*:1349*//*1356:*/
#line 16078 "./marpa.w"

YIM t_trace_earley_item;
/*:1356*//*1370:*/
#line 16277 "./marpa.w"

PIM*t_trace_pim_nsy_p;
PIM t_trace_postdot_item;
/*:1370*//*1377:*/
#line 16426 "./marpa.w"

SRCL t_trace_source_link;
/*:1377*/
#line 6077 "./marpa.w"

/*558:*/
#line 6105 "./marpa.w"
int t_ref_count;
/*:558*//*574:*/
#line 6219 "./marpa.w"
int t_earley_item_warning_threshold;
/*:574*//*578:*/
#line 6248 "./marpa.w"
JEARLEME t_furthest_earleme;
/*:578*//*583:*/
#line 6269 "./marpa.w"

int t_active_event_count;
/*:583*//*618:*/
#line 6688 "./marpa.w"
YSID t_first_inconsistent_ys;
/*:618*//*639:*/
#line 6810 "./marpa.w"

int t_earley_set_count;
/*:639*/
#line 6078 "./marpa.w"

/*567:*/
#line 6173 "./marpa.w"

BITFIELD t_input_phase:2;
/*:567*//*607:*/
#line 6608 "./marpa.w"

BITFIELD t_use_leo_flag:1;
BITFIELD t_is_using_leo:1;
/*:607*//*614:*/
#line 6660 "./marpa.w"
BITFIELD t_is_exhausted:1;
/*:614*//*1378:*/
#line 16428 "./marpa.w"

BITFIELD t_trace_source_type:3;
/*:1378*/
#line 6079 "./marpa.w"

};

/*:555*/
#line 17432 "./marpa.w"

/*685:*/
#line 7324 "./marpa.w"

struct s_token_source{
NSYID t_nsyid;
int t_value;
};

/*:685*//*686:*/
#line 7333 "./marpa.w"

struct s_source{
void*t_predecessor;
union{
void*t_completion;
struct s_token_source t_token;
}t_cause;
BITFIELD t_is_rejected:1;
BITFIELD t_is_active:1;

};

/*:686*//*689:*/
#line 7350 "./marpa.w"

struct marpa_source_link_s{
SRCL t_next;
struct s_source t_source;
};
typedef struct marpa_source_link_s SRCL_Object;

/*:689*//*690:*/
#line 7357 "./marpa.w"

struct s_ambiguous_source{
SRCL t_leo;
SRCL t_token;
SRCL t_completion;
};

/*:690*//*691:*/
#line 7364 "./marpa.w"

union u_source_container{
struct s_ambiguous_source t_ambiguous;
struct marpa_source_link_s t_unique;
};

/*:691*/
#line 17433 "./marpa.w"

/*656:*/
#line 7004 "./marpa.w"

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

/*:656*/
#line 17434 "./marpa.w"

/*937:*/
#line 11159 "./marpa.w"

struct marpa_traverser{
/*938:*/
#line 11174 "./marpa.w"

YIM t_trv_yim;
SRCL t_trv_leo_srcl;
SRCL t_trv_token_srcl;
SRCL t_trv_completion_srcl;

/*:938*//*944:*/
#line 11199 "./marpa.w"

RECCE t_trv_recce;
/*:944*/
#line 11161 "./marpa.w"

/*962:*/
#line 11536 "./marpa.w"

int t_ref_count;
/*:962*/
#line 11162 "./marpa.w"

/*940:*/
#line 11187 "./marpa.w"

int t_trv_soft_error;
/*:940*//*969:*/
#line 11592 "./marpa.w"

BITFIELD t_is_trivial:1;
/*:969*/
#line 11163 "./marpa.w"

};
typedef struct marpa_traverser TRAVERSER_Object;

/*:937*/
#line 17435 "./marpa.w"

/*984:*/
#line 11735 "./marpa.w"

struct marpa_ltraverser{
/*985:*/
#line 11747 "./marpa.w"

LIM t_ltrv_lim;

/*:985*//*991:*/
#line 11769 "./marpa.w"

RECCE t_ltrv_recce;
/*:991*/
#line 11737 "./marpa.w"

/*1001:*/
#line 11838 "./marpa.w"

int t_ref_count;
/*:1001*/
#line 11738 "./marpa.w"

/*987:*/
#line 11757 "./marpa.w"

int t_ltrv_soft_error;
/*:987*/
#line 11739 "./marpa.w"

};
typedef struct marpa_ltraverser LTRAVERSER_Object;

/*:984*/
#line 17436 "./marpa.w"

/*1010:*/
#line 11901 "./marpa.w"

struct marpa_ptraverser{
/*1011:*/
#line 11913 "./marpa.w"

PIM t_ptrv_pim;
YS t_ptrv_ys;

/*:1011*//*1017:*/
#line 11936 "./marpa.w"

RECCE t_ptrv_recce;
/*:1017*/
#line 11903 "./marpa.w"

/*1028:*/
#line 12092 "./marpa.w"

int t_ref_count;
/*:1028*/
#line 11904 "./marpa.w"

/*1013:*/
#line 11924 "./marpa.w"

int t_ptrv_soft_error;
/*:1013*//*1035:*/
#line 12148 "./marpa.w"

BITFIELD t_is_trivial:1;
/*:1035*/
#line 11905 "./marpa.w"

};
typedef struct marpa_ptraverser PTRAVERSER_Object;

/*:1010*/
#line 17437 "./marpa.w"

/*1041:*/
#line 12181 "./marpa.w"

struct marpa_bocage{
/*1042:*/
#line 12195 "./marpa.w"

OR*t_or_nodes;
AND t_and_nodes;
/*:1042*//*1046:*/
#line 12224 "./marpa.w"

GRAMMAR t_grammar;

/*:1046*//*1050:*/
#line 12241 "./marpa.w"

struct marpa_obstack*t_obs;
/*:1050*//*1053:*/
#line 12309 "./marpa.w"

LBV t_valued_bv;
LBV t_valued_locked_bv;

/*:1053*/
#line 12183 "./marpa.w"

/*1043:*/
#line 12198 "./marpa.w"

int t_or_node_capacity;
int t_or_node_count;
int t_and_node_count;
ORID t_top_or_node_id;

/*:1043*//*1067:*/
#line 12457 "./marpa.w"
int t_ambiguity_metric;
/*:1067*//*1071:*/
#line 12471 "./marpa.w"
int t_ref_count;
/*:1071*/
#line 12184 "./marpa.w"

/*1078:*/
#line 12528 "./marpa.w"

BITFIELD t_is_nulling:1;
/*:1078*/
#line 12185 "./marpa.w"

};

/*:1041*/
#line 17438 "./marpa.w"


/*:1457*/

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

/*1458:*/
#line 17440 "./marpa.w"

/*1347:*/
#line 15978 "./marpa.w"

extern void*(*const marpa__out_of_memory)(void);

/*:1347*//*1438:*/
#line 17252 "./marpa.w"

extern int marpa__default_debug_handler(const char*format,...);
extern int(*marpa__debug_handler)(const char*,...);
extern int marpa__debug_level;

/*:1438*/
#line 17441 "./marpa.w"

#if MARPA_DEBUG
/*1443:*/
#line 17284 "./marpa.w"

static const char*yim_tag_safe(
char*buffer,GRAMMAR g,YIM yim)UNUSED;
static const char*yim_tag(GRAMMAR g,YIM yim)UNUSED;
/*:1443*//*1445:*/
#line 17310 "./marpa.w"

static char*lim_tag_safe(char*buffer,LIM lim)UNUSED;
static char*lim_tag(LIM lim)UNUSED;
/*:1445*//*1447:*/
#line 17336 "./marpa.w"

static const char*or_tag_safe(char*buffer,OR or)UNUSED;
static const char*or_tag(OR or)UNUSED;
/*:1447*//*1449:*/
#line 17368 "./marpa.w"

static const char*ahm_tag_safe(char*buffer,AHM ahm)UNUSED;
static const char*ahm_tag(AHM ahm)UNUSED;
/*:1449*/
#line 17443 "./marpa.w"

/*1444:*/
#line 17289 "./marpa.w"

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

/*:1444*//*1446:*/
#line 17315 "./marpa.w"

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

/*:1446*//*1448:*/
#line 17340 "./marpa.w"

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

/*:1448*//*1450:*/
#line 17371 "./marpa.w"

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

/*:1450*/
#line 17444 "./marpa.w"

#endif
/*1442:*/
#line 17276 "./marpa.w"

int(*marpa__debug_handler)(const char*,...)= 
marpa__default_debug_handler;
int marpa__debug_level= 0;

/*:1442*/
#line 17446 "./marpa.w"

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
/*:79*//*81:*/
#line 862 "./marpa.w"

g->t_start_nsyid= -1;
/*:81*//*85:*/
#line 901 "./marpa.w"

g->t_start_nrl= NULL;
g->t_start_irl= NULL;

/*:85*//*88:*/
#line 916 "./marpa.w"

External_Size_of_G(g)= 0;

/*:88*//*91:*/
#line 929 "./marpa.w"

g->t_max_rule_length= 0;

/*:91*//*95:*/
#line 942 "./marpa.w"

g->t_default_rank= 0;
/*:95*//*100:*/
#line 977 "./marpa.w"

g->t_is_precomputed= 0;
/*:100*//*103:*/
#line 989 "./marpa.w"

g->t_has_cycle= 0;
/*:103*//*106:*/
#line 1009 "./marpa.w"
g->t_bv_nsyid_is_terminal= NULL;

/*:106*//*108:*/
#line 1024 "./marpa.w"

g->t_lbv_isyid_is_completion_event= NULL;
g->t_lbv_isyid_completion_event_starts_active= NULL;
g->t_lbv_isyid_is_nulled_event= NULL;
g->t_lbv_isyid_nulled_event_starts_active= NULL;
g->t_lbv_isyid_is_prediction_event= NULL;
g->t_lbv_isyid_prediction_event_starts_active= NULL;

/*:108*//*115:*/
#line 1065 "./marpa.w"

MARPA_DSTACK_INIT(g->t_events,GEV_Object,INITIAL_G_EVENTS_CAPACITY);
/*:115*//*123:*/
#line 1137 "./marpa.w"

(g)->t_irl_tree= _marpa_avl_create(duplicate_rule_cmp,NULL);
/*:123*//*127:*/
#line 1168 "./marpa.w"

g->t_obs= marpa_obs_init;
g->t_irl_obs= marpa_obs_init;
/*:127*//*130:*/
#line 1184 "./marpa.w"

cilar_init(&(g)->t_cilar);
/*:130*//*139:*/
#line 1232 "./marpa.w"

g->t_error= MARPA_ERR_NONE;
g->t_error_string= NULL;
/*:139*//*164:*/
#line 1395 "./marpa.w"

g->t_force_valued= 0;
/*:164*//*460:*/
#line 4919 "./marpa.w"

g->t_ahm_count= 0;

/*:460*//*462:*/
#line 4927 "./marpa.w"

g->t_ahms= NULL;
/*:462*//*536:*/
#line 5855 "./marpa.w"

MARPA_DSTACK_INIT2(g->t_gzwa_stack,GZWA);
/*:536*//*544:*/
#line 5894 "./marpa.w"

(g)->t_zwp_tree= _marpa_avl_create(zwp_cmp,NULL);
/*:544*/
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

/*:70*//*116:*/
#line 1067 "./marpa.w"
MARPA_DSTACK_DESTROY(g->t_events);

/*:116*//*125:*/
#line 1144 "./marpa.w"

/*124:*/
#line 1139 "./marpa.w"

{
_marpa_avl_destroy((g)->t_irl_tree);
(g)->t_irl_tree= NULL;
}
/*:124*/
#line 1145 "./marpa.w"


/*:125*//*128:*/
#line 1171 "./marpa.w"

marpa_obs_free(g->t_obs);
marpa_obs_free(g->t_irl_obs);

/*:128*//*131:*/
#line 1186 "./marpa.w"

cilar_destroy(&(g)->t_cilar);

/*:131*//*463:*/
#line 4929 "./marpa.w"

my_free(g->t_ahms);

/*:463*//*537:*/
#line 5857 "./marpa.w"

MARPA_DSTACK_DESTROY(g->t_gzwa_stack);

/*:537*//*545:*/
#line 5896 "./marpa.w"

{
_marpa_avl_destroy((g)->t_zwp_tree);
(g)->t_zwp_tree= NULL;
}

/*:545*//*546:*/
#line 5902 "./marpa.w"

/*124:*/
#line 1139 "./marpa.w"

{
_marpa_avl_destroy((g)->t_irl_tree);
(g)->t_irl_tree= NULL;
}
/*:124*/
#line 5903 "./marpa.w"


/*:546*/
#line 740 "./marpa.w"

my_free(g);
}

/*:58*//*63:*/
#line 765 "./marpa.w"

int marpa_g_highest_symbol_id(Marpa_Grammar g){
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 767 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
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
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 824 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 825 "./marpa.w"

return IRL_Count_of_G(g)-1;
}
int _marpa_g_nrl_count(Marpa_Grammar g){
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 829 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
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

/*:76*//*82:*/
#line 864 "./marpa.w"

Marpa_Symbol_ID marpa_g_start_symbol(Marpa_Grammar g)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 867 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 868 "./marpa.w"

if(g->t_start_isy_id<0){
MARPA_ERROR(MARPA_ERR_NO_START_SYMBOL);
return-1;
}
return g->t_start_isy_id;
}
/*:82*//*83:*/
#line 881 "./marpa.w"

Marpa_Symbol_ID marpa_g_start_symbol_set(Marpa_Grammar g,Marpa_Symbol_ID isy_id)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 884 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 885 "./marpa.w"

/*1319:*/
#line 15731 "./marpa.w"

if(_MARPA_UNLIKELY(G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_PRECOMPUTED);
return failure_indicator;
}

/*:1319*/
#line 886 "./marpa.w"

/*1321:*/
#line 15742 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1321*/
#line 887 "./marpa.w"

/*1322:*/
#line 15749 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}
/*:1322*/
#line 888 "./marpa.w"

return g->t_start_isy_id= isy_id;
}

/*:83*//*96:*/
#line 944 "./marpa.w"

Marpa_Rank marpa_g_default_rank(Marpa_Grammar g)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 947 "./marpa.w"

clear_error(g);
/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 949 "./marpa.w"

return Default_Rank_of_G(g);
}
/*:96*//*97:*/
#line 954 "./marpa.w"

Marpa_Rank marpa_g_default_rank_set(Marpa_Grammar g,Marpa_Rank rank)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 957 "./marpa.w"

clear_error(g);
/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 959 "./marpa.w"

/*1319:*/
#line 15731 "./marpa.w"

if(_MARPA_UNLIKELY(G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_PRECOMPUTED);
return failure_indicator;
}

/*:1319*/
#line 960 "./marpa.w"

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

/*:97*//*101:*/
#line 979 "./marpa.w"

int marpa_g_is_precomputed(Marpa_Grammar g)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 982 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 983 "./marpa.w"

return G_is_Precomputed(g);
}

/*:101*//*104:*/
#line 991 "./marpa.w"

int marpa_g_has_cycle(Marpa_Grammar g)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 994 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 995 "./marpa.w"

return g->t_has_cycle;
}

/*:104*//*118:*/
#line 1077 "./marpa.w"

PRIVATE
void event_new(GRAMMAR g,int type)
{


GEV end_of_stack= G_EVENT_PUSH(g);
end_of_stack->t_type= type;
end_of_stack->t_value= 0;
}
/*:118*//*119:*/
#line 1087 "./marpa.w"

PRIVATE
void int_event_new(GRAMMAR g,int type,int value)
{


GEV end_of_stack= G_EVENT_PUSH(g);
end_of_stack->t_type= type;
end_of_stack->t_value= value;
}

/*:119*//*120:*/
#line 1098 "./marpa.w"

Marpa_Event_Type
marpa_g_event(Marpa_Grammar g,Marpa_Event*public_event,
int ix)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 1103 "./marpa.w"

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

/*:120*//*121:*/
#line 1123 "./marpa.w"

Marpa_Event_Type
marpa_g_event_count(Marpa_Grammar g)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 1127 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 1128 "./marpa.w"

return MARPA_DSTACK_LENGTH(g->t_events);
}

/*:121*//*141:*/
#line 1243 "./marpa.w"

Marpa_Error_Code marpa_g_error(Marpa_Grammar g,const char**p_error_string)
{
const Marpa_Error_Code error_code= g->t_error;
const char*error_string= g->t_error_string;
if(p_error_string){
*p_error_string= error_string;
}
return error_code;
}

/*:141*//*142:*/
#line 1254 "./marpa.w"

Marpa_Error_Code
marpa_g_error_clear(Marpa_Grammar g)
{
clear_error(g);
return g->t_error;
}

/*:142*//*148:*/
#line 1284 "./marpa.w"

PRIVATE ISY
symbol_new(GRAMMAR g)
{
ISY isy= marpa_obs_new(g->t_obs,struct s_isy,1);
/*153:*/
#line 1317 "./marpa.w"

isy->t_rank= Default_Rank_of_G(g);
/*:153*//*157:*/
#line 1363 "./marpa.w"

ISY_is_LHS(isy)= 0;

/*:157*//*159:*/
#line 1370 "./marpa.w"

ISY_is_Sequence_LHS(isy)= 0;

/*:159*//*161:*/
#line 1386 "./marpa.w"

ISY_is_Valued(isy)= g->t_force_valued?1:0;
ISY_is_Valued_Locked(isy)= g->t_force_valued?1:0;

/*:161*//*169:*/
#line 1454 "./marpa.w"

isy->t_is_accessible= 0;
/*:169*//*172:*/
#line 1475 "./marpa.w"

isy->t_is_counted= 0;
/*:172*//*175:*/
#line 1491 "./marpa.w"

isy->t_is_nulling= 0;
/*:175*//*178:*/
#line 1508 "./marpa.w"

isy->t_is_nullable= 0;
/*:178*//*181:*/
#line 1531 "./marpa.w"

isy->t_is_terminal= 0;
isy->t_is_locked_terminal= 0;
/*:181*//*186:*/
#line 1576 "./marpa.w"

isy->t_is_productive= 0;
/*:186*//*189:*/
#line 1599 "./marpa.w"

isy->t_is_completion_event= 0;
isy->t_completion_event_starts_active= 0;
/*:189*//*194:*/
#line 1669 "./marpa.w"

isy->t_is_nulled_event= 0;
isy->t_nulled_event_starts_active= 0;
/*:194*//*199:*/
#line 1742 "./marpa.w"

isy->t_is_prediction_event= 0;
isy->t_prediction_event_starts_active= 0;
/*:199*//*205:*/
#line 1821 "./marpa.w"

Nulled_ISYIDs_of_ISY(isy)= NULL;

/*:205*//*208:*/
#line 1837 "./marpa.w"
NSY_of_ISY(isy)= NULL;
/*:208*//*212:*/
#line 1869 "./marpa.w"
Nulling_NSY_of_ISY(isy)= NULL;
/*:212*/
#line 1289 "./marpa.w"

symbol_add(g,isy);
return isy;
}

/*:148*//*149:*/
#line 1294 "./marpa.w"

Marpa_Symbol_ID
marpa_g_symbol_new(Marpa_Grammar g)
{
const ISY symbol= symbol_new(g);
return ID_of_ISY(symbol);
}

/*:149*//*151:*/
#line 1303 "./marpa.w"

int marpa_g_symbol_is_start(Marpa_Grammar g,Marpa_Symbol_ID isy_id)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 1306 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 1307 "./marpa.w"

/*1321:*/
#line 15742 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1321*/
#line 1308 "./marpa.w"

/*1322:*/
#line 15749 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}
/*:1322*/
#line 1309 "./marpa.w"

if(g->t_start_isy_id<0)return 0;
return isy_id==g->t_start_isy_id?1:0;
}

/*:151*//*154:*/
#line 1320 "./marpa.w"

int marpa_g_symbol_rank(Marpa_Grammar g,
Marpa_Symbol_ID isy_id)
{
ISY isy;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 1325 "./marpa.w"

clear_error(g);
/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 1327 "./marpa.w"

/*1321:*/
#line 15742 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1321*/
#line 1328 "./marpa.w"

/*1323:*/
#line 15754 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return failure_indicator;
}

/*:1323*/
#line 1329 "./marpa.w"

isy= ISY_by_ID(isy_id);
return Rank_of_ISY(isy);
}
/*:154*//*155:*/
#line 1333 "./marpa.w"

int marpa_g_symbol_rank_set(
Marpa_Grammar g,Marpa_Symbol_ID isy_id,Marpa_Rank rank)
{
ISY isy;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 1338 "./marpa.w"

clear_error(g);
/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 1340 "./marpa.w"

/*1319:*/
#line 15731 "./marpa.w"

if(_MARPA_UNLIKELY(G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_PRECOMPUTED);
return failure_indicator;
}

/*:1319*/
#line 1341 "./marpa.w"

/*1321:*/
#line 15742 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1321*/
#line 1342 "./marpa.w"

/*1323:*/
#line 15754 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return failure_indicator;
}

/*:1323*/
#line 1343 "./marpa.w"

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

/*:155*//*165:*/
#line 1397 "./marpa.w"

int marpa_g_force_valued(Marpa_Grammar g)
{
ISYID isyid;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 1401 "./marpa.w"

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

/*:165*//*166:*/
#line 1416 "./marpa.w"

int marpa_g_symbol_is_valued(
Marpa_Grammar g,
Marpa_Symbol_ID isy_id)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 1421 "./marpa.w"

/*1321:*/
#line 15742 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1321*/
#line 1422 "./marpa.w"

/*1322:*/
#line 15749 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}
/*:1322*/
#line 1423 "./marpa.w"

return ISY_is_Valued(ISY_by_ID(isy_id));
}

/*:166*//*167:*/
#line 1427 "./marpa.w"

int marpa_g_symbol_is_valued_set(
Marpa_Grammar g,Marpa_Symbol_ID isy_id,int value)
{
ISY symbol;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 1432 "./marpa.w"

/*1321:*/
#line 15742 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1321*/
#line 1433 "./marpa.w"

/*1322:*/
#line 15749 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}
/*:1322*/
#line 1434 "./marpa.w"

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

/*:167*//*170:*/
#line 1462 "./marpa.w"

int marpa_g_symbol_is_accessible(Marpa_Grammar g,Marpa_Symbol_ID isy_id)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 1465 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 1466 "./marpa.w"

/*1320:*/
#line 15737 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1320*/
#line 1467 "./marpa.w"

/*1321:*/
#line 15742 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1321*/
#line 1468 "./marpa.w"

/*1322:*/
#line 15749 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}
/*:1322*/
#line 1469 "./marpa.w"

return ISY_is_Accessible(ISY_by_ID(isy_id));
}

/*:170*//*173:*/
#line 1477 "./marpa.w"

int marpa_g_symbol_is_counted(Marpa_Grammar g,
Marpa_Symbol_ID isy_id)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 1481 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 1482 "./marpa.w"

/*1321:*/
#line 15742 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1321*/
#line 1483 "./marpa.w"

/*1322:*/
#line 15749 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}
/*:1322*/
#line 1484 "./marpa.w"

return ISY_by_ID(isy_id)->t_is_counted;
}

/*:173*//*176:*/
#line 1493 "./marpa.w"

int marpa_g_symbol_is_nulling(Marpa_Grammar g,Marpa_Symbol_ID isy_id)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 1496 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 1497 "./marpa.w"

/*1320:*/
#line 15737 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1320*/
#line 1498 "./marpa.w"

/*1321:*/
#line 15742 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1321*/
#line 1499 "./marpa.w"

/*1322:*/
#line 15749 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}
/*:1322*/
#line 1500 "./marpa.w"

return ISY_is_Nulling(ISY_by_ID(isy_id));
}

/*:176*//*179:*/
#line 1510 "./marpa.w"

int marpa_g_symbol_is_nullable(Marpa_Grammar g,Marpa_Symbol_ID isy_id)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 1513 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 1514 "./marpa.w"

/*1320:*/
#line 15737 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1320*/
#line 1515 "./marpa.w"

/*1321:*/
#line 15742 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1321*/
#line 1516 "./marpa.w"

/*1322:*/
#line 15749 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}
/*:1322*/
#line 1517 "./marpa.w"

return ISYID_is_Nullable(isy_id);
}

/*:179*//*183:*/
#line 1537 "./marpa.w"

int marpa_g_symbol_is_terminal(Marpa_Grammar g,
Marpa_Symbol_ID isy_id)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 1541 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 1542 "./marpa.w"

/*1321:*/
#line 15742 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1321*/
#line 1543 "./marpa.w"

/*1322:*/
#line 15749 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}
/*:1322*/
#line 1544 "./marpa.w"

return ISYID_is_Terminal(isy_id);
}
/*:183*//*184:*/
#line 1547 "./marpa.w"

int marpa_g_symbol_is_terminal_set(
Marpa_Grammar g,Marpa_Symbol_ID isy_id,int value)
{
ISY symbol;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 1552 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 1553 "./marpa.w"

/*1319:*/
#line 15731 "./marpa.w"

if(_MARPA_UNLIKELY(G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_PRECOMPUTED);
return failure_indicator;
}

/*:1319*/
#line 1554 "./marpa.w"

/*1321:*/
#line 15742 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1321*/
#line 1555 "./marpa.w"

/*1322:*/
#line 15749 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}
/*:1322*/
#line 1556 "./marpa.w"

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

/*:184*//*187:*/
#line 1578 "./marpa.w"

int marpa_g_symbol_is_productive(
Marpa_Grammar g,
Marpa_Symbol_ID isy_id)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 1583 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 1584 "./marpa.w"

/*1320:*/
#line 15737 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1320*/
#line 1585 "./marpa.w"

/*1321:*/
#line 15742 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1321*/
#line 1586 "./marpa.w"

/*1322:*/
#line 15749 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}
/*:1322*/
#line 1587 "./marpa.w"

return ISY_is_Productive(ISY_by_ID(isy_id));
}

/*:187*//*190:*/
#line 1602 "./marpa.w"

int marpa_g_symbol_is_completion_event(Marpa_Grammar g,
Marpa_Symbol_ID isy_id)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 1606 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 1607 "./marpa.w"

/*1321:*/
#line 15742 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1321*/
#line 1608 "./marpa.w"

/*1322:*/
#line 15749 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}
/*:1322*/
#line 1609 "./marpa.w"

return ISYID_is_Completion_Event(isy_id);
}
/*:190*//*191:*/
#line 1612 "./marpa.w"

int marpa_g_symbol_is_completion_event_set(
Marpa_Grammar g,Marpa_Symbol_ID isy_id,int value)
{
ISY isy;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 1617 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 1618 "./marpa.w"

/*1319:*/
#line 15731 "./marpa.w"

if(_MARPA_UNLIKELY(G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_PRECOMPUTED);
return failure_indicator;
}

/*:1319*/
#line 1619 "./marpa.w"

/*1321:*/
#line 15742 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1321*/
#line 1620 "./marpa.w"

/*1322:*/
#line 15749 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}
/*:1322*/
#line 1621 "./marpa.w"

isy= ISY_by_ID(isy_id);
switch(value){
case 0:case 1:
ISY_Completion_Event_Starts_Active(isy)= Boolean(value);
return ISY_is_Completion_Event(isy)= Boolean(value);
}
MARPA_ERROR(MARPA_ERR_INVALID_BOOLEAN);
return failure_indicator;
}
/*:191*//*192:*/
#line 1631 "./marpa.w"

int
marpa_g_completion_symbol_activate(Marpa_Grammar g,
Marpa_Symbol_ID isy_id,
int reactivate)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 1637 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 1638 "./marpa.w"

/*1319:*/
#line 15731 "./marpa.w"

if(_MARPA_UNLIKELY(G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_PRECOMPUTED);
return failure_indicator;
}

/*:1319*/
#line 1639 "./marpa.w"

/*1321:*/
#line 15742 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1321*/
#line 1640 "./marpa.w"

/*1322:*/
#line 15749 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}
/*:1322*/
#line 1641 "./marpa.w"

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

/*:192*//*195:*/
#line 1672 "./marpa.w"

int marpa_g_symbol_is_nulled_event(Marpa_Grammar g,
Marpa_Symbol_ID isy_id)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 1676 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 1677 "./marpa.w"

/*1321:*/
#line 15742 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1321*/
#line 1678 "./marpa.w"

/*1322:*/
#line 15749 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}
/*:1322*/
#line 1679 "./marpa.w"

return ISYID_is_Nulled_Event(isy_id);
}

/*:195*//*196:*/
#line 1685 "./marpa.w"

int marpa_g_symbol_is_nulled_event_set(
Marpa_Grammar g,Marpa_Symbol_ID isy_id,int value)
{
ISY isy;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 1690 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 1691 "./marpa.w"

/*1319:*/
#line 15731 "./marpa.w"

if(_MARPA_UNLIKELY(G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_PRECOMPUTED);
return failure_indicator;
}

/*:1319*/
#line 1692 "./marpa.w"

/*1321:*/
#line 15742 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1321*/
#line 1693 "./marpa.w"

/*1322:*/
#line 15749 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}
/*:1322*/
#line 1694 "./marpa.w"

isy= ISY_by_ID(isy_id);
switch(value){
case 0:case 1:
ISY_Nulled_Event_Starts_Active(isy)= Boolean(value);
return ISY_is_Nulled_Event(isy)= Boolean(value);
}
MARPA_ERROR(MARPA_ERR_INVALID_BOOLEAN);
return failure_indicator;
}
/*:196*//*197:*/
#line 1704 "./marpa.w"

int
marpa_g_nulled_symbol_activate(Marpa_Grammar g,
Marpa_Symbol_ID isy_id,
int reactivate)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 1710 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 1711 "./marpa.w"

/*1319:*/
#line 15731 "./marpa.w"

if(_MARPA_UNLIKELY(G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_PRECOMPUTED);
return failure_indicator;
}

/*:1319*/
#line 1712 "./marpa.w"

/*1321:*/
#line 15742 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1321*/
#line 1713 "./marpa.w"

/*1322:*/
#line 15749 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}
/*:1322*/
#line 1714 "./marpa.w"

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

/*:197*//*200:*/
#line 1745 "./marpa.w"

int marpa_g_symbol_is_prediction_event(Marpa_Grammar g,
Marpa_Symbol_ID isy_id)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 1749 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 1750 "./marpa.w"

/*1321:*/
#line 15742 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1321*/
#line 1751 "./marpa.w"

/*1322:*/
#line 15749 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}
/*:1322*/
#line 1752 "./marpa.w"

return ISYID_is_Prediction_Event(isy_id);
}
/*:200*//*201:*/
#line 1755 "./marpa.w"

int marpa_g_symbol_is_prediction_event_set(
Marpa_Grammar g,Marpa_Symbol_ID isy_id,int value)
{
ISY isy;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 1760 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 1761 "./marpa.w"

/*1319:*/
#line 15731 "./marpa.w"

if(_MARPA_UNLIKELY(G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_PRECOMPUTED);
return failure_indicator;
}

/*:1319*/
#line 1762 "./marpa.w"

/*1321:*/
#line 15742 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1321*/
#line 1763 "./marpa.w"

/*1322:*/
#line 15749 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}
/*:1322*/
#line 1764 "./marpa.w"

isy= ISY_by_ID(isy_id);
switch(value){
case 0:case 1:
ISY_Prediction_Event_Starts_Active(isy)= Boolean(value);
return ISY_is_Prediction_Event(isy)= Boolean(value);
}
MARPA_ERROR(MARPA_ERR_INVALID_BOOLEAN);
return failure_indicator;
}
/*:201*//*202:*/
#line 1774 "./marpa.w"

int
marpa_g_prediction_symbol_activate(Marpa_Grammar g,
Marpa_Symbol_ID isy_id,
int reactivate)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 1780 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 1781 "./marpa.w"

/*1319:*/
#line 15731 "./marpa.w"

if(_MARPA_UNLIKELY(G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_PRECOMPUTED);
return failure_indicator;
}

/*:1319*/
#line 1782 "./marpa.w"

/*1321:*/
#line 15742 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1321*/
#line 1783 "./marpa.w"

/*1322:*/
#line 15749 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}
/*:1322*/
#line 1784 "./marpa.w"

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

/*:202*//*203:*/
#line 1804 "./marpa.w"

/*:203*//*209:*/
#line 1838 "./marpa.w"

Marpa_NSY_ID _marpa_g_isy_nsy(
Marpa_Grammar g,
Marpa_Symbol_ID isy_id)
{
ISY isy;
NSY nsy;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 1845 "./marpa.w"

/*1321:*/
#line 15742 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1321*/
#line 1846 "./marpa.w"

/*1322:*/
#line 15749 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}
/*:1322*/
#line 1847 "./marpa.w"

isy= ISY_by_ID(isy_id);
nsy= NSY_of_ISY(isy);
return nsy?ID_of_NSY(nsy):-1;
}

/*:209*//*213:*/
#line 1870 "./marpa.w"

Marpa_NSY_ID _marpa_g_isy_nulling_nsy(
Marpa_Grammar g,
Marpa_Symbol_ID isy_id)
{
ISY isy;
NSY nsy;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 1877 "./marpa.w"

/*1321:*/
#line 15742 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1321*/
#line 1878 "./marpa.w"

/*1322:*/
#line 15749 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}
/*:1322*/
#line 1879 "./marpa.w"

isy= ISY_by_ID(isy_id);
nsy= Nulling_NSY_of_ISY(isy);
return nsy?ID_of_NSY(nsy):-1;
}

/*:213*//*215:*/
#line 1891 "./marpa.w"

PRIVATE
NSY symbol_alias_create(GRAMMAR g,ISY symbol)
{
NSY alias_nsy= semantic_nsy_new(g,symbol);
ISY_is_Nulling(symbol)= 0;
ISY_is_Nullable(symbol)= 1;
NSY_is_Nulling(alias_nsy)= 1;
return alias_nsy;
}

/*:215*//*222:*/
#line 1949 "./marpa.w"

PRIVATE NSY
nsy_start(GRAMMAR g)
{
const NSY nsy= marpa_obs_new(g->t_obs,struct s_nsy,1);
ID_of_NSY(nsy)= MARPA_DSTACK_LENGTH((g)->t_nsy_stack);
*MARPA_DSTACK_PUSH((g)->t_nsy_stack,NSY)= nsy;
/*220:*/
#line 1941 "./marpa.w"

nsy->t_nulling_or_node.t_or_node_type= NULLING_TOKEN_OR_NODE;

nsy->t_unvalued_or_node.t_or_node_type= UNVALUED_TOKEN_OR_NODE;
nsy->t_unvalued_or_node.t_nsyid= ID_of_NSY(nsy);

/*:220*//*232:*/
#line 2027 "./marpa.w"
NSY_is_LHS(nsy)= 0;
/*:232*//*235:*/
#line 2041 "./marpa.w"
NSY_is_Nulling(nsy)= 0;
/*:235*//*238:*/
#line 2058 "./marpa.w"
LHS_CIL_of_NSY(nsy)= NULL;

/*:238*//*240:*/
#line 2066 "./marpa.w"
NSY_is_Semantic(nsy)= 0;
/*:240*//*243:*/
#line 2089 "./marpa.w"
Source_ISY_of_NSY(nsy)= NULL;
/*:243*//*247:*/
#line 2114 "./marpa.w"

LHS_IRL_of_NSY(nsy)= NULL;
IRL_Offset_of_NSY(nsy)= -1;

/*:247*//*252:*/
#line 2165 "./marpa.w"

Rank_of_NSY(nsy)= Default_Rank_of_G(g)*EXTERNAL_RANK_FACTOR+MAXIMUM_CHAF_RANK;
/*:252*/
#line 1956 "./marpa.w"

return nsy;
}

/*:222*//*223:*/
#line 1962 "./marpa.w"

PRIVATE NSY
nsy_new(GRAMMAR g,ISY source)
{
const NSY new_nsy= nsy_start(g);
Source_ISY_of_NSY(new_nsy)= source;
Rank_of_NSY(new_nsy)= NSY_Rank_by_ISY(source);
return new_nsy;
}

/*:223*//*224:*/
#line 1974 "./marpa.w"

PRIVATE NSY
semantic_nsy_new(GRAMMAR g,ISY source)
{
const NSY new_nsy= nsy_new(g,source);
NSY_is_Semantic(new_nsy)= 1;
return new_nsy;
}

/*:224*//*225:*/
#line 1985 "./marpa.w"

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

/*:225*//*228:*/
#line 2007 "./marpa.w"

int _marpa_g_nsy_count(Marpa_Grammar g){
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 2009 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 2010 "./marpa.w"

return NSY_Count_of_G(g);
}

/*:228*//*230:*/
#line 2015 "./marpa.w"

Marpa_NSY_ID _marpa_g_start_nsy(Marpa_Grammar g)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 2018 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 2019 "./marpa.w"

/*1320:*/
#line 15737 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1320*/
#line 2020 "./marpa.w"

return g->t_start_nsyid;
}

/*:230*//*233:*/
#line 2028 "./marpa.w"

int _marpa_g_nsy_is_lhs(Marpa_Grammar g,Marpa_NSY_ID nsy_id)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 2031 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 2032 "./marpa.w"

/*1320:*/
#line 15737 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1320*/
#line 2033 "./marpa.w"

/*1324:*/
#line 15760 "./marpa.w"

if(_MARPA_UNLIKELY(!nsy_is_valid(g,nsy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_NSYID);
return failure_indicator;
}
/*:1324*/
#line 2034 "./marpa.w"

return NSY_is_LHS(NSY_by_ID(nsy_id));
}

/*:233*//*236:*/
#line 2042 "./marpa.w"

int _marpa_g_nsy_is_nulling(Marpa_Grammar g,Marpa_NSY_ID nsy_id)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 2045 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 2046 "./marpa.w"

/*1320:*/
#line 15737 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1320*/
#line 2047 "./marpa.w"

/*1324:*/
#line 15760 "./marpa.w"

if(_MARPA_UNLIKELY(!nsy_is_valid(g,nsy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_NSYID);
return failure_indicator;
}
/*:1324*/
#line 2048 "./marpa.w"

return NSY_is_Nulling(NSY_by_ID(nsy_id));
}

/*:236*//*241:*/
#line 2067 "./marpa.w"

int _marpa_g_nsy_is_semantic(
Marpa_Grammar g,
Marpa_NRL_ID nsy_id)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 2072 "./marpa.w"

/*1324:*/
#line 15760 "./marpa.w"

if(_MARPA_UNLIKELY(!nsy_is_valid(g,nsy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_NSYID);
return failure_indicator;
}
/*:1324*/
#line 2073 "./marpa.w"

return NSYID_is_Semantic(nsy_id);
}

/*:241*//*244:*/
#line 2090 "./marpa.w"

Marpa_Rule_ID _marpa_g_source_isy(
Marpa_Grammar g,
Marpa_NRL_ID nsy_id)
{
ISY source_isy;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 2096 "./marpa.w"

/*1324:*/
#line 15760 "./marpa.w"

if(_MARPA_UNLIKELY(!nsy_is_valid(g,nsy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_NSYID);
return failure_indicator;
}
/*:1324*/
#line 2097 "./marpa.w"

source_isy= Source_ISY_of_NSYID(nsy_id);
return ID_of_ISY(source_isy);
}

/*:244*//*249:*/
#line 2125 "./marpa.w"

Marpa_Rule_ID _marpa_g_nsy_lhs_irl(Marpa_Grammar g,Marpa_NSY_ID nsy_id)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 2128 "./marpa.w"

/*1324:*/
#line 15760 "./marpa.w"

if(_MARPA_UNLIKELY(!nsy_is_valid(g,nsy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_NSYID);
return failure_indicator;
}
/*:1324*/
#line 2129 "./marpa.w"

{
const NSY nsy= NSY_by_ID(nsy_id);
const IRL lhs_irl= LHS_IRL_of_NSY(nsy);
if(lhs_irl)
return ID_of_IRL(lhs_irl);
}
return-1;
}

/*:249*//*250:*/
#line 2149 "./marpa.w"

int _marpa_g_nsy_irl_offset(Marpa_Grammar g,Marpa_NSY_ID nsy_id)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 2152 "./marpa.w"

NSY nsy;
/*1324:*/
#line 15760 "./marpa.w"

if(_MARPA_UNLIKELY(!nsy_is_valid(g,nsy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_NSYID);
return failure_indicator;
}
/*:1324*/
#line 2154 "./marpa.w"

nsy= NSY_by_ID(nsy_id);
return IRL_Offset_of_NSY(nsy);
}

/*:250*//*253:*/
#line 2167 "./marpa.w"

Marpa_Rank _marpa_g_nsy_rank(
Marpa_Grammar g,
Marpa_NSY_ID nsy_id)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 2172 "./marpa.w"

/*1324:*/
#line 15760 "./marpa.w"

if(_MARPA_UNLIKELY(!nsy_is_valid(g,nsy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_NSYID);
return failure_indicator;
}
/*:1324*/
#line 2173 "./marpa.w"

return Rank_of_NSY(NSY_by_ID(nsy_id));
}

/*:253*//*259:*/
#line 2208 "./marpa.w"

PRIVATE
IRL irl_start(GRAMMAR g,const ISYID lhs,const ISYID*rhs,int length)
{
IRL irl;
const size_t sizeof_irl= offsetof(struct s_irl,t_symbols)+
((size_t)length+1)*sizeof(irl->t_symbols[0]);
irl= marpa_obs_start(g->t_irl_obs,sizeof_irl,ALIGNOF(IRL));
Length_of_IRL(irl)= length;
irl->t_symbols[0]= lhs;
ISY_is_LHS(ISY_by_ID(lhs))= 1;
{
int i;
for(i= 0;i<length;i++)
{
irl->t_symbols[i+1]= rhs[i];
}
}
return irl;
}

PRIVATE
IRL irl_finish(GRAMMAR g,IRL rule)
{
/*278:*/
#line 2554 "./marpa.w"

rule->t_rank= Default_Rank_of_G(g);
/*:278*//*282:*/
#line 2603 "./marpa.w"

rule->t_null_ranks_high= 0;
/*:282*//*286:*/
#line 2643 "./marpa.w"

rule->t_is_bnf= 0;

/*:286*//*288:*/
#line 2649 "./marpa.w"

rule->t_is_sequence= 0;

/*:288*//*290:*/
#line 2663 "./marpa.w"

rule->t_minimum= -1;
/*:290*//*293:*/
#line 2689 "./marpa.w"

Separator_of_IRL(rule)= -1;
/*:293*//*298:*/
#line 2726 "./marpa.w"

rule->t_is_discard= 0;
/*:298*//*302:*/
#line 2766 "./marpa.w"

rule->t_is_proper_separation= 0;
/*:302*//*306:*/
#line 2787 "./marpa.w"

rule->t_is_loop= 0;
/*:306*//*309:*/
#line 2805 "./marpa.w"

IRL_is_Nulling(rule)= 0;
/*:309*//*312:*/
#line 2824 "./marpa.w"

IRL_is_Nullable(rule)= 0;
/*:312*//*316:*/
#line 2843 "./marpa.w"

IRL_is_Accessible(rule)= 1;
/*:316*//*319:*/
#line 2862 "./marpa.w"

IRL_is_Productive(rule)= 1;
/*:319*//*322:*/
#line 2881 "./marpa.w"

IRL_is_Used(rule)= 0;
/*:322*/
#line 2232 "./marpa.w"

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

/*:259*//*260:*/
#line 2248 "./marpa.w"

PRIVATE NRL
nrl_start(GRAMMAR g,int length)
{
NRL nrl;
const size_t sizeof_nrl= offsetof(struct s_nrl,t_nsyid_array)+
((size_t)length+1)*sizeof(nrl->t_nsyid_array[0]);


nrl= marpa__obs_alloc(g->t_obs,sizeof_nrl,ALIGNOF(NRL_Object));

ID_of_NRL(nrl)= MARPA_DSTACK_LENGTH((g)->t_nrl_stack);
Length_of_NRL(nrl)= length;
/*343:*/
#line 3018 "./marpa.w"

NRL_has_Virtual_LHS(nrl)= 0;
/*:343*//*346:*/
#line 3034 "./marpa.w"

NRL_has_Virtual_RHS(nrl)= 0;
/*:346*//*349:*/
#line 3053 "./marpa.w"

NRL_is_Right_Recursive(nrl)= 0;

/*:349*//*352:*/
#line 3064 "./marpa.w"
Real_SYM_Count_of_NRL(nrl)= 0;
/*:352*//*355:*/
#line 3082 "./marpa.w"
nrl->t_virtual_start= -1;
/*:355*//*358:*/
#line 3102 "./marpa.w"
nrl->t_virtual_end= -1;
/*:358*//*361:*/
#line 3124 "./marpa.w"
Source_IRL_of_NRL(nrl)= NULL;
/*:361*//*364:*/
#line 3151 "./marpa.w"

Rank_of_NRL(nrl)= Default_Rank_of_G(g)*EXTERNAL_RANK_FACTOR+MAXIMUM_CHAF_RANK;
/*:364*//*367:*/
#line 3173 "./marpa.w"

First_AHM_of_NRL(nrl)= NULL;

/*:367*//*412:*/
#line 4106 "./marpa.w"

NRL_is_CHAF(nrl)= 0;
/*:412*//*476:*/
#line 5026 "./marpa.w"

Last_Proper_SYMI_of_NRL(nrl)= -1;

/*:476*/
#line 2261 "./marpa.w"

*MARPA_DSTACK_PUSH((g)->t_nrl_stack,NRL)= nrl;
return nrl;
}

PRIVATE void
nrl_finish(GRAMMAR g,NRL nrl)
{
const NSY lhs_nsy= LHS_of_NRL(nrl);
NSY_is_LHS(lhs_nsy)= 1;
}

/*:260*//*262:*/
#line 2287 "./marpa.w"

Marpa_Rule_ID
marpa_g_rule_new(Marpa_Grammar g,
Marpa_Symbol_ID lhs_id,Marpa_Symbol_ID*rhs_ids,int length)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 2292 "./marpa.w"

Marpa_Rule_ID rule_id;
RULE rule;
/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 2295 "./marpa.w"

/*1319:*/
#line 15731 "./marpa.w"

if(_MARPA_UNLIKELY(G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_PRECOMPUTED);
return failure_indicator;
}

/*:1319*/
#line 2296 "./marpa.w"

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

/*:262*//*263:*/
#line 2341 "./marpa.w"

Marpa_Rule_ID marpa_g_sequence_new(Marpa_Grammar g,
Marpa_Symbol_ID lhs_id,Marpa_Symbol_ID rhs_id,Marpa_Symbol_ID separator_id,
int min,int flags)
{
RULE original_rule;
RULEID original_rule_id= -2;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 2348 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 2349 "./marpa.w"

/*1319:*/
#line 15731 "./marpa.w"

if(_MARPA_UNLIKELY(G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_PRECOMPUTED);
return failure_indicator;
}

/*:1319*/
#line 2350 "./marpa.w"

/*265:*/
#line 2381 "./marpa.w"

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

/*:265*/
#line 2351 "./marpa.w"

/*264:*/
#line 2359 "./marpa.w"

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

/*:264*/
#line 2352 "./marpa.w"

return original_rule_id;
FAILURE:
return failure_indicator;
}

/*:263*//*267:*/
#line 2434 "./marpa.w"

PRIVATE_NOT_INLINE int
duplicate_rule_cmp(const void*ap,const void*bp,void*param UNUSED)
{
IRL irl1= (IRL)ap;
IRL irl2= (IRL)bp;
int diff= LHS_ID_of_IRL(irl2)-LHS_ID_of_IRL(irl1);
if(diff)
return diff;
{




int ix;
const int length= Length_of_IRL(irl1);
diff= Length_of_IRL(irl2)-length;
if(diff)
return diff;
for(ix= 0;ix<length;ix++)
{
diff= RHS_ID_of_IRL(irl2,ix)-RHS_ID_of_IRL(irl1,ix);
if(diff)
return diff;
}
}
return 0;
}

/*:267*//*270:*/
#line 2490 "./marpa.w"

PRIVATE Marpa_Symbol_ID rule_lhs_get(RULE rule)
{
return rule->t_symbols[0];}
/*:270*//*271:*/
#line 2494 "./marpa.w"

Marpa_Symbol_ID marpa_g_rule_lhs(Marpa_Grammar g,Marpa_Rule_ID irl_id){
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 2496 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 2497 "./marpa.w"

/*1330:*/
#line 15798 "./marpa.w"

if(_MARPA_UNLIKELY(IRLID_is_Malformed(irl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_RULE_ID);
return failure_indicator;
}

/*:1330*/
#line 2498 "./marpa.w"

/*1328:*/
#line 15786 "./marpa.w"

if(_MARPA_UNLIKELY(!IRLID_of_G_Exists(irl_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_RULE_ID);
return-1;
}

/*:1328*/
#line 2499 "./marpa.w"

return rule_lhs_get(IRL_by_ID(irl_id));
}
/*:271*//*272:*/
#line 2502 "./marpa.w"

PRIVATE Marpa_Symbol_ID*rule_rhs_get(RULE rule)
{
return rule->t_symbols+1;}
/*:272*//*273:*/
#line 2506 "./marpa.w"

Marpa_Symbol_ID marpa_g_rule_rhs(Marpa_Grammar g,Marpa_Rule_ID irl_id,int ix){
RULE rule;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 2509 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 2510 "./marpa.w"

/*1330:*/
#line 15798 "./marpa.w"

if(_MARPA_UNLIKELY(IRLID_is_Malformed(irl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_RULE_ID);
return failure_indicator;
}

/*:1330*/
#line 2511 "./marpa.w"

/*1328:*/
#line 15786 "./marpa.w"

if(_MARPA_UNLIKELY(!IRLID_of_G_Exists(irl_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_RULE_ID);
return-1;
}

/*:1328*/
#line 2512 "./marpa.w"

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

/*:273*//*274:*/
#line 2525 "./marpa.w"

int marpa_g_rule_length(Marpa_Grammar g,Marpa_Rule_ID irl_id){
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 2527 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 2528 "./marpa.w"

/*1330:*/
#line 15798 "./marpa.w"

if(_MARPA_UNLIKELY(IRLID_is_Malformed(irl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_RULE_ID);
return failure_indicator;
}

/*:1330*/
#line 2529 "./marpa.w"

/*1328:*/
#line 15786 "./marpa.w"

if(_MARPA_UNLIKELY(!IRLID_of_G_Exists(irl_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_RULE_ID);
return-1;
}

/*:1328*/
#line 2530 "./marpa.w"

return Length_of_IRL(IRL_by_ID(irl_id));
}

/*:274*//*279:*/
#line 2557 "./marpa.w"

int marpa_g_rule_rank(Marpa_Grammar g,
Marpa_Rule_ID irl_id)
{
IRL irl;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 2562 "./marpa.w"

clear_error(g);
/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 2564 "./marpa.w"

/*1330:*/
#line 15798 "./marpa.w"

if(_MARPA_UNLIKELY(IRLID_is_Malformed(irl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_RULE_ID);
return failure_indicator;
}

/*:1330*/
#line 2565 "./marpa.w"

/*1329:*/
#line 15792 "./marpa.w"

if(_MARPA_UNLIKELY(!IRLID_of_G_Exists(irl_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_RULE_ID);
return failure_indicator;
}
/*:1329*/
#line 2566 "./marpa.w"

clear_error(g);
irl= IRL_by_ID(irl_id);
return Rank_of_IRL(irl);
}
/*:279*//*280:*/
#line 2571 "./marpa.w"

int marpa_g_rule_rank_set(
Marpa_Grammar g,Marpa_Rule_ID irl_id,Marpa_Rank rank)
{
IRL irl;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 2576 "./marpa.w"

clear_error(g);
/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 2578 "./marpa.w"

/*1319:*/
#line 15731 "./marpa.w"

if(_MARPA_UNLIKELY(G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_PRECOMPUTED);
return failure_indicator;
}

/*:1319*/
#line 2579 "./marpa.w"

/*1330:*/
#line 15798 "./marpa.w"

if(_MARPA_UNLIKELY(IRLID_is_Malformed(irl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_RULE_ID);
return failure_indicator;
}

/*:1330*/
#line 2580 "./marpa.w"

/*1329:*/
#line 15792 "./marpa.w"

if(_MARPA_UNLIKELY(!IRLID_of_G_Exists(irl_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_RULE_ID);
return failure_indicator;
}
/*:1329*/
#line 2581 "./marpa.w"

irl= IRL_by_ID(irl_id);
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
return Rank_of_IRL(irl)= rank;
}

/*:280*//*283:*/
#line 2607 "./marpa.w"

int marpa_g_rule_null_high(Marpa_Grammar g,
Marpa_Rule_ID irl_id)
{
IRL irl;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 2612 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 2613 "./marpa.w"

/*1330:*/
#line 15798 "./marpa.w"

if(_MARPA_UNLIKELY(IRLID_is_Malformed(irl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_RULE_ID);
return failure_indicator;
}

/*:1330*/
#line 2614 "./marpa.w"

/*1328:*/
#line 15786 "./marpa.w"

if(_MARPA_UNLIKELY(!IRLID_of_G_Exists(irl_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_RULE_ID);
return-1;
}

/*:1328*/
#line 2615 "./marpa.w"

irl= IRL_by_ID(irl_id);
return Null_Ranks_High_of_RULE(irl);
}
/*:283*//*284:*/
#line 2619 "./marpa.w"

int marpa_g_rule_null_high_set(
Marpa_Grammar g,Marpa_Rule_ID irl_id,int flag)
{
IRL irl;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 2624 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 2625 "./marpa.w"

/*1319:*/
#line 15731 "./marpa.w"

if(_MARPA_UNLIKELY(G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_PRECOMPUTED);
return failure_indicator;
}

/*:1319*/
#line 2626 "./marpa.w"

/*1330:*/
#line 15798 "./marpa.w"

if(_MARPA_UNLIKELY(IRLID_is_Malformed(irl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_RULE_ID);
return failure_indicator;
}

/*:1330*/
#line 2627 "./marpa.w"

/*1328:*/
#line 15786 "./marpa.w"

if(_MARPA_UNLIKELY(!IRLID_of_G_Exists(irl_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_RULE_ID);
return-1;
}

/*:1328*/
#line 2628 "./marpa.w"

irl= IRL_by_ID(irl_id);
if(_MARPA_UNLIKELY(flag<0||flag> 1))
{
MARPA_ERROR(MARPA_ERR_INVALID_BOOLEAN);
return failure_indicator;
}
return Null_Ranks_High_of_RULE(irl)= Boolean(flag);
}

/*:284*//*291:*/
#line 2665 "./marpa.w"

int marpa_g_sequence_min(
Marpa_Grammar g,
Marpa_Rule_ID irl_id)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 2670 "./marpa.w"

IRL irl;
/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 2672 "./marpa.w"

/*1330:*/
#line 15798 "./marpa.w"

if(_MARPA_UNLIKELY(IRLID_is_Malformed(irl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_RULE_ID);
return failure_indicator;
}

/*:1330*/
#line 2673 "./marpa.w"

/*1329:*/
#line 15792 "./marpa.w"

if(_MARPA_UNLIKELY(!IRLID_of_G_Exists(irl_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_RULE_ID);
return failure_indicator;
}
/*:1329*/
#line 2674 "./marpa.w"

irl= IRL_by_ID(irl_id);
if(!IRL_is_Sequence(irl))
{
MARPA_ERROR(MARPA_ERR_NOT_A_SEQUENCE);
return-1;
}
return Minimum_of_IRL(irl);
}

/*:291*//*294:*/
#line 2691 "./marpa.w"

Marpa_Symbol_ID marpa_g_sequence_separator(
Marpa_Grammar g,
Marpa_Rule_ID irl_id)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 2696 "./marpa.w"

IRL irl;
/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 2698 "./marpa.w"

/*1330:*/
#line 15798 "./marpa.w"

if(_MARPA_UNLIKELY(IRLID_is_Malformed(irl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_RULE_ID);
return failure_indicator;
}

/*:1330*/
#line 2699 "./marpa.w"

/*1329:*/
#line 15792 "./marpa.w"

if(_MARPA_UNLIKELY(!IRLID_of_G_Exists(irl_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_RULE_ID);
return failure_indicator;
}
/*:1329*/
#line 2700 "./marpa.w"

irl= IRL_by_ID(irl_id);
if(!IRL_is_Sequence(irl))
{
MARPA_ERROR(MARPA_ERR_NOT_A_SEQUENCE);
return failure_indicator;
}
return Separator_of_IRL(irl);
}

/*:294*//*299:*/
#line 2728 "./marpa.w"

int _marpa_g_rule_is_keep_separation(
Marpa_Grammar g,
Marpa_Rule_ID irl_id)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 2733 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 2734 "./marpa.w"

/*1330:*/
#line 15798 "./marpa.w"

if(_MARPA_UNLIKELY(IRLID_is_Malformed(irl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_RULE_ID);
return failure_indicator;
}

/*:1330*/
#line 2735 "./marpa.w"

/*1328:*/
#line 15786 "./marpa.w"

if(_MARPA_UNLIKELY(!IRLID_of_G_Exists(irl_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_RULE_ID);
return-1;
}

/*:1328*/
#line 2736 "./marpa.w"

return!IRL_by_ID(irl_id)->t_is_discard;
}

/*:299*//*303:*/
#line 2768 "./marpa.w"

int marpa_g_rule_is_proper_separation(
Marpa_Grammar g,
Marpa_Rule_ID irl_id)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 2773 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 2774 "./marpa.w"

/*1330:*/
#line 15798 "./marpa.w"

if(_MARPA_UNLIKELY(IRLID_is_Malformed(irl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_RULE_ID);
return failure_indicator;
}

/*:1330*/
#line 2775 "./marpa.w"

/*1328:*/
#line 15786 "./marpa.w"

if(_MARPA_UNLIKELY(!IRLID_of_G_Exists(irl_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_RULE_ID);
return-1;
}

/*:1328*/
#line 2776 "./marpa.w"

return IRL_is_Proper_Separation(IRL_by_ID(irl_id));
}

/*:303*//*307:*/
#line 2789 "./marpa.w"

int marpa_g_rule_is_loop(Marpa_Grammar g,Marpa_Rule_ID irl_id)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 2792 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 2793 "./marpa.w"

/*1320:*/
#line 15737 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1320*/
#line 2794 "./marpa.w"

/*1330:*/
#line 15798 "./marpa.w"

if(_MARPA_UNLIKELY(IRLID_is_Malformed(irl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_RULE_ID);
return failure_indicator;
}

/*:1330*/
#line 2795 "./marpa.w"

/*1328:*/
#line 15786 "./marpa.w"

if(_MARPA_UNLIKELY(!IRLID_of_G_Exists(irl_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_RULE_ID);
return-1;
}

/*:1328*/
#line 2796 "./marpa.w"

/*1320:*/
#line 15737 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1320*/
#line 2797 "./marpa.w"

return IRL_by_ID(irl_id)->t_is_loop;
}

/*:307*//*310:*/
#line 2807 "./marpa.w"

int marpa_g_rule_is_nulling(Marpa_Grammar g,Marpa_Rule_ID irl_id)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 2810 "./marpa.w"

IRL irl;
/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 2812 "./marpa.w"

/*1320:*/
#line 15737 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1320*/
#line 2813 "./marpa.w"

/*1330:*/
#line 15798 "./marpa.w"

if(_MARPA_UNLIKELY(IRLID_is_Malformed(irl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_RULE_ID);
return failure_indicator;
}

/*:1330*/
#line 2814 "./marpa.w"

/*1328:*/
#line 15786 "./marpa.w"

if(_MARPA_UNLIKELY(!IRLID_of_G_Exists(irl_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_RULE_ID);
return-1;
}

/*:1328*/
#line 2815 "./marpa.w"

irl= IRL_by_ID(irl_id);
return IRL_is_Nulling(irl);
}

/*:310*//*313:*/
#line 2826 "./marpa.w"

int marpa_g_rule_is_nullable(Marpa_Grammar g,Marpa_Rule_ID irl_id)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 2829 "./marpa.w"

IRL irl;
/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 2831 "./marpa.w"

/*1320:*/
#line 15737 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1320*/
#line 2832 "./marpa.w"

/*1330:*/
#line 15798 "./marpa.w"

if(_MARPA_UNLIKELY(IRLID_is_Malformed(irl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_RULE_ID);
return failure_indicator;
}

/*:1330*/
#line 2833 "./marpa.w"

/*1328:*/
#line 15786 "./marpa.w"

if(_MARPA_UNLIKELY(!IRLID_of_G_Exists(irl_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_RULE_ID);
return-1;
}

/*:1328*/
#line 2834 "./marpa.w"

irl= IRL_by_ID(irl_id);
return IRL_is_Nullable(irl);
}

/*:313*//*317:*/
#line 2845 "./marpa.w"

int marpa_g_rule_is_accessible(Marpa_Grammar g,Marpa_Rule_ID irl_id)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 2848 "./marpa.w"

IRL irl;
/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 2850 "./marpa.w"

/*1320:*/
#line 15737 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1320*/
#line 2851 "./marpa.w"

/*1330:*/
#line 15798 "./marpa.w"

if(_MARPA_UNLIKELY(IRLID_is_Malformed(irl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_RULE_ID);
return failure_indicator;
}

/*:1330*/
#line 2852 "./marpa.w"

/*1328:*/
#line 15786 "./marpa.w"

if(_MARPA_UNLIKELY(!IRLID_of_G_Exists(irl_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_RULE_ID);
return-1;
}

/*:1328*/
#line 2853 "./marpa.w"

irl= IRL_by_ID(irl_id);
return IRL_is_Accessible(irl);
}

/*:317*//*320:*/
#line 2864 "./marpa.w"

int marpa_g_rule_is_productive(Marpa_Grammar g,Marpa_Rule_ID irl_id)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 2867 "./marpa.w"

IRL irl;
/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 2869 "./marpa.w"

/*1320:*/
#line 15737 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1320*/
#line 2870 "./marpa.w"

/*1330:*/
#line 15798 "./marpa.w"

if(_MARPA_UNLIKELY(IRLID_is_Malformed(irl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_RULE_ID);
return failure_indicator;
}

/*:1330*/
#line 2871 "./marpa.w"

/*1328:*/
#line 15786 "./marpa.w"

if(_MARPA_UNLIKELY(!IRLID_of_G_Exists(irl_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_RULE_ID);
return-1;
}

/*:1328*/
#line 2872 "./marpa.w"

irl= IRL_by_ID(irl_id);
return IRL_is_Productive(irl);
}

/*:320*//*323:*/
#line 2883 "./marpa.w"

int
_marpa_g_rule_is_used(Marpa_Grammar g,Marpa_Rule_ID irl_id)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 2887 "./marpa.w"

/*1330:*/
#line 15798 "./marpa.w"

if(_MARPA_UNLIKELY(IRLID_is_Malformed(irl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_RULE_ID);
return failure_indicator;
}

/*:1330*/
#line 2888 "./marpa.w"

/*1328:*/
#line 15786 "./marpa.w"

if(_MARPA_UNLIKELY(!IRLID_of_G_Exists(irl_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_RULE_ID);
return-1;
}

/*:1328*/
#line 2889 "./marpa.w"

return IRL_is_Used(IRL_by_ID(irl_id));
}

/*:323*//*325:*/
#line 2896 "./marpa.w"

Marpa_Rule_ID
_marpa_g_nrl_semantic_equivalent(Marpa_Grammar g,Marpa_NRL_ID nrl_id)
{
NRL nrl;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 2901 "./marpa.w"

/*1327:*/
#line 15778 "./marpa.w"

if(_MARPA_UNLIKELY(!NRLID_of_G_is_Valid(nrl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_NRLID);
return failure_indicator;
}
/*:1327*/
#line 2902 "./marpa.w"

nrl= NRL_by_ID(nrl_id);
if(NRL_has_Virtual_LHS(nrl))return-1;
return ID_of_IRL(Source_IRL_of_NRL(nrl));
}

/*:325*//*334:*/
#line 2943 "./marpa.w"

Marpa_NSY_ID _marpa_g_nrl_lhs(Marpa_Grammar g,Marpa_NRL_ID nrl_id){
NRL nrl;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 2946 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 2947 "./marpa.w"

/*1320:*/
#line 15737 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1320*/
#line 2948 "./marpa.w"

/*1327:*/
#line 15778 "./marpa.w"

if(_MARPA_UNLIKELY(!NRLID_of_G_is_Valid(nrl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_NRLID);
return failure_indicator;
}
/*:1327*/
#line 2949 "./marpa.w"

nrl= NRL_by_ID(nrl_id);
return LHSID_of_NRL(nrl);
}

/*:334*//*336:*/
#line 2956 "./marpa.w"

Marpa_NSY_ID _marpa_g_nrl_rhs(Marpa_Grammar g,Marpa_NRL_ID nrl_id,int ix){
NRL nrl;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 2959 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 2960 "./marpa.w"

/*1320:*/
#line 15737 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1320*/
#line 2961 "./marpa.w"

/*1327:*/
#line 15778 "./marpa.w"

if(_MARPA_UNLIKELY(!NRLID_of_G_is_Valid(nrl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_NRLID);
return failure_indicator;
}
/*:1327*/
#line 2962 "./marpa.w"

nrl= NRL_by_ID(nrl_id);
if(Length_of_NRL(nrl)<=ix)return-1;
return RHSID_of_NRL(nrl,ix);
}

/*:336*//*338:*/
#line 2970 "./marpa.w"

int _marpa_g_nrl_length(Marpa_Grammar g,Marpa_NRL_ID nrl_id){
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 2972 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 2973 "./marpa.w"

/*1320:*/
#line 15737 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1320*/
#line 2974 "./marpa.w"

/*1327:*/
#line 15778 "./marpa.w"

if(_MARPA_UNLIKELY(!NRLID_of_G_is_Valid(nrl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_NRLID);
return failure_indicator;
}
/*:1327*/
#line 2975 "./marpa.w"

return Length_of_NRL(NRL_by_ID(nrl_id));
}

/*:338*//*344:*/
#line 3020 "./marpa.w"

int _marpa_g_nrl_is_virtual_lhs(
Marpa_Grammar g,
Marpa_NRL_ID nrl_id)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 3025 "./marpa.w"

/*1320:*/
#line 15737 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1320*/
#line 3026 "./marpa.w"

/*1327:*/
#line 15778 "./marpa.w"

if(_MARPA_UNLIKELY(!NRLID_of_G_is_Valid(nrl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_NRLID);
return failure_indicator;
}
/*:1327*/
#line 3027 "./marpa.w"

return NRL_has_Virtual_LHS(NRL_by_ID(nrl_id));
}

/*:344*//*347:*/
#line 3036 "./marpa.w"

int _marpa_g_nrl_is_virtual_rhs(
Marpa_Grammar g,
Marpa_NRL_ID nrl_id)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 3041 "./marpa.w"

/*1320:*/
#line 15737 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1320*/
#line 3042 "./marpa.w"

/*1327:*/
#line 15778 "./marpa.w"

if(_MARPA_UNLIKELY(!NRLID_of_G_is_Valid(nrl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_NRLID);
return failure_indicator;
}
/*:1327*/
#line 3043 "./marpa.w"

return NRL_has_Virtual_RHS(NRL_by_ID(nrl_id));
}

/*:347*//*353:*/
#line 3065 "./marpa.w"

int _marpa_g_real_symbol_count(
Marpa_Grammar g,
Marpa_NRL_ID nrl_id)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 3070 "./marpa.w"

/*1320:*/
#line 15737 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1320*/
#line 3071 "./marpa.w"

/*1327:*/
#line 15778 "./marpa.w"

if(_MARPA_UNLIKELY(!NRLID_of_G_is_Valid(nrl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_NRLID);
return failure_indicator;
}
/*:1327*/
#line 3072 "./marpa.w"

return Real_SYM_Count_of_NRL(NRL_by_ID(nrl_id));
}

/*:353*//*356:*/
#line 3083 "./marpa.w"

int _marpa_g_virtual_start(
Marpa_Grammar g,
Marpa_NRL_ID nrl_id)
{
NRL nrl;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 3089 "./marpa.w"

/*1320:*/
#line 15737 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1320*/
#line 3090 "./marpa.w"

/*1327:*/
#line 15778 "./marpa.w"

if(_MARPA_UNLIKELY(!NRLID_of_G_is_Valid(nrl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_NRLID);
return failure_indicator;
}
/*:1327*/
#line 3091 "./marpa.w"

nrl= NRL_by_ID(nrl_id);
return Virtual_Start_of_NRL(nrl);
}

/*:356*//*359:*/
#line 3103 "./marpa.w"

int _marpa_g_virtual_end(
Marpa_Grammar g,
Marpa_NRL_ID nrl_id)
{
NRL nrl;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 3109 "./marpa.w"

/*1320:*/
#line 15737 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1320*/
#line 3110 "./marpa.w"

/*1327:*/
#line 15778 "./marpa.w"

if(_MARPA_UNLIKELY(!NRLID_of_G_is_Valid(nrl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_NRLID);
return failure_indicator;
}
/*:1327*/
#line 3111 "./marpa.w"

nrl= NRL_by_ID(nrl_id);
return Virtual_End_of_NRL(nrl);
}

/*:359*//*362:*/
#line 3125 "./marpa.w"

Marpa_Rule_ID _marpa_g_source_irl(
Marpa_Grammar g,
Marpa_NRL_ID nrl_id)
{
IRL source_irl;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 3131 "./marpa.w"

/*1327:*/
#line 15778 "./marpa.w"

if(_MARPA_UNLIKELY(!NRLID_of_G_is_Valid(nrl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_NRLID);
return failure_indicator;
}
/*:1327*/
#line 3132 "./marpa.w"

source_irl= Source_IRL_of_NRL(NRL_by_ID(nrl_id));
return source_irl?ID_of_IRL(source_irl):-1;
}

/*:362*//*365:*/
#line 3153 "./marpa.w"

Marpa_Rank _marpa_g_nrl_rank(
Marpa_Grammar g,
Marpa_NRL_ID nrl_id)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 3158 "./marpa.w"

/*1327:*/
#line 15778 "./marpa.w"

if(_MARPA_UNLIKELY(!NRLID_of_G_is_Valid(nrl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_NRLID);
return failure_indicator;
}
/*:1327*/
#line 3159 "./marpa.w"

return Rank_of_NRL(NRL_by_ID(nrl_id));
}

/*:365*//*369:*/
#line 3193 "./marpa.w"

int marpa_g_precompute(Marpa_Grammar g)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 3196 "./marpa.w"

int return_value= failure_indicator;
struct marpa_obstack*obs_precompute= marpa_obs_init;
/*374:*/
#line 3323 "./marpa.w"

IRLID irl_count= IRL_Count_of_G(g);
ISYID pre_census_isy_count= ISY_Count_of_G(g);
ISYID post_census_isy_count= -1;

/*:374*//*378:*/
#line 3357 "./marpa.w"

ISYID start_isy_id= g->t_start_isy_id;

/*:378*//*391:*/
#line 3660 "./marpa.w"

Bit_Matrix reach_matrix= NULL;

/*:391*/
#line 3199 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 3200 "./marpa.w"

G_EVENTS_CLEAR(g);
/*375:*/
#line 3328 "./marpa.w"

if(_MARPA_UNLIKELY(irl_count<=0)){
MARPA_ERROR(MARPA_ERR_NO_RULES);
goto FAILURE;
}

/*:375*/
#line 3202 "./marpa.w"

/*1319:*/
#line 15731 "./marpa.w"

if(_MARPA_UNLIKELY(G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_PRECOMPUTED);
return failure_indicator;
}

/*:1319*/
#line 3203 "./marpa.w"

/*377:*/
#line 3338 "./marpa.w"

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

/*:377*/
#line 3204 "./marpa.w"





MARPA_OFF_DEBUG3("At %s, ahm count is %ld",STRLOC,(long)(g->t_ahm_count));

/*124:*/
#line 1139 "./marpa.w"

{
_marpa_avl_destroy((g)->t_irl_tree);
(g)->t_irl_tree= NULL;
}
/*:124*/
#line 3211 "./marpa.w"




{
/*383:*/
#line 3539 "./marpa.w"

Bit_Vector terminal_v= NULL;

/*:383*//*384:*/
#line 3542 "./marpa.w"

Bit_Vector lhs_v= NULL;
Bit_Vector empty_lhs_v= NULL;

/*:384*//*385:*/
#line 3547 "./marpa.w"

RULEID**irl_list_x_rh_sym= NULL;
RULEID**irl_list_x_lh_sym= NULL;

/*:385*//*389:*/
#line 3606 "./marpa.w"

Bit_Vector productive_v= NULL;
Bit_Vector nullable_v= NULL;

/*:389*/
#line 3216 "./marpa.w"

/*373:*/
#line 3307 "./marpa.w"

{
/*381:*/
#line 3381 "./marpa.w"

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

/*:381*/
#line 3309 "./marpa.w"

/*382:*/
#line 3508 "./marpa.w"

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

/*:382*/
#line 3310 "./marpa.w"

/*390:*/
#line 3628 "./marpa.w"

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

/*:390*/
#line 3311 "./marpa.w"

/*386:*/
#line 3551 "./marpa.w"

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

/*:386*/
#line 3312 "./marpa.w"

/*387:*/
#line 3579 "./marpa.w"

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

/*:387*/
#line 3313 "./marpa.w"

/*388:*/
#line 3600 "./marpa.w"

if(_MARPA_UNLIKELY(!bv_bit_test(productive_v,start_isy_id)))
{
MARPA_ERROR(MARPA_ERR_UNPRODUCTIVE_START);
goto FAILURE;
}
/*:388*/
#line 3314 "./marpa.w"

/*392:*/
#line 3669 "./marpa.w"

{
{
const RULEID*p_start_irlid= irl_list_x_lh_sym[start_isy_id];
const IRL irl= IRL_by_ID(*p_start_irlid);
if(Length_of_IRL(irl)!=1){
MARPA_INTERNAL_ERROR("Length of start rule is not 1");
}
{
const RULEID*p_next_irlid= irl_list_x_lh_sym[start_isy_id+1];
const ptrdiff_t rules_with_this_lhs= p_next_irlid-p_start_irlid;
if(rules_with_this_lhs!=1){
MARPA_INTERNAL_ERROR("Start symbol on more than one RHS");
}
}
}
{
const RULEID*p_start_irlid= irl_list_x_rh_sym[start_isy_id];
const RULEID*p_next_irlid= irl_list_x_rh_sym[start_isy_id+1];
const ptrdiff_t rules_with_this_rhs= p_next_irlid-p_start_irlid;
if(rules_with_this_rhs!=0){
MARPA_INTERNAL_ERROR("Start symbol is on a RHS");
}
}
}

/*:392*/
#line 3315 "./marpa.w"

/*393:*/
#line 3697 "./marpa.w"

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

/*:393*/
#line 3316 "./marpa.w"

/*394:*/
#line 3717 "./marpa.w"

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

/*:394*/
#line 3317 "./marpa.w"

/*395:*/
#line 3756 "./marpa.w"

{
IRLID irl_id;
for(irl_id= 0;irl_id<irl_count;irl_id++)
{
const IRL irl= IRL_by_ID(irl_id);
const ISYID lhs_id= LHS_ID_of_IRL(irl);
const ISY lhs= ISY_by_ID(lhs_id);
IRL_is_Accessible(irl)= ISY_is_Accessible(lhs);
if(IRL_is_Sequence(irl))
{
/*397:*/
#line 3807 "./marpa.w"

{
const ISYID rhs_id= RHS_ID_of_IRL(irl,0);
const ISY rh_isy= ISY_by_ID(rhs_id);
const ISYID separator_id= Separator_of_IRL(irl);




IRL_is_Nullable(irl)= Minimum_of_IRL(irl)<=0
||ISY_is_Nullable(rh_isy);



IRL_is_Nulling(irl)= ISY_is_Nulling(rh_isy);




IRL_is_Productive(irl)= IRL_is_Nullable(irl)||ISY_is_Productive(rh_isy);



IRL_is_Used(irl)= IRL_is_Accessible(irl)&&ISY_is_Productive(rh_isy);



if(separator_id>=0)
{
const ISY separator_isy= ISY_by_ID(separator_id);



if(!ISY_is_Nulling(separator_isy))
{
IRL_is_Nulling(irl)= 0;
}




if(_MARPA_UNLIKELY(!ISY_is_Productive(separator_isy)))
{
IRL_is_Productive(irl)= IRL_is_Nullable(irl);



IRL_is_Used(irl)= 0;
}
}



if(IRL_is_Nulling(irl))IRL_is_Used(irl)= 0;
}

/*:397*/
#line 3767 "./marpa.w"

continue;
}
/*396:*/
#line 3776 "./marpa.w"

{
int rh_ix;
int is_nulling= 1;
int is_nullable= 1;
int is_productive= 1;
for(rh_ix= 0;rh_ix<Length_of_IRL(irl);rh_ix++)
{
const ISYID rhs_id= RHS_ID_of_IRL(irl,rh_ix);
const ISY rh_isy= ISY_by_ID(rhs_id);
if(_MARPA_LIKELY(!ISY_is_Nulling(rh_isy)))
is_nulling= 0;
if(_MARPA_LIKELY(!ISY_is_Nullable(rh_isy)))
is_nullable= 0;
if(_MARPA_UNLIKELY(!ISY_is_Productive(rh_isy)))
is_productive= 0;
}
IRL_is_Nulling(irl)= Boolean(is_nulling);
IRL_is_Nullable(irl)= Boolean(is_nullable);
IRL_is_Productive(irl)= Boolean(is_productive);
IRL_is_Used(irl)= IRL_is_Accessible(irl)&&IRL_is_Productive(irl)
&&!IRL_is_Nulling(irl);
}

/*:396*/
#line 3770 "./marpa.w"

}
}

/*:395*/
#line 3318 "./marpa.w"

/*398:*/
#line 3872 "./marpa.w"

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

/*:398*/
#line 3319 "./marpa.w"

/*399:*/
#line 3901 "./marpa.w"

{
ISYID isyid;
IRLID irlid;


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
for(irlid= 0;irlid<irl_count;irlid++)
{
int rh_ix;
IRL irl= IRL_by_ID(irlid);
const ISYID lhs_id= LHS_ID_of_IRL(irl);
if(IRL_is_Nullable(irl))
{
for(rh_ix= 0;rh_ix<Length_of_IRL(irl);rh_ix++)
{
const ISYID rhs_id= RHS_ID_of_IRL(irl,rh_ix);
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

/*:399*/
#line 3320 "./marpa.w"

}

/*:373*/
#line 3217 "./marpa.w"

/*450:*/
#line 4779 "./marpa.w"

{
int loop_rule_count= 0;
Bit_Matrix unit_transition_matrix= 
matrix_obs_create(obs_precompute,irl_count,
irl_count);
/*451:*/
#line 4800 "./marpa.w"

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



/*452:*/
#line 4855 "./marpa.w"

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

/*:452*/
#line 4828 "./marpa.w"

}
else if(nonnullable_count==0)
{
for(rhs_ix= 0;rhs_ix<rule_length;rhs_ix++)
{




nonnullable_id= RHS_ID_of_RULE(rule,rhs_ix);

if(ISY_is_Nulling(ISY_by_ID(nonnullable_id)))
continue;



/*452:*/
#line 4855 "./marpa.w"

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

/*:452*/
#line 4846 "./marpa.w"

}
}
}
}

/*:451*/
#line 4785 "./marpa.w"

transitive_closure(unit_transition_matrix);
/*453:*/
#line 4869 "./marpa.w"

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

/*:453*/
#line 4787 "./marpa.w"

if(loop_rule_count)
{
g->t_has_cycle= 1;
int_event_new(g,MARPA_EVENT_LOOP_RULES,loop_rule_count);
}
}

/*:450*/
#line 3218 "./marpa.w"

}



/*517:*/
#line 5467 "./marpa.w"

MARPA_DSTACK_INIT(g->t_nrl_stack,NRL,2*MARPA_DSTACK_CAPACITY(g->t_irl_stack));

/*:517*/
#line 3223 "./marpa.w"

/*518:*/
#line 5475 "./marpa.w"

{
MARPA_DSTACK_INIT(g->t_nsy_stack,NSY,2*MARPA_DSTACK_CAPACITY(g->t_isy_stack));
}

/*:518*/
#line 3224 "./marpa.w"

/*415:*/
#line 4123 "./marpa.w"

{
/*416:*/
#line 4154 "./marpa.w"

Marpa_Rule_ID rule_id;
int pre_chaf_rule_count;

/*:416*//*419:*/
#line 4212 "./marpa.w"

int factor_count;
int*factor_positions;
/*:419*/
#line 4125 "./marpa.w"

/*420:*/
#line 4215 "./marpa.w"

factor_positions= marpa_obs_new(obs_precompute,int,g->t_max_rule_length);

/*:420*/
#line 4126 "./marpa.w"

/*417:*/
#line 4160 "./marpa.w"

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

/*:417*/
#line 4127 "./marpa.w"

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
/*400:*/
#line 3954 "./marpa.w"

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
/*401:*/
#line 3983 "./marpa.w"

{
NRL rewrite_nrl= nrl_start(g,1);
LHSID_of_NRL(rewrite_nrl)= lhs_nsyid;
RHSID_of_NRL(rewrite_nrl,0)= internal_lhs_nsyid;
nrl_finish(g,rewrite_nrl);
Source_IRL_of_NRL(rewrite_nrl)= rule;
Rank_of_NRL(rewrite_nrl)= NRL_Rank_by_IRL(rule);

NRL_has_Virtual_RHS(rewrite_nrl)= 1;
}

/*:401*/
#line 3975 "./marpa.w"

if(separator_nsyid>=0&&!IRL_is_Proper_Separation(rule)){
/*402:*/
#line 3996 "./marpa.w"

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

/*:402*/
#line 3977 "./marpa.w"

}
/*403:*/
#line 4013 "./marpa.w"

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
/*:403*/
#line 3979 "./marpa.w"

/*404:*/
#line 4024 "./marpa.w"

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

/*:404*/
#line 3980 "./marpa.w"

}

/*:400*/
#line 4140 "./marpa.w"

continue;
}
/*418:*/
#line 4191 "./marpa.w"

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
/*:418*/
#line 4143 "./marpa.w"


if(factor_count> 0)
{
/*421:*/
#line 4219 "./marpa.w"

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
/*424:*/
#line 4255 "./marpa.w"

NSY chaf_virtual_nsy;
NSYID chaf_virtual_nsyid;
int first_factor_position= factor_positions[factor_position_ix];
int second_factor_position= factor_positions[factor_position_ix+1];
if(second_factor_position>=nullable_suffix_ix){
piece_end= second_factor_position-1;



/*422:*/
#line 4245 "./marpa.w"

{
const ISYID chaf_irl_lhs_id= LHS_ID_of_IRL(chaf_irl);
chaf_virtual_nsy= nsy_new(g,ISY_by_ID(chaf_irl_lhs_id));
chaf_virtual_nsyid= ID_of_NSY(chaf_virtual_nsy);
}

/*:422*/
#line 4265 "./marpa.w"

/*425:*/
#line 4284 "./marpa.w"

{
{
const int real_symbol_count= piece_end-piece_start+1;
/*430:*/
#line 4382 "./marpa.w"

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
/*442:*/
#line 4685 "./marpa.w"

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

/*:442*/
#line 4396 "./marpa.w"

}

/*:430*/
#line 4288 "./marpa.w"
;
}
/*426:*/
#line 4298 "./marpa.w"

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
/*442:*/
#line 4685 "./marpa.w"

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

/*:442*/
#line 4320 "./marpa.w"

}

/*:426*/
#line 4290 "./marpa.w"
;
{
const int real_symbol_count= piece_end-piece_start+1;
/*432:*/
#line 4428 "./marpa.w"

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
/*442:*/
#line 4685 "./marpa.w"

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

/*:442*/
#line 4452 "./marpa.w"

}

/*:432*/
#line 4293 "./marpa.w"
;
}
/*427:*/
#line 4328 "./marpa.w"

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
/*442:*/
#line 4685 "./marpa.w"

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

/*:442*/
#line 4366 "./marpa.w"

}
}

/*:427*/
#line 4295 "./marpa.w"
;
}

/*:425*/
#line 4266 "./marpa.w"

factor_position_ix++;
}else{
piece_end= second_factor_position;
/*422:*/
#line 4245 "./marpa.w"

{
const ISYID chaf_irl_lhs_id= LHS_ID_of_IRL(chaf_irl);
chaf_virtual_nsy= nsy_new(g,ISY_by_ID(chaf_irl_lhs_id));
chaf_virtual_nsyid= ID_of_NSY(chaf_virtual_nsy);
}

/*:422*/
#line 4270 "./marpa.w"

/*429:*/
#line 4372 "./marpa.w"

{
const int real_symbol_count= piece_end-piece_start+1;
/*430:*/
#line 4382 "./marpa.w"

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
/*442:*/
#line 4685 "./marpa.w"

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

/*:442*/
#line 4396 "./marpa.w"

}

/*:430*/
#line 4375 "./marpa.w"

/*431:*/
#line 4400 "./marpa.w"

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
/*442:*/
#line 4685 "./marpa.w"

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

/*:442*/
#line 4424 "./marpa.w"

}

/*:431*/
#line 4376 "./marpa.w"

/*432:*/
#line 4428 "./marpa.w"

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
/*442:*/
#line 4685 "./marpa.w"

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

/*:442*/
#line 4452 "./marpa.w"

}

/*:432*/
#line 4377 "./marpa.w"

/*433:*/
#line 4456 "./marpa.w"

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
/*442:*/
#line 4685 "./marpa.w"

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

/*:442*/
#line 4490 "./marpa.w"

}

/*:433*/
#line 4378 "./marpa.w"

}

/*:429*/
#line 4271 "./marpa.w"

factor_position_ix+= 2;
}
current_lhs_nsy= chaf_virtual_nsy;
current_lhs_nsyid= chaf_virtual_nsyid;
piece_start= piece_end+1;

/*:424*/
#line 4236 "./marpa.w"

}
if(unprocessed_factor_count==2){
/*434:*/
#line 4495 "./marpa.w"

{
const int first_factor_position= factor_positions[factor_position_ix];
const int second_factor_position= factor_positions[factor_position_ix+1];
const int real_symbol_count= Length_of_IRL(rule)-piece_start;
piece_end= Length_of_IRL(rule)-1;
/*435:*/
#line 4508 "./marpa.w"

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
/*442:*/
#line 4685 "./marpa.w"

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

/*:442*/
#line 4521 "./marpa.w"

}

/*:435*/
#line 4501 "./marpa.w"

/*436:*/
#line 4525 "./marpa.w"

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
/*442:*/
#line 4685 "./marpa.w"

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

/*:442*/
#line 4548 "./marpa.w"

}

/*:436*/
#line 4502 "./marpa.w"

/*437:*/
#line 4552 "./marpa.w"

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
/*442:*/
#line 4685 "./marpa.w"

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

/*:442*/
#line 4575 "./marpa.w"

}

/*:437*/
#line 4503 "./marpa.w"

/*438:*/
#line 4580 "./marpa.w"

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
/*442:*/
#line 4685 "./marpa.w"

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

/*:442*/
#line 4617 "./marpa.w"

}
}

/*:438*/
#line 4504 "./marpa.w"

}

/*:434*/
#line 4239 "./marpa.w"

}else{
/*439:*/
#line 4622 "./marpa.w"

{
int real_symbol_count;
const int first_factor_position= factor_positions[factor_position_ix];
piece_end= Length_of_IRL(rule)-1;
real_symbol_count= piece_end-piece_start+1;
/*440:*/
#line 4633 "./marpa.w"

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
/*442:*/
#line 4685 "./marpa.w"

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

/*:442*/
#line 4646 "./marpa.w"

}

/*:440*/
#line 4628 "./marpa.w"

/*441:*/
#line 4651 "./marpa.w"

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
/*442:*/
#line 4685 "./marpa.w"

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

/*:442*/
#line 4677 "./marpa.w"

}
}

/*:441*/
#line 4629 "./marpa.w"

}

/*:439*/
#line 4241 "./marpa.w"

}
}

/*:421*/
#line 4147 "./marpa.w"

continue;
}
/*261:*/
#line 2273 "./marpa.w"

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

/*:261*/
#line 4150 "./marpa.w"

}
}

/*:415*/
#line 3225 "./marpa.w"

/*444:*/
#line 4703 "./marpa.w"

{
const ISY start_isy= ISY_by_ID(start_isy_id);
if(_MARPA_LIKELY(!ISY_is_Nulling(start_isy))){
/*445:*/
#line 4713 "./marpa.w"
{
NRL new_start_nrl;

const NSY new_start_nsy= nsy_new(g,start_isy);
const NSYID new_start_nsyid= ID_of_NSY(new_start_nsy);
g->t_start_nsyid= new_start_nsyid;

new_start_nrl= nrl_start(g,1);
LHSID_of_NRL(new_start_nrl)= new_start_nsyid;
RHSID_of_NRL(new_start_nrl,0)= NSYID_of_ISY(start_isy);
nrl_finish(g,new_start_nrl);
NRL_has_Virtual_LHS(new_start_nrl)= 1;
Real_SYM_Count_of_NRL(new_start_nrl)= 1;
g->t_start_nrl= new_start_nrl;

}

/*:445*/
#line 4707 "./marpa.w"

}
}

/*:444*/
#line 3226 "./marpa.w"

post_census_isy_count= ISY_Count_of_G(g);
/*529:*/
#line 5664 "./marpa.w"

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

/*:529*/
#line 3228 "./marpa.w"




if(!G_is_Trivial(g)){
/*516:*/
#line 5458 "./marpa.w"

const RULEID nrl_count= NRL_Count_of_G(g);
const NSYID nsy_count= NSY_Count_of_G(g);
Bit_Matrix nsy_by_right_nsy_matrix;
Bit_Matrix prediction_nsy_by_nrl_matrix;

/*:516*/
#line 3234 "./marpa.w"

/*519:*/
#line 5480 "./marpa.w"

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

/*:519*/
#line 3235 "./marpa.w"

/*490:*/
#line 5114 "./marpa.w"

{
NRLID nrl_id;
int ahm_count= 0;
AHM base_item;
AHM current_item;
int symbol_instance_of_next_rule= 0;
for(nrl_id= 0;nrl_id<nrl_count;nrl_id++){
const NRL nrl= NRL_by_ID(nrl_id);
/*492:*/
#line 5167 "./marpa.w"

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

/*:492*/
#line 5123 "./marpa.w"

}
current_item= base_item= marpa_new(struct s_ahm,ahm_count);
for(nrl_id= 0;nrl_id<nrl_count;nrl_id++){
const NRL nrl= NRL_by_ID(nrl_id);
SYMI_of_NRL(nrl)= symbol_instance_of_next_rule;
/*491:*/
#line 5142 "./marpa.w"

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
/*493:*/
#line 5179 "./marpa.w"

{
/*495:*/
#line 5202 "./marpa.w"

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
/*510:*/
#line 5355 "./marpa.w"

Event_AHMIDs_of_AHM(current_item)= NULL;
Event_Group_Size_of_AHM(current_item)= 0;

/*:510*/
#line 5220 "./marpa.w"

}

/*:495*/
#line 5181 "./marpa.w"

AHM_predicts_ZWA(current_item)= 0;

Postdot_NSYID_of_AHM(current_item)= rh_nsyid;
Position_of_AHM(current_item)= rhs_ix;
SYMI_of_AHM(current_item)
= AHM_is_Prediction(current_item)
?-1
:SYMI_of_NRL(nrl)+Position_of_AHM(current_item-1);
memoize_irl_data_for_AHM(current_item,nrl);
}

/*:493*/
#line 5153 "./marpa.w"

current_item++;
leading_nulls= 0;
}
else
{
leading_nulls++;
}
}
/*494:*/
#line 5193 "./marpa.w"

{
/*495:*/
#line 5202 "./marpa.w"

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
/*510:*/
#line 5355 "./marpa.w"

Event_AHMIDs_of_AHM(current_item)= NULL;
Event_Group_Size_of_AHM(current_item)= 0;

/*:510*/
#line 5220 "./marpa.w"

}

/*:495*/
#line 5195 "./marpa.w"

Postdot_NSYID_of_AHM(current_item)= -1;
Position_of_AHM(current_item)= -1;
SYMI_of_AHM(current_item)= SYMI_of_NRL(nrl)+Position_of_AHM(current_item-1);
memoize_irl_data_for_AHM(current_item,nrl);
}

/*:494*/
#line 5162 "./marpa.w"

current_item++;
AHM_Count_of_NRL(nrl)= (int)(current_item-first_ahm_of_nrl);
}

/*:491*/
#line 5129 "./marpa.w"

{
symbol_instance_of_next_rule+= Length_of_NRL(nrl);
}
}
SYMI_Count_of_G(g)= symbol_instance_of_next_rule;
MARPA_ASSERT(ahm_count==current_item-base_item);
AHM_Count_of_G(g)= ahm_count;
MARPA_DEBUG3("At %s, Setting debug count to %ld",STRLOC,(long)ahm_count);
g->t_ahms= marpa_renew(struct s_ahm,base_item,ahm_count);
/*498:*/
#line 5273 "./marpa.w"

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

/*:498*/
#line 5139 "./marpa.w"

}

/*:490*/
#line 3236 "./marpa.w"

/*522:*/
#line 5533 "./marpa.w"
{
Bit_Matrix prediction_nsy_by_nsy_matrix= 
matrix_obs_create(obs_precompute,nsy_count,nsy_count);
/*523:*/
#line 5541 "./marpa.w"

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

/*:523*/
#line 5536 "./marpa.w"

transitive_closure(prediction_nsy_by_nsy_matrix);
/*524:*/
#line 5578 "./marpa.w"
{
/*525:*/
#line 5582 "./marpa.w"

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

/*:525*/
#line 5579 "./marpa.w"

}

/*:524*/
#line 5538 "./marpa.w"

}

/*:522*/
#line 3237 "./marpa.w"

/*512:*/
#line 5368 "./marpa.w"
{
nsy_by_right_nsy_matrix= 
matrix_obs_create(obs_precompute,nsy_count,nsy_count);
/*513:*/
#line 5379 "./marpa.w"

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

/*:513*/
#line 5371 "./marpa.w"

transitive_closure(nsy_by_right_nsy_matrix);
/*514:*/
#line 5404 "./marpa.w"

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

/*:514*/
#line 5373 "./marpa.w"

matrix_clear(nsy_by_right_nsy_matrix);
/*515:*/
#line 5431 "./marpa.w"

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

/*:515*/
#line 5375 "./marpa.w"

transitive_closure(nsy_by_right_nsy_matrix);
}

/*:512*/
#line 3238 "./marpa.w"

/*527:*/
#line 5619 "./marpa.w"

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

/*:527*/
#line 3239 "./marpa.w"

/*528:*/
#line 5643 "./marpa.w"

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

/*:528*/
#line 3240 "./marpa.w"

/*530:*/
#line 5708 "./marpa.w"

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

/*:530*/
#line 3242 "./marpa.w"

/*531:*/
#line 5774 "./marpa.w"

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

/*:531*/
#line 3243 "./marpa.w"

/*532:*/
#line 5790 "./marpa.w"

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

/*:532*/
#line 3244 "./marpa.w"

/*551:*/
#line 5995 "./marpa.w"

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

/*:551*/
#line 3245 "./marpa.w"

/*552:*/
#line 6040 "./marpa.w"

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

/*:552*/
#line 3246 "./marpa.w"

}
g->t_is_precomputed= 1;
if(g->t_has_cycle)
{
MARPA_ERROR(MARPA_ERR_GRAMMAR_HAS_CYCLE);
goto FAILURE;
}
/*370:*/
#line 3268 "./marpa.w"

{cilar_buffer_reinit(&g->t_cilar);}
/*:370*/
#line 3254 "./marpa.w"

return_value= 0;
goto CLEANUP;
FAILURE:;
goto CLEANUP;
CLEANUP:;
marpa_obs_free(obs_precompute);
return return_value;
}

/*:369*//*380:*/
#line 3368 "./marpa.w"

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

/*:380*//*414:*/
#line 4112 "./marpa.w"

int _marpa_g_nrl_is_chaf(
Marpa_Grammar g,
Marpa_NRL_ID nrl_id)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 4117 "./marpa.w"

/*1320:*/
#line 15737 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1320*/
#line 4118 "./marpa.w"

/*1327:*/
#line 15778 "./marpa.w"

if(_MARPA_UNLIKELY(!NRLID_of_G_is_Valid(nrl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_NRLID);
return failure_indicator;
}
/*:1327*/
#line 4119 "./marpa.w"

return NRL_is_CHAF(NRL_by_ID(nrl_id));
}

/*:414*//*464:*/
#line 4933 "./marpa.w"

PRIVATE int ahm_is_valid(
GRAMMAR g,AHMID item_id)
{
return item_id<(AHMID)AHM_Count_of_G(g)&&item_id>=0;
}

/*:464*//*481:*/
#line 5059 "./marpa.w"

int _marpa_g_ahm_count(Marpa_Grammar g){
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 5061 "./marpa.w"

/*1320:*/
#line 15737 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1320*/
#line 5062 "./marpa.w"

return AHM_Count_of_G(g);
}

/*:481*//*482:*/
#line 5066 "./marpa.w"

Marpa_NRL_ID _marpa_g_ahm_nrl(Marpa_Grammar g,
Marpa_AHM_ID item_id){
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 5069 "./marpa.w"

/*1320:*/
#line 15737 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1320*/
#line 5070 "./marpa.w"

/*1333:*/
#line 15821 "./marpa.w"

if(_MARPA_UNLIKELY(!ahm_is_valid(g,item_id))){
MARPA_ERROR(MARPA_ERR_INVALID_AIMID);
return failure_indicator;
}

/*:1333*/
#line 5071 "./marpa.w"

return NRLID_of_AHM(AHM_by_ID(item_id));
}

/*:482*//*484:*/
#line 5076 "./marpa.w"

int _marpa_g_ahm_position(Marpa_Grammar g,
Marpa_AHM_ID item_id){
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 5079 "./marpa.w"

/*1320:*/
#line 15737 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1320*/
#line 5080 "./marpa.w"

/*1333:*/
#line 15821 "./marpa.w"

if(_MARPA_UNLIKELY(!ahm_is_valid(g,item_id))){
MARPA_ERROR(MARPA_ERR_INVALID_AIMID);
return failure_indicator;
}

/*:1333*/
#line 5081 "./marpa.w"

return Position_of_AHM(AHM_by_ID(item_id));
}

/*:484*//*485:*/
#line 5085 "./marpa.w"

int _marpa_g_ahm_raw_position(Marpa_Grammar g,
Marpa_AHM_ID item_id){
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 5088 "./marpa.w"

/*1320:*/
#line 15737 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1320*/
#line 5089 "./marpa.w"

/*1333:*/
#line 15821 "./marpa.w"

if(_MARPA_UNLIKELY(!ahm_is_valid(g,item_id))){
MARPA_ERROR(MARPA_ERR_INVALID_AIMID);
return failure_indicator;
}

/*:1333*/
#line 5090 "./marpa.w"

return Raw_Position_of_AHM(AHM_by_ID(item_id));
}

/*:485*//*486:*/
#line 5094 "./marpa.w"

int _marpa_g_ahm_null_count(Marpa_Grammar g,
Marpa_AHM_ID item_id){
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 5097 "./marpa.w"

/*1320:*/
#line 15737 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1320*/
#line 5098 "./marpa.w"

/*1333:*/
#line 15821 "./marpa.w"

if(_MARPA_UNLIKELY(!ahm_is_valid(g,item_id))){
MARPA_ERROR(MARPA_ERR_INVALID_AIMID);
return failure_indicator;
}

/*:1333*/
#line 5099 "./marpa.w"

return Null_Count_of_AHM(AHM_by_ID(item_id));
}

/*:486*//*488:*/
#line 5104 "./marpa.w"

Marpa_Symbol_ID _marpa_g_ahm_postdot(Marpa_Grammar g,
Marpa_AHM_ID item_id){
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 5107 "./marpa.w"

/*1320:*/
#line 15737 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1320*/
#line 5108 "./marpa.w"

/*1333:*/
#line 15821 "./marpa.w"

if(_MARPA_UNLIKELY(!ahm_is_valid(g,item_id))){
MARPA_ERROR(MARPA_ERR_INVALID_AIMID);
return failure_indicator;
}

/*:1333*/
#line 5109 "./marpa.w"

return Postdot_NSYID_of_AHM(AHM_by_ID(item_id));
}

/*:488*//*496:*/
#line 5223 "./marpa.w"

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

/*:496*//*547:*/
#line 5905 "./marpa.w"

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

/*:547*//*548:*/
#line 5920 "./marpa.w"

Marpa_Assertion_ID
marpa_g_zwa_new(Marpa_Grammar g,int default_value)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 5924 "./marpa.w"

ZWAID zwa_id;
GZWA gzwa;
/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 5927 "./marpa.w"

/*1319:*/
#line 15731 "./marpa.w"

if(_MARPA_UNLIKELY(G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_PRECOMPUTED);
return failure_indicator;
}

/*:1319*/
#line 5928 "./marpa.w"

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

/*:548*//*549:*/
#line 5942 "./marpa.w"

Marpa_Assertion_ID
marpa_g_highest_zwa_id(Marpa_Grammar g)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 5946 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 5947 "./marpa.w"

return ZWA_Count_of_G(g)-1;
}

/*:549*//*550:*/
#line 5954 "./marpa.w"

int
marpa_g_zwa_place(Marpa_Grammar g,
Marpa_Assertion_ID zwaid,
Marpa_Rule_ID irl_id,int rhs_ix)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 5960 "./marpa.w"

void*avl_insert_result;
ZWP zwp;
IRL irl;
int irl_length;
/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 5965 "./marpa.w"

/*1319:*/
#line 15731 "./marpa.w"

if(_MARPA_UNLIKELY(G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_PRECOMPUTED);
return failure_indicator;
}

/*:1319*/
#line 5966 "./marpa.w"

/*1330:*/
#line 15798 "./marpa.w"

if(_MARPA_UNLIKELY(IRLID_is_Malformed(irl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_RULE_ID);
return failure_indicator;
}

/*:1330*/
#line 5967 "./marpa.w"

/*1328:*/
#line 15786 "./marpa.w"

if(_MARPA_UNLIKELY(!IRLID_of_G_Exists(irl_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_RULE_ID);
return-1;
}

/*:1328*/
#line 5968 "./marpa.w"

/*1332:*/
#line 15810 "./marpa.w"

if(_MARPA_UNLIKELY(ZWAID_is_Malformed(zwaid))){
MARPA_ERROR(MARPA_ERR_INVALID_ASSERTION_ID);
return failure_indicator;
}

/*:1332*/
#line 5969 "./marpa.w"

/*1331:*/
#line 15804 "./marpa.w"

if(_MARPA_UNLIKELY(!ZWAID_of_G_Exists(zwaid))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_ASSERTION_ID);
return failure_indicator;
}
/*:1331*/
#line 5970 "./marpa.w"

irl= IRL_by_ID(irl_id);
if(rhs_ix<-1){
MARPA_ERROR(MARPA_ERR_RHS_IX_NEGATIVE);
return failure_indicator;
}
irl_length= Length_of_IRL(irl);
if(irl_length<=rhs_ix){
MARPA_ERROR(MARPA_ERR_RHS_IX_OOB);
return failure_indicator;
}
if(rhs_ix==-1){
rhs_ix= IRL_is_Sequence(irl)?1:irl_length;
}
zwp= marpa_obs_new(g->t_obs,ZWP_Object,1);
IRLID_of_ZWP(zwp)= irl_id;
Dot_of_ZWP(zwp)= rhs_ix;
ZWAID_of_ZWP(zwp)= zwaid;
avl_insert_result= _marpa_avl_insert(g->t_zwp_tree,zwp);
return avl_insert_result?-1:0;
}

/*:550*//*556:*/
#line 6086 "./marpa.w"

Marpa_Recognizer marpa_r_new(Marpa_Grammar g)
{
RECCE r;
int nsy_count;
int nrl_count;
/*1317:*/
#line 15723 "./marpa.w"
void*const failure_indicator= NULL;
/*:1317*/
#line 6092 "./marpa.w"

/*1320:*/
#line 15737 "./marpa.w"

if(_MARPA_UNLIKELY(!G_is_Precomputed(g))){
MARPA_ERROR(MARPA_ERR_NOT_PRECOMPUTED);
return failure_indicator;
}
/*:1320*/
#line 6093 "./marpa.w"

nsy_count= NSY_Count_of_G(g);
nrl_count= NRL_Count_of_G(g);
r= my_malloc(sizeof(struct marpa_r));
/*621:*/
#line 6696 "./marpa.w"
r->t_obs= marpa_obs_init;
/*:621*/
#line 6097 "./marpa.w"

/*559:*/
#line 6106 "./marpa.w"

r->t_ref_count= 1;

/*:559*//*564:*/
#line 6157 "./marpa.w"

{
G_of_R(r)= g;
grammar_ref(g);
}
/*:564*//*569:*/
#line 6176 "./marpa.w"

Input_Phase_of_R(r)= R_BEFORE_INPUT;

/*:569*//*571:*/
#line 6186 "./marpa.w"

r->t_first_earley_set= NULL;
r->t_latest_earley_set= NULL;
r->t_current_earleme= -1;

/*:571*//*575:*/
#line 6220 "./marpa.w"

r->t_earley_item_warning_threshold= 
MAX(DEFAULT_YIM_WARNING_THRESHOLD,AHM_Count_of_G(g)*3);
/*:575*//*579:*/
#line 6249 "./marpa.w"
r->t_furthest_earleme= 0;
/*:579*//*586:*/
#line 6291 "./marpa.w"

r->t_bv_nsyid_is_expected= bv_obs_create(r->t_obs,nsy_count);
/*:586*//*590:*/
#line 6368 "./marpa.w"

r->t_nsy_expected_is_event= lbv_obs_new0(r->t_obs,nsy_count);
/*:590*//*608:*/
#line 6611 "./marpa.w"

r->t_use_leo_flag= 1;
r->t_is_using_leo= 0;
/*:608*//*612:*/
#line 6644 "./marpa.w"

r->t_bv_nrl_seen= bv_obs_create(r->t_obs,nrl_count);
MARPA_DSTACK_INIT2(r->t_nrl_cil_stack,CIL);
/*:612*//*615:*/
#line 6661 "./marpa.w"
r->t_is_exhausted= 0;
/*:615*//*619:*/
#line 6689 "./marpa.w"
r->t_first_inconsistent_ys= -1;

/*:619*//*625:*/
#line 6718 "./marpa.w"

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

/*:625*//*640:*/
#line 6812 "./marpa.w"

r->t_earley_set_count= 0;

/*:640*//*707:*/
#line 7615 "./marpa.w"

MARPA_DSTACK_INIT2(r->t_alternatives,ALT_Object);
/*:707*//*732:*/
#line 8113 "./marpa.w"
MARPA_DSTACK_SAFE(r->t_yim_work_stack);
/*:732*//*736:*/
#line 8128 "./marpa.w"
MARPA_DSTACK_SAFE(r->t_completion_stack);
/*:736*//*740:*/
#line 8139 "./marpa.w"
MARPA_DSTACK_SAFE(r->t_earley_set_stack);
/*:740*//*831:*/
#line 9672 "./marpa.w"

r->t_current_report_item= &progress_report_not_ready;
r->t_progress_report_traverser= NULL;
/*:831*//*865:*/
#line 10107 "./marpa.w"

ur_node_stack_init(URS_of_R(r));
/*:865*//*1350:*/
#line 16004 "./marpa.w"

r->t_trace_earley_set= NULL;

/*:1350*//*1357:*/
#line 16080 "./marpa.w"

r->t_trace_earley_item= NULL;

/*:1357*//*1371:*/
#line 16280 "./marpa.w"

r->t_trace_pim_nsy_p= NULL;
r->t_trace_postdot_item= NULL;
/*:1371*//*1379:*/
#line 16430 "./marpa.w"

r->t_trace_source_link= NULL;
r->t_trace_source_type= NO_SOURCE;

/*:1379*/
#line 6098 "./marpa.w"

/*1299:*/
#line 15536 "./marpa.w"

{
if(G_is_Trivial(g)){
psar_safe(Dot_PSAR_of_R(r));
}else{
psar_init(Dot_PSAR_of_R(r),AHM_Count_of_G(g));
}
}
/*:1299*/
#line 6099 "./marpa.w"

/*584:*/
#line 6271 "./marpa.w"

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

/*:584*/
#line 6100 "./marpa.w"

return r;
}

/*:556*//*560:*/
#line 6110 "./marpa.w"

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

/*:560*//*561:*/
#line 6128 "./marpa.w"

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

/*:561*//*562:*/
#line 6142 "./marpa.w"

PRIVATE
void recce_free(struct marpa_r*r)
{
/*565:*/
#line 6162 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:565*/
#line 6146 "./marpa.w"

/*566:*/
#line 6164 "./marpa.w"
grammar_unref(g);

/*:566*//*613:*/
#line 6647 "./marpa.w"

MARPA_DSTACK_DESTROY(r->t_nrl_cil_stack);

/*:613*//*708:*/
#line 7617 "./marpa.w"
MARPA_DSTACK_DESTROY(r->t_alternatives);

/*:708*//*734:*/
#line 8121 "./marpa.w"
MARPA_DSTACK_DESTROY(r->t_yim_work_stack);

/*:734*//*738:*/
#line 8136 "./marpa.w"
MARPA_DSTACK_DESTROY(r->t_completion_stack);

/*:738*//*741:*/
#line 8140 "./marpa.w"
MARPA_DSTACK_DESTROY(r->t_earley_set_stack);

/*:741*//*833:*/
#line 9681 "./marpa.w"

/*832:*/
#line 9675 "./marpa.w"

r->t_current_report_item= &progress_report_not_ready;
if(r->t_progress_report_traverser){
_marpa_avl_destroy(MARPA_TREE_OF_AVL_TRAV(r->t_progress_report_traverser));
}
r->t_progress_report_traverser= NULL;
/*:832*/
#line 9682 "./marpa.w"
;
/*:833*//*866:*/
#line 10109 "./marpa.w"

ur_node_stack_destroy(URS_of_R(r));

/*:866*//*1300:*/
#line 15544 "./marpa.w"

psar_destroy(Dot_PSAR_of_R(r));
/*:1300*/
#line 6147 "./marpa.w"

/*622:*/
#line 6697 "./marpa.w"
marpa_obs_free(r->t_obs);

/*:622*/
#line 6148 "./marpa.w"

my_free(r);
}

/*:562*//*572:*/
#line 6194 "./marpa.w"

Marpa_Earleme marpa_r_current_earleme(Marpa_Recognizer r)
{
/*565:*/
#line 6162 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:565*/
#line 6197 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return-1;
}
return Current_Earleme_of_R(r);
}

/*:572*//*573:*/
#line 6209 "./marpa.w"

PRIVATE YS ys_at_current_earleme(RECCE r)
{
const YS latest= Latest_YS_of_R(r);
if(Earleme_of_YS(latest)==Current_Earleme_of_R(r))return latest;
return NULL;
}

/*:573*//*576:*/
#line 6223 "./marpa.w"

int
marpa_r_earley_item_warning_threshold(Marpa_Recognizer r)
{
return r->t_earley_item_warning_threshold;
}

/*:576*//*577:*/
#line 6232 "./marpa.w"

int
marpa_r_earley_item_warning_threshold_set(Marpa_Recognizer r,int threshold)
{
const int new_threshold= threshold<=0?YIM_FATAL_THRESHOLD:threshold;
r->t_earley_item_warning_threshold= new_threshold;
return new_threshold;
}

/*:577*//*580:*/
#line 6250 "./marpa.w"

unsigned int marpa_r_furthest_earleme(Marpa_Recognizer r)
{return(unsigned int)Furthest_Earleme_of_R(r);}

/*:580*//*587:*/
#line 6299 "./marpa.w"

int marpa_r_terminals_expected(Marpa_Recognizer r,Marpa_Symbol_ID*buffer)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 6302 "./marpa.w"

/*565:*/
#line 6162 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:565*/
#line 6303 "./marpa.w"

NSYID isy_count;
Bit_Vector bv_terminals;
int min,max,start;
int next_buffer_ix= 0;

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 6309 "./marpa.w"

/*1335:*/
#line 15835 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1335*/
#line 6310 "./marpa.w"


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

/*:587*//*588:*/
#line 6337 "./marpa.w"

int marpa_r_terminal_is_expected(Marpa_Recognizer r,
Marpa_Symbol_ID isy_id)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 6341 "./marpa.w"

/*565:*/
#line 6162 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:565*/
#line 6342 "./marpa.w"

ISY isy;
NSY nsy;
/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 6345 "./marpa.w"

/*1335:*/
#line 15835 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1335*/
#line 6346 "./marpa.w"

/*1321:*/
#line 15742 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1321*/
#line 6347 "./marpa.w"

/*1323:*/
#line 15754 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return failure_indicator;
}

/*:1323*/
#line 6348 "./marpa.w"

isy= ISY_by_ID(isy_id);
if(_MARPA_UNLIKELY(!ISY_is_Terminal(isy))){
return 0;
}
nsy= NSY_of_ISY(isy);
if(_MARPA_UNLIKELY(!nsy))return 0;
return bv_bit_test(r->t_bv_nsyid_is_expected,ID_of_NSY(nsy));
}

/*:588*//*591:*/
#line 6371 "./marpa.w"

int
marpa_r_expected_symbol_event_set(Marpa_Recognizer r,Marpa_Symbol_ID isy_id,
int value)
{
ISY isy;
NSY nsy;
NSYID nsyid;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 6379 "./marpa.w"

/*565:*/
#line 6162 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:565*/
#line 6380 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 6381 "./marpa.w"

/*1321:*/
#line 15742 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1321*/
#line 6382 "./marpa.w"

/*1322:*/
#line 15749 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}
/*:1322*/
#line 6383 "./marpa.w"

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

/*:591*//*593:*/
#line 6422 "./marpa.w"

int
marpa_r_completion_symbol_activate(Marpa_Recognizer r,
Marpa_Symbol_ID isy_id,int reactivate)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 6427 "./marpa.w"

/*565:*/
#line 6162 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:565*/
#line 6428 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 6429 "./marpa.w"

/*1321:*/
#line 15742 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1321*/
#line 6430 "./marpa.w"

/*1322:*/
#line 15749 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}
/*:1322*/
#line 6431 "./marpa.w"

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

/*:593*//*595:*/
#line 6469 "./marpa.w"

int
marpa_r_nulled_symbol_activate(Marpa_Recognizer r,Marpa_Symbol_ID isy_id,
int reactivate)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 6474 "./marpa.w"

/*565:*/
#line 6162 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:565*/
#line 6475 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 6476 "./marpa.w"

/*1321:*/
#line 15742 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1321*/
#line 6477 "./marpa.w"

/*1322:*/
#line 15749 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}
/*:1322*/
#line 6478 "./marpa.w"

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

/*:595*//*597:*/
#line 6516 "./marpa.w"

int
marpa_r_prediction_symbol_activate(Marpa_Recognizer r,
Marpa_Symbol_ID isy_id,int reactivate)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 6521 "./marpa.w"

/*565:*/
#line 6162 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:565*/
#line 6522 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 6523 "./marpa.w"

/*1321:*/
#line 15742 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1321*/
#line 6524 "./marpa.w"

/*1322:*/
#line 15749 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}
/*:1322*/
#line 6525 "./marpa.w"

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

/*:597*//*609:*/
#line 6617 "./marpa.w"

int _marpa_r_is_use_leo(Marpa_Recognizer r)
{
/*565:*/
#line 6162 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:565*/
#line 6620 "./marpa.w"

/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 6621 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 6622 "./marpa.w"

return r->t_use_leo_flag;
}
/*:609*//*610:*/
#line 6625 "./marpa.w"

int _marpa_r_is_use_leo_set(
Marpa_Recognizer r,int value)
{
/*565:*/
#line 6162 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:565*/
#line 6629 "./marpa.w"

/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 6630 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 6631 "./marpa.w"

/*1334:*/
#line 15830 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)!=R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_STARTED);
return failure_indicator;
}
/*:1334*/
#line 6632 "./marpa.w"

return r->t_use_leo_flag= value?1:0;
}

/*:610*//*617:*/
#line 6672 "./marpa.w"

int marpa_r_is_exhausted(Marpa_Recognizer r)
{
/*565:*/
#line 6162 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:565*/
#line 6675 "./marpa.w"

/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 6676 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 6677 "./marpa.w"

return R_is_Exhausted(r);
}

/*:617*//*644:*/
#line 6831 "./marpa.w"

int marpa_r_earley_set_value(Marpa_Recognizer r,Marpa_Earley_Set_ID set_id)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 6834 "./marpa.w"

YS earley_set;
/*565:*/
#line 6162 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:565*/
#line 6836 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 6837 "./marpa.w"

/*1335:*/
#line 15835 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1335*/
#line 6838 "./marpa.w"

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

/*:644*//*645:*/
#line 6854 "./marpa.w"

int
marpa_r_earley_set_values(Marpa_Recognizer r,Marpa_Earley_Set_ID set_id,
int*p_value,void**p_pvalue)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 6859 "./marpa.w"

YS earley_set;
/*565:*/
#line 6162 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:565*/
#line 6861 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 6862 "./marpa.w"

/*1335:*/
#line 15835 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1335*/
#line 6863 "./marpa.w"

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

/*:645*//*646:*/
#line 6881 "./marpa.w"

int marpa_r_latest_earley_set_value_set(Marpa_Recognizer r,int value)
{
YS earley_set;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 6885 "./marpa.w"

/*565:*/
#line 6162 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:565*/
#line 6886 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 6887 "./marpa.w"

/*1335:*/
#line 15835 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1335*/
#line 6888 "./marpa.w"

earley_set= Latest_YS_of_R(r);
return Value_of_YS(earley_set)= value;
}

/*:646*//*647:*/
#line 6893 "./marpa.w"

int marpa_r_latest_earley_set_values_set(Marpa_Recognizer r,int value,
void*pvalue)
{
YS earley_set;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 6898 "./marpa.w"

/*565:*/
#line 6162 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:565*/
#line 6899 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 6900 "./marpa.w"

/*1335:*/
#line 15835 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1335*/
#line 6901 "./marpa.w"

earley_set= Latest_YS_of_R(r);
Value_of_YS(earley_set)= value;
PValue_of_YS(earley_set)= pvalue;
return 1;
}

/*:647*//*648:*/
#line 6909 "./marpa.w"

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
/*643:*/
#line 6827 "./marpa.w"

Value_of_YS(set)= -1;
PValue_of_YS(set)= NULL;

/*:643*//*1306:*/
#line 15600 "./marpa.w"

{set->t_dot_psl= NULL;}

/*:1306*/
#line 6924 "./marpa.w"

return set;
}

/*:648*//*658:*/
#line 7034 "./marpa.w"

PRIVATE YIM earley_item_create(const RECCE r,
const YIK_Object key)
{
/*1317:*/
#line 15723 "./marpa.w"
void*const failure_indicator= NULL;
/*:1317*/
#line 7038 "./marpa.w"

/*565:*/
#line 6162 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:565*/
#line 7039 "./marpa.w"

YIM new_item;
YIM*end_of_work_stack;
const YS set= key.t_set;
const int count= ++YIM_Count_of_YS(set);
/*660:*/
#line 7093 "./marpa.w"

if(_MARPA_UNLIKELY(count>=YIM_FATAL_THRESHOLD))
{
MARPA_FATAL(MARPA_ERR_YIM_COUNT);
return failure_indicator;
}

/*:660*/
#line 7044 "./marpa.w"

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

/*:658*//*659:*/
#line 7061 "./marpa.w"

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

/*:659*//*664:*/
#line 7129 "./marpa.w"

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

/*:664*//*676:*/
#line 7250 "./marpa.w"

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
/*:676*//*677:*/
#line 7270 "./marpa.w"

PRIVATE PIM first_pim_of_ys_by_nsyid(YS set,NSYID nsyid)
{
PIM*pim_nsy_p= pim_nsy_p_find(set,nsyid);
return pim_nsy_p?*pim_nsy_p:NULL;
}

/*:677*//*695:*/
#line 7427 "./marpa.w"

PRIVATE
SRCL unique_srcl_new(struct marpa_obstack*t_obs)
{
const SRCL new_srcl= marpa_obs_new(t_obs,SRCL_Object,1);
SRCL_is_Rejected(new_srcl)= 0;
SRCL_is_Active(new_srcl)= 1;
return new_srcl;
}

/*:695*//*696:*/
#line 7437 "./marpa.w"
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

/*:696*//*697:*/
#line 7468 "./marpa.w"

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

/*:697*//*698:*/
#line 7498 "./marpa.w"

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

/*:698*//*700:*/
#line 7547 "./marpa.w"

PRIVATE_NOT_INLINE
void earley_item_ambiguate(struct marpa_r*r,YIM item)
{
unsigned int previous_source_type= Source_Type_of_YIM(item);
Source_Type_of_YIM(item)= SOURCE_IS_AMBIGUOUS;
switch(previous_source_type)
{
case SOURCE_IS_TOKEN:/*701:*/
#line 7564 "./marpa.w"
{
SRCL new_link= marpa_obs_new(r->t_obs,SRCL_Object,1);
*new_link= *SRCL_of_YIM(item);
LV_First_Leo_SRCL_of_YIM(item)= NULL;
LV_First_Completion_SRCL_of_YIM(item)= NULL;
LV_First_Token_SRCL_of_YIM(item)= new_link;
}

/*:701*/
#line 7555 "./marpa.w"

return;
case SOURCE_IS_COMPLETION:/*702:*/
#line 7572 "./marpa.w"
{
SRCL new_link= marpa_obs_new(r->t_obs,SRCL_Object,1);
*new_link= *SRCL_of_YIM(item);
LV_First_Leo_SRCL_of_YIM(item)= NULL;
LV_First_Completion_SRCL_of_YIM(item)= new_link;
LV_First_Token_SRCL_of_YIM(item)= NULL;
}

/*:702*/
#line 7557 "./marpa.w"

return;
case SOURCE_IS_LEO:/*703:*/
#line 7580 "./marpa.w"
{
SRCL new_link= marpa_obs_new(r->t_obs,SRCL_Object,1);
*new_link= *SRCL_of_YIM(item);
LV_First_Leo_SRCL_of_YIM(item)= new_link;
LV_First_Completion_SRCL_of_YIM(item)= NULL;
LV_First_Token_SRCL_of_YIM(item)= NULL;
}

/*:703*/
#line 7559 "./marpa.w"

return;
}
}

/*:700*//*710:*/
#line 7623 "./marpa.w"

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

/*:710*//*712:*/
#line 7667 "./marpa.w"

PRIVATE int alternative_cmp(const ALT_Const a,const ALT_Const b)
{
int subkey= End_Earleme_of_ALT(b)-End_Earleme_of_ALT(a);
if(subkey)return subkey;
subkey= NSYID_of_ALT(a)-NSYID_of_ALT(b);
if(subkey)return subkey;
return Start_Earleme_of_ALT(a)-Start_Earleme_of_ALT(b);
}

/*:712*//*713:*/
#line 7684 "./marpa.w"

PRIVATE ALT alternative_pop(RECCE r,JEARLEME earleme)
{
MARPA_DSTACK alternatives= &r->t_alternatives;
ALT end_of_stack= MARPA_DSTACK_TOP(*alternatives,ALT_Object);

if(!end_of_stack)return NULL;






if(earleme<End_Earleme_of_ALT(end_of_stack))
return NULL;

return MARPA_DSTACK_POP(*alternatives,ALT_Object);
}

/*:713*//*715:*/
#line 7711 "./marpa.w"

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

/*:715*//*716:*/
#line 7734 "./marpa.w"
int marpa_r_start_input(Marpa_Recognizer r)
{
int return_value= 1;
YS set0;
YIK_Object key;

NRL start_nrl;
AHM start_ahm;

/*565:*/
#line 6162 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:565*/
#line 7743 "./marpa.w"

/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 7744 "./marpa.w"


/*1334:*/
#line 15830 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)!=R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_STARTED);
return failure_indicator;
}
/*:1334*/
#line 7746 "./marpa.w"

{
/*718:*/
#line 7864 "./marpa.w"

const NSYID nsy_count= NSY_Count_of_G(g);
const NSYID isy_count= ISY_Count_of_G(g);
Bit_Vector bv_ok_for_chain= bv_create(nsy_count);
/*:718*/
#line 7748 "./marpa.w"

Current_Earleme_of_R(r)= 0;
/*724:*/
#line 7906 "./marpa.w"

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

/*:724*/
#line 7750 "./marpa.w"

G_EVENTS_CLEAR(g);

set0= earley_set_new(r,0);
Latest_YS_of_R(r)= set0;
First_YS_of_R(r)= set0;

if(G_is_Trivial(g)){
return_value+= trigger_trivial_events(r);
/*616:*/
#line 6662 "./marpa.w"

{
R_is_Exhausted(r)= 1;
Input_Phase_of_R(r)= R_AFTER_INPUT;
event_new(g,MARPA_EVENT_EXHAUSTED);
}

/*:616*/
#line 7759 "./marpa.w"

goto CLEANUP;
}
Input_Phase_of_R(r)= R_DURING_INPUT;
psar_reset(Dot_PSAR_of_R(r));
/*777:*/
#line 8772 "./marpa.w"

r->t_bv_lim_symbols= bv_obs_create(r->t_obs,nsy_count);
r->t_bv_pim_symbols= bv_obs_create(r->t_obs,nsy_count);
r->t_pim_workarea= marpa_obs_new(r->t_obs,void*,nsy_count);
/*:777*//*796:*/
#line 9054 "./marpa.w"

r->t_lim_chain= marpa_obs_new(r->t_obs,void*,2*nsy_count);
/*:796*/
#line 7764 "./marpa.w"

/*733:*/
#line 8114 "./marpa.w"

{
if(!MARPA_DSTACK_IS_INITIALIZED(r->t_yim_work_stack))
{
MARPA_DSTACK_INIT2(r->t_yim_work_stack,YIM);
}
}
/*:733*//*737:*/
#line 8129 "./marpa.w"

{
if(!MARPA_DSTACK_IS_INITIALIZED(r->t_completion_stack))
{
MARPA_DSTACK_INIT2(r->t_completion_stack,YIM);
}
}
/*:737*/
#line 7765 "./marpa.w"


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
/*719:*/
#line 7868 "./marpa.w"

bv_free(bv_ok_for_chain);

/*:719*/
#line 7817 "./marpa.w"

}
return return_value;
}

/*:716*//*717:*/
#line 7822 "./marpa.w"

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


/*:717*//*725:*/
#line 7946 "./marpa.w"

Marpa_Earleme marpa_r_alternative(
Marpa_Recognizer r,
Marpa_Symbol_ID tkn_isy_id,
int value,
int length)
{
/*565:*/
#line 6162 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:565*/
#line 7953 "./marpa.w"

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
/*726:*/
#line 7985 "./marpa.w"
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

/*:726*/
#line 7978 "./marpa.w"

/*729:*/
#line 8045 "./marpa.w"

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

/*:729*/
#line 7979 "./marpa.w"

/*727:*/
#line 8025 "./marpa.w"
{
target_earleme= current_earleme+length;
if(target_earleme>=JEARLEME_THRESHOLD){
MARPA_ERROR(MARPA_ERR_PARSE_TOO_LONG);
return MARPA_ERR_PARSE_TOO_LONG;
}
}

/*:727*/
#line 7980 "./marpa.w"

/*730:*/
#line 8083 "./marpa.w"

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

/*:730*/
#line 7981 "./marpa.w"

return MARPA_ERR_NONE;
}

/*:725*//*743:*/
#line 8160 "./marpa.w"

int
marpa_r_earleme_complete(Marpa_Recognizer r)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 8164 "./marpa.w"

/*565:*/
#line 6162 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:565*/
#line 8165 "./marpa.w"

YIM*cause_p;
YS current_earley_set;
JEARLEME current_earleme;





JEARLEME return_value= -2;

/*1336:*/
#line 15840 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)!=R_DURING_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_ACCEPTING_INPUT);
return failure_indicator;
}

if(_MARPA_UNLIKELY(!R_is_Consistent(r))){
MARPA_ERROR(MARPA_ERR_RECCE_IS_INCONSISTENT);
return failure_indicator;
}

/*:1336*/
#line 8176 "./marpa.w"

if(_MARPA_UNLIKELY(!R_is_Consistent(r))){
MARPA_ERROR(MARPA_ERR_RECCE_IS_INCONSISTENT);
return failure_indicator;
}

{
int count_of_expected_terminals;
/*744:*/
#line 8226 "./marpa.w"

const NSYID nsy_count= NSY_Count_of_G(g);
Bit_Vector bv_ok_for_chain= bv_create(nsy_count);
struct marpa_obstack*const earleme_complete_obs= marpa_obs_init;
/*:744*/
#line 8184 "./marpa.w"

G_EVENTS_CLEAR(g);
psar_dealloc(Dot_PSAR_of_R(r));
bv_clear(r->t_bv_nsyid_is_expected);
bv_clear(r->t_bv_nrl_seen);
/*746:*/
#line 8234 "./marpa.w"
{
current_earleme= ++(Current_Earleme_of_R(r));
if(current_earleme> Furthest_Earleme_of_R(r))
{
/*616:*/
#line 6662 "./marpa.w"

{
R_is_Exhausted(r)= 1;
Input_Phase_of_R(r)= R_AFTER_INPUT;
event_new(g,MARPA_EVENT_EXHAUSTED);
}

/*:616*/
#line 8238 "./marpa.w"

MARPA_ERROR(MARPA_ERR_PARSE_EXHAUSTED);
return_value= failure_indicator;
goto CLEANUP;
}
}

/*:746*/
#line 8189 "./marpa.w"

/*748:*/
#line 8257 "./marpa.w"
{
ALT end_of_stack= MARPA_DSTACK_TOP(r->t_alternatives,ALT_Object);
if(!end_of_stack||current_earleme!=End_Earleme_of_ALT(end_of_stack))
{
return_value= 0;
goto CLEANUP;
}
}

/*:748*/
#line 8190 "./marpa.w"

/*747:*/
#line 8247 "./marpa.w"
{
current_earley_set= earley_set_new(r,current_earleme);
Next_YS_of_YS(Latest_YS_of_R(r))= current_earley_set;
Latest_YS_of_R(r)= current_earley_set;
}

/*:747*/
#line 8191 "./marpa.w"

/*749:*/
#line 8266 "./marpa.w"

{
ALT alternative;


while((alternative= alternative_pop(r,current_earleme)))
/*751:*/
#line 8285 "./marpa.w"

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
/*752:*/
#line 8304 "./marpa.w"

{
const YIM scanned_earley_item= earley_item_assign(r,
current_earley_set,
Origin_of_YIM
(predecessor),
scanned_ahm);
YIM_was_Scanned(scanned_earley_item)= 1;
tkn_link_add(r,scanned_earley_item,predecessor,alternative);
}

/*:752*/
#line 8299 "./marpa.w"

}
}
}

/*:751*/
#line 8272 "./marpa.w"

}

/*:749*/
#line 8192 "./marpa.w"

/*753:*/
#line 8320 "./marpa.w"
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

/*:753*/
#line 8193 "./marpa.w"

while((cause_p= MARPA_DSTACK_POP(r->t_completion_stack,YIM))){
YIM cause= *cause_p;
/*754:*/
#line 8341 "./marpa.w"

{
if(YIM_is_Active(cause)&&YIM_is_Completion(cause))
{
NSYID complete_nsyid= LHS_NSYID_of_YIM(cause);
const YS middle= Origin_of_YIM(cause);
/*755:*/
#line 8351 "./marpa.w"

{
PIM postdot_item;
for(postdot_item= First_PIM_of_YS_by_NSYID(middle,complete_nsyid);
postdot_item;postdot_item= Next_PIM_of_PIM(postdot_item))
{
const YIM predecessor= YIM_of_PIM(postdot_item);
if(!predecessor){


const LIM leo_item= LIM_of_PIM(postdot_item);








if(!LIM_is_Active(leo_item))goto NEXT_PIM;

/*758:*/
#line 8418 "./marpa.w"
{
const YS origin= Origin_of_LIM(leo_item);
const AHM effect_ahm= Top_AHM_of_LIM(leo_item);
const YIM effect= earley_item_assign(r,current_earley_set,
origin,effect_ahm);
YIM_was_Fusion(effect)= 1;
if(Earley_Item_has_No_Source(effect))
{


/*757:*/
#line 8412 "./marpa.w"
{
YIM*end_of_stack= MARPA_DSTACK_PUSH(r->t_completion_stack,YIM);
*end_of_stack= effect;
}

/*:757*/
#line 8428 "./marpa.w"

}
leo_link_add(r,effect,leo_item,cause);
}

/*:758*/
#line 8372 "./marpa.w"





goto LAST_PIM;
}else{


if(!YIM_is_Active(predecessor))continue;



/*756:*/
#line 8392 "./marpa.w"

{
const AHM predecessor_ahm= AHM_of_YIM(predecessor);
const AHM effect_ahm= Next_AHM_of_AHM(predecessor_ahm);
const YS origin= Origin_of_YIM(predecessor);
const YIM effect= earley_item_assign(r,current_earley_set,
origin,effect_ahm);
YIM_was_Fusion(effect)= 1;
if(Earley_Item_has_No_Source(effect)){


if(YIM_is_Completion(effect)){
/*757:*/
#line 8412 "./marpa.w"
{
YIM*end_of_stack= MARPA_DSTACK_PUSH(r->t_completion_stack,YIM);
*end_of_stack= effect;
}

/*:757*/
#line 8404 "./marpa.w"

}
}
completion_link_add(r,effect,predecessor,cause);
}

/*:756*/
#line 8385 "./marpa.w"

}
NEXT_PIM:;
}
LAST_PIM:;
}

/*:755*/
#line 8347 "./marpa.w"

}
}

/*:754*/
#line 8196 "./marpa.w"

}
/*759:*/
#line 8433 "./marpa.w"

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

/*:759*/
#line 8198 "./marpa.w"

postdot_items_create(r,bv_ok_for_chain,current_earley_set);





count_of_expected_terminals= bv_count(r->t_bv_nsyid_is_expected);
if(count_of_expected_terminals<=0
&&MARPA_DSTACK_LENGTH(r->t_alternatives)<=0)
{
/*616:*/
#line 6662 "./marpa.w"

{
R_is_Exhausted(r)= 1;
Input_Phase_of_R(r)= R_AFTER_INPUT;
event_new(g,MARPA_EVENT_EXHAUSTED);
}

/*:616*/
#line 8209 "./marpa.w"

}
earley_set_update_items(r,current_earley_set);
/*661:*/
#line 7101 "./marpa.w"

{
const int yim_count= YIM_Count_of_YS(current_earley_set);
if(yim_count>=r->t_earley_item_warning_threshold)
{
int_event_new(g,MARPA_EVENT_EARLEY_ITEM_THRESHOLD,yim_count);
}
}

/*:661*/
#line 8212 "./marpa.w"

if(r->t_active_event_count> 0){
trigger_events(r);
}
return_value= G_EVENT_COUNT(g);
CLEANUP:;
/*745:*/
#line 8230 "./marpa.w"

bv_free(bv_ok_for_chain);
marpa_obs_free(earleme_complete_obs);

/*:745*/
#line 8218 "./marpa.w"

}
return return_value;
}

/*:743*//*760:*/
#line 8458 "./marpa.w"

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

/*:760*//*761:*/
#line 8626 "./marpa.w"

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

/*:761*//*762:*/
#line 8646 "./marpa.w"

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

/*:762*//*763:*/
#line 8675 "./marpa.w"

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

/*:763*//*779:*/
#line 8779 "./marpa.w"

PRIVATE_NOT_INLINE void
postdot_items_create(RECCE r,
Bit_Vector bv_ok_for_chain,
const YS current_earley_set)
{
/*565:*/
#line 6162 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:565*/
#line 8785 "./marpa.w"

/*778:*/
#line 8776 "./marpa.w"

bv_clear(r->t_bv_lim_symbols);
bv_clear(r->t_bv_pim_symbols);
/*:778*/
#line 8786 "./marpa.w"

/*780:*/
#line 8798 "./marpa.w"
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

/*:780*/
#line 8787 "./marpa.w"

if(r->t_is_using_leo){
/*782:*/
#line 8841 "./marpa.w"

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
/*783:*/
#line 8885 "./marpa.w"
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

/*:783*/
#line 8870 "./marpa.w"

}
}
}
NEXT_NSYID:;
}
}
}

/*:782*/
#line 8789 "./marpa.w"

/*792:*/
#line 8973 "./marpa.w"
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

/*794:*/
#line 9029 "./marpa.w"

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

/*:794*/
#line 8990 "./marpa.w"

if(predecessor_lim&&LIM_is_Populated(predecessor_lim)){
/*802:*/
#line 9148 "./marpa.w"

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

/*:802*/
#line 8992 "./marpa.w"

continue;
}
if(!predecessor_lim){


/*804:*/
#line 9189 "./marpa.w"
{
const AHM trailhead_ahm= Trailhead_AHM_of_LIM(lim_to_process);
const YIM base_yim= Trailhead_YIM_of_LIM(lim_to_process);
Origin_of_LIM(lim_to_process)= Origin_of_YIM(base_yim);
CIL_of_LIM(lim_to_process)= Event_AHMIDs_of_AHM(trailhead_ahm);
}

/*:804*/
#line 8998 "./marpa.w"

continue;
}
/*797:*/
#line 9056 "./marpa.w"
{
int lim_chain_ix;
/*800:*/
#line 9076 "./marpa.w"

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

/*794:*/
#line 9029 "./marpa.w"

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

/*:794*/
#line 9109 "./marpa.w"


r->t_lim_chain[lim_chain_ix++]= LIM_of_PIM(lim_to_process);


bv_bit_clear(bv_ok_for_chain,
postdot_nsyid_of_lim_to_process);





if(!predecessor_lim)
break;
if(LIM_is_Populated(predecessor_lim))
break;



}
}

/*:800*/
#line 9058 "./marpa.w"

/*801:*/
#line 9131 "./marpa.w"

for(lim_chain_ix--;lim_chain_ix>=0;lim_chain_ix--){
lim_to_process= r->t_lim_chain[lim_chain_ix];
if(predecessor_lim&&LIM_is_Populated(predecessor_lim)){
/*802:*/
#line 9148 "./marpa.w"

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

/*:802*/
#line 9135 "./marpa.w"

}else{
/*804:*/
#line 9189 "./marpa.w"
{
const AHM trailhead_ahm= Trailhead_AHM_of_LIM(lim_to_process);
const YIM base_yim= Trailhead_YIM_of_LIM(lim_to_process);
Origin_of_LIM(lim_to_process)= Origin_of_YIM(base_yim);
CIL_of_LIM(lim_to_process)= Event_AHMIDs_of_AHM(trailhead_ahm);
}

/*:804*/
#line 9137 "./marpa.w"

}
predecessor_lim= lim_to_process;
}

/*:801*/
#line 9059 "./marpa.w"

}

/*:797*/
#line 9001 "./marpa.w"

}
}
}

/*:792*/
#line 8790 "./marpa.w"

}
/*805:*/
#line 9196 "./marpa.w"
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


/*:805*/
#line 8792 "./marpa.w"

bv_and(r->t_bv_nsyid_is_expected,r->t_bv_pim_symbols,g->t_bv_nsyid_is_terminal);
}

/*:779*//*808:*/
#line 9232 "./marpa.w"

Marpa_Earleme
marpa_r_clean(Marpa_Recognizer r)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 9236 "./marpa.w"

/*565:*/
#line 6162 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:565*/
#line 9237 "./marpa.w"

YSID ysid_to_clean;


const YS current_ys= Latest_YS_of_R(r);
const YSID current_ys_id= Ord_of_YS(current_ys);

int count_of_expected_terminals;
/*809:*/
#line 9293 "./marpa.w"




struct marpa_obstack*const method_obstack= marpa_obs_init;

YIMID*prediction_by_nrl= 
marpa_obs_new(method_obstack,YIMID,NRL_Count_of_G(g));

/*:809*/
#line 9245 "./marpa.w"






const JEARLEME return_value= -2;

/*1336:*/
#line 15840 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)!=R_DURING_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_ACCEPTING_INPUT);
return failure_indicator;
}

if(_MARPA_UNLIKELY(!R_is_Consistent(r))){
MARPA_ERROR(MARPA_ERR_RECCE_IS_INCONSISTENT);
return failure_indicator;
}

/*:1336*/
#line 9253 "./marpa.w"


G_EVENTS_CLEAR(g);



if(R_is_Consistent(r))return 0;





earley_set_update_items(r,current_ys);

for(ysid_to_clean= First_Inconsistent_YS_of_R(r);
ysid_to_clean<=current_ys_id;
ysid_to_clean++){
/*811:*/
#line 9307 "./marpa.w"

{
const YS ys_to_clean= YS_of_R_by_Ord(r,ysid_to_clean);
const YIM*yims_to_clean= YIMs_of_YS(ys_to_clean);
const int yim_to_clean_count= YIM_Count_of_YS(ys_to_clean);
Bit_Matrix acceptance_matrix= matrix_obs_create(method_obstack,
yim_to_clean_count,
yim_to_clean_count);
/*812:*/
#line 9327 "./marpa.w"

{
int yim_ix= yim_to_clean_count-1;
YIM yim= yims_to_clean[yim_ix];






while(YIM_was_Predicted(yim)){
prediction_by_nrl[NRLID_of_YIM(yim)]= yim_ix;
yim= yims_to_clean[--yim_ix];
}
}

/*:812*/
#line 9315 "./marpa.w"

/*813:*/
#line 9343 "./marpa.w"
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



/*814:*/
#line 9380 "./marpa.w"

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

/*:814*/
#line 9370 "./marpa.w"







}
}

/*:813*/
#line 9316 "./marpa.w"

transitive_closure(acceptance_matrix);
/*819:*/
#line 9440 "./marpa.w"
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

/*:819*/
#line 9318 "./marpa.w"

/*820:*/
#line 9481 "./marpa.w"
{
int yim_ix;
for(yim_ix= 0;yim_ix<yim_to_clean_count;yim_ix++){
const YIM yim= yims_to_clean[yim_ix];
if(!YIM_is_Active(yim))continue;
YIM_is_Rejected(yim)= 1;
}
}

/*:820*/
#line 9319 "./marpa.w"

/*822:*/
#line 9495 "./marpa.w"
{}

/*:822*/
#line 9320 "./marpa.w"

/*823:*/
#line 9499 "./marpa.w"

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

/*:823*/
#line 9321 "./marpa.w"

}

/*:811*/
#line 9270 "./marpa.w"

}




/*824:*/
#line 9544 "./marpa.w"
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

/*:824*/
#line 9276 "./marpa.w"


bv_clear(r->t_bv_nsyid_is_expected);
/*826:*/
#line 9624 "./marpa.w"
{}

/*:826*/
#line 9279 "./marpa.w"

count_of_expected_terminals= bv_count(r->t_bv_nsyid_is_expected);
if(count_of_expected_terminals<=0
&&MARPA_DSTACK_LENGTH(r->t_alternatives)<=0)
{
/*616:*/
#line 6662 "./marpa.w"

{
R_is_Exhausted(r)= 1;
Input_Phase_of_R(r)= R_AFTER_INPUT;
event_new(g,MARPA_EVENT_EXHAUSTED);
}

/*:616*/
#line 9284 "./marpa.w"

}

First_Inconsistent_YS_of_R(r)= -1;

/*810:*/
#line 9302 "./marpa.w"

{
marpa_obs_free(method_obstack);
}

/*:810*/
#line 9289 "./marpa.w"

return return_value;
}

/*:808*//*825:*/
#line 9598 "./marpa.w"

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

/*:825*//*827:*/
#line 9627 "./marpa.w"

int
marpa_r_zwa_default_set(Marpa_Recognizer r,
Marpa_Assertion_ID zwaid,
int default_value)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 9633 "./marpa.w"

/*565:*/
#line 6162 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:565*/
#line 9634 "./marpa.w"

ZWA zwa;
int old_default_value;
/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 9637 "./marpa.w"

/*1332:*/
#line 15810 "./marpa.w"

if(_MARPA_UNLIKELY(ZWAID_is_Malformed(zwaid))){
MARPA_ERROR(MARPA_ERR_INVALID_ASSERTION_ID);
return failure_indicator;
}

/*:1332*/
#line 9638 "./marpa.w"

/*1331:*/
#line 15804 "./marpa.w"

if(_MARPA_UNLIKELY(!ZWAID_of_G_Exists(zwaid))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_ASSERTION_ID);
return failure_indicator;
}
/*:1331*/
#line 9639 "./marpa.w"

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

/*:827*//*828:*/
#line 9651 "./marpa.w"

int
marpa_r_zwa_default(Marpa_Recognizer r,
Marpa_Assertion_ID zwaid)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 9656 "./marpa.w"

/*565:*/
#line 6162 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:565*/
#line 9657 "./marpa.w"

ZWA zwa;
/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 9659 "./marpa.w"

/*1332:*/
#line 15810 "./marpa.w"

if(_MARPA_UNLIKELY(ZWAID_is_Malformed(zwaid))){
MARPA_ERROR(MARPA_ERR_INVALID_ASSERTION_ID);
return failure_indicator;
}

/*:1332*/
#line 9660 "./marpa.w"

/*1331:*/
#line 15804 "./marpa.w"

if(_MARPA_UNLIKELY(!ZWAID_of_G_Exists(zwaid))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_ASSERTION_ID);
return failure_indicator;
}
/*:1331*/
#line 9661 "./marpa.w"

zwa= RZWA_by_ID(zwaid);
return Default_Value_of_ZWA(zwa);
}

/*:828*//*837:*/
#line 9701 "./marpa.w"

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

/*:837*//*838:*/
#line 9718 "./marpa.w"

int marpa_r_progress_report_start(
Marpa_Recognizer r,
Marpa_Earley_Set_ID set_id)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 9723 "./marpa.w"

YS earley_set;
/*565:*/
#line 6162 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:565*/
#line 9725 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 9726 "./marpa.w"

/*1335:*/
#line 15835 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1335*/
#line 9727 "./marpa.w"

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

/*832:*/
#line 9675 "./marpa.w"

r->t_current_report_item= &progress_report_not_ready;
if(r->t_progress_report_traverser){
_marpa_avl_destroy(MARPA_TREE_OF_AVL_TRAV(r->t_progress_report_traverser));
}
r->t_progress_report_traverser= NULL;
/*:832*/
#line 9744 "./marpa.w"

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
/*840:*/
#line 9777 "./marpa.w"

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

/*:840*/
#line 9756 "./marpa.w"

}
r->t_progress_report_traverser= _marpa_avl_t_init(report_tree);
return(int)marpa_avl_count(report_tree);
}
}
/*:838*//*839:*/
#line 9763 "./marpa.w"

int marpa_r_progress_report_reset(Marpa_Recognizer r)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 9766 "./marpa.w"

MARPA_AVL_TRAV traverser= r->t_progress_report_traverser;
/*565:*/
#line 6162 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:565*/
#line 9768 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 9769 "./marpa.w"

/*1335:*/
#line 15835 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1335*/
#line 9770 "./marpa.w"

/*844:*/
#line 9927 "./marpa.w"

{
if(!traverser)
{
MARPA_ERROR(MARPA_ERR_PROGRESS_REPORT_NOT_STARTED);
return failure_indicator;
}
}

/*:844*/
#line 9771 "./marpa.w"

_marpa_avl_t_reset(traverser);
return 1;
}

/*:839*//*841:*/
#line 9811 "./marpa.w"

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

MARPA_OFF_DEBUG3("%s, irl = %d",STRLOC,ID_of_IRL(source_irl));
MARPA_OFF_DEBUG3("%s, irl dot = %d",STRLOC,IRL_Position_of_AHM(report_ahm));
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

/*:841*//*842:*/
#line 9889 "./marpa.w"

int marpa_r_progress_report_finish(Marpa_Recognizer r){
const int success= 1;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 9892 "./marpa.w"

/*565:*/
#line 6162 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:565*/
#line 9893 "./marpa.w"

const MARPA_AVL_TRAV traverser= r->t_progress_report_traverser;
/*1335:*/
#line 15835 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1335*/
#line 9895 "./marpa.w"

/*844:*/
#line 9927 "./marpa.w"

{
if(!traverser)
{
MARPA_ERROR(MARPA_ERR_PROGRESS_REPORT_NOT_STARTED);
return failure_indicator;
}
}

/*:844*/
#line 9896 "./marpa.w"

/*832:*/
#line 9675 "./marpa.w"

r->t_current_report_item= &progress_report_not_ready;
if(r->t_progress_report_traverser){
_marpa_avl_destroy(MARPA_TREE_OF_AVL_TRAV(r->t_progress_report_traverser));
}
r->t_progress_report_traverser= NULL;
/*:832*/
#line 9897 "./marpa.w"

return success;
}

/*:842*//*843:*/
#line 9901 "./marpa.w"

Marpa_Rule_ID marpa_r_progress_item(
Marpa_Recognizer r,int*position,Marpa_Earley_Set_ID*origin
){
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 9905 "./marpa.w"

PROGRESS report_item;
MARPA_AVL_TRAV traverser;
/*565:*/
#line 6162 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:565*/
#line 9908 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 9909 "./marpa.w"

/*1335:*/
#line 15835 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1335*/
#line 9910 "./marpa.w"

traverser= r->t_progress_report_traverser;
if(_MARPA_UNLIKELY(!position||!origin)){
MARPA_ERROR(MARPA_ERR_POINTER_ARG_NULL);
return failure_indicator;
}
/*844:*/
#line 9927 "./marpa.w"

{
if(!traverser)
{
MARPA_ERROR(MARPA_ERR_PROGRESS_REPORT_NOT_STARTED);
return failure_indicator;
}
}

/*:844*/
#line 9916 "./marpa.w"

report_item= _marpa_avl_t_next(traverser);
if(!report_item){
MARPA_ERROR(MARPA_ERR_PROGRESS_REPORT_EXHAUSTED);
return-1;
}
*position= Position_of_PROGRESS(report_item);
*origin= Origin_of_PROGRESS(report_item);
return RULEID_of_PROGRESS(report_item);
}

/*:843*//*867:*/
#line 10112 "./marpa.w"

PRIVATE void ur_node_stack_init(URS stack)
{
stack->t_obs= marpa_obs_init;
stack->t_base= ur_node_new(stack,0);
ur_node_stack_reset(stack);
}

/*:867*//*868:*/
#line 10120 "./marpa.w"

PRIVATE void ur_node_stack_reset(URS stack)
{
stack->t_top= stack->t_base;
}

/*:868*//*869:*/
#line 10126 "./marpa.w"

PRIVATE void ur_node_stack_destroy(URS stack)
{
if(stack->t_base)marpa_obs_free(stack->t_obs);
stack->t_base= NULL;
}

/*:869*//*870:*/
#line 10133 "./marpa.w"

PRIVATE UR ur_node_new(URS stack,UR prev)
{
UR new_ur_node;
new_ur_node= marpa_obs_new(stack->t_obs,UR_Object,1);
Next_UR_of_UR(new_ur_node)= 0;
Prev_UR_of_UR(new_ur_node)= prev;
return new_ur_node;
}

/*:870*//*871:*/
#line 10143 "./marpa.w"

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

/*:871*//*872:*/
#line 10158 "./marpa.w"

PRIVATE UR
ur_node_pop(URS stack)
{
UR new_top= Prev_UR_of_UR(stack->t_top);
if(!new_top)return NULL;
stack->t_top= new_top;
return new_top;
}

/*:872*//*874:*/
#line 10195 "./marpa.w"

PRIVATE void push_ur_if_new(
struct s_bocage_setup_per_ys*per_ys_data,
URS ur_node_stack,YIM yim)
{
if(!psi_test_and_set(per_ys_data,yim))
{
ur_node_push(ur_node_stack,yim);
}
}

/*:874*//*875:*/
#line 10211 "./marpa.w"

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

/*:875*//*877:*/
#line 10253 "./marpa.w"

PRIVATE void
Set_boolean_in_PSI_for_initial_nulls(struct s_bocage_setup_per_ys*per_ys_data,
YIM yim)
{
const AHM ahm= AHM_of_YIM(yim);
if(Null_Count_of_AHM(ahm))
psi_test_and_set(per_ys_data,(yim));
}

/*:877*//*896:*/
#line 10511 "./marpa.w"

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

/*:896*//*906:*/
#line 10711 "./marpa.w"

PRIVATE
DAND draft_and_node_new(struct marpa_obstack*obs,OR predecessor,OR cause)
{
DAND draft_and_node= marpa_obs_new(obs,DAND_Object,1);
Predecessor_OR_of_DAND(draft_and_node)= predecessor;
Cause_OR_of_DAND(draft_and_node)= cause;
MARPA_ASSERT(cause!=NULL);
return draft_and_node;
}

/*:906*//*907:*/
#line 10722 "./marpa.w"

PRIVATE
void draft_and_node_add(struct marpa_obstack*obs,OR parent,OR predecessor,OR cause)
{
MARPA_OFF_ASSERT(Position_of_OR(parent)<=1||predecessor)
const DAND new= draft_and_node_new(obs,predecessor,cause);
Next_DAND_of_DAND(new)= DANDs_of_OR(parent);
DANDs_of_OR(parent)= new;
}

/*:907*//*915:*/
#line 10862 "./marpa.w"

PRIVATE
OR or_by_origin_and_symi(struct s_bocage_setup_per_ys*per_ys_data,
YSID origin,
SYMI symbol_instance)
{
const PSL or_psl_at_origin= per_ys_data[(origin)].t_or_psl;
return PSL_Datum(or_psl_at_origin,(symbol_instance));
}

/*:915*//*920:*/
#line 10921 "./marpa.w"

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

/*:920*//*921:*/
#line 10955 "./marpa.w"

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

/*:921*//*922:*/
#line 10970 "./marpa.w"

PRIVATE
OR set_or_from_yim(struct s_bocage_setup_per_ys*per_ys_data,
YIM psi_yim)
{
const YIM psi_earley_item= psi_yim;
const int psi_earley_set_ordinal= YS_Ord_of_YIM(psi_earley_item);
const int psi_item_ordinal= Ord_of_YIM(psi_earley_item);
return OR_by_PSI(per_ys_data,psi_earley_set_ordinal,psi_item_ordinal);
}

/*:922*//*925:*/
#line 11028 "./marpa.w"

PRIVATE
OR safe_or_from_yim(
struct s_bocage_setup_per_ys*per_ys_data,
YIM yim)
{
if(Position_of_AHM(AHM_of_YIM(yim))<1)return NULL;
return set_or_from_yim(per_ys_data,yim);
}

/*:925*//*943:*/
#line 11192 "./marpa.w"

int marpa_trv_soft_error(Marpa_Traverser trv)
{
return TRV_has_Soft_Error(trv);
}

/*:943*//*948:*/
#line 11213 "./marpa.w"

PRIVATE Marpa_Traverser
trv_new(RECCE r,YIM yim)
{
TRAVERSER trv;

trv= my_malloc(sizeof(*trv));
/*942:*/
#line 11190 "./marpa.w"

TRV_has_Soft_Error(trv)= 0;
/*:942*//*945:*/
#line 11201 "./marpa.w"

R_of_TRV(trv)= r;

/*:945*//*963:*/
#line 11538 "./marpa.w"

trv->t_ref_count= 1;
/*:963*/
#line 11220 "./marpa.w"

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

/*:948*//*949:*/
#line 11238 "./marpa.w"

Marpa_Traverser marpa_trv_new(Marpa_Recognizer r,
Marpa_Earley_Set_ID es_arg,
Marpa_Earley_Item_ID eim_arg
)
{
/*1317:*/
#line 15723 "./marpa.w"
void*const failure_indicator= NULL;
/*:1317*/
#line 11244 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 11246 "./marpa.w"


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

/*1335:*/
#line 15835 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1335*/
#line 11259 "./marpa.w"


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

/*:949*//*950:*/
#line 11308 "./marpa.w"

int marpa_trv_at_completion(Marpa_Traverser trv)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 11311 "./marpa.w"

/*946:*/
#line 11204 "./marpa.w"

const RECCE r UNUSED= R_of_TRV(trv);
const GRAMMAR g UNUSED= G_of_R(r);

/*:946*/
#line 11312 "./marpa.w"

SRCL srcl;
/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 11314 "./marpa.w"


if(G_is_Trivial(g))return 0;
srcl= COMPLETION_SRCL_of_TRV(trv);
return srcl?1:0;
}

/*:950*//*951:*/
#line 11322 "./marpa.w"

int marpa_trv_at_token(Marpa_Traverser trv)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 11325 "./marpa.w"

/*946:*/
#line 11204 "./marpa.w"

const RECCE r UNUSED= R_of_TRV(trv);
const GRAMMAR g UNUSED= G_of_R(r);

/*:946*/
#line 11326 "./marpa.w"

SRCL srcl;
/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 11328 "./marpa.w"


if(G_is_Trivial(g))return 0;
srcl= TOKEN_SRCL_of_TRV(trv);
return srcl?1:0;
}

/*:951*//*952:*/
#line 11336 "./marpa.w"

int marpa_trv_at_leo(Marpa_Traverser trv)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 11339 "./marpa.w"

/*946:*/
#line 11204 "./marpa.w"

const RECCE r UNUSED= R_of_TRV(trv);
const GRAMMAR g UNUSED= G_of_R(r);

/*:946*/
#line 11340 "./marpa.w"

SRCL srcl;
/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 11342 "./marpa.w"


if(G_is_Trivial(g))return 0;
srcl= LEO_SRCL_of_TRV(trv);
return srcl?1:0;
}

/*:952*//*953:*/
#line 11352 "./marpa.w"

Marpa_Traverser marpa_trv_completion_cause(Marpa_Traverser trv)
{
/*1317:*/
#line 15723 "./marpa.w"
void*const failure_indicator= NULL;
/*:1317*/
#line 11355 "./marpa.w"

/*946:*/
#line 11204 "./marpa.w"

const RECCE r UNUSED= R_of_TRV(trv);
const GRAMMAR g UNUSED= G_of_R(r);

/*:946*/
#line 11356 "./marpa.w"

SRCL srcl;
YIM cause;
/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 11359 "./marpa.w"

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

/*:953*//*954:*/
#line 11385 "./marpa.w"

Marpa_Traverser marpa_trv_completion_predecessor(Marpa_Traverser trv)
{
/*1317:*/
#line 15723 "./marpa.w"
void*const failure_indicator= NULL;
/*:1317*/
#line 11388 "./marpa.w"

/*946:*/
#line 11204 "./marpa.w"

const RECCE r UNUSED= R_of_TRV(trv);
const GRAMMAR g UNUSED= G_of_R(r);

/*:946*/
#line 11389 "./marpa.w"

SRCL srcl;
YIM predecessor;
/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 11392 "./marpa.w"

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

/*:954*//*955:*/
#line 11418 "./marpa.w"

Marpa_LTraverser marpa_trv_lim(Marpa_Traverser trv)
{
/*1317:*/
#line 15723 "./marpa.w"
void*const failure_indicator= NULL;
/*:1317*/
#line 11421 "./marpa.w"

/*946:*/
#line 11204 "./marpa.w"

const RECCE r UNUSED= R_of_TRV(trv);
const GRAMMAR g UNUSED= G_of_R(r);

/*:946*/
#line 11422 "./marpa.w"

SRCL srcl;
LIM predecessor;
/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 11425 "./marpa.w"

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

/*:955*//*956:*/
#line 11451 "./marpa.w"

Marpa_Traverser marpa_trv_token_predecessor(Marpa_Traverser trv)
{
/*1317:*/
#line 15723 "./marpa.w"
void*const failure_indicator= NULL;
/*:1317*/
#line 11454 "./marpa.w"

/*946:*/
#line 11204 "./marpa.w"

const RECCE r UNUSED= R_of_TRV(trv);
const GRAMMAR g UNUSED= G_of_R(r);

/*:946*/
#line 11455 "./marpa.w"

SRCL srcl;
YIM predecessor;
/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 11458 "./marpa.w"

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

/*:956*//*958:*/
#line 11482 "./marpa.w"

int marpa_trv_completion_next(Marpa_Traverser trv)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 11485 "./marpa.w"

/*946:*/
#line 11204 "./marpa.w"

const RECCE r UNUSED= R_of_TRV(trv);
const GRAMMAR g UNUSED= G_of_R(r);

/*:946*/
#line 11486 "./marpa.w"

SRCL srcl;
/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 11488 "./marpa.w"

if(G_is_Trivial(g)){
return 0;
}
srcl= COMPLETION_SRCL_of_TRV(trv);
if(!srcl)return 0;
srcl= COMPLETION_SRCL_of_TRV(trv)= Next_SRCL_of_SRCL(srcl);
if(!srcl)return 0;
return 1;
}

/*:958*//*959:*/
#line 11500 "./marpa.w"

int marpa_trv_leo_next(Marpa_Traverser trv)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 11503 "./marpa.w"

/*946:*/
#line 11204 "./marpa.w"

const RECCE r UNUSED= R_of_TRV(trv);
const GRAMMAR g UNUSED= G_of_R(r);

/*:946*/
#line 11504 "./marpa.w"

SRCL srcl;
/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 11506 "./marpa.w"

if(G_is_Trivial(g)){
return 0;
}
srcl= LEO_SRCL_of_TRV(trv);
if(!srcl)return 0;
srcl= LEO_SRCL_of_TRV(trv)= Next_SRCL_of_SRCL(srcl);
if(!srcl)return 0;
return 1;
}

/*:959*//*960:*/
#line 11518 "./marpa.w"

int marpa_trv_token_next(Marpa_Traverser trv)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 11521 "./marpa.w"

/*946:*/
#line 11204 "./marpa.w"

const RECCE r UNUSED= R_of_TRV(trv);
const GRAMMAR g UNUSED= G_of_R(r);

/*:946*/
#line 11522 "./marpa.w"

SRCL srcl;
/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 11524 "./marpa.w"

if(G_is_Trivial(g)){
return 0;
}
srcl= TOKEN_SRCL_of_TRV(trv);
if(!srcl)return 0;
srcl= TOKEN_SRCL_of_TRV(trv)= Next_SRCL_of_SRCL(srcl);
if(!srcl)return 0;
return 1;
}

/*:960*//*964:*/
#line 11541 "./marpa.w"

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

/*:964*//*965:*/
#line 11559 "./marpa.w"

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

/*:965*//*967:*/
#line 11577 "./marpa.w"

PRIVATE void
traverser_free(TRAVERSER trv)
{
/*946:*/
#line 11204 "./marpa.w"

const RECCE r UNUSED= R_of_TRV(trv);
const GRAMMAR g UNUSED= G_of_R(r);

/*:946*/
#line 11581 "./marpa.w"

if(trv)
{
/*939:*/
#line 11182 "./marpa.w"

{
recce_unref(R_of_TRV(trv));
}

/*:939*/
#line 11584 "./marpa.w"
;
}
my_free(trv);
}

/*:967*//*971:*/
#line 11599 "./marpa.w"

int marpa_trv_is_trivial(Marpa_Traverser trv)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 11602 "./marpa.w"

/*946:*/
#line 11204 "./marpa.w"

const RECCE r UNUSED= R_of_TRV(trv);
const GRAMMAR g UNUSED= G_of_R(r);

/*:946*/
#line 11603 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 11604 "./marpa.w"

return TRV_is_Trivial(trv);
}
/*:971*//*974:*/
#line 11616 "./marpa.w"

int marpa_trv_ahm_id(Marpa_Traverser trv)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 11619 "./marpa.w"

/*946:*/
#line 11204 "./marpa.w"

const RECCE r UNUSED= R_of_TRV(trv);
const GRAMMAR g UNUSED= G_of_R(r);

/*:946*/
#line 11620 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 11621 "./marpa.w"

/*972:*/
#line 11607 "./marpa.w"

if(TRV_is_Trivial(trv)){
MARPA_ERROR(MARPA_ERR_GRAMMAR_IS_TRIVIAL);
return failure_indicator;
}

/*:972*/
#line 11622 "./marpa.w"

{
const YIM yim= YIM_of_TRV(trv);
return AHMID_of_YIM(yim);
}
}

/*:974*//*975:*/
#line 11630 "./marpa.w"

Marpa_Rule_ID marpa_trv_rule_id(Marpa_Traverser trv)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 11633 "./marpa.w"

/*946:*/
#line 11204 "./marpa.w"

const RECCE r UNUSED= R_of_TRV(trv);
const GRAMMAR g UNUSED= G_of_R(r);

/*:946*/
#line 11634 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 11635 "./marpa.w"

/*972:*/
#line 11607 "./marpa.w"

if(TRV_is_Trivial(trv)){
MARPA_ERROR(MARPA_ERR_GRAMMAR_IS_TRIVIAL);
return failure_indicator;
}

/*:972*/
#line 11636 "./marpa.w"

{
const YIM yim= YIM_of_TRV(trv);
const AHM ahm= AHM_of_YIM(yim);
const IRL irl= IRL_of_AHM(ahm);
if(irl)return ID_of_IRL(irl);
}
return-1;
}

/*:975*//*976:*/
#line 11647 "./marpa.w"

int marpa_trv_dot(Marpa_Traverser trv)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 11650 "./marpa.w"

/*946:*/
#line 11204 "./marpa.w"

const RECCE r UNUSED= R_of_TRV(trv);
const GRAMMAR g UNUSED= G_of_R(r);

/*:946*/
#line 11651 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 11652 "./marpa.w"

/*972:*/
#line 11607 "./marpa.w"

if(TRV_is_Trivial(trv)){
MARPA_ERROR(MARPA_ERR_GRAMMAR_IS_TRIVIAL);
return failure_indicator;
}

/*:972*/
#line 11653 "./marpa.w"

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

/*:976*//*977:*/
#line 11667 "./marpa.w"

int marpa_trv_current(Marpa_Traverser trv)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 11670 "./marpa.w"

/*946:*/
#line 11204 "./marpa.w"

const RECCE r UNUSED= R_of_TRV(trv);
const GRAMMAR g UNUSED= G_of_R(r);

/*:946*/
#line 11671 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 11672 "./marpa.w"

/*972:*/
#line 11607 "./marpa.w"

if(TRV_is_Trivial(trv)){
MARPA_ERROR(MARPA_ERR_GRAMMAR_IS_TRIVIAL);
return failure_indicator;
}

/*:972*/
#line 11673 "./marpa.w"

{
const YIM yim= YIM_of_TRV(trv);
return YS_Ord_of_YIM(yim);
}
}

/*:977*//*978:*/
#line 11681 "./marpa.w"

int marpa_trv_origin(Marpa_Traverser trv)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 11684 "./marpa.w"

/*946:*/
#line 11204 "./marpa.w"

const RECCE r UNUSED= R_of_TRV(trv);
const GRAMMAR g UNUSED= G_of_R(r);

/*:946*/
#line 11685 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 11686 "./marpa.w"

/*972:*/
#line 11607 "./marpa.w"

if(TRV_is_Trivial(trv)){
MARPA_ERROR(MARPA_ERR_GRAMMAR_IS_TRIVIAL);
return failure_indicator;
}

/*:972*/
#line 11687 "./marpa.w"

{
const YIM yim= YIM_of_TRV(trv);
return Origin_Ord_of_YIM(yim);
}
}

/*:978*//*979:*/
#line 11695 "./marpa.w"

Marpa_NRL_ID marpa_trv_nrl_id(Marpa_Traverser trv)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 11698 "./marpa.w"

/*946:*/
#line 11204 "./marpa.w"

const RECCE r UNUSED= R_of_TRV(trv);
const GRAMMAR g UNUSED= G_of_R(r);

/*:946*/
#line 11699 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 11700 "./marpa.w"

/*972:*/
#line 11607 "./marpa.w"

if(TRV_is_Trivial(trv)){
MARPA_ERROR(MARPA_ERR_GRAMMAR_IS_TRIVIAL);
return failure_indicator;
}

/*:972*/
#line 11701 "./marpa.w"

{
const YIM yim= YIM_of_TRV(trv);
const AHM ahm= AHM_of_YIM(yim);
const NRL nrl= NRL_of_AHM(ahm);
if(nrl)return ID_of_NRL(nrl);
}
return-1;
}

/*:979*//*980:*/
#line 11712 "./marpa.w"

int marpa_trv_nrl_dot(Marpa_Traverser trv)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 11715 "./marpa.w"

/*946:*/
#line 11204 "./marpa.w"

const RECCE r UNUSED= R_of_TRV(trv);
const GRAMMAR g UNUSED= G_of_R(r);

/*:946*/
#line 11716 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 11717 "./marpa.w"

/*972:*/
#line 11607 "./marpa.w"

if(TRV_is_Trivial(trv)){
MARPA_ERROR(MARPA_ERR_GRAMMAR_IS_TRIVIAL);
return failure_indicator;
}

/*:972*/
#line 11718 "./marpa.w"

{
const YIM yim= YIM_of_TRV(trv);
const AHM ahm= AHM_of_YIM(yim);
return Position_of_AHM(ahm);
}
}

/*:980*//*990:*/
#line 11762 "./marpa.w"

int marpa_ltrv_soft_error(Marpa_LTraverser ltrv)
{
return LTRV_has_Soft_Error(ltrv);
}

/*:990*//*995:*/
#line 11780 "./marpa.w"

PRIVATE Marpa_LTraverser
ltrv_new(RECCE r,LIM lim)
{
LTRAVERSER ltrv;

ltrv= my_malloc(sizeof(*ltrv));
/*989:*/
#line 11760 "./marpa.w"

LTRV_has_Soft_Error(ltrv)= 0;
/*:989*//*992:*/
#line 11771 "./marpa.w"

R_of_LTRV(ltrv)= r;

/*:992*//*1002:*/
#line 11840 "./marpa.w"

ltrv->t_ref_count= 1;
/*:1002*/
#line 11787 "./marpa.w"

recce_ref(r);
LIM_of_LTRV(ltrv)= lim;
return ltrv;
}

/*:995*//*996:*/
#line 11794 "./marpa.w"

Marpa_LTraverser marpa_ltrv_predecessor(Marpa_LTraverser ltrv)
{
/*1317:*/
#line 15723 "./marpa.w"
void*const failure_indicator= NULL;
/*:1317*/
#line 11797 "./marpa.w"

/*993:*/
#line 11774 "./marpa.w"

const RECCE r UNUSED= R_of_LTRV(ltrv);
const GRAMMAR g UNUSED= G_of_R(r);

/*:993*/
#line 11798 "./marpa.w"

LIM predecessor;
/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 11800 "./marpa.w"

LTRV_has_Soft_Error(ltrv)= 0;
predecessor= Predecessor_LIM_of_LIM(LIM_of_LTRV(ltrv));
if(!predecessor){
LTRV_has_Soft_Error(ltrv)= 1;
return NULL;
}
return ltrv_new(r,predecessor);
}

/*:996*//*998:*/
#line 11812 "./marpa.w"

Marpa_Rule_ID
marpa_ltrv_trailhead_eim(Marpa_LTraverser ltrv,int*p_dot,Marpa_Earley_Set_ID*p_origin)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 11816 "./marpa.w"

/*993:*/
#line 11774 "./marpa.w"

const RECCE r UNUSED= R_of_LTRV(ltrv);
const GRAMMAR g UNUSED= G_of_R(r);

/*:993*/
#line 11817 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 11818 "./marpa.w"

{
const LIM lim= LIM_of_LTRV(ltrv);
const AHM ahm= Trailhead_AHM_of_LIM(lim);
const YIM yim= Trailhead_YIM_of_LIM(lim);
const IRL irl= IRL_of_AHM(ahm);
if(irl){
if(p_dot)
*p_dot= IRL_Position_of_AHM(ahm);
if(p_origin)
*p_origin= Origin_Ord_of_YIM(yim);
return ID_of_IRL(irl);
}
}
return-1;
}

/*:998*//*1003:*/
#line 11843 "./marpa.w"

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

/*:1003*//*1004:*/
#line 11861 "./marpa.w"

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

/*:1004*//*1006:*/
#line 11878 "./marpa.w"

PRIVATE void
ltraverser_free(LTRAVERSER ltrv)
{
/*993:*/
#line 11774 "./marpa.w"

const RECCE r UNUSED= R_of_LTRV(ltrv);
const GRAMMAR g UNUSED= G_of_R(r);

/*:993*/
#line 11882 "./marpa.w"

if(ltrv)
{
/*986:*/
#line 11752 "./marpa.w"

{
recce_unref(R_of_LTRV(ltrv));
}

/*:986*/
#line 11885 "./marpa.w"
;
}
my_free(ltrv);
}

/*:1006*//*1016:*/
#line 11929 "./marpa.w"

int marpa_ptrv_soft_error(Marpa_PTraverser ptrv)
{
return PTRV_has_Soft_Error(ptrv);
}

/*:1016*//*1021:*/
#line 11950 "./marpa.w"

PRIVATE Marpa_PTraverser
ptrv_new(RECCE r,YS ys,NSYID nsyid)
{
PTRAVERSER ptrv;
const PIM pim= First_PIM_of_YS_by_NSYID(ys,nsyid);

if(!pim)return NULL;
ptrv= my_malloc(sizeof(*ptrv));
/*1015:*/
#line 11927 "./marpa.w"

PTRV_has_Soft_Error(ptrv)= 0;
/*:1015*//*1018:*/
#line 11938 "./marpa.w"

R_of_PTRV(ptrv)= r;

/*:1018*//*1029:*/
#line 12094 "./marpa.w"

ptrv->t_ref_count= 1;
/*:1029*/
#line 11959 "./marpa.w"

recce_ref(r);
PIM_of_PTRV(ptrv)= pim;
PTRV_is_Trivial(ptrv)= 0;
YS_of_PTRV(ptrv)= ys;
return ptrv;
}

/*:1021*//*1022:*/
#line 11971 "./marpa.w"

Marpa_PTraverser marpa_ptrv_new(Marpa_Recognizer r,
Marpa_Earley_Set_ID es_arg,
Marpa_NSY_ID nsyid
)
{
/*1317:*/
#line 15723 "./marpa.w"
void*const failure_indicator= NULL;
/*:1317*/
#line 11977 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 11979 "./marpa.w"


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

/*1335:*/
#line 15835 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1335*/
#line 11992 "./marpa.w"


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

/*:1022*//*1023:*/
#line 12026 "./marpa.w"

int marpa_ptrv_at_lim(Marpa_PTraverser ptrv)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 12029 "./marpa.w"

/*1019:*/
#line 11941 "./marpa.w"

const RECCE r UNUSED= R_of_PTRV(ptrv);
const GRAMMAR g UNUSED= G_of_R(r);

/*:1019*/
#line 12030 "./marpa.w"

PIM pim;
/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 12032 "./marpa.w"


if(G_is_Trivial(g))return 0;
pim= PIM_of_PTRV(ptrv);
if(!pim)return 0;
return PIM_is_LIM(pim);
}

/*:1023*//*1024:*/
#line 12041 "./marpa.w"

int marpa_ptrv_at_eim(Marpa_PTraverser ptrv)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 12044 "./marpa.w"

/*1019:*/
#line 11941 "./marpa.w"

const RECCE r UNUSED= R_of_PTRV(ptrv);
const GRAMMAR g UNUSED= G_of_R(r);

/*:1019*/
#line 12045 "./marpa.w"

PIM pim;
/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 12047 "./marpa.w"


if(G_is_Trivial(g))return 0;
pim= PIM_of_PTRV(ptrv);
if(!pim)return 0;
return!PIM_is_LIM(pim);
}

/*:1024*//*1026:*/
#line 12060 "./marpa.w"

Marpa_Traverser marpa_ptrv_eim_iter(Marpa_PTraverser ptrv)
{
/*1317:*/
#line 15723 "./marpa.w"
void*const failure_indicator= NULL;
/*:1317*/
#line 12063 "./marpa.w"

/*1019:*/
#line 11941 "./marpa.w"

const RECCE r UNUSED= R_of_PTRV(ptrv);
const GRAMMAR g UNUSED= G_of_R(r);

/*:1019*/
#line 12064 "./marpa.w"

PIM pim;
YIM yim;
/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 12067 "./marpa.w"

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

/*:1026*//*1030:*/
#line 12097 "./marpa.w"

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

/*:1030*//*1031:*/
#line 12115 "./marpa.w"

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

/*:1031*//*1033:*/
#line 12133 "./marpa.w"

PRIVATE void
ptraverser_free(PTRAVERSER ptrv)
{
/*1019:*/
#line 11941 "./marpa.w"

const RECCE r UNUSED= R_of_PTRV(ptrv);
const GRAMMAR g UNUSED= G_of_R(r);

/*:1019*/
#line 12137 "./marpa.w"

if(ptrv)
{
/*1012:*/
#line 11919 "./marpa.w"

{
recce_unref(R_of_PTRV(ptrv));
}

/*:1012*/
#line 12140 "./marpa.w"
;
}
my_free(ptrv);
}

/*:1033*//*1037:*/
#line 12155 "./marpa.w"

int marpa_ptrv_is_trivial(Marpa_PTraverser ptrv)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 12158 "./marpa.w"

/*1019:*/
#line 11941 "./marpa.w"

const RECCE r UNUSED= R_of_PTRV(ptrv);
const GRAMMAR g UNUSED= G_of_R(r);

/*:1019*/
#line 12159 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 12160 "./marpa.w"

return PTRV_is_Trivial(ptrv);
}








/*:1037*//*1052:*/
#line 12247 "./marpa.w"

Marpa_Bocage marpa_b_new(Marpa_Recognizer r,
Marpa_Earley_Set_ID ordinal_arg)
{
/*1317:*/
#line 15723 "./marpa.w"
void*const failure_indicator= NULL;
/*:1317*/
#line 12251 "./marpa.w"

/*1055:*/
#line 12318 "./marpa.w"

const GRAMMAR g= G_of_R(r);
const int isy_count= ISY_Count_of_G(g);
BOCAGE b= NULL;
YS end_of_parse_earley_set;
JEARLEME end_of_parse_earleme;
YIM start_yim= NULL;
struct marpa_obstack*bocage_setup_obs= NULL;
int count_of_earley_items_in_parse;
const int earley_set_count_of_r= YS_Count_of_R(r);

/*:1055*//*1058:*/
#line 12341 "./marpa.w"

struct s_bocage_setup_per_ys*per_ys_data= NULL;

/*:1058*/
#line 12252 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 12253 "./marpa.w"

if(_MARPA_UNLIKELY(ordinal_arg<=-2))
{
MARPA_ERROR(MARPA_ERR_INVALID_LOCATION);
return failure_indicator;
}

/*1335:*/
#line 15835 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1335*/
#line 12260 "./marpa.w"

{
struct marpa_obstack*const obstack= marpa_obs_init;
b= marpa_obs_new(obstack,struct marpa_bocage,1);
OBS_of_B(b)= obstack;
}
/*1044:*/
#line 12204 "./marpa.w"

ORs_of_B(b)= NULL;
OR_Count_of_B(b)= 0;
ANDs_of_B(b)= NULL;
AND_Count_of_B(b)= 0;
Top_ORID_of_B(b)= -1;

/*:1044*//*1047:*/
#line 12227 "./marpa.w"

{
G_of_B(b)= G_of_R(r);
grammar_ref(g);
}

/*:1047*//*1054:*/
#line 12313 "./marpa.w"

Valued_BV_of_B(b)= lbv_clone(b->t_obs,r->t_valued,isy_count);
Valued_Locked_BV_of_B(b)= 
lbv_clone(b->t_obs,r->t_valued_locked,isy_count);

/*:1054*//*1068:*/
#line 12458 "./marpa.w"

Ambiguity_Metric_of_B(b)= 1;

/*:1068*//*1072:*/
#line 12472 "./marpa.w"

b->t_ref_count= 1;
/*:1072*//*1079:*/
#line 12530 "./marpa.w"

B_is_Nulling(b)= 0;
/*:1079*/
#line 12266 "./marpa.w"


if(G_is_Trivial(g)){
switch(ordinal_arg){
default:goto NO_PARSE;
case 0:case-1:break;
}
B_is_Nulling(b)= 1;
return b;
}
r_update_earley_sets(r);
/*1059:*/
#line 12344 "./marpa.w"

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

/*:1059*/
#line 12277 "./marpa.w"

if(end_of_parse_earleme==0)
{
if(!ISY_is_Nullable(ISY_by_ID(g->t_start_isy_id)))
goto NO_PARSE;
B_is_Nulling(b)= 1;
return b;
}
/*1062:*/
#line 12410 "./marpa.w"

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

/*:1062*/
#line 12285 "./marpa.w"

if(!start_yim)goto NO_PARSE;
bocage_setup_obs= marpa_obs_init;
/*1060:*/
#line 12366 "./marpa.w"

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

/*:1060*/
#line 12288 "./marpa.w"

/*873:*/
#line 10176 "./marpa.w"

{
UR_Const ur_node;
const URS ur_node_stack= URS_of_R(r);
ur_node_stack_reset(ur_node_stack);


push_ur_if_new(per_ys_data,ur_node_stack,start_yim);
while((ur_node= ur_node_pop(ur_node_stack)))
{

const YIM parent_earley_item= YIM_of_UR(ur_node);
MARPA_ASSERT(!YIM_was_Predicted(parent_earley_item))
/*876:*/
#line 10229 "./marpa.w"

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

/*:876*/
#line 10189 "./marpa.w"

/*878:*/
#line 10263 "./marpa.w"

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

/*:878*/
#line 10190 "./marpa.w"

/*879:*/
#line 10286 "./marpa.w"

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

/*:879*/
#line 10191 "./marpa.w"

}
}

/*:873*/
#line 12289 "./marpa.w"

/*891:*/
#line 10413 "./marpa.w"

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
/*892:*/
#line 10439 "./marpa.w"

{
int item_ordinal;
for(item_ordinal= 0;item_ordinal<item_count;
item_ordinal++)
{
if(OR_by_PSI(per_ys_data,work_earley_set_ordinal,item_ordinal))
{
const YIM work_earley_item= yims_of_ys[item_ordinal];
{
/*893:*/
#line 10455 "./marpa.w"

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
/*895:*/
#line 10489 "./marpa.w"

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

/*:895*/
#line 10468 "./marpa.w"

/*898:*/
#line 10537 "./marpa.w"

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

/*:898*/
#line 10469 "./marpa.w"

}



MARPA_OFF_ASSERT(psi_or_node)




OR_by_PSI(per_ys_data,working_ys_ordinal,working_yim_ordinal)
= psi_or_node;
/*899:*/
#line 10572 "./marpa.w"

{
SRCL source_link;
for(source_link= First_Leo_SRCL_of_YIM(work_earley_item);
source_link;source_link= Next_SRCL_of_SRCL(source_link))
{
LIM leo_predecessor= LIM_of_SRCL(source_link);
if(leo_predecessor){
/*900:*/
#line 10589 "./marpa.w"

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
/*901:*/
#line 10611 "./marpa.w"

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

/*:901*/
#line 10601 "./marpa.w"

/*902:*/
#line 10636 "./marpa.w"

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

/*:902*/
#line 10602 "./marpa.w"

}
previous_leo_item= this_leo_item;
}
}

/*:900*/
#line 10580 "./marpa.w"

}
}
}

/*:899*/
#line 10481 "./marpa.w"

}

/*:893*/
#line 10449 "./marpa.w"

}
}
}
}

/*:892*/
#line 10432 "./marpa.w"

/*908:*/
#line 10732 "./marpa.w"

{
int item_ordinal;
for(item_ordinal= 0;item_ordinal<item_count;item_ordinal++)
{
OR or_node= OR_by_PSI(per_ys_data,work_earley_set_ordinal,item_ordinal);
const YIM work_earley_item= yims_of_ys[item_ordinal];
const int work_origin_ordinal= Ord_of_YS(Origin_of_YIM(work_earley_item));
/*909:*/
#line 10749 "./marpa.w"

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

/*:909*/
#line 10740 "./marpa.w"

if(or_node){
/*910:*/
#line 10763 "./marpa.w"

{
const AHM work_ahm= AHM_of_YIM(work_earley_item);
MARPA_ASSERT(work_ahm>=AHM_by_ID(1))
const int work_symbol_instance= SYMI_of_AHM(work_ahm);
const OR work_proper_or_node= or_by_origin_and_symi(per_ys_data,
work_origin_ordinal,work_symbol_instance);
/*912:*/
#line 10805 "./marpa.w"

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
/*913:*/
#line 10826 "./marpa.w"

{

NRL path_nrl= NULL;

NRL previous_path_nrl;
LIM path_leo_item= leo_predecessor;
LIM higher_path_leo_item= Predecessor_LIM_of_LIM(path_leo_item);
OR dand_predecessor;
OR path_or_node;
YIM base_earley_item= Trailhead_YIM_of_LIM(path_leo_item);
dand_predecessor= set_or_from_yim(per_ys_data,base_earley_item);
/*914:*/
#line 10853 "./marpa.w"

{
if(higher_path_leo_item){
/*923:*/
#line 10981 "./marpa.w"

{
int symbol_instance;
const int origin_ordinal= Origin_Ord_of_YIM(base_earley_item);
const AHM ahm= AHM_of_YIM(base_earley_item);
path_nrl= NRL_of_AHM(ahm);
symbol_instance= Last_Proper_SYMI_of_NRL(path_nrl);
path_or_node= or_by_origin_and_symi(per_ys_data,origin_ordinal,symbol_instance);
}


/*:923*/
#line 10856 "./marpa.w"

}else{
path_or_node= work_proper_or_node;
}
}

/*:914*/
#line 10838 "./marpa.w"

/*916:*/
#line 10872 "./marpa.w"

{
const OR dand_cause
= set_or_from_yim(per_ys_data,cause_earley_item);
if(!dand_is_duplicate(path_or_node,dand_predecessor,dand_cause)){
draft_and_node_add(bocage_setup_obs,path_or_node,
dand_predecessor,dand_cause);
}
}

/*:916*/
#line 10839 "./marpa.w"

previous_path_nrl= path_nrl;
while(higher_path_leo_item){
path_leo_item= higher_path_leo_item;
higher_path_leo_item= Predecessor_LIM_of_LIM(path_leo_item);
base_earley_item= Trailhead_YIM_of_LIM(path_leo_item);
dand_predecessor
= set_or_from_yim(per_ys_data,base_earley_item);
/*914:*/
#line 10853 "./marpa.w"

{
if(higher_path_leo_item){
/*923:*/
#line 10981 "./marpa.w"

{
int symbol_instance;
const int origin_ordinal= Origin_Ord_of_YIM(base_earley_item);
const AHM ahm= AHM_of_YIM(base_earley_item);
path_nrl= NRL_of_AHM(ahm);
symbol_instance= Last_Proper_SYMI_of_NRL(path_nrl);
path_or_node= or_by_origin_and_symi(per_ys_data,origin_ordinal,symbol_instance);
}


/*:923*/
#line 10856 "./marpa.w"

}else{
path_or_node= work_proper_or_node;
}
}

/*:914*/
#line 10847 "./marpa.w"

/*919:*/
#line 10898 "./marpa.w"

{
const SYMI symbol_instance= SYMI_of_Completed_NRL(previous_path_nrl);
const int origin= Ord_of_YS(YS_of_LIM(path_leo_item));
const OR dand_cause= or_by_origin_and_symi(per_ys_data,origin,symbol_instance);
if(!dand_is_duplicate(path_or_node,dand_predecessor,dand_cause)){
draft_and_node_add(bocage_setup_obs,path_or_node,
dand_predecessor,dand_cause);
}
}

/*:919*/
#line 10848 "./marpa.w"

previous_path_nrl= path_nrl;
}
}

/*:913*/
#line 10820 "./marpa.w"

}
}
}

/*:912*/
#line 10770 "./marpa.w"

/*924:*/
#line 10996 "./marpa.w"

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

/*:924*/
#line 10771 "./marpa.w"

/*926:*/
#line 11038 "./marpa.w"

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

/*:926*/
#line 10772 "./marpa.w"

}

/*:910*/
#line 10742 "./marpa.w"

}
}
}

/*:908*/
#line 10433 "./marpa.w"

}
psar_destroy(or_psar);
ORs_of_B(b)= marpa_renew(OR,ORs_of_B(b),OR_Count_of_B(b));
}

/*:891*/
#line 12290 "./marpa.w"

/*932:*/
#line 11110 "./marpa.w"

{
int unique_draft_and_node_count= 0;
/*927:*/
#line 11063 "./marpa.w"

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

/*:927*/
#line 11113 "./marpa.w"

/*933:*/
#line 11117 "./marpa.w"

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

/*:933*/
#line 11114 "./marpa.w"

}

/*:932*/
#line 12291 "./marpa.w"

/*1063:*/
#line 12431 "./marpa.w"

{
const YSID end_of_parse_ordinal= Ord_of_YS(end_of_parse_earley_set);
const int start_earley_item_ordinal= Ord_of_YIM(start_yim);
const OR root_or_node= 
OR_by_PSI(per_ys_data,end_of_parse_ordinal,start_earley_item_ordinal);
Top_ORID_of_B(b)= ID_of_OR(root_or_node);
}

/*:1063*/
#line 12292 "./marpa.w"
;
marpa_obs_free(bocage_setup_obs);
return b;
NO_PARSE:;
MARPA_ERROR(MARPA_ERR_NO_PARSE);
if(b){
/*1075:*/
#line 12508 "./marpa.w"

/*1045:*/
#line 12211 "./marpa.w"

{
OR*or_nodes= ORs_of_B(b);
AND and_nodes= ANDs_of_B(b);

grammar_unref(G_of_B(b));
my_free(or_nodes);
ORs_of_B(b)= NULL;
my_free(and_nodes);
ANDs_of_B(b)= NULL;
}

/*:1045*/
#line 12509 "./marpa.w"
;
/*1051:*/
#line 12243 "./marpa.w"

marpa_obs_free(OBS_of_B(b));

/*:1051*/
#line 12510 "./marpa.w"
;

/*:1075*/
#line 12298 "./marpa.w"
;
}
return NULL;
}

/*:1052*//*1065:*/
#line 12442 "./marpa.w"

Marpa_Or_Node_ID _marpa_b_top_or_node(Marpa_Bocage b)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 12445 "./marpa.w"

/*1049:*/
#line 12235 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1049*/
#line 12446 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 12447 "./marpa.w"

return Top_ORID_of_B(b);
}

/*:1065*//*1069:*/
#line 12461 "./marpa.w"

int marpa_b_ambiguity_metric(Marpa_Bocage b)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 12464 "./marpa.w"

/*1049:*/
#line 12235 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1049*/
#line 12465 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 12466 "./marpa.w"

return Ambiguity_Metric_of_B(b);
}

/*:1069*//*1073:*/
#line 12475 "./marpa.w"

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

/*:1073*//*1074:*/
#line 12493 "./marpa.w"

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

/*:1074*//*1076:*/
#line 12514 "./marpa.w"

PRIVATE void
bocage_free(BOCAGE b)
{
/*1049:*/
#line 12235 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1049*/
#line 12518 "./marpa.w"

if(b)
{
/*1075:*/
#line 12508 "./marpa.w"

/*1045:*/
#line 12211 "./marpa.w"

{
OR*or_nodes= ORs_of_B(b);
AND and_nodes= ANDs_of_B(b);

grammar_unref(G_of_B(b));
my_free(or_nodes);
ORs_of_B(b)= NULL;
my_free(and_nodes);
ANDs_of_B(b)= NULL;
}

/*:1045*/
#line 12509 "./marpa.w"
;
/*1051:*/
#line 12243 "./marpa.w"

marpa_obs_free(OBS_of_B(b));

/*:1051*/
#line 12510 "./marpa.w"
;

/*:1075*/
#line 12521 "./marpa.w"
;
}
}

/*:1076*//*1080:*/
#line 12532 "./marpa.w"

int marpa_b_is_null(Marpa_Bocage b)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 12535 "./marpa.w"

/*1049:*/
#line 12235 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1049*/
#line 12536 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 12537 "./marpa.w"

return B_is_Nulling(b);
}

/*:1080*//*1087:*/
#line 12577 "./marpa.w"

Marpa_Order marpa_o_new(Marpa_Bocage b)
{
/*1317:*/
#line 15723 "./marpa.w"
void*const failure_indicator= NULL;
/*:1317*/
#line 12580 "./marpa.w"

/*1049:*/
#line 12235 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1049*/
#line 12581 "./marpa.w"

ORDER o;
/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 12583 "./marpa.w"

o= my_malloc(sizeof(*o));
B_of_O(o)= b;
bocage_ref(b);
/*1084:*/
#line 12565 "./marpa.w"

{
o->t_and_node_orderings= NULL;
o->t_is_frozen= 0;
OBS_of_O(o)= NULL;
}

/*:1084*//*1090:*/
#line 12595 "./marpa.w"

o->t_ref_count= 1;

/*:1090*//*1103:*/
#line 12763 "./marpa.w"

High_Rank_Count_of_O(o)= 1;
/*:1103*/
#line 12587 "./marpa.w"

O_is_Nulling(o)= B_is_Nulling(b);
Ambiguity_Metric_of_O(o)= -1;
return o;
}

/*:1087*//*1091:*/
#line 12599 "./marpa.w"

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

/*:1091*//*1092:*/
#line 12617 "./marpa.w"

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

/*:1092*//*1093:*/
#line 12631 "./marpa.w"

PRIVATE void order_free(ORDER o)
{
/*1094:*/
#line 12640 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1049:*/
#line 12235 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1049*/
#line 12642 "./marpa.w"


/*:1094*/
#line 12634 "./marpa.w"

bocage_unref(b);
marpa_obs_free(OBS_of_O(o));
my_free(o);
}

/*:1093*//*1097:*/
#line 12652 "./marpa.w"

int marpa_o_ambiguity_metric(Marpa_Order o)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 12655 "./marpa.w"

/*1094:*/
#line 12640 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1049:*/
#line 12235 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1049*/
#line 12642 "./marpa.w"


/*:1094*/
#line 12656 "./marpa.w"

const int old_ambiguity_metric_of_o
= Ambiguity_Metric_of_O(o);
const int ambiguity_metric_of_b
= (Ambiguity_Metric_of_B(b)<=1?1:2);
/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 12661 "./marpa.w"

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
/*1098:*/
#line 12680 "./marpa.w"

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

/*:1098*/
#line 12672 "./marpa.w"

return Ambiguity_Metric_of_O(o);
}

/*:1097*//*1101:*/
#line 12746 "./marpa.w"

int marpa_o_is_null(Marpa_Order o)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 12749 "./marpa.w"

/*1094:*/
#line 12640 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1049:*/
#line 12235 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1049*/
#line 12642 "./marpa.w"


/*:1094*/
#line 12750 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 12751 "./marpa.w"

return O_is_Nulling(o);
}

/*:1101*//*1104:*/
#line 12765 "./marpa.w"

int marpa_o_high_rank_only_set(
Marpa_Order o,
int count)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 12770 "./marpa.w"

/*1094:*/
#line 12640 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1049:*/
#line 12235 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1049*/
#line 12642 "./marpa.w"


/*:1094*/
#line 12771 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 12772 "./marpa.w"

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

/*:1104*//*1105:*/
#line 12787 "./marpa.w"

int marpa_o_high_rank_only(Marpa_Order o)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 12790 "./marpa.w"

/*1094:*/
#line 12640 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1049:*/
#line 12235 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1049*/
#line 12642 "./marpa.w"


/*:1094*/
#line 12791 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 12792 "./marpa.w"

return High_Rank_Count_of_O(o);
}

/*:1105*//*1109:*/
#line 12829 "./marpa.w"

int marpa_o_rank(Marpa_Order o)
{
ANDID**and_node_orderings;
struct marpa_obstack*obs;
int bocage_was_reordered= 0;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 12835 "./marpa.w"

/*1094:*/
#line 12640 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1049:*/
#line 12235 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1049*/
#line 12642 "./marpa.w"


/*:1094*/
#line 12836 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 12837 "./marpa.w"

if(O_is_Frozen(o))
{
MARPA_ERROR(MARPA_ERR_ORDER_FROZEN);
return failure_indicator;
}
/*1115:*/
#line 12998 "./marpa.w"

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

/*:1115*/
#line 12843 "./marpa.w"

if(High_Rank_Count_of_O(o)){
/*1110:*/
#line 12858 "./marpa.w"

{
const AND and_nodes= ANDs_of_B(b);
const int or_node_count_of_b= OR_Count_of_B(b);
int or_node_id= 0;

while(or_node_id<or_node_count_of_b)
{
const OR work_or_node= OR_of_B_by_ID(b,or_node_id);
const ANDID and_count_of_or= AND_Count_of_OR(work_or_node);
/*1111:*/
#line 12873 "./marpa.w"

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
/*1112:*/
#line 12911 "./marpa.w"

{
const OR cause_or= Cause_OR_of_AND(and_node);
if(OR_is_Token(cause_or)){
const NSYID nsy_id= NSYID_of_OR(cause_or);
and_node_rank= Rank_of_NSY(NSY_by_ID(nsy_id));
}else{
and_node_rank= Rank_of_NRL(NRL_of_OR(cause_or));
}
}

/*:1112*/
#line 12893 "./marpa.w"

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

/*:1111*/
#line 12868 "./marpa.w"

or_node_id++;
}
}

/*:1110*/
#line 12845 "./marpa.w"

}else{
/*1113:*/
#line 12922 "./marpa.w"

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
/*1112:*/
#line 12911 "./marpa.w"

{
const OR cause_or= Cause_OR_of_AND(and_node);
if(OR_is_Token(cause_or)){
const NSYID nsy_id= NSYID_of_OR(cause_or);
and_node_rank= Rank_of_NSY(NSY_by_ID(nsy_id));
}else{
and_node_rank= Rank_of_NRL(NRL_of_OR(cause_or));
}
}

/*:1112*/
#line 12934 "./marpa.w"

rank_by_and_id[and_node_id]= and_node_rank;
}
while(or_node_id<or_node_count_of_b)
{
const OR work_or_node= OR_of_B_by_ID(b,or_node_id);
const ANDID and_count_of_or= AND_Count_of_OR(work_or_node);
/*1114:*/
#line 12967 "./marpa.w"

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

/*:1114*/
#line 12941 "./marpa.w"

or_node_id++;
}
my_free(rank_by_and_id);
}

/*:1113*/
#line 12847 "./marpa.w"

}
if(!bocage_was_reordered){
marpa_obs_free(obs);
OBS_of_O(o)= NULL;
o->t_and_node_orderings= NULL;
}
O_is_Frozen(o)= 1;
return 1;
}

/*:1109*//*1116:*/
#line 13015 "./marpa.w"

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

/*:1116*//*1117:*/
#line 13036 "./marpa.w"

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

/*:1117*//*1118:*/
#line 13050 "./marpa.w"

Marpa_And_Node_ID _marpa_o_and_order_get(Marpa_Order o,
Marpa_Or_Node_ID or_node_id,int ix)
{
OR or_node;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 13055 "./marpa.w"

/*1094:*/
#line 12640 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1049:*/
#line 12235 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1049*/
#line 12642 "./marpa.w"


/*:1094*/
#line 13056 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 13057 "./marpa.w"

/*1405:*/
#line 16829 "./marpa.w"

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
/*:1405*/
#line 13058 "./marpa.w"

/*1406:*/
#line 16841 "./marpa.w"

{
if(_MARPA_UNLIKELY(!ORs_of_B(b)))
{
MARPA_ERROR(MARPA_ERR_NO_OR_NODES);
return failure_indicator;
}
or_node= OR_of_B_by_ID(b,or_node_id);
}

/*:1406*/
#line 13059 "./marpa.w"

if(ix<0){
MARPA_ERROR(MARPA_ERR_ANDIX_NEGATIVE);
return failure_indicator;
}
if(!and_order_ix_is_valid(o,or_node,ix))return-1;
return and_order_get(o,or_node,ix);
}

/*:1118*//*1123:*/
#line 13112 "./marpa.w"

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

/*:1123*//*1124:*/
#line 13130 "./marpa.w"

Marpa_Tree marpa_t_new(Marpa_Order o)
{
/*1317:*/
#line 15723 "./marpa.w"
void*const failure_indicator= NULL;
/*:1317*/
#line 13133 "./marpa.w"

TREE t;
/*1094:*/
#line 12640 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1049:*/
#line 12235 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1049*/
#line 12642 "./marpa.w"


/*:1094*/
#line 13135 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 13136 "./marpa.w"

t= my_malloc(sizeof(*t));
O_of_T(t)= o;
order_ref(o);
O_is_Frozen(o)= 1;
/*1137:*/
#line 13283 "./marpa.w"

T_is_Exhausted(t)= 0;

/*:1137*/
#line 13141 "./marpa.w"

/*1125:*/
#line 13146 "./marpa.w"

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

/*:1125*//*1128:*/
#line 13170 "./marpa.w"

t->t_ref_count= 1;

/*:1128*//*1133:*/
#line 13222 "./marpa.w"
t->t_generation= 0;

/*:1133*/
#line 13142 "./marpa.w"

return t;
}

/*:1124*//*1129:*/
#line 13174 "./marpa.w"

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

/*:1129*//*1130:*/
#line 13192 "./marpa.w"

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

/*:1130*//*1131:*/
#line 13206 "./marpa.w"

PRIVATE void tree_free(TREE t)
{
order_unref(O_of_T(t));
tree_exhaust(t);
my_free(t);
}

/*:1131*//*1134:*/
#line 13225 "./marpa.w"

int marpa_t_next(Marpa_Tree t)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 13228 "./marpa.w"

const int termination_indicator= -1;
int is_first_tree_attempt= (t->t_parse_count<1);
/*1122:*/
#line 13108 "./marpa.w"

ORDER o= O_of_T(t);
/*1094:*/
#line 12640 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1049:*/
#line 12235 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1049*/
#line 12642 "./marpa.w"


/*:1094*/
#line 13110 "./marpa.w"
;

/*:1122*/
#line 13231 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 13232 "./marpa.w"

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
/*1143:*/
#line 13312 "./marpa.w"

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

/*:1143*/
#line 13262 "./marpa.w"

}else{
/*1144:*/
#line 13337 "./marpa.w"
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

/*:1144*/
#line 13264 "./marpa.w"

}
/*1145:*/
#line 13379 "./marpa.w"
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
/*1146:*/
#line 13442 "./marpa.w"

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

/*:1146*/
#line 13436 "./marpa.w"
;
NEXT_NOOK_ON_WORKLIST:;
}
NEXT_TREE:;
}

/*:1145*/
#line 13266 "./marpa.w"

}
TREE_IS_FINISHED:;
t->t_parse_count++;
return FSTACK_LENGTH(t->t_nook_stack);
TREE_IS_EXHAUSTED:;
tree_exhaust(t);
MARPA_ERROR(MARPA_ERR_TREE_EXHAUSTED);
return termination_indicator;

}

/*:1134*//*1141:*/
#line 13299 "./marpa.w"

PRIVATE int tree_or_node_try(TREE tree,ORID or_node_id)
{
return!bv_bit_test_then_set(tree->t_or_node_in_use,or_node_id);
}
/*:1141*//*1142:*/
#line 13305 "./marpa.w"

PRIVATE void tree_or_node_release(TREE tree,ORID or_node_id)
{
bv_bit_clear(tree->t_or_node_in_use,or_node_id);
}

/*:1142*//*1147:*/
#line 13463 "./marpa.w"

int marpa_t_parse_count(Marpa_Tree t)
{
return t->t_parse_count;
}

/*:1147*//*1148:*/
#line 13471 "./marpa.w"

int _marpa_t_size(Marpa_Tree t)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 13474 "./marpa.w"

/*1122:*/
#line 13108 "./marpa.w"

ORDER o= O_of_T(t);
/*1094:*/
#line 12640 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1049:*/
#line 12235 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1049*/
#line 12642 "./marpa.w"


/*:1094*/
#line 13110 "./marpa.w"
;

/*:1122*/
#line 13475 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 13476 "./marpa.w"

if(T_is_Exhausted(t)){
MARPA_ERROR(MARPA_ERR_TREE_EXHAUSTED);
return failure_indicator;
}
if(T_is_Nulling(t))return 0;
return Size_of_T(t);
}

/*:1148*//*1169:*/
#line 13689 "./marpa.w"

Marpa_Value marpa_v_new(Marpa_Tree t)
{
/*1317:*/
#line 15723 "./marpa.w"
void*const failure_indicator= NULL;
/*:1317*/
#line 13692 "./marpa.w"

/*1122:*/
#line 13108 "./marpa.w"

ORDER o= O_of_T(t);
/*1094:*/
#line 12640 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1049:*/
#line 12235 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1049*/
#line 12642 "./marpa.w"


/*:1094*/
#line 13110 "./marpa.w"
;

/*:1122*/
#line 13693 "./marpa.w"
;
/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 13694 "./marpa.w"

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
/*1160:*/
#line 13615 "./marpa.w"

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

/*:1160*//*1167:*/
#line 13678 "./marpa.w"

MARPA_DSTACK_SAFE(VStack_of_V(v));
/*:1167*//*1172:*/
#line 13726 "./marpa.w"

v->t_ref_count= 1;

/*:1172*//*1182:*/
#line 13797 "./marpa.w"

V_is_Nulling(v)= 0;

/*:1182*//*1184:*/
#line 13804 "./marpa.w"

V_is_Trace(v)= 0;
/*:1184*//*1187:*/
#line 13826 "./marpa.w"

NOOK_of_V(v)= -1;
/*:1187*//*1192:*/
#line 13854 "./marpa.w"

{
ISY_is_Valued_BV_of_V(v)= lbv_clone(v->t_obs,Valued_BV_of_B(b),isy_count);
Valued_Locked_BV_of_V(v)= 
lbv_clone(v->t_obs,Valued_Locked_BV_of_B(b),isy_count);
}


/*:1192*/
#line 13707 "./marpa.w"

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

/*:1169*//*1173:*/
#line 13730 "./marpa.w"

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

/*:1173*//*1174:*/
#line 13748 "./marpa.w"

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
/*1317:*/
#line 15723 "./marpa.w"
void*const failure_indicator= NULL;
/*:1317*/
#line 13759 "./marpa.w"

const VALUE v= (VALUE)public_v;
/*1176:*/
#line 13774 "./marpa.w"

TREE t= T_of_V(v);
/*1122:*/
#line 13108 "./marpa.w"

ORDER o= O_of_T(t);
/*1094:*/
#line 12640 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1049:*/
#line 12235 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1049*/
#line 12642 "./marpa.w"


/*:1094*/
#line 13110 "./marpa.w"
;

/*:1122*/
#line 13776 "./marpa.w"


/*:1176*/
#line 13761 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 13762 "./marpa.w"

/*1179:*/
#line 13786 "./marpa.w"

if(_MARPA_UNLIKELY(V_T_Generation(v)!=T_Generation(t))){
MARPA_ERROR(MARPA_ERR_BASE_GENERATION_MISMATCH);
return failure_indicator;
}

/*:1179*/
#line 13763 "./marpa.w"

return(Marpa_Value)value_ref(v);
}

/*:1174*//*1175:*/
#line 13767 "./marpa.w"

PRIVATE void value_free(VALUE v)
{
/*1168:*/
#line 13680 "./marpa.w"

{
if(_MARPA_LIKELY(MARPA_DSTACK_IS_INITIALIZED(VStack_of_V(v))!=NULL))
{
MARPA_DSTACK_DESTROY(VStack_of_V(v));
}
}

/*:1168*/
#line 13770 "./marpa.w"

/*1162:*/
#line 13631 "./marpa.w"

marpa_obs_free(v->t_obs);

/*:1162*/
#line 13771 "./marpa.w"

}

/*:1175*//*1185:*/
#line 13806 "./marpa.w"

int _marpa_v_trace(Marpa_Value public_v,int flag)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 13809 "./marpa.w"

const VALUE v= (VALUE)public_v;
/*1176:*/
#line 13774 "./marpa.w"

TREE t= T_of_V(v);
/*1122:*/
#line 13108 "./marpa.w"

ORDER o= O_of_T(t);
/*1094:*/
#line 12640 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1049:*/
#line 12235 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1049*/
#line 12642 "./marpa.w"


/*:1094*/
#line 13110 "./marpa.w"
;

/*:1122*/
#line 13776 "./marpa.w"


/*:1176*/
#line 13811 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 13812 "./marpa.w"

/*1179:*/
#line 13786 "./marpa.w"

if(_MARPA_UNLIKELY(V_T_Generation(v)!=T_Generation(t))){
MARPA_ERROR(MARPA_ERR_BASE_GENERATION_MISMATCH);
return failure_indicator;
}

/*:1179*/
#line 13813 "./marpa.w"

if(_MARPA_UNLIKELY(!V_is_Active(v))){
MARPA_ERROR(MARPA_ERR_VALUATOR_INACTIVE);
return failure_indicator;
}
V_is_Trace(v)= Boolean(flag);
return 1;
}

/*:1185*//*1188:*/
#line 13829 "./marpa.w"

Marpa_Nook_ID _marpa_v_nook(Marpa_Value public_v)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 13832 "./marpa.w"

const VALUE v= (VALUE)public_v;
/*1176:*/
#line 13774 "./marpa.w"

TREE t= T_of_V(v);
/*1122:*/
#line 13108 "./marpa.w"

ORDER o= O_of_T(t);
/*1094:*/
#line 12640 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1049:*/
#line 12235 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1049*/
#line 12642 "./marpa.w"


/*:1094*/
#line 13110 "./marpa.w"
;

/*:1122*/
#line 13776 "./marpa.w"


/*:1176*/
#line 13834 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 13835 "./marpa.w"

/*1179:*/
#line 13786 "./marpa.w"

if(_MARPA_UNLIKELY(V_T_Generation(v)!=T_Generation(t))){
MARPA_ERROR(MARPA_ERR_BASE_GENERATION_MISMATCH);
return failure_indicator;
}

/*:1179*/
#line 13836 "./marpa.w"

if(_MARPA_UNLIKELY(V_is_Nulling(v)))return-1;
if(_MARPA_UNLIKELY(!V_is_Active(v))){
MARPA_ERROR(MARPA_ERR_VALUATOR_INACTIVE);
return failure_indicator;
}
return NOOK_of_V(v);
}

/*:1188*//*1193:*/
#line 13863 "./marpa.w"

PRIVATE int symbol_is_valued(
VALUE v,
Marpa_Symbol_ID isy_id)
{
return lbv_bit_test(ISY_is_Valued_BV_of_V(v),isy_id);
}

/*:1193*//*1194:*/
#line 13872 "./marpa.w"

int marpa_v_symbol_is_valued(
Marpa_Value public_v,
Marpa_Symbol_ID isy_id)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 13877 "./marpa.w"

const VALUE v= (VALUE)public_v;
/*1176:*/
#line 13774 "./marpa.w"

TREE t= T_of_V(v);
/*1122:*/
#line 13108 "./marpa.w"

ORDER o= O_of_T(t);
/*1094:*/
#line 12640 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1049:*/
#line 12235 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1049*/
#line 12642 "./marpa.w"


/*:1094*/
#line 13110 "./marpa.w"
;

/*:1122*/
#line 13776 "./marpa.w"


/*:1176*/
#line 13879 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 13880 "./marpa.w"

/*1179:*/
#line 13786 "./marpa.w"

if(_MARPA_UNLIKELY(V_T_Generation(v)!=T_Generation(t))){
MARPA_ERROR(MARPA_ERR_BASE_GENERATION_MISMATCH);
return failure_indicator;
}

/*:1179*/
#line 13881 "./marpa.w"

/*1321:*/
#line 15742 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1321*/
#line 13882 "./marpa.w"

/*1322:*/
#line 15749 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}
/*:1322*/
#line 13883 "./marpa.w"

return lbv_bit_test(ISY_is_Valued_BV_of_V(v),isy_id);
}

/*:1194*//*1195:*/
#line 13889 "./marpa.w"

PRIVATE int symbol_is_valued_set(
VALUE v,ISYID isy_id,int value)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 13893 "./marpa.w"

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

/*:1195*//*1196:*/
#line 13912 "./marpa.w"

int marpa_v_symbol_is_valued_set(
Marpa_Value public_v,Marpa_Symbol_ID isy_id,int value)
{
const VALUE v= (VALUE)public_v;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 13917 "./marpa.w"

/*1176:*/
#line 13774 "./marpa.w"

TREE t= T_of_V(v);
/*1122:*/
#line 13108 "./marpa.w"

ORDER o= O_of_T(t);
/*1094:*/
#line 12640 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1049:*/
#line 12235 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1049*/
#line 12642 "./marpa.w"


/*:1094*/
#line 13110 "./marpa.w"
;

/*:1122*/
#line 13776 "./marpa.w"


/*:1176*/
#line 13918 "./marpa.w"

/*1179:*/
#line 13786 "./marpa.w"

if(_MARPA_UNLIKELY(V_T_Generation(v)!=T_Generation(t))){
MARPA_ERROR(MARPA_ERR_BASE_GENERATION_MISMATCH);
return failure_indicator;
}

/*:1179*/
#line 13919 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 13920 "./marpa.w"

if(_MARPA_UNLIKELY(value<0||value> 1))
{
MARPA_ERROR(MARPA_ERR_INVALID_BOOLEAN);
return failure_indicator;
}
/*1321:*/
#line 15742 "./marpa.w"

if(_MARPA_UNLIKELY(ISYID_is_Malformed(isy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1321*/
#line 13926 "./marpa.w"

/*1322:*/
#line 15749 "./marpa.w"

if(_MARPA_UNLIKELY(!ISYID_of_G_Exists(isy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}
/*:1322*/
#line 13927 "./marpa.w"

return symbol_is_valued_set(v,isy_id,value);
}

/*:1196*//*1197:*/
#line 13933 "./marpa.w"

int
marpa_v_valued_force(Marpa_Value public_v)
{
const VALUE v= (VALUE)public_v;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 13938 "./marpa.w"

ISYID isy_count;
ISYID isy_id;
/*1176:*/
#line 13774 "./marpa.w"

TREE t= T_of_V(v);
/*1122:*/
#line 13108 "./marpa.w"

ORDER o= O_of_T(t);
/*1094:*/
#line 12640 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1049:*/
#line 12235 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1049*/
#line 12642 "./marpa.w"


/*:1094*/
#line 13110 "./marpa.w"
;

/*:1122*/
#line 13776 "./marpa.w"


/*:1176*/
#line 13941 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 13942 "./marpa.w"

/*1179:*/
#line 13786 "./marpa.w"

if(_MARPA_UNLIKELY(V_T_Generation(v)!=T_Generation(t))){
MARPA_ERROR(MARPA_ERR_BASE_GENERATION_MISMATCH);
return failure_indicator;
}

/*:1179*/
#line 13943 "./marpa.w"

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

/*:1197*//*1198:*/
#line 13958 "./marpa.w"

int marpa_v_rule_is_valued_set(
Marpa_Value public_v,Marpa_Rule_ID irl_id,int value)
{
const VALUE v= (VALUE)public_v;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 13963 "./marpa.w"

/*1176:*/
#line 13774 "./marpa.w"

TREE t= T_of_V(v);
/*1122:*/
#line 13108 "./marpa.w"

ORDER o= O_of_T(t);
/*1094:*/
#line 12640 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1049:*/
#line 12235 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1049*/
#line 12642 "./marpa.w"


/*:1094*/
#line 13110 "./marpa.w"
;

/*:1122*/
#line 13776 "./marpa.w"


/*:1176*/
#line 13964 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 13965 "./marpa.w"

/*1179:*/
#line 13786 "./marpa.w"

if(_MARPA_UNLIKELY(V_T_Generation(v)!=T_Generation(t))){
MARPA_ERROR(MARPA_ERR_BASE_GENERATION_MISMATCH);
return failure_indicator;
}

/*:1179*/
#line 13966 "./marpa.w"

if(_MARPA_UNLIKELY(value<0||value> 1))
{
MARPA_ERROR(MARPA_ERR_INVALID_BOOLEAN);
return failure_indicator;
}
/*1330:*/
#line 15798 "./marpa.w"

if(_MARPA_UNLIKELY(IRLID_is_Malformed(irl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_RULE_ID);
return failure_indicator;
}

/*:1330*/
#line 13972 "./marpa.w"

/*1328:*/
#line 15786 "./marpa.w"

if(_MARPA_UNLIKELY(!IRLID_of_G_Exists(irl_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_RULE_ID);
return-1;
}

/*:1328*/
#line 13973 "./marpa.w"

{
const IRL irl= IRL_by_ID(irl_id);
const ISYID isy_id= LHS_ID_of_IRL(irl);
return symbol_is_valued_set(v,isy_id,value);
}
}

/*:1198*//*1199:*/
#line 13981 "./marpa.w"

int marpa_v_rule_is_valued(
Marpa_Value public_v,Marpa_Rule_ID irl_id)
{
const VALUE v= (VALUE)public_v;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 13986 "./marpa.w"

/*1176:*/
#line 13774 "./marpa.w"

TREE t= T_of_V(v);
/*1122:*/
#line 13108 "./marpa.w"

ORDER o= O_of_T(t);
/*1094:*/
#line 12640 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1049:*/
#line 12235 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1049*/
#line 12642 "./marpa.w"


/*:1094*/
#line 13110 "./marpa.w"
;

/*:1122*/
#line 13776 "./marpa.w"


/*:1176*/
#line 13987 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 13988 "./marpa.w"

/*1179:*/
#line 13786 "./marpa.w"

if(_MARPA_UNLIKELY(V_T_Generation(v)!=T_Generation(t))){
MARPA_ERROR(MARPA_ERR_BASE_GENERATION_MISMATCH);
return failure_indicator;
}

/*:1179*/
#line 13989 "./marpa.w"

/*1330:*/
#line 15798 "./marpa.w"

if(_MARPA_UNLIKELY(IRLID_is_Malformed(irl_id))){
MARPA_ERROR(MARPA_ERR_INVALID_RULE_ID);
return failure_indicator;
}

/*:1330*/
#line 13990 "./marpa.w"

/*1328:*/
#line 15786 "./marpa.w"

if(_MARPA_UNLIKELY(!IRLID_of_G_Exists(irl_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_RULE_ID);
return-1;
}

/*:1328*/
#line 13991 "./marpa.w"

{
const IRL irl= IRL_by_ID(irl_id);
const ISYID isy_id= LHS_ID_of_IRL(irl);
return symbol_is_valued(v,isy_id);
}
}

/*:1199*//*1201:*/
#line 14006 "./marpa.w"

Marpa_Step_Type marpa_v_step(Marpa_Value public_v)
{
const VALUE v= (VALUE)public_v;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 14010 "./marpa.w"

/*1176:*/
#line 13774 "./marpa.w"

TREE t= T_of_V(v);
/*1122:*/
#line 13108 "./marpa.w"

ORDER o= O_of_T(t);
/*1094:*/
#line 12640 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1049:*/
#line 12235 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1049*/
#line 12642 "./marpa.w"


/*:1094*/
#line 13110 "./marpa.w"
;

/*:1122*/
#line 13776 "./marpa.w"


/*:1176*/
#line 14011 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 14012 "./marpa.w"

/*1179:*/
#line 13786 "./marpa.w"

if(_MARPA_UNLIKELY(V_T_Generation(v)!=T_Generation(t))){
MARPA_ERROR(MARPA_ERR_BASE_GENERATION_MISMATCH);
return failure_indicator;
}

/*:1179*/
#line 14013 "./marpa.w"


if(V_is_Nulling(v)){
/*1203:*/
#line 14095 "./marpa.w"

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

/*:1203*/
#line 14016 "./marpa.w"

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
/*1202:*/
#line 14079 "./marpa.w"

{
const LBV isy_bv= ISY_is_Valued_BV_of_V(v);
const IRLID irl_count= IRL_Count_of_G(g);
const LBV irl_bv= lbv_obs_new0(v->t_obs,irl_count);
IRLID irlid;
IRL_is_Valued_BV_of_V(v)= irl_bv;
for(irlid= 0;irlid<irl_count;irlid++){
const IRL irl= IRL_by_ID(irlid);
const ISYID lhs_isy_id= LHS_ID_of_IRL(irl);
if(lbv_bit_test(isy_bv,lhs_isy_id)){
lbv_bit_set(irl_bv,irlid);
}
}
}

/*:1202*/
#line 14029 "./marpa.w"

}

case STEP_GET_DATA:
/*1204:*/
#line 14120 "./marpa.w"

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

/*:1204*/
#line 14033 "./marpa.w"

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

/*:1201*//*1206:*/
#line 14281 "./marpa.w"

PRIVATE int lbv_bits_to_size(int bits)
{
const LBW result= (LBW)(((unsigned int)bits+(lbv_wordbits-1))/lbv_wordbits);
return(int)result;
}

/*:1206*//*1207:*/
#line 14289 "./marpa.w"

PRIVATE Bit_Vector
lbv_obs_new(struct marpa_obstack*obs,int bits)
{
int size= lbv_bits_to_size(bits);
LBV lbv= marpa_obs_new(obs,LBW,size);
return lbv;
}

/*:1207*//*1208:*/
#line 14299 "./marpa.w"

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

/*:1208*//*1209:*/
#line 14312 "./marpa.w"

PRIVATE Bit_Vector
lbv_obs_new0(struct marpa_obstack*obs,int bits)
{
LBV lbv= lbv_obs_new(obs,bits);
return lbv_zero(lbv,bits);
}

/*:1209*//*1211:*/
#line 14331 "./marpa.w"

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

/*:1211*//*1212:*/
#line 14347 "./marpa.w"

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

/*:1212*//*1215:*/
#line 14383 "./marpa.w"

PRIVATE unsigned int bv_bits_to_size(int bits)
{
return((LBW)bits+bv_modmask)/bv_wordbits;
}
/*:1215*//*1216:*/
#line 14389 "./marpa.w"

PRIVATE unsigned int bv_bits_to_unused_mask(int bits)
{
LBW mask= (LBW)bits&bv_modmask;
if(mask)mask= (LBW)~(~0uL<<mask);else mask= (LBW)~0uL;
return(mask);
}

/*:1216*//*1218:*/
#line 14403 "./marpa.w"

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

/*:1218*//*1220:*/
#line 14421 "./marpa.w"

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


/*:1220*//*1221:*/
#line 14442 "./marpa.w"

PRIVATE Bit_Vector bv_shadow(Bit_Vector bv)
{
return bv_create((int)BV_BITS(bv));
}
PRIVATE Bit_Vector bv_obs_shadow(struct marpa_obstack*obs,Bit_Vector bv)
{
return bv_obs_create(obs,(int)BV_BITS(bv));
}

/*:1221*//*1222:*/
#line 14456 "./marpa.w"

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

/*:1222*//*1223:*/
#line 14474 "./marpa.w"

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

/*:1223*//*1224:*/
#line 14488 "./marpa.w"

PRIVATE void bv_free(Bit_Vector vector)
{
if(_MARPA_LIKELY(vector!=NULL))
{
vector-= bv_hiddenwords;
my_free(vector);
}
}

/*:1224*//*1225:*/
#line 14499 "./marpa.w"

PRIVATE void bv_fill(Bit_Vector bv)
{
LBW size= BV_SIZE(bv);
if(size<=0)return;
while(size--)*bv++= ~0u;
--bv;
*bv&= BV_MASK(bv);
}

/*:1225*//*1226:*/
#line 14510 "./marpa.w"

PRIVATE void bv_clear(Bit_Vector bv)
{
LBW size= BV_SIZE(bv);
if(size<=0)return;
while(size--)*bv++= 0u;
}

/*:1226*//*1228:*/
#line 14524 "./marpa.w"

PRIVATE void bv_over_clear(Bit_Vector bv,int raw_bit)
{
const LBW bit= (LBW)raw_bit;
LBW length= bit/bv_wordbits+1;
while(length--)*bv++= 0u;
}

/*:1228*//*1230:*/
#line 14533 "./marpa.w"

PRIVATE void bv_bit_set(Bit_Vector vector,int raw_bit)
{
const LBW bit= (LBW)raw_bit;
*(vector+(bit/bv_wordbits))|= (bv_lsb<<(bit%bv_wordbits));
}

/*:1230*//*1231:*/
#line 14541 "./marpa.w"

PRIVATE void bv_bit_clear(Bit_Vector vector,int raw_bit)
{
const LBW bit= (LBW)raw_bit;
*(vector+(bit/bv_wordbits))&= ~(bv_lsb<<(bit%bv_wordbits));
}

/*:1231*//*1232:*/
#line 14549 "./marpa.w"

PRIVATE int bv_bit_test(Bit_Vector vector,int raw_bit)
{
const LBW bit= (LBW)raw_bit;
return(*(vector+(bit/bv_wordbits))&(bv_lsb<<(bit%bv_wordbits)))!=0u;
}

/*:1232*//*1233:*/
#line 14561 "./marpa.w"

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

/*:1233*//*1234:*/
#line 14575 "./marpa.w"

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

/*:1234*//*1235:*/
#line 14589 "./marpa.w"

PRIVATE void bv_not(Bit_Vector X,Bit_Vector Y)
{
LBW size= BV_SIZE(X);
LBW mask= BV_MASK(X);
while(size--> 0)*X++= ~*Y++;
*(--X)&= mask;
}

/*:1235*//*1236:*/
#line 14599 "./marpa.w"

PRIVATE void bv_and(Bit_Vector X,Bit_Vector Y,Bit_Vector Z)
{
LBW size= BV_SIZE(X);
LBW mask= BV_MASK(X);
while(size--> 0)*X++= *Y++&*Z++;
*(--X)&= mask;
}

/*:1236*//*1237:*/
#line 14609 "./marpa.w"

PRIVATE void bv_or(Bit_Vector X,Bit_Vector Y,Bit_Vector Z)
{
LBW size= BV_SIZE(X);
LBW mask= BV_MASK(X);
while(size--> 0)*X++= *Y++|*Z++;
*(--X)&= mask;
}

/*:1237*//*1238:*/
#line 14619 "./marpa.w"

PRIVATE void bv_or_assign(Bit_Vector X,Bit_Vector Y)
{
LBW size= BV_SIZE(X);
LBW mask= BV_MASK(X);
while(size--> 0)*X++|= *Y++;
*(--X)&= mask;
}

/*:1238*//*1239:*/
#line 14629 "./marpa.w"

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

/*:1239*//*1240:*/
#line 14709 "./marpa.w"

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

/*:1240*//*1245:*/
#line 14756 "./marpa.w"

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

/*:1245*//*1250:*/
#line 14903 "./marpa.w"

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

/*:1250*//*1252:*/
#line 14926 "./marpa.w"

PRIVATE size_t matrix_sizeof(int rows,int columns)
{
const LBW bv_data_words= bv_bits_to_size(columns);
const LBW row_bytes= 
(LBW)(bv_data_words+bv_hiddenwords)*(LBW)sizeof(Bit_Vector_Word);
return offsetof(struct s_bit_matrix,
t_row_data)+((size_t)rows)*row_bytes;
}

/*:1252*//*1254:*/
#line 14937 "./marpa.w"

PRIVATE Bit_Matrix matrix_obs_create(
struct marpa_obstack*obs,
int rows,
int columns)
{

Bit_Matrix matrix_addr= 
marpa__obs_alloc(obs,matrix_sizeof(rows,columns),ALIGNOF(Bit_Matrix_Object));
return matrix_buffer_create(matrix_addr,rows,columns);
}

/*:1254*//*1255:*/
#line 14950 "./marpa.w"

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

/*:1255*//*1256:*/
#line 14972 "./marpa.w"

PRIVATE int matrix_columns(Bit_Matrix matrix)
{
Bit_Vector row0= matrix->t_row_data+bv_hiddenwords;
return(int)BV_BITS(row0);
}

/*:1256*//*1257:*/
#line 14988 "./marpa.w"

PRIVATE Bit_Vector matrix_row(Bit_Matrix matrix,int row)
{
Bit_Vector row0= matrix->t_row_data+bv_hiddenwords;
LBW words_per_row= BV_SIZE(row0)+bv_hiddenwords;
return row0+(LBW)row*words_per_row;
}

/*:1257*//*1259:*/
#line 14997 "./marpa.w"

PRIVATE void matrix_bit_set(Bit_Matrix matrix,int row,int column)
{
Bit_Vector vector= matrix_row(matrix,row);
bv_bit_set(vector,column);
}

/*:1259*//*1261:*/
#line 15005 "./marpa.w"

PRIVATE void matrix_bit_clear(Bit_Matrix matrix,int row,int column)
{
Bit_Vector vector= matrix_row(matrix,row);
bv_bit_clear(vector,column);
}

/*:1261*//*1263:*/
#line 15013 "./marpa.w"

PRIVATE int matrix_bit_test(Bit_Matrix matrix,int row,int column)
{
Bit_Vector vector= matrix_row(matrix,row);
return bv_bit_test(vector,column);
}

/*:1263*//*1264:*/
#line 15030 "./marpa.w"

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

/*:1264*//*1276:*/
#line 15171 "./marpa.w"

PRIVATE void
cilar_init(const CILAR cilar)
{
cilar->t_obs= marpa_obs_init;
cilar->t_avl= _marpa_avl_create(cil_cmp,NULL);
MARPA_DSTACK_INIT(cilar->t_buffer,int,2);
*MARPA_DSTACK_INDEX(cilar->t_buffer,int,0)= 0;
}
/*:1276*//*1277:*/
#line 15185 "./marpa.w"

PRIVATE void
cilar_buffer_reinit(const CILAR cilar)
{
MARPA_DSTACK_DESTROY(cilar->t_buffer);
MARPA_DSTACK_INIT(cilar->t_buffer,int,2);
*MARPA_DSTACK_INDEX(cilar->t_buffer,int,0)= 0;
}

/*:1277*//*1278:*/
#line 15194 "./marpa.w"

PRIVATE void cilar_destroy(const CILAR cilar)
{
_marpa_avl_destroy(cilar->t_avl);
marpa_obs_free(cilar->t_obs);
MARPA_DSTACK_DESTROY((cilar->t_buffer));
}

/*:1278*//*1279:*/
#line 15203 "./marpa.w"

PRIVATE CIL cil_empty(CILAR cilar)
{
CIL cil= MARPA_DSTACK_BASE(cilar->t_buffer,int);

Count_of_CIL(cil)= 0;
return cil_buffer_add(cilar);
}

/*:1279*//*1280:*/
#line 15213 "./marpa.w"

PRIVATE CIL cil_singleton(CILAR cilar,int element)
{
CIL cil= MARPA_DSTACK_BASE(cilar->t_buffer,int);
Count_of_CIL(cil)= 1;
Item_of_CIL(cil,0)= element;

return cil_buffer_add(cilar);
}

/*:1280*//*1281:*/
#line 15229 "./marpa.w"

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

/*:1281*//*1282:*/
#line 15257 "./marpa.w"

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

/*:1282*//*1283:*/
#line 15274 "./marpa.w"

PRIVATE void cil_buffer_clear(CILAR cilar)
{
const MARPA_DSTACK dstack= &cilar->t_buffer;
MARPA_DSTACK_CLEAR(*dstack);




*MARPA_DSTACK_PUSH(*dstack,int)= 0;
}

/*:1283*//*1284:*/
#line 15289 "./marpa.w"

PRIVATE CIL cil_buffer_push(CILAR cilar,int new_item)
{
CIL cil_in_buffer;
MARPA_DSTACK dstack= &cilar->t_buffer;
*MARPA_DSTACK_PUSH(*dstack,int)= new_item;



cil_in_buffer= MARPA_DSTACK_BASE(*dstack,int);
Count_of_CIL(cil_in_buffer)++;
return cil_in_buffer;
}

/*:1284*//*1285:*/
#line 15305 "./marpa.w"

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

/*:1285*//*1286:*/
#line 15324 "./marpa.w"

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

/*:1286*//*1287:*/
#line 15377 "./marpa.w"

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

/*:1287*//*1288:*/
#line 15412 "./marpa.w"

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

/*:1288*//*1301:*/
#line 15551 "./marpa.w"

PRIVATE void
psar_safe(const PSAR psar)
{
psar->t_psl_length= 0;
psar->t_first_psl= psar->t_first_free_psl= NULL;
}
/*:1301*//*1302:*/
#line 15558 "./marpa.w"

PRIVATE void
psar_init(const PSAR psar,int length)
{
psar->t_psl_length= length;
psar->t_first_psl= psar->t_first_free_psl= psl_new(psar);
}
/*:1302*//*1303:*/
#line 15565 "./marpa.w"

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
/*:1303*//*1304:*/
#line 15579 "./marpa.w"

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
/*:1304*//*1307:*/
#line 15610 "./marpa.w"

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

/*:1307*//*1309:*/
#line 15628 "./marpa.w"

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

/*:1309*//*1311:*/
#line 15648 "./marpa.w"

PRIVATE void psl_claim(
PSL*const psl_owner,const PSAR psar)
{
PSL new_psl= psl_alloc(psar);
(*psl_owner)= new_psl;
new_psl->t_owner= psl_owner;
}


/*:1311*//*1312:*/
#line 15658 "./marpa.w"

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

/*:1312*//*1313:*/
#line 15675 "./marpa.w"

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

/*:1313*//*1341:*/
#line 15907 "./marpa.w"

PRIVATE_NOT_INLINE void
set_error(GRAMMAR g,Marpa_Error_Code code,const char*message,unsigned int flags)
{
g->t_error= code;
g->t_error_string= message;
if(flags&FATAL_FLAG)
g->t_is_ok= 0;
}
/*:1341*//*1342:*/
#line 15926 "./marpa.w"

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

/*:1342*//*1346:*/
#line 15969 "./marpa.w"

PRIVATE_NOT_INLINE void*
marpa__default_out_of_memory(void)
{
abort();
return NULL;
}
void*(*const marpa__out_of_memory)(void)= marpa__default_out_of_memory;

/*:1346*//*1351:*/
#line 16007 "./marpa.w"

Marpa_Earley_Set_ID _marpa_r_trace_earley_set(Marpa_Recognizer r)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 16010 "./marpa.w"

/*565:*/
#line 6162 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:565*/
#line 16011 "./marpa.w"

YS trace_earley_set= r->t_trace_earley_set;
/*1337:*/
#line 15851 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 15852 "./marpa.w"

/*1335:*/
#line 15835 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1335*/
#line 15853 "./marpa.w"


/*:1337*/
#line 16013 "./marpa.w"

if(!trace_earley_set){
MARPA_ERROR(MARPA_ERR_NO_TRACE_YS);
return failure_indicator;
}
return Ord_of_YS(trace_earley_set);
}

/*:1351*//*1352:*/
#line 16021 "./marpa.w"

Marpa_Earley_Set_ID marpa_r_latest_earley_set(Marpa_Recognizer r)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 16024 "./marpa.w"

/*565:*/
#line 6162 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:565*/
#line 16025 "./marpa.w"

/*1337:*/
#line 15851 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 15852 "./marpa.w"

/*1335:*/
#line 15835 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1335*/
#line 15853 "./marpa.w"


/*:1337*/
#line 16026 "./marpa.w"

if(G_is_Trivial(g))return 0;
return Ord_of_YS(Latest_YS_of_R(r));
}

/*:1352*//*1353:*/
#line 16031 "./marpa.w"

Marpa_Earleme marpa_r_earleme(Marpa_Recognizer r,Marpa_Earley_Set_ID set_id)
{
/*565:*/
#line 6162 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:565*/
#line 16034 "./marpa.w"

/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 16035 "./marpa.w"

YS earley_set;
/*1335:*/
#line 15835 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1335*/
#line 16037 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 16038 "./marpa.w"

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

/*:1353*//*1355:*/
#line 16056 "./marpa.w"

int _marpa_r_earley_set_size(Marpa_Recognizer r,Marpa_Earley_Set_ID set_id)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 16059 "./marpa.w"

YS earley_set;
/*565:*/
#line 6162 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:565*/
#line 16061 "./marpa.w"

/*1335:*/
#line 15835 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1335*/
#line 16062 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 16063 "./marpa.w"

r_update_earley_sets(r);
if(!YS_Ord_is_Valid(r,set_id))
{
MARPA_ERROR(MARPA_ERR_INVALID_LOCATION);
return failure_indicator;
}
earley_set= YS_of_R_by_Ord(r,set_id);
return YIM_Count_of_YS(earley_set);
}

/*:1355*//*1360:*/
#line 16105 "./marpa.w"

Marpa_Earleme
_marpa_r_earley_set_trace(Marpa_Recognizer r,Marpa_Earley_Set_ID set_id)
{
YS earley_set;
const int es_does_not_exist= -1;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 16111 "./marpa.w"

/*565:*/
#line 6162 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:565*/
#line 16112 "./marpa.w"

/*1337:*/
#line 15851 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 15852 "./marpa.w"

/*1335:*/
#line 15835 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1335*/
#line 15853 "./marpa.w"


/*:1337*/
#line 16113 "./marpa.w"

if(r->t_trace_earley_set&&Ord_of_YS(r->t_trace_earley_set)==set_id)
{


return Earleme_of_YS(r->t_trace_earley_set);
}
/*1361:*/
#line 16136 "./marpa.w"
{
r->t_trace_earley_set= NULL;
trace_earley_item_clear(r);
/*1373:*/
#line 16325 "./marpa.w"

r->t_trace_pim_nsy_p= NULL;
r->t_trace_postdot_item= NULL;

/*:1373*/
#line 16139 "./marpa.w"

}

/*:1361*/
#line 16120 "./marpa.w"

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

/*:1360*//*1362:*/
#line 16142 "./marpa.w"

Marpa_AHM_ID
_marpa_r_earley_item_trace(Marpa_Recognizer r,Marpa_Earley_Item_ID item_id)
{
const int yim_does_not_exist= -1;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 16147 "./marpa.w"

YS trace_earley_set;
YIM earley_item;
YIM*earley_items;
/*565:*/
#line 6162 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:565*/
#line 16151 "./marpa.w"

/*1337:*/
#line 15851 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 15852 "./marpa.w"

/*1335:*/
#line 15835 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1335*/
#line 15853 "./marpa.w"


/*:1337*/
#line 16152 "./marpa.w"

trace_earley_set= r->t_trace_earley_set;
if(!trace_earley_set)
{
/*1361:*/
#line 16136 "./marpa.w"
{
r->t_trace_earley_set= NULL;
trace_earley_item_clear(r);
/*1373:*/
#line 16325 "./marpa.w"

r->t_trace_pim_nsy_p= NULL;
r->t_trace_postdot_item= NULL;

/*:1373*/
#line 16139 "./marpa.w"

}

/*:1361*/
#line 16156 "./marpa.w"

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

/*:1362*//*1364:*/
#line 16185 "./marpa.w"

PRIVATE void trace_earley_item_clear(RECCE r)
{
/*1363:*/
#line 16182 "./marpa.w"

r->t_trace_earley_item= NULL;

/*:1363*/
#line 16188 "./marpa.w"

trace_source_link_clear(r);
}

/*:1364*//*1365:*/
#line 16192 "./marpa.w"

Marpa_Earley_Set_ID _marpa_r_earley_item_origin(Marpa_Recognizer r)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 16195 "./marpa.w"

YIM item= r->t_trace_earley_item;
/*565:*/
#line 6162 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:565*/
#line 16197 "./marpa.w"

/*1337:*/
#line 15851 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 15852 "./marpa.w"

/*1335:*/
#line 15835 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1335*/
#line 15853 "./marpa.w"


/*:1337*/
#line 16198 "./marpa.w"

if(!item){
/*1363:*/
#line 16182 "./marpa.w"

r->t_trace_earley_item= NULL;

/*:1363*/
#line 16200 "./marpa.w"

MARPA_ERROR(MARPA_ERR_NO_TRACE_YIM);
return failure_indicator;
}
return Origin_Ord_of_YIM(item);
}

/*:1365*//*1367:*/
#line 16212 "./marpa.w"

Marpa_Symbol_ID _marpa_r_leo_predecessor_symbol(Marpa_Recognizer r)
{
const Marpa_Symbol_ID no_predecessor= -1;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 16216 "./marpa.w"

PIM postdot_item= r->t_trace_postdot_item;
LIM predecessor_leo_item;
/*565:*/
#line 6162 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:565*/
#line 16219 "./marpa.w"

/*1337:*/
#line 15851 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 15852 "./marpa.w"

/*1335:*/
#line 15835 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1335*/
#line 15853 "./marpa.w"


/*:1337*/
#line 16220 "./marpa.w"

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

/*:1367*//*1368:*/
#line 16234 "./marpa.w"

Marpa_Earley_Set_ID _marpa_r_leo_base_origin(Marpa_Recognizer r)
{
const JEARLEME pim_is_not_a_leo_item= -1;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 16238 "./marpa.w"

PIM postdot_item= r->t_trace_postdot_item;
/*565:*/
#line 6162 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:565*/
#line 16240 "./marpa.w"

YIM base_earley_item;
/*1337:*/
#line 15851 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 15852 "./marpa.w"

/*1335:*/
#line 15835 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1335*/
#line 15853 "./marpa.w"


/*:1337*/
#line 16242 "./marpa.w"

if(!postdot_item){
MARPA_ERROR(MARPA_ERR_NO_TRACE_PIM);
return failure_indicator;
}
if(YIM_of_PIM(postdot_item))return pim_is_not_a_leo_item;
base_earley_item= Trailhead_YIM_of_LIM(LIM_of_PIM(postdot_item));
return Origin_Ord_of_YIM(base_earley_item);
}

/*:1368*//*1369:*/
#line 16253 "./marpa.w"

Marpa_AHM_ID _marpa_r_leo_base_state(Marpa_Recognizer r)
{
const JEARLEME pim_is_not_a_leo_item= -1;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 16257 "./marpa.w"

PIM postdot_item= r->t_trace_postdot_item;
YIM base_earley_item;
/*565:*/
#line 6162 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:565*/
#line 16260 "./marpa.w"

/*1337:*/
#line 15851 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 15852 "./marpa.w"

/*1335:*/
#line 15835 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1335*/
#line 15853 "./marpa.w"


/*:1337*/
#line 16261 "./marpa.w"

if(!postdot_item){
MARPA_ERROR(MARPA_ERR_NO_TRACE_PIM);
return failure_indicator;
}
if(YIM_of_PIM(postdot_item))return pim_is_not_a_leo_item;
base_earley_item= Trailhead_YIM_of_LIM(LIM_of_PIM(postdot_item));
return AHMID_of_YIM(base_earley_item);
}

/*:1369*//*1372:*/
#line 16299 "./marpa.w"

Marpa_Symbol_ID
_marpa_r_postdot_symbol_trace(Marpa_Recognizer r,
Marpa_Symbol_ID nsy_id)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 16304 "./marpa.w"

YS current_ys= r->t_trace_earley_set;
PIM*pim_nsy_p;
PIM pim;
/*565:*/
#line 6162 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:565*/
#line 16308 "./marpa.w"

/*1373:*/
#line 16325 "./marpa.w"

r->t_trace_pim_nsy_p= NULL;
r->t_trace_postdot_item= NULL;

/*:1373*/
#line 16309 "./marpa.w"

/*1337:*/
#line 15851 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 15852 "./marpa.w"

/*1335:*/
#line 15835 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1335*/
#line 15853 "./marpa.w"


/*:1337*/
#line 16310 "./marpa.w"

/*1325:*/
#line 15765 "./marpa.w"

if(_MARPA_UNLIKELY(NSYID_is_Malformed(nsy_id))){
MARPA_ERROR(MARPA_ERR_INVALID_SYMBOL_ID);
return failure_indicator;
}
/*:1325*/
#line 16311 "./marpa.w"

/*1326:*/
#line 15772 "./marpa.w"

if(_MARPA_UNLIKELY(!NSYID_of_G_Exists(nsy_id))){
MARPA_ERROR(MARPA_ERR_NO_SUCH_SYMBOL_ID);
return-1;
}

/*:1326*/
#line 16312 "./marpa.w"

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

/*:1372*//*1374:*/
#line 16335 "./marpa.w"

Marpa_Symbol_ID
_marpa_r_first_postdot_item_trace(Marpa_Recognizer r)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 16339 "./marpa.w"

YS current_earley_set= r->t_trace_earley_set;
PIM pim;
/*565:*/
#line 6162 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:565*/
#line 16342 "./marpa.w"

PIM*pim_nsy_p;
/*1373:*/
#line 16325 "./marpa.w"

r->t_trace_pim_nsy_p= NULL;
r->t_trace_postdot_item= NULL;

/*:1373*/
#line 16344 "./marpa.w"

/*1337:*/
#line 15851 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 15852 "./marpa.w"

/*1335:*/
#line 15835 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1335*/
#line 15853 "./marpa.w"


/*:1337*/
#line 16345 "./marpa.w"

if(!current_earley_set){
/*1363:*/
#line 16182 "./marpa.w"

r->t_trace_earley_item= NULL;

/*:1363*/
#line 16347 "./marpa.w"

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

/*:1374*//*1375:*/
#line 16366 "./marpa.w"

Marpa_Symbol_ID
_marpa_r_next_postdot_item_trace(Marpa_Recognizer r)
{
const ISYID no_more_postdot_symbols= -1;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 16371 "./marpa.w"

YS current_set= r->t_trace_earley_set;
PIM pim;
PIM*pim_nsy_p;
/*565:*/
#line 6162 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:565*/
#line 16375 "./marpa.w"


pim_nsy_p= r->t_trace_pim_nsy_p;
pim= r->t_trace_postdot_item;
/*1373:*/
#line 16325 "./marpa.w"

r->t_trace_pim_nsy_p= NULL;
r->t_trace_postdot_item= NULL;

/*:1373*/
#line 16379 "./marpa.w"

if(!pim_nsy_p||!pim){
MARPA_ERROR(MARPA_ERR_NO_TRACE_PIM);
return failure_indicator;
}
/*1337:*/
#line 15851 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 15852 "./marpa.w"

/*1335:*/
#line 15835 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1335*/
#line 15853 "./marpa.w"


/*:1337*/
#line 16384 "./marpa.w"

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

/*:1375*//*1376:*/
#line 16404 "./marpa.w"

Marpa_Symbol_ID _marpa_r_postdot_item_symbol(Marpa_Recognizer r)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 16407 "./marpa.w"

PIM postdot_item= r->t_trace_postdot_item;
/*565:*/
#line 6162 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:565*/
#line 16409 "./marpa.w"

/*1337:*/
#line 15851 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 15852 "./marpa.w"

/*1335:*/
#line 15835 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1335*/
#line 15853 "./marpa.w"


/*:1337*/
#line 16410 "./marpa.w"

if(!postdot_item){
MARPA_ERROR(MARPA_ERR_NO_TRACE_PIM);
return failure_indicator;
}
return Postdot_NSYID_of_PIM(postdot_item);
}

/*:1376*//*1381:*/
#line 16440 "./marpa.w"

Marpa_Symbol_ID _marpa_r_first_token_link_trace(Marpa_Recognizer r)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 16443 "./marpa.w"

SRCL source_link;
unsigned int source_type;
YIM item= r->t_trace_earley_item;
/*565:*/
#line 6162 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:565*/
#line 16447 "./marpa.w"

/*1337:*/
#line 15851 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 15852 "./marpa.w"

/*1335:*/
#line 15835 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1335*/
#line 15853 "./marpa.w"


/*:1337*/
#line 16448 "./marpa.w"

/*1395:*/
#line 16637 "./marpa.w"

item= r->t_trace_earley_item;
if(!item){
trace_source_link_clear(r);
MARPA_ERROR(MARPA_ERR_NO_TRACE_YIM);
return failure_indicator;
}

/*:1395*/
#line 16449 "./marpa.w"

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

/*:1381*//*1384:*/
#line 16481 "./marpa.w"

Marpa_Symbol_ID _marpa_r_next_token_link_trace(Marpa_Recognizer r)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 16484 "./marpa.w"

SRCL source_link;
YIM item;
/*565:*/
#line 6162 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:565*/
#line 16487 "./marpa.w"

/*1337:*/
#line 15851 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 15852 "./marpa.w"

/*1335:*/
#line 15835 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1335*/
#line 15853 "./marpa.w"


/*:1337*/
#line 16488 "./marpa.w"

/*1395:*/
#line 16637 "./marpa.w"

item= r->t_trace_earley_item;
if(!item){
trace_source_link_clear(r);
MARPA_ERROR(MARPA_ERR_NO_TRACE_YIM);
return failure_indicator;
}

/*:1395*/
#line 16489 "./marpa.w"

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

/*:1384*//*1386:*/
#line 16512 "./marpa.w"

Marpa_Symbol_ID _marpa_r_first_completion_link_trace(Marpa_Recognizer r)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 16515 "./marpa.w"

SRCL source_link;
unsigned int source_type;
YIM item= r->t_trace_earley_item;
/*565:*/
#line 6162 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:565*/
#line 16519 "./marpa.w"

/*1337:*/
#line 15851 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 15852 "./marpa.w"

/*1335:*/
#line 15835 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1335*/
#line 15853 "./marpa.w"


/*:1337*/
#line 16520 "./marpa.w"

/*1395:*/
#line 16637 "./marpa.w"

item= r->t_trace_earley_item;
if(!item){
trace_source_link_clear(r);
MARPA_ERROR(MARPA_ERR_NO_TRACE_YIM);
return failure_indicator;
}

/*:1395*/
#line 16521 "./marpa.w"

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

/*:1386*//*1389:*/
#line 16552 "./marpa.w"

Marpa_Symbol_ID _marpa_r_next_completion_link_trace(Marpa_Recognizer r)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 16555 "./marpa.w"

SRCL source_link;
YIM item;
/*565:*/
#line 6162 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:565*/
#line 16558 "./marpa.w"

/*1337:*/
#line 15851 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 15852 "./marpa.w"

/*1335:*/
#line 15835 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1335*/
#line 15853 "./marpa.w"


/*:1337*/
#line 16559 "./marpa.w"

/*1395:*/
#line 16637 "./marpa.w"

item= r->t_trace_earley_item;
if(!item){
trace_source_link_clear(r);
MARPA_ERROR(MARPA_ERR_NO_TRACE_YIM);
return failure_indicator;
}

/*:1395*/
#line 16560 "./marpa.w"

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

/*:1389*//*1391:*/
#line 16583 "./marpa.w"

Marpa_Symbol_ID
_marpa_r_first_leo_link_trace(Marpa_Recognizer r)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 16587 "./marpa.w"

SRCL source_link;
YIM item= r->t_trace_earley_item;
/*565:*/
#line 6162 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:565*/
#line 16590 "./marpa.w"

/*1337:*/
#line 15851 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 15852 "./marpa.w"

/*1335:*/
#line 15835 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1335*/
#line 15853 "./marpa.w"


/*:1337*/
#line 16591 "./marpa.w"

/*1395:*/
#line 16637 "./marpa.w"

item= r->t_trace_earley_item;
if(!item){
trace_source_link_clear(r);
MARPA_ERROR(MARPA_ERR_NO_TRACE_YIM);
return failure_indicator;
}

/*:1395*/
#line 16592 "./marpa.w"

source_link= First_Leo_SRCL_of_YIM(item);
if(source_link){
r->t_trace_source_type= SOURCE_IS_LEO;
r->t_trace_source_link= source_link;
return Cause_AHMID_of_SRCL(source_link);
}
trace_source_link_clear(r);
return-1;
}

/*:1391*//*1394:*/
#line 16611 "./marpa.w"

Marpa_Symbol_ID
_marpa_r_next_leo_link_trace(Marpa_Recognizer r)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 16615 "./marpa.w"

SRCL source_link;
YIM item;
/*565:*/
#line 6162 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:565*/
#line 16618 "./marpa.w"

/*1337:*/
#line 15851 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 15852 "./marpa.w"

/*1335:*/
#line 15835 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1335*/
#line 15853 "./marpa.w"


/*:1337*/
#line 16619 "./marpa.w"

/*1395:*/
#line 16637 "./marpa.w"

item= r->t_trace_earley_item;
if(!item){
trace_source_link_clear(r);
MARPA_ERROR(MARPA_ERR_NO_TRACE_YIM);
return failure_indicator;
}

/*:1395*/
#line 16620 "./marpa.w"

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

/*:1394*//*1396:*/
#line 16646 "./marpa.w"

PRIVATE void trace_source_link_clear(RECCE r)
{
r->t_trace_source_link= NULL;
r->t_trace_source_type= NO_SOURCE;
}

/*:1396*//*1397:*/
#line 16661 "./marpa.w"

AHMID _marpa_r_source_predecessor_state(Marpa_Recognizer r)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 16664 "./marpa.w"

unsigned int source_type;
SRCL source_link;
/*565:*/
#line 6162 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:565*/
#line 16667 "./marpa.w"

/*1337:*/
#line 15851 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 15852 "./marpa.w"

/*1335:*/
#line 15835 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1335*/
#line 15853 "./marpa.w"


/*:1337*/
#line 16668 "./marpa.w"

source_type= r->t_trace_source_type;
/*1403:*/
#line 16813 "./marpa.w"

source_link= r->t_trace_source_link;
if(!source_link){
MARPA_ERROR(MARPA_ERR_NO_TRACE_SRCL);
return failure_indicator;
}

/*:1403*/
#line 16670 "./marpa.w"

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

/*:1397*//*1398:*/
#line 16702 "./marpa.w"

Marpa_Symbol_ID _marpa_r_source_token(Marpa_Recognizer r,int*value_p)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 16705 "./marpa.w"

unsigned int source_type;
SRCL source_link;
/*565:*/
#line 6162 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:565*/
#line 16708 "./marpa.w"

/*1337:*/
#line 15851 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 15852 "./marpa.w"

/*1335:*/
#line 15835 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1335*/
#line 15853 "./marpa.w"


/*:1337*/
#line 16709 "./marpa.w"

source_type= r->t_trace_source_type;
/*1403:*/
#line 16813 "./marpa.w"

source_link= r->t_trace_source_link;
if(!source_link){
MARPA_ERROR(MARPA_ERR_NO_TRACE_SRCL);
return failure_indicator;
}

/*:1403*/
#line 16711 "./marpa.w"

if(source_type==SOURCE_IS_TOKEN){
if(value_p)*value_p= Value_of_SRCL(source_link);
return NSYID_of_SRCL(source_link);
}
MARPA_ERROR(invalid_source_type_code(source_type));
return failure_indicator;
}

/*:1398*//*1400:*/
#line 16733 "./marpa.w"

Marpa_Symbol_ID _marpa_r_source_leo_transition_symbol(Marpa_Recognizer r)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 16736 "./marpa.w"

unsigned int source_type;
SRCL source_link;
/*565:*/
#line 6162 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:565*/
#line 16739 "./marpa.w"

/*1337:*/
#line 15851 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 15852 "./marpa.w"

/*1335:*/
#line 15835 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1335*/
#line 15853 "./marpa.w"


/*:1337*/
#line 16740 "./marpa.w"

source_type= r->t_trace_source_type;
/*1403:*/
#line 16813 "./marpa.w"

source_link= r->t_trace_source_link;
if(!source_link){
MARPA_ERROR(MARPA_ERR_NO_TRACE_SRCL);
return failure_indicator;
}

/*:1403*/
#line 16742 "./marpa.w"

switch(source_type)
{
case SOURCE_IS_LEO:
return Leo_Transition_NSYID_of_SRCL(source_link);
}
MARPA_ERROR(invalid_source_type_code(source_type));
return failure_indicator;
}

/*:1400*//*1402:*/
#line 16776 "./marpa.w"

Marpa_Earley_Set_ID _marpa_r_source_middle(Marpa_Recognizer r)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 16779 "./marpa.w"

YIM predecessor_yim= NULL;
unsigned int source_type;
SRCL source_link;
/*565:*/
#line 6162 "./marpa.w"

const GRAMMAR g= G_of_R(r);
/*:565*/
#line 16783 "./marpa.w"

/*1337:*/
#line 15851 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 15852 "./marpa.w"

/*1335:*/
#line 15835 "./marpa.w"

if(_MARPA_UNLIKELY(Input_Phase_of_R(r)==R_BEFORE_INPUT)){
MARPA_ERROR(MARPA_ERR_RECCE_NOT_STARTED);
return failure_indicator;
}
/*:1335*/
#line 15853 "./marpa.w"


/*:1337*/
#line 16784 "./marpa.w"

source_type= r->t_trace_source_type;
/*1403:*/
#line 16813 "./marpa.w"

source_link= r->t_trace_source_link;
if(!source_link){
MARPA_ERROR(MARPA_ERR_NO_TRACE_SRCL);
return failure_indicator;
}

/*:1403*/
#line 16786 "./marpa.w"


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

/*:1402*//*1407:*/
#line 16851 "./marpa.w"

int _marpa_b_or_node_set(Marpa_Bocage b,
Marpa_Or_Node_ID or_node_id)
{
OR or_node;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 16856 "./marpa.w"

/*1049:*/
#line 12235 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1049*/
#line 16857 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 16858 "./marpa.w"

/*1405:*/
#line 16829 "./marpa.w"

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
/*:1405*/
#line 16859 "./marpa.w"

/*1406:*/
#line 16841 "./marpa.w"

{
if(_MARPA_UNLIKELY(!ORs_of_B(b)))
{
MARPA_ERROR(MARPA_ERR_NO_OR_NODES);
return failure_indicator;
}
or_node= OR_of_B_by_ID(b,or_node_id);
}

/*:1406*/
#line 16860 "./marpa.w"

return YS_Ord_of_OR(or_node);
}

/*:1407*//*1408:*/
#line 16864 "./marpa.w"

int _marpa_b_or_node_origin(Marpa_Bocage b,
Marpa_Or_Node_ID or_node_id)
{
OR or_node;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 16869 "./marpa.w"

/*1049:*/
#line 12235 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1049*/
#line 16870 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 16871 "./marpa.w"

/*1405:*/
#line 16829 "./marpa.w"

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
/*:1405*/
#line 16872 "./marpa.w"

/*1406:*/
#line 16841 "./marpa.w"

{
if(_MARPA_UNLIKELY(!ORs_of_B(b)))
{
MARPA_ERROR(MARPA_ERR_NO_OR_NODES);
return failure_indicator;
}
or_node= OR_of_B_by_ID(b,or_node_id);
}

/*:1406*/
#line 16873 "./marpa.w"

return Origin_Ord_of_OR(or_node);
}

/*:1408*//*1409:*/
#line 16877 "./marpa.w"

Marpa_NRL_ID _marpa_b_or_node_nrl(Marpa_Bocage b,
Marpa_Or_Node_ID or_node_id)
{
OR or_node;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 16882 "./marpa.w"

/*1049:*/
#line 12235 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1049*/
#line 16883 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 16884 "./marpa.w"

/*1405:*/
#line 16829 "./marpa.w"

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
/*:1405*/
#line 16885 "./marpa.w"

/*1406:*/
#line 16841 "./marpa.w"

{
if(_MARPA_UNLIKELY(!ORs_of_B(b)))
{
MARPA_ERROR(MARPA_ERR_NO_OR_NODES);
return failure_indicator;
}
or_node= OR_of_B_by_ID(b,or_node_id);
}

/*:1406*/
#line 16886 "./marpa.w"

return NRLID_of_OR(or_node);
}

/*:1409*//*1410:*/
#line 16890 "./marpa.w"

int _marpa_b_or_node_position(Marpa_Bocage b,
Marpa_Or_Node_ID or_node_id)
{
OR or_node;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 16895 "./marpa.w"

/*1049:*/
#line 12235 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1049*/
#line 16896 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 16897 "./marpa.w"

/*1405:*/
#line 16829 "./marpa.w"

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
/*:1405*/
#line 16898 "./marpa.w"

/*1406:*/
#line 16841 "./marpa.w"

{
if(_MARPA_UNLIKELY(!ORs_of_B(b)))
{
MARPA_ERROR(MARPA_ERR_NO_OR_NODES);
return failure_indicator;
}
or_node= OR_of_B_by_ID(b,or_node_id);
}

/*:1406*/
#line 16899 "./marpa.w"

return Position_of_OR(or_node);
}

/*:1410*//*1411:*/
#line 16903 "./marpa.w"

int _marpa_b_or_node_is_whole(Marpa_Bocage b,
Marpa_Or_Node_ID or_node_id)
{
OR or_node;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 16908 "./marpa.w"

/*1049:*/
#line 12235 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1049*/
#line 16909 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 16910 "./marpa.w"

/*1405:*/
#line 16829 "./marpa.w"

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
/*:1405*/
#line 16911 "./marpa.w"

/*1406:*/
#line 16841 "./marpa.w"

{
if(_MARPA_UNLIKELY(!ORs_of_B(b)))
{
MARPA_ERROR(MARPA_ERR_NO_OR_NODES);
return failure_indicator;
}
or_node= OR_of_B_by_ID(b,or_node_id);
}

/*:1406*/
#line 16912 "./marpa.w"

return Position_of_OR(or_node)>=Length_of_NRL(NRL_of_OR(or_node))?1:0;
}

/*:1411*//*1412:*/
#line 16916 "./marpa.w"

int _marpa_b_or_node_is_semantic(Marpa_Bocage b,
Marpa_Or_Node_ID or_node_id)
{
OR or_node;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 16921 "./marpa.w"

/*1049:*/
#line 12235 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1049*/
#line 16922 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 16923 "./marpa.w"

/*1405:*/
#line 16829 "./marpa.w"

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
/*:1405*/
#line 16924 "./marpa.w"

/*1406:*/
#line 16841 "./marpa.w"

{
if(_MARPA_UNLIKELY(!ORs_of_B(b)))
{
MARPA_ERROR(MARPA_ERR_NO_OR_NODES);
return failure_indicator;
}
or_node= OR_of_B_by_ID(b,or_node_id);
}

/*:1406*/
#line 16925 "./marpa.w"

return!NRL_has_Virtual_LHS(NRL_of_OR(or_node));
}

/*:1412*//*1413:*/
#line 16929 "./marpa.w"

int _marpa_b_or_node_first_and(Marpa_Bocage b,
Marpa_Or_Node_ID or_node_id)
{
OR or_node;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 16934 "./marpa.w"

/*1049:*/
#line 12235 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1049*/
#line 16935 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 16936 "./marpa.w"

/*1405:*/
#line 16829 "./marpa.w"

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
/*:1405*/
#line 16937 "./marpa.w"

/*1406:*/
#line 16841 "./marpa.w"

{
if(_MARPA_UNLIKELY(!ORs_of_B(b)))
{
MARPA_ERROR(MARPA_ERR_NO_OR_NODES);
return failure_indicator;
}
or_node= OR_of_B_by_ID(b,or_node_id);
}

/*:1406*/
#line 16938 "./marpa.w"

return First_ANDID_of_OR(or_node);
}

/*:1413*//*1414:*/
#line 16942 "./marpa.w"

int _marpa_b_or_node_last_and(Marpa_Bocage b,
Marpa_Or_Node_ID or_node_id)
{
OR or_node;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 16947 "./marpa.w"

/*1049:*/
#line 12235 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1049*/
#line 16948 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 16949 "./marpa.w"

/*1405:*/
#line 16829 "./marpa.w"

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
/*:1405*/
#line 16950 "./marpa.w"

/*1406:*/
#line 16841 "./marpa.w"

{
if(_MARPA_UNLIKELY(!ORs_of_B(b)))
{
MARPA_ERROR(MARPA_ERR_NO_OR_NODES);
return failure_indicator;
}
or_node= OR_of_B_by_ID(b,or_node_id);
}

/*:1406*/
#line 16951 "./marpa.w"

return First_ANDID_of_OR(or_node)
+AND_Count_of_OR(or_node)-1;
}

/*:1414*//*1415:*/
#line 16956 "./marpa.w"

int _marpa_b_or_node_and_count(Marpa_Bocage b,
Marpa_Or_Node_ID or_node_id)
{
OR or_node;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 16961 "./marpa.w"

/*1049:*/
#line 12235 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1049*/
#line 16962 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 16963 "./marpa.w"

/*1405:*/
#line 16829 "./marpa.w"

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
/*:1405*/
#line 16964 "./marpa.w"

/*1406:*/
#line 16841 "./marpa.w"

{
if(_MARPA_UNLIKELY(!ORs_of_B(b)))
{
MARPA_ERROR(MARPA_ERR_NO_OR_NODES);
return failure_indicator;
}
or_node= OR_of_B_by_ID(b,or_node_id);
}

/*:1406*/
#line 16965 "./marpa.w"

return AND_Count_of_OR(or_node);
}

/*:1415*//*1418:*/
#line 16979 "./marpa.w"

int _marpa_o_or_node_and_node_count(Marpa_Order o,
Marpa_Or_Node_ID or_node_id)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 16983 "./marpa.w"

/*1094:*/
#line 12640 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1049:*/
#line 12235 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1049*/
#line 12642 "./marpa.w"


/*:1094*/
#line 16984 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 16985 "./marpa.w"

/*1405:*/
#line 16829 "./marpa.w"

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
/*:1405*/
#line 16986 "./marpa.w"

if(!O_is_Default(o))
{
ANDID**const and_node_orderings= o->t_and_node_orderings;
ANDID*ordering= and_node_orderings[or_node_id];
if(ordering)return ordering[0];
}
{
OR or_node;
/*1406:*/
#line 16841 "./marpa.w"

{
if(_MARPA_UNLIKELY(!ORs_of_B(b)))
{
MARPA_ERROR(MARPA_ERR_NO_OR_NODES);
return failure_indicator;
}
or_node= OR_of_B_by_ID(b,or_node_id);
}

/*:1406*/
#line 16995 "./marpa.w"

return AND_Count_of_OR(or_node);
}
}

/*:1418*//*1419:*/
#line 17000 "./marpa.w"

int _marpa_o_or_node_and_node_id_by_ix(Marpa_Order o,
Marpa_Or_Node_ID or_node_id,int ix)
{
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 17004 "./marpa.w"

/*1094:*/
#line 12640 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1049:*/
#line 12235 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1049*/
#line 12642 "./marpa.w"


/*:1094*/
#line 17005 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 17006 "./marpa.w"

/*1405:*/
#line 16829 "./marpa.w"

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
/*:1405*/
#line 17007 "./marpa.w"

if(!O_is_Default(o))
{
ANDID**const and_node_orderings= o->t_and_node_orderings;
ANDID*ordering= and_node_orderings[or_node_id];
if(ordering)return ordering[1+ix];
}
{
OR or_node;
/*1406:*/
#line 16841 "./marpa.w"

{
if(_MARPA_UNLIKELY(!ORs_of_B(b)))
{
MARPA_ERROR(MARPA_ERR_NO_OR_NODES);
return failure_indicator;
}
or_node= OR_of_B_by_ID(b,or_node_id);
}

/*:1406*/
#line 17016 "./marpa.w"

return First_ANDID_of_OR(or_node)+ix;
}
}

/*:1419*//*1421:*/
#line 17023 "./marpa.w"

int _marpa_b_and_node_count(Marpa_Bocage b)
{
/*1049:*/
#line 12235 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1049*/
#line 17026 "./marpa.w"

/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 17027 "./marpa.w"

/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 17028 "./marpa.w"

return AND_Count_of_B(b);
}

/*:1421*//*1423:*/
#line 17054 "./marpa.w"

int _marpa_b_and_node_parent(Marpa_Bocage b,
Marpa_And_Node_ID and_node_id)
{
AND and_node;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 17059 "./marpa.w"

/*1049:*/
#line 12235 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1049*/
#line 17060 "./marpa.w"

/*1422:*/
#line 17032 "./marpa.w"

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

/*:1422*/
#line 17061 "./marpa.w"

return ID_of_OR(OR_of_AND(and_node));
}

/*:1423*//*1424:*/
#line 17065 "./marpa.w"

int _marpa_b_and_node_predecessor(Marpa_Bocage b,
Marpa_And_Node_ID and_node_id)
{
AND and_node;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 17070 "./marpa.w"

/*1049:*/
#line 12235 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1049*/
#line 17071 "./marpa.w"

/*1422:*/
#line 17032 "./marpa.w"

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

/*:1422*/
#line 17072 "./marpa.w"

{
const OR predecessor_or= Predecessor_OR_of_AND(and_node);
const ORID predecessor_or_id= 
predecessor_or?ID_of_OR(predecessor_or):-1;
return predecessor_or_id;
}
}

/*:1424*//*1425:*/
#line 17081 "./marpa.w"

int _marpa_b_and_node_cause(Marpa_Bocage b,
Marpa_And_Node_ID and_node_id)
{
AND and_node;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 17086 "./marpa.w"

/*1049:*/
#line 12235 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1049*/
#line 17087 "./marpa.w"

/*1422:*/
#line 17032 "./marpa.w"

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

/*:1422*/
#line 17088 "./marpa.w"

{
const OR cause_or= Cause_OR_of_AND(and_node);
const ORID cause_or_id= 
OR_is_Token(cause_or)?-1:ID_of_OR(cause_or);
return cause_or_id;
}
}

/*:1425*//*1426:*/
#line 17097 "./marpa.w"

int _marpa_b_and_node_symbol(Marpa_Bocage b,
Marpa_And_Node_ID and_node_id)
{
AND and_node;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 17102 "./marpa.w"

/*1049:*/
#line 12235 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1049*/
#line 17103 "./marpa.w"

/*1422:*/
#line 17032 "./marpa.w"

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

/*:1422*/
#line 17104 "./marpa.w"

{
const OR cause_or= Cause_OR_of_AND(and_node);
const ISYID symbol_id= 
OR_is_Token(cause_or)?NSYID_of_OR(cause_or):-1;
return symbol_id;
}
}

/*:1426*//*1427:*/
#line 17113 "./marpa.w"

Marpa_Symbol_ID _marpa_b_and_node_token(Marpa_Bocage b,
Marpa_And_Node_ID and_node_id,int*value_p)
{
AND and_node;
OR cause_or;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 17119 "./marpa.w"

/*1049:*/
#line 12235 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1049*/
#line 17120 "./marpa.w"

/*1422:*/
#line 17032 "./marpa.w"

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

/*:1422*/
#line 17121 "./marpa.w"


cause_or= Cause_OR_of_AND(and_node);
if(!OR_is_Token(cause_or))return-1;
if(value_p)*value_p= Value_of_OR(cause_or);
return NSYID_of_OR(cause_or);
}

/*:1427*//*1428:*/
#line 17136 "./marpa.w"

Marpa_Earley_Set_ID _marpa_b_and_node_middle(Marpa_Bocage b,
Marpa_And_Node_ID and_node_id)
{
AND and_node;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 17141 "./marpa.w"

/*1049:*/
#line 12235 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1049*/
#line 17142 "./marpa.w"

/*1422:*/
#line 17032 "./marpa.w"

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

/*:1422*/
#line 17143 "./marpa.w"

{
const OR predecessor_or= Predecessor_OR_of_AND(and_node);
if(predecessor_or)
{
return YS_Ord_of_OR(predecessor_or);
}
}
return Origin_Ord_of_OR(OR_of_AND(and_node));
}

/*:1428*//*1431:*/
#line 17176 "./marpa.w"

int _marpa_t_nook_or_node(Marpa_Tree t,int nook_id)
{
NOOK nook;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 17180 "./marpa.w"

/*1122:*/
#line 13108 "./marpa.w"

ORDER o= O_of_T(t);
/*1094:*/
#line 12640 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1049:*/
#line 12235 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1049*/
#line 12642 "./marpa.w"


/*:1094*/
#line 13110 "./marpa.w"
;

/*:1122*/
#line 17181 "./marpa.w"

/*1430:*/
#line 17158 "./marpa.w"
{
NOOK base_nook;
/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 17160 "./marpa.w"

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

/*:1430*/
#line 17182 "./marpa.w"

return ID_of_OR(OR_of_NOOK(nook));
}

/*:1431*//*1432:*/
#line 17186 "./marpa.w"

int _marpa_t_nook_choice(Marpa_Tree t,int nook_id)
{
NOOK nook;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 17190 "./marpa.w"

/*1122:*/
#line 13108 "./marpa.w"

ORDER o= O_of_T(t);
/*1094:*/
#line 12640 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1049:*/
#line 12235 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1049*/
#line 12642 "./marpa.w"


/*:1094*/
#line 13110 "./marpa.w"
;

/*:1122*/
#line 17191 "./marpa.w"

/*1430:*/
#line 17158 "./marpa.w"
{
NOOK base_nook;
/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 17160 "./marpa.w"

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

/*:1430*/
#line 17192 "./marpa.w"

return Choice_of_NOOK(nook);
}

/*:1432*//*1433:*/
#line 17196 "./marpa.w"

int _marpa_t_nook_parent(Marpa_Tree t,int nook_id)
{
NOOK nook;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 17200 "./marpa.w"

/*1122:*/
#line 13108 "./marpa.w"

ORDER o= O_of_T(t);
/*1094:*/
#line 12640 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1049:*/
#line 12235 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1049*/
#line 12642 "./marpa.w"


/*:1094*/
#line 13110 "./marpa.w"
;

/*:1122*/
#line 17201 "./marpa.w"

/*1430:*/
#line 17158 "./marpa.w"
{
NOOK base_nook;
/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 17160 "./marpa.w"

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

/*:1430*/
#line 17202 "./marpa.w"

return Parent_of_NOOK(nook);
}

/*:1433*//*1434:*/
#line 17206 "./marpa.w"

int _marpa_t_nook_cause_is_ready(Marpa_Tree t,int nook_id)
{
NOOK nook;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 17210 "./marpa.w"

/*1122:*/
#line 13108 "./marpa.w"

ORDER o= O_of_T(t);
/*1094:*/
#line 12640 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1049:*/
#line 12235 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1049*/
#line 12642 "./marpa.w"


/*:1094*/
#line 13110 "./marpa.w"
;

/*:1122*/
#line 17211 "./marpa.w"

/*1430:*/
#line 17158 "./marpa.w"
{
NOOK base_nook;
/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 17160 "./marpa.w"

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

/*:1430*/
#line 17212 "./marpa.w"

return NOOK_Cause_is_Expanded(nook);
}

/*:1434*//*1435:*/
#line 17216 "./marpa.w"

int _marpa_t_nook_predecessor_is_ready(Marpa_Tree t,int nook_id)
{
NOOK nook;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 17220 "./marpa.w"

/*1122:*/
#line 13108 "./marpa.w"

ORDER o= O_of_T(t);
/*1094:*/
#line 12640 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1049:*/
#line 12235 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1049*/
#line 12642 "./marpa.w"


/*:1094*/
#line 13110 "./marpa.w"
;

/*:1122*/
#line 17221 "./marpa.w"

/*1430:*/
#line 17158 "./marpa.w"
{
NOOK base_nook;
/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 17160 "./marpa.w"

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

/*:1430*/
#line 17222 "./marpa.w"

return NOOK_Predecessor_is_Expanded(nook);
}

/*:1435*//*1436:*/
#line 17226 "./marpa.w"

int _marpa_t_nook_is_cause(Marpa_Tree t,int nook_id)
{
NOOK nook;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 17230 "./marpa.w"

/*1122:*/
#line 13108 "./marpa.w"

ORDER o= O_of_T(t);
/*1094:*/
#line 12640 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1049:*/
#line 12235 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1049*/
#line 12642 "./marpa.w"


/*:1094*/
#line 13110 "./marpa.w"
;

/*:1122*/
#line 17231 "./marpa.w"

/*1430:*/
#line 17158 "./marpa.w"
{
NOOK base_nook;
/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 17160 "./marpa.w"

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

/*:1430*/
#line 17232 "./marpa.w"

return NOOK_is_Cause(nook);
}

/*:1436*//*1437:*/
#line 17236 "./marpa.w"

int _marpa_t_nook_is_predecessor(Marpa_Tree t,int nook_id)
{
NOOK nook;
/*1318:*/
#line 15726 "./marpa.w"
const int failure_indicator= -2;

/*:1318*/
#line 17240 "./marpa.w"

/*1122:*/
#line 13108 "./marpa.w"

ORDER o= O_of_T(t);
/*1094:*/
#line 12640 "./marpa.w"

const BOCAGE b= B_of_O(o);
/*1049:*/
#line 12235 "./marpa.w"

const GRAMMAR g UNUSED= G_of_B(b);

/*:1049*/
#line 12642 "./marpa.w"


/*:1094*/
#line 13110 "./marpa.w"
;

/*:1122*/
#line 17241 "./marpa.w"

/*1430:*/
#line 17158 "./marpa.w"
{
NOOK base_nook;
/*1338:*/
#line 15859 "./marpa.w"

if(HEADER_VERSION_MISMATCH){
MARPA_ERROR(MARPA_ERR_HEADERS_DO_NOT_MATCH);
return failure_indicator;
}
if(_MARPA_UNLIKELY(!IS_G_OK(g))){
MARPA_ERROR(g->t_error);
return failure_indicator;
}

/*:1338*/
#line 17160 "./marpa.w"

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

/*:1430*/
#line 17242 "./marpa.w"

return NOOK_is_Predecessor(nook);
}

/*:1437*//*1439:*/
#line 17257 "./marpa.w"

void marpa_debug_handler_set(int(*debug_handler)(const char*,...))
{
marpa__debug_handler= debug_handler;
}

/*:1439*//*1440:*/
#line 17263 "./marpa.w"

int marpa_debug_level_set(int new_level)
{
const int old_level= marpa__debug_level;
marpa__debug_level= new_level;
return old_level;
}


/*:1440*/
#line 17447 "./marpa.w"


/*:1458*/
