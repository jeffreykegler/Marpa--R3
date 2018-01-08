#!perl
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

use 5.010001;
use warnings;
use strict;

use Test::More tests => 5;
use lib 'lib';
use lib 'blib/arch';
use lib 'inc';

BEGIN {
    Test::More::use_ok('Devel::SawAmpersand');
    Test::More::use_ok('Marpa::R3');
    Test::More::use_ok('Marpa::R3::Test');
} ## end BEGIN

Test::More::ok( !Devel::SawAmpersand::sawampersand(), 'PL_sawampersand set' );
