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

my $define = q{};
$define .= ' -DWIN32 -DPERL_STATIC_SYMS' if ($^O eq 'MSWin32');

my @all_h_files = <*.h>;
my @h_files = grep { $_ ne 'config_from_autoconf.h' } @all_h_files;
my @c_files = <*.c>;
my $o_files = join q{ }, @c_files;
$o_files =~ s/[.]c/.o/xmsg;

WriteMakefile(
    NAME      => 'marpa', # (doesn't matter what the name is here) oh yes it does
#    LINKTYPE  => 'static',
    DEFINE    => $define,
    SKIP      => [qw(dynamic dynamic_lib dlsyms)],
    OBJECT    => $o_files,
    clean     => {'FILES' => 'libmarpa.a'},
    H         => \@h_files,
    C         => \@c_files,
);

sub MY::constants {
    package MY;
    my $self = shift;

    $self->{INST_STATIC} = 'libmarpa$(LIB_EXT)';

    return $self->SUPER::constants();
}

sub MY::top_targets {
    my $r = '
all :: static
	$(NOECHO) $(NOOP)

config ::
	$(NOECHO) $(NOOP)

';
if (0) {
    # I hope I don't need this.
    $r .= '
# This is a workaround, the problem is that our old GNU make exports
# variables into the environment so $(MYEXTLIB) is set in here to this
# value which can not be built.
sdbm/libsdbm.a:
	$(NOECHO) $(NOOP)
' unless $^O eq 'VMS';
} ## end if (0)

    return $r;
}
