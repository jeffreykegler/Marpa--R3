# Copyright 2016 Jeffrey Kegler
# This file is part of Marpa::R3.  Marpa::R3 is free software: you can
# redistribute it and/or modify it under the terms of the GNU Lesser
# General Public License as published by the Free Software Foundation,
# either version 3 of the License, or (at your option) any later version.
#
# Marpa::R3 is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser
# General Public License along with Marpa::R3.  If not, see
# http://www.gnu.org/licenses/.

package Marpa::R3::Scanless::G;

use 5.010001;
use strict;
use warnings;

use vars qw($VERSION $STRING_VERSION);
$VERSION        = '4.001_002';
$STRING_VERSION = $VERSION;
## no critic(BuiltinFunctions::ProhibitStringyEval)
$VERSION = eval $VERSION;
## use critic

package Marpa::R3::Internal::Scanless::G;

use Scalar::Util 'blessed';
use English qw( -no_match_vars );

# names of packages for strings
our $PACKAGE = 'Marpa::R3::Scanless::G';

sub Marpa::R3::Internal::Scanless::meta_grammar {

    my $meta_slg = bless [], 'Marpa::R3::Scanless::G';
    state $hashed_metag = Marpa::R3::Internal::MetaG::hashed_grammar();
    $meta_slg->[Marpa::R3::Internal::Scanless::G::TRACE_TERMINALS] = 0;
    $meta_slg->[Marpa::R3::Internal::Scanless::G::TRACE_FILE_HANDLE] = \*STDERR;
    Marpa::R3::Internal::Scanless::G::hash_to_runtime( $meta_slg,
        $hashed_metag,
        { bless_package => 'Marpa::R3::Internal::MetaAST_Nodes' } );

    my $thick_g1_grammar =
        $meta_slg->[Marpa::R3::Internal::Scanless::G::THICK_G1_GRAMMAR];
    my @mask_by_rule_id;
    $mask_by_rule_id[$_] = $thick_g1_grammar->_rule_mask($_)
        for $thick_g1_grammar->rule_ids();
    $meta_slg->[Marpa::R3::Internal::Scanless::G::MASK_BY_RULE_ID] =
        \@mask_by_rule_id;
    $meta_slg->[Marpa::R3::Internal::Scanless::G::TRACE_TERMINALS] = 0;

    return $meta_slg;

} ## end sub Marpa::R3::Internal::Scanless::meta_grammar

sub Marpa::R3::Scanless::G::new {
    my ( $class, @hash_ref_args ) = @_;

    my $slg = [];
    bless $slg, $class;

    $slg->[Marpa::R3::Internal::Scanless::G::TRACE_TERMINALS]   = 0;
    $slg->[Marpa::R3::Internal::Scanless::G::TRACE_FILE_HANDLE] = \*STDERR;
    $slg->[Marpa::R3::Internal::Scanless::G::WARNINGS]          = 1;
    $slg->[Marpa::R3::Internal::Scanless::G::IF_INACCESSIBLE]   = 'warn';

    my ( $flat_args, $error_message ) =
      Marpa::R3::flatten_hash_args( \@hash_ref_args );
    Marpa::R3::exception( sprintf $error_message, '$slg->new' )
      if not $flat_args;

    my ( $dsl, $g1_args ) =
      Marpa::R3::Internal::Scanless::G::set( $slg, $flat_args );
    my $ast        = Marpa::R3::Internal::MetaAST->new($dsl);
    my $hashed_ast = $ast->ast_to_hash();
    Marpa::R3::Internal::Scanless::G::hash_to_runtime( $slg, $hashed_ast,
        $g1_args );
    return $slg;
}

sub Marpa::R3::Scanless::G::set {
    my ( $slg, @hash_ref_args ) = @_;
    my ( $flat_args, $error_message ) =
      Marpa::R3::flatten_hash_args( \@hash_ref_args );
    Marpa::R3::exception( sprintf $error_message, '$slg->set' )
      if not $flat_args;

    my $value = $flat_args->{trace_terminals};
    if ( defined $value ) {
        if ( Scalar::Util::looks_like_number($value) ) {
            Marpa::R3::exception(
"trace_terminals named argument is $value; must have a value > 0"
            ) if $value < 0;
        }
        else {
            Marpa::R3::exception(
"trace_terminals named argument is $value; must have a numeric value"
            );
        }
        $slg->[Marpa::R3::Internal::Scanless::G::TRACE_TERMINALS] = $value;
        delete $flat_args->{trace_terminals};
    }

    $value = $flat_args->{trace_file_handle};
    if ( defined $value ) {
        $slg->[Marpa::R3::Internal::Scanless::G::TRACE_FILE_HANDLE] = $value;
        delete $flat_args->{trace_file_handle};
    }

    my @bad_arguments = keys %{$flat_args};
    if ( scalar @bad_arguments ) {
        Marpa::R3::exception(
            q{Bad named argument(s) to $slg->set() method} . join q{ },
            @bad_arguments );
    }
    return $slg;
}

sub Marpa::R3::Internal::Scanless::G::set {
    my ( $slg, $flat_args ) = @_;

    my $dsl = $flat_args->{'source'};
    Marpa::R3::exception(
        qq{Marpa::R3::Scanless::G::new() called without a 'source' argument})
      if not defined $dsl;
    my $dsl_ref_type = ref $dsl;
    if ( $dsl_ref_type ne 'SCALAR' ) {
        my $desc = $dsl_ref_type ? "a ref to $dsl_ref_type" : 'not a ref';
        Marpa::R3::exception(
qq{'source' name argument to Marpa::R3::Scanless::G->new() is $desc\n},
            "  It should be a ref to a string\n"
        );
    }
    if ( not defined ${$dsl} ) {
        Marpa::R3::exception(
qq{'source' name argument to Marpa::R3::Scanless::G->new() is a ref to a an undef\n},
            "  It should be a ref to a string\n"
        );
    } ## end if ( $ref_type ne 'SCALAR' )
    delete $flat_args->{'source'};

    my $value = $flat_args->{trace_file_handle};
    if ( defined $value ) {
        $slg->[Marpa::R3::Internal::Scanless::G::TRACE_FILE_HANDLE] = $value;
        delete $flat_args->{'trace_file_handle'};
    }

    $value = $flat_args->{trace_terminals};
    if ( defined $value ) {
        $slg->[Marpa::R3::Internal::Scanless::G::TRACE_TERMINALS] = $value;
        delete $flat_args->{'trace_terminals'};
    }

    return ( $dsl, $flat_args );

} ## end sub Marpa::R3::Internal::Scanless::G::set

sub Marpa::R3::Internal::Scanless::G::hash_to_runtime {
    my ( $slg, $hashed_source, $g1_args ) = @_;

    my $trace_fh =
        $slg->[Marpa::R3::Internal::Scanless::G::TRACE_FILE_HANDLE];
    my $trace_terminals =
        $slg->[Marpa::R3::Internal::Scanless::G::TRACE_TERMINALS];

    # Pre-lexer G1 processing

    my @xsy_names = keys %{$hashed_source->{xsy}};

    my $xsy_by_id = $slg->[Marpa::R3::Internal::Scanless::G::XSY_BY_ID] = [];
    my $xsy_by_name = $slg->[Marpa::R3::Internal::Scanless::G::XSY_BY_NAME] = {};
    for my $xsy_name ( sort @xsy_names ) {
        my $runtime_xsy_data = [];
        $runtime_xsy_data->[Marpa::R3::Internal::XSY::ID] = scalar @{$xsy_by_id};
        $runtime_xsy_data->[Marpa::R3::Internal::XSY::NAME] = $xsy_name;
        my $source_xsy_data = $hashed_source->{xsy}->{$xsy_name};
      KEY: for my $datum_key ( keys %{$source_xsy_data} ) {
            if ( $datum_key eq 'action' ) {
                $runtime_xsy_data->[Marpa::R3::Internal::XSY::LEXEME_SEMANTICS] =
                  $source_xsy_data->{$datum_key};
                next KEY;
            }
            if ( $datum_key eq 'blessing' ) {
                $runtime_xsy_data->[Marpa::R3::Internal::XSY::BLESSING] =
                  $source_xsy_data->{$datum_key};
                next KEY;
            }
            if ( $datum_key eq 'dsl_form' ) {
                $runtime_xsy_data->[Marpa::R3::Internal::XSY::DSL_FORM] =
                  $source_xsy_data->{$datum_key};
                next KEY;
            }
            if ( $datum_key eq 'if_inaccessible' ) {
                $runtime_xsy_data->[Marpa::R3::Internal::XSY::IF_INACCESSIBLE] =
                  $source_xsy_data->{$datum_key};
                next KEY;
            }
            if ( $datum_key eq 'name_source' ) {
                $runtime_xsy_data->[Marpa::R3::Internal::XSY::NAME_SOURCE] =
                  $source_xsy_data->{$datum_key};
                next KEY;
            }
            Marpa::R3::exception(
                "Internal error: Unknown hashed source xsy field: $datum_key");
        }
        push @{$xsy_by_id}, $runtime_xsy_data;
        $xsy_by_name->{$xsy_name} = $runtime_xsy_data;
    }

    $slg->[Marpa::R3::Internal::Scanless::G::CACHE_G1_IRLIDS_BY_LHS_NAME] = {};

    my $if_inaccessible_default_arg =
      $hashed_source->{defaults}->{if_inaccessible};
    if ( defined $if_inaccessible_default_arg ) {
        $slg->[Marpa::R3::Internal::Scanless::G::IF_INACCESSIBLE] =
          $if_inaccessible_default_arg;
    }
    my $if_inaccessible_default =
      $slg->[Marpa::R3::Internal::Scanless::G::IF_INACCESSIBLE];

    # Prepare the arguments for the G1 grammar
    $g1_args->{rules}   = $hashed_source->{rules}->{G1};
    $g1_args->{symbols} = $hashed_source->{symbols}->{G1};
    state $g1_target_symbol = '[:start]';
    $g1_args->{start} = $g1_target_symbol;

    if ( defined( my $value = $g1_args->{'bless_package'} ) ) {
        $slg->[Marpa::R3::Internal::Scanless::G::BLESS_PACKAGE] = $value;
        delete $g1_args->{'bless_package'};
    }

    if ( defined( my $value = $g1_args->{'warnings'} ) ) {
        $slg->[Marpa::R3::Internal::Scanless::G::WARNINGS] = $value;
        delete $g1_args->{'warnings'};
    }

    my $thick_g1_grammar = Marpa::R3::Grammar->g1_naif_new($slg, $g1_args);
    my $g1_tracer = $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];
    my $g1_thin          = $g1_tracer->grammar();

    my $symbol_ids_by_event_name_and_type = {};
    $slg->[
        Marpa::R3::Internal::Scanless::G::SYMBOL_IDS_BY_EVENT_NAME_AND_TYPE]
        = $symbol_ids_by_event_name_and_type;

    my $completion_events_by_name = $hashed_source->{completion_events};
    my $completion_events_by_id =
        $slg->[Marpa::R3::Internal::Scanless::G::COMPLETION_EVENT_BY_ID] = [];
    for my $symbol_name ( keys %{$completion_events_by_name} ) {
        my ( $event_name, $is_active ) =
            @{ $completion_events_by_name->{$symbol_name} };
        my $symbol_id = $g1_tracer->symbol_by_name($symbol_name);
        if ( not defined $symbol_id ) {
            Marpa::R3::exception(
                "Completion event defined for non-existent symbol: $symbol_name\n"
            );
        }

        # Must be done before precomputation
        $g1_thin->symbol_is_completion_event_set( $symbol_id, 1 );
        $g1_thin->completion_symbol_activate( $symbol_id, 0 )
            if not $is_active;
        $slg->[Marpa::R3::Internal::Scanless::G::COMPLETION_EVENT_BY_ID]
            ->[$symbol_id] = $event_name;
        push
            @{ $symbol_ids_by_event_name_and_type->{$event_name}->{completion}
            }, $symbol_id;
    } ## end for my $symbol_name ( keys %{$completion_events_by_name...})

    my $nulled_events_by_name = $hashed_source->{nulled_events};
    my $nulled_events_by_id =
        $slg->[Marpa::R3::Internal::Scanless::G::NULLED_EVENT_BY_ID] = [];
    for my $symbol_name ( keys %{$nulled_events_by_name} ) {
        my ( $event_name, $is_active ) =
            @{ $nulled_events_by_name->{$symbol_name} };
        my $symbol_id = $g1_tracer->symbol_by_name($symbol_name);
        if ( not defined $symbol_id ) {
            Marpa::R3::exception(
                "nulled event defined for non-existent symbol: $symbol_name\n"
            );
        }

        # Must be done before precomputation
        $g1_thin->symbol_is_nulled_event_set( $symbol_id, 1 );
        $g1_thin->nulled_symbol_activate( $symbol_id, 0 ) if not $is_active;
        $slg->[Marpa::R3::Internal::Scanless::G::NULLED_EVENT_BY_ID]
            ->[$symbol_id] = $event_name;
        push @{ $symbol_ids_by_event_name_and_type->{$event_name}->{nulled} },
            $symbol_id;
    } ## end for my $symbol_name ( keys %{$nulled_events_by_name} )

    my $prediction_events_by_name = $hashed_source->{prediction_events};
    my $prediction_events_by_id =
        $slg->[Marpa::R3::Internal::Scanless::G::PREDICTION_EVENT_BY_ID] = [];
    for my $symbol_name ( keys %{$prediction_events_by_name} ) {
        my ( $event_name, $is_active ) =
            @{ $prediction_events_by_name->{$symbol_name} };
        my $symbol_id = $g1_tracer->symbol_by_name($symbol_name);
        if ( not defined $symbol_id ) {
            Marpa::R3::exception(
                "prediction event defined for non-existent symbol: $symbol_name\n"
            );
        }

        # Must be done before precomputation
        $g1_thin->symbol_is_prediction_event_set( $symbol_id, 1 );
        $g1_thin->prediction_symbol_activate( $symbol_id, 0 )
            if not $is_active;
        $slg->[Marpa::R3::Internal::Scanless::G::PREDICTION_EVENT_BY_ID]
            ->[$symbol_id] = $event_name;
        push
            @{ $symbol_ids_by_event_name_and_type->{$event_name}->{prediction}
            }, $symbol_id;
    } ## end for my $symbol_name ( keys %{$prediction_events_by_name...})

    my $lexeme_events_by_id =
        $slg->[Marpa::R3::Internal::Scanless::G::LEXEME_EVENT_BY_ID] = [];

    my $precompute_error = Marpa::R3::Internal::Scanless::G::precompute($slg, $thick_g1_grammar);
    if (defined $precompute_error) {
        if ( $precompute_error == $Marpa::R3::Error::UNPRODUCTIVE_START ) {

            # Maybe someday improve this by finding the start rule and showing
            # its RHS -- for now it is clear enough
            Marpa::R3::exception(qq{Unproductive start symbol});
        } ## end if ( $precompute_error == ...)
        Marpa::R3::exception(
            'Internal errror: unnkown precompute error code ',
            $precompute_error );
    } ## end if ( defined( my $precompute_error = ...))

    # Find out the list of lexemes according to G1
    my %g1_id_by_lexeme_name = ();
    SYMBOL: for my $symbol_id ( 0 .. $g1_thin->highest_symbol_id() ) {

        # Not a lexeme, according to G1
        next SYMBOL if not $g1_thin->symbol_is_terminal($symbol_id);

        my $symbol_name = $g1_tracer->symbol_name($symbol_id);
        $g1_id_by_lexeme_name{$symbol_name} = $symbol_id;

    } ## end SYMBOL: for my $symbol_id ( 0 .. $g1_thin->highest_symbol_id(...))

    # A first phase of applying defaults
    my $discard_default_adverbs = $hashed_source->{discard_default_adverbs};
    my $lexeme_declarations     = $hashed_source->{lexeme_declarations};
    my $lexeme_default_adverbs  = $hashed_source->{lexeme_default_adverbs};
    my $latm_default_value      = $lexeme_default_adverbs->{latm} // 1;

    # Current lexeme data is spread out in many places.
    # Change so that it all resides in this hash, indexed by
    # name
    my %lexeme_data = ();

    # Determine "latm" status
    LEXEME: for my $lexeme_name ( keys %g1_id_by_lexeme_name ) {
        my $declarations = $lexeme_declarations->{$lexeme_name};
        my $latm_value = $declarations->{latm} // $latm_default_value;
        $lexeme_data{$lexeme_name}{latm} = $latm_value;
    }

    # Lexers

    my @discard_event_by_lexer_rule_id      = ();
    state $lex_start_symbol_name = '[:start_lex]';
    state $discard_symbol_name   = '[:discard]';

    my $lexer_rules = $hashed_source->{rules}->{'L0'};
    my $character_class_hash = $hashed_source->{character_classes};
    my $lexer_symbols = $hashed_source->{symbols}->{'L0'};

    # If no lexer rules, fake a lexer
    # Fake a lexer -- it discards symbols in character classes which
    # never matches
    if ( not $lexer_rules ) {
        $character_class_hash = { '[[^\\d\\D]]' => [ '[^\\d\\D]', '' ] };
        $lexer_rules = [
            {   'rhs'         => [ '[[^\\d\\D]]' ],
                'lhs'         => '[:discard]',
                'symbol_as_event' => '[^\\d\\D]',
                # 'description' => 'Discard rule for <[[^\\d\\D]]>'
            },
        ];
        $lexer_symbols = {
            '[:discard]' => {
                # 'description'  => 'Internal LHS for lexer "L0" discard'
            },
            '[[^\\d\\D]]' => {
                # 'description'  => 'Character class: [^\\d\\D]'
            }
        };
    } ## end if ( not $lexer_rules )

    my %lex_lhs           = ();
    my %lex_rhs           = ();
    my %lex_separator     = ();
    my %lexer_rule_by_tag = ();

    my $rule_tag = 'rule0';
    for my $lex_rule ( @{$lexer_rules} ) {
        $lex_rule->{tag} = ++$rule_tag;
        my %lex_rule_copy = %{$lex_rule};
        $lexer_rule_by_tag{$rule_tag} = \%lex_rule_copy;
        delete $lex_rule->{event};
        delete $lex_rule->{symbol_as_event};
        $lex_lhs{ $lex_rule->{lhs} } = 1;
        $lex_rhs{$_} = 1 for @{ $lex_rule->{rhs} };
        if ( defined( my $separator = $lex_rule->{separator} ) ) {
            $lex_separator{$separator} = 1;
        }
    } ## end for my $lex_rule ( @{$lexer_rules} )

    my %this_lexer_symbols = ();
    SYMBOL:
    for my $symbol_name ( ( keys %lex_lhs ), ( keys %lex_rhs ),
        ( keys %lex_separator ) )
    {
        my $symbol_data = $lexer_symbols->{$symbol_name};
        $this_lexer_symbols{$symbol_name} = $symbol_data
            if defined $symbol_data;
    } ## end SYMBOL: for my $symbol_name ( ( keys %lex_lhs ), ( keys %lex_rhs...))

    my %is_lexeme_in_this_lexer = map { $_ => 1 }
        grep { not $lex_rhs{$_} and not $lex_separator{$_} }
        keys %lex_lhs;

    my @lex_lexeme_names = keys %is_lexeme_in_this_lexer;

    Marpa::R3::exception( "No lexemes in lexer\n",
        "  An SLIF grammar must have at least one lexeme\n" )
        if not scalar @lex_lexeme_names;

    # Do I need this?
    my @unproductive =
        map {"<$_>"}
        grep { not $lex_lhs{$_} and not $_ =~ /\A \[\[ /xms }
        ( keys %lex_rhs, keys %lex_separator );
    if (@unproductive) {
        Marpa::R3::exception( 'Unproductive lexical symbols: ',
            join q{ }, @unproductive );
    }

    # $this_lexer_symbols{$lex_start_symbol_name}->{description} =
    # 'Internal L0 (lexical) start symbol';
    push @{$lexer_rules}, map {
        ;
        {
            #   description => "Internal lexical start rule for <$_>",
            lhs => $lex_start_symbol_name,
            rhs => [$_]
        }
    } sort keys %is_lexeme_in_this_lexer;

    # Create the thick lex grammar
    my $lex_thick_grammar =
      Marpa::R3::Grammar->l0_naif_new( $slg, $lex_start_symbol_name,
        \%this_lexer_symbols, $lexer_rules );
    my $lex_tracer = $slg->[Marpa::R3::Internal::Scanless::G::L0_TRACER];
    my $lex_thin   = $lex_tracer->grammar();

    my $lex_discard_symbol_id =
        $lex_tracer->symbol_by_name($discard_symbol_name) // -1;
    my @lex_lexeme_to_g1_symbol;
    $lex_lexeme_to_g1_symbol[$_] = -1 for 0 .. $g1_thin->highest_symbol_id();

    LEXEME_NAME: for my $lexeme_name (@lex_lexeme_names) {
        next LEXEME_NAME if $lexeme_name eq $discard_symbol_name;
        next LEXEME_NAME if $lexeme_name eq $lex_start_symbol_name;
        my $g1_symbol_id = $g1_id_by_lexeme_name{$lexeme_name};
        if ( not defined $g1_symbol_id ) {
            Marpa::R3::exception(
                "A lexeme in L0 is not a lexeme in G1: $lexeme_name"
            );
        }
        if ( not $g1_thin->symbol_is_accessible($g1_symbol_id) ) {
            my $message =
                "A lexeme in L0 is not accessible from the G1 start symbol: $lexeme_name";
            say {$trace_fh} $message
                if $if_inaccessible_default eq 'warn';
            Marpa::R3::exception($message)
                if $if_inaccessible_default eq 'fatal';
        } ## end if ( not $g1_thin->symbol_is_accessible($g1_symbol_id...))
        my $lex_symbol_id = $lex_tracer->symbol_by_name($lexeme_name);
        $lexeme_data{$lexeme_name}{lexer}{'id'} =
            $lex_symbol_id;
        $lex_lexeme_to_g1_symbol[$lex_symbol_id] = $g1_symbol_id;
    } ## end LEXEME_NAME: for my $lexeme_name (@lex_lexeme_names)

    my @lex_rule_to_g1_lexeme;
    my $lex_start_symbol_id =
        $lex_tracer->symbol_by_name($lex_start_symbol_name);
    RULE_ID: for my $rule_id ( 0 .. $lex_thin->highest_rule_id() ) {
        my $lhs_id = $lex_thin->rule_lhs($rule_id);
        if ( $lhs_id == $lex_discard_symbol_id ) {
            $lex_rule_to_g1_lexeme[$rule_id] = -2;
            next RULE_ID;
        }
        if ( $lhs_id != $lex_start_symbol_id ) {
            $lex_rule_to_g1_lexeme[$rule_id] = -1;
            next RULE_ID;
        }
        my $lexer_lexeme_id = $lex_thin->rule_rhs( $rule_id, 0 );
        if ( $lexer_lexeme_id == $lex_discard_symbol_id ) {
            $lex_rule_to_g1_lexeme[$rule_id] = -1;
            next RULE_ID;
        }
        my $lexeme_id = $lex_lexeme_to_g1_symbol[$lexer_lexeme_id] // -1;
        $lex_rule_to_g1_lexeme[$rule_id] = $lexeme_id;
        next RULE_ID if $lexeme_id < 0;
        my $lexeme_name = $g1_tracer->symbol_name($lexeme_id);

        # If 1 is the default, we don't need an assertion
        next RULE_ID if not $lexeme_data{$lexeme_name}{latm};

        my $trace_terminals = $slg->[Marpa::R3::Internal::Scanless::G::TRACE_TERMINALS];
        my $assertion_id =
            $lexeme_data{$lexeme_name}{lexer}{'assertion'};
        if ( not defined $assertion_id ) {
            $assertion_id = $lex_thin->zwa_new(0);

            if ( $trace_terminals >= 2 ) {
                say {$trace_fh} "Assertion $assertion_id defaults to 0";
            }

            $lexeme_data{$lexeme_name}{lexer}{'assertion'} =
                $assertion_id;
        } ## end if ( not defined $assertion_id )
        $lex_thin->zwa_place( $assertion_id, $rule_id, 0 );
        if ( $trace_terminals >= 2 ) {
            say {$trace_fh}
                "Assertion $assertion_id applied to L0 rule ",
                slg_rule_show( $slg, $rule_id, $lex_thick_grammar );
        }
    } ## end RULE_ID: for my $rule_id ( 0 .. $lex_thin->highest_rule_id() )

    my $lex_precompute_error =
      Marpa::R3::Internal::Scanless::G::precompute( $slg, $lex_thick_grammar );
    if ( defined $lex_precompute_error ) {
        Marpa::R3::exception(
'Internal errror: expected error code from precompute of lexer grammar ',
            $precompute_error
        );
    }

    my @class_table          = ();

    CLASS_SYMBOL:
    for my $class_symbol ( sort keys %{$character_class_hash} ) {
        my $symbol_id = $lex_tracer->symbol_by_name($class_symbol);
        next CLASS_SYMBOL if not defined $symbol_id;
        my $cc_components = $character_class_hash->{$class_symbol};
        my ( $compiled_re, $error ) =
            Marpa::R3::Internal::MetaAST::char_class_to_re($cc_components);
        if ( not $compiled_re ) {
            $error =~ s/^/  /gxms;    #indent all lines
            Marpa::R3::exception(
                "Failed belatedly to evaluate character class\n", $error );
        }
        push @class_table, [ $symbol_id, $compiled_re ];
    } ## end CLASS_SYMBOL: for my $class_symbol ( sort keys %{...})
    my $character_class_table = \@class_table;

    # Apply defaults to determine the discard event for every
    # rule id of the lexer.

    my $default_discard_event = $discard_default_adverbs->{event};
    RULE_ID: for my $rule_id ( 0 .. $lex_thin->highest_rule_id() ) {
        my $tag = $lex_thick_grammar->tag($rule_id);
        next RULE_ID if not defined $tag;
        my $event;
        FIND_EVENT: {
            $event = $lexer_rule_by_tag{$tag}->{event};
            last FIND_EVENT if defined $event;
            my $lhs_id = $lex_thin->rule_lhs($rule_id);
            last FIND_EVENT if $lhs_id != $lex_discard_symbol_id;
            $event = $default_discard_event;
        } ## end FIND_EVENT:
        next RULE_ID if not defined $event;

        my ( $event_name, $event_starts_active ) = @{$event};
        if ( $event_name eq q{'symbol} ) {
            my @event = (
                $lexer_rule_by_tag{$tag}->{symbol_as_event},
                $event_starts_active
            );
            $discard_event_by_lexer_rule_id[$rule_id] = \@event;
            next RULE_ID;
        } ## end if ( $event_name eq q{'symbol} )
        if ( ( substr $event_name, 0, 1 ) ne q{'} ) {
            $discard_event_by_lexer_rule_id[$rule_id] = $event;
            next RULE_ID;
        }
        Marpa::R3::exception(
            qq{Discard event has unknown name: "$event_name"}
        );

    } ## end RULE_ID: for my $rule_id ( 0 .. $lex_thin->highest_rule_id() )

    # Post-lexer G1 processing

    my $thin_L0  = $lex_tracer->[Marpa::R3::Internal::Trace::G::C];
    my $thin_slg = $slg->[Marpa::R3::Internal::Scanless::G::C] =
        Marpa::R3::Thin::SLG->new( $thin_L0, $g1_tracer->grammar() );

    LEXEME: for my $lexeme_name ( keys %g1_id_by_lexeme_name ) {
        Marpa::R3::exception(
            "A lexeme in G1 is not a lexeme in L0: $lexeme_name"
        ) if not defined $lexeme_data{$lexeme_name}{'lexer'};
    }

    # At this point we know which symbols are lexemes.
    # So now let's check for inconsistencies

    # Check for lexeme declarations for things which are not lexemes
    for my $lexeme_name ( keys %{$lexeme_declarations} ) {
        Marpa::R3::exception(
            "Symbol <$lexeme_name> is declared as a lexeme, but it is not used as one.\n"
        ) if not defined $g1_id_by_lexeme_name{$lexeme_name};
    }

    # Now that we know the lexemes, check attempts to defined a
    # completion or a nulled event for one
    for my $symbol_name ( keys %{$completion_events_by_name} ) {
        Marpa::R3::exception(
            "A completion event is declared for <$symbol_name>, but it is a lexeme.\n",
            "  Completion events are only valid for symbols on the LHS of G1 rules.\n"
        ) if defined $g1_id_by_lexeme_name{$symbol_name};
    } ## end for my $symbol_name ( keys %{$completion_events_by_name...})

    for my $symbol_name ( keys %{$nulled_events_by_name} ) {
        Marpa::R3::exception(
            "A nulled event is declared for <$symbol_name>, but it is a G1 lexeme.\n",
            "  nulled events are only valid for symbols on the LHS of G1 rules.\n"
        ) if defined $g1_id_by_lexeme_name{$symbol_name};
    } ## end for my $symbol_name ( keys %{$nulled_events_by_name} )

    # Mark the lexemes, and set their data
    # Now that we have created the SLG, we can set the latm value,
    # already determined above.
    LEXEME: for my $lexeme_name ( keys %g1_id_by_lexeme_name ) {
        my $g1_lexeme_id = $g1_id_by_lexeme_name{$lexeme_name};
        my $declarations = $lexeme_declarations->{$lexeme_name};
        my $priority     = $declarations->{priority} // 0;
        $thin_slg->g1_lexeme_set( $g1_lexeme_id, $priority );
        my $latm_value = $lexeme_data{$lexeme_name}{latm} // 0;
        $thin_slg->g1_lexeme_latm_set( $g1_lexeme_id, $latm_value );
        my $pause_value = $declarations->{pause};
        if ( defined $pause_value ) {
            $thin_slg->g1_lexeme_pause_set( $g1_lexeme_id, $pause_value );
            my $is_active = 1;

            if ( defined( my $event_data = $declarations->{'event'} ) ) {
                my $event_name;
                ( $event_name, $is_active ) = @{$event_data};
                $lexeme_events_by_id->[$g1_lexeme_id] = $event_name;
                push @{ $symbol_ids_by_event_name_and_type->{$event_name}
                        ->{lexeme} }, $g1_lexeme_id;
            } ## end if ( defined( my $event_data = $declarations->{'event'...}))

            $thin_slg->g1_lexeme_pause_activate( $g1_lexeme_id, $is_active );
        } ## end if ( defined $pause_value )

    } ## end LEXEME: for my $lexeme_name ( keys %g1_id_by_lexeme_name )

    # Second phase of lexer processing
    RULE_ID: for my $lexer_rule_id ( 0 .. $#lex_rule_to_g1_lexeme ) {
        my $g1_lexeme_id = $lex_rule_to_g1_lexeme[$lexer_rule_id];
        my $lexeme_name  = $g1_tracer->symbol_name($g1_lexeme_id);
        my $assertion_id =
            $lexeme_data{$lexeme_name}{lexer}{'assertion'}
            // -1;
        $thin_slg->lexer_rule_to_g1_lexeme_set( $lexer_rule_id,
            $g1_lexeme_id, $assertion_id );
        my $discard_event = $discard_event_by_lexer_rule_id[$lexer_rule_id];
        if ( defined $discard_event ) {
            my ( $event_name, $is_active ) = @{$discard_event};
            $slg->[
                Marpa::R3::Internal::Scanless::G::DISCARD_EVENT_BY_LEXER_RULE
            ]->[$lexer_rule_id] = $event_name;
            push @{ $symbol_ids_by_event_name_and_type->{$event_name}
                    ->{discard} }, $lexer_rule_id;
            $thin_slg->discard_event_set( $lexer_rule_id, 1 );
            $thin_slg->discard_event_activate( $lexer_rule_id, 1 )
                if $is_active;
        } ## end if ( defined $discard_event )
    }

    # Second phase of G1 processing

    $thin_slg->precompute();
    $slg->[Marpa::R3::Internal::Scanless::G::THICK_G1_GRAMMAR] =
        $thick_g1_grammar;

    # More lexer processing
    # Determine events by lexer rule, applying the defaults

    $slg->[Marpa::R3::Internal::Scanless::G::CHARACTER_CLASS_TABLE]
        = $character_class_table;
    $slg->[Marpa::R3::Internal::Scanless::G::THICK_L0_GRAMMAR]
        = $lex_thick_grammar;

    # This section violates the NAIF interface, directly changing some
    # of its internal structures.
    #
    # Some lexeme default adverbs are applied in earlier phases.
    #
    APPLY_DEFAULT_LEXEME_ADVERBS: {
        last APPLY_DEFAULT_LEXEME_ADVERBS if not $lexeme_default_adverbs;

        my $default_lexeme_action = $lexeme_default_adverbs->{action};
        my $xsy_by_isyid =
            $g1_tracer->[Marpa::R3::Internal::Trace::G::XSY_BY_ISYID];

        LEXEME:
        for my $lexeme_name ( keys %g1_id_by_lexeme_name ) {
            my $g1_lexeme_id = $g1_id_by_lexeme_name{$lexeme_name};
            my $xsy = $xsy_by_isyid->[$g1_lexeme_id];
            next LEXEME if not defined $xsy;
            next LEXEME if 
                $xsy->[Marpa::R3::Internal::XSY::NAME_SOURCE] ne 'lexical';
            $xsy->[Marpa::R3::Internal::XSY::LEXEME_SEMANTICS] //=
                $default_lexeme_action;
        } ## end LEXEME: for my $lexeme_name ( keys %g1_id_by_lexeme_name )

        my $blessing = $lexeme_default_adverbs->{bless};
        last APPLY_DEFAULT_LEXEME_ADVERBS if not $blessing;
        last APPLY_DEFAULT_LEXEME_ADVERBS if $blessing eq '::undef';

        LEXEME:
        for my $lexeme_name ( keys %g1_id_by_lexeme_name ) {
            my $g1_lexeme_id = $g1_id_by_lexeme_name{$lexeme_name};
            my $xsy = $xsy_by_isyid->[$g1_lexeme_id];
            next LEXEME if not defined $xsy;
            next LEXEME if 
                $xsy->[Marpa::R3::Internal::XSY::NAME_SOURCE] ne 'lexical';

            if ( $blessing eq '::name' ) {
                if ( $lexeme_name =~ / [^ [:alnum:]] /xms ) {
                    Marpa::R3::exception(
                        qq{Lexeme blessing by '::name' only allowed if lexeme name is whitespace and alphanumerics\n},
                        qq{   Problematic lexeme was <$lexeme_name>\n}
                    );
                } ## end if ( $lexeme_name =~ / [^ [:alnum:]] /xms )
                my $blessing_by_name = $lexeme_name;
                $blessing_by_name =~ s/[ ]/_/gxms;
                $xsy->[Marpa::R3::Internal::XSY::BLESSING] =
                    $blessing_by_name;
                next LEXEME;
            } ## end if ( $blessing eq '::name' )
            if ( $blessing =~ / [\W] /xms ) {
                Marpa::R3::exception(
                    qq{Blessing lexeme as '$blessing' is not allowed\n},
                    qq{   Problematic lexeme was <$lexeme_name>\n}
                );
            } ## end if ( $blessing =~ / [\W] /xms )
            $xsy->[Marpa::R3::Internal::XSY::BLESSING] = $blessing;
        } ## end LEXEME: for my $lexeme_name ( keys %g1_id_by_lexeme_name )

    } ## end APPLY_DEFAULT_LEXEME_ADVERBS:

    return $slg;

} ## end sub Marpa::R3::Internal::Scanless::G::hash_to_runtime

sub Marpa::R3::Internal::Scanless::G::precompute {
    my ($slg, $grammar) = @_;

    my $tracer     = $grammar->[Marpa::R3::Internal::Grammar::TRACER];
    my $rules = $tracer->[Marpa::R3::Internal::Trace::G::RULES];
    my $grammar_c = $tracer->[Marpa::R3::Internal::Trace::G::C];
    my $xsy_by_isyid     = $tracer->[Marpa::R3::Internal::Trace::G::XSY_BY_ISYID];

    my $trace_fh =
        $slg->[Marpa::R3::Internal::Scanless::G::TRACE_FILE_HANDLE];

    return if $grammar_c->is_precomputed();
    if ($grammar_c->force_valued() < 0) {
        Marpa::R3::uncaught_error( scalar $grammar_c->error() );
    }

    set_start_symbol($grammar);

    # Catch errors in precomputation
    my $precompute_error_code = $Marpa::R3::Error::NONE;
    $grammar_c->throw_set(0);
    my $precompute_result = $grammar_c->precompute();
    $grammar_c->throw_set(1);

    if ( $precompute_result < 0 ) {
        ($precompute_error_code) = $grammar_c->error();
        if ( not defined $precompute_error_code ) {
            Marpa::R3::exception(
                'libmarpa error, but no error code returned');
        }

        # If already precomputed, let higher level know
        return $precompute_error_code
            if $precompute_error_code == $Marpa::R3::Error::PRECOMPUTED;

        # We'll collect the 'MARPA_EVENT_LOOP_RULES' events later,
        # and use them to give a detailed error message
        $precompute_error_code = $Marpa::R3::Error::NONE
            if $precompute_error_code == $Marpa::R3::Error::GRAMMAR_HAS_CYCLE;

    } ## end if ( $precompute_result < 0 )

    if ( $precompute_error_code != $Marpa::R3::Error::NONE ) {

        # Report the errors, then return failure

        if ( $precompute_error_code == $Marpa::R3::Error::NO_RULES ) {
            Marpa::R3::exception(
                'Attempted to precompute grammar with no rules');
        }
        if ( $precompute_error_code == $Marpa::R3::Error::NULLING_TERMINAL ) {
            my @nulling_terminals = ();
            my $event_count       = $grammar_c->event_count();
            EVENT:
            for ( my $event_ix = 0; $event_ix < $event_count; $event_ix++ ) {
                my ( $event_type, $value ) = $grammar_c->event($event_ix);
                if ( $event_type eq 'MARPA_EVENT_NULLING_TERMINAL' ) {
                    push @nulling_terminals, $grammar->symbol_name($value);
                }
            } ## end EVENT: for ( my $event_ix = 0; $event_ix < $event_count; ...)
            my @nulling_terminal_messages =
                map {qq{Nulling symbol "$_" is also a terminal\n}}
                @nulling_terminals;
            Marpa::R3::exception( @nulling_terminal_messages,
                'A terminal symbol cannot also be a nulling symbol' );
        } ## end if ( $precompute_error_code == ...)
        if ( $precompute_error_code == $Marpa::R3::Error::COUNTED_NULLABLE ) {
            my @counted_nullables = ();
            my $event_count       = $grammar_c->event_count();
            EVENT:
            for ( my $event_ix = 0; $event_ix < $event_count; $event_ix++ ) {
                my ( $event_type, $value ) = $grammar_c->event($event_ix);
                if ( $event_type eq 'MARPA_EVENT_COUNTED_NULLABLE' ) {
                    push @counted_nullables, $grammar->symbol_name($value);
                }
            } ## end EVENT: for ( my $event_ix = 0; $event_ix < $event_count; ...)
            my @counted_nullable_messages = map {
                      q{Nullable symbol "}
                    . $_
                    . qq{" is on rhs of counted rule\n}
            } @counted_nullables;
            Marpa::R3::exception( @counted_nullable_messages,
                'Counted nullables confuse Marpa -- please rewrite the grammar'
            );
        } ## end if ( $precompute_error_code == ...)

        if ( $precompute_error_code == $Marpa::R3::Error::NO_START_SYMBOL ) {
            Marpa::R3::exception('No start symbol');
        }
        if ( $precompute_error_code == $Marpa::R3::Error::START_NOT_LHS ) {
            my $name = $tracer->[Marpa::R3::Internal::Trace::G::START_NAME];
            Marpa::R3::exception(
                qq{Start symbol "$name" not on LHS of any rule});
        }

        return $precompute_error_code
            if $precompute_error_code
            == $Marpa::R3::Error::UNPRODUCTIVE_START;

        Marpa::R3::uncaught_error( scalar $grammar_c->error() );

    } ## end if ( $precompute_error_code != $Marpa::R3::Error::NONE)

    # Shadow all the new rules
    {
        my $highest_rule_id = $grammar_c->highest_rule_id();
        RULE:
        for ( my $rule_id = 0; $rule_id <= $highest_rule_id; $rule_id++ ) {
            next RULE if defined $rules->[$rule_id];

            # The Marpa::R3 logic assumes no "gaps" in the rule numbering,
            # which is currently the case for Libmarpa,
            # but not guaranteed.
            shadow_rule( $grammar, $rule_id );
        } ## end RULE: for ( my $rule_id = 0; $rule_id <= $highest_rule_id; ...)
    }

    # Above I went through the error events
    # Here I go through the events for situations where there was no
    # hard error returned from libmarpa
    my $loop_rule_count = 0;
    {
        my $event_count = $grammar_c->event_count();
        EVENT:
        for ( my $event_ix = 0; $event_ix < $event_count; $event_ix++ ) {
            my ( $event_type, $value ) = $grammar_c->event($event_ix);
            if ( $event_type ne 'MARPA_EVENT_LOOP_RULES' ) {
                Marpa::R3::exception(
                    qq{Unknown grammar precomputation event; type="$event_type"}
                );
            }
            $loop_rule_count = $value;
        } ## end EVENT: for ( my $event_ix = 0; $event_ix < $event_count; ...)
    }

    if ( $loop_rule_count ) {
        my @loop_rules =
            grep { $grammar_c->rule_is_loop($_) } ( 0 .. $#{$rules} );
        for my $rule_id (@loop_rules) {
            print {$trace_fh}
                'Cycle found involving rule: ',
                $grammar->brief_rule($rule_id), "\n"
                or Marpa::R3::exception("Could not print: $ERRNO");
        } ## end for my $rule_id (@loop_rules)
        Marpa::R3::exception('Cycles in grammar, fatal error');
    }

    my $default_if_inaccessible =
        $slg->[Marpa::R3::Internal::Scanless::G::IF_INACCESSIBLE]
        // 'warn';
    SYMBOL:
    for my $symbol_id ( grep { !$grammar_c->symbol_is_accessible($_) }
        ( 0 .. $grammar_c->highest_symbol_id() ) )
    {
        my $xsy      = $xsy_by_isyid->[$symbol_id];

        # Inaccessible internal symbols may be created
        # from inaccessible use symbols -- ignore these.
        # This assumes that Marpa's logic
        # is correct and that
        # it is not creating inaccessible symbols from
        # accessible ones.
        next SYMBOL if not defined $xsy;

        my $treatment =
            $xsy->[Marpa::R3::Internal::XSY::IF_INACCESSIBLE] //
            $default_if_inaccessible;
        next SYMBOL if $treatment eq 'ok';
        my $symbol_name = $grammar->symbol_name($symbol_id);
        my $message = "Inaccessible symbol: $symbol_name";
        Marpa::R3::exception($message) if $treatment eq 'fatal';
        $DB::single = 1;
        say {$trace_fh} $message
            or Marpa::R3::exception("Could not print: $ERRNO");
    } ## end for my $symbol_id ( grep { !$grammar_c->...})

    # Save some memory
    $slg->[Marpa::R3::Internal::Scanless::G::CHARACTER_CLASSES] = undef;

    return ;

}

sub set_start_symbol {
    my $grammar = shift;

    my $tracer           = $grammar->[Marpa::R3::Internal::Grammar::TRACER];
    my $grammar_c        = $tracer->[Marpa::R3::Internal::Trace::G::C];
    my $start_name = $tracer->[Marpa::R3::Internal::Trace::G::START_NAME];
    my $start_id = $tracer->symbol_by_name($start_name);
    if ( not defined $start_id ) {
        Marpa::R3::exception(
qq{Internal error: Start symbol $start_name missing from grammar\n}
        );
    }

    if ( not defined $grammar_c->start_symbol_set($start_id) ) {
        Marpa::R3::uncaught_error( $grammar_c->error() );
    }
    return 1;
} ## end sub set_start_symbol

sub thick_subgrammar_by_name {
    my ( $slg, $subgrammar ) = @_;

    # Allow G0 as legacy synonym for L0
    state $grammar_names = { 'G0' => 1, 'G1' => 1, 'L0' => 1 };
    $subgrammar //= 'G1';

    Marpa::R3::exception(qq{No lexer named "$subgrammar"})
        if not defined $grammar_names->{$subgrammar};

    return $slg->[Marpa::R3::Internal::Scanless::G::THICK_G1_GRAMMAR]
        if $subgrammar eq 'G1';

    return $slg->[Marpa::R3::Internal::Scanless::G::THICK_L0_GRAMMAR];
} ## end sub thick_subgrammar_by_name

sub Marpa::R3::Scanless::G::start_symbol_id {
    my ( $slg, $rule_id, $subgrammar ) = @_;
    return thick_subgrammar_by_name( $slg, $subgrammar )->start_symbol();
}

sub Marpa::R3::Scanless::G::rule_name {
    my ( $slg, $rule_id, $subgrammar ) = @_;
    return thick_subgrammar_by_name( $slg, $subgrammar )->rule_name($rule_id);
}

sub Marpa::R3::Scanless::G::rule_expand {
    my ( $slg, $rule_id, $subgrammar ) = @_;
    return thick_subgrammar_by_name( $slg, $subgrammar )->tracer()
        ->rule_expand($rule_id);
}

sub Marpa::R3::Scanless::G::symbol_name {
    my ( $slg, $symbol_id, $subgrammar ) = @_;
    return thick_subgrammar_by_name($slg, $subgrammar)->tracer()
        ->symbol_name($symbol_id);
}

sub Marpa::R3::Scanless::G::symbol_display_form {
    my ( $slg, $symbol_id, $subgrammar ) = @_;
    return thick_subgrammar_by_name( $slg, $subgrammar )
        ->symbol_in_display_form($slg, $symbol_id);
}

sub Marpa::R3::Scanless::G::symbol_dsl_form {
    my ( $slg, $symbol_id ) = @_;
    my $subgrammar = $slg->[Marpa::R3::Internal::Scanless::G::THICK_G1_GRAMMAR];
    return $subgrammar->symbol_dsl_form($slg, $symbol_id);
}

sub Marpa::R3::Scanless::G::l0_symbol_dsl_form {
    my ( $slg, $symbol_id ) = @_;
    my $subgrammar = $slg->[Marpa::R3::Internal::Scanless::G::THICK_L0_GRAMMAR];
    return $subgrammar->symbol_dsl_form($slg, $symbol_id);
}

sub Marpa::R3::Scanless::G::rule_show
{
    my ( $slg, $rule_id, $subgrammar) = @_;
    return slg_rule_show($slg, $rule_id, thick_subgrammar_by_name($slg, $subgrammar));
}

sub slg_rule_show {
    my ( $slg, $rule_id, $subgrammar ) = @_;
    my $tracer       = $subgrammar->tracer();
    my $subgrammar_c = $tracer->[Marpa::R3::Internal::Trace::G::C];
    my @symbol_ids   = $tracer->rule_expand($rule_id);
    return if not scalar @symbol_ids;
    my ( $lhs, @rhs ) =
        map { $subgrammar->symbol_in_display_form($slg, $_) } @symbol_ids;
    my $minimum    = $subgrammar_c->sequence_min($rule_id);
    my @quantifier = ();

    if ( defined $minimum ) {
        @quantifier = ( $minimum <= 0 ? q{*} : q{+} );
    }
    return join q{ }, $lhs, q{::=}, @rhs, @quantifier;
} ## end sub slg_rule_show

sub Marpa::R3::Scanless::G::show_rules {
    my ( $slg, $verbose, $subgrammar ) = @_;
    my $text     = q{};
    $verbose    //= 0;
    $subgrammar //= 'G1';

    my $thick_grammar = thick_subgrammar_by_name($slg, $subgrammar);
    my $tracer = $thick_grammar->[Marpa::R3::Internal::Grammar::TRACER];
    my $grammar_c = $tracer->[Marpa::R3::Internal::Trace::G::C];
    my $rules = $tracer->[Marpa::R3::Internal::Trace::G::RULES];

    for my $rule ( @{$rules} ) {
        my $rule_id = $rule->[Marpa::R3::Internal::Rule::ID];

        my $minimum = $grammar_c->sequence_min($rule_id);
        my @quantifier =
            defined $minimum ? $minimum <= 0 ? (q{*}) : (q{+}) : ();
        my $lhs_id      = $grammar_c->rule_lhs($rule_id);
        my $rule_length = $grammar_c->rule_length($rule_id);
        my @rhs_ids =
            map { $grammar_c->rule_rhs( $rule_id, $_ ) }
            ( 0 .. $rule_length - 1 );
        $text .= join q{ }, $subgrammar, "R$rule_id",
            $thick_grammar->symbol_in_display_form($slg, $lhs_id),
            '::=',
            ( map { $thick_grammar->symbol_in_display_form($slg, $_) } @rhs_ids ),
            @quantifier;
        $text .= "\n";

        if ( $verbose >= 2 ) {

            my @comment = ();
            $grammar_c->rule_length($rule_id) == 0
                and push @comment, 'empty';
            $thick_grammar->rule_is_used($rule_id)
                or push @comment, '!used';
            $grammar_c->rule_is_productive($rule_id)
                or push @comment, 'unproductive';
            $grammar_c->rule_is_accessible($rule_id)
                or push @comment, 'inaccessible';
            $rule->[Marpa::R3::Internal::Rule::DISCARD_SEPARATION]
                and push @comment, 'discard_sep';

            if (@comment) {
                $text .= q{  } . ( join q{ }, q{/*}, @comment, q{*/} ) . "\n";
            }

            $text .= "  Symbol IDs: <$lhs_id> ::= "
                . ( join q{ }, map {"<$_>"} @rhs_ids ) . "\n";

        } ## end if ( $verbose >= 2 )

        if ( $verbose >= 3 ) {

            $text
                .= "  Internal symbols: <"
                . $tracer->symbol_name($lhs_id)
                . q{> ::= }
                . (
                join q{ },
                map { '<' . $tracer->symbol_name($_) . '>' } @rhs_ids
                ) . "\n";

        } ## end if ( $verbose >= 3 )

    } ## end for my $rule ( @{$rules} )

    return $text;
} ## end sub Marpa::R3::Scanless::G::show_rules

sub Marpa::R3::Scanless::G::show_symbols {
    my ( $slg, $verbose, $subgrammar ) = @_;
    my $text = q{};
    $verbose    //= 0;
    $subgrammar //= 'G1';

    my $thick_grammar = thick_subgrammar_by_name( $slg, $subgrammar );
    my $tracer        = $thick_grammar->tracer();
    my $grammar_c     = $tracer->[Marpa::R3::Internal::Trace::G::C];

    for my $symbol_id ( 0 .. $grammar_c->highest_symbol_id() ) {

        $text .= join q{ }, $subgrammar, "S$symbol_id",
          $thick_grammar->symbol_in_display_form( $slg, $symbol_id );
        $text .= "\n";

        if ( $verbose >= 2 ) {

            my @tag_list = ();
            $grammar_c->symbol_is_productive($symbol_id)
              or push @tag_list, 'unproductive';
            $grammar_c->symbol_is_accessible($symbol_id)
              or push @tag_list, 'inaccessible';
            $grammar_c->symbol_is_nulling($symbol_id)
              and push @tag_list, 'nulling';
            $grammar_c->symbol_is_terminal($symbol_id)
              and push @tag_list, 'terminal';

            if (@tag_list) {
                $text .= q{  } . ( join q{ }, q{/*}, @tag_list, q{*/} ) . "\n";
            }

            $text .=
              "  Internal name: <" . $tracer->symbol_name($symbol_id) . qq{>\n};

        } ## end if ( $verbose >= 2 )

        if ( $verbose >= 3 ) {

            my $dsl_form = $thick_grammar->symbol_dsl_form( $slg, $symbol_id );
            if ($dsl_form) { $text .= qq{  SLIF name: $dsl_form\n}; }

        } ## end if ( $verbose >= 3 )

    } ## end for my $symbol ( @{$symbols} )

    return $text;
} ## end sub Marpa::R3::Scanless::G::show_symbols

sub Marpa::R3::Scanless::G::symid_is_accessible {
    my ( $slg, $symid ) = @_;
    my $thick_grammar = thick_subgrammar_by_name($slg, 'G1');
    my $tracer = $thick_grammar->[Marpa::R3::Internal::Grammar::TRACER];
    my $grammar_c = $tracer->[Marpa::R3::Internal::Trace::G::C];
    return $grammar_c->symbol_is_accessible($symid)
}

sub Marpa::R3::Scanless::G::symid_is_productive {
    my ( $slg, $symid ) = @_;
    my $thick_grammar = thick_subgrammar_by_name($slg, 'G1');
    my $tracer = $thick_grammar->[Marpa::R3::Internal::Grammar::TRACER];
    my $grammar_c = $tracer->[Marpa::R3::Internal::Trace::G::C];
    return $grammar_c->symbol_is_productive($symid)
}

sub Marpa::R3::Scanless::G::symid_is_nulling {
    my ( $slg, $symid ) = @_;
    my $thick_grammar = thick_subgrammar_by_name($slg, 'G1');
    my $tracer = $thick_grammar->[Marpa::R3::Internal::Grammar::TRACER];
    my $grammar_c = $tracer->[Marpa::R3::Internal::Trace::G::C];
    return $grammar_c->symbol_is_nulling($symid)
}

sub Marpa::R3::Scanless::G::show_dotted_rule {
    my ( $slg, $rule_id, $dot_position ) = @_;
    my $grammar =  $slg->[Marpa::R3::Internal::Scanless::G::THICK_G1_GRAMMAR];
    my $tracer  = $grammar->tracer();
    my $grammar_c = $tracer->[Marpa::R3::Internal::Trace::G::C];
    my ( $lhs, @rhs ) =
    map { $grammar->symbol_in_display_form($slg, $_) } $tracer->rule_expand($rule_id);
    my $rhs_length = scalar @rhs;

    my $minimum = $grammar_c->sequence_min($rule_id);
    my @quantifier = ();
    if (defined $minimum) {
        @quantifier = ($minimum <= 0 ? q{*} : q{+} );
    }
    $dot_position = 0 if $dot_position < 0;
    if ($dot_position < $rhs_length) {
        splice @rhs, $dot_position, 0, q{.};
        return join q{ }, $lhs, q{->}, @rhs, @quantifier;
    } else {
        return join q{ }, $lhs, q{->}, @rhs, @quantifier, q{.};
    }
} ## end sub Marpa::R3::Grammar::show_dotted_rule

sub Marpa::R3::Scanless::G::rule_ids {
    my ($slg, $subgrammar) = @_;
    return thick_subgrammar_by_name($slg, $subgrammar)->rule_ids();
}

sub Marpa::R3::Scanless::G::symbol_ids {
    my ($slg, $subgrammar) = @_;
    return thick_subgrammar_by_name($slg, $subgrammar)->symbol_ids();
}

# Internal methods, not to be documented

sub Marpa::R3::Scanless::G::thick_g1_grammar {
    my ($slg) = @_;
    return $slg->[Marpa::R3::Internal::Scanless::G::THICK_G1_GRAMMAR];
}

sub Marpa::R3::Scanless::G::tracer {
    my ($slg) = @_;
    my $grammar =  $slg->[Marpa::R3::Internal::Scanless::G::THICK_G1_GRAMMAR];
    return $grammar->tracer();
}

sub Marpa::R3::Scanless::G::show_irls {
    my ($slg, $subgrammar) = @_;
    return thick_subgrammar_by_name($slg, $subgrammar)->show_irls();
}

sub Marpa::R3::Scanless::G::show_isys {
    my ($slg, $subgrammar) = @_;
    return thick_subgrammar_by_name($slg, $subgrammar)->show_isys();
}

sub Marpa::R3::Scanless::G::show_ahms {
    my ( $slg, $verbose ) = @_;
    my $g1_tracer = $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];
    return $g1_tracer->show_ahms($verbose);
}
1;

# vim: expandtab shiftwidth=4:
