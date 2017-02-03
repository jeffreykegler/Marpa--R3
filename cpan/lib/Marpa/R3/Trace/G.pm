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
$VERSION        = '4.001_036';
$STRING_VERSION = $VERSION;
$VERSION        = eval $VERSION;

sub new {
    my ( $class, $slg, $name ) = @_;
    my $tracer = bless [], $class;
    my $thin_slg = $slg->[Marpa::R3::Internal::Scanless::G::C];
    $tracer->[Marpa::R3::Internal::Trace::G::SLG_C] = $thin_slg;
    $tracer->[Marpa::R3::Internal::Trace::G::NAME] = $name;
    my $lmw_name = 'lmw_' . (lc $name) . 'g';
    $tracer->[Marpa::R3::Internal::Trace::G::LMW_NAME]
      = $lmw_name;
    $slg->[Marpa::R3::Internal::Scanless::G::PER_LMG]->{$lmw_name} = $tracer;

    my $field_name = 'lmw_' . (lc $name) . 'g';
    my $grammar_c = Marpa::R3::Thin::G->new($thin_slg, $field_name);
    $tracer->[Marpa::R3::Internal::Trace::G::C] = $grammar_c;

    $thin_slg->call_by_tag(
        ('@' . __FILE__ . ':' .  __LINE__),
      <<'END_OF_LUA', 's', (lc $name));
    local g, short_name = ...
    lmw_g_name = 'lmw_' .. short_name .. 'g'
    local lmw_g = g[lmw_g_name]
    lmw_g.short_name = short_name
    lmw_g:post_metal()
END_OF_LUA

    return $tracer;
} ## end sub new

sub grammar {
    my ($self) = @_;
    return $self->[Marpa::R3::Internal::Trace::G::C];
}

sub name {
    my ($self) = @_;
    return $self->[Marpa::R3::Internal::Trace::G::NAME];
}

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
