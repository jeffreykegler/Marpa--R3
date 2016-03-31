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

use 5.010;
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
$VERSION        = '3.003_003';
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
    'ExtUtils::MakeMaker'   => '6.42',
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
    'Module::Build'         => '0.4003',
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
# This file is written by Build.PL
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

sub file_slurp {
    my ( @name_components ) = @_;
    my $path_name = File::Spec->catfile( @name_components );
    open my $fh, q{<}, $path_name;
    my $contents = do { local $RS = undef; <$fh> };
    close $fh;
    return $contents;
}

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
    Marpa::R3::Stuifzand
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
    DIR => ['xs'],
    EXE_FILES          => [
        'html/script/marpa_r3_html_fmt',
        'html/script/marpa_r3_html_score',
    ],
    META_ADD => {
        no_index => {
            directory => [
                qw( pperl tool libmarpa author.t
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
    MYEXTLIB => 'xs/R3.o xs/libmarpa$(LIB_EXT)',

    test => { RECURSIVE_TEST_FILES => 1 }

);

my @debug_flags            = ();
my @configure_command_args = ();
push @configure_command_args, qw(--with-pic --disable-shared);

if ($libmarpa_debug) {
    if ( defined $ENV{LIBMARPA_CFLAGS} ) {
        $ENV{CFLAGS} = $ENV{LIBMARPA_CFLAGS};
    }
    push @debug_flags, '-DMARPA_DEBUG=1';
    push @debug_flags, '-fno-inline', '-Wno-inline'
        if ( $Config{'cc'} eq 'gcc' );
    push @configure_command_args,
        'MARPA_DEBUG_FLAG=' . ( join q{ }, @debug_flags );
} ## end if ($libmarpa_debug)

# As of this writing, only used by Config::AutoConf logic,
# but that may change.
my $libmarpa_version = file_slurp(qw(engine read_only LIB_VERSION));
chomp $libmarpa_version;
my @libmarpa_version = split /[.]/xms, $libmarpa_version;

my $cwd = Cwd::getcwd();
if ($use_perl_autoconf) {
    my $from_dir  = File::Spec->catdir(qw(engine read_only));
    my $build_dir = File::Spec->catdir(qw(engine perl_ac_build));
    ExtUtils::Install::install(
        [   from_to => { $from_dir => $build_dir, },
            verbose => 1
        ]
    );

    my $src_makefile_writer = do {
        my $cf_dir = File::Spec->catdir(qw(engine cf));
        File::Spec->catfile( $cf_dir, 'write_makefile.pl' );
    };
    my $dest_makefile_pl = File::Spec->catfile( $build_dir, 'Makefile.PL' );
    File::Copy::copy( $src_makefile_writer => $dest_makefile_pl );

    chdir $build_dir || die "Cannot chdir to $build_dir: $ERRNO";
    my $stamp_file = 'stamp-h1';
    File::Path::rmtree( $stamp_file, 0, 0 );

    {

        #
        ## C.f. http://fr.slideshare.net/hashashin/building-c-and-c-libraries-with-perl
        #
        my @c = qw/marpa_ami.c marpa_avl.c marpa.c
            marpa_codes.c marpa_obs.c marpa_slif.c marpa_tavl.c/;
        if ( !-r 'config.h' ) {
            #
            ## Because Config::AutoConf can only generate #define/#undef
            ## stubs, we write our config.h with these stubs, our config.h
            ## will then include a generated config_from_autoconf.h
            #
            if ($verbose) {
                say join q{ }, "Doing config.h"
                    or die "print failed: $ERRNO";
            }
            open my $config_fh, '>>',
                'config.h' || die "Cannot open config.h, $!\n";
            my $ac        = Config::AutoConf->new();
            my $inline_ok = 0;
            {
                $ac->msg_checking('inline');
                my $program = $ac->lang_build_program(
                    "static inline int testinline() {return 1;}\n",
                    'testinline' );
                $inline_ok = $ac->compile_if_else($program);
                $ac->msg_result( $inline_ok ? 'yes' : 'no' );
            }
            my $inline = '';
            if ( !$inline_ok ) {
                foreach (qw/__inline__ __inline/) {
                    my $candidate = $_;
                    $ac->msg_checking($candidate);
                    my $program = $ac->lang_build_program(
                        "static $candidate int testinline() {return 1;}\n",
                        'testinline' );
                    my $rc = $ac->compile_if_else($program);
                    $ac->msg_result( $rc ? 'yes' : 'no' );
                    if ($rc) {
                        $inline = $candidate;
                        last;
                    }
                } ## end foreach (qw/__inline__ __inline/)
            } ## end if ( !$inline_ok )
            if ($inline) {
                print {$config_fh} <<INLINEHOOK;
#ifndef __CONFIG_WITH_STUBS_H
#ifndef __cplusplus
#define inline $inline
#endif
#include "config_from_autoconf.h"
#endif /* __CONFIG_WITH_STUBS_H */
INLINEHOOK
            } ## end if ($inline)
            else {
                print {$config_fh} <<INLINEHOOK;
#ifndef __CONFIG_WITH_STUBS_H
#ifndef __cplusplus
/* #undef inline */
#endif
#include "config_from_autoconf.h"
#endif /* __CONFIG_WITH_STUBS_H */
INLINEHOOK
            } ## end else [ if ($inline) ]

            # Config::Autoconf mistakes 0 for undef, so these must be done explicitly
            say {$config_fh} join q{ }, '#define MARPA_LIB_MAJOR_VERSION',
                $libmarpa_version[0];
            say {$config_fh} join q{ }, '#define MARPA_LIB_MINOR_VERSION',
                $libmarpa_version[1];
            say {$config_fh} join q{ }, '#define MARPA_LIB_MICRO_VERSION',
                $libmarpa_version[2];

            close($config_fh);
            $ac = Config::AutoConf->new();
            my $sizeof_int = $ac->check_sizeof_type('int');
            if ( $sizeof_int < 4 ) {
                die
                    "Marpa requires that int be at least 32 bits -- on this system that is not the case";
            }

            $ac->check_stdc_headers;
            $ac->check_default_headers();

            $ac->define_var( 'PACKAGE', "\"libmarpa\"" );
            $ac->define_var( 'PACKAGE_BUGREPORT',
                "\"http://rt.cpan.org/NoAuth/Bugs.html?Dist=Marpa\"" );
            $ac->define_var( 'PACKAGE_NAME', "\"libmarpa\"" );
            $ac->define_var( 'PACKAGE_STRING',
                "\"libmarpa $libmarpa_version[0].$libmarpa_version[1].$libmarpa_version[2]\""
            );
            $ac->define_var( 'PACKAGE_TARNAME', "\"libmarpa\"" );
            $ac->define_var( 'PACKAGE_URL',     "\"\"" );
            $ac->define_var( 'PACKAGE_VERSION', "\"$libmarpa_version\"" );
            $ac->define_var( 'PACKAGE_STRING',  "\"$libmarpa_version\"" );
            $ac->write_config_h('config_from_autoconf.h');
        } ## end if ( !-r 'config.h' )

        die "Could not run Makefile.PL: $ERRNO"
            if not IPC::Cmd::run(
            command => [ $EXECUTABLE_NAME, 'Makefile.PL' ],
            verbose => 1
            );
    }
} ## end if ($use_perl_autoconf)
else {
    my $from_dir = File::Spec->catdir(qw(engine read_only));
    my $build_dir   = File::Spec->catdir(qw(engine gnu_ac_build));
    ExtUtils::Install::install(
        [ from_to => { $from_dir => $build_dir }, verbose => 1 ] );
    my $stamp_file = 'stamp-h1';

    chdir $build_dir;
    File::Path::rmtree( $stamp_file, 0, 0 );

    my $shell            = $Config{sh};
    my $configure_script = 'configure';
    if ($verbose) {
        say join q{ }, "Running command:", $shell, $configure_script,
            @configure_command_args
            or die "print failed: $ERRNO";
    }
    if (not IPC::Cmd::run(
            command => [ $shell, $configure_script, @configure_command_args ],
            verbose => 1
        )
        )
    {
        die "Failed: $configure_script\n",
         "Current directory: $build_dir\n",
        'Cannot run libmarpa configure';
    } ## end if ( not IPC::Cmd::run( command => [ $shell, $configure_script...]))
} ## end else [ if ($use_perl_autoconf) ]

chdir $cwd;

sub MY::postamble {
    my $postamble = (
        $use_perl_autoconf
        ? "LIBMARPA_BUILD_DIR = engine/perl_ac_build\n"
        : "LIBMARPA_BUILD_DIR = engine/gnu_ac_build\n"
    );

    $postamble .= <<'END_OF_POSTAMBLE';

# The touch's in the following target
# are necessary for GNU autoconf, which is aggressive
# about looking for things to update
# This might be accomplished more easily by adding
# AM_MAINTAINER_MODe([disable]) to configure.ac

engine/gnu_ac_build/.libs/libmarpa$(LIB_EXT): engine/read_only/stamp-h1
	-$(TOUCH) engine/gnu_ac_build/aclocal.m4
	-$(TOUCH) engine/gnu_ac_build/configure
	-$(TOUCH) engine/gnu_ac_build/config.h.in
	cd engine/gnu_ac_build && $(MAKE)

engine/perl_ac_build/libmarpa$(LIB_EXT): engine/read_only/stamp-h1
	cd engine/perl_ac_build && $(MAKE)

xs/R3.o: xs/marpa.h xs/marpa_slif.h

END_OF_POSTAMBLE

    if ($use_perl_autoconf) {
        $postamble .= <<'EOT';
xs/marpa.h: engine/perl_ac_build/marpa.h
	cp $? $@

xs/marpa_slif.h: engine/perl_ac_build/marpa_slif.h
	cp $? $@

xs/libmarpa$(LIB_EXT): engine/perl_ac_build/libmarpa$(LIB_EXT)
	cp $? $@

EOT
    } ## end if ($use_perl_autoconf)
    else {
        $postamble .= <<'EOT';
xs/marpa.h: engine/gnu_ac_build/marpa.h
	cp $? $@

xs/marpa_slif.h: engine/gnu_ac_build/marpa_slif.h
	cp $? $@

xs/libmarpa$(LIB_EXT): engine/gnu_ac_build/.libs/libmarpa$(LIB_EXT)
	cp $? $@

EOT
    } ## end else [ if ($use_perl_autoconf) ]

    return $postamble;
} ## end sub MY::postamble


# vim: shiftwidth=4:
