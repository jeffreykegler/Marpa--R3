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

# The synopsis for the Marpa::R3::Semantics::Rank pod
# Based on an example from Lukas Atkinson
# Here longest is highest rank, as in his original

use 5.010001;

use strict;
use warnings;

use Test::More tests => 8;
use Data::Dumper;
use English qw( -no_match_vars );
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale( LC_ALL, "C" );

use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

my @tests_data = ();
my @results    = ();

# Marpa::R3::Display
# name: Rank document synopsis

my $source = <<'END_OF_SOURCE';
  :discard ~ ws; ws ~ [\s]+
  :default ::= action => ::array
  
  Top ::= List action => main::group
  List ::= Item3 rank => 6
  List ::= Item2 rank => 5
  List ::= Item1 rank => 4
  List ::= List Item3 rank => 3
  List ::= List Item2 rank => 2
  List ::= List Item1 rank => 1
  Item3 ::= VAR '=' VAR rank => 3 action => main::concat
  Item2 ::= VAR '='     rank => 2 action => main::concat
  Item1 ::= VAR         rank => 1 action => main::concat
  VAR ~ [\w]+

END_OF_SOURCE

my @tests = (
    [ 'a',                 '(a)', ],
    [ 'a = b',             '(a=b)', ],
    [ 'a = b = c',         '(a=)(b=c)', ],
    [ 'a = b = c = d',     '(a=)(b=)(c=d)', ],
    [ 'a = b c = d',       '(a=b)(c=d)' ],
    [ 'a = b c = d e =',   '(a=b)(c=d)(e=)' ],
    [ 'a = b c = d e',     '(a=b)(c=d)(e)' ],
    [ 'a = b c = d e = f', '(a=b)(c=d)(e=f)' ],
);

my $grammar = Marpa::R3::Grammar->new(
    { ranking_method => 'high_rule_only', source => \$source } );

for my $test (@tests) {
    my ( $input, $output ) = @{$test};
    my $recce = Marpa::R3::Recognizer->new( { grammar => $grammar } );
    $recce->read( \$input );
    my $value_ref = $recce->value();
    if ( not defined $value_ref ) {
        die 'No parse';
    }
    push @results, ${$value_ref};
}

# Marpa::R3::Display::End

for my $ix ( 0 .. $#tests ) {
    my ( $input, $output ) = @{$tests[$ix]};
    my $result = $results[$ix];
    Test::More::is( $result, $output,
        sprintf( 'Ranking synopsis test #%d: "%s"', $ix, $input ) );
}

# Marpa::R3::Display
# name: rank example semantics

sub flatten {
    my ($array) = @_;

    # say STDERR 'flatten arg: ', Data::Dumper::Dumper($array);
    my $ref = ref $array;
    return [$array] if $ref ne 'ARRAY';
    my @flat = ();
  ELEMENT: for my $element ( @{$array} ) {
        my $ref = ref $element;
        if ( $ref ne 'ARRAY' ) {
            push @flat, $element;
            next ELEMENT;
        }
        my $flat_piece = flatten($element);
        push @flat, @{$flat_piece};
    }
    return \@flat;
}

sub concat {
    my ( $pp, @args ) = @_;

    # say STDERR 'concat: ', Data::Dumper::Dumper(\@args);
    my $flat = flatten( \@args );
    return join '', @{$flat};
}

sub group {
    my ( $pp, @args ) = @_;

    # say STDERR 'comma_sep args: ', Data::Dumper::Dumper(\@args);
    my $flat = flatten( \@args );
    return join '', map { +'(' . $_ . ')'; } @{$flat};
}

# Marpa::R3::Display::End

# vim: expandtab shiftwidth=4:
