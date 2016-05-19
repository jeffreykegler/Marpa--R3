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

use 5.010001;
use strict;
use warnings;
use ExtUtils::Install;
use Fatal qw(open close mkdir chdir);
use File::Spec 0.82;
use English qw( -no_match_vars );

use Config;
use ExtUtils::MakeMaker;

use vars qw($VERSION $STRING_VERSION);
$VERSION        = '4.001_007';
$STRING_VERSION = $VERSION;
## no critic (BuiltinFunctions::ProhibitStringyEval)
$VERSION = eval $VERSION;
## use critic

my $myextlib = join q{ }, '../../../../lua/marpa_lua$(LIB_EXT)';

WriteMakefile(
    'NAME'    => 'Marpa::R3::Lua',
    'VERSION' => $STRING_VERSION,
    'INC' =>
      '-I../../../../xs/ -I../../../../engine/read_only/ -I../../../../lua/',
    MYEXTLIB => $myextlib,
);
