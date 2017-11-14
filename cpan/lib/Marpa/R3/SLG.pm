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

package Marpa::R3::Grammar;

use 5.010001;
use strict;
use warnings;

use vars qw($VERSION $STRING_VERSION);
$VERSION        = '4.001_050';
$STRING_VERSION = $VERSION;
## no critic(BuiltinFunctions::ProhibitStringyEval)
$VERSION = eval $VERSION;
## use critic

package Marpa::R3::Internal_G;

use Scalar::Util 'blessed';
use English qw( -no_match_vars );

# names of packages for strings
our $PACKAGE = 'Marpa::R3::Grammar';

# The bare mininum Scanless grammer, suitable as a base
# for both metagrammar and user grammars.
sub pre_construct {
    my ($class) = @_;
    my $pre_slg = bless [], $class;
    $pre_slg->[Marpa::R3::Internal_G::TRACE_FILE_HANDLE] = \*STDERR;
    $pre_slg->[Marpa::R3::Internal_G::CONSTANTS] = [];

    my $lua = Marpa::R3::Lua->new();
    $pre_slg->[Marpa::R3::Internal_G::L] = $lua;

    my ($regix) = $lua->call_by_tag (-1,
        ('@' .__FILE__ . ':' .  __LINE__),
       <<'END_OF_LUA', '');
        local slg = _M.slg_new()
        return slg.regix
END_OF_LUA

    $pre_slg->[Marpa::R3::Internal_G::REGIX] = $regix;
    return $pre_slg;
}

sub Marpa::R3::Internal::meta_grammar {

    my $meta_slg = pre_construct('Marpa::R3::Grammar');

    state $hashed_metag = Marpa::R3::Internal::MetaG::hashed_grammar();
    $meta_slg->[Marpa::R3::Internal_G::BLESS_PACKAGE] =
      'Marpa::R3::Internal::MetaAST_Nodes';
    Marpa::R3::Internal_G::hash_to_runtime( $meta_slg, $hashed_metag );

    return $meta_slg;

} ## end sub Marpa::R3::Internal::meta_grammar

sub Marpa::R3::Grammar::new {
    my ( $class, @hash_ref_args ) = @_;

    my $slg = pre_construct($class);

    my ( $flat_args, $error_message ) =
      Marpa::R3::flatten_hash_args( \@hash_ref_args );
    Marpa::R3::exception( sprintf $error_message, '$slg->new' )
      if not $flat_args;

    my $p_dsl = Marpa::R3::Internal_G::set( $slg, $flat_args );
    my $ast        = Marpa::R3::Internal::MetaAST->new($p_dsl);
    my $hashed_ast = $ast->ast_to_hash($p_dsl);
    Marpa::R3::Internal_G::hash_to_runtime( $slg, $hashed_ast);
    return $slg;
}

sub Marpa::R3::Grammar::DESTROY {
    # say STDERR "In Marpa::R3::Grammar::DESTROY before test";
    my $slg = shift;
    my $lua = $slg->[Marpa::R3::Internal_G::L];

    # If we are destroying the Perl interpreter, then all the Marpa
    # objects will be destroyed, including Marpa's Lua interpreter.
    # We do not need to worry about cleaning up the
    # grammar is an orderly manner, because the Lua interpreter
    # containing the grammar will be destroyed.
    # In fact, the Lua interpreter may already have been destroyed,
    # so this test is necessary to avoid a warning message.
    return if not $lua;
    # say STDERR "In Marpa::R3::Grammar::DESTROY after test";

    my $regix = $slg->[Marpa::R3::Internal_G::REGIX];
    $lua->call_by_tag($regix,
        ('@' . __FILE__ . ':' . __LINE__),
        <<'END_OF_LUA', 'i', $regix);
    local grammar, regix = ...
    _M.unregister(_M.registry, regix)
END_OF_LUA
}

sub Marpa::R3::Grammar::set {
    my ( $slg, @hash_ref_args ) = @_;
    my ( $flat_args, $error_message ) =
      Marpa::R3::flatten_hash_args( \@hash_ref_args );
    Marpa::R3::exception( sprintf $error_message, '$slg->set' )
      if not $flat_args;

    my $value = $flat_args->{trace_file_handle};
    if ( defined $value ) {
        $slg->[Marpa::R3::Internal_G::TRACE_FILE_HANDLE] = $value;
        delete $flat_args->{trace_file_handle};
    }

    my @bad_arguments = keys %{$flat_args};
    if ( scalar @bad_arguments ) {
        Marpa::R3::exception(
            q{Bad named argument(s) to $slg->set() method} . join q{ },
            @bad_arguments );
    }
    return;
}

sub Marpa::R3::Internal_G::set {
    my ( $slg, $flat_args ) = @_;

    my $dsl = $flat_args->{'source'};
    Marpa::R3::exception(
        qq{Marpa::R3::Grammar::new() called without a 'source' argument})
      if not defined $dsl;
    my $dsl_ref_type = ref $dsl;
    if ( $dsl_ref_type ne 'SCALAR' ) {
        my $desc = $dsl_ref_type ? "a ref to $dsl_ref_type" : 'not a ref';
        Marpa::R3::exception(
qq{'source' name argument to Marpa::R3::Grammar->new() is $desc\n},
            "  It should be a ref to a string\n"
        );
    }
    if ( not defined ${$dsl} ) {
        Marpa::R3::exception(
qq{'source' name argument to Marpa::R3::Grammar->new() is a ref to a an undef\n},
            "  It should be a ref to a string\n"
        );
    } ## end if ( $ref_type ne 'SCALAR' )
    delete $flat_args->{'source'};

    my $value = $flat_args->{trace_file_handle};
    if ( defined $value ) {
        $slg->[Marpa::R3::Internal_G::TRACE_FILE_HANDLE] = $value;
        delete $flat_args->{'trace_file_handle'};
    }

    my $trace_file_handle =
        $slg->[Marpa::R3::Internal_G::TRACE_FILE_HANDLE];

    if ( exists $flat_args->{'trace_actions'} ) {
        my $value = $flat_args->{'trace_actions'};
        $slg->[Marpa::R3::Internal_G::TRACE_ACTIONS] = $value;
        if ($value) {
            say {$trace_file_handle} 'Setting trace_actions option'
              or Marpa::R3::exception("Cannot print: $ERRNO");
        }
        delete $flat_args->{'trace_actions'};
    }

    if ( defined( exists $flat_args->{'bless_package'} ) ) {
        my $value = $flat_args->{'bless_package'};
        $slg->[Marpa::R3::Internal_G::BLESS_PACKAGE] = $value;
        delete $flat_args->{'bless_package'};
    }

    if ( exists $flat_args->{'exhaustion'} ) {

        my $value = $flat_args->{'exhaustion'} // '';

    $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 's', $value);
    local slg, value = ...
    local exhaustion_actions = {
        fatal = true,
        event = true
    }
    if not exhaustion_actions[value] then
        if #value == 0 then value = 'undefined' end
        error(string.format(
            "'exhaustion' named arg value is %s \z
            'event' or 'fatal'",
            value
        ))
    end
    slg.exhaustion_action = value
END_OF_LUA

        delete $flat_args->{'exhaustion'};

    }

    if ( exists $flat_args->{'rejection'} ) {

        my $value = $flat_args->{'rejection'} // '';

    $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 's', $value);
    local slg, value = ...
    local rejection_actions = {
        fatal = true,
        event = true
    }
    if not rejection_actions[value] then
        if #value == 0 then value = 'undefined' end
        error(string.format(
            "'rejection' named arg value is %s \z
            'event' or 'fatal'",
            value
        ))
    end
    slg.rejection_action = value
END_OF_LUA

        delete $flat_args->{'rejection'};

    }

    if ( exists $flat_args->{'semantics_package'} ) {
        my $value = $flat_args->{'semantics_package'};
        $slg->[Marpa::R3::Internal_G::SEMANTICS_PACKAGE] = $value;
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

    return $dsl;

}

# The object, in computing the hash, is to get as much
# precomputation in as possible, without using undue space.
# That means CPU-intensive processing should tend to be done
# before or during hash creation, and space-intensive processing
# should tend to be done here, in the code that converts the
# hash to its runtime equivalent.
sub Marpa::R3::Internal_G::hash_to_runtime {
    my ( $slg, $hashed_source ) = @_;

    my $is_meta = exists $hashed_source->{meta} ? 1 : undef;

    my $trace_file_handle = $slg->[Marpa::R3::Internal_G::TRACE_FILE_HANDLE];
    # Pre-lexer G1 processing

    my ($if_inaccessible_default) = $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 's', $hashed_source );
        local slg, source_hash = ...

        slg:xsys_populate( source_hash)
        slg:xrls_populate(source_hash)
        slg:xprs_populate(source_hash)
        local if_inaccessible = slg.if_inaccessible
        do
            local defaults = source_hash.defaults
            if defaults then
                if_inaccessible = defaults.if_inaccessible or if_inaccessible
            end
        end
        slg.if_inaccessible = if_inaccessible

        slg:g1_precompute(source_hash);

        local l0g = _M.grammar_new(slg, 'l0')
        slg.l0 = l0g
        l0g.start_name = '[:lex_start:]'

        local g1g = slg.g1

        do
           local l0_symbols = source_hash.symbols.l0
           local l0_symbol_names = {}
           for symbol_name, _ in pairs(l0_symbols) do
               l0_symbol_names[#l0_symbol_names+1] = symbol_name
           end
           table.sort(l0_symbol_names)
           for ix = 1,#l0_symbol_names do
               local symbol_name = l0_symbol_names[ix]
               local options = l0_symbols[symbol_name]
               slg:l0_symbol_assign(symbol_name, options)
           end
        end

        do
           local l0_rules = source_hash.rules.l0
           for ix = 1,#l0_rules do
               local options = l0_rules[ix]
               slg:l0_rule_add(options)
           end
        end

        for g1_isyid = 0, g1g:highest_symbol_id() do
            local is_terminal = 0 ~= g1g:symbol_is_terminal(g1_isyid)

            if is_terminal then
                 local g1_isy = g1g.isys[g1_isyid]
                 local lexeme = { g1_isy = g1_isy }
                 g1g.isys[g1_isyid].lexeme = lexeme
                 local xsy = g1g:_xsy(g1_isyid)
                 if xsy then
                     if xsy.lexeme then

                         local g1_isyid2 = xsy.lexeme.g1_isy.id
                         _M._internal_error(
                             "Xsymbol %q (id=%d) has 2 g1 lexemes: \n\z
                             \u{20}   %q (id=%d), and\n\z
                             \u{20}   %q (id=%d)\n",
                             xsy:display_name(), xsy.id,
                             g1g:symbol_name(g1_isyid), g1_isyid,
                             g1g:symbol_name(g1_isyid2), g1_isyid2
                         )
                     end
                     lexeme.xsy = xsy
                     xsy.lexeme = lexeme

                     -- TODO delete this check after development
                     if xsy.name ~= slg.g1:symbol_name(g1_isyid) then
                         _M._internal_error(
                             "1: Lexeme name mismatch xsy=%q, g1 isy = %q",
                             xsy.name,
                             slg.g1:symbol_name(g1_isyid)
                         )
                     end
                 end
            end
        end

        return if_inaccessible
END_OF_LUA

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
    state $lex_start_symbol_name = '[:lex_start:]';
    state $discard_symbol_name   = '[:discard:]';

    my $character_class_hash = $hashed_source->{character_classes};

    my @lex_lexeme_names = sort keys %{$lexeme_declarations};

    my $lex_discard_symbol_id =
      $slg->l0_symbol_by_name($discard_symbol_name) // -1;
    my @lex_lexeme_to_g1_symbol;
    for (
        my $iter = $slg->g1_symbol_ids_gen() ;
        defined( my $lexeme_id = $iter->() ) ;
      )
    {
        $lex_lexeme_to_g1_symbol[$lexeme_id] = -1;
    }

  LEXEME_NAME: for my $lexeme_name (@lex_lexeme_names) {
        next LEXEME_NAME if $lexeme_name eq $discard_symbol_name;
        next LEXEME_NAME if $lexeme_name eq $lex_start_symbol_name;

    my ($g1_symbol_id) = $slg->coro_by_tag(
        ( '@' . __FILE__ . ':' . __LINE__ ),
        {
            signature => 's',
            args      => [$lexeme_name],
            handlers  => {
                trace => sub {
                    my ($msg) = @_;
                    say {$trace_file_handle} $msg;
                    return 'ok';
                },
            }
        },
        <<'END_OF_LUA');
        local slg, lexeme_name = ...
        _M.wrap(function ()
            return 'ok', slg:g1_symbol_by_name(lexeme_name)
        end)
END_OF_LUA

        if ( not $slg->g1_symbol_is_accessible($g1_symbol_id) ) {
            my $message =
"A lexeme in L0 is not accessible from the G1 start symbol: $lexeme_name";
            say {$trace_file_handle} $message
              if $if_inaccessible_default eq 'warn';
            Marpa::R3::exception($message)
              if $if_inaccessible_default eq 'fatal';
        }

        my $lex_symbol_id = $slg->l0_symbol_by_name($lexeme_name);
        $lex_lexeme_to_g1_symbol[$lex_symbol_id] = $g1_symbol_id;
    } ## end LEXEME_NAME: for my $lexeme_name (@lex_lexeme_names)

    my @lex_rule_to_g1_lexeme;
    my $lex_start_symbol_id =
      $slg->l0_symbol_by_name($lex_start_symbol_name);
  RULE_ID: for (my $iter = $slg->l0_rule_ids_gen(); defined ( my $rule_id = $iter->());) {

        my ($lhs_id) = $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
            <<'END_OF_LUA', 'i>*', $rule_id );
    local grammar, rule_id = ...
    local l0g = grammar.l0
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
    local l0g = grammar.l0
    return l0g:rule_rhs(rule_id, 0)
END_OF_LUA

        {
            if ( $lexer_lexeme_id == $lex_discard_symbol_id ) {
                $lex_rule_to_g1_lexeme[$rule_id] = -1;
                next RULE_ID;
            }
            my $lexeme_id = $lex_lexeme_to_g1_symbol[$lexer_lexeme_id] // -1;
            $lex_rule_to_g1_lexeme[$rule_id] = $lexeme_id;
            next RULE_ID if $lexeme_id < 0;
            my $lexeme_name = $slg->g1_symbol_name($lexeme_id);

            my $assertion_id =
              $lexeme_data{$lexeme_name}{lexer}{'assertion'};
            if ( not defined $assertion_id ) {

                ($assertion_id) =
                  $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
                    <<'END_OF_LUA', '>*' );
    local grammar = ...
    local l0g = grammar.l0
    return l0g:zwa_new(0)
END_OF_LUA

                $lexeme_data{$lexeme_name}{lexer}{'assertion'} =
                  $assertion_id;
            } ## end if ( not defined $assertion_id )

            $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
                <<'END_OF_LUA', 'ii>*', $assertion_id, $rule_id );
    local grammar, assertion_id, rule_id = ...
    local l0g = grammar.l0
    l0g:zwa_place(assertion_id, rule_id, 0)
END_OF_LUA
        }

    }

      Marpa::R3::Internal_G::precompute( $slg, 'l0' );

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

    my $default_discard_event = $discard_default_adverbs->{event};
  RULE_ID:
    for (
        my $iter = $slg->l0_rule_ids_gen() ;
        defined( my $irlid = $iter->() ) ;
      )
    {

        # There may be gaps in the IRLIDs
        my $event;
      FIND_EVENT: {

            my ( $cmd, $event_name, $event_starts_active ) =
              $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
                <<'END_OF_LUA', 'ii>*', $irlid, $lex_discard_symbol_id );
    local slg, irlid, lex_discard_symbol_id = ...
    local lyr_l0 = slg.l0
    local irl = lyr_l0.irls[irlid]
    local xpr = irl.xpr
    if not xpr then
        return 'next RULE_ID'
    end
    local event_name = xpr.event_name
    if event_name then
         return 'ok', event_name, xpr.event_starts_active
    end
    local l0g = lyr_l0
    local lhs_id = l0g:rule_lhs(irlid)
    if lhs_id ~= lex_discard_symbol_id then
        return 'next RULE_ID'
    end
    return ''
END_OF_LUA

            if ( $cmd eq 'ok' ) {
                $event = [ $event_name, $event_starts_active ];
                last FIND_EVENT;
            }

            next RULE_ID if $cmd eq 'next RULE_ID';

            $event = $default_discard_event;
        } ## end FIND_EVENT:

        next RULE_ID if not defined $event;

        my ( $event_name, $event_starts_active ) = @{$event};
        if ( $event_name eq q{'symbol} ) {

            my ($symbol_as_event) =
              $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
                <<'END_OF_LUA', 'i>*', $irlid );
    local slg, irlid = ...
    local irl = slg.l0.irls[irlid]
    -- at this point, xpr must be defined
    local xpr = irl.xpr
    return xpr.symbol_as_event
END_OF_LUA

            $event = $symbol_as_event;
            my @event = ( $event, $event_starts_active );
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

    # At this point we know which symbols are lexemes.
    # So now let's check for inconsistencies

    $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 's', ($lexeme_declarations // {}));
    local slg, lexeme_declarations = ...
    local g1g = slg.g1
    -- local slg, lexeme_name, g1_lexeme_id, declarations = ...

    local lexeme_event_by_isy = {}
    slg.lexeme_event_by_isy = lexeme_event_by_isy
    local lexeme_event_by_name = {}
    slg.lexeme_event_by_name = lexeme_event_by_name

    for g1_lexeme_id = 0, g1g:highest_symbol_id() do
        local isy = g1g.isys[g1_lexeme_id]
        local lexeme_name = isy.name
        local declarations = lexeme_declarations[lexeme_name]
        if not isy.lexeme then
            goto NEXT_SYMBOL
        end
        declarations = declarations or {}

        local g1_isy = slg.g1.isys[g1_lexeme_id]
        local priority = 0
        if declarations.priority then
            priority = declarations.priority + 0
        end
        g1_isy.priority = priority
        if declarations.eager then g1_isy.eager = true end
        if slg.completion_event_by_isy[lexeme_name] then
            error(string.format(
                "A completion event is declared for <%s>, but it is a lexeme.\n\z
                \u{20}    Completion events are only valid for symbols on the LHS of G1 rules.\n",
                lexeme_name
            ))
        end
        if slg.nulled_event_by_isy[lexeme_name] then
            error(string.format(
                "A nulled event is declared for <%s>, but it is a lexeme.\n\z
                \u{20}    Nulled events are only valid for symbols on the LHS of G1 rules.\n",
                lexeme_name
            ))
        end

        local pause_value = declarations.pause
        if pause_value then
            pause_value = math.tointeger(pause_value)
            local g1_isy = slg.g1.isys[g1_lexeme_id]
            if pause_value == 1 then
                 g1_isy.pause_after = true
            elseif pause_value == -1 then
                 g1_isy.pause_before = true
            end
            local event = declarations.event
            local is_active = 1
            if event then
                local event_name = event[1]
                local is_active = event[2] ~= '0'

                local event_desc = {
                   name = event_name,
                   isyid = g1_lexeme_id,
                }
                lexeme_event_by_isy[g1_lexeme_id] = event_desc
                lexeme_event_by_isy[lexeme_name] = event_desc
                local name_entry = lexeme_event_by_name[event_name]
                if not name_entry then
                    lexeme_event_by_name[event_name] = { event_desc }
                else
                    name_entry[#name_entry+1] = event_desc
                end

                local g1_isy = slg.g1.isys[g1_lexeme_id]
                if is_active then
                    -- activate only if event is enabled
                    g1_isy.pause_after_active = g1_isy.pause_after
                    g1_isy.pause_before_active = g1_isy.pause_before
                else
                    g1_isy.pause_after_active = nil
                    g1_isy.pause_before_active = nil
                end

            end
        end
        ::NEXT_SYMBOL::
    end
END_OF_LUA

    # Second phase of lexer processing
      $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', '');
        local slg = ...
        slg.discard_event_by_irl = {}
        slg.discard_event_by_name = {}
END_OF_LUA

  RULE_ID: for my $lexer_rule_id ( 0 .. $#lex_rule_to_g1_lexeme ) {
        my $g1_lexeme_id = $lex_rule_to_g1_lexeme[$lexer_rule_id];
        my $assertion_id = -1;
        my $lexeme_name  = $slg->g1_symbol_name($g1_lexeme_id);
        if (defined $lexeme_name) {
            $assertion_id = $lexeme_data{$lexeme_name}{lexer}{'assertion'};
        }
        my ( $discard_symbol_id ) = $slg->l0_rule_expand($lexer_rule_id);

      $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA',
    local g, lexer_rule_id, g1_lexeme_id, assertion_id, discard_symbol_id = ...
    if lexer_rule_id >= 0 then
        g.l0.irls[lexer_rule_id].g1_lexeme = g1_lexeme_id
        if g1_lexeme_id >= 0 then
            local eager = g.g1.isys[g1_lexeme_id].eager
            if eager then g.l0.irls[lexer_rule_id].eager = true end
        end
        local eager = g.l0.isys[discard_symbol_id].eager
        if eager then
            g.l0.irls[lexer_rule_id].eager = true
        end
    end
    if g1_lexeme_id >= 0 then
        g.g1.isys[g1_lexeme_id].assertion = assertion_id
    end
END_OF_LUA
        'iiii', $lexer_rule_id, $g1_lexeme_id, $assertion_id, $discard_symbol_id );

        my $discard_event = $discard_event_by_lexer_rule_id[$lexer_rule_id];

      $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 'is', $lexer_rule_id, $discard_event );
        local slg, lexer_rule_id, discard_event = ...
        if discard_event then
            local event_name = discard_event[1]
            local is_active = discard_event[2] == "1"
            local l0_rules = slg.l0.irls

            local event_desc = {
               name = event_name,
               irlid = lexer_rule_id
            }
            slg.discard_event_by_irl[lexer_rule_id] = event_desc
            local name_entry = slg.discard_event_by_name[event_name]
            if not name_entry then
                slg.discard_event_by_name[event_name] = { event_desc }
            else
                name_entry[#name_entry+1] = event_desc
            end

            l0_rules[lexer_rule_id].event_on_discard = true
            l0_rules[lexer_rule_id].event_on_discard_active = is_active
        end
END_OF_LUA

    }

    # Second phase of G1 processing
    # The grammar can be thought to be "precomputed" at this point,
    # although I don't think the concept is as relevant as it is
    # for the Libmarpa grammars.

    # More lexer processing
    # Determine events by lexer rule, applying the defaults

    $slg->[Marpa::R3::Internal_G::CHARACTER_CLASS_TABLE] =
      $character_class_table;

    # Some lexeme default adverbs are applied in earlier phases.
  {

        my $default_lexeme_action = $lexeme_default_adverbs->{action};

        $slg->call_by_tag(
        ('@' .__FILE__ . ':' .  __LINE__),
        <<'END_OF_LUA', 's', $default_lexeme_action);
        local slg, default_lexeme_action = ...
        for _, xsy in pairs(slg.xsys) do
            local name_source = xsy.name_source
            if name_source == 'lexical' and not xsy.lexeme_semantics then
                xsy.lexeme_semantics = default_lexeme_action
            end
        end
END_OF_LUA

    }

  APPLY_DEFAULT_LEXEME_BLESSING: {
        my $default_blessing = $lexeme_default_adverbs->{bless};

      G1_SYMBOL:
        for (my $iter = $slg->symbol_ids_gen();
        defined(my $xsyid = $iter->()); ) {

        my ($cmd, $blessing, $g1_lexeme_id, $lexeme_name) = $slg->call_by_tag(
        ('@' .__FILE__ . ':' .  __LINE__),
        <<'END_OF_LUA', 'is', $xsyid, ($default_blessing // '::undef'));
        local slg, xsyid, default_blessing = ...
        local xsy = slg.xsys[xsyid]
        if not xsy then
            return 'next G1_SYMBOL', default_blessing
        end
        local lexeme = xsy.lexeme
        if not lexeme then
            return 'next G1_SYMBOL', default_blessing
        end
        local g1_lexeme_id = lexeme.g1_isy.id
        local name_source = xsy.name_source
        if name_source ~= 'lexical' then return 'next G1_SYMBOL', default_blessing end
        if not xsy.blessing then
            xsy.blessing = default_blessing
        end

        -- TODO delete the following check after development
        if xsy.name ~= slg.g1:symbol_name(g1_lexeme_id) then
            _M._internal_error(
                "Lexeme name mismatch xsy=%q, g1 isy = %q",
                xsy.name,
                slg.g1:symbol_name(g1_lexeme_id)
            )
        end

        return 'ok', xsy.blessing, g1_lexeme_id, xsy.name
END_OF_LUA

            next G1_SYMBOL if $cmd eq 'next G1_SYMBOL';

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

            $slg->call_by_tag(
                ('@' .__FILE__ . ':' .  __LINE__),
                <<'END_OF_LUA', 'is', $g1_lexeme_id, $blessing);
            local slg, isyid, blessing = ...
            local xsy = slg.g1.xsys[isyid]
            xsy.blessing = blessing
END_OF_LUA

        }

    }

    my $registrations = registrations_find($slg );
    registrations_set($slg, $registrations );

    return $slg;

}

sub Marpa::R3::Internal_G::precompute {
    my ( $slg, $subg_name ) = @_;
    my $trace_file_handle = $slg->[Marpa::R3::Internal_G::TRACE_FILE_HANDLE];
    $slg->coro_by_tag(
        ( '@' . __FILE__ . ':' . __LINE__ ),
        {
            signature => 's',
            args      => [$subg_name],
            handlers  => {
                trace => sub {
                    my ($msg) = @_;
                    say {$trace_file_handle} $msg;
                    return 'ok';
                },
            }
        },
        <<'END_OF_LUA');
    local slg, subg_name = ...
    _M.wrap(function ()
        local subg = slg[subg_name]
        slg:precompute(subg)
        return 'ok'
    end)
END_OF_LUA
    return;
}

our $kwgen_code_template = <<'END_OF_TEMPLATE';
END_OF_TEMPLATE

sub kwgen {
    my ($line, $perl_name, $kollos_name, $signature) = @_;
    my $tag = '@' . __FILE__ . ':' .  $line;
    my $code = sprintf( 'return _M.class_slg.%s(...)', $kollos_name );
    # my $code = sprintf( 'io.stderr:write("Calling slg.%s ", table.concat(..., "")); return _M.class_slg.%s(...)', $kollos_name, $kollos_name );
    no strict 'refs';
    *{ 'Marpa::R3::Grammar::' . $perl_name }
        = sub () {
            my ($slg, @args) = @_;
            my ($retour) = $slg->call_by_tag($tag, $code, $signature, @args);
            return $retour;
        };
    use strict;
}

sub kwgen_arr {
    my ($line, $perl_name, $kollos_name, $signature) = @_;
    my $tag = '@' . __FILE__ . ':' .  $line;
    my $code = sprintf( 'return _M.class_slg.%s(...)', $kollos_name );
    # my $code = sprintf( 'io.stderr:write("Calling slg.%s ", table.concat(..., "")); return _M.class_slg.%s(...)', $kollos_name, $kollos_name );
    no strict 'refs';
    *{ 'Marpa::R3::Grammar::' . $perl_name }
        = sub () {
            my ($slg, @args) = @_;
            my ($retour) = $slg->call_by_tag($tag, $code, $signature, @args);
            return @{$retour};
        };
    use strict;
}

sub kwgen_opt {
    my ($line, $perl_name, $kollos_name, $signature, @defaults) = @_;
    my $tag = '@' . __FILE__ . ':' .  $line;
    my $code = sprintf( 'return _M.class_slg.%s(...)', $kollos_name );
    # my $code = sprintf( 'io.stderr:write("Calling slg.%s ", table.concat(..., "")); return _M.class_slg.%s(...)', $kollos_name, $kollos_name );
    no strict 'refs';
    *{ 'Marpa::R3::Grammar::' . $perl_name }
        = sub () {
            my ($slg, @args) = @_;
            $args[$_] //= $defaults[$_] for 0 .. $#defaults;
            my ($retour) = $slg->call_by_tag($tag, $code, $signature, @args);
            return $retour;
        };
    use strict;
}

sub Marpa::R3::Grammar::production_show {
    my ($slg, $xprid, $options) = @_;
    my $verbose = $options->{verbose} or 0;
    my $diag = $options->{diag} ? 1 : 0;
    my $tag = '@' . __FILE__ . ':' .  __LINE__;
    my $code = <<'END_OF_CODE';
    local slg, xprid, verbose, diag = ...
    diag = diag ~= 0 -- convert diag to a boolean
    return slg:xpr_show(xprid, { verbose = verbose, diag = diag })
END_OF_CODE
    my ($retour) = $slg->call_by_tag($tag, $code, 'iii',
        $xprid, $verbose, $diag);
    return $retour;
}

sub Marpa::R3::Grammar::symbols_show {
    my ($slg, $options) = @_;
    my $verbose = $options->{verbose} or 0;
    my $diag = $options->{diag} ? 1 : 0;
    my $tag = '@' . __FILE__ . ':' .  __LINE__;
    my $code = <<'END_OF_CODE';
    local slg, verbose, diag = ...
    diag = diag ~= 0 -- convert diag to a boolean
    return slg:symbols_show({ verbose = verbose, diag = diag })
END_OF_CODE
    my ($retour) = $slg->call_by_tag($tag, $code, 'ii',
        $verbose, $diag);
    return $retour;
}

sub Marpa::R3::Grammar::symbol_show {
    my ($slg, $xsyid, $options) = @_;
    my $verbose = $options->{verbose} or 0;
    my $diag = $options->{diag} ? 1 : 0;
    my $tag = '@' . __FILE__ . ':' .  __LINE__;
    my $code = <<'END_OF_CODE';
    local slg, xsyid, verbose, diag = ...
    diag = diag ~= 0 -- convert diag to a boolean
    return slg:symbol_show(xsyid, { verbose = verbose, diag = diag })
END_OF_CODE
    my ($retour) = $slg->call_by_tag($tag, $code, 'iii',
        $xsyid, $verbose, $diag);
    return $retour;
}

sub Marpa::R3::Grammar::lmg_rule_show {
    my ($slg, $subg, $irlid, $options) = @_;
    my $verbose = $options->{verbose} or 0;
    my $diag = $options->{diag} ? 1 : 0;
    my $tag = '@' . __FILE__ . ':' .  __LINE__;
    my $code = <<'END_OF_CODE';
    local slg, subg, irlid, verbose, diag = ...
    diag = diag ~= 0 -- convert diag to a boolean
    return slg:lmg_rule_show(subg, irlid, { verbose = verbose, diag = diag })
END_OF_CODE
    my ($retour) = $slg->call_by_tag($tag, $code, 'siii',
        $subg, $irlid, $verbose, $diag);
    return $retour;
}

sub Marpa::R3::Grammar::g1_rule_show {
    my ($slg, $irlid, $options) = @_;
    my $verbose = $options->{verbose} or 0;
    my $diag = $options->{diag} ? 1 : 0;
    my $tag = '@' . __FILE__ . ':' .  __LINE__;
    my $code = <<'END_OF_CODE';
    local slg, irlid, verbose, diag = ...
    diag = diag ~= 0 -- convert diag to a boolean
    return slg:g1_rule_show(irlid, { verbose = verbose, diag = diag })
END_OF_CODE
    my ($retour) = $slg->call_by_tag($tag, $code, 'iii',
        $irlid, $verbose, $diag);
    return $retour;
}

sub Marpa::R3::Grammar::l0_rule_show {
    my ($slg, $irlid, $options) = @_;
    my $verbose = $options->{verbose} or 0;
    my $diag = $options->{diag} ? 1 : 0;
    my $tag = '@' . __FILE__ . ':' .  __LINE__;
    my $code = <<'END_OF_CODE';
    local slg, irlid, verbose, diag = ...
    diag = diag ~= 0 -- convert diag to a boolean
    return slg:l0_rule_show(irlid, { verbose = verbose, diag = diag })
END_OF_CODE
    my ($retour) = $slg->call_by_tag($tag, $code, 'iii',
        $irlid, $verbose, $diag);
    return $retour;
}

sub Marpa::R3::Grammar::productions_show {
    my ($slg, $options) = @_;
    my $verbose = $options->{verbose} or 0;
    my $diag = $options->{diag} ? 1 : 0;
    my $tag = '@' . __FILE__ . ':' .  __LINE__;
    my $code = <<'END_OF_CODE';
    local slg, verbose, diag = ...
    diag = diag ~= 0 -- convert diag to a boolean
    return slg:xprs_show({ verbose = verbose, diag = diag })
END_OF_CODE
    my ($retour) = $slg->call_by_tag($tag, $code, 'ii',
        $verbose, $diag);
    return $retour;
}

sub Marpa::R3::Grammar::lmg_rules_show {
    my ($slg, $subg, $options) = @_;
    my $verbose = $options->{verbose} or 0;
    my $diag = $options->{diag} ? 1 : 0;
    my $tag = '@' . __FILE__ . ':' .  __LINE__;
    my $code = <<'END_OF_CODE';
    local slg, subg, verbose, diag = ...
    diag = diag ~= 0 -- convert diag to a boolean
    return slg:lmg_rules_show(subg, { verbose = verbose, diag = diag })
END_OF_CODE
    my ($retour) = $slg->call_by_tag($tag, $code, 'sii',
        $subg, $verbose, $diag);
    return $retour;
}

sub Marpa::R3::Grammar::g1_rules_show {
    my ($slg, $options) = @_;
    my $verbose = $options->{verbose} or 0;
    my $diag = $options->{diag} ? 1 : 0;
    my $tag = '@' . __FILE__ . ':' .  __LINE__;
    my $code = <<'END_OF_CODE';
    local slg, verbose, diag = ...
    diag = diag ~= 0 -- convert diag to a boolean
    return slg:g1_rules_show({ verbose = verbose, diag = diag })
END_OF_CODE
    my ($retour) = $slg->call_by_tag($tag, $code, 'ii',
        $verbose, $diag);
    return $retour;
}

sub Marpa::R3::Grammar::l0_rules_show {
    my ($slg, $options) = @_;
    my $verbose = $options->{verbose} or 0;
    my $diag = $options->{diag} ? 1 : 0;
    my $tag = '@' . __FILE__ . ':' . __LINE__;
    my $code = <<'END_OF_LUA';
    local slg, verbose, diag = ...
    diag = diag ~= 0 -- convert diag to a boolean
    return slg:l0_rules_show({ verbose = verbose, diag = diag })
END_OF_LUA
    my ($retour) = $slg->call_by_tag($tag, $code, 'ii',
        $verbose, $diag);
    return $retour;
}

# TODO: Census all uses of Marpa::R3::Grammar::g1_symbol_name
# in pod and tests, and make sure that they are appropriate --
# that is, that they should not be symbol_name() instead.

kwgen(__LINE__, qw(highest_symbol_id highest_symbol_id), '');
kwgen(__LINE__, qw(lmg_highest_symbol_id lmg_highest_symbol_id i));
kwgen(__LINE__, qw(g1_highest_symbol_id g1_highest_symbol_id), '');
kwgen(__LINE__, qw(l0_highest_symbol_id l0_highest_symbol_id), '');

kwgen(__LINE__, qw(start_symbol_id start_symbol_id), '');
kwgen(__LINE__, qw(lmg_start_symbol_id lmg_start_symbol_id s));
kwgen(__LINE__, qw(g1_start_symbol_id g1_start_symbol_id), '');
kwgen(__LINE__, qw(l0_start_symbol_id l0_start_symbol_id), '');

kwgen(__LINE__, qw(g1_xsymbol_id g1_xsyid i));
kwgen(__LINE__, qw(l0_xsymbol_id l0_xsyid i));

kwgen(__LINE__, qw(symbol_name symbol_name i));
kwgen(__LINE__, qw(lmg_symbol_name lmg_symbol_name si));
kwgen(__LINE__, qw(g1_symbol_name g1_symbol_name i));
kwgen(__LINE__, qw(l0_symbol_name l0_symbol_name i));

kwgen(__LINE__, qw(symbol_display_form symbol_display_form i));
kwgen(__LINE__, qw(lmg_symbol_display_form lmg_symbol_display_form si));
kwgen(__LINE__, qw(g1_symbol_display_form g1_symbol_display_form i));
kwgen(__LINE__, qw(l0_symbol_display_form l0_symbol_display_form i));

kwgen(__LINE__, qw(symbol_angled_form symbol_angled_form i));
kwgen(__LINE__, qw(lmg_symbol_angled_form lmg_symbol_angled_form si));
kwgen(__LINE__, qw(g1_symbol_angled_form g1_symbol_angled_form i));
kwgen(__LINE__, qw(l0_symbol_angled_form l0_symbol_angled_form i));

kwgen(__LINE__, qw(symbol_dsl_form symbol_dsl_form i));
kwgen(__LINE__, qw(lmg_symbol_dsl_form lmg_symbol_dsl_form si));
kwgen(__LINE__, qw(g1_symbol_dsl_form g1_symbol_dsl_form i));
kwgen(__LINE__, qw(l0_symbol_dsl_form l0_symbol_dsl_form i));

kwgen_opt(__LINE__, qw(lmg_symbols_show lmg_symbols_show si), 0, 0);
kwgen_opt(__LINE__, qw(g1_symbols_show g1_symbols_show i), 0);
kwgen_opt(__LINE__, qw(l0_symbols_show l0_symbols_show i), 0);

kwgen(__LINE__, qw(lmg_symbol_by_name lmg_symbol_by_name si));
kwgen(__LINE__, qw(g1_symbol_by_name g1_symbol_by_name i));
kwgen(__LINE__, qw(l0_symbol_by_name l0_symbol_by_name i));

kwgen(__LINE__, qw(g1_symbol_is_accessible g1_symbol_is_accessible i));
kwgen(__LINE__, qw(g1_symbol_is_nulling g1_symbol_is_nulling i));
kwgen(__LINE__, qw(g1_symbol_is_productive g1_symbol_is_productive i));

kwgen(__LINE__, qw(production_dotted_show xpr_dotted_show ii));
kwgen(__LINE__, qw(lmg_dotted_rule_show lmg_dotted_rule_show sii));
kwgen(__LINE__, qw(g1_dotted_rule_show g1_dotted_rule_show ii));
kwgen(__LINE__, qw(l0_dotted_rule_show l0_dotted_rule_show ii));

kwgen(__LINE__, qw(production_name xpr_name i));

kwgen(__LINE__, qw(lmg_rule_to_production_id lmg_rule_to_xprid si));
kwgen(__LINE__, qw(g1_rule_to_production_id g1_rule_to_xprid i));
kwgen(__LINE__, qw(l0_rule_to_production_id l0_rule_to_xprid i));

kwgen(__LINE__, qw(lmg_rule_to_production_dot lmg_rule_to_xpr_dots si));
kwgen(__LINE__, qw(g1_rule_to_production_dot g1_rule_to_xpr_dots i));
kwgen(__LINE__, qw(l0_rule_to_production_dot l0_rule_to_xpr_dots i));

kwgen(__LINE__, qw(highest_production_id highest_xprid), '');
kwgen(__LINE__, qw(lmg_highest_rule_id lmg_highest_rule_id), '');
kwgen(__LINE__, qw(g1_highest_rule_id g1_highest_rule_id), '');
kwgen(__LINE__, qw(l0_highest_rule_id l0_highest_rule_id), '');

kwgen_arr(__LINE__, qw(production_expand xpr_expand i));
kwgen_arr(__LINE__, qw(lmg_rule_expand lmg_irl_isyids si));
kwgen_arr(__LINE__, qw(g1_rule_expand g1_irl_isyids i));
kwgen_arr(__LINE__, qw(l0_rule_expand l0_irl_isyids i));

kwgen(__LINE__, qw(production_length xpr_length i));

sub Marpa::R3::Grammar::call_by_tag {
    my ( $slg, $tag, $codestr, $sig, @args ) = @_;
    my $lua = $slg->[Marpa::R3::Internal_G::L];
    my $regix = $slg->[Marpa::R3::Internal_G::REGIX];
    # $DB::single = 1 if not defined $lua;
    # $DB::single = 1 if not defined $regix;
    # $DB::single = 1 if not defined $tag;
    # $DB::single = 1 if not defined $codestr;
    # $DB::single = 1 if not defined $sig;
    # $DB::single = 1 if grep { not defined $_ } @args;
    my @results;
    my $eval_error;
    my $eval_ok;
    {
        local $@;
        $eval_ok = eval {
            # say STDERR "About to call_by_tag($regix, $tag, $codestr, $sig, @args)";;
            @results = $lua->call_by_tag($regix, $tag, $codestr, $sig, @args);
            # say STDERR "Returned from call_by_tag($regix, $tag, $codestr, $sig, @args)";;
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
sub Marpa::R3::Grammar::coro_by_tag {
    my ( $slg, $tag, $args, $codestr ) = @_;
    my $lua        = $slg->[Marpa::R3::Internal_G::L];
    my $regix      = $slg->[Marpa::R3::Internal_G::REGIX];
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
            my $coro_arg;
          CORO_CALL: while (1) {
                my ( $cmd, $yield_data ) =
                  $lua->call_by_tag( $regix, $resume_tag,
                    'local slg, coro_arg = ...; return _M.resume(coro_arg)',
                    's', $coro_arg );

                if (not $cmd) {
                   @results = @{$yield_data};
                   return 1;
                }
                my $handler = $handler->{$cmd};
                Marpa::R3::exception(qq{No coro handler for "$cmd"})
                  if not $handler;
                $yield_data //= [];
                my $handler_cmd;
                ($handler_cmd, $coro_arg) = $handler->(@{$yield_data});
            }
            return 1;
        };
        $eval_error = $@;
    }
    if ( not $eval_ok ) {
        Marpa::R3::exception($eval_error);
    }
    return @results;
}

sub Marpa::R3::Grammar::symbol_ids_gen {
    my ($slg) = @_;
    my $next = 1;
    my $last = $slg->highest_symbol_id();
    return sub () {
        return if $next > $last;
        my $current;
        ($current, $next) = ($next, $next+1);
        return $current;
    }
}

sub Marpa::R3::Grammar::lmg_symbol_ids_gen {
    my ($slg, $subg) = @_;
    my $next = 0;
    my $last = $slg->lmg_highest_symbol_id($subg);
    return sub () {
        return if $next > $last;
        my $current;
        ($current, $next) = ($next, $next+1);
        return $current;
    }
}

sub Marpa::R3::Grammar::g1_symbol_ids_gen {
    my ($slg) = @_;
    my $next = 0;
    my $last = $slg->g1_highest_symbol_id();
    return sub () {
        return if $next > $last;
        my $current;
        ($current, $next) = ($next, $next+1);
        return $current;
    }
}

sub Marpa::R3::Grammar::l0_symbol_ids_gen {
    my ($slg) = @_;
    my $next = 0;
    my $last = $slg->l0_highest_symbol_id();
    return sub () {
        return if $next > $last;
        my $current;
        ($current, $next) = ($next, $next+1);
        return $current;
    }
}

sub Marpa::R3::Grammar::production_ids_gen {
    my ($slg) = @_;
    my $next = 1;
    my $last = $slg->highest_production_id();
    return sub () {
        return if $next > $last;
        my $current;
        ($current, $next) = ($next, $next+1);
        return $current;
    }
}

sub Marpa::R3::Grammar::lmg_rule_ids_gen {
    my ($slg, $subg) = @_;
    my $next = 0;
    my $last = $slg->lmg_highest_rule_id($subg);
    return sub () {
        return if $next > $last;
        my $current;
        ($current, $next) = ($next, $next+1);
        return $current;
    }
}

sub Marpa::R3::Grammar::g1_rule_ids_gen {
    my ($slg) = @_;
    my $next = 0;
    my $last = $slg->g1_highest_rule_id();
    return sub () {
        return if $next > $last;
        my $current;
        ($current, $next) = ($next, $next+1);
        return $current;
    }
}

sub Marpa::R3::Grammar::l0_rule_ids_gen {
    my ($slg) = @_;
    my $next = 0;
    my $last = $slg->l0_highest_rule_id();
    return sub () {
        return if $next > $last;
        my $current;
        ($current, $next) = ($next, $next+1);
        return $current;
    }
}

# not to be documented
sub Marpa::R3::Grammar::nrls_show {
    my ($slg) = @_;
    my ($result) =
      $slg->call_by_tag(
        ('@' . __FILE__ . ':' .  __LINE__),
        <<'END_OF_LUA', '' );
    local grammar = ...
    local g1g = grammar.g1
    local nrl_count = g1g:_irl_count()
    local pieces = {}
    for nrl_id = 0, nrl_count - 1 do
        pieces[#pieces+1] = g1g:brief_nrl(nrl_id)
    end
    pieces[#pieces+1] = ''
    return table.concat(pieces, '\n')
END_OF_LUA
    return $result;
}

# not to be documented
sub Marpa::R3::Grammar::nsys_show {
    my ($slg) = @_;
    my ($result) =
      $slg->call_by_tag(
        ('@' . __FILE__ . ':' .  __LINE__),
        <<'END_OF_LUA', '' );
    local grammar = ...
    local g1g = grammar.g1
    local nsy_count = g1g:_nsy_count()
    local pieces = {}
    for nsy_id = 0, nsy_count - 1 do
        pieces[#pieces+1] = g1g:nsy_show(nsy_id)
    end
    return table.concat(pieces)
END_OF_LUA
    return $result;
}

# not to be documented
sub Marpa::R3::Grammar::ahms_show {
    my ( $slg ) = @_;

    my ($text) = $slg->call_by_tag(
        ('@' . __FILE__ . ':' .  __LINE__),
        <<'END_OF_LUA', '' );
    local grammar = ...
    local g1g = grammar.g1
    return g1g:ahms_show()
END_OF_LUA

    return $text;

}

# not to be documented
sub Marpa::R3::Grammar::dotted_nrl_show {
    my ( $slg, $nrl_id, $dot_position ) = @_;
    my ($result) =
      $slg->call_by_tag(
        ('@' . __FILE__ . ':' .  __LINE__),
        <<'END_OF_LUA', 'ii', $nrl_id, $dot_position );
    local grammar, nrl_id, dot_position = ...
    local g1g = grammar.g1
    return g1g:_dotted_nrl_show(nrl_id, dot_position)
END_OF_LUA
    return $result;
}

# not to be documented
sub Marpa::R3::Grammar::briefer_ahm {
    my ( $slg, $item_id ) = @_;

    my ($text) = $slg->call_by_tag(
        ('@' . __FILE__ . ':' .  __LINE__),
        <<'END_OF_LUA', 'i', $item_id );
    local grammar, item_id = ...
    local g1g = grammar.g1
    local irl_id = g1g:_ahm_nrl(item_id)
    local dot_position = g1g:_ahm_position(item_id)
    if (dot_position < 0 ) then
        return string.format("R%d$", irl_id)
    end
    return string.format("R%d:%d", irl_id, dot_position)
END_OF_LUA

    return $text;

}

# not to be documented
sub Marpa::R3::Grammar::brief_nrl {
    my ( $slg, $nrl_id ) = @_;
    my ($text) = $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 'i', $nrl_id );
    local grammar, nrl_id = ...
    local g1g = grammar.g1
    return g1g:brief_nrl(nrl_id)
END_OF_LUA

    return $text;
}

# not to be documented
sub Marpa::R3::Grammar::regix {
    my ( $slg ) = @_;
    my $regix = $slg->[Marpa::R3::Internal_G::REGIX];
    return $regix;
}

sub registrations_find {
    my ($slg) = @_;
    my $trace_file_handle =
      $slg->[Marpa::R3::Internal_G::TRACE_FILE_HANDLE];
    my $trace_actions =
      $slg->[Marpa::R3::Internal_G::TRACE_ACTIONS] // 0;

    my @closure_by_irlid   = ();
    my @semantics_by_irlid = ();
    my @blessing_by_irlid  = ();

    my ( $rule_resolutions, $lexeme_resolutions ) = resolve_grammar($slg);

    # Set the arrays, and perform various checks on the resolutions
    # we received
    {
      RULE: for (my $iter = $slg->g1_rule_ids_gen(); defined ( my $irlid = $iter->());) {
            my ( $new_resolution, $closure, $semantics, $blessing ) =
              @{ $rule_resolutions->[$irlid] };
            my ($lhs_id) =
              $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
                <<'END_OF_LUA', 'i>*', $irlid );
    local grammar, irlid = ...
    local g1g = grammar.g1
    return g1g:rule_lhs(irlid)
END_OF_LUA

          REFINE_SEMANTICS: {

                if (
                    '[' eq substr $semantics,
                    0, 1 and ']' eq substr $semantics,
                    -1, 1
                  )
                {
                    # Normalize array semantics
                    $semantics =~ s/ //gxms;
                    last REFINE_SEMANTICS;
                } ## end if ( '[' eq substr $semantics, 0, 1 and ']' eq ...)

                state $allowed_semantics = {
                    map { ; ( $_, 1 ) } qw(::array ::undef ::first ::!default),
                    q{}
                };
                last REFINE_SEMANTICS if $allowed_semantics->{$semantics};
                last REFINE_SEMANTICS
                  if $semantics =~ m/ \A rhs \d+ \z /xms;

                Marpa::R3::exception(
                    q{Unknown semantics for rule },
                    $slg->g1_rule_show($irlid),
                    "\n",
                    qq{    Semantics were specified as "$semantics"\n}
                );

            } ## end REFINE_SEMANTICS:

            $semantics_by_irlid[$irlid] = $semantics;
            $blessing_by_irlid[$irlid]  = $blessing;
            $closure_by_irlid[$irlid]   = $closure;

          CHECK_BLESSING: {
                last CHECK_BLESSING if $blessing eq '::undef';
                if ($closure) {
                    my $ref_type = Scalar::Util::reftype $closure;
                    if ( $ref_type eq 'SCALAR' ) {

               # The constant's dump might be long so I repeat the error message
                        Marpa::R3::exception(
qq{Fatal error: Attempt to bless a rule that resolves to a scalar constant\n},
                            qq{  Scalar constant is },
                            Data::Dumper::Dumper($closure),
                            qq{  Blessing is "$blessing"\n},
                            q{  Rule is: },
                            $slg->g1_rule_show($irlid),
                            "\n",
qq{  Cannot bless rule when it resolves to a scalar constant},
                            "\n",
                        );
                    } ## end if ( $ref_type eq 'SCALAR' )
                    last CHECK_BLESSING;
                } ## end if ($closure)
                last CHECK_BLESSING if $semantics eq '::array';
                last CHECK_BLESSING if ( substr $semantics, 0, 1 ) eq '[';
                Marpa::R3::exception(
                    qq{Cannot bless rule when the semantics are "$semantics"},
                    q{  Rule is: },
                    $slg->g1_rule_show($irlid),
                    "\n",
                    qq{  Blessing is "$blessing"\n},
                    qq{  Semantics are "$semantics"\n}
                );
            } ## end CHECK_BLESSING:

        }

    } ## end CHECK_FOR_WHATEVER_CONFLICT

    # A LHS can be nullable via more than one rule,
    # and that means more than one semantics might be specified for
    # the nullable symbol.  This logic deals with that.
    my @nullable_rule_ids_by_lhs = ();
      RULE: for (my $iter = $slg->g1_rule_ids_gen(); defined ( my $irlid = $iter->());) {

        my ( $lhs_id, $rule_is_nullable ) =
          $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
            <<'END_OF_LUA', 'i>*', $irlid );
    local grammar, irlid = ...
    local g1g = grammar.g1
    return g1g:rule_lhs(irlid), g1g:rule_is_nullable(irlid)
END_OF_LUA

        push @{ $nullable_rule_ids_by_lhs[$lhs_id] }, $irlid
          if $rule_is_nullable;
    }

    my @null_symbol_closures;
  LHS:
    for ( my $lhs_id = 0 ; $lhs_id <= $#nullable_rule_ids_by_lhs ; $lhs_id++ ) {
        my $irlids = $nullable_rule_ids_by_lhs[$lhs_id];
        my $resolution_rule;

        # No nullable rules for this LHS?  No problem.
        next LHS if not defined $irlids;
        my $rule_count = scalar @{$irlids};

        # I am not sure if this test is necessary
        next LHS if $rule_count <= 0;

        # Just one nullable rule?  Then that's our semantics.
        if ( $rule_count == 1 ) {
            $resolution_rule = $irlids->[0];
            my ( $resolution_name, $closure ) =
              @{ $rule_resolutions->[$resolution_rule] };
            if ($trace_actions) {
                my $lhs_name = $slg->g1_symbol_display($lhs_id);
                say {$trace_file_handle}
                  qq{Nulled symbol "$lhs_name" },
                  qq{ resolved to "$resolution_name" from rule },
                  $slg->g1_rule_show($resolution_rule)
                  or Marpa::R3::exception('print to trace handle failed');
            } ## end if ($trace_actions)
            $null_symbol_closures[$lhs_id] = $resolution_rule;
            next LHS;
        } ## end if ( $rule_count == 1 )

        # More than one rule?  Are any empty?
        # If so, use the semantics of the empty rule
        my ($empty_rules) =
          $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
            <<'END_OF_LUA', 'i>*', $irlids );
    local grammar, irlids = ...
    local g1g = grammar.g1
    local empty_rules = {}
    for ix = 1, #irlids do
        local irlid = irlids[ix]
        local rule_length = g1g:rule_length(irlid)
        if rule_length and rule_length == 0 then
           empty_rules[#empty_rules+1] = irlid
        end
    end
    return empty_rules
END_OF_LUA

        if ( scalar @{$empty_rules} ) {
            $resolution_rule = $empty_rules->[0];
            my ( $resolution_name, $closure ) =
              @{ $rule_resolutions->[$resolution_rule] };
            if ($trace_actions) {
                my $lhs_name = $slg->g1_symbol_display($lhs_id);
                say {$trace_file_handle}
                  qq{Nulled symbol "$lhs_name" },
                  qq{ resolved to "$resolution_name" from rule },
                  $slg->g1_rule_show($resolution_rule)
                  or Marpa::R3::exception('print to trace handle failed');
            } ## end if ($trace_actions)
            $null_symbol_closures[$lhs_id] = $resolution_rule;
            next LHS;
        }

        # Multiple rules, none of them empty.
        my ( $first_resolution, @other_resolutions ) =
          map { $rule_resolutions->[$_] } @{$irlids};

        # Do they have more than one semantics?
        # If so, just call it an error and let the user sort it out.
        my ( $first_closure_name, undef, $first_semantics, $first_blessing ) =
          @{$first_resolution};
      OTHER_RESOLUTION: for my $other_resolution (@other_resolutions) {
            my ( $other_closure_name, undef, $other_semantics, $other_blessing )
              = @{$other_resolution};

            if (   $first_closure_name ne $other_closure_name
                or $first_semantics ne $other_semantics
                or $first_blessing ne $other_blessing )
            {
                Marpa::R3::exception(
                    'When nulled, symbol ',
                    $slg->g1_symbol_display($lhs_id),
                    qq{  can have more than one semantics\n},
                    qq{  Marpa needs there to be only one semantics\n},
                    qq{  The rules involved are:\n},
                    g1_show_rule_list( $slg, $irlids )
                );
            } ## end if ( $first_closure_name ne $other_closure_name or ...)
        } ## end OTHER_RESOLUTION: for my $other_resolution (@other_resolutions)

        # Multiple rules, but they all have one semantics.
        # So (obviously) use that semantics
        $resolution_rule = $irlids->[0];
        my ( $resolution_name, $closure ) =
          @{ $rule_resolutions->[$resolution_rule] };
        if ($trace_actions) {
            my $lhs_name = $slg->g1_symbol_display($lhs_id);
            say {$trace_file_handle}
              qq{Nulled symbol "$lhs_name" },
              qq{ resolved to "$resolution_name" from rule },
              $slg->g1_rule_show($resolution_rule)
              or Marpa::R3::exception('print to trace handle failed');
        } ## end if ($trace_actions)
        $null_symbol_closures[$lhs_id] = $resolution_rule;

    } ## end LHS: for ( my $lhs_id = 0; $lhs_id <= $#nullable_rule_ids_by_lhs...)

    # Do consistency checks

    # Set the object values
    my $null_values = $slg->[Marpa::R3::Internal_G::NULL_VALUES] =
      \@null_symbol_closures;

    my @semantics_by_lexeme_id = ();
    my @blessing_by_lexeme_id  = ();

    # Check the lexeme semantics
    {
        my ($highest_symbol_id) =
          $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
            <<'END_OF_LUA', '>*' );
    local grammar = ...
    local g1g = grammar.g1
    return g1g:highest_symbol_id()
END_OF_LUA

      LEXEME: for my $lexeme_id ( 0 .. $highest_symbol_id ) {

            my ( $semantics, $blessing ) =
              @{ $lexeme_resolutions->[$lexeme_id] };
          CHECK_SEMANTICS: {
                if ( not $semantics ) {
                    $semantics = '::!default';
                    last CHECK_SEMANTICS;
                }
                if ( ( substr $semantics, 0, 1 ) eq '[' ) {
                    $semantics =~ s/ //gxms;
                    last CHECK_SEMANTICS;
                }
                state $allowed_semantics =
                  { map { ; ( $_, 1 ) } qw(::array ::undef ::!default ) };

                if ( not $allowed_semantics->{$semantics} ) {
                    Marpa::R3::exception(
                        q{Unknown semantics for lexeme },
                        $slg->g1_symbol_display($lexeme_id),
                        "\n",
                        qq{    Semantics were specified as "$semantics"\n}
                    );
                } ## end if ( not $allowed_semantics->{$semantics} )

            } ## end CHECK_SEMANTICS:
          CHECK_BLESSING: {
                if ( not $blessing ) {
                    $blessing = '::undef';
                    last CHECK_BLESSING;
                }
                last CHECK_BLESSING if $blessing eq '::undef';
                last CHECK_BLESSING
                  if $blessing =~ /\A [[:alpha:]] [:\w]* \z /xms;
                Marpa::R3::exception(
                    q{Unknown blessing for lexeme },
                    $slg->g1_symbol_display($lexeme_id),
                    "\n",
                    qq{    Blessing as specified as "$blessing"\n}
                );
            } ## end CHECK_BLESSING:
            $semantics_by_lexeme_id[$lexeme_id] = $semantics;
            $blessing_by_lexeme_id[$lexeme_id]  = $blessing;

        }

    }

    # state $op_lua = Marpa::R3::Thin::op('lua');
    my ($op_lua) = $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', '' );
        return _M.defines.MARPA_OP_LUA
END_OF_LUA

    my ($op_debug_key)        = op_fn_key_by_name( $slg, "debug" );
    my ($op_noop_key)         = op_fn_key_by_name( $slg, "noop" );
    my ($op_bail_key)         = op_fn_key_by_name( $slg, "bail" );
    my ($op_bless_key)        = op_fn_key_by_name( $slg, "bless" );
    my ($op_callback_key)     = op_fn_key_by_name( $slg, "callback" );
    my ($result_is_undef_key) = op_fn_key_by_name( $slg, 'result_is_undef' );
    my ($result_is_constant_key) =
      op_fn_key_by_name( $slg, 'result_is_constant' );
    my ($result_is_token_value_key) =
      op_fn_key_by_name( $slg, "result_is_token_value" );
    my ($result_is_n_of_rhs_key) =
      op_fn_key_by_name( $slg, "result_is_n_of_rhs" );
    my ($result_is_n_of_sequence_key) =
      op_fn_key_by_name( $slg, "result_is_n_of_sequence" );
    my ($result_is_array_key)   = op_fn_key_by_name( $slg, "result_is_array" );
    my ($op_push_constant_key)  = op_fn_key_by_name( $slg, 'push_constant' );
    my ($op_push_undef_key)     = op_fn_key_by_name( $slg, 'push_undef' );
    my ($op_push_one_key)       = op_fn_key_by_name( $slg, 'push_one' );
    my ($op_push_values_key)    = op_fn_key_by_name( $slg, 'push_values' );
    my ($op_push_g1_start_key)  = op_fn_key_by_name( $slg, 'push_g1_start' );
    my ($op_push_g1_length_key) = op_fn_key_by_name( $slg, 'push_g1_length' );
    my ($op_push_start_key)     = op_fn_key_by_name( $slg, 'push_start' );
    my ($op_push_length_key)    = op_fn_key_by_name( $slg, 'push_length' );

    my @nulling_symbol_by_semantic_rule;
  NULLING_SYMBOL: for my $nulling_symbol ( 0 .. $#{$null_values} ) {
        my $semantic_rule = $null_values->[$nulling_symbol];
        next NULLING_SYMBOL if not defined $semantic_rule;
        $nulling_symbol_by_semantic_rule[$semantic_rule] = $nulling_symbol;
    } ## end NULLING_SYMBOL: for my $nulling_symbol ( 0 .. $#{$null_values} )

    my @work_list = ();
    RULE: for (my $iter = $slg->g1_rule_ids_gen(); defined ( my $irlid = $iter->());) {

        my $semantics = $semantics_by_irlid[$irlid];
        my $blessing  = $blessing_by_irlid[$irlid];

        $semantics = '[name,values]' if $semantics eq '::!default';
        $semantics = '[values]'      if $semantics eq '::array';
        $semantics = '::rhs0'        if $semantics eq '::first';

        push @work_list, [ $irlid, undef, $semantics, $blessing ];
    }

    my ($highest_symbol_id) =
      $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', '' );
        local grammar = ...
        return grammar.g1:highest_symbol_id()
END_OF_LUA

  LEXEME: for my $lexeme_id ( 0 .. $highest_symbol_id ) {

        my $semantics = $semantics_by_lexeme_id[$lexeme_id];
        my $blessing  = $blessing_by_lexeme_id[$lexeme_id];

        next LEXEME
          if $semantics eq '::!default' and $blessing eq '::undef';
        $semantics = '::value' if $semantics eq '::!default';
        $semantics = '[value]' if $semantics eq '::array';

        push @work_list, [ undef, $lexeme_id, $semantics, $blessing ];
    }

    # Registering operations is postponed to this point, because
    # the valuator must exist for this to happen.  In the future,
    # it may be best to have a separate semantics object.
    my @nulling_closures = ();
    my @registrations    = ();

  WORK_ITEM: for my $work_item (@work_list) {
        my ( $irlid, $lexeme_id, $semantics, $blessing ) = @{$work_item};

        my ( $closure, $rule_length,
            $is_sequence_rule,
            $is_discard_sequence_rule,
            $nulling_symbol_id );
        if ( defined $irlid ) {
            $nulling_symbol_id = $nulling_symbol_by_semantic_rule[$irlid];
            $closure           = $closure_by_irlid[$irlid];

            ( $rule_length, $is_sequence_rule,
                $is_discard_sequence_rule ) =
              $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
                <<'END_OF_LUA', 'i', $irlid );
        local slg, irlid = ...
        local g1g = slg.g1
        local is_sequence_rule = g1g:sequence_min(irlid) and 1 or 0
        local irl = slg.g1.irls[irlid]
        local xpr = irl.xpr
        local is_discard_sequence = false
        if xpr and xpr.discard_separation and is_sequence_rule then
            is_discard_sequence = true
        end
        return g1g:rule_length(irlid), is_sequence_rule, is_discard_sequence
END_OF_LUA

        } ## end if ( defined $irlid )

        # Determine the "fate" of the array of child values
        my @array_fate = ();
      ARRAY_FATE: {
            if ( defined $closure and ref $closure eq 'CODE' ) {
                push @array_fate, $op_lua, $op_callback_key, $op_bail_key;
                last ARRAY_FATE;

            }

            if ( ( substr $semantics, 0, 1 ) eq '[' ) {
                push @array_fate, $op_lua, $result_is_array_key, $op_bail_key;
                last ARRAY_FATE;
            }
        } ## end ARRAY_FATE:

        my @ops = ();

      SET_OPS: {

            if ( $semantics eq '::undef' ) {
                @ops = ( $op_lua, $result_is_undef_key, $op_bail_key );
                last SET_OPS;
            }

          CHECK_TYPE: {
                last CHECK_TYPE if not defined $irlid;
                my $thingy_ref = $closure_by_irlid[$irlid];
                last CHECK_TYPE if not defined $thingy_ref;
                my $ref_type = Scalar::Util::reftype $thingy_ref;
                if ( $ref_type eq q{} ) {
                    my $rule_desc = $slg->g1_rule_show($irlid);
                    Marpa::R3::exception(
                        qq{An action resolved to a scalar.\n},
                        qq{  This is not allowed.\n},
                        qq{  A constant action must be a reference.\n},
                        qq{  Rule was $rule_desc\n}
                    );
                } ## end if ( $ref_type eq q{} )

                if ( $ref_type eq 'CODE' ) {

               # Set the nulling closure if this is the nulling symbol of a rule
                    $nulling_closures[$nulling_symbol_id] = $thingy_ref
                      if defined $nulling_symbol_id
                      and defined $irlid;
                    last CHECK_TYPE;
                } ## end if ( $ref_type eq 'CODE' )

                my $rule_desc = $slg->g1_rule_show($irlid);
                Marpa::R3::exception(
                    qq{Constant action is not of an allowed type.\n},
                    qq{  It was of type reference to $ref_type.\n},
                    qq{  Rule was $rule_desc\n}
                );
            }

            # After this point, any closure will be a ref to 'CODE'

            if ( defined $lexeme_id and $semantics eq '::value' ) {
                @ops = ( $op_lua, $result_is_token_value_key, $op_bail_key );
                last SET_OPS;
            }

          PROCESS_SINGLETON_RESULT: {
                last PROCESS_SINGLETON_RESULT if not defined $irlid;

                my $singleton;
                if ( $semantics =~ m/\A [:][:] rhs (\d+)  \z/xms ) {
                    $singleton = $1 + 0;
                }

                last PROCESS_SINGLETON_RESULT if not defined $singleton;

                my $singleton_element = $singleton;
                if ($is_discard_sequence_rule) {
                    @ops = (
                        $op_lua, $result_is_n_of_sequence_key,
                        $singleton_element
                    );
                    last SET_OPS;
                }
                if ($is_sequence_rule) {
                    @ops =
                      ( $op_lua, $result_is_n_of_rhs_key, $singleton_element );
                    last SET_OPS;
                }

                my ($mask) = $slg->call_by_tag(
                    ( '@' . __FILE__ . ':' . __LINE__ ),
                    <<'END_OF_LUA', 'i>0', $irlid );
                        local slg, irlid = ...
                        return slg.g1.irls[irlid].mask
END_OF_LUA

                my @elements =
                  grep { $mask->[$_] } 0 .. ( $rule_length - 1 );
                if ( not scalar @elements ) {
                    my $original_semantics = $semantics_by_irlid[$irlid];
                    Marpa::R3::exception(
                        q{Impossible semantics for empty rule: },
                        $slg->g1_rule_show($irlid),
                        "\n",
qq{    Semantics were specified as "$original_semantics"\n}
                    );
                } ## end if ( not scalar @elements )
                $singleton_element = $elements[$singleton];

                if ( not defined $singleton_element ) {
                    my $original_semantics = $semantics_by_irlid[$irlid];
                    Marpa::R3::exception(
                        q{Impossible semantics for rule: },
                        $slg->g1_rule_show($irlid),
                        "\n",
qq{    Semantics were specified as "$original_semantics"\n}
                    );
                } ## end if ( not defined $singleton_element )
                @ops = ( $op_lua, $result_is_n_of_rhs_key, $singleton_element );
                last SET_OPS;
            } ## end PROCESS_SINGLETON_RESULT:

            if ( not @array_fate ) {
                @ops = ( $op_lua, $result_is_undef_key, $op_bail_key );
                last SET_OPS;
            }

            # if here, @array_fate is non-empty

            my @bless_ops = ();
            if ( $blessing ne '::undef' ) {
                push @bless_ops, $op_lua, $op_bless_key, \[$irlid, $lexeme_id, $blessing];
            }

            Marpa::R3::exception(qq{Unknown semantics: "$semantics"})
              if ( substr $semantics, 0, 1 ) ne '[';

            my @push_ops = ();
            my $array_descriptor = substr $semantics, 1, -1;
            $array_descriptor =~ s/^\s*|\s*$//g;
          RESULT_DESCRIPTOR:
            for my $result_descriptor ( split /[,]\s*/xms, $array_descriptor ) {
                $result_descriptor =~ s/^\s*|\s*$//g;
                if ( $result_descriptor eq 'g1start' ) {
                    push @push_ops, $op_lua, $op_push_g1_start_key,
                      $op_bail_key;
                    next RESULT_DESCRIPTOR;
                }
                if ( $result_descriptor eq 'g1length' ) {
                    push @push_ops, $op_lua, $op_push_g1_length_key,
                      $op_bail_key;
                    next RESULT_DESCRIPTOR;
                }
                if ( $result_descriptor eq 'start' ) {
                    push @push_ops, $op_lua, $op_push_start_key, $op_bail_key;
                    next RESULT_DESCRIPTOR;
                }
                if ( $result_descriptor eq 'length' ) {
                    push @push_ops, $op_lua, $op_push_length_key, $op_bail_key;
                    next RESULT_DESCRIPTOR;
                }

                if ( $result_descriptor eq 'lhs' ) {
                    if ( defined $irlid ) {

                        my ($lhs_id) = $slg->call_by_tag(
                            ( '@' . __FILE__ . ':' . __LINE__ ),
                            <<'END_OF_LUA', 'i>*', $irlid );
    local grammar, irlid = ...
    local g1g = grammar.g1
    return g1g:rule_lhs(irlid)
END_OF_LUA
                        push @push_ops, $op_lua, $op_push_constant_key,
                          \$lhs_id;
                        next RESULT_DESCRIPTOR;
                    }
                    if ( defined $lexeme_id ) {
                        push @push_ops, $op_lua, $op_push_constant_key,
                          \$lexeme_id;
                        next RESULT_DESCRIPTOR;
                    }
                    push @push_ops, $op_lua, $op_push_undef_key, $op_bail_key;
                    next RESULT_DESCRIPTOR;
                } ## end if ( $result_descriptor eq 'lhs' )

                if ( $result_descriptor eq 'name' ) {
                    if ( defined $irlid ) {
                        my $production_id =
                          $slg->g1_rule_to_production_id($irlid);
                        my $name = $slg->production_name($production_id);
                        push @push_ops, $op_lua, $op_push_constant_key, \$name;
                        next RESULT_DESCRIPTOR;
                    }
                    if ( defined $lexeme_id ) {
                        my $name = $slg->g1_symbol_name($lexeme_id);
                        push @push_ops, $op_lua, $op_push_constant_key, \$name;
                        next RESULT_DESCRIPTOR;
                    }
                    if ( defined $nulling_symbol_id ) {
                        my $name = $slg->g1_symbol_name($nulling_symbol_id);
                        push @push_ops, $op_lua, $op_push_constant_key, \$name;
                        next RESULT_DESCRIPTOR;
                    }
                    push @push_ops, $op_lua, $op_push_undef_key, $op_bail_key;
                    next RESULT_DESCRIPTOR;
                } ## end if ( $result_descriptor eq 'name' )

                if ( $result_descriptor eq 'symbol' ) {
                    if ( defined $irlid ) {
                        my ($name) = $slg->call_by_tag(
                            ( '@' . __FILE__ . ':' . __LINE__ ),
                            <<'END_OF_LUA', 'i>*', $irlid );
    local grammar, irlid = ...
    local g1g = grammar.g1
    local lhs_id = g1g:rule_lhs(irlid)
    return g1g:symbol_name(lhs_id)
END_OF_LUA
                        push @push_ops, $op_lua, $op_push_constant_key, \$name;
                        next RESULT_DESCRIPTOR;
                    } ## end if ( defined $irlid )
                    if ( defined $lexeme_id ) {
                        my $name = $slg->g1_symbol_name($lexeme_id);
                        push @push_ops, $op_lua, $op_push_constant_key, \$name;
                        next RESULT_DESCRIPTOR;
                    }
                    if ( defined $nulling_symbol_id ) {
                        my $name = $slg->g1_symbol_name($nulling_symbol_id);
                        push @push_ops, $op_lua, $op_push_constant_key, \$name;
                        next RESULT_DESCRIPTOR;
                    }
                    push @push_ops, $op_lua, $op_push_undef_key, $op_bail_key;
                    next RESULT_DESCRIPTOR;
                } ## end if ( $result_descriptor eq 'symbol' )

                if ( $result_descriptor eq 'rule' ) {
                    if ( defined $irlid ) {
                        push @push_ops, $op_lua, $op_push_constant_key, \$irlid;
                        next RESULT_DESCRIPTOR;
                    }
                    push @push_ops, $op_lua, $op_push_undef_key, $op_bail_key;
                    next RESULT_DESCRIPTOR;
                } ## end if ( $result_descriptor eq 'rule' )
                if (   $result_descriptor eq 'values'
                    or $result_descriptor eq 'value' )
                {
                    if ( defined $lexeme_id ) {
                        push @push_ops, $op_lua, $op_push_values_key, 1;
                        next RESULT_DESCRIPTOR;
                    }
                    if ($is_sequence_rule) {
                        push @push_ops, $op_lua, $op_push_values_key,
                          ( $is_discard_sequence_rule ? 2 : 1 );
                        next RESULT_DESCRIPTOR;
                    } ## end if ($is_sequence_rule)

                    my ($mask) = $slg->call_by_tag(
                    ( '@' . __FILE__ . ':' . __LINE__ ),
                    <<'END_OF_LUA', 'i>0', $irlid );
                        local slg, irlid = ...
                        return slg.g1.irls[irlid].mask
END_OF_LUA

                    if ( $rule_length > 0 ) {
                        push @push_ops, map {
                            $mask->[$_]
                              ? ( $op_lua, $op_push_one_key, $_ )
                              : ()
                        } 0 .. $rule_length - 1;
                    }
                    next RESULT_DESCRIPTOR;
                } ## end if ( $result_descriptor eq 'values' or ...)
                Marpa::R3::exception(
                    qq{Unknown result descriptor: "$result_descriptor"\n},
                    qq{  The full semantics were "$semantics"}
                );
            } ## end RESULT_DESCRIPTOR: for my $result_descriptor ( split /[,]\s*/xms, ...)
            @ops = ( @push_ops, @bless_ops, @array_fate );

        } ## end SET_OPS:

        if ( defined $irlid ) {
            push @registrations, [ 'rule', $irlid, @ops ];
        }

        if ( defined $nulling_symbol_id ) {

            push @registrations, [ 'nulling', $nulling_symbol_id, @ops ];
        } ## end if ( defined $nulling_symbol_id )

        if ( defined $lexeme_id ) {
            push @registrations, [ 'token', $lexeme_id, @ops ];
        }

    } ## end WORK_ITEM: for my $work_item (@work_list)

  SLR_NULLING_GRAMMAR_HACK: {

        # A hack for nulling SLR grammars --
        # the nulling semantics of the start symbol should
        # be those of the symbol on the
        # RHS of the start rule --
        # so copy them.

        my $start_symbol_id = $slg->g1_symbol_by_name('[:start:]');

        my ($symbol_is_nullable) =
          $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
            <<'END_OF_LUA', 'i>*', $start_symbol_id );
    local grammar, irlid = ...
    local g1g = grammar.g1
    return (g1g:symbol_is_nullable(irlid) and 1 or 0)
END_OF_LUA

        last SLR_NULLING_GRAMMAR_HACK if not $symbol_is_nullable;

        my $start_rhs_symbol_id;
      RULE: for (my $iter = $slg->g1_rule_ids_gen(); defined ( my $irlid = $iter->());) {
            my ( $lhs, $rhs0 ) = $slg->g1_rule_expand($irlid);
            if ( $start_symbol_id == $lhs ) {
                $start_rhs_symbol_id = $rhs0;
                last RULE;
            }
        }

      REGISTRATION: for my $registration (@registrations) {
            my ( $type, $nulling_symbol_id ) = @{$registration};
            if ( $nulling_symbol_id == $start_rhs_symbol_id ) {
                my ( undef, undef, @ops ) = @{$registration};
                push @registrations, [ 'nulling', $start_symbol_id, @ops ];
                $nulling_closures[$start_symbol_id] =
                  $nulling_closures[$start_rhs_symbol_id];
                last REGISTRATION;
            } ## end if ( $nulling_symbol_id == $start_rhs_symbol_id )
        } ## end REGISTRATION: for my $registration (@registrations)
    } ## end SLR_NULLING_GRAMMAR_HACK:

    $slg->[Marpa::R3::Internal_G::CLOSURE_BY_SYMBOL_ID] =
      \@nulling_closures;
    $slg->[Marpa::R3::Internal_G::CLOSURE_BY_RULE_ID] =
      \@closure_by_irlid;

    return \@registrations;

}

sub resolve_grammar {

    my ($slg) = @_;

    my $trace_actions =
      $slg->[Marpa::R3::Internal_G::TRACE_ACTIONS] // 0;
    my $trace_file_handle =
      $slg->[Marpa::R3::Internal_G::TRACE_FILE_HANDLE];

    my $resolve_error;

    my $default_action_resolution =
      resolve_action( $slg, undef, \$resolve_error );
    Marpa::R3::exception( "Could not resolve default action\n",
        q{  }, ( $resolve_error // 'Failed to resolve action' ) )
      if not $default_action_resolution;

    my $rule_resolutions = [];

  RULE_ID: for (my $iter = $slg->g1_rule_ids_gen(); defined ( my $irlid = $iter->());) {

        my $rule_resolution = resolve_rule_by_id( $slg, $irlid );
        $rule_resolution //= $default_action_resolution;

        if ( not $rule_resolution ) {
            my $rule_desc = $slg->g1_rule_show($irlid);

            my ($action) =
              $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
                <<'END_OF_LUA', 'is>*', $irlid );
    local slg, irl_id, rule_desc = ...
    local action = slg.g1.irls[irl_id].action
    local message = string.format(
        "Could not resolve action\n  Rule was %s\n",
        rule_desc)
    if action then
        message = message ..
           string.format("  Action was specified as %q\n", action)
    end
    error(message)
END_OF_LUA

        } ## end if ( not $rule_resolution )

      DETERMINE_BLESSING: {

            my $blessing = rule_blessing_find( $slg, $irlid );
            my ( $closure_name, $closure, $semantics ) = @{$rule_resolution};

            if ( $blessing ne '::undef' ) {
                $semantics = '::array' if $semantics eq '::!default';
              CHECK_SEMANTICS: {
                    last CHECK_SEMANTICS if $semantics eq '::array';
                    last CHECK_SEMANTICS
                      if ( substr $semantics, 0, 1 ) eq '[';
                    Marpa::R3::exception(
qq{Attempt to bless, but improper semantics: "$semantics"\n},
                        qq{  Blessing: "$blessing"\n},
                        '  Rule: ',
                        $slg->g1_rule_show($irlid)
                    );
                } ## end CHECK_SEMANTICS:
            } ## end if ( $blessing ne '::undef' )

            $rule_resolution =
              [ $closure_name, $closure, $semantics, $blessing ];
        } ## end DETERMINE_BLESSING:

        $rule_resolutions->[$irlid] = $rule_resolution;

    }

    if ( $trace_actions >= 2 ) {

        my ($highest_irlid) =
          $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
            <<'END_OF_LUA', '>*' );
    local grammar = ...
    local g1g = grammar.g1
    return g1g:highest_rule_id()
END_OF_LUA

      RULE: for my $rule_id ( 0 .. $highest_irlid ) {
            my ( $resolution_name, $closure ) =
              @{ $rule_resolutions->[$rule_id] };
            say {$trace_file_handle} 'Rule ',
              $slg->g1_rule_show($rule_id),
              qq{ resolves to "$resolution_name"}
              or Marpa::R3::exception('print to trace handle failed');
        }
    }

    my @lexeme_resolutions = ();

    my ($highest_symbol_id) =
      $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', '>*' );
    local grammar = ...
    local g1g = grammar.g1
    return g1g:highest_symbol_id()
END_OF_LUA

  SYMBOL: for my $lexeme_id ( 0 .. $highest_symbol_id ) {

        my $semantics = lexeme_semantics_find( $slg, $lexeme_id );
        if ( not defined $semantics ) {
            my $message =
                "Could not determine lexeme's semantics\n"
              . q{  Lexeme was }
              . $slg->g1_symbol_display($lexeme_id) . "\n";
            Marpa::R3::exception($message);
        } ## end if ( not defined $semantics )
        my $blessing = lexeme_blessing_find( $slg, $lexeme_id );
        if ( not defined $blessing ) {
            my $message =
                "Could not determine lexeme's blessing\n"
              . q{  Lexeme was }
              . $slg->g1_symbol_display($lexeme_id) . "\n";
            Marpa::R3::exception($message);
        } ## end if ( not defined $blessing )
        $lexeme_resolutions[$lexeme_id] = [ $semantics, $blessing ];

    }

    return ( $rule_resolutions, \@lexeme_resolutions );
}

# Given the grammar and an action name, resolve it to a closure,
# or return undef
sub resolve_action {
    my ( $slg, $closure_name, $p_error ) = @_;
    my $trace_file_handle =
      $slg->[Marpa::R3::Internal_G::TRACE_FILE_HANDLE];
    my $trace_actions = $slg->[Marpa::R3::Internal_G::TRACE_ACTIONS];

    # A reserved closure name;
    return [ q{}, undef, '::!default' ] if not defined $closure_name;

    if ( $closure_name eq q{} ) {
        ${$p_error} = q{The action string cannot be the empty string}
          if defined $p_error;
        return;
    }

    return [ q{}, \undef, $closure_name ] if $closure_name eq '::undef';
    if (   substr( $closure_name, 0, 2 ) eq q{::}
        or substr( $closure_name, 0, 1 ) eq '[' )
    {
        return [ q{}, undef, $closure_name ];
    }

    my $fully_qualified_name;
    if ( $closure_name =~ /([:][:])|[']/xms ) {
        $fully_qualified_name = $closure_name;
    }

    if ( not $fully_qualified_name ) {
        my $resolve_package =
          $slg->[Marpa::R3::Internal_G::SEMANTICS_PACKAGE];
        if ( not defined $resolve_package ) {
            ${$p_error} = Marpa::R3::Internal::X->new(
                {
                    message =>
qq{Could not fully qualify "$closure_name": no semantics package},
                    name => 'NO RESOLVE PACKAGE'
                }
            );
            return;
        } ## end if ( not defined $resolve_package )
        $fully_qualified_name = $resolve_package . q{::} . $closure_name;
    } ## end if ( not $fully_qualified_name )

    my $closure;
    my $type;
  TYPE: {
        no strict 'refs';
        $closure = *{$fully_qualified_name}{'CODE'};
        use strict;
        if ( defined $closure ) {
            $type = 'CODE';
            last TYPE;
        }
        no strict 'refs';
        $closure = *{$fully_qualified_name}{'SCALAR'};
        use strict;

        # Currently $closure is always defined, but this
        # behavior is said to be subject to change in perlref
        if ( defined $closure and defined ${$closure} ) {
            $type = 'SCALAR';
            Marpa::R3::exception(
                "$closure_name resolves to SCALAR, which is not yet implemented"
            );
            last TYPE;
        }

        $closure = undef;
    } ## end TYPE:

    if ( defined $closure ) {
        if ($trace_actions) {
            print {$trace_file_handle}
              qq{Successful resolution of action "$closure_name" as $type },
              'to ', $fully_qualified_name, "\n"
              or Marpa::R3::exception('Could not print to trace file');
        } ## end if ($trace_actions)
        return [ $fully_qualified_name, $closure, '::array' ];
    } ## end if ( defined $closure )

    if ( $trace_actions or defined $p_error ) {
        for my $slot (qw(ARRAY HASH IO FORMAT)) {
            no strict 'refs';
            if ( defined *{$fully_qualified_name}{$slot} ) {
                my $error =
qq{Failed resolution of action "$closure_name" to $fully_qualified_name\n}
                  . qq{  $fully_qualified_name is present as a $slot, but a $slot is not an acceptable resolution\n};
                if ($trace_actions) {
                    print {$trace_file_handle} $error
                      or Marpa::R3::exception('Could not print to trace file');
                }
                ${$p_error} = $error if defined $p_error;
                return;
            } ## end if ( defined *{$fully_qualified_name}{$slot} )
        } ## end for my $slot (qw(ARRAY HASH IO FORMAT))
    } ## end if ( $trace_actions or defined $p_error )

    {
        my $error =
qq{Failed resolution of action "$closure_name" to $fully_qualified_name\n};
        ${$p_error} = $error if defined $p_error;
        if ($trace_actions) {
            print {$trace_file_handle} $error
              or Marpa::R3::exception('Could not print to trace file');
        }
    }
    return;

}

sub resolve_rule_by_id {
    my ( $slg, $irlid ) = @_;

        my ($action_name) =
          $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
            <<'END_OF_LUA', 'i>*', $irlid );
    local slg, irl_id = ...
    return slg.g1.irls[irl_id].action
END_OF_LUA

    my $resolve_error;
    return if not defined $action_name;
    my $resolution = resolve_action( $slg, $action_name, \$resolve_error );

    if ( not $resolution ) {
        my $rule_desc = $slg->g1_rule_show($irlid);
        Marpa::R3::exception(
            "Could not resolve rule action named '$action_name'\n",
            "  Rule was $rule_desc\n",
            q{  },
            ( $resolve_error // 'Failed to resolve action' )
        );
    } ## end if ( not $resolution )
    return $resolution;
} ## end sub resolve_rule_by_id

# Find the blessing for a rule.
sub rule_blessing_find {
    my ( $slg, $irlid ) = @_;
    my ($blessing) =
      $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 'i', $irlid);
        local slg, irlid = ...
        local irl = slg.g1.irls[irlid]
        local blessing = '::undef'
        local xpr = irl.xpr
        if xpr then
            blessing = xpr.bless or '::undef'
        end
        return blessing
END_OF_LUA
    return $blessing;
}

# Find the semantics for a lexeme.
sub lexeme_semantics_find {
    my ( $slg, $lexeme_id ) = @_;

        my ($semantics) =
          $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
            <<'END_OF_LUA', 'i>*', $lexeme_id);
    local slg, isyid = ...
    local xsy = slg.g1.xsys[isyid]
    if not xsy then return '::!default' end
    local semantics = xsy.lexeme_semantics
    return semantics or '::!default'
END_OF_LUA

    return $semantics;
}

# Find the blessing for a lexeme.
sub lexeme_blessing_find {
    my ( $slg, $lexeme_id ) = @_;

    my ($result) = $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 'i', $lexeme_id );
      local slg, isyid = ...
      local xsy = slg.g1.xsys[isyid]
      if not xsy then return '::undef' end
      local blessing = xsy.blessing
      return blessing or '::undef'
END_OF_LUA

    return $result;
}

sub op_fn_key_by_name {
    my ( $slg, $name ) = @_;
    my ($key) = $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 's', $name );
      local recce, name = ...
      return _M.get_op_fn_key_by_name(name)
END_OF_LUA

    return $key;
}

sub op_fn_name_by_key {
    my ( $slg, $key ) = @_;
    my ($name) = $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 'i', $key );
      local recce, key = ...
      return _M.get_op_fn_name_by_key(key)
END_OF_LUA

    return $name;
}

sub registrations_set {
    my ( $slg, $registrations ) = @_;
    my $trace_file_handle =
      $slg->[Marpa::R3::Internal_G::TRACE_FILE_HANDLE];
    my $trace_actions =
      $slg->[Marpa::R3::Internal_G::TRACE_ACTIONS] // 0;

  REGISTRATION: for my $registration ( @{$registrations} ) {
        my ( $type, $id, @raw_ops ) = @{$registration};
        my @ops = ();
      PRINT_TRACES: {
            last PRINT_TRACES if $trace_actions <= 2;
            if ( $type eq 'nulling' ) {
                say {$trace_file_handle}
                  "Registering semantics for nulling symbol: ",
                  $slg->g1_symbol_display($id),
                  "\n", '  Semantics are ', $slg->show_semantics(@raw_ops)
                  or Marpa::R3::exception('Cannot say to trace file handle');
                last PRINT_TRACES;
            } ## end if ( $type eq 'nulling' )
            if ( $type eq 'rule' ) {
                say {$trace_file_handle}
                  "Registering semantics for $type: ",
                  $slg->g1_rule_show($id),
                  '  Semantics are ', $slg->show_semantics(@raw_ops)
                  or Marpa::R3::exception('Cannot say to trace file handle');
                last PRINT_TRACES;
            }
            if ( $type eq 'token' ) {
                say {$trace_file_handle}
                  "Registering semantics for $type: ",
                  $slg->g1_symbol_display($id),
                  "\n", '  Semantics are ', $slg->show_semantics(@raw_ops)
                  or Marpa::R3::exception('Cannot say to trace file handle');
                last PRINT_TRACES;
            }
            say {$trace_file_handle} "Registration has unknown type: $type"
              or Marpa::R3::exception('Cannot say to trace file handle');
        } ## end PRINT_TRACES:

      OP: for my $raw_op (@raw_ops) {
            if ( ref $raw_op ) {

                my $constants = $slg->[Marpa::R3::Internal_G::CONSTANTS];
                my $next_ix = scalar @{$constants};
                push @ops, $next_ix;
                $slg->[Marpa::R3::Internal_G::CONSTANTS]->[$next_ix]
                    = ${$raw_op};
                next OP;
            }
            push @ops, $raw_op;
        } ## end OP: for my $raw_op (@raw_ops)

        my ($constant_ix) = $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
            << 'END_OF_LUA', 'sii', $type, $id, \@ops );
                local grammar, type, id, ops = ...
                if type == 'token' then
                    grammar.token_semantics[id] = ops
                elseif type == 'nulling' then
                    grammar.nulling_semantics[id] = ops
                elseif type == 'rule' then
                    grammar.rule_semantics[id] = ops
                end
END_OF_LUA

        next REGISTRATION;

        # Marpa::R3::exception(
            # 'Registration: with unknown type: ',
            # Data::Dumper::Dumper($registration)
        # );

    } ## end REGISTRATION: for my $registration ( @{ $recce->[...]})
}

1;

# vim: expandtab shiftwidth=4:
