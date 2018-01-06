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

package Marpa::R3::ASF;

use 5.010001;
use strict;
use warnings;
no warnings qw(recursion);

use vars qw($VERSION $STRING_VERSION);
$VERSION        = '4.001_051';
$STRING_VERSION = $VERSION;
## no critic(BuiltinFunctions::ProhibitStringyEval)
$VERSION = eval $VERSION;
## use critic

# The code in this file, for now, breaks "the rules".  It makes use
# of internal methods not documented as part of Libmarpa.
# It is intended to create documented Libmarpa methods to underlie
# this interface, and rewrite it to use them

package Marpa::R3::Internal_ASF;

use Scalar::Util qw(blessed tainted);
use English qw( -no_match_vars );

our $PACKAGE = 'Marpa::R3::ASF';

# Set those common args which are at the Perl level.
# This is more complicated that it needs to be for the current implementation.
# It allows for LHS terminals (implemented in Libmarpa but not allowed by the SLIF).
# It also assumes that every or-node which can be constructed from preceding or-nodes
# and the input will be present.  This is currently the case, but in the future
# rules and/or symbols may have extra-syntactic conditions attached making this
# assumption false.

# Terms:

# NID (Node ID): Encoded ID of either an or-node or an and-node.
#
# Extensions:
# Set "powers":  A set of power 0 is an "atom" -- a single NID.
# A set of power 1 is a set of NID's -- a nidset.
# A set of power 2 is a set of sets of NID's, also called a powerset.
# A set of power 3 is a set of powersets, etc.
#
# The whole ID of NID is the external rule id of an or-node, or -1
# if the NID is for a token and-node.
#
# Intensions:
# A Symch is a nidset, where all the NID's share the same "whole ID"
# and the same span.  NID's in a symch may differ in their internal rule,
# or have different causes.  If the symch contains and-node NID's they
# will all have the same symbol.
#
# A choicepoint is a powerset -- a set of symches all of which share
# the same set of predecessors.  (This set of predecessors is a power 3 set of
# choicepoints.)  All symches in a choicepoint also share the same span,
# and the same symch-symbol.  A symch's symbol is the LHS of the rule,
# or the symbol of the token in the token and-nodes.

# No check for conflicting usage -- value(), asf(), etc.
# at this point
sub Marpa::R3::ASF::peak {
    my ($asf)    = @_;
    die("Not yet implemented");
} ## end sub Marpa::R3::ASF::peak

our $NID_LEAF_BASE = -43;

# Range from -1 to -42 reserved for special values
sub and_node_to_nid { return -$_[0] + $NID_LEAF_BASE; }
sub nid_to_and_node { return -$_[0] + $NID_LEAF_BASE; }

# Set those common args which are at the Perl level.
sub asf_common_set {
    my ( $asf, $flat_args ) = @_;
    if ( my $value = $flat_args->{'trace_file_handle'} ) {
        $asf->[Marpa::R3::Internal_ASF::TRACE_FILE_HANDLE] = $value;
    }
    my $trace_file_handle =
      $asf->[Marpa::R3::Internal_ASF::TRACE_FILE_HANDLE];
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

        ARG: for my $arg ( keys %{$flat_args} ) {
            if ( $arg eq 'factoring_max' ) {
                $asf->[Marpa::R3::Internal_ASF::FACTORING_MAX] =
                    $flat_args->{$arg};
                delete $flat_args->{$arg};
                next ARG;
            }
        }

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
            local asf = slr:asf_new(flat_args)
            if not asf then return 'ok', -1 end
            local bocage = asf.lmw_b
            if bocage:is_null() == 1 then
                error([[
        An attempt was make to create an ASF for a null parse\n\a
        \u{20}  A null parse is a successful parse of a zero-length string\n\z
        \u{20}  ASF's are not defined for null parses\n\z
        ]])
            end
            return 'ok', asf.regix
        end)
END_OF_LUA

    return if $regix < 0;
    $asf->[Marpa::R3::Internal_ASF::REGIX]  = $regix;

    $asf->[Marpa::R3::Internal_ASF::FACTORING_MAX] //= 42;

    return $asf;

} ## end sub Marpa::R3::ASF::new

sub Marpa::R3::ASF::DESTROY {
    # say STDERR "In Marpa::R3::ASF::DESTROY before test";
    my $asf = shift;
    my $lua = $asf->[Marpa::R3::Internal_ASF::L];

    # If we are destroying the Perl interpreter, then all the Marpa
    # objects will be destroyed, including Marpa's Lua interpreter.
    # We do not need to worry about cleaning up the
    # recognizer is an orderly manner, because the Lua interpreter
    # containing the recognizer will be destroyed.
    # In fact, the Lua interpreter may already have been destroyed,
    # so this test is necessary to avoid a warning message.
    return if not $lua;
    # say STDERR "In Marpa::R3::ASF::DESTROY after test";

    my $regix = $asf->[Marpa::R3::Internal_ASF::REGIX];
    $asf->call_by_tag(
        ('@' . __FILE__ . ':' . __LINE__),
        <<'END_OF_LUA', '');
    local asf = ...
    local regix = asf.regix
    _M.unregister(_M.registry, regix)
END_OF_LUA
}

sub Marpa::R3::ASF::grammar {
    my ($asf)   = @_;
    my $slr     = $asf->[Marpa::R3::Internal_ASF::SLR];
    my $slg = $slr->[Marpa::R3::Internal_R::SLG];
    return $slg;
} ## end sub Marpa::R3::ASF::grammar

# TODO -- Document this method
sub Marpa::R3::ASF::recognizer {
    my ($asf)   = @_;
    my $slr     = $asf->[Marpa::R3::Internal_ASF::SLR];
    return $slr;
}

# not to be documented
sub Marpa::R3::ASF::call_by_tag {
    my ( $asf, $tag, $codestr, $signature, @args ) = @_;
    my $lua   = $asf->[Marpa::R3::Internal_ASF::L];
    my $regix = $asf->[Marpa::R3::Internal_ASF::REGIX];

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
sub Marpa::R3::ASF::coro_by_tag {
    my ( $asf, $tag, $args, $codestr ) = @_;
    my $lua        = $asf->[Marpa::R3::Internal_ASF::L];
    my $regix      = $asf->[Marpa::R3::Internal_ASF::REGIX];
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
                    'local asf, resume_arg = ...; return _M.resume(resume_arg)',
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

sub Marpa::R3::ASF::ambiguity_level {
    my ($asf) = @_;

    my ($metric) = $asf->call_by_tag(
    ('@' . __FILE__ . ':' . __LINE__),
    <<'END__OF_LUA', '>*' );
    local asf = ...
    return asf:ambiguity_level()
END__OF_LUA
    return $metric;
}

sub Marpa::R3::ASF::g1_pos {
    my ( $asf ) = @_;
    my ($g1_pos) = $asf->call_by_tag(
    ('@' . __FILE__ . ':' . __LINE__),
    <<'END__OF_LUA', '>*' );
    local asf = ...
    return asf:g1_pos()
END__OF_LUA
    return $g1_pos;
}

# not to be documented
sub Marpa::R3::ASF::regix {
    my ( $asf ) = @_;
    my $regix = $asf->[Marpa::R3::Internal_ASF::REGIX];
    return $regix;
}

1;

# vim: expandtab shiftwidth=4:
