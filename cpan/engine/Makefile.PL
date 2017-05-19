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
use strict;
use warnings;
use ExtUtils::Install;
use Fatal qw(open close mkdir chdir);
use File::Spec 0.82;
use English qw( -no_match_vars );

use Config;
use ExtUtils::MakeMaker;

use vars qw($VERSION $STRING_VERSION);
$VERSION        = '4.001_046';
$STRING_VERSION = $VERSION;
## no critic (BuiltinFunctions::ProhibitStringyEval)
$VERSION = eval $VERSION;
## use critic

my %perl_autoconf_os =
    map { $_ => 1 } qw( MSWin32 openbsd solaris sunos midnightbsd );
my $use_perl_autoconf = $ENV{MARPA_USE_PERL_AUTOCONF}
    || ( $perl_autoconf_os{$^O} // 0 );

my $marpa_debug_flags = '';
if ($ENV{MARPA_DEBUG_FLAG}) {
  $marpa_debug_flags = 'MARPA_DEBUG_FLAG=' .  $ENV{MARPA_DEBUG_FLAG};
}

my $define = q{};
$define .= ' -DWIN32' if ($^O eq 'MSWin32');

undef &MY::post_initialize; # suppress warning
*MY::post_initialize = sub {
    my ($self) = @_;
    my @pieces = (".NOTPARALLEL:\n");
    if ($use_perl_autoconf) {
        push @pieces,
	    'LIBMARPA_BUILD_DIR = perl_ac_build',
	    'LIBMARPA_IN_BUILD_DIR = $(LIBMARPA_BUILD_DIR)/libmarpa$(LIB_EXT)',
	    q{};
    } else {
        push @pieces,
	    'LIBMARPA_BUILD_DIR = gnu_ac_build',
	    'LIBMARPA_IN_BUILD_DIR = $(LIBMARPA_BUILD_DIR)/.libs/libmarpa$(LIB_EXT)',
	    q{};
    }
    return join "\n", @pieces;
};

undef &MY::top_targets; # suppress warning
*MY::top_targets = sub {
    my $r = '
all :: $(LIBMARPA_IN_BUILD_DIR)
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

';
    return $r;
};

undef &MY::postamble; # suppress warning
*MY::postamble = sub {
    my ($self) = @_;

    my @postamble_pieces = ();
    push @postamble_pieces, sprintf "LIBMARPA_INSTALL = %s\n",
      $self->oneliner(
'install([ from_to => {@ARGV}, skip => q{cf/INSTALL.SKIP}, dir_mode => "$(PERM_DIR)" ]);',
        [qw(-MExtUtils::Install)]
      );

    push @postamble_pieces, <<'END_OF_POSTAMBLE_PIECE';
gnu_ac_build.time-stamp: read_only.time-stamp
	$(RM_RF) gnu_ac_build
	$(LIBMARPA_INSTALL) read_only gnu_ac_build
	date > gnu_ac_build.time-stamp
END_OF_POSTAMBLE_PIECE

    push @postamble_pieces, <<'END_OF_POSTAMBLE_PIECE';
perl_ac_build/Makefile.PL: read_only.time-stamp cf/perl_ac_makefile.PL
	$(RM_RF) perl_ac_build
	$(LIBMARPA_INSTALL) read_only perl_ac_build
	$(CP) cf/perl_ac_makefile.PL perl_ac_build/Makefile.PL
END_OF_POSTAMBLE_PIECE


# == Logic to create Makefile for GNU autoconf
    push @postamble_pieces, sprintf <<'END_OF_POSTAMBLE_PIECE',
gnu_ac_build/Makefile: gnu_ac_build.time-stamp
	%s
END_OF_POSTAMBLE_PIECE
        $self->cd(
            File::Spec->catdir(qw(gnu_ac_build)),
            join( q{ },
                '$(SHELL) configure',
                $marpa_debug_flags,
                '--with-pic --disable-shared --disable-maintainer-mode' )
        );

# == Logic to create Makefile for Perl autoconf
# The Makefile.PL reads the contents of the directory,
# so the directory must be populated
# before Makefile.PL is run.

    push @postamble_pieces, <<'END_OF_POSTAMBLE_PIECE';
END_OF_POSTAMBLE_PIECE

    push @postamble_pieces, sprintf <<'END_OF_POSTAMBLE_PIECE',
perl_ac_build/Makefile: perl_ac_build/Makefile.PL
	%s
END_OF_POSTAMBLE_PIECE
	$self->cd(File::Spec->catdir(qw(perl_ac_build)), '$(PERLRUN) Makefile.PL $(ARGV)');

# == Logic to compile and build library for GNU autoconf
    push @postamble_pieces, sprintf <<'END_OF_POSTAMBLE_PIECE',
gnu_ac_build/.libs/libmarpa$(LIB_EXT): gnu_ac_build/Makefile
	%s
END_OF_POSTAMBLE_PIECE
	$self->cd(File::Spec->catdir(qw(gnu_ac_build)), '$(MAKE)');

# == Logic to compile and build library for Perl autoconf
# GNU autoconf automatically creates/updates stamp-h1.
# For Config::AutoConf, but we don't use it, so we don't create one.

    push @postamble_pieces, sprintf <<'END_OF_POSTAMBLE_PIECE',
perl_ac_build/libmarpa$(LIB_EXT): perl_ac_build/Makefile
	%s
END_OF_POSTAMBLE_PIECE
	$self->cd(File::Spec->catdir(qw(perl_ac_build)), '$(MAKE)');

    return join "\n", @postamble_pieces;
};

my @files_to_cleanup = ( "gnu_ac_build.time-stamp" );

WriteMakefile(
    clean   => { FILES => ( join q{ }, @files_to_cleanup ) },
    INC     => '-I.',
    NAME    => 'Marpa::R3',
    VERSION => $STRING_VERSION,
    DEFINE  => $define,
    SKIP => [qw(test test_dynamic dynamic dynamic_lib dlsyms)],
);

