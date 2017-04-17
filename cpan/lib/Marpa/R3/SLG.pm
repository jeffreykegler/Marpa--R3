# Marpa::R3 is Copyright (C) 2017, Jeffrey Kegler.
#
# This module is free software; you can redistribute it and/or modify it
# under the same terms as Perl 5.10.1. For more details, see the full text
# of the licenses in the directory LICENSES.
#
# This program is distributed in the hope that it will be
# useful, but it is provided “as is” and without any express
# or implied warranties. For details, see the full text of
# of the licenses in the directory LICENSES.

package Marpa::R3::Scanless::G;

use 5.010001;
use strict;
use warnings;

use vars qw($VERSION $STRING_VERSION);
$VERSION        = '4.001_043';
$STRING_VERSION = $VERSION;
## no critic(BuiltinFunctions::ProhibitStringyEval)
$VERSION = eval $VERSION;
## use critic

package Marpa::R3::Internal::Scanless::G;

use Scalar::Util 'blessed';
use English qw( -no_match_vars );

# names of packages for strings
our $PACKAGE = 'Marpa::R3::Scanless::G';

# The bare mininum Scanless grammer, suitable as a base
# for both metagrammar and user grammars.
sub pre_construct {
    my ($class) = @_;
    my $pre_slg = bless [], $class;
    $pre_slg->[Marpa::R3::Internal::Scanless::G::EXHAUSTION_ACTION] = 'fatal';
    $pre_slg->[Marpa::R3::Internal::Scanless::G::REJECTION_ACTION] = 'fatal';
    $pre_slg->[Marpa::R3::Internal::Scanless::G::TRACE_FILE_HANDLE] = \*STDERR;
    $pre_slg->[Marpa::R3::Internal::Scanless::G::CONSTANTS] = [];

    my $lua = Marpa::R3::Lua->new();
    $pre_slg->[Marpa::R3::Internal::Scanless::G::L] = $lua;

    my ($regix) = $lua->call_by_tag (-1,
        ('@' .__FILE__ . ':' .  __LINE__),
       <<'END_OF_LUA', '');
        local grammar = {}
        local registry = debug.getregistry()
        setmetatable(grammar, _M.class_slg)
        local regix = _M.register(registry, grammar)
        grammar.ref_count = 1
        grammar:post_new()
        grammar.ranking_method = 'none'
        grammar.l0_rules = {}
        grammar.l0_symbols = {}
        grammar.g1_rules = {}
        grammar.g1_symbols = {}
        return regix
END_OF_LUA

    $pre_slg->[Marpa::R3::Internal::Scanless::G::REGIX] = $regix;
    return $pre_slg;
}

sub Marpa::R3::Internal::Scanless::meta_grammar {

    my $meta_slg = pre_construct('Marpa::R3::Scanless::G');

    state $hashed_metag = Marpa::R3::Internal::MetaG::hashed_grammar();
    Marpa::R3::Internal::Scanless::G::hash_to_runtime( $meta_slg, $hashed_metag,
        { bless_package => 'Marpa::R3::Internal::MetaAST_Nodes' } );

    my $tracer = $meta_slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];

    return $meta_slg;

} ## end sub Marpa::R3::Internal::Scanless::meta_grammar

sub Marpa::R3::Scanless::G::new {
    my ( $class, @hash_ref_args ) = @_;

    my $slg = pre_construct($class);

    $slg->[Marpa::R3::Internal::Scanless::G::WARNINGS]        = 1;
    $slg->[Marpa::R3::Internal::Scanless::G::IF_INACCESSIBLE] = 'warn';

    my ( $flat_args, $error_message ) =
      Marpa::R3::flatten_hash_args( \@hash_ref_args );
    Marpa::R3::exception( sprintf $error_message, '$slg->new' )
      if not $flat_args;

    my ( $p_dsl, $g1_args ) =
      Marpa::R3::Internal::Scanless::G::set( $slg, $flat_args );
    my $ast        = Marpa::R3::Internal::MetaAST->new($p_dsl);
    my $hashed_ast = $ast->ast_to_hash($p_dsl);
    Marpa::R3::Internal::Scanless::G::hash_to_runtime( $slg, $hashed_ast,
        $g1_args );
    return $slg;
}

sub Marpa::R3::Scanless::G::DESTROY {
    # say STDERR "In Marpa::R3::Scanless::G::DESTROY before test";
    my $slg = shift;
    my $lua = $slg->[Marpa::R3::Internal::Scanless::G::L];

    # If we are destroying the Perl interpreter, then all the Marpa
    # objects will be destroyed, including Marpa's Lua interpreter.
    # We do not need to worry about cleaning up the
    # grammar is an orderly manner, because the Lua interpreter
    # containing the grammar will be destroyed.
    # In fact, the Lua interpreter may already have been destroyed,
    # so this test is necessary to avoid a warning message.
    return if not $lua;
    # say STDERR "In Marpa::R3::Scanless::G::DESTROY after test";

    my $regix = $slg->[Marpa::R3::Internal::Scanless::G::REGIX];
    $lua->call_by_tag($regix,
        ('@' . __FILE__ . ':' . __LINE__),
        <<'END_OF_LUA', 'i', $regix);
    local grammar, regix = ...
    local registry = debug.getregistry()
    _M.unregister(registry, regix)
END_OF_LUA
}

sub Marpa::R3::Scanless::G::set {
    my ( $slg, @hash_ref_args ) = @_;
    my ( $flat_args, $error_message ) =
      Marpa::R3::flatten_hash_args( \@hash_ref_args );
    Marpa::R3::exception( sprintf $error_message, '$slg->set' )
      if not $flat_args;

    my $value = $flat_args->{trace_file_handle};
    if ( defined $value ) {
        $slg->[Marpa::R3::Internal::Scanless::G::TRACE_FILE_HANDLE] = $value;
        delete $flat_args->{trace_file_handle};
    }

    my @bad_arguments = keys %{$flat_args};
    if ( scalar @bad_arguments ) {
        Marpa::R3::exception(
            q{Bad named argument(s) to $slg->set() method} . join q{ },
            @bad_arguments );
    }
    return $slg;
}

sub Marpa::R3::Internal::Scanless::G::set {
    my ( $slg, $flat_args ) = @_;

    my $dsl = $flat_args->{'source'};
    Marpa::R3::exception(
        qq{Marpa::R3::Scanless::G::new() called without a 'source' argument})
      if not defined $dsl;
    my $dsl_ref_type = ref $dsl;
    if ( $dsl_ref_type ne 'SCALAR' ) {
        my $desc = $dsl_ref_type ? "a ref to $dsl_ref_type" : 'not a ref';
        Marpa::R3::exception(
qq{'source' name argument to Marpa::R3::Scanless::G->new() is $desc\n},
            "  It should be a ref to a string\n"
        );
    }
    if ( not defined ${$dsl} ) {
        Marpa::R3::exception(
qq{'source' name argument to Marpa::R3::Scanless::G->new() is a ref to a an undef\n},
            "  It should be a ref to a string\n"
        );
    } ## end if ( $ref_type ne 'SCALAR' )
    delete $flat_args->{'source'};

    my $value = $flat_args->{trace_file_handle};
    if ( defined $value ) {
        $slg->[Marpa::R3::Internal::Scanless::G::TRACE_FILE_HANDLE] = $value;
        delete $flat_args->{'trace_file_handle'};
    }

    my $trace_file_handle = 
        $slg->[Marpa::R3::Internal::Scanless::G::TRACE_FILE_HANDLE];

    if ( exists $flat_args->{'trace_actions'} ) {
        my $value = $flat_args->{'trace_actions'};
        $slg->[Marpa::R3::Internal::Scanless::G::TRACE_ACTIONS] = $value;
        if ($value) {
            say {$trace_file_handle} 'Setting trace_actions option'
              or Marpa::R3::exception("Cannot print: $ERRNO");
        }
        delete $flat_args->{'trace_actions'};
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
        $slg->[Marpa::R3::Internal::Scanless::G::EXHAUSTION_ACTION] = $value;
        delete $flat_args->{'exhaustion'};

    }

    if ( exists $flat_args->{'rejection'} ) {

        state $rejection_actions = { map { ( $_, 0 ) } qw(fatal event) };
        my $value = $flat_args->{'rejection'} // 'undefined';
        Marpa::R3::exception(
            qq{'rejection' named arg value is $value (should be one of },
            ( join q{, }, map { q{'} . $_ . q{'} } keys %{$rejection_actions} ),
            ')'
        ) if not exists $rejection_actions->{$value};
        $slg->[Marpa::R3::Internal::Scanless::G::REJECTION_ACTION] = $value;
        delete $flat_args->{'rejection'};

    }

    if ( exists $flat_args->{'semantics_package'} ) {
        my $value = $flat_args->{'semantics_package'};
        $slg->[Marpa::R3::Internal::Scanless::G::SEMANTICS_PACKAGE] = $value;
        delete $flat_args->{'semantics_package'};
    }

    if ( exists $flat_args->{'ranking_method'} ) {

        # Only allowed in new method
        my $value = $flat_args->{'ranking_method'} // 'undefined';

    $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 's', $value);
    local slg, value = ...
    if not _M.ranking_methods[value] then
        local list = {}
        for method,_ in pairs(_M.ranking_methods) do
            list[#list+1] = string.format('%q', key)
        end
        error(string.format(
            'ranking_method value is %q (should be one of %s)',
            value, table.concat(list, ', ')
        ))
    end
    slg.ranking_method = value
END_OF_LUA

        delete $flat_args->{'ranking_method'};
    }

    return ( $dsl, $flat_args );

} ## end sub Marpa::R3::Internal::Scanless::G::set

# not to be documented
sub per_lmg_init {
    my ( $slg, $name ) = @_;
    my $field_name_form = lc $name;
    my $per_lmg = [];
    $per_lmg->[Marpa::R3::Internal::Trace::G::NAME] = $name;
    my $lmw_name = 'lmw_' . $field_name_form . 'g';
    $per_lmg->[Marpa::R3::Internal::Trace::G::LMW_NAME]            = $lmw_name;
    $per_lmg->[Marpa::R3::Internal::Trace::G::XSY_BY_ISYID]        = [];
    $slg->[Marpa::R3::Internal::Scanless::G::PER_LMG]->{$lmw_name} = $per_lmg;

    $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 's', $field_name_form );
    local g, field_name_form = ...
    lmw_g_name = 'lmw_' .. field_name_form .. 'g'
    g[lmw_g_name] = kollos.grammar_new()
    g[field_name_form] = {}
    g[field_name_form].xsy_by_isyid = {}
    local lmw_g = g[lmw_g_name]
    lmw_g:force_valued()
    lmw_g.short_name = field_name_form
END_OF_LUA

    return $per_lmg;
}

sub Marpa::R3::Internal::Scanless::G::hash_to_runtime {
    my ( $slg, $hashed_source, $g1_args ) = @_;

    my $trace_fh = $slg->[Marpa::R3::Internal::Scanless::G::TRACE_FILE_HANDLE];
    # Pre-lexer G1 processing

    my $g1_tracer = $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER] =
      per_lmg_init($slg, "G1");
    my $lex_tracer = $slg->[Marpa::R3::Internal::Scanless::G::L0_TRACER] =
      per_lmg_init($slg, "L0");

    my $xsy_names = [ keys %{ $hashed_source->{xsy} } ];

    my $xsy_by_id = $slg->[Marpa::R3::Internal::Scanless::G::XSY_BY_ID] = [];
    my $xsy_by_name = $slg->[Marpa::R3::Internal::Scanless::G::XSY_BY_NAME] =
      {};
    $xsy_names = [ sort @{$xsy_names} ];
    for my $xsy_name ( @{$xsy_names} ) {
        my $runtime_xsy_data = [];
        $runtime_xsy_data->[Marpa::R3::Internal::XSY::NAME] = $xsy_name;
        my $source_xsy_data = $hashed_source->{xsy}->{$xsy_name};
      KEY: for my $datum_key ( keys %{$source_xsy_data} ) {
            if ( $datum_key eq 'action' ) {
                $runtime_xsy_data->[Marpa::R3::Internal::XSY::LEXEME_SEMANTICS]
                  = $source_xsy_data->{$datum_key};
                next KEY;
            }
            if ( $datum_key eq 'blessing' ) {
                $runtime_xsy_data->[Marpa::R3::Internal::XSY::BLESSING] =
                  $source_xsy_data->{$datum_key};
                next KEY;
            }
        }
        $runtime_xsy_data->[Marpa::R3::Internal::XSY::ID] = scalar @{$xsy_by_id};
        push @{$xsy_by_id}, $runtime_xsy_data;
        $xsy_by_name->{$xsy_name} = $runtime_xsy_data;
    }

    # ($xsy_names) =
    $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 's', $hashed_source );
        local slg, source_hash = ...
        slg.xsys = {}
        -- io.stderr:write(inspect(source_hash))
        local xsy_names = {}
        local hash_xsy_data = source_hash.xsy
        for xsy_name, _ in pairs(hash_xsy_data) do
             xsy_names[#xsy_names+1] = xsy_name
        end
        table.sort(xsy_names)
        for ix = 1, #xsy_names do
            -- during development, zero-based so that it duplicates original
            -- Perl implementation
            local xsy_name = xsy_names[ix]
            local runtime_xsy = { name = xsy_name }

            local xsy_source = hash_xsy_data[xsy_name]

            -- copy, so that we can destroy `source_hash`
            runtime_xsy.lexeme_semantics = xsy_source.action
            runtime_xsy.blessing = xsy_source.blessing
            runtime_xsy.dsl_form = xsy_source.dsl_form
            runtime_xsy.if_inaccessible = xsy_source.if_inaccessible
            runtime_xsy.name_source = xsy_source.name_source

            slg.xsys[xsy_name] = runtime_xsy
        end
        -- io.stderr:write(inspect(xsy_names), "\n")
        -- io.stderr:write("Before returning xsy_names\n")
        -- return xsy_names
END_OF_LUA

    # say STDERR Data::Dumper::Dumper($xsy_names);

    $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 's', $xsy_names );
        local slg, xsy_names = ...
        -- io.stderr:write(inspect(xsy_names), "\n")
        xsys = slg.xsys
        for ix = 1, #xsy_names do
            local xsy_name = xsy_names[ix]
            local xsy_source = xsys[xsy_name]
            -- TODO delete next test after development
            if not xsy_source then
                 error("No xsy for " .. inspect(xsy_name))
            end
            local xsy_id = ix - 1
            xsy_source.id = xsy_id
            xsys[xsy_id] = xsy_source
        end
END_OF_LUA

    $slg->[Marpa::R3::Internal::Scanless::G::XRL_BY_ID]   = [];
    $slg->[Marpa::R3::Internal::Scanless::G::XRL_BY_NAME] = {};
    my $xrls        = $hashed_source->{xrl};
    my $xrl_by_id   = $slg->[Marpa::R3::Internal::Scanless::G::XRL_BY_ID];
    my $xrl_by_name = $slg->[Marpa::R3::Internal::Scanless::G::XRL_BY_NAME];

    # Sort (from major to minor) by start position,
    # and subkey.
    for my $xrl_name (
        map  { $_->[0] }
        sort { $a->[1] <=> $b->[1] }
        map  { [ $_, $xrls->{$_}->{start} ] } keys %{$xrls}
      )
    {
        my $source_xrl_data  = $xrls->{$xrl_name};
        my $runtime_xrl_data = [];
        $runtime_xrl_data->[Marpa::R3::Internal::XRL::ID] =
          scalar @{$xrl_by_id};
        $runtime_xrl_data->[Marpa::R3::Internal::XRL::NAME] = $xrl_name;
      KEY: for my $datum_key ( keys %{$source_xrl_data} ) {
            if ( $datum_key eq 'id' ) {
                $runtime_xrl_data->[Marpa::R3::Internal::XRL::NAME] =
                  $source_xrl_data->{$datum_key};
                next KEY;
            }
            if ( $datum_key eq 'precedence_count' ) {
                $runtime_xrl_data->[Marpa::R3::Internal::XRL::PRECEDENCE_COUNT]
                  = $source_xrl_data->{$datum_key};
                next KEY;
            }
            if ( $datum_key eq 'lhs' ) {
                $runtime_xrl_data->[Marpa::R3::Internal::XRL::LHS] =
                  $source_xrl_data->{$datum_key};
                next KEY;
            }
            if ( $datum_key eq 'start' ) {
                $runtime_xrl_data->[Marpa::R3::Internal::XRL::START] =
                  $source_xrl_data->{$datum_key};
                next KEY;
            }
            if ( $datum_key eq 'length' ) {
                $runtime_xrl_data->[Marpa::R3::Internal::XRL::LENGTH] =
                  $source_xrl_data->{$datum_key};
                next KEY;
            }
            Marpa::R3::exception(
                "Internal error: Unknown hashed source xrl field: $datum_key");
        }
        push @{$xrl_by_id}, $runtime_xrl_data;
        $xrl_by_name->{$xrl_name} = $runtime_xrl_data;
    }

    $slg->[Marpa::R3::Internal::Scanless::G::L0_XBNF_BY_ID]   = [];
    $slg->[Marpa::R3::Internal::Scanless::G::G1_XBNF_BY_ID]   = [];
    $slg->[Marpa::R3::Internal::Scanless::G::L0_XBNF_BY_NAME] = {};
    $slg->[Marpa::R3::Internal::Scanless::G::G1_XBNF_BY_NAME] = {};
    for my $subgrammar (qw(G1 L0)) {
        my $xbnfs = $hashed_source->{xbnf}->{$subgrammar};
        my $xbnf_by_id =
            $subgrammar eq 'L0'
          ? $slg->[Marpa::R3::Internal::Scanless::G::L0_XBNF_BY_ID]
          : $slg->[Marpa::R3::Internal::Scanless::G::G1_XBNF_BY_ID];
        my $xbnf_by_name =
            $subgrammar eq 'L0'
          ? $slg->[Marpa::R3::Internal::Scanless::G::L0_XBNF_BY_NAME]
          : $slg->[Marpa::R3::Internal::Scanless::G::G1_XBNF_BY_NAME];

        # Sort (from major to minor) by start position,
        # and subkey.
        for my $xbnf_name (
            map { $_->[0] }
            sort {
                # die  "a=", Data::Dumper::Dumper($a) if not defined $a->[1];
                # die  "a=", Data::Dumper::Dumper($a) if not defined $a->[2];
                # die  "b=", Data::Dumper::Dumper($b) if not defined $a->[1];
                # die  "b=", Data::Dumper::Dumper($b) if not defined $b->[2];
                $a->[1] <=> $b->[1]
                  || $a->[2] <=> $b->[2]
            }
            map { [ $_, $xbnfs->{$_}->{start}, $xbnfs->{$_}->{subkey} ] }
            keys %{$xbnfs}
          )
        {
            $DB::single = 1 if not defined $xbnf_name;
            my $source_xbnf_data  = $xbnfs->{$xbnf_name};
            my $runtime_xbnf_data = [];
            $runtime_xbnf_data->[Marpa::R3::Internal::XBNF::ID] =
              scalar @{$xbnf_by_id};
          KEY: for my $datum_key ( keys %{$source_xbnf_data} ) {
                if ( $datum_key eq 'xrlid' ) {
                    $runtime_xbnf_data->[Marpa::R3::Internal::XBNF::XRL] =
                      $xrl_by_name->{$datum_key};
                    next KEY;
                }
                if ( $datum_key eq 'name' ) {
                    $runtime_xbnf_data->[Marpa::R3::Internal::XBNF::NAME] =
                      $source_xbnf_data->{$datum_key};
                    next KEY;
                }
                if ( $datum_key eq 'lhs' ) {
                    $runtime_xbnf_data->[Marpa::R3::Internal::XBNF::LHS] =
                      $source_xbnf_data->{$datum_key};
                    next KEY;
                }
                if ( $datum_key eq 'rhs' ) {
                    $runtime_xbnf_data->[Marpa::R3::Internal::XBNF::RHS] =
                      $source_xbnf_data->{$datum_key};
                    next KEY;
                }
                if ( $datum_key eq 'rank' ) {
                    $runtime_xbnf_data->[Marpa::R3::Internal::XBNF::RANK] =
                      $source_xbnf_data->{$datum_key};
                    next KEY;
                }
                if ( $datum_key eq 'null_ranking' ) {
                    $runtime_xbnf_data
                      ->[Marpa::R3::Internal::XBNF::NULL_RANKING] =
                      $source_xbnf_data->{$datum_key};
                    next KEY;
                }
                if ( $datum_key eq 'symbol_as_event' ) {
                    $runtime_xbnf_data
                      ->[Marpa::R3::Internal::XBNF::SYMBOL_AS_EVENT] =
                      $source_xbnf_data->{$datum_key};
                    next KEY;
                }
                if ( $datum_key eq 'event' ) {
                    $runtime_xbnf_data->[Marpa::R3::Internal::XBNF::EVENT] =
                      $source_xbnf_data->{$datum_key};
                    next KEY;
                }
                if ( $datum_key eq 'min' ) {
                    $runtime_xbnf_data->[Marpa::R3::Internal::XBNF::MIN] =
                      $source_xbnf_data->{$datum_key};
                    next KEY;
                }
                if ( $datum_key eq 'separator' ) {
                    $runtime_xbnf_data->[Marpa::R3::Internal::XBNF::SEPARATOR]
                      = $source_xbnf_data->{$datum_key};
                    next KEY;
                }
                if ( $datum_key eq 'proper' ) {
                    $runtime_xbnf_data->[Marpa::R3::Internal::XBNF::PROPER] =
                      $source_xbnf_data->{$datum_key};
                    next KEY;
                }
                if ( $datum_key eq 'bless' ) {
                    $runtime_xbnf_data->[Marpa::R3::Internal::XBNF::BLESSING] =
                      $source_xbnf_data->{$datum_key};
                    next KEY;
                }
                if ( $datum_key eq 'action' ) {
                    $runtime_xbnf_data->[Marpa::R3::Internal::XBNF::ACTION_NAME]
                      = $source_xbnf_data->{$datum_key};
                    next KEY;
                }
                if ( $datum_key eq 'start' ) {
                    $runtime_xbnf_data->[Marpa::R3::Internal::XBNF::START] =
                      $source_xbnf_data->{$datum_key};
                    next KEY;
                }
                if ( $datum_key eq 'length' ) {
                    $runtime_xbnf_data->[Marpa::R3::Internal::XBNF::LENGTH] =
                      $source_xbnf_data->{$datum_key};
                    next KEY;
                }
                if ( $datum_key =~ /\A (mask|keep|subkey|id) \z/xms ) {
                    next KEY;
                }
                Marpa::R3::exception(
"Internal error: Unknown hashed source xbnf field: $datum_key"
                );
            }

            $runtime_xbnf_data->[Marpa::R3::Internal::XBNF::DISCARD_SEPARATION]
              = $runtime_xbnf_data->[Marpa::R3::Internal::XBNF::SEPARATOR]
              && !$source_xbnf_data->{keep};

            my $rhs_length =
              scalar @{ $runtime_xbnf_data->[Marpa::R3::Internal::XBNF::RHS] };

            if ( $rhs_length == 0
                || !
                defined $runtime_xbnf_data->[Marpa::R3::Internal::XBNF::MIN] )
            {
                my $explicit_mask = $source_xbnf_data->{mask};
                if ($explicit_mask) {
                    $runtime_xbnf_data->[Marpa::R3::Internal::XBNF::MASK] =
                      $explicit_mask;
                }
                else {
                    $runtime_xbnf_data->[Marpa::R3::Internal::XBNF::MASK] =
                      [ (1) x $rhs_length ];
                }
            }

            push @{$xbnf_by_id}, $runtime_xbnf_data;
            $xbnf_by_name->{$xbnf_name} = $runtime_xbnf_data;
        }
    }

    my $if_inaccessible_default_arg =
      $hashed_source->{defaults}->{if_inaccessible};
    if ( defined $if_inaccessible_default_arg ) {
        $slg->[Marpa::R3::Internal::Scanless::G::IF_INACCESSIBLE] =
          $if_inaccessible_default_arg;
    }
    my $if_inaccessible_default =
      $slg->[Marpa::R3::Internal::Scanless::G::IF_INACCESSIBLE];

    # Create the the G1 grammar

    if ( defined( my $value = $g1_args->{'bless_package'} ) ) {
        $slg->[Marpa::R3::Internal::Scanless::G::BLESS_PACKAGE] = $value;
        delete $g1_args->{'bless_package'};
    }

    if ( defined( my $value = $g1_args->{'warnings'} ) ) {
        $slg->[Marpa::R3::Internal::Scanless::G::WARNINGS] = $value;
        delete $g1_args->{'warnings'};
    }

    $slg->call_by_tag(
        ('@' .__FILE__ . ':' .  __LINE__),
        <<'END_OF_LUA', '');
        local grammar = ...
        local g1g = grammar.lmw_g1g
        g1g.start_name = '[:start]'
END_OF_LUA

    for my $symbol ( sort keys %{ $hashed_source->{symbols}->{G1} } ) {
        assign_G1_symbol( $slg, $symbol,
            $hashed_source->{symbols}->{G1}->{$symbol} );
    }

    add_G1_user_rules( $slg, $hashed_source->{rules}->{G1} );

    my @bad_arguments = keys %{$g1_args};
    if ( scalar @bad_arguments ) {
        Marpa::R3::exception(
            q{Internal error: Bad named argument(s) to hash_to_runtime() method}
              . join q{ },
            @bad_arguments
        );
    }

    my $symbol_ids_by_event_name_and_type = {};
    $slg->[Marpa::R3::Internal::Scanless::G::SYMBOL_IDS_BY_EVENT_NAME_AND_TYPE]
      = $symbol_ids_by_event_name_and_type;

    my $completion_events_by_name = $hashed_source->{completion_events};
    my $completion_events_by_id =
      $slg->[Marpa::R3::Internal::Scanless::G::COMPLETION_EVENT_BY_ID] = [];
    for my $symbol_name ( keys %{$completion_events_by_name} ) {
        my ( $event_name, $is_active ) =
          @{ $completion_events_by_name->{$symbol_name} };
        my $symbol_id = $slg->symbol_by_name($symbol_name);
        if ( not defined $symbol_id ) {
            Marpa::R3::exception(
"Completion event defined for non-existent symbol: $symbol_name\n"
            );
        }

        # Must be done before precomputation

    $slg->call_by_tag(
        ('@' .__FILE__ . ':' .  __LINE__),
        <<'END_OF_LUA', 'ii', $symbol_id, ($is_active ? 1 : 0));
        local grammar, symbol_id, is_active = ...
        local g1g = grammar.lmw_g1g
        g1g:symbol_is_completion_event_set(symbol_id, 1)
        if is_active == 0 then
            g1g:completion_symbol_activate(symbol_id, 0)
        end
END_OF_LUA

        $slg->[Marpa::R3::Internal::Scanless::G::COMPLETION_EVENT_BY_ID]
          ->[$symbol_id] = $event_name;
        push @{ $symbol_ids_by_event_name_and_type->{$event_name}->{completion}
        }, $symbol_id;
    } ## end for my $symbol_name ( keys %{$completion_events_by_name...})

    my $nulled_events_by_name = $hashed_source->{nulled_events};
    my $nulled_events_by_id =
      $slg->[Marpa::R3::Internal::Scanless::G::NULLED_EVENT_BY_ID] = [];
    for my $symbol_name ( keys %{$nulled_events_by_name} ) {
        my ( $event_name, $is_active ) =
          @{ $nulled_events_by_name->{$symbol_name} };
        my $symbol_id = $slg->symbol_by_name($symbol_name);
        if ( not defined $symbol_id ) {
            Marpa::R3::exception(
                "nulled event defined for non-existent symbol: $symbol_name\n"
            );
        }

        # Must be done before precomputation
    $slg->call_by_tag(
        ('@' .__FILE__ . ':' .  __LINE__),
        <<'END_OF_LUA', 'ii', $symbol_id, ($is_active ? 1 : 0));
        local grammar, symbol_id, is_active = ...
        local g1g = grammar.lmw_g1g
        g1g:symbol_is_nulled_event_set(symbol_id, 1)
        if is_active == 0 then
            g1g:nulled_symbol_activate(symbol_id, 0)
        end
END_OF_LUA

        $slg->[Marpa::R3::Internal::Scanless::G::NULLED_EVENT_BY_ID]
          ->[$symbol_id] = $event_name;
        push @{ $symbol_ids_by_event_name_and_type->{$event_name}->{nulled} },
          $symbol_id;
    } ## end for my $symbol_name ( keys %{$nulled_events_by_name} )

    my $prediction_events_by_name = $hashed_source->{prediction_events};
    my $prediction_events_by_id =
      $slg->[Marpa::R3::Internal::Scanless::G::PREDICTION_EVENT_BY_ID] = [];
    for my $symbol_name ( keys %{$prediction_events_by_name} ) {
        my ( $event_name, $is_active ) =
          @{ $prediction_events_by_name->{$symbol_name} };
        my $symbol_id = $slg->symbol_by_name($symbol_name);
        if ( not defined $symbol_id ) {
            Marpa::R3::exception(
"prediction event defined for non-existent symbol: $symbol_name\n"
            );
        }

        # Must be done before precomputation
    $slg->call_by_tag(
        ('@' .__FILE__ . ':' .  __LINE__),
        <<'END_OF_LUA', 'ii', $symbol_id, ($is_active ? 1 : 0));
        local grammar, symbol_id, is_active = ...
        local g1g = grammar.lmw_g1g
        g1g:symbol_is_prediction_event_set(symbol_id, 1)
        if is_active == 0 then
            g1g:prediction_symbol_activate(symbol_id, 0)
        end
END_OF_LUA

        $slg->[Marpa::R3::Internal::Scanless::G::PREDICTION_EVENT_BY_ID]
          ->[$symbol_id] = $event_name;
        push @{ $symbol_ids_by_event_name_and_type->{$event_name}->{prediction}
        }, $symbol_id;
    } ## end for my $symbol_name ( keys %{$prediction_events_by_name...})

    my $lexeme_events_by_id =
      $slg->[Marpa::R3::Internal::Scanless::G::LEXEME_EVENT_BY_ID] = [];

    my $precompute_error =
      Marpa::R3::Internal::Scanless::G::precompute( $slg, $g1_tracer );
    if ( defined $precompute_error ) {
        if ( $precompute_error == $Marpa::R3::Error::UNPRODUCTIVE_START ) {

            # Maybe someday improve this by finding the start rule and showing
            # its RHS -- for now it is clear enough
            Marpa::R3::exception(qq{Unproductive start symbol});
        } ## end if ( $precompute_error == ...)
        Marpa::R3::exception( 'Internal errror: unnkown precompute error code ',
            $precompute_error );
    } ## end if ( defined( my $precompute_error = ...))

    # G1 is now precomputed

    # Find out the list of lexemes according to G1
    my %g1_id_by_lexeme_name = ();
  SYMBOL: for my $symbol_id ( $slg->symbol_ids() ) {

    my ($is_terminal) = $slg->call_by_tag(
        ('@' .__FILE__ . ':' .  __LINE__),
        <<'END_OF_LUA', 'i', $symbol_id);
        local grammar, symbol_id = ...
        local g1g = grammar.lmw_g1g
        return g1g:symbol_is_terminal(symbol_id)
END_OF_LUA

        # Not a lexeme, according to G1
        next SYMBOL if not $is_terminal;

        my $symbol_name = $slg->symbol_name($symbol_id);
        $g1_id_by_lexeme_name{$symbol_name} = $symbol_id;

    }

    # A first phase of applying defaults
    my $discard_default_adverbs = $hashed_source->{discard_default_adverbs};
    my $lexeme_declarations     = $hashed_source->{lexeme_declarations};
    my $lexeme_default_adverbs  = $hashed_source->{lexeme_default_adverbs} // {};

    # Current lexeme data is spread out in many places.
    # Change so that it all resides in this hash, indexed by
    # name
    my %lexeme_data = ();

    # Lexers

    my @discard_event_by_lexer_rule_id = ();
    state $lex_start_symbol_name = '[:start_lex]';
    state $discard_symbol_name   = '[:discard]';

    my $lexer_rules          = $hashed_source->{rules}->{'L0'};
    my $character_class_hash = $hashed_source->{character_classes};
    my $lexer_symbols        = $hashed_source->{symbols}->{'L0'};

    # If no lexer rules, fake a lexer
    # Fake a lexer -- it discards symbols in character classes which
    # never matches
    if ( not scalar @{$lexer_rules} ) {
        $character_class_hash = { '[[^\\d\\D]]' => [ '[^\\d\\D]', '' ] };
        $lexer_rules = [
            {
                'rhs'             => ['[[^\\d\\D]]'],
                'lhs'             => '[:discard]',
                'symbol_as_event' => '[^\\d\\D]',

                # 'description' => 'Discard rule for <[[^\\d\\D]]>'
            },
        ];
        $lexer_symbols = {
            '[:discard]' => {

                # 'description'  => 'Internal LHS for lexer "L0" discard'
            },
            '[[^\\d\\D]]' => {

                # 'description'  => 'Character class: [^\\d\\D]'
            }
        };
    } ## end if ( not $lexer_rules )

    my %lex_lhs       = ();
    my %lex_rhs       = ();
    my %lex_separator = ();

    for my $lex_rule ( @{$lexer_rules} ) {
        delete $lex_rule->{event};
        delete $lex_rule->{symbol_as_event};
        $lex_lhs{ $lex_rule->{lhs} } = 1;
        $lex_rhs{$_} = 1 for @{ $lex_rule->{rhs} };
        if ( defined( my $separator = $lex_rule->{separator} ) ) {
            $lex_separator{$separator} = 1;
        }
    } ## end for my $lex_rule ( @{$lexer_rules} )

    my %this_lexer_symbols = ();
  SYMBOL:
    for my $symbol_name ( ( keys %lex_lhs ), ( keys %lex_rhs ),
        ( keys %lex_separator ) )
    {
        my $symbol_data = $lexer_symbols->{$symbol_name};
        $this_lexer_symbols{$symbol_name} = $symbol_data
          if defined $symbol_data;
    } ## end SYMBOL: for my $symbol_name ( ( keys %lex_lhs ), ( keys %lex_rhs...))

    my %is_lexeme_in_this_lexer = map { $_ => 1 }
      grep { not $lex_rhs{$_} and not $lex_separator{$_} }
      keys %lex_lhs;

    my @lex_lexeme_names = keys %is_lexeme_in_this_lexer;

    Marpa::R3::exception( "No lexemes in lexer\n",
        "  An SLIF grammar must have at least one lexeme\n" )
      if not scalar @lex_lexeme_names;

    # Do I need this?
    my @unproductive =
      map { "<$_>" }
      grep { not $lex_lhs{$_} and not $_ =~ /\A \[\[ /xms }
      ( keys %lex_rhs, keys %lex_separator );
    if (@unproductive) {
        Marpa::R3::exception( 'Unproductive lexical symbols: ',
            join q{ }, @unproductive );
    }

    # $this_lexer_symbols{$lex_start_symbol_name}->{description} =
    # 'Internal L0 (lexical) start symbol';
    push @{$lexer_rules}, map {
        ;
        {
            #   description => "Internal lexical start rule for <$_>",
            lhs => $lex_start_symbol_name,
            rhs => [$_]
        }
    } sort keys %is_lexeme_in_this_lexer;

    $slg->call_by_tag(
        ('@' .__FILE__ . ':' .  __LINE__),
        <<'END_OF_LUA', 's', $lex_start_symbol_name);
        local grammar, start_name = ...
        local l0g = grammar.lmw_l0g
        l0g.start_name = start_name
END_OF_LUA

    for my $symbol ( sort keys %this_lexer_symbols ) {
        my $properties = $this_lexer_symbols{$symbol};
        assign_L0_symbol( $slg, $symbol, $properties );
    }

    add_L0_user_rules( $slg, $lexer_rules );

    my $lex_discard_symbol_id =
      $slg->l0_symbol_by_name($discard_symbol_name) // -1;
    my @lex_lexeme_to_g1_symbol;
    $lex_lexeme_to_g1_symbol[$_] = -1 for $slg->symbol_ids();

  LEXEME_NAME: for my $lexeme_name (@lex_lexeme_names) {
        next LEXEME_NAME if $lexeme_name eq $discard_symbol_name;
        next LEXEME_NAME if $lexeme_name eq $lex_start_symbol_name;
        my $g1_symbol_id = $g1_id_by_lexeme_name{$lexeme_name};
        if ( not defined $g1_symbol_id ) {
            Marpa::R3::exception(
                "A lexeme in L0 is not a lexeme in G1: $lexeme_name");
        }
        if ( not $slg->symbol_is_accessible($g1_symbol_id) ) {
            my $message =
"A lexeme in L0 is not accessible from the G1 start symbol: $lexeme_name";
            say {$trace_fh} $message
              if $if_inaccessible_default eq 'warn';
            Marpa::R3::exception($message)
              if $if_inaccessible_default eq 'fatal';
        }
        my $lex_symbol_id = $slg->l0_symbol_by_name($lexeme_name);
        $lexeme_data{$lexeme_name}{lexer}{'id'} =
          $lex_symbol_id;
        $lex_lexeme_to_g1_symbol[$lex_symbol_id] = $g1_symbol_id;
    } ## end LEXEME_NAME: for my $lexeme_name (@lex_lexeme_names)

    my @lex_rule_to_g1_lexeme;
    my $lex_start_symbol_id =
      $slg->l0_symbol_by_name($lex_start_symbol_name);
  RULE_ID: for my $rule_id ( $slg->l0_rule_ids() ) {

        my ($lhs_id) = $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
            <<'END_OF_LUA', 'i>*', $rule_id );
    local grammar, rule_id = ...
    local l0g = grammar.lmw_l0g
    return l0g:rule_lhs(rule_id)
END_OF_LUA

        if ( $lhs_id == $lex_discard_symbol_id ) {
            $lex_rule_to_g1_lexeme[$rule_id] = -2;
            next RULE_ID;
        }
        if ( $lhs_id != $lex_start_symbol_id ) {
            $lex_rule_to_g1_lexeme[$rule_id] = -1;
            next RULE_ID;
        }
        my ($lexer_lexeme_id) =
          $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
            <<'END_OF_LUA', 'i>*', $rule_id );
    local grammar, rule_id = ...
    local l0g = grammar.lmw_l0g
    return l0g:rule_rhs(rule_id, 0)
END_OF_LUA

        if ( $lexer_lexeme_id == $lex_discard_symbol_id ) {
            $lex_rule_to_g1_lexeme[$rule_id] = -1;
            next RULE_ID;
        }
        my $lexeme_id = $lex_lexeme_to_g1_symbol[$lexer_lexeme_id] // -1;
        $lex_rule_to_g1_lexeme[$rule_id] = $lexeme_id;
        next RULE_ID if $lexeme_id < 0;
        my $lexeme_name = $slg->symbol_name($lexeme_id);

        my $assertion_id =
          $lexeme_data{$lexeme_name}{lexer}{'assertion'};
        if ( not defined $assertion_id ) {

            ($assertion_id) =
              $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
                <<'END_OF_LUA', '>*' );
    local grammar = ...
    local l0g = grammar.lmw_l0g
    return l0g:zwa_new(0)
END_OF_LUA

            $lexeme_data{$lexeme_name}{lexer}{'assertion'} =
              $assertion_id;
        } ## end if ( not defined $assertion_id )

        $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
            <<'END_OF_LUA', 'ii>*', $assertion_id, $rule_id );
    local grammar, assertion_id, rule_id = ...
    local l0g = grammar.lmw_l0g
    l0g:zwa_place(assertion_id, rule_id, 0)
END_OF_LUA

    }

    my $lex_precompute_error =
      Marpa::R3::Internal::Scanless::G::precompute( $slg, $lex_tracer );
    if ( defined $lex_precompute_error ) {
        Marpa::R3::exception(
'Internal errror: expected error code from precompute of lexer grammar ',
            $precompute_error
        );
    }

    # L0 is now precomputed

    my @class_table = ();

  CLASS_SYMBOL:
    for my $class_symbol ( sort keys %{$character_class_hash} ) {
        my $symbol_id = $slg->l0_symbol_by_name($class_symbol);
        next CLASS_SYMBOL if not defined $symbol_id;
        my $cc_components = $character_class_hash->{$class_symbol};
        my ( $compiled_re, $error ) =
          Marpa::R3::Internal::MetaAST::char_class_to_re($cc_components);
        if ( not $compiled_re ) {
            $error =~ s/^/  /gxms;    #indent all lines
            Marpa::R3::exception(
                "Failed belatedly to evaluate character class\n", $error );
        }
        push @class_table, [ $symbol_id, $compiled_re ];
    } ## end CLASS_SYMBOL: for my $class_symbol ( sort keys %{...})
    my $character_class_table = \@class_table;

    # Apply defaults to determine the discard event for every
    # rule id of the lexer.

    my $l0_xbnfs_by_irlid =
      $lex_tracer->[Marpa::R3::Internal::Trace::G::XBNF_BY_IRLID];
    my $default_discard_event = $discard_default_adverbs->{event};
  RULE_ID: for my $irlid ( $slg->l0_rule_ids() ) {
        my $xbnf = $l0_xbnfs_by_irlid->[$irlid];

        # There may be gaps in the IRLIDs
        next RULE_ID if not defined $xbnf;
        my $event;
      FIND_EVENT: {
            $event = $xbnf->[Marpa::R3::Internal::XBNF::EVENT];
            last FIND_EVENT if defined $event;

    my ($lhs_id) = $slg->call_by_tag(
    ('@' .__FILE__ . ':' . __LINE__),
    <<'END_OF_LUA', 'i>*', $irlid ) ;
    local grammar, irlid = ...
    local l0g = grammar.lmw_l0g
    return l0g:rule_lhs(irlid)
END_OF_LUA
            last FIND_EVENT if $lhs_id != $lex_discard_symbol_id;
            $event = $default_discard_event;
        } ## end FIND_EVENT:
        next RULE_ID if not defined $event;

        my ( $event_name, $event_starts_active ) = @{$event};
        if ( $event_name eq q{'symbol} ) {
            my @event = (
                $event = $xbnf->[Marpa::R3::Internal::XBNF::SYMBOL_AS_EVENT],
                $event_starts_active
            );
            $discard_event_by_lexer_rule_id[$irlid] = \@event;
            next RULE_ID;
        } ## end if ( $event_name eq q{'symbol} )
        if ( ( substr $event_name, 0, 1 ) ne q{'} ) {
            $discard_event_by_lexer_rule_id[$irlid] = $event;
            next RULE_ID;
        }
        Marpa::R3::exception(qq{Discard event has unknown name: "$event_name"});

    }

    # Post-lexer G1 processing

  LEXEME: for my $lexeme_name ( keys %g1_id_by_lexeme_name ) {
        Marpa::R3::exception(
            "A lexeme in G1 is not a lexeme in L0: $lexeme_name")
          if not defined $lexeme_data{$lexeme_name}{'lexer'};
    }

    # At this point we know which symbols are lexemes.
    # So now let's check for inconsistencies

    # Check for lexeme declarations for things which are not lexemes
    for my $lexeme_name ( keys %{$lexeme_declarations} ) {
        Marpa::R3::exception(
"Symbol <$lexeme_name> is declared as a lexeme, but it is not used as one.\n"
        ) if not defined $g1_id_by_lexeme_name{$lexeme_name};
    }

    # Now that we know the lexemes, check attempts to defined a
    # completion or a nulled event for one
    for my $symbol_name ( keys %{$completion_events_by_name} ) {
        Marpa::R3::exception(
"A completion event is declared for <$symbol_name>, but it is a lexeme.\n",
"  Completion events are only valid for symbols on the LHS of G1 rules.\n"
        ) if defined $g1_id_by_lexeme_name{$symbol_name};
    } ## end for my $symbol_name ( keys %{$completion_events_by_name...})

    for my $symbol_name ( keys %{$nulled_events_by_name} ) {
        Marpa::R3::exception(
"A nulled event is declared for <$symbol_name>, but it is a G1 lexeme.\n",
"  nulled events are only valid for symbols on the LHS of G1 rules.\n"
        ) if defined $g1_id_by_lexeme_name{$symbol_name};
    } ## end for my $symbol_name ( keys %{$nulled_events_by_name} )

    # Mark the lexemes, and set their data
    # already determined above.
  LEXEME: for my $lexeme_name ( keys %g1_id_by_lexeme_name ) {
        my $g1_lexeme_id = $g1_id_by_lexeme_name{$lexeme_name};
        my $declarations = $lexeme_declarations->{$lexeme_name};
        my $priority     = $declarations->{priority} // 0;
        my $eager     = $declarations->{eager} ? 1 : 0;

        $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
            <<'END_OF_LUA', 'iii', $g1_lexeme_id, $priority, $eager );
    local slg, g1_lexeme_id, priority, eager = ...
    local lexeme_data = slg.g1_symbols[g1_lexeme_id]
    lexeme_data.is_lexeme = true
    lexeme_data.priority = priority
    if eager ~= 0 then lexeme_data.eager = true end
END_OF_LUA

        my $pause_value = $declarations->{pause};
        if ( defined $pause_value ) {

            $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
                <<'END_OF_LUA', 'ii', $g1_lexeme_id, $pause_value );
    local slg, g1_lexeme_id, pause_value = ...
    local lexeme_data = slg.g1_symbols[g1_lexeme_id]
    if pause_value == 1 then
         lexeme_data.pause_after = true
    elseif pause_value == -1 then
         lexeme_data.pause_before = true
    end
END_OF_LUA

            my $is_active = 1;

            if ( defined( my $event_data = $declarations->{'event'} ) ) {
                my $event_name;
                ( $event_name, $is_active ) = @{$event_data};
                $lexeme_events_by_id->[$g1_lexeme_id] = $event_name;
                push
                  @{ $symbol_ids_by_event_name_and_type->{$event_name}->{lexeme}
                  }, $g1_lexeme_id;
            } ## end if ( defined( my $event_data = $declarations->{'event'...}))

            $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
                <<'END_OF_LUA', 'ii', $g1_lexeme_id, $is_active );
    local slg, g1_lexeme_id, is_active_arg = ...
    local is_active = (is_active_arg ~= 0 and true or nil)
    local lexeme_data = slg.g1_symbols[g1_lexeme_id]
    if is_active then
        -- activate only if event is enabled
        lexeme_data.pause_after_active = lexeme_data.pause_after
        lexeme_data.pause_before_active = lexeme_data.pause_before
    else
        lexeme_data.pause_after_active = nil
        lexeme_data.pause_before_active = nil
    end
END_OF_LUA

        } ## end if ( defined $pause_value )

    } ## end LEXEME: for my $lexeme_name ( keys %g1_id_by_lexeme_name )

    # Second phase of lexer processing
  RULE_ID: for my $lexer_rule_id ( 0 .. $#lex_rule_to_g1_lexeme ) {
        my $g1_lexeme_id = $lex_rule_to_g1_lexeme[$lexer_rule_id];
        my $lexeme_name  = $slg->symbol_name($g1_lexeme_id);
        my $assertion_id = $lexeme_data{$lexeme_name}{lexer}{'assertion'} // -1;
        my $discard_symbol_id = -1;
        if ($lexer_rule_id >= 0) {
            ( $discard_symbol_id ) = $slg->l0_rule_expand($lexer_rule_id);
        }

      $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA',
    local g, lexer_rule_id, g1_lexeme_id, assertion_id, discard_symbol_id = ...
    if lexer_rule_id >= 0 then
        g.l0_rules[lexer_rule_id].g1_lexeme = g1_lexeme_id
        if g1_lexeme_id >= 0 then
            local eager = g.g1_symbols[g1_lexeme_id].eager
            if eager then g.l0_rules[lexer_rule_id].eager = true end
        end
        local eager = g.l0_symbols[discard_symbol_id].eager
        if eager then
            g.l0_rules[lexer_rule_id].eager = true
        end
    end
    if g1_lexeme_id >= 0 then
        g.g1_symbols[g1_lexeme_id].assertion = assertion_id
    end
END_OF_LUA
        'iiii', $lexer_rule_id, $g1_lexeme_id, $assertion_id, $discard_symbol_id );

        my $discard_event = $discard_event_by_lexer_rule_id[$lexer_rule_id];
        if ( defined $discard_event ) {
            my ( $event_name, $is_active ) = @{$discard_event};
            $slg
              ->[ Marpa::R3::Internal::Scanless::G::DISCARD_EVENT_BY_LEXER_RULE
              ]->[$lexer_rule_id] = $event_name;
            push
              @{ $symbol_ids_by_event_name_and_type->{$event_name}->{discard} },
              $lexer_rule_id;

      $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 'ii', $lexer_rule_id, ($is_active ? 1 : 0) );
        local slg, lexer_rule_id, is_active_arg = ...
        local is_active = (is_active_arg ~= 0 and true or nil)
        local l0_rules = slg.l0_rules
        l0_rules[lexer_rule_id].event_on_discard = true
        l0_rules[lexer_rule_id].event_on_discard_active = is_active
END_OF_LUA

        } ## end if ( defined $discard_event )
    }

    # Second phase of G1 processing
    # The grammar can be thought to be "precomputed" at this point,
    # although I don't think the concept is as relevant as it is
    # for the Libmarpa grammars.

    # More lexer processing
    # Determine events by lexer rule, applying the defaults

    $slg->[Marpa::R3::Internal::Scanless::G::CHARACTER_CLASS_TABLE] =
      $character_class_table;

    # Some lexeme default adverbs are applied in earlier phases.
  {

        my $default_lexeme_action = $lexeme_default_adverbs->{action};
        my $xsy_by_isyid =
          $g1_tracer->[Marpa::R3::Internal::Trace::G::XSY_BY_ISYID];

      LEXEME:
        for my $lexeme_name ( keys %g1_id_by_lexeme_name ) {
            my $g1_lexeme_id = $g1_id_by_lexeme_name{$lexeme_name};
            my $xsy          = $xsy_by_isyid->[$g1_lexeme_id];
            next LEXEME if not defined $xsy;
            my $xsy_id = $xsy->[Marpa::R3::Internal::XSY::ID];
            my $xsy_name = $xsy->[Marpa::R3::Internal::XSY::NAME];

        my ($name_source) = $slg->call_by_tag(
        ('@' .__FILE__ . ':' .  __LINE__),
        <<'END_OF_LUA', 'is', $xsy_id, $xsy_name);
        local slg, xsy_id, xsy_name = ...
        -- print(inspect( xsy_id ) )
        -- print(inspect( slg.xsys[xsy_id]))
        -- local name_source_by_id = slg.xsys[xsy_id].name_source
        -- local name_source_by_name = slg.xsys[xsy_name].name_source
        -- if (name_source_by_id ~= name_source_by_name) then
            -- io.stderr:write(string.format(
                -- "id=%s; name=%s; id by name = %s; name by id = %s\n",
                -- inspect(xsy_id), inspect(xsy_name),
                -- inspect(slg.xsys[xsy_name].id),
                -- inspect(slg.xsys[xsy_id].name)
            -- ))
            -- error(string.format(
                -- "name_source mismatch, by id = %s; by name = %s\n",
                -- inspect(name_source_by_id),
                -- inspect(name_source_by_name)
            -- ))
        -- end
        return slg.xsys[xsy_id].name_source
END_OF_LUA
            next LEXEME if $name_source ne 'lexical';

            $xsy->[Marpa::R3::Internal::XSY::LEXEME_SEMANTICS] //=
              $default_lexeme_action;
        } ## end LEXEME: for my $lexeme_name ( keys %g1_id_by_lexeme_name )
    }

  APPLY_DEFAULT_LEXEME_BLESSING: {
        my $tracer = $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];
        my $default_blessing = $lexeme_default_adverbs->{bless};
        my $xsy_by_isyid =
          $g1_tracer->[Marpa::R3::Internal::Trace::G::XSY_BY_ISYID];

      LEXEME:
        for my $lexeme_name ( keys %g1_id_by_lexeme_name ) {
            my $g1_lexeme_id = $g1_id_by_lexeme_name{$lexeme_name};
            my $xsy          = $xsy_by_isyid->[$g1_lexeme_id];
            next LEXEME if not defined $xsy;
            my $xsy_name = $xsy->[Marpa::R3::Internal::XSY::NAME];

        my ($name_source) = $slg->call_by_tag(
        ('@' .__FILE__ . ':' .  __LINE__),
        <<'END_OF_LUA', 's', $xsy_name);
        local slg, xsy_name = ...
        -- print(inspect( slg.xsys[xsy_name]))
        return slg.xsys[xsy_name].name_source
END_OF_LUA
            next LEXEME if $name_source ne 'lexical';

            my $blessing = $xsy->[Marpa::R3::Internal::XSY::BLESSING]
              // $default_blessing;
            $blessing //= '::undef';

          FIND_BASE_BLESSING: {
                if ( $blessing eq '::undef' ) {
                    last FIND_BASE_BLESSING;
                }
                if ( $blessing eq '::name' ) {
                    if ( $lexeme_name =~ / [^ [:alnum:]] /xms ) {
                        Marpa::R3::exception(
qq{Lexeme blessing by '::name' only allowed if lexeme name is whitespace and alphanumerics\n},
                            qq{   Problematic lexeme was <$lexeme_name>\n}
                        );
                    } ## end if ( $lexeme_name =~ / [^ [:alnum:]] /xms )
                    $blessing = $lexeme_name;
                    $blessing =~ s/[ ]/_/gxms;
                    last FIND_BASE_BLESSING;
                } ## end if ( $default_blessing eq '::name' )
                if ( $blessing =~ /^ :: /xms ) {
                    Marpa::R3::exception(
                        qq{Blessing lexeme as '$blessing' is not allowed\n},
qq{   It is in pseudo-blessing form, but there is no such psuedo-blessing\n},
                        qq{   Problematic lexeme was <$lexeme_name>\n}
                    );
                }
                if ( $blessing =~ / [\W] /xms ) {
                    Marpa::R3::exception(
                        qq{Blessing lexeme as '$blessing' is not allowed\n},
qq{   It contained non-word characters and that is not allowed\n},
                        qq{   Problematic lexeme was <$lexeme_name>\n}
                    );
                } ## end if ( $default_blessing =~ / [\W] /xms )
            }

            if ( $blessing !~ / :: /xms ) {
                my $bless_package =
                  $slg->[Marpa::R3::Internal::Scanless::G::BLESS_PACKAGE];
                if ( not defined $bless_package ) {
                    my $lexeme_name = $slg->symbol_name($g1_lexeme_id);
                    Marpa::R3::exception(
qq{Symbol "$lexeme_name" needs a blessing package, but grammar has none\n},
                        qq{  The blessing for "$lexeme_name" was "$blessing"\n}
                    );
                } ## end if ( not defined $bless_package )
                $blessing = $bless_package . q{::} . $blessing;
            }

            $xsy->[Marpa::R3::Internal::XSY::BLESSING] = $blessing;

        } ## end LEXEME: for my $lexeme_name ( keys %g1_id_by_lexeme_name )

    }

    my $registrations = Marpa::R3::Internal::Value::registrations_find($slg );
    Marpa::R3::Internal::Value::registrations_set($slg, $registrations );

    return $slg;

} ## end sub Marpa::R3::Internal::Scanless::G::hash_to_runtime

sub Marpa::R3::Internal::Scanless::G::precompute {
    my ($slg, $per_lmg) = @_;

    my $xsy_by_isyid     = $per_lmg->[Marpa::R3::Internal::Trace::G::XSY_BY_ISYID];
    my $lmw_name     = $per_lmg->[Marpa::R3::Internal::Trace::G::LMW_NAME];

    my $trace_fh =
        $slg->[Marpa::R3::Internal::Scanless::G::TRACE_FILE_HANDLE];

    my ($do_return, $precompute_result, $precompute_error_code)
      = $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 's', $lmw_name );
    local grammar, lmw_name = ...
    local lmw_g = grammar[lmw_name]
    if lmw_g:is_precomputed() ~= 0 then
        return "false"
    end
    if lmw_g:force_valued() < 0 then
        error( lmw_g:error_description() )
    end
    local start_name = lmw_g.start_name
    local start_id = lmw_g.isyid_by_name[start_name]
    if not start_id then
        error(string.format(
"Internal error: Start symbol %q missing from grammar", start_name))
    end
    local result = lmw_g:start_symbol_set(start_id)
    if result < 0 then
        error(string.format(
            "Internal error: start_symbol_set() of %q failed; %s",
                start_name,
                lmw_g:error_description()
        ))
    end
    kollos.throw = false
    local result, error = lmw_g:precompute()
    kollos.throw = true
    if result then return "no", result, 0 end
    return "no", -1, error.code
END_OF_LUA

    return if $do_return eq "false";

    if ( $precompute_result < 0 ) {
        if ( not defined $precompute_error_code ) {
            Marpa::R3::exception(
                'libmarpa error, but no error code returned');
        }

        # If already precomputed, let higher level know
        return $precompute_error_code
            if $precompute_error_code == $Marpa::R3::Error::PRECOMPUTED;

        # We'll collect the 'MARPA_EVENT_LOOP_RULES' events later,
        # and use them to give a detailed error message
        $precompute_error_code = $Marpa::R3::Error::NONE
            if $precompute_error_code == $Marpa::R3::Error::GRAMMAR_HAS_CYCLE;

    } ## end if ( $precompute_result < 0 )

    if ( $precompute_error_code != $Marpa::R3::Error::NONE ) {

      my ($ok, $result) =
      $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 'si', $lmw_name, $precompute_error_code );
    local grammar, lmw_name, error_code = ...
    local lmw_g = grammar[lmw_name]
    if error_code == kollos.err["NO_RULES"] then
        kollos.userX('Attempted to precompute grammar with no rules')
    end
    if error_code == kollos.err["NULLING_TERMINAL"] then
        local msgs = {}
        local events = lmw_g:events()
        for i = 1, #events, 2 do
            local event_type = events[i]
            if event_type == kollos.event["NULLING_TERMINAL"] then
                msgs[#msgs+1] =
                   string.format("Nullable symbol %q is also a terminal\n",
                       lmw_g:symbol_name(events[i+1])
                   )
            end
        end
        msgs[#msgs+1] = 'A terminal symbol cannot also be a nulling symbol'
        kollos.userX( table.concat(msgs) )
    end
    if error_code == kollos.err["COUNTED_NULLABLE"] then
        local msgs = {}
        local events = lmw_g:events()
        for i = 1, #events, 2 do
            local event_type = events[i]
            if event_type == kollos.event["COUNTED_NULLABLE"] then
                msgs[#msgs+1] =
                   string.format("Nullable symbol %q is on RHS of counted rule\n",
                       lmw_g:symbol_name(events[i+1])
                   )
            end
        end
        msgs[#msgs+1] = 'Counted nullables confuse Marpa -- please rewrite the grammar\n'
        kollos.userX( table.concat(msgs) )
    end
    if error_code == kollos.err["START_NOT_LHS"] then
        kollos.userX( "Start symbol " .. lmw_g.start_name .. " not on LHS of any rule");
    end
    if error_code == kollos.err["NO_START_SYMBOL"] then
            kollos.userX('No start symbol')
    end
    if error_code ~= kollos.err["UNPRODUCTIVE_START"] then
            kollos.userX( lmw_g:error_description() )
    end
    return "ok"
END_OF_LUA

    if ($ok ne "ok") { Marpa::R3::exception( $result ); }

    return $precompute_error_code;

    } ## end if ( $precompute_error_code != $Marpa::R3::Error::NONE)

    # Above I went through the error events
    # Here I go through the events for situations where there was no
    # hard error returned from libmarpa
      my ($loop_rule_count) = 
      $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 's', $lmw_name );
        local grammar, lmw_name = ...
        local loop_rule_count = 0
        local lmw_g = grammar[lmw_name]
        local events = lmw_g:events()
        for i = 1, #events, 2 do
            local event_type = events[i]
            if event_type == kollos.event["LOOP_RULES"] then
                error(string.format(
                   "Unknown grammar precomputation event; type=%q"))
            end
            loop_rule_count = events[i+1]
        end
        return loop_rule_count
END_OF_LUA

    if ($loop_rule_count) {
      RULE:
        for my $rule_id ( $slg->lmg_rule_ids($lmw_name) ) {
            my ($rule_is_loop) =
              $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
                <<'END_OF_LUA', 'si', $lmw_name, $rule_id );
        local grammar, lmw_name, rule_id = ...
        local lmw_g = grammar[lmw_name]
        return lmw_g:rule_is_loop(rule_id)
END_OF_LUA

            next RULE unless $rule_is_loop;
            print {$trace_fh}
              'Cycle found involving rule: ', $slg->brief_rule($rule_id), "\n"
              or Marpa::R3::exception("Could not print: $ERRNO");
        } ## end for my $rule_id (@loop_rules)
        Marpa::R3::exception('Cycles in grammar, fatal error');
    }

    my $default_if_inaccessible =
        $slg->[Marpa::R3::Internal::Scanless::G::IF_INACCESSIBLE]
        // 'warn';
    SYMBOL:
    for my $symbol_id ( $slg->lmg_symbol_ids($lmw_name))
    {
        my ($is_accessible) = $slg->call_by_tag(
        ('@' .__FILE__ . ':' .  __LINE__),
        <<'END_OF_LUA', 'si', $lmw_name, $symbol_id);
        local grammar, lmw_name, symbol_id = ...
        local lmw_g = grammar[lmw_name]
        return lmw_g:symbol_is_accessible(symbol_id)
END_OF_LUA
        next SYMBOL if $is_accessible;

        my $xsy      = $xsy_by_isyid->[$symbol_id];
        my $xsy_name = $xsy->[Marpa::R3::Internal::XSY::NAME];

        # Inaccessible internal symbols may be created
        # from inaccessible use symbols -- ignore these.
        # This assumes that Marpa's logic
        # is correct and that
        # it is not creating inaccessible symbols from
        # accessible ones.
        next SYMBOL if not defined $xsy;

        my ($treatment) = $slg->call_by_tag(
        ('@' .__FILE__ . ':' .  __LINE__),
        <<'END_OF_LUA', 'ss', $xsy_name, $default_if_inaccessible);
        local slg, xsy_name, default_treatment = ...
        return slg.xsys[xsy_name].if_inaccessible or default_treatment
END_OF_LUA

        next SYMBOL if $treatment eq 'ok';
        my $symbol_name = $slg->lmg_symbol_name($lmw_name, $symbol_id);
        my $message = "Inaccessible symbol: $symbol_name";
        Marpa::R3::exception($message) if $treatment eq 'fatal';
        say {$trace_fh} $message
            or Marpa::R3::exception("Could not print: $ERRNO");
    }

    # Save some memory
    $slg->[Marpa::R3::Internal::Scanless::G::CHARACTER_CLASSES] = undef;

    return ;

}


sub assign_G1_symbol {
    # $slg will be needed for the XSY's
    my ( $slg, $name, $options ) = @_;
    my $tracer = $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];

    my $symbol_id = $slg->symbol_by_name($name);
    if ( defined $symbol_id ) {
        return $symbol_id;
    }

    ($symbol_id) =
      $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 's', $name );
    local g, symbol_name = ...
    local lmw_g = g.lmw_g1g
    local symbol_id = lmw_g:symbol_new(symbol_name)
    g.g1_symbols[symbol_id] = { id = symbol_id }
    return symbol_id
END_OF_LUA

    PROPERTY: for my $property ( sort keys %{$options} ) {
        if ( $property eq 'wsyid' ) {
            next PROPERTY;
        }
        if ( $property eq 'xsy' ) {
            my $xsy_name = $options->{$property};
            my $xsy = $slg->[Marpa::R3::Internal::Scanless::G::XSY_BY_NAME]->{$xsy_name};
            $tracer->[Marpa::R3::Internal::Trace::G::XSY_BY_ISYID]->[$symbol_id] =
                $xsy;
            next PROPERTY;
        }


        if ( $property eq 'terminal' ) {
            my $value = $options->{$property};

      $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 's', $symbol_id, ($value ? 1 : 0));
    local g, symbol_id, value = ...
    local g1g = g.lmw_g1g
    gig:symbol_is_terminal_set(symbol_id, value)
END_OF_LUA

            next PROPERTY;
        }
        if ( $property eq 'rank' ) {
            my $value = $options->{$property};
            Marpa::R3::exception(qq{Symbol "$name": rank must be an integer})
                if not Scalar::Util::looks_like_number($value)
                    or int($value) != $value;

      $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 's', $symbol_id, $value);
    local g, symbol_id, value = ...
    local g1g = g.lmw_g1g
    g1g:symbol_rank_set(symbol_id, value)
END_OF_LUA
            next PROPERTY;
        }

        Marpa::R3::exception(qq{Unknown symbol property "$property"});
    } ## end PROPERTY: for my $property ( keys %{$options} )

    return $symbol_id;

}

sub assign_L0_symbol {
    # $slg will be needed for the XSY's
    my ( $slg, $name, $options ) = @_;
    my $tracer = $slg->[Marpa::R3::Internal::Scanless::G::L0_TRACER];

    my $symbol_id = $slg->l0_symbol_by_name($name);
    if ( defined $symbol_id ) {
        return $symbol_id;
    }

    ($symbol_id) =
      $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 's', $name );
    local g, symbol_name = ...
    local lmw_g = g.lmw_l0g
    local symbol_id = lmw_g:symbol_new(symbol_name)
    g.l0_symbols[symbol_id] = { id = symbol_id }
    return symbol_id
END_OF_LUA

    PROPERTY: for my $property ( sort keys %{$options} ) {
        if ( $property eq 'wsyid' ) {
            next PROPERTY;
        }
        if ( $property eq 'xsy' ) {
            my $xsy_name = $options->{$property};
            my $xsy = $slg->[Marpa::R3::Internal::Scanless::G::XSY_BY_NAME]->{$xsy_name};
            $tracer->[Marpa::R3::Internal::Trace::G::XSY_BY_ISYID]->[$symbol_id] =
                $xsy;
            next PROPERTY;
        }
        if ( $property eq 'eager' ) {
            my $value = $options->{$property};

      $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 'ii', $symbol_id, ($value ? 1 : 0));
    local g, symbol_id, eager = ...
    if eager > 0 then
        g.l0_symbols[symbol_id].eager = true
    end
END_OF_LUA

            next PROPERTY;
        }
        if ( $property eq 'terminal' ) {
            my $value = $options->{$property};

      $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 's', $symbol_id, ($value ? 1 : 0));
    local g, symbol_id, value = ...
    local l0g = g.lmw_l0g
    l0g:symbol_is_terminal_set(symbol_id, value)
END_OF_LUA

            next PROPERTY;
        }
        if ( $property eq 'rank' ) {
            my $value = $options->{$property};
            Marpa::R3::exception(qq{Symbol "$name": rank must be an integer})
                if not Scalar::Util::looks_like_number($value)
                    or int($value) != $value;

      $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 's', $symbol_id, $value);
    local g, symbol_id, value = ...
    local l0g = g.lmw_l0g
    l0g:symbol_rank_set(symbol_id, value)
END_OF_LUA

            next PROPERTY;
        } ## end if ( $property eq 'rank' )
        Marpa::R3::exception(qq{Unknown symbol property "$property"});
    } ## end PROPERTY: for my $property ( keys %{$options} )

    return $symbol_id;

}

sub add_G1_user_rules {
    my ( $slg, $rules ) = @_;

    for my $rule (@{$rules}) {
        add_G1_user_rule( $slg, $rule );
    }

    return;

}

sub add_L0_user_rules {
    my ( $slg, $rules ) = @_;

    for my $rule (@{$rules}) {
        add_L0_user_rule( $slg, $rule );
    }

    return;

}

sub add_G1_user_rule {
    my ( $slg, $options ) = @_;

    my $tracer = $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];
    my $subgrammar = $tracer->[Marpa::R3::Internal::Trace::G::NAME];

    my ( $lhs_name, $rhs_names, $action, $blessing );
    my ( $min, $separator_name );
    my $rank;
    my $null_ranking;
    my $xbnf;
    my $proper_separation = 0;

  OPTION: for my $option ( keys %{$options} ) {
        my $value = $options->{$option};
        if ( $option eq 'xbnfid' ) {
            $xbnf = $slg->[
              Marpa::R3::Internal::Scanless::G::G1_XBNF_BY_NAME
            ]->{$value};
            next OPTION;
        }
        if ( $option eq 'rhs' )    { $rhs_names = $value; next OPTION }
        if ( $option eq 'lhs' )    { $lhs_name  = $value; next OPTION }
        if ( $option eq 'action' ) { $action    = $value; next OPTION }
        if ( $option eq 'rank' )   { $rank      = $value; next OPTION }
        if ( $option eq 'null_ranking' ) {
            $null_ranking = $value;
            next OPTION;
        }
        if ( $option eq 'min' ) { $min = $value; next OPTION }
        if ( $option eq 'separator' ) {
            $separator_name = $value;
            next OPTION;
        }
        if ( $option eq 'proper' ) {
            $proper_separation = $value;
            next OPTION;
        }
        Marpa::R3::exception("Unknown user rule option: $option");
    } ## end OPTION: for my $option ( keys %{$options} )


    $rhs_names //= [];

    my ($default_rank) =
          $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ), <<'END_OF_LUA', '');
    local grammar = ...
    return grammar.lmw_g1g:default_rank()
END_OF_LUA

    $rank //= $default_rank;
    $null_ranking //= 'low';

    # Is this is an ordinary, non-counted rule?
    my $is_ordinary_rule = scalar @{$rhs_names} == 0 || !defined $min;
    if ( defined $separator_name and $is_ordinary_rule ) {
        if ( defined $separator_name ) {
            Marpa::R3::exception(
                'separator defined for rule without repetitions');
        }
    } ## end if ( defined $separator_name and $is_ordinary_rule )

    my @rhs_ids = map {
                assign_G1_symbol( $slg, $_ )
        } @{$rhs_names};
    my $lhs_id = assign_G1_symbol( $slg, $lhs_name );

    my $base_rule_id;
    my $separator_id = -1;

    if ($is_ordinary_rule) {

        ($base_rule_id) =
          $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
            <<'END_OF_LUA', 'i', [ $lhs_id, @rhs_ids ] );
    local g, rule  = ...
    -- remove the test for nil or less than zero
    -- once refactoring is complete?
    kollos.throw = false
    local base_rule_id = g.lmw_g1g:rule_new(rule)
    -- print('base_rule_id: ', inspect(base_rule_id))
    kollos.throw = true
    if not base_rule_id or base_rule_id < 0 then return -1 end
    g.g1_rules[base_rule_id] = { id = base_rule_id }
    return base_rule_id
END_OF_LUA

    } ## end if ($is_ordinary_rule)
    else {
        Marpa::R3::exception('Only one rhs symbol allowed for counted rule')
          if scalar @{$rhs_names} != 1;

        # create the separator symbol, if we're using one
        if ( defined $separator_name ) {
            $separator_id = assign_G1_symbol( $slg, $separator_name );
        } ## end if ( defined $separator_name )

        # The original rule for a sequence rule is
        # not actually used in parsing,
        # but some of the rewritten sequence rules are its
        # semantic equivalents.

        my $arg_hash = {
            lhs => $lhs_id,
            rhs => $rhs_ids[0],
            separator => $separator_id,
            proper    => $proper_separation,
            min       => $min,
        };

      ($base_rule_id) = 
      $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 'i', $arg_hash);
    local g, arg_hash = ...
    -- print('arg_hash: ', inspect(arg_hash))
    arg_hash.proper = (arg_hash.proper ~= 0)
    kollos.throw = false
    base_rule_id = g.lmw_g1g:sequence_new(arg_hash)
    kollos.throw = true
    -- remove the test for nil or less than zero
    -- once refactoring is complete?
    if not base_rule_id or base_rule_id < 0 then return end
    g.g1_rules[base_rule_id] = { id = base_rule_id }
    return base_rule_id
END_OF_LUA

    }

    if ( not defined $base_rule_id or $base_rule_id < 0 ) {
        my $rule_description = rule_describe( $lhs_name, $rhs_names );
        my ($ok, $problem) =
        $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
            <<'END_OF_LUA', 's', $rule_description );
            local grammar, rule_description = ...
            local g1g = grammar.lmw_g1g
            local error_code = g1g:error_code()
            if error_code == kollos.err.DUPLICATE_RULE then
                problem_description = "Duplicate rule"
            else
                problem_description = kollos.err[error_code].description
            end
            return "abend", (problem_description .. ': ' .. rule_description)
END_OF_LUA

        Marpa::R3::exception($problem) if $ok ne 'fail'
    }

    $tracer->[Marpa::R3::Internal::Trace::G::XBNF_BY_IRLID]->[$base_rule_id] = $xbnf;

    # Later on we will need per-IRL actions and masks
    $tracer->[Marpa::R3::Internal::Trace::G::ACTION_BY_IRLID]->[$base_rule_id] =
        $xbnf->[Marpa::R3::Internal::XBNF::ACTION_NAME];
    $tracer->[Marpa::R3::Internal::Trace::G::MASK_BY_IRLID]->[$base_rule_id] =
        $xbnf->[Marpa::R3::Internal::XBNF::MASK];

      $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 'iii',
        local grammar, rule_id, ranking_is_high, rank = ...
        local g1g = grammar.lmw_g1g
        g1g:rule_null_high_set(rule_id, ranking_is_high)
        g1g:rule_rank_set(rule_id, rank)
END_OF_LUA
            $base_rule_id, ( $null_ranking eq 'high' ? 1 : 0 ), $rank);

    return;

}

sub add_L0_user_rule {
    my ( $slg, $options ) = @_;

    my $tracer = $slg->[Marpa::R3::Internal::Scanless::G::L0_TRACER];

    my ( $lhs_name, $rhs_names, $action, $blessing );
    my ( $min, $separator_name );
    my $rank;
    my $null_ranking;
    my $xbnf;
    my $proper_separation = 0;

  OPTION: for my $option ( keys %{$options} ) {
        my $value = $options->{$option};
        if ( $option eq 'xbnfid' ) {
            $xbnf = $slg->[
              Marpa::R3::Internal::Scanless::G::L0_XBNF_BY_NAME
            ]->{$value};
            next OPTION;
        }
        if ( $option eq 'rhs' )    { $rhs_names = $value; next OPTION }
        if ( $option eq 'lhs' )    { $lhs_name  = $value; next OPTION }
        if ( $option eq 'action' ) { $action    = $value; next OPTION }
        if ( $option eq 'rank' )   { $rank      = $value; next OPTION }
        if ( $option eq 'null_ranking' ) {
            $null_ranking = $value;
            next OPTION;
        }
        if ( $option eq 'min' ) { $min = $value; next OPTION }
        if ( $option eq 'separator' ) {
            $separator_name = $value;
            next OPTION;
        }
        if ( $option eq 'proper' ) {
            $proper_separation = $value;
            next OPTION;
        }
        Marpa::R3::exception("Unknown user rule option: $option");
    } ## end OPTION: for my $option ( keys %{$options} )


    $rhs_names //= [];

    my ($default_rank) =
          $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ), <<'END_OF_LUA', '');
    local grammar = ...
    return grammar.lmw_l0g:default_rank()
END_OF_LUA
    $rank //= $default_rank;
    $null_ranking //= 'low';

    # Is this is an ordinary, non-counted rule?
    my $is_ordinary_rule = scalar @{$rhs_names} == 0 || !defined $min;
    if ( defined $separator_name and $is_ordinary_rule ) {
        if ( defined $separator_name ) {
            Marpa::R3::exception(
                'separator defined for rule without repetitions');
        }
    } ## end if ( defined $separator_name and $is_ordinary_rule )

    my @rhs_ids = map {
                assign_L0_symbol( $slg, $_ )
        } @{$rhs_names};
    my $lhs_id = assign_L0_symbol( $slg, $lhs_name );

    my $base_rule_id;
    my $separator_id = -1;

    if ($is_ordinary_rule) {

        ($base_rule_id) =
          $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
            <<'END_OF_LUA', 'i', [ $lhs_id, @rhs_ids ] );
    local g, rule  = ...
    -- remove the test for nil or less than zero
    -- once refactoring is complete?
    kollos.throw = false
    local base_rule_id = g.lmw_l0g:rule_new(rule)
    -- print('base_rule_id: ', inspect(base_rule_id))
    kollos.throw = true
    if not base_rule_id or base_rule_id < 0 then return -1 end
    g.l0_rules[base_rule_id] = { id = base_rule_id }
    return base_rule_id
END_OF_LUA

    } ## end if ($is_ordinary_rule)
    else {
        Marpa::R3::exception('Only one rhs symbol allowed for counted rule')
          if scalar @{$rhs_names} != 1;

        # create the separator symbol, if we're using one
        if ( defined $separator_name ) {
            $separator_id = assign_L0_symbol( $slg, $separator_name );
        } ## end if ( defined $separator_name )


        # The original rule for a sequence rule is
        # not actually used in parsing,
        # but some of the rewritten sequence rules are its
        # semantic equivalents.

        my $arg_hash = {
            lhs => $lhs_id,
            rhs => $rhs_ids[0],
            separator => $separator_id,
            proper    => $proper_separation,
            min       => $min,
        };

      ($base_rule_id) = 
      $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 'i', $arg_hash);
    local g, arg_hash = ...
    -- print('arg_hash: ', inspect(arg_hash))
    arg_hash.proper = (arg_hash.proper ~= 0)
    kollos.throw = false
    base_rule_id = g.lmw_l0g:sequence_new(arg_hash)
    kollos.throw = true
    -- remove the test for nil or less than zero
    -- once refactoring is complete?
    if not base_rule_id or base_rule_id < 0 then return end
    local l0_rule = { id = base_rule_id }
    g.l0_rules[base_rule_id] = l0_rule
    return base_rule_id
END_OF_LUA

    }

    if ( not defined $base_rule_id or $base_rule_id < 0 ) {
        my $rule_description = rule_describe( $lhs_name, $rhs_names );
        my ($ok, $problem) =
        $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
            <<'END_OF_LUA', 's', $rule_description );
            local grammar, rule_description = ...
            local l0g = grammar.lmw_l0g
            local error_code = l0g:error_code()
            if error_code == kollos.err.DUPLICATE_RULE then
                problem_description = "Duplicate rule"
            else
                problem_description = kollos.err[error_code].description
            end
            return "abend", (problem_description .. ': ' .. rule_description)
END_OF_LUA

        Marpa::R3::exception($problem) if $ok ne 'fail';
    }

    $tracer->[Marpa::R3::Internal::Trace::G::XBNF_BY_IRLID]->[$base_rule_id] = $xbnf;

    # Later on we will need per-IRL actions and masks
    $tracer->[Marpa::R3::Internal::Trace::G::ACTION_BY_IRLID]->[$base_rule_id] =
        $xbnf->[Marpa::R3::Internal::XBNF::ACTION_NAME];
    $tracer->[Marpa::R3::Internal::Trace::G::MASK_BY_IRLID]->[$base_rule_id] =
        $xbnf->[Marpa::R3::Internal::XBNF::MASK];

      $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 'iii',
        local grammar, rule_id, ranking_is_high, rank = ...
        local l0g = grammar.lmw_l0g
        l0g:rule_null_high_set(rule_id, ranking_is_high)
        l0g:rule_rank_set(rule_id, rank)
END_OF_LUA
            $base_rule_id, ( $null_ranking eq 'high' ? 1 : 0 ), $rank);

    return;

}

sub rule_describe {
    my ( $lhs_name, $rhs_names ) = @_;
    # wrap symbol names with whitespaces allowed by SLIF
    $lhs_name = "<$lhs_name>" if $lhs_name =~ / /;
    return "$lhs_name -> " . ( join q{ }, map { / / ? "<$_>" : $_ } @{$rhs_names} );
} ## end sub rule_describe

sub Marpa::R3::Scanless::G::start_symbol_id {
    my ( $slg ) = @_;
    my ($start_symbol) = $slg->call_by_tag(
    ('@' .__FILE__ . ':' . __LINE__),
    <<'END_OF_LUA', '>*' ) ;
    local grammar = ...
    return grammar.lmw_g1g:start_symbol()
END_OF_LUA
    return $start_symbol;
}

sub Marpa::R3::Scanless::G::rule_name {
    my ( $slg, $rule_id ) = @_;
    my $tracer = $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];
    my $xbnf_by_irlid = $tracer->[Marpa::R3::Internal::Trace::G::XBNF_BY_IRLID];
    my $xbnf  = $xbnf_by_irlid->[$rule_id];
    return "Non-existent rule $rule_id" if not defined $xbnf;
    my $name = $xbnf->[Marpa::R3::Internal::XBNF::NAME];
    return $name if defined $name;
    my ( $lhs_id ) = $slg->rule_expand($rule_id);
    return $slg->symbol_name($lhs_id);
}

sub Marpa::R3::Scanless::G::rule_expand {
    my ( $slg, $rule_id ) = @_;
    return $slg->irl_isyids($rule_id);
}

sub Marpa::R3::Scanless::G::l0_rule_expand {
    my ( $slg, $rule_id ) = @_;
    return $slg->l0_irl_isyids($rule_id);
}

sub Marpa::R3::Scanless::G::symbol_name {
    my ( $slg, $symbol_id ) = @_;
    $symbol_id += 0;
    return $slg->lmg_symbol_name('lmw_g1g', $symbol_id);
}

sub Marpa::R3::Scanless::G::l0_symbol_name {
    my ( $slg, $symbol_id ) = @_;
    return $slg->lmg_symbol_name('lmw_l0g', $symbol_id);
}

sub Marpa::R3::Scanless::G::symbol_display_form {
    my ( $slg, $symbol_id ) = @_;
    return $slg->lmg_symbol_display_form('lmw_g1g', $symbol_id);
}

sub Marpa::R3::Scanless::G::l0_symbol_display_form {
    my ( $slg, $symbol_id ) = @_;
    return $slg->lmg_symbol_display_form('lmw_l0g', $symbol_id);
}

sub Marpa::R3::Scanless::G::symbol_dsl_form {
    my ( $slg, $symbol_id ) = @_;
    return $slg->lmg_symbol_dsl_form('lmw_g1g', $symbol_id);
}

sub Marpa::R3::Scanless::G::l0_symbol_dsl_form {
    my ( $slg, $symbol_id ) = @_;
    return $slg->lmg_symbol_dsl_form('lmw_l0g', $symbol_id);
}

sub Marpa::R3::Scanless::G::rule_show
{
    my ( $slg, $rule_id ) = @_;
    my $tracer = $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];
    return slg_rule_show($slg, $tracer, $rule_id);
}

sub Marpa::R3::Scanless::G::l0_rule_show
{
    my ( $slg, $rule_id ) = @_;
    my $tracer = $slg->[Marpa::R3::Internal::Scanless::G::L0_TRACER];
    return slg_rule_show($slg, $tracer, $rule_id);
}

sub Marpa::R3::Scanless::G::call_by_tag {
    my ( $slg, $tag, $codestr, $sig, @args ) = @_;
    my $lua = $slg->[Marpa::R3::Internal::Scanless::G::L];
    my $regix = $slg->[Marpa::R3::Internal::Scanless::G::REGIX];
    $DB::single = 1 if not defined $lua;
    $DB::single = 1 if not defined $regix;
    $DB::single = 1 if not defined $tag;
    $DB::single = 1 if not defined $codestr;
    $DB::single = 1 if not defined $sig;
    $DB::single = 1 if grep { not defined $_ } @args;
    my @results = $lua->call_by_tag($regix, $tag, $codestr, $sig, @args);
    return @results;
}

sub slg_rule_show {
    my ( $slg, $tracer, $irlid ) = @_;
    my $lmw_name     = $tracer->[Marpa::R3::Internal::Trace::G::LMW_NAME];
    my ($symbol_ids) = $slg->call_by_tag(
    ('@' .__FILE__ . ':' . __LINE__),
    <<'END_OF_LUA', 'si>*', $lmw_name, $irlid ) ;
    local grammar, lmw_name, irlid = ...
    local lmw_g = grammar[lmw_name]
    return lmw_g:irl_isyids(irlid)
END_OF_LUA

    return if not scalar @{$symbol_ids};
    my ( $lhs, @rhs ) =
        map { $slg->lmg_symbol_display_form($lmw_name, $_) } @{$symbol_ids};

    my ($has_minimum, $minimum) = $slg->call_by_tag(
    ('@' .__FILE__ . ':' . __LINE__),
    <<'END_OF_LUA', 'si>*', $lmw_name, $irlid ) ;
    local grammar, lmw_name, irlid = ...
    local lmw_g = grammar[lmw_name]
    local minimum = lmw_g:sequence_min(irlid)
    if not minimum then return 0, -1 end
    return 1, minimum
END_OF_LUA

    my @quantifier = ();

    if ( $has_minimum ) {
        @quantifier = ( $minimum <= 0 ? q{*} : q{+} );
    }
    return join q{ }, $lhs, q{::=}, @rhs, @quantifier;
}

sub Marpa::R3::Scanless::G::show_rules {
    my ( $slg, $verbose ) = @_;
    $verbose //= 0;
    return $slg->lmg_show_rules('lmw_g1g', $verbose);
}

sub Marpa::R3::Scanless::G::l0_show_rules {
    my ( $slg, $verbose ) = @_;
    $verbose //= 0;
    return $slg->lmg_show_rules('lmw_l0g', $verbose);
}

sub Marpa::R3::Scanless::G::show_symbols {
    my ( $slg, $verbose ) = @_;
    $verbose //= 0;
    return $slg->lmg_show_symbols('lmw_g1g', $verbose);
}

sub Marpa::R3::Scanless::G::l0_show_symbols {
    my ( $slg, $verbose ) = @_;
    $verbose //= 0;
    return $slg->lmg_show_symbols('lmw_l0g', $verbose);
}

sub Marpa::R3::Scanless::G::symbol_is_accessible {
    my ( $slg, $symid ) = @_;
    my ($is_accessible) = $slg->call_by_tag(
    ('@' .__FILE__ . ':' . __LINE__),
    <<'END_OF_LUA', 'i>*', $symid ) ;
    local grammar, symid = ...
    local g1g = grammar.lmw_g1g
    return g1g:symbol_is_accessible(symid)
END_OF_LUA

    return $is_accessible;
}

sub Marpa::R3::Scanless::G::symbol_is_productive {
    my ( $slg, $symid ) = @_;
    my ($is_productive) = $slg->call_by_tag(
    ('@' .__FILE__ . ':' . __LINE__),
    <<'END_OF_LUA', 'i>*', $symid ) ;
    local grammar, symid = ...
    local g1g = grammar.lmw_g1g
    return g1g:symbol_is_productive(symid)
END_OF_LUA

    return $is_productive;
}

sub Marpa::R3::Scanless::G::symbol_is_nulling {
    my ( $slg, $symid ) = @_;
    my ($is_nulling) = $slg->call_by_tag(
    ('@' .__FILE__ . ':' . __LINE__),
    <<'END_OF_LUA', 'i>*', $symid ) ;
    local grammar, symid = ...
    local g1g = grammar.lmw_g1g
    return g1g:symbol_is_nulling(symid)
END_OF_LUA

    return $is_nulling;
}

sub Marpa::R3::Scanless::G::show_dotted_rule {
    my ( $slg, $irlid, $dot_position ) = @_;
    my $tracer =  $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];
    my $lmw_name     = $tracer->[Marpa::R3::Internal::Trace::G::LMW_NAME];
    my ( $lhs, @rhs ) =
    map { $slg->lmg_symbol_display_form($lmw_name, $_) } $slg->irl_isyids($irlid);
    my $rhs_length = scalar @rhs;

    my ($has_minimum, $minimum) = $slg->call_by_tag(
    ('@' .__FILE__ . ':' . __LINE__),
    <<'END_OF_LUA', 'i>*', $irlid ) ;
    local grammar, irlid = ...
    local g1g = grammar.lmw_g1g
    local minimum = g1g:sequence_min(irlid)
    if not minimum then return 0, -1 end
    return 1, minimum
END_OF_LUA

    my @quantifier = ();
    if ($has_minimum) {
        @quantifier = ($minimum <= 0 ? q{*} : q{+} );
    }
    $dot_position = $rhs_length + $dot_position + 1 if $dot_position < 0;
    if ($dot_position < $rhs_length) {
        splice @rhs, $dot_position, 0, q{.};
        return join q{ }, $lhs, q{->}, @rhs, @quantifier;
    } else {
        return join q{ }, $lhs, q{->}, @rhs, @quantifier, q{.};
    }
}

sub Marpa::R3::Scanless::G::rule_ids {
    my ($slg) = @_;
    return $slg->lmg_rule_ids('lmw_g1g');
}

sub Marpa::R3::Scanless::G::l0_rule_ids {
    my ($slg) = @_;
    return $slg->lmg_rule_ids('lmw_l0g');
}

sub Marpa::R3::Scanless::G::symbol_ids {
    my ($slg) = @_;
    return $slg->lmg_symbol_ids('lmw_g1g');
}

sub Marpa::R3::Scanless::G::l0_symbol_ids {
    my ($slg) = @_;
    return $slg->lmg_symbol_ids('lmw_l0g');
}

sub Marpa::R3::Scanless::G::symbol_by_name {
    my ($slg, $name) = @_;
    return $slg->lmg_symbol_by_name('lmw_g1g', $name);
}

sub Marpa::R3::Scanless::G::l0_symbol_by_name {
    my ($slg, $name) = @_;
    return $slg->lmg_symbol_by_name('lmw_l0g', $name);
}

# Internal methods, not to be documented

sub Marpa::R3::Scanless::G::lmg_symbol_by_name {
    my ( $slg, $lmw_name, $symbol_name ) = @_;

    my ($symbol_id) = $slg->call_by_tag(
        ('@' . __FILE__ . ':' .  __LINE__),
      <<'END_OF_LUA', 'ss', $lmw_name, $symbol_name);
    local g, lmw_name, symbol_name = ...
    local lmw_g = g[lmw_name]
    return lmw_g.isyid_by_name[symbol_name]
END_OF_LUA

    return $symbol_id;
}

sub Marpa::R3::Scanless::G::lmg_symbol_name {
    my ( $slg, $lmw_name, $symbol_id ) = @_;

    my ($name) = $slg->call_by_tag(
        ('@' . __FILE__ . ':' .  __LINE__),
      <<'END_OF_LUA', 'si', $lmw_name, $symbol_id);
    local g, lmw_name, symbol_id = ...
    local lmw_g = g[lmw_name]
    return lmw_g:symbol_name(symbol_id)
END_OF_LUA

    return $name;

} ## end sub symbol_name

sub Marpa::R3::Scanless::G::formatted_symbol_name {
    my ( $slg, $symbol_id ) = @_;
    my $symbol_name = $slg->symbol_name($symbol_id);
    # As-is if all word characters
    return $symbol_name if $symbol_name =~ m/ \A \w* \z/xms;
    # As-is if ends in right bracket
    return $symbol_name if $symbol_name =~ m/ \] \z/xms;
    return '<' . $symbol_name . '>';
}

sub Marpa::R3::Scanless::G::brief_rule {
    my ($slg, $irlid) = @_;
    return $slg->lmg_brief_rule('lmw_g1g', $irlid);
}

sub Marpa::R3::Scanless::G::lmg_brief_rule {
    my ( $slg, $lmw_name, $irlid ) = @_;
    my ($lhs_id, @rhs_ids) = $slg->irl_isyids($irlid);
    my $lhs = $slg->formatted_symbol_name( $lhs_id );
    my @rhs = map { $slg->formatted_symbol_name( $_ ) } @rhs_ids;
    my ($has_minimum, $minimum) = $slg->call_by_tag(
    ('@' .__FILE__ . ':' . __LINE__),
    <<'END_OF_LUA', 'si>*', $lmw_name, $irlid ) ;
    local grammar, lmw_name, irlid = ...
    local lmw_g = grammar[lmw_name]
    local minimum = lmw_g:sequence_min(irlid)
    if not minimum then return 0, -1 end
    return 1, minimum
END_OF_LUA

    my @quantifier = ();
    if ($has_minimum) {
         push @quantifier, ($minimum <= 0 ? q{ *} : q{ +});
    }
    return join q{ }, $lhs, q{::=}, @rhs, @quantifier;
}

# This logic deals with gaps in the rule numbering.
# Currently there are none, but Libmarpa does not
# guarantee this.
sub Marpa::R3::Scanless::G::lmg_rule_ids {
    my ($slg, $lmw_name) = @_;
    my ($highest_rule_id) = $slg->call_by_tag(
    ('@' .__FILE__ . ':' . __LINE__),
    <<'END_OF_LUA', 's>*', $lmw_name ) ;
    local grammar, lmw_name = ...
    local lmw_g = grammar[lmw_name]
    return lmw_g:highest_rule_id()
END_OF_LUA

    return 0 .. $highest_rule_id;
}

# This logic deals with gaps in the symbol numbering.
# Currently there are none, but Libmarpa does not
# guarantee this.
sub Marpa::R3::Scanless::G::lmg_symbol_ids {
    my ($slg, $lmw_name) = @_;
    my ($highest_symbol_id) = $slg->call_by_tag(
    ('@' .__FILE__ . ':' . __LINE__),
    <<'END_OF_LUA', 's>*', $lmw_name ) ;
    local grammar, lmw_name = ...
    local lmw_g = grammar[lmw_name]
    return lmw_g:highest_symbol_id()
END_OF_LUA

    return 0 .. $highest_symbol_id;
}

# Return DSL form of symbol
# Does no checking
sub Marpa::R3::Scanless::G::lmg_symbol_dsl_form {
    my ( $slg, $lmw_name, $isyid ) = @_;
    my $per_lmg =
      $slg->[Marpa::R3::Internal::Scanless::G::PER_LMG]->{$lmw_name};
    my $xsy_by_isyid = $per_lmg->[Marpa::R3::Internal::Trace::G::XSY_BY_ISYID];
    my $xsy          = $xsy_by_isyid->[$isyid];
    return if not defined $xsy;

    # switch to ID after developement
    my $xsy_name = $xsy->[Marpa::R3::Internal::XSY::NAME];

    my ($dsl_form) = $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 's', $xsy_name );
        local slg, xsy_name = ...
        return slg.xsys[xsy_name].dsl_form
END_OF_LUA
    return $dsl_form;
}

# Return display form of symbol
# Does lots of checking and makes use of alternatives.
sub Marpa::R3::Scanless::G::lmg_symbol_display_form {
    my ( $slg, $lmw_name, $isyid ) = @_;
    my $text = $slg->lmg_symbol_dsl_form( $lmw_name, $isyid )
      // $slg->lmg_symbol_name($lmw_name, $isyid);
    return "<!No symbol with ID $isyid!>" if not defined $text;
    return ( $text =~ m/\s/xms ) ? "<$text>" : $text;
}

sub Marpa::R3::Scanless::G::lmg_show_symbols {
    my ( $slg, $lmw_name, $verbose ) = @_;
    my $per_lmg =
      $slg->[Marpa::R3::Internal::Scanless::G::PER_LMG]->{$lmw_name};
    my $text = q{};
    $verbose //= 0;

    my $grammar_name = $per_lmg->[Marpa::R3::Internal::Trace::G::NAME];

    my ($highest_symbol_id) =
      $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 's>*', $lmw_name );
    local grammar, lmw_name = ...
    local lmw_g = grammar[lmw_name]
    return lmw_g:highest_symbol_id()
END_OF_LUA

    for my $symbol_id ( 0 .. $highest_symbol_id ) {

        $text .= join q{ }, $grammar_name, "S$symbol_id",
          $slg->lmg_symbol_display_form( $lmw_name, $symbol_id );
        $text .= "\n";

        if ( $verbose >= 2 ) {

            ($text) = $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
                <<'END_OF_LUA', 'sis', $lmw_name, $symbol_id, $text );
    local g, lmw_name, symbol_id, text = ...
    local pieces = { text }
    local tags = { ' /*' }
    local lmw_g = g[lmw_name]
    if lmw_g:symbol_is_productive(symbol_id) == 0 then
        tags[#tags+1] = 'unproductive'
    end
    if lmw_g:symbol_is_accessible(symbol_id) == 0 then
        tags[#tags+1] = 'inaccessible'
    end
    if lmw_g:symbol_is_nulling(symbol_id) ~= 0 then
        tags[#tags+1] = 'nulling'
    end
    if lmw_g:symbol_is_terminal(symbol_id) ~= 0 then
        tags[#tags+1] = 'terminal'
    end
    if #tags >= 2 then
        tags[#tags+1] = '*/'
        pieces[#pieces+1] = " "
        pieces[#pieces+1] = table.concat(tags, ' ')
        pieces[#pieces+1] =  '\n'
    end
    pieces[#pieces+1] =  "  Internal name: <" 
    pieces[#pieces+1] =  lmw_g:symbol_name(symbol_id)
    pieces[#pieces+1] =  ">\n"
    return table.concat(pieces)
END_OF_LUA

        } ## end if ( $verbose >= 2 )

        if ( $verbose >= 3 ) {

            my $dsl_form = $slg->lmg_symbol_dsl_form( $lmw_name, $symbol_id );
            if ($dsl_form) { $text .= qq{  SLIF name: $dsl_form\n}; }

        } ## end if ( $verbose >= 3 )

    }

    return $text;
}

sub Marpa::R3::Scanless::G::lmg_show_rules {
    my ( $slg, $lmw_name, $verbose ) = @_;
    my $text = q{};
    $verbose //= 0;

    my $per_lmg =
      $slg->[Marpa::R3::Internal::Scanless::G::PER_LMG]->{$lmw_name};
    my $grammar_name = $per_lmg->[Marpa::R3::Internal::Trace::G::NAME];
    my $xbnf_by_irlid = $per_lmg->[Marpa::R3::Internal::Trace::G::XBNF_BY_IRLID];

    my ($highest_rule_id) = $slg->call_by_tag(
    ('@' .__FILE__ . ':' . __LINE__),
    <<'END_OF_LUA', 's>*', $lmw_name ) ;
    local grammar, lmw_name = ...
    local lmw_g = grammar[lmw_name]
    return lmw_g:highest_rule_id()
END_OF_LUA

    for my $irlid ( 0 .. $highest_rule_id ) {

        my $xbnf = $xbnf_by_irlid->[$irlid];

        my ( $has_minimum, $minimum ) =
          $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
            <<'END_OF_LUA', 'si>*', $lmw_name, $irlid );
    local grammar, lmw_name, irlid = ...
    local lmw_g = grammar[lmw_name]
    local minimum = lmw_g:sequence_min(irlid)
    if not minimum then return 0, -1 end
    return 1, minimum
END_OF_LUA

        my @quantifier = ();

        if ($has_minimum) {
            @quantifier = ( $minimum <= 0 ? q{*} : q{+} );
        }

        my ( $lhs_id, @rhs_ids ) = $slg->lmg_irl_isyids( $lmw_name, $irlid );
        $text .= join q{ }, $grammar_name, "R$irlid",
          $slg->lmg_symbol_display_form( $lmw_name, $lhs_id ),
          '::=',
          ( map { $slg->lmg_symbol_display_form( $lmw_name, $_ ) } @rhs_ids ),
          @quantifier;
        $text .= "\n";

        if ( $verbose >= 2 ) {

            my $comments = [];
            ( scalar @rhs_ids ) == 0
              and push @{$comments}, 'empty';

            ($comments) =
              $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
                <<'END_OF_LUA', 'sis', $lmw_name, $irlid, $comments );
    local g, lmw_name, irl_id, comments = ...
    local lmw_g = g[lmw_name]
    if lmw_g:_rule_is_used(irl_id) == 0 then
        comments[#comments+1] = '!used'
    end
    if lmw_g:rule_is_productive(irl_id) == 0 then
        comments[#comments+1] = 'unproductive'
    end
    if lmw_g:rule_is_accessible(irl_id) == 0 then
        comments[#comments+1] = 'inaccessible'
    end
    return comments
END_OF_LUA

            $xbnf->[Marpa::R3::Internal::XBNF::DISCARD_SEPARATION]
              and push @{$comments}, 'discard_sep';

            if ( @{$comments} ) {
                $text .=
                  q{  } . ( join q{ }, q{/*}, @{$comments}, q{*/} ) . "\n";
            }

            $text .= "  Symbol IDs: <$lhs_id> ::= "
              . ( join q{ }, map { "<$_>" } @rhs_ids ) . "\n";

        } ## end if ( $verbose >= 2 )

        if ( $verbose >= 3 ) {

            $text .=
                "  Internal symbols: <"
              . $slg->lmg_symbol_name( $lmw_name, $lhs_id )
              . q{> ::= }
              . (
                join q{ },
                map { '<' . $slg->lmg_symbol_name( $lmw_name, $_ ) . '>' }
                  @rhs_ids
              ) . "\n";

        } ## end if ( $verbose >= 3 )

    } ## end for my $rule ( @{$rules} )

    return $text;
}

sub Marpa::R3::Scanless::G::irl_isyids {
    my ($slg, $irlid) = @_;
    return $slg->lmg_irl_isyids('lmw_g1g', $irlid);
}

sub Marpa::R3::Scanless::G::l0_irl_isyids {
    my ($slg, $irlid) = @_;
    return $slg->lmg_irl_isyids('lmw_l0g', $irlid);
}

sub Marpa::R3::Scanless::G::lmg_irl_isyids {
    my ($slg, $lmw_name, $irlid) = @_;
    my ($symbols) = $slg->call_by_tag(
    ('@' .__FILE__ . ':' . __LINE__),
    <<'END_OF_LUA', 'si>*', $lmw_name, $irlid ) ;
    local grammar, lmw_name, irlid = ...
    local lmw_g = grammar[lmw_name]
    return lmw_g:irl_isyids(irlid)
END_OF_LUA
    return @{$symbols};
}

# not to be documented
sub Marpa::R3::Scanless::G::show_irls {
    my ($slg) = @_;
    my ($result) =
      $slg->call_by_tag(
        ('@' . __FILE__ . ':' .  __LINE__),
	<<'END_OF_LUA', '' );
    local grammar = ...
    local g1g = grammar.lmw_g1g
    local irl_count = g1g:_irl_count()
    local pieces = {}
    for irl_id = 0, irl_count - 1 do
        pieces[#pieces+1] = g1g:brief_irl(irl_id)
    end
    pieces[#pieces+1] = ''
    return table.concat(pieces, '\n')
END_OF_LUA
    return $result;
}

# not to be documented
sub Marpa::R3::Scanless::G::show_isys {
    my ($slg) = @_;
    my ($result) =
      $slg->call_by_tag(
        ('@' . __FILE__ . ':' .  __LINE__),
	<<'END_OF_LUA', '' );
    local grammar = ...
    local g1g = grammar.lmw_g1g
    local nsy_count = g1g:_nsy_count()
    local pieces = {}
    for isy_id = 0, nsy_count - 1 do
        pieces[#pieces+1] = g1g:show_isy(isy_id)
    end
    return table.concat(pieces)
END_OF_LUA
    return $result;
}

# not to be documented
sub Marpa::R3::Scanless::G::show_ahms {
    my ( $slg ) = @_;

    my ($text) = $slg->call_by_tag(
        ('@' . __FILE__ . ':' .  __LINE__),
	<<'END_OF_LUA', '' );
    local grammar = ...
    local g1g = grammar.lmw_g1g
    return g1g:show_ahms()
END_OF_LUA

    return $text;

} ## end sub show_ahms

# not to be documented
sub Marpa::R3::Scanless::G::show_dotted_irl {
    my ( $slg, $irl_id, $dot_position ) = @_;
    my ($result) =
      $slg->call_by_tag(
        ('@' . __FILE__ . ':' .  __LINE__),
	<<'END_OF_LUA', 'ii', $irl_id, $dot_position );
    local grammar, irl_id, dot_position = ...
    local g1g = grammar.lmw_g1g
    return g1g:show_dotted_irl(irl_id, dot_position)
END_OF_LUA
    return $result;
}

# not to be documented
sub Marpa::R3::Scanless::G::show_briefer_ahm {
    my ( $slg, $item_id ) = @_;

    my ($text) = $slg->call_by_tag(
        ('@' . __FILE__ . ':' .  __LINE__),
	<<'END_OF_LUA', 'i', $item_id );
    local grammar, item_id = ...
    local g1g = grammar.lmw_g1g
    local irl_id = g1g:_ahm_irl(item_id)
    local dot_position = g1g:_ahm_position(item_id)
    if (dot_position < 0 ) then
        return string.format("R%d$", irl_id)
    end
    return string.format("R%d:%d", irl_id, dot_position)
END_OF_LUA

    return $text;

}

# not to be documented
sub Marpa::R3::Scanless::G::brief_irl {
    my ( $slg, $irl_id ) = @_;
    my ($text) = $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 'i', $irl_id );
    local grammar, irl_id = ...
    local g1g = grammar.lmw_g1g
    return g1g:brief_irl(irl_id)
END_OF_LUA

    return $text;
}

# not to be documented
sub Marpa::R3::Scanless::G::regix {
    my ( $slg ) = @_;
    my $regix = $slg->[Marpa::R3::Internal::Scanless::G::REGIX];
    return $regix;
}

1;

# vim: expandtab shiftwidth=4:
