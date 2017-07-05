#!/usr/bin/perl
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

# Converted from Marpa::R2 sl_context.t

# Test of bail() and context variables in SLIF semantics

# MITOSIS: FINISHED

use 5.010001;
use strict;
use warnings;

use Test::More tests => 6;

use English qw( -no_match_vars );
use Fatal qw( open close );
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

my $trace_rules = q{};

sub no_bail {
    my ($action_object) = @_;
    my $altid           = $Marpa::R3::Context::altid;
    my $slg             = $Marpa::R3::Context::slg;
    my ( $lhs, @rhs ) =
      map { $slg->symbol_name($_) } $slg->rule_expand($altid);
    $action_object->{text} =
        "rule $altid: $lhs ::= "
      . ( join q{ }, @rhs ) . "\n"
      . "locations: "
      . ( join q{-}, Marpa::R3::Context::g1_range() ) . "\n";
    return $action_object;
}

my $bail_message = "This is a bail out message!";

sub do_bail_with_message_if_A {
    my ($action_object, $v) = @_;
    my ($terminal) = @{$v};
    Marpa::R3::Context::bail($bail_message) if $terminal eq 'a';
}

sub do_bail_with_object_if_A {
    my ($action_object, $v) = @_;
    my ($terminal) = @{$v};
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
    my $expected_text = qq{rule 2: S ::= A B C D\nlocations: 0-4\n};
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
