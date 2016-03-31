#!/usr/bin/perl
# Copyright 2014 Jeffrey Kegler
# This file is part of Marpa::R3.  Marpa::R3 is free software: you can
# redistribute it and/or modify it under the terms of the GNU Lesser
# General Public License as published by the Free Software Foundation,
# either version 3 of the License, or (at your option) any later version.
# ## end if ($Marpa::R3::USE_PERL_AUTOCONF)
# Marpa::R3 is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser
# General Public License along with Marpa::R3.  If not, see
# http://www.gnu.org/licenses/.

# This writes a Makefile in the libmarpa build directory.
# It used in cases where GNU autoconf does not work.

# It expects to be run in the libmarpa *build* directory.

# This code is adopted from code in the SDBM_File module.

use ExtUtils::MakeMaker;

use vars qw($VERSION $STRING_VERSION);
$VERSION        = '3.003_003';
$STRING_VERSION = $VERSION;
## no critic (BuiltinFunctions::ProhibitStringyEval)
$VERSION = eval $VERSION;
## use critic

my $define = q{};
$define .= ' -DWIN32 -DPERL_STATIC_SYMS' if ($^O eq 'MSWin32');

my @c_files = <*.c>;
my $o_files = join q{ }, @c_files;
$o_files =~ s/[.]c/.o/xmsg;

WriteMakefile(
    INC => '-I.',
    NAME      => 'Marpa::R3',
    VERSION => $STRING_VERSION,
#    LINKTYPE  => 'static',
    DEFINE    => $define,
    SKIP      => [qw(test dynamic dynamic_lib dlsyms)],
    XS => { 'R3.xs' => 'R3.c' },
    OBJECT => 'R3.o',
    # clean     => {'FILES' => 'libmarpa.a'},
    # H         => \@h_files,
    # C         => \@c_files,
);


sub MY::top_targets {
    my $r = '
all :: R3.o
	$(NOECHO) $(NOOP)

config ::
	$(NOECHO) $(NOOP)

';
    return $r;
}
