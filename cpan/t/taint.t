#!perl -T
# Marpa::R3 is Copyright (C) 2018, Jeffrey Kegler.
#
# This module is free software; you can redistribute it and/or modify it
# under the same terms as Perl 5.10.1. For more details, see the full text
# of the licenses in the directory LICENSES.
#
# This program is distributed in the hope that it will be
# useful, but it is provided "as is" and without any express
# or implied warranties. For details, see the full text of
# of the licenses in the directory LICENSES.

# Test of scannerless parsing for tainted grammars

use 5.010001;

use strict;
use warnings;

use English qw( -no_match_vars );
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use Test::More tests => 1;
use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

# $^X is always tainted
my $tainted_grammar = q{:start ::= A A ~ 'a' # } . $^X;

# Make sure we fail with tainted data
# -T flag was set on first line for this script
my $eval_ok = eval {
    Marpa::R3::Grammar->new( { source => \$tainted_grammar } );
    1;
};
if ($eval_ok) {
    Test::More::fail("Tainted grammar accepted -- that should not happen");
}
else {
    my $eval_error = $EVAL_ERROR;
    Test::More::like(
        $eval_error,
qr/Attempt \s+ to \s+ use \s+ a \s+ tainted \s+ input \s+ string \s+ in \s+ .*read.*
 \s+ Marpa::R3 \s+ is \s+ insecure \s+ for \s+ use \s+ with \s+ tainted \s+ data/xms,
        "Tainted grammar detected and rejected"
    );
} ## end else [ if ($eval_ok) ]

# vim: expandtab shiftwidth=4:
