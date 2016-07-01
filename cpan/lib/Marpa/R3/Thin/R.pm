# Marpa::R3 is Copyright (C) 2016, Jeffrey Kegler.
#
# This module is free software; you can redistribute it and/or modify it
# under the same terms as Perl 5.10.1. For more details, see the full text
# of the licenses in the directory LICENSES.
#
# This program is distributed in the hope that it will be
# useful, but it is provided “as is” and without any express
# or implied warranties. For details, see the full text of
# of the licenses in the directory LICENSES.

package Marpa::R3::Thin::R;

use 5.010001;
use warnings;
use strict;

use vars qw($VERSION $STRING_VERSION);
$VERSION        = '4.001_016';
$STRING_VERSION = $VERSION;
$VERSION        = eval $VERSION;

# Additional Perl methods for the XS package Marpa::R3::Thin::R

sub Marpa::R3::Thin::R::show_leo_item {
    my ($recce_c, $tracer)        = @_;
    my $grammar_c = $tracer->grammar();
    my $leo_base_state = $recce_c->_marpa_r_leo_base_state();
    return if not defined $leo_base_state;
    my $trace_earley_set      = $recce_c->_marpa_r_trace_earley_set();
    my $trace_earleme         = $recce_c->earleme($trace_earley_set);
    my $postdot_symbol_id     = $recce_c->_marpa_r_postdot_item_symbol();
    my $postdot_symbol_name   = $tracer->isy_name($postdot_symbol_id);
    my $predecessor_symbol_id = $recce_c->_marpa_r_leo_predecessor_symbol();
    my $base_origin_set_id    = $recce_c->_marpa_r_leo_base_origin();
    my $base_origin_earleme   = $recce_c->earleme($base_origin_set_id);

    my $text = sprintf 'L%d@%d', $postdot_symbol_id, $trace_earleme;
    my @link_texts = qq{"$postdot_symbol_name"};
    if ( defined $predecessor_symbol_id ) {
        push @link_texts, sprintf 'L%d@%d', $predecessor_symbol_id,
            $base_origin_earleme;
    }
    push @link_texts, sprintf 'S%d@%d-%d', $leo_base_state,
        $base_origin_earleme,
        $trace_earleme;
    $text .= ' [' . ( join '; ', @link_texts ) . ']';
    return $text;
}

# Assumes trace token source link set by caller
sub Marpa::R3::Thin::R::show_token_link_choice {
    my ( $recce_c, $tracer, $current_earleme, $token_values ) = @_;
    my $grammar_c = $tracer->grammar();
    my $text    = q{};
    my @pieces  = ();
    my ( $token_id, $value_ix ) = $recce_c->_marpa_r_source_token();
    my $predecessor_ahm = $recce_c->_marpa_r_source_predecessor_state();
    my $origin_set_id     = $recce_c->_marpa_r_earley_item_origin();
    my $origin_earleme    = $recce_c->earleme($origin_set_id);
    my $middle_earleme    = $origin_earleme;

    if ( defined $predecessor_ahm ) {
        my $middle_set_id = $recce_c->_marpa_r_source_middle();
        $middle_earleme = $recce_c->earleme($middle_set_id);
        push @pieces,
              'c='
            . $grammar_c->ahm_describe($predecessor_ahm)
            . q{@}
            . $origin_earleme . q{-}
            . $middle_earleme;
    } ## end if ( defined $predecessor_ahm )
    my $symbol_name = $tracer->isy_name($token_id);
    push @pieces, 's=' . $symbol_name;
    my $token_length = $current_earleme - $middle_earleme;
    my $value = $token_values->[$value_ix];
    my $token_dump = Data::Dumper->new( [ \$value ] )->Terse(1)->Dump;
    chomp $token_dump;
    push @pieces, "t=$token_dump";
    return '[' . ( join '; ', @pieces ) . ']';
}

# Assumes trace completion source link set by caller
sub Marpa::R3::Thin::R::show_completion_link_choice {
    my ( $recce_c, $tracer, $link_ahm_id, $current_earleme ) = @_;
    my $grammar_c = $tracer->grammar();
    my $text    = q{};
    my @pieces  = ();
    my $predecessor_state = $recce_c->_marpa_r_source_predecessor_state();
    my $origin_set_id     = $recce_c->_marpa_r_earley_item_origin();
    my $origin_earleme    = $recce_c->earleme($origin_set_id);
    my $middle_set_id     = $recce_c->_marpa_r_source_middle();
    my $middle_earleme    = $recce_c->earleme($middle_set_id);

    if ( defined $predecessor_state ) {
        push @pieces,
              'p='
            . $grammar_c->ahm_describe($predecessor_state) . q{@}
            . $origin_earleme . q{-}
            . $middle_earleme;
    } ## end if ( defined $predecessor_state )
    push @pieces,
          'c=' . $grammar_c->ahm_describe($link_ahm_id) . q{@}
        . $middle_earleme . q{-}
        . $current_earleme;
    return '[' . ( join '; ', @pieces ) . ']';
}

# Assumes trace completion source link set by caller
sub Marpa::R3::Thin::R::show_leo_link_choice {
    my ( $recce_c, $tracer, $link_ahm_id, $current_earleme ) = @_;
    my $grammar_c = $tracer->grammar();
    my $text           = q{};
    my @pieces         = ();
    my $middle_set_id  = $recce_c->_marpa_r_source_middle();
    my $middle_earleme = $recce_c->earleme($middle_set_id);
    my $leo_transition_symbol =
        $recce_c->_marpa_r_source_leo_transition_symbol();
    push @pieces, 'l=L' . $leo_transition_symbol . q{@} . $middle_earleme;
    push @pieces,
          'c=' . $grammar_c->ahm_describe($link_ahm_id)
        . q{@}
        . $middle_earleme . q{-}
        . $current_earleme;
    return '[' . ( join '; ', @pieces ) . ']';
} ## end sub Marpa::R3::show_leo_link_choice

# Assumes trace earley item was set by caller
sub Marpa::R3::Thin::R::show_earley_item {
    my ( $recce_c, $tracer, $current_es, $item_id, $token_values ) = @_;
    my $grammar_c = $tracer->grammar();

    my $ahm_id_of_yim = $recce_c->_marpa_r_earley_item_trace($item_id);
    return if not defined $ahm_id_of_yim;

    my $text           = q{};
    my $origin_set_id  = $recce_c->_marpa_r_earley_item_origin();
    my $earleme        = $recce_c->earleme($current_es);
    my $origin_earleme = $recce_c->earleme($origin_set_id);
    $text .= sprintf "ahm%d: %s@%d-%d", $ahm_id_of_yim,
        $grammar_c->ahm_describe($ahm_id_of_yim),
        $origin_earleme, $earleme;
    my @lines    = $text;
    my $irl_id = $grammar_c->_marpa_g_ahm_irl($ahm_id_of_yim);
    my $dot_position = $grammar_c->_marpa_g_ahm_position($ahm_id_of_yim);
    push @lines, qq{  }
        . $grammar_c->ahm_describe($ahm_id_of_yim)
        . q{: }
        . $tracer->show_dotted_irl($irl_id, $dot_position);
    my @sort_data = ();

    for (
        my $symbol_id = $recce_c->_marpa_r_first_token_link_trace();
        defined $symbol_id;
        $symbol_id = $recce_c->_marpa_r_next_token_link_trace()
        )
    {
        push @sort_data,
            [
            $recce_c->_marpa_r_source_middle(),
            $symbol_id,
            ( $recce_c->_marpa_r_source_predecessor_state() // -1 ),
            $recce_c->Marpa::R3::Thin::R::show_token_link_choice( $tracer, $earleme, $token_values )
            ];
    } ## end for ( my $symbol_id = $recce_c->_marpa_r_first_token_link_trace...)
    my @pieces = map { $_->[-1] } sort {
               $a->[0] <=> $b->[0]
            || $a->[1] <=> $b->[1]
            || $a->[2] <=> $b->[2]
    } @sort_data;
    @sort_data = ();
    for (
        my $cause_AHFA_id = $recce_c->_marpa_r_first_completion_link_trace();
        defined $cause_AHFA_id;
        $cause_AHFA_id = $recce_c->_marpa_r_next_completion_link_trace()
        )
    {
        push @sort_data,
            [
            $recce_c->_marpa_r_source_middle(),
            $cause_AHFA_id,
            ( $recce_c->_marpa_r_source_predecessor_state() // -1 ),
            $recce_c->Marpa::R3::Thin::R::show_completion_link_choice(
                $tracer, $cause_AHFA_id, $earleme
            )
            ];
    } ## end for ( my $cause_AHFA_id = $recce_c...)
    push @pieces, map { $_->[-1] } sort {
               $a->[0] <=> $b->[0]
            || $a->[1] <=> $b->[1]
            || $a->[2] <=> $b->[2]
    } @sort_data;
    @sort_data = ();
    for (
        my $link_ahm_id = $recce_c->_marpa_r_first_leo_link_trace();
        defined $link_ahm_id;
        $link_ahm_id = $recce_c->_marpa_r_next_leo_link_trace()
        )
    {
        push @sort_data,
            [
            $recce_c->_marpa_r_source_middle(),
            $link_ahm_id,
            $recce_c->_marpa_r_source_leo_transition_symbol(),
            $recce_c->Marpa::R3::Thin::R::show_leo_link_choice(
                $tracer, $link_ahm_id, $earleme
            )
            ];
    } ## end for ( my $link_ahm_id = $recce_c...)
    push @pieces, map { $_->[-1] } sort {
               $a->[0] <=> $b->[0]
            || $a->[1] <=> $b->[1]
            || $a->[2] <=> $b->[2]
    } @sort_data;
    push @lines, q{  } . join q{ }, @pieces if @pieces;
    return join "\n", @lines, q{};
}

sub Marpa::R3::Thin::R::show_earley_set {
    my ( $recce_c, $tracer, $traced_set_id, $token_values ) = @_;
    my $text      = q{};
    my @sorted_data = ();
    if ( not defined $recce_c->_marpa_r_earley_set_trace($traced_set_id) ) {
        return $text;
    }
    EARLEY_ITEM: for ( my $item_id = 0;; $item_id++ ) {
        my $item_desc = $recce_c->Marpa::R3::Thin::R::show_earley_item( $tracer, $traced_set_id, $item_id, $token_values );
        last EARLEY_ITEM if not defined $item_desc;
        # We do not sort these any more
        push @sorted_data, $item_desc;
    } ## end EARLEY_ITEM: for ( my $item_id = 0;; $item_id++ )
    my @sort_data = ();
    POSTDOT_ITEM:
    for (
        my $postdot_symbol_id = $recce_c->_marpa_r_first_postdot_item_trace();
        defined $postdot_symbol_id;
        $postdot_symbol_id = $recce_c->_marpa_r_next_postdot_item_trace()
        )
    {

        # If there is no base Earley item,
        # then this is not a Leo item, so we skip it
        my $leo_item_desc = $recce_c->Marpa::R3::Thin::R::show_leo_item($tracer);
        next POSTDOT_ITEM if not defined $leo_item_desc;
        push @sort_data, [ $postdot_symbol_id, $leo_item_desc ];
    } ## end POSTDOT_ITEM: for ( my $postdot_symbol_id = $recce_c...)
    push @sorted_data, join q{},
        map { $_->[-1] . "\n" } sort { $a->[0] <=> $b->[0] } @sort_data;
    return join q{}, @sorted_data;
}

sub Marpa::R3::Thin::R::show_and_nodes {
    my ($recce_c, $bocage) = @_;
    my $text;
    my @data = ();
    AND_NODE: for ( my $id = 0;; $id++ ) {
        my $parent      = $bocage->_marpa_b_and_node_parent($id);
        my $predecessor = $bocage->_marpa_b_and_node_predecessor($id);
        my $cause       = $bocage->_marpa_b_and_node_cause($id);
        my $symbol      = $bocage->_marpa_b_and_node_symbol($id);
        last AND_NODE if not defined $parent;
        my $origin            = $bocage->_marpa_b_or_node_origin($parent);
        my $set               = $bocage->_marpa_b_or_node_set($parent);
        my $irl_id            = $bocage->_marpa_b_or_node_irl($parent);
        my $position          = $bocage->_marpa_b_or_node_position($parent);
        my $origin_earleme    = $recce_c->earleme($origin);
        my $current_earleme   = $recce_c->earleme($set);
        my $middle_earley_set = $bocage->_marpa_b_and_node_middle($id);
        my $middle_earleme    = $recce_c->earleme($middle_earley_set);

#<<<  perltidy introduces trailing space on this
        my $desc =
              "And-node #$id: R"
            . $irl_id . q{:}
            . $position . q{@}
            . $origin_earleme . q{-}
            . $current_earleme;
#>>>
        my $cause_rule = -1;
        if ( defined $cause ) {
            my $cause_irl_id = $bocage->_marpa_b_or_node_irl($cause);
            $desc .= 'C' . $cause_irl_id;
        }
        else {
            $desc .= 'S' . $symbol;
        }
        $desc .= q{@} . $middle_earleme;
        push @data,
            [
            $origin_earleme, $current_earleme, $irl_id,
            $position,       $middle_earleme,  $cause_rule,
            ( $symbol // -1 ), $desc
            ];
    } ## end AND_NODE: for ( my $id = 0;; $id++ )
    my @sorted_data = map { $_->[-1] } sort {
               $a->[0] <=> $b->[0]
            or $a->[1] <=> $b->[1]
            or $a->[2] <=> $b->[2]
            or $a->[3] <=> $b->[3]
            or $a->[4] <=> $b->[4]
            or $a->[5] <=> $b->[5]
            or $a->[6] <=> $b->[6]
    } @data;
    return ( join "\n", @sorted_data ) . "\n";
}

sub Marpa::R3::Thin::R::show_or_nodes {
    my ( $recce_c, $bocage, $verbose ) = @_;
    my $text;
    my @data = ();
    my $id   = 0;
    OR_NODE: for ( ;; ) {
        my $origin   = $bocage->_marpa_b_or_node_origin($id);
        my $set      = $bocage->_marpa_b_or_node_set($id);
        my $irl_id   = $bocage->_marpa_b_or_node_irl($id);
        my $position = $bocage->_marpa_b_or_node_position($id);
        $id++;
        last OR_NODE if not defined $origin;
        my $origin_earleme  = $recce_c->earleme($origin);
        my $current_earleme = $recce_c->earleme($set);

#<<<  perltidy introduces trailing space on this
        my $desc =
              'R'
            . $irl_id . q{:}
            . $position . q{@}
            . $origin_earleme . q{-}
            . $current_earleme;
#>>>
        push @data,
            [ $origin_earleme, $current_earleme, $irl_id, $position, $desc ];
    } ## end OR_NODE: for ( ;; )
    my @sorted_data = map { $_->[-1] } sort {
               $a->[0] <=> $b->[0]
            or $a->[1] <=> $b->[1]
            or $a->[2] <=> $b->[2]
            or $a->[3] <=> $b->[3]
    } @data;
    return ( join "\n", @sorted_data ) . "\n";
}

1;
