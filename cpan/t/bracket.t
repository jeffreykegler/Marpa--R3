#!/usr/bin/env perl
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

# This utility searches for mismatched braces --
# curly, square and round.

use 5.010001;

use strict;
use warnings;
use Marpa::R3;
use Data::Dumper;
use English qw( -no_match_vars );
use Getopt::Long ();
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use Test::More;

sub usage {
    die "Usage: $PROGRAM_NAME < file\n",
        "For testing: $PROGRAM_NAME --test\n";
}

our $TESTING = 1;
my $verbose = 0;
usage()
    if
    not Getopt::Long::GetOptions( verbose => \$verbose, 'test!' => \$TESTING );
usage() if @ARGV;

Test::More::plan tests => 5 if $TESTING;

my $grammar = << '=== GRAMMAR ===';
lexeme default = action => [ name, value ] # to add token names to ast

text ::= pieces
pieces ::= piece*
piece ::= filler | balanced

balanced ::= 
    lparen pieces rparen
  | lcurly pieces rcurly
  | lsquare pieces rsquare

# x5b is left square bracket
# x5d is right square bracket
filler ~ [^(){}\x5B\x5D]+

lparen ~ '('
rparen ~ ')'
lcurly ~ '{'
rcurly ~ '}'
lsquare ~ '['
rsquare ~ ']'

=== GRAMMAR ===

my %literal_match = ();
for my $pair (qw= () [] {} =) {
    my ( $left, $right ) = split //xms, $pair;
    $literal_match{$left}  = $right;
    $literal_match{$right} = $left;
}
my %closing_char_by_name = (
    rcurly  => '}',
    rsquare => ']',
    rparen  => ')',
);

my $g = Marpa::R3::Scanless::G->new(
    {
        source => \($grammar),
        ## Ask Marpa to generate an event on rejection
        rejection => 'event',
    }
);

my @tests = ();

if ($TESTING) {
    @tests = (
        [ 'z}ab)({[]})))(([]))zz',                   '1{ 4( 11( 12(' ],
        [ '9\090]{[][][9]89]8[][]90]{[]\{}{}09[]}[', '5[ 16} 16[ 24[ 39]' ],
        [ '([]([])([]([]',                           '13) 13) 13)' ],
        [ '([([([([',    '8] 8) 8] 8) 8] 8) 8] 8)' ],
        [ '({]-[(}-[{)', '2} 2) 2[ 6) 6] 6{ 10} 10] 10(' ],
    );
    for my $test (@tests) {
        my ( $string, $expected_result ) = @{$test};
        my $fixes = q{};
        test( $g, $string, \$fixes );
        diagnostic( "Input: ", substr( $string, 0, 60 ) ) if $verbose;
        my $description = qq{Result of "} . ( substr $string, 0, 60 ) . q{"};
        Test::More::is( $fixes, $expected_result, $description );
    } ## end for my $test (@tests)
} ## end if ($TESTING)
else {
    local $RS = undef;
    my $input = <>;
    my $actual_result = test( $g, $input );
    if ( not scalar @{$actual_result} ) {
        say '=== All brackets balanced ===';
    }
    else {
        my $divider = "\n" . ( '=' x 20 ) . "\n";
        say join $divider, @{$actual_result};
    }
} ## end else [ if ($TESTING) ]

sub diagnostic {
    if ($TESTING) {
        Test::More::diag(@_);
    }
    else {
        say {*STDERR} @_;
    }
} ## end sub diagnostic

sub marked_line {
    my ( $string, $column1, $column2 ) = @_;
    my $max_line_length = 60;
    $max_line_length = $column1 if $column1 > $max_line_length;
    $max_line_length = $column2
        if defined $column2 and $column2 > $max_line_length;

    # $pos_column is always the last of the two columns
    my $output_line = substr $string, 0, $max_line_length;
    my $nl_pos = index $output_line, "\n";
    $output_line = substr $output_line, 0, $nl_pos;
    my $pointer_line = ( q{ } x $column1 ) . q{^};
    if ( defined $column2 and $column2 > $column1 ) {
        my $further_offset = $column2 - $column1;
        $pointer_line .= ( q{ } x ( $further_offset - 1 ) ) . q{^};
    }
    return join "\n", $output_line, $pointer_line;
} ## end sub marked_line

sub test {
    my ( $g, $string, $fixes ) = @_;
    my @problems = ();
    my @fixes    = ();
    diagnostic( "Input: ", substr( $string, 0, 60 ) ) if $verbose;

    # Record the length of the "real input"
    my $input_length = length $string;

    # state $recce_debug_args = { trace_terminals => 1, trace_values => 1 };
    state $recce_debug_args = {};

    my $rejection_is_fatal = undef;
    my $stalled            = undef;

    my $recce = Marpa::R3::Scanless::R->new(
        {
            grammar        => $g,
            event_handlers => {
                "'rejected" => sub () {
                    die "Rejection at end of string"
                      if $rejection_is_fatal;
                    $stalled = 1;
                    'pause';
                }
            }
        },
        $recce_debug_args
    );

    my $main_block = $recce->block_new( \$string );
    my $pos        = 0;

    my %blk_by_bracket = ();
    for my $char ( keys %literal_match ) {
        $blk_by_bracket{$char} = $recce->block_new( \$char );
    }

    # I define a local closure for each of the main cases.
    # After they are defined, the main loop will call them

    # Local closure to
    # deal with the main case --
    # that where we want to read more input from the
    # main block
    my $main_block_read = sub {
            $rejection_is_fatal = undef;
            $recce->block_set($main_block);
            $recce->block_move( $pos, -1 );
            $recce->block_read();
            $pos = $recce->pos();
            };

    # Local closure to
    # deal with the case of a missing close bracket
    my $missing_close_bracket_handle = sub {
        my ($token_literal) = @_;
        my $token_blk = $blk_by_bracket{$token_literal};
        $rejection_is_fatal = 1;
        $recce->block_set($token_blk);
        $recce->block_move( 0, -1 );
        $recce->block_read();
        $recce->block_set($main_block);

        # We've created a properly bracketed span of the input, using
        # the Ruby Slippers token.  Use Marpa's tables to find its
        # beginning.
        my ($opening_bracket) = $recce->last_completed('balanced');
        my ( $bracket_block, $bracket_l0_pos ) =
          $recce->g1_to_l0_first($opening_bracket);
        my ( $line, $column ) =
          $recce->line_column( $bracket_l0_pos, $bracket_block );
        my $opening_column0 = $bracket_l0_pos - ( $column - 1 );

        my $problem = q{};
        my $pos     = $recce->pos();
        my ( $pos_line, $pos_column ) = $recce->line_column($pos);
        if ( $line == $pos_line ) {

            # Report a missing close bracket for cases contained in
            # a single text line
            $problem = join "\n",
              "* Line $line, column $column: Missing close $token_literal, "
              . "problem detected at line $pos_line, column $pos_column",
              marked_line(
                substr( $string, $pos - ( $pos_column - 1 ) ),
                $column - 1,
                $pos_column - 1
              );
        } ## end if ( $line == $pos_line )
        else {
            # Report a missing close bracket for cases that span
            # two or more text lines
            $problem = join "\n",
                "* Line $line, column $column: No matching bracket for "
              . q{'}
              . $literal_match{$token_literal} . q{', },
              marked_line( substr( $string, $opening_column0 ), $column - 1 ),
              , "*   Problem detected at line $pos_line, column $pos_column:",
              marked_line( substr( $string, $pos - ( $pos_column - 1 ), ),
                $pos_column - 1 );
        } ## end else [ if ( $line == $pos_line ) ]

        # Add our report to the list of problems.
        push @problems, [ $line, $column, $problem ];
        push @fixes, "$pos$token_literal" if $fixes;
        diagnostic(
            "* Line $line, column $column: Missing close $token_literal, ",
            "problem detected at line $pos_line, column $pos_column"
        ) if $verbose;
    };

    # While we have unread input or unclosed brackets ...
  MAIN_LOOP: while (1) {

        # If we're not stalled, just read from the main block
        if ( not $stalled and $pos < $input_length ) {
            $main_block_read->();
            next MAIN_LOOP;
        }
        $stalled = undef;

        # If here we are stalled, or are at end-of-input with unclosed brackets.
        # Either way, first thing we want to know is: are there any unclosed
        # brackets?

        # Find, at random, one of the expected tokens that is a closing bracket.
        # (There should be only one.)
        my ($token_literal) =
          grep { defined }
          map  { $closing_char_by_name{$_} } @{ $recce->terminals_expected() };

        # If there is an unclosed bracket, use Ruby Slippers to close it,
        # report the fix,
        # and start the read loop again.
        if ($token_literal) {
            $missing_close_bracket_handle->($token_literal);
            next MAIN_LOOP;
        }

        # If we are here
        # we have closed all brackets.
        # If we have also read all of the input,
        # then we have finished finished.
        last MAIN_LOOP if $pos >= $input_length;

        # If we are here, we are stalled but not because of a missing
        # close bracket.
        # The only remaining possibility is the opposite issue:
        # an extra close bracket, one which does not match any
        # opening bracket.
        # We will use the Ruby Slippers to insert
        # an open bracket to fix the problem.
        my $nextchar = substr $string, $pos, 1;
        $token_literal = $literal_match{$nextchar};

        # If the next character in input is not an close bracket,
        # something strange has happened.
        # All we can do is abend.
        die "Rejection at pos $pos: ", substr( $string, $pos, 10 )
          if not defined $token_literal;

        my $token_blk = $blk_by_bracket{$token_literal};

        $rejection_is_fatal = 1;
        $recce->block_set($token_blk);
        $recce->block_move( 0, -1 );
        $recce->block_read();
        $recce->block_set($main_block);

        # Used for testing
        push @fixes, "$pos$token_literal" if $fixes;

        # We've done the Ruby Slippers thing, and are ready to
        # continue reading.
        # But first we want to report the error.

        my ( $pos_line, $pos_column ) = $recce->line_column($pos);

        # Report the error if it was a case of a missing open bracket.
        my $problem = join "\n",
          "* Line $pos_line, column $pos_column: Missing open $token_literal",
          marked_line( ( substr $string, $pos - ( $pos_column - 1 ) ),
            $pos_column - 1 );
        push @problems, [ $pos_line, $pos_column, $problem ];
        diagnostic(
            "* Line $pos_line, column $pos_column: Missing open $token_literal"
        ) if $verbose;

    }

    # For testing
    if ( ref $fixes ) {
        ${$fixes} = join " ", @fixes;
    }

    # The problems do not necessarily occur in lexical order.
    # Sort them so that they can be reported that way.
    my @sorted_problems =
      sort { $a->[0] <=> $b->[0] or $a->[1] <=> $b->[1] } @problems;
    my @result = map { $_->[-1] } @sorted_problems;
    return \@result;

} ## end sub test

# vim: expandtab shiftwidth=4:
