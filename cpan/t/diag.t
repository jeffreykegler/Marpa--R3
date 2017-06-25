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

# Test of scannerless parsing -- diagnostics

use 5.010001;
use strict;
use warnings;

use Test::More tests => 10;
use English qw( -no_match_vars );
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

my $dsl = <<'END_OF_RULES';
:default ::= action => My_Actions::do_arg0
:start ::= Script
Script ::= Calculation* action => do_list
Calculation ::= Expression | ('say') Expression
Expression ::=
     Number
   | ('+') Expression Expression action => do_add
Number ~ [\d] +
:discard ~ whitespace
whitespace ~ [\s]+
# allow comments
:discard ~ <hash comment>
<hash comment> ~ <terminated hash comment> | <unterminated
   final hash comment>
<terminated hash comment> ~ '#' <hash comment body> <vertical space char>
<unterminated final hash comment> ~ '#' <hash comment body>
<hash comment body> ~ <hash comment char>*
<vertical space char> ~ [\x{A}\x{B}\x{C}\x{D}\x{2028}\x{2029}]
<hash comment char> ~ [^\x{A}\x{B}\x{C}\x{D}\x{2028}\x{2029}]
END_OF_RULES

my $grammar = Marpa::R3::Scanless::G->new(
    { semantics_package => 'My_Actions', source => \$dsl, } );

package My_Actions;
# The SELF object is a very awkward way of specifying the per-parse
# argument directly, one which was necessary before the $recce->value()
# method took an argument.
# This way of doing things is discourage and preserved here for testing purposes.
our $SELF;
sub new { return $SELF }

sub do_list {
    my ( $self, $v ) = @_;
    my @results = @{$v};
    return +( scalar @results ) . ' results: ' . join q{ }, @results;
}

sub do_add  { return $_[1]->[0] + $_[1]->[1] }
sub do_arg0 { return $_[1]->[0] }

sub show_last_expression {
    my ($self) = @_;
    my $recce = $self->{recce};
    my ( $start, $length ) = $recce->last_completed('Expression');
    return if not defined $start;
    my $last_expression = $recce->g1_literal( $start, $length );
    return $last_expression;
} ## end sub show_last_expression

package main;

sub my_parser {
    my ( $grammar, $string ) = @_;

    my $self = bless { grammar => $grammar }, 'My_Actions';
    local $My_Actions::SELF = $self;

    my $trace_output = q{};
    open my $trace_fh, q{>}, \$trace_output;
    my $recce = Marpa::R3::Scanless::R->new(
        {   grammar               => $grammar,
            trace_terminals       => 3,
            trace_file_handle     => $trace_fh,
            too_many_earley_items => 100,         # test this
        }
    );
    $self->{recce} = $recce;
    my ( $parse_value, $parse_status, $last_expression );

    my $eval_ok = eval { $recce->read( \$string ); 1 };
    close $trace_fh;

    if ( not defined $eval_ok ) {
        my $abbreviated_error = $EVAL_ERROR;
        chomp $abbreviated_error;
        $abbreviated_error =~ s/\n.*//xms;
        die $self->show_last_expression(), $EVAL_ERROR;
    } ## end if ( not defined $eval_ok )
    my $value_ref = $recce->value;
    if ( not defined $value_ref ) {
        die join q{ },
            'Input read to end but no parse',
            $self->show_last_expression();
    }
    return $recce, ${$value_ref}, $trace_output;
} ## end sub my_parser

my @tests_data = (
    [ '+++ 1 2 3 + + 1 2 4', '1 results: 13', 'Parse OK', 'entire input' ],
);

TEST:
for my $test_data (@tests_data) {
    my ($test_string,     $expected_value,
        $expected_result, $expected_last_expression
    ) = @{$test_data};
    my ( $recce, $actual_value, $trace_output ) =
        my_parser( $grammar, $test_string );

# Marpa::R3::Display
# name: Scanless terminals_expected() synopsis

    my @terminals_expected = @{$recce->terminals_expected()};

# Marpa::R3::Display::End

    Marpa::R3::Test::is(
        ( join q{ }, sort @terminals_expected ),
        'Number [Lex-0] [Lex-1]',
        qq{SLIF terminals_expected()}
    );

# Marpa::R3::Display
# name: Scanless g1_show_progress() synopsis

    my $g1_show_progress_output = $recce->g1_show_progress();

# Marpa::R3::Display::End

    Marpa::R3::Test::is( $g1_show_progress_output,
        <<'END_OF_EXPECTED_OUTPUT', qq{Scanless show_progess()} );
F0 @0-11 B1L1c1-19 Script -> Calculation * .
P1 @11-11 B1L1c20 Calculation -> . Expression
F1 @0-11 B1L1c1-19 Calculation -> Expression .
P2 @11-11 B1L1c20 Calculation -> . 'say' Expression
P3 @11-11 B1L1c20 Expression -> . Number
F3 @10-11 B1L1c19 Expression -> Number .
P4 @11-11 B1L1c20 Expression -> . '+' Expression Expression
F4 x2 @0,6-11 B1L1c1-19 Expression -> '+' Expression Expression .
F5 @0-11 B1L1c1-19 [:start:] -> Script .
END_OF_EXPECTED_OUTPUT

    Marpa::R3::Test::is( $actual_value, $expected_value,
        qq{Value of "$test_string"} );
    Marpa::R3::Test::is( $trace_output,
        <<'END_OF_OUTPUT', qq{Trace output for "$test_string"} );
Setting trace_terminals option
Expecting "Number" at earleme 0
Expecting "[Lex-0]" at earleme 0
Expecting "[Lex-1]" at earleme 0
Registering character U+002b "+" as symbol 5: [\+]
Registering character U+002b "+" as symbol 9: [^\x{A}\x{B}\x{C}\x{D}\x{2028}\x{2029}]
Registering character U+0020 " " as symbol 7: [\s]
Registering character U+0020 " " as symbol 9: [^\x{A}\x{B}\x{C}\x{D}\x{2028}\x{2029}]
Registering character U+0031 "1" as symbol 6: [\d]
Registering character U+0031 "1" as symbol 9: [^\x{A}\x{B}\x{C}\x{D}\x{2028}\x{2029}]
Registering character U+0032 "2" as symbol 6: [\d]
Registering character U+0032 "2" as symbol 9: [^\x{A}\x{B}\x{C}\x{D}\x{2028}\x{2029}]
Registering character U+0033 "3" as symbol 6: [\d]
Registering character U+0033 "3" as symbol 9: [^\x{A}\x{B}\x{C}\x{D}\x{2028}\x{2029}]
Registering character U+0034 "4" as symbol 6: [\d]
Registering character U+0034 "4" as symbol 9: [^\x{A}\x{B}\x{C}\x{D}\x{2028}\x{2029}]
Restarted recognizer at B1L1c1
Expected lexeme Number at B1L1c1; assertion ID = 0
Expected lexeme 'say' at B1L1c1; assertion ID = 1
Expected lexeme '+' at B1L1c1; assertion ID = 2
Reading codepoint "+" 0x002b at B1L1c1
Codepoint "+" 0x002b accepted as [\+] at B1L1c1
Codepoint "+" 0x002b rejected as [^\x{A}\x{B}\x{C}\x{D}\x{2028}\x{2029}] at B1L1c1
Attempting to read lexeme B1L1c1 e1: '+'; value="+"
Accepted lexeme B1L1c1 e1: '+'; value="+"
Restarted recognizer at B1L1c2
Expected lexeme Number at B1L1c2; assertion ID = 0
Expected lexeme '+' at B1L1c2; assertion ID = 2
Reading codepoint "+" 0x002b at B1L1c2
Codepoint "+" 0x002b accepted as [\+] at B1L1c2
Codepoint "+" 0x002b rejected as [^\x{A}\x{B}\x{C}\x{D}\x{2028}\x{2029}] at B1L1c2
Attempting to read lexeme B1L1c2 e2: '+'; value="+"
Accepted lexeme B1L1c2 e2: '+'; value="+"
Restarted recognizer at B1L1c3
Expected lexeme Number at B1L1c3; assertion ID = 0
Expected lexeme '+' at B1L1c3; assertion ID = 2
Reading codepoint "+" 0x002b at B1L1c3
Codepoint "+" 0x002b accepted as [\+] at B1L1c3
Codepoint "+" 0x002b rejected as [^\x{A}\x{B}\x{C}\x{D}\x{2028}\x{2029}] at B1L1c3
Attempting to read lexeme B1L1c3 e3: '+'; value="+"
Accepted lexeme B1L1c3 e3: '+'; value="+"
Restarted recognizer at B1L1c4
Expected lexeme Number at B1L1c4; assertion ID = 0
Expected lexeme '+' at B1L1c4; assertion ID = 2
Reading codepoint " " 0x0020 at B1L1c4
Codepoint " " 0x0020 accepted as [\s] at B1L1c4
Codepoint " " 0x0020 rejected as [^\x{A}\x{B}\x{C}\x{D}\x{2028}\x{2029}] at B1L1c4
Reading codepoint "1" 0x0031 at B1L1c5
Codepoint "1" 0x0031 rejected as [\d] at B1L1c5
Codepoint "1" 0x0031 rejected as [^\x{A}\x{B}\x{C}\x{D}\x{2028}\x{2029}] at B1L1c5
Discarded lexeme B1L1c4: whitespace
Restarted recognizer at B1L1c5
Expected lexeme Number at B1L1c5; assertion ID = 0
Expected lexeme '+' at B1L1c5; assertion ID = 2
Reading codepoint "1" 0x0031 at B1L1c5
Codepoint "1" 0x0031 accepted as [\d] at B1L1c5
Codepoint "1" 0x0031 rejected as [^\x{A}\x{B}\x{C}\x{D}\x{2028}\x{2029}] at B1L1c5
Reading codepoint " " 0x0020 at B1L1c6
Codepoint " " 0x0020 rejected as [\s] at B1L1c6
Codepoint " " 0x0020 rejected as [^\x{A}\x{B}\x{C}\x{D}\x{2028}\x{2029}] at B1L1c6
Attempting to read lexeme B1L1c5 e4: Number; value="1"
Accepted lexeme B1L1c5 e4: Number; value="1"
Restarted recognizer at B1L1c6
Expected lexeme Number at B1L1c6; assertion ID = 0
Expected lexeme '+' at B1L1c6; assertion ID = 2
Reading codepoint " " 0x0020 at B1L1c6
Codepoint " " 0x0020 accepted as [\s] at B1L1c6
Codepoint " " 0x0020 rejected as [^\x{A}\x{B}\x{C}\x{D}\x{2028}\x{2029}] at B1L1c6
Reading codepoint "2" 0x0032 at B1L1c7
Codepoint "2" 0x0032 rejected as [\d] at B1L1c7
Codepoint "2" 0x0032 rejected as [^\x{A}\x{B}\x{C}\x{D}\x{2028}\x{2029}] at B1L1c7
Discarded lexeme B1L1c6: whitespace
Restarted recognizer at B1L1c7
Expected lexeme Number at B1L1c7; assertion ID = 0
Expected lexeme '+' at B1L1c7; assertion ID = 2
Reading codepoint "2" 0x0032 at B1L1c7
Codepoint "2" 0x0032 accepted as [\d] at B1L1c7
Codepoint "2" 0x0032 rejected as [^\x{A}\x{B}\x{C}\x{D}\x{2028}\x{2029}] at B1L1c7
Reading codepoint " " 0x0020 at B1L1c8
Codepoint " " 0x0020 rejected as [\s] at B1L1c8
Codepoint " " 0x0020 rejected as [^\x{A}\x{B}\x{C}\x{D}\x{2028}\x{2029}] at B1L1c8
Attempting to read lexeme B1L1c7 e5: Number; value="2"
Accepted lexeme B1L1c7 e5: Number; value="2"
Restarted recognizer at B1L1c8
Expected lexeme Number at B1L1c8; assertion ID = 0
Expected lexeme '+' at B1L1c8; assertion ID = 2
Reading codepoint " " 0x0020 at B1L1c8
Codepoint " " 0x0020 accepted as [\s] at B1L1c8
Codepoint " " 0x0020 rejected as [^\x{A}\x{B}\x{C}\x{D}\x{2028}\x{2029}] at B1L1c8
Reading codepoint "3" 0x0033 at B1L1c9
Codepoint "3" 0x0033 rejected as [\d] at B1L1c9
Codepoint "3" 0x0033 rejected as [^\x{A}\x{B}\x{C}\x{D}\x{2028}\x{2029}] at B1L1c9
Discarded lexeme B1L1c8: whitespace
Restarted recognizer at B1L1c9
Expected lexeme Number at B1L1c9; assertion ID = 0
Expected lexeme '+' at B1L1c9; assertion ID = 2
Reading codepoint "3" 0x0033 at B1L1c9
Codepoint "3" 0x0033 accepted as [\d] at B1L1c9
Codepoint "3" 0x0033 rejected as [^\x{A}\x{B}\x{C}\x{D}\x{2028}\x{2029}] at B1L1c9
Reading codepoint " " 0x0020 at B1L1c10
Codepoint " " 0x0020 rejected as [\s] at B1L1c10
Codepoint " " 0x0020 rejected as [^\x{A}\x{B}\x{C}\x{D}\x{2028}\x{2029}] at B1L1c10
Attempting to read lexeme B1L1c9 e6: Number; value="3"
Accepted lexeme B1L1c9 e6: Number; value="3"
Restarted recognizer at B1L1c10
Expected lexeme Number at B1L1c10; assertion ID = 0
Expected lexeme '+' at B1L1c10; assertion ID = 2
Reading codepoint " " 0x0020 at B1L1c10
Codepoint " " 0x0020 accepted as [\s] at B1L1c10
Codepoint " " 0x0020 rejected as [^\x{A}\x{B}\x{C}\x{D}\x{2028}\x{2029}] at B1L1c10
Reading codepoint "+" 0x002b at B1L1c11
Codepoint "+" 0x002b rejected as [\+] at B1L1c11
Codepoint "+" 0x002b rejected as [^\x{A}\x{B}\x{C}\x{D}\x{2028}\x{2029}] at B1L1c11
Discarded lexeme B1L1c10: whitespace
Restarted recognizer at B1L1c11
Expected lexeme Number at B1L1c11; assertion ID = 0
Expected lexeme '+' at B1L1c11; assertion ID = 2
Reading codepoint "+" 0x002b at B1L1c11
Codepoint "+" 0x002b accepted as [\+] at B1L1c11
Codepoint "+" 0x002b rejected as [^\x{A}\x{B}\x{C}\x{D}\x{2028}\x{2029}] at B1L1c11
Attempting to read lexeme B1L1c11 e7: '+'; value="+"
Accepted lexeme B1L1c11 e7: '+'; value="+"
Restarted recognizer at B1L1c12
Expected lexeme Number at B1L1c12; assertion ID = 0
Expected lexeme '+' at B1L1c12; assertion ID = 2
Reading codepoint " " 0x0020 at B1L1c12
Codepoint " " 0x0020 accepted as [\s] at B1L1c12
Codepoint " " 0x0020 rejected as [^\x{A}\x{B}\x{C}\x{D}\x{2028}\x{2029}] at B1L1c12
Reading codepoint "+" 0x002b at B1L1c13
Codepoint "+" 0x002b rejected as [\+] at B1L1c13
Codepoint "+" 0x002b rejected as [^\x{A}\x{B}\x{C}\x{D}\x{2028}\x{2029}] at B1L1c13
Discarded lexeme B1L1c12: whitespace
Restarted recognizer at B1L1c13
Expected lexeme Number at B1L1c13; assertion ID = 0
Expected lexeme '+' at B1L1c13; assertion ID = 2
Reading codepoint "+" 0x002b at B1L1c13
Codepoint "+" 0x002b accepted as [\+] at B1L1c13
Codepoint "+" 0x002b rejected as [^\x{A}\x{B}\x{C}\x{D}\x{2028}\x{2029}] at B1L1c13
Attempting to read lexeme B1L1c13 e8: '+'; value="+"
Accepted lexeme B1L1c13 e8: '+'; value="+"
Restarted recognizer at B1L1c14
Expected lexeme Number at B1L1c14; assertion ID = 0
Expected lexeme '+' at B1L1c14; assertion ID = 2
Reading codepoint " " 0x0020 at B1L1c14
Codepoint " " 0x0020 accepted as [\s] at B1L1c14
Codepoint " " 0x0020 rejected as [^\x{A}\x{B}\x{C}\x{D}\x{2028}\x{2029}] at B1L1c14
Reading codepoint "1" 0x0031 at B1L1c15
Codepoint "1" 0x0031 rejected as [\d] at B1L1c15
Codepoint "1" 0x0031 rejected as [^\x{A}\x{B}\x{C}\x{D}\x{2028}\x{2029}] at B1L1c15
Discarded lexeme B1L1c14: whitespace
Restarted recognizer at B1L1c15
Expected lexeme Number at B1L1c15; assertion ID = 0
Expected lexeme '+' at B1L1c15; assertion ID = 2
Reading codepoint "1" 0x0031 at B1L1c15
Codepoint "1" 0x0031 accepted as [\d] at B1L1c15
Codepoint "1" 0x0031 rejected as [^\x{A}\x{B}\x{C}\x{D}\x{2028}\x{2029}] at B1L1c15
Reading codepoint " " 0x0020 at B1L1c16
Codepoint " " 0x0020 rejected as [\s] at B1L1c16
Codepoint " " 0x0020 rejected as [^\x{A}\x{B}\x{C}\x{D}\x{2028}\x{2029}] at B1L1c16
Attempting to read lexeme B1L1c15 e9: Number; value="1"
Accepted lexeme B1L1c15 e9: Number; value="1"
Restarted recognizer at B1L1c16
Expected lexeme Number at B1L1c16; assertion ID = 0
Expected lexeme '+' at B1L1c16; assertion ID = 2
Reading codepoint " " 0x0020 at B1L1c16
Codepoint " " 0x0020 accepted as [\s] at B1L1c16
Codepoint " " 0x0020 rejected as [^\x{A}\x{B}\x{C}\x{D}\x{2028}\x{2029}] at B1L1c16
Reading codepoint "2" 0x0032 at B1L1c17
Codepoint "2" 0x0032 rejected as [\d] at B1L1c17
Codepoint "2" 0x0032 rejected as [^\x{A}\x{B}\x{C}\x{D}\x{2028}\x{2029}] at B1L1c17
Discarded lexeme B1L1c16: whitespace
Restarted recognizer at B1L1c17
Expected lexeme Number at B1L1c17; assertion ID = 0
Expected lexeme '+' at B1L1c17; assertion ID = 2
Reading codepoint "2" 0x0032 at B1L1c17
Codepoint "2" 0x0032 accepted as [\d] at B1L1c17
Codepoint "2" 0x0032 rejected as [^\x{A}\x{B}\x{C}\x{D}\x{2028}\x{2029}] at B1L1c17
Reading codepoint " " 0x0020 at B1L1c18
Codepoint " " 0x0020 rejected as [\s] at B1L1c18
Codepoint " " 0x0020 rejected as [^\x{A}\x{B}\x{C}\x{D}\x{2028}\x{2029}] at B1L1c18
Attempting to read lexeme B1L1c17 e10: Number; value="2"
Accepted lexeme B1L1c17 e10: Number; value="2"
Restarted recognizer at B1L1c18
Expected lexeme Number at B1L1c18; assertion ID = 0
Expected lexeme '+' at B1L1c18; assertion ID = 2
Reading codepoint " " 0x0020 at B1L1c18
Codepoint " " 0x0020 accepted as [\s] at B1L1c18
Codepoint " " 0x0020 rejected as [^\x{A}\x{B}\x{C}\x{D}\x{2028}\x{2029}] at B1L1c18
Reading codepoint "4" 0x0034 at B1L1c19
Codepoint "4" 0x0034 rejected as [\d] at B1L1c19
Codepoint "4" 0x0034 rejected as [^\x{A}\x{B}\x{C}\x{D}\x{2028}\x{2029}] at B1L1c19
Discarded lexeme B1L1c18: whitespace
Restarted recognizer at B1L1c19
Expected lexeme Number at B1L1c19; assertion ID = 0
Expected lexeme '+' at B1L1c19; assertion ID = 2
Reading codepoint "4" 0x0034 at B1L1c19
Codepoint "4" 0x0034 accepted as [\d] at B1L1c19
Codepoint "4" 0x0034 rejected as [^\x{A}\x{B}\x{C}\x{D}\x{2028}\x{2029}] at B1L1c19
Attempting to read lexeme B1L1c19 e11: Number; value="4"
Accepted lexeme B1L1c19 e11: Number; value="4"
END_OF_OUTPUT

    my $expected_progress_output = [
        [ 0, -1, 0 ],
        [ 1, -1, 0 ],
        [ 3, -1, 10 ],
        [ 4, -1, 0 ],
        [ 4, -1, 6 ],
        [ 5, -1, 0 ],
        [ 1, 0,  11 ],
        [ 2, 0,  11 ],
        [ 3, 0,  11 ],
        [ 4, 0,  11 ],
    ];

# Marpa::R3::Display
# name: Scanless progress() synopsis

    my $progress_output = $recce->g1_progress();

# Marpa::R3::Display::End

    Marpa::R3::Test::is(
        Data::Dumper::Dumper($progress_output),
        Data::Dumper::Dumper($expected_progress_output),
        qq{Scanless progress()}
    );

# Marpa::R3::Display
# name: Scanless g1_pos() synopsis

    my $g1_pos = $recce->g1_pos();

# Marpa::R3::Display::End

    Test::More::is( $g1_pos, 11, qq{Scanless g1_pos()} );

# Marpa::R3::Display
# name: SLIF pos() example

    my $pos = $recce->pos();

# Marpa::R3::Display::End

    Test::More::is( $pos, 19, qq{Scanless pos()} );

# Marpa::R3::Display
# name: SLIF input_length() example

    my $input_length = $recce->input_length();

# Marpa::R3::Display::End

    Test::More::is( $input_length, 19, qq{Scanless input_length()} );

# Marpa::R3::Display
# name: SLIF input_length() 1-arg example

    $input_length = $recce->input_length(1);

# Marpa::R3::Display::End

    Test::More::is( $input_length, 19, qq{Scanless 1-arg input_length()} );

    # Test translation from G1 location to input stream spans
    my %location_seen = ();
    my @spans         = ();
    for my $g1_location (
        sort { $a <=> $b }
        grep { !$location_seen{$_}++ and $_ != $g1_pos ; } map { $_->[-1] } @{$progress_output}
        )
    {

# Marpa::R3::Display
# name: Scanless g1_to_l0_first() synopsis

        my ( $first_block, $first_l0_pos ) =
            $recce->g1_to_l0_first($g1_location);

# Marpa::R3::Display::End

# Marpa::R3::Display
# name: Scanless g1_to_l0_last() synopsis

        my ( $last_block, $last_l0_pos ) =
            $recce->g1_to_l0_last($g1_location);

# Marpa::R3::Display::End

        push @spans, [ $g1_location, $first_block, $first_l0_pos, $last_block, $last_l0_pos];
    }

    # One result for each unique G1 location in progress report
    # Format of each result is
    #    [g1_location, first_block, first_l0_pos, last_block, last_l0_pos]

    my $expected_spans =
          [ [ 0, 1, 0, 1, 0 ], [ 6, 1, 10, 1, 10 ], [ 10, 1, 18, 1, 18 ] ];
    Test::More::is_deeply( \@spans, $expected_spans,
        qq{Scanless g1_to_l0_first() & g1_to_l0_last() } );

} ## end TEST: for my $test_data (@tests_data)

# vim: expandtab shiftwidth=4:
