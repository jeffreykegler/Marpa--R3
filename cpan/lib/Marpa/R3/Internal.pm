# Marpa::R3 is Copyright (C) 2017, Jeffrey Kegler.
#
# This module is free software; you can redistribute it and/or modify it
# under the same terms as Perl 5.10.1. For more details, see the full text
# of the licenses in the directory LICENSES.
#
# This program is distributed in the hope that it will be
# useful, but it is provided "as is" and without any express
# or implied warranties. For details, see the full text of
# of the licenses in the directory LICENSES.

# DO NOT EDIT THIS FILE DIRECTLY
# It was generated by make_internal_pm.pl

package Marpa::R3::Internal;

use 5.010001;
use strict;
use warnings;
use Carp;

use vars qw($VERSION $STRING_VERSION);
$VERSION        = '4.001_050';
$STRING_VERSION = $VERSION;
$VERSION = eval $VERSION;


package Marpa::R3::Internal::Glade;
use constant ID => 0;
use constant SYMCHES => 1;
use constant VISITED => 2;
use constant REGISTERED => 3;

package Marpa::R3::Internal::Choicepoint;
use constant ASF => 0;
use constant FACTORING_STACK => 1;
use constant OR_NODE_IN_USE => 2;

package Marpa::R3::Internal::Nook;
use constant PARENT => 0;
use constant OR_NODE => 1;
use constant FIRST_CHOICE => 2;
use constant LAST_CHOICE => 3;
use constant IS_CAUSE => 4;
use constant IS_PREDECESSOR => 5;
use constant CAUSE_IS_EXPANDED => 6;
use constant PREDECESSOR_IS_EXPANDED => 7;

package Marpa::R3::Internal::ASF;
use constant SLR => 0;
use constant SLV => 1;
use constant END_OF_PARSE => 2;
use constant LEXEME_RESOLUTIONS => 3;
use constant RULE_RESOLUTIONS => 4;
use constant FACTORING_MAX => 5;
use constant RULE_BLESSINGS => 6;
use constant SYMBOL_BLESSINGS => 7;
use constant DEFAULT_RULE_BLESSING_PACKAGE => 8;
use constant DEFAULT_TOKEN_BLESSING_PACKAGE => 9;
use constant OR_NODES => 10;
use constant GLADES => 11;
use constant INTSET_BY_KEY => 12;
use constant NEXT_INTSET_ID => 13;
use constant NIDSET_BY_ID => 14;
use constant POWERSET_BY_ID => 15;

package Marpa::R3::Internal::ASF::Traverse;
use constant ASF => 0;
use constant VALUES => 1;
use constant CODE => 2;
use constant PER_TRAVERSE_OBJECT => 3;
use constant GLADE => 4;
use constant SYMCH_IX => 5;
use constant FACTORING_IX => 6;

package Marpa::R3::Internal::Nidset;
use constant ID => 0;
use constant NIDS => 1;

package Marpa::R3::Internal::Powerset;
use constant ID => 0;
use constant NIDSET_IDS => 1;

package Marpa::R3::Internal_G;
use constant L => 0;
use constant REGIX => 1;
use constant TRACE_FILE_HANDLE => 2;
use constant CONSTANTS => 3;
use constant CHARACTER_CLASS_TABLE => 4;
use constant BLESS_PACKAGE => 5;
use constant SEMANTICS_PACKAGE => 6;
use constant TRACE_ACTIONS => 7;
use constant NULL_VALUES => 8;
use constant CLOSURE_BY_SYMBOL_ID => 9;
use constant CLOSURE_BY_RULE_ID => 10;

package Marpa::R3::Internal_R;
use constant SLG => 0;
use constant L => 1;
use constant REGIX => 2;
use constant TRACE_FILE_HANDLE => 3;
use constant EVENT_HANDLERS => 4;
use constant CURRENT_EVENT => 5;

package Marpa::R3::Internal_V;
use constant SLR => 0;
use constant L => 1;
use constant REGIX => 2;
use constant TRACE_FILE_HANDLE => 3;

1;
