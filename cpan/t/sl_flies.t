#!/usr/bin/perl
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
# Note: converted from timeflies.t NAIF test to SLIF

# This example is from Ralf Muschall, who clearly knows English
# grammar better than most native speakers.  I've reworked the
# terminology to follow _A Comprehensive Grammar of the English
# Language_, by Quirk, Greenbaum, Leech and Svartvik.  My edition
# was the "Seventh (corrected) impression 1989".
#
# When it is not a verb, I treat "like"
# as a preposition in an adjunct of manner,
# as per 8.79, p. 557; 9.4, pp. 661; and 9.48, pp. 698-699.
#
# The saying "time flies like an arrow; fruit flies like a banana"
# is attributed to Groucho Marx, but there is no reason to believe
# he ever said it.  Apparently, the saying
# first appeared on the Usenet on net.jokes in 1982.
# I've documented this whole thing on Wikipedia:
# http://en.wikipedia.org/wiki/Time_flies_like_an_arrow
#
# The permalink is:
# http://en.wikipedia.org/w/index.php?title=Time_flies_like_an_arrow&oldid=311163283

use 5.010001;
use strict;
use warnings;
use English qw( -no_match_vars );

use Test::More tests => 1;
use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

## no critic (Subroutines::RequireArgUnpacking)

sub do_sva_sentence      { return "sva($_[1];$_[2];$_[3])" }
sub do_svo_sentence      { return "svo($_[1];$_[2];$_[3])" }
sub do_adjunct           { return "adju($_[1];$_[2])" }
sub do_adjective         { return "adje(${$_[1]})" }
sub do_qualified_subject { return "s($_[1];$_[2])" }
sub do_bare_subject      { return "s($_[1])" }
sub do_noun              { return "n(${$_[1]})" }
sub do_verb              { return "v(${$_[1]})" }
sub do_object            { return "o($_[1];$_[2])" }
sub do_article           { return "art(${$_[1]})" }
sub do_preposition       { return "pr(${$_[1]})" }

## use critic

my $grammar = Marpa::R3::Scanless::G->new(
    {
        source => \<<'END_OF_DSL',
sentence    ::= subject verb adjunct    action => do_sva_sentence
sentence    ::= subject verb object     action => do_svo_sentence
adjunct     ::= preposition object      action => do_adjunct
adjective   ::= adjective_noun_lex      action => do_adjective
subject     ::= adjective noun          action => do_qualified_subject
subject     ::= noun                    action => do_bare_subject
noun        ::= adjective_noun_lex      action => do_noun
verb        ::= verb_lex                action => do_verb
object      ::= article noun            action => do_object
article     ::= article_lex             action => do_article
preposition ::= preposition_lex         action => do_preposition
adjective_noun_lex ~ unicorn
verb_lex ~ unicorn
article_lex ~ unicorn
preposition_lex ~ unicorn
unicorn ~ [\d\D]
END_OF_DSL
    }
);

my $expected = <<'EOS';
sva(s(n(fruit));v(flies);adju(pr(like);o(art(a);n(banana))))
sva(s(n(time));v(flies);adju(pr(like);o(art(an);n(arrow))))
svo(s(adje(fruit);n(flies));v(like);o(art(a);n(banana)))
svo(s(adje(time);n(flies));v(like);o(art(an);n(arrow)))
EOS
my @actual = ();

my %lexical_class = (
    'preposition_lex'    => 'like',
    'verb_lex'           => 'like flies',
    'adjective_noun_lex' => 'fruit banana time arrow flies',
    'article_lex'        => 'a an',
);
my %vocabulary = ();
for my $lexical_class (keys %lexical_class) {
    my $words = $lexical_class{$lexical_class};
    for my $word ( split q{ }, $words ) {
        push @{ $vocabulary{$word} }, $lexical_class;
    }
} ## end for my $lexical_class (%lexical_class)

for my $data ( 'time flies like an arrow', 'fruit flies like a banana' ) {

    my $recce = Marpa::R3::Scanless::R->new( {
        grammar => $grammar,
        semantics_package => 'main',
    } );
    die 'Failed to create recognizer' if not $recce;

    my $lexeme_start = 0;
    $recce->read( \$data, 0, 0 );
    for my $word ( split q{ }, $data ) {
        for my $type ( @{ $vocabulary{$word} } ) {
            $recce->lexeme_alternative( $type, \$word )
                or die 'Recognition failed';
        }
        $recce->lexeme_complete($lexeme_start, length $word);
        $lexeme_start += length $word;
    } ## end for my $word ( split q{ }, $data )

    while ( defined( my $value_ref = $recce->value() ) ) {
        my $value = $value_ref ? ${$value_ref} : 'No parse';
        push @actual, $value;
    }
} ## end for my $data ( 'time flies like an arrow', ...)

Marpa::R3::Test::is( ( join "\n", sort @actual ) . "\n",
    $expected, 'Ambiguous English sentences' );

# vim: expandtab shiftwidth=4:
