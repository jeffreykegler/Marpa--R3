#!perl
# Copyright 2016 Jeffrey Kegler
# This file is part of Marpa::R3.  Marpa::R3 is free software: you can
# redistribute it and/or modify it under the terms of the GNU Lesser
# General Public License as published by the Free Software Foundation,
# either version 3 of the License, or (at your option) any later version.
#
# Marpa::R3 is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser
# General Public License along with Marpa::R3.  If not, see
# http://www.gnu.org/licenses/.

# CENSUS: ASIS
# Converted to SLIF from naif.t

# Regression test of ref to undef as token value

use 5.010001;

# Small NAIF tests

use strict;
use warnings;

use Test::More tests => 1;
use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;
use Data::Dumper;

my $dsl = <<'END_OF_DSL';
:default ::= action => My_Actions::dwim
start ::= x y
x ~ unicorn
y ~ unicorn
unicorn ~ [^\d\D]
END_OF_DSL

my $grammar = Marpa::R3::Scanless::G->new( { source => \$dsl } ); 
my $rec = Marpa::R3::Scanless::R->new( { grammar => $grammar } ); 

$rec->read( \'xy', 0, 0);
$rec->lexeme_alternative('x',\undef);
$rec->lexeme_complete(undef, 1);
$rec->lexeme_alternative('y',\"some");
$rec->lexeme_complete(undef, 1);

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
