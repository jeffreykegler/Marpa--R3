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

# A test using the Dyck-Hollerith language

use 5.010001;

use strict;
use warnings;

use Test::More tests => 1;
use English qw( -no_match_vars );
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;
use Data::Dumper;

my $dsl = <<'END_OF_DSL';
# The BNF
:default ::= action => ::first
:start ::= sentence
sentence ::= element
array ::= 'A' <array count> '(' elements ')'
    action => check_array
string ::= ( 'S' <string length> '(' ) text ( ')' )
elements ::= element+
  action => ::array
element ::= string | array

# Declare the places where we pause before
# and after lexemes
:lexeme ~ <string length> pause => after event => 'string length'
event 'expecting text' = predicted <text>

# Declare the lexemes themselves
<array count> ~ [\d]+
<string length> ~ [\d]+
# define <text> as one character of anything, as a stub
# the external scanner determines its actual size and value
text ~ [\d\D]
END_OF_DSL

my $grammar = Marpa::R3::Scanless::G->new(
    {
        semantics_package => 'My_Actions',
        source            => \$dsl
    }
);
my @events = ();
my $recce = Marpa::R3::Scanless::R->new( { grammar => $grammar,
    event_handlers => {
        "'default" => sub () {
            my ($slr, @event) = @_;
            push @events, \@event;
            'pause';
        }
    }
} );

my $input = 'A2(A2(S3(Hey)S13(Hello, World!))S5(Ciao!))';

my $last_string_length;
my $input_length = length $input;
INPUT:
for (
    my $pos = $recce->read( \$input );
    $pos < $input_length;
    $pos = $recce->resume($pos)
    )
{
    EVENT: for my $event ( @events ) {
        my ($name, @event_data) = @{$event};
        if ( $name eq 'expecting text' ) {
            my $text_length = $last_string_length;
            $recce->lexeme_read( 'text', $pos, $text_length );
            $pos += $text_length;
            next EVENT;
        } ## end if ( $name eq 'expecting text' )
        if ( $name eq 'string length' ) {
            my ( undef, $block_ix, $start_pos, $length ) = @event_data;
            $last_string_length = $recce->literal( $start_pos, $length, $block_ix ) + 0;
            $pos = $start_pos + $length;
            next EVENT;
        } ## end if ( $name eq 'string length' )
        die "Unexpected event: ", join q{ }, @{$event};
    }
    @events = ();
} ## end INPUT: for ( my $pos = $recce->read( \$input ); $pos < $input_length...)

my $result = $recce->value();
die 'No parse' if not defined $result;
my $received = Data::Dumper::Dumper( ${$result} );

my $expected = <<'EXPECTED_OUTPUT';
$VAR1 = [
          [
            'Hey',
            'Hello, World!'
          ],
          'Ciao!'
        ];
EXPECTED_OUTPUT
Test::More::is( $received, $expected , 'Dyck-Hollerith value');

sub My_Actions::check_array {
    my ( undef, $v ) = @_;
    my ( undef, $declared_size, undef, $array ) = @{$v};
    my $actual_size = @{$array};
    warn
        "Array size ($actual_size) does not match that specified ($declared_size)"
        if $declared_size != $actual_size;
    return $array;
} ## end sub check_array

# vim: expandtab shiftwidth=4:
