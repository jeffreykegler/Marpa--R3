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
local $main::TRACE_ES;
$main::TRACE_ES = 0;
local $main::DEBUG;
$main::DEBUG = 0;

if (0) {

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

if (0) {

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

if (0) {

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

    # C code block
    my $expected = <<'EOS';
=== Value 1 ===
@1-1 L1c1-L1c4 white space, length=4
@1-1 L1c5-L1c9 token="token"; length=5
@1-1 L1c10-L1c10 white space, length=1
@1-3 L1c11-L3c5 comment: "/* test
\begin{code}
   */"
@3-3 L3c6-L3c6 white space, length=1
@4-4 L4c1-L4c10 token="\end{code}"; length=10
@4-4 L4c11-L4c11 white space, length=1

=== Value 2 ===
@1-1 L1c1-L1c18 Tex line: "    token /* test
"
@2-2 L2c1-L2c13 \begin{code}
@3-3 L3c1-L3c6 [CODE]
@4-4 L4c1-L4c10 \end{code}

EOS

    my $sourceFile = <<'EOS';
    token /* test
\begin{code}
   */
\end{code}
EOS
    my $result = MarpaX::R3::Idlit::parse( \$sourceFile );
    # say Data::Dumper::Dumper($result);
    eq_or_diff $result, $expected, "small C code block";
}

exit 0;
