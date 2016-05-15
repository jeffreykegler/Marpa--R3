#!/usr/bin/perl
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

# This writes a Makefile in the libmarpa build directory.
# It used in cases where GNU autoconf does not work.

use 5.010001;
use File::Spec;
use ExtUtils::MakeMaker;

#
## C.f. http://fr.slideshare.net/hashashin/building-c-and-c-libraries-with-perl
#
my @c = qw/alllib.c/;

my $define = q{};
# These setting adopted from Lua's src/Makefile
$define .= ' -DWIN32 -DPERL_STATIC_SYMS' if ($^O eq 'MSWin32');
$define .= ' -DLUA_USE_POSIX' if ($^O eq 'aix');
$define .= ' -DLUA_USE_POSIX' if ($^O eq 'bsdos');
$define .= ' -DLUA_USE_LINUX' if ($^O eq 'freebsd');
$define .= ' -DLUA_USE_LINUX' if ($^O eq 'linux');
$define .= ' -DLUA_USE_LINUX' if ($^O eq 'darwin');
$define .= ' -DLUA_USE_POSIX' if ($^O eq 'solaris');

my @h_files = <*.h>;
my $c_files = 'alllib$(OBJ_EXT)';

WriteMakefile(
    NAME      => 'marpa',
    DEFINE    => $define,
    SKIP      => [qw(test test_dynamic dynamic dynamic_lib dlsyms)],
    OBJECT    => $o_files,
    clean     => {'FILES' => 'marpa_lua$(LIB_EXT)'},
    H         => \@h_files,
    C         => \@c_files,
);

sub MY::constants {
    package MY;
    my $self = shift;

    $self->{INST_STATIC} = 'marpa_lua$(LIB_EXT)';

    return $self->SUPER::constants();
}

sub MY::top_targets {
    my $r = q{
all :: static
	$(NOECHO) $(NOOP)

config ::
	$(NOECHO) $(NOOP)

# test is SKIP’ped, so this avoids nmake’s “don’t know how to make test” complaints
test ::
	$(NOECHO) $(NOOP)

# and so is test_dynamic, so this helps avoid make’s
# “don’t know how to make test_dynamic” complaints under freebsd
test_dynamic ::
	$(NOECHO) $(NOOP)

};
}
