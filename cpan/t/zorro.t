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

# Note: Converted to SLIF from null_value.t

# VALUATOR: TODO

use 5.010001;

use strict;
use warnings;
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use Test::More tests => 1;
use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

package Test;

# The start rule

sub new { my $class = shift; return bless {}, $class }

## no critic (Subroutines::RequireArgUnpacking)
sub rule0 {
    my (undef, $values) = @_;
    return $values->[0] . ', but ' . $values->[1];
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
