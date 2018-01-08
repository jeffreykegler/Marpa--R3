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

package Marpa::R3::Internal::License;

use 5.010001;
use strict;
use warnings;

use English qw( -no_match_vars );
use Fatal qw(open close read);
use File::Spec;
use Text::Diff ();

my $lgpl_copyright_line = q{Copyright 2018 Jeffrey Kegler};
( my $copyright_line_in_tex = $lgpl_copyright_line )
    =~ s/ ^ Copyright \s /Copyright \\copyright\\ /xms;

my $closed_license = "$lgpl_copyright_line\n" . <<'END_OF_STRING';
This document is not part of the Marpa or Marpa::R3 source.
Although it may be included with a Marpa distribution that
is under an open source license, this document is
not under that open source license.
Jeffrey Kegler retains full rights.
END_OF_STRING

my $lgpl_license_body = <<'END_OF_STRING';
This file is part of Marpa::R3.  Marpa::R3 is free software: you can
redistribute it and/or modify it under the terms of the GNU Lesser
General Public License as published by the Free Software Foundation,
either version 3 of the License, or (at your option) any later version.

Marpa::R3 is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser
General Public License along with Marpa::R3.  If not, see
http://www.gnu.org/licenses/.
END_OF_STRING

my $lgpl_license = "$lgpl_copyright_line\n$lgpl_license_body";

my $perl_copyright_line = 'Marpa::R3 is Copyright (C) 2018, Jeffrey Kegler.';

my $perl_license_body = <<'END_OF_STRING';
This module is free software; you can redistribute it and/or modify it
under the same terms as Perl 5.10.1. For more details, see the full text
of the licenses in the directory LICENSES.
END_OF_STRING

my $perl_no_warranty = <<'END_OF_STRING';
This program is distributed in the hope that it will be
useful, but it is provided "as is" and without any express
or implied warranties. For details, see the full text of
of the licenses in the directory LICENSES.
END_OF_STRING

my $perl_license = join "\n", $perl_copyright_line, q{}, $perl_license_body,
  $perl_no_warranty;

my $marpa_r3_license = $lgpl_license;
$marpa_r3_license =~ s/Marpa::R3/Libmarpa/gxms;

my $mit_license_body = <<'END_OF_STRING';
Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
END_OF_STRING

my $mit_license = "$lgpl_copyright_line\n$mit_license_body";

# License, redone as Tex input
my $license_in_tex =
    "$copyright_line_in_tex\n" . "\\bigskip\\noindent\n" . "$lgpl_license_body";
$license_in_tex =~ s/^$/\\smallskip\\noindent/gxms;

my $texi_copyright = <<'END_OF_TEXI_COPYRIGHT';
Copyright @copyright{} 2018 Jeffrey Kegler.
END_OF_TEXI_COPYRIGHT

my $fdl_license = <<'END_OF_FDL_LANGUAGE';
@quotation
Permission is granted to copy, distribute and/or modify this document
under the terms of the @acronym{GNU} Free Documentation License,
Version 1.3 or any later version published by the Free Software
Foundation.
A copy of the license is included in the section entitled
``@acronym{GNU} Free Documentation License.''
@end quotation
@end copying
END_OF_FDL_LANGUAGE

my $cc_a_nd_body = <<'END_OF_CC_A_ND_LANGUAGE';
This document is licensed under
a Creative Commons Attribution-NoDerivs 3.0 United States License.
END_OF_CC_A_ND_LANGUAGE

my $cc_a_nd_license = "$lgpl_copyright_line\n$cc_a_nd_body";
my $cc_a_nd_thanks = $cc_a_nd_body;

sub hash_comment {
    my ( $text, $char ) = @_;
    $char //= q{#};
    $text =~ s/^/$char /gxms;
    $text =~ s/ [ ]+ $//gxms;
    return $text;
} ## end sub hash_comment

# Assumes $text ends in \n
sub c_comment {
    my ($text) = @_;
    $text =~ s/^/ * /gxms;
    $text =~ s/ [ ] $//gxms;
    return qq{/*\n$text */\n};
} ## end sub c_comment

my $c_license          = c_comment($perl_license);
my $c_mit_license          = c_comment($mit_license);
my $c_mit_license_2015          = $c_mit_license;
    $c_mit_license_2015          =~ s/2018/2015/xms;
my $lua_license = hash_comment($mit_license, q{--});
my $xs_license          = c_comment($perl_license);
my $r2_hash_license    = hash_comment($lgpl_license);
my $perl_hash_license    = hash_comment($perl_license);
my $libmarpa_hash_license    = hash_comment($mit_license);
my $xsh_hash_license    = hash_comment($perl_license, q{ #});
my $tex_closed_license = hash_comment( $closed_license, q{%} );
my $tex_license        = hash_comment( $lgpl_license, q{%} );
my $tex_cc_a_nd_license = hash_comment( $cc_a_nd_license, q{%} );

my $md_license = "<!--\n" . $mit_license . '-->';

my $perl_pod_no_warranty = <<'END_OF_NO_WARRANTY';
This program is distributed in the hope that it will be
useful, but without any warranty; without even the implied
warranty of merchantability or fitness for a particular purpose.
END_OF_NO_WARRANTY

my $perl_pod_legalese = join "\n", $perl_copyright_line, q{}, $perl_license_body,
  $perl_pod_no_warranty;
$perl_pod_legalese =~ s/^/  /gxms;
$perl_pod_legalese =~ s/[ ]+$//gxms;

my $perl_pod_section = <<'END_OF_STRING';
=head1 COPYRIGHT AND LICENSE

=for Marpa::R3::Display
ignore: 1

END_OF_STRING

$perl_pod_section .= "$perl_pod_legalese\n";

# Next line is to fake out display checking logic
# Otherwise it will think the lines to come are part
# of a display

=cut

$perl_pod_section .= <<'END_OF_STRING';
=for Marpa::R3::Display::End

END_OF_STRING

# Next line is to fake out display checking logic
# Otherwise it will think the lines to come are part
# of a display

=cut

my %GNU_file = (
    map {
    (
        'engine/read_only/' . $_,   1,
        )
    } qw(
        aclocal.m4
        config.guess
        config.sub
        configure
        depcomp
        mdate-sh
        texinfo.tex
        ltmain.sh
        m4/libtool.m4
        m4/ltoptions.m4
        m4/ltsugar.m4
        m4/ltversion.m4
        m4/lt~obsolete.m4
        missing
        Makefile.in
    )
);;

sub ignored {
    my ( $filename, $verbose ) = @_;
    my @problems = ();
    if ($verbose) {
        say {*STDERR} "Checking $filename as ignored file" or die "say failed: $ERRNO";
    }
    return @problems;
} ## end sub trivial

sub trivial {
    my ( $filename, $verbose ) = @_;
    if ($verbose) {
        say {*STDERR} "Checking $filename as trivial file" or die "say failed: $ERRNO";
    }
    my $length   = 1000;
    my @problems = ();
    my $actual_length = -s $filename;
    if (not defined $actual_length) {
        my $problem =
            qq{"Trivial" file does not exit: "$filename"\n};
        return $problem;
    }
    if ( -s $filename > $length ) {
        my $problem =
            qq{"Trivial" file is more than $length characters: "$filename"\n};
        push @problems, $problem;
    }
    return @problems;
} ## end sub trivial

sub check_GNU_copyright {
    my ( $filename, $verbose ) = @_;
    if ($verbose) {
        say {*STDERR} "Checking $filename as GNU copyright file" or die "say failed: $ERRNO";
    }
    my @problems = ();
    my $text = slurp_top( $filename, 1000 );
    ${$text} =~ s/^[#]//gxms;
    if ( ${$text}
        !~ / \s copyright \s .* Free \s+ Software \s+ Foundation [\s,] /xmsi )
    {
        my $problem = "GNU copyright missing in $filename\n";
        if ($verbose) {
            $problem .= "$filename starts:\n" . ${$text} . "\n";
        }
        push @problems, $problem;
    } ## end if ( ${$text} !~ ...)
    return @problems;
} ## end sub check_GNU_copyright

sub check_X_copyright {
    my ( $filename, $verbose ) = @_;
    if ($verbose) {
        say {*STDERR} "Checking $filename as X Consortium file" or die "say failed: $ERRNO";
    }
    my @problems = ();
    my $text = slurp_top( $filename, 1000 );
    if ( ${$text} !~ / \s copyright \s .* X \s+ Consortium [\s,] /xmsi ) {
        my $problem = "X copyright missing in $filename\n";
        if ($verbose) {
            $problem .= "$filename starts:\n" . ${$text} . "\n";
        }
        push @problems, $problem;
    } ## end if ( ${$text} !~ ...)
    return @problems;
} ## end sub check_X_copyright

sub check_tag {
    my ( $tag, $length ) = @_;
    $length //= 250;
    return sub {
        my ( $filename, $verbose ) = @_;
        my @problems = ();
        my $text = slurp_top( $filename, $length );
        if ( ( index ${$text}, $tag ) < 0 ) {
            my $problem = "tag missing in $filename\n";
            if ($verbose) {
                $problem .= "\nMissing tag:\n$tag\n";
            }
            push @problems, $problem;
        } ## end if ( ( index ${$text}, $tag ) < 0 )
        return @problems;
        }
} ## end sub check_tag

my %files_by_type = (
    'LICENSES/Artistic_1_0' => \&ignored,
    'LICENSES/GPL_2' => \&ignored,
    'META.json' =>
        \&ignored,    # not source, and not clear how to add license at top
    'META.yml' =>
        \&ignored,    # not source, and not clear how to add license at top
    'README'                            => \&trivial,
    'lua/CHANGES'                       => \&trivial,
    'ABOUT_ME'                          => \&trivial,
    'INSTALL'                           => \&trivial,
    'TODO'                              => \&trivial,
    'author.t/accept_tidy'              => \&trivial,
    'author.t/critic1'                  => \&trivial,
    'author.t/perltidyrc'               => \&trivial,
    'author.t/spelling_exceptions.list' => \&trivial,
    'author.t/tidy1'                    => \&trivial,
    'etc/pod_errors.pl'                 => \&trivial,
    'etc/pod_dump.pl'                   => \&trivial,
    'etc/dovg.sh'                       => \&trivial,
    'etc/compile_for_debug.sh'          => \&trivial,
    'etc/OLD_libmarpa_test.sh'              => \&trivial,
    'etc/reserved_check.sh'             => \&trivial,
    'kollos/miranda'             =>
        gen_license_problems_in_text_file($lua_license, '2018'),
    'engine/LOG_DATA'                 => \&ignored,    # not worth the trouble
    'engine/cf/LIBMARPA_MODE'         => \&trivial,
    'engine/cf/INSTALL.SKIP' => \&trivial,
    'engine/read_only/LIB_VERSION'    => \&trivial,
    'engine/read_only/LIB_VERSION.in' => \&trivial,
    'engine/read_only/Makefile.am' =>
        gen_license_problems_in_hash_file($libmarpa_hash_license, '2015'),
    'engine/read_only/configure.ac' =>
        gen_license_problems_in_hash_file($libmarpa_hash_license, '2015'),
    'engine/read_only/notes/shared_test.txt' =>
        gen_license_problems_in_hash_file($libmarpa_hash_license, '2015'),
    'engine/read_only/win32/do_config_h.pl' =>
        gen_license_problems_in_hash_file($libmarpa_hash_license, '2015'),
    'engine/read_only/Makefile.win32' =>
        gen_license_problems_in_hash_file($libmarpa_hash_license, '2015'),
    'etc/my_suppressions' => \&trivial,
    'xs/ppport.h' => \&ignored,    # copied from CPAN, just leave it alone
    'engine/read_only/README' =>
        gen_license_problems_in_text_file($mit_license, '2015'),
    'engine/read_only/README.INSTALL' =>
        gen_license_problems_in_text_file($libmarpa_hash_license, '2015'),
    'engine/read_only/AUTHORS' => \&trivial,
    'engine/read_only/NEWS' => \&trivial,
    'engine/read_only/ChangeLog' => \&trivial,
    'engine/read_only/events.table' =>
        gen_license_problems_in_text_file($libmarpa_hash_license, '2015'),
    'engine/read_only/error_codes.table' =>
        gen_license_problems_in_text_file($libmarpa_hash_license, '2015'),
    'engine/read_only/steps.table' =>
        gen_license_problems_in_text_file($libmarpa_hash_license, '2015'),

    ## GNU license text, leave it alone
    'engine/read_only/COPYING.LESSER' => \&ignored,

    ## GNU standard -- has their license language
    'engine/read_only/INSTALL' => \&ignored,
    'engine/read_only/compile' => \&ignored,

    'engine/read_only/COPYING' => gen_license_problems_in_text_file( $mit_license_body ),
    'engine/read_only/stamp-h1' => \&trivial,
    'engine/read_only/stamp-1' => \&trivial,
    'engine/read_only/stamp-vti' => \&trivial,
    'engine/read_only/install-sh' => \&check_X_copyright,
    'engine/read_only/config.h.in' =>
        check_tag( 'Generated from configure.ac by autoheader', 250 ),

    # Leave licensing in adopted Lua packages as is
    'kollos/inspect.lua' => \&ignored,
    'kollos/strict.lua' => \&ignored,
    'inc/Marpa/R3/Lua/Test/Builder.lua' => \&ignored,
    'inc/Marpa/R3/Lua/Test/More.lua' => \&ignored,

    # Leave GNU obstack licensing as is
    'engine/read_only/marpa_obs.c' => \&ignored,
    'engine/read_only/marpa_obs.h' => \&ignored,

    # Leave Pfaff's licensing as is
    'engine/read_only/marpa_avl.c'  => \&ignored,
    'engine/read_only/marpa_avl.h'  => \&ignored,
    'engine/read_only/marpa_tavl.c' => \&ignored,
    'engine/read_only/marpa_tavl.h' => \&ignored,

    # Leave Roberto's licensing as is

    'lua/COPYRIGHT' => \&ignored,
    'lua/HISTORY' => \&ignored,
    'lua/INSTALL' => \&ignored,
    'lua/README' => \&ignored,
    'lua/lapi.c.h' => \&ignored,
    'lua/lapi.h' => \&ignored,
    'lua/lauxlib.c.h' => \&ignored,
    'lua/lauxlib.h' => \&ignored,
    'lua/lbaselib.c.h' => \&ignored,
    'lua/lcode.c.h' => \&ignored,
    'lua/lcode.h' => \&ignored,
    'lua/ldblib.c.h' => \&ignored,
    'lua/ldebug.c.h' => \&ignored,
    'lua/ldebug.h' => \&ignored,
    'lua/ldo.c.h' => \&ignored,
    'lua/ldo.h' => \&ignored,
    'lua/ldump.c.h' => \&ignored,
    'lua/lfunc.c.h' => \&ignored,
    'lua/lfunc.h' => \&ignored,
    'lua/lgc.c.h' => \&ignored,
    'lua/lgc.h' => \&ignored,
    'lua/liblua.a' => \&ignored,
    'lua/linit.c.h' => \&ignored,
    'lua/liolib.c.h' => \&ignored,
    'lua/llex.c.h' => \&ignored,
    'lua/llex.h' => \&ignored,
    'lua/llimits.h' => \&ignored,
    'lua/lmathlib.c.h' => \&ignored,
    'lua/lmem.c.h' => \&ignored,
    'lua/lmem.h' => \&ignored,
    'lua/loadlib.c.h' => \&ignored,
    'lua/lobject.c.h' => \&ignored,
    'lua/lobject.h' => \&ignored,
    'lua/lopcodes.c.h' => \&ignored,
    'lua/lopcodes.h' => \&ignored,
    'lua/loslib.c.h' => \&ignored,
    'lua/lparser.c.h' => \&ignored,
    'lua/lparser.h' => \&ignored,
    'lua/lstate.c.h' => \&ignored,
    'lua/lstate.h' => \&ignored,
    'lua/lstring.c.h' => \&ignored,
    'lua/lstring.h' => \&ignored,
    'lua/lstrlib.c.h' => \&ignored,
    'lua/ltable.c.h' => \&ignored,
    'lua/ltable.h' => \&ignored,
    'lua/ltablib.c.h' => \&ignored,
    'lua/ltm.c.h' => \&ignored,
    'lua/ltm.h' => \&ignored,
    'lua/luac.c.h' => \&ignored,
    'lua/lua.c.h' => \&ignored,
    'lua/luaconf.h' => \&ignored,
    'lua/lua.h' => \&ignored,
    'lua/lualib.h' => \&ignored,
    'lua/lundump.c.h' => \&ignored,
    'lua/lundump.h' => \&ignored,
    'lua/lvm.c.h' => \&ignored,
    'lua/lvm.h' => \&ignored,
    'lua/lzio.c.h' => \&ignored,
    'lua/lzio.h' => \&ignored,
    'lua/Makefile' => \&ignored,
    'lua/prefix.pl' => \&ignored,
    'lua/print.c.h' => \&ignored,
    'lua/one.c' => \&ignored,
    'lua/lcorolib.c.h' => \&ignored,
    'lua/lbitlib.c.h' => \&ignored,
    'lua/lctype.c.h' => \&ignored,
    'lua/lctype.h' => \&ignored,
    'lua/lprefix.h' => \&ignored,
    'lua/lutf8lib.c.h' => \&ignored,

    # Libmarpa licensing
    'engine/read_only/marpa_ami.h' =>
        &gen_license_problems_in_c_file($c_mit_license_2015),
    'engine/read_only/marpa.h' =>
        &gen_license_problems_in_c_file($c_mit_license_2015),
    'engine/read_only/marpa_codes.c' =>
        &gen_license_problems_in_c_file($c_mit_license_2015),
    'engine/read_only/marpa.c' =>
        &gen_license_problems_in_c_file($c_mit_license_2015),
    'engine/read_only/marpa_codes.h' =>
        &gen_license_problems_in_c_file($c_mit_license_2015),
    'engine/read_only/marpa_ami.c' =>
        &gen_license_problems_in_c_file($c_mit_license_2015),

    # Kollos licensing
    'okollos/okollos.h' =>
        &gen_license_problems_in_c_file($c_mit_license),

    # MS .def file -- contents trivial
    'engine/read_only/win32/marpa.def' => \&ignored,
);


sub file_type {
    my ($filename) = @_;
    my $closure = $files_by_type{$filename};
    return $closure if defined $closure;
    my ( $volume, $dirpart, $filepart ) = File::Spec->splitpath($filename);
    my @dirs = grep {length} File::Spec->splitdir($dirpart);
    return \&ignored if $filepart =~ /[.]tar\z/xms;

    # info files are generated -- licensing is in source
    return \&ignored if $filepart =~ /[.]info\z/xms;
    return \&trivial if $filepart eq '.gitignore';
    return \&trivial if $filepart eq '.gitattributes';
    return \&trivial if $filepart eq '.gdbinit';
    return \&check_GNU_copyright
        if $GNU_file{$filename};
    return gen_license_problems_in_perl_file($perl_hash_license)
        if $filepart =~ /[.] (PL|pl|pm|t) \z /xms;
    return gen_license_problems_in_perl_file($perl_hash_license)
        if $filepart eq 'typemap';
    return \&license_problems_in_fdl_file
        if $filepart eq 'internal.texi';
    return \&license_problems_in_fdl_file
        if $filepart eq 'api.texi';
    return \&license_problems_in_pod_file if $filepart =~ /[.]pod \z/xms;
    return gen_license_problems_in_text_file($lua_license, '2018')
        if $filepart =~ /[.] (lua) \z /xms;
    return gen_license_problems_in_text_file($md_license, '2018')
        if $filepart =~ /[.] (md) \z /xms;
    return gen_license_problems_in_c_file($xs_license)
        if $filepart =~ /[.] (xs) \z /xms;
    return gen_license_problems_in_c_file()
        if $filepart =~ /[.] (c|h) \z /xms;
    return \&license_problems_in_xsh_file
        if $filepart =~ /[.] (xsh) \z /xms;
    return \&license_problems_in_sh_file
        if $filepart =~ /[.] (sh) \z /xms;
    return gen_license_problems_in_c_file()
        if $filepart =~ /[.] (c|h) [.] in \z /xms;
    return \&license_problems_in_tex_file
        if $filepart =~ /[.] (w) \z /xms;
    return \&trivial
        if $filepart =~ /[.] time [-] stamp \z /xms;
    return gen_license_problems_in_hash_file()

} ## end sub file_type

sub Marpa::R3::License::file_license_problems {
    my ( $filename, $verbose ) = @_;
    $verbose //= 0;
    if ($verbose) {
        say {*STDERR} "Checking license of $filename" or die "say failed: $ERRNO";
    }
    my @problems = ();
    return @problems if @problems;
    my $closure = file_type($filename);
    if ( defined $closure ) {
        push @problems, $closure->( $filename, $verbose );
        return @problems;
    }

    # type eq "text"
    my $problems_closure = gen_license_problems_in_text_file();
    push @problems, $problems_closure->( $filename, $verbose );
    return @problems;
} ## end sub Marpa::R3::License::file_license_problems

sub Marpa::R3::License::license_problems {
    my ( $files, $verbose ) = @_;
    return
        map { Marpa::R3::License::file_license_problems( $_, $verbose ) }
        @{$files};
} ## end sub Marpa::R3::License::license_problems

sub slurp {
    my ($filename) = @_;
    local $RS = undef;
    open my $fh, q{<}, $filename;
    my $text = <$fh>;
    close $fh;
    return \$text;
} ## end sub slurp

sub slurp_top {
    my ( $filename, $length ) = @_;
    $length //= 2000 + ( length $perl_license );
    local $RS = undef;
    open my $fh, q{<}, $filename;
    my $text;
    read $fh, $text, $length;
    close $fh;
    return \$text;
} ## end sub slurp_top

sub files_equal {
    my ( $filename1, $filename2 ) = @_;
    return ${ slurp($filename1) } eq ${ slurp($filename2) };
}

sub tops_equal {
    my ( $filename1, $filename2, $length ) = @_;
    return ${ slurp_top( $filename1, $length ) } eq
        ${ slurp_top( $filename2, $length ) };
}

sub gen_license_problems_in_hash_file {
    my ($license, $year) = @_;
    $license //= $perl_hash_license;
    if ($year) {
       $license =~ s/2018/$year/;
    }
    return sub {
        my ( $filename, $verbose ) = @_;
        if ($verbose) {
            say {*STDERR} "Checking $filename as hash style file"
                or die "say failed: $ERRNO";
        }
        my @problems = ();
        my $text = slurp_top( $filename, 200 + length $license );
        if ( 0 > index ${$text}, $license ) {
            my $problem = "No license language in $filename (hash style)\n";
            if ($verbose) {
                $problem
                    .= "=== Differences ===\n"
                    . Text::Diff::diff( $text, \$license )
                    . ( q{=} x 30 );
            } ## end if ($verbose)
            push @problems, $problem;
        } ## end if ( $license ne ${$text} )
        if ( scalar @problems and $verbose >= 2 ) {
            my $problem =
                  "=== license for $filename should be as follows:\n"
                . $license
                . ( q{=} x 30 );
            push @problems, $problem;
        } ## end if ( scalar @problems and $verbose >= 2 )
        return @problems;
    };
} ## end sub gen_license_problems_in_hash_file

sub license_problems_in_xsh_file {
    my ( $filename, $verbose ) = @_;
    if ($verbose) {
        say {*STDERR} "Checking $filename as hash style file"
            or die "say failed: $ERRNO";
    }
    my @problems = ();
    my $text = slurp_top( $filename, length $xsh_hash_license );
    if ( $xsh_hash_license ne ${$text} ) {
        my $problem = "No license language in $filename (hash style)\n";
        if ($verbose) {
            $problem
                .= "=== Differences ===\n"
                . Text::Diff::diff( $text, \$xsh_hash_license )
                . ( q{=} x 30 );
        } ## end if ($verbose)
        push @problems, $problem;
    } ## end if ( $xsh_hash_license ne ${$text} )
    if ( scalar @problems and $verbose >= 2 ) {
        my $problem =
              "=== license for $filename should be as follows:\n"
            . $xsh_hash_license
            . ( q{=} x 30 );
        push @problems, $problem;
    } ## end if ( scalar @problems and $verbose >= 2 )
    return @problems;
} ## end sub license_problems_in_xsh_file

sub license_problems_in_sh_file {
    my ( $filename, $verbose ) = @_;
    if ($verbose) {
        say {*STDERR} "Checking $filename as sh hash style file"
            or die "say failed: $ERRNO";
    }
    my @problems = ();
    $DB::single = 1;
    my $ref_text = slurp_top( $filename, 256 + length $perl_hash_license );
    my $text = ${$ref_text};
    $text =~ s/ \A [#][!] [^\n]* \n//xms;
    $text = substr $text, 0, length $perl_hash_license;
    if ( $perl_hash_license ne $text ) {
        my $problem = "No license language in $filename (sh hash style)\n";
        if ($verbose) {
            $problem
                .= "=== Differences ===\n"
                . Text::Diff::diff( \$text, \$perl_hash_license )
                . ( q{=} x 30 );
        } ## end if ($verbose)
        push @problems, $problem;
    }
    if ( scalar @problems and $verbose >= 2 ) {
        my $problem =
              "=== license for $filename should be as follows:\n"
            . $perl_hash_license
            . ( q{=} x 30 );
        push @problems, $problem;
    } ## end if ( scalar @problems and $verbose >= 2 )
    return @problems;
}


sub gen_license_problems_in_perl_file {
    my ($license, $year) = @_;
    my $perl_license = $license // $r2_hash_license;
    if ($year) {
        $perl_license =~ s/2018/$year/xms;
    }
    return sub {
        my ( $filename, $verbose ) = @_;
        if ($verbose) {
            say {*STDERR} "Checking $filename as perl file"
                or die "say failed: $ERRNO";
        }
        $verbose //= 0;
        my @problems = ();
        my $text = slurp_top( $filename, 256 + length $perl_license );

        # Delete hash bang line, if present
        ${$text} =~ s/\A [#][!] [^\n] \n//xms;
        if ( 0 > index ${$text}, $perl_license ) {
            my $problem = "No license language in $filename (perl style)\n";
            if ($verbose) {
                $problem
                    .= "=== Differences ===\n"
                    . Text::Diff::diff( $text, \$perl_license )
                    . ( q{=} x 30 );
            } ## end if ($verbose)
            push @problems, $problem;
        } ## end if ( 0 > index ${$text}, $perl_license )
        if ( scalar @problems and $verbose >= 2 ) {
            my $problem =
                  "=== license for $filename should be as follows:\n"
                . $perl_license
                . ( q{=} x 30 );
            push @problems, $problem;
        } ## end if ( scalar @problems and $verbose >= 2 )
        return @problems;
    };
} ## end sub gen_license_problems_in_perl_file

sub gen_license_problems_in_c_file {
    my ($license) = @_;
    $license //= $c_license;
    return sub {
        my ( $filename, $verbose ) = @_;
        if ($verbose) {
            say {*STDERR} "Checking $filename as C file"
                or die "say failed: $ERRNO";
        }
        my @problems = ();
        my $text = slurp_top( $filename, 500 + length $license );
        ${$text}
            =~ s{ \A [/][*] \s+ DO \s+ NOT \s+ EDIT \s+ DIRECTLY [^\n]* \n }{}xms;
        if ( ( index ${$text}, $license ) < 0 ) {
            my $problem = "No license language in $filename (C style)\n";
            if ($verbose) {
                $problem
                    .= "=== Differences ===\n"
                    . Text::Diff::diff( $text, \$license )
                    . ( q{=} x 30 );
            } ## end if ($verbose)
            push @problems, $problem;
        } ## end if ( ( index ${$text}, $license ) < 0 )
        if ( scalar @problems and $verbose >= 2 ) {
            my $problem =
                  "=== license for $filename should be as follows:\n"
                . $license
                . ( q{=} x 30 );
            push @problems, $problem;
        } ## end if ( scalar @problems and $verbose >= 2 )
        return @problems;
    };
} ## end sub gen_license_problems_in_c_line

sub license_problems_in_tex_file {
    my ( $filename, $verbose ) = @_;
    if ($verbose) {
        say {*STDERR} "Checking $filename as TeX file" or die "say failed: $ERRNO";
    }
    my @problems = ();
    my $text = slurp_top( $filename, 200 + length $tex_license );
    ${$text}
        =~ s{ \A [%] \s+ DO \s+ NOT \s+ EDIT \s+ DIRECTLY [^\n]* \n }{}xms;
    if ( ( index ${$text}, $tex_license ) < 0 ) {
        my $problem = "No license language in $filename (TeX style)\n";
        if ($verbose) {
            $problem
                .= "=== Differences ===\n"
                . Text::Diff::diff( $text, \$tex_license )
                . ( q{=} x 30 );
        } ## end if ($verbose)
        push @problems, $problem;
    } ## end if ( ( index ${$text}, $tex_license ) < 0 )
    if ( scalar @problems and $verbose >= 2 ) {
        my $problem =
              "=== license for $filename should be as follows:\n"
            . $tex_license
            . ( q{=} x 30 );
        push @problems, $problem;
    } ## end if ( scalar @problems and $verbose >= 2 )
    return @problems;
} ## end sub license_problems_in_tex_file

# This was the license for the lyx documents
# For the Latex versions, I switched to CC-A_ND
sub tex_closed {
    my ( $filename, $verbose ) = @_;
    my @problems = ();
    my $text = slurp_top( $filename, 400 + length $tex_closed_license );

    if ( ( index ${$text}, $tex_closed_license ) < 0 ) {
        my $problem = "No license language in $filename (TeX style)\n";
        if ($verbose) {
            $problem
                .= "=== Differences ===\n"
                . Text::Diff::diff( $text, \$tex_closed_license )
                . ( q{=} x 30 );
        } ## end if ($verbose)
        push @problems, $problem;
    } ## end if ( ( index ${$text}, $tex_closed_license ) < 0 )
    if ( scalar @problems and $verbose >= 2 ) {
        my $problem =
              "=== license for $filename should be as follows:\n"
            . $tex_closed_license
            . ( q{=} x 30 );
        push @problems, $problem;
    } ## end if ( scalar @problems and $verbose >= 2 )
    return @problems;
} ## end sub tex_closed

# Note!!!  This license is not Debian-compatible!!!
sub tex_cc_a_nd {
    my ( $filename, $verbose ) = @_;
    my @problems = ();
    my $text = slurp( $filename );

# say "=== Looking for\n", $tex_cc_a_nd_license, "===";
# say "=== Looking in\n", ${$text}, "===";
# say STDERR index ${$text}, $tex_cc_a_nd_license ;

    if ( ( index ${$text}, $tex_cc_a_nd_license ) != 0 ) {
        my $problem = "No CC-A-ND language in $filename (TeX style)\n";
        push @problems, $problem;
    } ## end if ( ( index ${$text}, $tex_cc_a_nd_license ) != 0 )
    if ( ( index ${$text}, $cc_a_nd_thanks ) < 0 ) {
        my $problem = "No CC-A-ND LaTeX thanks in $filename\n";
        push @problems, $problem;
    } ## end if ( ( index ${$text}, $tex_cc_a_nd_license ) != 0 )
    if ( ( index ${$text}, $copyright_line_in_tex ) < 0 ) {
        my $problem = "No copyright line in $filename\n";
        push @problems, $problem;
    } ## end if ( ( index ${$text}, $tex_cc_a_nd_license ) != 0 )
    if ( scalar @problems and $verbose >= 2 ) {
        my $problem =
              "=== license for $filename should be as follows:\n"
            . $tex_closed_license
            . ( q{=} x 30 );
        push @problems, $problem;
    } ## end if ( scalar @problems and $verbose >= 2 )
    return @problems;
} ## end sub tex_closed

sub cc_a_nd {
    my ( $filename, $verbose ) = @_;
    my @problems = ();
    my $text     = slurp($filename);
    if ( ( index ${$text}, $cc_a_nd_body ) < 0 ) {
        my $problem = "No CC-A-ND language in $filename (TeX style)\n";
        push @problems, $problem;
    }
    if ( ( index ${$text}, $lgpl_copyright_line ) < 0 ) {
        my $problem = "No copyright line in $filename\n";
        push @problems, $problem;
    }
    if ( scalar @problems and $verbose >= 2 ) {
        my $problem =
              "=== license for $filename should be as follows:\n"
            . $cc_a_nd_body
            . ( q{=} x 30 );
        push @problems, $problem;
    } ## end if ( scalar @problems and $verbose >= 2 )
    return @problems;
} ## end sub cc_a_nd

sub copyright_page {
    my ( $filename, $verbose ) = @_;

    my @problems = ();
    my $text     = ${ slurp($filename) };
    if ( $text =~ m/ ^ Copyright \s [^J]* \s Jeffrey \s Kegler $ /xmsp ) {
        ## no critic (Variables::ProhibitPunctuationVars);
        my $pos = length ${^PREMATCH};
        $text = substr $text, $pos;
    }
    else {
        push @problems,
            "No copyright and license language in copyright page file: $filename\n";
    }
    if ( not scalar @problems and ( index $text, $license_in_tex ) < 0 ) {
        my $problem = "No copyright/license in $filename\n";
        if ($verbose) {
            $problem .= "Missing copyright/license:\n"
                . Text::Diff::diff( \$text, \$license_in_tex );
        }
        push @problems, $problem;
    } ## end if ( not scalar @problems and ( index $text, $license_in_tex...))
    if ( scalar @problems and $verbose >= 2 ) {
        my $problem =
              "=== copyright/license in $filename should be as follows:\n"
            . $license_in_tex
            . ( q{=} x 30 );
        push @problems, $problem;
    } ## end if ( scalar @problems and $verbose >= 2 )
    return @problems;
} ## end sub copyright_page

sub license_problems_in_pod_file {
    my ( $filename, $verbose ) = @_;
    if ($verbose) {
        say {*STDERR} "Checking $filename as POD file" or die "say failed: $ERRNO";
    }

    # Pod files are Perl files, and should also have the
    # license statement at the start of the file
    my $closure = gen_license_problems_in_perl_file($perl_hash_license);
    my @problems = $closure->( $filename, $verbose );

    my $text = ${ slurp($filename, (length $perl_pod_section + 100)) };
    if ( $text =~ m/ ^ [=]head1 \s+ COPYRIGHT \s+ AND \s+ LICENSE /xmsp ) {
        ## no critic (Variables::ProhibitPunctuationVars);
        my $pos = length ${^PREMATCH};
        $text = substr $text, $pos;
    }
    else {
        push @problems,
            qq{No "COPYRIGHT AND LICENSE" header in pod file $filename\n};
    }
    if ( not scalar @problems and ( index $text, $perl_pod_section ) < 0 ) {
        my $problem = "No LICENSE pod section in $filename\n";
        if ($verbose) {
            $problem .= "Missing pod section:\n"
                . Text::Diff::diff( \$text, \$perl_pod_section );
        }
        push @problems, $problem;
    } ## end if ( not scalar @problems and ( index $text, $perl_pod_section...))
    if ( scalar @problems and $verbose >= 2 ) {
        my $problem =
            "=== licensing pod section for $filename should be as follows:\n"
            . $perl_pod_section
            . ( q{=} x 30 )
            . "\n"
            ;
        push @problems, $problem;
    } ## end if ( scalar @problems and $verbose >= 2 )
    return @problems;
} ## end sub license_problems_in_pod_file

# In "Text" files, just look for the full language.
# No need to comment it out.
sub gen_license_problems_in_text_file {
    my ($license, $year) = @_;
    if ($year) {
        $license =~ s/2018/$year/xms;
    }
    return sub {
        my ( $filename, $verbose ) = @_;
        if ($verbose) {
            say {*STDERR} "Checking $filename as text file"
                or die "say failed: $ERRNO";
        }
        my @problems = ();
        my $text     = slurp_top($filename, (length $license)*2);
        if ( ( index ${$text}, $license ) < 0 ) {
            my $problem = "Full language missing in text file $filename\n";
            if ($verbose) {
                $problem .= "\nMissing license language:\n"
                    . Text::Diff::diff( $text, \$license );
            }
            push @problems, $problem;
        } ## end if ( ( index ${$text}, $license ) < 0 )
        if ( scalar @problems and $verbose >= 2 ) {
            my $problem =
                "=== licensing for $filename should be as follows:\n"
                . $license
                . ( q{=} x 30 );
            push @problems, $problem;
        } ## end if ( scalar @problems and $verbose >= 2 )
        return @problems;
    }
} ## end sub gen_license_problems_in_text_file

# In "Text" files, just look for the full language.
# No need to comment it out.
sub license_problems_in_fdl_file {
    my ( $filename, $verbose ) = @_;
    if ($verbose) {
        say {*STDERR} "Checking $filename as FDL file"
            or die "say failed: $ERRNO";
    }
    my @problems = ();
    my $text     = slurp_top($filename);
    if ( ( index ${$text}, $texi_copyright ) < 0 ) {
        my $problem = "Copyright missing in texinfo file $filename\n";
        if ($verbose) {
            $problem .= "\nMissing FDL license language:\n"
                . Text::Diff::diff( $text, \$fdl_license );
        }
        push @problems, $problem;
    }
    if ( ( index ${$text}, $fdl_license ) < 0 ) {
        my $problem = "FDL language missing in text file $filename\n";
        if ($verbose) {
            $problem .= "\nMissing FDL license language:\n"
                . Text::Diff::diff( $text, \$fdl_license );
        }
        push @problems, $problem;
    } ## end if ( ( index ${$text}, $fdl_license ) < 0 )
    if ( scalar @problems and $verbose >= 2 ) {
        my $problem =
            "=== FDL licensing section for $filename should be as follows:\n"
            . $perl_pod_section
            . ( q{=} x 30 );
        push @problems, $problem;
    } ## end if ( scalar @problems and $verbose >= 2 )
    return @problems;
} ## end sub license_problems_in_fdl_file

1;

# vim: expandtab shiftwidth=4:
