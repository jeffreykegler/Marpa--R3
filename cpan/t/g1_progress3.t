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

# Progress report for a trivial grammar

# VALUATOR: TODO

use 5.010001;

use strict;
use warnings;

use Test::More tests => 5;
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

## no critic (Subroutines::RequireArgUnpacking)

sub default_action {
    my (undef, $v) = @_;
    my $v_count = scalar @{$v};
    return q{}   if $v_count <= 0;
    return $v->[0] if $v_count == 1;
    return '(' . ( join q{;}, @{$v}) . ')';
}

## use critic

my $dsl = <<'END_OF_DSL';
:start ::= top
top ::= middle
middle ::= bottom
bottom ::= action => main::default_action
END_OF_DSL

my $grammar = Marpa::R3::Scanless::G->new( {   source => \$dsl });

Marpa::R3::Test::is( $grammar->g1_rules_show(), <<'EOS', 'Aycock/Horspool G1 Rules' );
R0 top ::= middle
R1 middle ::= bottom
R2 bottom ::=
R3 [:start:] ::= top
EOS

Marpa::R3::Test::is( $grammar->g1_symbols_show,
    <<'EOS', 'Aycock/Horspool G1 Symbols' );
g1 S0 [:start:]
g1 S1 bottom
g1 S2 middle
g1 S3 top
EOS

Marpa::R3::Test::is( $grammar->nsys_show(),
    <<'EOS', 'Aycock/Horspool NSYs' );
0: [:start:][], nulling
1: bottom[], nulling
2: middle[], nulling
3: top[], nulling
EOS

# There are no nulling rules in Libmarpa --
# only nulling symbols
Marpa::R3::Test::is( $grammar->nrls_show(),
    <<'EOS', 'Aycock/Horspool NRLs' );
EOS

my $recce = Marpa::R3::Scanless::R->new( {   grammar => $grammar });
# my $input_length = 11;
# my $input = ('a' x $input_length);
# $recce->read( \$input );

sub earley_set_display {
    my ($earley_set) = @_;
    my @items = @{ $recce->g1_progress($earley_set) };
    my @data = ();
    for my $item (@items) {
        my ( $rule_id, $dot, $origin ) = @{$item};
        my $desc .=
            "S:$dot " . '@'
          . "$origin-$earley_set "
          . $grammar->g1_dotted_rule_show( $rule_id, $dot );
        my @datum = ( $origin, $rule_id, $dot, $origin, $desc );
        push @data, \@datum;
    }
    return join "\n", "=== Earley Set $earley_set ===", @data, '';
}

# There are no nulling rules in Libmarpa,
# and no rules means an empty progress report
Marpa::R3::Test::is( earley_set_display(0), <<'EOS', 'Earley Set 0' );
=== Earley Set 0 ===
EOS

# vim: expandtab shiftwidth=4:
