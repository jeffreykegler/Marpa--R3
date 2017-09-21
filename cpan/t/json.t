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

# Test using a JSON parser
# Inspired by a parser written by Peter Stuifzand

# VALUATOR: TODO

use 5.010001;

use strict;
use warnings;
use Test::More tests => 14;
use English qw( -no_match_vars );
use Scalar::Util qw(blessed);
use POSIX qw(setlocale LC_ALL);

POSIX::setlocale(LC_ALL, "C");

use lib 'inc';
use Marpa::R3::Test;

## no critic (ErrorHandling::RequireCarping);

use Marpa::R3;

my $p = MarpaX::JSON->new();

my $data = $p->parse_json(q${"test":"1"}$);
is($data->{test}, 1);

{
    my $test = q${"test":[1,2,3]}$;
    $data = $p->parse_json(q${"test":[1,2,3]}$);
    is_deeply( $data->{test}, [ 1, 2, 3 ], $test );
}

$data = $p->parse_json(q${"test":true}$);
is($data->{test}, 1);

$data = $p->parse_json(q${"test":false}$);
is($data->{test}, '');

$data = $p->parse_json(q${"test":null}$);
is($data->{test}, undef);

$data = $p->parse_json(q${"test":null, "test2":"hello world"}$);
is($data->{test}, undef);
is($data->{test2}, "hello world");

$data = $p->parse_json(q${"test":"1.25"}$);
is($data->{test}, '1.25', '1.25');

$data = $p->parse_json(q${"test":"1.25e4"}$);
is($data->{test}, '1.25e4', '1.25e4');

$data = $p->parse_json(q$[]$);
is_deeply($data, [], '[]');

$data = $p->parse_json(<<'JSON');
[
      {
         "precision": "zip",
         "Latitude":  37.7668,
         "Longitude": -122.3959,
         "Address":   "",
         "City":      "SAN FRANCISCO",
         "State":     "CA",
         "Zip":       "94107",
         "Country":   "US"
      },
      {
         "precision": "zip",
         "Latitude":  37.371991,
         "Longitude": -122.026020,
         "Address":   "",
         "City":      "SUNNYVALE",
         "State":     "CA",
         "Zip":       "94085",
         "Country":   "US"
      }
]
JSON
is_deeply($data, [
    { "precision"=>"zip", Latitude => "37.7668", Longitude=>"-122.3959",
      "Country" => "US", Zip => 94107, Address => '',
      City => "SAN FRANCISCO", State => 'CA' },
    { "precision" => "zip", Longitude => "-122.026020", Address => "",
      City => "SUNNYVALE", Country => "US", Latitude => "37.371991",
      Zip => 94085, State => "CA" }
], 'Geo data');

$data = $p->parse_json(<<'JSON');
{
    "Image": {
        "Width":  800,
        "Height": 600,
        "Title":  "View from 15th Floor",
        "Thumbnail": {
            "Url":    "http://www.example.com/image/481989943",
            "Height": 125,
            "Width":  "100"
        },
        "IDs": [116, 943, 234, 38793]
    }
}
JSON
is_deeply($data, { 
    "Image" => {
        "Width" => 800, "Height" => 600,
        "Title" => "View from 15th Floor",
        "Thumbnail" => {
            "Url" => "http://www.example.com/image/481989943",
            "Height" => 125,
            "Width" => 100,
        },
        "IDs" => [ 116, 943, 234, 38793 ],
    }
}, 'is_deeply test');

my $big_test = <<'JSON';
{
    "source" : "<a href=\"http://janetter.net/\" rel=\"nofollow\">Janetter</a>",
    "entities" : {
        "user_mentions" : [ {
                "name" : "James Governor",
                "screen_name" : "moankchips",
                "indices" : [ 0, 10 ],
                "id_str" : "61233",
                "id" : 61233
            } ],
        "media" : [ ],
        "hashtags" : [ ],
        "urls" : [ ]
    },
    "in_reply_to_status_id_str" : "281400879465238529",
    "geo" : {
    },
    "id_str" : "281405942321532929",
    "in_reply_to_user_id" : 61233,
    "text" : "@monkchips Ouch. Some regrets are harsher than others.",
    "id" : 281405942321532929,
    "in_reply_to_status_id" : 281400879465238529,
    "created_at" : "Wed Dec 19 14:29:39 +0000 2012",
    "in_reply_to_screen_name" : "monkchips",
    "in_reply_to_user_id_str" : "61233",
    "user" : {
        "name" : "Sarah Bourne",
        "screen_name" : "sarahebourne",
        "protected" : false,
        "id_str" : "16010789",
        "profile_image_url_https" : "https://si0.twimg.com/profile_images/638441870/Snapshot-of-sb_normal.jpg",
        "id" : 16010789,
        "verified" : false
    }
}
JSON
$data = $p->parse_json($big_test);

my $trace = $p->trace_json($big_test);
is($trace, <<'END_OF_EXPECTED_TRACE', 'big test trace');
Line 2, column 5, lexeme <lstring>, literal ""source""
Line 2, column 16, lexeme <lstring>, literal ""<a href=\"http://janetter.net/\" rel=\"nofollow\">Janetter</a>""
Line 3, column 5, lexeme <lstring>, literal ""entities""
Line 4, column 9, lexeme <lstring>, literal ""user_mentions""
Line 5, column 17, lexeme <lstring>, literal ""name""
Line 5, column 26, lexeme <lstring>, literal ""James Governor""
Line 6, column 17, lexeme <lstring>, literal ""screen_name""
Line 6, column 33, lexeme <lstring>, literal ""moankchips""
Line 7, column 17, lexeme <lstring>, literal ""indices""
Line 8, column 17, lexeme <lstring>, literal ""id_str""
Line 8, column 28, lexeme <lstring>, literal ""61233""
Line 9, column 17, lexeme <lstring>, literal ""id""
Line 11, column 9, lexeme <lstring>, literal ""media""
Line 12, column 9, lexeme <lstring>, literal ""hashtags""
Line 13, column 9, lexeme <lstring>, literal ""urls""
Line 15, column 5, lexeme <lstring>, literal ""in_reply_to_status_id_str""
Line 15, column 35, lexeme <lstring>, literal ""281400879465238529""
Line 16, column 5, lexeme <lstring>, literal ""geo""
Line 18, column 5, lexeme <lstring>, literal ""id_str""
Line 18, column 16, lexeme <lstring>, literal ""281405942321532929""
Line 19, column 5, lexeme <lstring>, literal ""in_reply_to_user_id""
Line 20, column 5, lexeme <lstring>, literal ""text""
Line 20, column 14, lexeme <lstring>, literal ""@monkchips Ouch. Some regrets are harsher than others.""
Line 21, column 5, lexeme <lstring>, literal ""id""
Line 22, column 5, lexeme <lstring>, literal ""in_reply_to_status_id""
Line 23, column 5, lexeme <lstring>, literal ""created_at""
Line 23, column 20, lexeme <lstring>, literal ""Wed Dec 19 14:29:39 +0000 2012""
Line 24, column 5, lexeme <lstring>, literal ""in_reply_to_screen_name""
Line 24, column 33, lexeme <lstring>, literal ""monkchips""
Line 25, column 5, lexeme <lstring>, literal ""in_reply_to_user_id_str""
Line 25, column 33, lexeme <lstring>, literal ""61233""
Line 26, column 5, lexeme <lstring>, literal ""user""
Line 27, column 9, lexeme <lstring>, literal ""name""
Line 27, column 18, lexeme <lstring>, literal ""Sarah Bourne""
Line 28, column 9, lexeme <lstring>, literal ""screen_name""
Line 28, column 25, lexeme <lstring>, literal ""sarahebourne""
Line 29, column 9, lexeme <lstring>, literal ""protected""
Line 30, column 9, lexeme <lstring>, literal ""id_str""
Line 30, column 20, lexeme <lstring>, literal ""16010789""
Line 31, column 9, lexeme <lstring>, literal ""profile_image_url_https""
Line 31, column 37, lexeme <lstring>, literal ""https://si0.twimg.com/profile_images/638441870/Snapshot-of-sb_normal.jpg""
Line 32, column 9, lexeme <lstring>, literal ""id""
Line 33, column 9, lexeme <lstring>, literal ""verified""
END_OF_EXPECTED_TRACE


$data = $p->parse_json(<<'JSON');
{ "test":  "\u2603" }
JSON
is($data->{test}, "\x{2603}", 'Unicode char');

package MarpaX::JSON;

sub new {
    my ($class) = @_;

    my $parser = bless {}, $class;

    $parser->{grammar} = Marpa::R3::Scanless::G->new(
        {
            semantics_package => 'MarpaX::JSON::Actions',
            source         => \(<<'END_OF_SOURCE'),
:default ::= action => ::first

:start       ::= json

json         ::= object
               | array

object       ::= ('{') members ('}')       action => do_object

# comma is provided as a char class here, to ensure that char classes
# as separators are in the test suite.
members      ::= pair*                 action => ::array separator => [,]

pair         ::= string (':') value action => ::array

value        ::= string
               | object
               | number
               | array
               | 'true'                action => do_true
               | 'false'               action => do_true
               | 'null'                action => ::undef


array        ::= ('[' ']')               action => []
               | ('[') elements (']') 

# comma is provided as a char class here, to ensure that char classes
# as separators are in the test suite.
elements     ::= value+                action => ::array separator => [,]

number         ~ int
               | int frac
               | int exp
               | int frac exp

int            ~ digits
               | '-' digits

digits         ~ [\d]+

frac           ~ '.' digits

exp            ~ e digits

e              ~ 'e'
               | 'e+'
               | 'e-'
               | 'E'
               | 'E+'
               | 'E-'

string       ::= lstring

:lexeme ~ lstring pause => before event => 'before lstring'

lstring        ~ quote in_string quote
quote          ~ ["]
in_string      ~ in_string_char*
in_string_char  ~ [^"] | '\"'

:discard       ~ whitespace
whitespace     ~ [\s]+

END_OF_SOURCE

        }
    );
    return $parser;
}

sub parse {
    my ( $parser, $string ) = @_;

# Marpa::R3::Display
# name: SLIF read/resume example

    my $recce = Marpa::R3::Scanless::R->new(
        {
            grammar        => $parser->{grammar},
            event_handlers => {
                'before lstring' => sub () { 'pause' },
            }
        }
    );
    my $length = length $string;
    for (
        my $pos = $recce->read( \$string );
        $pos < $length;
        $pos = $recce->resume()
        )
    {
        my ( $start, $length ) = $recce->pause_span();
        my $value = substr $string, $start + 1, $length - 2;
        $value = decode_string($value) if -1 != index $value, '\\';
        $recce->lexeme_read( 'lstring', $start, $length, $value ) // die;
    } ## end for ( my $pos = $recce->read( \$string ); $pos < $length...)
    my $per_parse_arg = bless {}, 'MarpaX::JSON::Actions';
    my $value_ref = $recce->old_value($per_parse_arg);
    return ${$value_ref};

# Marpa::R3::Display::End

} ## end sub parse

sub parse_json {
    my ($parser, $string) = @_;
    return $parser->parse($string);
}

sub trace_json {
    my ($parser, $string) = @_;
    my $trace_desc = q{};

# Marpa::R3::Display
# name: SLIF trace example

        my $recce = Marpa::R3::Scanless::R->new(
            {
                grammar        => $parser->{grammar},
                event_handlers => {
                    'before lstring' => sub () { 'pause' },
                }
            }
        );
        my $length = length $string;
        my $pos    = $recce->read( \$string );
        while ( $pos < $length ) {
            my ( $start, $span_length ) = $recce->pause_span();
            my ( $line,  $column )      = $recce->line_column($start);
            my $lexeme = 'lstring';
            my $literal_string = $recce->literal( $start, $span_length );
            $trace_desc .=
                qq{Line $line, column $column, lexeme <$lexeme>, literal "$literal_string"\n};
            my $value = substr $string, $start + 1, $span_length - 2;
            $value = decode_string($value) if -1 != index $value, q{\\};
            $recce->lexeme_read( $lexeme, $start, $span_length, $value ) // die;
            $pos = $recce->resume();
        }
        return $trace_desc;

# Marpa::R3::Display::End

}

sub decode_string {
    my ($s) = @_;

    $s =~ s/\\u([0-9A-Fa-f]{4})/chr(hex($1))/egxms;
    $s =~ s/\\n/\n/gxms;
    $s =~ s/\\r/\r/gxms;
    $s =~ s/\\b/\b/gxms;
    $s =~ s/\\f/\f/gxms;
    $s =~ s/\\t/\t/gxms;
    $s =~ s/\\\\/\\/gxms;
    $s =~ s{\\/}{/}gxms;
    $s =~ s{\\"}{"}gxms;

    return $s;
} ## end sub decode_string

use strict;

sub MarpaX::JSON::Actions::do_object {
    my (undef, $values) = @_;
    my ($members) = @{$values};
    return { map { @{$_} } @{$members} };
}

sub MarpaX::JSON::Actions::do_true {
    return $_[1]->[0] eq 'true';
}

# vim: expandtab shiftwidth=4:
