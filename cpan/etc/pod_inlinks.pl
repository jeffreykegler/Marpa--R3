#!/usr/bin/perl
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

use 5.010001;

use Pod::Simple::SimpleTree;
use Data::Dumper;

my $filename = shift;
my $tree = Pod::Simple::SimpleTree->new->parse_file($filename)->root;

my %headers = ();

sub find_header {
     my ($subtree) = @_;
     if (ref $subtree eq 'ARRAY') {
         if (substr($subtree->[0], 0, 4) eq 'head') {
            $headers{$subtree->[2]} = 1;
            # say $subtree->[2];
         }
         if ($subtree->[0] eq 'L') {
             my $hash = $subtree->[1];
             return if not $hash->{type} eq 'pod';
             return if exists $hash->{to};
             return if not exists $hash->{section};
             push @section_ref, $hash->{section};
         }
       find_header($_) for @{$subtree};
     }
     return;
}

# say Dumper($tree);
find_header($tree);
for my $section_ref (@section_ref) {
    if (not exists $headers{$section_ref})
    {
        say STDERR "Unresolved internal section reference: $section_ref"
    }
}
