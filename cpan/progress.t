#!perl
# Marpa::R3 is Copyright (C) 2017, Jeffrey Kegler.
#
# This module is free software; you can redistribute it and/or modify it
# under the same terms as Perl 5.10.1. For more details, see the full text
# of the licenses in the directory LICENSES.
#
# This program is distributed in the hope that it will be
# useful, but it is provided “as is” and without any express
# or implied warranties. For details, see the full text of
# of the licenses in the directory LICENSES.

# Note: ah2.t and bocage.t folded into this test

# the example grammar in Aycock/Horspool "Practical Earley Parsing",
# _The Computer Journal_, Vol. 45, No. 6, pp. 620-630,
# in its "NNF" form

use 5.010001;
use strict;
use warnings;

use Test::More tests => 42;
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

## no critic (Subroutines::RequireArgUnpacking)

sub default_action {
    my (undef, $v) = @_;
    my $v_count = scalar @{$v};
    return q{}   if $v_count <= 0;
    return $v->[0] if $v_count == 1;
    return '(' . ( join q{;}, @{$v}) . ')';
}

## use critic

my $dsl = <<'END_OF_DSL';
:default ::= action => main::default_action
:start ::= S
S ::= A A A A A A A
A ::=
A ::= 'a'
END_OF_DSL

my $grammar = Marpa::R3::Scanless::G->new( {   source => \$dsl });

GRAMMAR_TESTS_FOLDED_FROM_ah2_t: {

Marpa::R3::Test::is( $grammar->show_rules, <<'EOS', 'Aycock/Horspool Rules' );
G1 R0 S ::= A A A A A A A
G1 R1 A ::=
G1 R2 A ::= 'a'
G1 R3 [:start] ::= S
EOS

Marpa::R3::Test::is( $grammar->show_symbols,
    <<'EOS', 'Aycock/Horspool Symbols' );
G1 S0 A
G1 S1 S
G1 S2 [:start]
G1 S3 'a'
EOS

Marpa::R3::Test::is( $grammar->show_irls,
    <<'EOS', 'Aycock/Horspool IRLs' );
0: S -> A S[R0:1]
1: S -> A A[] A[] A[]
2: S -> A[] S[R0:1]
3: S[R0:1] -> A S[R0:2]
4: S[R0:1] -> A A[] A[]
5: S[R0:1] -> A[] S[R0:2]
6: S[R0:2] -> A A
7: S[R0:2] -> A A[]
8: S[R0:2] -> A[] A
9: A -> [Lex-0]
10: [:start] -> S
11: [:start]['] -> [:start]
EOS

}

my $recce = Marpa::R3::Scanless::R->new( {   grammar => $grammar });
my $input_length = 7;
my $input = ('a' x $input_length);
$recce->read( \$input );
# for my $earley_set (0 .. 7) {
for my $earley_set (7) {
    say "=== Earley Set $earley_set->progress() ===";
    say Data::Dumper::Dumper($recce->progress($earley_set));
    say "=== Earley Set $earley_set->show_progress() ===";
    say $recce->show_progress($earley_set);
    say "=== Earley Set $earley_set->show_earley_set() ===";
    say $recce->show_earley_set($earley_set);
    say "===";
    my ($set_data) =
      $recce->call_by_tag(
    ('@' . __FILE__ . ':' . __LINE__),
    <<'END_OF_LUA', 'i>2', $earley_set );
      local recce, earley_set_id = ...
      local g1r = recce.lmw_g1r
      local g1g = recce.slg.lmw_g1g
      local result = {}
      for item_id = 0, math.maxinteger do
          local item_data = g1r:earley_item_data(earley_set, item_id)
          if not item_data then break end
          local irl_id = item_data.irl_id
          if g1g:_irl_is_virtual_lhs(irl_id) ~= 0 then 
              io.stderr:write(string.format("IRL #%d is virtual LHS\n", irl_id))
          else
              result[#result+1] = item_data
              io.stderr:write(string.format("IRL #%d is NOT virtual LHS\n", irl_id))
          end
      end
      return result
END_OF_LUA
    say Data::Dumper::Dumper($set_data);
}

exit 0;

for my $earley_set_id (0 .. 7) {
    my ($set_data) =
      $recce->call_by_tag(
    ('@' . __FILE__ . ':' . __LINE__),
    <<'END_OF_LUA', 'i>2', $earley_set_id );
      local recce, earley_set_id = ...
      return recce:g1_earley_set_data(earley_set_id)
END_OF_LUA

    return if not $set_data;
    my %set_data = @{$set_data};
    my $current_earleme = $set_data{earleme};
  EARLEY_ITEM: for ( my $item_id = 0 ; ; $item_id++ ) {

        my $item_data = $set_data{ $item_id + 1 };
        last EARLEY_ITEM if not defined $item_data;

        my %item_data = @{$item_data};

        my $irl_id       = $item_data{irl_id};
        my $dot_position = $item_data{dot_position};
        my $ahm_id_of_yim  = $item_data{ahm_id_of_yim};
        my $origin_earleme = $item_data{origin_earleme};

        say
            qq{  }
          . $irl_id . q{: } . '@' . $origin_earleme
          . '-' . $earley_set_id . ' '
          . $grammar->show_dotted_irl( $irl_id, $dot_position );

    }
}

# vim: expandtab shiftwidth=4:
