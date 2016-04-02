#!perl
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

use English qw( -no_match_vars );
use Fatal qw(open close);
use File::Spec;
use Test::More;

BEGIN {
    use lib 'html/tool/lib';
    my $eval_result = eval { require Marpa::R3::HTML::Test::Util; 1 };
    if ( !$eval_result ) {
        Test::More::plan tests => 1;
        Test::More::fail(
            "Could not load Marpa::R3::HTML::Test::Util; $EVAL_ERROR");
        exit 0;
    } ## end if ( !$eval_result )
} ## end BEGIN

BEGIN { Marpa::R3::HTML::Test::Util::load_or_skip_all('HTML::Parser'); }

BEGIN { Test::More::plan tests => 2; }

use lib 'tool/lib';
use Marpa::R3::Test;

my $blib = $ENV{MARPA_TEST_BLIB} // 'blib';
my $script_dir = File::Spec->catdir( $blib, 'script' );

my @data_dir   = qw( html t fmt_t_data );

for my $test (qw(1 2)) {
    my $expected;
    my $output = Marpa::R3::HTML::Test::Util::run_command(
        File::Spec->catfile( $script_dir, 'marpa_r2_html_fmt' ),
        File::Spec->catfile( @data_dir, ( 'input' . $test . '.html' ) )
    );
    local $RS = undef;
    open my $fh, q{<},
        File::Spec->catfile( @data_dir, ( 'expected' . $test . '.html' ) );
    $expected = <$fh>;
    close $fh;
    Marpa::R3::Test::is( $output, $expected, 'marpa_r2_html_fmt test' );
} ## end for my $test (qw(1 2))

