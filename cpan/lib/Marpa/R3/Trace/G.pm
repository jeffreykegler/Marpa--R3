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
$VERSION        = '4.001_031';
$STRING_VERSION = $VERSION;
$VERSION        = eval $VERSION;

sub new {
    my ( $class, $thin_slg, $name ) = @_;
    my $self = bless [], $class;
    $self->[Marpa::R3::Internal::Trace::G::SLG_C] = $thin_slg;
    $self->[Marpa::R3::Internal::Trace::G::NAME] = $name;

    my $field_name = 'lmw_' . (lc $name) . 'g';
    my $grammar_c = Marpa::R3::Thin::G->new($thin_slg, $field_name);
    $self->[Marpa::R3::Internal::Trace::G::C] = $grammar_c;

    $thin_slg->call_by_tag(
        ('@' . __FILE__ . ':' .  __LINE__),
      <<'END_OF_LUA', 's', (lc $name));
    local g, short_name = ...
    lmw_g_name = 'lmw_' .. short_name .. 'g'
    local lmw_g = g[lmw_g_name]
    lmw_g.short_name = short_name
    lmw_g.isyid_by_name = {}
    lmw_g.name_by_isyid = {}
END_OF_LUA

    return $self;
} ## end sub new

sub grammar {
    my ($self) = @_;
    return $self->[Marpa::R3::Internal::Trace::G::C];
}

sub name {
    my ($self) = @_;
    return $self->[Marpa::R3::Internal::Trace::G::NAME];
}

# A development hack -- I will delete this once tracers
# are eliminated
sub lmw_name {
    my ($tracer) = @_;
    my $short_lmw_g_name = $tracer->[Marpa::R3::Internal::Trace::G::NAME];
    return 'lmw_' . (lc $short_lmw_g_name) . 'g';
}

sub symbol_by_name {
    my ( $self, $symbol_name ) = @_;
    my $thin_slg = $self->[Marpa::R3::Internal::Trace::G::SLG_C];
    my $short_lmw_g_name = $self->[Marpa::R3::Internal::Trace::G::NAME];
    my $lmw_g_name = 'lmw_' . (lc $short_lmw_g_name) . 'g';
    my ($symbol_id) = $thin_slg->call_by_tag(
        ('@' . __FILE__ . ':' .  __LINE__),
      <<'END_OF_LUA', 'ss', $lmw_g_name, $symbol_name);
    local g, lmw_g_name, symbol_name = ...
    local lmw_g = g[lmw_g_name]
    return lmw_g.isyid_by_name[symbol_name]
END_OF_LUA
    return $symbol_id;
}

sub symbol_name {
    my ( $self, $symbol_id ) = @_;
    my $thin_slg = $self->[Marpa::R3::Internal::Trace::G::SLG_C];

    my $short_lmw_g_name = $self->[Marpa::R3::Internal::Trace::G::NAME];
    my $lmw_g_name = 'lmw_' . (lc $short_lmw_g_name) . 'g';
    my ($sym_name) = $thin_slg->call_by_tag(
        ('@' . __FILE__ . ':' .  __LINE__),
      <<'END_OF_LUA', 'si', $lmw_g_name, $symbol_id);
    local g, lmw_g_name, symbol_id = ...
    local lmw_g = g[lmw_g_name]
    return lmw_g:symbol_name(symbol_id)
END_OF_LUA
    return $sym_name;

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

sub symbol_new {
    my ( $tracer, $symbol_name ) = @_;
    my $thin_slg         = $tracer->[Marpa::R3::Internal::Trace::G::SLG_C];
    my $short_lmw_g_name = $tracer->[Marpa::R3::Internal::Trace::G::NAME];
    my $lmw_g_name       = 'lmw_' . ( lc $short_lmw_g_name ) . 'g';

    my ($symbol_id) =
      $thin_slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 'ss', $lmw_g_name, $symbol_name );
    local g, lmw_g_name, symbol_name = ...
    local lmw_g = g[lmw_g_name]
    local symbol_id = lmw_g:symbol_new()
    lmw_g.isyid_by_name[symbol_name] = symbol_id
    lmw_g.name_by_isyid[symbol_id] = symbol_name
    return symbol_id
END_OF_LUA

    return $symbol_id;
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
}

sub show_dotted_irl {
    my ( $self, $irl_id, $dot_position ) = @_;
    my $thin_slg         = $self->[Marpa::R3::Internal::Trace::G::SLG_C];
    my $short_name = $self->[Marpa::R3::Internal::Trace::G::NAME];
    my ($result) =
      $thin_slg->call_by_tag(
        ('@' . __FILE__ . ':' .  __LINE__),
	<<'END_OF_LUA', 'sii', (lc $short_name), $irl_id, $dot_position );
    local g, short_name, irl_id, dot_position = ...
    local lmw_g_field_name = 'lmw_' .. short_name .. 'g'
    -- print('lmw_g_field_name', lmw_g_field_name)
    local lmw_g = g[lmw_g_field_name]
    return lmw_g:show_dotted_irl(irl_id, dot_position)
END_OF_LUA
    return $result;
}
 ## end sub show_dotted_irl

sub show_ahm {
    my ( $self, $item_id ) = @_;
    my $thin_slg         = $self->[Marpa::R3::Internal::Trace::G::SLG_C];
    my $short_lmw_g_name = $self->[Marpa::R3::Internal::Trace::G::NAME];
    my $lmw_g_name       = 'lmw_' . ( lc $short_lmw_g_name ) . 'g';

    my ($text) = $thin_slg->call_by_tag(
        ('@' . __FILE__ . ':' .  __LINE__),
	<<'END_OF_LUA', 'si', $lmw_g_name, $item_id );
    local g, lmw_g_name, item_id = ...
    local lmw_g = g[lmw_g_name]
    return lmw_g:show_ahm(item_id)
END_OF_LUA

    return $text;
} ## end sub show_ahm

sub show_briefer_ahm {
    my ( $self, $item_id ) = @_;
    my $thin_slg         = $self->[Marpa::R3::Internal::Trace::G::SLG_C];
    my $short_lmw_g_name = $self->[Marpa::R3::Internal::Trace::G::NAME];
    my $lmw_g_name       = 'lmw_' . ( lc $short_lmw_g_name ) . 'g';

    my ($text) = $thin_slg->call_by_tag(
        ('@' . __FILE__ . ':' .  __LINE__),
	<<'END_OF_LUA', 'si', $lmw_g_name, $item_id );
    local g, lmw_g_name, item_id = ...
    local lmw_g = g[lmw_g_name]
    local irl_id = lmw_g:_ahm_irl(item_id)
    local dot_position = lmw_g:_ahm_position(item_id)
    if (dot_position < 0 ) then
        return string.format("R%d$", irl_id)
    end
    return string.format("R%d:%d", irl_id, dot_position)
END_OF_LUA

    return $text;

}

sub show_ahms {
    my ( $self ) = @_;
    my $thin_slg         = $self->[Marpa::R3::Internal::Trace::G::SLG_C];
    my $short_lmw_g_name = $self->[Marpa::R3::Internal::Trace::G::NAME];
    my $lmw_g_name       = 'lmw_' . ( lc $short_lmw_g_name ) . 'g';

    my ($text) = $thin_slg->call_by_tag(
        ('@' . __FILE__ . ':' .  __LINE__),
	<<'END_OF_LUA', 's', $lmw_g_name );
    local g, lmw_g_name, item_id = ...
    local lmw_g = g[lmw_g_name]
    local pieces = {}
    local count = lmw_g:_ahm_count()
    for i = 0, count -1 do
        pieces[#pieces+1] = lmw_g:show_ahm(i)
    end
    return table.concat(pieces)
END_OF_LUA

    return $text;

} ## end sub show_ahms

sub isy_name {
    my ( $self, $symbol_id ) = @_;
    my $thin_slg         = $self->[Marpa::R3::Internal::Trace::G::SLG_C];
    my $short_lmw_g_name = $self->[Marpa::R3::Internal::Trace::G::NAME];
    my $lmw_g_name       = 'lmw_' . ( lc $short_lmw_g_name ) . 'g';
    my ($sym_name) =
      $thin_slg->call_by_tag(
        ('@' . __FILE__ . ':' .  __LINE__),
	<<'END_OF_LUA', 'si', $lmw_g_name, $symbol_id );
    local g, lmw_g_name, symbol_id = ...
    local lmw_g = g[lmw_g_name]
    return lmw_g:isy_name(symbol_id)
END_OF_LUA
    return $sym_name;

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

    my $thin_slg         = $tracer->[Marpa::R3::Internal::Trace::G::SLG_C];
    my $grammar_name = $tracer->[Marpa::R3::Internal::Trace::G::NAME];
    my $short_lmw_g_name = $tracer->[Marpa::R3::Internal::Trace::G::NAME];
    my $lmw_g_name       = 'lmw_' . ( lc $short_lmw_g_name ) . 'g';

    my $grammar_c = $tracer->[Marpa::R3::Internal::Trace::G::C];
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

    my ($rule_is_used) = $thin_slg->call_by_tag(
        ('@' . __FILE__ . ':' .  __LINE__),
	<<'END_OF_LUA', 'si', $lmw_g_name, $irlid );
    local g, lmw_g_name, irl_id = ...
    local lmw_g = g[lmw_g_name]
    return lmw_g:_rule_is_used(irl_id)
END_OF_LUA

            $rule_is_used or push @comment, '!used';
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
    my ( $self, $irl_id ) = @_;
    my $thin_slg         = $self->[Marpa::R3::Internal::Trace::G::SLG_C];
    my $short_lmw_g_name = $self->[Marpa::R3::Internal::Trace::G::NAME];
    my $lmw_g_name       = 'lmw_' . ( lc $short_lmw_g_name ) . 'g';

    my ($text) = $thin_slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 'si', $lmw_g_name, $irl_id );
    local g, lmw_g_name, irl_id = ...
    local lmw_g = g[lmw_g_name]
    return lmw_g:brief_irl(irl_id)
END_OF_LUA

    return $text;
}

sub Marpa::R3::Trace::G::show_isys {
    my ( $tracer ) = @_;
    my $thin_slg         = $tracer->[Marpa::R3::Internal::Trace::G::SLG_C];
    my $short_lmw_g_name = $tracer->[Marpa::R3::Internal::Trace::G::NAME];
    my $lmw_g_name       = 'lmw_' . ( lc $short_lmw_g_name ) . 'g';
    my ($result) =
      $thin_slg->call_by_tag(
        ('@' . __FILE__ . ':' .  __LINE__),
	<<'END_OF_LUA', 's', $lmw_g_name );
    local g, lmw_g_name = ...
    local lmw_g = g[lmw_g_name]
    local nsy_count = lmw_g:_nsy_count()
    local pieces = {}
    for isy_id = 0, nsy_count - 1 do
        pieces[#pieces+1] = lmw_g:show_isy(isy_id)
    end
    return table.concat(pieces)
END_OF_LUA
    return $result;
}

sub Marpa::R3::Trace::G::show_irls {
    my ($tracer) = @_;
    my $thin_slg         = $tracer->[Marpa::R3::Internal::Trace::G::SLG_C];
    my $short_lmw_g_name = $tracer->[Marpa::R3::Internal::Trace::G::NAME];
    my $lmw_g_name       = 'lmw_' . ( lc $short_lmw_g_name ) . 'g';
    my ($result) =
      $thin_slg->call_by_tag(
        ('@' . __FILE__ . ':' .  __LINE__),
	<<'END_OF_LUA', 's', $lmw_g_name );
    local g, lmw_g_name = ...
    local lmw_g = g[lmw_g_name]
    local irl_count = lmw_g:_irl_count()
    local pieces = {}
    for irl_id = 0, irl_count - 1 do
        pieces[#pieces+1] = lmw_g:brief_irl(irl_id)
    end
    pieces[#pieces+1] = ''
    return table.concat(pieces, '\n')
END_OF_LUA
    return $result;
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
