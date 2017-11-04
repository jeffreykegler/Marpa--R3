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

package Marpa::R3::Value;

use 5.010001;
use warnings;
use strict;

use vars qw($VERSION $STRING_VERSION);
$VERSION        = '4.001_050';
$STRING_VERSION = $VERSION;
## no critic (BuiltinFunctions::ProhibitStringyEval)
$VERSION = eval $VERSION;
## use critic

package Marpa::R3::Internal::Value;

use English qw( -no_match_vars );

# Given the grammar and an action name, resolve it to a closure,
# or return undef
sub resolve_action {
    my ( $slg, $closure_name, $p_error ) = @_;
    my $trace_file_handle =
      $slg->[Marpa::R3::Internal::Scanless::G::TRACE_FILE_HANDLE];
    my $trace_actions = $slg->[Marpa::R3::Internal::Scanless::G::TRACE_ACTIONS];

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
          $slg->[Marpa::R3::Internal::Scanless::G::SEMANTICS_PACKAGE];
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

# Dump semantics for diagnostics
sub Marpa::R3::Scanless::R::show_semantics {
    my ( $slg, @ops ) = @_;
    my @op_descs = ();
    my $op_ix    = 0;
  OP: while ( $op_ix < scalar @ops ) {
        my $op = $ops[ $op_ix++ ];

        my $op_name = $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
            <<'END_OF_LUA', 'i', $op );
    local grammar, op = ...
    return _M.op_names[op]
END_OF_LUA

        push @op_descs, $op_name;
        if ( $op_name eq 'lua' ) {

            my ($lua_op_name) = op_fn_name_by_key( $slg, $ops[$op_ix] );
            push @op_descs, $lua_op_name;
            $op_ix++;
            if ( $lua_op_name eq 'callback' ) {
                push @op_descs, op_fn_name_by_key( $slg, $ops[$op_ix] );
            }
            else {
                push @op_descs, $ops[$op_ix];
            }
            $op_ix++;
            next OP;
        }
        if ( $op_name eq 'alternative' ) {
            push @op_descs, $ops[$op_ix];
            $op_ix++;
            push @op_descs, $ops[$op_ix];
            $op_ix++;
            next OP;
        } ## end if ( $op_name eq 'alternative' )
    } ## end OP: while ( $op_ix < scalar @ops )
    return join q{ }, @op_descs;
} ## end sub show_semantics

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

# Find the blessing for a rule.
sub rule_blessing_find {
    my ( $slg, $irlid ) = @_;
    my $bless_package = $slg->[Marpa::R3::Internal::Scanless::G::BLESS_PACKAGE];

    my ($blessing) =
      $slg->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ),
        <<'END_OF_LUA', 'is>*', $irlid, ($bless_package // ''));
        local slg, irlid, bless_package = ...
        local irl = slg.g1.irls[irlid]
        local blessing = '::undef'
        local xpr = irl.xpr
        if xpr then
            blessing = xpr.bless or '::undef'
        end
        if blessing == '::undef' then return blessing end
        if #bless_package == 0 then
            error(string.format(
                'A blessed rule is in a grammar with no bless_package\n'
                .. '  The rule was blessed as %q\n',
                blessing
            ))
        end
        return bless_package .. '::' .. blessing
END_OF_LUA

    return $blessing;

}

sub resolve_grammar {

    my ($slg) = @_;

    my $trace_actions =
      $slg->[Marpa::R3::Internal::Scanless::G::TRACE_ACTIONS] // 0;
    my $trace_file_handle =
      $slg->[Marpa::R3::Internal::Scanless::G::TRACE_FILE_HANDLE];

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

# For diagnostics
sub g1_show_rule_list {
    my ( $slg, $rule_ids ) = @_;
    my @rules = map { $slg->g1_rule_show($_) } @{$rule_ids};
    return join q{}, map { q{    } . $_ . "\n" } @rules;
}

sub registrations_set {
    my ( $slg, $registrations ) = @_;
    my $trace_file_handle =
      $slg->[Marpa::R3::Internal::Scanless::G::TRACE_FILE_HANDLE];
    my $trace_actions =
      $slg->[Marpa::R3::Internal::Scanless::G::TRACE_ACTIONS] // 0;

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

                my $constants = $slg->[Marpa::R3::Internal::Scanless::G::CONSTANTS];
                my $next_ix = scalar @{$constants};
                push @ops, $next_ix;
                $slg->[Marpa::R3::Internal::Scanless::G::CONSTANTS]->[$next_ix]
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

sub registrations_find {
    my ($slg) = @_;
    my $trace_file_handle =
      $slg->[Marpa::R3::Internal::Scanless::G::TRACE_FILE_HANDLE];
    my $trace_actions =
      $slg->[Marpa::R3::Internal::Scanless::G::TRACE_ACTIONS] // 0;

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
    my $null_values = $slg->[Marpa::R3::Internal::Scanless::G::NULL_VALUES] =
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
                push @bless_ops, $op_lua, $op_bless_key, \$blessing;
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

    $slg->[Marpa::R3::Internal::Scanless::G::CLOSURE_BY_SYMBOL_ID] =
      \@nulling_closures;
    $slg->[Marpa::R3::Internal::Scanless::G::CLOSURE_BY_RULE_ID] =
      \@closure_by_irlid;

    return \@registrations;

}

sub Marpa::R3::Scanless::R::value {
    my ( $slr, $per_parse_arg ) = @_;
    my $slv = Marpa::R3::Scanless::V->new( { recognizer => $slr } );
    my $ambiguity_level = $slv->ambiguity_level();
    return if $ambiguity_level == 0;
    if ( $ambiguity_level != 1 ) {
        my $ambiguous_status = $slv->ambiguous();
        Marpa::R3::exception( "Parse of the input is ambiguous\n",
            $ambiguous_status );
    }
    my $value_ref = $slv->value($per_parse_arg);
    Marpa::R3::exception("$slr->value(): No parse\n")
      if not $value_ref;
    return $value_ref;
}

# INTERNAL OK AFTER HERE _marpa_

1;

# vim: expandtab shiftwidth=4:
