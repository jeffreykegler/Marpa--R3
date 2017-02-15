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
1: S -> A A[] A[] A[] A[] A[] A[]
2: S -> A[] S[R0:1]
3: S[R0:1] -> A S[R0:2]
4: S[R0:1] -> A A[] A[] A[] A[] A[]
5: S[R0:1] -> A[] S[R0:2]
6: S[R0:2] -> A S[R0:3]
7: S[R0:2] -> A A[] A[] A[] A[]
8: S[R0:2] -> A[] S[R0:3]
9: S[R0:3] -> A S[R0:4]
10: S[R0:3] -> A A[] A[] A[]
11: S[R0:3] -> A[] S[R0:4]
12: S[R0:4] -> A S[R0:5]
13: S[R0:4] -> A A[] A[]
14: S[R0:4] -> A[] S[R0:5]
15: S[R0:5] -> A A
16: S[R0:5] -> A A[]
17: S[R0:5] -> A[] A
18: A -> [Lex-0]
19: [:start] -> S
20: [:start]['] -> [:start]
EOS

}

my ($S_sym) = grep { $grammar->symbol_name($_) eq 'S' } $grammar->symbol_ids();
my ($S_rule) = grep { ($grammar->rule_expand($_))[0] eq $S_sym } $grammar->rule_ids();

my $recce = Marpa::R3::Scanless::R->new( {   grammar => $grammar });
my $input_length = 7;
my $input = ('a' x $input_length);
$recce->read( \$input );
EARLEY_SET: for my $earley_set (0 .. 7) {
    say "=== Earley Set $earley_set->progress() ===";
    my @S_items = grep { $_->[0] eq $S_rule } @{$recce->progress($earley_set)};
    # say Data::Dumper::Dumper($recce->progress($earley_set));
    for my $S_item (@S_items) {
        my ($rule_id, $dot, $origin) = @{$S_item};
        say "S:$dot " . '@' . "$origin-$earley_set " . $grammar->show_dotted_rule($rule_id, $dot);
    }

    my ($set_data) =
      $recce->call_by_tag(
    ('@' . __FILE__ . ':' . __LINE__),
    <<'END_OF_LUA', 'ii', $earley_set, $S_rule );
      local recce, earley_set_id, S_rule = ...
      local cmp = function(a, b)
          for i = 1, #a do
             if a[i] < b[i] then return true end
             if a[i] > b[i] then return false end
          end
          return false
      end
      local g1r = recce.lmw_g1r
      local g1g = recce.slg.lmw_g1g
      local xrl_data = {}
      local fmt = "jjj"
      for item_id = 0, math.maxinteger do
          local item_data = g1r:earley_item_data(earley_set_id, item_id)
          if not item_data then break end
          local irl_id = item_data.irl_id
          if g1g:_irl_is_virtual_lhs(irl_id) ~= 0 then 
              goto NEXT_ITEM
          end
          local irl_lhs = g1g:_irl_lhs(irl_id)
          local xrl = g1g:_source_xrl(irl_id)
          if not xrl then goto NEXT_ITEM end
          if xrl ~= S_rule then goto NEXT_ITEM end
          print(inspect(item_data))
          local key = string.pack(fmt,
              xrl, item_data.dot_position, item_data.origin_set_id)
          xrl_data[key] = true
          ::NEXT_ITEM::
      end
      result = {}
      for key, value in pairs(xrl_data) do
           local xrl_datum = { string.unpack(fmt, key) }
           xrl_datum[#xrl_datum] = nil
           result[#result+1] = xrl_datum
      end
      table.sort(result, cmp)
      return result
END_OF_LUA
    # say Data::Dumper::Dumper($set_data);
    say "===";
    for my $datum (@{$set_data}) {
        my ($rule_id, $dot, $origin) = @{$datum};
        say "S:$dot " . '@' . "$origin-$earley_set " . $grammar->show_dotted_rule($rule_id, $dot);
    }
}

# vim: expandtab shiftwidth=4:
