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

# Set those common args which are at the Perl level.
sub slv_common_set {
    my ( $slv, $flat_args ) = @_;
    if ( my $value = $flat_args->{'trace_file_handle'} ) {
        $slv->[Marpa::R3::Internal::Scanless::V::TRACE_FILE_HANDLE] = $value;
    }
    my $trace_file_handle =
      $slv->[Marpa::R3::Internal::Scanless::V::TRACE_FILE_HANDLE];
    delete $flat_args->{'trace_file_handle'};
    return $flat_args;
}

sub Marpa::R3::Scanless::V::link {
    my ( $class, @args ) = @_;

    my $slv = [];
    bless $slv, $class;

    # Set recognizer args to default
    # Lua equivalent is set below

    my ( $flat_args, $error_message ) = Marpa::R3::flatten_hash_args( \@args );
    Marpa::R3::exception( sprintf $error_message, '$slv->new' )
      if not $flat_args;
    $flat_args = slv_common_set( $slv, $flat_args );

    my $slr = $flat_args->{recce};
    Marpa::R3::exception(
        qq{Marpa::R3::Scanless::V::new() called without a "recce" argument} )
      if not defined $slr;
    $slv->[Marpa::R3::Internal::Scanless::V::SLR] = $slr;
    delete $flat_args->{recce};

    my $slr_class = 'Marpa::R3::Scanless::R';
    if ( not blessed $slr or not $slr->isa($slr_class) ) {
        my $ref_type = ref $slr;
        my $desc = $ref_type ? "a ref to $ref_type" : 'not a ref';
        Marpa::R3::exception(
            qq{'recce' named argument to new() is $desc\n},
            "  It should be a ref to $slr_class\n"
        );
    }

    $slv->[Marpa::R3::Internal::Scanless::V::TRACE_FILE_HANDLE] //=
      $slr->[Marpa::R3::Internal::Scanless::R::TRACE_FILE_HANDLE];

    my $trace_file_handle =
      $slv->[Marpa::R3::Internal::Scanless::V::TRACE_FILE_HANDLE];

    my $lua = $slr->[Marpa::R3::Internal::Scanless::R::L];
    $slv->[Marpa::R3::Internal::Scanless::V::L] = $lua;

    my ( $regix ) = $slr->coro_by_tag(
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
            }
        },
        <<'END_OF_LUA');
        local slr, flat_args = ...
        _M.wrap(function ()
            -- local v_regix = slr:islv_register(flat_args)
            local v_regix = slr.slv.regix
            return 'ok', v_regix
        end)
END_OF_LUA

    $slv->[Marpa::R3::Internal::Scanless::V::REGIX]  = $regix;

    return $slv;
}

sub Marpa::R3::Scanless::V::DESTROY {
    # say STDERR "In Marpa::R3::Scanless::V::DESTROY before test";
    my $slv = shift;
    my $lua = $slv->[Marpa::R3::Internal::Scanless::V::L];

    # If we are destroying the Perl interpreter, then all the Marpa
    # objects will be destroyed, including Marpa's Lua interpreter.
    # We do not need to worry about cleaning up the
    # recognizer is an orderly manner, because the Lua interpreter
    # containing the recognizer will be destroyed.
    # In fact, the Lua interpreter may already have been destroyed,
    # so this test is necessary to avoid a warning message.
    return if not $lua;
    # say STDERR "In Marpa::R3::Scanless::V::DESTROY after test";

    my $regix = $slv->[Marpa::R3::Internal::Scanless::V::REGIX];
    $slv->call_by_tag(
        ('@' . __FILE__ . ':' . __LINE__),
        <<'END_OF_LUA', '');
    local slv = ...
    local slr = slv.slr
    -- TODO test unnecessary once slr-internal slv is eliminated
    if not slv.is_r_internal then
        slr:valuation_reset()
        local regix = slv.regix
        _M.unregister(_M.registry, regix)
    end
END_OF_LUA
}

sub Marpa::R3::Scanless::V::set {
    my ( $slv, @args ) = @_;

    my ($flat_args, $error_message) = Marpa::R3::flatten_hash_args(\@args);
    Marpa::R3::exception( sprintf $error_message, '$slv->set()' ) if not $flat_args;
    $flat_args = slv_common_set($slv, $flat_args);
    my $trace_file_handle =
      $slv->[Marpa::R3::Internal::Scanless::V::TRACE_FILE_HANDLE];

    $slv->coro_by_tag(
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
        local slv, flat_args = ...
        return _M.wrap(function ()
                slv:common_set(flat_args)
            end
        )
END_OF_LUA
    return $slv;
}

# not to be documented
sub Marpa::R3::Scanless::V::call_by_tag {
    my ( $slv, $tag, $codestr, $signature, @args ) = @_;
    my $lua   = $slv->[Marpa::R3::Internal::Scanless::V::L];
    my $regix = $slv->[Marpa::R3::Internal::Scanless::V::REGIX];

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
sub Marpa::R3::Scanless::V::coro_by_tag {
    my ( $slv, $tag, $args, $codestr ) = @_;
    my $lua        = $slv->[Marpa::R3::Internal::Scanless::V::L];
    my $regix      = $slv->[Marpa::R3::Internal::Scanless::V::REGIX];
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
                    'local slv, resume_arg = ...; return _M.resume(resume_arg)',
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
sub Marpa::R3::Scanless::V::tree_show {
    my ( $slv, $verbose ) = @_;
    my $text = q{};
    NOOK: for ( my $nook_id = 0; 1; $nook_id++ ) {
        my $nook_text = $slv->nook_show( $nook_id, $verbose );
        last NOOK if not defined $nook_text;
        $text .= "$nook_id: $nook_text";
    }
    return $text;
}

# not to be documented
sub Marpa::R3::Scanless::V::nook_show {
    my ( $slv, $nook_id, $verbose ) = @_;
    my $slr = $slv->[Marpa::R3::Internal::Scanless::V::SLR];

    my ($or_node_id, $text) = $slv->call_by_tag(
    ('@' . __FILE__ . ':' . __LINE__),
    <<'END_OF_LUA', 'i', $nook_id);
    local slv, nook_id = ...
    local slr = slv.slr
    local tree = slv.lmw_t
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

    local tree = slv.lmw_t
    text = text .. " " .. slv:or_node_tag(or_node_id) .. ' p'
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
        ($this_choice) = $slv->call_by_tag(
    ('@' . __FILE__ . ':' . __LINE__),
            'local slv, nook_id = ...; return slv.lmw_t:_nook_choice(nook_id)',
            'i', $nook_id
        );
        CHOICE: for ( my $choice_ix = 0;; $choice_ix++ ) {

                my ($and_node_id) = $slv->call_by_tag(
    ('@' . __FILE__ . ':' . __LINE__),
                <<'END_OF_LUA', 'ii>*', $or_node_id, $choice_ix );
                local slv, or_node_id, choice_ix = ...
                return slv.lmw_o:_and_order_get(or_node_id+0, choice_ix+0)
END_OF_LUA

            last CHOICE if not defined $and_node_id;
            $text .= " o$or_node_id" . '[' . $choice_ix . ']';
            if ( defined $this_choice and $this_choice == $choice_ix ) {
                $text .= q{*};
            }
            my $and_node_tag =
                $slv->and_node_tag( $and_node_id );
            $text .= " ::= a$and_node_id $and_node_tag";
            $text .= "\n";
        } ## end CHOICE: for ( my $choice_ix = 0;; $choice_ix++ )
    } ## end DESCRIBE_CHOICES:
    return $text;
}

# not to be documented
sub Marpa::R3::Scanless::V::and_node_tag {
    my ( $slv, $and_node_id ) = @_;

    my ($tag) = $slv->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        << 'END_OF_LUA', 'i', $and_node_id );
    local slv, and_node_id=...
    return slv:and_node_tag(and_node_id)
END_OF_LUA

    return $tag;
}

# not to be documented
sub Marpa::R3::Scanless::V::verbose_or_node {
    my ( $slv, $or_node_id ) = @_;
    my $slr = $slv->[Marpa::R3::Internal::Scanless::V::SLR];
    my $slg = $slr->[Marpa::R3::Internal::Scanless::R::SLG];

    my ($text, $nrl_id, $position)
        = $slv->call_by_tag(
    ('@' . __FILE__ . ':' . __LINE__),
        <<'END_OF_LUA', 'i', $or_node_id);
        local slv, or_node_id = ...
        local slr = slv.slr
        local bocage = slr.lmw_b
        local origin = bocage:_or_node_origin(or_node_id)
        if not origin then return end
        local set = bocage:_or_node_set(or_node_id)
        local position = bocage:_or_node_position(or_node_id)
        local g1r = slr.g1
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

    $text .= ( q{ } x 4 )
        . $slg->dotted_nrl_show( $nrl_id, $position ) . "\n";
    return $text;
}

# not to be documented
sub Marpa::R3::Scanless::V::bocage_show {
    my ($slv)     = @_;

    my ($result) = $slv->call_by_tag(
    ('@' . __FILE__ . ':' . __LINE__),
        <<'END_OF_LUA', '');
        local slv = ...
        return slv:bocage_show()
END_OF_LUA

    return $result;
}

# not to be documented
sub Marpa::R3::Scanless::V::or_nodes_show {
    my ( $slv ) = @_;

    my ($result) = $slv->call_by_tag(
    ('@' . __FILE__ . ':' . __LINE__),
    <<'END_OF_LUA', '');
    local slv = ...
    return slv:or_nodes_show()
END_OF_LUA

    return $result;
}

# not to be documented
sub Marpa::R3::Scanless::V::and_nodes_show {
    my ( $slv ) = @_;
    my ($result) = $slv->call_by_tag(
    ('@' . __FILE__ . ':' . __LINE__),
    <<'END_OF_LUA', '');
    local slv = ...
    return slv:and_nodes_show()
END_OF_LUA

    return $result;
}

sub Marpa::R3::Scanless::V::ambiguous {
    my ($slv) = @_;
    my $slr = $slv->[Marpa::R3::Internal::Scanless::V::SLR];
    my $ambiguity_metric = $slv->ambiguity_metric();
    return q{No parse} if $ambiguity_metric <= 0;
    return q{} if $ambiguity_metric == 1;
    # TODO ASF must be created for end location of SLV,
    #   not of SLR!
    my $asf = Marpa::R3::ASF->new( { slr => $slr } );
    die 'Could not create ASF' if not defined $asf;
    my $ambiguities = Marpa::R3::Internal::ASF::ambiguities($asf);
    my @ambiguities = grep {defined} @{$ambiguities}[ 0 .. 1 ];
    return Marpa::R3::Internal::ASF::ambiguities_show( $asf, \@ambiguities );
} ## end sub Marpa::R3::Scanless::R::ambiguous

sub Marpa::R3::Scanless::V::ambiguity_metric {
    my ($slv) = @_;

    my ($metric) = $slv->call_by_tag(
    ('@' . __FILE__ . ':' . __LINE__),
    <<'END__OF_LUA', '>*' );
    local slv = ...
    local order = slv:ordering_get()
    if not order then return 0 end
    return order:ambiguity_metric()
END__OF_LUA

    return $metric;
} ## end sub Marpa::R3::Scanless::R::ambiguity_metric

# not to be documented
sub Marpa::R3::Scanless::V::regix {
    my ( $slv ) = @_;
    my $regix = $slv->[Marpa::R3::Internal::Scanless::V::REGIX];
    return $regix;
}

sub Marpa::R3::Scanless::V::series_restart {
    my ( $slv , @args ) = @_;
    my ($flat_args, $error_message) = Marpa::R3::flatten_hash_args(\@args);
    Marpa::R3::exception( sprintf $error_message, '$slv->series_restart()' ) if not $flat_args;

    $flat_args = slv_common_set($slv, $flat_args);
    my $trace_file_handle =
      $slv->[Marpa::R3::Internal::Scanless::R::TRACE_FILE_HANDLE];

    $slv->coro_by_tag(
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
        local slv, flat_args = ...
        local slr = slv.slr
        return _M.wrap(function ()
                if slv.is_r_internal then slr.phase = "read" end
                slr:valuation_reset()
                slr:common_set(flat_args)
            end
        )
END_OF_LUA
    return 1;
}

1;

# vim: expandtab shiftwidth=4:
