#!perl
# Marpa::R3 is Copyright (C) 2016, Jeffrey Kegler.
#
# This module is free software; you can redistribute it and/or modify it
# under the same terms as Perl 5.10.1. For more details, see the full text
# of the licenses in the directory LICENSES.
#
# This program is distributed in the hope that it will be
# useful, but it is provided “as is” and without any express
# or implied warranties. For details, see the full text of
# of the licenses in the directory LICENSES.

# CENSUS: ASIS
# Note: SLIF TEST

# This test was originally based on Marpa::R2 Github issue #254 --
# constructor invoked on per-parse argument, which should not happen.
#
# Per-parse constructors and all effects of per-parse arguments were
# eliminated in Marpa::R3, so this test is now very basic and much simpler.

# _The Computer Journal_, Vol. 45, No. 6, pp. 620-630,
# in its "NNF" form

use 5.010001;
use strict;
use warnings;

use English qw( -no_match_vars );
use Test::More tests => 8;
use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;
use Data::Dumper;

package Class_Actions;

sub do_A {
    my ( $self, $values ) = @_;
    my ($letter) = @{$values};
    return join ';', "class method", "letter=$letter";
}

package Package_Actions;

sub do_A {
    my ( $self, $values ) = @_;
    my ($letter) = @{$values};
    return join ';', "package method", "letter=$letter";
}

package main;

my $grammar =
    Marpa::R3::Scanless::G->new( { source => \q(A ::= 'a' action => do_A) } );

my @tests = ();
PPO: for my $ppo_desc ( 'no', 'unblessed', 'same blessed', 'other blessed' ) {
    my $recce_arg   = {};
    my $method_desc = undef;
    $recce_arg = { semantics_package => 'Package_Actions' };
    $method_desc = 'package method';
    my $ppo = undef;
  SET_PPO_PARMS: {
        last SET_PPO_PARMS if $ppo_desc eq 'no';
        if ( $ppo_desc eq 'unblessed' ) {
            $ppo = { desc => $ppo_desc };
            last SET_PPO_PARMS;
        }
        if ( $ppo_desc eq 'same blessed' ) {
            $ppo = bless { desc => $ppo_desc }, 'Package_Actions';
            $method_desc = 'package method' if not defined $method_desc;
            last SET_PPO_PARMS;
        } ## end if ( $ppo_desc eq 'same blessed' )
        if ( $ppo_desc eq 'other blessed' ) {
            $ppo = bless { desc => $ppo_desc }, 'Class_Actions';
            $method_desc = 'class method' if not defined $method_desc;
            last SET_PPO_PARMS;
        } ## end if ( $ppo_desc eq 'other blessed' )
        die;
    } ## end SET_PPO_PARMS:
    next PPO if not defined $method_desc;
    my $value = join ';', $method_desc, 'letter=a';
    my $desc = "$ppo_desc ppo";
    push @tests, [ $recce_arg, $ppo, $value, 'Parse OK', $desc ];
} ## end PPO: for my $ppo_desc ( 'no', 'unblessed', 'same blessed',...)

TEST:
for my $test_data (@tests) {
    my ( $recce_arg, $ppo, $expected_value, $expected_result,
        $test_name )
        = @{$test_data};
    my ( $actual_value, $actual_result ) =
        my_parser( $grammar, $recce_arg, $ppo );
    Test::More::is(
        Data::Dumper::Dumper( \$actual_value ),
        Data::Dumper::Dumper( \$expected_value ),
        qq{Value of $test_name}
    );
    Test::More::is( $actual_result, $expected_result,
        qq{Result of $test_name} );
} ## end TEST: for my $test_data (@tests_data)

sub my_parser {
    my ( $grammar, $recce_arg, $ppo ) = @_;

    my $recce = Marpa::R3::Scanless::R->new( { grammar => $grammar }, $recce_arg );

    if ( not defined eval { $recce->read( \'a' ); 1 } ) {
        # say $EVAL_ERROR
        my $abbreviated_error = $EVAL_ERROR;
        chomp $abbreviated_error;
        return 'No parse', $abbreviated_error;
    } ## end if ( not defined eval { $recce->read( \$string ); 1 ...})
    my $value_ref;
    if (not defined eval { $value_ref = $recce->value($ppo); 1 } ) {
        # say $EVAL_ERROR
        my $abbreviated_error = $EVAL_ERROR;
        chomp $abbreviated_error;
        return 'value() failure', $abbreviated_error;
    }
    if ( not defined $value_ref ) {
        return 'No parse', 'Input read to end but no parse';
    }
    return ${$value_ref}, 'Parse OK';
} ## end sub my_parser

# vim: expandtab shiftwidth=4:
