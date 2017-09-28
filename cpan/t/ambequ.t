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

# Note: Converted to SLIF from equation.t

# An ambiguous equation

use 5.010001;

use strict;
use warnings;

use Test::More tests => 10;

use lib 'inc';
use Marpa::R3::Test;
use English qw( -no_match_vars );
use Fatal qw( close open );
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use Marpa::R3;

## no critic (InputOutput::RequireBriefOpen)
open my $original_stdout, q{>&STDOUT};
## use critic

sub save_stdout {
    my $save;
    my $save_ref = \$save;
    close STDOUT;
    open STDOUT, q{>}, $save_ref;
    return $save_ref;
} ## end sub save_stdout

sub restore_stdout {
    close STDOUT;
    open STDOUT, q{>&}, $original_stdout;
    return 1;
}

## no critic (Subroutines::RequireArgUnpacking, ErrorHandling::RequireCarping)

sub do_op {
    my ( $right_string, $right_value ) = ( $_[1]->[2] =~ /^(.*)==(.*)$/xms );
    my ( $left_string,  $left_value )  = ( $_[1]->[0] =~ /^(.*)==(.*)$/xms );
    my $op = $_[1]->[1];
    my $value;
    if ( $op eq q{+} ) {
        $value = $left_value + $right_value;
    }
    elsif ( $op eq q{*} ) {
        $value = $left_value * $right_value;
    }
    elsif ( $op eq q{-} ) {
        $value = $left_value - $right_value;
    }
    else {
        die "Unknown op: $op";
    }
    return '(' . $left_string . $op . $right_string . ')==' . $value;
} ## end sub do_op

sub number {
    my (undef, $v) = @_;
    my $v0 = pop @{$v};
    return $v0 . q{==} . $v0;
}

sub default_action {
    my ( undef, $v ) = @_;
    my $v_count = scalar @{$v};
    return q{} if $v_count <= 0;
    return $v->[0] if $v_count == 1;
    return '(' . join( q{;}, @{$v} ) . ')';
}

my $dsl = <<'END_OF_DSL';
:default ::= action => main::default_action
E ::= E Op E action => main::do_op
E ::= Number action => main::number
Number ~ [\d]+
Op ~ [-+*]
END_OF_DSL

my $grammar = Marpa::R3::Scanless::G->new( {   source => \$dsl });

my $actual_ref;
$actual_ref = save_stdout();

print $grammar->symbols_show()
    or die "print failed: $ERRNO";

restore_stdout();

Marpa::R3::Test::is( ${$actual_ref},
    <<'END_SYMBOLS', 'Ambiguous Equation Symbols' );
S1 E
S2 Number
S3 Op
S4 [:lex_start:]
S5 [:start:]
S6 [-+*]
S7 [\d]
END_SYMBOLS

$actual_ref = save_stdout();

print $grammar->productions_show()
    or die "print failed: $ERRNO";

restore_stdout();

Marpa::R3::Test::is( ${$actual_ref},
    <<'END_RULES', 'Ambiguous Equation Rules' );
R1 [:start:] ::= E
R2 E ::= E Op E
R3 E ::= Number
R4 [:lex_start:] ~ Number
R5 [:lex_start:] ~ Op
R6 Number ~ [\d] +
R7 Op ~ [-+*]
END_RULES

$actual_ref = save_stdout();

print $grammar->ahms_show()
    or die "print failed: $ERRNO";

restore_stdout();

Marpa::R3::Test::is( ${$actual_ref},
    <<'EOS', 'Ambiguous Equation AHMs' );
AHM 0: postdot = "E"
    E ::= . E Op E
AHM 1: postdot = "Op"
    E ::= E . Op E
AHM 2: postdot = "E"
    E ::= E Op . E
AHM 3: completion
    E ::= E Op E .
AHM 4: postdot = "Number"
    E ::= . Number
AHM 5: completion
    E ::= Number .
AHM 6: postdot = "E"
    [:start:] ::= . E
AHM 7: completion
    [:start:] ::= E .
AHM 8: postdot = "[:start:]"
    [:start:]['] ::= . [:start:]
AHM 9: completion
    [:start:]['] ::= [:start:] .
EOS

my $recce = Marpa::R3::Scanless::R->new( { grammar => $grammar } );

$recce->read( \'2-0*3+1' );

$actual_ref = save_stdout();

print $recce->earley_sets_show()
    or die "print failed: $ERRNO";

my $expected_earley_sets = <<'END_OF_EARLEY_SETS';
Last Completed: 7; Furthest: 7
Earley Set 0
ahm8: R3:0@0-0
  R3:0: [:start:]['] ::= . [:start:]
ahm6: R2:0@0-0
  R2:0: [:start:] ::= . E
ahm0: R0:0@0-0
  R0:0: E ::= . E Op E
ahm4: R1:0@0-0
  R1:0: E ::= . Number
Earley Set 1
ahm5: R1$@0-1
  R1$: E ::= Number .
  [c=R1:0@0-0; s=Number; t=\'2']
ahm1: R0:1@0-1
  R0:1: E ::= E . Op E
  [p=R0:0@0-0; c=R1$@0-1]
ahm7: R2$@0-1
  R2$: [:start:] ::= E .
  [p=R2:0@0-0; c=R1$@0-1]
ahm9: R3$@0-1
  R3$: [:start:]['] ::= [:start:] .
  [p=R3:0@0-0; c=R2$@0-1]
Earley Set 2
ahm2: R0:2@0-2
  R0:2: E ::= E Op . E
  [c=R0:1@0-1; s=Op; t=\'-']
ahm0: R0:0@2-2
  R0:0: E ::= . E Op E
ahm4: R1:0@2-2
  R1:0: E ::= . Number
Earley Set 3
ahm5: R1$@2-3
  R1$: E ::= Number .
  [c=R1:0@2-2; s=Number; t=\'0']
ahm1: R0:1@2-3
  R0:1: E ::= E . Op E
  [p=R0:0@2-2; c=R1$@2-3]
ahm3: R0$@0-3
  R0$: E ::= E Op E .
  [p=R0:2@0-2; c=R1$@2-3]
ahm1: R0:1@0-3
  R0:1: E ::= E . Op E
  [p=R0:0@0-0; c=R0$@0-3]
ahm7: R2$@0-3
  R2$: [:start:] ::= E .
  [p=R2:0@0-0; c=R0$@0-3]
ahm9: R3$@0-3
  R3$: [:start:]['] ::= [:start:] .
  [p=R3:0@0-0; c=R2$@0-3]
Earley Set 4
ahm2: R0:2@0-4
  R0:2: E ::= E Op . E
  [c=R0:1@0-3; s=Op; t=\'*']
ahm2: R0:2@2-4
  R0:2: E ::= E Op . E
  [c=R0:1@2-3; s=Op; t=\'*']
ahm0: R0:0@4-4
  R0:0: E ::= . E Op E
ahm4: R1:0@4-4
  R1:0: E ::= . Number
Earley Set 5
ahm5: R1$@4-5
  R1$: E ::= Number .
  [c=R1:0@4-4; s=Number; t=\'3']
ahm1: R0:1@4-5
  R0:1: E ::= E . Op E
  [p=R0:0@4-4; c=R1$@4-5]
ahm3: R0$@2-5
  R0$: E ::= E Op E .
  [p=R0:2@2-4; c=R1$@4-5]
ahm3: R0$@0-5
  R0$: E ::= E Op E .
  [p=R0:2@0-2; c=R0$@2-5]
  [p=R0:2@0-4; c=R1$@4-5]
ahm1: R0:1@0-5
  R0:1: E ::= E . Op E
  [p=R0:0@0-0; c=R0$@0-5]
ahm7: R2$@0-5
  R2$: [:start:] ::= E .
  [p=R2:0@0-0; c=R0$@0-5]
ahm9: R3$@0-5
  R3$: [:start:]['] ::= [:start:] .
  [p=R3:0@0-0; c=R2$@0-5]
ahm1: R0:1@2-5
  R0:1: E ::= E . Op E
  [p=R0:0@2-2; c=R0$@2-5]
Earley Set 6
ahm2: R0:2@2-6
  R0:2: E ::= E Op . E
  [c=R0:1@2-5; s=Op; t=\'+']
ahm2: R0:2@0-6
  R0:2: E ::= E Op . E
  [c=R0:1@0-5; s=Op; t=\'+']
ahm2: R0:2@4-6
  R0:2: E ::= E Op . E
  [c=R0:1@4-5; s=Op; t=\'+']
ahm0: R0:0@6-6
  R0:0: E ::= . E Op E
ahm4: R1:0@6-6
  R1:0: E ::= . Number
Earley Set 7
ahm5: R1$@6-7
  R1$: E ::= Number .
  [c=R1:0@6-6; s=Number; t=\'1']
ahm1: R0:1@6-7
  R0:1: E ::= E . Op E
  [p=R0:0@6-6; c=R1$@6-7]
ahm3: R0$@4-7
  R0$: E ::= E Op E .
  [p=R0:2@4-6; c=R1$@6-7]
ahm3: R0$@0-7
  R0$: E ::= E Op E .
  [p=R0:2@0-2; c=R0$@2-7]
  [p=R0:2@0-4; c=R0$@4-7]
  [p=R0:2@0-6; c=R1$@6-7]
ahm3: R0$@2-7
  R0$: E ::= E Op E .
  [p=R0:2@2-4; c=R0$@4-7]
  [p=R0:2@2-6; c=R1$@6-7]
ahm1: R0:1@2-7
  R0:1: E ::= E . Op E
  [p=R0:0@2-2; c=R0$@2-7]
ahm1: R0:1@0-7
  R0:1: E ::= E . Op E
  [p=R0:0@0-0; c=R0$@0-7]
ahm7: R2$@0-7
  R2$: [:start:] ::= E .
  [p=R2:0@0-0; c=R0$@0-7]
ahm9: R3$@0-7
  R3$: [:start:]['] ::= [:start:] .
  [p=R3:0@0-0; c=R2$@0-7]
ahm1: R0:1@4-7
  R0:1: E ::= E . Op E
  [p=R0:0@4-4; c=R0$@4-7]
END_OF_EARLEY_SETS

Marpa::R3::Test::is( ${$actual_ref}, $expected_earley_sets,
    'Ambiguous Equation Earley Sets' );

restore_stdout();

$actual_ref = save_stdout();

print $recce->progress_show()
    or die "print failed: $ERRNO";

Marpa::R3::Test::is( ${$actual_ref},
    <<'END_OF_PROGRESS_REPORT', 'Ambiguous Equation Progress Report' );
=== Earley set 7 at B1L1c8 ===
R2:1 x4 B1L1c1-7 E ::= E . Op E
F1 B1L1c1 [:start:] ::= E .
F2 x3 B1L1c1-5 E ::= E Op E .
F3 B1L1c7 E ::= Number .
END_OF_PROGRESS_REPORT

restore_stdout();

my %expected_value = (
    '(2-(0*(3+1)))==2' => 1,
    '(((2-0)*3)+1)==7' => 1,
    '((2-(0*3))+1)==3' => 1,
    '((2-0)*(3+1))==8' => 1,
    '(2-((0*3)+1))==1' => 1,
);

# Set max at 10 just in case there's an infinite loop.
# This is for debugging, after all

$recce->set( { max_parses => 10, } );

my $i = 0;
my $valuer = Marpa::R3::Scanless::V->new( { recognizer => $recce } );
while ( defined( my $value = $valuer->value() ) ) {
    my $value = ${$value};
    if ( defined $expected_value{$value} ) {
        delete $expected_value{$value};
        Test::More::pass("Expected Value $i: $value");
    }
    else {
        Test::More::fail("Unexpected Value $i: $value");
    }
    $i++;
}

1;    # In case used as "do" file

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
