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

use 5.010001;


# A variation on
# the example grammar in Aycock/Horspool "Practical Earley Parsing",
# _The Computer Journal_, Vol. 45, No. 6, pp. 620-630,
# Its order of ambiguity generates Pascal's triangle.

use strict;
use warnings;
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use Test::More tests => 6;
use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

my $base_dsl = <<'END_OF_BASE_DSL';
:start ::= S
A ::= 'a' | E
E ::= # empty
END_OF_BASE_DSL

sub ah_extended {
    my $n = shift;

    my $full_dsl = $base_dsl . join q{ }, 'S', '::=', ( ('A') x $n );
    my $grammar   = Marpa::R3::Grammar->new( { source => \$full_dsl, } );
    my $input = 'a' x $n;
    my $recce   = Marpa::R3::Scanless::R->new( { grammar => $grammar } );
    $recce->read( \$input );

    my @parse_counts = (1);
    for my $loc ( 1 .. $n ) {
        my $parse_number = 0;

        my $asf = Marpa::R3::ASF->new( { recognizer => $recce , factoring_max => 1000, end => $loc } );
        $parse_counts[$loc] = $asf->traverse(
            {},
            sub {
                my ($glade) = @_;
                my $glade_count = 0;
                do {
                    my $rule_count = 1;
                    if ( defined $glade->rule_id() ) {
                        $rule_count *= $glade->rh_value($_)
                            for 0 .. $glade->rh_length() - 1;
                    }
                    $glade_count += $rule_count;
                        $glade->literal();
                } while defined $glade->next();
                return $glade_count;
            }
        );

    } ## end for my $loc ( 0 .. $n )
    return join q{ }, @parse_counts;
} ## end sub ah_extended

# In the NAIF, the zero case was one of my more important tests,
# but allowing a SLIF whose lexers are never used seems pointless.
my @answers = (
    undef,
    '1 1',
    '1 2 1',
    '1 3 3 1',
    '1 4 6 4 1',
    '1 5 10 10 5 1',
    '1 6 15 20 15 6 1',
    '1 7 21 35 35 21 7 1',
    '1 8 28 56 70 56 28 8 1',
    '1 9 36 84 126 126 84 36 9 1',
    '1 10 45 120 210 252 210 120 45 10 1',
);

## no critic (ValuesAndExpressions::ProhibitMagicNumbers)
for my $a ( ( 1 .. 5 ), 10 ) {
## use critic

    Marpa::R3::Test::is( ah_extended($a), $answers[$a],
        "Row $a of Pascal's triangle matches parse counts" );

} ## end for my $a ( ( 0 .. 5 ), 10 )

1;    # In case used as "do" file

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: set expandtab shiftwidth=4:
