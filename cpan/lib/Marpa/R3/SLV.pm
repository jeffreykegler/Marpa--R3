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

package Marpa::R3::Scanless::V;

use 5.010001;
use strict;
use warnings;

use vars qw($VERSION $STRING_VERSION);
$VERSION        = '4.001_049';
$STRING_VERSION = $VERSION;
## no critic(BuiltinFunctions::ProhibitStringyEval)
$VERSION = eval $VERSION;
## use critic

package Marpa::R3::Internal::Scanless::V;

use Scalar::Util qw(blessed tainted);
use English qw( -no_match_vars );

our $PACKAGE = 'Marpa::R3::Scanless::V';

sub Marpa::R3::Scanless::V::new {
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
    $slr->[Marpa::R3::Internal::Scanless::R::SLG] = $slg;
    delete $flat_args->{grammar};

    my $event_handlers = $flat_args->{event_handlers} // {};
    $slr->[Marpa::R3::Internal::Scanless::R::EVENT_HANDLERS] = $event_handlers;
    if ( ref $event_handlers ne 'HASH' ) {
        my $ref_type = ref $event_handlers;
        Marpa::R3::exception(
            qq{'event_handlers' named argument to new() is $ref_type\n},
            "  It should be a ref to a hash\n",
            "  whose keys are event names and\n",
            "  whose values are code refs\n"
        );
    }
    # TODO -- restore after development
    # delete $flat_args->{event_handlers};

    my $slg_class = 'Marpa::R3::Scanless::G';
    if ( not blessed $slg or not $slg->isa($slg_class) ) {
        my $ref_type = ref $slg;
        my $desc = $ref_type ? "a ref to $ref_type" : 'not a ref';
        Marpa::R3::exception(
            qq{'grammar' named argument to new() is $desc\n},
            "  It should be a ref to $slg_class\n"
        );
    } ## end if ( not blessed $slg or not $slg->isa($slg_class) )

    $slr->[Marpa::R3::Internal::Scanless::R::TRACE_FILE_HANDLE] //=
      $slg->[Marpa::R3::Internal::Scanless::G::TRACE_FILE_HANDLE];

    my $trace_file_handle =
      $slr->[Marpa::R3::Internal::Scanless::R::TRACE_FILE_HANDLE];

    my $lua = $slg->[Marpa::R3::Internal::Scanless::G::L];
    $slr->[Marpa::R3::Internal::Scanless::R::L] = $lua;

    my ( $regix ) = $slg->coro_by_tag(
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
        local slg, flat_args = ...
        _M.wrap(function ()
            local slr = slg:slr_new(flat_args)
            return 'ok', slr.regix
        end)
END_OF_LUA

    $slr->[Marpa::R3::Internal::Scanless::R::REGIX]  = $regix;

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
            slr:convert_libmarpa_events(slr)
            return 'ok'
        end)
END_OF_LUA

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
    $slr->call_by_tag(
        ('@' . __FILE__ . ':' . __LINE__),
        <<'END_OF_LUA', '');
    local slr = ...
    slr:valuation_reset()
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
      $slr->[Marpa::R3::Internal::Scanless::R::TRACE_FILE_HANDLE];

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
    return $slr;
} ## end sub Marpa::R3::Scanless::R::set

sub Marpa::R3::Scanless::R::series_restart {
    my ( $slr , @args ) = @_;
    my ($flat_args, $error_message) = Marpa::R3::flatten_hash_args(\@args);
    Marpa::R3::exception( sprintf $error_message, '$slr->series_restart()' ) if not $flat_args;

    $flat_args = perl_common_set($slr, $flat_args);
    my $trace_file_handle =
      $slr->[Marpa::R3::Internal::Scanless::R::TRACE_FILE_HANDLE];

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
                slr.phase = "read"
                slr:valuation_reset()
                slr:common_set(flat_args)
            end
        )
END_OF_LUA
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

# Internal methods, not to be documented

# not to be documented
sub Marpa::R3::Scanless::R::call_by_tag {
    my ( $slr, $tag, $codestr, $signature, @args ) = @_;
    my $lua   = $slr->[Marpa::R3::Internal::Scanless::R::L];
    my $regix = $slr->[Marpa::R3::Internal::Scanless::R::REGIX];

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
    my $lua        = $slr->[Marpa::R3::Internal::Scanless::R::L];
    my $regix      = $slr->[Marpa::R3::Internal::Scanless::R::REGIX];
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
sub Marpa::R3::Scanless::R::or_nodes_show {
    my ( $slr ) = @_;

    my ($result) = $slr->call_by_tag(
    ('@' . __FILE__ . ':' . __LINE__),
    <<'END_OF_LUA', '');
    local recce = ...
    return recce:or_nodes_show()
END_OF_LUA

    return $result;
}

# not to be documented
sub Marpa::R3::Scanless::R::and_nodes_show {
    my ( $slr ) = @_;
    my ($result) = $slr->call_by_tag(
    ('@' . __FILE__ . ':' . __LINE__),
    <<'END_OF_LUA', '');
    local recce = ...
    return recce:and_nodes_show()
END_OF_LUA

    return $result;
}

# not to be documented
sub Marpa::R3::Scanless::R::tree_show {
    my ( $slr, $verbose ) = @_;
    my $text = q{};
    NOOK: for ( my $nook_id = 0; 1; $nook_id++ ) {
        my $nook_text = $slr->nook_show( $nook_id, $verbose );
        last NOOK if not defined $nook_text;
        $text .= "$nook_id: $nook_text";
    }
    return $text;
}

# not to be documented
sub Marpa::R3::Scanless::R::nook_show {
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
sub Marpa::R3::Scanless::R::bocage_show {
    my ($slr)     = @_;

    my ($result) = $slr->call_by_tag(
    ('@' . __FILE__ . ':' . __LINE__),
        <<'END_OF_LUA', '');
        local recce = ...
        return recce:bocage_show()
END_OF_LUA

    return $result;
}

# not to be documented
sub Marpa::R3::Scanless::R::verbose_or_node {
    my ( $slr, $or_node_id ) = @_;
    my ($text, $nrl_id, $position)
        = $slr->call_by_tag(
    ('@' . __FILE__ . ':' . __LINE__),
        <<'END_OF_LUA', 'i', $or_node_id);
        local recce, or_node_id = ...
        local bocage = recce.lmw_b
        local origin = bocage:_or_node_origin(or_node_id)
        if not origin then return end
        local set = bocage:_or_node_set(or_node_id)
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
        . $slg->dotted_nrl_show( $nrl_id, $position ) . "\n";
    return $text;
}

# not to be documented
sub Marpa::R3::Scanless::V::regix {
    my ( $slr ) = @_;
    my $regix = $slr->[Marpa::R3::Internal::Scanless::V::REGIX];
    return $regix;
}

1;

# vim: expandtab shiftwidth=4:
