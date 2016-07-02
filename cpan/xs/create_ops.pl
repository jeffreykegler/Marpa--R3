#!perl
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

use 5.010001;
use strict;
use warnings;
use English qw( -no_match_vars );
use autodie;

if (scalar @ARGV != 0) {
    die("usage: $PROGRAM_NAME > marpa_slifop.h");
}

my @ops = sort { $a->[0] cmp $b->[0] }
    [ "alternative",             "MARPA_OP_ALTERNATIVE" ],
    [ "bless",                   "MARPA_OP_BLESS" ],
    [ "callback",                "MARPA_OP_CALLBACK" ],
    [ "earleme_complete",        "MARPA_OP_EARLEME_COMPLETE" ],
    [ "invalid_char",            "MARPA_OP_INVALID_CHAR" ],
    [ "noop",                    "MARPA_OP_NOOP" ],
    [ "push_constant",           "MARPA_OP_PUSH_CONSTANT" ],
    [ "result_is_array",         "MARPA_OP_RESULT_IS_ARRAY" ],
    [ "result_is_constant",      "MARPA_OP_RESULT_IS_CONSTANT" ],
    [ "lua",               "MARPA_OP_LUA" ];

say <<'END_OF_PREAMBLE';
/*
 * Marpa::R3 is Copyright (C) 2016, Jeffrey Kegler.
 *
 * This module is free software; you can redistribute it and/or modify it
 * under the same terms as Perl 5.10.1. For more details, see the full text
 * of the licenses in the directory LICENSES.
 *
 * This program is distributed in the hope that it will be
 * useful, but it is provided “as is” and without any express
 * or implied warranties. For details, see the full text of
 * of the licenses in the directory LICENSES.
 */

END_OF_PREAMBLE

say <<END_OF_PREAMBLE;
/* Generated automatically by $PROGRAM_NAME
 * NOTE: Changes made to this file will be lost: look at $PROGRAM_NAME.
 */
END_OF_PREAMBLE

for (my $i = 0; $i <= $#ops; $i++) {
   my (undef, $macro) = @{$ops[$i]};
   say "#define $macro $i";
}
print "\n";

say q<static struct op_data_s op_by_name_object[] = {>;
for (my $i = 0; $i <= $#ops; $i++) {
   my ($name, $macro) = @{$ops[$i]};
   say qq<  { "$name", $macro },>;
}
say q<};>;
print "\n";

say q<static const char* op_name_by_id_object[] = {>;
for (my $i = 0; $i <= $#ops; $i++) {
   my ($name) = @{$ops[$i]};
   say qq<  "$name",>;
}
say q<};>;
print "\n";

# vim: expandtab shiftwidth=4:
