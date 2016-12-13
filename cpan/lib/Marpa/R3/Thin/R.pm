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
$VERSION        = '4.001_027';
$STRING_VERSION = $VERSION;
$VERSION        = eval $VERSION;

# Additional Perl methods for the XS package Marpa::R3::Thin::R

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

1;
