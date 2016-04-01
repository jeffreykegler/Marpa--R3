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

use 5.010;
use strict;
use warnings;
use English qw( -no_match_vars );
use List::Util;
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

use Marpa::R3::HTML;
use lib 'tool/lib';
use Marpa::R3::Test;

# Non-synopsis example in HTML.pod

# Marpa::R3::Display
# name: 'HTML Pod: Handler Precedence'

my $html = <<'END_OF_HTML';
<span class="high">High Span</span>
<span class="low">Low Span</span>
<div class="high">High Div</div>
<div class="low">Low Div</div>
<div class="oddball">Oddball Div</div>
END_OF_HTML

our @RESULTS = ();
Marpa::R3::HTML::html(
    \$html,
    {   q{*} => sub {
            push @RESULTS, 'wildcard handler: ' . Marpa::R3::HTML::contents();
        },
        'div' => sub {
            push @RESULTS, '"div" handler: ' . Marpa::R3::HTML::contents();
        },
        '.high' => sub {
            push @RESULTS, '".high" handler: ' . Marpa::R3::HTML::contents();
        },
        'div.high' => sub {
            push @RESULTS,
                '"div.high" handler: ' . Marpa::R3::HTML::contents();
        },
        '.oddball' => sub {
            push @RESULTS,
                '".oddball" handler: ' . Marpa::R3::HTML::contents();
        },
        'body' => sub {undef},
        'head' => sub {undef},
        'html' => sub {undef},
        'p'    => sub {undef},
    }
);

# Marpa::R3::Display::End

# Marpa::R3::Display
# name: 'HTML Pod: Handler Precedence Result'
# start-after-line: EXPECTED_RESULT
# end-before-line: '^EXPECTED_RESULT$'

my $expected_result = <<'EXPECTED_RESULT';
".high" handler: High Span
wildcard handler: Low Span
"div.high" handler: High Div
"div" handler: Low Div
".oddball" handler: Oddball Div
EXPECTED_RESULT

# Marpa::R3::Display::End

my $result = join "\n", @RESULTS;
Marpa::R3::Test::is( "$result\n", $expected_result,
    'handler precedence example' );

# Marpa::R3::Display
# name: 'HTML Pod: Structure vs. Element Example'
# start-after-line: END_OF_EXAMPLE
# end-before-line: '^END_OF_EXAMPLE$'

my $tagged_html_example = <<'END_OF_EXAMPLE';
    <title>Short</title><p>Text</head><head>
END_OF_EXAMPLE

# Marpa::R3::Display::End

my $expected_structured_result = <<'END_OF_EXPECTED';
    <html>
<head>
<title>Short</title></head>
<body>
<p>Text</p>
</head><head>
</body>
</html>
END_OF_EXPECTED

sub supply_missing_tags {
    my $tagname = Marpa::R3::HTML::tagname();
    return
          ( Marpa::R3::HTML::start_tag() // "<$tagname>\n" )
        . Marpa::R3::HTML::contents()
        . ( Marpa::R3::HTML::end_tag() // "</$tagname>\n" );
} ## end sub supply_missing_tags
my $structured_html_ref =
    Marpa::R3::HTML::html( \$tagged_html_example,
    { q{*} => \&supply_missing_tags } );

Marpa::R3::Test::is( ${$structured_html_ref}, $expected_structured_result,
    'structure vs. tags example' );

