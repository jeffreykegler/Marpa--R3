#!/usr/bin/perl
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
$define .= ' -DLUA_USE_POSIX' if ($^O eq 'freebsd');
$define .= ' -DLUA_USE_POSIX' if ($^O eq 'linux');
$define .= ' -DLUA_USE_POSIX' if ($^O eq 'darwin');
$define .= ' -DLUA_USE_POSIX' if ($^O eq 'solaris');
$define .= ' -DLUA_USE_APICHECK' if $ENV{MARPA_DEBUG};

WriteMakefile(
    NAME   => 'marpa',
    DEFINE => $define,
    SKIP   => [qw(test test_dynamic dynamic dynamic_lib dlsyms)],
    # OBJECT => $o_files,
    clean  => { 'FILES' => 'marpa_lua$(LIB_EXT)' },
    # H      => \@h_files,
    # C      => \@c_files,
);

sub MY::top_targets {
    my $r = q{

all :: marpa_lua$(LIB_EXT) lua luac
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

if ( $^O eq 'MSWin32' ) {
    $r .= q{

marpa_lua$(LIB_EXT): one$(OBJ_EXT)
	$(RM_RF) $@
	$(CC) -c $(PASTHRU_INC) $(INC) $(CCFLAGS) $(OPTIMIZE) \
	  $(CCCDLFLAGS) $(PASTHRU_DEFINE) $(DEFINE) -DMAKE_LIB one.c
	$(AR) -out:$@ one$(OBJ_EXT)
	$(CHMOD) $(PERM_RWX) $@

lua: one.c
	$(CC) -Fe$@ $(PASTHRU_INC) $(INC) $(CCFLAGS) $(OPTIMIZE) \
	  $(PASTHRU_DEFINE) $(DEFINE) -DMAKE_LUA one.c

luac: one.c
	$(CC) -Fe$@ $(PASTHRU_INC) $(INC) $(CCFLAGS) $(OPTIMIZE) \
	  $(PASTHRU_DEFINE) $(DEFINE) -DMAKE_LUAC one.c

};
} else {
    $r .= q{

marpa_lua$(LIB_EXT): one$(OBJ_EXT)
	$(RM_RF) $@
	$(FULL_AR) $(AR_STATIC_ARGS) $@ one$(OBJ_EXT) && $(RANLIB) $@
	$(CHMOD) $(PERM_RWX) $@
 
one$(OBJ_EXT):
	$(CC) -c $(PASTHRU_INC) $(INC) $(CCFLAGS) $(OPTIMIZE) \
	  $(CCCDLFLAGS) $(PASTHRU_DEFINE) $(DEFINE) -DMAKE_LIB one.c

lua: one.c
	$(CC) -o $@ $(PASTHRU_INC) $(INC) $(CCFLAGS) $(OPTIMIZE) \
	  $(PASTHRU_DEFINE) $(DEFINE) -DMAKE_LUA one.c -lm

luac: one.c
	$(CC) -o $@ $(PASTHRU_INC) $(INC) $(CCFLAGS) $(OPTIMIZE) \
	  $(PASTHRU_DEFINE) $(DEFINE) -DMAKE_LUAC one.c -lm

};
}

return $r;

}
