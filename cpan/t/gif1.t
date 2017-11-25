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

# Tests which require only a GIF combination-- a grammar (G),
# input (I), and an (F) ASF output, with no semantics

use 5.010001;

use strict;
use warnings;

use Data::Dumper;
use English qw( -no_match_vars );
use POSIX qw(setlocale LC_ALL);
use Test::More tests => 22;

POSIX::setlocale(LC_ALL, "C");

use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

my @tests_data = ();

my $aaaa_grammar = Marpa::R3::Grammar->new(
    {   source => \(<<'END_OF_SOURCE'),
    :start ::= quartet
    quartet ::= a a a a
    a ~ 'a'
END_OF_SOURCE
    }
);

push @tests_data, [
    $aaaa_grammar, 'aaaa',
    <<'END_OF_ASF',
GL2 Rule 0: quartet ::= a a a a
  GL3 Symbol a: "a"
  GL4 Symbol a: "a"
  GL5 Symbol a: "a"
  GL6 Symbol a: "a"
END_OF_ASF
    'ASF OK',
    'Basic "a a a a" grammar'
    ]
    if 1;

my $abcd_grammar = Marpa::R3::Grammar->new(
    {   source => \(<<'END_OF_SOURCE'),
    :start ::= quartet
    quartet ::= a b c d
    a ~ 'a'
    b ~ 'b'
    c ~ 'c'
    d ~ 'd'
END_OF_SOURCE
    }
);

# Marpa::R3::Display
# name: ASF symch dump example grammar
# start-after-line: END_OF_SOURCE
# end-before-line: '^END_OF_SOURCE$'

my $venus_grammar = Marpa::R3::Grammar->new(
    {   source => \(<<'END_OF_SOURCE'),
:start ::= planet
planet ::= hesperus
planet ::= phosphorus
hesperus ::= venus
phosphorus ::= venus
venus ~ 'venus'
END_OF_SOURCE
    }
);

# Marpa::R3::Display::End

# Marpa::R3::Display
# name: ASF symch dump example output
# start-after-line: END_OF_OUTPUT
# end-before-line: '^END_OF_OUTPUT$'

push @tests_data, [
    $venus_grammar, 'venus',
    <<'END_OF_OUTPUT',
Symbol #0 planet has 2 symches
  Symch #0.0
  GL2 Rule 0: planet ::= hesperus
    GL3 Rule 2: hesperus ::= venus
      GL4 Symbol venus: "venus"
  Symch #0.1
  GL2 Rule 1: planet ::= phosphorus
    GL5 Rule 3: phosphorus ::= venus
      GL6 Symbol venus: "venus"
END_OF_OUTPUT
    'ASF OK',
    '"Hesperus is Phosphorus"" grammar'
    ]
    if 1;

# Marpa::R3::Display::End

push @tests_data, [
    $abcd_grammar, 'abcd',
    <<'END_OF_ASF',
GL2 Rule 0: quartet ::= a b c d
  GL3 Symbol a: "a"
  GL4 Symbol b: "b"
  GL5 Symbol c: "c"
  GL6 Symbol d: "d"
END_OF_ASF
    'ASF OK',
    'Basic "a b c d" grammar'
    ]
    if 1;

# Marpa::R3::Display
# name: ASF factoring dump example grammar
# start-after-line: END_OF_SOURCE
# end-before-line: '^END_OF_SOURCE$'

my $bb_grammar = Marpa::R3::Grammar->new(
    {   source => \(<<'END_OF_SOURCE'),
:start ::= top
top ::= b b
b ::= a a
b ::= a
a ~ 'a'
END_OF_SOURCE
    }
);

# Marpa::R3::Display::End

# Marpa::R3::Display
# name: ASF factoring dump example output
# start-after-line: END_OF_OUTPUT
# end-before-line: '^END_OF_OUTPUT$'

push @tests_data, [
    $bb_grammar, 'aaa',
    <<'END_OF_OUTPUT',
GL2 Rule 0: top ::= b b
  Factoring #0
    GL3 Rule 2: b ::= a
      GL4 Symbol a: "a"
    GL5 Rule 1: b ::= a a
      GL6 Symbol a: "a"
      GL7 Symbol a: "a"
  Factoring #1
    GL8 Rule 1: b ::= a a
      GL9 Symbol a: "a"
      GL10 Symbol a: "a"
    GL11 Rule 2: b ::= a
      GL12 Symbol a: "a"
END_OF_OUTPUT
    'ASF OK',
    '"b b" grammar'
    ]
    if 1;

# Marpa::R3::Display::End

my $seq_grammar = Marpa::R3::Grammar->new(
    {   source => \(<<'END_OF_SOURCE'),
:start ::= sequence
sequence ::= item+
item ::= pair | singleton
singleton ::= 'a'
pair ::= item item
END_OF_SOURCE
    }
);

push @tests_data, [
    $seq_grammar, 'aa',
    <<'END_OF_ASF',
GL2 Rule 0: sequence ::= item +
  Factoring #0
    GL3 Rule 1: item ::= pair
      GL4 Rule 4: pair ::= item item
        GL5 Rule 2: item ::= singleton
          GL6 Rule 3: singleton ::= 'a'
            GL7 Symbol 'a': "a"
        GL8 Rule 2: item ::= singleton
          GL9 Rule 3: singleton ::= 'a'
            GL10 Symbol 'a': "a"
  Factoring #1
    GL5 already displayed
    GL8 already displayed
END_OF_ASF
    'ASF OK',
    'Sequence grammar for "aa"'
    ]
    if 1;

push @tests_data, [
    $seq_grammar, 'aaa',
    <<'END_OF_ASF',
GL2 Rule 0: sequence ::= item +
  Factoring #0
    GL3 Rule 1: item ::= pair
      GL4 Rule 4: pair ::= item item
        Factoring #0.0
          GL5 Rule 1: item ::= pair
            GL6 Rule 4: pair ::= item item
              GL7 Rule 2: item ::= singleton
                GL8 Rule 3: singleton ::= 'a'
                  GL9 Symbol 'a': "a"
              GL10 Rule 2: item ::= singleton
                GL11 Rule 3: singleton ::= 'a'
                  GL12 Symbol 'a': "a"
          GL13 Rule 2: item ::= singleton
            GL14 Rule 3: singleton ::= 'a'
              GL15 Symbol 'a': "a"
        Factoring #0.1
          GL7 already displayed
          GL16 Rule 1: item ::= pair
            GL17 Rule 4: pair ::= item item
              GL10 already displayed
              GL13 already displayed
  Factoring #1
    GL5 already displayed
    GL13 already displayed
  Factoring #2
    GL7 already displayed
    GL10 already displayed
    GL13 already displayed
  Factoring #3
    GL7 already displayed
    GL16 already displayed
END_OF_ASF
    'ASF OK',
    'Sequence grammar for "aaa"'
    ]
    if 1;

my $venus_seq_grammar = Marpa::R3::Grammar->new(
    {   source => \(<<'END_OF_SOURCE'),
:start ::= sequence
sequence ::= item+
item ::= pair | Hesperus | Phosphorus
Hesperus ::= 'a'
Phosphorus ::= 'a'
pair ::= item item
END_OF_SOURCE
    }
);

push @tests_data, [
    $venus_seq_grammar, 'aa',
    <<'END_OF_ASF',
GL2 Rule 0: sequence ::= item +
  Factoring #0
    GL3 Rule 1: item ::= pair
      GL4 Rule 6: pair ::= item item
        Symbol #0 item has 2 symches
          Symch #0.0.0
          GL5 Rule 3: item ::= Phosphorus
            GL6 Rule 5: Phosphorus ::= 'a'
              GL7 Symbol 'a': "a"
          Symch #0.0.1
          GL5 Rule 2: item ::= Hesperus
            GL8 Rule 4: Hesperus ::= 'a'
              GL9 Symbol 'a': "a"
        Symbol #1 item has 2 symches
          Symch #0.1.0
          GL10 Rule 2: item ::= Hesperus
            GL11 Rule 4: Hesperus ::= 'a'
              GL12 Symbol 'a': "a"
          Symch #0.1.1
          GL10 Rule 3: item ::= Phosphorus
            GL13 Rule 5: Phosphorus ::= 'a'
              GL14 Symbol 'a': "a"
  Factoring #1
    GL5 already displayed
    GL10 already displayed
END_OF_ASF
    'ASF OK',
    'Sequence grammar for "aa"'
    ]
    if 1;

my $nulls_grammar = Marpa::R3::Grammar->new(
    {   source => \(<<'END_OF_SOURCE'),
:start ::= top
top ::= a a a a
a ::= 'a'
a ::=
END_OF_SOURCE
    }
);

push @tests_data, [
    $nulls_grammar, 'aaaa',
    <<'END_OF_ASF',
GL2 Rule 0: top ::= a a a a
  GL3 Rule 1: a ::= 'a'
    GL4 Symbol 'a': "a"
  GL5 Rule 1: a ::= 'a'
    GL6 Symbol 'a': "a"
  GL7 Rule 1: a ::= 'a'
    GL8 Symbol 'a': "a"
  GL9 Rule 1: a ::= 'a'
    GL10 Symbol 'a': "a"
END_OF_ASF
    'ASF OK',
    'Nulls grammar for "aaaa"'
    ]
    if 1;

push @tests_data, [
    $nulls_grammar, 'aaa',
    <<'END_OF_ASF',
GL2 Rule 0: top ::= a a a a
  Factoring #0
    GL3 Symbol a: ""
    GL4 Rule 1: a ::= 'a'
      GL5 Symbol 'a': "a"
    GL6 Rule 1: a ::= 'a'
      GL7 Symbol 'a': "a"
    GL8 Rule 1: a ::= 'a'
      GL9 Symbol 'a': "a"
  Factoring #1
    GL4 already displayed
    GL10 Symbol a: ""
    GL6 already displayed
    GL8 already displayed
  Factoring #2
    GL4 already displayed
    GL6 already displayed
    GL8 already displayed
    GL11 Symbol a: ""
  Factoring #3
    GL4 already displayed
    GL6 already displayed
    GL12 Symbol a: ""
    GL8 already displayed
END_OF_ASF
    'ASF OK',
    'Nulls grammar for "aaa"'
    ]
    if 1;

push @tests_data, [
    $nulls_grammar, 'aa',
    <<'END_OF_ASF',
GL2 Rule 0: top ::= a a a a
  Factoring #0
    GL3 Symbol a: ""
    GL4 Symbol a: ""
    GL5 Rule 1: a ::= 'a'
      GL6 Symbol 'a': "a"
    GL7 Rule 1: a ::= 'a'
      GL8 Symbol 'a': "a"
  Factoring #1
    GL3 already displayed
    GL5 already displayed
    GL7 already displayed
    GL9 Symbol a: ""
  Factoring #2
    GL3 already displayed
    GL5 already displayed
    GL10 Symbol a: ""
    GL7 already displayed
  Factoring #3
    GL5 already displayed
    GL11 Symbol a: ""
    GL7 already displayed
    GL9 already displayed
  Factoring #4
    GL5 already displayed
    GL11 already displayed
    GL10 already displayed
    GL7 already displayed
  Factoring #5
    GL5 already displayed
    GL7 already displayed
    GL12 Symbol a: ""
    GL13 Symbol a: ""
END_OF_ASF
    'ASF OK',
    'Nulls grammar for "aa"'
    ]
    if 1;

push @tests_data, [
    $nulls_grammar, 'a',
    <<'END_OF_ASF',
GL2 Rule 0: top ::= a a a a
  Factoring #0
    GL3 Rule 1: a ::= 'a'
      GL4 Symbol 'a': "a"
    GL5 Symbol a: ""
    GL6 Symbol a: ""
    GL7 Symbol a: ""
  Factoring #1
    GL8 Symbol a: ""
    GL3 already displayed
    GL9 Symbol a: ""
    GL10 Symbol a: ""
  Factoring #2
    GL8 already displayed
    GL11 Symbol a: ""
    GL3 already displayed
    GL12 Symbol a: ""
  Factoring #3
    GL8 already displayed
    GL11 already displayed
    GL13 Symbol a: ""
    GL3 already displayed
END_OF_ASF
    'ASF OK',
    'Nulls grammar for "a"'
    ]
    if 1;

TEST:
for my $test_data (@tests_data) {
    my ( $grammar, $test_string, $expected_value, $expected_result,
        $test_name )
        = @{$test_data};

    my ( $actual_value, $actual_result ) =
        my_parser( $grammar, $test_string );

    Marpa::R3::Test::is(
        Data::Dumper::Dumper( \$actual_value ),
        Data::Dumper::Dumper( \$expected_value ),
        qq{Value of $test_name}
    );

    Test::More::is( $actual_result, $expected_result,
        qq{Result of $test_name} );
} ## end TEST: for my $test_data (@tests_data)

sub my_parser {
    my ( $grammar, $string ) = @_;

    my $recce = Marpa::R3::Recognizer->new( { grammar => $grammar } );

    if ( not defined eval { $recce->read( \$string ); 1 } ) {
        my $abbreviated_error = $EVAL_ERROR;
        chomp $abbreviated_error;
        return 'No parse', $abbreviated_error;
    } ## end if ( not defined eval { $recce->read( \$string ); 1 } )
    my $asf = Marpa::R3::ASF2->new( { recognizer => $recce } );
    if ( not defined $asf ) {
        return 'No ASF', 'Input read to end but no ASF';
    }

    my $asf_desc = $asf->dump();
    return $asf_desc, 'ASF OK';

} ## end sub my_parser

# vim: expandtab shiftwidth=4:
