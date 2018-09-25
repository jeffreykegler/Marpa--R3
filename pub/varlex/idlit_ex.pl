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

my $sourceFile = <<'EOS';
some Tex ..
\begin{code}
some code ..
\end{code}
some Tex ..
EOS

# This trace level above that allowed in test suite
local $main::TRACE_ES = 2;

local $main::DEBUG = 0;
my $inputRef = \$sourceFile;

my ($result, $valueRef) = MarpaX::R2::Haskell::parse($inputRef);
if ( $result ne 'OK' ) {
    Test::More::fail(qq{Result was "$result", not OK});
    return;
}
Test::More::pass(qq{Result is OK});
