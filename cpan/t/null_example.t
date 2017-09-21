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

# Note: SLIF TEST

# VALUATOR: TODO

use 5.010001;

use strict;
use warnings;

use English qw( -no_match_vars );
use Fatal qw(open close);
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use Test::More tests => 1;

use lib 'inc';
use Marpa::R3::Test;
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

# Marpa::R3::Display
# name: SLIF null value example

sub do_L {
    my (undef, $values) = @_;
    return 'L(' . ( join q{;}, map { $_ // '[ERROR!]' } @{$values} ) . ')';
}

sub do_R {
    return 'R(): I will never be called';
}

sub do_S {
    my (undef, $values) = @_;
    return 'S(' . ( join q{;}, map { $_ // '[ERROR!]' } @{$values} ) . ')';
}

sub do_X { return 'X(' . $_[1]->[0] . ')'; }
sub do_Y { return 'Y(' . $_[1]->[0] . ')'; }

sub null_A { return 'null A'; }
sub null_B { return 'null B'; }
sub null_L { return 'null L'; }
sub null_R { return 'null R'; }
sub null_X { return 'null X'; }
sub null_Y { return 'null Y'; }

my $slg = Marpa::R3::Scanless::G->new(
    {
        semantics_package => 'main',
        source            => \<<'END_OF_DSL',
:start ::= S
S ::= L R action => do_S
L ::= A B X action => do_L
L ::= action => null_L
R ::= A B Y action => do_R
R ::= action => null_R
A ::= action => null_A
B ::= action => null_B
X ::= action => null_X
X ::= 'x' action => do_X
Y ::= action => null_Y
Y ::= 'y' action => do_Y
END_OF_DSL
    }
);

my $slr = Marpa::R3::Scanless::R->new( { grammar => $slg } );

$slr->read( \'x' );

# Marpa::R3::Display::End

## use critic

# Marpa::R3::Display
# name: SLIF null value example output
# start-after-line: END_OF_OUTPUT
# end-before-line: '^END_OF_OUTPUT$'

chomp( my $expected = <<'END_OF_OUTPUT');
S(L(null A;null B;X(x));null R)
END_OF_OUTPUT

# Marpa::R3::Display::End

my $value = $slr->old_value();
Marpa::R3::Test::is( ${$value}, $expected, 'Null example' );

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
