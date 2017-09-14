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

sub Marpa::R3::Scanless::V::link {
    my ( $class, @args ) = @_;

    my $slv = [];
    bless $slv, $class;

    # Set recognizer args to default
    # Lua equivalent is set below

    my ( $flat_args, $error_message ) = Marpa::R3::flatten_hash_args( \@args );
    Marpa::R3::exception( sprintf $error_message, '$slv->new' )
      if not $flat_args;
    $flat_args = perl_common_set( $slv, $flat_args );

    my $slg = $flat_args->{recce};
    Marpa::R3::exception(
        qq{Marpa::R3::Scanless::V::new() called without a "recce" argument} )
      if not defined $slg;
    $slv->[Marpa::R3::Internal::Scanless::V::SLR] = $slr;
    delete $flat_args->{grammar};

    my $slr_class = 'Marpa::R3::Scanless::R';
    if ( not blessed $slg or not $slg->isa($slg_class) ) {
        my $ref_type = ref $slg;
        my $desc = $ref_type ? "a ref to $ref_type" : 'not a ref';
        Marpa::R3::exception(
            qq{'recce' named argument to new() is $desc\n},
            "  It should be a ref to $slg_class\n"
        );
    } ## end if ( not blessed $slg or not $slg->isa($slg_class) )

    $slr->[Marpa::R3::Internal::Scanless::V::TRACE_FILE_HANDLE] //=
      $slg->[Marpa::R3::Internal::Scanless::R::TRACE_FILE_HANDLE];

    my $trace_file_handle =
      $slr->[Marpa::R3::Internal::Scanless::V::TRACE_FILE_HANDLE];

    my $lua = $slg->[Marpa::R3::Internal::Scanless::R::L];
    $slr->[Marpa::R3::Internal::Scanless::V::L] = $lua;

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
            local slv = slr:islv_register(flat_args)
            return 'ok', slv.regix
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
    slr:valuation_reset()
    local regix = slv.regix
    _M.unregister(_M.registry, regix)
END_OF_LUA
}

sub Marpa::R3::Scanless::V::set {
    my ( $slv, @args ) = @_;

    my ($flat_args, $error_message) = Marpa::R3::flatten_hash_args(\@args);
    Marpa::R3::exception( sprintf $error_message, '$slv->set()' ) if not $flat_args;
    $flat_args = perl_common_set($slv, $flat_args);
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
sub Marpa::R3::Scanless::V::regix {
    my ( $slv ) = @_;
    my $regix = $slv->[Marpa::R3::Internal::Scanless::V::REGIX];
    return $regix;
}

1;

# vim: expandtab shiftwidth=4:
