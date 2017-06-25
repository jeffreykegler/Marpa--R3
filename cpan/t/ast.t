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

# Synopsis for Scannerless interface

use 5.010001;
use strict;
use warnings;
use Test::More tests => 4;
use English qw( -no_match_vars );
use Scalar::Util qw(blessed);
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use lib 'inc';
use Marpa::R3::Test;

## no critic (ErrorHandling::RequireCarping);

use Marpa::R3;

my $grammar = Marpa::R3::Scanless::G->new(
    {   bless_package => 'My_Nodes',
        source        => \(<<'END_OF_SOURCE'),
:default ::= action => ::array bless => ::lhs
:start ::= Script
Script ::= Expression+ separator => comma bless => script
comma ~ [,]
Expression ::=
    Number bless => primary
    | ('(') Expression (')') assoc => group bless => parens
   || Expression ('**') Expression assoc => right bless => power
   || Expression ('*') Expression bless => multiply
    | Expression ('/') Expression bless => divide
   || Expression ('+') Expression bless => add
    | Expression ('-') Expression bless => subtract
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

# Marpa::R3::Display
# name: SLG g1_rules_show() synopsis

my $rules_show_output = $grammar->g1_rules_show();

# Marpa::R3::Display::End

$rules_show_output .= $grammar->l0_rules_show(1);

Marpa::R3::Test::is( $rules_show_output,
    <<'END_OF_SHOW_RULES_OUTPUT', 'Scanless l0_rules_show()' );
G1 R0 Script ::= Expression +
G1 R1 Expression ::= Expression
G1 R2 Expression ::= Expression
G1 R3 Expression ::= Expression
G1 R4 Expression ::= Expression
G1 R5 Expression ::= Number
G1 R6 Expression ::= '(' Expression ')'
G1 R7 Expression ::= Expression '**' Expression
G1 R8 Expression ::= Expression '*' Expression
G1 R9 Expression ::= Expression '/' Expression
G1 R10 Expression ::= Expression '+' Expression
G1 R11 Expression ::= Expression '-' Expression
G1 R12 [:start:] ::= Script
L0 R0 comma ::= [,]
L0 R1 '(' ::= [\(]
L0 R2 ')' ::= [\)]
L0 R3 '**' ::= [\*] [\*]
L0 R4 '*' ::= [\*]
L0 R5 '/' ::= [\/]
L0 R6 '+' ::= [\+]
L0 R7 '-' ::= [\-]
L0 R8 Number ::= [\d] +
L0 R9 [:discard:] ::= whitespace
L0 R10 whitespace ::= [\s] +
L0 R11 [:discard:] ::= <hash comment>
L0 R12 <hash comment> ::= <terminated hash comment>
L0 R13 <hash comment> ::= <unterminated final hash comment>
L0 R14 <terminated hash comment> ::= [\#] <hash comment body> <vertical space char>
L0 R15 <unterminated final hash comment> ::= [\#] <hash comment body>
L0 R16 <hash comment body> ::= <hash comment char> *
L0 R17 <vertical space char> ::= [\x{A}\x{B}\x{C}\x{D}\x{2028}\x{2029}]
L0 R18 <hash comment char> ::= [^\x{A}\x{B}\x{C}\x{D}\x{2028}\x{2029}]
L0 R19 [:lex_start:] ::= Number
L0 R20 [:lex_start:] ::= [:discard:]
L0 R21 [:lex_start:] ::= '('
L0 R22 [:lex_start:] ::= ')'
L0 R23 [:lex_start:] ::= '**'
L0 R24 [:lex_start:] ::= '*'
L0 R25 [:lex_start:] ::= '/'
L0 R26 [:lex_start:] ::= '+'
L0 R27 [:lex_start:] ::= '-'
L0 R28 [:lex_start:] ::= comma
END_OF_SHOW_RULES_OUTPUT

sub my_parser {
    my ( $grammar, $p_input_string ) = @_;

    my $recce = Marpa::R3::Scanless::R->new( { grammar => $grammar } );

    $recce->read($p_input_string);
    my $value_ref = $recce->value();
    if ( not defined $value_ref ) {
        die "No parse was found, after reading the entire input\n";
    }
    return ${$value_ref}->doit();

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
    my $result = my_parser( $grammar, \$input );
    Test::More::like( $result, $output_re, 'Value of scannerless parse' );
}

sub My_Nodes::script::doit {
    my ($self) = @_;
    return join q{ }, map { $_->doit() } @{$self};
}

sub My_Nodes::add::doit {
    my ($self) = @_;
    my ( $a, $b ) = @{$self};
    return $a->doit() + $b->doit();
}

sub My_Nodes::subtract::doit {
    my ($self) = @_;
    my ( $a, $b ) = @{$self};
    return $a->doit() - $b->doit();
}

sub My_Nodes::multiply::doit {
    my ($self) = @_;
    my ( $a, $b ) = @{$self};
    return $a->doit() * $b->doit();
}

sub My_Nodes::divide::doit {
    my ($self) = @_;
    my ( $a, $b ) = @{$self};
    return $a->doit() / $b->doit();
}

sub My_Nodes::primary::doit { return $_[0]->[0]; }
sub My_Nodes::parens::doit  { return $_[0]->[0]->doit(); }

sub My_Nodes::power::doit {
    my ($self) = @_;
    my ( $a, $b ) = @{$self};
    return $a->doit()**$b->doit();
}

# vim: expandtab shiftwidth=4:
