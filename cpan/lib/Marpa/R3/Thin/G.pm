# Copyright 2016 Jeffrey Kegler
# This file is part of Marpa::R3.  Marpa::R3 is free software: you can
# redistribute it and/or modify it under the terms of the GNU Lesser
# General Public License as published by the Free Software Foundation,
# either version 3 of the License, or (at your option) any later version.
#
# Marpa::R3 is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser
# General Public License along with Marpa::R3.  If not, see
# http://www.gnu.org/licenses/.

package Marpa::R3::Thin::G;

use 5.010001;
use warnings;
use strict;

use vars qw($VERSION $STRING_VERSION);
$VERSION        = '4.001_003';
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
