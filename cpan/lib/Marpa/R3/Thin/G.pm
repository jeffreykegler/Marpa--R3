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

package Marpa::R3::Thin::G;

use 5.010001;
use warnings;
use strict;

use vars qw($VERSION $STRING_VERSION);
$VERSION        = '4.001_014';
$STRING_VERSION = $VERSION;
$VERSION        = eval $VERSION;

# Additional Perl methods for the XS package Marpa::R3::Thin::G

sub Marpa::R3::Thin::G::ahm_describe {
    my ($grammar_c, $ahm_id)        = @_;
    my $irl_id = $grammar_c->_marpa_g_ahm_irl($ahm_id);
    my $dot_position = $grammar_c->_marpa_g_ahm_position($ahm_id);
    if ($dot_position < 0) { return 'R' . $irl_id . q{$} }
    return 'R' . $irl_id . q{:} . $dot_position;
}

1;
