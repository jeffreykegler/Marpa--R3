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

# Test of SLIF external interface

use 5.010001;

use strict;
use warnings;
use Test::More tests => 3;
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use lib 'inc';
use Marpa::R3::Test;

## no critic (ErrorHandling::RequireCarping);

use Marpa::R3;

my $grammar = Marpa::R3::Scanless::G->new(
    {   bless_package => 'My_Nodes',
        source          => \(<<'END_OF_SOURCE'),
:default ::= action => ::array
:start ::= Script
Script ::= Expression+ separator => <op comma> bless => script
Expression ::=
    Number bless => primary
    | (<op lparen>) Expression (<op rparen>) bless => parens assoc => group
   || Expression (<op pow>) Expression bless => power assoc => right
   || Expression (<op times>) Expression bless => multiply
    | Expression (<op divide>) Expression bless => divide
   || Expression (<op add>) Expression bless => add
    | Expression (<op subtract>) Expression bless => subtract

# we don't actually use the SLIF lexer
# This is a placebo lexer that recognizes nothing,
# and discards everything
:discard ~ [\s\S]
Number ~ unicorn
<op comma> ~ unicorn
<op lparen> ~ unicorn
<op rparen> ~ unicorn
<op pow> ~ unicorn
<op times> ~ unicorn
<op divide> ~ unicorn
<op add> ~ unicorn
<op subtract> ~ unicorn
unicorn ~ [^\s\S]
END_OF_SOURCE
    }
);

my @terminals = (
    [ Number   => qr/\d+/xms,    "Number" ],
    [ 'op pow' => qr/[\^]/xms,   'Exponentiation operator' ],
    [ 'op pow' => qr/[*][*]/xms, 'Exponentiation' ],          # order matters!
    [ 'op times' => qr/[*]/xms, 'Multiplication operator' ],  # order matters!
    [ 'op divide'   => qr/[\/]/xms, 'Division operator' ],
    [ 'op add'      => qr/[+]/xms,  'Addition operator' ],
    [ 'op subtract' => qr/[-]/xms,  'Subtraction operator' ],
    [ 'op lparen'   => qr/[(]/xms,  'Left parenthesis' ],
    [ 'op rparen'   => qr/[)]/xms,  'Right parenthesis' ],
    [ 'op comma'    => qr/[,]/xms,  'Comma operator' ],
);

sub lo_literal_reader {
    my ( $recce, $start_of_lexeme, $lexeme, $token_name, $long_name ) = @_;
    my ($main_block, $offset, $eoread) = $recce->block_progress();
    my $lexeme_length = length $lexeme;

# Marpa::R3::Display
# name: SLIF lexeme_alternative_literal() example

    if ( not defined $recce->lexeme_alternative_literal($token_name) ) {
        die
qq{Parser rejected token "$long_name" at position $start_of_lexeme, before "},
          $recce->literal( $main_block, $start_of_lexeme, 40 ), q{"};
    }
    if (
        not $recce->lexeme_complete(
            $main_block, $start_of_lexeme, $lexeme_length
        )
      )
    {
        die qq{No token found at position $start_of_lexeme, before "},
          $recce->literal( $main_block, $start_of_lexeme, 40 ), q{"};
    }

# Marpa::R3::Display::End


}

sub hi_literal_reader {
    my ( $recce, $start_of_lexeme, $lexeme, $token_name, $long_name ) = @_;
    my ($main_block, $offset, $eoread) = $recce->block_progress();
    my $lexeme_length = length $lexeme;

# Marpa::R3::Display
# name: recognizer lexeme_read_literal() synopsis

    if ( not defined $recce->lexeme_read_literal($token_name, $main_block, $start_of_lexeme, $lexeme_length) ) {
        die
qq{Parser rejected token "$long_name" at position $start_of_lexeme, before "},
          $recce->literal( $main_block, $start_of_lexeme, 40 ), q{"};
    }

# Marpa::R3::Display::End


}

sub hi_read_reader {
    my ( $recce, $start_of_lexeme, $lexeme, $token_name, $long_name ) = @_;
    my ($main_block, $offset, $eoread) = $recce->block_progress();

# Marpa::R3::Display
# name: recognizer lexeme_read_string() synopsis

    if ( not defined $recce->lexeme_read_string($token_name, $lexeme )) {
        die
qq{Parser rejected token "$long_name" at position $start_of_lexeme, before "},
          $recce->literal( $main_block, $start_of_lexeme, 40 ), q{"};
    }

# Marpa::R3::Display::End

}

sub my_parser {
    my ( $grammar, $reader, $string ) = @_;
    my $recce = Marpa::R3::Scanless::R->new( { grammar => $grammar } );

# Marpa::R3::Display
# name: SLIF external read example

    $recce->read( \$string, 0, 0 );

# Marpa::R3::Display::End

    my ($main_block) = $recce->block_progress();

    my $length = length $string;
    pos $string = 0;
    TOKEN: while (1) {
        my $start_of_lexeme = pos $string;
        last TOKEN if $start_of_lexeme >= $length;
        next TOKEN if $string =~ m/\G\s+/gcxms;    # skip whitespace
        TOKEN_TYPE: for my $t (@terminals) {
            my ( $token_name, $regex, $long_name ) = @{$t};
            my $start_of_lexeme = pos $string;
            next TOKEN_TYPE if not $string =~ m/\G($regex)/gcxms;
            my $lexeme = $1;
            $reader-> ( $recce, $start_of_lexeme, $lexeme, $token_name, $long_name );
            $recce->block_move($start_of_lexeme + length $lexeme);
        }
    } ## end TOKEN: while (1)
    my $value_ref = $recce->value();
    if ( not defined $value_ref ) {
        die "No parse was found, after reading the entire input\n";
    }
    return ${$value_ref}->doit();
}

my $value = my_parser( $grammar, \&lo_literal_reader, '42*2+7/3, 42*(2+7)/3, 2**7-3, 2**(7-3)' );
Test::More::like( $value, qr/\A 86[.]3\d+ \s+ 126 \s+ 125 \s+ 16\z/xms, 'Value of parse' );
$value = my_parser( $grammar, \&hi_literal_reader, '42*2+7/3, 42*(2+7)/3, 2**7-3, 2**(7-3)' );
Test::More::like( $value, qr/\A 86[.]3\d+ \s+ 126 \s+ 125 \s+ 16\z/xms, 'Value of parse' );
$value = my_parser( $grammar, \&hi_read_reader, '42*2+7/3, 42*(2+7)/3, 2**7-3, 2**(7-3)' );
Test::More::like( $value, qr/\A 86[.]3\d+ \s+ 126 \s+ 125 \s+ 16\z/xms, 'Value of parse' );

sub My_Nodes::script::doit {
    my ($self) = @_;
    return join q{ }, map { $_->doit() } @{$self};
}

sub My_Nodes::add::doit {
    my ($self) = @_;
    my ( $a, $b ) = @{$self};
    return $a->doit() + $b->doit();
}

sub My_Nodes::subtract::doit {
    my ($self) = @_;
    my ( $a, $b ) = @{$self};
    return $a->doit() - $b->doit();
}

sub My_Nodes::multiply::doit {
    my ($self) = @_;
    my ( $a, $b ) = @{$self};
    return $a->doit() * $b->doit();
}

sub My_Nodes::divide::doit {
    my ($self) = @_;
    my ( $a, $b ) = @{$self};
    return $a->doit() / $b->doit();
}

sub My_Nodes::primary::doit { return $_[0]->[0]; }
sub My_Nodes::parens::doit  { return $_[0]->[0]->doit(); }

sub My_Nodes::power::doit {
    my ($self) = @_;
    my ( $a, $b ) = @{$self};
    return $a->doit()**$b->doit();
}

# vim: expandtab shiftwidth=4:
