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
local $main::TRACE_ES = 2;
local $main::DEBUG = 0;

if (1) {

    my $sourceFile = <<'EOS';
some Tex ..
\begin{code}
some code ..
\end{code}
some Tex ..
EOS
    my ($valueRef) = MarpaX::R3::Idlit::parse( \$sourceFile );

    # say Data::Dumper::Dumper($result);
    # say Data::Dumper::Dumper($valueRef);
    say showBricks($valueRef);
    Test::More::is_deeply( $valueRef, [] );
}

sub extractLines {
   my ($tree) = @_;
   my $refType = ref $tree;
   # say STDERR $refType;
   return extractLines(${$tree}) if $refType eq 'REF';
   # say STDERR __LINE__;
   return [] if $refType ne 'ARRAY';
   # say STDERR __LINE__;
   my @lines = ();
   if (substr($tree->[0], 0, 5) eq 'BRICK') {
       # say STDERR 'BRICK!';
       return [$tree];
   }
   # say STDERR __LINE__;
   # say STDERR '$#$tree: ';
   # say STDERR join '', '$#$tree: ', $#$tree;
   push @lines, @{ extractLines($tree->[$_]) } for 0 .. $#$tree;
   return \@lines;
}

sub showBricks {
   my ($tree) = @_;
   my $lines = extractLines($tree);
   my @bricks = sort { $a->[1] <=> $b->[1] } @$lines;
   return Data::Dumper::Dumper(\@bricks);
}
