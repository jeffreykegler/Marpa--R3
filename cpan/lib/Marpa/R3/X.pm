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

# Marpa::R3 exceptions and their methods

# Adapted from CPAN's Exception::Class module

package Marpa::R3::X;

use 5.010001;
use warnings;
use strict;
use English qw( -no_match_vars );

use vars qw($VERSION $STRING_VERSION);
$VERSION        = '4.001_048';
$STRING_VERSION = $VERSION;
## no critic(BuiltinFunctions::ProhibitStringyEval)
$VERSION = eval $VERSION;
## use critic

package Marpa::R3::Internal::X;

use warnings;
use strict;
use English qw( -no_match_vars );
use Scalar::Util qw( blessed );

use overload

    # an exception is always true
    bool => sub {1}, '""' => 'as_string', fallback => 1;

# Create accessor routines

sub throw {
    my $proto = shift;
    $proto->rethrow if ref $proto;
    die $proto->new(@_);
}

sub rethrow {
    my $self = shift;
    die $self;
}

sub new {
    my ($class, $args)  = @_;
    $args //= { error => $_[0] };
    return bless $args, $class;
}

sub description {
    return 'Generic exception';
}

sub as_string {
    my $self      = shift;
    my $string    = q{};
    my $to_string = $self->{to_string};
    if ( $to_string and ref $to_string eq 'CODE' ) {
        $string = &{$to_string}($self);
    }
    else {
      FIELD: for my $field ( sort keys %{$self} ) {
            if ( $field eq 'try' ) {
                my $try_to_string = $self->{try};
                if ( ref $try_to_string ne 'CODE' ) {
                    $string .= qq{$field: [!not a CODE object!]\n};
                }
                $string .= &{$try_to_string}($self);
                next FIELD;
            }
            next FIELD if $field =~ /\A (slg|slr|tracer|msg|fatal) \z/;
            my $value = $self->{$field};
            if ( not defined $value ) {
                $string .= "$field: [not defined]\n";
                next FIELD;
            }
            my $ref_type = ref $value;
            if ($ref_type) {
                $string .= "$field: ref to $ref_type\n";
                next FIELD;
            }
            $string .= "$field: $value\n";
        }
    }
    my $fatal = $self->{fatal} // 1;
    if ($fatal) {
        $string =
            qq{========= Marpa::R3 Fatal error =========\n}
          . $string
          . qq{=========================================\n};
    }
    return $string;
}

sub caught {
    my $class = shift;
    my $e = $@;
    return unless defined $e && blessed($e) && $e->isa($class);
    return $e;
}

1;
