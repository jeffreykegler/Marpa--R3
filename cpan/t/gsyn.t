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

# Synopsis for Scannerless version of Stuizand interface

use 5.010001;

use strict;
use warnings;
use English qw( -no_match_vars );
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use Test::More tests => 7;
use lib 'inc';
use Marpa::R3::Test;

## no critic (ErrorHandling::RequireCarping);

# Marpa::R3::Display
# name: Scanless grammar synopsis

use Marpa::R3;

my $grammar = Marpa::R3::Grammar->new(
    {
        semantics_package => 'My_Actions',
        source            => \(<<'END_OF_SOURCE'),
:default ::= action => do_first_arg
:start ::= Script
Script ::= Expression+ separator => comma action => do_script
comma ~ [,]
Expression ::=
    Number
    | '(' Expression ')' action => do_parens assoc => group
   || Expression '**' Expression action => do_pow assoc => right
   || Expression '*' Expression action => do_multiply
    | Expression '/' Expression action => do_divide
   || Expression '+' Expression action => do_add
    | Expression '-' Expression action => do_subtract
Number ~ [\d]+

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
END_OF_SOURCE
    }
);

my $input = '42 * 1 + 7';
my $value_ref = $grammar->parse( \$input );

# Marpa::R3::Display::End

Marpa::R3::Test::is( ${$value_ref}, 49, 'Synopsis value test');

my $productions_show_output = $grammar->productions_show();
Marpa::R3::Test::is( $productions_show_output,
    <<'END_OF_SHOW_RULES_OUTPUT', 'Scanless productions_show()' );
R1 [:start:] ::= Script
R2 Expression ::= Expression; prec=-1
R3 Expression ::= Expression; prec=0
R4 Expression ::= Expression; prec=1
R5 Expression ::= Expression; prec=2
R6 Expression ::= Number; prec=3
R7 Expression ::= '(' Expression ')'; prec=3
R8 Expression ::= Expression '**' Expression; prec=2
R9 Expression ::= Expression '*' Expression; prec=1
R10 Expression ::= Expression '/' Expression; prec=1
R11 Expression ::= Expression '+' Expression; prec=0
R12 Expression ::= Expression '-' Expression; prec=0
R13 Script ::= Expression +
R14 [:lex_start:] ~ Number
R15 [:lex_start:] ~ [:discard:]
R16 [:lex_start:] ~ '('
R17 [:lex_start:] ~ ')'
R18 [:lex_start:] ~ '**'
R19 [:lex_start:] ~ '*'
R20 [:lex_start:] ~ '/'
R21 [:lex_start:] ~ '+'
R22 [:lex_start:] ~ '-'
R23 [:lex_start:] ~ comma
R24 comma ~ [,]
R25 '(' ~ [\(]
R26 ')' ~ [\)]
R27 '**' ~ [\*] [\*]
R28 '*' ~ [\*]
R29 '/' ~ [\/]
R30 '+' ~ [\+]
R31 '-' ~ [\-]
R32 Number ~ [\d] +
R33 [:discard:] ~ whitespace
R34 whitespace ~ [\s] +
R35 [:discard:] ~ <hash comment>
R36 <hash comment> ~ <terminated hash comment>
R37 <hash comment> ~ <unterminated final hash comment>
R38 <terminated hash comment> ~ [\#] <hash comment body> <vertical space char>
R39 <unterminated final hash comment> ~ [\#] <hash comment body>
R40 <hash comment body> ~ <hash comment char> *
R41 <vertical space char> ~ [\x{A}\x{B}\x{C}\x{D}\x{2028}\x{2029}]
R42 <hash comment char> ~ [^\x{A}\x{B}\x{C}\x{D}\x{2028}\x{2029}]
END_OF_SHOW_RULES_OUTPUT

my $rules_show_output;
$rules_show_output = $grammar->g1_rules_show();
Marpa::R3::Test::is( $rules_show_output,
    <<'END_OF_SHOW_RULES_OUTPUT', 'Scanless g1_rules_show()' );
R0 Script ::= Expression +
R1 Expression ::= Expression
R2 Expression ::= Expression
R3 Expression ::= Expression
R4 Expression ::= Expression
R5 Expression ::= Number
R6 Expression ::= '(' Expression ')'
R7 Expression ::= Expression '**' Expression
R8 Expression ::= Expression '*' Expression
R9 Expression ::= Expression '/' Expression
R10 Expression ::= Expression '+' Expression
R11 Expression ::= Expression '-' Expression
R12 [:start:] ::= Script
END_OF_SHOW_RULES_OUTPUT


$rules_show_output = $grammar->l0_rules_show({ verbose => 1 } );

Marpa::R3::Test::is( $rules_show_output,
    <<'END_OF_SHOW_RULES_OUTPUT', 'Scanless l0_rules_show()' );
R0 comma ~ [,]
R1 '(' ~ [\(]
R2 ')' ~ [\)]
R3 '**' ~ [\*] [\*]
R4 '*' ~ [\*]
R5 '/' ~ [\/]
R6 '+' ~ [\+]
R7 '-' ~ [\-]
R8 Number ~ [\d] +
R9 [:discard:] ~ whitespace
R10 whitespace ~ [\s] +
R11 [:discard:] ~ <hash comment>
R12 <hash comment> ~ <terminated hash comment>
R13 <hash comment> ~ <unterminated final hash comment>
R14 <terminated hash comment> ~ [\#] <hash comment body> <vertical space char>
R15 <unterminated final hash comment> ~ [\#] <hash comment body>
R16 <hash comment body> ~ <hash comment char> *
R17 <vertical space char> ~ [\x{A}\x{B}\x{C}\x{D}\x{2028}\x{2029}]
R18 <hash comment char> ~ [^\x{A}\x{B}\x{C}\x{D}\x{2028}\x{2029}]
R19 [:lex_start:] ~ Number
R20 [:lex_start:] ~ [:discard:]
R21 [:lex_start:] ~ '('
R22 [:lex_start:] ~ ')'
R23 [:lex_start:] ~ '**'
R24 [:lex_start:] ~ '*'
R25 [:lex_start:] ~ '/'
R26 [:lex_start:] ~ '+'
R27 [:lex_start:] ~ '-'
R28 [:lex_start:] ~ comma
END_OF_SHOW_RULES_OUTPUT

sub my_parser {
    my ( $grammar, $p_input_string ) = @_;

# Marpa::R3::Display
# name: Scanless recognizer synopsis

    my $recce = Marpa::R3::Scanless::R->new( { grammar => $grammar } );
    my $self = bless { grammar => $grammar }, 'My_Actions';
    $self->{recce} = $recce;

    if ( not defined eval { $recce->read($p_input_string); 1 }
        )
    {
        ## Add last expression found, and rethrow
        my $eval_error = $EVAL_ERROR;
        chomp $eval_error;
        die $self->show_last_expression(), "\n", $eval_error, "\n";
    } ## end if ( not defined eval { $event_count = $recce->read...})

    my $value_ref = $recce->value( $self );
    if ( not defined $value_ref ) {
        die $self->show_last_expression(), "\n",
            "No parse was found, after reading the entire input\n";
    }

# Marpa::R3::Display::End

    return ${$value_ref};

} ## end sub my_parser

my @tests = (
    [   '42*2+7/3, 42*(2+7)/3, 2**7-3, 2**(7-3)' =>
            qr/\A 86[.]3\d+ \s+ 126 \s+ 125 \s+ 16\z/xms
    ],
    [   '42*3+7, 42 * 3 + 7, 42 * 3+7' => qr/ \s* 133 \s+ 133 \s+ 133 \s* /xms
    ],
    [   '15329 + 42 * 290 * 711, 42*3+7, 3*3+4* 4' =>
            qr/ \s* 8675309 \s+ 133 \s+ 25 \s* /xms
    ],
);

for my $test (@tests) {
    my ( $input, $output_re ) = @{$test};
    my $value = my_parser( $grammar, \$input );
    Test::More::like( $value, $output_re, 'Value of scannerless parse' );
}

# Marpa::R3::Display
# name: Scanless recognizer semantics

package My_Actions;

sub do_parens    { return $_[1]->[1] }
sub do_add       { return $_[1]->[0] + $_[1]->[2] }
sub do_subtract  { return $_[1]->[0] - $_[1]->[2] }
sub do_multiply  { return $_[1]->[0] * $_[1]->[2] }
sub do_divide    { return $_[1]->[0] / $_[1]->[2] }
sub do_pow       { return $_[1]->[0]**$_[1]->[2] }
sub do_first_arg { return $_[1]->[0] }
sub do_script    { return join q{ }, @{$_[1]} }

# Marpa::R3::Display::End

# Marpa::R3::Display
# name: Scanless recognizer diagnostics

sub show_last_expression {
    my ($self) = @_;
    my $recce = $self->{recce};
    my ( $g1_start, $g1_length ) = $recce->last_completed('Expression');
    return 'No expression was successfully parsed' if not defined $g1_start;
    my $last_expression = $recce->g1_literal( $g1_start, $g1_length );
    return "Last expression successfully parsed was: $last_expression";
} ## end sub show_last_expression

# Marpa::R3::Display::End

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
