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
$VERSION        = '4.001_052';
$STRING_VERSION = $VERSION;
## no critic (BuiltinFunctions::ProhibitStringyEval)
$VERSION = eval $VERSION;
## use critic

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
    'IPC::Cmd'              => '0.40_1',
    'List::Util'            => '1.21',

    # 1.17 shipped with Perl 5.10.1
    'POSIX'                 => '1.17',

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
    my @use_packages     = qw( Scalar::Util Carp Data::Dumper Marpa::R3 );
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
    Scalar::Util
    Test::More
    Time::Piece
    XSLoader
);

my %requires =
    map { ( $_, $version_for_config{$_} ) }
    qw( CPAN::Meta::Converter ),
    @always_required,
    @packages_for_perl_autoconf;

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
        die "Failed to rename POD file: $pod_file";
    } ## end LINE: for my $pod_file (@pod_files)
}
$pod_files{'pod/Marpa_R3.pod'}  = q{$(INST_MAN1DIR)} . '/Marpa-R3.pod';

{
    my @r3_components      = qw(lib Marpa R3);
    my $config_pm_filename = File::Spec->catfile(qw(inc Marpa R3 Config.pm ));
    my @derived_files      = (
        File::Spec->catfile( @r3_components,      'Version.pm' ),
        File::Spec->catfile( @r3_components,      'Installed.pm' ),
    );
    say {*STDERR} 'Writing version files' or die "say failed: $ERRNO";
    write_installed_pm(qw(lib Marpa R3 ));
    my $perl_version_pm = perl_version_contents('Marpa::R3::Perl');
    my $version_pm      = xs_version_contents('Marpa::R3');
    file_write( $version_pm,      qw(lib Marpa R3 Version.pm) );

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
    Marpa::R3::Perl
    Marpa::R3::Test
    Marpa::R3::Display
    Marpa::R3::Internal_G
    Marpa::R3::Internal_R
    Marpa::R3::Internal_V
    Marpa::R3::MetaAST
    Marpa::R3::MetaG
);

my @files_to_cleanup = (
    'lib/Marpa/R3/Version.pm', 'lib/Marpa/R3/Installed.pm',
    'lib/Marpa/R3.o',          'engine/gnu_ac_build',
    'engine/perl_ac_build',
);

my $libmarpa_build_dir =
  $use_perl_autoconf
  ? 'engine/perl_ac_build'
  : 'engine/gnu_ac_build';
my $libmarpa_in_build_dir =
  $use_perl_autoconf
  ?  $libmarpa_build_dir . q{/libmarpa$(LIB_EXT)}
  :  $libmarpa_build_dir . q{/.libs/libmarpa$(LIB_EXT)};

my $myextlib = join q{ }, $libmarpa_in_build_dir, 'lua/marpa_lua$(LIB_EXT)',
  'glue/glue$(LIB_EXT)', 'kollos/kollos$(LIB_EXT)';

# my $ccflags = $Config{ccflags} . " -Iengine/read_only -Ixs";

undef &MY::postamble; # suppress warning
*MY::postamble = sub {
    my ($self) = @_;
    my @postamble_pieces = (".NOTPARALLEL:\n");

# == Logic to compile and build library for GNU autoconf
    push @postamble_pieces, sprintf <<'END_OF_POSTAMBLE_PIECE',
engine/gnu_ac_build/.libs/libmarpa$(LIB_EXT):
	%s
END_OF_POSTAMBLE_PIECE
	$self->cd(File::Spec->catdir(qw(engine)), '$(MAKE)');

# == Logic to compile and build library for Perl autoconf
# GNU autoconf automatically creates/updates stamp-h1.
# For Config::AutoConf, but we don't use it, so we don't create one.

    push @postamble_pieces, sprintf <<'END_OF_POSTAMBLE_PIECE',
engine/perl_ac_build/libmarpa$(LIB_EXT):
	%s
END_OF_POSTAMBLE_PIECE
	$self->cd(File::Spec->catdir(qw(engine)), '$(MAKE)');

# == Logic to build in XS directory:

    push @postamble_pieces, sprintf <<'END_OF_POSTAMBLE_PIECE',
xs/R3$(OBJ_EXT):
	%s
END_OF_POSTAMBLE_PIECE
	$self->cd(File::Spec->catdir(qw(xs)), '$(MAKE) R3$(OBJ_EXT)');

# == Logic to build in Lua directory:

    push @postamble_pieces, sprintf <<'END_OF_POSTAMBLE_PIECE',
lua/marpa_lua$(LIB_EXT):
	%s
END_OF_POSTAMBLE_PIECE
	$self->cd(File::Spec->catdir(qw(lua)), '$(MAKE) ');

# == Logic to build in glue directory:

    push @postamble_pieces, sprintf <<'END_OF_POSTAMBLE_PIECE',
glue/glue$(LIB_EXT):
	%s
END_OF_POSTAMBLE_PIECE
	$self->cd(File::Spec->catdir(qw(glue)), '$(MAKE) ');

# == Logic to build in kollos directory:

    push @postamble_pieces, sprintf <<'END_OF_POSTAMBLE_PIECE',
kollos/kollos$(LIB_EXT):
	%s
END_OF_POSTAMBLE_PIECE
	$self->cd(File::Spec->catdir(qw(kollos)), '$(MAKE) ');

# == Additional dependencies for making from PL files

if ($^O eq 'MSWin32'){
    push @postamble_pieces, <<'END_OF_POSTAMBLE_PIECE';

all :: inc\Marpa\R3\Lua\Test\Builder.pm

all :: inc\Marpa\R3\Lua\Test\More.pm

inc\Marpa\R3\Lua\Test\Builder.pm: inc\Marpa\R3\Lua\Test\Builder.lua inc\Marpa\R3\Lua\Test\Builder.PL
	$(PERLRUN) inc\Marpa\R3\Lua\Test\Builder.PL inc\Marpa\R3\Lua\Test\Builder.pm

inc\Marpa\R3\Lua\Test\More.pm: inc\Marpa\R3\Lua\Test\More.lua inc\Marpa\R3\Lua\Test\More.PL
	$(PERLRUN) inc\Marpa\R3\Lua\Test\More.PL inc\Marpa\R3\Lua\Test\More.pm

END_OF_POSTAMBLE_PIECE
}
else{
    push @postamble_pieces, <<'END_OF_POSTAMBLE_PIECE';

all :: inc/Marpa/R3/Lua/Test/Builder.pm

all :: inc/Marpa/R3/Lua/Test/More.pm

inc/Marpa/R3/Lua/Test/Builder.pm: inc/Marpa/R3/Lua/Test/Builder.lua inc/Marpa/R3/Lua/Test/Builder.PL
	$(PERLRUN) inc/Marpa/R3/Lua/Test/Builder.PL inc/Marpa/R3/Lua/Test/Builder.pm

inc/Marpa/R3/Lua/Test/More.pm: inc/Marpa/R3/Lua/Test/More.lua inc/Marpa/R3/Lua/Test/More.PL
	$(PERLRUN) inc/Marpa/R3/Lua/Test/More.PL inc/Marpa/R3/Lua/Test/More.pm

END_OF_POSTAMBLE_PIECE
}
    push @postamble_pieces, sprintf <<'END_OF_POSTAMBLE_PIECE',
kollos/kollos.lua: lua/lua kollos/kollos.md
	%s
END_OF_POSTAMBLE_PIECE
	$self->cd(File::Spec->catdir(qw(kollos)), '$(MAKE)');

    push @postamble_pieces, sprintf <<'END_OF_POSTAMBLE_PIECE',
lua/lua:
	%s
END_OF_POSTAMBLE_PIECE
	$self->cd(File::Spec->catdir(qw(lua)), '$(MAKE)');

    push @postamble_pieces, sprintf <<'END_OF_POSTAMBLE_PIECE',
glue/glue.lua: lua/lua glue/glue.md
	%s
END_OF_POSTAMBLE_PIECE
	$self->cd(File::Spec->catdir(qw(glue)), '$(MAKE)');

    return join "\n", @postamble_pieces;

}; ## end sub MY::postamble

WriteMakefile(
    clean    => { FILES => ( join q{ }, @files_to_cleanup ) },
    NAME     => 'Marpa::R3',
    VERSION => $STRING_VERSION,
    AUTHOR   => 'Jeffrey Kegler',
    ABSTRACT => 'Release 3 of Marpa',

    # Let the three of these be the same.
    CONFIGURE_REQUIRES => \%requires,
    BUILD_REQUIRES => \%requires,
    PREREQ_PM => \%requires,

    PM                 => \%pm_files,
    MIN_PERL_VERSION => '5.10.1',
    DIR => [qw(engine lua kollos glue xs)],
    META_ADD => {
        no_index => {
            directory => [
                qw( engine author.t )
            ],
            namespace => [
                @no_index_namespace_inclusive
            ],
            package =>
                [ @no_index_namespace_inclusive ],
        }
    },
    PM => {
        q[lib/Marpa/R3.pm]           => q[$(INST_LIB)/Marpa/R3.pm],
        q[lib/Marpa/R3/ASF.pm]       => q[$(INST_LIB)/Marpa/R3/ASF.pm],
        q[lib/Marpa/R3/ASF2.pm]       => q[$(INST_LIB)/Marpa/R3/ASF2.pm],
        q[lib/Marpa/R3/Common.pm]    => q[$(INST_LIB)/Marpa/R3/Common.pm],
        q[lib/Marpa/R3/Glade.pm]    => q[$(INST_LIB)/Marpa/R3/Glade.pm],
        q[lib/Marpa/R3/Installed.pm] => q[$(INST_LIB)/Marpa/R3/Installed.pm],
        q[lib/Marpa/R3/Internal.pm]  => q[$(INST_LIB)/Marpa/R3/Internal.pm],
        q[lib/Marpa/R3/MetaAST.pm]   => q[$(INST_LIB)/Marpa/R3/MetaAST.pm],
        q[lib/Marpa/R3/MetaG.pm]     => q[$(INST_LIB)/Marpa/R3/MetaG.pm],
        q[lib/Marpa/R3/SLG.pm]       => q[$(INST_LIB)/Marpa/R3/SLG.pm],
        q[lib/Marpa/R3/SLR.pm]       => q[$(INST_LIB)/Marpa/R3/SLR.pm],
        q[lib/Marpa/R3/SLV.pm]       => q[$(INST_LIB)/Marpa/R3/SLV.pm],
        q[lib/Marpa/R3/Version.pm] => q[$(INST_LIB)/Marpa/R3/Version.pm],
        q[lib/Marpa/R3/X.pm]       => q[$(INST_LIB)/Marpa/R3/X.pm]
      },
    META_MERGE => {
        resources =>
            { repository => 'git://github.com/jeffreykegler/Marpa--R3.git', },
    },
    MAN1PODS => \%pod_files,
    LICENSE  => 'perl_5',
    OBJECT => 'xs/R3$(OBJ_EXT)',
    MYEXTLIB => $myextlib

);

# vim: shiftwidth=4:
