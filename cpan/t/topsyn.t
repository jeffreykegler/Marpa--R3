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

# Landing page synopsis

use 5.010001;

use strict;
use warnings;
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use Test::More tests => 1;

use lib 'inc';
use Marpa::R3::Test;

## no critic (ErrorHandling::RequireCarping);

# Marpa::R3::Display
# name: Landing page synopsis

use Marpa::R3;

my $dsl = <<'END_OF_DSL';

Calculator ::= Expression action => ::first

Factor ::= Number action => ::first
Term ::=
    Term '*' Factor action => do_multiply
    | Factor action => ::first
Expression ::=
    Expression '+' Term action => do_add
    | Term action => ::first
Number ~ digits
digits ~ [\d]+
:discard ~ whitespace
whitespace ~ [\s]+
END_OF_DSL

my $grammar = Marpa::R3::Scanless::G->new(
    {
        semantics_package => 'My_Actions',
        source            => \$dsl
    }
);
my $input     = '42 * 1 + 7';
my $value_ref = $grammar->parse( \$input );

sub My_Actions::do_add {
    my ( undef, $values ) = @_;
    my ( $t1, undef, $t2 ) = @{$values};
    return $t1 + $t2;
}

sub My_Actions::do_multiply {
    my ( undef, $values ) = @_;
    my ( $t1, undef, $t2 ) = @{$values};
    return $t1 * $t2;
}

# Marpa::R3::Display::End

Test::More::is( ${$value_ref}, 49, 'Landing page synopsis value' );

1;    # In case used as "do" file

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
