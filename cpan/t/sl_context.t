#!/usr/bin/perl
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

# CENSUS: ASIS
# Note: Converted from sl_context.t

# Test of bail() and context variables in SLIF semantics

use 5.010001;
use strict;
use warnings;

use Test::More tests => 6;

use English qw( -no_match_vars );
use Fatal qw( open close );
use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

my $trace_rules = q{};

sub no_bail {
    my ($action_object) = @_;
    my $rule_id = $Marpa::R3::Context::rule;
    my $slg = $Marpa::R3::Context::slg;
    my ( $lhs, @rhs ) = $slg->rule($rule_id);
    $action_object->{text} =
          "rule $rule_id: $lhs ::= "
        . ( join q{ }, @rhs ) . "\n"
        . "locations: "
        . ( join q{-}, Marpa::R3::Context::g1_range() ) . "\n";
    return $action_object;
} ## end sub do_S

my $bail_message = "This is a bail out message!";

sub do_bail_with_message_if_A {
    my ($action_object, $terminal) = @_;
    Marpa::R3::Context::bail($bail_message) if $terminal eq 'a';
}

sub do_bail_with_object_if_A {
    my ($action_object, $terminal) = @_;
    Marpa::R3::Context::bail([$bail_message]) if $terminal eq 'a';
}

my $dsl = <<'END_OF_DSL';
S ::= A B C D action => DOIT
A ~ [\d\D]
B ~ [\d\D]
C ~ [\d\D]
D ~ [\d\D]
END_OF_DSL

my @terminals = qw/A B C D/;

sub do_parse {
    my ($action) = @_;
    my $this_dsl = $dsl;
    $this_dsl =~ s/DOIT/$action/xms;
    my $grammar   = Marpa::R3::Scanless::G->new(
        {   source => \$this_dsl }
    );
    my $recce = Marpa::R3::Scanless::R->new( { grammar => $grammar } );
    $recce->read( \'abcd' );
    return $recce->value();
} ## end sub do_parse

my $value_ref;
$value_ref = do_parse('main::no_bail');
VALUE_TEST: {
    if ( ref $value_ref ne 'REF' ) {
        my $ref_type = ref $value_ref;
        Test::More::fail(
            qq{Parse result ref type is "$ref_type"; it needs to be "REF"});
        last VALUE_TEST;
    } ## end if ( ref $value_ref ne 'REF' )
    my $value = ${$value_ref};
    if ( ref $value ne 'HASH' ) {
        my $ref_type = ref $value;
        Test::More::fail(
            qq{Parse value ref type is "$ref_type"; it needs to be "HASH"});
        last VALUE_TEST;
    } ## end if ( ref $value ne 'HASH' )
    my $expected_text = qq{rule 0: S ::= A B C D\nlocations: 0-4\n};
    Test::More::is( $value->{text}, $expected_text, 'Parse ok?' );
} ## end VALUE_TEST:

my $eval_ok;
{
    $eval_ok = eval {
        $value_ref = do_parse( 'main::do_bail_with_message_if_A' );
        1;
    };
}
my $actual_eval_error = $EVAL_ERROR
    // 'no eval error';    # grab it now to be safe
Test::More::ok( ( not defined $eval_ok ),
    "bail with string argument happened" );
$actual_eval_error
    =~ s/\A User \s+ bailed \s+ at \s+ line \s+ \d+ [^\n]* \n/<LOCATION LINE>/xms;
Test::More::is(
    $actual_eval_error,
    '<LOCATION LINE>' . $bail_message . "\n",
    "bail with string argument"
);

{
    $eval_ok = eval {
        $value_ref = do_parse( 'main::do_bail_with_object_if_A' );
        1;
    };
}
$actual_eval_error = $EVAL_ERROR;
my $eval_error_ref_type = ref $actual_eval_error;
my $exception_value_desc =
      $eval_error_ref_type eq 'ARRAY'
    ? $actual_eval_error->[0]
    : "ref type of exception is $eval_error_ref_type";
Test::More::ok( ( not defined $eval_ok ),
    "bail with object argument happened" );
Test::More::is( $eval_error_ref_type, 'ARRAY',
    "bail with object argument ref type" );
Test::More::is( $exception_value_desc, $bail_message,
    "bail with object argument value" );

# vim: expandtab shiftwidth=4:
