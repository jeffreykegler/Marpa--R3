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

my $expected = <<'EOS';
=== Value 1 ===
@1-1 L1c1-L1c4 white space, length=4
@1-1 L1c5-L1c7 token="int"; length=3
@1-1 L1c8-L1c8 white space, length=1
@1-1 L1c9-L1c10 token="fn"; length=2
@1-1 L1c11-L1c11 white space, length=1
@1-1 L1c12-L1c13 token="()"; length=2
@1-1 L1c14-L1c14 white space, length=1
@1-1 L1c15-L1c15 token="{"; length=1
@1-1 L1c16-L1c16 white space, length=1
@1-3 L1c17-L3c5 comment: "/* for later
\begin{code}
   */"
@3-3 L3c6-L3c6 white space, length=1
@3-3 L3c7-L3c9 token="int"; length=3
@3-3 L3c10-L3c10 white space, length=1
@3-3 L3c11-L3c16 token="fn2();"; length=6
@3-3 L3c17-L3c17 white space, length=1
@3-3 L3c18-L3c20 token="int"; length=3
@3-3 L3c21-L3c21 white space, length=1
@3-3 L3c22-L3c22 token="a"; length=1
@3-3 L3c23-L3c23 white space, length=1
@3-3 L3c24-L3c24 token="="; length=1
@3-3 L3c25-L3c25 white space, length=1
@3-3 L3c26-L3c31 token="fn2();"; length=6
@3-4 L3c32-L4c3 white space, length=4
@4-4 L4c4-L4c6 token="int"; length=3
@4-4 L4c7-L4c7 white space, length=1
@4-4 L4c8-L4c8 token="b"; length=1
@4-4 L4c9-L4c9 white space, length=1
@4-4 L4c10-L4c10 token="="; length=1
@4-4 L4c11-L4c11 white space, length=1
@4-4 L4c12-L4c14 token="42;"; length=3
@4-5 L4c15-L5c3 white space, length=4
@5-5 L5c4-L5c9 token="return"; length=6
@5-5 L5c10-L5c11 white space, length=2
@5-5 L5c12-L5c12 token="a"; length=1
@5-5 L5c13-L5c13 white space, length=1
@5-5 L5c14-L5c14 token="+"; length=1
@5-5 L5c15-L5c15 white space, length=1
@5-5 L5c16-L5c17 token="b;"; length=2
@5-5 L5c18-L5c18 white space, length=1
@5-7 L5c19-L7c2 comment: "/* for later
\end{code}
*/"
@7-7 L7c3-L7c3 white space, length=1
@7-7 L7c4-L7c4 token="}"; length=1
@7-7 L7c5-L7c5 white space, length=1

=== Value 2 ===
@1-1 L1c1-L1c29 Tex line: "    int fn () { /* for later
"
@2-2 L2c1-L2c13 \begin{code}
@3-5 L3c1-L5c31 [CODE]
@6-6 L6c1-L6c10 \end{code}
@7-7 L7c1-L7c5 Tex line: "*/ }
"

EOS

# C code block
my $sourceFile = <<'EOS';
    int fn () { /* for later
\begin{code}
   */ int fn2(); int a = fn2();
   int b = 42;
   return  a + b; /* for later
\end{code}
*/ }
EOS
my $result = MarpaX::R3::Idlit::parse( \$sourceFile );

# say Data::Dumper::Dumper($result);
eq_or_diff $result, $expected, "C with Tex commentend out";

