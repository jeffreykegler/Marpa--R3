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

# This code is adopted from code in the SDBM_File module.

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
$VERSION        = '4.001_004';
$STRING_VERSION = $VERSION;
## no critic (BuiltinFunctions::ProhibitStringyEval)
$VERSION = eval $VERSION;
## use critic

my $define = q{};
$define .= ' -DWIN32' if ($^O eq 'MSWin32');

my $ccflags = $Config{ccflags} . " -I../engine/read_only";

undef &MY::top_targets; # suppress warning
*MY::top_targets = sub {
    my $r = '
all :: R3$(OBJ_EXT)
	$(NOECHO) $(NOOP)
	$(NOECHO) $(ECHO) Executing all target in xs directory


config ::
	$(NOECHO) $(NOOP)

# test is SKIP’ped, so this avoids nmake’s “don’t know how to make test” complaints
test ::
	$(NOECHO) $(NOOP)

';
    return $r;
};

undef &MY::postamble; # suppress warning
*MY::postamble = sub {
    my ($self) = @_;
    my @postamble_pieces = (".NOTPARALLEL:\n");

    push @postamble_pieces, <<'END_OF_POSTAMBLE_PIECE';
R3$(OBJ_EXT): general_pattern.xsh marpa_slifop.h

general_pattern.xsh: gp_generate.pl
	$(PERLRUN) gp_generate.pl general_pattern.xsh

marpa_slifop.h: create_ops.pl
	$(PERLRUN) create_ops.pl > marpa_slifop.h

END_OF_POSTAMBLE_PIECE

    return join "\n", @postamble_pieces;
};

WriteMakefile(
    INC => '-I.',
    NAME      => 'Marpa::R3',
    VERSION => $STRING_VERSION,
    DEFINE    => $define,
    SKIP      => [qw(test dynamic dynamic_lib dlsyms)],
    CCFLAGS => $ccflags,
    XS => { 'R3.xs' => 'R3.c' },
    OBJECT => 'R3.o',
);

