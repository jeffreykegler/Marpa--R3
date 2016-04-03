#!perl -T
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

# CENSUS: SLIF TEST -- KEEP


# Test of scannerless parsing for tainted grammars

use 5.010001;
use strict;
use warnings;

use Test::More tests => 1;
use English qw( -no_match_vars );
use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

# $^X is always tainted
my $tainted_grammar = q{:start ::= A A ~ 'a' # } . $^X;

# Make sure we fail with tainted data
# -T flag was set on first line for this script
my $eval_ok = eval {
    Marpa::R3::Scanless::G->new( { source => \$tainted_grammar } );
    1;
};
if ($eval_ok) {
    Test::More::fail("Tainted grammar accepted -- that should not happen");
}
else {
    my $eval_error = $EVAL_ERROR;
    Test::More::like(
        $eval_error,
        qr/Attempt \s+ to \s+ use \s+ a \s+ tainted \s+ input \s+ string \s+ with \s+ Marpa::R3
    \s+ Marpa::R3 \s+ is \s+ insecure \s+ for \s+ use \s+ with \s+ tainted \s+ data/xms,
        "Tainted grammar detected and rejected"
    );
} ## end else [ if ($eval_ok) ]

# vim: expandtab shiftwidth=4:
