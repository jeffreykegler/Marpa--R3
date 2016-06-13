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

use vars qw($VERSION $STRING_VERSION);
$VERSION        = '4.001_012';
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

my @new_ccflags = ( );

if ( $Config{'ccname'} eq 'gcc' ) {
    ## -W instead of -Wextra is case the GCC is pre 3.0.0
    ## -Winline omitted because too noisy
    ## -ansi will not work with Lua or on Android
    push @new_ccflags, qw( -Wall -W
        -ansi -pedantic -Wundef -Wendif-labels
	-Wpointer-arith -Wstrict-prototypes -Wwrite-strings
	-Wmissing-declarations );
    push @new_ccflags, '-Wdeclaration-after-statement' if gcc_at_least('3.4.6');
} ## end if ( $self->config('cc') eq 'gcc' )

my $ccflags = join q{ }, $Config{'ccflags'}, @new_ccflags;

WriteMakefile(
    INC     => '-I../lua -I../engine/read_only',
    NAME    => 'Marpa::R3',
    VERSION => $STRING_VERSION,
    CCFLAGS => $ccflags,
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

    return $constants;

}

sub MY::top_targets {
    my $r = q{

all :: kollos$(LIB_EXT)
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

kollos.c: kollos.c.lua
	$(LUA_INTERP) kollos.c.lua errors=$(ERROR_TABLE) events=$(EVENT_TABLE) > $@

};

    if ( $^O eq 'MSWin32' ) {
        $r .= q[

kollos$(LIB_EXT): kollos$(OBJ_EXT)
	$(RM_RF) $@
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
 
];
    }

    return $r;

}
