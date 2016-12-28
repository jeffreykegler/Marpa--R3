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

package Marpa::R3::Scanless::R;

use 5.010001;
use strict;
use warnings;

use vars qw($VERSION $STRING_VERSION);
$VERSION        = '4.001_028';
$STRING_VERSION = $VERSION;
## no critic(BuiltinFunctions::ProhibitStringyEval)
$VERSION = eval $VERSION;
## use critic

package Marpa::R3::Internal::Scanless::R;

use Scalar::Util 'blessed';
use English qw( -no_match_vars );

our $PACKAGE = 'Marpa::R3::Scanless::R';

# Given a scanless
# recognizer and a symbol,
# return the start earley set
# and length
# of the last such symbol completed,
# undef if there was none.
sub Marpa::R3::Scanless::R::last_completed {
    my ( $slr, $symbol_name ) = @_;
    my $slg  = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
    my $g1_tracer =
        $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];
    my $symbol_id       = $g1_tracer->symbol_by_name($symbol_name);
    my ($start, $length) = $slr->exec_sig_name(
        'last_completed',
        'i>*',
        $symbol_id
        );
    return if not defined $start;
    return $start, $length;
} ## end sub Marpa::R3::Scanless::R::last_completed

# Returns most input stream span for symbol.
# If more than one ends at the same location,
# returns the longest.
# Returns under if there is no such span.
# Other failure is thrown.
sub Marpa::R3::Scanless::R::last_completed_span {
    my ( $slr, $symbol_name ) = @_;
    my ($g1_origin, $g1_span) = $slr->last_completed( $symbol_name );
    return if not defined $g1_origin;
    my ($start_input_location) = $slr->g1_location_to_span($g1_origin + 1);
    my @end_span = $slr->g1_location_to_span($g1_origin + $g1_span);
    return ($start_input_location, ($end_span[0]+$end_span[1])-$start_input_location);
}

sub Marpa::R3::Scanless::R::g1_input_span {
    my ( $slr, $start_earley_set, $length_in_parse_locations ) = @_;
    return
        if not defined $start_earley_set
        or not defined $length_in_parse_locations;

    my ($latest_earley_set) = $slr->exec_sig(<<'END_OF_LUA', '');
    local recce = ...
    return recce.lmw_g1r:latest_earley_set()
END_OF_LUA

    my $earley_set_for_first_position = $start_earley_set + 1;
    my $earley_set_for_last_position =
        $start_earley_set + $length_in_parse_locations;

    die 'Error in $slr->g1_literal(',
        "$start_earley_set, $length_in_parse_locations", '): ',
        "start ($start_earley_set) is at or after latest_earley_set ($latest_earley_set)"
        if $earley_set_for_first_position > $latest_earley_set;
    die 'Error in $slr->g1_literal(',
        "$start_earley_set, $length_in_parse_locations", '): ',
        "end ( $start_earley_set + $length_in_parse_locations ) is after latest_earley_set ($latest_earley_set)"
        if $earley_set_for_last_position > $latest_earley_set;

    my $thin_slr = $slr->[Marpa::R3::Internal::Scanless::R::SLR_C];
    my ($first_start_position) =
        $thin_slr->span($earley_set_for_first_position);
    my ( $last_start_position, $last_length ) =
        $thin_slr->span($earley_set_for_last_position);
    my $length_in_characters =
        ( $last_start_position + $last_length ) - $first_start_position;

    # Negative lengths are quite possible if the application has jumped around in
    # the input.
    $length_in_characters = 0 if $length_in_characters <= 0;
    return ( $first_start_position, $length_in_characters );

}

# Given a scanless recognizer and
# and two earley sets, return the input string
sub Marpa::R3::Scanless::R::g1_literal {
    my ( $slr, $start_earley_set, $length_in_parse_locations ) = @_;
    my $p_input = $slr->[Marpa::R3::Internal::Scanless::R::P_INPUT_STRING];
    my ($l0_start, $l0_length) = $slr->g1_input_span($start_earley_set, $length_in_parse_locations);
    die "Error in $slr->g1_literal($start_earley_set, $length_in_parse_locations)\n"
       if not defined $l0_start;
    return substr ${$p_input}, $l0_start, $l0_length;
} ## end sub Marpa::R3::Scanless::R::g1_literal

sub Marpa::R3::Scanless::R::g1_location_to_span {
    my ( $self, $g1_location ) = @_;
    my $thin_self = $self->[Marpa::R3::Internal::Scanless::R::SLR_C];
    return $thin_self->span($g1_location);
}

# Substring in terms of locations in the input stream
# This is the one users will be most interested in.
sub Marpa::R3::Scanless::R::literal {
    my ( $slr, $start_pos, $length ) = @_;
    my $thin_slr = $slr->[Marpa::R3::Internal::Scanless::R::SLR_C];
    return $thin_slr->substring( $start_pos, $length );
} ## end sub Marpa::R3::Scanless::R::literal

sub Marpa::R3::Internal::Scanless::meta_recce {
    my ($hash_args) = @_;
    state $meta_grammar = Marpa::R3::Internal::Scanless::meta_grammar();
    $hash_args->{grammar} = $meta_grammar;
    my $self = Marpa::R3::Scanless::R->new($hash_args);
    return $self;
} ## end sub Marpa::R3::Internal::Scanless::meta_recce

# For error messages, make it convenient to use an SLR
sub Marpa::R3::Scanless::R::rule_show {
    my ( $slr, $rule_id ) = @_;
    my $slg = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
    return $slg->rule_show($rule_id);
}

sub Marpa::R3::Scanless::R::new {
    my ( $class, @args ) = @_;

    my $slr = [];
    bless $slr, $class;

    # Set recognizer args to default
    $slr->[Marpa::R3::Internal::Scanless::R::EXHAUSTION_ACTION] = 'fatal';
    $slr->[Marpa::R3::Internal::Scanless::R::REJECTION_ACTION] = 'fatal';
    $slr->[Marpa::R3::Internal::Scanless::R::TRACE_TERMINALS] = 0;
    $slr->[Marpa::R3::Internal::Scanless::R::RANKING_METHOD] = 'none';
    $slr->[Marpa::R3::Internal::Scanless::R::MAX_PARSES]     = 0;
    $slr->[Marpa::R3::Internal::Scanless::R::EVENTS] = [];

    my ($flat_args, $error_message) = Marpa::R3::flatten_hash_args(\@args);
    Marpa::R3::exception( sprintf $error_message, '$slr->new' ) if not $flat_args;

    my $slg = $flat_args->{grammar};
    Marpa::R3::exception(
        qq{Marpa::R3::Scanless::R::new() called without a "grammar" argument}
    ) if not defined $slg;
    $slr->[Marpa::R3::Internal::Scanless::R::SLG] = $slg;
    delete $flat_args->{grammar};

    my $slg_class = 'Marpa::R3::Scanless::G';
    if ( not blessed $slg or not $slg->isa($slg_class) ) {
        my $ref_type = ref $slg;
        my $desc = $ref_type ? "a ref to $ref_type" : 'not a ref';
        Marpa::R3::exception(
            qq{'grammar' named argument to new() is $desc\n},
            "  It should be a ref to $slg_class\n" );
    } ## end if ( not blessed $slg or not $slg->isa($slg_class) )

    my $tracer =
        $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];
    $slr->[Marpa::R3::Internal::Scanless::R::TRACE_FILE_HANDLE] =
         $slg->[Marpa::R3::Internal::Scanless::G::TRACE_FILE_HANDLE];

    my $grammar_c = $tracer->[Marpa::R3::Internal::Trace::G::C];

    my $thin_slr = Marpa::R3::Thin::SLR->new(
        $slg->[Marpa::R3::Internal::Scanless::G::C]
    );
    $slr->[Marpa::R3::Internal::Scanless::R::SLR_C]      = $thin_slr;

    $slr->reset_evaluation();

    common_set( $slr, "new",  $flat_args );

    my $symbol_ids_by_event_name_and_type =
        $slg->[
        Marpa::R3::Internal::Scanless::G::SYMBOL_IDS_BY_EVENT_NAME_AND_TYPE];

    my $event_is_active_arg = $flat_args->{event_is_active} // {};
    if (ref $event_is_active_arg ne 'HASH') {
        Marpa::R3::exception( 'event_is_active named argument must be ref to hash' );
    }

    # Completion/nulled/prediction events are always initialized by
    # Libmarpa to 'on'.  So here we need to override that if and only
    # if we in fact want to initialize them to 'off'.

    # Events are already initialized as described by
    # the DSL.  Here we override that with the recce arg, if
    # necessary.

    EVENT: for my $event_name ( keys %{$event_is_active_arg} ) {

        my $is_active = $event_is_active_arg->{$event_name};

        my $symbol_ids =
            $symbol_ids_by_event_name_and_type->{$event_name}->{lexeme};
        $thin_slr->lexeme_event_activate( $_, $is_active )
            for @{$symbol_ids};
        my $lexer_rule_ids =
            $symbol_ids_by_event_name_and_type->{$event_name}->{discard};
        $thin_slr->discard_event_activate( $_, $is_active )
            for @{$lexer_rule_ids};

        $symbol_ids =
            $symbol_ids_by_event_name_and_type->{$event_name}->{completion}
            // [];
        for my $symbol_id ( @{ $symbol_ids } ) {
            $slr->exec_sig( <<'END_OF_LUA', 'ii', $symbol_id, $is_active );
            local recce, symbol_id, activate = ...
            recce.lmw_g1r:completion_symbol_activate(symbol_id, activate)
END_OF_LUA
        }

        $symbol_ids =
            $symbol_ids_by_event_name_and_type->{$event_name}->{nulled} // [];
        # $recce_c->nulled_symbol_activate( $_, $is_active ) for @{$symbol_ids};
        for my $symbol_id ( @{ $symbol_ids } ) {
            $slr->exec_sig( <<'END_OF_LUA', 'ii', $symbol_id, $is_active );
            local recce, symbol_id, activate = ...
            recce.lmw_g1r:nulled_symbol_activate(symbol_id, activate)
END_OF_LUA
        }

        $symbol_ids =
            $symbol_ids_by_event_name_and_type->{$event_name}->{prediction}
            // [];
        for my $symbol_id ( @{ $symbol_ids } ) {
            $slr->exec_sig( <<'END_OF_LUA', 'ii', $symbol_id, $is_active );
            local recce, symbol_id, activate = ...
            recce.lmw_g1r:prediction_symbol_activate(symbol_id, activate)
END_OF_LUA
        }

    } ## end EVENT: for my $event_name ( keys %{$event_is_active_arg} )

    if ( not $thin_slr->start_input() ) {
        my $error = $grammar_c->error();
        Marpa::R3::exception( 'Recognizer start of input failed: ', $error );
    }

    if ( $slr->[Marpa::R3::Internal::Scanless::R::TRACE_TERMINALS] > 1 ) {
        my $terminals_expected = $slr->terminals_expected();
        for my $terminal ( sort @{$terminals_expected} ) {

           # We may have set and reset the trace file handle during this method,
           # so we do not memoize its value, bjut get it directly
            say { $slr->[Marpa::R3::Internal::Scanless::R::TRACE_FILE_HANDLE] }
              qq{Expecting "$terminal" at earleme 0}
              or Marpa::R3::exception("Cannot print: $ERRNO");
        }
    }

    Marpa::R3::Internal::Scanless::convert_libmarpa_events($slr);

    $slr->exec_sig(<<'END_OF_LUA', '');
    local recce = ...

    recce.token_values = {}
    recce.token_is_undef = 1
    recce.token_values[recce.token_is_undef] = marpa.sv.undef()

    -- token is literal is a pseudo-index, and the SV undef
    -- is just a place holder
    recce.token_is_literal = 2
    recce.token_values[recce.token_is_literal] = marpa.sv.undef()

END_OF_LUA

    return $slr;
} ## end sub Marpa::R3::Scanless::R::new

sub Marpa::R3::Scanless::R::set {
    my ( $slr, @args ) = @_;
    my ($flat_args, $error_message) = Marpa::R3::flatten_hash_args(\@args);
    Marpa::R3::exception( sprintf $error_message, '$slr->set()' ) if not $flat_args;
    common_set( $slr, "set", $flat_args );
    return $slr;
} ## end sub Marpa::R3::Scanless::R::set

# The context flag indicates whether this set is called directly by the user
# or is for series reset or the constructor.  "Context" flags of this kind
# are much decried practice, and for good reason, but in this case
# I think it is justified.
# This logic is best kept all in one place, and a flag
# to trigger the minor differences needed by the various calling
# contexts is a small price to pay for that.
#
sub common_set {

    my ( $slr, $method, $flat_args ) = @_;

    # These recce args are allowed in all contexts
    state $common_recce_args = {
        map { ( $_, 1 ); }
          qw(trace_terminals trace_file_handle rejection exhaustion
          end max_parses too_many_earley_items
          trace_actions trace_values)
    };
    state $set_method_args = { map { ( $_, 1 ); } keys %{$common_recce_args} };
    state $new_method_args = {
        map { ( $_, 1 ); }
          qw(grammar semantics_package ranking_method event_is_active),
        keys %{$set_method_args}
    };
    state $series_restart_method_args =
      { map { ( $_, 1 ); } qw(semantics_package), keys %{$common_recce_args} };

    my $ok_args = $set_method_args;
    $ok_args = $new_method_args            if $method eq 'new';
    $ok_args = $series_restart_method_args if $method eq 'series_restart';
    my @bad_args = grep { not $ok_args->{$_} } keys %{$flat_args};
    if ( scalar @bad_args ) {
        Marpa::R3::exception(
            q{Bad named argument(s) to $slr->}
              . $method
              . q{() method: }
              . join q{ },
            @bad_args
        );
    } ## end if ( scalar @bad_args )

    if ( my $value = $flat_args->{'trace_file_handle'} ) {
        $slr->[Marpa::R3::Internal::Scanless::R::TRACE_FILE_HANDLE] = $value;
    }
    my $trace_file_handle =
      $slr->[Marpa::R3::Internal::Scanless::R::TRACE_FILE_HANDLE];

    if ( exists $flat_args->{'trace_terminals'} ) {
        my $value = $flat_args->{'trace_terminals'};
        my $normalized_value =
          Scalar::Util::looks_like_number($value) ? $value : 0;
        $slr->[Marpa::R3::Internal::Scanless::R::TRACE_TERMINALS] =
          $normalized_value;
        if ($normalized_value) {
            say {$trace_file_handle} qq{Setting trace_terminals option};
        }
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
        $slr->[Marpa::R3::Internal::Scanless::R::EXHAUSTION_ACTION] = $value;

    }

    if ( exists $flat_args->{'rejection'} ) {

        state $rejection_actions = { map { ( $_, 0 ) } qw(fatal event) };
        my $value = $flat_args->{'rejection'} // 'undefined';
        Marpa::R3::exception(
            qq{'rejection' named arg value is $value (should be one of },
            ( join q{, }, map { q{'} . $_ . q{'} } keys %{$rejection_actions} ),
            ')'
        ) if not exists $rejection_actions->{$value};
        $slr->[Marpa::R3::Internal::Scanless::R::REJECTION_ACTION] = $value;

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
        $slr->[Marpa::R3::Internal::Scanless::R::RANKING_METHOD] = $value;
    }

    if ( defined $flat_args->{'max_parses'} ) {
        my $value = $flat_args->{'max_parses'};
        $slr->[Marpa::R3::Internal::Scanless::R::MAX_PARSES] = $value;
    }

    if ( defined( my $value = $flat_args->{'semantics_package'} ) ) {
        $slr->[Marpa::R3::Internal::Scanless::R::SEMANTICS_PACKAGE] = $value;
    } ## end if ( defined( my $value = $flat_args->{'semantics_package'...}))

    if ( defined( my $value = $flat_args->{'trace_actions'} ) ) {
        $slr->[Marpa::R3::Internal::Scanless::R::TRACE_ACTIONS] = $value;
        if ($value) {
            say {$trace_file_handle} 'Setting trace_actions option'
              or Marpa::R3::exception("Cannot print: $ERRNO");
        }
    } ## end if ( defined( my $value = $flat_args->{'trace_actions'} ))

    if ( defined( my $value = $flat_args->{'trace_values'} ) ) {
        $slr->[Marpa::R3::Internal::Scanless::R::TRACE_VALUES] = $value;
        if ($value) {
            say {$trace_file_handle} "Setting trace_values option to $value"
              or Marpa::R3::exception("Cannot print: $ERRNO");
        }
    } ## end if ( defined( my $value = $flat_args->{'trace_values'} ) )

    if ( defined( my $value = $flat_args->{'too_many_earley_items'} ) ) {
        $slr->exec_sig(
            'local recce, value = ...; recce.lmw_g1r:earley_item_warning_threshold_set(value)',
            'i',
            $value
        );
    }

    if ( defined( my $value = $flat_args->{'end'} ) ) {

        # Not allowed once evaluation is started
        my ($has_bocage) = $slr->exec_sig(
            'local recce = ...; return recce.lmw_b', ''
        );
        if ( $has_bocage ) {
            Marpa::R3::exception(
                q{Cannot reset end once evaluation has started});
        }
        $slr->[Marpa::R3::Internal::Scanless::R::END_OF_PARSE] = $value;
    } ## end if ( defined( my $value = $arg_hash->{'end'} ) )

}

sub Marpa::R3::Scanless::R::thin {
    return $_[0]->[Marpa::R3::Internal::Scanless::R::SLR_C];
}

sub Marpa::R3::Scanless::R::trace {
    my ( $self, $level ) = @_;
    my $thin_slr = $self->[Marpa::R3::Internal::Scanless::R::SLR_C];
    $level //= 1;
    return $thin_slr->trace($level);
} ## end sub Marpa::R3::Scanless::R::trace

sub Marpa::R3::Scanless::R::error {
    my ($self) = @_;
    return $self->[Marpa::R3::Internal::Scanless::R::READ_STRING_ERROR];
}

sub Marpa::R3::Scanless::R::read {
    my ( $self, $p_string, $start_pos, $length ) = @_;

    $start_pos //= 0;
    $length    //= -1;
    Marpa::R3::exception(
        "Multiple read()'s tried on a scannerless recognizer\n",
        '  Currently the string cannot be changed once set'
    ) if defined $self->[Marpa::R3::Internal::Scanless::R::P_INPUT_STRING];

    if ( ( my $ref_type = ref $p_string ) ne 'SCALAR' ) {
        my $desc = $ref_type ? "a ref to $ref_type" : 'not a ref';
        Marpa::R3::exception(
            qq{Arg to Marpa::R3::Scanless::R::read() is $desc\n},
            '  It should be a ref to scalar' );
    } ## end if ( ( my $ref_type = ref $p_string ) ne 'SCALAR' )

    if ( not defined ${$p_string} ) {
        Marpa::R3::exception(
            qq{Arg to Marpa::R3::Scanless::R::read() is a ref to an undef\n},
            '  It should be a ref to a defined scalar' );
    } ## end if ( ( my $ref_type = ref $p_string ) ne 'SCALAR' )

    $self->[Marpa::R3::Internal::Scanless::R::P_INPUT_STRING] = $p_string;

    my $thin_slr = $self->[Marpa::R3::Internal::Scanless::R::SLR_C];
    my $trace_terminals = $self->[Marpa::R3::Internal::Scanless::R::TRACE_TERMINALS];
    $thin_slr->trace_terminals($trace_terminals) if $trace_terminals;

    $thin_slr->string_set($p_string);

    return 0 if @{ $self->[Marpa::R3::Internal::Scanless::R::EVENTS] };

    return $self->resume( $start_pos, $length );

} ## end sub Marpa::R3::Scanless::R::read

my $libmarpa_trace_event_handlers = {

    'g1 accepted lexeme' => sub {
        my ( $slr, $event ) = @_;
        my ( undef, undef, $lexeme_start_pos, $lexeme_end_pos, $g1_lexeme)
            = @{$event};
        my $thin_slr = $slr->[Marpa::R3::Internal::Scanless::R::SLR_C];
        my $raw_token_value =
            $thin_slr->substring( $lexeme_start_pos,
            $lexeme_end_pos - $lexeme_start_pos );
        my $trace_file_handle =
            $slr->[Marpa::R3::Internal::Scanless::R::TRACE_FILE_HANDLE];
        my $slg              = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
        my $tracer = $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];
        say {$trace_file_handle} qq{Accepted lexeme },
            input_range_describe( $slr, $lexeme_start_pos,
            $lexeme_end_pos - 1 ),
            q{ e}, $slr->g1_pos(),
            q{: },
            $tracer->symbol_in_display_form($g1_lexeme),
            qq{; value="$raw_token_value"}
            or Marpa::R3::exception("Could not say(): $ERRNO");
    },
    'rejected lexeme' => sub {
        my ( $slr, $event ) = @_;
        # Necessary to check, because this one can be returned when not tracing
        return if not $slr->[Marpa::R3::Internal::Scanless::R::TRACE_TERMINALS];
        my ( undef, undef, $lexeme_start_pos, $lexeme_end_pos, $g1_lexeme)
            = @{$event};
        my $thin_slr = $slr->[Marpa::R3::Internal::Scanless::R::SLR_C];
        my $raw_token_value =
            $thin_slr->substring( $lexeme_start_pos,
            $lexeme_end_pos - $lexeme_start_pos );
        my $trace_file_handle =
            $slr->[Marpa::R3::Internal::Scanless::R::TRACE_FILE_HANDLE];
        my $slg              = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
        my $tracer = $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];
        say {$trace_file_handle} qq{Rejected lexeme },
            input_range_describe( $slr, $lexeme_start_pos,
            $lexeme_end_pos - 1 ),
            q{: },
            $tracer->symbol_in_display_form($g1_lexeme),
            qq{; value="$raw_token_value"}
            or Marpa::R3::exception("Could not say(): $ERRNO");
    },
    'expected lexeme' => sub {
        my ( $slr, $event ) = @_;
        # Necessary to check, because this one can be returned when not tracing
        return if not $slr->[Marpa::R3::Internal::Scanless::R::TRACE_TERMINALS];
        my ( undef, undef, $position, $g1_lexeme, $assertion_id)
            = @{$event};
        my ( $line, $column ) = $slr->line_column($position);
        my $thin_slr = $slr->[Marpa::R3::Internal::Scanless::R::SLR_C];
        my $trace_file_handle =
            $slr->[Marpa::R3::Internal::Scanless::R::TRACE_FILE_HANDLE];
        my $slg              = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
        my $tracer = $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];
        say {$trace_file_handle} qq{Expected lexeme },
            $tracer->symbol_in_display_form($g1_lexeme),
            " at line $line, column $column; assertion ID = $assertion_id"
            or Marpa::R3::exception("Could not say(): $ERRNO");
    },
    'outprioritized lexeme' => sub {
        my ( $slr, $event ) = @_;
        my ( undef, undef, $lexeme_start_pos, $lexeme_end_pos, $g1_lexeme,
            $lexeme_priority, $required_priority )
            = @{$event};
        my $thin_slr = $slr->[Marpa::R3::Internal::Scanless::R::SLR_C];
        my $raw_token_value =
            $thin_slr->substring( $lexeme_start_pos,
            $lexeme_end_pos - $lexeme_start_pos );
        my $trace_file_handle =
            $slr->[Marpa::R3::Internal::Scanless::R::TRACE_FILE_HANDLE];
        my $slg              = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
        my $tracer = $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];
        say {$trace_file_handle}
            qq{Outprioritized lexeme },
            input_range_describe( $slr, $lexeme_start_pos,
            $lexeme_end_pos - 1 ),
            q{: },
            $tracer->symbol_in_display_form($g1_lexeme),
            qq{; value="$raw_token_value"; },
            qq{priority was $lexeme_priority, but $required_priority was required}
            or Marpa::R3::exception("Could not say(): $ERRNO");
    },
    'g1 duplicate lexeme' => sub {
        my ( $slr, $event ) = @_;
        my ( undef, undef, $lexeme_start_pos, $lexeme_end_pos, $g1_lexeme ) =
            @{$event};
        my $thin_slr = $slr->[Marpa::R3::Internal::Scanless::R::SLR_C];
        my $raw_token_value =
            $thin_slr->substring( $lexeme_start_pos,
            $lexeme_end_pos - $lexeme_start_pos );
        my $trace_file_handle =
            $slr->[Marpa::R3::Internal::Scanless::R::TRACE_FILE_HANDLE];
        my $slg              = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
        my $tracer = $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];
        say {$trace_file_handle}
            'Rejected as duplicate lexeme ',
            input_range_describe( $slr, $lexeme_start_pos,
            $lexeme_end_pos - 1 ),
            q{: },
            $tracer->symbol_in_display_form($g1_lexeme),
            qq{; value="$raw_token_value"}
            or Marpa::R3::exception("Could not say(): $ERRNO");
    },
    'g1 attempting lexeme' => sub {
        my ( $slr, $event ) = @_;
        my ( undef, undef, $lexeme_start_pos, $lexeme_end_pos, $g1_lexeme ) =
            @{$event};
        my $thin_slr = $slr->[Marpa::R3::Internal::Scanless::R::SLR_C];
        my $raw_token_value =
            $thin_slr->substring( $lexeme_start_pos,
            $lexeme_end_pos - $lexeme_start_pos );
        my $trace_file_handle =
            $slr->[Marpa::R3::Internal::Scanless::R::TRACE_FILE_HANDLE];
        my $slg              = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
        my $tracer = $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];
        say {$trace_file_handle}
            'Attempting to read lexeme ',
            input_range_describe( $slr, $lexeme_start_pos,
            $lexeme_end_pos - 1 ),
            q{ e}, $slr->g1_pos(),
            q{: },
            $tracer->symbol_in_display_form($g1_lexeme),
            qq{; value="$raw_token_value"}
            or Marpa::R3::exception("Could not say(): $ERRNO");
    },
    'lexer reading codepoint' => sub {
        my ( $slr, $event ) = @_;
        my ( undef, undef, $codepoint, $position, ) = @{$event};
        my $char      = chr $codepoint;
        my @char_desc = ();
        push @char_desc, qq{"$char"}
            if $char =~ /[\p{IsGraph}]/xms;
        push @char_desc, ( sprintf '0x%04x', $codepoint );
        my $char_desc = join q{ }, @char_desc;
        my ( $line, $column ) = $slr->line_column($position);
        my $trace_file_handle =
            $slr->[Marpa::R3::Internal::Scanless::R::TRACE_FILE_HANDLE];
        my $slg = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
        say {$trace_file_handle}
            qq{Reading codepoint $char_desc at line $line, column $column}
            or Marpa::R3::exception("Could not say(): $ERRNO");
    },
    'lexer accepted codepoint' => sub {
        my ( $slr, $event ) = @_;
        my ( undef, undef, $codepoint, $position, $token_id ) =
            @{$event};
        my $char      = chr $codepoint;
        my @char_desc = ();
        push @char_desc, qq{"$char"}
            if $char =~ /[\p{IsGraph}]/xms;
        push @char_desc, ( sprintf '0x%04x', $codepoint );
        my $char_desc = join q{ }, @char_desc;
        my $slg = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
        my $lex_tracer =
            $slg->[Marpa::R3::Internal::Scanless::G::L0_TRACER];
        my $symbol_in_display_form =
            $lex_tracer->symbol_in_display_form($token_id);
        my ( $line, $column ) = $slr->line_column($position);
        my $trace_file_handle =
            $slr->[Marpa::R3::Internal::Scanless::R::TRACE_FILE_HANDLE];
        say {$trace_file_handle}
            qq{Codepoint $char_desc accepted as $symbol_in_display_form at line $line, column $column}
            or Marpa::R3::exception("Could not say(): $ERRNO");
    },
    'lexer rejected codepoint' => sub {
        my ( $slr, $event ) = @_;
        my ( undef, undef, $codepoint, $position, $token_id ) =
            @{$event};
        my $char      = chr $codepoint;
        my @char_desc = ();
        push @char_desc, qq{"$char"}
            if $char =~ /[\p{IsGraph}]/xms;
        push @char_desc, ( sprintf '0x%04x', $codepoint );
        my $char_desc = join q{ }, @char_desc;
        my $slg = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
        my $lex_tracer =
            $slg->[Marpa::R3::Internal::Scanless::G::L0_TRACER];
        my $symbol_in_display_form =
            $lex_tracer->symbol_in_display_form($token_id);
        my ( $line, $column ) = $slr->line_column($position);
        my $trace_file_handle =
            $slr->[Marpa::R3::Internal::Scanless::R::TRACE_FILE_HANDLE];
        say {$trace_file_handle}
            qq{Codepoint $char_desc rejected as $symbol_in_display_form at line $line, column $column}
            or Marpa::R3::exception("Could not say(): $ERRNO");
    },
    'lexer restarted recognizer' => sub {
        my ( $slr, $event ) = @_;
        my ( undef, undef, $position ) = @{$event};
        my ( $line, $column ) = $slr->line_column($position);
        my $trace_file_handle =
            $slr->[Marpa::R3::Internal::Scanless::R::TRACE_FILE_HANDLE];
        my $slg = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
        say {$trace_file_handle}
            qq{Restarted recognizer at line $line, column $column}
            or Marpa::R3::exception("Could not say(): $ERRNO");
    },
    'discarded lexeme' => sub {
        my ( $slr, $event ) = @_;
        my ( undef, undef, $lex_rule_id, $start, $end ) =
            @{$event};
        my $slg = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
        my $tracer =
            $slg->[Marpa::R3::Internal::Scanless::G::L0_TRACER];
        my $grammar_c = $tracer->[Marpa::R3::Internal::Trace::G::C];
        my $rule_length = $grammar_c->rule_length($lex_rule_id);
        my @rhs_ids =
            map { $grammar_c->rule_rhs( $lex_rule_id, $_ ) }
            ( 0 .. $rule_length - 1 );
        my @rhs =
            map { $tracer->symbol_in_display_form($_) } @rhs_ids;
        my $trace_file_handle =
            $slr->[Marpa::R3::Internal::Scanless::R::TRACE_FILE_HANDLE];
        say {$trace_file_handle} qq{Discarded lexeme },
            input_range_describe( $slr, $start, $end - 1 ), q{: }, join q{ },
            @rhs
            or Marpa::R3::exception("Could not say(): $ERRNO");
    },
    'g1 pausing before lexeme' => sub {
        my ( $slr, $event ) = @_;
        my ( undef, undef, $start, $end, $lexeme_id ) = @{$event};
        my $slg = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
        my $tracer = $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];
        my $lexeme_name =
            $tracer->symbol_in_display_form($lexeme_id);
        my $trace_file_handle =
            $slr->[Marpa::R3::Internal::Scanless::R::TRACE_FILE_HANDLE];
        say {$trace_file_handle} 'Paused before lexeme ',
            input_range_describe( $slr, $start, $end - 1 ), ": $lexeme_name"
            or Marpa::R3::exception("Could not say(): $ERRNO");
    },
    'g1 pausing after lexeme' => sub {
        my ( $slr, $event ) = @_;
        my ( undef, undef, $start, $end, $lexeme_id ) = @{$event};
        my $slg = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
        my $tracer = $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];
        my $lexeme_name =
            $tracer->symbol_in_display_form($lexeme_id);
        my $trace_file_handle =
            $slr->[Marpa::R3::Internal::Scanless::R::TRACE_FILE_HANDLE];
        say {$trace_file_handle} 'Paused after lexeme ',
            input_range_describe( $slr, $start, $end - 1 ), ": $lexeme_name"
            or Marpa::R3::exception("Could not say(): $ERRNO");
    },
    'ignored lexeme' => sub {
        my ( $slr, $event ) = @_;
        my ( undef, undef, $g1_symbol_id, $start, $end ) = @{$event};
        my $slg = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
        my $tracer = $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];
        my $lexeme_name =
            $tracer->symbol_in_display_form($g1_symbol_id);
        my $trace_file_handle =
            $slr->[Marpa::R3::Internal::Scanless::R::TRACE_FILE_HANDLE];
        say {$trace_file_handle} 'Ignored lexeme ',
            input_range_describe( $slr, $start, $end - 1 ), ": $lexeme_name"
            or Marpa::R3::exception("Could not say(): $ERRNO");
    },
};

my $libmarpa_event_handlers = {
    q{!trace} => sub {
        my ( $slr, $event ) = @_;
        my $handler = $libmarpa_trace_event_handlers->{ $event->[1] };
        if ( defined $handler ) {
            $handler->( $slr, $event );
        }
        else {
            my $trace_file_handle =
                $slr->[Marpa::R3::Internal::Scanless::R::TRACE_FILE_HANDLE];
            say {$trace_file_handle} join q{ }, qw(Trace event:), @{$event}[1 .. $#{$event}]
                or Marpa::R3::exception("Could not say(): $ERRNO");
        } ## end else [ if ( defined $handler ) ]
        return 0;
    },

    'symbol completed' => sub {
        my ( $slr, $event ) = @_;
        my ( undef, $completed_symbol_id ) = @{$event};
        my $slg = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
        my $completion_event_by_id =
            $slg->[Marpa::R3::Internal::Scanless::G::COMPLETION_EVENT_BY_ID];
        push @{ $slr->[Marpa::R3::Internal::Scanless::R::EVENTS] },
            [ $completion_event_by_id->[$completed_symbol_id] ];
        return 1;
    },

    'symbol nulled' => sub {
        my ( $slr,  $event )            = @_;
        my ( undef, $nulled_symbol_id ) = @{$event};
        my $slg = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
        my $nulled_event_by_id =
            $slg->[Marpa::R3::Internal::Scanless::G::NULLED_EVENT_BY_ID];
        push @{ $slr->[Marpa::R3::Internal::Scanless::R::EVENTS] },
            [ $nulled_event_by_id->[$nulled_symbol_id] ];
        return 1;
    },

    'symbol predicted' => sub {
        my ( $slr, $event ) = @_;
        my ( undef, $predicted_symbol_id ) = @{$event};
        my $slg = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
        my $prediction_event_by_id =
            $slg->[Marpa::R3::Internal::Scanless::G::PREDICTION_EVENT_BY_ID];
        push @{ $slr->[Marpa::R3::Internal::Scanless::R::EVENTS] },
            [ $prediction_event_by_id->[$predicted_symbol_id] ];
        return 1;
    },

    # 'after lexeme' is same -- copied over below
    'before lexeme' => sub {
        my ( $slr,  $event )     = @_;
        my ( undef, $lexeme_id ) = @{$event};
        my $slg = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
        my $lexeme_event =
            $slg->[Marpa::R3::Internal::Scanless::G::LEXEME_EVENT_BY_ID]
            ->[$lexeme_id];
        push @{ $slr->[Marpa::R3::Internal::Scanless::R::EVENTS] },
            [$lexeme_event]
            if defined $lexeme_event;
        return 1;
    },

    'discarded lexeme' => sub {
        my ( $slr,  $event )     = @_;
        my ( undef, $rule_id, @other_data) = @{$event};
        my $slg = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
        my $lexeme_event =
            $slg->[Marpa::R3::Internal::Scanless::G::DISCARD_EVENT_BY_LEXER_RULE]
            ->[$rule_id];
        push @{ $slr->[Marpa::R3::Internal::Scanless::R::EVENTS] },
            [$lexeme_event, @other_data]
            if defined $lexeme_event;
        return 1;
    },

    'l0 earley item threshold exceeded' => sub {
        my ( $slr, $event ) = @_;
        my ( undef, $position, $yim_count) = @{$event};
        my $trace_file_handle =
            $slr->[Marpa::R3::Internal::Scanless::R::TRACE_FILE_HANDLE];
        say {$trace_file_handle}
            qq{L0 exceeded earley item threshold at pos $position: $yim_count Earley items}
            or Marpa::R3::exception("Could not say(): $ERRNO");
    },

    'g1 earley item threshold exceeded' => sub {
        my ( $slr, $event ) = @_;
        my ( undef, $position, $yim_count) = @{$event};
        my $trace_file_handle =
            $slr->[Marpa::R3::Internal::Scanless::R::TRACE_FILE_HANDLE];
        say {$trace_file_handle}
            qq{G1 exceeded earley item threshold at pos $position: $yim_count Earley items}
            or Marpa::R3::exception("Could not say(): $ERRNO");
    },

    'unknown g1 event' => sub {
        my ( $slr, $event ) = @_;
        Marpa::R3::exception( ( join q{ }, 'Unknown event:', @{$event} ) );
        return 0;
    },

    'no acceptable input' => sub {
        ## Do nothing at this point
        return 0;
    },
};

$libmarpa_event_handlers->{'after lexeme'} = $libmarpa_event_handlers->{'before lexeme'};

# Return 1 if internal scanning should pause
sub Marpa::R3::Internal::Scanless::convert_libmarpa_events {
    my ($slr)    = @_;
    my $pause    = 0;
    my @events = $slr->xs_events();
    EVENT: for my $event ( @events ) {
        my ($event_type) = @{$event};
        my $handler = $libmarpa_event_handlers->{$event_type};
        Marpa::R3::exception( ( join q{ }, 'Unknown event:', @{$event} ) )
            if not defined $handler;
        $pause = 1 if $handler->( $slr, $event );
    }
    return $pause;
} ## end sub Marpa::R3::Internal::Scanless::convert_libmarpa_events

sub Marpa::R3::Scanless::R::resume {
    my ( $slr, $start_pos, $length ) = @_;
    Marpa::R3::exception(
        "Attempt to resume an SLIF recce which has no string set\n",
        '  The string should be set first using read()'
        )
        if not defined $slr->[Marpa::R3::Internal::Scanless::R::P_INPUT_STRING];

    my $thin_slr = $slr->[Marpa::R3::Internal::Scanless::R::SLR_C];
    my $trace_terminals =
        $slr->[Marpa::R3::Internal::Scanless::R::TRACE_TERMINALS];

    $thin_slr->pos_set( $start_pos, $length );
    $slr->[Marpa::R3::Internal::Scanless::R::EVENTS] = [];
    my $slg = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
    my $thin_slg = $slg->[Marpa::R3::Internal::Scanless::G::C];

    OUTER_READ: while (1) {

        my $problem_code = $thin_slr->read();
        last OUTER_READ if not $problem_code;
        my $pause =
            Marpa::R3::Internal::Scanless::convert_libmarpa_events($slr);

        last OUTER_READ if $pause;
        next OUTER_READ if $problem_code eq 'event';
        next OUTER_READ if $problem_code eq 'trace';

        # The event on exhaustion only occurs if needed to provide a reason
        # to return -- if an exhausted reader would return anyway, there is
        # no exhaustion event.  For a reliable way to detect exhaustion,
        # use the $slr->exhausted() method.
        # The name of the exhausted event begins with a single quote, so
        # that it will not conflict with any user-defined event name.

        if (    $problem_code eq 'R1 exhausted before end'
            and $slr->[Marpa::R3::Internal::Scanless::R::EXHAUSTION_ACTION]
            eq 'event' )
        {
            push @{ $slr->[Marpa::R3::Internal::Scanless::R::EVENTS] },
                [q{'exhausted}];
            last OUTER_READ;
        } ## end if ( $problem_code eq 'R1 exhausted before end' and ...)

        if (    $problem_code eq 'no lexeme'
            and $slr->[Marpa::R3::Internal::Scanless::R::REJECTION_ACTION]
            eq 'event' )
        {
            push @{ $slr->[Marpa::R3::Internal::Scanless::R::EVENTS] },
                [q{'rejected}];
            last OUTER_READ;
        }

        if ( $problem_code eq 'invalid char' ) {
            my $codepoint = $thin_slr->codepoint();
            Marpa::R3::exception(
                qq{Failed at unacceptable character },
                character_describe( chr $codepoint ) );
        } ## end if ( $problem_code eq 'invalid char' )

        if ( $problem_code eq 'unregistered char' ) {

            state $op_alternative  = Marpa::R3::Thin::op('alternative');
            state $op_invalid_char = Marpa::R3::Thin::op('invalid_char');
            state $op_earleme_complete =
                Marpa::R3::Thin::op('earleme_complete');

            # Recover by registering character, if we can
            my $codepoint = $thin_slr->codepoint();
            # say STDERR ${$slr->[Marpa::R3::Internal::Scanless::R::P_INPUT_STRING]} ;
            # say STDERR
                # utf8::is_utf8( ${$slr->[Marpa::R3::Internal::Scanless::R::P_INPUT_STRING]} ) ? "is utf8" : "is NOT utf8";
            my $character =
                substr ${$slr->[Marpa::R3::Internal::Scanless::R::P_INPUT_STRING]},
                   $thin_slr->pos(), 1;
           # say STDERR join " ", "Character via string vs. codepoint:", $character, (ord $character), (chr $codepoint), $codepoint;
            my $character_class_table = $slg->[Marpa::R3::Internal::Scanless::G::CHARACTER_CLASS_TABLE];
            my @ops;
            for my $entry ( @{$character_class_table} ) {

                my ( $symbol_id, $re ) = @{$entry};
                if ( $character =~ $re ) {

                    if ( $trace_terminals >= 2 ) {
                        my $lex_tracer =
                          $slg
                          ->[Marpa::R3::Internal::Scanless::G::L0_TRACER
                          ];
                        my $trace_file_handle = $slr->[
                          Marpa::R3::Internal::Scanless::R::TRACE_FILE_HANDLE];
                        my $char_desc = sprintf 'U+%04x', $codepoint;
                        if ( $character =~ m/[[:graph:]]+/ ) {
                            $char_desc .= qq{ '$character'};
                        }
                        say {$trace_file_handle}
qq{Registering character $char_desc as symbol $symbol_id: },
                          $lex_tracer->symbol_in_display_form($symbol_id )
                          or Marpa::R3::exception("Could not say(): $ERRNO");
                    } ## end if ( $trace_terminals >= 2 )
                    push @ops, $op_alternative, $symbol_id, 1, 1;
                } ## end if ( $character =~ $re )
            } ## end for my $entry ( @{$character_class_table} )

            if ( not @ops ) {
                $thin_slr->char_register( $codepoint, $op_invalid_char );
                next OUTER_READ;
            }
            $thin_slr->char_register( $codepoint, @ops,
                $op_earleme_complete );
            next OUTER_READ;
        } ## end if ( $problem_code eq 'unregistered char' )

        return $slr->read_problem($problem_code);

    } ## end OUTER_READ: while (1)

    return $thin_slr->pos();
} ## end sub Marpa::R3::Scanless::R::resume

sub Marpa::R3::Scanless::R::events {
    my ($self) = @_;
    return $self->[Marpa::R3::Internal::Scanless::R::EVENTS];
}

sub Marpa::R3::Scanless::R::xs_events {
    my ($slr) = @_;
    my $thin_slr = $slr->[Marpa::R3::Internal::Scanless::R::SLR_C];
    my ($event_queue) = $thin_slr->exec_sig(<<'END_OF_LUA',
        recce = ...
        -- print(inspect(recce.event_queue))
        return recce.event_queue
END_OF_LUA
        '>0');
    return @{$event_queue};
}

## From here, recovery is a matter for the caller,
## if it is possible at all
sub Marpa::R3::Scanless::R::read_problem {
    my ( $slr, $problem_code ) = @_;

    die 'No problem_code in slr->read_problem()' if not $problem_code;

    my $thin_slr = $slr->[Marpa::R3::Internal::Scanless::R::SLR_C];
    my $slg  = $slr->[Marpa::R3::Internal::Scanless::R::SLG];

    my $lex_tracer =
        $slg->[Marpa::R3::Internal::Scanless::G::L0_TRACER];

    my $trace_file_handle =
        $slr->[Marpa::R3::Internal::Scanless::R::TRACE_FILE_HANDLE];

    my $g1_tracer =
        $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];

    my $thin_g1 = $g1_tracer->[Marpa::R3::Internal::Trace::G::C];

    my $pos      = $thin_slr->pos();
    my $problem_pos = $pos;
    my $p_string = $slr->[Marpa::R3::Internal::Scanless::R::P_INPUT_STRING];
    my $length_of_string = length ${$p_string};

    my $problem;
    my $stream_status = 0;
    my $g1_status = 0;
    CODE_TO_PROBLEM: {
        if ( $problem_code eq 'R1 exhausted before end' ) {
            my ($lexeme_start) = $thin_slr->lexeme_span();
            my ( $line, $column ) = $slr->line_column($lexeme_start);
            $problem =
                "Parse exhausted, but lexemes remain, at line $line, column $column\n";
            last CODE_TO_PROBLEM;
        }
        if ( $problem_code eq 'SLIF loop' ) {
            my ($lexeme_start) = $thin_slr->lexeme_span();
            my ( $line, $column ) = $slr->line_column($lexeme_start);
            $problem = "SLIF loops at line $line, column $column";
            last CODE_TO_PROBLEM;
        }
        if ( $problem_code eq 'no lexeme' ) {
            $problem_pos = $thin_slr->problem_pos();
            my ( $line, $column ) = $slr->line_column($problem_pos);
            my @details    = ();
            my %rejections = ();
            my @events     = $slr->xs_events();
            if ( scalar @events > 100 ) {
                my $omitted = scalar @events - 100;
                push @details,
                    "  [there were $omitted events -- only the first 100 were examined]";
                $#events = 99;
            } ## end if ( scalar @events > 100 )
          EVENT: for my $event (@events) {
                my (
                    $event_type,     $trace_event_type, $lexeme_start_pos,
                    $lexeme_end_pos, $g1_lexeme
                ) = @{$event};
                next EVENT
                  if $event_type ne q{'trace}
                  or $trace_event_type ne 'rejected lexeme';
                my $thin_slr = $slr->[Marpa::R3::Internal::Scanless::R::SLR_C];
                my $raw_token_value =
                  $thin_slr->substring( $lexeme_start_pos,
                    $lexeme_end_pos - $lexeme_start_pos );
                my $trace_file_handle =
                  $slr->[Marpa::R3::Internal::Scanless::R::TRACE_FILE_HANDLE];
                my $slg = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
                my $tracer =
                  $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];

       # Different internal symbols may have the same external "display form",
       # which in naive reporting logic would result in many identical messages,
       # confusing the user.  This logic makes sure that identical rejection
       # reports are not repeated, even when they have different causes
       # internally.

                $rejections{
                    $tracer->symbol_in_display_form( $g1_lexeme )
                      . qq{; value="$raw_token_value"; length = }
                      . ( $lexeme_end_pos - $lexeme_start_pos )
                } = 1;
            } ## end EVENT: for my $event (@events)
            my @problem    = ();
            my @rejections = keys %rejections;
            if ( scalar @rejections ) {
                my $rejection_count = scalar @rejections;
                push @problem,
                    "No lexemes accepted at line $line, column $column";
                REJECTION: for my $i ( 0 .. 5 ) {
                    my $rejection = $rejections[$i];
                    last REJECTION if not defined $rejection;
                    push @problem, qq{  Rejected lexeme #$i: $rejection};
                }
                if ( $rejection_count > 5 ) {
                    push @problem,
                        "  [there were $rejection_count rejection messages -- only the first 5 are shown]";
                }
                push @problem, @details;
            } ## end if ( scalar @rejections )
            else {
                push @problem,
                    "No lexeme found at line $line, column $column";
            }
            $problem = join "\n", @problem;
            last CODE_TO_PROBLEM;
        } ## end if ( $problem_code eq 'no lexeme' )
        $problem = 'Unrecognized problem code: ' . $problem_code;
    } ## end CODE_TO_PROBLEM:

    my $desc;
    DESC: {
        if ( defined $problem ) {
            $desc .= "$problem";
        }
        if ( $stream_status == -1 ) {
            $desc = 'Lexer: Character rejected';
            last DESC;
        }
        if ( $stream_status == -2 ) {
            $desc = 'Lexer: Unregistered character';
            last DESC;
        }

        # -5 indicates success, in which case we should never have called this subroutine.
        if ( $stream_status == -3 || $stream_status == -5 ) {
            $desc = 'Unexpected return value from lexer: Parse exhausted';
            last DESC;
        }
        if ($g1_status) {
            my $true_event_count = $thin_g1->event_count();
            EVENT:
            for (
                my $event_ix = 0;
                $event_ix < $true_event_count;
                $event_ix++
                )
            {
                my ( $event_type, $value ) =
                    $thin_g1->event($event_ix);
                if ( $event_type eq 'MARPA_EVENT_EARLEY_ITEM_THRESHOLD' ) {
                    $desc = join "\n", $desc,
                        "G1 grammar: Earley item count ($value) exceeds warning threshold\n";
                    next EVENT;
                }
                if ( $event_type eq 'MARPA_EVENT_SYMBOL_EXPECTED' ) {
                    $desc = join "\n", $desc,
                        "Unexpected G1 grammar event: $event_type "
                        . $g1_tracer->symbol_name($value);
                    next EVENT;
                } ## end if ( $event_type eq 'MARPA_EVENT_SYMBOL_EXPECTED' )
                if ( $event_type eq 'MARPA_EVENT_EXHAUSTED' ) {
                    $desc = join "\n", $desc, 'Parse exhausted';
                    next EVENT;
                }
                Marpa::R3::exception( $desc, "\n",
                    qq{Unknown event: "$event_type"; event value = $value\n}
                );
            } ## end EVENT: for ( my $event_ix = 0; $event_ix < ...)
            last DESC;
        } ## end if ($g1_status)
        if ( $g1_status < 0 ) {
            $desc = 'G1 error: ' . $thin_g1->error();
            chomp $desc;
            last DESC;
        }
    } ## end DESC:
    my $read_string_error;
    if ( $problem_pos < $length_of_string) {
        my $char = substr ${$p_string}, $problem_pos, 1;
        my $char_desc = character_describe($char);
        my ( $line, $column ) = $thin_slr->line_column($problem_pos);
        my $prefix =
            $problem_pos >= 50
            ? ( substr ${$p_string}, $problem_pos - 50, 50 )
            : ( substr ${$p_string}, 0, $problem_pos );

        $read_string_error =
              "Error in SLIF parse: $desc\n"
            . '* String before error: '
            . Marpa::R3::escape_string( $prefix, -50 ) . "\n"
            . "* The error was at line $line, column $column, and at character $char_desc, ...\n"
            . '* here: '
            . Marpa::R3::escape_string( ( substr ${$p_string}, $problem_pos, 50 ),
            50 )
            . "\n";
    } ## end elsif ( $problem_pos < $length_of_string )
    else {
        $read_string_error =
              "Error in SLIF parse: $desc\n"
            . "* Error was at end of input\n"
            . '* String before error: '
            . Marpa::R3::escape_string( ${$p_string}, -50 ) . "\n";
    } ## end else [ if ($g1_status) ]

    $slr->[Marpa::R3::Internal::Scanless::R::READ_STRING_ERROR] =
        $read_string_error;
    Marpa::R3::exception($read_string_error);

    # Never reached
    # Fall through to return undef
    return;

} ## end sub Marpa::R3::Scanless::R::read_problem

sub character_describe {
    my ($char) = @_;
    my $text = sprintf '0x%04x', ord $char;
    $text .= q{ }
        . (
        $char =~ m/[[:graph:]]/xms
        ? qq{'$char'}
        : '(non-graphic character)'
        );
    return $text;
} ## end sub character_describe

my @escape_by_ord = ();
$escape_by_ord[ ord q{\\} ] = q{\\\\};
$escape_by_ord[ ord eval qq{"$_"} ] = $_
    for "\\t", "\\r", "\\f", "\\b", "\\a", "\\e";
$escape_by_ord[0xa] = '\\n';
$escape_by_ord[$_] //= chr $_ for 32 .. 126;
$escape_by_ord[$_] //= sprintf( "\\x%02x", $_ ) for 0 .. 255;

# This and the sister routine for "forward strings"
# should replace the other string "escaping" subroutine
sub Marpa::R3::Internal::Scanless::reversed_input_escape {
    my ( $p_input, $base_pos, $length ) = @_;
    my @escaped_chars = ();
    my $pos           =  $base_pos - 1 ;

    my $trailing_spaces = 0;
    CHAR: while ( $pos > 0 ) {
        last CHAR if substr ${$p_input}, $pos, 1 ne q{ };
        $trailing_spaces++;
        $pos--;
    }
    my $length_so_far = $trailing_spaces * 2;

    CHAR: while ( $pos >= 0 ) {
        my $char         = substr ${$p_input}, $pos, 1;
        my $ord          = ord $char;
        my $escaped_char = $escape_by_ord[$ord]
            // sprintf( "\\x{%04x}", $ord );
        my $char_length = length $escaped_char;
        $length_so_far += $char_length;
        last CHAR if $length_so_far > $length;
        push @escaped_chars, $escaped_char;
        $pos--;
    } ## end CHAR: while ( $pos > 0 and $pos < $end_of_input )
    @escaped_chars = reverse @escaped_chars;
    push @escaped_chars, '\\s' for 1 .. $trailing_spaces;
    return join q{}, @escaped_chars;
} ## end sub Marpa::R3::Internal::Scanless::input_escape

sub Marpa::R3::Internal::Scanless::input_escape {
    my ( $p_input, $base_pos, $length ) = @_;
    my @escaped_chars = ();
    my $pos           = $base_pos;

    my $length_so_far = 0;

    my $end_of_input = length ${$p_input};
    CHAR: while ( $pos < $end_of_input ) {
        my $char         = substr ${$p_input}, $pos, 1;
        my $ord          = ord $char;
        my $escaped_char = $escape_by_ord[$ord]
            // sprintf( "\\x{%04x}", $ord );
        my $char_length = length $escaped_char;
        $length_so_far += $char_length;
        last CHAR if $length_so_far > $length;
        push @escaped_chars, $escaped_char;
        $pos++;
    } ## end CHAR: while ( $pos < $end_of_input )

    my $trailing_spaces = 0;
    TRAILING_SPACE:
    for (
        my $first_non_space_ix = $#escaped_chars;
        $first_non_space_ix >= 0;
        $first_non_space_ix--
        )
    {
        last TRAILING_SPACE if $escaped_chars[$first_non_space_ix] ne q{ };
        pop @escaped_chars;
        $trailing_spaces++;
    } ## end TRAILING_SPACE: for ( my $first_non_space_ix = $#escaped_chars; ...)
    if ($trailing_spaces) {
        $length_so_far -= $trailing_spaces;
        TRAILING_SPACE: while ( $trailing_spaces-- > 0 ) {
            $length_so_far += 2;
            last TRAILING_SPACE if $length_so_far > $length;
            push @escaped_chars, '\\s';
        }
    } ## end if ($trailing_spaces)
    return join q{}, @escaped_chars;
} ## end sub Marpa::R3::Internal::Scanless::input_escape

sub Marpa::R3::Scanless::R::ambiguity_metric {
    my ($slr) = @_;
    $slr->ordering_get();

    my ($metric) = $slr->exec( <<'END__OF_LUA' );
    local recce = ...
    local order = recce.lmw_o
    if not order then return 0 end
    return order:ambiguity_metric()
END__OF_LUA

    return $metric;
} ## end sub Marpa::R3::Scanless::R::ambiguity_metric

sub Marpa::R3::Scanless::R::ambiguous {
    my ($slr) = @_;
    local $Marpa::R3::Context::slr = $slr;
    my $ambiguity_metric = $slr->ambiguity_metric();
    return q{No parse} if $ambiguity_metric <= 0;
    return q{} if $ambiguity_metric == 1;
    my $asf = Marpa::R3::ASF->new( { slr => $slr } );
    die 'Could not create ASF' if not defined $asf;
    my $ambiguities = Marpa::R3::Internal::ASF::ambiguities($asf);
    my @ambiguities = grep {defined} @{$ambiguities}[ 0 .. 1 ];
    return Marpa::R3::Internal::ASF::ambiguities_show( $asf, \@ambiguities );
} ## end sub Marpa::R3::Scanless::R::ambiguous

# This is a Marpa Scanless::G method, but is included in this
# file because internally it is all about the recognizer.
sub Marpa::R3::Scanless::G::parse {
    my ( $slg, $input_ref, $arg1, @more_args ) = @_;
    if ( not defined $input_ref or ref $input_ref ne 'SCALAR' ) {
        Marpa::R3::exception(
            q{$slr->parse(): first argument must be a ref to string});
    }
    my @recce_args = ( { grammar => $slg } );
    my @semantics_package_arg = ();
    DO_ARG1: {
        last if not defined $arg1;
        my $reftype = ref $arg1;
        if ( $reftype eq 'HASH' ) {

            # if second arg is ref to hash, it is the first set
            # of named args for
            # the recognizer
            push @recce_args, $arg1;
            last DO_ARG1;
        } ## end if ( $reftype eq 'HASH' )
        if ( $reftype eq q{} ) {

            # if second arg is a string, it is the semantic package
            push @semantics_package_arg, { semantics_package => $arg1 };
        }
        if ( ref $arg1 and ref $input_ref ne 'HASH' ) {
            Marpa::R3::exception(
                q{$slr->parse(): second argument must be a package name or a ref to HASH}
            );
        }
    } ## end DO_ARG1:
    if ( grep { ref $_ ne 'HASH' } @more_args ) {
        Marpa::R3::exception(
            q{$slr->parse(): third and later arguments must be ref to HASH});
    }
    my $slr = Marpa::R3::Scanless::R->new( @recce_args, @more_args,
        @semantics_package_arg );
    my $input_length = ${$input_ref};
    my $length_read  = $slr->read($input_ref);
    if ( $length_read != length $input_length ) {
        die 'read in $slr->parse() ended prematurely', "\n",
            "  The input length is $input_length\n",
            "  The length read is $length_read\n",
            "  The cause may be an event\n",
            "  The $slr->parse() method does not allow parses to trigger events";
    } ## end if ( $length_read != length $input_length )
    if ( my $ambiguous_status = $slr->ambiguous() ) {
        Marpa::R3::exception( "Parse of the input is ambiguous\n",
            $ambiguous_status );
    }

    my $value_ref = $slr->value();
    Marpa::R3::exception(
        '$slr->parse() read the input, but there was no parse', "\n" )
        if not $value_ref;

    return $value_ref;
} ## end sub Marpa::R3::Scanless::G::parse

sub Marpa::R3::Scanless::R::series_restart {
    my ( $slr , @args ) = @_;

    $slr->[Marpa::R3::Internal::Scanless::R::EXHAUSTION_ACTION] = 'fatal';
    $slr->[Marpa::R3::Internal::Scanless::R::REJECTION_ACTION] = 'fatal';

    $slr->reset_evaluation();

    my ($flat_args, $error_message) = Marpa::R3::flatten_hash_args(\@args);
    Marpa::R3::exception( sprintf $error_message, '$slr->series_restart()' ) if not $flat_args;
    common_set($slr, "series_restart", $flat_args );
    return 1;
}

# For the non-legacy case,
# I reset the ordering, forcing it to be recalculated
# for each parse series.
# But I do not actually allow the ranking method to
# be changed once a parse is created.
# Since I am stabilizing Marpa::R3, the "fix" should
# probably be to save the overhead, rather than
# to allow 'ranking_method' to be changed.
#
# But for now I will do nothing.
# JK -- Mon Nov 24 17:35:24 PST 2014
#
# In Marpa::R3, the ranking_method can only be set in
# the recce constructor, so I should stop resetting the
# ordering
# JK -- Sun May  1 19:18:08 PDT 2016
#
sub Marpa::R3::Scanless::R::reset_evaluation {
    my ($slr) = @_;
    $slr->[Marpa::R3::Internal::Scanless::R::NO_PARSE]              = undef;
    $slr->[Marpa::R3::Internal::Scanless::R::SEMANTICS_PACKAGE]       = undef;
    $slr->[Marpa::R3::Internal::Scanless::R::NULL_VALUES]           = undef;

    $slr->[Marpa::R3::Internal::Scanless::R::REGISTRATIONS]         = undef;
    $slr->[Marpa::R3::Internal::Scanless::R::CLOSURE_BY_SYMBOL_ID] = undef;
    $slr->[Marpa::R3::Internal::Scanless::R::CLOSURE_BY_RULE_ID]   = undef;

    $slr->[Marpa::R3::Internal::Scanless::R::TREE_MODE] = undef;

    $slr->exec_name('valuation_reset');
    return;
}

# Given a list of G1 locations, return the minimum span in the input string
# that includes them all
# Caller must ensure that there is an input, which is not the case
# when the parse is initialized.
sub g1_locations_to_input_range {
    my ( $slr, @g1_locations ) = @_;
    my $thin_slr = $slr->[Marpa::R3::Internal::Scanless::R::SLR_C];
    my $first_pos = $thin_slr->input_length();
    my $last_pos = 0;
    for my $g1_location (@g1_locations) {
        my ( $input_start, $input_length ) = $thin_slr->span($g1_location);
        my $input_end = $input_length ? $input_start + $input_length - 1 : $input_start;
        $first_pos = $input_start if $input_start < $first_pos;
        $last_pos = $input_end if $input_end > $last_pos;
    } ## end for my $g1_location (@other_g1_locations)
    return ($first_pos, $last_pos);
}

sub input_range_describe {
    my ( $slr, $first_pos,  $last_pos )     = @_;
    my ( $first_line, $first_column ) = $slr->line_column($first_pos);
    my ( $last_line,  $last_column )  = $slr->line_column($last_pos);
    if ( $first_line == $last_line ) {
        return join q{}, 'L', $first_line, 'c', $first_column
            if $first_column == $last_column;
        return join q{}, 'L', $first_line, 'c', $first_column, '-',
            $last_column;
    } ## end if ( $first_line == $last_line )
    return join q{}, 'L', $first_line, 'c', $first_column, '-L', $last_line,
        'c', $last_column;
} ## end sub input_range_describe

sub Marpa::R3::Scanless::R::show_progress {
    my ( $slr, $start_ordinal, $end_ordinal ) = @_;
    my $slg = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
    my $tracer  = $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];
    my $grammar_c = $tracer->[Marpa::R3::Internal::Trace::G::C];

    my ($last_ordinal) = $slr->exec_sig(
            'local recce = ...; return recce.lmw_g1r:latest_earley_set()',
            '');

    if ( not defined $start_ordinal ) {
        $start_ordinal = $last_ordinal;
    }
    if ( $start_ordinal < 0 ) {
        $start_ordinal += $last_ordinal + 1;
    }
    else {
        if ( $start_ordinal < 0 or $start_ordinal > $last_ordinal ) {
            return
                "Marpa::R3::Scanless::R::show_progress start index is $start_ordinal, "
                . "must be in range 0-$last_ordinal";
        }
    } ## end else [ if ( $start_ordinal < 0 ) ]

    if ( not defined $end_ordinal ) {
        $end_ordinal = $start_ordinal;
    }
    else {
        my $end_ordinal_argument = $end_ordinal;
        if ( $end_ordinal < 0 ) {
            $end_ordinal += $last_ordinal + 1;
        }
        if ( $end_ordinal < 0 ) {
            return
                "Marpa::R3::Scanless::R::show_progress end index is $end_ordinal_argument, "
                . sprintf ' must be in range %d-%d', -( $last_ordinal + 1 ),
                $last_ordinal;
        } ## end if ( $end_ordinal < 0 )
    } ## end else [ if ( not defined $end_ordinal ) ]

    my $text = q{};
    for my $current_ordinal ( $start_ordinal .. $end_ordinal ) {
        my $current_earleme     = $slr->earleme($current_ordinal);
        my %by_rule_by_position = ();
        for my $progress_item ( @{ $slr->progress($current_ordinal) } ) {
            my ( $rule_id, $position, $origin ) = @{$progress_item};
            if ( $position < 0 ) {
                $position = $grammar_c->rule_length($rule_id);
            }
            $by_rule_by_position{$rule_id}->{$position}->{$origin}++;
        } ## end for my $progress_item ( @{ $recce->progress($current_ordinal...)})

        for my $rule_id ( sort { $a <=> $b } keys %by_rule_by_position ) {
            my $by_position = $by_rule_by_position{$rule_id};
            for my $position ( sort { $a <=> $b } keys %{$by_position} ) {
                my $raw_origins   = $by_position->{$position};
                my @origins       = sort { $a <=> $b } keys %{$raw_origins};
                my $origins_count = scalar @origins;
                my $origin_desc;
                if ( $origins_count <= 3 ) {
                    $origin_desc = join q{,}, @origins;
                }
                else {
                    $origin_desc = $origins[0] . q{...} . $origins[-1];
                }

                my $rhs_length = $grammar_c->rule_length($rule_id);
                my @item_text;

                if ( $position >= $rhs_length ) {
                    push @item_text, "F$rule_id";
                }
                elsif ($position) {
                    push @item_text, "R$rule_id:$position";
                }
                else {
                    push @item_text, "P$rule_id";
                }
                push @item_text, "x$origins_count" if $origins_count > 1;
                push @item_text, q{@} . $origin_desc . q{-} . $current_earleme;

                if ( $current_earleme > 0 ) {
                    my $input_range = input_range_describe(
                        $slr,
                        g1_locations_to_input_range(
                            $slr, $current_earleme, @origins
                        )
                    );
                    push @item_text, $input_range;
                }  else {
                    push @item_text, 'L0c0';
                }

                push @item_text,
                    $slg->show_dotted_rule( $rule_id, $position );
                $text .= ( join q{ }, @item_text ) . "\n";
            } ## end for my $position ( sort { $a <=> $b } keys %{...})
        } ## end for my $rule_id ( sort { $a <=> $b } keys ...)

    } ## end for my $current_ordinal ( $start_ordinal .. $end_ordinal)
    return $text;
}

sub Marpa::R3::Scanless::R::progress {
    my ( $slr, $ordinal_arg ) = @_;
    my ($result) = $slr->exec_sig_name(
        'progress',
        'i>0',
        ($ordinal_arg // -1)
        );
    return $result;
}

sub Marpa::R3::Scanless::R::terminals_expected {
    my ($slr)      = @_;
    my $slg        = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
    my ($terminals_expected) = $slr->exec_sig(<<'END_OF_LUA', '>0');
    local recce = ...
    local terminals_expected = recce.lmw_g1r:terminals_expected()
    return terminals_expected
END_OF_LUA

    return [ map { $slg->symbol_name($_) } @{$terminals_expected} ];
}

sub Marpa::R3::Scanless::R::exhausted {
    my ($slr) = @_;
    my ($is_exhausted) = $slr->exec_sig(<<'END_OF_LUA', '');
    local recce = ...
    local is_exhausted = recce.lmw_g1r:is_exhausted()
    return is_exhausted
END_OF_LUA
    return $is_exhausted;
}

# Latest and current G1 location are the same
sub Marpa::R3::Scanless::R::g1_pos {
    my ($slr) = @_;
    my ($latest_earley_set) = $slr->exec_sig(<<'END_OF_LUA', '');
    local recce = ...
    local latest_earley_set = recce.lmw_g1r:latest_earley_set()
    return latest_earley_set
END_OF_LUA
    return $latest_earley_set;
}

sub Marpa::R3::Scanless::R::current_earleme {
    my ($slr) = @_;
    my ($current_earleme) = $slr->exec_sig(<<'END_OF_LUA', '');
    local recce = ...
    local current_earleme = recce.lmw_g1r:current_earleme()
    return current_earleme
END_OF_LUA
    return $current_earleme;
}

# Not documented, I think
sub Marpa::R3::Scanless::R::furthest_earleme {
    my ($slr) = @_;
    my ($furthest_earleme) = $slr->exec_sig(
        <<'END_OF_LUA', '');
    local recce = ...
    local furthest_earleme = recce.lmw_g1r:furthest_earleme()
    return furthest_earleme
END_OF_LUA
    return $furthest_earleme;
}

sub Marpa::R3::Scanless::R::earleme {
    my ( $slr, $earley_set_id ) = @_;
    my ($earleme) = $slr->exec_sig(
        <<'END_OF_LUA', 'i', $earley_set_id);
    local recce, earley_set_id = ...
    local earleme = recce.lmw_g1r:earleme(earley_set_id)
    return earleme
END_OF_LUA
    return $earleme;
}

sub Marpa::R3::Scanless::R::lexeme_alternative {
    my ( $slr, $symbol_name, @value ) = @_;
    my $thin_slr = $slr->[Marpa::R3::Internal::Scanless::R::SLR_C];

    Marpa::R3::exception(
        "slr->alternative(): symbol name is undefined\n",
        "    The symbol name cannot be undefined\n"
    ) if not defined $symbol_name;

    my $slg        = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
    my $g1_tracer = $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];
    my $symbol_id  = $g1_tracer->symbol_by_name($symbol_name);
    if ( not defined $symbol_id ) {
        Marpa::R3::exception(
            qq{slr->alternative(): symbol "$symbol_name" does not exist});
    }

    my $result = $thin_slr->g1_alternative( $symbol_id, @value );
    return 1 if $result == $Marpa::R3::Error::NONE;

    # The last two are perhaps unnecessary or arguable,
    # but they preserve compatibility with Marpa::XS
    return
        if $result == $Marpa::R3::Error::UNEXPECTED_TOKEN_ID
            || $result == $Marpa::R3::Error::NO_TOKEN_EXPECTED_HERE
            || $result == $Marpa::R3::Error::INACCESSIBLE_TOKEN;

    Marpa::R3::exception( qq{Problem reading symbol "$symbol_name": },
        ( scalar $g1_tracer->error() ) );
} ## end sub Marpa::R3::Scanless::R::lexeme_alternative

# Returns 0 on unthrown failure, current location on success
sub Marpa::R3::Scanless::R::lexeme_complete {
    my ( $slr, $start, $length ) = @_;
    my $thin_slr = $slr->[Marpa::R3::Internal::Scanless::R::SLR_C];
    my $slg  = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
    my $g1_tracer =
        $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];
    my $thin_g1 = $g1_tracer->[Marpa::R3::Internal::Trace::G::C];

    $slr->[Marpa::R3::Internal::Scanless::R::EVENTS] = [];
    my $return_value = $thin_slr->g1_lexeme_complete( $start, $length );
    Marpa::R3::Internal::Scanless::convert_libmarpa_events($slr);
    die q{} . $thin_g1->error() if $return_value == 0;
    return $return_value;
} ## end sub Marpa::R3::Scanless::R::lexeme_complete

# Returns 0 on unthrown failure, current location on success,
# undef if lexeme not accepted.
sub Marpa::R3::Scanless::R::lexeme_read {
    my ( $slr, $symbol_name, $start, $length, @value ) = @_;
    return if not $slr->lexeme_alternative( $symbol_name, @value );
    return $slr->lexeme_complete( $start, $length );
}

sub Marpa::R3::Scanless::R::pause_span {
    my ($slr) = @_;
    my $thin_slr = $slr->[Marpa::R3::Internal::Scanless::R::SLR_C];
    return $thin_slr->pause_span();
}

sub Marpa::R3::Scanless::R::line_column {
    my ( $slr, $pos ) = @_;
    my $thin_slr = $slr->[Marpa::R3::Internal::Scanless::R::SLR_C];
    $pos //= $thin_slr->pos();
    return $thin_slr->line_column($pos);
} ## end sub Marpa::R3::Scanless::R::line_column

sub Marpa::R3::Scanless::R::pos {
    my ( $slr ) = @_;
    my $thin_slr = $slr->[Marpa::R3::Internal::Scanless::R::SLR_C];
    return $thin_slr->pos();
}

sub Marpa::R3::Scanless::R::input_length {
    my ( $slr ) = @_;
    my $thin_slr = $slr->[Marpa::R3::Internal::Scanless::R::SLR_C];
    return $thin_slr->input_length();
}

# no return value documented
sub Marpa::R3::Scanless::R::activate {
    my ( $slr, $event_name, $activate ) = @_;
    my $slg = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
    $activate //= 1;
    my $event_symbol_ids_by_type =
      $slg
      ->[Marpa::R3::Internal::Scanless::G::SYMBOL_IDS_BY_EVENT_NAME_AND_TYPE]
      ->{$event_name};

    for my $event ( @{ $event_symbol_ids_by_type->{completion} } ) {
        $slr->exec_sig( <<'END_OF_LUA', 'ii', $event, $activate );
        local recce, event, activate = ...
        recce.lmw_g1r:completion_symbol_activate(event, activate)
END_OF_LUA
    }

    for my $event ( @{ $event_symbol_ids_by_type->{nulled} } ) {
        $slr->exec_sig( <<'END_OF_LUA', 'ii', $event, $activate );
        local recce, event, activate = ...
        recce.lmw_g1r:nulled_symbol_activate(event, activate)
END_OF_LUA
    }

    for my $event ( @{ $event_symbol_ids_by_type->{prediction} } ) {
        $slr->exec_sig( <<'END_OF_LUA', 'ii', $event, $activate );
        local recce, event, activate = ...
        recce.lmw_g1r:prediction_symbol_activate(event, activate)
END_OF_LUA
    }

    my $thin_slr = $slr->[Marpa::R3::Internal::Scanless::R::SLR_C];
    $thin_slr->lexeme_event_activate( $_, $activate )
      for @{ $event_symbol_ids_by_type->{lexeme} };

    return 1;
} ## end sub Marpa::R3::Scanless::R::activate

# On success, returns the old priority value.
# Failures are thrown.
sub Marpa::R3::Scanless::R::lexeme_priority_set {
    my ( $slr, $lexeme_name, $new_priority ) = @_;
    my $thin_slr = $slr->[Marpa::R3::Internal::Scanless::R::SLR_C];
    my $slg      = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
    my $g1_tracer = $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];
    my $lexeme_id = $g1_tracer->symbol_by_name($lexeme_name);
    Marpa::R3::exception("Bad symbol in lexeme_priority_set(): $lexeme_name")
      if not defined $lexeme_id;
    return $thin_slr->lexeme_priority_set( $lexeme_id, $new_priority );
}

# Lua method(s), not documented at this stage of their development

# Sun Dec  4 18:03:15 PST 2016 -- at this point, I don't think
# I ever will document these -- I'll keep them internal.

sub Marpa::R3::Scanless::R::exec {
    my ( $slr, $codestr, @args ) = @_;
    my $thin_slr = $slr->[Marpa::R3::Internal::Scanless::R::SLR_C];
    return $thin_slr->exec($codestr, @args);
}

sub Marpa::R3::Scanless::R::exec_name {
    my ( $slr, $name, @args ) = @_;
    my $thin_slr = $slr->[Marpa::R3::Internal::Scanless::R::SLR_C];
    my @results = $thin_slr->exec_name($name, @args);
    return @results;
}

sub Marpa::R3::Scanless::R::exec_sig {
    my ( $slr, $codestr, $signature, @args ) = @_;
    my $thin_slr = $slr->[Marpa::R3::Internal::Scanless::R::SLR_C];
    return $thin_slr->exec_sig($codestr, $signature, @args);
}

sub Marpa::R3::Scanless::R::exec_sig_name {
    my ( $slr, $name, $signature, @args ) = @_;
    my $thin_slr = $slr->[Marpa::R3::Internal::Scanless::R::SLR_C];
    my @results = $thin_slr->exec_sig_name($name, $signature, @args);
    return @results;
}

# Internal methods, not to be documented

# not to be documented
sub Marpa::R3::Scanless::R::earley_set_size {
    my ($slr, $set_id) = @_;
    my ($size) = $slr->exec_sig(
        <<'END_OF_LUA', 'i', ($set_id // -1));
    local recce, set_id = ...
    local g1r = recce.lmw_g1r
    if set_id < 0 then set_id = g1r:lastest_earley_set() end
    return g1r:_earley_set_size(set_id)
END_OF_LUA
    return $size;
}

sub Marpa::R3::Scanless::R::show_earley_sets {
    my ($slr)                = @_;

    my ($last_completed_earleme, $furthest_earleme) = $slr->exec_sig(
        <<'END_OF_LUA', '');
        local recce = ...
        local g1r = recce.lmw_g1r
        return g1r:current_earleme(), g1r:furthest_earleme()
END_OF_LUA

    my $text                   = "Last Completed: $last_completed_earleme; "
        . "Furthest: $furthest_earleme\n";
    LIST: for ( my $ix = 0;; $ix++ ) {
        my $set_desc =
          $slr->Marpa::R3::Scanless::R::show_earley_set( $ix );
        last LIST if not $set_desc;
        $text .= "Earley Set $ix\n$set_desc";
    }
    return $text;
}

sub Marpa::R3::Scanless::R::show_earley_set {
    my ( $slr, $traced_set_id ) = @_;
    my $slg     = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
    my $tracer  = $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];

    my ($set_data) =
      $slr->exec_sig_name( 'g1_earley_set_data', 'i>2', $traced_set_id );
    return if not $set_data;
    my %set_data = @{$set_data};

    my $current_earleme = $set_data{earleme};

    my @sorted_data = ();

  EARLEY_ITEM: for ( my $item_id = 0 ; ; $item_id++ ) {

        my $item_data = $set_data{ $item_id + 1 };
        last EARLEY_ITEM if not defined $item_data;

        my %item_data = @{$item_data};

        my $irl_id       = $item_data{irl_id};
        my $dot_position = $item_data{dot_position};
        my $ahm_desc;
        if ( $dot_position < 0 ) {
            $ahm_desc = sprintf( 'R%d$', $irl_id );
        }
        else {
            $ahm_desc = sprintf( 'R%d:%d', $irl_id, $dot_position );
        }
        my $ahm_id_of_yim  = $item_data{ahm_id_of_yim};
        my $origin_earleme = $item_data{origin_earleme};

        my $text .= sprintf "ahm%d: %s@%d-%d", $ahm_id_of_yim,
          $ahm_desc,
          $origin_earleme, $current_earleme;

        my @lines = $text;
        push @lines,
            qq{  }
          . $ahm_desc . q{: }
          . $tracer->show_dotted_irl( $irl_id, $dot_position );

        push @sorted_data, @lines;

        # Token links
        {
            my @sort_data   = ();
            my @lines       = ();
            my $token_links = $item_data{token_links};
            my %token_links = @{$token_links};
          TOKEN_LINK: for ( my $token_link_ix = 0 ; ; $token_link_ix++ ) {
                my $token_link_data = $token_links{ $token_link_ix + 1 };
                last TOKEN_LINK if not $token_link_data;
                my %token_link_data = @{$token_link_data};

                my $predecessor_ahm = $token_link_data{predecessor_ahm};
                my $origin_earleme  = $token_link_data{origin_earleme};
                my $middle_earleme  = $token_link_data{middle_earleme};
                my $middle_set_id   = $token_link_data{middle_set_id};
                my $token_name      = $token_link_data{token_name};
                my $token_id        = $token_link_data{token_id};
                my $value_ix        = $token_link_data{value_ix};
                my $value           = $token_link_data{value};
                my $source_predecessor_state =
                  $token_link_data{source_predecessor_state};

                my @pieces = ();
                if ( defined $predecessor_ahm ) {
                    my $ahm_desc = $tracer->show_briefer_ahm($predecessor_ahm);
                    push @pieces,
                        'c='
                      . $ahm_desc . q{@}
                      . $origin_earleme . q{-}
                      . $middle_earleme;
                } ## end if ( defined $predecessor_ahm )

                push @pieces, 's=' . $token_name;

                if ( not defined $value ) {

                    # Value is literal
                    my $token_length = $current_earleme - $middle_earleme;
                    $value = $slr->g1_literal( $middle_earleme, $token_length );
                }
                my $token_dump =
                  Data::Dumper->new( [ \$value ] )->Terse(1)->Dump;
                chomp $token_dump;
                push @pieces, "t=$token_dump";
                my $token_link_desc = '[' . ( join '; ', @pieces ) . ']';
                push @sort_data,
                  [
                    $middle_set_id,   $token_id,
                    $predecessor_ahm, $token_link_desc
                  ];
            }
            push @sorted_data, map { qq{  } . $_->[-1] } sort {
                     $a->[0] <=> $b->[0]
                  || $a->[1] <=> $b->[1]
                  || $a->[2] <=> $b->[2]
            } @sort_data;
        }

        # Completion links
        {
            my @sort_data        = ();
            my @lines            = ();
            my $completion_links = $item_data{completion_links};
            my %completion_links = @{$completion_links};
          TOKEN_LINK:
            for ( my $completion_link_ix = 0 ; ; $completion_link_ix++ ) {
                my $completion_link_data =
                  $completion_links{ $completion_link_ix + 1 };
                last TOKEN_LINK if not $completion_link_data;
                my %completion_link_data = @{$completion_link_data};

                my $predecessor_ahm_id =
                  $completion_link_data{predecessor_state};
                my $ahm_id         = $completion_link_data{ahm_id};
                my $origin_earleme = $completion_link_data{origin_earleme};
                my $middle_earleme = $completion_link_data{middle_earleme};
                my $ahm_desc       = $tracer->show_briefer_ahm($ahm_id);

                my @pieces = ();
                if ( defined $predecessor_ahm_id ) {
                    my $predecessor_ahm_desc =
                      $tracer->show_briefer_ahm($predecessor_ahm_id);
                    push @pieces,
                        'p='
                      . $predecessor_ahm_desc . '@'
                      . $origin_earleme . q{-}
                      . $middle_earleme;
                }

                push @pieces,
                    'c='
                  . $ahm_desc . q{@}
                  . $middle_earleme . q{-}
                  . $current_earleme;
                my $link_desc = '[' . ( join '; ', @pieces ) . ']';

                push @sort_data,
                  [
                    $middle_earleme, $ahm_id,
                    ( $predecessor_ahm_id // -1 ), $link_desc
                  ];
            }
            push @sorted_data, map { q{  } . $_->[-1] } sort {
                     $a->[0] <=> $b->[0]
                  || $a->[1] <=> $b->[1]
                  || $a->[2] <=> $b->[2]
            } @sort_data;
        }

        # Leo links
        {
            my @sort_data = ();
            my @lines     = ();
            my $leo_links = $item_data{leo_links};
            my %leo_links = @{$leo_links};
          LEO_LINK:
            for ( my $leo_link_ix = 0 ; ; $leo_link_ix++ ) {
                my $leo_link_data = $leo_links{ $leo_link_ix + 1 };
                last LEO_LINK if not $leo_link_data;
                my %leo_link_data = @{$leo_link_data};

                my $middle_earleme = $leo_link_data{middle_earleme};
                my $middle_set_id  = $leo_link_data{middle_set_id};
                my $leo_transition_symbol =
                  $leo_link_data{leo_transition_symbol};
                my $ahm_id   = $leo_link_data{ahm_id};
                my $ahm_desc = $tracer->show_briefer_ahm($ahm_id);

                my @pieces = ();
                push @pieces,
                  'l=L' . $leo_transition_symbol . q{@} . $middle_earleme;
                push @pieces,
                    'c='
                  . $ahm_desc . q{@}
                  . $middle_earleme . q{-}
                  . $current_earleme;
                my $link_desc = '[' . ( join '; ', @pieces ) . ']';

                push @sort_data,
                  [
                    $middle_set_id,         $ahm_id,
                    $leo_transition_symbol, $link_desc,
                  ];
            }
            push @sorted_data, map { q{  } . $_->[-1] } sort {
                     $a->[0] <=> $b->[0]
                  || $a->[1] <=> $b->[1]
                  || $a->[2] <=> $b->[2]
            } @sort_data;
        }
    }

    # Leo items
    {
        my $leo_data  = $set_data{leo};
        my %leo_data  = @{$leo_data};
        my @sort_data = ();
      LEO_ITEM: for ( my $leo_item_id = 0 ; ; $leo_item_id++ ) {

            my $leo_item_data = $leo_data{ $leo_item_id + 1 };
            last LEO_ITEM if not defined $leo_item_data;

            my %leo_item_data         = @{$leo_item_data};
            my $postdot_symbol_id     = $leo_item_data{postdot_symbol_id};
            my $postdot_symbol_name   = $leo_item_data{postdot_symbol_name};
            my $predecessor_symbol_id = $leo_item_data{predecessor_symbol_id};
            my $base_origin_earleme   = $leo_item_data{base_origin_earleme};
            my $leo_base_state        = $leo_item_data{leo_base_state};
            my $trace_earleme         = $leo_item_data{trace_earleme};

            # L2@8 ["Expression"; L2@6; S16@6-8]
            my @link_texts = ( q{"} . $postdot_symbol_name . q{"} );
            if ( defined $predecessor_symbol_id ) {
                push @link_texts,
                  sprintf( 'L%d@%d',
                    $predecessor_symbol_id, $base_origin_earleme );
            }
            push @link_texts,
              sprintf( 'S%d@%d-%d',
                $leo_base_state, $base_origin_earleme, $trace_earleme );
            my $leo_line = sprintf( 'L%d@%d [%s]',
                $postdot_symbol_id, $trace_earleme,
                ( join q{; }, @link_texts ) );
            push @sort_data, [ $postdot_symbol_id, $leo_line ];
            push @sorted_data,
              (
                join q{},
                map { $_->[-1] } sort { $a->[0] <=> $b->[0] } @sort_data
              );
        }
    }

    return join "\n", @sorted_data, q{};
}

sub Marpa::R3::Scanless::R::show_or_nodes {
    my ( $slr ) = @_;
    my ($result) = $slr->exec_sig_name('show_or_nodes', '');
    return $result;
}

sub Marpa::R3::Scanless::R::show_and_nodes {
    my ( $slr ) = @_;
    my ($result) = $slr->exec_sig_name('show_and_nodes', '');
    return $result;
}


sub Marpa::R3::Scanless::R::show_tree {
    my ( $slr, $verbose ) = @_;
    my $text = q{};
    NOOK: for ( my $nook_id = 0; 1; $nook_id++ ) {
        my $nook_text = $slr->show_nook( $nook_id, $verbose );
        last NOOK if not defined $nook_text;
        $text .= "$nook_id: $nook_text";
    }
    return $text;
}

sub Marpa::R3::Scanless::R::show_nook {
    my ( $slr, $nook_id, $verbose ) = @_;

    my ($or_node_id, $text) = $slr->exec_sig(<<'END_OF_LUA', 'i', $nook_id);
    local recce, nook_id = ...
    local tree = recce.lmw_t
    -- print('nook_id', nook_id)
    local or_node_id = tree:_nook_or_node(nook_id)
    if not or_node_id then return end
    local text = 'o' .. or_node_id
    local parent = tree:_nook_parent(nook_id) or '-'
    -- print('nook_is_cause', tree:_nook_is_cause(nook_id))
    if tree:_nook_is_cause(nook_id) ~= 0 then
        text = text .. '[c' .. parent .. ']'
        goto CHILD_TYPE_FOUND
    end
    if tree:_nook_is_predecessor(nook_id) ~= 0 then
        text = text .. '[p' .. parent .. ']'
        goto CHILD_TYPE_FOUND
    end
    text = text .. '[-]'
    ::CHILD_TYPE_FOUND::

    if not or_node_id then return end

    local tree = recce.lmw_t
    text = text .. " " .. or_node_tag(recce, or_node_id) .. ' p'
    if tree:_nook_predecessor_is_ready(nook_id) ~= 0 then
        text = text .. '=ok'
    else
        text = text .. '-'
    end
    text = text .. ' c'
    if tree:_nook_cause_is_ready(nook_id) ~= 0 then
        text = text .. '=ok'
    else
        text = text .. '-'
    end
    text = text .. '\n'
    return or_node_id, text
END_OF_LUA

    return if not defined $or_node_id;

    DESCRIBE_CHOICES: {
        my $this_choice;
        ($this_choice) = $slr->exec_sig(
            ' recce, nook_id = ...; return recce.lmw_t:_nook_choice(nook_id)',
            'i', $nook_id
        );
        CHOICE: for ( my $choice_ix = 0;; $choice_ix++ ) {

                my ($and_node_id) = $slr->exec( <<'END_OF_LUA', $or_node_id, $choice_ix );
                recce, or_node_id, choice_ix = ...
                return recce.lmw_o:_and_order_get(or_node_id+0, choice_ix+0)
END_OF_LUA

            last CHOICE if not defined $and_node_id;
            $text .= " o$or_node_id" . '[' . $choice_ix . ']';
            if ( defined $this_choice and $this_choice == $choice_ix ) {
                $text .= q{*};
            }
            my $and_node_tag =
                $slr->and_node_tag( $and_node_id );
            $text .= " ::= a$and_node_id $and_node_tag";
            $text .= "\n";
        } ## end CHOICE: for ( my $choice_ix = 0;; $choice_ix++ )
    } ## end DESCRIBE_CHOICES:
    return $text;
}

sub Marpa::R3::Scanless::R::show_bocage {
    my ($slr)     = @_;
    my ($result) = $slr->exec_sig_name('show_bocage', '');
    return $result;
}

sub Marpa::R3::Scanless::R::verbose_or_node {
    my ( $slr, $or_node_id ) = @_;
    my ($text, $irl_id, $position)
        = $slr->exec_sig(<<'END_OF_LUA', 'i', $or_node_id);
        local recce, or_node_id = ...
        local bocage = recce.lmw_b
        local origin = bocage:_or_node_origin(or_node_id)
        if not origin then return end
        local set = bocage:_or_node_set(or_node_id)
        local irl_id = bocage:_or_node_irl(or_node_id)
        local position = bocage:_or_node_position(or_node_id)
        local g1r = recce.lmw_g1r
        local origin_earleme = g1r:earleme(origin)
        local current_earleme = g1r:earleme(set)
        local text = string.format(
            'OR-node #%d: R%d:@%d-%d\n',
            or_node_id,
            position,
            origin_earleme,
            current_earleme,
            )

END_OF_LUA
    return if not $text;

    my $slg = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
    my $tracer =
        $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];
    $text .= ( q{ } x 4 )
        . $tracer->show_dotted_irl( $irl_id, $position ) . "\n";
    return $text;
}

1;

# vim: expandtab shiftwidth=4:
