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

# Portability is NOT emphasized here -- this script is part
# of the development environment, not the configuration or
# installation environment

sub usage {
     die "usage: $PROGRAM_NAME [auto.xs]";
}

if (@ARGV > 1) {
   usage();
}

my $out;
if ( @ARGV == 1 ) {
    my $xsh_file_name = $ARGV[0];
    open $out, q{>}, $xsh_file_name;
} else {
   $out = *STDOUT;
}

my %format_by_type = (
   int => '%d',
   Marpa_Assertion_ID => '%d',
   Marpa_IRL_ID => '%d',
   Marpa_NSY_ID => '%d',
   Marpa_Or_Node_ID => '%d',
   Marpa_And_Node_ID => '%d',
   Marpa_Rank => '%d',
   Marpa_Rule_ID => '%d',
   Marpa_Symbol_ID => '%d',
   Marpa_Earley_Set_ID => '%d',
);

sub gp_generate {
    my ( $function, @arg_type_pairs ) = @_;
    my $output = q{};

    # For example, 'g_wrapper'
    my $wrapper_variable = $main::CLASS_LETTER . '_wrapper';

    # For example, 'G_Wrapper'
    my $wrapper_type = ( uc $main::CLASS_LETTER ) . '_Wrapper';

    # For example, 'g_wrapper'
    my $libmarpa_method =
          $function =~ m/^_marpa_/xms
        ? $function
        : 'marpa_' . $main::CLASS_LETTER . '_' . $function;

    # Just g_wrapper for the grammar, self->base otherwise
    my $base = $main::CLASS_LETTER eq 'g' ? 'g_wrapper' : "$wrapper_variable->base";

    $output .= "void\n";
    my @args = ();
    ARG: for ( my $i = 0; $i < $#arg_type_pairs; $i += 2 ) {
        push @args, $arg_type_pairs[ $i + 1 ];
    }
    $output
        .= "$function( " . ( join q{, }, $wrapper_variable, @args ) . " )\n";
    $output .= "    $wrapper_type *$wrapper_variable;\n";
    ARG: for ( my $i = 0; $i < $#arg_type_pairs; $i += 2 ) {
        $output .= q{    };
        $output .= join q{ }, @arg_type_pairs[ $i .. $i + 1 ];
        $output .= ";\n";
    }
    $output .= "PPCODE:\n";
    $output .= "{\n";
    $output
        .= "  $main::LIBMARPA_CLASS self = $wrapper_variable->$main::CLASS_LETTER;\n";
    $output .= "  int gp_result = (int)$libmarpa_method("
        . ( join q{, }, 'self', @args ) . ");\n";
    $output .= "  if ( gp_result == -1 ) { XSRETURN_UNDEF; }\n";
    $output .= "  if ( gp_result < 0 && $base->throw ) {\n";
    my @format    = ();
    my @variables = ();
    ARG: for ( my $i = 0; $i < $#arg_type_pairs; $i += 2 ) {
        my $arg_type = $arg_type_pairs[$i];
        my $variable = $arg_type_pairs[ $i + 1 ];
        if ( my $format = $format_by_type{$arg_type} ) {
            push @format,    $format;
            push @variables, $variable;
            next ARG;
        }
        die "Unknown arg_type $arg_type";
    } ## end for ( my $i = 0; $i < $#arg_type_pairs; $i += 2 )
    my $format_string =
          q{"Problem in }
        . $main::CLASS_LETTER . q{->}
        . $function . '('
        . ( join q{, }, @format )
        . q{): %s"};
    my @format_args = @variables;
    push @format_args, qq{xs_g_error( $base )};
    $output .= "    croak( $format_string,\n";
    $output .= q{     } . (join q{, }, @format_args) . ");\n";
    $output .= "  }\n";
    $output .= q{  XPUSHs (sv_2mortal (newSViv (gp_result)));} . "\n";
    $output .= "}\n";
    return $output;
} ## end sub gp_generate

print ${out} <<'END_OF_PREAMBLE';
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

END_OF_PREAMBLE

print ${out} <<END_OF_PREAMBLE;
 # DO NOT EDIT please, unless you are aware that this file is
 # generated automatically by $PROGRAM_NAME
 # NOTE: Changes made to this file will be lost: look at $PROGRAM_NAME.

END_OF_PREAMBLE

$main::CLASS_LETTER   = 'g';
$main::LIBMARPA_CLASS = 'Marpa_Grammar';
print {$out} 'MODULE = Marpa::R3        PACKAGE = Marpa::R3::Thin::G', "\n\n";

say {$out} gp_generate(qw(completion_symbol_activate Marpa_Symbol_ID sym_id int activate));
say {$out} gp_generate(qw(error_clear));
say {$out} gp_generate(qw(event_count));
say {$out} gp_generate(qw(force_valued));
say {$out} gp_generate(qw(has_cycle));
say {$out} gp_generate(qw(highest_rule_id));
say {$out} gp_generate(qw(highest_symbol_id));
say {$out} gp_generate(qw(is_precomputed));
say {$out} gp_generate(qw(nulled_symbol_activate Marpa_Symbol_ID sym_id int activate));
say {$out} gp_generate(qw(prediction_symbol_activate Marpa_Symbol_ID sym_id int activate));
say {$out} gp_generate(qw(rule_is_accessible Marpa_Rule_ID rule_id));
say {$out} gp_generate(qw(rule_is_loop Marpa_Rule_ID rule_id));
say {$out} gp_generate(qw(rule_is_nullable Marpa_Rule_ID rule_id));
say {$out} gp_generate(qw(rule_is_nulling Marpa_Rule_ID rule_id));
say {$out} gp_generate(qw(rule_is_productive Marpa_Rule_ID rule_id));
say {$out} gp_generate(qw(rule_is_proper_separation Marpa_Rule_ID rule_id));
say {$out} gp_generate(qw(rule_length Marpa_Rule_ID rule_id));
say {$out} gp_generate(qw(rule_lhs Marpa_Rule_ID rule_id));
say {$out} gp_generate(qw(rule_null_high Marpa_Rule_ID rule_id));
say {$out} gp_generate(qw(rule_null_high_set Marpa_Rule_ID rule_id int flag));
say {$out} gp_generate(qw(rule_rhs Marpa_Rule_ID rule_id int ix));
say {$out} gp_generate(qw(sequence_min Marpa_Rule_ID rule_id));
say {$out} gp_generate(qw(sequence_separator Marpa_Rule_ID rule_id));
say {$out} gp_generate(qw(start_symbol));
say {$out} gp_generate(qw(start_symbol_set Marpa_Symbol_ID id));
say {$out} gp_generate(qw(symbol_is_accessible Marpa_Symbol_ID symbol_id ));
say {$out} gp_generate(qw(symbol_is_completion_event Marpa_Symbol_ID sym_id));
say {$out} gp_generate(qw(symbol_is_completion_event_set Marpa_Symbol_ID sym_id int value));
say {$out} gp_generate(qw(symbol_is_counted Marpa_Symbol_ID symbol_id ));
say {$out} gp_generate(qw(symbol_is_nullable Marpa_Symbol_ID symbol_id ));
say {$out} gp_generate(qw(symbol_is_nulled_event Marpa_Symbol_ID sym_id));
say {$out} gp_generate(qw(symbol_is_nulled_event_set Marpa_Symbol_ID sym_id int value));
say {$out} gp_generate(qw(symbol_is_nulling Marpa_Symbol_ID symbol_id ));
say {$out} gp_generate(qw(symbol_is_prediction_event Marpa_Symbol_ID sym_id));
say {$out} gp_generate(qw(symbol_is_prediction_event_set Marpa_Symbol_ID sym_id int value));
say {$out} gp_generate(qw(symbol_is_productive Marpa_Symbol_ID symbol_id));
say {$out} gp_generate(qw(symbol_is_start Marpa_Symbol_ID symbol_id));
say {$out} gp_generate(qw(symbol_is_terminal Marpa_Symbol_ID symbol_id));
say {$out} gp_generate(qw(symbol_is_terminal_set Marpa_Symbol_ID symbol_id int boolean));
say {$out} gp_generate(qw(symbol_is_valued Marpa_Symbol_ID symbol_id));
say {$out} gp_generate(qw(symbol_is_valued_set Marpa_Symbol_ID symbol_id int boolean));
say {$out} gp_generate(qw(symbol_new));
say {$out} gp_generate(qw(zwa_new int default_value));
say {$out} gp_generate(qw(zwa_place Marpa_Assertion_ID zwaid Marpa_Rule_ID xrl_id int rhs_ix));

