# Marpa::R3 is Copyright (C) 2018, Jeffrey Kegler.
#
# This module is free software; you can redistribute it and/or modify it
# under the same terms as Perl 5.10.1. For more details, see the full text
# of the licenses in the directory LICENSES.
#
# This program is distributed in the hope that it will be
# useful, but it is provided "as is" and without any express
# or implied warranties. For details, see the full text of
# of the licenses in the directory LICENSES.

package Marpa::R3::Glade;

use 5.010001;
use strict;
use warnings;
no warnings qw(recursion);

use vars qw($VERSION $STRING_VERSION);
$VERSION        = '4.001_052';
$STRING_VERSION = $VERSION;
## no critic(BuiltinFunctions::ProhibitStringyEval)
$VERSION = eval $VERSION;
## use critic

# The code in this file, for now, breaks "the rules".  It makes use
# of internal methods not documented as part of Libmarpa.
# It is intended to create documented Libmarpa methods to underlie
# this interface, and rewrite it to use them

package Marpa::R3::Internal_Glade;

use Scalar::Util qw(blessed tainted);
use English qw( -no_match_vars );

our $PACKAGE = 'Marpa::R3::Glade';

# Set those common args which are at the Perl level.
# This is more complicated that it needs to be for the current implementation.
# It allows for LHS terminals (implemented in Libmarpa but not allowed by the SLIF).
# It also assumes that every or-node which can be constructed from preceding or-nodes
# and the input will be present.  This is currently the case, but in the future
# rules and/or symbols may have extra-syntactic conditions attached making this
# assumption false.

# Set those common args which are at the Perl level.
sub glade_common_set {
    my ( $glade, $flat_args ) = @_;
    if ( my $value = $flat_args->{'trace_file_handle'} ) {
        $glade->[Marpa::R3::Internal_Glade::TRACE_FILE_HANDLE] = $value;
    }
    my $trace_file_handle =
      $glade->[Marpa::R3::Internal_Glade::TRACE_FILE_HANDLE];
    delete $flat_args->{'trace_file_handle'};
    return $flat_args;
}

# Returns undef if no parse
sub Marpa::R3::ASF::new {
    my ( $class, @args ) = @_;
    my $asf = bless [], $class;

    my $end_of_parse;

    my ( $flat_args, $error_message ) = Marpa::R3::flatten_hash_args( \@args );
    Marpa::R3::exception( sprintf $error_message, '$asf->new' )
      if not $flat_args;
    $flat_args = asf_common_set( $asf, $flat_args );

    my $slr = $flat_args->{recognizer};
    Marpa::R3::exception(
        qq{Marpa::R3::ASF::new() called without a "recognizer" argument} )
      if not defined $slr;
    $asf->[Marpa::R3::Internal_ASF::SLR] = $slr;
    delete $flat_args->{recognizer};

    my $slr_class = 'Marpa::R3::Recognizer';
    if ( not blessed $slr or not $slr->isa($slr_class) ) {
        my $ref_type = ref $slr;
        my $desc = $ref_type ? "a ref to $ref_type" : 'not a ref';
        Marpa::R3::exception(
            qq{'recognizer' named argument to new() is $desc\n},
            "  It should be a ref to $slr_class\n"
        );
    }

    $asf->[Marpa::R3::Internal_ASF::TRACE_FILE_HANDLE] //=
      $slr->[Marpa::R3::Internal_R::TRACE_FILE_HANDLE];

    my $trace_file_handle =
      $asf->[Marpa::R3::Internal_ASF::TRACE_FILE_HANDLE];

    my $lua = $slr->[Marpa::R3::Internal_R::L];
    $asf->[Marpa::R3::Internal_ASF::L] = $lua;

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
            local glade = slr:glade_new(flat_args)
            if not glade then return 'ok', -1 end
            return 'ok', glade.regix
        end)
END_OF_LUA

    return if $regix < 0;
    $glade->[Marpa::R3::Internal_ASF::REGIX]  = $regix;

    $glade->[Marpa::R3::Internal_ASF::FACTORING_MAX] //= 42;

    return $glade;

} ## end sub Marpa::R3::ASF::new

sub Marpa::R3::Glade::DESTROY {
    # say STDERR "In Marpa::R3::Glade::DESTROY before test";
    my $glade = shift;
    my $lua = $glade->[Marpa::R3::Internal_Glade::L];

    # If we are destroying the Perl interpreter, then all the Marpa
    # objects will be destroyed, including Marpa's Lua interpreter.
    # We do not need to worry about cleaning up the
    # recognizer is an orderly manner, because the Lua interpreter
    # containing the recognizer will be destroyed.
    # In fact, the Lua interpreter may already have been destroyed,
    # so this test is necessary to avoid a warning message.
    return if not $lua;
    # say STDERR "In Marpa::R3::Glade::DESTROY after test";

    my $regix = $glade->[Marpa::R3::Internal_Glade::REGIX];
    $glade->call_by_tag(
        ('@' . __FILE__ . ':' . __LINE__),
        <<'END_OF_LUA', '');
    local glade = ...
    local regix = glade.regix
    _M.unregister(_M.registry, regix)
END_OF_LUA
}

# not to be documented
sub Marpa::R3::Glade::call_by_tag {
    my ( $glade, $tag, $codestr, $signature, @args ) = @_;
    my $lua   = $glade->[Marpa::R3::Internal_Glade::L];
    my $regix = $glade->[Marpa::R3::Internal_Glade::REGIX];

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
sub Marpa::R3::Glade::coro_by_tag {
    my ( $glade, $tag, $args, $codestr ) = @_;
    my $lua        = $glade->[Marpa::R3::Internal_ASF::L];
    my $regix      = $glade->[Marpa::R3::Internal_ASF::REGIX];
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
                    'local glade, resume_arg = ...; return _M.resume(resume_arg)',
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
sub Marpa::R3::Glade::regix {
    my ( $glade ) = @_;
    my $regix = $glade->[Marpa::R3::Internal_Glade::REGIX];
    return $regix;
}

1;

# vim: expandtab shiftwidth=4:
