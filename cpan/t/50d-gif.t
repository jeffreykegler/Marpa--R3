#!perl
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

# Tests which require only a GIF combination-- a grammar (G),
# input (I), and an (F) ASF output, with no semantics

use 5.010001;

use strict;
use warnings;

use Data::Dumper;
use English qw( -no_match_vars );
use POSIX qw(setlocale LC_ALL);
use Test::More tests => 4;

POSIX::setlocale(LC_ALL, "C");

use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

my @tests_data = ();

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
