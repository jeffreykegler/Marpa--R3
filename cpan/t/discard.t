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

# Example of use of discard events

use 5.010001;

use strict;
use warnings;
use Test::More tests => 1;
use English qw( -no_match_vars );
use Scalar::Util;
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use lib 'inc';
use Marpa::R3::Test;

## no critic (ErrorHandling::RequireCarping);

# Marpa::R3::Display
# name: discard event synopsis

use Marpa::R3;

my $grammar = Marpa::R3::Grammar->new(
    {
        semantics_package => 'My_Nodes',
        source            => \(<<'END_OF_SOURCE'),
:default ::= action => [g1start, g1length, values]

Script ::= Expression+ separator => comma action => do_expression
comma ~ [,]
Expression ::= Subexpression action => [g1start,g1length,value]
Subexpression ::=
    Number action => do_number
    | ('(') Subexpression (')') assoc => group action => do_paren
   || Subexpression ('**') Subexpression assoc => right action => do_power
   || Subexpression ('*') Subexpression  action => do_multiply
    | Subexpression ('/') Subexpression  action => do_divide
   || Subexpression ('+') Subexpression  action => do_add
    | Subexpression ('-') Subexpression  action => do_subtract

Number ~ [\d]+
:discard ~ whitespace event => ws
whitespace ~ [\s]+
# allow comments
:discard ~ <hash comment> event => comment
<hash comment> ~ <terminated hash comment> | <unterminated
   final hash comment>
<terminated hash comment> ~ '#' <hash comment body> <vertical space char>
<unterminated final hash comment> ~ '#' <hash comment body>
<hash comment body> ~ <hash comment char>*
<vertical space char> ~ [\x{A}\x{B}\x{C}\x{D}\x{2028}\x{2029}]
<hash comment char> ~ [^\x{A}\x{B}\x{C}\x{D}\x{2028}\x{2029}]
END_OF_SOURCE
    }
);

# Marpa::R3::Display::End

my $input = <<'EOI';
42*2+7/3, 42*(2+7)/3, 2**7-3, 2**(7-3),
# Hardy-Ramanujan number
1729, 1**3+12**3, 9**3+10**3,
# Next highest taxicab number
# note: weird spacing is deliberate
87539319, 167**3+ 436**3,228**3 + 423**3,255**3+414**3
EOI

my $output_re =
  qr/\A 86[.]3\d+ \s+ 126 \s+ 125 \s+ 16 \s+ 1729 \s+ 1729 \s+ 1729 .*\z/xms;

my $length = length $input;
my @events = ();
my $recce  = Marpa::R3::Recognizer->new(
    {
        grammar        => $grammar,
        event_handlers => {
            "'default" => sub () {
                my ( $slr, @event ) = @_;
                push @events, \@event;
                'ok';
            }
        }
    }
);

my $pos = $recce->read( \$input );
READ: while ( $pos < $length ) {
    $pos = $recce->resume($pos);
}

my $value_ref = $recce->value();
if ( not defined $value_ref ) {
    die "No parse was found, after reading the entire input\n";
}

my $event_ix = 0;
my $result   = '';
for my $expression ( @{ ${$value_ref} } ) {
    my ( $g1start, $g1length, $value ) = @{$expression};
    my $g1end = $g1start + $g1length - 1;
    $result .=
        qq{expression: "}
      . $recce->g1_literal( $g1start, $g1length - 1 )
      . qq{" = }
      . round_value($value);
    $result .= "\n";
  EVENT: while ( $event_ix <= $#events ) {
        my $event = $events[$event_ix];
        my $g1loc = $event->[4];
        last EVENT if $g1loc >= $g1end;
        my $type = $g1loc == $g1start ? 'preceding' : 'internal';
        $result .= join q{ }, $type, display_event( $recce, @{$event} );
        $result .= "\n";
        $event_ix++;
    }
    $result .= "\n";
}

EVENT: while ( $event_ix <= $#events ) {
    my $event = $events[$event_ix];
    $result .= join q{ }, 'trailing', display_event( $recce, @{$event} );
    $result .= "\n";
    $event_ix++;
} ## end EVENT: while ( $event_ix <= $#events )

# round value down, for testing on platforms
# with various float precisions
sub round_value {
    my ($value) = @_;
    return ( int $value * 100 ) / 100;
}

sub display_event {
    my ( $recce, $event_name, $block_id, $start, $length ) = @_;
    if ( $event_name eq 'ws' ) {
        return "ws of length " . $length;
    }
    my $literal = $recce->literal( $block_id, $start, $length );
    $literal =~ s/\n/\\n/xmsg;
    return qq{$event_name: "$literal"};
}

my $expected_result = <<'END_OF_RESULT';
expression: "42*2+7/3" = 86.33

expression: "42*(2+7)/3" = 126
preceding ws of length 1

expression: "2**7-3" = 125
preceding ws of length 1

expression: "2**(7-3)" = 16
preceding ws of length 1

expression: "1729" = 1729
preceding ws of length 1
preceding comment: "# Hardy-Ramanujan number\n"

expression: "1**3+12**3" = 1729
preceding ws of length 1

expression: "9**3+10**3" = 1729
preceding ws of length 1

expression: "87539319" = 87539319
preceding ws of length 1
preceding comment: "# Next highest taxicab number\n"
preceding comment: "# note: weird spacing is deliberate\n"

expression: "167**3+ 436**3" = 87539319
preceding ws of length 1
internal ws of length 1

expression: "228**3 + 423**3" = 87539319
internal ws of length 1
internal ws of length 1

expression: "255**3+414**3" = 87539319

trailing ws of length 1
END_OF_RESULT

Marpa::R3::Test::is( $result, $expected_result,
    "interweave of events and parse tree" );

package My_Nodes;

sub My_Nodes::do_expression {
    my ( $parse, $v ) = @_;
    my @values = @{$v};
    return \@values;

    # say STDERR "pushing value: ", Data::Dumper::Dumper(\@_);
}

sub My_Nodes::do_number {
    my ( $parse, $v ) = @_;
    my ($number) = @{$v};
    return $number + 0;
}

sub My_Nodes::do_paren {
    my ( $parse, $v ) = @_;
    my ($expr) = @{$v};
    return $expr;
}

sub My_Nodes::do_add {
    my ( $parse, $v )    = @_;
    my ( $right, $left ) = @{$v};
    return $right + $left;
}

sub My_Nodes::do_subtract {
    my ( $parse, $v )    = @_;
    my ( $right, $left ) = @{$v};
    return $right - $left;
}

sub My_Nodes::do_multiply {
    my ( $parse, $v )    = @_;
    my ( $right, $left ) = @{$v};
    return $right * $left;
}

sub My_Nodes::do_divide {
    my ( $parse, $v )    = @_;
    my ( $right, $left ) = @{$v};
    return $right / $left;
}

sub My_Nodes::do_power {
    my ( $parse, $v )    = @_;
    my ( $right, $left ) = @{$v};
    return $right**$left;
}

# vim: expandtab shiftwidth=4:
