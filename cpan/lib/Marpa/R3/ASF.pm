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
$VERSION        = '4.001_050';
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

sub intset_id {
    my ( $asf, @ids ) = @_;
    my $key           = join q{ }, sort { $a <=> $b } @ids;
    my $intset_by_key = $asf->[Marpa::R3::Internal_ASF::INTSET_BY_KEY];
    my $intset_id     = $intset_by_key->{$key};
    return $intset_id if defined $intset_id;
    $intset_id = $asf->[Marpa::R3::Internal_ASF::NEXT_INTSET_ID]++;
    $intset_by_key->{$key} = $intset_id;
    return $intset_id;
} ## end sub intset_id

sub Marpa::R3::Nidset::obtain {
    my ( $class, $asf, @nids ) = @_;
    my $id           = intset_id( $asf, @nids );
    my $nidset_by_id = $asf->[Marpa::R3::Internal_ASF::NIDSET_BY_ID];
    my $nidset       = $nidset_by_id->[$id];
    return $nidset if defined $nidset;
    $nidset = bless [], $class;
    $nidset->[Marpa::R3::Internal::Nidset::ID] = $id;
    $nidset->[Marpa::R3::Internal::Nidset::NIDS] =
        [ sort { $a <=> $b } @nids ];
    $nidset_by_id->[$id] = $nidset;
    return $nidset;
} ## end sub Marpa::R3::Nidset::obtain

sub Marpa::R3::Nidset::nids {
    my ($nidset) = @_;
    return $nidset->[Marpa::R3::Internal::Nidset::NIDS];
}

sub Marpa::R3::Nidset::nid {
    my ( $nidset, $ix ) = @_;
    return $nidset->[Marpa::R3::Internal::Nidset::NIDS]->[$ix];
}

sub Marpa::R3::Nidset::count {
    my ($nidset) = @_;
    return scalar @{ $nidset->[Marpa::R3::Internal::Nidset::NIDS] };
}

sub Marpa::R3::Nidset::id {
    my ($nidset) = @_;
    return $nidset->[Marpa::R3::Internal::Nidset::ID];
}

sub Marpa::R3::Nidset::show {
    my ($nidset) = @_;
    my $id       = $nidset->id();
    my $nids     = $nidset->nids();
    return "Nidset #$id: " . join q{ }, @{$nids};
} ## end sub Marpa::R3::Nidset::show

sub Marpa::R3::Powerset::obtain {
    my ( $class, $asf, @nidset_ids ) = @_;
    my $id             = intset_id( $asf, @nidset_ids );
    my $powerset_by_id = $asf->[Marpa::R3::Internal_ASF::POWERSET_BY_ID];
    my $powerset       = $powerset_by_id->[$id];
    return $powerset if defined $powerset;
    $powerset = bless [], $class;
    $powerset->[Marpa::R3::Internal::Powerset::ID] = $id;
    $powerset->[Marpa::R3::Internal::Powerset::NIDSET_IDS] =
        [ sort { $a <=> $b } @nidset_ids ];
    $powerset_by_id->[$id] = $powerset;
    return $powerset;
} ## end sub Marpa::R3::Powerset::obtain

sub Marpa::R3::Powerset::nidset_ids {
    my ($powerset) = @_;
    return $powerset->[Marpa::R3::Internal::Powerset::NIDSET_IDS];
}

sub Marpa::R3::Powerset::count {
    my ($powerset) = @_;
    return scalar @{ $powerset->[Marpa::R3::Internal::Powerset::NIDSET_IDS] };
}

sub Marpa::R3::Powerset::nidset_id {
    my ( $powerset, $ix ) = @_;
    my $nidset_ids = $powerset->[Marpa::R3::Internal::Powerset::NIDSET_IDS];
    return if $ix > $#{$nidset_ids};
    return $powerset->[Marpa::R3::Internal::Powerset::NIDSET_IDS]->[$ix];
} ## end sub Marpa::R3::Powerset::nidset_id

sub Marpa::R3::Powerset::nidset {
    my ( $powerset, $asf, $ix ) = @_;
    my $nidset_ids = $powerset->[Marpa::R3::Internal::Powerset::NIDSET_IDS];
    return if $ix > $#{$nidset_ids};
    my $nidset_id = $powerset->[Marpa::R3::Internal::Powerset::NIDSET_IDS]->[$ix];
    my $nidset_by_id = $asf->[Marpa::R3::Internal_ASF::NIDSET_BY_ID];
    return $nidset_by_id->[$nidset_id];
} ## end sub Marpa::R3::Powerset::nidset_id

sub Marpa::R3::Powerset::id {
    my ($powerset) = @_;
    return $powerset->[Marpa::R3::Internal::Powerset::ID];
}

sub Marpa::R3::Powerset::show {
    my ($powerset) = @_;
    my $id         = $powerset->id();
    my $nidset_ids = $powerset->nidset_ids();
    return "Powerset #$id: " . join q{ }, @{$nidset_ids};
} ## end sub Marpa::R3::Powerset::show

sub set_last_choice {
    my ( $asf, $nook ) = @_;
    my $or_nodes   = $asf->[Marpa::R3::Internal_ASF::OR_NODES];
    my $or_node_id = $nook->[Marpa::R3::Internal::Nook::OR_NODE];
    my $and_nodes  = $or_nodes->[$or_node_id];
    my $choice     = $nook->[Marpa::R3::Internal::Nook::FIRST_CHOICE];
    return if $choice > $#{$and_nodes};
    if ( nook_has_semantic_cause( $asf, $nook ) ) {
        my $slr       = $asf->[Marpa::R3::Internal_ASF::SLR];
        my $slg = $slr->[Marpa::R3::Internal_R::SLG];
        my $and_node_id = $and_nodes->[$choice];
        my ($current_predecessor) = $asf->call_by_tag(
        ('@' . __FILE__ . ':' . __LINE__),
        <<'END_OF_LUA',
            local asf, id = ...
            local current = asf.lmw_b:_and_node_predecessor(id)
            return current and current or -1
END_OF_LUA
            'i', $and_node_id);
        AND_NODE: while (1) {
            $choice++;
            $and_node_id = $and_nodes->[$choice];
            last AND_NODE if not defined $and_node_id;
            my ($next_predecessor) = $asf->call_by_tag(
        ('@' . __FILE__ . ':' . __LINE__),
            <<'END_OF_LUA',
                local asf, id = ...
                local next = asf.lmw_b:_and_node_predecessor(id)
                return next and next or -1
END_OF_LUA
                'i', ($and_node_id // -1));
            last AND_NODE if $current_predecessor != $next_predecessor;
        } ## end AND_NODE: while (1)
        $choice--;
    } ## end if ( nook_has_semantic_cause( $asf, $nook ) )
    $nook->[Marpa::R3::Internal::Nook::LAST_CHOICE] = $choice;
    return $choice;
} ## end sub set_last_choice

sub nook_new {
    my ( $asf, $or_node_id, $parent_or_node_id ) = @_;
    my $nook = [];
    $nook->[Marpa::R3::Internal::Nook::OR_NODE] = $or_node_id;
    $nook->[Marpa::R3::Internal::Nook::PARENT] = $parent_or_node_id // -1;
    $nook->[Marpa::R3::Internal::Nook::FIRST_CHOICE] = 0;
    set_last_choice( $asf, $nook );
    return $nook;
} ## end sub nook_new

sub nook_increment {
    my ( $asf, $nook ) = @_;
    $nook->[Marpa::R3::Internal::Nook::LAST_CHOICE] //= 0;
    $nook->[Marpa::R3::Internal::Nook::FIRST_CHOICE] =
        $nook->[Marpa::R3::Internal::Nook::LAST_CHOICE] + 1;
    return if not defined set_last_choice( $asf, $nook );
    return 1;
} ## end sub nook_increment

sub nook_has_semantic_cause {
    my ( $asf, $nook ) = @_;
    my $or_node   = $nook->[Marpa::R3::Internal::Nook::OR_NODE];

    my ($result) = $asf->call_by_tag(
        ('@' . __FILE__ . ':' . __LINE__),
    <<'END_OF_LUA', 'i', $or_node);
    local asf, or_node = ...
    local slr = asf.slr
    local irl_id = asf.lmw_b:_or_node_nrl(or_node)
    local predot_position = asf.lmw_b:_or_node_position(or_node) - 1
    local predot_isyid = slr.slg.g1:_nrl_rhs(irl_id, predot_position)
    return slr.slg.g1:_nsy_is_semantic(predot_isyid)
END_OF_LUA
     return $result;
} ## end sub nook_has_semantic_cause

# No check for conflicting usage -- value(), asf(), etc.
# at this point
sub Marpa::R3::ASF::peak {
    my ($asf)    = @_;
    my $or_nodes = $asf->[Marpa::R3::Internal_ASF::OR_NODES];

    my ($augment_or_node_id) = $asf->call_by_tag(
        ('@' . __FILE__ . ':' . __LINE__),
    <<'END_OF_LUA', '');
        local asf = ...
        local bocage = asf.lmw_b
        if not bocage then error('No Bocage') end
        return bocage:_top_or_node()
END_OF_LUA

    # TODO: Why does Lua think this was a string?
    my $augment_and_node_id = $or_nodes->[$augment_or_node_id]->[0];
    my ($start_or_node_id)
        = $asf->call_by_tag(
        ('@' . __FILE__ . ':' . __LINE__),
            'local asf, id = ...; return asf.lmw_b:_and_node_cause(id)',
            'i',
            $augment_and_node_id
            );

    my $base_nidset = Marpa::R3::Nidset->obtain( $asf, $start_or_node_id );
    my $glade_id = $base_nidset->id();

    # Cannot "obtain" the glade if it is not registered
    $asf->[Marpa::R3::Internal_ASF::GLADES]->[$glade_id]
        ->[Marpa::R3::Internal::Glade::REGISTERED] = 1;
    glade_obtain( $asf, $glade_id );
    return $glade_id;
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
            local order = asf.lmw_o
            if not order then
                error( 'Parse failed' )
            end
            if order:is_null() == 1 then
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
    $asf->[Marpa::R3::Internal_ASF::NEXT_INTSET_ID] = 0;
    $asf->[Marpa::R3::Internal_ASF::INTSET_BY_KEY]  = {};
    $asf->[Marpa::R3::Internal_ASF::NIDSET_BY_ID]   = [];
    $asf->[Marpa::R3::Internal_ASF::POWERSET_BY_ID] = [];
    $asf->[Marpa::R3::Internal_ASF::GLADES] = [];

    my $or_nodes = $asf->[Marpa::R3::Internal_ASF::OR_NODES] = [];
    OR_NODE: for ( my $or_node_id = 0;; $or_node_id++ ) {

        my ($and_node_ids) = $asf->call_by_tag(
    ('@' . __FILE__ . ':' . __LINE__),
        <<'END_OF_LUA', 'i>*', $or_node_id );
        -- assumes throw mode
        local asf, or_node_id = ...
        local and_node_ids = {}
        local order = asf.lmw_o
        local count = order:_or_node_and_node_count(or_node_id)
        if not count then return and_node_ids end
        for ix = 1, count do
            and_node_ids[ix] =
                order:_or_node_and_node_id_by_ix(or_node_id, ix-1);
        end
        return and_node_ids
END_OF_LUA

        last OR_NODE if not scalar @{$and_node_ids};

        # Originally I had intended to sort the and node IDs by
        # MAJOR: and-node predecessor (or -1 if no predecessor) and
        # MINOR: and_node ID
        # Don't know why, and in fact I screwed up the implementation
        # and left the and nodes unsorted,
        # which is how they are in the current implementation.

        $or_nodes->[$or_node_id] = $and_node_ids;

    } ## end OR_NODE: for ( my $or_node_id = 0;; $or_node_id++ )

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

sub Marpa::R3::ASF::glade_is_visited {
    my ( $asf, $glade_id ) = @_;
    my $glade = $asf->[Marpa::R3::Internal_ASF::GLADES]->[$glade_id];
    return if not $glade;
    return $glade->[Marpa::R3::Internal::Glade::VISITED];
} ## end sub Marpa::R3::ASF::glade_is_visited

sub Marpa::R3::ASF::glade_visited_clear {
    my ( $asf, $glade_id ) = @_;
    my $glade_list =
        defined $glade_id
        ? [ $asf->[Marpa::R3::Internal_ASF::GLADES]->[$glade_id] ]
        : $asf->[Marpa::R3::Internal_ASF::GLADES];
    $_->[Marpa::R3::Internal::Glade::VISITED] = undef
        for grep {defined} @{$glade_list};
    return;
} ## end sub Marpa::R3::ASF::glade_visited_clear

sub nid_sort_ix {
    my ( $asf, $nid ) = @_;
    my $slr       = $asf->[Marpa::R3::Internal_ASF::SLR];

    if ( $nid >= 0 ) {
        my ($result) = $asf->call_by_tag(
        ('@' . __FILE__ . ':' . __LINE__),
        <<'END_OF_LUA', 'i', $nid);
        local asf, nid = ...
        local slr = asf.slr
        local irl_id = asf.lmw_b:_or_node_nrl(nid)
        return slr.slg.g1:_source_xrl(irl_id)
END_OF_LUA
        return $result;
    }

    my $and_node_id  = nid_to_and_node($nid);

    my ($result) = $asf->call_by_tag(
        ('@' . __FILE__ . ':' . __LINE__),
    <<'END_OF_LUA', 'i', $and_node_id);
    local asf, and_node_id = ...
    local slr = asf.slr
    local token_nsy_id = asf.lmw_b:_and_node_symbol(and_node_id)
    local token_id = slr.slg.g1:_source_xsy(token_nsy_id)
    -- -2 is reserved for 'end of data'
    return -token_id - 3
END_OF_LUA
    return $result;
} ## end sub nid_sort_ix

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

sub nid_rule_id {
    my ( $asf, $nid ) = @_;
    return if $nid < 0;

    my ($xrl_id) = $asf->call_by_tag(
        ('@' . __FILE__ . ':' . __LINE__),
    <<'END_OF_LUA', 'i', $nid);
    local asf, nid = ...
    local slr = asf.slr
    local irl_id = asf.lmw_b:_or_node_nrl(nid)
    local xrl_id = slr.slg.g1:_source_xrl(irl_id)
    return xrl_id
END_OF_LUA
    return $xrl_id;
}

sub or_node_es_span {
    my ( $asf, $choicepoint ) = @_;

    my ($origin_es, $current_es) = $asf->call_by_tag(
        ('@' . __FILE__ . ':' . __LINE__),
    <<'END_OF_LUA', 'i', $choicepoint);
    local asf, choicepoint = ...
    local slr = asf.slr
    local origin_es = asf.lmw_b:_or_node_origin(choicepoint)
    local current_es = asf.lmw_b:_or_node_set(choicepoint)
    return origin_es, current_es
END_OF_LUA

    return $origin_es, $current_es - $origin_es;
} ## end sub or_node_es_span

sub token_es_span {
    my ( $asf, $and_node_id ) = @_;

    my ($predecessor_id, $parent_or_node_id) = $asf->call_by_tag(
        ('@' . __FILE__ . ':' . __LINE__),
    <<'END_OF_LUA',
        local asf, and_node_id = ...
        local slr = asf.slr
        local b = asf.lmw_b
        return
            b:_and_node_predecessor(and_node_id),
            b:_and_node_parent(and_node_id)
END_OF_LUA
        'i', $and_node_id);

    if ( defined $predecessor_id ) {

        my ($origin_es, $current_es) = $asf->call_by_tag(
        ('@' . __FILE__ . ':' . __LINE__),
        <<'END_OF_LUA',
            local asf, predecessor_id, parent_or_node_id = ...
            local slr = asf.slr
            local b = asf.lmw_b
            return
                b:_or_node_set(predecessor_id),
                b:_or_node_set(parent_or_node_id)
END_OF_LUA
            'ii', $predecessor_id, $parent_or_node_id);

        return ( $origin_es, $current_es - $origin_es );
    }

    return or_node_es_span( $asf, $parent_or_node_id );
} ## end sub token_es_span

sub nid_literal {
    my ( $asf, $nid ) = @_;
    my $slr = $asf->[Marpa::R3::Internal_ASF::SLR];
    if ( $nid <= $NID_LEAF_BASE ) {
        my $and_node_id = nid_to_and_node($nid);
        my ( $start, $length ) = token_es_span( $asf, $and_node_id );
        return q{} if $length == 0;
        return $slr->g1_literal( $start, $length );
    } ## end if ( $nid <= $NID_LEAF_BASE )
    if ( $nid >= 0 ) {
        return $slr->g1_literal( or_node_es_span( $asf, $nid ) );
    }
    Marpa::R3::exception("No literal for node ID: $nid");
}

sub nid_span {
    my ( $asf, $nid ) = @_;
    my $slr = $asf->[Marpa::R3::Internal_ASF::SLR];
    if ( $nid <= $NID_LEAF_BASE ) {
        my $and_node_id = nid_to_and_node($nid);
        my ( $start, $length ) = token_es_span( $asf, $and_node_id );
        return ($start, 0) if $length == 0;
        return $start, $length;
    } ## end if ( $nid <= $NID_LEAF_BASE )
    if ( $nid >= 0 ) {
        return or_node_es_span( $asf, $nid );
    }
    Marpa::R3::exception("No literal for node ID: $nid");
}

sub nid_token_id {
    my ( $asf, $nid ) = @_;
    return if $nid > $NID_LEAF_BASE;
    my $and_node_id  = nid_to_and_node($nid);

    my ($token_id) = $asf->call_by_tag(
        ('@' . __FILE__ . ':' . __LINE__),
    <<'END_OF_LUA',
        local asf, and_node_id = ...
        local slr = asf.slr
        local token_nsy_id = asf.lmw_b:_and_node_symbol(and_node_id)
        local token_id = slr.slg.g1:_source_xsy(token_nsy_id)
        return token_id
END_OF_LUA
        'i', $and_node_id);

    return $token_id;
}

sub nid_symbol_id {
    my ( $asf, $nid ) = @_;
    my $token_id = nid_token_id($asf, $nid);
    return $token_id if defined $token_id;
    Marpa::R3::exception("No symbol ID for node ID: $nid") if $nid < 0;

    # Not a token, so return the LHS of the rule
    my ($lhs_id) = $asf->call_by_tag(
        ('@' . __FILE__ . ':' . __LINE__),
    <<'END_OF_LUA',
        local asf, nid = ...
        local slr = asf.slr
        local irl_id = asf.lmw_b:_or_node_nrl(nid)
        local g1g = slr.slg.g1
        local xrl_id = g1g:_source_xrl(irl_id)
        local lhs_id = g1g:rule_lhs(xrl_id)
        return lhs_id
END_OF_LUA
        'i', $nid);

    return $lhs_id;
}

sub nid_symbol_name {
    my ( $asf, $nid ) = @_;
    my $slr       = $asf->[Marpa::R3::Internal_ASF::SLR];
    my $slg = $slr->[Marpa::R3::Internal_R::SLG];
    my $symbol_id = nid_symbol_id($asf, $nid);
    return $slg->g1_symbol_name($symbol_id);
}

sub nid_token_name {
    my ( $asf, $nid ) = @_;
    my $slr      = $asf->[Marpa::R3::Internal_ASF::SLR];
    my $slg = $slr->[Marpa::R3::Internal_R::SLG];
    my $token_id = nid_token_id($asf, $nid);
    return if not defined $token_id;
    return $slg->g1_symbol_name($token_id);
}

# Memoization is heavily used -- it needs to be to keep the worst cases from
# going exponential.  The need to memoize is the reason for the very heavy use of
# hashes.  For example, quite often an HOH (hash of hashes) is used where
# an HoL (hash of lists) would usually be preferred.  But the HOL would leave me
# with the problem of having duplicates, which if followed up upon, would make
# the algorithm go exponential.

# For the "seen" hashes, the intent, in C, is to use a bit vector.  Since typically
# choicepoints will only use a tiny fraction of the or- and and-node space, I'll create
# a per-choicepoint index in the bit vector for each or- and and-node.  The index will
# per-ASF, and to avoid the overhead of clearing it, it will track, or each node, the
# current CP indexing it.  It is assumed that the indexes need only remain valid within
# the method call that constructs the CPI (choicepoint iterator).

sub first_factoring {
    my ($choicepoint, $nid_of_choicepoint) = @_;

    # Current NID of current SYMCH
    # The caller should ensure that we are never called unless the current
    # NID is for a rule.
    Marpa::R3::exception(
        "Internal error: first_factoring() called for negative NID: $nid_of_choicepoint"
    ) if $nid_of_choicepoint < 0;

    # Due to skipping, even the top or-node can have no valid choices
    my $asf      = $choicepoint->[Marpa::R3::Internal::Choicepoint::ASF];
    my $or_nodes = $asf->[Marpa::R3::Internal_ASF::OR_NODES];
    if ( not scalar @{ $or_nodes->[$nid_of_choicepoint] } ) {
        $choicepoint->[Marpa::R3::Internal::Choicepoint::FACTORING_STACK] =
            undef;
        return;
    }

    $choicepoint->[Marpa::R3::Internal::Choicepoint::OR_NODE_IN_USE]
        ->{$nid_of_choicepoint} = 1;
    my $nook = nook_new( $asf, $nid_of_choicepoint );
    $choicepoint->[Marpa::R3::Internal::Choicepoint::FACTORING_STACK] =
        [$nook];

    # Iterate as long as we cannot finish this stack
    while ( not factoring_finish($choicepoint, $nid_of_choicepoint) ) {
        return if not factoring_iterate($choicepoint);
    }
    return 1;

}

sub next_factoring {
    my ($choicepoint, $nid_of_choicepoint) = @_;
    my $factoring_stack =
        $choicepoint->[Marpa::R3::Internal::Choicepoint::FACTORING_STACK];
    Marpa::R3::exception(
        'Attempt to iterate factoring of uninitialized checkpoint')
        if not $factoring_stack;

    while ( factoring_iterate($choicepoint) ) {
        return 1 if factoring_finish($choicepoint, $nid_of_choicepoint);
    }

    # Found nothing to iterate
    return;
}

sub factoring_iterate {
    my ($choicepoint) = @_;
    my $asf = $choicepoint->[Marpa::R3::Internal::Choicepoint::ASF];
    my $factoring_stack =
        $choicepoint->[Marpa::R3::Internal::Choicepoint::FACTORING_STACK];
    FIND_NODE_TO_ITERATE: while (1) {
        if ( not scalar @{$factoring_stack} ) {
            $choicepoint->[Marpa::R3::Internal::Choicepoint::FACTORING_STACK]
                = undef;
            return;
        }
        my $top_nook = $factoring_stack->[-1];
        if ( nook_increment( $asf, $top_nook ) ) {
            last FIND_NODE_TO_ITERATE;    # in C, a "break" will do this
        }

        # Could not iterate
        # "Dirty" the corresponding bits in the parent and pop this nook
        my $stack_ix_of_parent_nook =
            $top_nook->[Marpa::R3::Internal::Nook::PARENT];
        if ( $stack_ix_of_parent_nook >= 0 ) {
            my $parent_nook = $factoring_stack->[$stack_ix_of_parent_nook];
            $parent_nook->[Marpa::R3::Internal::Nook::CAUSE_IS_EXPANDED] = 0
                if $top_nook->[Marpa::R3::Internal::Nook::IS_CAUSE];
            $parent_nook->[Marpa::R3::Internal::Nook::PREDECESSOR_IS_EXPANDED]
                = 0
                if $top_nook->[Marpa::R3::Internal::Nook::IS_PREDECESSOR];
        } ## end if ( $stack_ix_of_parent_nook >= 0 )

        my $top_or_node = $top_nook->[Marpa::R3::Internal::Nook::OR_NODE];
        $choicepoint->[Marpa::R3::Internal::Choicepoint::OR_NODE_IN_USE]
            ->{$top_or_node} = undef;
        pop @{$factoring_stack};
    } ## end FIND_NODE_TO_ITERATE: while (1)
    return 1;
} ## end sub factoring_iterate

sub factoring_finish {
    my ($choicepoint, $nid_of_choicepoint) = @_;
    my $asf           = $choicepoint->[Marpa::R3::Internal::Choicepoint::ASF];
    my $or_nodes      = $asf->[Marpa::R3::Internal_ASF::OR_NODES];
    my $factoring_stack =
        $choicepoint->[Marpa::R3::Internal::Choicepoint::FACTORING_STACK];

    my $nidset_by_id   = $asf->[Marpa::R3::Internal_ASF::NIDSET_BY_ID];

    my @worklist = ( 0 .. $#{$factoring_stack} );

    DO_WORKLIST: while ( scalar @worklist ) {
        my $stack_ix_of_work_nook = $worklist[-1];
        my $work_nook    = $factoring_stack->[$stack_ix_of_work_nook];
        my $work_or_node = $work_nook->[Marpa::R3::Internal::Nook::OR_NODE];
        my $working_choice =
            $work_nook->[Marpa::R3::Internal::Nook::FIRST_CHOICE];
        my $work_and_node_id = $or_nodes->[$work_or_node]->[$working_choice];
        my $child_or_node;
        my $child_is_cause;
        my $child_is_predecessor;
        FIND_CHILD_OR_NODE: {

            if ( !$work_nook->[Marpa::R3::Internal::Nook::CAUSE_IS_EXPANDED] )
            {
                if ( not nook_has_semantic_cause( $asf, $work_nook ) ) {
                    ($child_or_node) = $asf->call_by_tag(
        ('@' . __FILE__ . ':' . __LINE__),
                        'local asf, work_and_node_id = ...; return asf.lmw_b:_and_node_cause(work_and_node_id)',
                        'i',
                        $work_and_node_id);
                    $child_is_cause = 1;
                    last FIND_CHILD_OR_NODE;
                } ## end if ( not nook_has_semantic_cause( $asf, $work_nook ))
            } ## end if ( !$work_nook->[...])
            $work_nook->[Marpa::R3::Internal::Nook::CAUSE_IS_EXPANDED] = 1;
            if ( !$work_nook
                ->[Marpa::R3::Internal::Nook::PREDECESSOR_IS_EXPANDED] )
            {
                ($child_or_node) = $asf->call_by_tag(
        ('@' . __FILE__ . ':' . __LINE__),
                    'local asf, work_and_node_id = ...; return asf.lmw_b:_and_node_predecessor(work_and_node_id)',
                    'i',
                    $work_and_node_id);
                if ( defined $child_or_node ) {
                    $child_is_predecessor = 1;
                    last FIND_CHILD_OR_NODE;
                }
            } ## end if ( !$work_nook->[...])
            $work_nook->[Marpa::R3::Internal::Nook::PREDECESSOR_IS_EXPANDED] =
                1;
            pop @worklist;
            next DO_WORKLIST;
        } ## end FIND_CHILD_OR_NODE:

        return 0
            if
            $choicepoint->[Marpa::R3::Internal::Choicepoint::OR_NODE_IN_USE]
                ->{$child_or_node};

        return 0
            if not scalar @{ $or_nodes->[$work_or_node] };

        my $new_nook =
            nook_new( $asf, $child_or_node, $stack_ix_of_work_nook );
        if ($child_is_cause) {
            $new_nook->[Marpa::R3::Internal::Nook::IS_CAUSE]           = 1;
            $work_nook->[Marpa::R3::Internal::Nook::CAUSE_IS_EXPANDED] = 1;
        }
        if ($child_is_predecessor) {
            $new_nook->[Marpa::R3::Internal::Nook::IS_PREDECESSOR] = 1;
            $work_nook->[Marpa::R3::Internal::Nook::PREDECESSOR_IS_EXPANDED] =
                1;
        }
        push @{$factoring_stack}, $new_nook;
        push @worklist, $#{$factoring_stack};

    } ## end DO_WORKLIST: while ( scalar @worklist )

    return 1;

} ## end sub factoring_finish

sub and_nodes_to_cause_nids {
    my ( $asf, @and_node_ids ) = @_;
    my %causes = ();
    for my $and_node_id (@and_node_ids) {
        my ($cause_nid) = $asf->call_by_tag(
        ('@' . __FILE__ . ':' . __LINE__),
            'local asf, and_node_id = ...; return asf.lmw_b:_and_node_cause(and_node_id)',
            'i',
            $and_node_id);
        $cause_nid //= and_node_to_nid($and_node_id);
        $causes{$cause_nid} = 1;
    }
    return [ keys %causes ];
} ## end sub and_nodes_to_cause_nids

sub glade_id_factors {
    my ($choicepoint) = @_;
    my $asf           = $choicepoint->[Marpa::R3::Internal::Choicepoint::ASF];
    my $slr           = $asf->[Marpa::R3::Internal_ASF::SLR];
    my $slg = $slr->[Marpa::R3::Internal_R::SLG];
    my $or_nodes      = $asf->[Marpa::R3::Internal_ASF::OR_NODES];

    my @result;
    my $factoring_stack =
        $choicepoint->[Marpa::R3::Internal::Choicepoint::FACTORING_STACK];
    return if not $factoring_stack;
    FACTOR:
    for (
        my $factor_ix = 0;
        $factor_ix <= $#{$factoring_stack};
        $factor_ix++
        )
    {
        my $nook = $factoring_stack->[$factor_ix];
        next FACTOR if not nook_has_semantic_cause( $asf, $nook );
        my $or_node    = $nook->[Marpa::R3::Internal::Nook::OR_NODE];
        my $and_nodes  = $or_nodes->[$or_node];
        my $cause_nids = and_nodes_to_cause_nids(
            $asf,
            map { $and_nodes->[$_] } (
                $nook->[Marpa::R3::Internal::Nook::FIRST_CHOICE]
                    .. $nook->[Marpa::R3::Internal::Nook::LAST_CHOICE]
            )
        );
        my $base_nidset = Marpa::R3::Nidset->obtain( $asf, @{$cause_nids} );
        my $glade_id = $base_nidset->id();

        $asf->[Marpa::R3::Internal_ASF::GLADES]->[$glade_id]
            ->[Marpa::R3::Internal::Glade::REGISTERED] = 1;
        push @result, $glade_id;
    } ## end FACTOR: for ( my $factor_ix = 0; $factor_ix <= $#{...})
    return \@result;
} ## end sub glade_id_factors

sub glade_obtain {
    my ( $asf, $glade_id ) = @_;

    my $factoring_max = $asf->[Marpa::R3::Internal_ASF::FACTORING_MAX];

    my $glades = $asf->[Marpa::R3::Internal_ASF::GLADES];
    my $glade  = $glades->[$glade_id];
    if (   not defined $glade
        or not $glade->[Marpa::R3::Internal::Glade::REGISTERED] )
    {
        say Data::Dumper::Dumper($glade);
        Marpa::R3::exception(
            "Attempt to use an invalid glade, one whose ID is $glade_id");
    } ## end if ( not defined $glade or not $glade->[...])

    # Return the glade if it is already set up
    return $glade if $glade->[Marpa::R3::Internal::Glade::SYMCHES];

    my $base_nidset =
        $asf->[Marpa::R3::Internal_ASF::NIDSET_BY_ID]->[$glade_id];
    my $choicepoint;
    my $choicepoint_powerset;
    {
        my @source_data = ();
        for my $source_nid ( @{ $base_nidset->nids() } ) {
            my $sort_ix = nid_sort_ix( $asf, $source_nid );
            push @source_data, [ $sort_ix, $source_nid ];
        }
        my @sorted_source_data = sort { $a->[0] <=> $b->[0] } @source_data;
        my $nid_ix = 0;
        my ( $sort_ix_of_this_nid, $this_nid ) =
            @{ $sorted_source_data[ $nid_ix++ ] };
        my @nids_with_current_sort_ix = ();
        my $current_sort_ix           = $sort_ix_of_this_nid;
        my @symch_ids                 = ();
        NID: while (1) {

            if ( $sort_ix_of_this_nid != $current_sort_ix ) {

                # Currently only whole id break logic
                my $nidset_for_sort_ix = Marpa::R3::Nidset->obtain( $asf,
                    @nids_with_current_sort_ix );
                push @symch_ids, $nidset_for_sort_ix->id();
                @nids_with_current_sort_ix = ();
                $current_sort_ix           = $sort_ix_of_this_nid;
            } ## end if ( $sort_ix_of_this_nid != $current_sort_ix )
            last NID if not defined $this_nid;
            push @nids_with_current_sort_ix, $this_nid;
            my $sorted_entry = $sorted_source_data[ $nid_ix++ ];
            if ( defined $sorted_entry ) {
                ( $sort_ix_of_this_nid, $this_nid ) = @{$sorted_entry};
                next NID;
            }
            $this_nid            = undef;
            $sort_ix_of_this_nid = -2;
        } ## end NID: while (1)
        $choicepoint_powerset = Marpa::R3::Powerset->obtain( $asf, @symch_ids );
        $choicepoint->[Marpa::R3::Internal::Choicepoint::ASF] = $asf;
        $choicepoint->[Marpa::R3::Internal::Choicepoint::FACTORING_STACK] =
            undef;
    }

    # Check if choicepoint already seen?
    my @symches     = ();
    my $symch_count = $choicepoint_powerset->count();
    SYMCH: for ( my $symch_ix = 0; $symch_ix < $symch_count; $symch_ix++ ) {
        $choicepoint->[Marpa::R3::Internal::Choicepoint::FACTORING_STACK] =
            undef;
        my $symch_nidset = $choicepoint_powerset->nidset($asf, $symch_ix);
        my $choicepoint_nid = $symch_nidset->nid(0);
        my $g1_symch_rule_id = nid_rule_id($asf, $choicepoint_nid) // -1;

        # Initial undef indicates no factorings omitted
        my @factorings = ( $g1_symch_rule_id, undef );

        # For a token
        # There will not be multiple factorings or nids,
        # it is assumed, for a token
        if ( $g1_symch_rule_id < 0 ) {
            my $base_nidset = Marpa::R3::Nidset->obtain( $asf, $choicepoint_nid );
            my $glade_id    = $base_nidset->id();

            $asf->[Marpa::R3::Internal_ASF::GLADES]->[$glade_id]
                ->[Marpa::R3::Internal::Glade::REGISTERED] = 1;
            push @factorings, [$glade_id];
            push @symches, \@factorings;
            next SYMCH;
        } ## end if ( $g1_symch_rule_id < 0 )

        my $symch = $choicepoint_powerset->nidset($asf, $symch_ix);
        my $nid_count = $symch->count();
        FACTORINGS_LOOP:
        for ( my $nid_ix = 0; $nid_ix < $nid_count; $nid_ix++ ) {
            $choicepoint_nid = $symch_nidset->nid($nid_ix);
            first_factoring($choicepoint, $choicepoint_nid);
            my $factoring = glade_id_factors($choicepoint);

            FACTOR: while ( defined $factoring ) {
                if ( scalar @factorings > $factoring_max ) {

                    # update factorings omitted flag
                    $factorings[1] = 1;
                    last FACTORINGS_LOOP;
                }
                my @factoring = ();
                for (
                    my $item_ix = $#{$factoring};
                    $item_ix >= 0;
                    $item_ix--
                    )
                {
                    push @factoring, $factoring->[$item_ix];
                } ## end for ( my $item_ix = $#{$factoring}; $item_ix >= 0; ...)
                push @factorings, \@factoring;
                next_factoring($choicepoint, $choicepoint_nid);
                $factoring = glade_id_factors($choicepoint);
            } ## end FACTOR: while ( defined $factoring )
        } ## end FACTORINGS_LOOP: for ( my $nid_ix = 0; $nid_ix < $nid_count; $nid_ix...)
        push @symches, \@factorings;
    } ## end SYMCH: for ( my $symch_ix = 0; $symch_ix < $symch_count; ...)

    $glade->[Marpa::R3::Internal::Glade::SYMCHES] = \@symches;

    $glade->[Marpa::R3::Internal::Glade::ID] = $glade_id;
    $asf->[Marpa::R3::Internal_ASF::GLADES]->[$glade_id] = $glade;
    return $glade;
} ## end sub glade_obtain

sub Marpa::R3::ASF::glade_symch_count {
    my ( $asf, $glade_id ) = @_;
    my $glade = glade_obtain( $asf, $glade_id );
    Marpa::R3::exception("No glade found for glade ID $glade_id)") if not defined $glade;
    return scalar @{ $glade->[Marpa::R3::Internal::Glade::SYMCHES] };
}

sub Marpa::R3::ASF::glade_literal {
    my ( $asf, $glade_id ) = @_;
    my $nidset_by_id = $asf->[Marpa::R3::Internal_ASF::NIDSET_BY_ID];
    my $nidset       = $nidset_by_id->[$glade_id];
    Marpa::R3::exception("No glade found for glade ID $glade_id)") if not defined $nidset;
    my $nid0         = $nidset->nid(0);
    return nid_literal($asf, $nid0);
} ## end sub Marpa::R3::ASF::glade_literal

sub Marpa::R3::ASF::glade_g1_span {
    my ( $asf, $glade_id ) = @_;
    my $nidset_by_id = $asf->[Marpa::R3::Internal_ASF::NIDSET_BY_ID];
    my $nidset       = $nidset_by_id->[$glade_id];
    Marpa::R3::exception("No glade found for glade ID $glade_id)") if not defined $nidset;
    my $nid0         = $nidset->nid(0);
    my ($g1_start, $g1_length) = nid_span($asf, $nid0);
    return $g1_start, $g1_length;
}

sub Marpa::R3::ASF::glade_L0_length {
    my ( $asf, $glade_id ) = @_;
    my ($g1_start, $g1_length) = $asf->glade_g1_span( $glade_id );
    my $slr           = $asf->[Marpa::R3::Internal_ASF::SLR];

    my ($l0_length) = $slr->call_by_tag(
    ('@' . __FILE__ . ':' . __LINE__),
    <<'END_OF_LUA', 'ii', $g1_start, $g1_length);
    local slr, g1_start, g1_length = ...
    return slr:g1_span_l0_length(g1_start, g1_length)
END_OF_LUA
    return $l0_length;
}

sub Marpa::R3::ASF::g1_glade_symbol_id {
    my ( $asf, $glade_id ) = @_;
    my $nidset_by_id = $asf->[Marpa::R3::Internal_ASF::NIDSET_BY_ID];
    my $nidset       = $nidset_by_id->[$glade_id];
    Marpa::R3::exception("No glade found for glade ID $glade_id)") if not defined $nidset;
    my $nid0         = $nidset->nid(0);
    return nid_symbol_id($asf, $nid0);
}

sub Marpa::R3::ASF::g1_symch_rule_id {
    my ( $asf, $glade_id, $symch_ix ) = @_;
    my $glade = glade_obtain( $asf, $glade_id );
    my $symches = $glade->[Marpa::R3::Internal::Glade::SYMCHES];
    return if $symch_ix > $#{$symches};
    my ($rule_id) = @{ $symches->[$symch_ix] };
    return $rule_id;
}

sub Marpa::R3::ASF::symch_factoring_count {
    my ( $asf, $glade_id, $symch_ix ) = @_;
    my $glade = glade_obtain( $asf, $glade_id );
    Marpa::R3::exception("No glade found for glade ID $glade_id)") if not defined $glade;
    my $symches = $glade->[Marpa::R3::Internal::Glade::SYMCHES];
    return if $symch_ix > $#{$symches};
    return $#{ $symches->[$symch_ix] } - 1;    # length minus 2
} ## end sub Marpa::R3::ASF::symch_factoring_count

sub Marpa::R3::ASF::factoring_downglades {
    my ( $asf, $glade_id, $symch_ix, $factoring_ix ) = @_;
    my $glade = glade_obtain( $asf, $glade_id );
    Marpa::R3::exception("No glade found for glade ID $glade_id)") if not defined $glade;
    my $symches = $glade->[Marpa::R3::Internal::Glade::SYMCHES];
    Marpa::R3::exception("No symch #$symch_ix exists for glade ID $glade_id")
        if $symch_ix > $#{$symches};
    my $symch = $symches->[$symch_ix];
    my ( $rule_id, undef, @factorings ) = @{$symch};
    Marpa::R3::exception("No downglades for glade ID $glade_id, symch #$symch_ix: it is a token symch")
        if $rule_id < 0;
    return if $factoring_ix >= scalar @factorings;
    my $factoring = $factorings[$factoring_ix];
    return $factoring;
}

sub Marpa::R3::ASF::factoring_symbol_count {
    my ( $asf, $glade_id, $symch_ix, $factoring_ix ) = @_;
    my $factoring = $asf->factoring_downglades($glade_id, $symch_ix, $factoring_ix);
    return if not defined $factoring;
    return scalar @{$factoring};
} ## end sub Marpa::R3::ASF::factoring_symbol_count

sub Marpa::R3::ASF::factor_downglade {
    my ( $asf, $glade_id, $symch_ix, $factoring_ix, $symbol_ix ) = @_;
    my $factoring = $asf->factoring_downglades($glade_id, $symch_ix, $factoring_ix);
    return if not defined $factoring;
    return $factoring->[$symbol_ix];
} ## end sub Marpa::R3::ASF::factor_downglade

sub Marpa::R3::Internal_ASF::ambiguities {
    my ($asf) = @_;
    my $peak = $asf->peak();
    return Marpa::R3::Internal_ASF::glade_ambiguities( $asf, $peak, [] );
}

sub Marpa::R3::Internal_ASF::glade_ambiguities {
    my ( $asf, $glade, $seen ) = @_;
    return [] if $seen->[$glade];    # empty on revisit
    $seen->[$glade] = 1;
    my $grammar     = $asf->grammar();
    my $symch_count = $asf->glade_symch_count($glade);
    if ( $symch_count > 1 ) {
        my $literal      = $asf->glade_literal($glade);
        my $symbol_id    = $asf->g1_glade_symbol_id($glade);
        my $display_form = $grammar->g1_symbol_display_form($symbol_id);
        return [ [ 'symch', $glade, ] ];
    } ## end if ( $symch_count > 1 )
    my $g1_rule_id = $asf->g1_symch_rule_id( $glade, 0 );
    return [] if $g1_rule_id < 0;       # no ambiguities if a token

    # ignore any truncation of the factorings

    my $factoring_count = $asf->symch_factoring_count( $glade, 0 );
    if ( $factoring_count <= 1 ) {
        my $downglades = $asf->factoring_downglades( $glade, 0, 0 );
        my @problems =
            map { @{ glade_ambiguities( $asf, $_, $seen ) } } @{$downglades};
        return \@problems;
    } ## end if ( $factoring_count <= 1 )
    my @results           = ();

    my $downglades = $asf->factoring_downglades( $glade, 0, 0 );
    my $min_factors = $#{$downglades} + 1;
    my ( $upglade_start, $upglade_length ) = $asf->glade_g1_span($glade);
    my $sync_location = $upglade_start + $upglade_length;

    my @factors_by_factoring = ($downglades);
    for (
        my $factoring_ix = 1;
        $factoring_ix < $factoring_count;
        $factoring_ix++
        )
    {
        my $downglades =
            $asf->factoring_downglades( $glade, 0, $factoring_ix );
        my $factor_count = $#{$downglades} + 1;
        $min_factors =
            $min_factors > $factor_count ? $factor_count : $min_factors;

        # Determine a first potential
        # "sync location of the factors" from
        # the earliest start of the first downglade of any factoring.
        # Currently this will be the start of the parent glade, but this
        # method will be safe against any future hacks.
        my ($this_sync_location) = $asf->glade_g1_span( $downglades->[0] );
        $sync_location =
            List::Util::min( $this_sync_location, $sync_location );

        push @factors_by_factoring, $downglades;
    } ## end for ( my $factoring_ix = 1; $factoring_ix < $factoring_count...)

    my @factor_ix = (0) x $factoring_count;
    SYNC_PASS: while (1) {

        # Assume synced and unambiguous until we see otherwise.
        my $is_synced = 1;

        # First find a synch'ed set of factors, if we can
        FACTORING:
        for (
            my $factoring_ix = 0;
            $factoring_ix < $factoring_count;
            $factoring_ix++
            )
        {
            my $this_factor_ix = $factor_ix[$factoring_ix];
            my $this_downglade =
                $factors_by_factoring[$factoring_ix][$this_factor_ix];
            my ($this_start) = $asf->glade_g1_span($this_downglade);

            # To keep time complexity down we limit the number of times we deal
            # with a factoring at a sync location to 3, worst case -- a pass which
            # identifies it as a potential sync location, a pass which
            # (if possible) brings all the factors to that location, and a
            # pass which leaves all factor IX's where they are, and determines
            # we have found a sync location.  This makes out time O(f*n), where
            # f is the factoring count and n is the mininum number of factors.

            while ( $this_start < $sync_location ) {
                $factor_ix[$factoring_ix]++;
                last SYNC_PASS if $factor_ix[$factoring_ix] >= $min_factors;
                $this_start = $asf->glade_g1_span($this_downglade);
            } ## end if ( $this_start < $sync_location )
            if ( $this_start > $sync_location ) {
                $is_synced     = 0;
                $sync_location = $this_start;
            }
        } ## end FACTORING: for ( my $factoring_ix = 0; $factoring_ix < ...)

        next SYNC_PASS if not $is_synced;

        # If here, every factor starts at the sync location

        SYNCED_RESULT: {

            my $ambiguous_factors;
            my $first_factor_ix = $factor_ix[0];
            my $first_downglade = $factors_by_factoring[0][$first_factor_ix];

            FACTORING:
            for (
                my $factoring_ix = 1;
                $factoring_ix < $factoring_count;
                $factoring_ix++
                )
            {
                my $this_factor_ix = $factor_ix[$factoring_ix];
                my $this_downglade =
                    $factors_by_factoring[$factoring_ix][$this_factor_ix];
                if ( $this_downglade != $first_downglade ) {
                    $ambiguous_factors = [
                        $first_factor_ix, $factoring_ix,
                        $this_factor_ix
                    ];
                    last FACTORING;
                } ## end if ( $this_downglade != $first_downglade )

            } ## end FACTORING: for ( my $factoring_ix = 1; $factoring_ix < ...)

            # If here, all the the downglades are identical
            if ( not defined $ambiguous_factors ) {
                push @results,
                    @{ glade_ambiguities( $asf, $first_downglade, $seen ) };
                last SYNCED_RESULT;
            }

            # First factoring IX is always zero
            push @results,
                [ 'factoring', $glade, 0, @{$ambiguous_factors} ];
        } ## end SYNCED_RESULT:

        $factor_ix[$_]++ for 0 .. $factoring_count;
        last SYNC_PASS if List::Util::max(@factor_ix) >= $min_factors;

    } ## end SYNC_PASS: while (1)

    return \@results;

} ## end sub Marpa::R3::Internal_ASF::glade_ambiguities

# A generic display routine for ambiguities -- complex application will
# want to replace this, using it perhaps as a fallback.
sub Marpa::R3::Internal_ASF::ambiguities_show {
    my ( $asf, $ambiguities ) = @_;
    my $grammar = $asf->grammar();
    my $slr     = $asf->[Marpa::R3::Internal_ASF::SLR];
    my $result  = q{};
    AMBIGUITY: for my $ambiguity ( @{$ambiguities} ) {
        my $type = $ambiguity->[0];
        if ( $type eq 'symch' ) {

            my ( undef, $glade ) = @{$ambiguity};
            my $symbol_display_form =
                $grammar->g1_symbol_display_form(
                $asf->g1_glade_symbol_id($glade) );

            my $l0_length = $asf->glade_L0_length($glade);
            my ( $g1_start, $g1_length )       = $asf->glade_g1_span($glade);
            my ( $l0_block1,      $l0_pos1 )       = $slr->g1_to_block_first($g1_start);
            my ( $l0_block2,      $l0_pos2 )       = $slr->g1_to_block_last($g1_start + $g1_length -1);
            my $l0_range = $slr->lc_brief($l0_block1, $l0_pos1, $l0_block2, $l0_pos2);
            my $display_length = List::Util::min( $l0_length, 60 );
            $result
                .= qq{Ambiguous symch at Glade=$glade, Symbol=<$symbol_display_form>:\n};
            $result
                .= qq{  The ambiguity is at $l0_range\n};
            my $literal_label =
                $display_length == $l0_length ? 'Text is: ' : 'Text begins: ';

        my ($escaped_input) = $slr->call_by_tag(
        ('@' . __FILE__ . ':' . __LINE__),
        <<'END_OF_LUA', 'ii', $g1_start, $display_length);
        local slr, g1_start, input_length = ...
        return slr:g1_escape(g1_start, input_length)
END_OF_LUA

            $result
                .= q{  }
                . $literal_label
                . $escaped_input
                . qq{\n};

            my $symch_count = $asf->glade_symch_count($glade);
            my $display_symch_count = List::Util::min( 5, $symch_count );
            $result .=
                $symch_count == $display_symch_count
                ? "  There are $symch_count symches\n"
                : "  There are $symch_count symches -- showing only the first $display_symch_count\n";
            SYMCH_IX: for my $symch_ix ( 0 .. $display_symch_count - 1 ) {
                my $g1_rule_id = $asf->g1_symch_rule_id( $glade, $symch_ix );
                if ( $g1_rule_id < 0 ) {
                    $result .= "  Symch $symch_ix is a token\n";
                    next SYMCH_IX;
                }
                $result .= "  Symch $symch_ix is a rule: "
                    . $grammar->g1_rule_show($g1_rule_id) . "\n";
            } ## end SYMCH_IX: for my $symch_ix ( 0 .. $display_symch_count - 1 )

            next AMBIGUITY;
        } ## end if ( $type eq 'symch' )
        if ( $type eq 'factoring' ) {
            my $factoring_ix1 = 0;
            my ( undef, $glade, $symch_ix, $factor_ix1, $factoring_ix2,
                $factor_ix2 )
                = @{$ambiguity};
            my $first_downglades =
                $asf->factoring_downglades( $glade, $symch_ix, 0 );
            my $first_downglade = $first_downglades->[$factor_ix1];
            {
                my $these_downglades =
                    $asf->factoring_downglades( $glade, $symch_ix,
                    $factoring_ix2 );
                my $this_downglade = $these_downglades->[$factor_ix2];
                my $symbol_display_form =
                    $grammar->g1_symbol_display_form(
                    $asf->g1_glade_symbol_id($first_downglade) );

                my ( $g1_start, $g1_length ) =
                    $asf->glade_g1_span($first_downglade);
                my $g1_last = $g1_length > 0 ? ($g1_start + $g1_length - 1) : $g1_start;

                my ( $l0_block1,      $l0_pos1 )       = $slr->g1_to_block_first($g1_start);
                my ( $l0_block2,      $l0_pos2 )       = $slr->g1_to_block_last($g1_last);
                my $l0_range = $slr->lc_brief($l0_block1, $l0_pos1, $l0_block2, $l0_pos2);

                my $first_length = $asf->glade_L0_length($first_downglade);
                my $this_length = $asf->glade_L0_length($this_downglade);
                my $display_length =
                    List::Util::min( $first_length, $this_length, 60 );
                $result
                    .= qq{Length of symbol "$symbol_display_form" at $l0_range is ambiguous\n};

                if ( $display_length > 0 ) {

                    my ($piece) = $slr->call_by_tag(
                    ('@' . __FILE__ . ':' . __LINE__),
                    <<'END_OF_LUA', 'ii', $g1_start, $display_length);
                    local slr, g1_start, input_length = ...
                    local escaped_input = slr:g1_escape(g1_start, input_length)
                    return "  Choices start with: " .. escaped_input .. "\n"
END_OF_LUA

                    $result .= $piece;

                } ## end if ( $display_length > 0 )

                my @display_downglade = ( $first_downglade, $this_downglade );
                DISPLAY_GLADE:
                for (
                    my $glade_ix = 0;
                    $glade_ix <= $#display_downglade;
                    $glade_ix++
                    )
                {
                    # Choices may be zero length
                    my $choice_number = $glade_ix + 1;
                    my $glade_id      = $display_downglade[$glade_ix];
                    my $l0_length = $asf->glade_L0_length($glade_id);
                    if ( $l0_length <= 0 ) {
                        $result
                            .= qq{  Choice $choice_number is zero length\n};
                        next DISPLAY_GLADE;
                    }

                    my ( $g1_start, $g1_length ) = $asf->glade_g1_span($glade_id);
                    my ( $l0_block,      $l0_pos )       = $slr->g1_to_block_last($g1_start + $g1_length -1);
                    my $l0_location = $slr->lc_brief($l0_block, $l0_pos);

                    $result
                        .= qq{  Choice $choice_number, length=$l0_length, ends at $l0_location\n};

                    my ($piece) = $slr->call_by_tag(
                    ('@' . __FILE__ . ':' . __LINE__),
                    <<'END_OF_LUA', 'iiii', $choice_number, $g1_start, $g1_length, $l0_length);
                    local slr, choice_number, g1_start, g1_length, l0_length = ...
                    local subpieces = {}
                    local escaped_input
                    if l0_length > 60 then
                        escaped_input =
                            slr:reversed_g1_escape(g1_start + g1_length, 60)
                        subpieces[#subpieces+1] = string.format("  Choice %d ending: %s\n",
                            choice_number,
                            escaped_input)
                    end
                    local display_length = math.min(l0_length, 60)
                    escaped_input = slr:g1_escape(g1_start, display_length)
                    subpieces[#subpieces+1] = string.format("  Choice %d: %s\n",
                            choice_number,
                            escaped_input)
                    return table.concat(subpieces)
END_OF_LUA

                    $result .= $piece;

                } ## end DISPLAY_GLADE: for ( my $glade_ix = 0; $glade_ix <= ...)
                next AMBIGUITY;
            } ## end FACTORING: for ( my $factoring_ix = 1; $factoring_ix < ...)
            next AMBIGUITY;
        } ## end if ( $type eq 'factoring' )
        $result
            .= qq{Ambiguities of type "$type" not implemented:\n}
            . Data::Dumper::dumper($ambiguity);
        next AMBIGUITY;

    } ## end AMBIGUITY: for my $ambiguity ( @{$ambiguities} )
    return $result;
} ## end sub Marpa::R3::Internal_ASF::ambiguities_show

# The higher level calls

sub Marpa::R3::ASF::traverse {
    my ( $asf, $per_traverse_object, $method ) = @_;
    if ( ref $method ne 'CODE' ) {
        Marpa::R3::exception(
            'Argument to $asf->traverse() must be an anonymous subroutine');
    }
    if ( not ref $per_traverse_object ) {
        Marpa::R3::exception(
            'Argument to $asf->traverse() must be a reference');
    }
    my $peak       = $asf->peak();
    my $peak_glade = glade_obtain( $asf, $peak );
    my $traverser  = bless [], "Marpa::R3::Internal_ASF::Traverse";
    $traverser->[Marpa::R3::Internal_ASF::Traverse::ASF]      = $asf;
    $traverser->[Marpa::R3::Internal_ASF::Traverse::CODE]     = $method;
    $traverser->[Marpa::R3::Internal_ASF::Traverse::PER_TRAVERSE_OBJECT] = $per_traverse_object;
    $traverser->[Marpa::R3::Internal_ASF::Traverse::VALUES]   = [];
    $traverser->[Marpa::R3::Internal_ASF::Traverse::GLADE]    = $peak_glade;
    $traverser->[Marpa::R3::Internal_ASF::Traverse::SYMCH_IX] = 0;
    $traverser->[Marpa::R3::Internal_ASF::Traverse::FACTORING_IX] = 0;
    return $method->( $traverser, $per_traverse_object );
} ## end sub Marpa::R3::ASF::traverse

sub Marpa::R3::Internal_ASF::Traverse::all_choices {
    my ( $traverser ) = @_;

    my @values = Marpa::R3::Internal_ASF::Traverse::rh_values( $traverser );
    my @results = ( [] );
    for my $rh_ix ( 0 .. @values - 1 ) {
        my @new_results = ();
        for my $old_result (@results) {
            my $child_value = $values[$rh_ix];
            $child_value = [ $child_value ] unless ref $child_value eq 'ARRAY';
            for my $new_value ( @{ $child_value } ) {
                push @new_results, [ @{$old_result}, $new_value ];
            }
        }
        @results = @new_results;
    } ## end for my $rh_ix ( 0 .. $length - 1 )

    return @results;
}

# TODO -- Document this method
sub Marpa::R3::Internal_ASF::Traverse::asf {
    my ( $traverser ) = @_;
    return $traverser->[Marpa::R3::Internal_ASF::Traverse::ASF];
}

sub Marpa::R3::Internal_ASF::Traverse::literal {
    my ( $traverser ) = @_;
    my $asf = $traverser->[Marpa::R3::Internal_ASF::Traverse::ASF];
    my $glade = $traverser->[Marpa::R3::Internal_ASF::Traverse::GLADE];
    my $glade_id = $glade->[Marpa::R3::Internal::Glade::ID];
    return $asf->glade_literal($glade_id);
}

# TODO document span() -> g1_span()
sub Marpa::R3::Internal_ASF::Traverse::g1_span {
    my ( $traverser ) = @_;
    my $asf = $traverser->[Marpa::R3::Internal_ASF::Traverse::ASF];
    my $glade = $traverser->[Marpa::R3::Internal_ASF::Traverse::GLADE];
    my $glade_id = $glade->[Marpa::R3::Internal::Glade::ID];
    return $asf->glade_g1_span($glade_id);
}

sub Marpa::R3::Internal_ASF::Traverse::symbol_id {
    my ( $traverser ) = @_;
    my $asf = $traverser->[Marpa::R3::Internal_ASF::Traverse::ASF];
    my $glade = $traverser->[Marpa::R3::Internal_ASF::Traverse::GLADE];
    my $glade_id = $glade->[Marpa::R3::Internal::Glade::ID];
    return $asf->g1_glade_symbol_id($glade_id);
}

sub Marpa::R3::Internal_ASF::Traverse::rule_id {
    my ( $traverser ) = @_;
    my $glade = $traverser->[Marpa::R3::Internal_ASF::Traverse::GLADE];
    my $symch_ix =
        $traverser->[Marpa::R3::Internal_ASF::Traverse::SYMCH_IX];
    my $symch = $glade->[Marpa::R3::Internal::Glade::SYMCHES]->[$symch_ix];
    my ( $rule_id ) = @{$symch};
    return if $rule_id < 0;
    return $rule_id;
} ## end sub Marpa::R3::Internal_ASF::Traverse::rule_id

sub Marpa::R3::Internal_ASF::Traverse::rh_length {
    my ( $traverser ) = @_;
    my $glade = $traverser->[Marpa::R3::Internal_ASF::Traverse::GLADE];
    my $symch_ix =
        $traverser->[Marpa::R3::Internal_ASF::Traverse::SYMCH_IX];
    my $symch = $glade->[Marpa::R3::Internal::Glade::SYMCHES]->[$symch_ix];
    my ( $rule_id, undef, @factorings ) = @{$symch};
    Marpa::R3::exception(
        '$glade->rh_length($rh_ix) called for a token -- that is not allowed')
        if $rule_id < 0;
    my $factoring_ix =
        $traverser->[Marpa::R3::Internal_ASF::Traverse::FACTORING_IX];
    my $factoring = $factorings[$factoring_ix];
    return scalar @{$factoring};
} ## end sub Marpa::R3::Internal_ASF::Traverse::rh_length

sub Marpa::R3::Internal_ASF::Traverse::rh_value {
    my ( $traverser, $rh_ix ) = @_;
    my $glade = $traverser->[Marpa::R3::Internal_ASF::Traverse::GLADE];
    my $symch_ix =
        $traverser->[Marpa::R3::Internal_ASF::Traverse::SYMCH_IX];
    my $symch = $glade->[Marpa::R3::Internal::Glade::SYMCHES]->[$symch_ix];
    my ( $rule_id, undef, @factorings ) = @{$symch};
    Marpa::R3::exception(
        '$glade->rh_value($rh_ix) called for a token -- that is not allowed')
        if $rule_id < 0;
    my $factoring_ix =
        $traverser->[Marpa::R3::Internal_ASF::Traverse::FACTORING_IX];
    my $factoring = $factorings[$factoring_ix];
    return if $rh_ix > $#{$factoring};
    my $downglade_id = $factoring->[$rh_ix];
    my $memoized_value = $traverser->[Marpa::R3::Internal_ASF::Traverse::VALUES]->[$downglade_id];
    return $memoized_value if defined $memoized_value;
    my $asf = $traverser->[Marpa::R3::Internal_ASF::Traverse::ASF];
    my $downglade    = glade_obtain( $asf, $downglade_id );
    my $blessing     = ref $traverser;

    # A shallow clone
    my $child_traverser = bless [ @{$traverser} ], $blessing;
    $child_traverser->[Marpa::R3::Internal_ASF::Traverse::GLADE] =
        $downglade;
    $child_traverser->[Marpa::R3::Internal_ASF::Traverse::SYMCH_IX]     = 0;
    $child_traverser->[Marpa::R3::Internal_ASF::Traverse::FACTORING_IX] = 0;
    my $code  = $traverser->[Marpa::R3::Internal_ASF::Traverse::CODE];
    my $value = $code->(
        $child_traverser,
        $traverser->[Marpa::R3::Internal_ASF::Traverse::PER_TRAVERSE_OBJECT]
    );
    Marpa::R3::exception(
        'The ASF traversing method returned undef -- that is not allowed')
        if not defined $value;
    $traverser->[Marpa::R3::Internal_ASF::Traverse::VALUES]->[$downglade_id]
        = $value;
    return $value;
} ## end sub Marpa::R3::Internal_ASF::Traverse::rh_value

sub Marpa::R3::Internal_ASF::Traverse::rh_values {
    my ( $traverser ) = @_;
    return map { Marpa::R3::Internal_ASF::Traverse::rh_value( $traverser, $_ ) }
        0 .. Marpa::R3::Internal_ASF::Traverse::rh_length( $traverser ) - 1;
}

sub Marpa::R3::Internal_ASF::Traverse::next_factoring {
    my ($traverser) = @_;
    my $glade       = $traverser->[Marpa::R3::Internal_ASF::Traverse::GLADE];
    my $glade_id = $glade->[Marpa::R3::Internal::Glade::ID];
    my $asf         = $traverser->[Marpa::R3::Internal_ASF::Traverse::ASF];
    my $symch_ix = $traverser->[Marpa::R3::Internal_ASF::Traverse::SYMCH_IX];
    my $last_factoring =
        $asf->symch_factoring_count( $glade_id, $symch_ix ) - 1;
    my $factoring_ix =
        $traverser->[Marpa::R3::Internal_ASF::Traverse::FACTORING_IX];
    return if $factoring_ix >= $last_factoring;
    $factoring_ix++;
    $traverser->[Marpa::R3::Internal_ASF::Traverse::FACTORING_IX] =
        $factoring_ix;
    return $factoring_ix;
} ## end sub Marpa::R3::Internal_ASF::Traverse::next_factoring

sub Marpa::R3::Internal_ASF::Traverse::next_symch {
    my ($traverser) = @_;
    my $glade       = $traverser->[Marpa::R3::Internal_ASF::Traverse::GLADE];
    my $glade_id = $glade->[Marpa::R3::Internal::Glade::ID];
    my $asf         = $traverser->[Marpa::R3::Internal_ASF::Traverse::ASF];
    my $symch_ix = $traverser->[Marpa::R3::Internal_ASF::Traverse::SYMCH_IX];
    my $last_symch = $asf->glade_symch_count( $glade_id ) - 1;
    return if $symch_ix >= $last_symch;
    $symch_ix++;
    $traverser->[Marpa::R3::Internal_ASF::Traverse::SYMCH_IX] = $symch_ix;
    $traverser->[Marpa::R3::Internal_ASF::Traverse::FACTORING_IX] = 0;
    return $symch_ix;
} ## end sub Marpa::R3::Internal_ASF::Traverse::next_symch

sub Marpa::R3::Internal_ASF::Traverse::next {
    my ($traverser) = @_;
    return $traverser->next_factoring() // $traverser->next_symch();
}

# GLADE_SEEN is a local -- this is to silence warnings
our %GLADE_SEEN;

sub form_choice {
    my ( $parent_choice, $sub_choice ) = @_;
    return $sub_choice if not defined $parent_choice;
    return join q{.}, $parent_choice, $sub_choice;
}

sub Marpa::R3::ASF::dump_glade {
    my ( $asf, $glade_id, $parent_choice, $item_ix ) = @_;
    if ( $GLADE_SEEN{$glade_id} ) {
        return [ [0, $glade_id, "already displayed"] ];
    }
    $GLADE_SEEN{$glade_id} = 1;

    my $grammar      = $asf->grammar();
    my @lines        = ();
    my $symch_indent = 0;

    my $symch_count  = $asf->glade_symch_count($glade_id);
    my $symch_choice = $parent_choice;
    if ( $symch_count > 1 ) {
        $item_ix //= 0;
        push @lines,
              [ 0, undef, "Symbol #$item_ix "
            . $grammar->g1_symbol_display_form($asf->g1_glade_symbol_id($glade_id))
            . " has $symch_count symches" ];
        $symch_indent += 2;
        $symch_choice = form_choice( $parent_choice, $item_ix );
    } ## end if ( $symch_count > 1 )
    for ( my $symch_ix = 0; $symch_ix < $symch_count; $symch_ix++ ) {
        my $current_choice =
            $symch_count > 1
            ? form_choice( $symch_choice, $symch_ix )
            : $symch_choice;
        my $indent = $symch_indent;
        if ( $symch_count > 1 ) {
            push @lines, [ $symch_indent , undef, "Symch #$current_choice" ];
        }
        my $rule_id = $asf->g1_symch_rule_id( $glade_id, $symch_ix );
        if ( $rule_id >= 0 ) {
            push @lines,
                [
                $symch_indent, $glade_id,
                "Rule $rule_id: " . $grammar->g1_rule_show($rule_id)
                ];
            for my $line (
                @{ dump_factorings(
                    $asf, $glade_id, $symch_ix, $current_choice
                ) }
                )
            {
                my ( $line_indent, @rest_of_line ) = @{$line};
                push @lines, [ $line_indent + $symch_indent + 2, @rest_of_line ];
            } ## end for my $line ( dump_factorings( $asf, $glade_id, ...))
        } ## end if ( $rule_id >= 0 )
        else {
            my $line = dump_terminal( $asf, $glade_id, $current_choice );
            my ( $line_indent, @rest_of_line ) = @{$line};
            push @lines, [ $line_indent + $symch_indent, @rest_of_line ];
        } ## end else [ if ( $rule_id >= 0 ) ]
    } ## end for ( my $symch_ix = 0; $symch_ix < $symch_count; $symch_ix...)
    return \@lines;
}

# Show all the factorings of a SYMCH
sub dump_factorings {
    my ( $asf, $glade_id, $symch_ix, $parent_choice ) = @_;

    my @lines;
    my $factoring_count = $asf->symch_factoring_count( $glade_id, $symch_ix );
    for (
        my $factoring_ix = 0;
        $factoring_ix < $factoring_count;
        $factoring_ix++
        )
    {
        my $indent         = 0;
        my $current_choice = $parent_choice;
        if ( $factoring_count > 1 ) {
            $indent = 2;
            $current_choice = form_choice( $parent_choice, $factoring_ix );
            push @lines, [ 0, undef, "Factoring #$current_choice" ];
        }
        my $symbol_count =
            $asf->factoring_symbol_count( $glade_id, $symch_ix,
            $factoring_ix );
        SYMBOL: for my $symbol_ix ( 0 .. $symbol_count - 1 ) {
            my $downglade =
                $asf->factor_downglade( $glade_id, $symch_ix, $factoring_ix,
                $symbol_ix );
            for my $line (
                @{  $asf->dump_glade( $downglade, $current_choice,
                        $symbol_ix )
                }
                )
            {
                my ( $line_indent, @rest_of_line ) = @{$line};
                push @lines, [ $line_indent + $indent, @rest_of_line ];

            } ## end for my $line ( @{ $asf->dump_glade( $downglade, ...)})
        } ## end SYMBOL: for my $symbol_ix ( 0 .. $symbol_count - 1 )
    } ## end for ( my $factoring_ix = 0; $factoring_ix < $factoring_count...)
    return \@lines;
} ## end sub dump_factorings

sub dump_terminal {
    my ( $asf, $glade_id, $symch_ix, $parent_choice ) = @_;

    # There can only be one symbol in a terminal and therefore only one factoring
    my $current_choice = $parent_choice;
    my $literal        = $asf->glade_literal($glade_id);
    my $symbol_id    = $asf->g1_glade_symbol_id($glade_id);
    my $grammar = $asf->grammar();
    my $display_form = $grammar->g1_symbol_display_form($symbol_id);
    return [0, $glade_id, qq{Symbol $display_form: "$literal"}];
} ## end sub dump_terminal

sub Marpa::R3::ASF::dump {
    my ($asf) = @_;
    my $peak = $asf->peak();
    local %GLADE_SEEN = ();    ## no critic (Variables::ProhibitLocalVars)
    my $lines = $asf->dump_glade( $peak );
    my $next_sequenced_id = 1; # one-based
    my %sequenced_id = ();
    $sequenced_id{$_} //= $next_sequenced_id++ for grep { defined } map { $_->[1] } @{$lines};
    my $text = q{};
    for my $line ( @{$lines}[ 1 .. $#$lines ] ) {
        my ( $line_indent, $glade_id, $body ) = @{$line};
        $line_indent -= 2;
        $text .= q{ } x $line_indent;
        $text .=  'GL' . $sequenced_id{$glade_id} . q{ } if defined $glade_id;
        $text .= "$body\n";
    }
    return $text;
} ## end sub show

sub Marpa::R3::ASF::show_nidsets {
    my ($asf)   = @_;
    my $text    = q{};
    my $nidsets = $asf->[Marpa::R3::Internal_ASF::NIDSET_BY_ID];
    for my $nidset ( grep {defined} @{$nidsets} ) {
        $text .= $nidset->show() . "\n";
    }
    return $text;
} ## end sub Marpa::R3::ASF::show_nidsets

sub Marpa::R3::ASF::show_powersets {
    my ($asf)     = @_;
    my $text      = q{};
    my $powersets = $asf->[Marpa::R3::Internal_ASF::POWERSET_BY_ID];
    for my $powerset ( grep {defined} @{$powersets} ) {
        $text .= $powerset->show() . "\n";
    }
    return $text;
} ## end sub Marpa::R3::ASF::show_powersets

sub dump_nook {
    my ( $asf, $nook ) = @_;
    my $or_nodes   = $asf->[Marpa::R3::Internal_ASF::OR_NODES];
    my $or_node_id = $nook->[Marpa::R3::Internal::Nook::OR_NODE];
    my $and_node_count = scalar @{ $or_nodes->[$or_node_id] };
    my $text           = 'Nook ';
    my @text           = ();
    push @text, $nook->[Marpa::R3::Internal::Nook::IS_CAUSE] ? q{C} : q{-};
    push @text,
        $nook->[Marpa::R3::Internal::Nook::IS_PREDECESSOR] ? q{P} : q{-};
    push @text,
        $nook->[Marpa::R3::Internal::Nook::CAUSE_IS_EXPANDED] ? q{C+} : q{--};
    push @text,
        $nook->[Marpa::R3::Internal::Nook::PREDECESSOR_IS_EXPANDED]
        ? q{P+}
        : q{--};
    $text .= join q{ }, @text;
    $text
        .= ' @'
        . $nook->[Marpa::R3::Internal::Nook::FIRST_CHOICE] . q{-}
        . $nook->[Marpa::R3::Internal::Nook::LAST_CHOICE]
        . qq{ of $and_node_count: };
    $text .= $asf->verbose_or_node($or_node_id);
    return $text;
} ## end sub dump_nook

# For debugging
sub dump_factoring_stack {
    my ( $asf, $stack ) = @_;
    my $text = q{};
    for ( my $stack_ix = 0; $stack_ix <= $#{$stack}; $stack_ix++ ) {

        # Nook already has newline at end
        $text .= "$stack_ix: " . dump_nook( $asf, $stack->[$stack_ix] );
    }
    return $text . "\n";
} ## end sub dump_factoring_stack

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

# not to be documented
sub Marpa::R3::ASF::and_node_tag {
    my ( $asf, $and_node_id ) = @_;

    my ($tag) = $asf->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        << 'END_OF_LUA', 'i', $and_node_id );
    local asf, and_node_id=...
    return asf:and_node_tag(and_node_id)
END_OF_LUA

    return $tag;
}

# not to be documented
sub Marpa::R3::ASF::verbose_or_node {
    my ( $asf, $or_node_id ) = @_;
    my $slr = $asf->[Marpa::R3::Internal_ASF::SLR];
    my $slg = $slr->[Marpa::R3::Internal_R::SLG];

    my ($text, $nrl_id, $position)
        = $asf->call_by_tag(
    ('@' . __FILE__ . ':' . __LINE__),
        <<'END_OF_LUA', 'i', $or_node_id);
        local asf, or_node_id = ...
        local slr = asf.slr
        local bocage = asf.lmw_b
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
sub Marpa::R3::ASF::bocage_show {
    my ($asf)     = @_;

    my ($result) = $asf->call_by_tag(
    ('@' . __FILE__ . ':' . __LINE__),
        <<'END_OF_LUA', '');
        local asf = ...
        return asf:bocage_show()
END_OF_LUA

    return $result;
}

# not to be documented
sub Marpa::R3::ASF::or_nodes_show {
    my ( $asf ) = @_;

    my ($result) = $asf->call_by_tag(
    ('@' . __FILE__ . ':' . __LINE__),
    <<'END_OF_LUA', '');
    local asf = ...
    return asf:or_nodes_show()
END_OF_LUA

    return $result;
}

# not to be documented
sub Marpa::R3::ASF::and_nodes_show {
    my ( $asf ) = @_;
    my ($result) = $asf->call_by_tag(
    ('@' . __FILE__ . ':' . __LINE__),
    <<'END_OF_LUA', '');
    local asf = ...
    return asf:and_nodes_show()
END_OF_LUA

    return $result;
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
