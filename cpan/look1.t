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

# Note: ah2.t and bocage.t folded into this test

# the example grammar in Aycock/Horspool "Practical Earley Parsing",
# _The Computer Journal_, Vol. 45, No. 6, pp. 620-630,
# in its "NNF" form

# Non-working code, not kept up to date
# Kept for reference
die "Non-working code";

use 5.010001;
use strict;
use warnings;

use Test::More tests => 11;
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
my ($target_rule) = grep { ($grammar->rule_expand($_))[0] eq $S_sym } $grammar->rule_ids();

my $recce = Marpa::R3::Scanless::R->new( {   grammar => $grammar });
my $input_length = 7;
my $input = ('a' x $input_length);
$recce->read( \$input );

sub earley_set_display {
    my ($earley_set) = @_;
    my $result = "=== Earley Set $earley_set ===\n";
    my ($set_data) = $recce->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 'ii', $earley_set, $target_rule );
      local recce, earley_set_id, target_rule = ...
      local function cmp(a, b)
          for i = 1, #a do
             if a[i] < b[i] then return true end
             if a[i] > b[i] then return false end
          end
          return false
      end
      local g1r = recce.g1.lmw_r -- fixed, but not tested
      local g1g = recce.slg.g1.lmw_g -- fixed, but not tested
      local function origin_gen(es_id, eim_id)
          local rule_id, dot, this_origin, irl_id, irl_dot
              = g1r:earley_item_look(es_id, eim_id)
          if rule_id < 0 then return end
          if g1g:_irl_is_virtual_lhs(irl_id) == 0 then
              coroutine.yield( this_origin )
              return
          end
          local lhs = g1g:_irl_lhs(irl_id)
          local eims = g1r:postdot_eims(this_origin, lhs)
          -- print(string.format('eims for %s@%d: %s',
              -- g1g:isy_name(lhs), this_origin, inspect(eims)))
          for ix = 1, #eims do
              origin_gen(this_origin, eims[ix])
          end
      end
      local function  origins(es_id, eim_id)
          local co = coroutine.create(
              function () origin_gen(es_id, eim_id) end
          )
          return function ()
              local code, res = coroutine.resume(co)
              if not code then error(res) end
              return res
          end
      end
      local xrl_data = {}
      local fmt = "jjj"
      for item_id = 0, math.maxinteger do
          -- IRL data for debugging only -- delete
          local rule_id, dot, origin, irl_id, irl_dot = g1r:earley_item_look(earley_set_id, item_id)
          if rule_id < 0 then break end
          if rule_id ~= target_rule then goto NEXT_ITEM end

          for origin in origins(earley_set_id, item_id) do
              local key = string.pack(fmt, rule_id, dot, origin)
              xrl_data[key] = true
          end

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
    for my $datum ( @{$set_data} ) {
        my ( $rule_id, $dot, $origin ) = @{$datum};
        $result .=
            "S:$dot " . '@'
          . "$origin-$earley_set "
          . $grammar->show_dotted_rule( $rule_id, $dot ) . "\n";
    }
    return $result;
}

TODO: {
    local $TODO = "Problem with Earley Set 0";
    Marpa::R3::Test::is( earley_set_display(0), <<'EOS', 'Earley Set 0' );
=== Earley Set 0 ===
Huh?
EOS
}

Marpa::R3::Test::is( earley_set_display(1),
    <<'EOS', 'Earley Set 1' );
=== Earley Set 1 ===
S:-1 @0-1 S -> A A A A A A A .
S:1 @0-1 S -> A . A A A A A A
S:2 @0-1 S -> A A . A A A A A
S:3 @0-1 S -> A A A . A A A A
S:4 @0-1 S -> A A A A . A A A
S:5 @0-1 S -> A A A A A . A A
S:6 @0-1 S -> A A A A A A . A
EOS

Marpa::R3::Test::is( earley_set_display(2),
    <<'EOS', 'Earley Set 2' );
=== Earley Set 2 ===
S:-1 @0-2 S -> A A A A A A A .
S:2 @0-2 S -> A A . A A A A A
S:3 @0-2 S -> A A A . A A A A
S:4 @0-2 S -> A A A A . A A A
S:5 @0-2 S -> A A A A A . A A
S:6 @0-2 S -> A A A A A A . A
EOS

Marpa::R3::Test::is( earley_set_display(3),
    <<'EOS', 'Earley Set 3' );
=== Earley Set 3 ===
S:-1 @0-3 S -> A A A A A A A .
S:3 @0-3 S -> A A A . A A A A
S:4 @0-3 S -> A A A A . A A A
S:5 @0-3 S -> A A A A A . A A
S:6 @0-3 S -> A A A A A A . A
EOS

Marpa::R3::Test::is( earley_set_display(4),
    <<'EOS', 'Earley Set 4' );
=== Earley Set 4 ===
S:-1 @0-4 S -> A A A A A A A .
S:4 @0-4 S -> A A A A . A A A
S:5 @0-4 S -> A A A A A . A A
S:6 @0-4 S -> A A A A A A . A
EOS

Marpa::R3::Test::is( earley_set_display(5),
    <<'EOS', 'Earley Set 5' );
=== Earley Set 5 ===
S:-1 @0-5 S -> A A A A A A A .
S:5 @0-5 S -> A A A A A . A A
S:6 @0-5 S -> A A A A A A . A
EOS

Marpa::R3::Test::is( earley_set_display(6),
    <<'EOS', 'Earley Set 6' );
=== Earley Set 6 ===
S:-1 @0-6 S -> A A A A A A A .
S:6 @0-6 S -> A A A A A A . A
EOS

Marpa::R3::Test::is( earley_set_display(7),
    <<'EOS', 'Earley Set 7' );
=== Earley Set 7 ===
S:-1 @0-7 S -> A A A A A A A .
EOS

# vim: expandtab shiftwidth=4:
