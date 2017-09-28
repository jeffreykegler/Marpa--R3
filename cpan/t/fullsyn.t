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

# A "full" Synopsis for the intro doc to the SLIF

use 5.010001;

use strict;
use warnings;
use Test::More tests => 1;
use English qw( -no_match_vars );
use Scalar::Util;
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use lib 'inc';
use Marpa::R3::Test;

## no critic (ErrorHandling::RequireCarping);

# Marpa::R3::Display
# name: SLIF full synopsis

use Marpa::R3;

my $grammar = Marpa::R3::Scanless::G->new(
    {   bless_package => 'My_Nodes',
        source        => \(<<'END_OF_SOURCE'),
:default ::= action => [values] bless => ::lhs
lexeme default = action => [ start, length, value ]
    bless => ::name

:start ::= Script
Script ::= Expression+ separator => comma
comma ~ [,]
Expression ::=
    Number bless => primary
    | '(' Expression ')' bless => paren assoc => group
   || Expression '**' Expression bless => exponentiate assoc => right
   || Expression '*' Expression bless => multiply
    | Expression '/' Expression bless => divide
   || Expression '+' Expression bless => add
    | Expression '-' Expression bless => subtract

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


my $recce = Marpa::R3::Scanless::R->new( { grammar => $grammar } );

my $input = '42*2+7/3, 42*(2+7)/3, 2**7-3, 2**(7-3)';
$recce->read(\$input);
my $value_ref = $recce->value();
die "No parse was found\n" if not defined $value_ref;

# Result will be something like "86.33... 126 125 16"
# depending on the floating point precision
my $result = ${$value_ref}->doit();

package My_Nodes;

sub My_Nodes::primary::doit { return $_[0]->[0]->doit() }
sub My_Nodes::Number::doit  { return $_[0]->[2] }
sub My_Nodes::paren::doit   { my ($self) = @_; $self->[1]->doit() }

sub My_Nodes::add::doit {
    my ($self) = @_;
    $self->[0]->doit() + $self->[2]->doit();
}

sub My_Nodes::subtract::doit {
    my ($self) = @_;
    $self->[0]->doit() - $self->[2]->doit();
}

sub My_Nodes::multiply::doit {
    my ($self) = @_;
    $self->[0]->doit() * $self->[2]->doit();
}

sub My_Nodes::divide::doit {
    my ($self) = @_;
    $self->[0]->doit() / $self->[2]->doit();
}

sub My_Nodes::exponentiate::doit {
    my ($self) = @_;
    $self->[0]->doit()**$self->[2]->doit();
}

sub My_Nodes::Script::doit {
    my ($self) = @_;
    return join q{ }, map { $_->doit() } @{$self};
}

# Marpa::R3::Display::End

package main;

Test::More::like(
    $result,
    qr/\A 86[.]3\d+ \s+ 126 \s+ 125 \s+ 16\z/xms,
    'Value of scannerless parse'
);

# vim: expandtab shiftwidth=4:
