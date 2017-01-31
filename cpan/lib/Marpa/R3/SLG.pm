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

package Marpa::R3::Scanless::G;

use 5.010001;
use strict;
use warnings;

use vars qw($VERSION $STRING_VERSION);
$VERSION        = '4.001_035';
$STRING_VERSION = $VERSION;
## no critic(BuiltinFunctions::ProhibitStringyEval)
$VERSION = eval $VERSION;
## use critic

package Marpa::R3::Internal::Scanless::G;

use Scalar::Util 'blessed';
use English qw( -no_match_vars );

# names of packages for strings
our $PACKAGE = 'Marpa::R3::Scanless::G';

# The bare mininum Scanless grammer, suitable as a base
# for both metagrammar and user grammars.
sub pre_construct {
    my ($class) = @_;
    my $pre_slg = bless [], $class;
    $pre_slg->[Marpa::R3::Internal::Scanless::G::EXHAUSTION_ACTION] = 'fatal';
    $pre_slg->[Marpa::R3::Internal::Scanless::G::REJECTION_ACTION] = 'fatal';
    $pre_slg->[Marpa::R3::Internal::Scanless::G::TRACE_FILE_HANDLE] = \*STDERR;
    $pre_slg->[Marpa::R3::Internal::Scanless::G::RANKING_METHOD] = 'none';
    return $pre_slg;
}

sub Marpa::R3::Internal::Scanless::meta_grammar {

    my $meta_slg = pre_construct('Marpa::R3::Scanless::G');

    state $hashed_metag = Marpa::R3::Internal::MetaG::hashed_grammar();
    Marpa::R3::Internal::Scanless::G::hash_to_runtime( $meta_slg, $hashed_metag,
        { bless_package => 'Marpa::R3::Internal::MetaAST_Nodes' } );

    my $tracer = $meta_slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];

    return $meta_slg;

} ## end sub Marpa::R3::Internal::Scanless::meta_grammar

sub Marpa::R3::Scanless::G::new {
    my ( $class, @hash_ref_args ) = @_;

    my $slg = pre_construct($class);

    $slg->[Marpa::R3::Internal::Scanless::G::WARNINGS]        = 1;
    $slg->[Marpa::R3::Internal::Scanless::G::IF_INACCESSIBLE] = 'warn';

    my ( $flat_args, $error_message ) =
      Marpa::R3::flatten_hash_args( \@hash_ref_args );
    Marpa::R3::exception( sprintf $error_message, '$slg->new' )
      if not $flat_args;

    my ( $p_dsl, $g1_args ) =
      Marpa::R3::Internal::Scanless::G::set( $slg, $flat_args );
    my $ast        = Marpa::R3::Internal::MetaAST->new($p_dsl);
    my $hashed_ast = $ast->ast_to_hash($p_dsl);
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

    my $value = $flat_args->{trace_file_handle};
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

    my $trace_file_handle = 
        $slg->[Marpa::R3::Internal::Scanless::G::TRACE_FILE_HANDLE];

    if ( exists $flat_args->{'trace_actions'} ) {
        my $value = $flat_args->{'trace_actions'};
        $slg->[Marpa::R3::Internal::Scanless::G::TRACE_ACTIONS] = $value;
        if ($value) {
            say {$trace_file_handle} 'Setting trace_actions option'
              or Marpa::R3::exception("Cannot print: $ERRNO");
        }
        delete $flat_args->{'trace_actions'};
    }

    if ( exists $flat_args->{'exhaustion'} ) {

        state $exhaustion_actions = { map { ( $_, 0 ) } qw(fatal event) };
        my $value = $flat_args->{'exhaustion'} // 'undefined';
        Marpa::R3::exception(
            qq{'exhaustion' named arg value is $value (should be one of },
            (
                join q{, }, map { q{'} . $_ . q{'} } keys %{$exhaustion_actions}
            ),
            ')'
        ) if not exists $exhaustion_actions->{$value};
        $slg->[Marpa::R3::Internal::Scanless::G::EXHAUSTION_ACTION] = $value;
        delete $flat_args->{'exhaustion'};

    }

    if ( exists $flat_args->{'rejection'} ) {

        state $rejection_actions = { map { ( $_, 0 ) } qw(fatal event) };
        my $value = $flat_args->{'rejection'} // 'undefined';
        Marpa::R3::exception(
            qq{'rejection' named arg value is $value (should be one of },
            ( join q{, }, map { q{'} . $_ . q{'} } keys %{$rejection_actions} ),
            ')'
        ) if not exists $rejection_actions->{$value};
        $slg->[Marpa::R3::Internal::Scanless::G::REJECTION_ACTION] = $value;
        delete $flat_args->{'rejection'};

    }

    if ( exists $flat_args->{'semantics_package'} ) {
        my $value = $flat_args->{'semantics_package'};
        $slg->[Marpa::R3::Internal::Scanless::G::SEMANTICS_PACKAGE] = $value;
        delete $flat_args->{'semantics_package'};
    }

    if ( exists $flat_args->{'ranking_method'} ) {

        # Only allowed in new method
        state $ranking_methods =
          { map { ( $_, 0 ) } qw(high_rule_only rule none) };
        my $value = $flat_args->{'ranking_method'} // 'undefined';
        Marpa::R3::exception(
            qq{ranking_method value is $value (should be one of },
            ( join q{, }, map { q{'} . $_ . q{'} } keys %{$ranking_methods} ),
            ')' )
          if not exists $ranking_methods->{$value};
        $slg->[Marpa::R3::Internal::Scanless::G::RANKING_METHOD] = $value;
        delete $flat_args->{'ranking_method'};
    }

    return ( $dsl, $flat_args );

} ## end sub Marpa::R3::Internal::Scanless::G::set

sub Marpa::R3::Internal::Scanless::G::hash_to_runtime {
    my ( $slg, $hashed_source, $g1_args ) = @_;

    my $trace_fh = $slg->[Marpa::R3::Internal::Scanless::G::TRACE_FILE_HANDLE];
    # Pre-lexer G1 processing

    my $kollos = Marpa::R3::Lua->new();
    my $thin_slg = $slg->[Marpa::R3::Internal::Scanless::G::C] =
      Marpa::R3::Thin::SLG->new($kollos);

    $slg->call_by_tag(
        ('@' .__FILE__ . ':' .  __LINE__),
        <<'END_OF_LUA', '');
        local grammar = ...
        grammar.l0_rules = {}
        grammar.l0_symbols = {}
        grammar.g1_rules = {}
        grammar.g1_symbols = {}
END_OF_LUA

    my @xsy_names = keys %{ $hashed_source->{xsy} };

    my $xsy_by_id = $slg->[Marpa::R3::Internal::Scanless::G::XSY_BY_ID] = [];
    my $xsy_by_name = $slg->[Marpa::R3::Internal::Scanless::G::XSY_BY_NAME] =
      {};
    for my $xsy_name ( sort @xsy_names ) {
        my $runtime_xsy_data = [];
        $runtime_xsy_data->[Marpa::R3::Internal::XSY::ID] =
          scalar @{$xsy_by_id};
        $runtime_xsy_data->[Marpa::R3::Internal::XSY::NAME] = $xsy_name;
        my $source_xsy_data = $hashed_source->{xsy}->{$xsy_name};
      KEY: for my $datum_key ( keys %{$source_xsy_data} ) {
            if ( $datum_key eq 'action' ) {
                $runtime_xsy_data->[Marpa::R3::Internal::XSY::LEXEME_SEMANTICS]
                  = $source_xsy_data->{$datum_key};
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
                $runtime_xsy_data->[Marpa::R3::Internal::XSY::IF_INACCESSIBLE]
                  = $source_xsy_data->{$datum_key};
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

    $slg->[Marpa::R3::Internal::Scanless::G::XRL_BY_ID]   = [];
    $slg->[Marpa::R3::Internal::Scanless::G::XRL_BY_NAME] = {};
    my $xrls        = $hashed_source->{xrl};
    my $xrl_by_id   = $slg->[Marpa::R3::Internal::Scanless::G::XRL_BY_ID];
    my $xrl_by_name = $slg->[Marpa::R3::Internal::Scanless::G::XRL_BY_NAME];

    # Sort (from major to minor) by start position,
    # and subkey.
    for my $xrl_name (
        map  { $_->[0] }
        sort { $a->[1] <=> $b->[1] }
        map  { [ $_, $xrls->{$_}->{start} ] } keys %{$xrls}
      )
    {
        my $source_xrl_data  = $xrls->{$xrl_name};
        my $runtime_xrl_data = [];
        $runtime_xrl_data->[Marpa::R3::Internal::XRL::ID] =
          scalar @{$xrl_by_id};
        $runtime_xrl_data->[Marpa::R3::Internal::XRL::NAME] = $xrl_name;
      KEY: for my $datum_key ( keys %{$source_xrl_data} ) {
            if ( $datum_key eq 'id' ) {
                $runtime_xrl_data->[Marpa::R3::Internal::XRL::NAME] =
                  $source_xrl_data->{$datum_key};
                next KEY;
            }
            if ( $datum_key eq 'precedence_count' ) {
                $runtime_xrl_data->[Marpa::R3::Internal::XRL::PRECEDENCE_COUNT]
                  = $source_xrl_data->{$datum_key};
                next KEY;
            }
            if ( $datum_key eq 'lhs' ) {
                $runtime_xrl_data->[Marpa::R3::Internal::XRL::LHS] =
                  $source_xrl_data->{$datum_key};
                next KEY;
            }
            if ( $datum_key eq 'start' ) {
                $runtime_xrl_data->[Marpa::R3::Internal::XRL::START] =
                  $source_xrl_data->{$datum_key};
                next KEY;
            }
            if ( $datum_key eq 'length' ) {
                $runtime_xrl_data->[Marpa::R3::Internal::XRL::LENGTH] =
                  $source_xrl_data->{$datum_key};
                next KEY;
            }
            Marpa::R3::exception(
                "Internal error: Unknown hashed source xrl field: $datum_key");
        }
        push @{$xrl_by_id}, $runtime_xrl_data;
        $xrl_by_name->{$xrl_name} = $runtime_xrl_data;
    }

    $slg->[Marpa::R3::Internal::Scanless::G::L0_XBNF_BY_ID]   = [];
    $slg->[Marpa::R3::Internal::Scanless::G::G1_XBNF_BY_ID]   = [];
    $slg->[Marpa::R3::Internal::Scanless::G::L0_XBNF_BY_NAME] = {};
    $slg->[Marpa::R3::Internal::Scanless::G::G1_XBNF_BY_NAME] = {};
    for my $subgrammar (qw(G1 L0)) {
        my $xbnfs = $hashed_source->{xbnf}->{$subgrammar};
        my $xbnf_by_id =
            $subgrammar eq 'L0'
          ? $slg->[Marpa::R3::Internal::Scanless::G::L0_XBNF_BY_ID]
          : $slg->[Marpa::R3::Internal::Scanless::G::G1_XBNF_BY_ID];
        my $xbnf_by_name =
            $subgrammar eq 'L0'
          ? $slg->[Marpa::R3::Internal::Scanless::G::L0_XBNF_BY_NAME]
          : $slg->[Marpa::R3::Internal::Scanless::G::G1_XBNF_BY_NAME];

        # Sort (from major to minor) by start position,
        # and subkey.
        for my $xbnf_name (
            map { $_->[0] }
            sort {
                # die  "a=", Data::Dumper::Dumper($a) if not defined $a->[1];
                # die  "a=", Data::Dumper::Dumper($a) if not defined $a->[2];
                # die  "b=", Data::Dumper::Dumper($b) if not defined $a->[1];
                # die  "b=", Data::Dumper::Dumper($b) if not defined $b->[2];
                $a->[1] <=> $b->[1]
                  || $a->[2] <=> $b->[2]
            }
            map { [ $_, $xbnfs->{$_}->{start}, $xbnfs->{$_}->{subkey} ] }
            keys %{$xbnfs}
          )
        {
            $DB::single = 1 if not defined $xbnf_name;
            my $source_xbnf_data  = $xbnfs->{$xbnf_name};
            my $runtime_xbnf_data = [];
            $runtime_xbnf_data->[Marpa::R3::Internal::XBNF::ID] =
              scalar @{$xbnf_by_id};
          KEY: for my $datum_key ( keys %{$source_xbnf_data} ) {
                if ( $datum_key eq 'xrlid' ) {
                    $runtime_xbnf_data->[Marpa::R3::Internal::XBNF::XRL] =
                      $xrl_by_name->{$datum_key};
                    next KEY;
                }
                if ( $datum_key eq 'name' ) {
                    $runtime_xbnf_data->[Marpa::R3::Internal::XBNF::NAME] =
                      $source_xbnf_data->{$datum_key};
                    next KEY;
                }
                if ( $datum_key eq 'lhs' ) {
                    $runtime_xbnf_data->[Marpa::R3::Internal::XBNF::LHS] =
                      $source_xbnf_data->{$datum_key};
                    next KEY;
                }
                if ( $datum_key eq 'rhs' ) {
                    $runtime_xbnf_data->[Marpa::R3::Internal::XBNF::RHS] =
                      $source_xbnf_data->{$datum_key};
                    next KEY;
                }
                if ( $datum_key eq 'rank' ) {
                    $runtime_xbnf_data->[Marpa::R3::Internal::XBNF::RANK] =
                      $source_xbnf_data->{$datum_key};
                    next KEY;
                }
                if ( $datum_key eq 'null_ranking' ) {
                    $runtime_xbnf_data
                      ->[Marpa::R3::Internal::XBNF::NULL_RANKING] =
                      $source_xbnf_data->{$datum_key};
                    next KEY;
                }
                if ( $datum_key eq 'symbol_as_event' ) {
                    $runtime_xbnf_data
                      ->[Marpa::R3::Internal::XBNF::SYMBOL_AS_EVENT] =
                      $source_xbnf_data->{$datum_key};
                    next KEY;
                }
                if ( $datum_key eq 'event' ) {
                    $runtime_xbnf_data->[Marpa::R3::Internal::XBNF::EVENT] =
                      $source_xbnf_data->{$datum_key};
                    next KEY;
                }
                if ( $datum_key eq 'min' ) {
                    $runtime_xbnf_data->[Marpa::R3::Internal::XBNF::MIN] =
                      $source_xbnf_data->{$datum_key};
                    next KEY;
                }
                if ( $datum_key eq 'separator' ) {
                    $runtime_xbnf_data->[Marpa::R3::Internal::XBNF::SEPARATOR]
                      = $source_xbnf_data->{$datum_key};
                    next KEY;
                }
                if ( $datum_key eq 'proper' ) {
                    $runtime_xbnf_data->[Marpa::R3::Internal::XBNF::PROPER] =
                      $source_xbnf_data->{$datum_key};
                    next KEY;
                }
                if ( $datum_key eq 'bless' ) {
                    $runtime_xbnf_data->[Marpa::R3::Internal::XBNF::BLESSING] =
                      $source_xbnf_data->{$datum_key};
                    next KEY;
                }
                if ( $datum_key eq 'action' ) {
                    $runtime_xbnf_data->[Marpa::R3::Internal::XBNF::ACTION_NAME]
                      = $source_xbnf_data->{$datum_key};
                    next KEY;
                }
                if ( $datum_key eq 'start' ) {
                    $runtime_xbnf_data->[Marpa::R3::Internal::XBNF::START] =
                      $source_xbnf_data->{$datum_key};
                    next KEY;
                }
                if ( $datum_key eq 'length' ) {
                    $runtime_xbnf_data->[Marpa::R3::Internal::XBNF::LENGTH] =
                      $source_xbnf_data->{$datum_key};
                    next KEY;
                }
                if ( $datum_key =~ /\A (mask|keep|subkey|id) \z/xms ) {
                    next KEY;
                }
                Marpa::R3::exception(
"Internal error: Unknown hashed source xbnf field: $datum_key"
                );
            }

            $runtime_xbnf_data->[Marpa::R3::Internal::XBNF::DISCARD_SEPARATION]
              = $runtime_xbnf_data->[Marpa::R3::Internal::XBNF::SEPARATOR]
              && !$source_xbnf_data->{keep};

            my $rhs_length =
              scalar @{ $runtime_xbnf_data->[Marpa::R3::Internal::XBNF::RHS] };

            if ( $rhs_length == 0
                || !
                defined $runtime_xbnf_data->[Marpa::R3::Internal::XBNF::MIN] )
            {
                my $explicit_mask = $source_xbnf_data->{mask};
                if ($explicit_mask) {
                    $runtime_xbnf_data->[Marpa::R3::Internal::XBNF::MASK] =
                      $explicit_mask;
                }
                else {
                    $runtime_xbnf_data->[Marpa::R3::Internal::XBNF::MASK] =
                      [ (1) x $rhs_length ];
                }
            }

            push @{$xbnf_by_id}, $runtime_xbnf_data;
            $xbnf_by_name->{$xbnf_name} = $runtime_xbnf_data;
        }
    }

    my $if_inaccessible_default_arg =
      $hashed_source->{defaults}->{if_inaccessible};
    if ( defined $if_inaccessible_default_arg ) {
        $slg->[Marpa::R3::Internal::Scanless::G::IF_INACCESSIBLE] =
          $if_inaccessible_default_arg;
    }
    my $if_inaccessible_default =
      $slg->[Marpa::R3::Internal::Scanless::G::IF_INACCESSIBLE];

    # Create the the G1 grammar

    if ( defined( my $value = $g1_args->{'bless_package'} ) ) {
        $slg->[Marpa::R3::Internal::Scanless::G::BLESS_PACKAGE] = $value;
        delete $g1_args->{'bless_package'};
    }

    if ( defined( my $value = $g1_args->{'warnings'} ) ) {
        $slg->[Marpa::R3::Internal::Scanless::G::WARNINGS] = $value;
        delete $g1_args->{'warnings'};
    }

    my $g1_tracer = $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER] =
      Marpa::R3::Trace::G->new($thin_slg, "G1");
    $g1_tracer->[Marpa::R3::Internal::Trace::G::XSY_BY_ISYID] = [];

    $slg->call_by_tag(
        ('@' .__FILE__ . ':' .  __LINE__),
        <<'END_OF_LUA', '');
        local grammar = ...
        local g1g = grammar.lmw_g1g
        g1g.start_name = '[:start]'
END_OF_LUA

    for my $symbol ( sort keys %{ $hashed_source->{symbols}->{G1} } ) {
        assign_G1_symbol( $slg, $symbol,
            $hashed_source->{symbols}->{G1}->{$symbol} );
    }

    add_G1_user_rules( $slg, $hashed_source->{rules}->{G1} );

    my @bad_arguments = keys %{$g1_args};
    if ( scalar @bad_arguments ) {
        Marpa::R3::exception(
            q{Internal error: Bad named argument(s) to hash_to_runtime() method}
              . join q{ },
            @bad_arguments
        );
    }

    my $g1_thin = $g1_tracer->grammar();

    my $symbol_ids_by_event_name_and_type = {};
    $slg->[Marpa::R3::Internal::Scanless::G::SYMBOL_IDS_BY_EVENT_NAME_AND_TYPE]
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
        push @{ $symbol_ids_by_event_name_and_type->{$event_name}->{completion}
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
        push @{ $symbol_ids_by_event_name_and_type->{$event_name}->{prediction}
        }, $symbol_id;
    } ## end for my $symbol_name ( keys %{$prediction_events_by_name...})

    my $lexeme_events_by_id =
      $slg->[Marpa::R3::Internal::Scanless::G::LEXEME_EVENT_BY_ID] = [];

    my $precompute_error =
      Marpa::R3::Internal::Scanless::G::precompute( $slg, $g1_tracer );
    if ( defined $precompute_error ) {
        if ( $precompute_error == $Marpa::R3::Error::UNPRODUCTIVE_START ) {

            # Maybe someday improve this by finding the start rule and showing
            # its RHS -- for now it is clear enough
            Marpa::R3::exception(qq{Unproductive start symbol});
        } ## end if ( $precompute_error == ...)
        Marpa::R3::exception( 'Internal errror: unnkown precompute error code ',
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
    my $lexeme_default_adverbs  = $hashed_source->{lexeme_default_adverbs} // {};

    # Current lexeme data is spread out in many places.
    # Change so that it all resides in this hash, indexed by
    # name
    my %lexeme_data = ();

    # Lexers

    my @discard_event_by_lexer_rule_id = ();
    state $lex_start_symbol_name = '[:start_lex]';
    state $discard_symbol_name   = '[:discard]';

    my $lexer_rules          = $hashed_source->{rules}->{'L0'};
    my $character_class_hash = $hashed_source->{character_classes};
    my $lexer_symbols        = $hashed_source->{symbols}->{'L0'};

    # If no lexer rules, fake a lexer
    # Fake a lexer -- it discards symbols in character classes which
    # never matches
    if ( not scalar @{$lexer_rules} ) {
        $character_class_hash = { '[[^\\d\\D]]' => [ '[^\\d\\D]', '' ] };
        $lexer_rules = [
            {
                'rhs'             => ['[[^\\d\\D]]'],
                'lhs'             => '[:discard]',
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

    my %lex_lhs       = ();
    my %lex_rhs       = ();
    my %lex_separator = ();

    for my $lex_rule ( @{$lexer_rules} ) {
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
      map { "<$_>" }
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

    my $lex_tracer = $slg->[Marpa::R3::Internal::Scanless::G::L0_TRACER] =
      Marpa::R3::Trace::G->new($thin_slg, "L0");
    $lex_tracer->[Marpa::R3::Internal::Trace::G::XSY_BY_ISYID] = [];

    $slg->call_by_tag(
        ('@' .__FILE__ . ':' .  __LINE__),
        <<'END_OF_LUA', 's', $lex_start_symbol_name);
        local grammar, start_name = ...
        local l0g = grammar.lmw_l0g
        l0g.start_name = start_name
END_OF_LUA

    for my $symbol ( sort keys %this_lexer_symbols ) {
        my $properties = $this_lexer_symbols{$symbol};
        assign_L0_symbol( $slg, $symbol, $properties );
    }

    add_L0_user_rules( $slg, $lexer_rules );

    my $lex_thin = $lex_tracer->grammar();

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
                "A lexeme in L0 is not a lexeme in G1: $lexeme_name");
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

        my $assertion_id =
          $lexeme_data{$lexeme_name}{lexer}{'assertion'};
        if ( not defined $assertion_id ) {
            $assertion_id = $lex_thin->zwa_new(0);
            $lexeme_data{$lexeme_name}{lexer}{'assertion'} =
              $assertion_id;
        } ## end if ( not defined $assertion_id )
        $lex_thin->zwa_place( $assertion_id, $rule_id, 0 );
    } ## end RULE_ID: for my $rule_id ( 0 .. $lex_thin->highest_rule_id() )

    my $lex_precompute_error =
      Marpa::R3::Internal::Scanless::G::precompute( $slg, $lex_tracer );
    if ( defined $lex_precompute_error ) {
        Marpa::R3::exception(
'Internal errror: expected error code from precompute of lexer grammar ',
            $precompute_error
        );
    }

    my @class_table = ();

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

    my $l0_xbnfs_by_irlid =
      $lex_tracer->[Marpa::R3::Internal::Trace::G::XBNF_BY_IRLID];
    my $default_discard_event = $discard_default_adverbs->{event};
  RULE_ID: for my $irlid ( 0 .. $lex_thin->highest_rule_id() ) {
        my $xbnf = $l0_xbnfs_by_irlid->[$irlid];

        # There may be gaps in the IRLIDs
        next RULE_ID if not defined $xbnf;
        my $event;
      FIND_EVENT: {
            $event = $xbnf->[Marpa::R3::Internal::XBNF::EVENT];
            last FIND_EVENT if defined $event;
            my $lhs_id = $lex_thin->rule_lhs($irlid);
            last FIND_EVENT if $lhs_id != $lex_discard_symbol_id;
            $event = $default_discard_event;
        } ## end FIND_EVENT:
        next RULE_ID if not defined $event;

        my ( $event_name, $event_starts_active ) = @{$event};
        if ( $event_name eq q{'symbol} ) {
            my @event = (
                $event = $xbnf->[Marpa::R3::Internal::XBNF::SYMBOL_AS_EVENT],
                $event_starts_active
            );
            $discard_event_by_lexer_rule_id[$irlid] = \@event;
            next RULE_ID;
        } ## end if ( $event_name eq q{'symbol} )
        if ( ( substr $event_name, 0, 1 ) ne q{'} ) {
            $discard_event_by_lexer_rule_id[$irlid] = $event;
            next RULE_ID;
        }
        Marpa::R3::exception(qq{Discard event has unknown name: "$event_name"});

    } ## end RULE_ID: for my $rule_id ( 0 .. $lex_thin->highest_rule_id() )

    # Post-lexer G1 processing

    my $thin_L0  = $lex_tracer->[Marpa::R3::Internal::Trace::G::C];
    $thin_slg->associate( $thin_L0, $g1_tracer->grammar() );

  LEXEME: for my $lexeme_name ( keys %g1_id_by_lexeme_name ) {
        Marpa::R3::exception(
            "A lexeme in G1 is not a lexeme in L0: $lexeme_name")
          if not defined $lexeme_data{$lexeme_name}{'lexer'};
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
    # already determined above.
  LEXEME: for my $lexeme_name ( keys %g1_id_by_lexeme_name ) {
        my $g1_lexeme_id = $g1_id_by_lexeme_name{$lexeme_name};
        my $declarations = $lexeme_declarations->{$lexeme_name};
        my $priority     = $declarations->{priority} // 0;
        $thin_slg->g1_lexeme_set( $g1_lexeme_id, $priority );
        my $pause_value = $declarations->{pause};
        if ( defined $pause_value ) {
            $thin_slg->g1_lexeme_pause_set( $g1_lexeme_id, $pause_value );
            my $is_active = 1;

            if ( defined( my $event_data = $declarations->{'event'} ) ) {
                my $event_name;
                ( $event_name, $is_active ) = @{$event_data};
                $lexeme_events_by_id->[$g1_lexeme_id] = $event_name;
                push
                  @{ $symbol_ids_by_event_name_and_type->{$event_name}->{lexeme}
                  }, $g1_lexeme_id;
            } ## end if ( defined( my $event_data = $declarations->{'event'...}))

            $thin_slg->g1_lexeme_pause_activate( $g1_lexeme_id, $is_active );
        } ## end if ( defined $pause_value )

    } ## end LEXEME: for my $lexeme_name ( keys %g1_id_by_lexeme_name )

    # Second phase of lexer processing
  RULE_ID: for my $lexer_rule_id ( 0 .. $#lex_rule_to_g1_lexeme ) {
        my $g1_lexeme_id = $lex_rule_to_g1_lexeme[$lexer_rule_id];
        my $lexeme_name  = $g1_tracer->symbol_name($g1_lexeme_id);
        my $assertion_id = $lexeme_data{$lexeme_name}{lexer}{'assertion'} // -1;

      $thin_slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 'iii', $lexer_rule_id, $g1_lexeme_id, $assertion_id );
    local g, lexer_rule_id, g1_lexeme_id, assertion_id = ...
    -- print('g1_lexeme_id: ', inspect(g1_lexeme_id))
    -- print('lexer_rule_id: ', inspect(lexer_rule_id))
    -- print('g: ', inspect(g.g1_rules[lexer_rule_id]))
    if lexer_rule_id >= 0 then
        g.l0_rules[lexer_rule_id].g1_lexeme = g1_lexeme_id
    end
    if g1_lexeme_id >= 0 then
        g.g1_symbols[g1_lexeme_id].assertion = assertion_id
    end
END_OF_LUA

        my $discard_event = $discard_event_by_lexer_rule_id[$lexer_rule_id];
        if ( defined $discard_event ) {
            my ( $event_name, $is_active ) = @{$discard_event};
            $slg
              ->[ Marpa::R3::Internal::Scanless::G::DISCARD_EVENT_BY_LEXER_RULE
              ]->[$lexer_rule_id] = $event_name;
            push
              @{ $symbol_ids_by_event_name_and_type->{$event_name}->{discard} },
              $lexer_rule_id;
            $thin_slg->discard_event_set( $lexer_rule_id, 1 );
            $thin_slg->discard_event_activate( $lexer_rule_id, 1 )
              if $is_active;
        } ## end if ( defined $discard_event )
    }

    # Second phase of G1 processing

    $thin_slg->precompute();

    # More lexer processing
    # Determine events by lexer rule, applying the defaults

    $slg->[Marpa::R3::Internal::Scanless::G::CHARACTER_CLASS_TABLE] =
      $character_class_table;

    # Some lexeme default adverbs are applied in earlier phases.
  {

        my $default_lexeme_action = $lexeme_default_adverbs->{action};
        my $xsy_by_isyid =
          $g1_tracer->[Marpa::R3::Internal::Trace::G::XSY_BY_ISYID];

      LEXEME:
        for my $lexeme_name ( keys %g1_id_by_lexeme_name ) {
            my $g1_lexeme_id = $g1_id_by_lexeme_name{$lexeme_name};
            my $xsy          = $xsy_by_isyid->[$g1_lexeme_id];
            next LEXEME if not defined $xsy;
            next LEXEME
              if $xsy->[Marpa::R3::Internal::XSY::NAME_SOURCE] ne 'lexical';
            $xsy->[Marpa::R3::Internal::XSY::LEXEME_SEMANTICS] //=
              $default_lexeme_action;
        } ## end LEXEME: for my $lexeme_name ( keys %g1_id_by_lexeme_name )
    }

  APPLY_DEFAULT_LEXEME_BLESSING: {
        my $tracer = $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];
        my $default_blessing = $lexeme_default_adverbs->{bless};
        my $xsy_by_isyid =
          $g1_tracer->[Marpa::R3::Internal::Trace::G::XSY_BY_ISYID];

      LEXEME:
        for my $lexeme_name ( keys %g1_id_by_lexeme_name ) {
            my $g1_lexeme_id = $g1_id_by_lexeme_name{$lexeme_name};
            my $xsy          = $xsy_by_isyid->[$g1_lexeme_id];
            next LEXEME if not defined $xsy;
            next LEXEME
              if $xsy->[Marpa::R3::Internal::XSY::NAME_SOURCE] ne 'lexical';

            my $blessing = $xsy->[Marpa::R3::Internal::XSY::BLESSING]
              // $default_blessing;
            $blessing //= '::undef';

          FIND_BASE_BLESSING: {
                if ( $blessing eq '::undef' ) {
                    last FIND_BASE_BLESSING;
                }
                if ( $blessing eq '::name' ) {
                    if ( $lexeme_name =~ / [^ [:alnum:]] /xms ) {
                        Marpa::R3::exception(
qq{Lexeme blessing by '::name' only allowed if lexeme name is whitespace and alphanumerics\n},
                            qq{   Problematic lexeme was <$lexeme_name>\n}
                        );
                    } ## end if ( $lexeme_name =~ / [^ [:alnum:]] /xms )
                    $blessing = $lexeme_name;
                    $blessing =~ s/[ ]/_/gxms;
                    last FIND_BASE_BLESSING;
                } ## end if ( $default_blessing eq '::name' )
                if ( $blessing =~ /^ :: /xms ) {
                    Marpa::R3::exception(
                        qq{Blessing lexeme as '$blessing' is not allowed\n},
qq{   It is in pseudo-blessing form, but there is no such psuedo-blessing\n},
                        qq{   Problematic lexeme was <$lexeme_name>\n}
                    );
                }
                if ( $blessing =~ / [\W] /xms ) {
                    Marpa::R3::exception(
                        qq{Blessing lexeme as '$blessing' is not allowed\n},
qq{   It contained non-word characters and that is not allowed\n},
                        qq{   Problematic lexeme was <$lexeme_name>\n}
                    );
                } ## end if ( $default_blessing =~ / [\W] /xms )
            }

            if ( $blessing !~ / :: /xms ) {
                my $bless_package =
                  $slg->[Marpa::R3::Internal::Scanless::G::BLESS_PACKAGE];
                if ( not defined $bless_package ) {
                    my $lexeme_name = $tracer->symbol_name($g1_lexeme_id);
                    Marpa::R3::exception(
qq{Symbol "$lexeme_name" needs a blessing package, but grammar has none\n},
                        qq{  The blessing for "$lexeme_name" was "$blessing"\n}
                    );
                } ## end if ( not defined $bless_package )
                $blessing = $bless_package . q{::} . $blessing;
            }

            $xsy->[Marpa::R3::Internal::XSY::BLESSING] = $blessing;

        } ## end LEXEME: for my $lexeme_name ( keys %g1_id_by_lexeme_name )

    }

    my $registrations = Marpa::R3::Internal::Value::registrations_find($slg );
    Marpa::R3::Internal::Value::registrations_set($slg, $registrations );

    return $slg;

} ## end sub Marpa::R3::Internal::Scanless::G::hash_to_runtime

sub Marpa::R3::Internal::Scanless::G::precompute {
    my ($slg, $tracer) = @_;

    my $lmw_name = 'lmw_' . (lc $tracer->name()) . 'g';
    my $thin_slg = $slg->[Marpa::R3::Internal::Scanless::G::C];
    my $grammar_c = $tracer->[Marpa::R3::Internal::Trace::G::C];
    my $xsy_by_isyid     = $tracer->[Marpa::R3::Internal::Trace::G::XSY_BY_ISYID];

    my $trace_fh =
        $slg->[Marpa::R3::Internal::Scanless::G::TRACE_FILE_HANDLE];

    my ($do_return, $precompute_result, $precompute_error_code)
      = $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 's', $lmw_name );
    local grammar, lmw_name = ...
    local lmw_g = grammar[lmw_name]
    if lmw_g:is_precomputed() ~= 0 then
        return "false"
    end
    if lmw_g:force_valued() < 0 then
        error( lmw_g:error_description() )
    end
    local start_name = lmw_g.start_name
    local start_id = lmw_g.isyid_by_name[start_name]
    if not start_id then
        error(string.format(
"Internal error: Start symbol %q missing from grammar", start_name))
    end
    local result = lmw_g:start_symbol_set(start_id)
    if result < 0 then
        error(string.format(
            "Internal error: start_symbol_set() of %q failed; %s",
                start_name,
                lmw_g:error_description()
        ))
    end
    kollos.throw = false
    local result, error = lmw_g:precompute()
    kollos.throw = true
    if result then return "no", result, 0 end
    return "no", -1, error.code
END_OF_LUA

    return if $do_return eq "false";

    if ( $precompute_result < 0 ) {
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

      my ($ok, $result) =
      $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 'si', $lmw_name, $precompute_error_code );
    local grammar, lmw_name, error_code = ...
    local lmw_g = grammar[lmw_name]
    if error_code == kollos.err["NO_RULES"] then
        return "fail", 'Attempted to precompute grammar with no rules'
    end
    if error_code == kollos.err["NULLING_TERMINAL"] then
        local msgs = {}
        local events = lmw_g:events()
        for i = 1, #events, 2 do
            local event_type = events[i]
            if event_type == kollos.event["NULLING_TERMINAL"] then
                msgs[#msgs+1] =
                   string.format("Nullable symbol %q is also a terminal\n",
                       lmw_g:symbol_name(events[i+1])
                   )
            end
        end
        msgs[#msgs+1] = 'A terminal symbol cannot also be a nulling symbol'
        return "fail", table.concat(msgs)
    end
    if error_code == kollos.err["COUNTED_NULLABLE"] then
        local msgs = {}
        local events = lmw_g:events()
        for i = 1, #events, 2 do
            local event_type = events[i]
            if event_type == kollos.event["COUNTED_NULLABLE"] then
                msgs[#msgs+1] =
                   string.format("Nullable symbol %q is on RHS of counted rule\n",
                       lmw_g:symbol_name(events[i+1])
                   )
            end
        end
        msgs[#msgs+1] = 'Counted nullables confuse Marpa -- please rewrite the grammar'
        return "fail", table.concat(msgs)
    end
    if error_code == kollos.err["START_NOT_LHS"] then
        error( "Start symbol " .. lmw_g.start_name .. " not on LHS of any rule");
    end
    if error_code == kollos.err["NO_START_SYMBOL"] then
            error('No start symbol')
    end
    if error_code ~= kollos.err["UNPRODUCTIVE_START"] then
            return "fail", lmw_g:error_description()
    end
    return "ok"
END_OF_LUA

    if ($ok ne "ok") { Marpa::R3::exception( $result ); }

    return $precompute_error_code;

    } ## end if ( $precompute_error_code != $Marpa::R3::Error::NONE)

    # Above I went through the error events
    # Here I go through the events for situations where there was no
    # hard error returned from libmarpa
      my ($loop_rule_count) = 
      $thin_slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 's', $lmw_name );
        local grammar, lmw_name = ...
        local loop_rule_count = 0
        local lmw_g = grammar[lmw_name]
        local events = lmw_g:events()
        for i = 1, #events, 2 do
            local event_type = events[i]
            if event_type == kollos.event["LOOP_RULES"] then
                error(string.format(
                   "Unknown grammar precomputation event; type=%q"))
            end
            loop_rule_count = events[i+1]
        end
        return loop_rule_count
END_OF_LUA

    if ( $loop_rule_count ) {
        my @loop_rules =
            grep { $grammar_c->rule_is_loop($_) } ( 0 .. $grammar_c->highest_rule_id() );
        for my $rule_id (@loop_rules) {
            print {$trace_fh}
                'Cycle found involving rule: ',
                $tracer->brief_rule($rule_id), "\n"
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
        my $symbol_name = $tracer->symbol_name($symbol_id);
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


sub assign_G1_symbol {
    # $slg will be needed for the XSY's
    my ( $slg, $name, $options ) = @_;
    my $thin_slg = $slg->[Marpa::R3::Internal::Scanless::G::C];
    my $tracer = $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];

    my $grammar_c = $tracer->[Marpa::R3::Internal::Trace::G::C];
    my $symbol_id = $tracer->symbol_by_name($name);
    if ( defined $symbol_id ) {
        return $symbol_id;
    }

    ($symbol_id) =
      $thin_slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 's', $name );
    local g, symbol_name = ...
    local lmw_g = g.lmw_g1g
    local symbol_id = lmw_g:symbol_new(symbol_name)
    g.g1_symbols[symbol_id] = { id = symbol_id }
    return symbol_id
END_OF_LUA

    PROPERTY: for my $property ( sort keys %{$options} ) {
        if ( $property eq 'wsyid' ) {
            next PROPERTY;
        }
        if ( $property eq 'xsy' ) {
            my $xsy_name = $options->{$property};
            my $xsy = $slg->[Marpa::R3::Internal::Scanless::G::XSY_BY_NAME]->{$xsy_name};
            $tracer->[Marpa::R3::Internal::Trace::G::XSY_BY_ISYID]->[$symbol_id] =
                $xsy;
            next PROPERTY;
        }


        if ( $property eq 'terminal' ) {
            my $value = $options->{$property};

      $thin_slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 's', $symbol_id, ($value ? 1 : 0));
    local g, symbol_id, value = ...
    local g1g = g.lmw_g1g
    gig:symbol_is_terminal_set(symbol_id, value)
END_OF_LUA

            next PROPERTY;
        }
        if ( $property eq 'rank' ) {
            my $value = $options->{$property};
            Marpa::R3::exception(qq{Symbol "$name": rank must be an integer})
                if not Scalar::Util::looks_like_number($value)
                    or int($value) != $value;

      $thin_slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 's', $symbol_id, $value);
    local g, symbol_id, value = ...
    local g1g = g.lmw_g1g
    g1g:symbol_rank_set(symbol_id, value)
END_OF_LUA
            next PROPERTY;
        }

        Marpa::R3::exception(qq{Unknown symbol property "$property"});
    } ## end PROPERTY: for my $property ( keys %{$options} )

    return $symbol_id;

}

sub assign_L0_symbol {
    # $slg will be needed for the XSY's
    my ( $slg, $name, $options ) = @_;
    my $thin_slg = $slg->[Marpa::R3::Internal::Scanless::G::C];
    my $tracer = $slg->[Marpa::R3::Internal::Scanless::G::L0_TRACER];

    my $grammar_c = $tracer->[Marpa::R3::Internal::Trace::G::C];
    my $symbol_id = $tracer->symbol_by_name($name);
    if ( defined $symbol_id ) {
        return $symbol_id;
    }

    ($symbol_id) =
      $thin_slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 's', $name );
    local g, symbol_name = ...
    local lmw_g = g.lmw_l0g
    local symbol_id = lmw_g:symbol_new(symbol_name)
    g.l0_symbols[symbol_id] = { id = symbol_id }
    return symbol_id
END_OF_LUA

    PROPERTY: for my $property ( sort keys %{$options} ) {
        if ( $property eq 'wsyid' ) {
            next PROPERTY;
        }
        if ( $property eq 'xsy' ) {
            my $xsy_name = $options->{$property};
            my $xsy = $slg->[Marpa::R3::Internal::Scanless::G::XSY_BY_NAME]->{$xsy_name};
            $tracer->[Marpa::R3::Internal::Trace::G::XSY_BY_ISYID]->[$symbol_id] =
                $xsy;
            next PROPERTY;
        }
        if ( $property eq 'terminal' ) {
            my $value = $options->{$property};

      $thin_slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 's', $symbol_id, ($value ? 1 : 0));
    local g, symbol_id, value = ...
    local l0g = g.lmw_l0g
    l0g:symbol_is_terminal_set(symbol_id, value)
END_OF_LUA

            next PROPERTY;
        }
        if ( $property eq 'rank' ) {
            my $value = $options->{$property};
            Marpa::R3::exception(qq{Symbol "$name": rank must be an integer})
                if not Scalar::Util::looks_like_number($value)
                    or int($value) != $value;

      $thin_slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 's', $symbol_id, $value);
    local g, symbol_id, value = ...
    local l0g = g.lmw_l0g
    l0g:symbol_rank_set(symbol_id, value)
END_OF_LUA

            next PROPERTY;
        } ## end if ( $property eq 'rank' )
        Marpa::R3::exception(qq{Unknown symbol property "$property"});
    } ## end PROPERTY: for my $property ( keys %{$options} )

    return $symbol_id;

}

sub add_G1_user_rules {
    my ( $slg, $rules ) = @_;

    for my $rule (@{$rules}) {
        add_G1_user_rule( $slg, $rule );
    }

    return;

}

sub add_L0_user_rules {
    my ( $slg, $rules ) = @_;

    for my $rule (@{$rules}) {
        add_L0_user_rule( $slg, $rule );
    }

    return;

}

sub add_G1_user_rule {
    my ( $slg, $options ) = @_;
    my $thin_slg = $slg->[Marpa::R3::Internal::Scanless::G::C];

    my $tracer = $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];
    my $subgrammar = $tracer->[Marpa::R3::Internal::Trace::G::NAME];
    my $grammar_c = $tracer->[Marpa::R3::Internal::Trace::G::C];

    my ( $lhs_name, $rhs_names, $action, $blessing );
    my ( $min, $separator_name );
    my $rank;
    my $null_ranking;
    my $xbnf;
    my $proper_separation = 0;

  OPTION: for my $option ( keys %{$options} ) {
        my $value = $options->{$option};
        if ( $option eq 'xbnfid' ) {
            $xbnf = $slg->[
              Marpa::R3::Internal::Scanless::G::G1_XBNF_BY_NAME
            ]->{$value};
            next OPTION;
        }
        if ( $option eq 'rhs' )    { $rhs_names = $value; next OPTION }
        if ( $option eq 'lhs' )    { $lhs_name  = $value; next OPTION }
        if ( $option eq 'action' ) { $action    = $value; next OPTION }
        if ( $option eq 'rank' )   { $rank      = $value; next OPTION }
        if ( $option eq 'null_ranking' ) {
            $null_ranking = $value;
            next OPTION;
        }
        if ( $option eq 'min' ) { $min = $value; next OPTION }
        if ( $option eq 'separator' ) {
            $separator_name = $value;
            next OPTION;
        }
        if ( $option eq 'proper' ) {
            $proper_separation = $value;
            next OPTION;
        }
        Marpa::R3::exception("Unknown user rule option: $option");
    } ## end OPTION: for my $option ( keys %{$options} )


    $rhs_names //= [];

    my ($default_rank) =
          $thin_slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ), <<'END_OF_LUA', '');
    local grammar = ...
    return grammar.lmw_g1g:default_rank()
END_OF_LUA

    $rank //= $default_rank;
    $null_ranking //= 'low';

    # Is this is an ordinary, non-counted rule?
    my $is_ordinary_rule = scalar @{$rhs_names} == 0 || !defined $min;
    if ( defined $separator_name and $is_ordinary_rule ) {
        if ( defined $separator_name ) {
            Marpa::R3::exception(
                'separator defined for rule without repetitions');
        }
    } ## end if ( defined $separator_name and $is_ordinary_rule )

    my @rhs_ids = map {
                assign_G1_symbol( $slg, $_ )
        } @{$rhs_names};
    my $lhs_id = assign_G1_symbol( $slg, $lhs_name );

    my $base_rule_id;
    my $separator_id = -1;

    if ($is_ordinary_rule) {

        ($base_rule_id) =
          $thin_slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
            <<'END_OF_LUA', 'i', [ $lhs_id, @rhs_ids ] );
    local g, rule  = ...
    -- remove the test for nil or less than zero
    -- once refactoring is complete?
    kollos.throw = false
    local base_rule_id = g.lmw_g1g:rule_new(rule)
    -- print('base_rule_id: ', inspect(base_rule_id))
    kollos.throw = true
    if not base_rule_id or base_rule_id < 0 then return -1 end
    g.g1_rules[base_rule_id] = { id = base_rule_id }
    return base_rule_id
END_OF_LUA

    } ## end if ($is_ordinary_rule)
    else {
        Marpa::R3::exception('Only one rhs symbol allowed for counted rule')
          if scalar @{$rhs_names} != 1;

        # create the separator symbol, if we're using one
        if ( defined $separator_name ) {
            $separator_id = assign_G1_symbol( $slg, $separator_name );
        } ## end if ( defined $separator_name )

        # The original rule for a sequence rule is
        # not actually used in parsing,
        # but some of the rewritten sequence rules are its
        # semantic equivalents.

        my $arg_hash = {
            lhs => $lhs_id,
            rhs => $rhs_ids[0],
            separator => $separator_id,
            proper    => $proper_separation,
            min       => $min,
        };

      ($base_rule_id) = 
      $thin_slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 'i', $arg_hash);
    local g, arg_hash = ...
    -- print('arg_hash: ', inspect(arg_hash))
    arg_hash.proper = (arg_hash.proper ~= 0)
    kollos.throw = false
    base_rule_id = g.lmw_g1g:sequence_new(arg_hash)
    kollos.throw = true
    -- remove the test for nil or less than zero
    -- once refactoring is complete?
    if not base_rule_id or base_rule_id < 0 then return end
    g.g1_rules[base_rule_id] = { id = base_rule_id }
    return base_rule_id
END_OF_LUA

    }

    if ( not defined $base_rule_id or $base_rule_id < 0 ) {
        my $rule_description = rule_describe( $lhs_name, $rhs_names );
        my ( $error_code, $error_string ) = $grammar_c->error();
        $error_code //= -1;
        my $problem_description =
            $error_code == $Marpa::R3::Error::DUPLICATE_RULE
            ? 'Duplicate rule'
            : $error_string;
        Marpa::R3::exception("$problem_description: $rule_description");
    } ## end if ( not defined $base_rule_id or $base_rule_id < 0 )
    $tracer->[Marpa::R3::Internal::Trace::G::XBNF_BY_IRLID]->[$base_rule_id] = $xbnf;

    # Later on we will need per-IRL actions and masks
    $tracer->[Marpa::R3::Internal::Trace::G::ACTION_BY_IRLID]->[$base_rule_id] =
        $xbnf->[Marpa::R3::Internal::XBNF::ACTION_NAME];
    $tracer->[Marpa::R3::Internal::Trace::G::MASK_BY_IRLID]->[$base_rule_id] =
        $xbnf->[Marpa::R3::Internal::XBNF::MASK];

      $thin_slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 'iii',
        local grammar, rule_id, ranking_is_high, rank = ...
        local g1g = grammar.lmw_g1g
        g1g:rule_null_high_set(rule_id, ranking_is_high)
        g1g:rule_rank_set(rule_id, rank)
END_OF_LUA
            $base_rule_id, ( $null_ranking eq 'high' ? 1 : 0 ), $rank);

    return;

}

sub add_L0_user_rule {
    my ( $slg, $options ) = @_;
    my $thin_slg = $slg->[Marpa::R3::Internal::Scanless::G::C];

    my $tracer = $slg->[Marpa::R3::Internal::Scanless::G::L0_TRACER];
    my $grammar_c = $tracer->[Marpa::R3::Internal::Trace::G::C];

    my ( $lhs_name, $rhs_names, $action, $blessing );
    my ( $min, $separator_name );
    my $rank;
    my $null_ranking;
    my $xbnf;
    my $proper_separation = 0;

  OPTION: for my $option ( keys %{$options} ) {
        my $value = $options->{$option};
        if ( $option eq 'xbnfid' ) {
            $xbnf = $slg->[
              Marpa::R3::Internal::Scanless::G::L0_XBNF_BY_NAME
            ]->{$value};
            next OPTION;
        }
        if ( $option eq 'rhs' )    { $rhs_names = $value; next OPTION }
        if ( $option eq 'lhs' )    { $lhs_name  = $value; next OPTION }
        if ( $option eq 'action' ) { $action    = $value; next OPTION }
        if ( $option eq 'rank' )   { $rank      = $value; next OPTION }
        if ( $option eq 'null_ranking' ) {
            $null_ranking = $value;
            next OPTION;
        }
        if ( $option eq 'min' ) { $min = $value; next OPTION }
        if ( $option eq 'separator' ) {
            $separator_name = $value;
            next OPTION;
        }
        if ( $option eq 'proper' ) {
            $proper_separation = $value;
            next OPTION;
        }
        Marpa::R3::exception("Unknown user rule option: $option");
    } ## end OPTION: for my $option ( keys %{$options} )


    $rhs_names //= [];

    my ($default_rank) =
          $thin_slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ), <<'END_OF_LUA', '');
    local grammar = ...
    return grammar.lmw_l0g:default_rank()
END_OF_LUA
    $rank //= $default_rank;
    $null_ranking //= 'low';

    # Is this is an ordinary, non-counted rule?
    my $is_ordinary_rule = scalar @{$rhs_names} == 0 || !defined $min;
    if ( defined $separator_name and $is_ordinary_rule ) {
        if ( defined $separator_name ) {
            Marpa::R3::exception(
                'separator defined for rule without repetitions');
        }
    } ## end if ( defined $separator_name and $is_ordinary_rule )

    my @rhs_ids = map {
                assign_L0_symbol( $slg, $_ )
        } @{$rhs_names};
    my $lhs_id = assign_L0_symbol( $slg, $lhs_name );

    my $base_rule_id;
    my $separator_id = -1;

    if ($is_ordinary_rule) {

        ($base_rule_id) =
          $thin_slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
            <<'END_OF_LUA', 'i', [ $lhs_id, @rhs_ids ] );
    local g, rule  = ...
    -- remove the test for nil or less than zero
    -- once refactoring is complete?
    kollos.throw = false
    local base_rule_id = g.lmw_l0g:rule_new(rule)
    -- print('base_rule_id: ', inspect(base_rule_id))
    kollos.throw = true
    if not base_rule_id or base_rule_id < 0 then return -1 end
    g.l0_rules[base_rule_id] = { id = base_rule_id }
    return base_rule_id
END_OF_LUA

    } ## end if ($is_ordinary_rule)
    else {
        Marpa::R3::exception('Only one rhs symbol allowed for counted rule')
          if scalar @{$rhs_names} != 1;

        # create the separator symbol, if we're using one
        if ( defined $separator_name ) {
            $separator_id = assign_L0_symbol( $slg, $separator_name );
        } ## end if ( defined $separator_name )


        # The original rule for a sequence rule is
        # not actually used in parsing,
        # but some of the rewritten sequence rules are its
        # semantic equivalents.

        my $arg_hash = {
            lhs => $lhs_id,
            rhs => $rhs_ids[0],
            separator => $separator_id,
            proper    => $proper_separation,
            min       => $min,
        };

      ($base_rule_id) = 
      $thin_slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 'i', $arg_hash);
    local g, arg_hash = ...
    -- print('arg_hash: ', inspect(arg_hash))
    arg_hash.proper = (arg_hash.proper ~= 0)
    kollos.throw = false
    base_rule_id = g.lmw_l0g:sequence_new(arg_hash)
    kollos.throw = true
    -- remove the test for nil or less than zero
    -- once refactoring is complete?
    if not base_rule_id or base_rule_id < 0 then return end
    g.l0_rules[base_rule_id] = { id = base_rule_id }
    return base_rule_id
END_OF_LUA

    }

    if ( not defined $base_rule_id or $base_rule_id < 0 ) {
        my $rule_description = rule_describe( $lhs_name, $rhs_names );
        my ( $error_code, $error_string ) = $grammar_c->error();
        $error_code //= -1;
        my $problem_description =
            $error_code == $Marpa::R3::Error::DUPLICATE_RULE
            ? 'Duplicate rule'
            : $error_string;
        Marpa::R3::exception("$problem_description: $rule_description");
    } ## end if ( not defined $base_rule_id or $base_rule_id < 0 )
    $tracer->[Marpa::R3::Internal::Trace::G::XBNF_BY_IRLID]->[$base_rule_id] = $xbnf;

    # Later on we will need per-IRL actions and masks
    $tracer->[Marpa::R3::Internal::Trace::G::ACTION_BY_IRLID]->[$base_rule_id] =
        $xbnf->[Marpa::R3::Internal::XBNF::ACTION_NAME];
    $tracer->[Marpa::R3::Internal::Trace::G::MASK_BY_IRLID]->[$base_rule_id] =
        $xbnf->[Marpa::R3::Internal::XBNF::MASK];

      $thin_slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 'iii',
        local grammar, rule_id, ranking_is_high, rank = ...
        local l0g = grammar.lmw_l0g
        l0g:rule_null_high_set(rule_id, ranking_is_high)
        l0g:rule_rank_set(rule_id, rank)
END_OF_LUA
            $base_rule_id, ( $null_ranking eq 'high' ? 1 : 0 ), $rank);

    return;

}

sub rule_describe {
    my ( $lhs_name, $rhs_names ) = @_;
    # wrap symbol names with whitespaces allowed by SLIF
    $lhs_name = "<$lhs_name>" if $lhs_name =~ / /;
    return "$lhs_name -> " . ( join q{ }, map { / / ? "<$_>" : $_ } @{$rhs_names} );
} ## end sub rule_describe

sub Marpa::R3::Scanless::G::start_symbol_id {
    my ( $slg, $rule_id ) = @_;
    my $tracer = $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];
    return $tracer->start_symbol();
}

sub Marpa::R3::Scanless::G::rule_name {
    my ( $slg, $rule_id ) = @_;
    my $tracer = $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];
    return $tracer->rule_name($rule_id);
}

sub Marpa::R3::Scanless::G::rule_expand {
    my ( $slg, $rule_id ) = @_;
    my $tracer = $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];
    return $tracer->rule_expand($rule_id);
}

sub Marpa::R3::Scanless::G::l0_rule_expand {
    my ( $slg, $rule_id ) = @_;
    my $tracer = $slg->[Marpa::R3::Internal::Scanless::G::L0_TRACER];
    return $tracer->rule_expand($rule_id);
}

sub Marpa::R3::Scanless::G::symbol_name {
    my ( $slg, $symbol_id ) = @_;
    my $tracer = $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];
    return $tracer->symbol_name($symbol_id);
}

sub Marpa::R3::Scanless::G::l0_symbol_name {
    my ( $slg, $symbol_id ) = @_;
    my $tracer = $slg->[Marpa::R3::Internal::Scanless::G::L0_TRACER];
    return $tracer->symbol_name($symbol_id);
}

sub Marpa::R3::Scanless::G::symbol_display_form {
    my ( $slg, $symbol_id ) = @_;
    my $tracer = $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];
    return $tracer->symbol_in_display_form($symbol_id);
}

sub Marpa::R3::Scanless::G::l0_symbol_display_form {
    my ( $slg, $symbol_id ) = @_;
    my $tracer = $slg->[Marpa::R3::Internal::Scanless::G::L0_TRACER];
    return $tracer->symbol_in_display_form($symbol_id);
}

sub Marpa::R3::Scanless::G::symbol_dsl_form {
    my ( $slg, $symbol_id ) = @_;
    my $tracer = $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];
    return $tracer->symbol_dsl_form($symbol_id);
}

sub Marpa::R3::Scanless::G::l0_symbol_dsl_form {
    my ( $slg, $symbol_id ) = @_;
    my $tracer = $slg->[Marpa::R3::Internal::Scanless::G::L0_TRACER];
    return $tracer->symbol_dsl_form($symbol_id);
}

sub Marpa::R3::Scanless::G::rule_show
{
    my ( $slg, $rule_id ) = @_;
    my $tracer = $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];
    return slg_rule_show($tracer, $rule_id);
}

sub Marpa::R3::Scanless::G::l0_rule_show
{
    my ( $slg, $rule_id ) = @_;
    my $tracer = $slg->[Marpa::R3::Internal::Scanless::G::L0_TRACER];
    return slg_rule_show($tracer, $rule_id);
}

sub Marpa::R3::Scanless::G::call_by_tag {
    my ( $slg, $tag, $codestr, $sig, @args ) = @_;
    my $thin_slg = $slg->[Marpa::R3::Internal::Scanless::G::C];
    my @results = $thin_slg->call_by_tag($tag, $codestr, $sig, @args);
    return @results;
}

sub slg_rule_show {
    my ( $tracer, $rule_id ) = @_;
    my $subgrammar_c = $tracer->[Marpa::R3::Internal::Trace::G::C];
    my @symbol_ids   = $tracer->rule_expand($rule_id);
    return if not scalar @symbol_ids;
    my ( $lhs, @rhs ) =
        map { $tracer->symbol_in_display_form($_) } @symbol_ids;
    my $minimum    = $subgrammar_c->sequence_min($rule_id);
    my @quantifier = ();

    if ( defined $minimum ) {
        @quantifier = ( $minimum <= 0 ? q{*} : q{+} );
    }
    return join q{ }, $lhs, q{::=}, @rhs, @quantifier;
}

sub Marpa::R3::Scanless::G::show_rules {
    my ( $slg, $verbose ) = @_;
    $verbose //= 0;
    my $tracer = $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];
    return $tracer->show_rules($verbose);
}

sub Marpa::R3::Scanless::G::l0_show_rules {
    my ( $slg, $verbose ) = @_;
    $verbose //= 0;
    my $tracer = $slg->[Marpa::R3::Internal::Scanless::G::L0_TRACER];
    return $tracer->show_rules($verbose);
}

sub Marpa::R3::Scanless::G::show_symbols {
    my ( $slg, $verbose ) = @_;
    $verbose //= 0;
    my $tracer = $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];
    return $tracer->show_symbols($verbose);
}

sub Marpa::R3::Scanless::G::l0_show_symbols {
    my ( $slg, $verbose ) = @_;
    $verbose //= 0;
    my $tracer = $slg->[Marpa::R3::Internal::Scanless::G::L0_TRACER];
    return $tracer->show_symbols($verbose);
}

sub Marpa::R3::Scanless::G::symid_is_accessible {
    my ( $slg, $symid ) = @_;
    my $tracer = $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];
    my $grammar_c = $tracer->[Marpa::R3::Internal::Trace::G::C];
    return $grammar_c->symbol_is_accessible($symid)
}

sub Marpa::R3::Scanless::G::symid_is_productive {
    my ( $slg, $symid ) = @_;
    my $tracer = $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];
    my $grammar_c = $tracer->[Marpa::R3::Internal::Trace::G::C];
    return $grammar_c->symbol_is_productive($symid)
}

sub Marpa::R3::Scanless::G::symid_is_nulling {
    my ( $slg, $symid ) = @_;
    my $tracer = $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];
    my $grammar_c = $tracer->[Marpa::R3::Internal::Trace::G::C];
    return $grammar_c->symbol_is_nulling($symid)
}

sub Marpa::R3::Scanless::G::show_dotted_rule {
    my ( $slg, $rule_id, $dot_position ) = @_;
    my $tracer =  $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];
    my $grammar_c = $tracer->[Marpa::R3::Internal::Trace::G::C];
    my ( $lhs, @rhs ) =
    map { $tracer->symbol_in_display_form($_) } $tracer->rule_expand($rule_id);
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
}

sub Marpa::R3::Scanless::G::rule_ids {
    my ($slg) = @_;
    my $tracer = $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];
    return $tracer->rule_ids();
}

sub Marpa::R3::Scanless::G::l0_rule_ids {
    my ($slg) = @_;
    my $tracer = $slg->[Marpa::R3::Internal::Scanless::G::L0_TRACER];
    return $tracer->rule_ids();
}

sub Marpa::R3::Scanless::G::symbol_ids {
    my ($slg) = @_;
    my $tracer = $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];
    return $tracer->symbol_ids();
}

sub Marpa::R3::Scanless::G::l0_symbol_ids {
    my ($slg) = @_;
    my $tracer = $slg->[Marpa::R3::Internal::Scanless::G::L0_TRACER];
    return $tracer->symbol_ids();
}

# Internal methods, not to be documented

sub Marpa::R3::Scanless::G::rule_symbols {
    my ($slg, $irlid) = @_;
    my ($symbols) = $slg->call_by_tag(
    ('@' .__FILE__ . ':' . __LINE__),
    <<'END_OF_LUA', 'i>*', $irlid ) ;
    local grammar, irlid = ...
    local g1g = grammar.lmw_g1g
    return g1g:rule_symbols(irlid)
END_OF_LUA
    return $symbols;
}

sub Marpa::R3::Scanless::G::l0_rule_symbols {
    my ($slg, $irlid) = @_;
    my ($symbols) = $slg->call_by_tag(
    ('@' .__FILE__ . ':' . __LINE__),
    <<'END_OF_LUA', 'i>*', $irlid ) ;
    local grammar, irlid = ...
    local l0g = grammar.lmw_l0g
    return l0g:rule_symbols(irlid)
END_OF_LUA
    return $symbols;
}

sub Marpa::R3::Scanless::G::show_irls {
    my ($slg) = @_;
    my $tracer = $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];
    return $tracer->show_irls();
}

sub Marpa::R3::Scanless::G::show_isys {
    my ($slg) = @_;
    my $tracer = $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];
    return $tracer->show_isys();
}

sub Marpa::R3::Scanless::G::show_ahms {
    my ( $slg, $verbose ) = @_;
    my $g1_tracer = $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];
    return $g1_tracer->show_ahms($verbose);
}

1;

# vim: expandtab shiftwidth=4:
