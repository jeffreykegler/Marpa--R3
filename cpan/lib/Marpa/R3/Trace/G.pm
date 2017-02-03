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

1;

# vim: expandtab shiftwidth=4:

