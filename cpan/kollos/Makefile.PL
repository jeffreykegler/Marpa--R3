#!/usr/bin/perl
# Marpa::R3 is Copyright (C) 2017, Jeffrey Kegler.
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
use File::Spec;
use ExtUtils::MakeMaker;

use vars qw($VERSION $STRING_VERSION);
$VERSION        = '4.001_048';
$STRING_VERSION = $VERSION;
## no critic (BuiltinFunctions::ProhibitStringyEval)
$VERSION = eval $VERSION;
## use critic

sub gcc_at_least {
    my ($required) = @_;
    state $gcc_version = $Config{gccversion};
    return if not $gcc_version;
    my @actual = ($gcc_version =~ m/ \A (\d+) [.] (\d+) [.] (\d+) \z /xms);
    return if @actual != 3;
    my @required = ($required =~ m/ \A (\d+) [.] (\d+) [.] (\d+) \z /xms);
    die if scalar @required != 3;
    my $cmp = $actual[0] <=> $required[0] ||
     $actual[1] <=> $required[1]  ||
     $actual[2] <=> $required[2] ;
    return $cmp >= 0 ? 1 : 0;
}

my @my_ccflags = ( );

if ( $Config{'ccname'} eq 'gcc' ) {
    # Original flags, from kollos repo:
    # -Wall -Wpointer-arith -Wstrict-prototypes -Wwrite-strings -Wshadow -Wmissing-declarations -Wconversion -ansi -pedantic -Wundef -Wendif-labels

    ## -W instead of -Wextra is case the GCC is pre 3.0.0
    ## -Winline omitted because too noisy
    ## -ansi will not work with Lua or on Android
    ## Lua 5.3.2 gcc flags are -Wall -Wextra
    ## Lua 5.3.2 prefers gcc -std=c99
    push @my_ccflags, qw( -Wall -W
        -Wundef -Wendif-labels
	-Wpointer-arith -Wstrict-prototypes -Wwrite-strings
	-Wconversion
	-Wmissing-declarations );
    push @my_ccflags, '-Wdeclaration-after-statement' if gcc_at_least('3.4.6');
} ## end if ( $self->config('cc') eq 'gcc' )
elsif ( $Config{'ccname'} eq 'cl' ) {
	## gcc's -Wundef is msvc's C4668 that is on with -Wall
	## gcc's -ansi -pedantic is msvc's /Za, but windows.h can't be compiled with it
	## msvc's equivalent for gcc's -Wendif-labels can't be found :)
	## -W4 -Wp64 will produce arguably too many warnings
	## in perl header files and XS macros, but can be useful for debugging
	push @my_ccflags, qw( -W3 );
}

my $my_ccflags = join q{ }, @my_ccflags;

WriteMakefile(
    INC     => '-I. -I../lua -I../engine/read_only',
    NAME    => 'Marpa::R3',
    VERSION => $STRING_VERSION,
    SKIP   => [qw(test test_dynamic dynamic dynamic_lib dlsyms)],
    clean  => { 'FILES' => 'kollos$(LIB_EXT)' },
);

package MY;

sub constants {

    my $self      = shift;
    my $constants = $self->SUPER::constants(@_);

    $constants .= "\n";
    $constants .= sprintf( "LUA_INTERP = %s\n",
        File::Spec->catfile( File::Spec->updir(), qw{lua lua} ) );
    $constants .= sprintf(
        "ERROR_TABLE = %s\n",
        File::Spec->catfile(
            File::Spec->updir(), qw{engine read_only error_codes.table}
        )
    );
    $constants .= sprintf(
        "EVENT_TABLE = %s\n",
        File::Spec->catfile(
            File::Spec->updir(), qw{engine read_only events.table}
        )
    );
    $constants .= sprintf(
        "STEP_TABLE = %s\n",
        File::Spec->catfile(
            File::Spec->updir(), qw{engine read_only steps.table}
        )
    );
    $constants .= sprintf(
        "MARPA_H = %s\n",
        File::Spec->catfile(
            File::Spec->updir(), qw{engine read_only marpa.h}
        )
    );
    $constants .= sprintf( "MY_CCFLAGS = %s\n", $my_ccflags);

    return $constants;

}

sub MY::top_targets {
    my $r = q{

all :: kollos.lua kollos$(LIB_EXT) kollos.h
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

kollos.lua: kollos.md error_table.md event_table.md step_table.md
	$(LUA_INTERP) miranda error_table.md event_table.md step_table.md \
	  kollos.md main=kollos.lua

error_table.md: gen_error_table.lua
	$(LUA_INTERP) gen_error_table.lua $(ERROR_TABLE) > $@

event_table.md: gen_event_table.lua
	$(LUA_INTERP) gen_event_table.lua $(EVENT_TABLE) > $@

step_table.md: gen_step_table.lua
	$(LUA_INTERP) gen_step_table.lua $(STEP_TABLE) > $@

kollos.c: kollos.md error_table.md event_table.md step_table.md \
	  kollos.h $(MARPA_H)
	$(LUA_INTERP) miranda error_table.md event_table.md step_table.md \
	  kollos.md kollos_c=kollos.c

kollos.h: kollos.md
	$(LUA_INTERP) miranda kollos.md kollos_h=kollos.h

};

    if ( $^O eq 'MSWin32' ) {
        $r .= q[

kollos$(LIB_EXT): kollos.c
	$(RM_RF) $@
	$(CC) -c $(PASTHRU_INC) $(INC) $(CCFLAGS) $(MY_CCFLAGS) $(OPTIMIZE) \
	  $(CCCDLFLAGS) $(PASTHRU_DEFINE) $(DEFINE) -DMAKE_LIB \
	  -DLUAOPEN_KOLLOS_METAL=kollos_metal_loader \
	  kollos.c
	$(AR) -out:$@ kollos$(OBJ_EXT)
	$(CHMOD) $(PERM_RWX) $@

];
    }
    else {
        $r .= q[

kollos$(LIB_EXT): kollos$(OBJ_EXT)
	$(RM_RF) $@
	$(FULL_AR) $(AR_STATIC_ARGS) $@ kollos$(OBJ_EXT) && $(RANLIB) $@
	$(CHMOD) $(PERM_RWX) $@

kollos$(OBJ_EXT): kollos.c
	$(CC) -c $(PASTHRU_INC) $(INC) $(CCFLAGS) $(MY_CCFLAGS) $(OPTIMIZE) \
	  $(CCCDLFLAGS) $(PASTHRU_DEFINE) $(DEFINE) \
	  -DLUAOPEN_KOLLOS_METAL=kollos_metal_loader \
	  -DMAKE_LIB kollos.c

];
    }

    return $r;

}
