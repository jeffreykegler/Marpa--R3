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

package Marpa::R3::Trace::G;

use 5.010001;
use warnings;
use strict;

use vars qw($VERSION $STRING_VERSION);
$VERSION        = '4.001_015';
$STRING_VERSION = $VERSION;
$VERSION        = eval $VERSION;

sub new {
    my ( $class ) = @_;
    my $self = bless [], $class;
    my $grammar_c = Marpa::R3::Thin::G->new( { if => 1 } );
    $self->[Marpa::R3::Internal::Trace::G::C] = $grammar_c;
    $self->[Marpa::R3::Internal::Trace::G::ISYID_BY_NAME] = {};
    $self->[Marpa::R3::Internal::Trace::G::NAME_BY_ISYID] = [];
    return $self;
} ## end sub new

sub grammar {
    my ($self) = @_;
    return $self->[Marpa::R3::Internal::Trace::G::C];
}

sub symbol_by_name {
    my ( $self, $name ) = @_;
    return $self->[Marpa::R3::Internal::Trace::G::ISYID_BY_NAME]->{$name};
}

sub symbol_name {
    my ( $self, $symbol_id ) = @_;
    my $symbol_name = $self->[Marpa::R3::Internal::Trace::G::NAME_BY_ISYID]->[$symbol_id];
    $symbol_name = 'R' . $symbol_id if not defined $symbol_name;
    return $symbol_name;
} ## end sub symbol_name

sub formatted_symbol_name {
    my ( $self, $symbol_id ) = @_;
    my $symbol_name = $self->symbol_name($symbol_id);
    # As-is if all word characters
    return $symbol_name if $symbol_name =~ m/ \A \w* \z/xms;
    # As-is if ends in right bracket
    return $symbol_name if $symbol_name =~ m/ \] \z/xms;
    return '<' . $symbol_name . '>';
}

sub symbol_name_set {
    my ( $self, $name, $symbol_id ) = @_;
    $self->[Marpa::R3::Internal::Trace::G::NAME_BY_ISYID]->[$symbol_id] = $name;
    $self->[Marpa::R3::Internal::Trace::G::ISYID_BY_NAME]->{$name} = $symbol_id;
    return $symbol_id;
} ## end sub symbol_name_set

sub symbol_new {
    my ( $self, $name ) = @_;
    return $self->symbol_name_set( $name,
        $self->[Marpa::R3::Internal::Trace::G::C]->symbol_new() );
}

sub symbol_force {
    my ( $self, $name ) = @_;
    return $self->[Marpa::R3::Internal::Trace::G::ISYID_BY_NAME]->{$name} // $self->symbol_new($name);
}

sub rule {
    my ( $self, $rule_id ) = @_;
    my $grammar_c     = $self->[Marpa::R3::Internal::Trace::G::C];
    my $rule_length = $grammar_c->rule_length($rule_id);
    my $lhs = $self->symbol_name( $grammar_c->rule_lhs($rule_id) );
    my @rhs =
        map { $self->symbol_name( $grammar_c->rule_rhs( $rule_id, $_ ) ) }
        ( 0 .. $rule_length - 1 );
    return ($lhs, @rhs);
}

# Expand a rule into a list of symbol IDs
sub rule_expand {
    my ( $self, $rule_id ) = @_;
    my $grammar_c     = $self->[Marpa::R3::Internal::Trace::G::C];
    my $rule_length = $grammar_c->rule_length($rule_id);
    return if not defined $rule_length;
    my $lhs         = ( $grammar_c->rule_lhs($rule_id) );
    return ( $lhs,
        map { $grammar_c->rule_rhs( $rule_id, $_ ) }
            ( 0 .. $rule_length - 1 ) );
} ## end sub rule_expand

sub dotted_rule {
    my ( $self, $rule_id, $dot_position ) = @_;
    my $grammar_c     = $self->[Marpa::R3::Internal::Trace::G::C];
    my $rule_length = $grammar_c->rule_length($rule_id);
    $dot_position = $rule_length if $dot_position < 0;
    my $lhs = $self->formatted_symbol_name( $grammar_c->rule_lhs($rule_id) );
    my @rhs =
        map { $self->formatted_symbol_name( $grammar_c->rule_rhs( $rule_id, $_ ) ) }
        ( 0 .. $rule_length - 1 );
    $dot_position = 0 if $dot_position < 0;
    splice( @rhs, $dot_position, 0, q{.} );
    return join q{ }, $lhs, q{::=}, @rhs;
} ## end sub dotted_rule

sub brief_rule {
    my ( $self, $rule_id ) = @_;
    my $grammar_c     = $self->[Marpa::R3::Internal::Trace::G::C];
    my $rule_length = $grammar_c->rule_length($rule_id);
    my $lhs = $self->formatted_symbol_name( $grammar_c->rule_lhs($rule_id) );
    my @rhs =
        map { $self->formatted_symbol_name( $grammar_c->rule_rhs( $rule_id, $_ ) ) }
        ( 0 .. $rule_length - 1 );
    my $minimum = $grammar_c->sequence_min($rule_id);
    my @quantifier = ();
    if (defined $minimum) {
         push @quantifier, ($minimum <= 0 ? q{ *} : q{ +});
    }
    return join q{ }, $lhs, q{::=}, @rhs, @quantifier;
} ## end sub dotted_rule

sub progress_report {
    my ( $self, $recce, $ordinal ) = @_;
    my $result = q{};
    $ordinal //= $recce->latest_earley_set();
    $recce->progress_report_start($ordinal);
    ITEM: while (1) {
        my ( $rule_id, $dot_position, $origin ) = $recce->progress_item();
        last ITEM if not defined $rule_id;
        $result
            .= q{@}
            . $origin . q{: }
            . $self->dotted_rule( $rule_id, $dot_position ) . "\n";
    } ## end ITEM: while (1)
    $recce->progress_report_finish();
    return $result;
} ## end sub progress_report

sub lexer_progress_report {
    my ( $self, $slr, $ordinal ) = @_;
    my $thin_slr = $slr->[Marpa::R3::Internal::Scanless::R::SLR_C];
    my $result = q{};
    $ordinal //= $thin_slr->lexer_latest_earley_set();
    $thin_slr->lexer_progress_report_start($ordinal);
    ITEM: while (1) {
        my ( $rule_id, $dot_position, $origin ) = $thin_slr->lexer_progress_item();
        last ITEM if not defined $rule_id;
        $result
            .= q{@}
            . $origin . q{: }
            . $self->dotted_rule( $rule_id, $dot_position ) . "\n";
    } ## end ITEM: while (1)
    $thin_slr->lexer_progress_report_finish();
    return $result;
} ## end sub progress_report

sub show_dotted_irl {
    my ( $self, $irl_id, $dot_position ) = @_;
    my $grammar_c     = $self->[Marpa::R3::Internal::Trace::G::C];
    my $lhs_id     = $grammar_c->_marpa_g_irl_lhs($irl_id);
    my $irl_length = $grammar_c->_marpa_g_irl_length($irl_id);

    my $text = $self->isy_name($lhs_id) . q{ ::=};

    if ( $dot_position < 0 ) {
        $dot_position = $irl_length;
    }

    my @rhs_names = ();
    for my $ix ( 0 .. $irl_length - 1 ) {
        my $rhs_nsy_id = $grammar_c->_marpa_g_irl_rhs( $irl_id, $ix );
        my $rhs_nsy_name = $self->isy_name($rhs_nsy_id);
        push @rhs_names, $rhs_nsy_name;
    }

    POSITION: for my $position ( 0 .. scalar @rhs_names ) {
        if ( $position == $dot_position ) {
            $text .= q{ .};
        }
        my $name = $rhs_names[$position];
        next POSITION if not defined $name;
        $text .= " $name";
    } ## end POSITION: for my $position ( 0 .. scalar @rhs_names )

    return $text;

} ## end sub show_dotted_irl

sub show_ahm {
    my ( $self, $item_id ) = @_;
    my $grammar_c     = $self->[Marpa::R3::Internal::Trace::G::C];
    my $postdot_id = $grammar_c->_marpa_g_ahm_postdot($item_id);
    my $text       = "AHM $item_id: ";
    my @properties = ();
    if ( $postdot_id < 0 ) {
        push @properties, 'completion';
    }
    else {
        my $postdot_symbol_name = $self->isy_name($postdot_id);
        push @properties, qq{postdot = "$postdot_symbol_name"};
    }
    $text .= join q{; }, @properties;
    $text .= "\n" . ( q{ } x 4 );
    $text .= $self->show_brief_ahm($item_id) . "\n";
    return $text;
} ## end sub show_ahm

sub show_brief_ahm {
    my ( $self, $item_id ) = @_;
    my $grammar_c     = $self->[Marpa::R3::Internal::Trace::G::C];
    my $postdot_id = $grammar_c->_marpa_g_ahm_postdot($item_id);
    my $irl_id     = $grammar_c->_marpa_g_ahm_irl($item_id);
    my $position   = $grammar_c->_marpa_g_ahm_position($item_id);
    return $self->show_dotted_irl( $irl_id, $position );
} ## end sub show_brief_ahm

sub show_ahms {
    my ($self)    = @_;
    my $grammar_c     = $self->[Marpa::R3::Internal::Trace::G::C];
    my $text      = q{};
    my $count     = $grammar_c->_marpa_g_ahm_count();
    for my $AHFA_item_id ( 0 .. $count - 1 ) {
        $text .= $self->show_ahm($AHFA_item_id);
    }
    return $text;
} ## end sub show_ahms

sub isy_name {
    my ( $self, $id ) = @_;
    my $grammar_c     = $self->[Marpa::R3::Internal::Trace::G::C];

    # The next is a little roundabout to prevent auto-instantiation
    my $name = '[ISY' . $id . ']';

    GEN_NAME: {

        if ( $grammar_c->_marpa_g_nsy_is_start($id) ) {
            my $source_id = $grammar_c->_marpa_g_source_xsy($id);
            $name = $self->symbol_name($source_id);
            $name .= q<[']>;
            last GEN_NAME;
        } ## end if ( $grammar_c->_marpa_g_nsy_is_start($id) )

        my $lhs_xrl = $grammar_c->_marpa_g_nsy_lhs_xrl($id);
        if ( defined $lhs_xrl and defined $grammar_c->sequence_min($lhs_xrl) )
        {
            my $original_lhs_id = $grammar_c->rule_lhs($lhs_xrl);
            $name = $self->symbol_name($original_lhs_id) . '[Seq]';
            last GEN_NAME;
        } ## end if ( defined $lhs_xrl and defined $grammar_c->sequence_min...)

        my $xrl_offset = $grammar_c->_marpa_g_nsy_xrl_offset($id);
        if ($xrl_offset) {
            my $original_lhs_id = $grammar_c->rule_lhs($lhs_xrl);
            $name =
                  $self->symbol_name($original_lhs_id) . '[R'
                . $lhs_xrl . q{:}
                . $xrl_offset . ']';
            last GEN_NAME;
        } ## end if ($xrl_offset)

        my $source_id = $grammar_c->_marpa_g_source_xsy($id);
        $name = $self->symbol_name($source_id);
        $name .= '[]' if $grammar_c->_marpa_g_nsy_is_nulling($id);

    } ## end GEN_NAME:

    return $name;
} ## end sub isy_name

sub show_rule {
    my ( $self, $rule_id ) = @_;

    my $grammar_c     = $self->[Marpa::R3::Internal::Trace::G::C];
    my @comment   = ();

    $grammar_c->rule_length($rule_id) == 0 and push @comment, 'empty';
    $grammar_c->rule_is_productive($rule_id) or push @comment, 'unproductive';
    $grammar_c->rule_is_accessible($rule_id) or push @comment, 'inaccessible';

    my $text = $self->brief_rule($rule_id);


    if (@comment) {
        $text .= q{ } . ( join q{ }, q{/*}, @comment, q{*/} );
    }

    return $text .= "\n";

}    # sub show_rule

sub Marpa::R3::Trace::G::show_rules {
    my ( $tracer, $verbose ) = @_;
    my $text     = q{};
    $verbose    //= 0;

    my $grammar_c = $tracer->[Marpa::R3::Internal::Trace::G::C];
    my $grammar_name = $tracer->[Marpa::R3::Internal::Trace::G::NAME];
    my $xbnf_by_irlid = $tracer->[Marpa::R3::Internal::Trace::G::XBNF_BY_IRLID];

    for my $irlid ( 0 .. $grammar_c->highest_rule_id() ) {

        my $xbnf    = $xbnf_by_irlid->[$irlid];
        my $minimum = $grammar_c->sequence_min($irlid);
        my @quantifier =
          defined $minimum ? $minimum <= 0 ? (q{*}) : (q{+}) : ();
        my $lhs_id      = $grammar_c->rule_lhs($irlid);
        my $rule_length = $grammar_c->rule_length($irlid);
        my @rhs_ids =
          map { $grammar_c->rule_rhs( $irlid, $_ ) } ( 0 .. $rule_length - 1 );
        $text .= join q{ }, $grammar_name, "R$irlid",
          $tracer->symbol_in_display_form($lhs_id),
          '::=',
          ( map { $tracer->symbol_in_display_form($_) } @rhs_ids ),
          @quantifier;
        $text .= "\n";

        if ( $verbose >= 2 ) {

            my @comment = ();
            $grammar_c->rule_length($irlid) == 0
              and push @comment, 'empty';
            $grammar_c->_marpa_g_rule_is_used($irlid)
              or push @comment, '!used';
            $grammar_c->rule_is_productive($irlid)
              or push @comment, 'unproductive';
            $grammar_c->rule_is_accessible($irlid)
              or push @comment, 'inaccessible';
            $xbnf->[Marpa::R3::Internal::XBNF::DISCARD_SEPARATION]
              and push @comment, 'discard_sep';

            if (@comment) {
                $text .= q{  } . ( join q{ }, q{/*}, @comment, q{*/} ) . "\n";
            }

            $text .= "  Symbol IDs: <$lhs_id> ::= "
              . ( join q{ }, map { "<$_>" } @rhs_ids ) . "\n";

        } ## end if ( $verbose >= 2 )

        if ( $verbose >= 3 ) {

            $text .=
                "  Internal symbols: <"
              . $tracer->symbol_name($lhs_id)
              . q{> ::= }
              . (
                join q{ },
                map { '<' . $tracer->symbol_name($_) . '>' } @rhs_ids
              ) . "\n";

        } ## end if ( $verbose >= 3 )

    } ## end for my $rule ( @{$rules} )

    return $text;
}

# Return DSL form of symbol
# Does no checking
sub Marpa::R3::Trace::G::symbol_dsl_form {
    my ( $tracer, $isyid ) = @_;
    my $xsy_by_isyid   = $tracer->[Marpa::R3::Internal::Trace::G::XSY_BY_ISYID];
    my $xsy = $xsy_by_isyid->[$isyid];
    return if not defined $xsy;
    return $xsy->[Marpa::R3::Internal::XSY::DSL_FORM];
}

# Return display form of symbol
# Does lots of checking and makes use of alternatives.
sub Marpa::R3::Trace::G::symbol_in_display_form {
    my ( $tracer, $symbol_id ) = @_;
    my $text = $tracer->symbol_dsl_form( $symbol_id )
      // $tracer->symbol_name($symbol_id);
    return "<!No symbol with ID $symbol_id!>" if not defined $text;
    return ( $text =~ m/\s/xms ) ? "<$text>" : $text;
}

sub Marpa::R3::Trace::G::show_symbols {
    my ( $tracer, $verbose, ) = @_;
    my $text = q{};
    $verbose    //= 0;

    my $grammar_name = $tracer->[Marpa::R3::Internal::Trace::G::NAME];
    my $grammar_c     = $tracer->[Marpa::R3::Internal::Trace::G::C];

    for my $symbol_id ( 0 .. $grammar_c->highest_symbol_id() ) {

        $text .= join q{ }, $grammar_name, "S$symbol_id",
          $tracer->symbol_in_display_form( $symbol_id );
        $text .= "\n";

        if ( $verbose >= 2 ) {

            my @tag_list = ();
            $grammar_c->symbol_is_productive($symbol_id)
              or push @tag_list, 'unproductive';
            $grammar_c->symbol_is_accessible($symbol_id)
              or push @tag_list, 'inaccessible';
            $grammar_c->symbol_is_nulling($symbol_id)
              and push @tag_list, 'nulling';
            $grammar_c->symbol_is_terminal($symbol_id)
              and push @tag_list, 'terminal';

            if (@tag_list) {
                $text .= q{  } . ( join q{ }, q{/*}, @tag_list, q{*/} ) . "\n";
            }

            $text .=
              "  Internal name: <" . $tracer->symbol_name($symbol_id) . qq{>\n};

        } ## end if ( $verbose >= 2 )

        if ( $verbose >= 3 ) {

            my $dsl_form = $tracer->symbol_dsl_form( $symbol_id );
            if ($dsl_form) { $text .= qq{  SLIF name: $dsl_form\n}; }

        } ## end if ( $verbose >= 3 )

    } ## end for my $symbol ( @{$symbols} )

    return $text;
}

# This logic deals with gaps in the rule numbering.
# Currently there are none, but Libmarpa does not
# guarantee this.
sub Marpa::R3::Trace::G::rule_ids {
    my ($tracer) = @_;
    my $grammar_c = $tracer->[Marpa::R3::Internal::Trace::G::C];
    return 0 .. $grammar_c->highest_rule_id();
}

# This logic deals with gaps in the symbol numbering.
# Currently there are none, but Libmarpa does not
# guarantee this.
sub Marpa::R3::Trace::G::symbol_ids {
    my ($tracer) = @_;
    my $grammar_c = $tracer->[Marpa::R3::Internal::Trace::G::C];
    return 0 .. $grammar_c->highest_symbol_id();
}

sub Marpa::R3::Trace::G::brief_irl {
    my ( $tracer, $irl_id ) = @_;
    my $grammar_c = $tracer->[Marpa::R3::Internal::Trace::G::C];
    my $lhs_id    = $grammar_c->_marpa_g_irl_lhs($irl_id);
    my $text = $irl_id . ': ' . $tracer->isy_name($lhs_id) . ' ->';
    if ( my $rh_length = $grammar_c->_marpa_g_irl_length($irl_id) ) {
        my @rhs_ids = ();
        for my $ix ( 0 .. $rh_length - 1 ) {
            push @rhs_ids, $grammar_c->_marpa_g_irl_rhs( $irl_id, $ix );
        }
        $text .= q{ } . ( join q{ }, map { $tracer->isy_name($_) } @rhs_ids );
    } ## end if ( my $rh_length = $grammar_c->_marpa_g_irl_length...)
    return $text;
}

sub Marpa::R3::Trace::G::show_isys {
    my ($tracer) = @_;
    my $grammar_c = $tracer->[Marpa::R3::Internal::Trace::G::C];
    my $text      = q{};
    for my $isy_id ( 0 .. $grammar_c->_marpa_g_nsy_count() - 1 ) {
        $text .= $tracer->show_isy($isy_id);
    }
    return $text;
}

sub Marpa::R3::Trace::G::show_isy {
    my ( $tracer, $isy_id ) = @_;
    my $grammar_c = $tracer->[Marpa::R3::Internal::Trace::G::C];
    my $text      = q{};

    my $name = $tracer->isy_name($isy_id);
    $text .= "$isy_id: $name";

    my @tag_list = ();
    $grammar_c->_marpa_g_nsy_is_nulling($isy_id)
        and push @tag_list, 'nulling';

    $text .= join q{ }, q{,}, @tag_list if scalar @tag_list;
    $text .= "\n";

    return $text;

}

sub Marpa::R3::Trace::G::show_irls {
    my ($tracer) = @_;
    my $grammar_c = $tracer->[Marpa::R3::Internal::Trace::G::C];
    my $text      = q{};
    for my $irl_id ( 0 .. $grammar_c->_marpa_g_irl_count() - 1 ) {
        $text .= $tracer->brief_irl($irl_id) . "\n";
    }
    return $text;
}

sub Marpa::R3::Trace::G::error {
    my ($tracer) = @_;
    my $grammar_c = $tracer->[Marpa::R3::Internal::Trace::G::C];
    return $grammar_c->error();
}

# Internal, for use with in coordinating thin and thick
# interfaces.  NOT DOCUMENTED.
sub Marpa::R3::Trace::G::start_symbol {
    my ( $tracer ) = @_;
    my $grammar_c = $tracer->[Marpa::R3::Internal::Trace::G::C];
    return $grammar_c->start_symbol();
}

sub Marpa::R3::Trace::G::rule_name {
    my ( $tracer, $rule_id ) = @_;
    my $xbnf_by_irlid = $tracer->[Marpa::R3::Internal::Trace::G::XBNF_BY_IRLID];
    my $xbnf  = $xbnf_by_irlid->[$rule_id];
    return "Non-existent rule $rule_id" if not defined $xbnf;
    my $name = $xbnf->[Marpa::R3::Internal::XBNF::NAME];
    return $name if defined $name;
    my ( $lhs_id ) = $tracer->rule_expand($rule_id);
    return $tracer->symbol_name($lhs_id);
}

1;
