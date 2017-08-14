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
R5 [:lex_start:] ~ 'a'
R6 'a' ~ [a]
EOS

Marpa::R3::Test::is( $grammar->symbols_show(),
    <<'EOS', 'Aycock/Horspool Symbols' );
S1 A
S2 S
S3 [:lex_start:]
S4 [:start:]
S5 'a'
S6 [a]
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
    my ($result) = $recce->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 'i', $earley_set );
      local slr, earley_set_id = ...
      local slg = slr.slg
      local g1r = slr.g1

    local function progress_line_do(
        slr, current_ordinal, origins, production_id, position
    )

        -- For origins[0], we apply
        --     -1 to convert earley set to G1, then
        --     +1 because it is an origin and the character
        --        doesn't begin until the next Earley set
        -- In other words, they balance and we do nothing
        local g1_first = origins[1]

        local slg = slr.slg
        local pcs = {}


        local dotted_type
        if position >= slg:xpr_length(production_id) then
            dotted_type = 'F'
            pcs[#pcs+1] = 'F' .. production_id
            goto TAG_FOUND
        end
        if position > 0 then
            dotted_type = 'R'
            pcs[#pcs+1] = 'R' .. production_id .. ':' .. position
            goto TAG_FOUND
        end
        dotted_type = 'P'
        pcs[#pcs+1] = 'P' .. production_id
        ::TAG_FOUND::

        if #origins > 1 then
            pcs[#pcs+1] = 'x' .. #origins
        end

        -- find the range
        if current_ordinal <= 0 then
            pcs[#pcs+1] = 'B0L0c0'
            goto HAVE_RANGE
        end
        if dotted_type == 'P' then
            local block, pos = slr:g1_pos_to_l0_first(current_ordinal)
            pcs[#pcs+1] = slr:lc_brief(pos, block)
            goto HAVE_RANGE
        end
        do
            if g1_first < 0 then g1_first = 0 end
            local g1_last = origins[#origins]
            local l0_first_b, l0_first_p = slr:g1_pos_to_l0_first(g1_first)
            local l0_last_b, l0_last_p = slr:g1_pos_to_l0_last(g1_last)
            pcs[#pcs+1] = slr:lc_range_brief(l0_first_b, l0_first_p, l0_last_b, l0_last_p)
            goto HAVE_RANGE
        end
        ::HAVE_RANGE::
        pcs[#pcs+1] = slg:xpr_dotted_show(production_id, position)
        return table.concat(pcs, ' ')
    end

      local function origins(traverser)
          local g1g = slg.g1
          local function origin_gen(base_trv, origin_trv)
              -- print(string.format('Calling origin gen %s %s', base_trv, origin_trv))
              -- print(string.format('Calling origin gen origin_trv = %s', inspect(origin_trv, {depth=2})))
              local nrl_id = origin_trv:nrl_id()
              -- print(string.format('nrl_id %s', nrl_id))
              local irl_id = origin_trv:rule_id()
              local origin = origin_trv:origin()
              if irl_id
                  and g1g:_nrl_semantic_equivalent(nrl_id)
                  and slg:g1_rule_is_xpr_top(irl_id)
              then
                  coroutine.yield(origin)
                  return
              end

              -- Do not recurse on sequence rules
              if g1g:sequence_min(irl_id) then return end

              -- If here, we are at a CHAF rule
              local lhs = g1g:_nrl_lhs(nrl_id)
              local ptrv = _M.ptraverser_new(g1r, origin, lhs)

              -- Do not recurse if there are any LIMs
              --    Note: LIM's are always first
              if ptrv:at_lim() then return end
              while true do
                  local trv = ptrv:eim_iter()
                  if not trv then break end
                  origin_gen(base_trv, trv)
              end

          end
          return coroutine.wrap(
                  function () origin_gen(traverser, traverser) end
          )
      end

      local function progress(slr, earley_set_id)
          local g1r = slr.g1
          local uniq_items = {}
          local max_eim = g1r:_earley_set_size(earley_set_id) - 1
          for item_id = 0, max_eim do
              -- IRL data for debugging only -- delete
              local trv = _M.traverser_new(g1r, earley_set_id, item_id)
              local irl_id = trv:rule_id()
              if not irl_id then goto NEXT_ITEM end
              local irl_dot = trv:dot()
              -- io.stderr:write(string.format("item: %d R%d:%d@%d\n", earley_set_id,
                   -- irl_id, irl_dot, trv:origin()))
              local xpr_id = slg:g1_rule_to_xprid(irl_id)
              local xpr_dots = slg:g1_rule_to_xpr_dots(irl_id)
              local xpr_dot
              if irl_dot == -1 then
                  xpr_dot = xpr_dots[#xpr_dots]
              else
                  xpr_dot = xpr_dots[irl_dot+1]
              end
              for origin in origins(trv) do
                  local vlq = _M.to_vlq{ xpr_id, xpr_dot, origin }
                  uniq_items[vlq] = true
              end
              ::NEXT_ITEM::
          end
          local items = {}
          for vlq, _ in  pairs(uniq_items) do
              items[#items+1] = _M.from_vlq(vlq)
          end
          return items
      end

      -- io.stderr:write(string.format("earley_set_display(%d)\n", earley_set_id))
      local result = { "=== Earley Set " .. earley_set_id .. "===" }
      local current_items = progress(slr, earley_set_id)
      local items = {}
      for ix = 1, #current_items do
          local xpr_id, xpr_dot, origin = table.unpack(current_items[ix])
          -- item_type is 0 for prediction, 1 for medial, 2 for completed
          local item_type = 1
          if xpr_dot == 0 then
              item_type = 0
          elseif xpr_dot == -1 then
              xpr_dot = slg:xpr_length(rule_id)
              item_type = 2
          end
          items[#items+1] = { earley_set_id, item_type, xpr_id, xpr_dot, origin }
      end
      local last_ordinal
      local lines = {}
      for this_ordinal, rule_id, position, origins in _M.collected_progress_items(items) do
          if this_ordinal ~= last_ordinal then
              local location = 'B0L0c0'
              if this_ordinal > 0 then
                    local block, pos = slr:g1_pos_to_l0_first(this_ordinal)
                    location = slr:lc_brief(pos, block)
              end
              lines = { string.format('=== Earley set %d at %s ===', this_ordinal, location) }
              last_ordinal = this_ordinal
          end
          lines[#lines+1] = progress_line_do( 
            slr, this_ordinal, origins, rule_id, position )
      end
      lines[#lines+1] = '' -- to get a final "\n"
      return table.concat(lines, "\n")
END_OF_LUA
    return $result;
}

Marpa::R3::Test::is( earley_set_display(0), <<'EOS', 'Earley Set 0' );
=== Earley set 0 at B0L0c0 ===
P1 B0L0c0 [:start:] ::= . S
P2 B0L0c0 S ::= . A A A A A A A
P4 B0L0c0 A ::= . 'a'
R2:1 B0L0c0 S ::= A . A A A A A A
R2:2 B0L0c0 S ::= A A . A A A A A
R2:3 B0L0c0 S ::= A A A . A A A A
R2:4 B0L0c0 S ::= A A A A . A A A
R2:5 B0L0c0 S ::= A A A A A . A A
R2:6 B0L0c0 S ::= A A A A A A . A
EOS

Marpa::R3::Test::is( earley_set_display(1),
    <<'EOS', 'Earley Set 1' );
=== Earley set 1 at B1L1c2 ===
P4 B1L1c2 A ::= . 'a'
F1 B1L1c1 [:start:] ::= S .
R2:1 B1L1c1 S ::= A . A A A A A A
R2:2 B1L1c1 S ::= A A . A A A A A
R2:3 B1L1c1 S ::= A A A . A A A A
R2:4 B1L1c1 S ::= A A A A . A A A
R2:5 B1L1c1 S ::= A A A A A . A A
R2:6 B1L1c1 S ::= A A A A A A . A
F2 B1L1c1 S ::= A A A A A A A .
F4 B1L1c1 A ::= 'a' .
EOS

Marpa::R3::Test::is( earley_set_display(2),
    <<'EOS', 'Earley Set 2' );
=== Earley set 2 at B1L1c3 ===
P4 B1L1c3 A ::= . 'a'
F1 B1L1c1 [:start:] ::= S .
R2:2 B1L1c1 S ::= A A . A A A A A
R2:3 B1L1c1 S ::= A A A . A A A A
R2:4 B1L1c1 S ::= A A A A . A A A
R2:5 B1L1c1 S ::= A A A A A . A A
R2:6 B1L1c1 S ::= A A A A A A . A
F2 B1L1c1 S ::= A A A A A A A .
F4 B1L1c2 A ::= 'a' .
EOS

Marpa::R3::Test::is( earley_set_display(3),
    <<'EOS', 'Earley Set 3' );
=== Earley set 3 at B1L1c4 ===
P4 B1L1c4 A ::= . 'a'
F1 B1L1c1 [:start:] ::= S .
R2:3 B1L1c1 S ::= A A A . A A A A
R2:4 B1L1c1 S ::= A A A A . A A A
R2:5 B1L1c1 S ::= A A A A A . A A
R2:6 B1L1c1 S ::= A A A A A A . A
F2 B1L1c1 S ::= A A A A A A A .
F4 B1L1c3 A ::= 'a' .
EOS

Marpa::R3::Test::is( earley_set_display(4),
    <<'EOS', 'Earley Set 4' );
=== Earley set 4 at B1L1c5 ===
P4 B1L1c5 A ::= . 'a'
F1 B1L1c1 [:start:] ::= S .
R2:4 B1L1c1 S ::= A A A A . A A A
R2:5 B1L1c1 S ::= A A A A A . A A
R2:6 B1L1c1 S ::= A A A A A A . A
F2 B1L1c1 S ::= A A A A A A A .
F4 B1L1c4 A ::= 'a' .
EOS

Marpa::R3::Test::is( earley_set_display(5),
    <<'EOS', 'Earley Set 5' );
=== Earley set 5 at B1L1c6 ===
P4 B1L1c6 A ::= . 'a'
F1 B1L1c1 [:start:] ::= S .
R2:5 B1L1c1 S ::= A A A A A . A A
R2:6 B1L1c1 S ::= A A A A A A . A
F2 B1L1c1 S ::= A A A A A A A .
F4 B1L1c5 A ::= 'a' .
EOS

Marpa::R3::Test::is( earley_set_display(6),
    <<'EOS', 'Earley Set 6' );
=== Earley set 6 at B1L1c7 ===
P4 B1L1c7 A ::= . 'a'
F1 B1L1c1 [:start:] ::= S .
R2:6 B1L1c1 S ::= A A A A A A . A
F2 B1L1c1 S ::= A A A A A A A .
F4 B1L1c6 A ::= 'a' .
EOS

Marpa::R3::Test::is( earley_set_display(7),
    <<'EOS', 'Earley Set 7' );
=== Earley set 7 at B1L1c8 ===
F1 B1L1c1 [:start:] ::= S .
F2 B1L1c1 S ::= A A A A A A A .
F4 B1L1c7 A ::= 'a' .
EOS

# vim: expandtab shiftwidth=4:
