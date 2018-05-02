# Marpa::R3 is Copyright (C) 2018, Jeffrey Kegler.
#
# This module is free software; you can redistribute it and/or modify it
# under the same terms as Perl 5.10.1. For more details, see the full text
# of the licenses in the directory LICENSES.
#
# This program is distributed in the hope that it will be
# useful, but it is provided "as is" and without any express
# or implied warranties. For details, see the full text of
# of the licenses in the directory LICENSES.

package Marpa::R3;

use 5.010001;
use strict;
use warnings;

use vars qw($VERSION $STRING_VERSION @ISA $DEBUG);
$VERSION        = '4.001_052';
$STRING_VERSION = $VERSION;
## no critic (BuiltinFunctions::ProhibitStringyEval)
$VERSION = eval $VERSION;
## use critic
$DEBUG = 0;

use Carp;
use English qw( -no_match_vars );
use XSLoader;

use Marpa::R3::Version;

XSLoader::load( 'Marpa::R3', $Marpa::R3::STRING_VERSION );

if ( not $ENV{'MARPA_AUTHOR_TEST'} ) {
    $Marpa::R3::DEBUG = 0;
}
else {
    Marpa::R3::Thin::debug_level_set(1);
    $Marpa::R3::DEBUG = 1;
}

sub version_ok {
    my ($sub_module_version) = @_;
    return 'not defined' if not defined $sub_module_version;
    return "$sub_module_version does not match Marpa::R3::VERSION " . $VERSION
        if $sub_module_version != $VERSION;
    return;
} ## end sub version_ok

# Set up the error values
my @error_names = Marpa::R3::Thin::error_names();
for ( my $error = 0; $error <= $#error_names; ) {
    my $current_error = $error;
    (my $name = $error_names[$error] ) =~ s/\A MARPA_ERR_//xms;
    no strict 'refs';
    *{ "Marpa::R3::Error::$name" } = \$current_error;
    # This shuts up the "used only once" warning
    my $dummy = eval q{$} . 'Marpa::R3::Error::' . $name;
    $error++;
}

my $version_result;
require Marpa::R3::Internal;
( $version_result = version_ok($Marpa::R3::Internal::VERSION) )
    and die 'Marpa::R3::Internal::VERSION ', $version_result;

require Marpa::R3::Common;
( $version_result = version_ok($Marpa::R3::Common::VERSION) )
    and die 'Marpa::R3::Common::VERSION ', $version_result;

require Marpa::R3::MetaG;
( $version_result = version_ok($Marpa::R3::MetaG::VERSION) )
    and die 'Marpa::R3::MetaG::VERSION ', $version_result;

require Marpa::R3::SLG;
( $version_result = version_ok($Marpa::R3::Grammar::VERSION) )
    and die 'Marpa::R3::Grammar::VERSION ', $version_result;

require Marpa::R3::SLR;
( $version_result = version_ok($Marpa::R3::Recognizer::VERSION) )
    and die 'Marpa::R3::Recognizer::VERSION ', $version_result;

require Marpa::R3::SLV;
( $version_result = version_ok($Marpa::R3::Valuer::VERSION) )
    and die 'Marpa::R3::Valuer::VERSION ', $version_result;

require Marpa::R3::MetaAST;
( $version_result = version_ok($Marpa::R3::MetaAST::VERSION) )
    and die 'Marpa::R3::MetaAST::VERSION ', $version_result;

require Marpa::R3::ASF;
( $version_result = version_ok($Marpa::R3::ASF::VERSION) )
    and die 'Marpa::R3::ASF::VERSION ', $version_result;

require Marpa::R3::ASF2;
( $version_result = version_ok($Marpa::R3::ASF2::VERSION) )
    and die 'Marpa::R3::ASF2::VERSION ', $version_result;

require Marpa::R3::X;
( $version_result = version_ok($Marpa::R3::X::VERSION) )
    and die 'Marpa::R3::X::VERSION ', $version_result;

1;

# vim: set expandtab shiftwidth=4:
