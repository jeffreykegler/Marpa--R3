#!perl
# Marpa::R3 is Copyright (C) 2017, Jeffrey Kegler.
#
# This module is free software; you can redistribute it and/or modify it
# under the same terms as Perl 5.10.1. For more details, see the full text
# of the licenses in the directory LICENSES.
#
# This program is distributed in the hope that it will be
# useful, but it is provided "as is" and without any express
# or implied warranties. For details, see the full text of
# of the licenses in the directory LICENSES.

use 5.010001;

use strict;
use warnings;

use utf8;
use Test::More tests => 1;
use English qw( -no_match_vars );
use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;
use Data::Dumper;
use Getopt::Long ();

our $VERBOSE = 0;
die if not Getopt::Long::GetOptions( verbose => \$VERBOSE );

my $dsl = <<'=== END OF DSL ===';
:start ::= test
test ::= [\w] | [\W]
=== END OF DSL ===

my $NEL = pack('U', 0x85); # Unicode NEXT LINE
my $input = "1\x{0A}2\x{0D}3\x{0D}\x{0A}4${NEL}5\x{0A}\x{0D}\x{0A}7"
  . ( "\x{0A}\x{0D}" x 4 ) #  5 lines -- 3 medial CRLF, plus 2 at ends
  . ( "\x{0D}" x 3 )  # 3 lines
  . "\x{85}" # 1 line
  . ( "\x{0A}" x 3 ) # 3 lines
  . ( "\x{0A}\x{0D}" x 4 ) #  5 lines -- 3 medial CRLF, plus 2 at ends
  . '24';
my $g = Marpa::R3::Grammar->new({source => \$dsl});
my $r = Marpa::R3::Scanless::R->new({grammar => $g});

# We do not need to actually read the input
$r->read(\$input, 0, 0);
my ($block_id) = $r->block_progress();

my @actual = ();
for my $i (0 .. length $input) {
   my ($line, $column) = $r->line_column($block_id, $i);
   if ($VERBOSE) {
   my $text = substr $input, $i, 20;
    $text =~ s/\n/\\n/g;
    $text =~ s/\r/\\r/g;
    say join " ", $line, $column, $text;
   }
   push @actual, join q{ }, $line, $column;
}
my $actual = join "\n", @actual, q{};

my $line_data = <<'END_OF_LINE_DATA';
1 1 1\n2\r3\r\n4�5\n\r\n7\n\r\n\r\n\r
1 2 \n2\r3\r\n4�5\n\r\n7\n\r\n\r\n\r\n
2 1 2\r3\r\n4�5\n\r\n7\n\r\n\r\n\r\n\r
2 2 \r3\r\n4�5\n\r\n7\n\r\n\r\n\r\n\r\r
3 1 3\r\n4�5\n\r\n7\n\r\n\r\n\r\n\r\r\r
3 2 \r\n4�5\n\r\n7\n\r\n\r\n\r\n\r\r\r\r
3 3 \n4�5\n\r\n7\n\r\n\r\n\r\n\r\r\r\r�
4 1 4�5\n\r\n7\n\r\n\r\n\r\n\r\r\r\r�\n
4 2 �5\n\r\n7\n\r\n\r\n\r\n\r\r\r\r�\n\n
5 1 5\n\r\n7\n\r\n\r\n\r\n\r\r\r\r�\n\n\n
5 2 \n\r\n7\n\r\n\r\n\r\n\r\r\r\r�\n\n\n\n
6 1 \r\n7\n\r\n\r\n\r\n\r\r\r\r�\n\n\n\n\r
6 2 \n7\n\r\n\r\n\r\n\r\r\r\r�\n\n\n\n\r\n
7 1 7\n\r\n\r\n\r\n\r\r\r\r�\n\n\n\n\r\n\r
7 2 \n\r\n\r\n\r\n\r\r\r\r�\n\n\n\n\r\n\r\n
8 1 \r\n\r\n\r\n\r\r\r\r�\n\n\n\n\r\n\r\n\r
8 2 \n\r\n\r\n\r\r\r\r�\n\n\n\n\r\n\r\n\r\n
9 1 \r\n\r\n\r\r\r\r�\n\n\n\n\r\n\r\n\r\n\r
9 2 \n\r\n\r\r\r\r�\n\n\n\n\r\n\r\n\r\n\r2
10 1 \r\n\r\r\r\r�\n\n\n\n\r\n\r\n\r\n\r24
10 2 \n\r\r\r\r�\n\n\n\n\r\n\r\n\r\n\r24
11 1 \r\r\r\r�\n\n\n\n\r\n\r\n\r\n\r24
12 1 \r\r\r�\n\n\n\n\r\n\r\n\r\n\r24
13 1 \r\r�\n\n\n\n\r\n\r\n\r\n\r24
14 1 \r�\n\n\n\n\r\n\r\n\r\n\r24
15 1 �\n\n\n\n\r\n\r\n\r\n\r24
16 1 \n\n\n\n\r\n\r\n\r\n\r24
17 1 \n\n\n\r\n\r\n\r\n\r24
18 1 \n\n\r\n\r\n\r\n\r24
19 1 \n\r\n\r\n\r\n\r24
20 1 \r\n\r\n\r\n\r24
20 2 \n\r\n\r\n\r24
21 1 \r\n\r\n\r24
21 2 \n\r\n\r24
22 1 \r\n\r24
22 2 \n\r24
23 1 \r24
24 1 24
24 2 4
24 3 
END_OF_LINE_DATA

my @expected = ();
for my $line (split $RS, $line_data)
{
   chomp $line;
  $line =~ s/\A(\d+ \s+ \d+) \s .*\z/$1/xms;
  push @expected, $line;
}
my $expected = join "\n", @expected, q{};
Marpa::R3::Test::is($actual, $expected, "Line and column test");

# vim: expandtab shiftwidth=4:
