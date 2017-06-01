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

package Marpa::R3::Scanless::R;

use 5.010001;
use strict;
use warnings;

use vars qw($VERSION $STRING_VERSION);
$VERSION        = '4.001_046';
$STRING_VERSION = $VERSION;
## no critic(BuiltinFunctions::ProhibitStringyEval)
$VERSION = eval $VERSION;
## use critic

package Marpa::R3::Internal::Scanless::R;

use Scalar::Util qw(blessed tainted);
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
    my $symbol_id       = $slg->symbol_by_name($symbol_name);

    my ($start, $length) = $slr->call_by_tag(
        ('@' . __FILE__ . ':' . __LINE__),
    <<'END_OF_LUA', 'i>*', $symbol_id);
        local recce, symbol_id  = ...
        return recce:last_completed(symbol_id)
END_OF_LUA

    return if not defined $start;
    return $start, $length;
} ## end sub Marpa::R3::Scanless::R::last_completed

# Given a scanless recognizer and
# and two earley sets, return the input string
sub Marpa::R3::Scanless::R::g1_literal {
    my ( $slr, $g1_start, $g1_count ) = @_;

    my ($literal) = $slr->call_by_tag(
    ('@' . __FILE__ . ':' . __LINE__),
    <<'END_OF_LUA', 'ii', $g1_start, $g1_count);
    local slr, g1_start, g1_count = ...
    return slr:g1_literal(g1_start, g1_count)
END_OF_LUA

   return $literal;

} ## end sub Marpa::R3::Scanless::R::g1_literal

# Substring in terms of locations in the input stream
# This is the one users will be most interested in.
# TODO - Document block_ix parameter
sub Marpa::R3::Scanless::R::literal {
    my ( $slr, $l0_start, $l0_count, $block_ix ) = @_;

    my ($literal) = $slr->call_by_tag(
    ('@' . __FILE__ . ':' . __LINE__),
    <<'END_OF_LUA', 'iii', $l0_start, $l0_count, ($block_ix // -1));
    local slr, l0_start, l0_count, block_ix = ...
    if block_ix <= 0 then block_ix = nil end
    return slr:l0_literal(l0_start, l0_count, block_ix)
END_OF_LUA

    return $literal;
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
    # Lua equivalent is set below

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

    $slr->[Marpa::R3::Internal::Scanless::R::TRACE_FILE_HANDLE] =
        $slg->[Marpa::R3::Internal::Scanless::G::TRACE_FILE_HANDLE];

    my $lua = $slg->[Marpa::R3::Internal::Scanless::G::L];
    $slr->[Marpa::R3::Internal::Scanless::R::L] = $lua;
    $slr->[Marpa::R3::Internal::Scanless::R::EVENTS] = [];

  my ($regix) = $slg->call_by_tag (
    ('@' . __FILE__ . ':' . __LINE__),
    <<'END_OF_LUA', '');
    local slg = ...
    return slg:slr_new()
END_OF_LUA

    $slr->[Marpa::R3::Internal::Scanless::R::REGIX]      = $regix;

    common_set( $slr, "new",  $flat_args );

    my $trace_file_handle =
        $slr->[Marpa::R3::Internal::Scanless::R::TRACE_FILE_HANDLE];

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

    $slr->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 'si', $event_name, ($is_active ? 1 : undef));
        local slr, event_name, activate = ...
        return slr:activate_by_event_name(event_name, activate)
END_OF_LUA

    } ## end EVENT: for my $event_name ( keys %{$event_is_active_arg} )

        $slr->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', '' );
        local recce = ...
        local g1r = recce.g1
        local return_value = g1r:start_input()
        if return_value == -1 then
            error( string.format('Recognizer start of input failed: %s',
                recce.slg.g1.error_description()))
        end
        if return_value < 0 then
            error( string.format('Problem in start_input(): %s',
                recce.slg.g1.error_description()))
        end
        recce:g1_convert_events()
END_OF_LUA

    {
        my ($trace_terminals) = $slr->call_by_tag(
    ('@' . __FILE__ . ':' . __LINE__),
            <<'END_OF_LUA', '');
        local recce = ...
        return recce.trace_terminals
END_OF_LUA

        if ( $trace_terminals > 1 ) {
            my $terminals_expected = $slr->terminals_expected();
            for my $terminal ( sort @{$terminals_expected} ) {

       # We may have set and reset the trace file handle during this method,
       # so we do not memoize its value, bjut get it directly
                say { $trace_file_handle }
                  qq{Expecting "$terminal" at earleme 0}
                  or Marpa::R3::exception("Cannot print: $ERRNO");
            }
        }
    }

    my ($trace_msgs, $events) = $slr->call_by_tag(
    ('@' . __FILE__ . ':' . __LINE__),
    <<'END_OF_LUA', '');
    local slr = ...

    slr.token_values = {}
    slr.token_is_undef = 1
    slr.token_values[slr.token_is_undef] = glue.sv.undef()

    -- token is literal is a pseudo-index, and the SV undef
    -- is just a place holder
    slr.token_is_literal = 2
    slr.token_values[slr.token_is_literal] = glue.sv.undef()

    return glue.convert_libmarpa_events(slr)

END_OF_LUA

    for my $msg (@{$trace_msgs}) {
        say {$trace_file_handle} $msg;
    }

    $slr->[Marpa::R3::Internal::Scanless::R::EVENTS] = $events;

    return $slr;
} ## end sub Marpa::R3::Scanless::R::new

sub Marpa::R3::Scanless::R::DESTROY {
    # say STDERR "In Marpa::R3::Scanless::R::DESTROY before test";
    my $slr = shift;
    my $lua = $slr->[Marpa::R3::Internal::Scanless::R::L];

    # If we are destroying the Perl interpreter, then all the Marpa
    # objects will be destroyed, including Marpa's Lua interpreter.
    # We do not need to worry about cleaning up the
    # recognizer is an orderly manner, because the Lua interpreter
    # containing the recognizer will be destroyed.
    # In fact, the Lua interpreter may already have been destroyed,
    # so this test is necessary to avoid a warning message.
    return if not $lua;
    # say STDERR "In Marpa::R3::Scanless::R::DESTROY after test";

    my $regix = $slr->[Marpa::R3::Internal::Scanless::R::REGIX];
    $lua->call_by_tag($regix,
        ('@' . __FILE__ . ':' . __LINE__),
        <<'END_OF_LUA', 'i', $regix);
    local slr, regix = ...
    slr:valuation_reset()
    local registry = debug.getregistry()
    _M.unregister(registry, regix)
END_OF_LUA
}

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
          qw(trace_terminals trace_file_handle
          end max_parses too_many_earley_items
          trace_values)
    };
    state $set_method_args = { map { ( $_, 1 ); } keys %{$common_recce_args} };
    state $new_method_args = {
        map { ( $_, 1 ); }
          qw(grammar event_is_active),
        keys %{$set_method_args}
    };
    state $series_restart_method_args =
      { map { ( $_, 1 ); } keys %{$common_recce_args} };

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
        if ($normalized_value) {
            say {$trace_file_handle} qq{Setting trace_terminals option};
        }
        $slr->call_by_tag(
    ('@' . __FILE__ . ':' . __LINE__),
        <<'END_OF_LUA',
            local slr, trace_terminals = ...
            slr.trace_terminals = trace_terminals
END_OF_LUA
            'i', $normalized_value);
    }

    if ( defined( my $value = $flat_args->{'max_parses'}) ) {
        $slr->call_by_tag(
            ( '@' . __FILE__ . ':' . __LINE__ ),
            <<'END_OF_LUA', 'i', $value
    local slr, value = ...
    slr.max_parses = value
END_OF_LUA
        );
    }

    if ( defined( my $value = $flat_args->{'trace_values'} ) ) {
        my $value = $flat_args->{'trace_values'};
        my $normalized_value =
          Scalar::Util::looks_like_number($value) ? $value : 0;
        if ($normalized_value) {
            say {$trace_file_handle} qq{Setting trace_values option to $value};
        }
        $slr->call_by_tag(
    ('@' . __FILE__ . ':' . __LINE__),
        <<'END_OF_LUA',
            local slr, trace_values = ...
            slr.trace_values = trace_values
END_OF_LUA
            'i', $normalized_value);

    } ## end if ( defined( my $value = $flat_args->{'trace_values'} ) )

    if ( defined( my $value = $flat_args->{'too_many_earley_items'} ) ) {
        $slr->call_by_tag(
            ('@' . __FILE__ . ':' . __LINE__ ),
            <<'END_OF_LUA', 'i', $value
    local slr, value = ...
    slr.too_many_earley_items = value
    slr.g1:earley_item_warning_threshold_set(value)
END_OF_LUA
        );
    }

    if ( defined( my $value = $flat_args->{'end'} ) ) {

        $slr->call_by_tag(
    ('@' . __FILE__ . ':' . __LINE__),
            <<'END_OF_LUA', 'i', $value);
            local recce, value = ...
            -- Not allowed once evaluation is started
            if recce.lmw_b then
                error'Cannot reset end once evaluation has started'
            end
            recce.end_of_parse = value
END_OF_LUA
    } ## end if ( defined( my $value = $arg_hash->{'end'} ) )

}

sub Marpa::R3::Scanless::R::read {
    my ( $slr, $p_string, $start_pos, $length ) = @_;
    my $slg              = $slr->[Marpa::R3::Internal::Scanless::R::SLG];

    Marpa::R3::exception(
    q{Attempt to use a tainted input string in $slr->read()},
    qq{\n  Marpa::R3 is insecure for use with tainted data\n}
    ) if Scalar::Util::tainted(${$p_string});

    $start_pos //= 0;
    $length    //= -1;

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

    my ($new_codepoints, $trace_terminals) = $slr->call_by_tag(
    ('@' . __FILE__ . ':' . __LINE__),
        <<'END_OF_LUA', 's', ${$p_string});
            local slr, input_string = ...
            local inputs = slr.inputs
            local this_input = {}
            inputs[#inputs + 1] = this_input
            slr.current_block = this_input
            this_input.text = input_string
            this_input.index = #inputs
            local ix = 1

            local eols = {
                [0x0A] = 0x0A,
                [0x0D] = 0x0D,
                [0x0085] = 0x0085,
                [0x000B] = 0x000B,
                [0x000C] = 0x000C,
                [0x2028] = 0x2028,
                [0x2029] = 0x2029
            }
            local eol_seen = false
            local line_no = 1
            local column_no = 0
            local codepoint_seen = {}
            local per_codepoint = slr.slg.per_codepoint
            for byte_p, codepoint in utf8.codes(input_string) do

                if not per_codepoint[codepoint] then
                   codepoint_seen[codepoint] = true
                end

                -- line numbering logic
                if eol_seen and
                   (eol_seen ~= 0x0D or codepoint ~= 0x0A) then
                   eol_seen = false
                   line_no = line_no + 1
                   column_no = 0
                end
                column_no = column_no + 1
                eol_seen = eols[codepoint]

                local vlq = _M.to_vlq({ byte_p, line_no, column_no })
                this_input[#this_input+1] = vlq
            end

            slr.phase = 'read'

            local new_codepoints = {}
            for codepoint, _ in pairs(codepoint_seen) do
                new_codepoints[#new_codepoints+1] = codepoint
            end
            return new_codepoints, slr.trace_terminals
END_OF_LUA

    my $character_class_table =
      $slg->[Marpa::R3::Internal::Scanless::G::CHARACTER_CLASS_TABLE];

    my @codepoint_cmds = ();
    # say STDERR "new_codepoints: ", Data::Dumper::Dumper($new_codepoints);
        for my $codepoint (@{$new_codepoints})
        {
            my $character = pack('U', $codepoint);
            my $is_graphic = ( $character =~ m/[[:graph:]]+/ ) ? 1 : 0;

            my @symbols;
            for my $entry ( @{$character_class_table} ) {

                my ( $symbol_id, $re ) = @{$entry};

                # say STDERR "Codepoint %x vs $re\n";

                if ( $character =~ $re ) {

                    if ( $trace_terminals >= 2 ) {
                        my $trace_file_handle = $slr->[
                          Marpa::R3::Internal::Scanless::R::TRACE_FILE_HANDLE];
                        my $char_desc = character_describe($slr, $codepoint);
                        say {$trace_file_handle}
qq{Registering character $char_desc as symbol $symbol_id: },
                          $slg->l0_symbol_display_form($symbol_id)
                          or Marpa::R3::exception("Could not say(): $ERRNO");
                    } ## end if ( $trace_terminals >= 2 )

                    push @symbols, $symbol_id;

                } ## end if ( $character =~ $re )
            } ## end for my $entry ( @{$character_class_table} )

            if (not scalar @symbols) {
                my $char_desc = character_describe($slr, $codepoint);
                Marpa::R3::exception("Character in input is not in alphabet of grammar: $char_desc\n");
            }
            push @codepoint_cmds, [ 'symbols', $codepoint, \@symbols ];
            push @codepoint_cmds, [ 'is_graphic', $codepoint, $is_graphic ]
               if $is_graphic;

        }

    # The argument is a sequence of "codepoint commands", each
    # of which is a sequence: `[command, codepoint, value ]`
    #
    # There are two commands.  The "symbols" command tells Kollos
    # to create a per-codepoint structure.  The `value` is a sequence
    # of symbols, used to populate the codepoint.  Kollos will recognize
    # that codepoint as each of that set of symbols.  (Codepoints can
    # be, and often are, ambiguous.)
    #
    # The other command is "is_graphic".  It set or unsets the
    # `is_graphic` boolean for the codepoint.  The per-codepoint
    # structure must already exist.
    $slr->call_by_tag( ('@' . __FILE__ . ':' . __LINE__),
        <<'END_OF_LUA', 'i', \@codepoint_cmds);
        local slr, codepoint_cmds = ...
        local per_codepoint = slr.slg.per_codepoint
        for cmd_ix = 1, #codepoint_cmds do
             local cmd, codepoint, value = table.unpack(codepoint_cmds[cmd_ix])
             if cmd == 'symbols' then
                  per_codepoint[codepoint] = value
                  goto NEXT_COMMAND
             end
             if cmd == 'is_graphic' then
                  per_codepoint[codepoint].is_graphic
                      = value ~= 0 and true or nil
                  goto NEXT_COMMAND
             end
             ::NEXT_COMMAND::
        end
END_OF_LUA

    my $event_count = scalar
        @{$slr->[Marpa::R3::Internal::Scanless::R::EVENTS]};

    return 0 if $event_count > 0;

    return $slr->resume( $start_pos, $length );

} ## end sub Marpa::R3::Scanless::R::read

sub Marpa::R3::Scanless::R::resume {
    my ( $slr, $start_pos, $length ) = @_;
    my $trace_file_handle =
      $slr->[Marpa::R3::Internal::Scanless::R::TRACE_FILE_HANDLE];
    my $result;

    # say STDERR join " ", __FILE__, __LINE__, Data::Dumper::Dumper($result);
  FOR_LUA: {
        $slr->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
            <<'END_OF_LUA', 'ii', $start_pos, $length );
            local slr, start_pos_arg, length_arg = ...

            if #slr.inputs <= 0 then
                error(
                    "Attempt to resume an SLIF recce which has no string set\n"
                    .. '  The string should be set first using read()'
                )
            end

            if slr.phase ~= 'read' then
                if slr.phase == 'value' then
                    error(
                        "Attempt to resume an SLIF slr while the parse is being evaluated\n"
                        .. '   The resume() method is not allowed once value() is called'
                    )
                end
                error(
                    "Attempt to resume an SLIF slr which is not in the Read Phase\n"
                    .. '   The resume() method is only allowed in the Read Phase'
                )
            end

           slr:pos_set(start_pos_arg, length_arg)
END_OF_LUA

      OUTER_READ: while (1) {

            my ( $ok, $trace_msgs, $events ) =
              $slr->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
                <<'END_OF_LUA', '' );
            local slr = ...
            local ok = slr:read()
            local trace_msgs, events = glue.convert_libmarpa_events(slr)
            return ok, trace_msgs, events
END_OF_LUA

            $slr->[Marpa::R3::Internal::Scanless::R::EVENTS] = $events;

            for my $msg ( @{$trace_msgs} ) {
                say {$trace_file_handle} $msg;
            }

            last OUTER_READ if $ok;
            last OUTER_READ if scalar @{$events}

        } ## end OUTER_READ: while (1)

        $result = $slr->pos();
    }
    return $result;
} ## end sub Marpa::R3::Scanless::R::resume

sub Marpa::R3::Scanless::R::events {
    my ($slr) = @_;
    my $events = $slr->[Marpa::R3::Internal::Scanless::R::EVENTS];
    # say Data::Dumper::Dumper($events);
    return $events // [];
}

sub character_describe {
    my ($slr, $codepoint) = @_;

    my ($desc) = $slr->call_by_tag(
    ('@' . __FILE__ . ':' . __LINE__),
    <<'END__OF_LUA', 'i', $codepoint );
    local slr, codepoint = ...
    return slr:character_describe(codepoint)
END__OF_LUA

    return $desc;
} ## end sub character_describe

sub Marpa::R3::Scanless::R::ambiguity_metric {
    my ($slr) = @_;

    my ($metric) = $slr->call_by_tag(
    ('@' . __FILE__ . ':' . __LINE__),
    <<'END__OF_LUA', '>*' );
    local recce = ...
    local order = recce:ordering_get()
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
    my ( $slg, $input_ref, @more_args ) = @_;
    if ( not defined $input_ref or ref $input_ref ne 'SCALAR' ) {
        Marpa::R3::exception(
            q{$slr->parse(): first argument must be a ref to string});
    }
    my @recce_args = ( { grammar => $slg } );
    if ( grep { ref $_ ne 'HASH' } @more_args ) {
        Marpa::R3::exception(
            q{$slr->parse(): second and later arguments must be ref to HASH});
    }
    my $slr = Marpa::R3::Scanless::R->new( @recce_args, @more_args,
        );
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

    $slr->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        'local recce = ...; recce.phase = "read"', '' );
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

    $slr->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
    <<'END_OF_LUA', '' );
        local slr = ...
        slr:valuation_reset()
END_OF_LUA

    return;
}

# Brief description of block/line/column for
# an L0 range
sub lc_brief {
    my ( $slr, $pos, $block )     = @_;
    my ($result) = $slr->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
    <<'END_OF_LUA', 'ii', $pos, ($block // -1));
        local slr, pos, block = ...
        if block < 0 then block = nil end
        return slr:lc_brief(pos, block)
END_OF_LUA
     return $result;
}

# Brief description of block/line/column for
# an L0 range
sub lc_range_brief {
    my ( $slr, $first_block, $first_pos, $last_block, $last_pos ) = @_;
    my ($result) = $slr->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 'iiii', $first_block, $first_pos, $last_block, $last_pos );
        local slr, block1, pos1, block2, pos2 = ...
        return slr:lc_range_brief(block1, pos1, block2, pos2)
END_OF_LUA
     return $result;

}

sub Marpa::R3::Scanless::R::show_progress {
    my ( $slr, $start_ordinal, $end_ordinal ) = @_;
    my $slg = $slr->[Marpa::R3::Internal::Scanless::R::SLG];

    my ($last_ordinal) = $slr->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        'local recce = ...; return recce.g1:latest_earley_set()', '' );

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
                ($position) = $slg->call_by_tag(
                    ( '@' . __FILE__ . ':' . __LINE__ ),
'local grammar, rule_id = ...; return grammar.g1:rule_length(rule_id)',
                    'i',
                    $rule_id
                );
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

                my ($rhs_length) = $slg->call_by_tag(
                    ( '@' . __FILE__ . ':' . __LINE__ ),
'local grammar, rule_id = ...; return grammar.g1:rule_length(rule_id)',
                    'i',
                    $rule_id
                );
                my @item_text;

                my $dotted_type = "R";
                if ( $position >= $rhs_length ) {
                    $dotted_type = "F";
                    push @item_text, "F$rule_id";
                }
                elsif ($position) {
                    push @item_text, "R$rule_id:$position";
                }
                else {
                    $dotted_type = "P";
                    push @item_text, "P$rule_id";
                }
                push @item_text, "x$origins_count" if $origins_count > 1;
                push @item_text, q{@} . $origin_desc . q{-} . $current_earleme;

                # For origins[0], we apply
                # -1 to convert earley set to G1, then
                # +1 one because it is an origin and the character
                # don't begin until the next Earley set
                # -- in other words, they balance and we do nothing

                my ($input_range) =
                  $slr->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
                    <<'END_OF_LUA', 'sii', $dotted_type, ($origins[0]+0), $current_ordinal );
    local slr, dotted_type, g1_first, current_ordinal = ...
    if current_ordinal <= 0 then return 'B0L0c0' end
    if dotted_type == 'P' then
        local block, pos = slr:g1_pos_to_l0_first(current_ordinal)
        return slr:lc_brief(pos, block)
    end
    if g1_first < 0 then g1_first = 0 end
    local g1_last = current_ordinal - 1
    local l0_first_b, l0_first_p = slr:g1_pos_to_l0_first(g1_first)
    local l0_last_b, l0_last_p = slr:g1_pos_to_l0_last(g1_last)
    return slr:lc_range_brief(l0_first_b, l0_first_p, l0_last_b, l0_last_p)
END_OF_LUA

                push @item_text, $input_range;

                push @item_text, $slg->show_dotted_rule( $rule_id, $position );
                $text .= ( join q{ }, @item_text ) . "\n";
            } ## end for my $position ( sort { $a <=> $b } keys %{...})
        } ## end for my $rule_id ( sort { $a <=> $b } keys ...)

    } ## end for my $current_ordinal ( $start_ordinal .. $end_ordinal)
    return $text;
}

sub Marpa::R3::Scanless::R::progress {
    my ( $slr, $ordinal_arg ) = @_;

    my ($result) = $slr->call_by_tag(
        ('@' . __FILE__ . ':' . __LINE__),
    <<'END_OF_LUA', 'i>0', ($ordinal_arg // -1));
    local recce, ordinal_arg = ...
    return recce:progress(ordinal_arg)
END_OF_LUA

    return $result;
}

sub Marpa::R3::Scanless::R::terminals_expected {
    my ($slr)      = @_;
    my $slg        = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
    my ($terminals_expected) = $slr->call_by_tag(
    ('@' . __FILE__ . ':' . __LINE__),
    <<'END_OF_LUA', '>0');
    local recce = ...
    local terminals_expected = recce.g1:terminals_expected()
    return terminals_expected
END_OF_LUA

    return [ map { $slg->symbol_name($_) } @{$terminals_expected} ];
}

sub Marpa::R3::Scanless::R::exhausted {
    my ($slr) = @_;
    my ($is_exhausted) = $slr->call_by_tag(
    ('@' . __FILE__ . ':' . __LINE__),
    <<'END_OF_LUA', '');
    local recce = ...
    local is_exhausted = recce.g1:is_exhausted()
    return is_exhausted
END_OF_LUA
    return $is_exhausted;
}

# Latest and current G1 location are the same
sub Marpa::R3::Scanless::R::g1_pos {
    my ($slr) = @_;
    my ($latest_earley_set) = $slr->call_by_tag(
    ('@' . __FILE__ . ':' . __LINE__),
    <<'END_OF_LUA', '');
    local recce = ...
    local latest_earley_set = recce.g1:latest_earley_set()
    return latest_earley_set
END_OF_LUA
    return $latest_earley_set;
}

sub Marpa::R3::Scanless::R::current_earleme {
    my ($slr) = @_;
    my ($current_earleme) = $slr->call_by_tag(
    ('@' . __FILE__ . ':' . __LINE__),
    <<'END_OF_LUA', '');
    local recce = ...
    local current_earleme = recce.g1:current_earleme()
    return current_earleme
END_OF_LUA
    return $current_earleme;
}

# Not documented, I think
sub Marpa::R3::Scanless::R::furthest_earleme {
    my ($slr) = @_;
    my ($furthest_earleme) = $slr->call_by_tag(
    ('@' . __FILE__ . ':' . __LINE__),
        <<'END_OF_LUA', '');
    local recce = ...
    local furthest_earleme = recce.g1:furthest_earleme()
    return furthest_earleme
END_OF_LUA
    return $furthest_earleme;
}

sub Marpa::R3::Scanless::R::earleme {
    my ( $slr, $earley_set_id ) = @_;
    my ($earleme) = $slr->call_by_tag(
    ('@' . __FILE__ . ':' . __LINE__),
        <<'END_OF_LUA', 'i', $earley_set_id);
    local recce, earley_set_id = ...
    local earleme = recce.g1:earleme(earley_set_id)
    return earleme
END_OF_LUA
    return $earleme;
}

sub Marpa::R3::Scanless::R::lexeme_alternative {
    my ( $slr, $symbol_name, @value ) = @_;

    Marpa::R3::exception(
        "slr->alternative(): symbol name is undefined\n",
        "    The symbol name cannot be undefined\n"
    ) if not defined $symbol_name;

    my $slg        = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
    my $symbol_id  = $slg->symbol_by_name($symbol_name);
    if ( not defined $symbol_id ) {
        Marpa::R3::exception(
            qq{slr->alternative(): symbol "$symbol_name" does not exist});
    }

    if (Scalar::Util::tainted($value[1])) {
        Marpa::R3::exception(
              "Problem in Marpa::R3: Attempt to use a tainted token value\n",
              "Marpa::R3 is insecure for use with tainted data\n");
    }
    my $result;
  DO_ALTERNATIVE: {
        if ( scalar @value == 0 ) {
            ($result) = $slr->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
                <<'END_OF_LUA', 'i', $symbol_id );
        local slr, symbol_id = ...
        local token_ix = _M.defines.TOKEN_VALUE_IS_LITERAL
        local g1r = slr.g1
        slr.is_external_scanning = true
        local return_value = g1r:alternative(symbol_id, token_ix, 1)
        return return_value
END_OF_LUA
            last DO_ALTERNATIVE;
        }
        my $value = $value[0];
        if ( not defined $value ) {
            ($result) = $slr->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
                <<'END_OF_LUA', 'i', $symbol_id );
        local slr, symbol_id = ...
        local token_ix = _M.defines.TOKEN_VALUE_IS_UNDEF
        local g1r = slr.g1
        slr.is_external_scanning = true
        local return_value = g1r:alternative(symbol_id, token_ix, 1)
        return return_value
END_OF_LUA
            last DO_ALTERNATIVE;
        }
            ($result) = $slr->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
                <<'END_OF_LUA', 'iS', $symbol_id, $value );
        local slr, symbol_id, token_sv = ...
        local token_ix = #slr.token_values + 1
        slr.token_values[token_ix] = token_sv
        local g1r = slr.g1
        slr.is_external_scanning = true
        local return_value = g1r:alternative(symbol_id, token_ix, 1)
        return return_value
END_OF_LUA
    }
    return 1 if $result == $Marpa::R3::Error::NONE;

    # The last two are perhaps unnecessary or arguable,
    # but they preserve compatibility with Marpa::XS
    return
        if $result == $Marpa::R3::Error::UNEXPECTED_TOKEN_ID
            || $result == $Marpa::R3::Error::NO_TOKEN_EXPECTED_HERE
            || $result == $Marpa::R3::Error::INACCESSIBLE_TOKEN;

    my ($error_description)
    = $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        'local grammar = ...; return grammar.g1:error_description()', '');
    Marpa::R3::exception( qq{Problem reading symbol "$symbol_name": },
        $error_description );
} ## end sub Marpa::R3::Scanless::R::lexeme_alternative

# Returns 0 on unthrown failure, current location on success
sub Marpa::R3::Scanless::R::lexeme_complete {
    my ( $slr, $start, $length ) = @_;

    my ($return_value, $trace_msgs, $events) = $slr->call_by_tag(
        ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 'ii', $start, $length );
      local slr, start_arg, length_arg = ...
      local start = start_arg
      if start then
         start = math.tointeger(start)
         if not start then
             error("lexeme_complete(): %s is not an integer", start_arg)
         end
      end
      local longueur = length_arg
      if longueur then
          longueur = math.tointeger(longueur)
          if not longueur then
              error("lexeme_complete(): %s is not an integer", length_arg)
          end
      end
      local complete_val = slr:ext_lexeme_complete(start, longueur)
      if complete_val == 0 then
          local slg = slr.slg
          slg.g1.error()
      end
      local trace_msgs, events = glue.convert_libmarpa_events(slr)
      return complete_val, trace_msgs, events
END_OF_LUA

    my $trace_file_handle =
        $slr->[Marpa::R3::Internal::Scanless::R::TRACE_FILE_HANDLE];
    for my $msg (@{$trace_msgs}) {
        say {$trace_file_handle} $msg;
    }

    $slr->[Marpa::R3::Internal::Scanless::R::EVENTS] = $events;

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
    my ($start, $end) = $slr->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
            <<'END_OF_LUA', ''  );
        local recce = ...
        local lexeme_start = recce.start_of_pause_lexeme
        local lexeme_end = recce.end_of_pause_lexeme
        if lexeme_end < 0 then return -1, -1 end
        local lexeme_length = lexeme_end - lexeme_start
        return lexeme_start, lexeme_end - lexeme_start
END_OF_LUA
    return if $start < 0;
    return $start, $end;
}

# TODO -- Document this method
sub Marpa::R3::Scanless::R::g1_to_l0_first {
    my ( $slr, $g1_pos ) = @_;
    return $slr->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 'i', $g1_pos  );
        local slr, g1_pos = ...
        return slr:g1_pos_to_l0_first(g1_pos)
END_OF_LUA
}

# TODO -- Document this method
sub Marpa::R3::Scanless::R::g1_to_l0_last {
    my ( $slr, $g1_pos ) = @_;
    return $slr->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 'i', $g1_pos  );
        local slr, g1_pos = ...
        return slr:g1_pos_to_l0_last(g1_pos)
END_OF_LUA
}

# TODO -- Document this method
sub Marpa::R3::Scanless::R::lc_brief {
    my ( $slr, $first_block, $first_pos, $last_block, $last_pos ) = @_;
    my ($desc) = $slr->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 'iiii', $first_block, $first_pos, $last_block, $last_pos );
        local slr, first_block, first_pos, last_block, last_pos = ...
        local function usage()
            error(
            "usage: $recce->lc_brief(first_block, first_pos, [last_block, last_pos])"
            )
        end
        if not first_block or not first_pos then
            return usage()
        end
        if last_block == nil or last_pos == nil then
            if last_block ~= nil or last_pos ~= nil then
                return usage()
            end
            last_block = first_block
            last_pos = first_pos
        end
        return slr:lc_range_brief(
            first_block, first_pos, last_block, last_pos)
END_OF_LUA
    return $desc;
}

# TODO -- Document $block parameter
sub Marpa::R3::Scanless::R::line_column {
    my ( $slr, $pos, $block ) = @_;
    $pos //= $slr->pos();
    $block //= -1;

    my ($line_no, $column_no) = $slr->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
            <<'END_OF_LUA', 'ii', $block, $pos  );
        local slr, block, pos = ...
        if block <= 0 then block = slr.current_block.index end
        local _, line_no, column_no = slr:per_pos(block, pos)
        return line_no, column_no
END_OF_LUA

    return $line_no, $column_no;
} ## end sub Marpa::R3::Scanless::R::line_column

# TODO -- Document block_ix result
# TODO -- Delete this in favor of l0_where()?
sub Marpa::R3::Scanless::R::pos {
    my ($slr) = @_;
    my ($l0_pos) = $slr->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
            <<'END_OF_LUA', '' );
        local slr = ...
        local _, l0_pos = slr:l0_where()
        return l0_pos
END_OF_LUA
    return $l0_pos;
}

# TODO -- Document block_ix result
sub Marpa::R3::Scanless::R::l0_where {
    my ($slr) = @_;
    my ($l0_pos, $block_ix) = $slr->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
            <<'END_OF_LUA', '' );
        local slr = ...
        local block_ix, l0_pos = slr:l0_where()
        return l0_pos, block_ix
END_OF_LUA
    return $l0_pos, $block_ix;
}

# TODO -- Document block_ix argument
sub Marpa::R3::Scanless::R::input_length {
    my ( $slr, $block_ix ) = @_;
    my ($length) = $slr->call_by_tag(
        ('@' . __FILE__ . ':' . __LINE__),
    <<'END_OF_LUA', 'i', ($block_ix // -1));
        local slr, block_ix  = ...
        local block = block_ix > 0 and slr.inputs[block_ix] or slr.current_block
        return #block
END_OF_LUA

    return $length;
}

# no return value documented
sub Marpa::R3::Scanless::R::activate {
    my ( $slr, $event_name, $activate ) = @_;
    my $slg = $slr->[Marpa::R3::Internal::Scanless::R::SLG];

    $slr->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 'si', $event_name, $activate);
        local slr, event_name, activate = ...
        if not activate then
           activate = 1
        else
           activate = activate ~= 0
        end
        -- print('$slr->activate():', event_name, activate)
        return slr:activate_by_event_name(event_name, activate)
END_OF_LUA

    return 1;
}

# On success, returns the old priority value.
# Failures are thrown.
sub Marpa::R3::Scanless::R::lexeme_priority_set {
    my ( $slr, $lexeme_name, $new_priority ) = @_;
    my ($old_priority) = $slr->call_by_tag(
    ('@' . __FILE__ . ':' . __LINE__),
        <<'END_OF_LUA', 'si>*', $lexeme_name, $new_priority );
        local recce, lexeme_name, new_priority = ...
        local slg = recce.slg
        local g1g = slg.g1
        local lexeme_id = g1g.isyid_by_name[lexeme_name]
        if not lexeme_id then
            _M.userX(string.format(
                "lexeme_priority_set(): no such symbol as %q",
                lexeme_name
            ))
        end
        if type(new_priority) ~= 'number' then
            _M.userX(string.format(
                "lexeme_priority_set(): priority is not a number, it is %s",
                new_priority
            ))
        end
        local g_lexeme_data = slg.g1.isys[lexeme_id]
        local r_lexeme_data = recce.g1_isys[lexeme_id]
        if not g_lexeme_data.is_lexeme then
            print(inspect(lexeme_data))
            _M.userX(string.format(
                "lexeme_priority_set(): %q is not a lexeme",
                lexeme_name
            ))
        end
        local old_priority = r_lexeme_data.lexeme_priority
        r_lexeme_data.lexeme_priority = new_priority
        return old_priority
END_OF_LUA

    return $old_priority;
}

# Internal methods, not to be documented

# not to be documented
sub Marpa::R3::Scanless::R::call_by_tag {
    my ( $slr, $tag, $codestr, $signature, @args ) = @_;
    my $lua   = $slr->[Marpa::R3::Internal::Scanless::R::L];
    my $regix = $slr->[Marpa::R3::Internal::Scanless::R::REGIX];

    # $DB::single = 1 if grep { not defined $_ } @args;
    my @results;
    my $eval_error;
    my $eval_ok;
    {
        local $@;
        $eval_ok = eval {
            @results =
              $lua->call_by_tag( $regix, $tag, $codestr, $signature, @args );
            return 1;
        };
        $eval_error = $@;
    }
    if ( not $eval_ok ) {
        Marpa::R3::exception($eval_error);
    }
    return @results;
}

# not to be documented
sub Marpa::R3::Scanless::R::earley_set_size {
    my ($slr, $set_id) = @_;
    my ($size) = $slr->call_by_tag(
    ('@' . __FILE__ . ':' . __LINE__),
        <<'END_OF_LUA', 'i', ($set_id // -1));
    local recce, set_id = ...
    local g1r = recce.g1
    if set_id < 0 then set_id = g1r:lastest_earley_set() end
    return g1r:_earley_set_size(set_id)
END_OF_LUA
    return $size;
}

# not to be documented
sub Marpa::R3::Scanless::R::show_earley_sets {
    my ($slr)                = @_;

    my ($last_completed_earleme, $furthest_earleme) = $slr->call_by_tag(
    ('@' . __FILE__ . ':' . __LINE__),
        <<'END_OF_LUA', '');
        local recce = ...
        local g1r = recce.g1
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

# not to be documented
sub Marpa::R3::Scanless::R::show_earley_set {
    my ( $slr, $traced_set_id ) = @_;
    my $slg     = $slr->[Marpa::R3::Internal::Scanless::R::SLG];

    my ($set_data) =
      $slr->call_by_tag(
    ('@' . __FILE__ . ':' . __LINE__),
    <<'END_OF_LUA', 'i>2', $traced_set_id );
      local recce, traced_set_id = ...
      return recce:g1_earley_set_data(traced_set_id)
END_OF_LUA

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
          . $slg->show_dotted_irl( $irl_id, $dot_position );

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
                    my $ahm_desc = $slg->show_briefer_ahm($predecessor_ahm);
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
                my $ahm_desc       = $slg->show_briefer_ahm($ahm_id);

                my @pieces = ();
                if ( defined $predecessor_ahm_id ) {
                    my $predecessor_ahm_desc =
                      $slg->show_briefer_ahm($predecessor_ahm_id);
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
                my $ahm_desc = $slg->show_briefer_ahm($ahm_id);

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

# not to be documented
sub Marpa::R3::Scanless::R::show_or_nodes {
    my ( $slr ) = @_;

    my ($result) = $slr->call_by_tag(
    ('@' . __FILE__ . ':' . __LINE__),
    <<'END_OF_LUA', '');
    local recce = ...
    return recce:show_or_nodes()
END_OF_LUA

    return $result;
}

# not to be documented
sub Marpa::R3::Scanless::R::show_and_nodes {
    my ( $slr ) = @_;
    my ($result) = $slr->call_by_tag(
    ('@' . __FILE__ . ':' . __LINE__),
    <<'END_OF_LUA', '');
    local recce = ...
    return recce:show_and_nodes()
END_OF_LUA

    return $result;
}

# not to be documented
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

# not to be documented
sub Marpa::R3::Scanless::R::show_nook {
    my ( $slr, $nook_id, $verbose ) = @_;

    my ($or_node_id, $text) = $slr->call_by_tag(
    ('@' . __FILE__ . ':' . __LINE__),
    <<'END_OF_LUA', 'i', $nook_id);
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
    text = text .. " " .. recce:or_node_tag(or_node_id) .. ' p'
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
        ($this_choice) = $slr->call_by_tag(
    ('@' . __FILE__ . ':' . __LINE__),
            'local slr, nook_id = ...; return slr.lmw_t:_nook_choice(nook_id)',
            'i', $nook_id
        );
        CHOICE: for ( my $choice_ix = 0;; $choice_ix++ ) {

                my ($and_node_id) = $slr->call_by_tag(
    ('@' . __FILE__ . ':' . __LINE__),
                <<'END_OF_LUA', 'ii>*', $or_node_id, $choice_ix );
                local slr, or_node_id, choice_ix = ...
                return slr.lmw_o:_and_order_get(or_node_id+0, choice_ix+0)
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

# not to be documented
sub Marpa::R3::Scanless::R::show_bocage {
    my ($slr)     = @_;

    my ($result) = $slr->call_by_tag(
    ('@' . __FILE__ . ':' . __LINE__),
        <<'END_OF_LUA', '');
        local recce = ...
        return recce:show_bocage()
END_OF_LUA

    return $result;
}

# not to be documented
sub Marpa::R3::Scanless::R::verbose_or_node {
    my ( $slr, $or_node_id ) = @_;
    my ($text, $irl_id, $position)
        = $slr->call_by_tag(
    ('@' . __FILE__ . ':' . __LINE__),
        <<'END_OF_LUA', 'i', $or_node_id);
        local recce, or_node_id = ...
        local bocage = recce.lmw_b
        local origin = bocage:_or_node_origin(or_node_id)
        if not origin then return end
        local set = bocage:_or_node_set(or_node_id)
        local irl_id = bocage:_or_node_irl(or_node_id)
        local position = bocage:_or_node_position(or_node_id)
        local g1r = recce.g1
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
    $text .= ( q{ } x 4 )
        . $slg->show_dotted_irl( $irl_id, $position ) . "\n";
    return $text;
}

# not to be documented
sub Marpa::R3::Scanless::R::regix {
    my ( $slr ) = @_;
    my $regix = $slr->[Marpa::R3::Internal::Scanless::R::REGIX];
    return $regix;
}

1;

# vim: expandtab shiftwidth=4:
