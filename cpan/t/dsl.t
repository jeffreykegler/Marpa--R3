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

# Test of scannerless parsing -- a DSL

use 5.010001;

use strict;
use warnings;

use Test::More tests => 7;
my $builder = Test::More->builder;
binmode $builder->output,         ":utf8";
binmode $builder->failure_output, ":utf8";
binmode $builder->todo_output,    ":utf8";
use English qw( -no_match_vars );
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

my $rules = <<'END_OF_GRAMMAR';
:default ::= action => do_arg0
:start ::= script
script ::= expression
script ::= (script ';') expression
reduce_op ::= '+' | '-' | '/' | '*'
expression ::=
     NUM
   | VAR action => do_is_var
   | ('(') expression (')') assoc => group
   | ([\x{300C}]) expression ([\x{300D}]) assoc => group
  || '-' expression action => do_negate
  || expression '^' expression action => do_caret assoc => right
  || expression '*' expression action => do_star
   | expression '/' expression action => do_slash
  || expression '+' expression action => do_plus
   | expression '-' expression action => do_minus
  || expression ',' expression action => do_array
  || reduce_op 'reduce' expression action => do_reduce
  || VAR '=' expression action => do_set_var

NUM ~ [\d]+
VAR ~ [\w]+
:discard ~ whitespace
whitespace ~ [\s]+
# allow comments
:discard ~ <hash comment>
<hash comment> ~ <terminated hash comment> | <unterminated
   final hash comment>
<terminated hash comment> ~ '#' <hash comment body> <vertical space char>
<unterminated final hash comment> ~ '#' <hash comment body>
<hash comment body> ~ <hash comment char>*
<vertical space char> ~ [\x{A}\x{B}\x{C}\x{D}\x{2028}\x{2029}]
<hash comment char> ~ [^\x{A}\x{B}\x{C}\x{D}\x{2028}\x{2029}]
END_OF_GRAMMAR

my $grammar = Marpa::R3::Grammar->new(
    {
        semantics_package => 'My_Actions',
        source            => \$rules
    }
);

my %binop_closure = (
    '*' => sub { $_[0] * $_[1] },
    '/' => sub {
        Marpa::R3::Context::bail('Division by zero') if not $_[1];
        $_[0] / $_[1];
    },
    '+' => sub { $_[0] + $_[1] },
    '-' => sub { $_[0] - $_[1] },
    '^' => sub { $_[0]**$_[1] },
);

my %symbol_table = ();

package main;

# For debugging
sub add_brackets {
    my ( undef, @children ) = @_;
    return $children[0] if 1 == scalar @children;
    my $original = join q{}, grep {defined} @children;
    return '[' . $original . ']';
} ## end sub add_brackets

sub calculate {
    my ($p_string) = @_;

    %symbol_table = ();

    my $recce = Marpa::R3::Recognizer->new( { grammar => $grammar } );

    my $self = bless { grammar => $grammar }, 'My_Actions';
    $self->{slr} = $recce;

    if ( not defined eval { $recce->read($p_string); 1 } ) {

        # Add last expression found, and rethrow
        my $eval_error = $EVAL_ERROR;
        chomp $eval_error;
        die $self->show_last_expression(), "\n", $eval_error, "\n";
    } ## end if ( not defined eval { $event_count = $recce->read...})
    my $valuer = Marpa::R3::Valuer->new( { recognizer => $recce } );
    my $value_ref = $valuer->value( $self );
    if ( not defined $value_ref ) {
        die $self->show_last_expression(), "\n",
            "No parse was found, after reading the entire input\n";
    }
    return ${$value_ref};

} ## end sub calculate

sub report_calculation {
    my ($string) = @_;
    my $result   = calculate(\$string);
    $result = join q{,}, @{$result} if ref $result eq 'ARRAY';
    my $output = "Parse: $result\n";
    for my $symbol ( sort keys %symbol_table ) {
        $output .= qq{"$symbol" = "} . $symbol_table{$symbol} . qq{"\n};
    }
    chomp $output;
    return $output;
} ## end sub report_calculation

my @tests_data = (
    [ "4 * 3 + 42 / 1" => 'Parse: 54' ],
    [   "4 * 3 / (a = b = 5) + 42 - 1" =>
            qq{Parse: 43.4\n"a" = "5"\n"b" = "5"}
    ],
    [ "4 * 3 /  5 - - - 3 + 42 - 1" => 'Parse: 40.4' ],
    [ "a=1;b = 5;  - a - b"         => qq{Parse: -6\n"a" = "1"\n"b" = "5"} ],
    [ "1 * 2 + 3 * 4 ^ 2 ^ 2 ^ 2 * 42 + 1" => 'Parse: 541165879299' ],
    [ "+ reduce 1 + 2, 3,4*2 , 5"          => 'Parse: 19' ]
);

my $unicoded_string = "4 * 3 / (a = b = 5) + 42 - 1";
$unicoded_string =~ tr/() /\x{300C}\x{300D}\x{2028}/;
push @tests_data, [ $unicoded_string, qq{Parse: 43.4\n"a" = "5"\n"b" = "5"} ];

TEST:
for my $test_data (@tests_data) {
    my ($test_string,     $expected_value) = @{$test_data};
    my $actual_value = report_calculation( $test_string );
    $actual_value //= 'NO PARSE!';
    Test::More::is( $actual_value, $expected_value, qq{Value of "$test_string"} );
} ## end TEST: for my $test_string (@test_strings)

package My_Actions;

sub do_is_var {
    my ( undef, $v ) = @_;
    my ( $var ) = @{$v};
    my $value = $symbol_table{$var};
    Marpa::R3::Context::bail(qq{Undefined variable "$var"})
        if not defined $value;
    return $value;
} ## end sub do_is_var

sub do_set_var {
    my ( undef, $v ) = @_;
    my ( $var, undef, $value ) = @{$v};
    return $symbol_table{$var} = $value;
}

sub do_negate {
    return -$_[1]->[1];
}

sub do_arg0 { return $_[1]->[0]; }
sub do_arg1 { return $_[1]->[1]; }
sub do_arg2 { return $_[1]->[2]; }

sub do_array {
    my ( undef, $v ) = @_;
    my ( $left, undef, $right ) = @{$v};
    my @value = ();
    my $ref;
    if ( $ref = ref $left ) {
        Marpa::R3::Context::bail("Bad ref type for array operand: $ref")
            if $ref ne 'ARRAY';
        push @value, @{$left};
    }
    else {
        push @value, $left;
    }
    if ( $ref = ref $right ) {
        Marpa::R3::Context::bail("Bad ref type for array operand: $ref")
            if $ref ne 'ARRAY';
        push @value, @{$right};
    }
    else {
        push @value, $right;
    }
    return \@value;
} ## end sub do_array

sub binop {
    my ( $op, $left, $right ) = @_;
    my $closure = $binop_closure{$op};
    Marpa::R3::Context::bail(
        qq{Do not know how to perform binary operation "$op"})
        if not defined $closure;
    return $closure->( $left, $right );
}

sub do_caret {
    my ( undef, $v ) = @_;
    my ( $left, undef, $right ) = @{$v};
    return binop( '^', $left, $right );
}

sub do_star {
    my ( undef, $v ) = @_;
    my ( $left, undef, $right ) = @{$v};
    return binop( '*', $left, $right );
}

sub do_slash {
    my ( undef, $v ) = @_;
    my ( $left, undef, $right ) = @{$v};
    return binop( '/', $left, $right );
}

sub do_plus {
    my ( undef, $v ) = @_;
    my ( $left, undef, $right ) = @{$v};
    return binop( '+', $left, $right );
}

sub do_minus {
    my ( undef, $v ) = @_;
    my ( $left, undef, $right ) = @{$v};
    return binop( '-', $left, $right );
}

sub do_reduce {
    my ( undef, $v ) = @_;
    my ( $op, undef, $args ) = @{$v};
    my $closure = $binop_closure{$op};
    Marpa::R3::Context::bail(
        qq{Do not know how to perform binary operation "$op"})
        if not defined $closure;
    $args = [$args] if ref $args eq '';
    my @stack = @{$args};
    OP: while (1) {
        return $stack[0] if scalar @stack <= 1;
        my $result = $closure->( $stack[-2], $stack[-1] );
        splice @stack, -2, 2, $result;
    }
    Marpa::R3::Context::bail('Should not get here');
} ## end sub do_reduce

sub show_last_expression {
    my ($self) = @_;
    my $slr = $self->{slr};
    my ( $start, $length ) = $slr->last_completed('expression');
    return 'No expression was successfully parsed' if not defined $start;
    my $last_expression = $slr->g1_literal( $start, $length );
    return "Last expression successfully parsed was: $last_expression";
} ## end sub show_last_expression

# vim: expandtab shiftwidth=4:
