#!/usr/bin/perl
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

# semantics examples

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

# Marpa::R3::Display
# name: action context synopsis

sub do_S {
    my ($per_parse_object) = @_;
    my $production_id = $Marpa::R3::Context::production_id;
    my $slg             = $Marpa::R3::Context::grammar;
    my ( $lhs, @rhs ) =
        map { $slg->symbol_display_form($_) } $slg->production_expand($production_id);
    $per_parse_object->{text} =
          "production $production_id: $lhs ::= "
        . ( join q{ }, @rhs ) . "\n"
        . "locations: "
        . ( join q{-}, Marpa::R3::Context::g1_range() ) . "\n";
    return $per_parse_object;
} ## end sub do_S

# Marpa::R3::Display::End

# Marpa::R3::Display
# name: bail synopsis

my $bail_message = "This is a bail out message!";

sub do_bail_with_message_if_A {
    my ($action_object, $values) = @_;
    my ($terminal) = @{$values};
    Marpa::R3::Context::bail($bail_message) if $terminal eq 'A';
}

sub do_bail_with_object_if_A {
    my ($action_object, $values) = @_;
    my ($terminal) = @{$values};
    Marpa::R3::Context::bail([$bail_message]) if $terminal eq 'A';
}

# Marpa::R3::Display::End

my @terminals = qw/A B C D/;
my $dsl = <<'END_OF_SOURCE';
:start ::= S
S ::= A B C D action => main::do_S
A ~ 'A'
B ~ 'B'
C ~ 'C'
D ~ 'D'
END_OF_SOURCE

sub do_parse {
    my $grammar = Marpa::R3::Grammar->new( { source  => \$dsl } );
    my $slr     = Marpa::R3::Recognizer->new( { grammar => $grammar } );
    $slr->read( \'ABCD' );
    return $slr->value();
}

my $value_ref;
$value_ref = do_parse();
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
    my $expected_text = qq{production 2: S ::= A B C D\nlocations: 0-3\n};
    Test::More::is( $value->{text}, $expected_text, 'Parse ok?' );
} ## end VALUE_TEST:

my $eval_ok;
{
    local *do_S = *do_bail_with_message_if_A;
    $eval_ok = eval { $value_ref = do_parse(); 1 };
}
my $actual_eval_error = $EVAL_ERROR
    // 'no eval error';    # grab it now to be safe
Test::More::ok( ( not defined $eval_ok ),
    "bail with string argument happened" );
$actual_eval_error
    =~ s/\A User \s+ bailed \s+ at \s+ line \s+ \d+ [^\n]*/<LOCATION LINE>/xms;
$actual_eval_error
    =~ s/^ Marpa::R3 \s+ exception \s+ at [^\n]*/<EXCEPTION LINE>/xms;
Test::More::is(
    $actual_eval_error,
    "<LOCATION LINE>\n"
    . $bail_message . "\n"
    . "<EXCEPTION LINE>\n",
    "bail with string argument"
);

{
    local *do_S = *do_bail_with_object_if_A;
    $eval_ok = eval { $value_ref = do_parse(); 1 };
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
