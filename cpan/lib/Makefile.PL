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
$VERSION        = '4.001_008';
$STRING_VERSION = $VERSION;
## no critic (BuiltinFunctions::ProhibitStringyEval)
$VERSION = eval $VERSION;
## use critic

my @dirs = qw( Marpa );

undef &MY::postamble; # suppress warning
*MY::postamble = sub {

my $postamble = <<'END_OF_POSTAMBLE';

config ::
	$(NOECHO) $(NOOP)

# The following targets are skipped, to avoid complaint
# on the freebsd OS and others

test ::
	$(NOECHO) $(NOOP)

test_dynamic ::
	$(NOECHO) $(NOOP)

dynamic ::
	$(NOECHO) $(NOOP)

dynamic_lib ::
	$(NOECHO) $(NOOP)

dlsyms ::
	$(NOECHO) $(NOOP)

END_OF_POSTAMBLE

};

WriteMakefile(
     NAME	=> 'Marpa',
     SKIP      => [qw(test test_dynamic dynamic dynamic_lib dlsyms)],
     VERSION => $STRING_VERSION,
     DIR      => [ @dirs ],
);
