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

# VALUATOR: TODO

use 5.010001;


# A variation on
# the example grammar in Aycock/Horspool "Practical Earley Parsing",
# _The Computer Journal_, Vol. 45, No. 6, pp. 620-630,
# Its order of ambiguity generates Pascal's triangle.

use strict;
use warnings;

use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use Test::More tests => 10;
use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

my $n = 10;

my $dsl = <<'=== END_OF_DSL ===';

sequence ::= A action => main::one
    | A sequence action => main::add
A ::= 'a' action => main::one
=== END_OF_DSL ===

sub one { return 1 }

sub add {
    my ( undef, $values ) = @_;
    my ( $left, $right )  = @{$values};
    return $left + $right;
}

my $grammar = Marpa::R3::Scanless::G->new( { source  => \$dsl } );
my $recce   = Marpa::R3::Scanless::R->new( { grammar => $grammar } );
my $input   = 'a' x $n;
$recce->read( \$input, 0, 0 );

my @parse_counts = (1);
for my $loc ( 1 .. $n ) {
    my $parse_number = 0;

    $recce->resume( undef, 1 );
    my $valuer   = Marpa::R3::Scanless::V->new( { recognizer => $recce } );
    die "No parse" if not my $value_ref = $valuer->value();
    local $Data::Dumper::Deepcopy = 1;
    # say STDERR Data::Dumper::Dumper($value_ref);
    my $actual = ${$value_ref};
    Marpa::R3::Test::is( $actual, $loc,
        "Count $loc of incremental read" );

} ## end for my $loc ( 1 .. $n )

1;    # In case used as "do" file

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: set expandtab shiftwidth=4:
