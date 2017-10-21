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
use Test::More tests => 11;
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use lib 'inc';
use Marpa::R3::Test;

## no critic (ErrorHandling::RequireCarping);

use Marpa::R3;

sub lo_reader {
    my ( $recce, $start_of_lexeme, $lexeme, $symbol_name, $long_name ) = @_;
    my ($block_id) = $recce->block_progress();
    my $value = $lexeme;
    my $length = length $value;
    my $offset = $start_of_lexeme;

# Marpa::R3::Display
# name: recognizer lexeme_alternative() synopsis

    my $ok = $recce->lexeme_alternative( $symbol_name, $value );
    if (not defined $ok) {
        my $literal = $recce->literal( $block_id, $offset, $length );
        die qq{Parser rejected symbol named "$symbol_name" },
            qq{at position $offset, before lexeme "$literal"};
    }

# Marpa::R3::Display::End

# Marpa::R3::Display
# name: recognizer lexeme_complete() synopsis

    my $new_offset = $recce->lexeme_complete( $block_id, $offset, $length );

# Marpa::R3::Display::End

}

sub hi_block_reader {
    my ( $recce, $start_of_lexeme, $lexeme, $symbol_name, $long_name ) = @_;
    my ($main_block, $offset, $eoread) = $recce->block_progress();
    my $lexeme_length = length $lexeme;
    my $value = $lexeme;

# Marpa::R3::Display
# name: recognizer lexeme_read_block() synopsis

    my $ok = $recce->lexeme_read_block($symbol_name, $value,
        $main_block, $start_of_lexeme, $lexeme_length);
    die qq{Parser rejected token "$long_name" at position $start_of_lexeme, before "},
      $recce->literal( $main_block, $start_of_lexeme, 40 ), q{"}
          if not defined $ok;

# Marpa::R3::Display::End

}

# Marpa::R3::Display
# name: recognizer lexeme_read_block() low-level equivalent
# normalize-whitespace: 1

    sub read_block_equivalent {
	my ( $recce, $symbol_name, $value, $block_id, $offset, $length ) = @_;
        return if not defined $recce->lexeme_alternative( $symbol_name, $value );
        return $recce->lexeme_complete( $block_id, $offset, $length );
    }

# Marpa::R3::Display::End

sub eq_block_reader {
    my ( $recce, $start_of_lexeme, $lexeme, $symbol_name, $long_name ) = @_;
    my ($main_block) = $recce->block_progress();
    my $length = length $lexeme;
    if (
        not defined read_block_equivalent(
            $recce, $symbol_name, $lexeme, $main_block, $start_of_lexeme, $length
        )
      )
    {
        die
qq{Parser rejected token "$long_name" at position $start_of_lexeme, before lexeme "},
          $recce->literal( $main_block, $start_of_lexeme, $length ), q{"};
    }
}

sub lo_literal_reader {
    my ( $recce, $start_of_lexeme, $lexeme, $symbol_name, $long_name ) = @_;
    my ($main_block, $offset, $eoread) = $recce->block_progress();
    my $lexeme_length = length $lexeme;

# Marpa::R3::Display
# name: recognizer lexeme_alternative_literal() synopsis

    my $ok = $recce->lexeme_alternative_literal($symbol_name);
    die qq{Parser rejected token "$long_name" at position $start_of_lexeme, before "},
        $recce->literal( $main_block, $start_of_lexeme, 40 ), q{"}
            if not defined $ok;
    $ok = $recce->lexeme_complete( $main_block, $start_of_lexeme, $lexeme_length);

# Marpa::R3::Display::End

}

sub hi_literal_reader {
    my ( $recce, $start_of_lexeme, $lexeme, $symbol_name, $long_name ) = @_;
    my ($main_block, $offset, $eoread) = $recce->block_progress();
    my $lexeme_length = length $lexeme;

# Marpa::R3::Display
# name: recognizer lexeme_read_literal() synopsis

    my $ok = $recce->lexeme_read_literal($symbol_name, $main_block, $start_of_lexeme, $lexeme_length);
    die qq{Parser rejected token "$long_name" at position $start_of_lexeme, before "},
       $recce->literal( $main_block, $start_of_lexeme, 40 ), q{"}
           if not defined $ok;

# Marpa::R3::Display::End

}

# Marpa::R3::Display
# name: recognizer lexeme_read_literal() low-level equivalent
# normalize-whitespace: 1

    sub read_literal_equivalent_lo {
	my ( $recce, $symbol_name, $block_id, $offset, $length ) = @_;
        return if not defined $recce->lexeme_alternative_literal( $symbol_name );
        return $recce->lexeme_complete( $block_id, $offset, $length );
    }

# Marpa::R3::Display::End

sub eq_literal_reader {
    my ( $recce, $start_of_lexeme, $lexeme, $symbol_name, $long_name ) = @_;
    my ($main_block) = $recce->block_progress();
    my $length = length $lexeme;
    if (
        not defined read_literal_equivalent_lo(
            $recce, $symbol_name, $main_block, $start_of_lexeme, $length
        )
      )
    {
        die
qq{Parser rejected token "$long_name" at position $start_of_lexeme, before lexeme "},
          $recce->literal( $main_block, $start_of_lexeme, $length ), q{"};
    }
}

# Marpa::R3::Display
# name: recognizer lexeme_read_literal() high-level equivalent
# normalize-whitespace: 1

    sub read_literal_equivalent_hi {
	my ( $recce, $symbol_name, $block_id, $offset, $length ) = @_;
	my $value = $recce->literal( $block_id, $offset, $length );
        return $recce->lexeme_read_block( $symbol_name, $value, $block_id, $offset, $length );
    }

# Marpa::R3::Display::End

sub eq2_literal_reader {
    my ( $recce, $start_of_lexeme, $lexeme, $symbol_name, $long_name ) = @_;
    my ($main_block) = $recce->block_progress();
    my $length = length $lexeme;
    if (
        not defined read_literal_equivalent_hi(
            $recce, $symbol_name, $main_block, $start_of_lexeme, $length
        )
      )
    {
        die
qq{Parser rejected token "$long_name" at position $start_of_lexeme, before lexeme "},
          $recce->literal( $main_block, $start_of_lexeme, $length ), q{"};
    }
}

sub hi_string_reader {
    my ( $recce, $start_of_lexeme, $lexeme, $symbol_name, $long_name ) = @_;
    my ($main_block, $offset, $eoread) = $recce->block_progress();

# Marpa::R3::Display
# name: recognizer lexeme_read_string() synopsis

    my $ok = $recce->lexeme_read_string( $symbol_name, $lexeme );
    die qq{Parser rejected token "$long_name" at position $start_of_lexeme, before "},
      $recce->literal( $main_block, $start_of_lexeme, 40 ), q{"}
         if not defined $ok;

# Marpa::R3::Display::End

}

# Marpa::R3::Display
# name: recognizer lexeme_read_string() low-level equivalent
# normalize-whitespace: 1

    sub read_string_equivalent_lo {
        my ($recce, $symbol_name, $string) = @_;
        my ($save_block) = $recce->block_progress();
        my $lexeme_block = $recce->block_new( \$string );
        return if not defined $recce->lexeme_alternative( $symbol_name, $string );
        my $return_value = $recce->lexeme_complete( $lexeme_block );
        $recce->block_set($save_block);
        return $return_value;
    }

# Marpa::R3::Display::End

sub eq_string_reader {
    my ( $recce, $start_of_lexeme, $lexeme, $symbol_name, $long_name ) = @_;
    if ( not defined read_string_equivalent_lo( $recce, $symbol_name, $lexeme ) ) {
        die
qq{Parser rejected token "$long_name" at position $start_of_lexeme, before lexeme "},
          $lexeme;
    }
}

# Marpa::R3::Display
# name: recognizer lexeme_read_string() high-level equivalent
# normalize-whitespace: 1

    sub read_string_equivalent_hi {
	my ( $recce, $symbol_name, $string ) = @_;
        my ($save_block) = $recce->block_progress();
        my $new_block = $recce->block_new( \$string );
        my $return_value = $recce->lexeme_read_literal( $symbol_name, $new_block );
        $recce->block_set($save_block);
        return $return_value;
    }

# Marpa::R3::Display::End

sub eq2_string_reader {
    my ( $recce, $start_of_lexeme, $lexeme, $symbol_name, $long_name ) = @_;
    my ($main_block) = $recce->block_progress();
    my $length = length $lexeme;
    if ( not defined read_string_equivalent_hi( $recce, $symbol_name, $lexeme ) )
    {
        die
qq{Parser rejected token "$long_name" at position $start_of_lexeme, before lexeme "},
          $recce->literal( $main_block, $start_of_lexeme, $length ), q{"};
    }
}

# Marpa::R3::Display
# name: recognizer value() equivalent
# normalize-whitespace: 1

    sub recce_value_equivalent {
        my ($recce, $per_parse_arg) = @_;
        my $valuer = Marpa::R3::Scanless::V->new( { recognizer => $recce } );
        my $ambiguity_level = $valuer->ambiguity_level();
        return if $ambiguity_level == 0;
        if ( $ambiguity_level != 1 ) {
            my $ambiguous_status = $valuer->ambiguous();
            die "Parse of the input is ambiguous\n", $ambiguous_status;
        }
        my $value_ref = $valuer->value($per_parse_arg);
        die '$valuer->value(): No parse', "\n" if not $value_ref;
        return $value_ref;
    }

# Marpa::R3::Display::End

sub eq_valuer {
    my ( $recce ) = @_;
    my $value_ref = recce_value_equivalent( $recce );
    if ( not defined $value_ref ) {
        die "No parse was found, after reading the entire input\n";
    }
    return ${$value_ref};
}

sub hi_valuer {
    my ($recce) = @_;
    my $value_ref = $recce->value();
    if ( not defined $value_ref ) {
        die "No parse was found, after reading the entire input\n";
    }
    return ${$value_ref};
}

{

    my $grammar = Marpa::R3::Scanless::G->new(
        {
            bless_package => 'Calc_Nodes',
            source        => \(<<'END_OF_SOURCE'),
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
        [ Number   => qr/\d+/xms,  "Number" ],
        [ 'op pow' => qr/[\^]/xms, 'Exponentiation operator' ],
        [ 'op pow' => qr/[*][*]/xms, 'Exponentiation' ],    # order matters!
        [ 'op times' => qr/[*]/xms, 'Multiplication operator' ]
        ,                                                   # order matters!
        [ 'op divide'   => qr/[\/]/xms, 'Division operator' ],
        [ 'op add'      => qr/[+]/xms,  'Addition operator' ],
        [ 'op subtract' => qr/[-]/xms,  'Subtraction operator' ],
        [ 'op lparen'   => qr/[(]/xms,  'Left parenthesis' ],
        [ 'op rparen'   => qr/[)]/xms,  'Right parenthesis' ],
        [ 'op comma'    => qr/[,]/xms,  'Comma operator' ],
    );

    sub do_test {
        my ($hash) = @_;
        my $reader = $hash->{reader};
        my $valuer = $hash->{valuer} || \&hi_valuer;
        my $string = '42*2+7/3, 42*(2+7)/3, 2**7-3, 2**(7-3)';
        my $recce = Marpa::R3::Scanless::R->new( { grammar => $grammar } );

# Marpa::R3::Display
# name: recognizer read() synopsis

        $recce->read( \$string, 0, 0 );

# Marpa::R3::Display::End

        my ($main_block) = $recce->block_progress();

        my $length = length $string;
        pos $string = 0;
      TOKEN: while (1) {
            my $start_of_lexeme = pos $string;
            last TOKEN if $start_of_lexeme >= $length;
            next TOKEN if $string =~ m/\G\s+/gcxms;      # skip whitespace
          TOKEN_TYPE: for my $t (@terminals) {
                my ( $symbol_name, $regex, $long_name ) = @{$t};
                my $start_of_lexeme = pos $string;
                next TOKEN_TYPE if not $string =~ m/\G($regex)/gcxms;
                my $lexeme = $1;
                $reader->(
                    $recce, $start_of_lexeme, $lexeme, $symbol_name, $long_name
                );
                $recce->block_move( $start_of_lexeme + length $lexeme );
            }
        } ## end TOKEN: while (1)
        my $value = $valuer->($recce)->doit();
        Test::More::like(
            $value,
            qr/\A 86[.]3\d+ \s+ 126 \s+ 125 \s+ 16\z/xms,
            'Value of parse'
        );
    }
}

do_test( { reader => \&lo_reader } );
do_test( { reader => \&hi_block_reader } );
do_test( { reader => \&eq_block_reader } );
do_test( { reader => \&lo_literal_reader } );
do_test( { reader => \&hi_literal_reader } );
do_test( { reader => \&eq_literal_reader } );
do_test( { reader => \&eq2_literal_reader } );
do_test( { reader => \&hi_string_reader } );
do_test( { reader => \&eq_string_reader } );
do_test( { reader => \&eq2_string_reader } );
do_test( { reader => \&hi_block_reader, valuer => \&eq_valuer } );

sub Calc_Nodes::script::doit {
    my ($self) = @_;
    return join q{ }, map { $_->doit() } @{$self};
}

sub Calc_Nodes::add::doit {
    my ($self) = @_;
    my ( $a, $b ) = @{$self};
    return $a->doit() + $b->doit();
}

sub Calc_Nodes::subtract::doit {
    my ($self) = @_;
    my ( $a, $b ) = @{$self};
    return $a->doit() - $b->doit();
}

sub Calc_Nodes::multiply::doit {
    my ($self) = @_;
    my ( $a, $b ) = @{$self};
    return $a->doit() * $b->doit();
}

sub Calc_Nodes::divide::doit {
    my ($self) = @_;
    my ( $a, $b ) = @{$self};
    return $a->doit() / $b->doit();
}

sub Calc_Nodes::primary::doit { return $_[0]->[0]; }
sub Calc_Nodes::parens::doit  { return $_[0]->[0]->doit(); }

sub Calc_Nodes::power::doit {
    my ($self) = @_;
    my ( $a, $b ) = @{$self};
    return $a->doit()**$b->doit();
}

# vim: expandtab shiftwidth=4:
