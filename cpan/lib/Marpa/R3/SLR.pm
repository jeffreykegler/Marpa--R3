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

package Marpa::R3::Scanless::R;

use 5.010001;
use strict;
use warnings;

use vars qw($VERSION $STRING_VERSION);
$VERSION        = '4.001_001';
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
    my $slg = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
    my $thick_g1_grammar =
        $slg->[Marpa::R3::Internal::Scanless::G::THICK_G1_GRAMMAR];
    my $thick_g1_recce =
        $slr->[Marpa::R3::Internal::Scanless::R::THICK_G1_RECCE];
    my $thin_g1_recce = $thick_g1_recce->thin();
    my $sought_rules =
        $slg->[Marpa::R3::Internal::Scanless::G::CACHE_RULEIDS_BY_LHS_NAME]
        ->{$symbol_name};
    if ( not defined $sought_rules ) {
        my $g1_tracer       = $thick_g1_grammar->tracer();
        my $thin_g1_grammar = $thick_g1_grammar->thin();
        my $symbol_id       = $g1_tracer->symbol_by_name($symbol_name);
        Marpa::R3::exception("Bad symbol in last_completed(): $symbol_name")
            if not defined $symbol_id;
        $sought_rules =
            $slg->[Marpa::R3::Internal::Scanless::G::CACHE_RULEIDS_BY_LHS_NAME]
            ->{$symbol_name} =
            [ grep { $thin_g1_grammar->rule_lhs($_) == $symbol_id; }
                0 .. $thin_g1_grammar->highest_rule_id() ];
        Marpa::R3::exception(
            "Looking for completion of non-existent rule lhs: $symbol_name")
            if not scalar @{$sought_rules};
    } ## end if ( not defined $sought_rules )
    my $latest_earley_set = $thin_g1_recce->latest_earley_set();
    my $earley_set        = $latest_earley_set;

    # Initialize to one past the end, so we can tell if there were no hits
    my $first_origin = $latest_earley_set + 1;
    EARLEY_SET: while ( $earley_set >= 0 ) {
        $thin_g1_recce->progress_report_start($earley_set);
        ITEM: while (1) {
            my ( $rule_id, $dot_position, $origin ) =
                $thin_g1_recce->progress_item();
            last ITEM if not defined $rule_id;
            next ITEM if $dot_position != -1;
            next ITEM if not scalar grep { $_ == $rule_id } @{$sought_rules};
            next ITEM if $origin >= $first_origin;
            $first_origin = $origin;
        } ## end ITEM: while (1)
        $thin_g1_recce->progress_report_finish();
        last EARLEY_SET if $first_origin <= $latest_earley_set;
        $earley_set--;
    } ## end EARLEY_SET: while ( $earley_set >= 0 )
    return if $earley_set < 0;
    return ( $first_origin, ( $earley_set - $first_origin ) );
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
    my $thick_g1_recce =
        $slr->[Marpa::R3::Internal::Scanless::R::THICK_G1_RECCE];
    my $thin_g1_recce     = $thick_g1_recce->thin();
    my $latest_earley_set = $thin_g1_recce->latest_earley_set();

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

# Substring in terms of earley sets.
# Necessary for the use of show_progress()
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

sub flatten_hash_args {
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

sub Marpa::R3::Scanless::R::new {
    my ( $class, @args ) = @_;

    my $slr = [];
    bless $slr, $class;

    # Set SLIF (not NAIF) recognizer args to default
    $slr->[Marpa::R3::Internal::Scanless::R::EXHAUSTION_ACTION] = 'fatal';
    $slr->[Marpa::R3::Internal::Scanless::R::REJECTION_ACTION] = 'fatal';
    $slr->[Marpa::R3::Internal::Scanless::R::TRACE_LEXERS] = 0;
    $slr->[Marpa::R3::Internal::Scanless::R::TRACE_TERMINALS] = 0;

    my ($flat_args, $error_message) = flatten_hash_args(\@args);
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

    my $thick_g1_grammar =
        $slg->[Marpa::R3::Internal::Scanless::G::THICK_G1_GRAMMAR];
    $slr->[Marpa::R3::Internal::Scanless::R::TRACE_FILE_HANDLE] =
         $thick_g1_grammar->[Marpa::R3::Internal::Grammar::TRACE_FILE_HANDLE];

    my $g1_recce_args =
        Marpa::R3::Internal::Scanless::R::set( $slr, "new",  $flat_args );
    my $too_many_earley_items = $g1_recce_args->{too_many_earley_items};

    my $thick_g1_recce =
        $slr->[Marpa::R3::Internal::Scanless::R::THICK_G1_RECCE] = bless [],
        'Marpa::R3::Recognizer';

    $thick_g1_recce->[Marpa::R3::Internal::Recognizer::GRAMMAR] = $thick_g1_grammar;

    my $grammar_c = $thick_g1_grammar->[Marpa::R3::Internal::Grammar::C];

    my $recce_c = $thick_g1_recce->[Marpa::R3::Internal::Recognizer::C] =
        Marpa::R3::Thin::R->new($grammar_c);
    if ( not defined $recce_c ) {
        Marpa::R3::exception( $grammar_c->error() );
    }

    $recce_c->ruby_slippers_set(1);

    if ( defined( my $value = $g1_recce_args->{'leo'} ) ) {
            my $boolean = $value ? 1 : 0;
            $thick_g1_recce->use_leo_set($boolean);
            delete $g1_recce_args->{leo};
        }

    $slr->[Marpa::R3::Internal::Scanless::R::RANKING_METHOD] = 'none';
    $slr->[Marpa::R3::Internal::Scanless::R::MAX_PARSES]     = 0;

    $slr->reset_evaluation();

    my $thin_slr =
        Marpa::R3::Thin::SLR->new( $slg->[Marpa::R3::Internal::Scanless::G::C],
        $thick_g1_recce->thin() );
    $thin_slr->earley_item_warning_threshold_set($too_many_earley_items)
        if defined $too_many_earley_items;
    $slr->[Marpa::R3::Internal::Scanless::R::SLR_C]      = $thin_slr;
    $slr->[Marpa::R3::Internal::Scanless::R::EVENTS] = [];

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
        $recce_c->completion_symbol_activate( $_, $is_active )
            for @{$symbol_ids};
        $symbol_ids =
            $symbol_ids_by_event_name_and_type->{$event_name}->{nulled} // [];
        $recce_c->nulled_symbol_activate( $_, $is_active ) for @{$symbol_ids};
        $symbol_ids =
            $symbol_ids_by_event_name_and_type->{$event_name}->{prediction}
            // [];
        $recce_c->prediction_symbol_activate( $_, $is_active )
            for @{$symbol_ids};
    } ## end EVENT: for my $event_name ( keys %{$event_is_active_arg} )

    if ( not $recce_c->start_input() ) {
        my $error = $grammar_c->error();
        Marpa::R3::exception( 'Recognizer start of input failed: ', $error );
    }

    $slr->naif_set($g1_recce_args);

    if ( $slr->[Marpa::R3::Internal::Scanless::R::TRACE_TERMINALS] > 1 ) {
        my @terminals_expected = @{ $thick_g1_recce->terminals_expected() };
        for my $terminal ( sort @terminals_expected ) {
            # We may have set and reset the trace file handle during this method,
            # so we do not memoize its value, bjut get it directly
            say {$slr->[Marpa::R3::Internal::Scanless::R::TRACE_FILE_HANDLE]}
                qq{Expecting "$terminal" at earleme 0}
                or Marpa::R3::exception("Cannot print: $ERRNO");
        }
    } ## end if ( $thick_g1_recce->[Marpa::R3::Internal::Recognizer::TRACE_TERMINALS...])

    Marpa::R3::Internal::Scanless::convert_libmarpa_events($slr);

    return $slr;
} ## end sub Marpa::R3::Scanless::R::new

sub Marpa::R3::Scanless::R::set {
    my ( $slr, @args ) = @_;
    my ($flat_args, $error_message) = flatten_hash_args(\@args);
    Marpa::R3::exception( sprintf $error_message, '$slr->set()' ) if not $flat_args;
    my $naif_recce_args =
        Marpa::R3::Internal::Scanless::R::set( $slr, "set", $flat_args );
    my $naif_recce = $slr->[Marpa::R3::Internal::Scanless::R::THICK_G1_RECCE];
    $slr->naif_set($naif_recce_args);
    return $slr;
} ## end sub Marpa::R3::Scanless::R::set

# The context flag indicates whether this set is called directly by the user
# or is for series reset or the constructor.  "Context" flags of this kind
# are much decried practice, and for good reason, but in this case
# I think it is justified.
# This logic really needs to be all in one place, and so a flag
# to trigger the minor differences needed by the various calling
# contexts is a small price to pay.
sub Marpa::R3::Internal::Scanless::R::set {

    my ( $slr, $method, $flat_args ) = @_;

    # These NAIF recce args are allowed in all contexts
    state $common_naif_recce_args = {
        map { ( $_, 1 ); }
            qw(end max_parses semantics_package too_many_earley_items
            trace_actions trace_values)
    };
    state $common_slif_recce_args =
        { map { ( $_, 1 ); } qw(trace_lexers trace_terminals trace_file_handle rejection exhaustion) };
    state $set_method_args = {
        map { ( $_, 1 ); } (
            keys %{$common_slif_recce_args},
            keys %{$common_naif_recce_args}
        )
    };
    state $new_method_args = {
        map { ( $_, 1 ); } qw(grammar ranking_method event_is_active),
        keys %{$set_method_args}
    };
    state $series_restart_method_args = {
        map { ( $_, 1 ); } (
            keys %{$common_slif_recce_args},
            keys %{$common_naif_recce_args}
        )
    };

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

    # Special SLIF (not NAIF) recce arg processing goes here

    if ( my $value = $flat_args->{'trace_file_handle'} ) {
        $slr->[Marpa::R3::Internal::Scanless::R::TRACE_FILE_HANDLE] = $value;
    }
    my $trace_file_handle = $slr->[Marpa::R3::Internal::Scanless::R::TRACE_FILE_HANDLE];

    if ( exists $flat_args->{'trace_terminals'} ) {
        my $value = $flat_args->{'trace_terminals'};
        my $normalized_value =
            Scalar::Util::looks_like_number( $value ) ? $value : 0;
        $slr->[Marpa::R3::Internal::Scanless::R::TRACE_TERMINALS] = 
            $normalized_value;
        if ($normalized_value) {
            say {$trace_file_handle} qq{Setting trace_terminals option};
        }
    }

    if ( exists $flat_args->{'trace_lexers'} ) {
        my $value = $flat_args->{'trace_lexers'};
        my $normalized_value =
            Scalar::Util::looks_like_number( $value ) ? $value : 0;
        $slr->[Marpa::R3::Internal::Scanless::R::TRACE_LEXERS] = 
            $normalized_value;
        if ($normalized_value) {
            say {$trace_file_handle} qq{Setting trace_lexers option};
        }
    }

    if ( exists $flat_args->{'exhaustion'} ) {

        state $exhaustion_actions = { map { ( $_, 0 ) } qw(fatal event) };
        my $value = $flat_args->{'exhaustion'} // 'undefined';
        Marpa::R3::exception(
            qq{'exhaustion' named arg value is $value (should be one of },
            (   join q{, },
                map { q{'} . $_ . q{'} } keys %{$exhaustion_actions}
            ),
            ')'
        ) if not exists $exhaustion_actions->{$value};
        $slr->[Marpa::R3::Internal::Scanless::R::EXHAUSTION_ACTION] = $value;

    }

    # Special SLIF (not NAIF) recce arg processing goes here
    if ( exists $flat_args->{'rejection'} ) {

        state $rejection_actions = { map { ( $_, 0 ) } qw(fatal event) };
        my $value = $flat_args->{'rejection'} // 'undefined';
        Marpa::R3::exception(
            qq{'rejection' named arg value is $value (should be one of },
            (   join q{, },
                map { q{'} . $_ . q{'} } keys %{$rejection_actions}
            ),
            ')'
        ) if not exists $rejection_actions->{$value};
        $slr->[Marpa::R3::Internal::Scanless::R::REJECTION_ACTION] = $value;

    }

    # These NAIF recce args, when applicable, are simply copies of the the
    # SLIF args of the same name
    state $copyable_naif_recce_args = {
        map { ( $_, 1 ); }
            qw(end max_parses semantics_package too_many_earley_items ranking_method
            trace_actions trace_values)
    };

    # Prune flat args of all those named args which are NOT to be copied
    # into the NAIF recce args
    my %g1_recce_args = ();
    for my $arg_name ( grep { $copyable_naif_recce_args->{$_} }
        keys %{$flat_args} )
    {
        $g1_recce_args{$arg_name} = $flat_args->{$arg_name};
    }

    return \%g1_recce_args;

} ## end sub Marpa::R3::Internal::Scanless::R::set

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
    my $trace_lexers = $self->[Marpa::R3::Internal::Scanless::R::TRACE_LEXERS];
    $thin_slr->trace_terminals($trace_terminals) if $trace_terminals;
    $thin_slr->trace_lexers($trace_lexers)       if $trace_lexers;

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
        my $thick_g1_recce =
            $slr->[Marpa::R3::Internal::Scanless::R::THICK_G1_RECCE];
        my $thick_g1_grammar = $thick_g1_recce->grammar();
        my $slg              = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
        say {$trace_file_handle} qq{Accepted lexeme },
            input_range_describe( $slr, $lexeme_start_pos,
            $lexeme_end_pos - 1 ),
            q{ e}, $slr->g1_pos(),
            q{: },
            $thick_g1_grammar->symbol_in_display_form($g1_lexeme),
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
        my $thick_g1_recce =
            $slr->[Marpa::R3::Internal::Scanless::R::THICK_G1_RECCE];
        my $thick_g1_grammar = $thick_g1_recce->grammar();
        my $slg              = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
        say {$trace_file_handle} qq{Rejected lexeme },
            input_range_describe( $slr, $lexeme_start_pos,
            $lexeme_end_pos - 1 ),
            q{: },
            $thick_g1_grammar->symbol_in_display_form($g1_lexeme),
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
        my $thick_g1_recce =
            $slr->[Marpa::R3::Internal::Scanless::R::THICK_G1_RECCE];
        my $thick_g1_grammar = $thick_g1_recce->grammar();
        my $slg              = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
        say {$trace_file_handle} qq{Expected lexeme },
            $thick_g1_grammar->symbol_in_display_form($g1_lexeme),
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
        my $thick_g1_recce =
            $slr->[Marpa::R3::Internal::Scanless::R::THICK_G1_RECCE];
        my $thick_g1_grammar = $thick_g1_recce->grammar();
        my $slg              = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
        say {$trace_file_handle}
            qq{Outprioritized lexeme },
            input_range_describe( $slr, $lexeme_start_pos,
            $lexeme_end_pos - 1 ),
            q{: },
            $thick_g1_grammar->symbol_in_display_form($g1_lexeme),
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
        my $thick_g1_recce =
            $slr->[Marpa::R3::Internal::Scanless::R::THICK_G1_RECCE];
        my $thick_g1_grammar = $thick_g1_recce->grammar();
        say {$trace_file_handle}
            'Rejected as duplicate lexeme ',
            input_range_describe( $slr, $lexeme_start_pos,
            $lexeme_end_pos - 1 ),
            q{: },
            $thick_g1_grammar->symbol_in_display_form($g1_lexeme),
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
        my $thick_g1_recce =
            $slr->[Marpa::R3::Internal::Scanless::R::THICK_G1_RECCE];
        my $thick_g1_grammar = $thick_g1_recce->grammar();
        say {$trace_file_handle}
            'Attempting to read lexeme ',
            input_range_describe( $slr, $lexeme_start_pos,
            $lexeme_end_pos - 1 ),
            q{ e}, $slr->g1_pos(),
            q{: },
            $thick_g1_grammar->symbol_in_display_form($g1_lexeme),
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
        my $grammar = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
        my $thick_lex_grammar =
            $grammar->[Marpa::R3::Internal::Scanless::G::THICK_LEX_GRAMMARS]
            ->[0];
        my $symbol_in_display_form =
            $thick_lex_grammar->symbol_in_display_form($token_id),
            my ( $line, $column ) = $slr->line_column($position);
        my $trace_file_handle =
            $slr->[Marpa::R3::Internal::Scanless::R::TRACE_FILE_HANDLE];
        my $slg = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
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
        my $grammar = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
        my $thick_lex_grammar =
            $grammar->[Marpa::R3::Internal::Scanless::G::THICK_LEX_GRAMMARS]
            ->[0];
        my $symbol_in_display_form =
            $thick_lex_grammar->symbol_in_display_form($token_id),
            my ( $line, $column ) = $slr->line_column($position);
        my $slg = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
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
        my $grammar = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
        my $thick_lex_grammar =
            $grammar->[Marpa::R3::Internal::Scanless::G::THICK_LEX_GRAMMARS]
            ->[0];
        my $grammar_c = $thick_lex_grammar->[Marpa::R3::Internal::Grammar::C];
        my $rule_length = $grammar_c->rule_length($lex_rule_id);
        my @rhs_ids =
            map { $grammar_c->rule_rhs( $lex_rule_id, $_ ) }
            ( 0 .. $rule_length - 1 );
        my @rhs =
            map { $thick_lex_grammar->symbol_in_display_form($_) } @rhs_ids;
        my $slg = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
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
        my $thick_g1_recce =
            $slr->[Marpa::R3::Internal::Scanless::R::THICK_G1_RECCE];
        my $thick_g1_grammar = $thick_g1_recce->grammar();
        my $lexeme_name =
            $thick_g1_grammar->symbol_in_display_form($lexeme_id);
        my $trace_file_handle =
            $slr->[Marpa::R3::Internal::Scanless::R::TRACE_FILE_HANDLE];
        say {$trace_file_handle} 'Paused before lexeme ',
            input_range_describe( $slr, $start, $end - 1 ), ": $lexeme_name"
            or Marpa::R3::exception("Could not say(): $ERRNO");
    },
    'g1 pausing after lexeme' => sub {
        my ( $slr, $event ) = @_;
        my ( undef, undef, $start, $end, $lexeme_id ) = @{$event};
        my $thick_g1_recce =
            $slr->[Marpa::R3::Internal::Scanless::R::THICK_G1_RECCE];
        my $thick_g1_grammar = $thick_g1_recce->grammar();
        my $lexeme_name =
            $thick_g1_grammar->symbol_in_display_form($lexeme_id);
        my $trace_file_handle =
            $slr->[Marpa::R3::Internal::Scanless::R::TRACE_FILE_HANDLE];
        say {$trace_file_handle} 'Paused after lexeme ',
            input_range_describe( $slr, $start, $end - 1 ), ": $lexeme_name"
            or Marpa::R3::exception("Could not say(): $ERRNO");
    },
    'ignored lexeme' => sub {
        my ( $slr, $event ) = @_;
        my ( undef, undef, $g1_symbol_id, $start, $end ) = @{$event};
        my $thick_g1_recce =
            $slr->[Marpa::R3::Internal::Scanless::R::THICK_G1_RECCE];
        my $thick_g1_grammar = $thick_g1_recce->grammar();
        my $lexeme_name =
            $thick_g1_grammar->symbol_in_display_form($g1_symbol_id);
        my $trace_file_handle =
            $slr->[Marpa::R3::Internal::Scanless::R::TRACE_FILE_HANDLE];
        say {$trace_file_handle} 'Ignored lexeme ',
            input_range_describe( $slr, $start, $end - 1 ), ": $lexeme_name"
            or Marpa::R3::exception("Could not say(): $ERRNO");
    },
};

my $libmarpa_event_handlers = {
    q{'trace} => sub {
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
    my $thin_slr = $slr->[Marpa::R3::Internal::Scanless::R::SLR_C];
    EVENT: for my $event ( $thin_slr->events() ) {
        my ($event_type) = @{$event};
        my $handler = $libmarpa_event_handlers->{$event_type};
        Marpa::R3::exception( ( join q{ }, 'Unknown event:', @{$event} ) )
            if not defined $handler;
        $pause = 1 if $handler->( $slr, $event );
    } ## end EVENT: for my $event ( $thin_slr->events() )
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
    my $trace_lexers = $slr->[Marpa::R3::Internal::Scanless::R::TRACE_LEXERS];

    $thin_slr->pos_set( $start_pos, $length );
    $slr->[Marpa::R3::Internal::Scanless::R::EVENTS] = [];
    my $slg = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
    my $thin_slg = $slg->[Marpa::R3::Internal::Scanless::G::C];

    OUTER_READ: while (1) {

        my $problem_code = $thin_slr->read();
        last OUTER_READ if not $problem_code;
        my $pause =
            Marpa::R3::Internal::Scanless::convert_libmarpa_events($slr);

        if ( $trace_lexers > 2 ) {
            my $stream_pos = $thin_slr->pos();
            my $trace_file_handle =
                $slr->[Marpa::R3::Internal::Scanless::R::TRACE_FILE_HANDLE];
            my $thick_lex_grammar =
                $slg->[Marpa::R3::Internal::Scanless::G::THICK_LEX_GRAMMARS]->[0];
            my $lex_tracer = $thick_lex_grammar->tracer();
            my ( $line, $column ) = $slr->line_column($stream_pos);
            print {$trace_file_handle}
                qq{\n=== Progress report at line $line, column $column\n},
                $lex_tracer->lexer_progress_report($slr),
                qq{=== End of progress report at line $line, column $column\n},
                or Marpa::R3::exception("Cannot print(): $ERRNO");
        } ## end if ( $trace_lexers > 2 )

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
            my $character_class_table =
                $slg->[Marpa::R3::Internal::Scanless::G::CHARACTER_CLASS_TABLES]
                ->[0];
            my @ops;
            for my $entry ( @{$character_class_table} ) {

                my ( $symbol_id, $re ) = @{$entry};
                if ( $character =~ $re ) {

                    if ( $trace_terminals >= 2 ) {
                        my $thick_lex_grammar =
                            $slg->[
                            Marpa::R3::Internal::Scanless::G::THICK_LEX_GRAMMARS]
                            ->[0];
                        my $trace_file_handle = $slr->[
                            Marpa::R3::Internal::Scanless::R::TRACE_FILE_HANDLE];
                        my $char_desc = sprintf 'U+%04x', $codepoint;
                        if ( $character =~ m/[[:graph:]]+/ ) {
                            $char_desc .= qq{ '$character'};
                        }
                        say {$trace_file_handle}
                            qq{Registering character $char_desc as symbol $symbol_id: },
                            $thick_lex_grammar->symbol_in_display_form(
                            $symbol_id)
                            or
                            Marpa::R3::exception("Could not say(): $ERRNO");
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

## From here, recovery is a matter for the caller,
## if it is possible at all
sub Marpa::R3::Scanless::R::read_problem {
    my ( $slr, $problem_code ) = @_;

    die 'No problem_code in slr->read_problem()' if not $problem_code;

    my $thin_slr = $slr->[Marpa::R3::Internal::Scanless::R::SLR_C];
    my $grammar  = $slr->[Marpa::R3::Internal::Scanless::R::SLG];

    my $thick_lex_grammar =
        $grammar->[Marpa::R3::Internal::Scanless::G::THICK_LEX_GRAMMARS]->[0];
    my $lex_tracer = $thick_lex_grammar->tracer();

    my $trace_file_handle =
        $slr->[Marpa::R3::Internal::Scanless::R::TRACE_FILE_HANDLE];

    my $thick_g1_recce =
        $slr->[Marpa::R3::Internal::Scanless::R::THICK_G1_RECCE];
    my $thin_g1_recce    = $thick_g1_recce->thin();
    my $thick_g1_grammar = $thick_g1_recce->grammar();
    my $g1_tracer        = $thick_g1_grammar->tracer();

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
            my $lexer_name;
            my @details    = ();
            my %rejections = ();
            my @events     = $thin_slr->events();
            if ( scalar @events > 100 ) {
                my $omitted = scalar @events - 100;
                push @details,
                    "  [there were $omitted events -- only the first 100 were examined]";
                $#events = 99;
            } ## end if ( scalar @events > 100 )
            EVENT: for my $event (@events) {
                my ( $event_type, $trace_event_type, $lexeme_start_pos,
                    $lexeme_end_pos, $g1_lexeme )
                    = @{$event};
                next EVENT
                    if $event_type ne q{'trace}
                    or $trace_event_type ne 'rejected lexeme';
                my $thin_slr = $slr->[Marpa::R3::Internal::Scanless::R::SLR_C];
                my $raw_token_value =
                    $thin_slr->substring( $lexeme_start_pos,
                    $lexeme_end_pos - $lexeme_start_pos );
                my $trace_file_handle =
                    $slr
                    ->[Marpa::R3::Internal::Scanless::R::TRACE_FILE_HANDLE];
                my $thick_g1_recce =
                    $slr->[Marpa::R3::Internal::Scanless::R::THICK_G1_RECCE];
                my $thick_g1_grammar = $thick_g1_recce->grammar();
                my $slg = $slr->[Marpa::R3::Internal::Scanless::R::SLG];

                # Different internal symbols may have the same external "display form",
                # which in naive reporting logic would result in many identical messages,
                # confusing the user.  This logic makes sure that identical rejection
                # reports are not repeated, even when they have different causes
                # internally.

                $rejections{ 
                        $thick_g1_grammar->symbol_in_display_form(
                        $g1_lexeme)
                        . qq{; value="$raw_token_value"; length = }
                        . ( $lexeme_end_pos - $lexeme_start_pos ) } = 1;
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
            my $true_event_count = $thin_slr->g1()->event_count();
            EVENT:
            for (
                my $event_ix = 0;
                $event_ix < $true_event_count;
                $event_ix++
                )
            {
                my ( $event_type, $value ) =
                    $thin_slr->g1()->event($event_ix);
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
            $desc = 'G1 error: ' . $thin_slr->g1()->error();
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

    if ( $slr->[Marpa::R3::Internal::Scanless::R::TRACE_LEXERS] ) {
        my $stream_pos = $thin_slr->pos();
        my $trace_file_handle =
            $slr->[Marpa::R3::Internal::Scanless::R::TRACE_FILE_HANDLE];
        my $slg = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
        my $thick_lex_grammar =
            $grammar->[Marpa::R3::Internal::Scanless::G::THICK_LEX_GRAMMARS]->[0];
        my $lex_tracer = $thick_lex_grammar->tracer();
        my ( $line, $column ) = $slr->line_column($stream_pos);
        $read_string_error .=
            qq{\n=== Progress report for lexer at line $line, column $column\n} .
            $lex_tracer->lexer_progress_report($slr);
    }

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
# in the NAIF
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
    my $thick_g1_recce =
        $slr->[Marpa::R3::Internal::Scanless::R::THICK_G1_RECCE];
    my $ordering = $slr->ordering_get();
    my $metric = $ordering ? $ordering->ambiguity_metric() : 0;
    my $bocage = $thick_g1_recce->[Marpa::R3::Internal::Recognizer::B_C];
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

sub Marpa::R3::Scanless::R::rule_closure {

    my ( $slr, $rule_id ) = @_;

    my $recce = $slr->[Marpa::R3::Internal::Scanless::R::THICK_G1_RECCE];

    if ( not $slr->[Marpa::R3::Internal::Scanless::R::REGISTRATIONS] ) {
        Marpa::R3::Internal::Value::registration_init( $slr, {} );
    }

    my $rule_closure =
      $slr->[Marpa::R3::Internal::Scanless::R::CLOSURE_BY_RULE_ID]->[$rule_id];
    if ( defined $rule_closure ) {
        my $ref_rule_closure = ref $rule_closure;
        if ( $ref_rule_closure eq 'CODE' ) {
            return $rule_closure;
        }
        elsif ( $ref_rule_closure eq 'SCALAR' ) {
            return $rule_closure;
        }
    }
    else {
        return;
    }

}

sub Marpa::R3::Scanless::R::value {
    my ( $slr, $per_parse_arg ) = @_;
    my $thick_g1_recce =
        $slr->[Marpa::R3::Internal::Scanless::R::THICK_G1_RECCE];
    my $thick_g1_value = $thick_g1_recce->value( $slr, $per_parse_arg );
    return $thick_g1_value;
} ## end sub Marpa::R3::Scanless::R::value

sub Marpa::R3::Scanless::R::series_restart {
    my ( $slr , @args ) = @_;
    my $thick_g1_recce =
        $slr->[Marpa::R3::Internal::Scanless::R::THICK_G1_RECCE];

    # Reset SLIF (not NAIF) recognizer args to default
    $slr->[Marpa::R3::Internal::Scanless::R::EXHAUSTION_ACTION] = 'fatal';
    $slr->[Marpa::R3::Internal::Scanless::R::REJECTION_ACTION] = 'fatal';

    $slr->reset_evaluation();

    my ($flat_args, $error_message) = flatten_hash_args(\@args);
    Marpa::R3::exception( sprintf $error_message, '$slr->series_restart()' ) if not $flat_args;
    my ($g1_recce_args) = Marpa::R3::Internal::Scanless::R::set($slr, "series_restart", $flat_args );
    $slr->naif_set( $g1_recce_args );
    return 1;
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
    my $recce = $slr->[Marpa::R3::Internal::Scanless::R::THICK_G1_RECCE];
    my $grammar   = $recce->[Marpa::R3::Internal::Recognizer::GRAMMAR];
    my $grammar_c = $grammar->[Marpa::R3::Internal::Grammar::C];

    my $last_ordinal = $recce->latest_earley_set();

    if ( not defined $start_ordinal ) {
        $start_ordinal = $last_ordinal;
    }
    if ( $start_ordinal < 0 ) {
        $start_ordinal += $last_ordinal + 1;
    }
    else {
        if ( $start_ordinal < 0 or $start_ordinal > $last_ordinal ) {
            return
                "Marpa::PP::Recognizer::show_progress start index is $start_ordinal, "
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
                "Marpa::PP::Recognizer::show_progress end index is $end_ordinal_argument, "
                . sprintf ' must be in range %d-%d', -( $last_ordinal + 1 ),
                $last_ordinal;
        } ## end if ( $end_ordinal < 0 )
    } ## end else [ if ( not defined $end_ordinal ) ]

    my $text = q{};
    for my $current_ordinal ( $start_ordinal .. $end_ordinal ) {
        my $current_earleme     = $recce->earleme($current_ordinal);
        my %by_rule_by_position = ();
        for my $progress_item ( @{ $recce->progress($current_ordinal) } ) {
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
    my ( $self, @args ) = @_;
    return $self->[Marpa::R3::Internal::Scanless::R::THICK_G1_RECCE]
        ->progress(@args);
}

sub Marpa::R3::Scanless::R::terminals_expected {
    my ($self) = @_;
    return $self->[Marpa::R3::Internal::Scanless::R::THICK_G1_RECCE]
        ->terminals_expected();
}

sub Marpa::R3::Scanless::R::exhausted {
    my ($self) = @_;
    return $self->[Marpa::R3::Internal::Scanless::R::THICK_G1_RECCE]
        ->exhausted();
}

# Latest and current G1 location are the same
sub Marpa::R3::Scanless::R::g1_pos {
    my ($slg) = @_;
    return $slg->[Marpa::R3::Internal::Scanless::R::THICK_G1_RECCE]
        ->latest_earley_set();
}

sub Marpa::R3::Scanless::R::lexeme_alternative {
    my ( $slr, $symbol_name, @value ) = @_;
    my $thin_slr = $slr->[Marpa::R3::Internal::Scanless::R::SLR_C];

    Marpa::R3::exception(
        "slr->alternative(): symbol name is undefined\n",
        "    The symbol name cannot be undefined\n"
    ) if not defined $symbol_name;

    my $slg        = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
    my $g1_grammar = $slg->[Marpa::R3::Internal::Scanless::G::THICK_G1_GRAMMAR];
    my $g1_tracer  = $g1_grammar->tracer();
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
        ( scalar $g1_grammar->error() ) );
} ## end sub Marpa::R3::Scanless::R::lexeme_alternative

# Returns 0 on unthrown failure, current location on success
sub Marpa::R3::Scanless::R::lexeme_complete {
    my ( $slr, $start, $length ) = @_;
    my $thin_slr = $slr->[Marpa::R3::Internal::Scanless::R::SLR_C];
    $slr->[Marpa::R3::Internal::Scanless::R::EVENTS] = [];
    my $return_value = $thin_slr->g1_lexeme_complete( $start, $length );
    Marpa::R3::Internal::Scanless::convert_libmarpa_events($slr);
    die q{} . $thin_slr->g1()->error() if $return_value == 0;
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
    my $slg      = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
    my $thin_slr = $slr->[Marpa::R3::Internal::Scanless::R::SLR_C];
    $activate //= 1;
    my $thick_g1_recce =
        $slr->[Marpa::R3::Internal::Scanless::R::THICK_G1_RECCE];
    my $thin_g1_recce = $thick_g1_recce->thin();
    my $event_symbol_ids_by_type =
        $slg
        ->[Marpa::R3::Internal::Scanless::G::SYMBOL_IDS_BY_EVENT_NAME_AND_TYPE]
        ->{$event_name};
    $thin_g1_recce->completion_symbol_activate( $_, $activate )
        for @{ $event_symbol_ids_by_type->{completion} };
    $thin_g1_recce->nulled_symbol_activate( $_, $activate )
        for @{ $event_symbol_ids_by_type->{nulled} };
    $thin_g1_recce->prediction_symbol_activate( $_, $activate )
        for @{ $event_symbol_ids_by_type->{prediction} };
    $thin_slr->lexeme_event_activate( $_, $activate )
        for @{ $event_symbol_ids_by_type->{lexeme} };
    return 1;
} ## end sub Marpa::R3::Scanless::R::activate

# On success, returns the old priority value.
# Failures are thrown.
sub Marpa::R3::Scanless::R::lexeme_priority_set {
    my ($slr, $lexeme_name, $new_priority) = @_;
    my $thin_slr = $slr->[Marpa::R3::Internal::Scanless::R::SLR_C];
    my $slg = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
    my $thick_g1_grammar =
        $slg->[Marpa::R3::Internal::Scanless::G::THICK_G1_GRAMMAR];
    my $g1_tracer       = $thick_g1_grammar->tracer();
    my $lexeme_id       = $g1_tracer->symbol_by_name($lexeme_name);
    Marpa::R3::exception("Bad symbol in lexeme_priority_set(): $lexeme_name")
        if not defined $lexeme_id;
    return $thin_slr->lexeme_priority_set($lexeme_id, $new_priority);
}

# Need to port show_and_nodes(), show_or_nodes() NAIF recognizer methods

# Internal methods, not to be documented

sub Marpa::R3::Scanless::R::thick_g1_grammar {
    my ($slr) = @_;
    my $slg = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
    return $slg->[Marpa::R3::Internal::Scanless::G::THICK_G1_GRAMMAR];
}

sub Marpa::R3::Scanless::R::thick_g1_recce {
    my ($slr) = @_;
    return $slr->[Marpa::R3::Internal::Scanless::R::THICK_G1_RECCE];
}

sub Marpa::R3::Scanless::R::default_g1_start_closure {
    my ($slr) = @_;
    my $slg = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
    my $default_action_name =
        $slg->[Marpa::R3::Internal::Scanless::G::DEFAULT_G1_START_ACTION];
    my $thick_g1_recce =
        $slr->[Marpa::R3::Internal::Scanless::R::THICK_G1_RECCE];
    my $resolution =
        Marpa::R3::Internal::Recognizer::resolve_action( $thick_g1_recce,
        $default_action_name );
    return if not $resolution;
    my ( undef, $closure ) = @{$resolution};
    return $closure;
} ## end sub Marpa::R3::Scanless::R::default_g1_start_closure

# not to be documented
sub Marpa::R3::Scanless::R::earley_set_size {
    my ($self, $set_id) = @_;
    # OK if set ID is undef, just pass it on.
    return $self->[Marpa::R3::Internal::Scanless::R::THICK_G1_RECCE]
        ->earley_set_size($set_id);
}

sub Marpa::R3::Scanless::R::show_earley_sets {
    my ($slr)                = @_;
    my $naif_recce = $slr->[Marpa::R3::Internal::Scanless::R::THICK_G1_RECCE];
    my $recce_c                = $naif_recce->[Marpa::R3::Internal::Recognizer::C];
    my $last_completed_earleme = $recce_c->current_earleme();
    my $furthest_earleme       = $recce_c->furthest_earleme();
    my $text                   = "Last Completed: $last_completed_earleme; "
        . "Furthest: $furthest_earleme\n";
    LIST: for ( my $ix = 0;; $ix++ ) {
        my $set_desc =
          $slr->Marpa::R3::Scanless::R::show_earley_set( $ix );
        last LIST if not $set_desc;
        $text .= "Earley Set $ix\n$set_desc";
    }
    return $text;
} ## end sub Marpa::R3::Recognizer::show_earley_sets

sub Marpa::R3::Scanless::R::show_leo_item {
    my ($slr)        = @_;
    my $naif_recce = $slr->[Marpa::R3::Internal::Scanless::R::THICK_G1_RECCE];
    my $recce_c                = $naif_recce->[Marpa::R3::Internal::Recognizer::C];
    my $grammar = $naif_recce->[Marpa::R3::Internal::Recognizer::GRAMMAR];
    my $grammar_c = $grammar->[Marpa::R3::Internal::Grammar::C];
    my $tracer  = $grammar->[Marpa::R3::Internal::Grammar::TRACER];
    my $leo_base_state = $recce_c->_marpa_r_leo_base_state();
    return if not defined $leo_base_state;
    my $trace_earley_set      = $recce_c->_marpa_r_trace_earley_set();
    my $trace_earleme         = $recce_c->earleme($trace_earley_set);
    my $postdot_symbol_id     = $recce_c->_marpa_r_postdot_item_symbol();
    my $postdot_symbol_name   = $tracer->isy_name($postdot_symbol_id);
    my $predecessor_symbol_id = $recce_c->_marpa_r_leo_predecessor_symbol();
    my $base_origin_set_id    = $recce_c->_marpa_r_leo_base_origin();
    my $base_origin_earleme   = $recce_c->earleme($base_origin_set_id);

    my $text = sprintf 'L%d@%d', $postdot_symbol_id, $trace_earleme;
    my @link_texts = qq{"$postdot_symbol_name"};
    if ( defined $predecessor_symbol_id ) {
        push @link_texts, sprintf 'L%d@%d', $predecessor_symbol_id,
            $base_origin_earleme;
    }
    push @link_texts, sprintf 'S%d@%d-%d', $leo_base_state,
        $base_origin_earleme,
        $trace_earleme;
    $text .= ' [' . ( join '; ', @link_texts ) . ']';
    return $text;
}

# Assumes trace token source link set by caller
sub Marpa::R3::Scanless::R::show_token_link_choice {
    my ( $slr, $current_earleme ) = @_;
    my $naif_recce = $slr->[Marpa::R3::Internal::Scanless::R::THICK_G1_RECCE];
    my $recce_c                = $naif_recce->[Marpa::R3::Internal::Recognizer::C];
    my $grammar = $naif_recce->[Marpa::R3::Internal::Recognizer::GRAMMAR];
    my $grammar_c = $grammar->[Marpa::R3::Internal::Grammar::C];
    my $tracer  = $grammar->[Marpa::R3::Internal::Grammar::TRACER];

    my $text    = q{};
    my @pieces  = ();
    my ( $token_id, $value_ix ) = $recce_c->_marpa_r_source_token();
    my $predecessor_ahm = $recce_c->_marpa_r_source_predecessor_state();
    my $origin_set_id     = $recce_c->_marpa_r_earley_item_origin();
    my $origin_earleme    = $recce_c->earleme($origin_set_id);
    my $middle_earleme    = $origin_earleme;

    if ( defined $predecessor_ahm ) {
        my $middle_set_id = $recce_c->_marpa_r_source_middle();
        $middle_earleme = $recce_c->earleme($middle_set_id);
        push @pieces,
              'c='
            . $grammar_c->ahm_describe($predecessor_ahm)
            . q{@}
            . $origin_earleme . q{-}
            . $middle_earleme;
    } ## end if ( defined $predecessor_ahm )
    my $symbol_name = $tracer->isy_name($token_id);
    push @pieces, 's=' . $symbol_name;
    my $token_length = $current_earleme - $middle_earleme;
    my $value;
    if ($value_ix == 2) {
        # Value is literal
        $value = $slr->g1_literal ( $middle_earleme, $token_length);
    } else {
        $value = $slr->thin()->token_value($value_ix);
    }
    my $token_dump = Data::Dumper->new( [ \$value ] )->Terse(1)->Dump;
    chomp $token_dump;
    push @pieces, "t=$token_dump";
    return '[' . ( join '; ', @pieces ) . ']';
}

# Assumes trace completion source link set by caller
sub Marpa::R3::Scanless::R::show_completion_link_choice {
    my ( $slr, $link_ahm_id, $current_earleme ) = @_;
    my $naif_recce = $slr->[Marpa::R3::Internal::Scanless::R::THICK_G1_RECCE];
    my $recce_c                = $naif_recce->[Marpa::R3::Internal::Recognizer::C];
    my $grammar = $naif_recce->[Marpa::R3::Internal::Recognizer::GRAMMAR];
    my $grammar_c = $grammar->[Marpa::R3::Internal::Grammar::C];
    my $tracer  = $grammar->[Marpa::R3::Internal::Grammar::TRACER];
 
    my $text    = q{};
    my @pieces  = ();
    my $predecessor_state = $recce_c->_marpa_r_source_predecessor_state();
    my $origin_set_id     = $recce_c->_marpa_r_earley_item_origin();
    my $origin_earleme    = $recce_c->earleme($origin_set_id);
    my $middle_set_id     = $recce_c->_marpa_r_source_middle();
    my $middle_earleme    = $recce_c->earleme($middle_set_id);

    if ( defined $predecessor_state ) {
        push @pieces,
              'p='
            . $grammar_c->ahm_describe($predecessor_state) . q{@}
            . $origin_earleme . q{-}
            . $middle_earleme;
    } ## end if ( defined $predecessor_state )
    push @pieces,
          'c=' . $grammar_c->ahm_describe($link_ahm_id) . q{@}
        . $middle_earleme . q{-}
        . $current_earleme;
    return '[' . ( join '; ', @pieces ) . ']';
}

# Assumes trace completion source link set by caller
sub Marpa::R3::Scanless::R::show_leo_link_choice {
    my ( $slr, $link_ahm_id, $current_earleme ) = @_;
    my $naif_recce = $slr->[Marpa::R3::Internal::Scanless::R::THICK_G1_RECCE];
    my $recce_c                = $naif_recce->[Marpa::R3::Internal::Recognizer::C];
    my $grammar = $naif_recce->[Marpa::R3::Internal::Recognizer::GRAMMAR];
    my $grammar_c = $grammar->[Marpa::R3::Internal::Grammar::C];

    my $text           = q{};
    my @pieces         = ();
    my $middle_set_id  = $recce_c->_marpa_r_source_middle();
    my $middle_earleme = $recce_c->earleme($middle_set_id);
    my $leo_transition_symbol =
        $recce_c->_marpa_r_source_leo_transition_symbol();
    push @pieces, 'l=L' . $leo_transition_symbol . q{@} . $middle_earleme;
    push @pieces,
          'c=' . $grammar_c->ahm_describe($link_ahm_id)
        . q{@}
        . $middle_earleme . q{-}
        . $current_earleme;
    return '[' . ( join '; ', @pieces ) . ']';
} ## end sub Marpa::R3::show_leo_link_choice

# Assumes trace earley item was set by caller
sub Marpa::R3::Scanless::R::show_earley_item {
    my ( $slr, $current_es, $item_id ) = @_;
    my $naif_recce = $slr->[Marpa::R3::Internal::Scanless::R::THICK_G1_RECCE];
    my $recce_c                = $naif_recce->[Marpa::R3::Internal::Recognizer::C];
    my $grammar = $naif_recce->[Marpa::R3::Internal::Recognizer::GRAMMAR];
    my $grammar_c = $grammar->[Marpa::R3::Internal::Grammar::C];
    my $tracer  = $grammar->[Marpa::R3::Internal::Grammar::TRACER];

    my $ahm_id_of_yim = $recce_c->_marpa_r_earley_item_trace($item_id);
    return if not defined $ahm_id_of_yim;

    my $text           = q{};
    my $origin_set_id  = $recce_c->_marpa_r_earley_item_origin();
    my $earleme        = $recce_c->earleme($current_es);
    my $origin_earleme = $recce_c->earleme($origin_set_id);
    $text .= sprintf "ahm%d: %s@%d-%d", $ahm_id_of_yim,
        $grammar_c->ahm_describe($ahm_id_of_yim),
        $origin_earleme, $earleme;
    my @lines    = $text;
    my $irl_id = $grammar_c->_marpa_g_ahm_irl($ahm_id_of_yim);
    my $dot_position = $grammar_c->_marpa_g_ahm_position($ahm_id_of_yim);
    push @lines, qq{  }
        . $grammar_c->ahm_describe($ahm_id_of_yim)
        . q{: }
        . $tracer->show_dotted_irl($irl_id, $dot_position);
    my @sort_data = ();

    for (
        my $symbol_id = $recce_c->_marpa_r_first_token_link_trace();
        defined $symbol_id;
        $symbol_id = $recce_c->_marpa_r_next_token_link_trace()
        )
    {
        push @sort_data,
            [
            $recce_c->_marpa_r_source_middle(),
            $symbol_id,
            ( $recce_c->_marpa_r_source_predecessor_state() // -1 ),
            $slr->Marpa::R3::Scanless::R::show_token_link_choice( $earleme )
            ];
    } ## end for ( my $symbol_id = $recce_c->_marpa_r_first_token_link_trace...)
    my @pieces = map { $_->[-1] } sort {
               $a->[0] <=> $b->[0]
            || $a->[1] <=> $b->[1]
            || $a->[2] <=> $b->[2]
    } @sort_data;
    @sort_data = ();
    for (
        my $cause_AHFA_id = $recce_c->_marpa_r_first_completion_link_trace();
        defined $cause_AHFA_id;
        $cause_AHFA_id = $recce_c->_marpa_r_next_completion_link_trace()
        )
    {
        push @sort_data,
            [
            $recce_c->_marpa_r_source_middle(),
            $cause_AHFA_id,
            ( $recce_c->_marpa_r_source_predecessor_state() // -1 ),
            $slr->Marpa::R3::Scanless::R::show_completion_link_choice(
                $cause_AHFA_id, $earleme
            )
            ];
    } ## end for ( my $cause_AHFA_id = $recce_c...)
    push @pieces, map { $_->[-1] } sort {
               $a->[0] <=> $b->[0]
            || $a->[1] <=> $b->[1]
            || $a->[2] <=> $b->[2]
    } @sort_data;
    @sort_data = ();
    for (
        my $link_ahm_id = $recce_c->_marpa_r_first_leo_link_trace();
        defined $link_ahm_id;
        $link_ahm_id = $recce_c->_marpa_r_next_leo_link_trace()
        )
    {
        push @sort_data,
            [
            $recce_c->_marpa_r_source_middle(),
            $link_ahm_id,
            $recce_c->_marpa_r_source_leo_transition_symbol(),
            $slr->Marpa::R3::Scanless::R::show_leo_link_choice(
                $link_ahm_id, $earleme
            )
            ];
    } ## end for ( my $link_ahm_id = $recce_c...)
    push @pieces, map { $_->[-1] } sort {
               $a->[0] <=> $b->[0]
            || $a->[1] <=> $b->[1]
            || $a->[2] <=> $b->[2]
    } @sort_data;
    push @lines, q{  } . join q{ }, @pieces if @pieces;
    return join "\n", @lines, q{};
}

sub Marpa::R3::Scanless::R::show_earley_set {
    my ( $slr, $traced_set_id ) = @_;
    my $naif_recce = $slr->[Marpa::R3::Internal::Scanless::R::THICK_G1_RECCE];
    my $recce_c                = $naif_recce->[Marpa::R3::Internal::Recognizer::C];

    my $text      = q{};
    my @sorted_data = ();
    if ( not defined $recce_c->_marpa_r_earley_set_trace($traced_set_id) ) {
        return $text;
    }
    EARLEY_ITEM: for ( my $item_id = 0;; $item_id++ ) {
        my $item_desc = $slr->Marpa::R3::Scanless::R::show_earley_item( $traced_set_id, $item_id );
        last EARLEY_ITEM if not defined $item_desc;
        # We do not sort these any more
        push @sorted_data, $item_desc;
    } ## end EARLEY_ITEM: for ( my $item_id = 0;; $item_id++ )
    my @sort_data = ();
    POSTDOT_ITEM:
    for (
        my $postdot_symbol_id = $recce_c->_marpa_r_first_postdot_item_trace();
        defined $postdot_symbol_id;
        $postdot_symbol_id = $recce_c->_marpa_r_next_postdot_item_trace()
        )
    {

        # If there is no base Earley item,
        # then this is not a Leo item, so we skip it
        my $leo_item_desc = $slr->Marpa::R3::Scanless::R::show_leo_item();
        next POSTDOT_ITEM if not defined $leo_item_desc;
        push @sort_data, [ $postdot_symbol_id, $leo_item_desc ];
    } ## end POSTDOT_ITEM: for ( my $postdot_symbol_id = $recce_c...)
    push @sorted_data, join q{},
        map { $_->[-1] . "\n" } sort { $a->[0] <=> $b->[0] } @sort_data;
    return join q{}, @sorted_data;
}

sub Marpa::R3::Scanless::R::show_or_nodes {
    my ( $slr, $verbose ) = @_;
    my $naif_recce = $slr->[Marpa::R3::Internal::Scanless::R::THICK_G1_RECCE];
    my $recce_c                = $naif_recce->[Marpa::R3::Internal::Recognizer::C];
    my $thick_g1_recce =
        $slr->[Marpa::R3::Internal::Scanless::R::THICK_G1_RECCE];
    my $bocage = $thick_g1_recce->[Marpa::R3::Internal::Recognizer::B_C];
    return $recce_c->show_or_nodes($bocage, $verbose);
}

sub Marpa::R3::Scanless::R::show_and_nodes {
    my ( $slr ) = @_;
    my $naif_recce = $slr->[Marpa::R3::Internal::Scanless::R::THICK_G1_RECCE];
    my $recce_c                = $naif_recce->[Marpa::R3::Internal::Recognizer::C];
    my $thick_g1_recce =
        $slr->[Marpa::R3::Internal::Scanless::R::THICK_G1_RECCE];
    my $bocage = $thick_g1_recce->[Marpa::R3::Internal::Recognizer::B_C];
    return $recce_c->show_and_nodes($bocage);
}

sub Marpa::R3::Scanless::R::show_tree {
    my ( $slr ) = @_;
    my $naif_recce = $slr->[Marpa::R3::Internal::Scanless::R::THICK_G1_RECCE];
    return $naif_recce->show_tree();
}

sub Marpa::R3::Scanless::R::show_bocage {
    my ( $slr ) = @_;
    my $naif_recce = $slr->[Marpa::R3::Internal::Scanless::R::THICK_G1_RECCE];
    return $naif_recce->show_bocage();
}

1;

# vim: expandtab shiftwidth=4:
