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

# Tests of ambiguity detection in the target grammar
# (as opposed to the SLIF DSL itself).

# MITOSIS: TODO

use 5.010001;
use strict;
use warnings;

use Test::More tests => 11;
use English qw( -no_match_vars );
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;
use Data::Dumper;

our $DEBUG = 0;

my $source = \(<<'END_OF_SOURCE');
:default ::= action => ::array
pair ::= duple | item item
duple ::= item item
item ::= Hesperus | Phosphorus
Hesperus ::= 'a'
Phosphorus ::= 'a'
END_OF_SOURCE

my $input           = 'aa';
my $expected_value   = 'Application grammar is ambiguous';
my $expected_result = <<'END_OF_MESSAGE';
Ambiguous symch at Glade=2, Symbol=<pair>:
  The ambiguity is at B1L1c1-2
  Text is: aa
  There are 2 symches
  Symch 0 is a rule: pair ::= duple
  Symch 1 is a rule: pair ::= item item
END_OF_MESSAGE
my $test_name = 'Symch ambiguity';

my $grammar = Marpa::R3::Scanless::G->new( { source  => $source } );
my $recce   = Marpa::R3::Scanless::R->new( { grammar => $grammar } );
my $is_ambiguous_parse = 1;

my ( $actual_value, $actual_result );
PROCESSING: {

    if ( not defined eval { $recce->read( \$input ); 1 } ) {
        say $EVAL_ERROR if $DEBUG;
        my $abbreviated_error = $EVAL_ERROR;
        chomp $abbreviated_error;
        $abbreviated_error =~ s/\n.*//xms;
        $actual_value  = 'No parse';
        $actual_result = $abbreviated_error;
        $is_ambiguous_parse = 0;
        last PROCESSING;
    } ## end if ( not defined eval { $recce->read( \$input ); 1 })

# Marpa::R3::Display
# name: ASF ambiguity reporting

    if ( $recce->ambiguity_metric() > 1 ) {
        my $asf = Marpa::R3::ASF->new( { slr => $recce } );
        die 'No ASF' if not defined $asf;
        my $ambiguities = Marpa::R3::Internal::ASF::ambiguities($asf);

        # Only report the first two
        my @ambiguities = grep {defined} @{$ambiguities}[ 0 .. 1 ];

        $actual_value = 'Application grammar is ambiguous';
        $actual_result =
            Marpa::R3::Internal::ASF::ambiguities_show( $asf, \@ambiguities );
        last PROCESSING;
    } ## end if ( $recce->ambiguity_metric() > 1 )

# Marpa::R3::Display::End

    $is_ambiguous_parse = 0;

    my $value_ref = $recce->value();
    if ( not defined $value_ref ) {
        $actual_value  = 'No parse';
        $actual_result = 'Input read to end but no parse';
        last PROCESSING;
    }
    $actual_value  = ${$value_ref};
    $actual_result = 'Parse OK';
    last PROCESSING;

} ## end PROCESSING:

Test::More::is(
    Data::Dumper::Dumper( \$actual_value ),
    Data::Dumper::Dumper( \$expected_value ),
    qq{Value of $test_name}
);
Test::More::is( $actual_result, $expected_result, qq{Result of $test_name} );

if ( !$is_ambiguous_parse ) {
    Test::More::fail(qq{glade_g1_span() start});
    Test::More::fail(qq{glade_g1_span() length});
}
else {
    $recce->series_restart();
    my $asf = Marpa::R3::ASF->new( { slr => $recce } );
    my $glade_id = $asf->peak;

# Marpa::R3::Display
# name: glade_g1_span() example

    my ( $glade_start, $glade_length ) = $asf->glade_g1_span($glade_id);

# Marpa::R3::Display::End

    Test::More::is( $glade_start,  0, qq{glade_g1_span() start} );
    Test::More::is( $glade_length, 2, qq{glade_g1_span() length} );

} ## end else [ if ( !$is_ambiguous_parse ) ]

# Tests of ambiguity_metric() anb ambiguous() across all ranking methods
$source = \(<<'END_OF_SOURCE');

top ::= unchoice rank => 1
top ::= choice
unchoice ::= choice1
choice ::= choice1 | choice2
choice1 ::= A1 B1
choice2 ::= A2 B2
A1 ~ 'a'
A2 ~ 'a'
B1 ~ 'b'
B2 ~ 'b'

:discard ~ ws
ws ~ [\s]+
END_OF_SOURCE

$input = q{a b};

for my $ranking_method ('none', 'rule', 'high_rule_only'){

    my $ranking_grammar = Marpa::R3::Scanless::G->new(
        { ranking_method => $ranking_method, source => $source } );

    $recce = Marpa::R3::Scanless::R->new( { grammar => $ranking_grammar } );

    $recce->read(\$input);

    if ($ranking_method eq 'high_rule_only'){
        # count parses and test that there is only one
        my $parse_count = 0;
        while (defined $recce->value()) { ++$parse_count }
        Test::More::is( $parse_count, 1, "$ranking_method ranking, single parse" );
        # reset recognizer and test ambiguity methods
        $recce->series_restart();
        Test::More::is( $recce->ambiguous(), '', "$ranking_method ranking, single parse, ambiguous status is empty" );
        Test::More::is( $recce->ambiguity_metric(), 1, "$ranking_method ranking, single parse, ambiguity metric is 1" );
    }
    else{
        Test::More::isnt( $recce->ambiguous(), '', "$ranking_method ranking, many parses, ambiguous status isn't empty" );
        Test::More::ok( $recce->ambiguity_metric() > 1, "$ranking_method ranking, many parses, ambiguity metric > 1" );
    }
} ## end for my $ranking_method ...

# vim: expandtab shiftwidth=4:
