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
my @c = qw/marpa_ami.c marpa_avl.c marpa.c
  marpa_codes.c marpa_obs.c marpa_tavl.c/;

my $define = q{};
$define .= ' -DWIN32 -DPERL_STATIC_SYMS' if ($^O eq 'MSWin32');

my @h_files = <*.h>;
my @c_files = <*.c>;
my $o_files = join q{ }, @c_files;
$o_files =~ s/[.]c/.o/xmsg;

WriteMakefile(
    NAME      => 'marpa',
    DEFINE    => $define,
    SKIP      => [qw(dynamic dynamic_lib dlsyms)],
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
    my $r = '
all :: static
	$(NOECHO) $(NOOP)

config ::
	$(NOECHO) $(NOOP)

';
