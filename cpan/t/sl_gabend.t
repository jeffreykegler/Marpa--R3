#!perl
# Copyright 2016 Jeffrey Kegler
# This file is part of Marpa::R3.  Marpa::R3 is free software: you can
# redistribute it and/or modify it under the terms of the GNU Lesser
# General Public License as published by the Free Software Foundation,
# either version 3 of the License, or (at your option) any later version.
#
# Marpa::R3 is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser
# General Public License along with Marpa::R3.  If not, see
# http://www.gnu.org/licenses/.

# CENSUS: ASIS
# Note: Converted from gabend.t

# Test grammar exceptions -- make sure problems actually
# are detected.  These tests are for problems which are supposed
# to abend.

use 5.010001;
use strict;
use warnings;
use English qw( -no_match_vars );
use Test::More tests => 6;
use Fatal qw(open close);

use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

## no critic (Subroutines::RequireArgUnpacking)

sub default_action {
    shift;
    my $v_count = scalar @_;
    return q{}   if $v_count <= 0;
    return $_[0] if $v_count == 1;
    return '(' . join( q{;}, @_ ) . ')';
} ## end sub default_action

## use critic

sub test_grammar {
    my ( $test_name, $dsl, $expected_error ) = @_;
    my $trace;
    my $memory;
    my $eval_ok = eval {
        my $grammar = Marpa::R3::Scanless::G->new({ source => \$dsl});
        1;
    };
    my $eval_error = $EVAL_ERROR;
    DETERMINE_TEST_RESULT: {
        if ($eval_ok) {
            Test::More::fail("Failed to catch problem: $test_name");
            last DETERMINE_TEST_RESULT;
        }
        $eval_error =~ s/ ^ Marpa::R3 \s+ exception \s+ at \s+ .* \z //xms;
        if ( $eval_error eq $expected_error ) {
            Test::More::pass("Successfully caught problem: $test_name");
            last DETERMINE_TEST_RESULT;
        }
        my $diag_message =
            "Failed to find expected message, was expecting:\n";
        my $temp;
        $temp = $expected_error;
        $temp =~ s/^/=== /xmsg;
        chomp $temp;
        $diag_message .= "$temp\n";
        $diag_message .= "This was the message actually received:\n";
        $temp = $eval_error;
        $temp =~ s/^/=== /xmsg;
        chomp $temp;
        $diag_message .= "$temp\n";

        # $diag_message =~ s/^Marpa::R3 \s+ exception \s+ at .* $//xms;
        Test::More::diag($diag_message);
        Test::More::fail("Unexpected message: $test_name");
    } ## end DETERMINE_TEST_RESULT:
    return;
} ## end sub test_grammar

my $counted_nullable_grammar = <<'END_OF_DSL';
    S ::= Seq*
    Seq ::= A B
    A ::=
    B ::=
    A ~ [\d\D]
END_OF_DSL

test_grammar(
    'counted nullable',
    $counted_nullable_grammar,
    qq{Nullable symbol "Seq" is on rhs of counted rule\n}
        . qq{Counted nullables confuse Marpa -- please rewrite the grammar\n}
);

my $duplicate_rule_grammar = <<'END_OF_DSL';
    Top ::= Dup
    Dup ::= Item
    Dup ::= Item
    Item ::= a
END_OF_DSL
test_grammar( 'duplicate rule',
    $duplicate_rule_grammar, qq{Duplicate rule: Dup -> Item\n} );

my $unique_lhs_grammar = <<'END_OF_DSL';
    Top ::= Dup
    Dup ::= Item*
    Dup ::= Item
    Item ::= a
END_OF_DSL
test_grammar( 'unique_lhs',
    $unique_lhs_grammar, qq{LHS of sequence rule would not be unique: Dup -> Item\n} );

my $nulling_terminal_grammar = <<'END_OF_DSL';
    Top ::= Bad
    Top ::= Good
    Bad ::=
    Bad ~ [\d\D]
    Good ~ [\d\D]
END_OF_DSL
test_grammar(
    'nulling terminal grammar',
    $nulling_terminal_grammar,
    <<'END_OF_MESSAGE'
A lexeme in lexer L0 is not a lexeme in G1: Bad
END_OF_MESSAGE
);

my $start_not_lhs_grammar = <<'END_OF_DSL';
    inaccessible is fatal by default
    :start ::= Bad
    Top ::= Bad
    Bad ~ [\d\D]
END_OF_DSL
test_grammar( 'start symbol not on lhs',
    $start_not_lhs_grammar,
    qq{Inaccessible symbol: Top\n}
);

my $unproductive_start_grammar = <<'END_OF_DSL';
    :start ::= Bad
    Top ::= Bad
    Bad ::= Worse
    Worse ::= Bad
    Top ::= Good
    Good ~ [\d\D]
END_OF_DSL
test_grammar(
    'unproductive start symbol',
    $unproductive_start_grammar,
    qq{Unproductive start symbol\n}
);

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4: