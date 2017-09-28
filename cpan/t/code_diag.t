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

# Ensure various coding errors are caught

use 5.010001;

use strict;
use warnings;

use Test::More tests => 7;

use lib 'inc';
use Marpa::R3::Test;
use Fatal qw( open close );
use English qw( -no_match_vars );
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use Marpa::R3;

sub DEFAULT_NULL_DESC { return '[default null]'; }
sub NULL_DESC         { return '[null]'; }

my @features = qw(
    E_OP_ACTION_FEATURE DEFAULT_ACTION_FEATURE
);

my @tests = ( 'run phase warning', 'run phase error', 'run phase die', );

# Code to produce a run phase warning
sub run_phase_warning {
    my $x;
    warn 'Test Warning 1';
    warn 'Test Warning 2';
    $x++;
    return 1;
} ## end sub run_phase_warning

# Code to produce a run phase error
sub run_phase_error {
    my $x = 0;
    $x = 1 / 0;
    return $x++;
}

# Code to produce a run phase die()
sub run_phase_die {
    my $x = 0;
    die 'test call to die';
}

my %test_arg;
my %expected;
for my $test (@tests) {
    for my $feature (@features) {
        $test_arg{$test}{$feature} = '1;';
        $expected{$test}{$feature} = q{};
    }
} ## end for my $test (@tests)

for my $feature (@features) {
    $test_arg{'run phase warning'}{$feature} = 'main::run_phase_warning';
    $test_arg{'run phase error'}{$feature}   = 'main::run_phase_error';
    $test_arg{'run phase die'}{$feature}     = 'main::run_phase_die';
}

my $getting_headers = 1;
my @headers;
my $data = q{};

my $test_data = <<'END_OF_TEST_DATA';

| bad code run phase warning
# this should be a run phase warning
my $x = 0;
warn "Test Warning 1";
warn "Test Warning 2";
$x++;
1;
__END__

| expected E_OP_ACTION_FEATURE run phase warning
============================================================
* THERE WERE 2 WARNING(S) IN THE MARPA SEMANTICS:
Marpa treats warnings as fatal errors
* THIS IS WHAT MARPA WAS DOING WHEN THE PROBLEM OCCURRED:
Computing value for rule: F ::= F MultOp F
* WARNING MESSAGE NUMBER 0:
Test Warning 1 at <LOCATION>
* WARNING MESSAGE NUMBER 1:
Test Warning 2 at <LOCATION>
Marpa::R3 exception at <LOCATION>
Marpa::R3 exception at <LOCATION>
__END__

| expected DEFAULT_ACTION_FEATURE run phase warning
============================================================
* THERE WERE 2 WARNING(S) IN THE MARPA SEMANTICS:
Marpa treats warnings as fatal errors
* THIS IS WHAT MARPA WAS DOING WHEN THE PROBLEM OCCURRED:
Computing value for rule: trailer ::= Text
* WARNING MESSAGE NUMBER 0:
Test Warning 1 at <LOCATION>
* WARNING MESSAGE NUMBER 1:
Test Warning 2 at <LOCATION>
Marpa::R3 exception at <LOCATION>
Marpa::R3 exception at <LOCATION>
__END__

| bad code run phase error
# this should be a run phase error
my $x = 0;
$x = 711/0;
$x++;
1;
__END__

| expected E_OP_ACTION_FEATURE run phase error
============================================================
* THE MARPA SEMANTICS PRODUCED A FATAL ERROR
* THIS IS WHAT MARPA WAS DOING WHEN THE PROBLEM OCCURRED:
Computing value for rule: F ::= F MultOp F
* THIS WAS THE FATAL ERROR MESSAGE:
Illegal division by zero at <LOCATION>
Marpa::R3 exception at <LOCATION>
Marpa::R3 exception at <LOCATION>
__END__

| expected DEFAULT_ACTION_FEATURE run phase error
============================================================
* THE MARPA SEMANTICS PRODUCED A FATAL ERROR
* THIS IS WHAT MARPA WAS DOING WHEN THE PROBLEM OCCURRED:
Computing value for rule: trailer ::= Text
* THIS WAS THE FATAL ERROR MESSAGE:
Illegal division by zero at <LOCATION>
Marpa::R3 exception at <LOCATION>
Marpa::R3 exception at <LOCATION>
__END__

| bad code run phase die
# this is a call to die()
my $x = 0;
die 'test call to die';
$x++;
1;
__END__

| expected E_OP_ACTION_FEATURE run phase die
============================================================
* THE MARPA SEMANTICS PRODUCED A FATAL ERROR
* THIS IS WHAT MARPA WAS DOING WHEN THE PROBLEM OCCURRED:
Computing value for rule: F ::= F MultOp F
* THIS WAS THE FATAL ERROR MESSAGE:
test call to die at <LOCATION>
Marpa::R3 exception at <LOCATION>
Marpa::R3 exception at <LOCATION>
__END__

| expected DEFAULT_ACTION_FEATURE run phase die
============================================================
* THE MARPA SEMANTICS PRODUCED A FATAL ERROR
* THIS IS WHAT MARPA WAS DOING WHEN THE PROBLEM OCCURRED:
Computing value for rule: trailer ::= Text
* THIS WAS THE FATAL ERROR MESSAGE:
test call to die at <LOCATION>
Marpa::R3 exception at <LOCATION>
Marpa::R3 exception at <LOCATION>
__END__

END_OF_TEST_DATA

## no critic (InputOutput::RequireBriefOpen)
open my $test_data_fh, q{<}, \$test_data;
## use critic
LINE: while ( my $line = <$test_data_fh> ) {

    if ($getting_headers) {
        next LINE if $line =~ m/ \A \s* \Z/xms;
        if ( $line =~ s/ \A [|] \s+ //xms ) {
            chomp $line;
            push @headers, $line;
            next LINE;
        }
        else {
            $getting_headers = 0;
            $data            = q{};
        }
    } ## end if ($getting_headers)

    # getting data

    if ( $line =~ /\A__END__\Z/xms ) {
        HEADER: while ( my $header = pop @headers ) {
            if ( $header =~ s/\A expected \s //xms ) {
                my ( $feature, $test ) =
                    ( $header =~ m/\A (\S*) \s+ (.*) \Z/xms );
                die
                    "expected result given for unknown test, feature: $test, $feature"
                    if not defined $expected{$test}{$feature};
                $expected{$test}{$feature} = $data;
                next HEADER;
            } ## end if ( $header =~ s/\A expected \s //xms )
            if ( $header =~ s/\A good \s code \s //xms ) {
                die 'Good code should no longer be in data section';
            }
            if ( $header =~ s/\A bad \s code \s //xms ) {
                chomp $header;
                die "test code given for unknown test: $header"
                    if not defined $test_arg{$header};
                next HEADER;
            } ## end if ( $header =~ s/\A bad \s code \s //xms )
            die "Bad header: $header";
        }    # HEADER
        $getting_headers = 1;
        $data            = q{};
    }    # if $line

    $data .= $line;
} ## end LINE: while ( my $line = <$test_data_fh> )

sub canonical {
    my $template = shift;

    # allow for this test file to change name
    # as long as it remains lower-case, with
    # _ or -
    $template =~ s{
        \s at \s t[^.]+[.]t \s line \s \d+ [^\n]*
    }{ at <LOCATION>}gxms;
    return $template;
} ## end sub canonical

my $dsl = <<'END_OF_DSL';
:default ::= action => DEFAULT_ACTION_FEATURE
S ::= T trailer optional_trailer1 optional_trailer2
T ::= T AddOp T action => main::e_op_action
T ::= F action => main::e_pass_through
F ::= F MultOp F action => E_OP_ACTION_FEATURE
F ::=  Number action => main::e_number_action
optional_trailer1 ::= trailer
optional_trailer1 ::= action => main::DEFAULT_NULL_DESC
optional_trailer2 ::= action => main::NULL_DESC
trailer ::= Text

Number ~ [\d]+
AddOp ~ '+'
MultOp ~ '*'
Text ~ 'trailer'
:discard ~ ws
ws ~ [\s]+
END_OF_DSL

sub run_test {
    my $args = shift;

    my $this_dsl = $dsl;

    ARG: for my $arg ( keys %{$args} ) {
        my $value        = $args->{$arg};
        if ( $arg eq 'E_OP_ACTION_FEATURE' ) {
            $this_dsl =~ s/E_OP_ACTION_FEATURE/$value/xms;
            next ARG;
        }
        if ( $arg eq 'DEFAULT_ACTION_FEATURE' ) {
            $this_dsl =~ s/DEFAULT_ACTION_FEATURE/$value/xms;
            next ARG;
        }
        die "unknown argument to run_test: $arg";
    } ## end ARG: for my $arg ( keys %{$args} )

    $this_dsl =~ s/E_OP_ACTION_FEATURE/main::e_op_action/xmsg;
    $this_dsl =~ s/DEFAULT_ACTION_FEATURE/main::default_action/xmsg;

    my $grammar = Marpa::R3::Scanless::G->new( { source => \$this_dsl });

    my $recce = Marpa::R3::Scanless::R->new( { grammar => $grammar } );
    $recce->read(\'2*3+4*1trailer');

    my $expected  = '(((2*3)+(4*1))==10;trailer;[default null];[null])';
    my $value_ref = $recce->value();
    my $value     = $value_ref ? ${$value_ref} : 'No parse';
    Marpa::R3::Test::is( $value, $expected, 'Ambiguous Equation Value' );

    return 1;

}    # sub run_test

run_test( {} );

for my $test (@tests) {
    FEATURE: for my $feature (@features) {
        next FEATURE if not defined $expected{$test}{$feature};
        my $test_name = "$test in $feature";
        if ( eval { run_test( { $feature => $test_arg{$test}{$feature}, } ); }
            )
        {
            Test::More::fail(
                "$test_name did not fail -- that shouldn't happen");
        } ## end if ( eval { run_test( { $feature => $test_arg{$test}...})})
        else {
            my $eval_error = $EVAL_ERROR;
            Marpa::R3::Test::is( canonical($eval_error),
                $expected{$test}{$feature}, $test_name );
        }
    } ## end FEATURE: for my $feature (@features)
} ## end for my $test (@tests)

## no critic (Subroutines::RequireArgUnpacking)

sub e_pass_through {
    return $_[1]->[0];
}

sub e_op_action {
    my ( $right_string, $right_value ) = ( $_[1]->[2] =~ /^(.*)==(.*)$/xms );
    my ( $left_string,  $left_value )  = ( $_[1]->[0] =~ /^(.*)==(.*)$/xms );
    my $op = $_[1]->[1];
    my $value;
    if ( $op eq q{+} ) {
        $value = $left_value + $right_value;
    }
    elsif ( $op eq q{*} ) {
        $value = $left_value * $right_value;
    }
    elsif ( $op eq q{-} ) {
        $value = $left_value - $right_value;
    }
    else {
        die "Unknown op: $op";
    }
    return '(' . $left_string . $op . $right_string . ')==' . $value;
} ## end sub e_op_action

sub e_number_action {
    my (undef, $v) = @_;
    my $v0 = pop @${v};
    return $v0 . q{==} . $v0;
}

sub default_action {
    my ( undef, $v ) = @_;
    my $v_count = scalar @{$v};
    return q{} if $v_count <= 0;
    return $v->[0] if $v_count == 1;
    return '(' . join( q{;}, ( map { $_ // 'undef' } @{$v} ) ) . ')';
} ## end sub default_action

# vim: expandtab shiftwidth=4:
