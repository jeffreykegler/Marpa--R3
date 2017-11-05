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

# Test of null ranking

use 5.010001;

use strict;
use warnings;

use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use Test::More tests => 10;
use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

## no critic (Subroutines::RequireArgUnpacking)

sub default_action {
    my (undef, $values) = @_;
    my $v_count = scalar @{$values};
    return q{} if $v_count == 0;
    return $values->[0] if $v_count == 1;
    return '(' . join( q{;}, @{$values} ) . ')';
} ## end sub default_action

## use critic

# Marpa::R3::Display
# name: null-ranking adverb example

my $high_dsl = <<'END_OF_DSL';
:default ::= action => main::default_action
:start ::= S
A ::= 'a'
A ::= empty
empty ::=
S ::= A A A A null-ranking => high
END_OF_DSL

# Marpa::R3::Display::End

my $low_dsl = $high_dsl;
$low_dsl =~ s/\s+ [=][>] \s+ high \Z/ => low/xms;
my %dsl = ( high => \$high_dsl, low => \$low_dsl );

my @maximal = ( q{}, qw[(a;;;) (a;a;;) (a;a;a;) (a;a;a;a)] );
my @minimal = ( q{}, qw[(;;;a) (;;a;a) (;a;a;a) (a;a;a;a)] );

for my $maximal ( 0, 1 ) {
    my $dsl = $dsl{ $maximal ? 'low' : 'high' };
    my $grammar = Marpa::R3::Grammar->new(
        { ranking_method => 'high_rule_only', source => $dsl } );
    my $recce = Marpa::R3::Recognizer->new( { grammar => $grammar } );

    my $input_length = 4;
    my $input        = 'a' x $input_length;
    $recce->read( \$input );

    # Silence message when trace_terminals is turned on

# Marpa::R3::Display
# name: recognizer set() synopsis

    my $trace_fh;
    $recce->set( { trace_file_handle => $trace_fh } );

# Marpa::R3::Display::End

    $recce->set( { trace_file_handle => \*STDERR } );

    for my $i ( 0 .. $input_length ) {
        my $expected = $maximal ? \@maximal : \@minimal;
        my $name     = $maximal ? 'maximal' : 'minimal';

        my $valuer = Marpa::R3::Scanless::V->new(
            {
                recognizer => $recce,
                end        => $i,
                max_parses => 42
            }
        );
        my $result = $valuer->value();
        die "No parse" if not defined $result;
        Test::More::is( ${$result}, $expected->[$i], "$name parse, length=$i" );
    } ## end for my $i ( 0 .. $input_length )

}

1;    # In case used as "do" file

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
