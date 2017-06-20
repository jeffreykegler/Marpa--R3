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

package Marpa::R3::Common;

# Marpa::R3 "common" methods

use 5.010001;
use warnings;
use strict;
use English qw( -no_match_vars );

use vars qw($VERSION $STRING_VERSION);
$VERSION        = '4.001_047';
$STRING_VERSION = $VERSION;
## no critic(BuiltinFunctions::ProhibitStringyEval)
$VERSION = eval $VERSION;
## use critic

package Marpa::R3::Internal;

use English qw( -no_match_vars );

# Viewing methods, for debugging

my @escape_by_ord = ();
$escape_by_ord[ ord q{\\} ] = q{\\\\};
$escape_by_ord[ ord eval qq{"$_"} ] = $_
    for "\\t", "\\r", "\\f", "\\b", "\\a", "\\e";
$escape_by_ord[0xa] = '\\n';
$escape_by_ord[$_] //= chr $_ for 32 .. 126;
$escape_by_ord[$_] //= sprintf( "\\x%02x", $_ ) for 0 .. 255;

sub Marpa::R3::escape_string {
    my ( $string, $length ) = @_;
    my $reversed = $length < 0;
    if ($reversed) {
        $string = reverse $string;
        $length = -$length;
    }
    my @escaped_chars = ();
    ORD: for my $ord ( map {ord} split //xms, $string ) {
        last ORD if $length <= 0;
        my $escaped_char = $escape_by_ord[$ord] // sprintf( "\\x{%04x}", $ord );
        $length -= length $escaped_char;
        push @escaped_chars, $escaped_char;
    } ## end for my $ord ( map {ord} split //xms, $string )
    @escaped_chars = reverse @escaped_chars if $reversed;
    IX: for my $ix ( reverse 0 .. $#escaped_chars ) {

        # only trailing spaces are escaped
        last IX if $escaped_chars[$ix] ne q{ };
        $escaped_chars[$ix] = '\\s';
    } ## end IX: for my $ix ( reverse 0 .. $#escaped_chars )
    return join q{}, @escaped_chars;
} ## end sub escape_string

sub Marpa::R3::flatten_hash_args {
    my ($hash_arg_array) = @_;
    my %flat_args = ();
    for my $hash_ref (@{$hash_arg_array}) {
        my $ref_type = ref $hash_ref;
        if ( not $ref_type ) {
            return undef, qq{"%s expects args as ref to HASH, got non-reference instead};
        } ## end if ( not $ref_type )
        if ( $ref_type ne 'HASH' ) {
            return undef, qq{"%s expects args as ref to HASH, got ref to $ref_type instead};
        } ## end if ( $ref_type ne 'HASH' )
        ARG: for my $arg_name ( keys %{$hash_ref} ) {
            $flat_args{$arg_name} = $hash_ref->{$arg_name};
        }
    } ## end for my $args (@hash_ref_args)
    return \%flat_args;
}

sub Marpa::R3::exception {
    my $exception = join q{}, @_;
    $exception =~ s/ \n* \z /\n/xms;
    die($exception) if $Marpa::R3::JUST_DIE;
    CALLER: for ( my $i = 0; 1; $i++) {
        my ($package ) = caller($i);
        last CALLER if not $package;
        last CALLER if not 'Marpa::R3::' eq substr $package, 0, 11;
        $Carp::Internal{ $package } = 1;
    }
    Carp::croak($exception, q{Marpa::R3 exception});
}

# Could/should this be made more efficient by caching line starts,
# then binary searching?
sub Marpa::R3::Internal::line_column {
    my ( $p_string, $pos ) = @_;
    state $EOL = "\n";
    my $line = () = substr( ${$p_string}, 0, $pos ) =~ /$EOL/g;
    my $column = $line ? $pos - $+[0] + 1 : $pos + 1;
    return [$line+1, $column];
}

# Returns a one-line string that is the escaped equivalent
# of its arguments, and whose length is at most $max.
# Returns a list of two elements: the escaped string and
# a boolean indicating if it was truncated
sub Marpa::R3::Internal::substr_as_line {
    my ( $p_string, $pos, $length, $max ) = @_;
    my $truncated     = 0;
    my $used          = 0;
    my @escaped_chars = ();
    my $trailing_ws   = 0;
    my $last_ix = $max > $length ? $pos + $length : $pos + $max;
  CHAR: for ( my $ix = $pos ; $ix <= $last_ix ; $ix++ ) {
        last CHAR if $used >= $max;
        my $char = substr ${$p_string}, $ix, 1;
        $trailing_ws = $char =~ /\s/ ? $trailing_ws + 1 : 0;
        my $ord = ord $char;
        my $escaped_char = $escape_by_ord[$ord] // sprintf( "\\x{%04x}", $ord );

        # say STDERR "ord=$ord $escaped_char";
        $used += length $escaped_char;
        push @escaped_chars, $escaped_char;
    }
    while ( $trailing_ws-- ) {
        my $ws_char = pop @escaped_chars;
        $used -= length $ws_char;
    }
    while ( $used > $max ) {
        my $excess_char = pop @escaped_chars;
        $used -= length $excess_char;
        $truncated = 1;
    }
    return ( join q{}, @escaped_chars ), $truncated;
}

# Returns a two-line summary of a substring --
# a first line with descriptive information and
# a one-line escaped version, indented 2 spaces
sub Marpa::R3::Internal::substr_as_2lines {
    my ( $what, $p_string, $pos, $length, $max ) = @_;
    my ($escaped, $trunc) = substr_as_line( $p_string, $pos, $length, $max );
    my ($line_no, $column) = @{line_column( $p_string, $pos)};
    my @pieces = ($what);
    push @pieces, $trunc ? 'begins' : 'is';
    push @pieces, qq{at line $line_no, column $column:};
    my $line1 = join q{ }, @pieces;
    return "$line1\n  $escaped";
}

1;

# vim: set expandtab shiftwidth=4:
