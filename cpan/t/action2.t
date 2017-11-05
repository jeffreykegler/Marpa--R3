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

# This was a
# test of scalar actions, now elimnated.
# All that remains is the test for the elimination 
# of side effects in the constructor
# Perhaps I should eliminate this test entirely?

use 5.010001;

use strict;
use warnings;

use Test::More tests => 2;

use English qw( -no_match_vars );
use Fatal qw( open close );
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

my $side_effect = 0;

no warnings 'once';
sub My_Actions::new { $side_effect = 42; }

sub My_Actions::join_contents {
    my ($ppo, $child) = @_;
    my @elements = map { $_->[0] } @{$child};
    return join '', @elements;
}

my $grammar = Marpa::R3::Grammar->new(
    {
        semantics_package => 'My_Actions',
        source            => \<<'END_OF_SOURCE',
:default ::= action => ::array
:start ::= S
S ::= <array ref>  <hash ref>  <ref ref>  <code ref>
    <code ref ref> <code> <scalar> 
    <scalar2> <array ref 2> <code ref 2>
    action => join_contents
<array ref> ::= 'a'
<hash ref> ::= 'a'
<ref ref>  ::= 'a'
<code ref>  ::= 'a'
<code ref ref>  ::= 'a'
<code>  ::= 'a'
<scalar>  ::= 'a'
<scalar2>  ::= 'a'
<array ref 2>  ::= 'a'
<code ref 2>  ::= 'a'
END_OF_SOURCE
    }
);

sub do_parse {
    my $slr = Marpa::R3::Scanless::R->new( { grammar => $grammar } );
    $slr->read( \'aaaaaaaaaa' );
    return $slr->value();
} ## end sub do_parse

my $value_ref = do_parse();
my $value = $value_ref ? ${$value_ref} : 'No parse';
Test::More::is($value, 'aaaaaaaaaa', 'Result');
Test::More::is($side_effect, 0, 'semantics_package constructor elminated');

# vim: expandtab shiftwidth=4:
