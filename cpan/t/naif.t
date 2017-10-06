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

# Converted to SLIF from naif.t

# Regression test of ref to undef as token value

use 5.010001;


# Small NAIF tests

use strict;
use warnings;
use Data::Dumper;
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use Test::More tests => 1;
use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

my $dsl = <<'END_OF_DSL';
:default ::= action => My_Actions::dwim
start ::= x y
x ~ 'z'
y ~ 'z'
END_OF_DSL

my $grammar = Marpa::R3::Scanless::G->new( { source => \$dsl } ); 
my $rec = Marpa::R3::Scanless::R->new( { grammar => $grammar } );

$rec->read( \'zz', 0, 0);
$rec->lexeme_alternative('x',\undef);
$rec->lexeme_complete(undef, undef, 1);
$rec->lexeme_alternative('y',\"some");
$rec->lexeme_complete(undef, undef, 1);

my $value_ref = $rec->value();
die if not defined $value_ref;

Test::More::is_deeply(
    ${$value_ref},
    [ \undef, \'some' ],
    "Regression test of ref to undef as token value"
);

sub My_Actions::dwim {
    shift;
    return $_[0] if scalar @_ == 1;
    return [@_];
}

# vim: expandtab shiftwidth=4:
