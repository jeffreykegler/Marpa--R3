# Marpa::R3 is Copyright (C) 2016, Jeffrey Kegler.
#
# This module is free software; you can redistribute it and/or modify it
# under the same terms as Perl 5.10.1. For more details, see the full text
# of the licenses in the directory LICENSES.
#
# This program is distributed in the hope that it will be
# useful, but it is provided “as is” and without any express
# or implied warranties. For details, see the full text of
# of the licenses in the directory LICENSES.

package Marpa::R3::Common;

# Marpa::R3 "common" methods

use 5.010001;
use warnings;
use strict;
use English qw( -no_match_vars );

use vars qw($VERSION $STRING_VERSION);
$VERSION        = '4.001_003';
$STRING_VERSION = $VERSION;
## no critic(BuiltinFunctions::ProhibitStringyEval)
$VERSION = eval $VERSION;
## use critic

package Marpa::R3::Internal::Common;

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

sub Marpa::R3::uncaught_error {
    my ($error) = @_;

    # This would be Carp::confess, but in the testing
    # the stack trace includes the hoped for error
    # message, which causes spurious success reports.
    Carp::croak( "libmarpa reported an error which Marpa::R3 did not catch\n",
        $error );
} ## end sub Marpa::R3::uncaught_error

1;

# vim: set expandtab shiftwidth=4:
