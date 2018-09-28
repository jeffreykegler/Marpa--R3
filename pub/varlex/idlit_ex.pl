#!/usr/bin/perl)

# An example of an LR-regular choice in
# list comprehension: Boolean guards versus
# generators.

# This example is for a specific blog post,
# and is not to be included in the test
# suite.

use 5.010;
use strict;
use warnings;

use Data::Dumper;
$Data::Dumper::Terse    = 1;
$Data::Dumper::Deepcopy = 1;
use English qw( -no_match_vars );

use Test::More tests => 1;
use Test::Differences;

use Marpa::R3 4.001_053;

require "idlit.pm";

# This trace level above that allowed in test suite
local $main::TRACE_ES = 0;
local $main::DEBUG = 0;

if (1) {

    say STDERR "Tex code block";
    my $sourceFile = <<'EOS';
some Tex ..
\begin{code}
some code ..
\end{code}
some Tex ..
EOS
    my $result = MarpaX::R3::Idlit::parse( \$sourceFile );
    # say Data::Dumper::Dumper($result);
    # eq_or_diff $result, "";
    say $result;
}

if (1) {

    say STDERR "Misformed Tex code block";
    # Misformed Tex code block
    my $sourceFile = <<'EOS';
some Tex ..
\begin{code}
some code ..
more ...
and more ...
EOS
    my $result = MarpaX::R3::Idlit::parse( \$sourceFile );
    # say Data::Dumper::Dumper($result);
    # eq_or_diff $result, "";
    say $result;
}

if (1) {

    say STDERR "C code block";
    # C code block
    my $sourceFile = <<'EOS';
some Tex ..
/*
\begin{code}
*/
some code ..
code ... /*
\end{code}
*/
some Tex ..
EOS
    my $result = MarpaX::R3::Idlit::parse( \$sourceFile );
    # say Data::Dumper::Dumper($result);
    # eq_or_diff $result, "";
    say $result;
}

if (1) {

    say STDERR "small C code block";
    # C code block
    my $sourceFile = <<'EOS';
    token
/* test
\begin{code}
   */
\end{code}
EOS
    my $result = MarpaX::R3::Idlit::parse( \$sourceFile );
    # say Data::Dumper::Dumper($result);
    # eq_or_diff $result, "";
    say $result;
}

