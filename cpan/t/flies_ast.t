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

# Note: version of sl_timeflies.t with AST semantics

# This example parses ambiguous English sentences.  The target annotation
# is Penn Treebank's syntactic bracketing tags.  For details, see
# http://www.cis.upenn.edu/~treebank/

# This example originally came from Ralf Muschall.  Ruslan Shvedov
# reworked my implementation, converting it to Marpa's DSL and
# Penn Treebank.  Ruslan and Ralf clearly know English grammar better than
# most of us native speakers.

# 'time', 'fruit', and 'flies' can be nouns or verbs, 'like' can be
# a preposition or a verb.  This creates syntactic ambiguity shown
# in the parse results.

# Modifier nouns are not tagged or lexed as adjectives (JJ), because
# "Nouns that are used as modifiers, whether in isolation or in sequences,
# should be tagged as nouns (NN, NNS) rather than as adjectives (JJ)."
# -- ftp://ftp.cis.upenn.edu/pub/treebank/doc/tagguide.ps.gz

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
use POSIX qw(setlocale LC_ALL);
use Test::More tests => 1;

POSIX::setlocale(LC_ALL, "C");

use lib 'inc';
use Marpa::R3::Test;
use Marpa::R3;

# Marpa::R3::Display
# name: time-flies DSL synopsis

my $grammar = Marpa::R3::Grammar->new(
    {   source => \(<<'END_OF_SOURCE'),

:default     ::= action => [ name, values ]
lexeme default = action => [ name, value ]

S   ::= NP  VP  period

NP  ::= NN
    |   DT  NN
    |   NN  NNS

VP  ::= VBP NP
    |   VBP PP
    |   VBZ PP

PP  ::= IN  NP

period ~ '.'

:discard ~ whitespace
whitespace ~ [\s]+

DT  ~ 'a' | 'an'
NN  ~ 'arrow' | 'banana'
NNS ~ 'flies'
VBZ ~ 'flies'
NN  ~ 'fruit':i
VBP ~ 'fruit':i
IN  ~ 'like'
VBP ~ 'like'
NN  ~ 'time':i
VBP ~ 'time':i

END_OF_SOURCE
    }
);

# Marpa::R3::Display::End

my $expected = <<'EOS';
(S
  (NP (NN Time) (NNS flies))
  (VP (VBP like)
    (NP (DT an) (NN arrow)))
  (. .))
(S
  (NP (NN Time))
  (VP (VBZ flies)
    (PP (IN like)
      (NP (DT an) (NN arrow))))
  (. .))
(S
  (NP (NN Fruit) (NNS flies))
  (VP (VBP like)
    (NP (DT a) (NN banana)))
  (. .))
(S
  (NP (NN Fruit))
  (VP (VBZ flies)
    (PP (IN like)
      (NP (DT a) (NN banana))))
  (. .))
EOS

my $paragraph = <<END_OF_PARAGRAPH;
Time flies like an arrow.
Fruit flies like a banana.
END_OF_PARAGRAPH

# structural tags -- need a newline
my %s_tags = map { $_ => undef } qw{ NP VP PP period };

my @actual = ();
for my $sentence (split /\n/, $paragraph){

    my $recce = Marpa::R3::Recognizer->new( { grammar => $grammar  } );
    $recce->read( \$sentence );

    my $valuer = Marpa::R3::Valuer->new( { recognizer => $recce  } );
    while ( defined( my $value_ref = $valuer->value() ) ) {
        my $value = $value_ref ? bracket ( ${$value_ref} ) : 'No parse';
        push @actual, $value;
    }
}

sub bracket   {
    my ($tag, @contents) = @{ $_[0] };
    state $level++;
    my $bracketed =
        exists $s_tags{$tag} ? ("\n" . ("  " x ($level-1))) : '';
    $tag = '.' if $tag eq 'period';
    if (ref $contents[0]){
        $bracketed .=
                "($tag "
            .   join(' ', map { bracket($_) } @contents)
            .   ")";
    }
    else {
        $bracketed .= "($tag $contents[0])";
    }
    $level--;
    $bracketed =~ s/\s\n/\n/g;
    return $bracketed;
}

Marpa::R3::Test::is( ( join "\n", @actual ) . "\n",
    $expected, 'Ambiguous English sentences' );

1;    # In case used as "do" file

# vim: set expandtab shiftwidth=4:

