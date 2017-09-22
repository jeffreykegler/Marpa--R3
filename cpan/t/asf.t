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

# Tests of glade traversal from rns
# Originally to report github issue #184

# TODO -- Revisit this once I decide whether ASF operates at XRL or IRL
# level.
# MITOSIS: ASF

# VALUATOR: TODO

use 5.010001;

use strict;
use warnings;

use Test::More tests => 3;
use English qw( -no_match_vars );
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;
use Data::Dumper;

my $g = Marpa::R3::Scanless::G->new(
    {   source => \(<<'END_OF_SOURCE'),

    lexeme default = action => [ name, value ]

        Expr ::=
              Number
           | Expr '**' Expr
           | Expr '-' Expr

        Number ~ [\d]+

    :discard ~ whitespace
    whitespace ~ [\s]+

END_OF_SOURCE
    }
);

my $input = <<EOI;
2**7-3**10
EOI

my $r = Marpa::R3::Scanless::R->new( { grammar => $g } );
$r->read( \$input );

{
 my $ambiguous_status = $r->ambiguous();
my $expected = <<'EOS';
Ambiguous symch at Glade=2, Symbol=<Expr>:
  The ambiguity is at B1L1c1-10
  Text is: 2**7-3**10
  There are 2 symches
  Symch 0 is a rule: Expr ::= Expr '**' Expr
  Symch 1 is a rule: Expr ::= Expr '-' Expr
EOS
Marpa::R3::Test::is($ambiguous_status, $expected, 'ambiguous_status()');
Test::More::ok( ( $r->ambiguity_metric() > 1 ), 'ambiguity_metric()');
}

{
    my $asf = Marpa::R3::ASF->new( { slr => $r } );
    my $full_result = $asf->traverse( {}, \&full_traverser );
    my $actual = join "\n", @{$full_result}, q{};
    my $expected = <<'EOS';
(Expr (Expr (Expr (2)) (**) (Expr (Expr (7)) (-) (Expr (3)))) (**) (Expr (10)))
(Expr (Expr (Expr (Expr (2)) (**) (Expr (7))) (-) (Expr (3))) (**) (Expr (10)))
(Expr (Expr (2)) (**) (Expr (Expr (Expr (7)) (-) (Expr (3))) (**) (Expr (10))))
(Expr (Expr (2)) (**) (Expr (Expr (7)) (-) (Expr (Expr (3)) (**) (Expr (10)))))
(Expr (Expr (Expr (2)) (**) (Expr (7))) (-) (Expr (Expr (3)) (**) (Expr (10))))
EOS
    Marpa::R3::Test::is( $actual, $expected, 'Result of ASF traversal' );
}

sub full_traverser {

    # This routine converts the glade into a list of elements.  It is called recursively.
    my ( $glade, $scratch ) = @_;
    my $rule_id     = $glade->rule_id();
    my $symbol_id   = $glade->symbol_id();
    my $symbol_name = $g->g1_symbol_name($symbol_id);

    # A token is a single choice, and we know enough to return it
    if ( not defined $rule_id ) {
        my $literal = $glade->literal();
        return ["($literal)"];
    }

    # Our result will be a list of choices
    my @return_value = ();

    CHOICE: while (1) {

        # The results at each position are a list of choices, so
        # to produce a new result list, we need to take a Cartesian
        # product of all the choices
        my $length = $glade->rh_length();
        my @results = ( [] );
        for my $rh_ix ( 0 .. $length - 1 ) {
            my @new_results = ();
            for my $old_result (@results) {
                my $child_value = $glade->rh_value($rh_ix);
                for my $new_value ( @{$child_value} ) {
                    push @new_results, [ @{$old_result}, $new_value ];
                }
            } ## end for my $old_result (@results)
            @results = @new_results;
        } ## end for my $rh_ix ( 0 .. $length - 1 )

        # Special case for the start rule
        if ( $symbol_name eq '[:start:]' ) {
            return [ map { join q{}, @{$_} } @results ];
        }

        # Now we have a list of choices, as a list of lists.  Each sub list
        # is a list of elements, which we need to join into
        # a single element.  The result will be to collapse
        # one level of lists, and leave us with a list of
        # elements
        my $join_ws = q{ };
        $join_ws = qq{\n   } if $symbol_name eq 'S';
        push @return_value,
            map { '(' . $symbol_name . q{ } . ( join $join_ws, @{$_} ) . ')' }
            @results;

        # Look at the next alternative in this glade, or end the
        # loop if there is none
        last CHOICE if not defined $glade->next();

    } ## end CHOICE: while (1)

    # Return the list of elements for this glade
    return \@return_value;
} ## end sub full_traverser

# vim: expandtab shiftwidth=4:
