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
$VERSION        = '4.001_050';
$STRING_VERSION = $VERSION;
## no critic(BuiltinFunctions::ProhibitStringyEval)
$VERSION = eval $VERSION;
## use critic

package Marpa::R3::Internal_R;

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
    my ($start, $length) = $slr->call_by_tag(
        ('@' . __FILE__ . ':' . __LINE__),
    <<'END_OF_LUA', 'i', $symbol_name);
        local slr, xsy_name  = ...
        local xsyid = slr.slg:symbol_by_name(xsy_name)
        if not xsyid then
            _M.userX(
                "last_completed(%q): no symbol with that name",
                xsy_name)
        end
        return slr:last_completed(xsyid)
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
sub Marpa::R3::Scanless::R::literal {
    my ( $slr, $block_id, $offset, $length ) = @_;
    my ($literal) = $slr->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 'iii', $block_id, $offset, $length );
    local slr, block_id_arg, offset_arg, length_arg = ...
    local block_id, offset, eoread
        = slr:block_check_range(block_id_arg, offset_arg, length_arg)
    if not block_id then
        -- if block == nil, offset is error message
        error(offset)
    end
    return slr:literal(block_id, offset, eoread-offset)
END_OF_LUA
    return $literal;
}

sub Marpa::R3::Internal::Scanless::meta_recce {
    my ($hash_args) = @_;
    state $meta_grammar = Marpa::R3::Internal::Scanless::meta_grammar();
    $hash_args->{grammar} = $meta_grammar;
    my $self = Marpa::R3::Scanless::R->new($hash_args);
    return $self;
} ## end sub Marpa::R3::Internal::Scanless::meta_recce

# Set those common args which are at the Perl level.
sub perl_common_set {
    my ( $slr, $flat_args ) = @_;
    if ( my $value = $flat_args->{'trace_file_handle'} ) {
        $slr->[Marpa::R3::Internal_R::TRACE_FILE_HANDLE] = $value;
    }
    my $trace_file_handle =
      $slr->[Marpa::R3::Internal_R::TRACE_FILE_HANDLE];
    delete $flat_args->{'trace_file_handle'};
    return $flat_args;
}

sub gen_app_event_handler {
    my ($slr) = @_;
    my $event_handlers =
      $slr->[Marpa::R3::Internal_R::EVENT_HANDLERS];
    return sub {
        my ( $event_type, $event_name, @data ) = @_;
        my $current_event =
          $slr->[Marpa::R3::Internal_R::CURRENT_EVENT];
        if ($current_event) {
            Marpa::R3::exception(
                qq{Attempt to throw call one event handler inside another\n},
                qq{  This is not allowed\n},
                qq{  The currently active handler is for a "$current_event" event\n},
                qq{  The attempted handler call is for a "$event_name" event\n}
            );
        }
        my $handler = $event_handlers->{$event_name};
        if ( not $handler ) {
            $handler = $event_handlers->{"'default"};
        }
        if ( not $handler ) {
            Marpa::R3::exception(
                qq{'No event handler for event "$event_name"\n});
        }
        if ( ref $handler ne 'CODE' ) {
            my $ref_type = ref $handler;
            Marpa::R3::exception(
                qq{Bad event handler for event "$event_name"\n},
                qq{  Handler is a ref to $ref_type\n},
                qq{  A handler should be a ref to code\n}
            );
        }
        $slr->[Marpa::R3::Internal_R::CURRENT_EVENT] = $event_name;
        my $retour = $handler->( $slr, $event_name, @data ) // 'ok';

        RETOUR_CHECK: {
            if ($retour eq 'ok') {
                if ($event_type eq 'before lexeme') {
                    Marpa::R3::exception(
                        qq{Bad return from event handler for event "$event_name"\n},
                        qq{  Event type was "$event_type"\n},
                        qq{  Return from handler was "$retour"\n},
                        qq{  A handler of type "$event_type" must return "pause"\n},
                    );
                }
                last RETOUR_CHECK;
            }
            last RETOUR_CHECK if $retour eq 'pause';
            Marpa::R3::exception(
                qq{Bad return from event handler for event "$event_name"\n},
                qq{  Event type was "$event_type"\n},
                qq{  Return from handler was "$retour"\n},
                qq{  Handler must return "ok" or "pause"\n},
            );
        }
        $slr->[Marpa::R3::Internal_R::CURRENT_EVENT] = undef;
        return 'ok', $retour;
    };
}

sub gen_codepoint_event_handler {
    my ($slr) = @_;
    my $slg = $slr->[Marpa::R3::Internal_R::SLG];
    my $character_class_table =
      $slg->[Marpa::R3::Internal_G::CHARACTER_CLASS_TABLE];

    return sub {
        my ( $codepoint, $trace_terminals ) = @_;
        my $character = pack( 'U', $codepoint );
        my $is_graphic = ( $character =~ m/[[:graph:]]+/ );

        my @symbols;
        for my $entry ( @{$character_class_table} ) {

            my ( $symbol_id, $re ) = @{$entry};

            # say STDERR "Codepoint %x vs $re\n";

            if ( $character =~ $re ) {

                if ( $trace_terminals >= 2 ) {
                    my $trace_file_handle =
                      $slr
                      ->[ Marpa::R3::Internal_R::TRACE_FILE_HANDLE ];
                    my $char_desc = character_describe( $slr, $codepoint );
                    say {$trace_file_handle}
qq{Registering character $char_desc as symbol $symbol_id: },
                      $slg->l0_symbol_display_form($symbol_id)
                      or Marpa::R3::exception("Could not say(): $ERRNO");
                } ## end if ( $trace_terminals >= 2 )

                push @symbols, $symbol_id;

            } ## end if ( $character =~ $re )
        } ## end for my $entry ( @{$character_class_table} )

        my $coro_arg = { symbols => \@symbols };
        $coro_arg->{is_graphic} = 'true' if $is_graphic;
        return 'ok', $coro_arg;
    };
}

sub Marpa::R3::Scanless::R::new {
    my ( $class, @args ) = @_;

    my $slr = [];
    bless $slr, $class;

    # Set recognizer args to default
    # Lua equivalent is set below

    my ( $flat_args, $error_message ) = Marpa::R3::flatten_hash_args( \@args );
    Marpa::R3::exception( sprintf $error_message, '$slr->new' )
      if not $flat_args;
    $flat_args = perl_common_set( $slr, $flat_args );

    my $slg = $flat_args->{grammar};
    Marpa::R3::exception(
        qq{Marpa::R3::Scanless::R::new() called without a "grammar" argument} )
      if not defined $slg;
    $slr->[Marpa::R3::Internal_R::SLG] = $slg;
    delete $flat_args->{grammar};

    my $event_handlers = $flat_args->{event_handlers} // {};
    $slr->[Marpa::R3::Internal_R::EVENT_HANDLERS] = $event_handlers;
    if ( ref $event_handlers ne 'HASH' ) {
        my $ref_type = ref $event_handlers;
        Marpa::R3::exception(
            qq{'event_handlers' named argument to new() is $ref_type\n},
            "  It should be a ref to a hash\n",
            "  whose keys are event names and\n",
            "  whose values are code refs\n"
        );
    }
    delete $flat_args->{event_handlers};

    my $slg_class = 'Marpa::R3::Scanless::G';
    if ( not blessed $slg or not $slg->isa($slg_class) ) {
        my $ref_type = ref $slg;
        my $desc = $ref_type ? "a ref to $ref_type" : 'not a ref';
        Marpa::R3::exception(
            qq{'grammar' named argument to new() is $desc\n},
            "  It should be a ref to $slg_class\n"
        );
    } ## end if ( not blessed $slg or not $slg->isa($slg_class) )

    $slr->[Marpa::R3::Internal_R::TRACE_FILE_HANDLE] //=
      $slg->[Marpa::R3::Internal_G::TRACE_FILE_HANDLE];

    my $trace_file_handle =
      $slr->[Marpa::R3::Internal_R::TRACE_FILE_HANDLE];

    my $lua = $slg->[Marpa::R3::Internal_G::L];
    $slr->[Marpa::R3::Internal_R::L] = $lua;

    my ( $regix ) = $slg->coro_by_tag(
        ( '@' . __FILE__ . ':' . __LINE__ ),
        {
            signature => 's',
            args      => [$flat_args],
            handlers  => {
                perl_undef => sub {
                    return 'sig', [ 'S', undef ];
                },
                trace => sub {
                    my ($msg) = @_;
                    say {$trace_file_handle} $msg;
                    return 'ok';
                },
                event => gen_app_event_handler($slr),
            }
        },
        <<'END_OF_LUA');
        local slg, flat_args = ...
        _M.wrap(function ()
            local slr = slg:slr_new(flat_args)
            return 'ok', slr.regix
        end)
END_OF_LUA

    $slr->[Marpa::R3::Internal_R::REGIX]  = $regix;

    $slr->coro_by_tag(
        ( '@' . __FILE__ . ':' . __LINE__ ),
        {
            signature => 's',
            args      => [$flat_args],
            handlers  => {
                trace => sub {
                    my ($msg) = @_;
                    say {$trace_file_handle} $msg;
                    return 'ok';
                },
                event => gen_app_event_handler($slr),
            }
        },
        <<'END_OF_LUA');
        local slr, flat_args = ...
        _M.wrap(function ()
            slr:convert_libmarpa_events()
            return 'ok'
        end)
END_OF_LUA

    return $slr;
} ## end sub Marpa::R3::Scanless::R::new

sub Marpa::R3::Scanless::R::DESTROY {
    # say STDERR "In Marpa::R3::Scanless::R::DESTROY before test";
    my $slr = shift;
    my $lua = $slr->[Marpa::R3::Internal_R::L];

    # If we are destroying the Perl interpreter, then all the Marpa
    # objects will be destroyed, including Marpa's Lua interpreter.
    # We do not need to worry about cleaning up the
    # recognizer is an orderly manner, because the Lua interpreter
    # containing the recognizer will be destroyed.
    # In fact, the Lua interpreter may already have been destroyed,
    # so this test is necessary to avoid a warning message.
    return if not $lua;
    # say STDERR "In Marpa::R3::Scanless::R::DESTROY after test";

    my $regix = $slr->[Marpa::R3::Internal_R::REGIX];
    $slr->call_by_tag(
        ('@' . __FILE__ . ':' . __LINE__),
        <<'END_OF_LUA', '');
    local slr = ...
    local regix = slr.regix
    _M.unregister(_M.registry, regix)
END_OF_LUA
}

sub Marpa::R3::Scanless::R::set {
    my ( $slr, @args ) = @_;

    my ($flat_args, $error_message) = Marpa::R3::flatten_hash_args(\@args);
    Marpa::R3::exception( sprintf $error_message, '$slr->set()' ) if not $flat_args;
    $flat_args = perl_common_set($slr, $flat_args);
    my $trace_file_handle =
      $slr->[Marpa::R3::Internal_R::TRACE_FILE_HANDLE];

    $slr->coro_by_tag(
        ( '@' . __FILE__ . ':' . __LINE__ ),
        {
            signature => 's',
            args      => [ $flat_args ],
            handlers  => {
                trace => sub {
                    my ($msg) = @_;
                    say {$trace_file_handle} $msg;
                    return 'ok';
                }
            }
        },
        <<'END_OF_LUA');
        local slr, flat_args = ...
        return _M.wrap(function ()
                slr:common_set(flat_args)
            end
        )
END_OF_LUA
    return;
} ## end sub Marpa::R3::Scanless::R::set

sub Marpa::R3::Scanless::R::read {
    my ( $slr, $p_string, $start_pos, $length ) = @_;
    if ( $slr->[Marpa::R3::Internal_R::CURRENT_EVENT] ) {
        Marpa::R3::exception(
            "$slr->read() called from inside a handler\n",
            "   This is not allowed\n",
            "   The event was ",
            $slr->[Marpa::R3::Internal_R::CURRENT_EVENT],
            "\n",
        );
    }
    my $slg = $slr->[Marpa::R3::Internal_R::SLG];

    my $block_id = $slr->block_new($p_string);
    $slr->block_set($block_id);
    $slr->block_move($start_pos, $length);
    return $slr->block_read();
}

sub Marpa::R3::Scanless::R::resume {
    my ( $slr, $start_pos, $length ) = @_;
    if ( $slr->[Marpa::R3::Internal_R::CURRENT_EVENT] ) {
        Marpa::R3::exception(
            "$slr->resume() called from inside a handler\n",
            "   This is not allowed\n",
            "   The event was ",
            $slr->[Marpa::R3::Internal_R::CURRENT_EVENT],
            "\n",
        );
    }
    my $trace_file_handle =
      $slr->[Marpa::R3::Internal_R::TRACE_FILE_HANDLE];
    $length //= -1;
    $slr->block_move( $start_pos, $length );
    return $slr->block_read();
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
    my $slv = Marpa::R3::Scanless::V->new( { recognizer => $slr });
    my $ambiguity_level = $slv->ambiguity_level();
    if ( $ambiguity_level != 1 ) {
        my $ambiguous_status = $slv->ambiguous();
        Marpa::R3::exception( "Parse of the input is ambiguous\n",
            $ambiguous_status );
    }

    my $value_ref = $slv->value();
    Marpa::R3::exception(
        '$slr->parse() read the input, but there was no parse', "\n" )
        if not $value_ref;

    return $value_ref;
} ## end sub Marpa::R3::Scanless::G::parse

# Brief description of block/line/column for
# an L0 range
sub lc_brief {
    my ( $slr, $pos, $block )     = @_;
    my ($result) = $slr->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
    <<'END_OF_LUA', 'ii', $pos, ($block // -1));
        local slr, pos, block = ...
        if block < 0 then block = nil end
        return slr:lc_brief(block, pos)
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

sub Marpa::R3::Scanless::R::progress_show {
    my ( $slr, $start_ordinal, $end_ordinal ) = @_;
    my ($text) = $slr->call_by_tag(
            ( '@' . __FILE__ . ':' . __LINE__ ),
            <<'END_OF_LUA', 'ii', $start_ordinal, $end_ordinal );
    local slr, start_ordinal_arg, end_ordinal_arg = ...
    return slr:progress_show(start_ordinal_arg, end_ordinal_arg )
END_OF_LUA
    return $text;
}

sub Marpa::R3::Scanless::R::progress {
    my ( $slr, $ordinal_arg ) = @_;
    my ($result) = $slr->call_by_tag(
        ('@' . __FILE__ . ':' . __LINE__),
    <<'END_OF_LUA', 'i>0', ($ordinal_arg // -1));
    local slr, ordinal_arg = ...
    return slr:progress(ordinal_arg)
END_OF_LUA
    return $result;
}

sub Marpa::R3::Scanless::R::g1_progress_show {
    my ( $slr, $start_ordinal, $end_ordinal ) = @_;
    my ($text) = $slr->call_by_tag(
            ( '@' . __FILE__ . ':' . __LINE__ ),
            <<'END_OF_LUA', 'ii', $start_ordinal, $end_ordinal );
    local slr, start_ordinal_arg, end_ordinal_arg = ...
    return slr:g1_progress_show(start_ordinal_arg, end_ordinal_arg )
END_OF_LUA
    return $text;
}

sub Marpa::R3::Scanless::R::g1_progress {
    my ( $slr, $ordinal_arg ) = @_;
    my ($result) = $slr->call_by_tag(
        ('@' . __FILE__ . ':' . __LINE__),
    <<'END_OF_LUA', 'i>0', ($ordinal_arg // -1));
    local slr, ordinal_arg = ...
    return slr:g1_progress(ordinal_arg)
END_OF_LUA
    return $result;
}

sub Marpa::R3::Scanless::R::terminals_expected {
    my ($slr)      = @_;
    my ($results) = $slr->call_by_tag(
    ('@' . __FILE__ . ':' . __LINE__),
    <<'END_OF_LUA', '');
    local slr = ...
    local slg = slr.slg
    local g1g = slg.g1
    local terminals_expected = slr.g1:terminals_expected()
    local results = {}
    for ix = 1, #terminals_expected do
        local g1_symbol_id = terminals_expected[ix]
        local xsy = g1g:_xsy(g1_symbol_id)
        if xsy then
            results[#results+1] = xsy.name
        end
    end
    return results
END_OF_LUA

    return $results;
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

sub Marpa::R3::Scanless::R::lexeme_alternative_literal {
    my ( $slr, $symbol_name ) = @_;

    Marpa::R3::exception(
        "slr->alternative_literal(): symbol name is undefined\n",
        "    The symbol name cannot be undefined\n"
    ) if not defined $symbol_name;

    my ($ok) = $slr->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 's', $symbol_name);
        local slr, symbol_name = ...
        return slr:lexeme_alternative_literal(symbol_name)
END_OF_LUA
    return 1 if $ok;
    return;
}

sub Marpa::R3::Scanless::R::lexeme_alternative {
    my ( $slr, $symbol_name, $value ) = @_;

    if ( Scalar::Util::tainted( $value ) ) {
        Marpa::R3::exception(
            "Problem in Marpa::R3: Attempt to use a tainted token value\n",
            "Marpa::R3 is insecure for use with tainted data\n"
        );
    }

    Marpa::R3::exception(
        "slr->alternative(): symbol name is undefined\n",
        "    The symbol name cannot be undefined\n"
    ) if not defined $symbol_name;

    my $ok;
    if (defined $value) {
    ($ok) = $slr->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 'sS', $symbol_name, $value );
        local slr, symbol_name, token_sv = ...
        return slr:lexeme_alternative(symbol_name, token_sv)
END_OF_LUA
    } else {
    ($ok) = $slr->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 's', $symbol_name );
        local slr, symbol_name = ...
        return slr:lexeme_alternative_undef(symbol_name )
END_OF_LUA
    }

    return 1 if $ok;
    return;
}

# Returns 0 on unthrown failure, current location on success
sub Marpa::R3::Scanless::R::lexeme_complete {
    my ( $slr, $block, $offset, $length ) = @_;
    if ( $slr->[Marpa::R3::Internal_R::CURRENT_EVENT] ) {
        Marpa::R3::exception(
            "$slr->lexeme_complete() called from inside a handler\n",
            "   This is not allowed\n",
            "   The event was ",
            $slr->[Marpa::R3::Internal_R::CURRENT_EVENT],
            "\n",
        );
    }

    my $trace_file_handle =
        $slr->[Marpa::R3::Internal_R::TRACE_FILE_HANDLE];

    my ($return_value) = $slr->coro_by_tag(
        ( '@' . __FILE__ . ':' . __LINE__ ),
        {
           signature => 'iii',
           args => [ $block, $offset, $length ],
           handlers => {
               trace => sub {
                    my ($msg) = @_;
                    say {$trace_file_handle} $msg;
                    return 'ok';
               },
               event => gen_app_event_handler($slr),
           }
        },
        <<'END_OF_LUA');
      local slr, block_id_arg, offset_arg, length_arg = ...
      local block_id, offset, eoread
          = slr:block_check_range(block_id_arg, offset_arg, length_arg)
      _M.wrap(function ()
          local new_offset = slr:lexeme_complete(block_id, offset, eoread-offset)
          slr:convert_libmarpa_events()
          return 'ok', new_offset
      end
      )
END_OF_LUA

    return $return_value;

} ## end sub Marpa::R3::Scanless::R::lexeme_complete

# Returns 0 on unthrown failure, current location on success,
# undef if lexeme not accepted.
sub Marpa::R3::Scanless::R::lexeme_read_literal {
    my ( $slr, $symbol_name, $block_id, $offset, $length ) = @_;
    if ( $slr->[Marpa::R3::Internal_R::CURRENT_EVENT] ) {
        Marpa::R3::exception(
            "$slr->lexeme_read_literal() called from inside a handler\n",
            "   This is not allowed\n",
            "   The event was ",
            $slr->[Marpa::R3::Internal_R::CURRENT_EVENT],
            "\n",
        );
    }
    my ($ok, $return_value) = $slr->coro_by_tag(
        ( '@' . __FILE__ . ':' . __LINE__ ),
        {
           signature => 'siii',
           args => [ $symbol_name, $block_id, $offset, $length ],
           handlers => {
               trace => sub {
                    my ($msg) = @_;
                    my $trace_file_handle =
                        $slr->[Marpa::R3::Internal_R::TRACE_FILE_HANDLE];
                    say {$trace_file_handle} $msg;
                    return 'ok';
               },
               codepoint => gen_codepoint_event_handler($slr),
               event => gen_app_event_handler($slr),
           }
        },
        <<'END_OF_LUA');
      local slr, symbol_name, block_id, offset, length = ...
      _M.wrap(function ()
          local offset = slr:lexeme_read_literal(symbol_name, block_id, offset, length )
          if not offset then return 'ok', 0 end
          return 'ok', 1, offset
      end
      )
END_OF_LUA

      return if not $ok;
      return $return_value;
}

# Returns 0 on unthrown failure, current location on success,
# undef if lexeme not accepted.
sub Marpa::R3::Scanless::R::lexeme_read_block {
    my ( $slr, $symbol_name, $value, $block_id, $offset, $length ) = @_;
    if ( $slr->[Marpa::R3::Internal_R::CURRENT_EVENT] ) {
        Marpa::R3::exception(
            "$slr->lexeme_read_block() called from inside a handler\n",
            "   This is not allowed\n",
            "   The event was ",
            $slr->[Marpa::R3::Internal_R::CURRENT_EVENT],
            "\n",
        );
    }
    if ( Scalar::Util::tainted( $value ) ) {
        Marpa::R3::exception(
            "Problem in Marpa::R3: Attempt to use a tainted token value\n",
            "Marpa::R3 is insecure for use with tainted data\n"
        );
    }
    my ($ok, $return_value) = $slr->coro_by_tag(
        ( '@' . __FILE__ . ':' . __LINE__ ),
        {
           signature => 'sSiii',
           args => [ $symbol_name, $value, $block_id, $offset, $length ],
           handlers => {
               trace => sub {
                    my ($msg) = @_;
                    my $trace_file_handle =
                        $slr->[Marpa::R3::Internal_R::TRACE_FILE_HANDLE];
                    say {$trace_file_handle} $msg;
                    return 'ok';
               },
               codepoint => gen_codepoint_event_handler($slr),
               event => gen_app_event_handler($slr),
           }
        },
        <<'END_OF_LUA');
      local slr, symbol_name, token_sv, block_id, offset, length = ...
      _M.wrap(function ()
          local offset = slr:lexeme_read_block(symbol_name, token_sv, block_id, offset, length )
          if not offset then return 'ok', 0 end
          return 'ok', 1, offset
      end
      )
END_OF_LUA

      return if not $ok;
      return $return_value;
}

# Returns 0 on unthrown failure, current location on success,
# undef if lexeme not accepted.
sub Marpa::R3::Scanless::R::lexeme_read_string {
    my ( $slr, $symbol_name, $string ) = @_;
    if ( $slr->[Marpa::R3::Internal_R::CURRENT_EVENT] ) {
        Marpa::R3::exception(
            '$recce->lexeme_read_string() called from inside a handler', "\n",
            "   This is not allowed\n",
            "   The event was ",
            $slr->[Marpa::R3::Internal_R::CURRENT_EVENT],
            "\n",
        );
    }

    my ($ok, $return_value) = $slr->coro_by_tag(
        ( '@' . __FILE__ . ':' . __LINE__ ),
        {
           signature => 'ss',
           args => [ $symbol_name, $string ],
           handlers => {
               trace => sub {
                    my ($msg) = @_;
                    my $trace_file_handle =
                        $slr->[Marpa::R3::Internal_R::TRACE_FILE_HANDLE];
                    say {$trace_file_handle} $msg;
                    return 'ok';
               },
               codepoint => gen_codepoint_event_handler($slr),
               event => gen_app_event_handler($slr),
           }
        },
        <<'END_OF_LUA');
      local slr, symbol_name, input_string = ...
      _M.wrap(function ()
          local offset = slr:lexeme_read_string(symbol_name, input_string )
          if not offset then return 'ok', 0 end
          return 'ok', 1, offset
      end
      )
END_OF_LUA

      return if not $ok;
      return $return_value;

}

sub Marpa::R3::Scanless::R::g1_to_block_first {
    my ( $slr, $g1_pos ) = @_;
    return $slr->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 'i', $g1_pos  );
        local slr, g1_pos = ...
        g1_pos = math.tointeger(g1_pos)
        if not g1_pos then
            _M.userX(
                "g1_to_block_first(%s): argument must be an integer",
                g1_pos)
        end
        return slr:g1_to_block_first(g1_pos)
END_OF_LUA
}

sub Marpa::R3::Scanless::R::g1_to_block_last {
    my ( $slr, $g1_pos ) = @_;
    return $slr->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 'i', $g1_pos  );
        local slr, g1_pos = ...
        g1_pos = math.tointeger(g1_pos)
        if not g1_pos then
            _M.userX(
                "g1_to_block_last(%s): argument must be an integer",
                g1_pos)
        end
        return slr:g1_to_block_last(g1_pos)
END_OF_LUA
}

# TODO -- Document this method ??
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

sub Marpa::R3::Scanless::R::line_column {
    my ( $slr, $block, $pos, ) = @_;
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

sub Marpa::R3::Scanless::R::block_new {
    my ( $slr, $p_string ) = @_;
    my $slg = $slr->[Marpa::R3::Internal_R::SLG];

    Marpa::R3::exception(
        q{Attempt to use a tainted input string in $slr->read()},
        qq{\n  Marpa::R3 is insecure for use with tainted data\n}
    ) if Scalar::Util::tainted( ${$p_string} );

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

    my $character_class_table =
      $slg->[Marpa::R3::Internal_G::CHARACTER_CLASS_TABLE];

    my ($block_id) = $slr->coro_by_tag(
        ( '@' . __FILE__ . ':' . __LINE__ ),
        {
            signature => 's',
            args      => [ ${$p_string} ],
            handlers  => {
                codepoint => gen_codepoint_event_handler($slr),
                event => gen_app_event_handler($slr),
            },
        },
        <<'END_OF_LUA');
            local slr, input_string = ...
            local new_block_id
            _M.wrap(function()
                    new_block_id = slr:block_new(input_string)
                    return 'ok', new_block_id
                end
            )
END_OF_LUA

    return $block_id;
}

sub Marpa::R3::Scanless::R::block_progress {
    my ($slr, $block_id) = @_;
    my ($l0_pos, $l0_end);
    ($block_id, $l0_pos, $l0_end)
        = $slr->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
            <<'END_OF_LUA', 'i', $block_id );
        local slr, block_id_arg = ...
        local block_id, erreur = slr:block_check_id(block_id_arg)
        if not block_id then
           error(erreur)
        end
        local l0_pos, l0_end
        block_id, l0_pos, l0_end = slr:block_progress(block_id)
        return block_id, l0_pos, l0_end
END_OF_LUA
    return $block_id, $l0_pos, $l0_end;
}

sub Marpa::R3::Scanless::R::block_set {
    my ($slr, $block_id) = @_;
    if ( $slr->[Marpa::R3::Internal_R::CURRENT_EVENT] ) {
        Marpa::R3::exception(
            "$slr->block_set() called from inside a handler\n",
            "   This is not allowed\n",
            "   The event was ",
            $slr->[Marpa::R3::Internal_R::CURRENT_EVENT],
            "\n",
        );
    }
    $slr->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
            <<'END_OF_LUA', 'i', $block_id );
        local slr, block_id_arg = ...
        local block_id, erreur = slr:block_check_id(block_id_arg)
        if not block_id then
           error(erreur)
        end
        return slr:block_set(block_id)
END_OF_LUA
    return;
}

# block_id defaults to current block
# block_offset defaults to don't set offset
# length defaults to don't set eoread
sub Marpa::R3::Scanless::R::block_move {
    my ($slr, $offset, $length) = @_;
    $slr->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
            <<'END_OF_LUA', 'ii', $offset, $length );
        local slr, offset_arg, length_arg = ...
        local ok, offset, eoread
            = slr:block_check_range(nil, offset_arg, length_arg)
        if not ok then
           -- new_block_offset is error message
           error(offset)
        end
        -- we don't set offset if the arg was nil
        local new_offset = offset_arg and offset or nil
        -- we don't set eoread if the length arg was nil
        local new_eoread = length_arg and eoread or nil
        return slr:block_move(new_offset, new_eoread)
END_OF_LUA
    return;
}

sub Marpa::R3::Scanless::R::block_read {
    my ($slr ) = @_;
    my ($offset) = $slr->coro_by_tag(
        ( '@' . __FILE__ . ':' . __LINE__ ),
        {
            signature => '',
            args => [],
            handlers => {
                trace => sub {
                    my ($msg) = @_;
                    my $trace_file_handle =
                        $slr->[Marpa::R3::Internal_R::TRACE_FILE_HANDLE];
                    say {$trace_file_handle} $msg;
                    return 'ok';
                },
                event => gen_app_event_handler($slr),
            }
        },
        <<'END_OF_LUA');
        local slr = ...
        _M.wrap(function ()
                local offset = slr:block_read()
                return 'ok', offset
            end
        )
END_OF_LUA
    return $offset;
}

sub Marpa::R3::Scanless::R::input_length {
    my ( $slr, $block_id ) = @_;
    my ($length) = $slr->call_by_tag(
        ('@' . __FILE__ . ':' . __LINE__),
    <<'END_OF_LUA', 'i', ($block_id // -1));
        local slr, block_id  = ...
        local block = block_id > 0 and slr.inputs[block_id] or slr.current_block
        return #block
END_OF_LUA

    return $length;
}

# no return value documented
sub Marpa::R3::Scanless::R::activate {
    my ( $slr, $event_name, $activate ) = @_;
    my $slg = $slr->[Marpa::R3::Internal_R::SLG];

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
    return;
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
            _M.userX(
                "lexeme_priority_set(): no such symbol as %q",
                lexeme_name
            )
        end
        if type(new_priority) ~= 'number' then
            _M.userX(
                "lexeme_priority_set(): priority is not a number, it is %s",
                new_priority
            )
        end
        local g_lexeme_data = slg.g1.isys[lexeme_id]
        local r_lexeme_data = recce.g1_isys[lexeme_id]
        if not g_lexeme_data.lexeme then
            print(inspect(lexeme_data))
            _M.userX(
                "lexeme_priority_set(): %q is not a lexeme",
                lexeme_name
            )
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
    my $lua   = $slr->[Marpa::R3::Internal_R::L];
    my $regix = $slr->[Marpa::R3::Internal_R::REGIX];

    $DB::single = 1 if not $slr;
    $DB::single = 1 if not $regix;
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
sub Marpa::R3::Scanless::R::coro_by_tag {
    my ( $slr, $tag, $args, $codestr ) = @_;
    my $lua        = $slr->[Marpa::R3::Internal_R::L];
    my $regix      = $slr->[Marpa::R3::Internal_R::REGIX];
    my $handler    = $args->{handlers} // {};
    my $resume_tag = $tag . '[R]';
    my $signature  = $args->{signature} // '';
    my $p_args     = $args->{args} // [];

    my @results;
    my $eval_error;
    my $eval_ok;
    {
        local $@;
        $eval_ok = eval {
            $lua->call_by_tag( $regix, $tag, $codestr, $signature, @{$p_args} );
            my @resume_args = ('');
            my $signature = 's';
          CORO_CALL: while (1) {
                my ( $cmd, $yield_data ) =
                  $lua->call_by_tag( $regix, $resume_tag,
                    'local slr, resume_arg = ...; return _M.resume(resume_arg)',
                    $signature, @resume_args ) ;
                if (not $cmd) {
                   @results = @{$yield_data};
                   return 1;
                }
                my $handler = $handler->{$cmd};
                Marpa::R3::exception(qq{No coro handler for "$cmd"})
                  if not $handler;
                $yield_data //= [];
                my ($handler_cmd, $new_resume_args) = $handler->(@{$yield_data});
                Marpa::R3::exception(qq{Undefined return command from handler for "$cmd"})
                   if not defined $handler_cmd;
                if ($handler_cmd eq 'ok') {
                   $signature = 's';
                   @resume_args = ($new_resume_args);
                   if (scalar @resume_args < 1) {
                       @resume_args = ('');
                   }
                   next CORO_CALL;
                }
                if ($handler_cmd eq 'sig') {
                   @resume_args = @{$new_resume_args};
                   $signature = shift @resume_args;
                   next CORO_CALL;
                }
                Marpa::R3::exception(qq{Bad return command ("$handler_cmd") from handler for "$cmd"})
            }
            return 1;
        };
        $eval_error = $@;
    }
    if ( not $eval_ok ) {
        # if it's an object, just die
        die $eval_error if ref $eval_error;
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
sub Marpa::R3::Scanless::R::earley_sets_show {
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
          $slr->Marpa::R3::Scanless::R::earley_set_show( $ix );
        last LIST if not $set_desc;
        $text .= "Earley Set $ix\n$set_desc";
    }
    return $text;
}

# not to be documented
sub Marpa::R3::Scanless::R::earley_set_show {
    my ( $slr, $traced_set_id ) = @_;
    my $slg     = $slr->[Marpa::R3::Internal_R::SLG];

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

        my $nrl_id       = $item_data{nrl_id};
        my $dot_position = $item_data{dot_position};
        my $ahm_desc;
        if ( $dot_position < 0 ) {
            $ahm_desc = sprintf( 'R%d$', $nrl_id );
        }
        else {
            $ahm_desc = sprintf( 'R%d:%d', $nrl_id, $dot_position );
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
          . $slg->dotted_nrl_show( $nrl_id, $dot_position );

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
                    my $ahm_desc = $slg->briefer_ahm($predecessor_ahm);
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
                my $ahm_desc       = $slg->briefer_ahm($ahm_id);

                my @pieces = ();
                if ( defined $predecessor_ahm_id ) {
                    my $predecessor_ahm_desc =
                      $slg->briefer_ahm($predecessor_ahm_id);
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
                my $ahm_desc = $slg->briefer_ahm($ahm_id);

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
sub Marpa::R3::Scanless::R::regix {
    my ( $slr ) = @_;
    my $regix = $slr->[Marpa::R3::Internal_R::REGIX];
    return $regix;
}

1;

# vim: expandtab shiftwidth=4:
