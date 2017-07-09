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

package Marpa::R3::Scanless::G;

use 5.010001;
use strict;
use warnings;

use vars qw($VERSION $STRING_VERSION);
$VERSION        = '4.001_047';
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
    $pre_slg->[Marpa::R3::Internal::Scanless::G::TRACE_FILE_HANDLE] = \*STDERR;
    $pre_slg->[Marpa::R3::Internal::Scanless::G::CONSTANTS] = [];

    my $lua = Marpa::R3::Lua->new();
    $pre_slg->[Marpa::R3::Internal::Scanless::G::L] = $lua;

    my ($regix) = $lua->call_by_tag (-1,
        ('@' .__FILE__ . ':' .  __LINE__),
       <<'END_OF_LUA', '');
        local slg = {}
        local registry = debug.getregistry()
        setmetatable(slg, _M.class_slg)
        local regix = _M.register(registry, slg)

        slg.exhaustion_action = 'fatal'
        slg.rejection_action = 'fatal'

        slg.nulling_semantics = {}
        slg.rule_semantics = {}
        slg.token_semantics = {}

        -- The codepoint data is populated, as needed, by the recognizers but,
        -- once populated, depends only on the codepoint and the
        -- grammar.
        slg.per_codepoint = {}

        slg.ranking_method = 'none'
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

# The object, in computing the hash, is to get as much
# precomputation in as possible, without using undue space.
# That means CPU-intensive processing should tend to be done
# before or during hash creation, and space-intensive processing
# should tend to be done here, in the code that converts the
# hash to its runtime equivalent.
sub Marpa::R3::Internal::Scanless::G::hash_to_runtime {
    my ( $slg, $hashed_source, $g1_args ) = @_;

    my $trace_fh = $slg->[Marpa::R3::Internal::Scanless::G::TRACE_FILE_HANDLE];
    # Pre-lexer G1 processing

    $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 's', $hashed_source );
        local slg, source_hash = ...
        slg.g1 = _M.grammar_new(slg)
        slg.l0 = _M.grammar_new(slg)
        slg:xsys_populate( source_hash)
        slg:xrls_populate(source_hash)
        slg:xprs_populate(source_hash)
END_OF_LUA

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
        local g1g = grammar.g1
        g1g.start_name = '[:start:]'
END_OF_LUA

    for my $symbol ( sort keys %{ $hashed_source->{symbols}->{g1} } ) {
        assign_G1_symbol( $slg, $symbol,
            $hashed_source->{symbols}->{g1}->{$symbol} );
    }

    add_G1_user_rules( $slg, $hashed_source->{rules}->{g1} );

    my @bad_arguments = keys %{$g1_args};
    if ( scalar @bad_arguments ) {
        Marpa::R3::exception(
            q{Internal error: Bad named argument(s) to hash_to_runtime() method}
              . join q{ },
            @bad_arguments
        );
    }

    my $completion_events_by_name = $hashed_source->{completion_events};
    my $nulled_events_by_name = $hashed_source->{nulled_events};

    $slg->call_by_tag(
        ('@' .__FILE__ . ':' .  __LINE__),
        <<'END_OF_LUA', 's', $hashed_source );
        local slg, hashed_source = ...
        local g1g = slg.g1

        local function event_setup(g1g, events, set_fn, activate_fn)
            local event_by_isy = {}
            local event_by_name = {}
            for isy_name, event in pairs(events) do
                local event_name = event[1]
                local is_active = (event[2] ~= "0")
                local isyid = g1g.isyid_by_name[isy_name]
                if not isyid then
                    error(string.format(
                        "Event defined for non-existent symbol: %s\n",
                        isy_name
                    ))
                end
                local event_desc = {
                   name = event_name,
                   isyid = isyid
                }
                event_by_isy[isyid] = event_desc
                event_by_isy[isy_name] = event_desc
                local name_entry = event_by_name[event_name]
                if not name_entry then
                    event_by_name[event_name] = { event_desc }
                else
                    name_entry[#name_entry+1] = event_desc
                end


                --  NOT serializable
                --  Must be done before precomputation
                set_fn(g1g, isyid, 1)
                if not is_active then activate_fn(g1g, isyid, 0) end
            end
        return event_by_isy, event_by_name
        end

        slg.completion_event_by_isy, slg.completion_event_by_name
            = event_setup(g1g,
                (hashed_source.completion_events or {}),
                g1g.symbol_is_completion_event_set,
                g1g.completion_symbol_activate
            )

        slg.nulled_event_by_isy, slg.nulled_event_by_name
            = event_setup(g1g,
                (hashed_source.nulled_events or {}),
                g1g.symbol_is_nulled_event_set,
                g1g.nulled_symbol_activate
            )

        slg.prediction_event_by_isy, slg.prediction_event_by_name
            = event_setup(g1g,
                (hashed_source.prediction_events or {}),
                g1g.symbol_is_prediction_event_set,
                g1g.prediction_symbol_activate
            )

END_OF_LUA

    my $precompute_error =
      Marpa::R3::Internal::Scanless::G::precompute( $slg, 'g1' );
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
  SYMBOL: for my $symbol_id ( $slg->g1_symbol_ids() ) {

        my ($is_lexeme) =
          $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
            <<'END_OF_LUA', 'i', $symbol_id );
        local slg, g1_isyid = ...
        local g1g = slg.g1
        local is_terminal = 0 ~= g1g:symbol_is_terminal(g1_isyid)
        local is_lexeme

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

                 return true
             end
             return true
        end

        return
END_OF_LUA

        # Not a lexeme, according to G1
        next SYMBOL if not $is_lexeme;

        my $symbol_name = $slg->g1_symbol_name($symbol_id);
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
    state $lex_start_symbol_name = '[:lex_start:]';
    state $discard_symbol_name   = '[:discard:]';

    my $lexer_rules          = $hashed_source->{rules}->{'l0'};
    my $character_class_hash = $hashed_source->{character_classes};
    my $lexer_symbols        = $hashed_source->{symbols}->{'l0'};

    # If no lexer rules, fake a lexer
    # Fake a lexer -- it discards symbols in character classes which
    # never matches
    if ( not scalar @{$lexer_rules} ) {
        $character_class_hash = { '[[^\\d\\D]]' => [ '[^\\d\\D]', '' ] };
        $lexer_rules = [
            {
                'rhs'             => ['[[^\\d\\D]]'],
                'lhs'             => '[:discard:]',
                'symbol_as_event' => '[^\\d\\D]',

                # 'description' => 'Discard rule for <[[^\\d\\D]]>'
            },
        ];
        $lexer_symbols = {
            '[:discard:]' => {

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

    my @lex_lexeme_names = 
      grep { not $lex_rhs{$_} and not $lex_separator{$_} }
      sort keys %lex_lhs;

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
    } @lex_lexeme_names;

    $slg->call_by_tag(
        ('@' .__FILE__ . ':' .  __LINE__),
        <<'END_OF_LUA', 's', $lex_start_symbol_name);
        local grammar, start_name = ...
        local l0g = grammar.l0
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
    $lex_lexeme_to_g1_symbol[$_] = -1 for $slg->g1_symbol_ids();

  LEXEME_NAME: for my $lexeme_name (@lex_lexeme_names) {
        next LEXEME_NAME if $lexeme_name eq $discard_symbol_name;
        next LEXEME_NAME if $lexeme_name eq $lex_start_symbol_name;
        my $g1_symbol_id = $g1_id_by_lexeme_name{$lexeme_name};
        if ( not defined $g1_symbol_id ) {
            Marpa::R3::exception(
                "A lexeme in L0 is not a lexeme in G1: $lexeme_name");
        }
        if ( not $slg->g1_symbol_is_accessible($g1_symbol_id) ) {
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

    my $lex_precompute_error =
      Marpa::R3::Internal::Scanless::G::precompute( $slg, 'l0' );
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

    my $default_discard_event = $discard_default_adverbs->{event};
  RULE_ID: for my $irlid ( $slg->l0_rule_ids() ) {

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

            if ($cmd eq 'ok') {
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

    for my $lexeme_name ( keys %g1_id_by_lexeme_name ) {
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
            -- Check for lexeme declarations of
            -- symbols that are, in fact, not actually lexemes
            if declarations then
                _M.userX(
                    "Symbol <%s> is declared as a lexeme, \z
                    but it is not used as one.\n",
                    lexeme_name
                )
            end
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

    $slg->[Marpa::R3::Internal::Scanless::G::CHARACTER_CLASS_TABLE] =
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
        for my $xsyid ( $slg->symbol_ids() ) {

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

            if ( $blessing !~ / :: /xms ) {
                my $bless_package =
                  $slg->[Marpa::R3::Internal::Scanless::G::BLESS_PACKAGE];
                if ( not defined $bless_package ) {
                    my $lexeme_name = $slg->g1_symbol_name($g1_lexeme_id);
                    Marpa::R3::exception(
qq{Symbol "$lexeme_name" needs a blessing package, but grammar has none\n},
                        qq{  The blessing for "$lexeme_name" was "$blessing"\n}
                    );
                } ## end if ( not defined $bless_package )
                $blessing = $bless_package . q{::} . $blessing;
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

    my $registrations = Marpa::R3::Internal::Value::registrations_find($slg );
    Marpa::R3::Internal::Value::registrations_set($slg, $registrations );

    return $slg;

} ## end sub Marpa::R3::Internal::Scanless::G::hash_to_runtime

sub Marpa::R3::Internal::Scanless::G::precompute {
    my ($slg, $subg_name ) = @_;

    my $trace_fh =
        $slg->[Marpa::R3::Internal::Scanless::G::TRACE_FILE_HANDLE];

    my ($do_return, $precompute_result, $precompute_error_code)
      = $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 's', $subg_name );
    local grammar, subg_name = ...
    local lmw_g = grammar[subg_name].lmw_g
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
    _M.throw = false
    local result, error = lmw_g:precompute()
    _M.throw = true
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
        <<'END_OF_LUA', 'si', $subg_name, $precompute_error_code );
    local grammar, subg_name, error_code = ...
    local lmw_g = grammar[subg_name].lmw_g
    if error_code == _M.err["NO_RULES"] then
        _M.userX('Attempted to precompute grammar with no rules')
    end
    if error_code == _M.err["NULLING_TERMINAL"] then
        local msgs = {}
        local events = lmw_g:events()
        for i = 1, #events, 2 do
            local event_type = events[i]
            if event_type == _M.event["NULLING_TERMINAL"] then
                msgs[#msgs+1] =
                   string.format("Nullable symbol %q is also a terminal\n",
                       lmw_g:symbol_name(events[i+1])
                   )
            end
        end
        msgs[#msgs+1] = 'A terminal symbol cannot also be a nulling symbol'
        _M.userX( '%s', table.concat(msgs) )
    end
    if error_code == _M.err["COUNTED_NULLABLE"] then
        local msgs = {}
        local events = lmw_g:events()
        for i = 1, #events, 2 do
            local event_type = events[i]
            if event_type == _M.event["COUNTED_NULLABLE"] then
                msgs[#msgs+1] =
                   string.format("Nullable symbol %q is on RHS of counted rule\n",
                       lmw_g:symbol_name(events[i+1])
                   )
            end
        end
        msgs[#msgs+1] = 'Counted nullables confuse Marpa -- please rewrite the grammar\n'
        _M.userX( '%s', table.concat(msgs) )
    end
    if error_code == _M.err["START_NOT_LHS"] then
        _M.userX( "Start symbol %s not on LHS of any rule",
            lmw_g.start_name);
    end
    if error_code == _M.err["NO_START_SYMBOL"] then
            _M.userX('No start symbol')
    end
    if error_code ~= _M.err["UNPRODUCTIVE_START"] then
            _M.userX( '%s', lmw_g:error_description() )
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
        <<'END_OF_LUA', 's', $subg_name );
        local grammar, subg_name = ...
        local loop_rule_count = 0
        local lmw_g = grammar[subg_name].lmw_g
        local events = lmw_g:events()
        for i = 1, #events, 2 do
            local event_type = events[i]
            if event_type == _M.event["LOOP_RULES"] then
                error(string.format(
                   "Unknown grammar precomputation event; type=%q"))
            end
            loop_rule_count = events[i+1]
        end
        return loop_rule_count
END_OF_LUA

    if ($loop_rule_count) {
      RULE:
        for my $rule_id ( $slg->lmg_rule_ids($subg_name) ) {
            my ($rule_is_loop) =
              $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
                <<'END_OF_LUA', 'si', $subg_name, $rule_id );
        local grammar, subg_name, rule_id = ...
        local lmw_g = grammar[subg_name].lmw_g
        return lmw_g:rule_is_loop(rule_id)
END_OF_LUA

            next RULE unless $rule_is_loop;
            print {$trace_fh} 'Cycle found involving rule: ',
              $slg->lmg_rule_show( $subg_name, $rule_id ), "\n"
              or Marpa::R3::exception("Could not print: $ERRNO");
        } ## end for my $rule_id (@loop_rules)
        Marpa::R3::exception('Cycles in grammar, fatal error');
    }

    my $default_if_inaccessible =
        $slg->[Marpa::R3::Internal::Scanless::G::IF_INACCESSIBLE]
        // 'warn';
    SYMBOL:
    for my $isyid ( $slg->lmg_symbol_ids($subg_name))
    {
        # Inaccessible internal symbols may be created
        # from inaccessible use symbols -- ignore these.
        # This assumes that Marpa's logic
        # is correct and that
        # it is not creating inaccessible symbols from
        # accessible ones.

        my ($cmd, $treatment) = $slg->call_by_tag(
        ('@' .__FILE__ . ':' .  __LINE__),
        <<'END_OF_LUA', 'sis', $subg_name, $isyid, $default_if_inaccessible);
        local slg, subg_name, isyid, default_treatment = ...
        local lmw_g = slg[subg_name].lmw_g
        local is_accessible = lmw_g:symbol_is_accessible(isyid) ~= 0
        if is_accessible then
            return 'next symbol', default_treatment
        end
        local xsy = slg[subg_name].xsys[isyid]
        if not xsy then
            return 'next symbol', default_treatment
        end
        local treatment = xsy.if_inaccessible or default_treatment
        if treatment == 'ok' then
            return 'next symbol', treatment
        end
        return 'ok', treatment
END_OF_LUA

        next SYMBOL if $cmd ne 'ok';

        my $symbol_name = $slg->lmg_symbol_name($subg_name, $isyid);
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
    my ($symbol_id) =
      $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 'ss', $name, $options );
    local slg, symbol_name, options = ...
    return slg:g1_symbol_assign(symbol_name, options)
END_OF_LUA
    return $symbol_id;
}

sub assign_L0_symbol {
    my ( $slg, $name, $options ) = @_;
    my ($symbol_id) =
      $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 'ss', $name, $options );
    local slg, symbol_name, options = ...
    return slg:l0_symbol_assign(symbol_name, options)
END_OF_LUA
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

# For diagnostics, describe a rule we were unable to create,
# and for which we have only the symbol names
sub proto_rule_describe {
    my ( $lhs_name, $rhs_names ) = @_;
    # wrap symbol names with whitespaces allowed by SLIF
    $lhs_name = "<$lhs_name>" if $lhs_name =~ / /;
    return "$lhs_name -> " . ( join q{ }, map { / / ? "<$_>" : $_ } @{$rhs_names} );
}

sub add_G1_user_rule {
    my ( $slg, $options ) = @_;

    my ( $lhs_name, $rhs_names, $action, $blessing );
    my ( $min, $separator_name );
    my $rank;
    my $null_ranking;
    my $proper_separation = 0;
    my $xpr_name;
    my $xpr_id;
    my $subgrammar;
    my $xpr_dot;

  OPTION: for my $option ( keys %{$options} ) {
        my $value = $options->{$option};
        if ( $option eq 'xprid' ) {
            $xpr_name = $value;
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
        if ( $option eq 'subgrammar' ) { $subgrammar      = $value; next OPTION }
        if ( $option eq 'xpr_dot' ) { $xpr_dot      = $value; next OPTION }
        Marpa::R3::exception("Unknown user rule option: $option");
    } ## end OPTION: for my $option ( keys %{$options} )


    $rhs_names //= [];

    my $default_rank;
    ($default_rank, $xpr_id) =
          $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
          <<'END_OF_LUA', 's', $xpr_name);
    local grammar, xpr_name = ...
    local default_rank = grammar.g1:default_rank()
    local xpr_id = grammar.xprs[xpr_name].id
    return default_rank, xpr_id
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

    my $base_irl_id;
    my $separator_id = -1;

    if ($is_ordinary_rule) {

        ($base_irl_id) =
          $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
            <<'END_OF_LUA', 'i', [ $lhs_id, @rhs_ids ] );
    local g, rule  = ...
    -- remove the test for nil or less than zero
    -- once refactoring is complete?
    _M.throw = false
    local base_irl_id = g.g1:rule_new(rule)
    _M.throw = true
    if not base_irl_id or base_irl_id < 0 then return -1 end
    g.g1.irls[base_irl_id] = { id = base_irl_id }
    return base_irl_id
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

      ($base_irl_id) =
      $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 'i', $arg_hash);
    local g, arg_hash = ...
    arg_hash.proper = (arg_hash.proper ~= 0)
    _M.throw = false
    local base_irl_id = g.g1:sequence_new(arg_hash)
    _M.throw = true
    -- remove the test for nil or less than zero
    -- once refactoring is complete?
    if not base_irl_id or base_irl_id < 0 then return end

    local g1_rule = setmetatable({}, _M.class_irl)
    g1_rule.id = base_irl_id
    g.g1.irls[base_irl_id] = g1_rule
    return base_irl_id
END_OF_LUA

    }

    if ( not defined $base_irl_id or $base_irl_id < 0 ) {
        my $rule_description = proto_rule_describe( $lhs_name, $rhs_names );
        my ($ok, $problem) =
        $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
            <<'END_OF_LUA', 's', $rule_description );
            local grammar, rule_description = ...
            local g1g = grammar.g1
            local error_code = g1g:error_code()
            local problem_description
            if error_code == _M.err.DUPLICATE_RULE then
                problem_description = "Duplicate rule"
            else
                problem_description = _M.err[error_code].description
            end
            return "abend", (problem_description .. ': ' .. rule_description)
END_OF_LUA

        Marpa::R3::exception($problem) if $ok ne 'fail'
    }

      $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 'iiii',
        local slg, irl_id, ranking_is_high, rank, xpr_id = ...
        local g1g = slg.g1
        g1g:rule_null_high_set(irl_id, ranking_is_high)
        g1g:rule_rank_set(irl_id, rank)
        local xpr = slg.xprs[xpr_id]
        local irl = slg.g1.irls[irl_id]
        irl.xpr = xpr
        -- right now, the action & mask of an irl
        -- is always the action/mask of its xpr.
        -- But some day each irl may need its own.
        irl.action = xpr.action
        irl.mask = xpr.mask
END_OF_LUA
            $base_irl_id,
            ( $null_ranking eq 'high' ? 1 : 0 ),
            $rank, $xpr_id);

    return;

}

sub add_L0_user_rule {
    my ( $slg, $options ) = @_;

    my ( $lhs_name, $rhs_names, $action, $blessing );
    my ( $min, $separator_name );
    my $rank;
    my $null_ranking;
    my $proper_separation = 0;
    my $xpr_name;
    my $xpr_id;
    my $subgrammar;
    my $xpr_dot;

  OPTION: for my $option ( keys %{$options} ) {
        my $value = $options->{$option};
        if ( $option eq 'xprid' ) {
            $xpr_name = $value;
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
        if ( $option eq 'subgrammar' ) { $subgrammar = $value; next OPTION }
        if ( $option eq 'xpr_dot' )    { $xpr_dot    = $value; next OPTION }
        Marpa::R3::exception("Unknown user rule option: $option");
    }

    $rhs_names //= [];

    my $default_rank;
    ($default_rank, $xpr_id) =
          $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
          <<'END_OF_LUA', 's', ($xpr_name // ''));
    local slg, xpr_name = ...
    local default_rank = slg.l0:default_rank()
    -- io.stderr:write('xpr_name: ', inspect(xpr_name), '\n')
    local xpr_id = -1
    if #xpr_name > 0 then
        xpr_id = slg.xprs[xpr_name].id
    end
    return default_rank, xpr_id
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

    my $base_irl_id;
    my $separator_id = -1;

    if ($is_ordinary_rule) {

        ($base_irl_id) =
          $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
            <<'END_OF_LUA', 'i', [ $lhs_id, @rhs_ids ] );
    local g, rule  = ...
    -- remove the test for nil or less than zero
    -- once refactoring is complete?
    _M.throw = false
    local base_irl_id = g.l0:rule_new(rule)
    _M.throw = true
    if not base_irl_id or base_irl_id < 0 then return -1 end
    g.l0.irls[base_irl_id] = { id = base_irl_id }
    return base_irl_id
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

      ($base_irl_id) =
      $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 'i', $arg_hash);
    local g, arg_hash = ...
    arg_hash.proper = (arg_hash.proper ~= 0)
    _M.throw = false
    local base_irl_id = g.l0:sequence_new(arg_hash)
    _M.throw = true
    -- remove the test for nil or less than zero
    -- once refactoring is complete?
    if not base_irl_id or base_irl_id < 0 then return end
    local l0_rule = setmetatable({}, _M.class_irl)
    l0_rule.id = base_irl_id
    g.l0.irls[base_irl_id] = l0_rule
    return base_irl_id
END_OF_LUA

    }

    if ( not defined $base_irl_id or $base_irl_id < 0 ) {
        my $rule_description = proto_rule_describe( $lhs_name, $rhs_names );
        my ($ok, $problem) =
        $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
            <<'END_OF_LUA', 's', $rule_description );
            local slg, rule_description = ...
            local l0g = slg.l0
            local error_code = l0g:error_code()
            local problem_description
            if error_code == _M.err.DUPLICATE_RULE then
                problem_description = "Duplicate rule"
            else
                problem_description = _M.err[error_code].description
            end
            return "abend", (problem_description .. ': ' .. rule_description)
END_OF_LUA

        Marpa::R3::exception($problem) if $ok ne 'fail';
    }

      $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 'iiii',
        local slg, irl_id, ranking_is_high, rank, xpr_id = ...
        local l0g = slg.l0
        l0g:rule_null_high_set(irl_id, ranking_is_high)
        l0g:rule_rank_set(irl_id, rank)
        if xpr_id >= 0 then
            local xpr = slg.xprs[xpr_id]
            local irl = slg.l0.irls[irl_id]
            irl.xpr = xpr
            -- right now, the action & mask of an irl
            -- is always the action/mask of its xpr.
            -- But some day each irl may need its own.
            irl.action = xpr.action
            irl.mask = xpr.mask
        end
END_OF_LUA
            $base_irl_id, ( $null_ranking eq 'high' ? 1 : 0 ),
            $rank, $xpr_id);

    return;

}

sub Marpa::R3::Scanless::G::symbol_ids {
    my ($slg) = @_;
    return 1 .. $slg->highest_symbol_id();
}

our $kwgen_code_template = <<'END_OF_TEMPLATE';
END_OF_TEMPLATE

sub kwgen {
    my ($line, $perl_name, $kollos_name, $signature) = @_;
    my $tag = '@' . __FILE__ . ':' .  $line;
    my $code = sprintf( 'return _M.class_slg.%s(...)', $kollos_name );
    # my $code = sprintf( 'io.stderr:write("Calling slg.%s ", table.concat(..., "")); return _M.class_slg.%s(...)', $kollos_name, $kollos_name );
    no strict 'refs';
    *{ 'Marpa::R3::Scanless::G::' . $perl_name }
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
    *{ 'Marpa::R3::Scanless::G::' . $perl_name }
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
    *{ 'Marpa::R3::Scanless::G::' . $perl_name }
        = sub () {
            my ($slg, @args) = @_;
            $args[$_] //= $defaults[$_] for 0 .. $#defaults;
            my ($retour) = $slg->call_by_tag($tag, $code, $signature, @args);
            return $retour;
        };
    use strict;
}

# TODO: Census all uses of Marpa::R3::Scanless::G::g1_symbol_name
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

kwgen(__LINE__, qw(symbol_dsl_form symbol_dsl_form i));
kwgen(__LINE__, qw(lmg_symbol_dsl_form lmg_symbol_dsl_form si));
kwgen(__LINE__, qw(g1_symbol_dsl_form g1_symbol_dsl_form i));
kwgen(__LINE__, qw(l0_symbol_dsl_form l0_symbol_dsl_form i));

kwgen_opt(__LINE__, qw(symbols_show symbols_show i), 0);
kwgen_opt(__LINE__, qw(lmg_symbols_show lmg_symbols_show si), 0, 0);
kwgen_opt(__LINE__, qw(g1_symbols_show g1_symbols_show i), 0);
kwgen_opt(__LINE__, qw(l0_symbols_show l0_symbols_show i), 0);

kwgen(__LINE__, qw(lmg_symbol_by_name lmg_symbol_by_name si));
kwgen(__LINE__, qw(g1_symbol_by_name g1_symbol_by_name i));
kwgen(__LINE__, qw(l0_symbol_by_name l0_symbol_by_name i));

kwgen(__LINE__, qw(g1_symbol_is_accessible g1_symbol_is_accessible i));
kwgen(__LINE__, qw(g1_symbol_is_nulling g1_symbol_is_nulling i));
kwgen(__LINE__, qw(g1_symbol_is_productive g1_symbol_is_productive i));

kwgen(__LINE__, qw(lmg_dotted_rule_show lmg_dotted_rule_show sii));
kwgen(__LINE__, qw(g1_dotted_rule_show g1_dotted_rule_show ii));
kwgen(__LINE__, qw(l0_dotted_rule_show l0_dotted_rule_show ii));

kwgen(__LINE__, qw(production_show xpr_show i));
kwgen(__LINE__, qw(lmg_rule_show lmg_rule_show si));
kwgen(__LINE__, qw(g1_rule_show g1_rule_show i));
kwgen(__LINE__, qw(l0_rule_show l0_rule_show i));

kwgen(__LINE__, qw(lmg_rule_display lmg_rule_display si));
kwgen(__LINE__, qw(g1_rule_display g1_rule_display i));
kwgen(__LINE__, qw(l0_rule_display l0_rule_display i));

kwgen_opt(__LINE__, qw(productions_show xprs_show i), 0);
kwgen_opt(__LINE__, qw(lmg_rules_show lmg_rules_show si), 0, 0);
kwgen_opt(__LINE__, qw(g1_rules_show g1_rules_show i), 0);
kwgen_opt(__LINE__, qw(l0_rules_show l0_rules_show i), 0);

kwgen(__LINE__, qw(production_name xpr_name i));

kwgen(__LINE__, qw(lmg_rule_to_production_id lmg_rule_to_xprid si));
kwgen(__LINE__, qw(g1_rule_to_production_id g1_rule_to_xprid i));
kwgen(__LINE__, qw(l0_rule_to_production_id l0_rule_to_xprid i));

kwgen(__LINE__, qw(highest_production_id highest_xprid), '');

kwgen_arr(__LINE__, qw(production_expand xpr_expand i));
kwgen_arr(__LINE__, qw(lmg_rule_expand lmg_irl_isyids si));
kwgen_arr(__LINE__, qw(g1_rule_expand g1_irl_isyids i));
kwgen_arr(__LINE__, qw(l0_rule_expand l0_irl_isyids i));

sub Marpa::R3::Scanless::G::call_by_tag {
    my ( $slg, $tag, $codestr, $sig, @args ) = @_;
    my $lua = $slg->[Marpa::R3::Internal::Scanless::G::L];
    my $regix = $slg->[Marpa::R3::Internal::Scanless::G::REGIX];
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
sub Marpa::R3::Scanless::G::coro_by_tag {
    my ( $slg, $tag, $args, $codestr ) = @_;
    my $lua        = $slg->[Marpa::R3::Internal::Scanless::G::L];
    my $regix      = $slg->[Marpa::R3::Internal::Scanless::G::REGIX];
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

# TODO -- Document that I guarantee no gaps in
# the symbol/rule numbering
sub Marpa::R3::Scanless::G::lmg_symbol_ids {
    my ($slg, $subg_name) = @_;
    my ($highest_symbol_id) = $slg->call_by_tag(
    ('@' .__FILE__ . ':' . __LINE__),
    <<'END_OF_LUA', 's>*', $subg_name ) ;
    local grammar, subg_name = ...
    local lmw_g = grammar[subg_name].lmw_g
    return lmw_g:highest_symbol_id()
END_OF_LUA

    return 0 .. $highest_symbol_id;
}

sub Marpa::R3::Scanless::G::g1_symbol_ids {
    my ($slg) = @_;
    return $slg->lmg_symbol_ids('g1');
}

sub Marpa::R3::Scanless::G::l0_symbol_ids {
    my ($slg) = @_;
    return $slg->lmg_symbol_ids('l0');
}

sub Marpa::R3::Scanless::G::production_ids {
    my ($slg) = @_;
    my ($highest_xprid) = $slg->call_by_tag(
    ('@' .__FILE__ . ':' . __LINE__),
    <<'END_OF_LUA', '>*' ) ;
    local slg = ...
    return slg:highest_xprid()
END_OF_LUA
    return 1 .. $highest_xprid;
}

# Currently there are no gaps in the rule ids.
# TODO -- Will I guarantee this?
sub Marpa::R3::Scanless::G::lmg_rule_ids {
    my ($slg, $subg_name) = @_;
    my ($highest_rule_id) = $slg->call_by_tag(
    ('@' .__FILE__ . ':' . __LINE__),
    <<'END_OF_LUA', 's>*', $subg_name ) ;
    local grammar, subg_name = ...
    local lmw_g = grammar[subg_name].lmw_g
    return lmw_g:highest_rule_id()
END_OF_LUA

    return 0 .. $highest_rule_id;
}

sub Marpa::R3::Scanless::G::g1_rule_ids {
    my ($slg) = @_;
    return $slg->lmg_rule_ids('g1');
}

sub Marpa::R3::Scanless::G::l0_rule_ids {
    my ($slg) = @_;
    return $slg->lmg_rule_ids('l0');
}

# not to be documented
sub Marpa::R3::Scanless::G::show_nrls {
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
sub Marpa::R3::Scanless::G::show_nsys {
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
        pieces[#pieces+1] = g1g:show_nsy(nsy_id)
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
    local g1g = grammar.g1
    return g1g:show_ahms()
END_OF_LUA

    return $text;

} ## end sub show_ahms

# not to be documented
sub Marpa::R3::Scanless::G::dotted_nrl_show {
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
sub Marpa::R3::Scanless::G::show_briefer_ahm {
    my ( $slg, $item_id ) = @_;

    my ($text) = $slg->call_by_tag(
        ('@' . __FILE__ . ':' .  __LINE__),
        <<'END_OF_LUA', 'i', $item_id );
    local grammar, item_id = ...
    local g1g = grammar.g1
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
sub Marpa::R3::Scanless::G::brief_nrl {
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
sub Marpa::R3::Scanless::G::regix {
    my ( $slg ) = @_;
    my $regix = $slg->[Marpa::R3::Internal::Scanless::G::REGIX];
    return $regix;
}

1;

# vim: expandtab shiftwidth=4:
