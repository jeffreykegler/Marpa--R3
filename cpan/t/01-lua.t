#!perl
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

# Tests of Marpa's Lua interpreter

use 5.010001;
use strict;
use warnings;

use Test::More tests => 1;
use English qw( -no_match_vars );
use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

my $result = Marpa::R3::Lua::exec(q{hi});
Marpa::R3::Test::is($result, 'salve, munde');

# vim: expandtab shiftwidth=4:
