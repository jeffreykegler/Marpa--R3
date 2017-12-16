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

use 5.010001;
use strict;
use warnings;
use English qw( -no_match_vars );
use Data::Dumper;

# This is a 'meta' tool, so I relax some of the
# restrictions I use to guarantee portability.
use autodie;

# I expect to be run from a subdirectory in the
# development heirarchy
use Marpa::R3;

use Getopt::Long;
my $verbose         = 1;
my $help_flag       = 0;
my $result          = Getopt::Long::GetOptions(
    'help'       => \$help_flag,
);
die "usage $PROGRAM_NAME [--help] file ...\n" if $help_flag;

my $p_bnf = do { local $RS = undef; \(<>) };
my $ast = Marpa::R3::Internal::MetaAST->new($p_bnf);
my $parse_result = $ast->ast_to_hash($p_bnf);

$Data::Dumper::Sortkeys = 1;
print Data::Dumper::Dumper( $ast->{top_node} );
