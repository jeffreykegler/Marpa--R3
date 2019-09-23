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
$VERSION        = '4.001_054';
$STRING_VERSION = $VERSION;
## no critic (BuiltinFunctions::ProhibitStringyEval)
$VERSION = eval $VERSION;
## use critic

my $define = q{};
$define .= ' -DWIN32' if ($^O eq 'MSWin32');

sub gcc_is_at_least {
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
	-Wpointer-arith -Wstrict-prototypes -Wwrite-strings
	-Wconversion
	-Wmissing-declarations );
    push @new_ccflags, '-Wdeclaration-after-statement' if gcc_is_at_least('3.4.6');
} ## end if ( $self->config('cc') eq 'gcc' )
elsif ( $Config{'ccname'} eq 'cl' ) {
	## gcc's -Wundef is msvc's C4668 that is on with -Wall
	## gcc's -ansi -pedantic is msvc's /Za, but windows.h can't be compiled with it
	## msvc's equivalent for gcc's -Wendif-labels can't be found :)
	## -W4 -Wp64 will produce arguably too many warnings
	## in perl header files and XS macros, but can be useful for debugging
	push @new_ccflags, qw( -W3 );
}

if (0) {
#    if ( defined $self->args('XS-debug') ) {
#        say 'XS-debug flag is on';
#        if ( $self->config('ccname') eq 'gcc' ) {
#            push @new_ccflags,
#              qw( -Wall -ansi -pedantic -Wundef -Wendif-labels );
#        } ## end if ( $self->config('cc') eq 'gcc' )
#        elsif ( $self->config('ccname') eq 'cl' ) {
#            ## gcc's -Wundef is msvc's C4668 that is on with -Wall
#            ## gcc's -ansi -pedantic is msvc's /Za, but windows.h can't be compiled with it
#            ## msvc's equivalent for gcc's -Wendif-labels can't be found :)
#            push @new_ccflags, qw( -W4 -Wp64 );
#        }
#    }
}

my $my_ccflags = join q{ }, $Config{'ccflags'}, @new_ccflags;


WriteMakefile(
    INC     => '-I. -I../engine/read_only -I../lua -I../kollos',
    NAME    => 'Marpa::R3',
    VERSION => $STRING_VERSION,
    DEFINE  => $define,
    SKIP    => [qw(test test_dynamic dynamic dynamic_lib dlsyms)],
    XS      => { 'R3.xs' => 'R3.c' },
    CCFLAGS => $my_ccflags,
    # OBJECT  => 'R3.o',
);

package MY;

no warnings "redefine";

sub constants {

    my $self      = shift;
    my $constants = $self->SUPER::constants(@_);

    $constants .= "\n";
    $constants .= sprintf( "LUA_INTERP = %s\n",
        File::Spec->catfile( File::Spec->updir(), qw{lua lua} ) );
    $constants .= sprintf( "LUAC = %s\n",
        File::Spec->catfile( File::Spec->updir(), qw{lua luac} ) );

    my $my_lua_path = File::Spec->catfile( File::Spec->updir(), qw{kollos XXX} );
    $my_lua_path =~ s/XXX$/?.lua/;
    $constants .=
      'LUA_PATH = ' . $self->quote_literal( (';;' . $my_lua_path ),
        { allow_variables => undef } ) . "\n";
    $constants .= sprintf( "MIRANDA = %s\n",
        File::Spec->catfile( File::Spec->updir(), qw{kollos miranda} ) );

    $constants .= sprintf( "INSPECT_LUA = %s\n",
        File::Spec->catfile( File::Spec->updir(), qw{kollos inspect.lua} ) );
    $constants .= sprintf( "GLUE_LUA = %s\n",
        File::Spec->catfile( File::Spec->updir(), qw{glue glue.lua} ) );
    $constants .= sprintf( "KOLLOS_LUA = %s\n",
        File::Spec->catfile( File::Spec->updir(), qw{kollos kollos.lua} ) );

    $constants .= sprintf( "STRING2H_LUA = %s\n",
        File::Spec->catfile( File::Spec->updir(), qw{glue string2h.lua} ) );
    $constants .= sprintf( "HEX2H_LUA = %s\n",
        File::Spec->catfile( File::Spec->updir(), qw{glue hex2h.lua} ) );

    $constants .= sprintf( "MY_CCFLAGS = %s\n", $my_ccflags );

    return $constants;

}

sub top_targets {
    my $r = '
all :: R3$(OBJ_EXT)
	$(NOECHO) $(NOOP)
	$(NOECHO) $(ECHO) Executing all target in xs directory


config ::
	$(NOECHO) $(NOOP)

# test is SKIP’ped, so this avoids nmake’s “don’t know how to make test” complaints
test ::
	$(NOECHO) $(NOOP)

# and so is test_dynamic, so this helps avoid make’s
# “don’t know how to make test_dynamic” complaints under freebsd
test_dynamic ::
	$(NOECHO) $(NOOP)

';
    return $r;
}

sub postamble {
    my ($self) = @_;
    my @postamble_pieces = (".NOTPARALLEL:\n");

    push @postamble_pieces, <<'END_OF_POSTAMBLE_PIECE';
R3.c: ../kollos/kollos.h \
      inspect_inc.c glue_inc.c kollos_inc.c

inspect.out: $(INSPECT_LUA)
	LUA_PATH=$(LUA_PATH) $(LUAC) -o inspect.out $(INSPECT_LUA)

inspect_inc.c: inspect.out $(HEX2H_LUA)
	LUA_PATH=$(LUA_PATH) $(LUA_INTERP) $(HEX2H_LUA) inspect < inspect.out > $@

glue.out: $(GLUE_LUA)
	LUA_PATH=$(LUA_PATH) $(LUAC) -o glue.out $(GLUE_LUA)

glue_inc.c: glue.out $(HEX2H_LUA)
	LUA_PATH=$(LUA_PATH) $(LUA_INTERP) $(HEX2H_LUA) glue < glue.out > $@

kollos.out: $(KOLLOS_LUA)
	LUA_PATH=$(LUA_PATH) $(LUAC) -o kollos.out $(KOLLOS_LUA)

kollos_inc.c: kollos.out $(HEX2H_LUA)
	LUA_PATH=$(LUA_PATH) $(LUA_INTERP) $(HEX2H_LUA) kollos < kollos.out > $@

END_OF_POSTAMBLE_PIECE

    return join "\n", @postamble_pieces;
};
