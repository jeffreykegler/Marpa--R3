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

# Displays for Progress.pod

use 5.010001;

use strict;
use warnings;

use Test::More tests => 47;

use Data::Dumper;
use English qw( -no_match_vars );
use Fatal qw( open close );
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

my $progress_report = q{};

# Marpa::R3::Display
# name: debug example, part 1

my $slif_debug_source = <<'END_OF_SOURCE';
:default ::= action => ::array bless => ::lhs
:start ::= statements
statements ::= statement *
statement ::= assignment | <numeric assignment>
assignment ::= 'set' variable 'to' expression

# This is a deliberate error in the grammar
# The next line should be:
# <numeric assignment> ::= variable '=' <numeric expression>
# I have changed the <numeric expression>  to <expression> which
# will cause problems.
<numeric assignment> ::= variable '=' expression

expression ::=
       variable | string
    || 'string' '(' <numeric expression> ')'
    || expression '+' expression
<numeric expression> ::=
       variable | number
    || <numeric expression> '*' <numeric expression>
    || <numeric expression> '+' <numeric expression>
variable ~ [\w]+
number ~ [\d]+
string ~ ['] <string contents> [']
<string contents> ~ [^'\x{0A}\x{0B}\x{0C}\x{0D}\x{0085}\x{2028}\x{2029}]+
:discard ~ whitespace
whitespace ~ [\s]+
END_OF_SOURCE

my $grammar = Marpa::R3::Grammar->new(
    {
    bless_package => 'My_Nodes',
    source => \$slif_debug_source,
});

# Marpa::R3::Display::End

## no critic (InputOutput::RequireBriefOpen)
open my $trace_fh, q{>}, \( my $trace_output = q{} );
## use critic

# Marpa::R3::Display
# name: grammar set() synopsis

$grammar->set( { trace_file_handle => $trace_fh } );

# Marpa::R3::Display::End

# Marpa::R3::Display
# name: debug example, part 2

my $recce = Marpa::R3::Recognizer->new(
    { grammar => $grammar,
    trace_terminals => 1,
    trace_values => 1,
    } );

my $test_input = 'a = 8675309 + 42 * 711';
my $eval_error = $EVAL_ERROR if not eval { $recce->read( \$test_input ); 1 };

$progress_report = $recce->progress_show( 0, -1 );

# Marpa::R3::Display::End

# Marpa::R3::Display
# name: debug example error message
# start-after-line: END_OF_TEXT
# end-before-line: '^END_OF_TEXT$'

$eval_error =~ s/^(Marpa::R3 \s+ exception \s+ at) .*/$1\n/xms;
Marpa::R3::Test::is($eval_error, <<'END_OF_TEXT', 'Error message before fix');
Error in parse: No lexeme found at B1L1c18
* String before error: a = 8675309 + 42\s
* The error was at B1L1c18, and at character U+002a "*", ...
* here: * 711
Marpa::R3 exception at
END_OF_TEXT

# Marpa::R3::Display::End


# Marpa::R3::Display
# name: debug example dump of value

my $value_ref = $recce->value();
my $expected_output = \bless( [
                 bless( [
                          bless( [
                                   'a',
                                   '=',
                                   bless( [
                                            bless( [
                                                     '8675309'
                                                   ], 'My_Nodes::expression' ),
                                            '+',
                                            bless( [
                                                     '42'
                                                   ], 'My_Nodes::expression' )
                                          ], 'My_Nodes::expression' )
                                 ], 'My_Nodes::numeric_assignment' )
                        ], 'My_Nodes::statement' )
               ], 'My_Nodes::statements' );

# Marpa::R3::Display::End

Test::More::is_deeply( $value_ref, $expected_output, 'Value before fix' );

# Marpa::R3::Display
# name: debug example progress report
# start-after-line: END_PROGRESS_REPORT
# end-before-line: '^END_PROGRESS_REPORT$'

Marpa::R3::Test::is( $progress_report,
    <<'END_PROGRESS_REPORT', 'progress report' );
=== Earley set 0 at B1L1c1 ===
P1 B1L1c1 [:start:] ::= . statements
P2 B1L1c1 statement ::= . <numeric assignment>
P3 B1L1c1 assignment ::= . 'set' variable 'to' expression
P4 B1L1c1 <numeric assignment> ::= . variable '=' expression
P18 B1L1c1 statements ::= . statement *
P20 B1L1c1 statement ::= . assignment
=== Earley set 1 at B1L1c3 ===
R4:1 B1L1c1 <numeric assignment> ::= variable . '=' expression
=== Earley set 2 at B1L1c5 ===
P5 B1L1c5 expression ::= . expression; prec=-1
P6 B1L1c5 expression ::= . expression; prec=0
P7 B1L1c5 expression ::= . expression; prec=1
P8 B1L1c5 expression ::= . variable; prec=2
P9 B1L1c5 expression ::= . string; prec=2
P10 B1L1c5 expression ::= . 'string' '(' <numeric expression> ')'; prec=1
P11 B1L1c5 expression ::= . expression '+' expression; prec=0
R4:2 B1L1c1 <numeric assignment> ::= variable '=' . expression
=== Earley set 3 at B1L1c13 ===
P2 B1L1c13 statement ::= . <numeric assignment>
P3 B1L1c13 assignment ::= . 'set' variable 'to' expression
P4 B1L1c13 <numeric assignment> ::= . variable '=' expression
P20 B1L1c13 statement ::= . assignment
R11:1 B1L1c5 expression ::= expression . '+' expression; prec=0
F1 B1L1c1 [:start:] ::= statements .
F2 B1L1c1 statement ::= <numeric assignment> .
F4 B1L1c1 <numeric assignment> ::= variable '=' expression .
F5 B1L1c5 expression ::= expression .; prec=-1
F6 B1L1c5 expression ::= expression .; prec=0
F7 B1L1c5 expression ::= expression .; prec=1
F8 B1L1c5 expression ::= variable .; prec=2
F18 B1L1c1 statements ::= statement . *
=== Earley set 4 at B1L1c15 ===
P7 B1L1c15 expression ::= . expression; prec=1
P8 B1L1c15 expression ::= . variable; prec=2
P9 B1L1c15 expression ::= . string; prec=2
P10 B1L1c15 expression ::= . 'string' '(' <numeric expression> ')'; prec=1
R11:2 B1L1c5 expression ::= expression '+' . expression; prec=0
=== Earley set 5 at B1L1c17 ===
P2 B1L1c17 statement ::= . <numeric assignment>
P3 B1L1c17 assignment ::= . 'set' variable 'to' expression
P4 B1L1c17 <numeric assignment> ::= . variable '=' expression
P20 B1L1c17 statement ::= . assignment
R11:1 B1L1c5 expression ::= expression . '+' expression; prec=0
F1 B1L1c1 [:start:] ::= statements .
F2 B1L1c1 statement ::= <numeric assignment> .
F4 B1L1c1 <numeric assignment> ::= variable '=' expression .
F5 B1L1c5 expression ::= expression .; prec=-1
F7 B1L1c15 expression ::= expression .; prec=1
F8 B1L1c15 expression ::= variable .; prec=2
F11 B1L1c5 expression ::= expression '+' expression .; prec=0
F18 B1L1c1 statements ::= statement . *
END_PROGRESS_REPORT

# Marpa::R3::Display::End

$Data::Dumper::Indent = 0;
$Data::Dumper::Terse  = 1;

# Marpa::R3::Display
# name: progress(0) example

my $report0 = $recce->progress(0);

# Marpa::R3::Display::End

# Marpa::R3::Display
# name: progress() output at location 0
# start-after-line: END_PROGRESS_REPORT
# end-before-line: '^END_PROGRESS_REPORT$'

chomp( my $expected_report0 = <<'END_PROGRESS_REPORT');
[[1,0,0],[2,0,0],[3,0,0],[4,0,0],[18,0,0],[20,0,0]]
END_PROGRESS_REPORT
Test::More::is_deeply( Data::Dumper::Dumper($report0),
    $expected_report0, 'progress report at location 0' );

# Marpa::R3::Display::End

# Try again with negative index
$report0 = $recce->progress(-6);
Test::More::is_deeply( Data::Dumper::Dumper($report0),
    $expected_report0, 'progress report at location -6' );

my $report1 = $recce->progress(1);

# Marpa::R3::Display
# name: progress() output at location 1
# start-after-line: END_PROGRESS_REPORT
# end-before-line: '^END_PROGRESS_REPORT$'

chomp( my $expected_report1 = <<'END_PROGRESS_REPORT');
[[4,1,0]]
END_PROGRESS_REPORT
Test::More::is_deeply( Data::Dumper::Dumper($report1),
    $expected_report1, 'progress report at location 1' );

# Marpa::R3::Display::End

# Try again with negative index
$report1 = $recce->progress(-5);
Test::More::is_deeply( Data::Dumper::Dumper($report1),
    $expected_report1, 'progress report at location -5' );

my $report2 = $recce->progress(2);

# Marpa::R3::Display
# name: progress() output at location 2
# start-after-line: END_PROGRESS_REPORT
# end-before-line: '^END_PROGRESS_REPORT$'

chomp( my $expected_report2 = <<'END_PROGRESS_REPORT');
[[4,2,0],[5,0,2],[6,0,2],[7,0,2],[8,0,2],[9,0,2],[10,0,2],[11,0,2]]
END_PROGRESS_REPORT
Test::More::is_deeply( Data::Dumper::Dumper($report2),
    $expected_report2, 'progress report at location 2' );

# Marpa::R3::Display::End

# Try again with negative index
$report2 = $recce->progress(-4);
Test::More::is_deeply( Data::Dumper::Dumper($report2),
    $expected_report2, 'progress report at location -4' );

# Marpa::R3::Display
# name: progress() example

my $latest_report = $recce->progress();

# Marpa::R3::Display::End

# Marpa::R3::Display
# name: progress() output at default location
# start-after-line: END_PROGRESS_REPORT
# end-before-line: '^END_PROGRESS_REPORT$'

chomp( my $expected_default_report = <<'END_PROGRESS_REPORT');
[[1,1,0],[2,0,5],[2,1,0],[3,0,5],[4,0,5],[4,3,0],[5,1,2],[7,1,4],[8,1,4],[11,1,2],[11,3,2],[18,1,0],[20,0,5]]
END_PROGRESS_REPORT
Test::More::is_deeply( Data::Dumper::Dumper($latest_report),
    $expected_default_report, 'progress report at default location' );

# Marpa::R3::Display::End

chomp( my $expected_report3 = <<'END_PROGRESS_REPORT');
[[1,1,0],[2,0,3],[2,1,0],[3,0,3],[4,0,3],[4,3,0],[5,1,2],[6,1,2],[7,1,2],[8,1,2],[11,1,2],[18,1,0],[20,0,3]]
END_PROGRESS_REPORT

# Try latest report again with explicit index
my $report3 = $recce->progress(3);
Test::More::is_deeply( Data::Dumper::Dumper($report3),
    $expected_report3, 'progress report at location 3' );

# Try latest report again with negative index
$latest_report = $recce->progress(-3);
Test::More::is_deeply( Data::Dumper::Dumper($latest_report),
    $expected_report3, 'progress report at location -3' );

# Marpa::R3::Display
# name: debug example trace output
# start-after-line: END_TRACE_OUTPUT
# end-before-line: '^END_TRACE_OUTPUT$'

Marpa::R3::Test::is( $trace_output, <<'END_TRACE_OUTPUT', 'trace output' );
Setting trace_terminals option
Setting trace_values option to 1
Restarted recognizer at B1L1c1
Reading codepoint "a" 0x0061 at B1L1c1
Codepoint "a" 0x0061 accepted as [\w] at B1L1c1
Codepoint "a" 0x0061 rejected as [^'\x{0A}\x{0B}\x{0C}\x{0D}\x{0085}\x{2028}\x{2029}] at B1L1c1
Reading codepoint " " 0x0020 at B1L1c2
Codepoint " " 0x0020 rejected as [\s] at B1L1c2
Codepoint " " 0x0020 rejected as [^'\x{0A}\x{0B}\x{0C}\x{0D}\x{0085}\x{2028}\x{2029}] at B1L1c2
Accepted lexeme B1L1c1 e1: variable; value="a"
Restarted recognizer at B1L1c2
Reading codepoint " " 0x0020 at B1L1c2
Codepoint " " 0x0020 accepted as [\s] at B1L1c2
Codepoint " " 0x0020 rejected as [^'\x{0A}\x{0B}\x{0C}\x{0D}\x{0085}\x{2028}\x{2029}] at B1L1c2
Reading codepoint "=" 0x003d at B1L1c3
Codepoint "=" 0x003d rejected as [\=] at B1L1c3
Codepoint "=" 0x003d rejected as [^'\x{0A}\x{0B}\x{0C}\x{0D}\x{0085}\x{2028}\x{2029}] at B1L1c3
Discarded lexeme B1L1c2: whitespace
Restarted recognizer at B1L1c3
Reading codepoint "=" 0x003d at B1L1c3
Codepoint "=" 0x003d accepted as [\=] at B1L1c3
Codepoint "=" 0x003d rejected as [^'\x{0A}\x{0B}\x{0C}\x{0D}\x{0085}\x{2028}\x{2029}] at B1L1c3
Accepted lexeme B1L1c3 e2: '='; value="="
Restarted recognizer at B1L1c4
Reading codepoint " " 0x0020 at B1L1c4
Codepoint " " 0x0020 accepted as [\s] at B1L1c4
Codepoint " " 0x0020 rejected as [^'\x{0A}\x{0B}\x{0C}\x{0D}\x{0085}\x{2028}\x{2029}] at B1L1c4
Reading codepoint "8" 0x0038 at B1L1c5
Codepoint "8" 0x0038 rejected as [\d] at B1L1c5
Codepoint "8" 0x0038 rejected as [\w] at B1L1c5
Codepoint "8" 0x0038 rejected as [^'\x{0A}\x{0B}\x{0C}\x{0D}\x{0085}\x{2028}\x{2029}] at B1L1c5
Discarded lexeme B1L1c4: whitespace
Restarted recognizer at B1L1c5
Reading codepoint "8" 0x0038 at B1L1c5
Codepoint "8" 0x0038 rejected as [\d] at B1L1c5
Codepoint "8" 0x0038 accepted as [\w] at B1L1c5
Codepoint "8" 0x0038 rejected as [^'\x{0A}\x{0B}\x{0C}\x{0D}\x{0085}\x{2028}\x{2029}] at B1L1c5
Reading codepoint "6" 0x0036 at B1L1c6
Codepoint "6" 0x0036 rejected as [\d] at B1L1c6
Codepoint "6" 0x0036 accepted as [\w] at B1L1c6
Codepoint "6" 0x0036 rejected as [^'\x{0A}\x{0B}\x{0C}\x{0D}\x{0085}\x{2028}\x{2029}] at B1L1c6
Reading codepoint "7" 0x0037 at B1L1c7
Codepoint "7" 0x0037 rejected as [\d] at B1L1c7
Codepoint "7" 0x0037 accepted as [\w] at B1L1c7
Codepoint "7" 0x0037 rejected as [^'\x{0A}\x{0B}\x{0C}\x{0D}\x{0085}\x{2028}\x{2029}] at B1L1c7
Reading codepoint "5" 0x0035 at B1L1c8
Codepoint "5" 0x0035 rejected as [\d] at B1L1c8
Codepoint "5" 0x0035 accepted as [\w] at B1L1c8
Codepoint "5" 0x0035 rejected as [^'\x{0A}\x{0B}\x{0C}\x{0D}\x{0085}\x{2028}\x{2029}] at B1L1c8
Reading codepoint "3" 0x0033 at B1L1c9
Codepoint "3" 0x0033 rejected as [\d] at B1L1c9
Codepoint "3" 0x0033 accepted as [\w] at B1L1c9
Codepoint "3" 0x0033 rejected as [^'\x{0A}\x{0B}\x{0C}\x{0D}\x{0085}\x{2028}\x{2029}] at B1L1c9
Reading codepoint "0" 0x0030 at B1L1c10
Codepoint "0" 0x0030 rejected as [\d] at B1L1c10
Codepoint "0" 0x0030 accepted as [\w] at B1L1c10
Codepoint "0" 0x0030 rejected as [^'\x{0A}\x{0B}\x{0C}\x{0D}\x{0085}\x{2028}\x{2029}] at B1L1c10
Reading codepoint "9" 0x0039 at B1L1c11
Codepoint "9" 0x0039 rejected as [\d] at B1L1c11
Codepoint "9" 0x0039 accepted as [\w] at B1L1c11
Codepoint "9" 0x0039 rejected as [^'\x{0A}\x{0B}\x{0C}\x{0D}\x{0085}\x{2028}\x{2029}] at B1L1c11
Reading codepoint " " 0x0020 at B1L1c12
Codepoint " " 0x0020 rejected as [\s] at B1L1c12
Codepoint " " 0x0020 rejected as [^'\x{0A}\x{0B}\x{0C}\x{0D}\x{0085}\x{2028}\x{2029}] at B1L1c12
Accepted lexeme B1L1c5-11 e3: variable; value="8675309"
Restarted recognizer at B1L1c12
Reading codepoint " " 0x0020 at B1L1c12
Codepoint " " 0x0020 accepted as [\s] at B1L1c12
Codepoint " " 0x0020 rejected as [^'\x{0A}\x{0B}\x{0C}\x{0D}\x{0085}\x{2028}\x{2029}] at B1L1c12
Reading codepoint "+" 0x002b at B1L1c13
Codepoint "+" 0x002b rejected as [\+] at B1L1c13
Codepoint "+" 0x002b rejected as [^'\x{0A}\x{0B}\x{0C}\x{0D}\x{0085}\x{2028}\x{2029}] at B1L1c13
Discarded lexeme B1L1c12: whitespace
Restarted recognizer at B1L1c13
Reading codepoint "+" 0x002b at B1L1c13
Codepoint "+" 0x002b accepted as [\+] at B1L1c13
Codepoint "+" 0x002b rejected as [^'\x{0A}\x{0B}\x{0C}\x{0D}\x{0085}\x{2028}\x{2029}] at B1L1c13
Accepted lexeme B1L1c13 e4: '+'; value="+"
Restarted recognizer at B1L1c14
Reading codepoint " " 0x0020 at B1L1c14
Codepoint " " 0x0020 accepted as [\s] at B1L1c14
Codepoint " " 0x0020 rejected as [^'\x{0A}\x{0B}\x{0C}\x{0D}\x{0085}\x{2028}\x{2029}] at B1L1c14
Reading codepoint "4" 0x0034 at B1L1c15
Codepoint "4" 0x0034 rejected as [\d] at B1L1c15
Codepoint "4" 0x0034 rejected as [\w] at B1L1c15
Codepoint "4" 0x0034 rejected as [^'\x{0A}\x{0B}\x{0C}\x{0D}\x{0085}\x{2028}\x{2029}] at B1L1c15
Discarded lexeme B1L1c14: whitespace
Restarted recognizer at B1L1c15
Reading codepoint "4" 0x0034 at B1L1c15
Codepoint "4" 0x0034 rejected as [\d] at B1L1c15
Codepoint "4" 0x0034 accepted as [\w] at B1L1c15
Codepoint "4" 0x0034 rejected as [^'\x{0A}\x{0B}\x{0C}\x{0D}\x{0085}\x{2028}\x{2029}] at B1L1c15
Reading codepoint "2" 0x0032 at B1L1c16
Codepoint "2" 0x0032 rejected as [\d] at B1L1c16
Codepoint "2" 0x0032 accepted as [\w] at B1L1c16
Codepoint "2" 0x0032 rejected as [^'\x{0A}\x{0B}\x{0C}\x{0D}\x{0085}\x{2028}\x{2029}] at B1L1c16
Reading codepoint " " 0x0020 at B1L1c17
Codepoint " " 0x0020 rejected as [\s] at B1L1c17
Codepoint " " 0x0020 rejected as [^'\x{0A}\x{0B}\x{0C}\x{0D}\x{0085}\x{2028}\x{2029}] at B1L1c17
Accepted lexeme B1L1c15-16 e5: variable; value="42"
Restarted recognizer at B1L1c17
Reading codepoint " " 0x0020 at B1L1c17
Codepoint " " 0x0020 accepted as [\s] at B1L1c17
Codepoint " " 0x0020 rejected as [^'\x{0A}\x{0B}\x{0C}\x{0D}\x{0085}\x{2028}\x{2029}] at B1L1c17
Reading codepoint "*" 0x002a at B1L1c18
Codepoint "*" 0x002a rejected as [\*] at B1L1c18
Codepoint "*" 0x002a rejected as [^'\x{0A}\x{0B}\x{0C}\x{0D}\x{0085}\x{2028}\x{2029}] at B1L1c18
Discarded lexeme B1L1c17: whitespace
Restarted recognizer at B1L1c18
Reading codepoint "*" 0x002a at B1L1c18
Codepoint "*" 0x002a rejected as [\*] at B1L1c18
Codepoint "*" 0x002a rejected as [^'\x{0A}\x{0B}\x{0C}\x{0D}\x{0085}\x{2028}\x{2029}] at B1L1c18
valuator trace level: 1
END_TRACE_OUTPUT

# Marpa::R3::Display::End

$slif_debug_source =~
    s{^ [<] numeric \s+ assignment [>] \s+ [:][:][=] \s+ variable \s+ ['][=]['] \s+ expression $}
    {<numeric assignment> ::= variable '=' <numeric expression>}xms;

$grammar = Marpa::R3::Grammar->new(
    {
    bless_package => 'My_Nodes',
    source => \$slif_debug_source,
});

$recce = Marpa::R3::Recognizer->new(
    { grammar => $grammar } );

die if not defined $recce->read( \$test_input );
my $valuer = Marpa::R3::Valuer->new( { recognizer => $recce } );
$value_ref = $valuer->value();
my $expected_value_after_fix = \bless(
    [
        bless(
            [
                bless(
                    [
                        'a', '=',
                        bless(
                            [
                                bless(
                                    ['8675309'], 'My_Nodes::numeric_expression'
                                ),
                                '+',
                                bless(
                                    [
                                        bless(
                                            ['42'],
                                            'My_Nodes::numeric_expression'
                                        ),
                                        '*',
                                        bless(
                                            ['711'],
                                            'My_Nodes::numeric_expression'
                                        )
                                    ],
                                    'My_Nodes::numeric_expression'
                                )
                            ],
                            'My_Nodes::numeric_expression'
                        )
                    ],
                    'My_Nodes::numeric_assignment'
                )
            ],
            'My_Nodes::statement'
        )
    ],
    'My_Nodes::statements'
);

Test::More::is_deeply($value_ref, $expected_value_after_fix, 'Value after fix');

my $productions_show_output = q{};

# Marpa::R3::Display
# name: SLG productions_show() synopsis

$productions_show_output = $grammar->productions_show();

# Marpa::R3::Display::End

Marpa::R3::Test::is( $productions_show_output,
    <<'END_OF_OUTPUT', 'productions_show()' );
R1 [:start:] ::= statements
R2 statement ::= <numeric assignment>
R3 assignment ::= 'set' variable 'to' expression
R4 <numeric assignment> ::= variable '=' <numeric expression>
R5 expression ::= expression; prec=-1
R6 expression ::= expression; prec=0
R7 expression ::= expression; prec=1
R8 expression ::= variable; prec=2
R9 expression ::= string; prec=2
R10 expression ::= 'string' '(' <numeric expression> ')'; prec=1
R11 expression ::= expression '+' expression; prec=0
R12 <numeric expression> ::= <numeric expression>; prec=-1
R13 <numeric expression> ::= <numeric expression>; prec=0
R14 <numeric expression> ::= <numeric expression>; prec=1
R15 <numeric expression> ::= variable; prec=2
R16 <numeric expression> ::= number; prec=2
R17 <numeric expression> ::= <numeric expression> '*' <numeric expression>; prec=1
R18 statements ::= statement *
R19 <numeric expression> ::= <numeric expression> '+' <numeric expression>; prec=0
R20 statement ::= assignment
R21 [:lex_start:] ~ [:target:]
R22 [:target:] ~ [:discard:]
R23 [:target:] ~ 'set'
R24 [:target:] ~ 'to'
R25 [:target:] ~ '='
R26 [:target:] ~ 'string'
R27 [:target:] ~ '('
R28 [:target:] ~ ')'
R29 [:target:] ~ '+'
R30 [:target:] ~ '*'
R31 [:target:] ~ number
R32 [:target:] ~ string
R33 [:target:] ~ variable
R34 'set' ~ [s] [e] [t]
R35 'to' ~ [t] [o]
R36 '=' ~ [\=]
R37 'string' ~ [s] [t] [r] [i] [n] [g]
R38 '(' ~ [\(]
R39 ')' ~ [\)]
R40 '+' ~ [\+]
R41 '*' ~ [\*]
R42 variable ~ [\w] +
R43 number ~ [\d] +
R44 string ~ ['] <string contents> [']
R45 <string contents> ~ [^'\x{0A}\x{0B}\x{0C}\x{0D}\x{0085}\x{2028}\x{2029}] +
R46 [:discard:] ~ whitespace
R47 whitespace ~ [\s] +
END_OF_OUTPUT

# Marpa::R3::Display
# name: SLG productions_show() verbose synopsis

$productions_show_output = $grammar->productions_show( { verbose => 3 } );

# Marpa::R3::Display::End

# Marpa::R3::Display
# name: debug example productions_show() output
# start-after-line: END_OF_OUTPUT
# end-before-line: '^END_OF_OUTPUT$'

Marpa::R3::Test::is( $productions_show_output,
    <<'END_OF_OUTPUT', 'productions_show()' );
R1 [:start:] ::= statements
  Symbol IDs: <3> ::=
  Canonical names: [:start:] ::=
R2 statement ::= <numeric assignment>
  Symbol IDs: <36> ::=
  Canonical names: statement ::=
R3 assignment ::= 'set' variable 'to' expression
  Symbol IDs: <31> ::= <5> <40> <6>
  Canonical names: assignment ::= [Lex-0] variable [Lex-1]
R4 <numeric assignment> ::= variable '=' <numeric expression>
  Symbol IDs: <34> ::= <40> <7>
  Canonical names: <numeric assignment> ::= variable [Lex-2]
R5 expression ::= expression; prec=-1
  Symbol IDs: <32> ::=
  Canonical names: expression ::=
R6 expression ::= expression; prec=0
  Symbol IDs: <32> ::=
  Canonical names: expression ::=
R7 expression ::= expression; prec=1
  Symbol IDs: <32> ::=
  Canonical names: expression ::=
R8 expression ::= variable; prec=2
  Symbol IDs: <32> ::=
  Canonical names: expression ::=
R9 expression ::= string; prec=2
  Symbol IDs: <32> ::=
  Canonical names: expression ::=
R10 expression ::= 'string' '(' <numeric expression> ')'; prec=1
  Symbol IDs: <32> ::= <8> <9> <35>
  Canonical names: expression ::= [Lex-3] [Lex-4] <numeric expression>
R11 expression ::= expression '+' expression; prec=0
  Symbol IDs: <32> ::= <32> <11>
  Canonical names: expression ::= expression [Lex-6]
R12 <numeric expression> ::= <numeric expression>; prec=-1
  Symbol IDs: <35> ::=
  Canonical names: <numeric expression> ::=
R13 <numeric expression> ::= <numeric expression>; prec=0
  Symbol IDs: <35> ::=
  Canonical names: <numeric expression> ::=
R14 <numeric expression> ::= <numeric expression>; prec=1
  Symbol IDs: <35> ::=
  Canonical names: <numeric expression> ::=
R15 <numeric expression> ::= variable; prec=2
  Symbol IDs: <35> ::=
  Canonical names: <numeric expression> ::=
R16 <numeric expression> ::= number; prec=2
  Symbol IDs: <35> ::=
  Canonical names: <numeric expression> ::=
R17 <numeric expression> ::= <numeric expression> '*' <numeric expression>; prec=1
  Symbol IDs: <35> ::= <35> <12>
  Canonical names: <numeric expression> ::= <numeric expression> [Lex-7]
R18 statements ::= statement *
  Symbol IDs: <37> ::=
  Canonical names: statements ::=
R19 <numeric expression> ::= <numeric expression> '+' <numeric expression>; prec=0
  Symbol IDs: <35> ::= <35> <11>
  Canonical names: <numeric expression> ::= <numeric expression> [Lex-6]
R20 statement ::= assignment
  Symbol IDs: <36> ::=
  Canonical names: statement ::=
R21 [:lex_start:] ~ [:target:]
  Symbol IDs: <2> ::=
  Canonical names: [:lex_start:] ::=
R22 [:target:] ~ [:discard:]
  Symbol IDs: <4> ::=
  Canonical names: [:target:] ::=
R23 [:target:] ~ 'set'
  Symbol IDs: <4> ::=
  Canonical names: [:target:] ::=
R24 [:target:] ~ 'to'
  Symbol IDs: <4> ::=
  Canonical names: [:target:] ::=
R25 [:target:] ~ '='
  Symbol IDs: <4> ::=
  Canonical names: [:target:] ::=
R26 [:target:] ~ 'string'
  Symbol IDs: <4> ::=
  Canonical names: [:target:] ::=
R27 [:target:] ~ '('
  Symbol IDs: <4> ::=
  Canonical names: [:target:] ::=
R28 [:target:] ~ ')'
  Symbol IDs: <4> ::=
  Canonical names: [:target:] ::=
R29 [:target:] ~ '+'
  Symbol IDs: <4> ::=
  Canonical names: [:target:] ::=
R30 [:target:] ~ '*'
  Symbol IDs: <4> ::=
  Canonical names: [:target:] ::=
R31 [:target:] ~ number
  Symbol IDs: <4> ::=
  Canonical names: [:target:] ::=
R32 [:target:] ~ string
  Symbol IDs: <4> ::=
  Canonical names: [:target:] ::=
R33 [:target:] ~ variable
  Symbol IDs: <4> ::=
  Canonical names: [:target:] ::=
R34 'set' ~ [s] [e] [t]
  Symbol IDs: <5> ::= <29> <23>
  Canonical names: [Lex-0] ::= [[s]] [[e]]
R35 'to' ~ [t] [o]
  Symbol IDs: <6> ::= <30>
  Canonical names: [Lex-1] ::= [[t]]
R36 '=' ~ [\=]
  Symbol IDs: <7> ::=
  Canonical names: [Lex-2] ::=
R37 'string' ~ [s] [t] [r] [i] [n] [g]
  Symbol IDs: <8> ::= <29> <30> <28> <25> <26>
  Canonical names: [Lex-3] ::= [[s]] [[t]] [[r]] [[i]] [[n]]
R38 '(' ~ [\(]
  Symbol IDs: <9> ::=
  Canonical names: [Lex-4] ::=
R39 ')' ~ [\)]
  Symbol IDs: <10> ::=
  Canonical names: [Lex-5] ::=
R40 '+' ~ [\+]
  Symbol IDs: <11> ::=
  Canonical names: [Lex-6] ::=
R41 '*' ~ [\*]
  Symbol IDs: <12> ::=
  Canonical names: [Lex-7] ::=
R42 variable ~ [\w] +
  Symbol IDs: <40> ::=
  Canonical names: variable ::=
R43 number ~ [\d] +
  Symbol IDs: <33> ::=
  Canonical names: number ::=
R44 string ~ ['] <string contents> [']
  Symbol IDs: <38> ::= <13> <39>
  Canonical names: string ::= [[']] <string contents>
R45 <string contents> ~ [^'\x{0A}\x{0B}\x{0C}\x{0D}\x{0085}\x{2028}\x{2029}] +
  Symbol IDs: <39> ::=
  Canonical names: <string contents> ::=
R46 [:discard:] ~ whitespace
  Symbol IDs: <1> ::=
  Canonical names: [:discard:] ::=
R47 whitespace ~ [\s] +
  Symbol IDs: <41> ::=
  Canonical names: whitespace ::=
END_OF_OUTPUT

# Marpa::R3::Display::End

my $rules_show_output = $grammar->g1_rules_show( { verbose => 3 } );

Marpa::R3::Test::is( $rules_show_output,
    <<'END_OF_SHOW_RULES_OUTPUT', 'g1_rules_show()' );
R0 statements ::= statement *
  Symbol IDs: <21> ::= <20>
  Canonical symbols: statements ::= statement
R1 statement ::= assignment
  Symbol IDs: <20> ::= <9>
  Canonical symbols: statement ::= assignment
R2 statement ::= <numeric assignment>
  Symbol IDs: <20> ::= <15>
  Canonical symbols: statement ::= <numeric assignment>
R3 assignment ::= 'set' variable 'to' expression
  Symbol IDs: <9> ::= <1> <23> <2> <10>
  Canonical symbols: assignment ::= [Lex-0] variable [Lex-1] expression
R4 <numeric assignment> ::= variable '=' <numeric expression>
  Symbol IDs: <15> ::= <23> <3> <16>
  Canonical symbols: <numeric assignment> ::= variable [Lex-2] <numeric expression>
R5 expression ::= expression
  Symbol IDs: <10> ::= <11>
  Canonical symbols: expression ::= <expression[0]>
R6 expression ::= expression
  Symbol IDs: <11> ::= <12>
  Canonical symbols: <expression[0]> ::= <expression[1]>
R7 expression ::= expression
  Symbol IDs: <12> ::= <13>
  Canonical symbols: <expression[1]> ::= <expression[2]>
R8 expression ::= variable
  Symbol IDs: <13> ::= <23>
  Canonical symbols: <expression[2]> ::= variable
R9 expression ::= string
  Symbol IDs: <13> ::= <22>
  Canonical symbols: <expression[2]> ::= string
R10 expression ::= 'string' '(' <numeric expression> ')'
  Symbol IDs: <12> ::= <4> <5> <16> <6>
  Canonical symbols: <expression[1]> ::= [Lex-3] [Lex-4] <numeric expression> [Lex-5]
R11 expression ::= expression '+' expression
  Symbol IDs: <11> ::= <11> <7> <12>
  Canonical symbols: <expression[0]> ::= <expression[0]> [Lex-6] <expression[1]>
R12 <numeric expression> ::= <numeric expression>
  Symbol IDs: <16> ::= <17>
  Canonical symbols: <numeric expression> ::= <numeric expression[0]>
R13 <numeric expression> ::= <numeric expression>
  Symbol IDs: <17> ::= <18>
  Canonical symbols: <numeric expression[0]> ::= <numeric expression[1]>
R14 <numeric expression> ::= <numeric expression>
  Symbol IDs: <18> ::= <19>
  Canonical symbols: <numeric expression[1]> ::= <numeric expression[2]>
R15 <numeric expression> ::= variable
  Symbol IDs: <19> ::= <23>
  Canonical symbols: <numeric expression[2]> ::= variable
R16 <numeric expression> ::= number
  Symbol IDs: <19> ::= <14>
  Canonical symbols: <numeric expression[2]> ::= number
R17 <numeric expression> ::= <numeric expression> '*' <numeric expression>
  Symbol IDs: <18> ::= <18> <8> <19>
  Canonical symbols: <numeric expression[1]> ::= <numeric expression[1]> [Lex-7] <numeric expression[2]>
R18 <numeric expression> ::= <numeric expression> '+' <numeric expression>
  Symbol IDs: <17> ::= <17> <7> <18>
  Canonical symbols: <numeric expression[0]> ::= <numeric expression[0]> [Lex-6] <numeric expression[1]>
R19 [:start:] ::= statements
  Symbol IDs: <0> ::= <21>
  Canonical symbols: [:start:] ::= statements
END_OF_SHOW_RULES_OUTPUT

$rules_show_output = $grammar->l0_rules_show( { verbose => 3 });

Marpa::R3::Test::is( $rules_show_output,
    <<'END_OF_SHOW_RULES_OUTPUT', 'l0_rules_show()' );
R0 'set' ~ [s] [e] [t]
  Symbol IDs: <3> ::= <27> <21> <28>
  Canonical symbols: [Lex-0] ::= [[s]] [[e]] [[t]]
R1 'to' ~ [t] [o]
  Symbol IDs: <4> ::= <28> <25>
  Canonical symbols: [Lex-1] ::= [[t]] [[o]]
R2 '=' ~ [\=]
  Symbol IDs: <5> ::= <16>
  Canonical symbols: [Lex-2] ::= [[\=]]
R3 'string' ~ [s] [t] [r] [i] [n] [g]
  Symbol IDs: <6> ::= <27> <28> <26> <23> <24> <22>
  Canonical symbols: [Lex-3] ::= [[s]] [[t]] [[r]] [[i]] [[n]] [[g]]
R4 '(' ~ [\(]
  Symbol IDs: <7> ::= <12>
  Canonical symbols: [Lex-4] ::= [[\(]]
R5 ')' ~ [\)]
  Symbol IDs: <8> ::= <13>
  Canonical symbols: [Lex-5] ::= [[\)]]
R6 '+' ~ [\+]
  Symbol IDs: <9> ::= <15>
  Canonical symbols: [Lex-6] ::= [[\+]]
R7 '*' ~ [\*]
  Symbol IDs: <10> ::= <14>
  Canonical symbols: [Lex-7] ::= [[\*]]
R8 variable ~ [\w] +
  Symbol IDs: <32> ::= <19>
  Canonical symbols: variable ::= [[\w]]
R9 number ~ [\d] +
  Symbol IDs: <29> ::= <17>
  Canonical symbols: number ::= [[\d]]
R10 string ~ ['] <string contents> [']
  Symbol IDs: <30> ::= <11> <31> <11>
  Canonical symbols: string ::= [[']] <string contents> [[']]
R11 <string contents> ~ [^'\x{0A}\x{0B}\x{0C}\x{0D}\x{0085}\x{2028}\x{2029}] +
  Symbol IDs: <31> ::= <20>
  Canonical symbols: <string contents> ::= [[^'\x{0A}\x{0B}\x{0C}\x{0D}\x{0085}\x{2028}\x{2029}]]
R12 [:discard:] ~ whitespace
  Symbol IDs: <0> ::= <33>
  Canonical symbols: [:discard:] ::= whitespace
R13 whitespace ~ [\s] +
  Symbol IDs: <33> ::= <18>
  Canonical symbols: whitespace ::= [[\s]]
R14 [:lex_start:] ~ [:target:]
  Symbol IDs: <1> ::= <2>
  Canonical symbols: [:lex_start:] ::= [:target:]
R15 [:target:] ~ [:discard:]
  Symbol IDs: <2> ::= <0>
  Canonical symbols: [:target:] ::= [:discard:]
R16 [:target:] ~ 'set'
  Symbol IDs: <2> ::= <3>
  Canonical symbols: [:target:] ::= [Lex-0]
R17 [:target:] ~ 'to'
  Symbol IDs: <2> ::= <4>
  Canonical symbols: [:target:] ::= [Lex-1]
R18 [:target:] ~ '='
  Symbol IDs: <2> ::= <5>
  Canonical symbols: [:target:] ::= [Lex-2]
R19 [:target:] ~ 'string'
  Symbol IDs: <2> ::= <6>
  Canonical symbols: [:target:] ::= [Lex-3]
R20 [:target:] ~ '('
  Symbol IDs: <2> ::= <7>
  Canonical symbols: [:target:] ::= [Lex-4]
R21 [:target:] ~ ')'
  Symbol IDs: <2> ::= <8>
  Canonical symbols: [:target:] ::= [Lex-5]
R22 [:target:] ~ '+'
  Symbol IDs: <2> ::= <9>
  Canonical symbols: [:target:] ::= [Lex-6]
R23 [:target:] ~ '*'
  Symbol IDs: <2> ::= <10>
  Canonical symbols: [:target:] ::= [Lex-7]
R24 [:target:] ~ number
  Symbol IDs: <2> ::= <29>
  Canonical symbols: [:target:] ::= number
R25 [:target:] ~ string
  Symbol IDs: <2> ::= <30>
  Canonical symbols: [:target:] ::= string
R26 [:target:] ~ variable
  Symbol IDs: <2> ::= <32>
  Canonical symbols: [:target:] ::= variable
END_OF_SHOW_RULES_OUTPUT

my $productions_diag_output = $grammar->productions_show( { diag => 1 } );

Marpa::R3::Test::is( $productions_diag_output,
    <<'END_OF_OUTPUT', 'productions_show() diag form' );
R1 [:start:] ::= statements
R2 statement ::= <numeric assignment>
R3 assignment ::= [Lex-0] variable [Lex-1] expression
R4 <numeric assignment> ::= variable [Lex-2] <numeric expression>
R5 expression ::= expression; prec=-1
R6 expression ::= expression; prec=0
R7 expression ::= expression; prec=1
R8 expression ::= variable; prec=2
R9 expression ::= string; prec=2
R10 expression ::= [Lex-3] [Lex-4] <numeric expression> [Lex-5]; prec=1
R11 expression ::= expression [Lex-6] expression; prec=0
R12 <numeric expression> ::= <numeric expression>; prec=-1
R13 <numeric expression> ::= <numeric expression>; prec=0
R14 <numeric expression> ::= <numeric expression>; prec=1
R15 <numeric expression> ::= variable; prec=2
R16 <numeric expression> ::= number; prec=2
R17 <numeric expression> ::= <numeric expression> [Lex-7] <numeric expression>; prec=1
R18 statements ::= statement *
R19 <numeric expression> ::= <numeric expression> [Lex-6] <numeric expression>; prec=0
R20 statement ::= assignment
R21 [:lex_start:] ~ [:target:]
R22 [:target:] ~ [:discard:]
R23 [:target:] ~ [Lex-0]
R24 [:target:] ~ [Lex-1]
R25 [:target:] ~ [Lex-2]
R26 [:target:] ~ [Lex-3]
R27 [:target:] ~ [Lex-4]
R28 [:target:] ~ [Lex-5]
R29 [:target:] ~ [Lex-6]
R30 [:target:] ~ [Lex-7]
R31 [:target:] ~ number
R32 [:target:] ~ string
R33 [:target:] ~ variable
R34 [Lex-0] ~ [[s]] [[e]] [[t]]
R35 [Lex-1] ~ [[t]] [[o]]
R36 [Lex-2] ~ [[\=]]
R37 [Lex-3] ~ [[s]] [[t]] [[r]] [[i]] [[n]] [[g]]
R38 [Lex-4] ~ [[\(]]
R39 [Lex-5] ~ [[\)]]
R40 [Lex-6] ~ [[\+]]
R41 [Lex-7] ~ [[\*]]
R42 variable ~ [[\w]] +
R43 number ~ [[\d]] +
R44 string ~ [[']] <string contents> [[']]
R45 <string contents> ~ [[^'\x{0A}\x{0B}\x{0C}\x{0D}\x{0085}\x{2028}\x{2029}]] +
R46 [:discard:] ~ whitespace
R47 whitespace ~ [[\s]] +
END_OF_OUTPUT

my $rules_diag_output;

$rules_diag_output = $grammar->g1_rules_show( { verbose => 3, diag => 1 } );

Marpa::R3::Test::is( $rules_diag_output,
    <<'END_OF_SHOW_RULES_OUTPUT', 'g1_rules_show() diag form' );
R0 statements ::= statement *
  Symbol IDs: <21> ::= <20>
  Canonical symbols: statements ::= statement
R1 statement ::= assignment
  Symbol IDs: <20> ::= <9>
  Canonical symbols: statement ::= assignment
R2 statement ::= <numeric assignment>
  Symbol IDs: <20> ::= <15>
  Canonical symbols: statement ::= <numeric assignment>
R3 assignment ::= [Lex-0] variable [Lex-1] expression
  Symbol IDs: <9> ::= <1> <23> <2> <10>
  Canonical symbols: assignment ::= [Lex-0] variable [Lex-1] expression
R4 <numeric assignment> ::= variable [Lex-2] <numeric expression>
  Symbol IDs: <15> ::= <23> <3> <16>
  Canonical symbols: <numeric assignment> ::= variable [Lex-2] <numeric expression>
R5 expression ::= <expression[0]>
  Symbol IDs: <10> ::= <11>
  Canonical symbols: expression ::= <expression[0]>
R6 <expression[0]> ::= <expression[1]>
  Symbol IDs: <11> ::= <12>
  Canonical symbols: <expression[0]> ::= <expression[1]>
R7 <expression[1]> ::= <expression[2]>
  Symbol IDs: <12> ::= <13>
  Canonical symbols: <expression[1]> ::= <expression[2]>
R8 <expression[2]> ::= variable
  Symbol IDs: <13> ::= <23>
  Canonical symbols: <expression[2]> ::= variable
R9 <expression[2]> ::= string
  Symbol IDs: <13> ::= <22>
  Canonical symbols: <expression[2]> ::= string
R10 <expression[1]> ::= [Lex-3] [Lex-4] <numeric expression> [Lex-5]
  Symbol IDs: <12> ::= <4> <5> <16> <6>
  Canonical symbols: <expression[1]> ::= [Lex-3] [Lex-4] <numeric expression> [Lex-5]
R11 <expression[0]> ::= <expression[0]> [Lex-6] <expression[1]>
  Symbol IDs: <11> ::= <11> <7> <12>
  Canonical symbols: <expression[0]> ::= <expression[0]> [Lex-6] <expression[1]>
R12 <numeric expression> ::= <numeric expression[0]>
  Symbol IDs: <16> ::= <17>
  Canonical symbols: <numeric expression> ::= <numeric expression[0]>
R13 <numeric expression[0]> ::= <numeric expression[1]>
  Symbol IDs: <17> ::= <18>
  Canonical symbols: <numeric expression[0]> ::= <numeric expression[1]>
R14 <numeric expression[1]> ::= <numeric expression[2]>
  Symbol IDs: <18> ::= <19>
  Canonical symbols: <numeric expression[1]> ::= <numeric expression[2]>
R15 <numeric expression[2]> ::= variable
  Symbol IDs: <19> ::= <23>
  Canonical symbols: <numeric expression[2]> ::= variable
R16 <numeric expression[2]> ::= number
  Symbol IDs: <19> ::= <14>
  Canonical symbols: <numeric expression[2]> ::= number
R17 <numeric expression[1]> ::= <numeric expression[1]> [Lex-7] <numeric expression[2]>
  Symbol IDs: <18> ::= <18> <8> <19>
  Canonical symbols: <numeric expression[1]> ::= <numeric expression[1]> [Lex-7] <numeric expression[2]>
R18 <numeric expression[0]> ::= <numeric expression[0]> [Lex-6] <numeric expression[1]>
  Symbol IDs: <17> ::= <17> <7> <18>
  Canonical symbols: <numeric expression[0]> ::= <numeric expression[0]> [Lex-6] <numeric expression[1]>
R19 [:start:] ::= statements
  Symbol IDs: <0> ::= <21>
  Canonical symbols: [:start:] ::= statements
END_OF_SHOW_RULES_OUTPUT

$rules_diag_output = $grammar->l0_rules_show( { verbose => 3, diag => 1 } );

Marpa::R3::Test::is( $rules_diag_output,
    <<'END_OF_SHOW_RULES_OUTPUT', 'l0_rules_show() diag form' );
R0 [Lex-0] ~ [[s]] [[e]] [[t]]
  Symbol IDs: <3> ::= <27> <21> <28>
  Canonical symbols: [Lex-0] ::= [[s]] [[e]] [[t]]
R1 [Lex-1] ~ [[t]] [[o]]
  Symbol IDs: <4> ::= <28> <25>
  Canonical symbols: [Lex-1] ::= [[t]] [[o]]
R2 [Lex-2] ~ [[\=]]
  Symbol IDs: <5> ::= <16>
  Canonical symbols: [Lex-2] ::= [[\=]]
R3 [Lex-3] ~ [[s]] [[t]] [[r]] [[i]] [[n]] [[g]]
  Symbol IDs: <6> ::= <27> <28> <26> <23> <24> <22>
  Canonical symbols: [Lex-3] ::= [[s]] [[t]] [[r]] [[i]] [[n]] [[g]]
R4 [Lex-4] ~ [[\(]]
  Symbol IDs: <7> ::= <12>
  Canonical symbols: [Lex-4] ::= [[\(]]
R5 [Lex-5] ~ [[\)]]
  Symbol IDs: <8> ::= <13>
  Canonical symbols: [Lex-5] ::= [[\)]]
R6 [Lex-6] ~ [[\+]]
  Symbol IDs: <9> ::= <15>
  Canonical symbols: [Lex-6] ::= [[\+]]
R7 [Lex-7] ~ [[\*]]
  Symbol IDs: <10> ::= <14>
  Canonical symbols: [Lex-7] ::= [[\*]]
R8 variable ~ [[\w]] +
  Symbol IDs: <32> ::= <19>
  Canonical symbols: variable ::= [[\w]]
R9 number ~ [[\d]] +
  Symbol IDs: <29> ::= <17>
  Canonical symbols: number ::= [[\d]]
R10 string ~ [[']] <string contents> [[']]
  Symbol IDs: <30> ::= <11> <31> <11>
  Canonical symbols: string ::= [[']] <string contents> [[']]
R11 <string contents> ~ [[^'\x{0A}\x{0B}\x{0C}\x{0D}\x{0085}\x{2028}\x{2029}]] +
  Symbol IDs: <31> ::= <20>
  Canonical symbols: <string contents> ::= [[^'\x{0A}\x{0B}\x{0C}\x{0D}\x{0085}\x{2028}\x{2029}]]
R12 [:discard:] ~ whitespace
  Symbol IDs: <0> ::= <33>
  Canonical symbols: [:discard:] ::= whitespace
R13 whitespace ~ [[\s]] +
  Symbol IDs: <33> ::= <18>
  Canonical symbols: whitespace ::= [[\s]]
R14 [:lex_start:] ~ [:target:]
  Symbol IDs: <1> ::= <2>
  Canonical symbols: [:lex_start:] ::= [:target:]
R15 [:target:] ~ [:discard:]
  Symbol IDs: <2> ::= <0>
  Canonical symbols: [:target:] ::= [:discard:]
R16 [:target:] ~ [Lex-0]
  Symbol IDs: <2> ::= <3>
  Canonical symbols: [:target:] ::= [Lex-0]
R17 [:target:] ~ [Lex-1]
  Symbol IDs: <2> ::= <4>
  Canonical symbols: [:target:] ::= [Lex-1]
R18 [:target:] ~ [Lex-2]
  Symbol IDs: <2> ::= <5>
  Canonical symbols: [:target:] ::= [Lex-2]
R19 [:target:] ~ [Lex-3]
  Symbol IDs: <2> ::= <6>
  Canonical symbols: [:target:] ::= [Lex-3]
R20 [:target:] ~ [Lex-4]
  Symbol IDs: <2> ::= <7>
  Canonical symbols: [:target:] ::= [Lex-4]
R21 [:target:] ~ [Lex-5]
  Symbol IDs: <2> ::= <8>
  Canonical symbols: [:target:] ::= [Lex-5]
R22 [:target:] ~ [Lex-6]
  Symbol IDs: <2> ::= <9>
  Canonical symbols: [:target:] ::= [Lex-6]
R23 [:target:] ~ [Lex-7]
  Symbol IDs: <2> ::= <10>
  Canonical symbols: [:target:] ::= [Lex-7]
R24 [:target:] ~ number
  Symbol IDs: <2> ::= <29>
  Canonical symbols: [:target:] ::= number
R25 [:target:] ~ string
  Symbol IDs: <2> ::= <30>
  Canonical symbols: [:target:] ::= string
R26 [:target:] ~ variable
  Symbol IDs: <2> ::= <32>
  Canonical symbols: [:target:] ::= variable
END_OF_SHOW_RULES_OUTPUT

my $symbols_show_output;

# Marpa::R3::Display
# name: SLG symbols_show() synopsis

$symbols_show_output = $grammar->symbols_show();

# Marpa::R3::Display::End

Marpa::R3::Test::is( $symbols_show_output,
    <<'END_OF_SHOW_SYMBOLS_OUTPUT', 'symbols_show()' );
S1 [:discard:]
S2 [:lex_start:]
S3 [:start:]
S4 [:target:]
S5 'set'
S6 'to'
S7 '='
S8 'string'
S9 '('
S10 ')'
S11 '+'
S12 '*'
S13 [']
S14 [\(]
S15 [\)]
S16 [\*]
S17 [\+]
S18 [\=]
S19 [\d]
S20 [\s]
S21 [\w]
S22 [^'\x{0A}\x{0B}\x{0C}\x{0D}\x{0085}\x{2028}\x{2029}]
S23 [e]
S24 [g]
S25 [i]
S26 [n]
S27 [o]
S28 [r]
S29 [s]
S30 [t]
S31 assignment
S32 expression
S33 number
S34 <numeric assignment>
S35 <numeric expression>
S36 statement
S37 statements
S38 string
S39 <string contents>
S40 variable
S41 whitespace
END_OF_SHOW_SYMBOLS_OUTPUT

# Marpa::R3::Display
# name: SLG symbols_show() verbose synopsis

$symbols_show_output = $grammar->symbols_show( { verbose => 3 } );

# Marpa::R3::Display::End

# Marpa::R3::Display
# name: debug example symbols_show() output
# start-after-line: END_OF_SHOW_SYMBOLS_OUTPUT
# end-before-line: '^END_OF_SHOW_SYMBOLS_OUTPUT$'

Marpa::R3::Test::is( $symbols_show_output,
    <<'END_OF_SHOW_SYMBOLS_OUTPUT', 'symbols_show() verbose' );
S1 [:discard:]
  Canonical name: [:discard:]
  DSL name: [:discard:]
S2 [:lex_start:]
  Canonical name: [:lex_start:]
  DSL name: [:lex_start:]
S3 [:start:]
  Canonical name: [:start:]
  DSL name: [:start:]
S4 [:target:]
  Canonical name: [:target:]
  DSL name: [:target:]
S5 'set'
  Canonical name: [Lex-0]
  DSL name: 'set'
S6 'to'
  Canonical name: [Lex-1]
  DSL name: 'to'
S7 '='
  Canonical name: [Lex-2]
  DSL name: '='
S8 'string'
  Canonical name: [Lex-3]
  DSL name: 'string'
S9 '('
  Canonical name: [Lex-4]
  DSL name: '('
S10 ')'
  Canonical name: [Lex-5]
  DSL name: ')'
S11 '+'
  Canonical name: [Lex-6]
  DSL name: '+'
S12 '*'
  Canonical name: [Lex-7]
  DSL name: '*'
S13 [']
  Canonical name: [[']]
  DSL name: [']
S14 [\(]
  Canonical name: [[\(]]
  DSL name: [\(]
S15 [\)]
  Canonical name: [[\)]]
  DSL name: [\)]
S16 [\*]
  Canonical name: [[\*]]
  DSL name: [\*]
S17 [\+]
  Canonical name: [[\+]]
  DSL name: [\+]
S18 [\=]
  Canonical name: [[\=]]
  DSL name: [\=]
S19 [\d]
  Canonical name: [[\d]]
  DSL name: [\d]
S20 [\s]
  Canonical name: [[\s]]
  DSL name: [\s]
S21 [\w]
  Canonical name: [[\w]]
  DSL name: [\w]
S22 [^'\x{0A}\x{0B}\x{0C}\x{0D}\x{0085}\x{2028}\x{2029}]
  Canonical name: [[^'\x{0A}\x{0B}\x{0C}\x{0D}\x{0085}\x{2028}\x{2029}]]
  DSL name: [^'\x{0A}\x{0B}\x{0C}\x{0D}\x{0085}\x{2028}\x{2029}]
S23 [e]
  Canonical name: [[e]]
  DSL name: [e]
S24 [g]
  Canonical name: [[g]]
  DSL name: [g]
S25 [i]
  Canonical name: [[i]]
  DSL name: [i]
S26 [n]
  Canonical name: [[n]]
  DSL name: [n]
S27 [o]
  Canonical name: [[o]]
  DSL name: [o]
S28 [r]
  Canonical name: [[r]]
  DSL name: [r]
S29 [s]
  Canonical name: [[s]]
  DSL name: [s]
S30 [t]
  Canonical name: [[t]]
  DSL name: [t]
S31 assignment
  Canonical name: assignment
  DSL name: assignment
S32 expression
  Canonical name: expression
  DSL name: expression
S33 number
  Canonical name: number
  DSL name: number
S34 <numeric assignment>
  Canonical name: <numeric assignment>
  DSL name: numeric assignment
S35 <numeric expression>
  Canonical name: <numeric expression>
  DSL name: numeric expression
S36 statement
  Canonical name: statement
  DSL name: statement
S37 statements
  Canonical name: statements
  DSL name: statements
S38 string
  Canonical name: string
  DSL name: string
S39 <string contents>
  Canonical name: <string contents>
  DSL name: string contents
S40 variable
  Canonical name: variable
  DSL name: variable
S41 whitespace
  Canonical name: whitespace
  DSL name: whitespace
END_OF_SHOW_SYMBOLS_OUTPUT

# Marpa::R3::Display::End

$symbols_show_output = "G1 Symbols:\n";
$symbols_show_output .= $grammar->g1_symbols_show(3);

Marpa::R3::Test::is( $symbols_show_output,
    <<'END_OF_SHOW_SYMBOLS_OUTPUT', 'g1_symbols_show()' );
G1 Symbols:
g1 S0 [:start:]
  /* nsyid=0 */
  Canonical name: [:start:]
  DSL name: [:start:]
g1 S1 'set'
  /* nsyid=2 terminal */
  Canonical name: [Lex-0]
  DSL name: 'set'
g1 S2 'to'
  /* nsyid=3 terminal */
  Canonical name: [Lex-1]
  DSL name: 'to'
g1 S3 '='
  /* nsyid=4 terminal */
  Canonical name: [Lex-2]
  DSL name: '='
g1 S4 'string'
  /* nsyid=5 terminal */
  Canonical name: [Lex-3]
  DSL name: 'string'
g1 S5 '('
  /* nsyid=6 terminal */
  Canonical name: [Lex-4]
  DSL name: '('
g1 S6 ')'
  /* nsyid=7 terminal */
  Canonical name: [Lex-5]
  DSL name: ')'
g1 S7 '+'
  /* nsyid=8 terminal */
  Canonical name: [Lex-6]
  DSL name: '+'
g1 S8 '*'
  /* nsyid=9 terminal */
  Canonical name: [Lex-7]
  DSL name: '*'
g1 S9 assignment
  /* nsyid=10 */
  Canonical name: assignment
  DSL name: assignment
g1 S10 expression
  /* nsyid=11 */
  Canonical name: expression
  DSL name: expression
g1 S11 expression
  /* nsyid=12 */
  Canonical name: <expression[0]>
  DSL name: expression
g1 S12 expression
  /* nsyid=13 */
  Canonical name: <expression[1]>
  DSL name: expression
g1 S13 expression
  /* nsyid=14 */
  Canonical name: <expression[2]>
  DSL name: expression
g1 S14 number
  /* nsyid=15 terminal */
  Canonical name: number
  DSL name: number
g1 S15 <numeric assignment>
  /* nsyid=16 */
  Canonical name: <numeric assignment>
  DSL name: numeric assignment
g1 S16 <numeric expression>
  /* nsyid=17 */
  Canonical name: <numeric expression>
  DSL name: numeric expression
g1 S17 <numeric expression>
  /* nsyid=18 */
  Canonical name: <numeric expression[0]>
  DSL name: numeric expression
g1 S18 <numeric expression>
  /* nsyid=19 */
  Canonical name: <numeric expression[1]>
  DSL name: numeric expression
g1 S19 <numeric expression>
  /* nsyid=20 */
  Canonical name: <numeric expression[2]>
  DSL name: numeric expression
g1 S20 statement
  /* nsyid=21 */
  Canonical name: statement
  DSL name: statement
g1 S21 statements
  /* nsyid=22 */
  Canonical name: statements
  DSL name: statements
g1 S22 string
  /* nsyid=24 terminal */
  Canonical name: string
  DSL name: string
g1 S23 variable
  /* nsyid=25 terminal */
  Canonical name: variable
  DSL name: variable
END_OF_SHOW_SYMBOLS_OUTPUT

$symbols_show_output = "L0 Symbols:\n";
$symbols_show_output .= $grammar->l0_symbols_show(3);

Marpa::R3::Test::is( $symbols_show_output,
    <<'END_OF_SHOW_SYMBOLS_OUTPUT', 'l0_symbols_show()' );
L0 Symbols:
l0 S0 [:discard:]
  /* nsyid=0 */
  Canonical name: [:discard:]
  DSL name: [:discard:]
l0 S1 [:lex_start:]
  /* nsyid=1 */
  Canonical name: [:lex_start:]
  DSL name: [:lex_start:]
l0 S2 [:target:]
  /* nsyid=2 */
  Canonical name: [:target:]
  DSL name: [:target:]
l0 S3 'set'
  /* nsyid=3 */
  Canonical name: [Lex-0]
  DSL name: 'set'
l0 S4 'to'
  /* nsyid=4 */
  Canonical name: [Lex-1]
  DSL name: 'to'
l0 S5 '='
  /* nsyid=5 */
  Canonical name: [Lex-2]
  DSL name: '='
l0 S6 'string'
  /* nsyid=6 */
  Canonical name: [Lex-3]
  DSL name: 'string'
l0 S7 '('
  /* nsyid=7 */
  Canonical name: [Lex-4]
  DSL name: '('
l0 S8 ')'
  /* nsyid=8 */
  Canonical name: [Lex-5]
  DSL name: ')'
l0 S9 '+'
  /* nsyid=9 */
  Canonical name: [Lex-6]
  DSL name: '+'
l0 S10 '*'
  /* nsyid=10 */
  Canonical name: [Lex-7]
  DSL name: '*'
l0 S11 [']
  /* nsyid=11 terminal */
  Canonical name: [[']]
  DSL name: [']
l0 S12 [\(]
  /* nsyid=12 terminal */
  Canonical name: [[\(]]
  DSL name: [\(]
l0 S13 [\)]
  /* nsyid=13 terminal */
  Canonical name: [[\)]]
  DSL name: [\)]
l0 S14 [\*]
  /* nsyid=14 terminal */
  Canonical name: [[\*]]
  DSL name: [\*]
l0 S15 [\+]
  /* nsyid=15 terminal */
  Canonical name: [[\+]]
  DSL name: [\+]
l0 S16 [\=]
  /* nsyid=16 terminal */
  Canonical name: [[\=]]
  DSL name: [\=]
l0 S17 [\d]
  /* nsyid=17 terminal */
  Canonical name: [[\d]]
  DSL name: [\d]
l0 S18 [\s]
  /* nsyid=18 terminal */
  Canonical name: [[\s]]
  DSL name: [\s]
l0 S19 [\w]
  /* nsyid=19 terminal */
  Canonical name: [[\w]]
  DSL name: [\w]
l0 S20 [^'\x{0A}\x{0B}\x{0C}\x{0D}\x{0085}\x{2028}\x{2029}]
  /* nsyid=20 terminal */
  Canonical name: [[^'\x{0A}\x{0B}\x{0C}\x{0D}\x{0085}\x{2028}\x{2029}]]
  DSL name: [^'\x{0A}\x{0B}\x{0C}\x{0D}\x{0085}\x{2028}\x{2029}]
l0 S21 [e]
  /* nsyid=21 terminal */
  Canonical name: [[e]]
  DSL name: [e]
l0 S22 [g]
  /* nsyid=22 terminal */
  Canonical name: [[g]]
  DSL name: [g]
l0 S23 [i]
  /* nsyid=23 terminal */
  Canonical name: [[i]]
  DSL name: [i]
l0 S24 [n]
  /* nsyid=24 terminal */
  Canonical name: [[n]]
  DSL name: [n]
l0 S25 [o]
  /* nsyid=25 terminal */
  Canonical name: [[o]]
  DSL name: [o]
l0 S26 [r]
  /* nsyid=26 terminal */
  Canonical name: [[r]]
  DSL name: [r]
l0 S27 [s]
  /* nsyid=27 terminal */
  Canonical name: [[s]]
  DSL name: [s]
l0 S28 [t]
  /* nsyid=28 terminal */
  Canonical name: [[t]]
  DSL name: [t]
l0 S29 number
  /* nsyid=29 */
  Canonical name: number
  DSL name: number
l0 S30 string
  /* nsyid=30 */
  Canonical name: string
  DSL name: string
l0 S31 <string contents>
  /* nsyid=31 */
  Canonical name: <string contents>
  DSL name: string contents
l0 S32 variable
  /* nsyid=32 */
  Canonical name: variable
  DSL name: variable
l0 S33 whitespace
  /* nsyid=33 */
  Canonical name: whitespace
  DSL name: whitespace
END_OF_SHOW_SYMBOLS_OUTPUT

our @TEST_ARRAY;
sub do_something { push @TEST_ARRAY, $_[0] }

@TEST_ARRAY = ();

# Marpa::R3::Display
# name: SLG symbol_ids_gen() synopsis

for (
    my $iter = $grammar->symbol_ids_gen() ;
    defined( my $symbol_id = $iter->() ) ;
  )
{
    do_something($symbol_id);
}

# Marpa::R3::Display::End

my $symbol_show_results = q{};

sub symbol_faire_des_choses {
    my ($symbol_id) = @_;
    my $dot_position = 0;

# Marpa::R3::Display
# name: SLG symbol_show() synopsis

    $symbol_show_results .= $grammar->symbol_show($symbol_id);

# Marpa::R3::Display::End

}

# Marpa::R3::Display
# name: SLG highest_symbol_id() synopsis

my $max_symbol_id = $grammar->highest_symbol_id();
for ( my $symbol_id = 1 ; $symbol_id <= $max_symbol_id ; $symbol_id++ ) {
    symbol_faire_des_choses($symbol_id);
}

# Marpa::R3::Display::End

Marpa::R3::Test::is( $symbol_show_results, <<'END_OF_TEXT', 'symbol_show() by id');
S1 [:discard:]
S2 [:lex_start:]
S3 [:start:]
S4 [:target:]
S5 'set'
S6 'to'
S7 '='
S8 'string'
S9 '('
S10 ')'
S11 '+'
S12 '*'
S13 [']
S14 [\(]
S15 [\)]
S16 [\*]
S17 [\+]
S18 [\=]
S19 [\d]
S20 [\s]
S21 [\w]
S22 [^'\x{0A}\x{0B}\x{0C}\x{0D}\x{0085}\x{2028}\x{2029}]
S23 [e]
S24 [g]
S25 [i]
S26 [n]
S27 [o]
S28 [r]
S29 [s]
S30 [t]
S31 assignment
S32 expression
S33 number
S34 <numeric assignment>
S35 <numeric expression>
S36 statement
S37 statements
S38 string
S39 <string contents>
S40 variable
S41 whitespace
END_OF_TEXT

Marpa::R3::Test::is(
    ( join "\n", @TEST_ARRAY ),
    ( join "\n", 1 .. 41 ),
    'Symbol ids'
);

@TEST_ARRAY = ();

for (
    my $iter = $grammar->g1_symbol_ids_gen() ;
    defined( my $symbol_id = $iter->() ) ;
  )
{
    do_something($symbol_id);
}

Marpa::R3::Test::is(
    ( join "\n", @TEST_ARRAY ),
    ( join "\n", 0 .. 23 ),
    'G1 symbol ids'
);

@TEST_ARRAY = ();

for (
    my $iter = $grammar->l0_symbol_ids_gen() ;
    defined( my $symbol_id = $iter->() ) ;
  )
{
    do_something($symbol_id);
}

Marpa::R3::Test::is(
    ( join "\n", @TEST_ARRAY ),
    ( join "\n", 0 .. 33 ),
    'L0 symbol ids'
);

my $text;

$text = q{};

for (
    my $iter = $grammar->symbol_ids_gen() ;
    defined( my $symbol_id = $iter->() ) ;
  ) {

# Marpa::R3::Display
# name: SLG symbol_name() synopsis

    my $name = $grammar->symbol_name($symbol_id);
    $text .= "symbol number: $symbol_id; name: $name\n";

# Marpa::R3::Display::End

# Marpa::R3::Display
# name: SLG symbol_display_form() synopsis

    my $display_form = $grammar->symbol_display_form($symbol_id);
    $text
        .= "symbol number: $symbol_id; name in display form: $display_form\n";

# Marpa::R3::Display::End

# Marpa::R3::Display
# name: SLG symbol_dsl_form() synopsis

    my $dsl_form = $grammar->symbol_dsl_form($symbol_id)
        // '[No name in DSL form]';
    $text .= "symbol number: $symbol_id; DSL form: $dsl_form\n";

# Marpa::R3::Display::End

}

Marpa::R3::Test::is( $text, <<'END_OF_TEXT', 'Symbol names and description');
symbol number: 1; name: [:discard:]
symbol number: 1; name in display form: [:discard:]
symbol number: 1; DSL form: [:discard:]
symbol number: 2; name: [:lex_start:]
symbol number: 2; name in display form: [:lex_start:]
symbol number: 2; DSL form: [:lex_start:]
symbol number: 3; name: [:start:]
symbol number: 3; name in display form: [:start:]
symbol number: 3; DSL form: [:start:]
symbol number: 4; name: [:target:]
symbol number: 4; name in display form: [:target:]
symbol number: 4; DSL form: [:target:]
symbol number: 5; name: [Lex-0]
symbol number: 5; name in display form: 'set'
symbol number: 5; DSL form: 'set'
symbol number: 6; name: [Lex-1]
symbol number: 6; name in display form: 'to'
symbol number: 6; DSL form: 'to'
symbol number: 7; name: [Lex-2]
symbol number: 7; name in display form: '='
symbol number: 7; DSL form: '='
symbol number: 8; name: [Lex-3]
symbol number: 8; name in display form: 'string'
symbol number: 8; DSL form: 'string'
symbol number: 9; name: [Lex-4]
symbol number: 9; name in display form: '('
symbol number: 9; DSL form: '('
symbol number: 10; name: [Lex-5]
symbol number: 10; name in display form: ')'
symbol number: 10; DSL form: ')'
symbol number: 11; name: [Lex-6]
symbol number: 11; name in display form: '+'
symbol number: 11; DSL form: '+'
symbol number: 12; name: [Lex-7]
symbol number: 12; name in display form: '*'
symbol number: 12; DSL form: '*'
symbol number: 13; name: [[']]
symbol number: 13; name in display form: [']
symbol number: 13; DSL form: [']
symbol number: 14; name: [[\(]]
symbol number: 14; name in display form: [\(]
symbol number: 14; DSL form: [\(]
symbol number: 15; name: [[\)]]
symbol number: 15; name in display form: [\)]
symbol number: 15; DSL form: [\)]
symbol number: 16; name: [[\*]]
symbol number: 16; name in display form: [\*]
symbol number: 16; DSL form: [\*]
symbol number: 17; name: [[\+]]
symbol number: 17; name in display form: [\+]
symbol number: 17; DSL form: [\+]
symbol number: 18; name: [[\=]]
symbol number: 18; name in display form: [\=]
symbol number: 18; DSL form: [\=]
symbol number: 19; name: [[\d]]
symbol number: 19; name in display form: [\d]
symbol number: 19; DSL form: [\d]
symbol number: 20; name: [[\s]]
symbol number: 20; name in display form: [\s]
symbol number: 20; DSL form: [\s]
symbol number: 21; name: [[\w]]
symbol number: 21; name in display form: [\w]
symbol number: 21; DSL form: [\w]
symbol number: 22; name: [[^'\x{0A}\x{0B}\x{0C}\x{0D}\x{0085}\x{2028}\x{2029}]]
symbol number: 22; name in display form: [^'\x{0A}\x{0B}\x{0C}\x{0D}\x{0085}\x{2028}\x{2029}]
symbol number: 22; DSL form: [^'\x{0A}\x{0B}\x{0C}\x{0D}\x{0085}\x{2028}\x{2029}]
symbol number: 23; name: [[e]]
symbol number: 23; name in display form: [e]
symbol number: 23; DSL form: [e]
symbol number: 24; name: [[g]]
symbol number: 24; name in display form: [g]
symbol number: 24; DSL form: [g]
symbol number: 25; name: [[i]]
symbol number: 25; name in display form: [i]
symbol number: 25; DSL form: [i]
symbol number: 26; name: [[n]]
symbol number: 26; name in display form: [n]
symbol number: 26; DSL form: [n]
symbol number: 27; name: [[o]]
symbol number: 27; name in display form: [o]
symbol number: 27; DSL form: [o]
symbol number: 28; name: [[r]]
symbol number: 28; name in display form: [r]
symbol number: 28; DSL form: [r]
symbol number: 29; name: [[s]]
symbol number: 29; name in display form: [s]
symbol number: 29; DSL form: [s]
symbol number: 30; name: [[t]]
symbol number: 30; name in display form: [t]
symbol number: 30; DSL form: [t]
symbol number: 31; name: assignment
symbol number: 31; name in display form: assignment
symbol number: 31; DSL form: assignment
symbol number: 32; name: expression
symbol number: 32; name in display form: expression
symbol number: 32; DSL form: expression
symbol number: 33; name: number
symbol number: 33; name in display form: number
symbol number: 33; DSL form: number
symbol number: 34; name: numeric assignment
symbol number: 34; name in display form: <numeric assignment>
symbol number: 34; DSL form: numeric assignment
symbol number: 35; name: numeric expression
symbol number: 35; name in display form: <numeric expression>
symbol number: 35; DSL form: numeric expression
symbol number: 36; name: statement
symbol number: 36; name in display form: statement
symbol number: 36; DSL form: statement
symbol number: 37; name: statements
symbol number: 37; name in display form: statements
symbol number: 37; DSL form: statements
symbol number: 38; name: string
symbol number: 38; name in display form: string
symbol number: 38; DSL form: string
symbol number: 39; name: string contents
symbol number: 39; name in display form: <string contents>
symbol number: 39; DSL form: string contents
symbol number: 40; name: variable
symbol number: 40; name in display form: variable
symbol number: 40; DSL form: variable
symbol number: 41; name: whitespace
symbol number: 41; name in display form: whitespace
symbol number: 41; DSL form: whitespace
END_OF_TEXT

$text = q{};

for (
    my $iter = $grammar->g1_symbol_ids_gen() ;
    defined( my $symbol_id = $iter->() ) ;
  )
{

    my $name = $grammar->g1_symbol_name($symbol_id);
    $text .= "symbol number: $symbol_id  name: $name\n";

    my $display_form = $grammar->g1_symbol_display_form($symbol_id);
    $text
        .= "symbol number: $symbol_id  name in display form: $display_form\n";

    my $dsl_form = $grammar->g1_symbol_dsl_form($symbol_id)
        // '[No name in DSL form]';
    $text .= "symbol number: $symbol_id  DSL form: $dsl_form\n";

}

Marpa::R3::Test::is( $text, <<'END_OF_TEXT', 'G1 symbol names and description');
symbol number: 0  name: [:start:]
symbol number: 0  name in display form: [:start:]
symbol number: 0  DSL form: [:start:]
symbol number: 1  name: [Lex-0]
symbol number: 1  name in display form: 'set'
symbol number: 1  DSL form: 'set'
symbol number: 2  name: [Lex-1]
symbol number: 2  name in display form: 'to'
symbol number: 2  DSL form: 'to'
symbol number: 3  name: [Lex-2]
symbol number: 3  name in display form: '='
symbol number: 3  DSL form: '='
symbol number: 4  name: [Lex-3]
symbol number: 4  name in display form: 'string'
symbol number: 4  DSL form: 'string'
symbol number: 5  name: [Lex-4]
symbol number: 5  name in display form: '('
symbol number: 5  DSL form: '('
symbol number: 6  name: [Lex-5]
symbol number: 6  name in display form: ')'
symbol number: 6  DSL form: ')'
symbol number: 7  name: [Lex-6]
symbol number: 7  name in display form: '+'
symbol number: 7  DSL form: '+'
symbol number: 8  name: [Lex-7]
symbol number: 8  name in display form: '*'
symbol number: 8  DSL form: '*'
symbol number: 9  name: assignment
symbol number: 9  name in display form: assignment
symbol number: 9  DSL form: assignment
symbol number: 10  name: expression
symbol number: 10  name in display form: expression
symbol number: 10  DSL form: expression
symbol number: 11  name: expression[0]
symbol number: 11  name in display form: expression
symbol number: 11  DSL form: expression
symbol number: 12  name: expression[1]
symbol number: 12  name in display form: expression
symbol number: 12  DSL form: expression
symbol number: 13  name: expression[2]
symbol number: 13  name in display form: expression
symbol number: 13  DSL form: expression
symbol number: 14  name: number
symbol number: 14  name in display form: number
symbol number: 14  DSL form: number
symbol number: 15  name: numeric assignment
symbol number: 15  name in display form: <numeric assignment>
symbol number: 15  DSL form: numeric assignment
symbol number: 16  name: numeric expression
symbol number: 16  name in display form: <numeric expression>
symbol number: 16  DSL form: numeric expression
symbol number: 17  name: numeric expression[0]
symbol number: 17  name in display form: <numeric expression>
symbol number: 17  DSL form: numeric expression
symbol number: 18  name: numeric expression[1]
symbol number: 18  name in display form: <numeric expression>
symbol number: 18  DSL form: numeric expression
symbol number: 19  name: numeric expression[2]
symbol number: 19  name in display form: <numeric expression>
symbol number: 19  DSL form: numeric expression
symbol number: 20  name: statement
symbol number: 20  name in display form: statement
symbol number: 20  DSL form: statement
symbol number: 21  name: statements
symbol number: 21  name in display form: statements
symbol number: 21  DSL form: statements
symbol number: 22  name: string
symbol number: 22  name in display form: string
symbol number: 22  DSL form: string
symbol number: 23  name: variable
symbol number: 23  name in display form: variable
symbol number: 23  DSL form: variable
END_OF_TEXT

$text = '';

for (
    my $iter = $grammar->l0_symbol_ids_gen() ;
    defined( my $symbol_id = $iter->() ) ;
  )
{

    my $name = $grammar->l0_symbol_name( $symbol_id );
    $text .= "l0 symbol number: $symbol_id  name: $name\n";

    my $display_form = $grammar->l0_symbol_display_form( $symbol_id );
    $text
        .= "l0 symbol number: $symbol_id  name in display form: $display_form\n";

    my $dsl_form = $grammar->l0_symbol_dsl_form( $symbol_id )
        // '[No name in DSL form]';
    $text .= "l0 symbol number: $symbol_id  DSL form: $dsl_form\n";

}

Marpa::R3::Test::is( $text, <<'END_OF_TEXT', 'L0 symbol names and description');
l0 symbol number: 0  name: [:discard:]
l0 symbol number: 0  name in display form: [:discard:]
l0 symbol number: 0  DSL form: [:discard:]
l0 symbol number: 1  name: [:lex_start:]
l0 symbol number: 1  name in display form: [:lex_start:]
l0 symbol number: 1  DSL form: [:lex_start:]
l0 symbol number: 2  name: [:target:]
l0 symbol number: 2  name in display form: [:target:]
l0 symbol number: 2  DSL form: [:target:]
l0 symbol number: 3  name: [Lex-0]
l0 symbol number: 3  name in display form: 'set'
l0 symbol number: 3  DSL form: 'set'
l0 symbol number: 4  name: [Lex-1]
l0 symbol number: 4  name in display form: 'to'
l0 symbol number: 4  DSL form: 'to'
l0 symbol number: 5  name: [Lex-2]
l0 symbol number: 5  name in display form: '='
l0 symbol number: 5  DSL form: '='
l0 symbol number: 6  name: [Lex-3]
l0 symbol number: 6  name in display form: 'string'
l0 symbol number: 6  DSL form: 'string'
l0 symbol number: 7  name: [Lex-4]
l0 symbol number: 7  name in display form: '('
l0 symbol number: 7  DSL form: '('
l0 symbol number: 8  name: [Lex-5]
l0 symbol number: 8  name in display form: ')'
l0 symbol number: 8  DSL form: ')'
l0 symbol number: 9  name: [Lex-6]
l0 symbol number: 9  name in display form: '+'
l0 symbol number: 9  DSL form: '+'
l0 symbol number: 10  name: [Lex-7]
l0 symbol number: 10  name in display form: '*'
l0 symbol number: 10  DSL form: '*'
l0 symbol number: 11  name: [[']]
l0 symbol number: 11  name in display form: [']
l0 symbol number: 11  DSL form: [']
l0 symbol number: 12  name: [[\(]]
l0 symbol number: 12  name in display form: [\(]
l0 symbol number: 12  DSL form: [\(]
l0 symbol number: 13  name: [[\)]]
l0 symbol number: 13  name in display form: [\)]
l0 symbol number: 13  DSL form: [\)]
l0 symbol number: 14  name: [[\*]]
l0 symbol number: 14  name in display form: [\*]
l0 symbol number: 14  DSL form: [\*]
l0 symbol number: 15  name: [[\+]]
l0 symbol number: 15  name in display form: [\+]
l0 symbol number: 15  DSL form: [\+]
l0 symbol number: 16  name: [[\=]]
l0 symbol number: 16  name in display form: [\=]
l0 symbol number: 16  DSL form: [\=]
l0 symbol number: 17  name: [[\d]]
l0 symbol number: 17  name in display form: [\d]
l0 symbol number: 17  DSL form: [\d]
l0 symbol number: 18  name: [[\s]]
l0 symbol number: 18  name in display form: [\s]
l0 symbol number: 18  DSL form: [\s]
l0 symbol number: 19  name: [[\w]]
l0 symbol number: 19  name in display form: [\w]
l0 symbol number: 19  DSL form: [\w]
l0 symbol number: 20  name: [[^'\x{0A}\x{0B}\x{0C}\x{0D}\x{0085}\x{2028}\x{2029}]]
l0 symbol number: 20  name in display form: [^'\x{0A}\x{0B}\x{0C}\x{0D}\x{0085}\x{2028}\x{2029}]
l0 symbol number: 20  DSL form: [^'\x{0A}\x{0B}\x{0C}\x{0D}\x{0085}\x{2028}\x{2029}]
l0 symbol number: 21  name: [[e]]
l0 symbol number: 21  name in display form: [e]
l0 symbol number: 21  DSL form: [e]
l0 symbol number: 22  name: [[g]]
l0 symbol number: 22  name in display form: [g]
l0 symbol number: 22  DSL form: [g]
l0 symbol number: 23  name: [[i]]
l0 symbol number: 23  name in display form: [i]
l0 symbol number: 23  DSL form: [i]
l0 symbol number: 24  name: [[n]]
l0 symbol number: 24  name in display form: [n]
l0 symbol number: 24  DSL form: [n]
l0 symbol number: 25  name: [[o]]
l0 symbol number: 25  name in display form: [o]
l0 symbol number: 25  DSL form: [o]
l0 symbol number: 26  name: [[r]]
l0 symbol number: 26  name in display form: [r]
l0 symbol number: 26  DSL form: [r]
l0 symbol number: 27  name: [[s]]
l0 symbol number: 27  name in display form: [s]
l0 symbol number: 27  DSL form: [s]
l0 symbol number: 28  name: [[t]]
l0 symbol number: 28  name in display form: [t]
l0 symbol number: 28  DSL form: [t]
l0 symbol number: 29  name: number
l0 symbol number: 29  name in display form: number
l0 symbol number: 29  DSL form: number
l0 symbol number: 30  name: string
l0 symbol number: 30  name in display form: string
l0 symbol number: 30  DSL form: string
l0 symbol number: 31  name: string contents
l0 symbol number: 31  name in display form: <string contents>
l0 symbol number: 31  DSL form: string contents
l0 symbol number: 32  name: variable
l0 symbol number: 32  name in display form: variable
l0 symbol number: 32  DSL form: variable
l0 symbol number: 33  name: whitespace
l0 symbol number: 33  name in display form: whitespace
l0 symbol number: 33  DSL form: whitespace
END_OF_TEXT

$text = q{};

sub do_production_things {
}

for (
    my $iter = $grammar->production_ids_gen() ;
    defined( my $prid = $iter->() ) ;
  )
{

# Marpa::R3::Display
# name: SLG production_show() synopsis

    my $production_description = $grammar->production_show($prid);

# Marpa::R3::Display::End

    if (not defined $production_description) {
        $text .= "[No such production, ID #$prid]\n";
    } else {
        $text .= "$production_description\n";
    }

}

Marpa::R3::Test::is( $text, <<'END_OF_TEXT', 'production_show() by id');
[:start:] ::= statements
statement ::= <numeric assignment>
assignment ::= 'set' variable 'to' expression
<numeric assignment> ::= variable '=' <numeric expression>
expression ::= expression; prec=-1
expression ::= expression; prec=0
expression ::= expression; prec=1
expression ::= variable; prec=2
expression ::= string; prec=2
expression ::= 'string' '(' <numeric expression> ')'; prec=1
expression ::= expression '+' expression; prec=0
<numeric expression> ::= <numeric expression>; prec=-1
<numeric expression> ::= <numeric expression>; prec=0
<numeric expression> ::= <numeric expression>; prec=1
<numeric expression> ::= variable; prec=2
<numeric expression> ::= number; prec=2
<numeric expression> ::= <numeric expression> '*' <numeric expression>; prec=1
statements ::= statement *
<numeric expression> ::= <numeric expression> '+' <numeric expression>; prec=0
statement ::= assignment
[:lex_start:] ~ [:target:]
[:target:] ~ [:discard:]
[:target:] ~ 'set'
[:target:] ~ 'to'
[:target:] ~ '='
[:target:] ~ 'string'
[:target:] ~ '('
[:target:] ~ ')'
[:target:] ~ '+'
[:target:] ~ '*'
[:target:] ~ number
[:target:] ~ string
[:target:] ~ variable
'set' ~ [s] [e] [t]
'to' ~ [t] [o]
'=' ~ [\=]
'string' ~ [s] [t] [r] [i] [n] [g]
'(' ~ [\(]
')' ~ [\)]
'+' ~ [\+]
'*' ~ [\*]
variable ~ [\w] +
number ~ [\d] +
string ~ ['] <string contents> [']
<string contents> ~ [^'\x{0A}\x{0B}\x{0C}\x{0D}\x{0085}\x{2028}\x{2029}] +
[:discard:] ~ whitespace
whitespace ~ [\s] +
END_OF_TEXT

$text = q{};

for (
    my $iter = $grammar->g1_rule_ids_gen() ;
    defined( my $rule_id = $iter->() ) ;
  )
{

    my $rule_description = $grammar->g1_rule_show($rule_id);

    if (not defined $rule_description) {
        $text .= "[No such rule, ID #$rule_id]\n";
    } else {
        $text .= "$rule_description\n";
    }

}

Marpa::R3::Test::is( $text, <<'END_OF_TEXT', 'G1 rule_show() by rule id');
statements ::= statement *
statement ::= assignment
statement ::= <numeric assignment>
assignment ::= 'set' variable 'to' expression
<numeric assignment> ::= variable '=' <numeric expression>
expression ::= expression
expression ::= expression
expression ::= expression
expression ::= variable
expression ::= string
expression ::= 'string' '(' <numeric expression> ')'
expression ::= expression '+' expression
<numeric expression> ::= <numeric expression>
<numeric expression> ::= <numeric expression>
<numeric expression> ::= <numeric expression>
<numeric expression> ::= variable
<numeric expression> ::= number
<numeric expression> ::= <numeric expression> '*' <numeric expression>
<numeric expression> ::= <numeric expression> '+' <numeric expression>
[:start:] ::= statements
END_OF_TEXT

$text = q{};

for (
    my $iter = $grammar->l0_rule_ids_gen() ;
    defined( my $rule_id = $iter->() ) ;
  )
{

    my $rule_description = $grammar->l0_rule_show($rule_id);

    if (not defined $rule_description) {
        $text .= "[No such rule, ID #$rule_id]\n";
    } else {
        $text .= "$rule_description\n";
    }

}

Marpa::R3::Test::is( $text, <<'END_OF_TEXT', 'L0 rule_show() by rule id');
'set' ~ [s] [e] [t]
'to' ~ [t] [o]
'=' ~ [\=]
'string' ~ [s] [t] [r] [i] [n] [g]
'(' ~ [\(]
')' ~ [\)]
'+' ~ [\+]
'*' ~ [\*]
variable ~ [\w] +
number ~ [\d] +
string ~ ['] <string contents> [']
<string contents> ~ [^'\x{0A}\x{0B}\x{0C}\x{0D}\x{0085}\x{2028}\x{2029}] +
[:discard:] ~ whitespace
whitespace ~ [\s] +
[:lex_start:] ~ [:target:]
[:target:] ~ [:discard:]
[:target:] ~ 'set'
[:target:] ~ 'to'
[:target:] ~ '='
[:target:] ~ 'string'
[:target:] ~ '('
[:target:] ~ ')'
[:target:] ~ '+'
[:target:] ~ '*'
[:target:] ~ number
[:target:] ~ string
[:target:] ~ variable
END_OF_TEXT

$text = q{};

for (
    my $iter = $grammar->production_ids_gen() ;
    defined( my $prid = $iter->() ) ;
  )
{

    my $production_description =
      $grammar->production_show( $prid, { diag => 1 } );

    if (not defined $production_description) {
        $text .= "[No such production, ID #$prid]\n";
    } else {
        $text .= "$production_description\n";
    }

}

Marpa::R3::Test::is( $text, <<'END_OF_TEXT', 'production_show() diag form by id');
[:start:] ::= statements
statement ::= <numeric assignment>
assignment ::= [Lex-0] variable [Lex-1] expression
<numeric assignment> ::= variable [Lex-2] <numeric expression>
expression ::= expression; prec=-1
expression ::= expression; prec=0
expression ::= expression; prec=1
expression ::= variable; prec=2
expression ::= string; prec=2
expression ::= [Lex-3] [Lex-4] <numeric expression> [Lex-5]; prec=1
expression ::= expression [Lex-6] expression; prec=0
<numeric expression> ::= <numeric expression>; prec=-1
<numeric expression> ::= <numeric expression>; prec=0
<numeric expression> ::= <numeric expression>; prec=1
<numeric expression> ::= variable; prec=2
<numeric expression> ::= number; prec=2
<numeric expression> ::= <numeric expression> [Lex-7] <numeric expression>; prec=1
statements ::= statement *
<numeric expression> ::= <numeric expression> [Lex-6] <numeric expression>; prec=0
statement ::= assignment
[:lex_start:] ~ [:target:]
[:target:] ~ [:discard:]
[:target:] ~ [Lex-0]
[:target:] ~ [Lex-1]
[:target:] ~ [Lex-2]
[:target:] ~ [Lex-3]
[:target:] ~ [Lex-4]
[:target:] ~ [Lex-5]
[:target:] ~ [Lex-6]
[:target:] ~ [Lex-7]
[:target:] ~ number
[:target:] ~ string
[:target:] ~ variable
[Lex-0] ~ [[s]] [[e]] [[t]]
[Lex-1] ~ [[t]] [[o]]
[Lex-2] ~ [[\=]]
[Lex-3] ~ [[s]] [[t]] [[r]] [[i]] [[n]] [[g]]
[Lex-4] ~ [[\(]]
[Lex-5] ~ [[\)]]
[Lex-6] ~ [[\+]]
[Lex-7] ~ [[\*]]
variable ~ [[\w]] +
number ~ [[\d]] +
string ~ [[']] <string contents> [[']]
<string contents> ~ [[^'\x{0A}\x{0B}\x{0C}\x{0D}\x{0085}\x{2028}\x{2029}]] +
[:discard:] ~ whitespace
whitespace ~ [[\s]] +
END_OF_TEXT

$text = q{};

for (
    my $iter = $grammar->g1_rule_ids_gen() ;
    defined( my $rule_id = $iter->() ) ;
  )
{

    my $rule_description = $grammar->g1_rule_show( $rule_id, { diag => 1 } );

    if (not defined $rule_description) {
        $text .= "[No such rule, ID #$rule_id]\n";
    } else {
        $text .= "$rule_description\n";
    }

}

Marpa::R3::Test::is( $text, <<'END_OF_TEXT', 'G1 rule_show() diag form by rule id');
statements ::= statement *
statement ::= assignment
statement ::= <numeric assignment>
assignment ::= [Lex-0] variable [Lex-1] expression
<numeric assignment> ::= variable [Lex-2] <numeric expression>
expression ::= <expression[0]>
<expression[0]> ::= <expression[1]>
<expression[1]> ::= <expression[2]>
<expression[2]> ::= variable
<expression[2]> ::= string
<expression[1]> ::= [Lex-3] [Lex-4] <numeric expression> [Lex-5]
<expression[0]> ::= <expression[0]> [Lex-6] <expression[1]>
<numeric expression> ::= <numeric expression[0]>
<numeric expression[0]> ::= <numeric expression[1]>
<numeric expression[1]> ::= <numeric expression[2]>
<numeric expression[2]> ::= variable
<numeric expression[2]> ::= number
<numeric expression[1]> ::= <numeric expression[1]> [Lex-7] <numeric expression[2]>
<numeric expression[0]> ::= <numeric expression[0]> [Lex-6] <numeric expression[1]>
[:start:] ::= statements
END_OF_TEXT

$text = q{};

for (
    my $iter = $grammar->l0_rule_ids_gen() ;
    defined( my $rule_id = $iter->() ) ;
  )
{

    my $rule_description = $grammar->l0_rule_show( $rule_id, { diag => 1 } );

    if (not defined $rule_description) {
        $text .= "[No such rule, ID #$rule_id]\n";
    } else {
        $text .= "$rule_description\n";
    }

}

Marpa::R3::Test::is( $text, <<'END_OF_TEXT', 'L0 rule_show() diag form by rule id');
[Lex-0] ~ [[s]] [[e]] [[t]]
[Lex-1] ~ [[t]] [[o]]
[Lex-2] ~ [[\=]]
[Lex-3] ~ [[s]] [[t]] [[r]] [[i]] [[n]] [[g]]
[Lex-4] ~ [[\(]]
[Lex-5] ~ [[\)]]
[Lex-6] ~ [[\+]]
[Lex-7] ~ [[\*]]
variable ~ [[\w]] +
number ~ [[\d]] +
string ~ [[']] <string contents> [[']]
<string contents> ~ [[^'\x{0A}\x{0B}\x{0C}\x{0D}\x{0085}\x{2028}\x{2029}]] +
[:discard:] ~ whitespace
whitespace ~ [[\s]] +
[:lex_start:] ~ [:target:]
[:target:] ~ [:discard:]
[:target:] ~ [Lex-0]
[:target:] ~ [Lex-1]
[:target:] ~ [Lex-2]
[:target:] ~ [Lex-3]
[:target:] ~ [Lex-4]
[:target:] ~ [Lex-5]
[:target:] ~ [Lex-6]
[:target:] ~ [Lex-7]
[:target:] ~ number
[:target:] ~ string
[:target:] ~ variable
END_OF_TEXT

@TEST_ARRAY = ();

# Marpa::R3::Display
# name: SLG production_ids_gen() synopsis

for (
    my $iter = $grammar->production_ids_gen() ;
    defined( my $prid = $iter->() ) ;
  )
{
    do_something($prid);
}

# Marpa::R3::Display::End

Marpa::R3::Test::is(
    ( join "\n", @TEST_ARRAY, '' ),
    ( join "\n", 1 .. 47, '' ),
    'production ids'
);

@TEST_ARRAY = ();

for (
    my $iter = $grammar->g1_rule_ids_gen() ;
    defined( my $rule_id = $iter->() ) ;
  )
{
    do_something($rule_id);
}

Marpa::R3::Test::is(
    ( join "\n", @TEST_ARRAY, '' ),
    ( join "\n", 0 .. 19, '' ),
    'G1 rule ids'
);

@TEST_ARRAY = ();

for (
    my $iter = $grammar->l0_rule_ids_gen() ;
    defined( my $rule_id = $iter->() ) ;
  )
{
    do_something($rule_id);
}

Marpa::R3::Test::is(
    ( join "\n", @TEST_ARRAY, ''),
    ( join "\n", 0 .. 26, '' ),
    'L0 rule ids'
);

$text = q{};

my $production_dotted_results = q{};
my $production_expand_results = q{};
my $production_length_results = q{};
my $production_name_results = q{};

sub production_faire_des_choses {
    my ($production_id) = @_;
    my $dot_position = 0;

# Marpa::R3::Display
# name: SLG production_dotted_show() synopsis

    $production_dotted_results .=
      $grammar->production_dotted_show( $production_id, $dot_position ) . "\n";

# Marpa::R3::Display::End

# Marpa::R3::Display
# name: SLG production_expand() synopsis

    my ($lhs_id, @rhs_ids) = $grammar->production_expand($production_id);
    $production_expand_results .= "Production #$production_id: $lhs_id ::= " . (join q{ }, @rhs_ids) . "\n";

# Marpa::R3::Display::End

# Marpa::R3::Display
# name: SLG production_length() synopsis

    my $length = $grammar->production_length($production_id);
    $production_length_results .= "Production #$production_id: length=$length\n";

# Marpa::R3::Display::End

# Marpa::R3::Display
# name: SLG production_name() synopsis

    my $name = $grammar->production_name($production_id);
    $production_name_results .= "Production #$production_id: $name\n";

# Marpa::R3::Display::End

}

# Marpa::R3::Display
# name: SLG highest_production_id() synopsis

my $max_production_id = $grammar->highest_production_id();
for (
    my $production_id = 1 ;
    $production_id <= $max_production_id ;
    $production_id++
  )
{
    production_faire_des_choses($production_id);
}

# Marpa::R3::Display::End

Marpa::R3::Test::is( $production_dotted_results, <<'END_OF_TEXT', 'predictions by production id');
[:start:] ::= . statements
statement ::= . <numeric assignment>
assignment ::= . 'set' variable 'to' expression
<numeric assignment> ::= . variable '=' <numeric expression>
expression ::= . expression; prec=-1
expression ::= . expression; prec=0
expression ::= . expression; prec=1
expression ::= . variable; prec=2
expression ::= . string; prec=2
expression ::= . 'string' '(' <numeric expression> ')'; prec=1
expression ::= . expression '+' expression; prec=0
<numeric expression> ::= . <numeric expression>; prec=-1
<numeric expression> ::= . <numeric expression>; prec=0
<numeric expression> ::= . <numeric expression>; prec=1
<numeric expression> ::= . variable; prec=2
<numeric expression> ::= . number; prec=2
<numeric expression> ::= . <numeric expression> '*' <numeric expression>; prec=1
statements ::= . statement *
<numeric expression> ::= . <numeric expression> '+' <numeric expression>; prec=0
statement ::= . assignment
[:lex_start:] ~ . [:target:]
[:target:] ~ . [:discard:]
[:target:] ~ . 'set'
[:target:] ~ . 'to'
[:target:] ~ . '='
[:target:] ~ . 'string'
[:target:] ~ . '('
[:target:] ~ . ')'
[:target:] ~ . '+'
[:target:] ~ . '*'
[:target:] ~ . number
[:target:] ~ . string
[:target:] ~ . variable
'set' ~ . [s] [e] [t]
'to' ~ . [t] [o]
'=' ~ . [\=]
'string' ~ . [s] [t] [r] [i] [n] [g]
'(' ~ . [\(]
')' ~ . [\)]
'+' ~ . [\+]
'*' ~ . [\*]
variable ~ . [\w] +
number ~ . [\d] +
string ~ . ['] <string contents> [']
<string contents> ~ . [^'\x{0A}\x{0B}\x{0C}\x{0D}\x{0085}\x{2028}\x{2029}] +
[:discard:] ~ . whitespace
whitespace ~ . [\s] +
END_OF_TEXT

Marpa::R3::Test::is( $production_expand_results, <<'END_OF_TEXT', 'symbol ids by production id');
Production #1: 3 ::= 37
Production #2: 36 ::= 34
Production #3: 31 ::= 5 40 6 32
Production #4: 34 ::= 40 7 35
Production #5: 32 ::= 32
Production #6: 32 ::= 32
Production #7: 32 ::= 32
Production #8: 32 ::= 40
Production #9: 32 ::= 38
Production #10: 32 ::= 8 9 35 10
Production #11: 32 ::= 32 11 32
Production #12: 35 ::= 35
Production #13: 35 ::= 35
Production #14: 35 ::= 35
Production #15: 35 ::= 40
Production #16: 35 ::= 33
Production #17: 35 ::= 35 12 35
Production #18: 37 ::= 36
Production #19: 35 ::= 35 11 35
Production #20: 36 ::= 31
Production #21: 2 ::= 4
Production #22: 4 ::= 1
Production #23: 4 ::= 5
Production #24: 4 ::= 6
Production #25: 4 ::= 7
Production #26: 4 ::= 8
Production #27: 4 ::= 9
Production #28: 4 ::= 10
Production #29: 4 ::= 11
Production #30: 4 ::= 12
Production #31: 4 ::= 33
Production #32: 4 ::= 38
Production #33: 4 ::= 40
Production #34: 5 ::= 29 23 30
Production #35: 6 ::= 30 27
Production #36: 7 ::= 18
Production #37: 8 ::= 29 30 28 25 26 24
Production #38: 9 ::= 14
Production #39: 10 ::= 15
Production #40: 11 ::= 17
Production #41: 12 ::= 16
Production #42: 40 ::= 21
Production #43: 33 ::= 19
Production #44: 38 ::= 13 39 13
Production #45: 39 ::= 22
Production #46: 1 ::= 41
Production #47: 41 ::= 20
END_OF_TEXT

Marpa::R3::Test::is( $production_length_results, <<'END_OF_TEXT', 'lengths by production id');
Production #1: length=1
Production #2: length=1
Production #3: length=4
Production #4: length=3
Production #5: length=1
Production #6: length=1
Production #7: length=1
Production #8: length=1
Production #9: length=1
Production #10: length=4
Production #11: length=3
Production #12: length=1
Production #13: length=1
Production #14: length=1
Production #15: length=1
Production #16: length=1
Production #17: length=3
Production #18: length=1
Production #19: length=3
Production #20: length=1
Production #21: length=1
Production #22: length=1
Production #23: length=1
Production #24: length=1
Production #25: length=1
Production #26: length=1
Production #27: length=1
Production #28: length=1
Production #29: length=1
Production #30: length=1
Production #31: length=1
Production #32: length=1
Production #33: length=1
Production #34: length=3
Production #35: length=2
Production #36: length=1
Production #37: length=6
Production #38: length=1
Production #39: length=1
Production #40: length=1
Production #41: length=1
Production #42: length=1
Production #43: length=1
Production #44: length=3
Production #45: length=1
Production #46: length=1
Production #47: length=1
END_OF_TEXT

Marpa::R3::Test::is( $production_name_results, <<'END_OF_TEXT', 'name by production id');
Production #1: [:start:]
Production #2: statement
Production #3: assignment
Production #4: numeric assignment
Production #5: expression
Production #6: expression
Production #7: expression
Production #8: expression
Production #9: expression
Production #10: expression
Production #11: expression
Production #12: numeric expression
Production #13: numeric expression
Production #14: numeric expression
Production #15: numeric expression
Production #16: numeric expression
Production #17: numeric expression
Production #18: statements
Production #19: numeric expression
Production #20: statement
Production #21: [:lex_start:]
Production #22: [:target:]
Production #23: [:target:]
Production #24: [:target:]
Production #25: [:target:]
Production #26: [:target:]
Production #27: [:target:]
Production #28: [:target:]
Production #29: [:target:]
Production #30: [:target:]
Production #31: [:target:]
Production #32: [:target:]
Production #33: [:target:]
Production #34: [Lex-0]
Production #35: [Lex-1]
Production #36: [Lex-2]
Production #37: [Lex-3]
Production #38: [Lex-4]
Production #39: [Lex-5]
Production #40: [Lex-6]
Production #41: [Lex-7]
Production #42: variable
Production #43: number
Production #44: string
Production #45: string contents
Production #46: [:discard:]
Production #47: whitespace
END_OF_TEXT

$text = q{};

for (
    my $iter = $grammar->g1_rule_ids_gen() ;
    defined( my $rule_id = $iter->() ) ;
  )
{

    my ($lhs_id, @rhs_ids) = $grammar->g1_rule_expand($rule_id);
    $text .= "Rule #$rule_id: $lhs_id ::= " . (join q{ }, @rhs_ids) . "\n";

}

Marpa::R3::Test::is( $text, <<'END_OF_TEXT', 'G1 symbol ids by rule id');
Rule #0: 21 ::= 20
Rule #1: 20 ::= 9
Rule #2: 20 ::= 15
Rule #3: 9 ::= 1 23 2 10
Rule #4: 15 ::= 23 3 16
Rule #5: 10 ::= 11
Rule #6: 11 ::= 12
Rule #7: 12 ::= 13
Rule #8: 13 ::= 23
Rule #9: 13 ::= 22
Rule #10: 12 ::= 4 5 16 6
Rule #11: 11 ::= 11 7 12
Rule #12: 16 ::= 17
Rule #13: 17 ::= 18
Rule #14: 18 ::= 19
Rule #15: 19 ::= 23
Rule #16: 19 ::= 14
Rule #17: 18 ::= 18 8 19
Rule #18: 17 ::= 17 7 18
Rule #19: 0 ::= 21
END_OF_TEXT

$text = q{};

for (
    my $iter = $grammar->l0_rule_ids_gen() ;
    defined( my $rule_id = $iter->() ) ;
  )
{

    my ($lhs_id, @rhs_ids) = $grammar->l0_rule_expand($rule_id);
    $text .= "l0 Rule #$rule_id: $lhs_id ::= " . (join q{ }, @rhs_ids) . "\n";

}

Marpa::R3::Test::is( $text, <<'END_OF_TEXT', 'L0 symbol ids by rule id');
l0 Rule #0: 3 ::= 27 21 28
l0 Rule #1: 4 ::= 28 25
l0 Rule #2: 5 ::= 16
l0 Rule #3: 6 ::= 27 28 26 23 24 22
l0 Rule #4: 7 ::= 12
l0 Rule #5: 8 ::= 13
l0 Rule #6: 9 ::= 15
l0 Rule #7: 10 ::= 14
l0 Rule #8: 32 ::= 19
l0 Rule #9: 29 ::= 17
l0 Rule #10: 30 ::= 11 31 11
l0 Rule #11: 31 ::= 20
l0 Rule #12: 0 ::= 33
l0 Rule #13: 33 ::= 18
l0 Rule #14: 1 ::= 2
l0 Rule #15: 2 ::= 0
l0 Rule #16: 2 ::= 3
l0 Rule #17: 2 ::= 4
l0 Rule #18: 2 ::= 5
l0 Rule #19: 2 ::= 6
l0 Rule #20: 2 ::= 7
l0 Rule #21: 2 ::= 8
l0 Rule #22: 2 ::= 9
l0 Rule #23: 2 ::= 10
l0 Rule #24: 2 ::= 29
l0 Rule #25: 2 ::= 30
l0 Rule #26: 2 ::= 32
END_OF_TEXT

# vim: expandtab shiftwidth=4:
