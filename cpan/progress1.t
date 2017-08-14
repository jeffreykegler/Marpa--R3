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

    local function progress_show(slr, start_ordinal_arg, end_ordinal_arg)
        local slg = slr.slg
        local g1g = slg.g1
        local g1r = slr.g1
        local last_ordinal = g1r:latest_earley_set()
        local start_ordinal = math.tointeger(start_ordinal_arg) or last_ordinal
        if start_ordinal < 0 then start_ordinal = last_ordinal + 1 + start_ordinal end
        if start_ordinal > last_ordinal or start_ordinal < 0 then
             _M._internal_error(
                "Marpa::R3::Scanless::R::g1_progress_show start index is %d, \z
                 must be in range 0-%d",
                 inspect(start_ordinal_arg, {depth=1}),
                 last_ordinal
             )
        end
        local end_ordinal = math.tointeger(end_ordinal_arg) or start_ordinal
        if end_ordinal < 0 then end_ordinal = last_ordinal + 1 + end_ordinal end
        if end_ordinal > last_ordinal or end_ordinal < 0 then
             _M._internal_error(
                "Marpa::R3::Scanless::R::g1_progress_show start index is %d, \z
                 must be in range 0-%d",
                 inspect(end_ordinal_arg, {depth=1}),
                 last_ordinal
             )
        end

        local lines = {}
        for current_ordinal = start_ordinal, end_ordinal do
              -- io.stderr:write(string.format("earley_set_display(%d)\n", current_ordinal))
              local result = { "=== Earley Set " .. current_ordinal .. "===" }
              local current_items = slr:progress(current_ordinal)
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
                  items[#items+1] = { current_ordinal, item_type, xpr_id, xpr_dot, origin }
              end
              local last_ordinal
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
      end
      lines[#lines+1] = '' -- to get a final "\n"
      return table.concat(lines, "\n")
      end

      return progress_show(slr, earley_set_id)

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
