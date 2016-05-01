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

package Marpa::R3::Scanless::G;

use 5.010001;

use warnings;

# There's a problem with this perlcritic check
# as of 9 Aug 2010
no warnings qw(recursion qw);

use strict;

package Marpa::R3::Grammar;

use vars qw($VERSION $STRING_VERSION);
$VERSION        = '4.001_002';
$STRING_VERSION = $VERSION;
## no critic(BuiltinFunctions::ProhibitStringyEval)
$VERSION = eval $VERSION;
## use critic

package Marpa::R3::Internal::Scanless::G;

use English qw( -no_match_vars );

use Marpa::R3::Trace::G;

package Marpa::R3::Internal::Scanless::G;
# INTERNAL OK AFTER HERE _marpa_
1;

# vim: expandtab shiftwidth=4:
