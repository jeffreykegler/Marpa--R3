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

package Marpa::R3::Test;

use 5.010001;
use strict;
use warnings;

use Data::Dumper;

Marpa::R3::exception('Test::More not loaded')
    if not defined &Test::More::is;

BEGIN {
    ## no critic (BuiltinFunctions::ProhibitStringyEval)
    ## no critic (ErrorHandling::RequireCheckingReturnValueOfEval)
    eval 'use Test::Differences';
}

sub Marpa::R3::Test::is {
    goto &Test::Differences::eq_or_diff
        if defined &Test::Differences::eq_or_diff && @_ > 1;
    @_ = map { ref $_ ? Data::Dumper::Dumper(@_) : $_ } @_;
    goto &Test::More::is;
} ## end sub Marpa::R3::Test::is

1;

