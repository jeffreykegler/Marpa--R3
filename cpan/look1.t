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

Marpa::R3::Test::is( $grammar->productions_show(), <<'EOS', 'Aycock/Horspool Rules' );
R1 [:start:] ::= S
R2 S ::= A A A A A A A
R3 A ::=
R4 A ::= 'a'
R5 'a' ~ [a]
EOS

Marpa::R3::Test::is( $grammar->symbols_show(),
    <<'EOS', 'Aycock/Horspool Symbols' );
S1 A
S2 S
S3 [:start:]
S4 'a'
S5 [a]
EOS

Marpa::R3::Test::is( $grammar->nrls_show(),
    <<'EOS', 'Aycock/Horspool NRLs' );
0: S ::= A S[R0:1]
1: S ::= A A[] A[] A[] A[] A[] A[]
2: S ::= A[] S[R0:1]
3: S[R0:1] ::= A S[R0:2]
4: S[R0:1] ::= A A[] A[] A[] A[] A[]
5: S[R0:1] ::= A[] S[R0:2]
6: S[R0:2] ::= A S[R0:3]
7: S[R0:2] ::= A A[] A[] A[] A[]
8: S[R0:2] ::= A[] S[R0:3]
9: S[R0:3] ::= A S[R0:4]
10: S[R0:3] ::= A A[] A[] A[]
11: S[R0:3] ::= A[] S[R0:4]
12: S[R0:4] ::= A S[R0:5]
13: S[R0:4] ::= A A[] A[]
14: S[R0:4] ::= A[] S[R0:5]
15: S[R0:5] ::= A A
16: S[R0:5] ::= A A[]
17: S[R0:5] ::= A[] A
18: A ::= [Lex-0]
19: [:start:] ::= S
20: [:start:]['] ::= [:start:]
EOS

my $recce = Marpa::R3::Scanless::R->new( {   grammar => $grammar });
my $input_length = 7;
my $input = ('a' x $input_length);
$recce->read( \$input );

sub earley_set_display {
    my ($earley_set) = @_;
    my $result = "=== Earley Set $earley_set ===\n";
    my ($set_data) = $recce->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 'i', $earley_set );
      local recce, earley_set_id = ...
      local function cmp_seq(a, b)
          for i = 1, #a do
             if a[i] < b[i] then return true end
             if a[i] > b[i] then return false end
          end
          return false
      end
      local g1r = recce.g1
      local g1g = recce.slg.g1
      local function origin_gen(es_id, eim_id)
          local irl_id, irl_dot, this_origin, nrl_id, nrl_dot
              = g1r:earley_item_look(es_id, eim_id)
          if irl_id < 0 then return end
          if g1g:_nrl_is_virtual_lhs(nrl_id) == 0 then
              coroutine.yield( this_origin )
              return
          end
          local lhs = g1g:_nrl_lhs(nrl_id)
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
      local fmt = "jjjj"
      for item_id = 0, math.maxinteger do
          -- IRL data for debugging only -- delete
          local irl_id, irl_dot, origin, nrl_id, nrl_dot = g1r:earley_item_look(earley_set_id, item_id)
          if irl_id < 0 then break end

          for origin in origins(earley_set_id, item_id) do
              -- type: completion, prediction or medial?
              local type = irl_dot < 0 and 2 or irl_dot == 0 and 0 or 1
              local key = string.pack(fmt, type, irl_id, irl_dot, origin)
              xrl_data[key] = true
          end

          ::NEXT_ITEM::
      end
      local result = {}
      for key, value in pairs(xrl_data) do
           local type, irl_id, irl_dot, origin = string.unpack(fmt, key)
           result[#result+1] = { type, irl_id, irl_dot, origin }
      end
      table.sort(result, cmp_seq)
      return result
END_OF_LUA
    for my $datum ( @{$set_data} ) {
        my ( $type, $irl_id, $irl_dot, $origin ) = @{$datum};
        $result .=
            "S:$irl_dot " . '@'
          . "$origin-$earley_set "
          . $grammar->g1_dotted_rule_show( $irl_id, $irl_dot ) . "\n";
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
S:1 @0-1 S ::= A . A A A A A A
S:2 @0-1 S ::= A A . A A A A A
S:3 @0-1 S ::= A A A . A A A A
S:4 @0-1 S ::= A A A A . A A A
S:5 @0-1 S ::= A A A A A . A A
S:6 @0-1 S ::= A A A A A A . A
S:-1 @0-1 S ::= A A A A A A A .
S:-1 @0-1 A ::= 'a' .
S:-1 @0-1 [:start:] ::= S .
EOS

Marpa::R3::Test::is( earley_set_display(2),
    <<'EOS', 'Earley Set 2' );
=== Earley Set 2 ===
S:2 @0-2 S ::= A A . A A A A A
S:3 @0-2 S ::= A A A . A A A A
S:4 @0-2 S ::= A A A A . A A A
S:5 @0-2 S ::= A A A A A . A A
S:6 @0-2 S ::= A A A A A A . A
S:-1 @0-2 S ::= A A A A A A A .
S:-1 @1-2 A ::= 'a' .
S:-1 @0-2 [:start:] ::= S .
EOS

Marpa::R3::Test::is( earley_set_display(3),
    <<'EOS', 'Earley Set 3' );
=== Earley Set 3 ===
S:3 @0-3 S ::= A A A . A A A A
S:4 @0-3 S ::= A A A A . A A A
S:5 @0-3 S ::= A A A A A . A A
S:6 @0-3 S ::= A A A A A A . A
S:-1 @0-3 S ::= A A A A A A A .
S:-1 @2-3 A ::= 'a' .
S:-1 @0-3 [:start:] ::= S .
EOS

Marpa::R3::Test::is( earley_set_display(4),
    <<'EOS', 'Earley Set 4' );
=== Earley Set 4 ===
S:4 @0-4 S ::= A A A A . A A A
S:5 @0-4 S ::= A A A A A . A A
S:6 @0-4 S ::= A A A A A A . A
S:-1 @0-4 S ::= A A A A A A A .
S:-1 @3-4 A ::= 'a' .
S:-1 @0-4 [:start:] ::= S .
EOS

Marpa::R3::Test::is( earley_set_display(5),
    <<'EOS', 'Earley Set 5' );
=== Earley Set 5 ===
S:5 @0-5 S ::= A A A A A . A A
S:6 @0-5 S ::= A A A A A A . A
S:-1 @0-5 S ::= A A A A A A A .
S:-1 @4-5 A ::= 'a' .
S:-1 @0-5 [:start:] ::= S .
EOS

Marpa::R3::Test::is( earley_set_display(6),
    <<'EOS', 'Earley Set 6' );
=== Earley Set 6 ===
S:6 @0-6 S ::= A A A A A A . A
S:-1 @0-6 S ::= A A A A A A A .
S:-1 @5-6 A ::= 'a' .
S:-1 @0-6 [:start:] ::= S .
EOS

Marpa::R3::Test::is( earley_set_display(7),
    <<'EOS', 'Earley Set 7' );
=== Earley Set 7 ===
S:-1 @0-7 S ::= A A A A A A A .
S:-1 @6-7 A ::= 'a' .
S:-1 @0-7 [:start:] ::= S .
EOS

# vim: expandtab shiftwidth=4:
