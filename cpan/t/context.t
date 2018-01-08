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

# Converted from Marpa::R2 sl_context.t

# Test of bail() and context variables in SLIF semantics

use 5.010001;

use strict;
use warnings;

use Test::More tests => 8;

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
    my $production_id           = $Marpa::R3::Context::production_id;
    my $slg             = $Marpa::R3::Context::grammar;
    my ( $lhs, @rhs ) =
      map { $slg->symbol_name($_) } $slg->production_expand($production_id);
    $action_object->{text} =
        "rule $production_id: $lhs ::= "
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

{
    # This grammar tests multiple uses of the same character class,
    # so we look at the symbols and productions.
    my $this_dsl = $dsl;
    $this_dsl =~ s/DOIT/main::no_bail/xms;
    my $grammar   = Marpa::R3::Grammar->new(
        {   source => \$this_dsl }
    );
    Marpa::R3::Test::is( $grammar->symbols_show(),
    <<'EO_TEXT', 'Symbols');
S1 A
S2 B
S3 C
S4 D
S5 S
S6 [:lex_start:]
S7 [:start:]
S8 [\d\D]
EO_TEXT
    Marpa::R3::Test::is( $grammar->productions_show(),
    <<'EO_TEXT', 'Productions');
R1 [:start:] ::= S
R2 S ::= A B C D
R3 [:lex_start:] ~ A
R4 [:lex_start:] ~ B
R5 [:lex_start:] ~ C
R6 [:lex_start:] ~ D
R7 A ~ [\d\D]
R8 B ~ [\d\D]
R9 C ~ [\d\D]
R10 D ~ [\d\D]
EO_TEXT
}

sub do_parse {
    my ($action) = @_;
    my $this_dsl = $dsl;
    $this_dsl =~ s/DOIT/$action/xms;
    my $grammar   = Marpa::R3::Grammar->new(
        {   source => \$this_dsl }
    );
    my $recce = Marpa::R3::Recognizer->new( { grammar => $grammar } );
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
    my $expected_text = qq{rule 2: S ::= A B C D\nlocations: 0-3\n};
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
