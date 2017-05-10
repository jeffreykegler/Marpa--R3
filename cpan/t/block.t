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

# Test of multiple input blocks

use 5.010001;
use strict;
use warnings;
use Test::More tests => 2;
use English qw( -no_match_vars );
use Scalar::Util qw(blessed);
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use lib 'inc';
use Marpa::R3::Test;

## no critic (ErrorHandling::RequireCarping);

use Marpa::R3;

my $calculator_grammar = Marpa::R3::Scanless::G->new(
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

do_test(
    'Calculator 1', $calculator_grammar,
    [split ' ', q<42*2+7/3 , 42*(2+7)/3, 2 ** 7 - 3, 2**(7-3)>],
    qr/\A 86[.]3\d+ \s+ 126 \s+ 125 \s+ 16\z/xms
);

do_test(
    'Calculator 2', $calculator_grammar,
    [' ', '42', '*(2', ' ', '+', '7)/3', ' '],
    qr/\A 126 \z/xms
);

sub do_test {
    my ( $name, $grammar, $input, $output_re) = @_;
    my $recce = Marpa::R3::Scanless::R->new( { grammar => $grammar } );

    for my $block (@{$input}) {
        $recce->read(\$block);
    }
    my $value_ref = $recce->value();
    if ( not defined $value_ref ) {
        die "No parse was found, after reading the entire input\n";
    }
    my $parse = { variables => { say => -1 } };
    my $value = ${$value_ref}->doit($parse);
    Test::More::like( $value, $output_re, $name );
}

sub My_Nodes::script::doit {
    my ($self, $parse) = @_;
    return join q{ }, map { $_->doit($parse) } @{$self};
}
sub My_Nodes::statement::doit {
    my ($self, $parse) = @_;
    return $self->[0]->doit($parse);
}

sub My_Nodes::add::doit {
    my ($self, $parse) = @_;
    my ( $a, $b ) = @{$self};
    return $a->doit($parse) + $b->doit($parse);
}

sub My_Nodes::subtract::doit {
    my ($self, $parse) = @_;
    my ( $a, $b ) = @{$self};
    return $a->doit($parse) - $b->doit($parse);
}

sub My_Nodes::multiply::doit {
    my ($self, $parse) = @_;
    my ( $a, $b ) = @{$self};
    return $a->doit($parse) * $b->doit($parse);
}

sub My_Nodes::divide::doit {
    my ($self, $parse) = @_;
    my ( $a, $b ) = @{$self};
    return $a->doit($parse) / $b->doit($parse);
}

sub My_Nodes::unary_sign::doit {
    my ($self, $parse) = @_;
    my ( $sign, $expression ) = @{$self};
    my $unsigned_result = $expression->doit($parse);
    return $sign eq '+' ? $unsigned_result : -$unsigned_result;
} ## end sub My_Nodes::unary_sign::doit

sub My_Nodes::variable::doit {
    my ( $self, $parse ) = @_;
    my $name = $self->[0];
    Marpa::R3::Context::bail(qq{variable "$name" does not exist})
        if not exists $parse->{variables}->{$name};
    return $parse->{variables}->{$name};
} ## end sub My_Nodes::variable::doit

sub My_Nodes::primary::doit {
    my ($self, $parse) = @_;
    return $self->[0];
}
sub My_Nodes::parens::doit  {
    my ($self, $parse) = @_;
    return $self->[0]->doit($parse);
}

sub My_Nodes::power::doit {
    my ($self, $parse) = @_;
    my ( $a, $b ) = @{$self};
    return $a->doit($parse)**$b->doit($parse);
}

# vim: expandtab shiftwidth=4:
