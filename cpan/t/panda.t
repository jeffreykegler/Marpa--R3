#!/usr/bin/perl
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

# This example parses ambiguous English sentences.  The target annotation
# is Penn Treebank's syntactic bracketing tags.  For details, see
# http://www.cis.upenn.edu/~treebank/

# TODO -- Revisit this once I decide whether ASF operates at XRL or IRL
# level.
# MITOSIS: ASF

use 5.010001;

use strict;
use warnings;
use English qw( -no_match_vars );
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use Test::More tests => 4;
use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

# Marpa::R3::Display
# name: ASF synopsis grammar
# start-after-line: END_OF_SOURCE
# end-before-line: '^END_OF_SOURCE$'

my $dsl = <<'END_OF_SOURCE';

:default ::= action => [ values ] bless => ::lhs
lexeme default = action => [ value ] bless => ::name

S   ::= NP  VP  period  bless => S

NP  ::= NN              bless => NP
    |   NNS          bless => NP
    |   DT  NN          bless => NP
    |   NN  NNS         bless => NP
    |   NNS CC NNS  bless => NP

VP  ::= VBZ NP          bless => VP
    | VP VBZ NNS        bless => VP
    | VP CC VP bless => VP
    | VP VP CC VP bless => VP
    | VBZ bless => VP

period ~ '.'

:discard ~ whitespace
whitespace ~ [\s]+

CC ~ 'and'
DT  ~ 'a' | 'an'
NN  ~ 'panda'
NNS  ~ 'shoots' | 'leaves'
VBZ ~ 'eats' | 'shoots' | 'leaves'

END_OF_SOURCE

# Marpa::R3::Display::End

my $grammar = Marpa::R3::Grammar->new(
    { bless_package => 'PennTags', source => \$dsl, } );

# Marpa::R3::Display
# name: ASF synopsis output
# start-after-line: END_OF_OUTPUT
# end-before-line: '^END_OF_OUTPUT$'

my $full_expected = <<'END_OF_OUTPUT';
(S (NP (DT a) (NN panda))
   (VP (VBZ eats) (NP (NNS shoots) (CC and) (NNS leaves)))
   (. .))
(S (NP (DT a) (NN panda))
   (VP (VP (VBZ eats) (NP (NNS shoots))) (CC and) (VP (VBZ leaves)))
   (. .))
(S (NP (DT a) (NN panda))
   (VP (VP (VBZ eats)) (VP (VBZ shoots)) (CC and) (VP (VBZ leaves)))
   (. .))
END_OF_OUTPUT

# Marpa::R3::Display::End

# Marpa::R3::Display
# name: ASF synopsis input

my $sentence = 'a panda eats shoots and leaves.';

# Marpa::R3::Display::End

my @actual = ();

my $recce = Marpa::R3::Recognizer->new( { grammar => $grammar } );

$recce->read( \$sentence );

my $valuer = Marpa::R3::Valuer->new( { recognizer => $recce } );
while ( defined( my $value_ref = $valuer->value() ) ) {
    my $value = $value_ref ? ${$value_ref}->bracket() : 'No parse';
    push @actual, $value;
}

Marpa::R3::Test::is( ( join "\n", sort @actual ) . "\n",
    $full_expected, 'Ambiguous English sentence using value()' );

# Marpa::R3::Display
# name: ASF synopsis code

my $panda_grammar = Marpa::R3::Grammar->new(
    { source => \$dsl, bless_package => 'PennTags', } );
my $panda_recce = Marpa::R3::Recognizer->new( { grammar => $panda_grammar } );
$panda_recce->read( \$sentence );
my $asf = Marpa::R3::ASF->new( { recognizer => $panda_recce } );
my $full_result = $asf->traverse( {}, \&full_traverser );
my $pruned_result = $asf->traverse( {}, \&pruning_traverser );

# Marpa::R3::Display::End

# Marpa::R3::Display
# name: ASF synopsis full traverser code

sub full_traverser {

    # This routine converts the glade into a list of Penn-tagged elements.
    # It is called recursively.
    my ( $glade, $scratch ) = @_;
    my $rule_id     = $glade->rule_id();
    my $symbol_id   = $glade->symbol_id();
    my $symbol_name = $panda_grammar->g1_symbol_name($symbol_id);

    # A token is a single choice, and we know enough to fully Penn-tag it
    if ( not defined $rule_id ) {
        my $literal  = $glade->literal();
        my $penn_tag = penn_tag($symbol_name);
        return ["($penn_tag $literal)"];
    } ## end if ( not defined $rule_id )

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
            }
            @results = @new_results;
        } ## end for my $rh_ix ( 0 .. $length - 1 )

        # Special case for the start rule
        if ( $symbol_name eq '[:start:]' ) {
            return [ map { join q{}, @{$_} } @results ];
        }

        # Now we have a list of choices, as a list of lists.  Each sub list
        # is a list of Penn-tagged elements, which we need to join into
        # a single Penn-tagged element.  The result will be to collapse
        # one level of lists, and leave us with a list of Penn-tagged
        # elements
        my $join_ws = q{ };
        $join_ws = qq{\n   } if $symbol_name eq 'S';
        push @return_value, map {
                '('
              . penn_tag($symbol_name) . q{ }
              . ( join $join_ws, @{$_} ) . ')'
        } @results;

        # Look at the next alternative in this glade, or end the
        # loop if there is none
        last CHOICE if not defined $glade->next();

    } ## end CHOICE: while (1)

    # Return the list of Penn-tagged elements for this glade
    return \@return_value;
}

# Marpa::R3::Display::End

my $cooked_result =  join "\n", (sort @{$full_result}), q{};
Marpa::R3::Test::is( $cooked_result, $full_expected,
    'Ambiguous English sentence using ASF' );

# Marpa::R3::Display
# name: ASF synopsis pruning traverser code

sub penn_tag {
   my ($symbol_name) = @_;
   return q{.} if $symbol_name eq 'period';
   return $symbol_name;
}

sub pruning_traverser {

    # This routine converts the glade into a list of Penn-tagged elements.  It is called recursively.
    my ( $glade, $scratch )     = @_;
    my $rule_id     = $glade->rule_id();
    my $symbol_id   = $glade->symbol_id();
    my $symbol_name = $panda_grammar->g1_symbol_name($symbol_id);

    # A token is a single choice, and we know enough to fully Penn-tag it
    if ( not defined $rule_id ) {
        my $literal = $glade->literal();
        my $penn_tag = penn_tag($symbol_name);
        return "($penn_tag $literal)";
    }

    my $length = $glade->rh_length();
    my @return_value = map { $glade->rh_value($_) } 0 .. $length - 1;

    # Special case for the start rule
    return ( join q{ }, @return_value ) . "\n" if  $symbol_name eq '[:start:]';

    my $join_ws = q{ };
    $join_ws = qq{\n   } if $symbol_name eq 'S';
    my $penn_tag = penn_tag($symbol_name);
    return "($penn_tag " . ( join $join_ws, @return_value ) . ')';

}

# Marpa::R3::Display::End

# Marpa::R3::Display
# name: ASF pruned synopsis output
# start-after-line: END_OF_OUTPUT
# end-before-line: '^END_OF_OUTPUT$'

my $pruned_expected = <<'END_OF_OUTPUT';
(S (NP (DT a) (NN panda))
   (VP (VBZ eats) (NP (NNS shoots) (CC and) (NNS leaves)))
   (. .))
END_OF_OUTPUT

# Marpa::R3::Display::End

Marpa::R3::Test::is( $pruned_result, $pruned_expected,
    'Ambiguous English sentence using ASF: pruned' );

my $located_actual = $asf->traverse( {}, \&located_traverser );

sub located_traverser {

    # This routine converts the glade into a list of Penn-tagged elements.  It is called recursively.
    my ($glade, $scratch )     = @_;
    my $rule_id     = $glade->rule_id();
    my $symbol_id   = $glade->symbol_id();
    my $symbol_name = $panda_grammar->g1_symbol_name($symbol_id);

    # A token is a single choice, and we know enough to fully Penn-tag it
    if ( not defined $rule_id ) {
        my $literal = $glade->literal();
        my $penn_tag = penn_tag($symbol_name);
        return "($penn_tag $literal)";
    }

    my $rh_length = $glade->rh_length();
    my @return_value = map { $glade->rh_value($_) } 0 .. $rh_length - 1;

    # Special case for the start rule
    return ( join q{ }, @return_value) . "\n" if  $symbol_name eq '[:start:]' ;

# Marpa::R3::Display::Start
# name: ASF g1_span() traverser method example

    my ( $g1_start, $g1_length ) = $glade->g1_span();

# Marpa::R3::Display::End

    my $asf = $glade->asf();
    my $recce = $asf->recognizer();
    my ( $block1, $pos1 ) = $recce->g1_to_block_first( $g1_start );
    my ( $block2, $pos2 ) = $recce->g1_to_block_last( $g1_start + $g1_length - 1 );
    my $location = $recce->lc_brief($block1, $pos1, $block2, $pos2);

    # Remove clutter in the display:
    #   Everything is expected to be in block 1, line 1
    $location =~ s/ ^ B1L1c //xms;

    my $atsign = q{@};
    my $join_ws = q{ };
    $join_ws = qq{\n   } if $symbol_name eq 'S';
    return "($symbol_name$atsign$location " . ( join $join_ws, @return_value ) . ')';
    my $penn_tag = penn_tag($symbol_name);
    return "($penn_tag$atsign$location " . ( join $join_ws, @return_value ) . ')';

}

# name: ASF located synopsis output
# start-after-line: END_OF_OUTPUT
# end-before-line: '^END_OF_OUTPUT$'

my $located_expected = <<'END_OF_OUTPUT';
(S@1-31 (NP@1-7 (DT a) (NN panda))
   (VP@9-30 (VBZ eats) (NP@14-30 (NNS shoots) (CC and) (NNS leaves)))
   (. .))
END_OF_OUTPUT

# Marpa::R3::Display::End

Marpa::R3::Test::is(  $located_actual, $located_expected, 'Located Penn tag example' );

package PennTags;

sub contents {
    join( $_[0], map { $_->bracket() } @{ $_[1] } );
}

sub PennTags::S::bracket { "(S " . contents( "\n   ", $_[0] ) . ")" }
sub PennTags::NP::bracket { "(NP " . contents( ' ', $_[0] ) . ")" }
sub PennTags::VP::bracket { "(VP " . contents( ' ', $_[0] ) . ")" }
sub PennTags::PP::bracket { "(PP " . contents( ' ', $_[0] ) . ")" }

sub PennTags::CC::bracket  {"(CC $_[0]->[0])"}
sub PennTags::DT::bracket  {"(DT $_[0]->[0])"}
sub PennTags::IN::bracket  {"(IN $_[0]->[0])"}
sub PennTags::NN::bracket  {"(NN $_[0]->[0])"}
sub PennTags::NNS::bracket {"(NNS $_[0]->[0])"}
sub PennTags::VB::bracket  {"(VB $_[0]->[0])"}
sub PennTags::VBP::bracket {"(VBP $_[0]->[0])"}
sub PennTags::VBZ::bracket {"(VBZ $_[0]->[0])"}

sub PennTags::period::bracket {"(. .)"}

# vim: expandtab shiftwidth=4:
