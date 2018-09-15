#!/usr/bin/perl
# Marpa::R3 is Copyright (C) 2018, Jeffrey Kegler.
#
# This module is free software; you can redistribute it and/or modify it
# under the same terms as Perl 5.10.1. For more details, see the full text
# of the licenses in the directory LICENSES.
#
# This program is distributed in the hope that it will be
# useful, but it is provided "as is" and without any express
# or implied warranties. For details, see the full text of
# of the licenses in the directory LICENSES.

# Test displays for variable-length lexemes

use 5.010001;

use strict;
use warnings;
use Test::More tests => 4;
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale( LC_ALL, "C" );

use lib 'inc';
use Marpa::R3::Test;

## no critic (ErrorHandling::RequireCarping);

use Marpa::R3;

my $grammar = Marpa::R3::Grammar->new(
    {
        source => \(<<'END_OF_SOURCE'),
:default ::= action => ::array
As ::= A+

# we don't actually use the SLIF lexer
# This is a placebo lexer that recognizes nothing,
# and discards everything
:discard ~ [\s\S]
A ~ unicorn
unicorn ~ [^\s\S]
END_OF_SOURCE
    }
);

my $recce = Marpa::R3::Recognizer->new( { grammar => $grammar } );

my $string   = 'aaaaa';
$recce->read( \$string, 0, 0 );

my $ok;

# Marpa::R3::Display
# name: recognizer lexeme_alternative() variable length synopsis

$ok = $recce->lexeme_alternative( 'A', 42, 2 );

# Marpa::R3::Display::End

$recce->lexeme_complete( undef, undef, 2 );

# Marpa::R3::Display
# name: recognizer latest_earleme() synopsis

my $latest_earleme = $recce->latest_earleme();

# Marpa::R3::Display::End

my $latest_earleme_direct = $latest_earleme;

# Marpa::R3::Display
# name: recognizer earleme() synopsis

my $latest_earley_set = $recce->g1_pos();
$latest_earleme = $recce->earleme($latest_earley_set);

# Marpa::R3::Display::End

Test::More::is ($latest_earleme, 2, "latest earleme via earleme()");
Test::More::is ($latest_earleme_direct, 2,
		"latest earleme via latest_earleme()");

#Marpa::R3::Display
#name: recognizer lexeme_alternative_literal() variable length synopsis

$ok = $recce->lexeme_alternative_literal ('A', 3);

#Marpa::R3::Display::End

# Marpa::R3::Display
# name: recognizer furthest_earleme() synopsis

my $furthest_earleme = $recce->furthest_earleme();

# Marpa::R3::Display::End

Test::More::is($furthest_earleme, 5, "furthest earleme");

$recce->lexeme_complete (undef, undef, 3);

local $Data::Dumper::Terse = 1;
#don't output names where feasible
local $Data::Dumper::Indent = 0;
#turn off all pretty print

my $value_ref = $recce->value ();
my $value = Data::Dumper::Dumper ($value_ref);

my $expected = '\\[42,\'aaa\']';
Test::More::is_deeply ($value, $expected, "parse value");

#vim: expandtab shiftwidth=4:
