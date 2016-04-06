#!/usr/bin/perl
# Copyright 2016 Jeffrey Kegler
# This file is part of Marpa::R3.  Marpa::R3 is free software: you can
# redistribute it and/or modify it under the terms of the GNU Lesser
# General Public License as published by the Free Software Foundation,
# either version 3 of the License, or (at your option) any later version.
#
# Marpa::R3 is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser
# General Public License along with Marpa::R3.  If not, see
# http://www.gnu.org/licenses/.

use 5.010001;
use strict;
use warnings;
use ExtUtils::Install;
use Fatal qw(open close mkdir chdir);
use File::Spec 0.82;
use File::Find 1.12;
use File::Copy;
use IPC::Cmd;
use English qw( -no_match_vars );
use Time::Piece 1.12;
use Cwd;

use Config;
use ExtUtils::MakeMaker;

use vars qw($VERSION $STRING_VERSION);
$VERSION        = '1.001_000';
$STRING_VERSION = $VERSION;
## no critic (BuiltinFunctions::ProhibitStringyEval)
$VERSION = eval $VERSION;
## use critic

my $verbose = 1;
my $libmarpa_debug = 0;

my %perl_autoconf_os =
    map { $_ => 1 } qw( MSWin32 openbsd solaris sunos midnightbsd );
my $use_perl_autoconf = $ENV{MARPA_USE_PERL_AUTOCONF}
    || ( $perl_autoconf_os{$^O} // 0 );

# This comment reminds me of how to use Module::CoreList.
# It's here for convenience in working on this file.
# perl -MModule::CoreList -E 'print $Module::CoreList::version{5.010001}{Carp};'

my %version_for_config = (
    # Carp is 1.11 to allow objects to be thrown as exceptions.
    'Carp'                  => '1.11',
    'Config::AutoConf'      => '0.22',
    'CPAN::Meta::Converter' => '2.120921',
    'Cwd'                   => '3.2501',
    'Data::Dumper'          => '2.125',
    'DynaLoader'            => '1.08',
    'English'               => '1.04',
    'Exporter'              => '5.62',
    'ExtUtils::CBuilder'    => '0.27',
    # ExtUtils::MakeMaker must be 6.48 so that MIN_PERL_VERSION
    # is supported
    'ExtUtils::MakeMaker'   => '6.48',
    'ExtUtils::Manifest'    => '1.51_01',
    'ExtUtils::Mkbootstrap' => '6.42',
    'Fatal'                 => '1.05',
    'File::Copy'            => '2.11',
    'File::Spec'            => '3.2501',
    'File::Find'            => '1.12',
    'HTML::Entities'        => '3.68',
    'HTML::Parser'          => '3.69',
    'IPC::Cmd'              => '0.40_1',
    'List::Util'            => '1.21',
    'PPI'                   => '1.206',
    'Scalar::Util'          => '1.21',
    'Test::More'            => '0.94',
    'Time::Piece'           => '1.12',
    'XSLoader'              => '0.08',
);

if ($use_perl_autoconf) {
    say "Using Config::AutoConf";
    for my $package (qw( Config::AutoConf )) {
        if ( not eval "require $package" ) {
            die "$package is not installed: $EVAL_ERROR\n",
                "    Module $package is required for Windows and for USE_PERL_AUTOCONF mode\n";
        }
        my $version = $version_for_config{$package};
        if ( not $package->VERSION($version) ) {
            die "Version $version of $package is not installed\n",
                "    Version $version of $package is required for Windows and for USE_PERL_AUTOCONF mode\n";
        }
    } ## end for my $package (qw( Config::AutoConf ))
} ## end if ($use_perl_autoconf)

my $preamble = <<'END_OF_STRING';
# This file is written by Makefile.PL
# It is not intended to be modified directly

END_OF_STRING

sub installed_contents {
    my ( $package ) = @_;
    my $marpa_version = $STRING_VERSION;
    my $text             = $preamble;
    $text .= "package $package;\n";

##no critic(ValuesAndExpressions::RequireInterpolationOfMetachars)
    $text .= q{use vars qw($VERSION $STRING_VERSION)} . qq{;\n};
    $text .= q{$VERSION = '} . $marpa_version . qq{';\n};
    $text .= q{$STRING_VERSION = $VERSION} . qq{;\n};
    $text .= q{$VERSION = eval $VERSION} . qq{;\n};
##use critic

    $text .= "1;\n";
    return $text;
} ## end sub installed_contents

sub xs_version_contents {
    my ( $package ) = @_;
    my @use_packages =
        qw( Scalar::Util List::Util Carp Data::Dumper );
    my $text = $preamble;
    $text .= "package $package;\n";

##no critic(ValuesAndExpressions::RequireInterpolationOfMetachars)
    $text .= q{use vars qw($TIMESTAMP)} . qq{;\n};
    $text .= q{$TIMESTAMP='} . localtime()->datetime . qq{';\n};
##use critic

    for my $package (@use_packages) {
        my $version = $version_for_config{$package};
        die "No version defined for $package" if not defined $version;
        $text .= "use $package $version ();\n";
    }
    $text .= "1;\n";
    return $text;
} ## end sub xs_version_contents

sub perl_version_contents {
    my ( $package, ) = @_;
    my @use_packages     = qw( Scalar::Util Carp Data::Dumper PPI Marpa::R3 );
    my $text             = $preamble;
    my $marpa_version = $STRING_VERSION;
    $text .= "package $package;\n";

##no critic(ValuesAndExpressions::RequireInterpolationOfMetachars)
    $text .= q{use vars qw($TIMESTAMP)} . qq{;\n};
    $text .= q{$TIMESTAMP='} . localtime()->datetime . qq{';\n};
##use critic

    for my $package (@use_packages) {
        my $version =
              $package eq 'Marpa::R3'
            ? $marpa_version
            : $version_for_config{$package};
        die "No version defined for $package" if not defined $version;
        $text .= "use $package $version ();\n";
    } ## end for my $package (@use_packages)
    $text .= "1;\n";
    return $text;
} ## end sub perl_version_contents

sub file_write {
    my ( $contents, @name_components ) = @_;
    my $file_name = pop @name_components;
    my $dir_name  = File::Spec->catdir( @name_components );
    -d $dir_name or mkdir $dir_name;
    my $path_name = File::Spec->catfile( $dir_name, $file_name );
    open my $fh, q{>}, $path_name;
    print {$fh} $contents or die "print failed: $ERRNO";
    close $fh;
    return 1;
} ## end sub file_write

sub write_installed_pm {
    my ( @components ) = @_;
    my $filename           = 'Installed';
    my @package_components = @components[ 1 .. $#components ];
    my $contents = installed_contents( join q{::}, @package_components,
        $filename );
    $filename .= q{.pm};
    return file_write( $contents, @components, $filename );
} ## end sub write_installed_pm

my @packages_for_perl_autoconf = qw( Config::AutoConf );
my @always_required            = qw(
    Carp
    Cwd
    Data::Dumper
    DynaLoader
    English
    Exporter
    ExtUtils::CBuilder
    ExtUtils::MakeMaker
    ExtUtils::Manifest
    ExtUtils::Mkbootstrap
    Fatal
    File::Copy
    File::Spec
    IPC::Cmd
    List::Util
    PPI
    Scalar::Util
    Test::More
    Time::Piece
    XSLoader
);

my %configure_requires =
    map { ( $_, $version_for_config{$_} ) }
    qw( CPAN::Meta::Converter ),
    @always_required,
    @packages_for_perl_autoconf;
my %requires =
    map { ( $_, $version_for_config{$_} ) }
    qw( HTML::Entities HTML::Parser ),
    @always_required;

# my %recommends =
    # map { ( $_, $version_for_config{$_} ) }
    # ( @packages_for_perl_autoconf, qw( PPI ) );

my %pod_files = ();
{
    local $RS = undef;
    open my $manifest_fh, q{<}, 'MANIFEST';
    my @pod_files = split /\n/xms, $manifest_fh->getline();
    close $manifest_fh;
    LINE: for my $pod_file (@pod_files) {
        $pod_file =~ s/ \s* [#] .* \z //xms;
        next LINE if not $pod_file =~ / [.] pod \z /xms;
        next LINE if $pod_file =~ m{ libmarpa [/] dev [/] old_pod [/] }xms;
        if ( ( my $destfile = $pod_file )
            =~ s{ \A pod [/] }{Marpa/R3/}xms )
        {
            $destfile =~ s{[/]}{-}xmsg;
            $pod_files{$pod_file} = q{$(INST_MAN1DIR)/} . $destfile;
            next LINE;
        } ## end if ( ( my $destfile = $pod_file ) =~ ...)
        if ( ( my $destfile = $pod_file )
            =~ s{ \A html [/] pod [/] }{Marpa/R3/}xms )
        {
            $destfile =~ s{[/]}{-}xmsg;
            $pod_files{$pod_file} = q{$(INST_MAN1DIR)/} . $destfile;
            next LINE;
        } ## end if ( ( my $destfile = $pod_file ) =~ ...)
        die "Failed to rename POD file: $pod_file";
    } ## end LINE: for my $pod_file (@pod_files)
}
$pod_files{'pod/Marpa_R3.pod'}  = q{$(INST_MAN1DIR)} . '/Marpa-R3.pod';
$pod_files{'html/pod/HTML.pod'} = q{$(INST_MAN1DIR)} . '/Marpa-R3-HTML.pod';

{
    my @r3_perl_components = qw(pperl Marpa R3 Perl);
    my @r3_components      = qw(lib Marpa R3);
    my $config_pm_filename = File::Spec->catfile(qw(inc Marpa R3 Config.pm ));
    my @derived_files      = (
        File::Spec->catfile( @r3_components,      'Version.pm' ),
        File::Spec->catfile( @r3_components,      'Installed.pm' ),
        File::Spec->catfile( @r3_perl_components, 'Version.pm' ),
        File::Spec->catfile( @r3_perl_components, 'Installed.pm' ),
    );
    say {*STDERR} 'Writing version files' or die "say failed: $ERRNO";
    write_installed_pm(qw(lib Marpa R3 ));
    write_installed_pm(qw(pperl Marpa R3 Perl ));
    my $perl_version_pm = perl_version_contents('Marpa::R3::Perl');
    my $version_pm      = xs_version_contents('Marpa::R3');
    file_write( $version_pm,      qw(lib Marpa R3 Version.pm) );
    file_write( $perl_version_pm, qw(pperl Marpa R3 Perl Version.pm) );

}

{
    my @use_packages = qw( HTML::Entities HTML::Parser);
    my $text         = $preamble;
    $text .= "package Marpa::R3::HTML::Test;\n";

##no critic(ValuesAndExpressions::RequireInterpolationOfMetachars)
    $text .= q{use vars qw($TIMESTAMP %VERSION_FOR_CONFIG)} . qq{;\n};
    $text .= q{$TIMESTAMP='} . localtime()->datetime . qq{';\n};
##use critic

    $text .= '%VERSION_FOR_CONFIG = (' . "\n";
    for my $package (@use_packages) {
        my $version = $version_for_config{$package};
        die "No version defined for $package" if not defined $version;
        $text .= q{    '} . $package . q{' => '} . $version . qq{',\n};
    }
    $text .= ');' . "\n\n";
    $text .= "1;\n";

    file_write( $text, qw(html tool lib Marpa R3 HTML Test Version.pm ) );

}

my %pm_files = ();
File::Find::find(
    sub {
        return if not m/[.]pm \z/xms;
        my ( $vol, $dirs, $file_name ) = File::Spec->splitpath($File::Find::name);
        my @dirs      = File::Spec->splitdir($dirs);
        shift @dirs; # shift off the lib component
        my $dest_dir = File::Spec->catdir( q{$(INST_LIB)}, @dirs );
        my $dest_file = File::Spec->catpath( $vol, $dest_dir, $file_name );
        $pm_files{$File::Find::name} = $dest_file;
    },
    'lib/Marpa/R3'
);
File::Find::find(
    sub {
        return if not m/[.]pm \z/xms;
        my ( $vol, $dirs, $file ) = File::Spec->splitpath($File::Find::name);
        my @dirs      = File::Spec->splitdir($dirs);
        shift @dirs, shift @dirs; # shift off the html/lib components
        my $dest_dirs = File::Spec->catdir( q{$(INST_LIB)}, @dirs );
        my $dest_name = File::Spec->catpath( $vol, $dest_dirs, $file );
        $pm_files{$File::Find::name} = $dest_name;
    },
    'html/lib'
);
{
    my $filename = 'R3.pm';
    my $from_dir = File::Spec->catdir( qw{lib Marpa } );
    my $from_file = File::Spec->catfile( $from_dir, $filename );
    my $dest_dir = File::Spec->catdir( q{$(INST_LIB)}, qw{Marpa} );
    my $dest_file = File::Spec->catfile( $dest_dir, $filename );
    $pm_files{$from_file} =  $dest_file;
}

# die Data::Dumper::Dumper(\%pm_files);

my @no_index_namespace_inclusive = qw(
    Marpa::R3::HTML
    Marpa::R3::Value
    Marpa::R3::Perl
    Marpa::R3::Test
    Marpa::R3::Display
    Marpa::R3::Inner
    Marpa::R3::Internal
    Marpa::R3::MetaAST
    Marpa::R3::MetaG
);

my @files_to_cleanup = (
    'lib/Marpa/R3/Version.pm',           'pperl/Marpa/R3/Perl/Version.pm',
    'html/lib/Marpa/R3/Test/Version.pm', 'lib/Marpa/R3/Installed.pm',
    'pperl/Marpa/R3/Perl/Installed.pm',  'lib/Marpa/R3.o',
    'engine/gnu_ac_build',                 'engine/perl_ac_build',
);

WriteMakefile(
    clean    => { FILES => ( join q{ }, @files_to_cleanup ) },
    NAME     => 'Marpa::R3',
    VERSION => $STRING_VERSION,
    AUTHOR   => 'Jeffrey Kegler',
    ABSTRACT => 'Release 3 of Marpa',

    # recommends         => \%recommends,
    PREREQ_PM          => \%requires,
    CONFIGURE_REQUIRES => \%configure_requires,
    PM                 => \%pm_files,
    # OBJECT => 'xs/R3.o',
    TYPEMAPS => ['typemap'],
    dist => { COMPRESS => 'gzip --best -f' },
    MIN_PERL_VERSION => '5.10.1',
    DIR => ['xs'],
    EXE_FILES          => [
        'html/script/marpa_r3_html_fmt',
        'html/script/marpa_r3_html_score',
    ],
    META_ADD => {
        no_index => {
            directory => [
                qw( pperl tool engine author.t
                    html/etc html/sandbox html/script html/t
                    )
            ],
            namespace => [
                'Marpa::R3::Recognizer', 'Marpa::R3::Grammar',
                @no_index_namespace_inclusive
            ],
            package =>
                [ @no_index_namespace_inclusive, 'Marpa::R3::Thin::Trace' ],
        }
    },
    META_MERGE => {
        resources =>
            { repository => 'git://github.com/jeffreykegler/Marpa--R3.git', },
    },
    NO_META  => 1,
    MAN1PODS => \%pod_files,
    LICENSE  => 'lgpl3',
    MYEXTLIB => 'xs/R3$(OBJ_EXT) xs/libmarpa$(LIB_EXT)',

    test => { RECURSIVE_TEST_FILES => 1 }

);

# my @debug_flags            = ();
# if ($libmarpa_debug) {
    # if ( defined $ENV{LIBMARPA_CFLAGS} ) {
        # $ENV{CFLAGS} = $ENV{LIBMARPA_CFLAGS};
    # }
    # push @debug_flags, '-DMARPA_DEBUG=1';
    # push @debug_flags, '-fno-inline', '-Wno-inline'
        # if ( $Config{'cc'} eq 'gcc' );
# } ## end if ($libmarpa_debug)

sub MY::postamble {
    my $postamble = "\n";
    if ($use_perl_autoconf) {
        $postamble .= join "\n",
	    'LIBMARPA_BUILD_DIR = engine/perl_ac_build',
	    'LIBMARPA_IN_BUILD_DIR = $(LIBMARPA_BUILD_DIR)/libmarpa$(LIB_EXT)',
	    q{}, q{};
    } else {
        $postamble .= join "\n",
	    'LIBMARPA_BUILD_DIR = engine/gnu_ac_build',
	    'LIBMARPA_IN_BUILD_DIR = $(LIBMARPA_BUILD_DIR)/.libs/libmarpa$(LIB_EXT)',
	    q{}, q{};
    }

    $postamble .= <<'END_OF_POSTAMBLE';

engine/gnu_ac_build/marpa.c engine/gnu_ac_build/marpa.h engine/gnu_ac_build/configure: \
            engine/read_only/stamp-h1
	test -d engine/gnu_ac_build || mkdir engine/gnu_ac_build
	cd engine/gnu_ac_build && (cd ../read_only; tar -cf - .) | tar xomf -

engine/gnu_ac_build/config.h engine/gnu_ac_build/Makefile: engine/gnu_ac_build/configure
	cd engine/gnu_ac_build && sh configure --with-pic --disable-shared --disable-maintainer-mode

engine/gnu_ac_build/.libs/libmarpa$(LIB_EXT): engine/gnu_ac_build/config.h engine/gnu_ac_build/Makefile
	cd engine/gnu_ac_build && $(MAKE)

engine/perl_ac_build/marpa.c engine/perl_ac_build/marpa.h: engine/read_only/stamp-h1
	$(RM_RF) engine/perl_ac_build
	$(MKPATH) engine/perl_ac_build
	cd engine/read_only && $(TAR) cf - . | $(TAR) xomf - -C ../perl_ac_build

# The Makefile.PL reads the contents of the directory.  marpa.h
# and marpa.c are prerequisites, so that the directory is populated
# before Makefile.PL is copied over
engine/perl_ac_build/Makefile.PL: engine/cf/perl_ac_makefile.PL \
		engine/perl_ac_build/marpa.c engine/perl_ac_build/marpa.h
	cp engine/cf/perl_ac_makefile.PL engine/perl_ac_build/Makefile.PL

engine/perl_ac_build/Makefile: engine/perl_ac_build/Makefile.PL
	cd engine/perl_ac_build && $(PERLRUN) Makefile.PL

engine/perl_ac_build/libmarpa$(LIB_EXT): engine/perl_ac_build/Makefile
	cd engine/perl_ac_build && $(MAKE)

xs/R3$(OBJ_EXT): xs/libmarpa$(LIB_EXT) \
    xs/marpa.h \
    xs/marpa_codes.h \
    xs/general_pattern.xsh \
    xs/marpa_slifop.h

xs/general_pattern.xsh: xs/gp_generate.pl
	perl xs/gp_generate.pl xs/general_pattern.xsh

xs/marpa_slifop.h: xs/create_ops.pl
	perl xs/create_ops.pl > xs/marpa_slifop.h

xs/marpa.h: $(LIBMARPA_BUILD_DIR)/marpa.h
	cp $? $@

xs/marpa_codes.h: $(LIBMARPA_BUILD_DIR)/marpa_codes.h
	cp $? $@

xs/libmarpa$(LIB_EXT): $(LIBMARPA_IN_BUILD_DIR)
	cp $? $@

END_OF_POSTAMBLE

    return $postamble;
} ## end sub MY::postamble

# vim: shiftwidth=4:
