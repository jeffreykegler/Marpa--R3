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

# It expects to be run in the libmarpa *build* directory.

# This code is adopted from code in the SDBM_File module.

use 5.010001;
use File::Spec;
use ExtUtils::MakeMaker;
use Config::AutoConf;

#
## C.f. http://fr.slideshare.net/hashashin/building-c-and-c-libraries-with-perl
#
my @c = qw/marpa_ami.c marpa_avl.c marpa.c
  marpa_codes.c marpa_obs.c marpa_tavl.c/;

sub file_slurp {
    my ( @name_components ) = @_;
    my $path_name = File::Spec->catfile( @name_components );
    open my $fh, q{<}, $path_name;
    my $contents = do { local $RS = undef; <$fh> };
    close $fh;
    return $contents;
}

my $libmarpa_version = file_slurp(File::Spec->updir(), qw(read_only LIB_VERSION));
chomp $libmarpa_version;
my @libmarpa_version = split /[.]/xms, $libmarpa_version;

#
## Because Config::AutoConf can only generate #define/#undef
## stubs, we write our config.h with these stubs, our config.h
## will then include a generated config_from_autoconf.h
#
open my $config_fh, '>>',
  'config.h' || die "Cannot open config.h, $!\n";
my $ac        = Config::AutoConf->new();
my $inline_ok = 0;
{
    $ac->msg_checking('inline');
    my $program = $ac->lang_build_program(
	"static inline int testinline() {return 1;}\n", 'testinline' );
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

my $define = q{};
$define .= ' -DWIN32 -DPERL_STATIC_SYMS' if ($^O eq 'MSWin32');

my @all_h_files = <*.h>;
my @h_files = grep { $_ ne 'config_from_autoconf.h' } @all_h_files;
my @c_files = <*.c>;
my $o_files = join q{ }, @c_files;
$o_files =~ s/[.]c/.o/xmsg;

WriteMakefile(
    NAME      => 'marpa',
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
    # From the SDBM original ...
    # I hope Mapra doesn't need this -- Jeffrey
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
