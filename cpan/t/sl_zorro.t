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
# Note: Converted to SLIF from null_value.t

use 5.010001;
use strict;
use warnings;

use Test::More tests => 1;
use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

package Test;

# The start rule

sub new { my $class = shift; return bless {}, $class }

## no critic (Subroutines::RequireArgUnpacking)
sub rule0 {
    return $_[1] . ', but ' . $_[2];
}
## use critic

sub rule1 { return 'A is missing' }
sub rule2 { return q{I'm sometimes null and sometimes not} }
sub rule3 { return 'B is missing' }
sub rule4 { return 'C is missing' }
sub rule5 { return 'C matches Y' }
sub rule6 { return 'Zorro was here' }

package main;

my $dsl = <<'END_OF_DSL';
s ::= a y action => Test::rule0
a ::= action => Test::rule1
a ::= b c action => Test::rule2
b ::= action => Test::rule3
c ::= action => Test::rule4
c ::= y action => Test::rule5
y ::= Z action => Test::rule6
Z ~ 'Z'
END_OF_DSL

my $g = Marpa::R3::Scanless::G->new( { source => \$dsl } );
my $recce = Marpa::R3::Scanless::R->new( { grammar => $g } );
$recce->read( \'Z' );
my $ref_value = $recce->value();
my $value = $ref_value ? ${$ref_value} : 'No parse';
Marpa::R3::Test::is(
    $value,
    'A is missing, but Zorro was here',
    'null value example'
);

# vim: expandtab shiftwidth=4:
