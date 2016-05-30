# Marpa::R3 is Copyright (C) 2016, Jeffrey Kegler.
#
# This module is free software; you can redistribute it and/or modify it
# under the same terms as Perl 5.10.1. For more details, see the full text
# of the licenses in the directory LICENSES.
#
# This program is distributed in the hope that it will be
# useful, but it is provided “as is” and without any express
# or implied warranties. For details, see the full text of
# of the licenses in the directory LICENSES.

package Marpa::R3::Value;

use 5.010001;
use warnings;
use strict;

use vars qw($VERSION $STRING_VERSION);
$VERSION        = '4.001_010';
$STRING_VERSION = $VERSION;
## no critic (BuiltinFunctions::ProhibitStringyEval)
$VERSION = eval $VERSION;
## use critic

package Marpa::R3::Internal::Value;

use English qw( -no_match_vars );

use constant SKIP => -1;

sub Marpa::R3::show_rank_ref {
    my ($rank_ref) = @_;
    return 'undef' if not defined $rank_ref;
    return 'SKIP'  if $rank_ref == Marpa::R3::Internal::Value::SKIP;
    return ${$rank_ref};
} ## end sub Marpa::R3::show_rank_ref

package Marpa::R3::Internal::Value;

# Given the grammar and an action name, resolve it to a closure,
# or return undef
sub Marpa::R3::Internal::Scanless::R::resolve_action {
    my ( $slr, $closure_name, $p_error ) = @_;
    my $trace_file_handle =
        $slr->[Marpa::R3::Internal::Scanless::R::TRACE_FILE_HANDLE];
    my $slg = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
    my $trace_actions =
        $slr->[Marpa::R3::Internal::Scanless::R::TRACE_ACTIONS];

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
            $slr->[Marpa::R3::Internal::Scanless::R::SEMANTICS_PACKAGE];
        if ( not defined $resolve_package ) {
            ${$p_error} = Marpa::R3::Internal::X->new(
                {   message =>
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
            last TYPE;
        }

        # Re other symbol tables entries:
        # We ignore ARRAY and HASH because they anything
        # we resolve to is a potential array entry, something
        # that not possible for arrays and hashes except
        # indirectly, via references.
        # FORMAT is deprecated.
        # IO and GLOB seem too abstruse at the moment.

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
                        or
                        Marpa::R3::exception('Could not print to trace file');
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

# Find the semantics for a lexeme.
sub Marpa::R3::Internal::Scanless::R::lexeme_semantics_find {
    my ( $slr, $lexeme_id ) = @_;
    my $recce_c                = $slr->[Marpa::R3::Internal::Scanless::R::R_C];
    my $slg = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
    my $tracer = $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];
    my $xsy_by_isyid =
        $tracer->[Marpa::R3::Internal::Trace::G::XSY_BY_ISYID];
    my $xsy = $xsy_by_isyid->[$lexeme_id];
    my $semantics = $xsy->[Marpa::R3::Internal::XSY::LEXEME_SEMANTICS];
    return '::!default' if not defined $semantics;
    return $semantics;
}

# Find the blessing for a rule.
sub Marpa::R3::Internal::Scanless::R::rule_blessing_find {
    my ( $slr, $irlid ) = @_;
    my $slg = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
    my $tracer = $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];
    my $xbnf_by_irlid = $tracer->[Marpa::R3::Internal::Trace::G::XBNF_BY_IRLID];
    my $xbnf = $xbnf_by_irlid->[$irlid];
    my $blessing = $xbnf->[Marpa::R3::Internal::XBNF::BLESSING];
    $blessing = '::undef' if not defined $blessing;
    return $blessing if $blessing eq '::undef';
    my $bless_package =
        $slg->[Marpa::R3::Internal::Scanless::G::BLESS_PACKAGE];

    if ( not defined $bless_package ) {
        Marpa::R3::exception(
                  qq{A blessed rule is in a grammar with no bless_package\n}
                . qq{  The rule was blessed as "$blessing"\n} );
    }
    return join q{}, $bless_package, q{::}, $blessing;
}

# Find the blessing for a lexeme.
sub Marpa::R3::Scanless::R::lexeme_blessing_find {
    my ( $slr, $lexeme_id ) = @_;
    my $slg = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
    my $tracer = $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];
    my $xsy_by_isyid = $tracer->[Marpa::R3::Internal::Trace::G::XSY_BY_ISYID];
    my $xsy   = $xsy_by_isyid->[$lexeme_id];
    my $blessing = $xsy->[Marpa::R3::Internal::XSY::BLESSING];

    return '::undef' if not defined $blessing;
    return '::undef' if $blessing eq '::undef';
    if ( $blessing =~ m/\A [:][:] /xms ) {
        my $lexeme_name = $tracer->symbol_name($lexeme_id);
        $slr->[Marpa::R3::Internal::Scanless::R::ERROR_MESSAGE] =
            qq{Symbol "$lexeme_name" has unknown blessing: "$blessing"};
        return;
    } ## end if ( $blessing =~ m/\A [:][:] /xms )
    if ( $blessing =~ m/ [:][:] /xms ) {
        return $blessing;
    }
    my $bless_package =
        $slg->[Marpa::R3::Internal::Scanless::G::BLESS_PACKAGE];
    if ( not defined $bless_package ) {
        my $lexeme_name = $tracer->symbol_name($lexeme_id);
        $slr->[Marpa::R3::Internal::Scanless::R::ERROR_MESSAGE] =
            qq{Symbol "$lexeme_name" needs a blessing package, but grammar has none\n}
            . qq{  The blessing for "$lexeme_name" was "$blessing"\n};
        return;
    } ## end if ( not defined $bless_package )
    return $bless_package . q{::} . $blessing;
}

# For diagnostics
sub Marpa::R3::Internal::Scanless::R::brief_rule_list {
    my ( $slr, $rule_ids ) = @_;
    my $slg = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
    my $tracer =
        $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];
    my @brief_rules = map { $tracer->brief_rule($_) } @{$rule_ids};
    return join q{}, map { q{    } . $_ . "\n" } @brief_rules;
}

our $CONTEXT_EXCEPTION_CLASS = __PACKAGE__ . '::Context_Exception';

sub Marpa::R3::Context::bail { ## no critic (Subroutines::RequireArgUnpacking)
    if ( scalar @_ == 1 and ref $_[0] ) {
        die bless { exception_object => $_[0] }, $CONTEXT_EXCEPTION_CLASS;
    }
    my $error_string = join q{}, @_;
    my ( $package, $filename, $line ) = caller;
    chomp $error_string;
    die bless { message => qq{User bailed at line $line in file "$filename"\n}
            . $error_string
            . "\n" }, $CONTEXT_EXCEPTION_CLASS;
} ## end sub Marpa::R3::Context::bail
## use critic

sub Marpa::R3::Context::g1_range {
    my $valuator = $Marpa::R3::Internal::Context::VALUATOR;
    Marpa::R3::exception(
        'Marpa::R3::Context::g1_range called outside of a valuation context')
        if not defined $valuator;
    return $valuator->location();
} ## end sub Marpa::R3::Context::g1_range

sub Marpa::R3::Context::g1_span {
    my $valuator = $Marpa::R3::Internal::Context::VALUATOR;
    my ($start, $end) = $valuator->location();
    return $start, ($start - $end) + 1;
}

sub code_problems {
    my $args = shift;

    my $grammar;
    my $fatal_error;
    my $warnings = [];
    my $where    = '?where?';
    my $long_where;
    my @msg = ();
    my $eval_value;
    my $eval_given = 0;

    push @msg, q{=} x 60, "\n";
    ARG: for my $arg ( keys %{$args} ) {
        my $value = $args->{$arg};
        if ( $arg eq 'fatal_error' ) { $fatal_error = $value; next ARG }
        if ( $arg eq 'grammar' )     { $grammar     = $value; next ARG }
        if ( $arg eq 'where' )       { $where       = $value; next ARG }
        if ( $arg eq 'long_where' )  { $long_where  = $value; next ARG }
        if ( $arg eq 'warnings' )    { $warnings    = $value; next ARG }
        if ( $arg eq 'eval_ok' ) {
            $eval_value = $value;
            $eval_given = 1;
            next ARG;
        }
        push @msg, "Unknown argument to code_problems: $arg";
    } ## end ARG: for my $arg ( keys %{$args} )

    GIVEN_FATAL_ERROR_REF_TYPE: {
        my $fatal_error_ref_type = ref $fatal_error;
        last GIVEN_FATAL_ERROR_REF_TYPE if not $fatal_error_ref_type;
        if ( $fatal_error_ref_type eq $CONTEXT_EXCEPTION_CLASS ) {
            my $exception_object = $fatal_error->{exception_object};
            die $exception_object if defined $exception_object;
            my $exception_message = $fatal_error->{message};
            die $exception_message if defined $exception_message;
            die "Internal error: bad $CONTEXT_EXCEPTION_CLASS object";
        } ## end if ( $fatal_error_ref_type eq $CONTEXT_EXCEPTION_CLASS)
        $fatal_error =
              "Exception thrown as object inside Marpa closure\n"
            . ( q{ } x 4 )
            . "This is not allowed\n"
            . ( q{ } x 4 )
            . qq{Exception as string is "$fatal_error"};
    } ## end GIVEN_FATAL_ERROR_REF_TYPE:

    my @problem_line     = ();
    my $max_problem_line = -1;
    for my $warning_data ( @{$warnings} ) {
        my ( $warning, $package, $filename, $problem_line ) =
            @{$warning_data};
        $problem_line[$problem_line] = 1;
        $max_problem_line = List::Util::max $problem_line, $max_problem_line;
    } ## end for my $warning_data ( @{$warnings} )

    $long_where //= $where;

    my $warnings_count = scalar @{$warnings};
    {
        my @problems;
        my $false_eval = $eval_given && !$eval_value && !$fatal_error;
        if ($false_eval) {
            push @problems, '* THE MARPA SEMANTICS RETURNED A PERL FALSE',
                'Marpa::R3 requires its semantics to return a true value';
        }
        if ($fatal_error) {
            push @problems, '* THE MARPA SEMANTICS PRODUCED A FATAL ERROR';
        }
        if ($warnings_count) {
            push @problems,
                "* THERE WERE $warnings_count WARNING(S) IN THE MARPA SEMANTICS:",
                'Marpa treats warnings as fatal errors';
        }
        if ( not scalar @problems ) {
            push @msg, '* THERE WAS A FATAL PROBLEM IN THE MARPA SEMANTICS';
        }
        push @msg, ( join "\n", @problems ) . "\n";
    }

    push @msg, "* THIS IS WHAT MARPA WAS DOING WHEN THE PROBLEM OCCURRED:\n"
        . $long_where . "\n";

    for my $warning_ix ( 0 .. ( $warnings_count - 1 ) ) {
        push @msg, "* WARNING MESSAGE NUMBER $warning_ix:\n";
        my $warning_message = $warnings->[$warning_ix]->[0];
        $warning_message =~ s/\n*\z/\n/xms;
        push @msg, $warning_message;
    } ## end for my $warning_ix ( 0 .. ( $warnings_count - 1 ) )

    if ($fatal_error) {
        push @msg, "* THIS WAS THE FATAL ERROR MESSAGE:\n";
        my $fatal_error_message = $fatal_error;
        $fatal_error_message =~ s/\n*\z/\n/xms;
        push @msg, $fatal_error_message;
    } ## end if ($fatal_error)

    Marpa::R3::exception(@msg);

    # this is to keep perlcritic happy
    return 1;

} ## end sub code_problems

# Dump semantics for diagnostics
sub show_semantics {
    my (@ops)    = @_;
    my @op_descs = ();
    my $op_ix    = 0;
    OP: while ( $op_ix < scalar @ops ) {
        my $op      = $ops[ $op_ix++ ];
        my $op_name = Marpa::R3::Thin::op_name($op);
        push @op_descs, $op_name;
        if ( $op_name eq 'bless' ) {
            push @op_descs, q{"} . $ops[$op_ix] . q{"};
            $op_ix++;
            next OP;
        }
        if ( $op_name eq 'push_constant' ) {
            push @op_descs, $ops[$op_ix];
            $op_ix++;
            next OP;
        }
        if ( $op_name eq 'push_one' ) {
            push @op_descs, $ops[$op_ix];
            $op_ix++;
            next OP;
        }
        if ( $op_name eq 'result_is_rhs_n' ) {
            push @op_descs, $ops[$op_ix];
            $op_ix++;
            next OP;
        }
        if ( $op_name eq 'result_is_n_of_sequence' ) {
            push @op_descs, $ops[$op_ix];
            $op_ix++;
            next OP;
        }
        if ( $op_name eq 'result_is_constant' ) {
            push @op_descs, $ops[$op_ix];
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

# Return false if no ordering was created,
# otherwise return the ordering.
sub Marpa::R3::Scanless::R::ordering_get {
    my ($slr) = @_;
    return if $slr->[Marpa::R3::Internal::Scanless::R::NO_PARSE];
    my $ordering = $slr->[Marpa::R3::Internal::Scanless::R::O_C];
    return $ordering if $ordering;
    my $parse_set_arg =
        $slr->[Marpa::R3::Internal::Scanless::R::END_OF_PARSE];
    my $slg = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
    my $tracer = $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];
    my $grammar_c = $tracer->[Marpa::R3::Internal::Trace::G::C];
    my $recce_c   = $slr->[Marpa::R3::Internal::Scanless::R::R_C];

    $grammar_c->throw_set(0);
    my $bocage = $slr->[Marpa::R3::Internal::Scanless::R::B_C] =
      Marpa::R3::Thin::B->new( $recce_c, ( $parse_set_arg // -1 ) );
    $grammar_c->throw_set(1);
    if ( not $bocage ) {
        $slr->[Marpa::R3::Internal::Scanless::R::NO_PARSE] = 1;
        return;
    }
    $ordering = $slr->[Marpa::R3::Internal::Scanless::R::O_C] =
      Marpa::R3::Thin::O->new($bocage);

    GIVEN_RANKING_METHOD: {
        my $ranking_method =
            $slr->[Marpa::R3::Internal::Scanless::R::RANKING_METHOD];
        if ( $ranking_method eq 'high_rule_only' ) {
            $ordering->high_rank_only_set(1);
            $ordering->rank();
            last GIVEN_RANKING_METHOD;
        }
        if ( $ranking_method eq 'rule' ) {
            $ordering->high_rank_only_set(0);
            $ordering->rank();
            last GIVEN_RANKING_METHOD;
        }
    } ## end GIVEN_RANKING_METHOD:

    return $ordering;
}

sub resolve_rule_by_id {
    my ( $slr, $irlid ) = @_;
    my $slg = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
    my $tracer = $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];
    my $action_name = $tracer->[Marpa::R3::Internal::Trace::G::ACTION_BY_IRLID]->[$irlid];
    my $resolve_error;
    return if not defined $action_name;
    my $resolution = Marpa::R3::Internal::Scanless::R::resolve_action( $slr,
        $action_name, \$resolve_error );

    if ( not $resolution ) {
        my $rule_desc = $slr->rule_show( $irlid );
        Marpa::R3::exception(
            "Could not resolve rule action named '$action_name'\n",
            "  Rule was $rule_desc\n",
            q{  },
            ( $resolve_error // 'Failed to resolve action' )
        );
    } ## end if ( not $resolution )
    return $resolution;
} ## end sub resolve_rule_by_id

sub resolve_recce {

    my ( $slr, $per_parse_arg ) = @_;
    my $slg = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
    my $tracer = $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];
    my $grammar_c = $tracer->[Marpa::R3::Internal::Trace::G::C];

    my $trace_actions =
        $slr->[Marpa::R3::Internal::Scanless::R::TRACE_ACTIONS] // 0;
    my $trace_file_handle =
        $slr->[Marpa::R3::Internal::Scanless::R::TRACE_FILE_HANDLE];

    my $resolve_error;

    my $default_action_resolution =
        Marpa::R3::Internal::Scanless::R::resolve_action( $slr, undef, \$resolve_error );
    Marpa::R3::exception(
        "Could not resolve default action\n",
        q{  }, ( $resolve_error // 'Failed to resolve action' ) )
        if not $default_action_resolution;

    my $rule_resolutions = [];

  RULE: for my $irlid ( $tracer->rule_ids() ) {

        my $rule_resolution = resolve_rule_by_id( $slr, $irlid );
        $rule_resolution //= $default_action_resolution;

        if ( not $rule_resolution ) {
            my $rule_desc = $slr->rule_show($irlid);
            my $message   = "Could not resolve action\n  Rule was $rule_desc\n";

            my $action =
              $tracer->[Marpa::R3::Internal::Trace::G::ACTION_BY_IRLID]
              ->[$irlid];
            $message .= qq{  Action was specified as "$action"\n}
              if defined $action;
            my $recce_error =
              $slr->[Marpa::R3::Internal::Scanless::R::ERROR_MESSAGE];
            $message .= q{  } . $recce_error if defined $recce_error;
            Marpa::R3::exception($message);
        } ## end if ( not $rule_resolution )

      DETERMINE_BLESSING: {

            my $blessing =
              Marpa::R3::Internal::Scanless::R::rule_blessing_find( $slr,
                $irlid );
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
                        $tracer->brief_rule($irlid)
                    );
                } ## end CHECK_SEMANTICS:
            } ## end if ( $blessing ne '::undef' )

            $rule_resolution =
              [ $closure_name, $closure, $semantics, $blessing ];
        } ## end DETERMINE_BLESSING:

        $rule_resolutions->[$irlid] = $rule_resolution;

    } ## end RULE: for my $rule_id ( $tracer->rule_ids() )

    if ( $trace_actions >= 2 ) {
        RULE: for my $rule_id ( 0 .. $grammar_c->highest_rule_id() ) {
            my ( $resolution_name, $closure ) =
                @{ $rule_resolutions->[$rule_id] };
            say {$trace_file_handle} 'Rule ',
                $tracer->brief_rule($rule_id),
                qq{ resolves to "$resolution_name"}
                or Marpa::R3::exception('print to trace handle failed');
        }
    }

    my @lexeme_resolutions = ();
    SYMBOL: for my $lexeme_id ( 0 .. $grammar_c->highest_symbol_id()) {

        my $semantics =
            Marpa::R3::Internal::Scanless::R::lexeme_semantics_find( $slr,
            $lexeme_id );
        if ( not defined $semantics ) {
            my $message =
                  "Could not determine lexeme's semantics\n"
                . q{  Lexeme was }
                . $tracer->symbol_name($lexeme_id) . "\n";
            $message
                .= q{  }
                . $slr->[Marpa::R3::Internal::Scanless::R::ERROR_MESSAGE];
            Marpa::R3::exception($message);
        } ## end if ( not defined $semantics )
        my $blessing = $slr->lexeme_blessing_find( $lexeme_id );
        if ( not defined $blessing ) {
            my $message =
                  "Could not determine lexeme's blessing\n"
                . q{  Lexeme was }
                . $tracer->symbol_name($lexeme_id) . "\n";
            $message
                .= q{  }
                . $slr->[Marpa::R3::Internal::Scanless::R::ERROR_MESSAGE];
            Marpa::R3::exception($message);
        } ## end if ( not defined $blessing )
        $lexeme_resolutions[$lexeme_id] = [ $semantics, $blessing ];

    }

    return ( $rule_resolutions, \@lexeme_resolutions );
} ## end sub resolve_recce

sub registration_init {
    my ( $slr, $per_parse_arg ) = @_;

    my $trace_file_handle =
        $slr->[Marpa::R3::Internal::Scanless::R::TRACE_FILE_HANDLE];
    my $slg = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
    my $tracer = $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];
    my $xbnf_by_irlid = $tracer->[Marpa::R3::Internal::Trace::G::XBNF_BY_IRLID];
    my $grammar_c = $tracer->[Marpa::R3::Internal::Trace::G::C];
    my $recce_c   = $slr->[Marpa::R3::Internal::Scanless::R::R_C];
    my $trace_actions =
        $slr->[Marpa::R3::Internal::Scanless::R::TRACE_ACTIONS] // 0;

    my @closure_by_irlid   = ();
    my @semantics_by_irlid = ();
    my @blessing_by_irlid  = ();

    my ( $rule_resolutions, $lexeme_resolutions ) =
        resolve_recce( $slr, $per_parse_arg );

    # Set the arrays, and perform various checks on the resolutions
    # we received
    {
        # ::whatever is deprecated and has been removed from the docs
        # it is now equivalent to ::undef

        RULE:
        for my $irlid ( $tracer->rule_ids() ) {
            my ( $new_resolution, $closure, $semantics, $blessing ) =
                @{ $rule_resolutions->[$irlid] };
            my $lhs_id = $grammar_c->rule_lhs($irlid);

            REFINE_SEMANTICS: {

                if ('[' eq substr $semantics,
                    0, 1 and ']' eq substr $semantics,
                    -1, 1
                    )
                {
                    # Normalize array semantics
                    $semantics =~ s/ //gxms;
                    last REFINE_SEMANTICS;
                } ## end if ( '[' eq substr $semantics, 0, 1 and ']' eq ...)

                state $allowed_semantics = {
                    map { ; ( $_, 1 ) }
                        qw(::array ::undef ::first ::whatever ::!default),
                    q{}
                };
                last REFINE_SEMANTICS if $allowed_semantics->{$semantics};
                last REFINE_SEMANTICS
                    if $semantics =~ m/ \A rhs \d+ \z /xms;

                Marpa::R3::exception(
                    q{Unknown semantics for rule },
                    $tracer->brief_rule($irlid),
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
                            $tracer->brief_rule($irlid),
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
                    $tracer->brief_rule($irlid),
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
    RULE: for my $irlid ( $tracer->rule_ids() ) {
        my $lhs_id = $grammar_c->rule_lhs($irlid);
        push @{ $nullable_rule_ids_by_lhs[$lhs_id] }, $irlid
            if $grammar_c->rule_is_nullable($irlid);
    }

    my @null_symbol_closures;
    LHS:
    for ( my $lhs_id = 0; $lhs_id <= $#nullable_rule_ids_by_lhs; $lhs_id++ ) {
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
                my $lhs_name = $tracer->symbol_name($lhs_id);
                say {$trace_file_handle}
                    qq{Nulled symbol "$lhs_name" },
                    qq{ resolved to "$resolution_name" from rule },
                    $tracer->brief_rule($resolution_rule)
                    or Marpa::R3::exception('print to trace handle failed');
            } ## end if ($trace_actions)
            $null_symbol_closures[$lhs_id] = $resolution_rule;
            next LHS;
        } ## end if ( $rule_count == 1 )

        # More than one rule?  Are any empty?
        # If so, use the semantics of the empty rule
        my @empty_rules =
            grep { $grammar_c->rule_length($_) <= 0 } @{$irlids};
        if ( scalar @empty_rules ) {
            $resolution_rule = $empty_rules[0];
            my ( $resolution_name, $closure ) =
                @{ $rule_resolutions->[$resolution_rule] };
            if ($trace_actions) {
                my $lhs_name = $tracer->symbol_name($lhs_id);
                say {$trace_file_handle}
                    qq{Nulled symbol "$lhs_name" },
                    qq{ resolved to "$resolution_name" from rule },
                    $tracer->brief_rule($resolution_rule)
                    or Marpa::R3::exception('print to trace handle failed');
            } ## end if ($trace_actions)
            $null_symbol_closures[$lhs_id] = $resolution_rule;
            next LHS;
        } ## end if ( scalar @empty_rules )

        # Multiple rules, none of them empty.
        my ( $first_resolution, @other_resolutions ) =
            map { $rule_resolutions->[$_] } @{$irlids};

        # Do they have more than one semantics?
        # If so, just call it an error and let the user sort it out.
        my ( $first_closure_name, undef, $first_semantics, $first_blessing )
            = @{$first_resolution};
        OTHER_RESOLUTION: for my $other_resolution (@other_resolutions) {
            my ( $other_closure_name, undef, $other_semantics,
                $other_blessing )
                = @{$other_resolution};

            if (   $first_closure_name ne $other_closure_name
                or $first_semantics ne $other_semantics
                or $first_blessing ne $other_blessing )
            {
                Marpa::R3::exception(
                    'When nulled, symbol ',
                    $tracer->symbol_name($lhs_id),
                    qq{  can have more than one semantics\n},
                    qq{  Marpa needs there to be only one semantics\n},
                    qq{  The rules involved are:\n},
                    Marpa::R3::Internal::Scanless::R::brief_rule_list(
                        $slr, $irlids
                    )
                );
            } ## end if ( $first_closure_name ne $other_closure_name or ...)
        } ## end OTHER_RESOLUTION: for my $other_resolution (@other_resolutions)

        # Multiple rules, but they all have one semantics.
        # So (obviously) use that semantics
        $resolution_rule = $irlids->[0];
        my ( $resolution_name, $closure ) =
            @{ $rule_resolutions->[$resolution_rule] };
        if ($trace_actions) {
            my $lhs_name = $tracer->symbol_name($lhs_id);
            say {$trace_file_handle}
                qq{Nulled symbol "$lhs_name" },
                qq{ resolved to "$resolution_name" from rule },
                $tracer->brief_rule($resolution_rule)
                or Marpa::R3::exception('print to trace handle failed');
        } ## end if ($trace_actions)
        $null_symbol_closures[$lhs_id] = $resolution_rule;

    } ## end LHS: for ( my $lhs_id = 0; $lhs_id <= $#nullable_rule_ids_by_lhs...)

    # Do consistency checks

    # Set the object values
    $slr->[Marpa::R3::Internal::Scanless::R::NULL_VALUES] =
        \@null_symbol_closures;

    my @semantics_by_lexeme_id = ();
    my @blessing_by_lexeme_id  = ();

    # Check the lexeme semantics
    {
        # ::whatever is deprecated and has been removed from the docs
        # it is now equivalent to ::undef
      LEXEME: for my $lexeme_id ( 0 .. $grammar_c->highest_symbol_id() ) {

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
                        $tracer->symbol_name($lexeme_id),
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
                    $tracer->symbol_name($lexeme_id),
                    "\n",
                    qq{    Blessing as specified as "$blessing"\n}
                );
            } ## end CHECK_BLESSING:
            $semantics_by_lexeme_id[$lexeme_id] = $semantics;
            $blessing_by_lexeme_id[$lexeme_id]  = $blessing;

        }

    }

    my $null_values = $slr->[Marpa::R3::Internal::Scanless::R::NULL_VALUES];

    state $op_bless          = Marpa::R3::Thin::op('bless');
    state $op_callback       = Marpa::R3::Thin::op('callback');
    state $op_push_constant  = Marpa::R3::Thin::op('push_constant');
    state $op_push_g1_length = Marpa::R3::Thin::op('push_g1_length');
    state $op_push_length    = Marpa::R3::Thin::op('push_length');
    state $op_push_undef     = Marpa::R3::Thin::op('push_undef');
    state $op_push_one       = Marpa::R3::Thin::op('push_one');
    state $op_push_sequence  = Marpa::R3::Thin::op('push_sequence');
    state $op_push_g1_start  = Marpa::R3::Thin::op('push_g1_start');
    state $op_push_start_location =
        Marpa::R3::Thin::op('push_start_location');
    state $op_push_values        = Marpa::R3::Thin::op('push_values');
    state $op_result_is_array    = Marpa::R3::Thin::op('result_is_array');
    state $op_result_is_constant = Marpa::R3::Thin::op('result_is_constant');
    state $op_result_is_n_of_sequence =
        Marpa::R3::Thin::op('result_is_n_of_sequence');
    state $op_result_is_rhs_n = Marpa::R3::Thin::op('result_is_rhs_n');
    state $op_result_is_token_value =
        Marpa::R3::Thin::op('result_is_token_value');
    state $op_result_is_undef = Marpa::R3::Thin::op('result_is_undef');
    state $op_lua = Marpa::R3::Thin::op('lua');

    my @nulling_symbol_by_semantic_rule;
    NULLING_SYMBOL: for my $nulling_symbol ( 0 .. $#{$null_values} ) {
        my $semantic_rule = $null_values->[$nulling_symbol];
        next NULLING_SYMBOL if not defined $semantic_rule;
        $nulling_symbol_by_semantic_rule[$semantic_rule] = $nulling_symbol;
    } ## end NULLING_SYMBOL: for my $nulling_symbol ( 0 .. $#{$null_values} )

    my @work_list = ();
    RULE: for my $irlid ( $tracer->rule_ids() ) {

        my $semantics = $semantics_by_irlid[$irlid];
        my $blessing  = $blessing_by_irlid[$irlid];

        $semantics = '[name,values]' if $semantics eq '::!default';
        $semantics = '[values]' if $semantics eq '::array';
        $semantics = '::undef'  if $semantics eq '::whatever';
        $semantics = '::rhs0'   if $semantics eq '::first';

        push @work_list, [ $irlid, undef, $semantics, $blessing ];
    }

  RULE: for my $lexeme_id ( 0 .. $grammar_c->highest_symbol_id() ) {

        my $semantics = $semantics_by_lexeme_id[$lexeme_id];
        my $blessing  = $blessing_by_lexeme_id[$lexeme_id];

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

        my ( $closure, $xbnf, $rule_length, $is_sequence_rule,
            $is_discard_sequence_rule, $nulling_symbol_id );
        if ( defined $irlid ) {
            $nulling_symbol_id = $nulling_symbol_by_semantic_rule[$irlid];
            $closure          = $closure_by_irlid[$irlid];
            $xbnf             = $xbnf_by_irlid->[$irlid];
            $rule_length      = $grammar_c->rule_length($irlid);
            $is_sequence_rule = defined $grammar_c->sequence_min($irlid);
            $is_discard_sequence_rule = $is_sequence_rule
                && $xbnf->[Marpa::R3::Internal::XBNF::DISCARD_SEPARATION];
        } ## end if ( defined $irlid )

        # Determine the "fate" of the array of child values
        my $array_fate;
        ARRAY_FATE: {
            if ( defined $closure and ref $closure eq 'CODE' ) {
                $array_fate = $op_callback;
                last ARRAY_FATE;

            }

            if ( ( substr $semantics, 0, 1 ) eq '[' ) {
                $array_fate = $op_result_is_array;
                last ARRAY_FATE;
            }
        } ## end ARRAY_FATE:

        my @ops = ();

        SET_OPS: {

            if ( $semantics eq '::undef' ) {
                @ops = ($op_result_is_undef);
                last SET_OPS;
            }

            DO_CONSTANT: {
                last DO_CONSTANT if not defined $irlid;
                my $thingy_ref = $closure_by_irlid[$irlid];
                last DO_CONSTANT if not defined $thingy_ref;
                my $ref_type = Scalar::Util::reftype $thingy_ref;
                if ( $ref_type eq q{} ) {
                    my $rule_desc = $slr->rule_show( $irlid );
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
                    last DO_CONSTANT;
                } ## end if ( $ref_type eq 'CODE' )
                if ( $ref_type eq 'SCALAR' ) {
                    my $thingy = ${$thingy_ref};
                    if ( not defined $thingy ) {
                        @ops = ($op_result_is_undef);
                        last SET_OPS;
                    }
                    @ops = ( $op_result_is_constant, $thingy_ref );
                    last SET_OPS;
                } ## end if ( $ref_type eq 'SCALAR' )

                # No test for 'ARRAY' or 'HASH' --
                # The ref is currenly only to scalar and code slots in the symbol table,
                # and therefore cannot be to (among other things) an ARRAY or HASH

                if ( $ref_type eq 'REF' ) {
                    @ops = ( $op_result_is_constant, $thingy_ref );
                    last SET_OPS;
                }

                my $rule_desc = $slr->rule_show( $irlid );
                Marpa::R3::exception(
                    qq{Constant action is not of an allowed type.\n},
                    qq{  It was of type reference to $ref_type.\n},
                    qq{  Rule was $rule_desc\n}
                );
            } ## end DO_CONSTANT:

            # After this point, any closure will be a ref to 'CODE'

            if ( defined $lexeme_id and $semantics eq '::value' ) {
                @ops = ($op_result_is_token_value);
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
                    @ops =
                        ( $op_result_is_n_of_sequence, $singleton_element );
                    last SET_OPS;
                }
                if ($is_sequence_rule) {
                    @ops = ( $op_result_is_rhs_n, $singleton_element );
                    last SET_OPS;
                }
                my $mask = $tracer->[Marpa::R3::Internal::Trace::G::MASK_BY_IRLID]->[$irlid];
                my @elements =
                    grep { $mask->[$_] } 0 .. ( $rule_length - 1 );
                if ( not scalar @elements ) {
                    my $original_semantics = $semantics_by_irlid[$irlid];
                    Marpa::R3::exception(
                        q{Impossible semantics for empty rule: },
                        $tracer->brief_rule($irlid),
                        "\n",
                        qq{    Semantics were specified as "$original_semantics"\n}
                    );
                } ## end if ( not scalar @elements )
                $singleton_element = $elements[$singleton];

                if ( not defined $singleton_element ) {
                    my $original_semantics = $semantics_by_irlid[$irlid];
                    Marpa::R3::exception(
                        q{Impossible semantics for rule: },
                        $tracer->brief_rule($irlid),
                        "\n",
                        qq{    Semantics were specified as "$original_semantics"\n}
                    );
                } ## end if ( not defined $singleton_element )
                @ops = ( $op_result_is_rhs_n, $singleton_element );
                last SET_OPS;
            } ## end PROCESS_SINGLETON_RESULT:

            if ( not defined $array_fate ) {
                @ops = ($op_result_is_undef);
                last SET_OPS;
            }

            # if here, $array_fate is defined

            my @bless_ops = ();
            if ( $blessing ne '::undef' ) {
                push @bless_ops, $op_bless, \$blessing;
            }

            Marpa::R3::exception(qq{Unknown semantics: "$semantics"})
                if ( substr $semantics, 0, 1 ) ne '[';

            my @push_ops = ();
            my $array_descriptor = substr $semantics, 1, -1;
            $array_descriptor =~ s/^\s*|\s*$//g;
            RESULT_DESCRIPTOR:
            for my $result_descriptor ( split /[,]\s*/xms, $array_descriptor )
            {
                $result_descriptor =~ s/^\s*|\s*$//g;
                if ( $result_descriptor eq 'g1start' ) {
                    push @push_ops, $op_push_g1_start;
                    next RESULT_DESCRIPTOR;
                }
                if ( $result_descriptor eq 'g1length' ) {
                    push @push_ops, $op_push_g1_length;
                    next RESULT_DESCRIPTOR;
                }
                if ( $result_descriptor eq 'start' ) {
                    push @push_ops, $op_push_start_location;
                    next RESULT_DESCRIPTOR;
                }
                if ( $result_descriptor eq 'length' ) {
                    push @push_ops, $op_push_length;
                    next RESULT_DESCRIPTOR;
                }

                if ( $result_descriptor eq 'lhs' ) {
                    if ( defined $irlid ) {
                        my $lhs_id = $grammar_c->rule_lhs($irlid);
                        push @push_ops, $op_push_constant, \$lhs_id;
                        next RESULT_DESCRIPTOR;
                    }
                    if ( defined $lexeme_id ) {
                        push @push_ops, $op_push_constant, \$lexeme_id;
                        next RESULT_DESCRIPTOR;
                    }
                    push @push_ops, $op_push_undef;
                    next RESULT_DESCRIPTOR;
                } ## end if ( $result_descriptor eq 'lhs' )

                if ( $result_descriptor eq 'name' ) {
                    if ( defined $irlid ) {
                        my $name = $tracer->rule_name($irlid);
                        push @push_ops, $op_push_constant, \$name;
                        next RESULT_DESCRIPTOR;
                    }
                    if ( defined $lexeme_id ) {
                        my $name = $tracer->symbol_name($lexeme_id);
                        push @push_ops, $op_push_constant, \$name;
                        next RESULT_DESCRIPTOR;
                    }
                    if ( defined $nulling_symbol_id ) {
                        my $name = $tracer->symbol_name($nulling_symbol_id);
                        push @push_ops, $op_push_constant, \$name;
                        next RESULT_DESCRIPTOR;
                    }
                    push @push_ops, $op_push_undef;
                    next RESULT_DESCRIPTOR;
                } ## end if ( $result_descriptor eq 'name' )

                if ( $result_descriptor eq 'symbol' ) {
                    if ( defined $irlid ) {
                        my $lhs_id = $grammar_c->rule_lhs($irlid);
                        my $name   = $tracer->symbol_name($lhs_id);
                        push @push_ops, $op_push_constant, \$name;
                        next RESULT_DESCRIPTOR;
                    } ## end if ( defined $irlid )
                    if ( defined $lexeme_id ) {
                        my $name = $tracer->symbol_name($lexeme_id);
                        push @push_ops, $op_push_constant, \$name;
                        next RESULT_DESCRIPTOR;
                    }
                    if ( defined $nulling_symbol_id ) {
                        my $name = $tracer->symbol_name($nulling_symbol_id);
                        push @push_ops, $op_push_constant, \$name;
                        next RESULT_DESCRIPTOR;
                    }
                    push @push_ops, $op_push_undef;
                    next RESULT_DESCRIPTOR;
                } ## end if ( $result_descriptor eq 'symbol' )

                if ( $result_descriptor eq 'rule' ) {
                    if ( defined $irlid ) {
                        push @push_ops, $op_push_constant, \$irlid;
                        next RESULT_DESCRIPTOR;
                    }
                    push @push_ops, $op_push_undef;
                    next RESULT_DESCRIPTOR;
                } ## end if ( $result_descriptor eq 'rule' )
                if (   $result_descriptor eq 'values'
                    or $result_descriptor eq 'value' )
                {
                    if ( defined $lexeme_id ) {
                        push @push_ops, $op_push_values;
                        next RESULT_DESCRIPTOR;
                    }
                    if ($is_sequence_rule) {
                        my $push_op =
                              $is_discard_sequence_rule
                            ? $op_push_sequence
                            : $op_push_values;
                        push @push_ops, $push_op;
                        next RESULT_DESCRIPTOR;
                    } ## end if ($is_sequence_rule)
                    my $mask = $xbnf->[Marpa::R3::Internal::XBNF::MASK];
                    if ( $rule_length > 0 ) {
                        push @push_ops,
                            map { $mask->[$_] ? ( $op_push_one, $_ ) : () }
                            0 .. $rule_length - 1;
                    }
                    next RESULT_DESCRIPTOR;
                } ## end if ( $result_descriptor eq 'values' or ...)
                Marpa::R3::exception(
                    qq{Unknown result descriptor: "$result_descriptor"\n},
                    qq{  The full semantics were "$semantics"}
                );
            } ## end RESULT_DESCRIPTOR: for my $result_descriptor ( split /[,]\s*/xms, ...)
            @ops = ( @push_ops, @bless_ops, $array_fate );

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

        my $start_symbol_id = $tracer->symbol_by_name('[:start]');
        last SLR_NULLING_GRAMMAR_HACK
            if not $grammar_c->symbol_is_nullable($start_symbol_id);

        my $start_rhs_symbol_id;
        RULE: for my $irlid ( $tracer->rule_ids() ) {
            my ( $lhs, $rhs0 ) = $tracer->rule_expand($irlid);
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

    $slr->[Marpa::R3::Internal::Scanless::R::REGISTRATIONS] =
        \@registrations;
    $slr->[Marpa::R3::Internal::Scanless::R::CLOSURE_BY_SYMBOL_ID] =
        \@nulling_closures;
    $slr->[Marpa::R3::Internal::Scanless::R::CLOSURE_BY_RULE_ID] =
        \@closure_by_irlid;

} ## end sub registration_init

# Returns false if no parse
sub Marpa::R3::Scanless::R::value {
    my ( $slr, $per_parse_arg ) = @_;
    my $slg = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
    my $tracer = $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];
    my $grammar_c = $tracer->[Marpa::R3::Internal::Trace::G::C];
    my $recce_c   = $slr->[Marpa::R3::Internal::Scanless::R::R_C];

    my $trace_actions =
        $slr->[Marpa::R3::Internal::Scanless::R::TRACE_ACTIONS] // 0;
    my $trace_values =
        $slr->[Marpa::R3::Internal::Scanless::R::TRACE_VALUES] // 0;
    my $trace_file_handle =
        $slr->[Marpa::R3::Internal::Scanless::R::TRACE_FILE_HANDLE];

    if ( scalar @_ != 1 ) {
        Marpa::R3::exception(
            'Too many arguments to Marpa::R3::Scanless::R::value')
            if ref $slr ne 'Marpa::R3::Scanless::R';
    }

    $slr->[Marpa::R3::Internal::Scanless::R::TREE_MODE] //= 'tree';
    if ( $slr->[Marpa::R3::Internal::Scanless::R::TREE_MODE] ne 'tree' ) {
        Marpa::R3::exception(
            "value() called when recognizer is not in tree mode\n",
            '  The current mode is "',
            $slr->[Marpa::R3::Internal::Scanless::R::TREE_MODE],
            qq{"\n}
        );
    }

    my $furthest_earleme       = $recce_c->furthest_earleme();
    my $last_completed_earleme = $recce_c->current_earleme();
    Marpa::R3::exception(
        "Attempt to evaluate incompletely recognized parse:\n",
        "  Last token ends at location $furthest_earleme\n",
        "  Recognition done only as far as location $last_completed_earleme\n"
    ) if $furthest_earleme > $last_completed_earleme;

    my $tree = $slr->[Marpa::R3::Internal::Scanless::R::T_C];

    if ($tree) {

        my $max_parses =
            $slr->[Marpa::R3::Internal::Scanless::R::MAX_PARSES];
        my $parse_count = $tree->parse_count();
        if ( $max_parses and $parse_count > $max_parses ) {
            Marpa::R3::exception(
                "Maximum parse count ($max_parses) exceeded");
        }

    } ## end if ($tree)
    else {
        # No tree, therefore not initialized

        my $order = $slr->ordering_get();
        return if not $order;
        $tree = $slr->[Marpa::R3::Internal::Scanless::R::T_C] =
            Marpa::R3::Thin::T->new($order);

    } ## end else [ if ($tree) ]

    return if not defined $tree->next();

    local $Marpa::R3::Context::rule    = undef;
    local $Marpa::R3::Context::slr     = $slr;
    local $Marpa::R3::Context::slg =
        $slr->[Marpa::R3::Internal::Scanless::R::SLG]
        if defined $slr;

    if ( not $slr->[Marpa::R3::Internal::Scanless::R::REGISTRATIONS] ) {
        registration_init( $slr, $per_parse_arg );
    }

    my $semantics_arg0 = $per_parse_arg // {};

    my $value = Marpa::R3::Thin::V->new($tree);
    $value->stack_mode_set( $slr->thin() );
    local $Marpa::R3::Internal::Context::VALUATOR = $value;
    value_trace( $value, $trace_values ? 1 : 0 );
    $value->trace_values($trace_values);

    my $null_values = $slr->[Marpa::R3::Internal::Scanless::R::NULL_VALUES];
    my $nulling_closures =
        $slr->[Marpa::R3::Internal::Scanless::R::CLOSURE_BY_SYMBOL_ID];
    my $rule_closures =
        $slr->[Marpa::R3::Internal::Scanless::R::CLOSURE_BY_RULE_ID];
    REGISTRATION:
    for my $registration (
        @{ $slr->[Marpa::R3::Internal::Scanless::R::REGISTRATIONS] } )
    {
        my ( $type, $id, @raw_ops ) = @{$registration};
        my @ops = ();
      PRINT_TRACES: {
            last PRINT_TRACES if $trace_values <= 2;
            if ( $type eq 'nulling' ) {
                say {$trace_file_handle}
                  "Registering semantics for nulling symbol: ",
                  $tracer->symbol_name($id),
                  "\n", '  Semantics are ', show_semantics(@raw_ops)
                  or Marpa::R3::exception('Cannot say to trace file handle');
                last PRINT_TRACES;
            } ## end if ( $type eq 'nulling' )
            if ( $type eq 'rule' ) {
                say {$trace_file_handle}
                  "Registering semantics for $type: ",
                  $tracer->show_rule($id),
                  '  Semantics are ', show_semantics(@raw_ops)
                  or Marpa::R3::exception('Cannot say to trace file handle');
                last PRINT_TRACES;
            }
            if ( $type eq 'token' ) {
                say {$trace_file_handle}
                  "Registering semantics for $type: ",
                  $tracer->symbol_name($id),
                  "\n", '  Semantics are ', show_semantics(@raw_ops)
                  or Marpa::R3::exception('Cannot say to trace file handle');
                last PRINT_TRACES;
            }
            say {$trace_file_handle} "Registration has unknown type: $type"
                  or Marpa::R3::exception('Cannot say to trace file handle');
        } ## end PRINT_TRACES:

        OP: for my $raw_op (@raw_ops) {
            if ( ref $raw_op ) {
                push @ops, $value->constant_register( ${$raw_op} );
                next OP;
            }
            push @ops, $raw_op;
        } ## end OP: for my $raw_op (@raw_ops)
        if ( $type eq 'token' ) {
            $value->token_register( $id, @ops );
            next REGISTRATION;
        }
        if ( $type eq 'nulling' ) {
            $value->nulling_symbol_register( $id, @ops );
            next REGISTRATION;
        }
        if ( $type eq 'rule' ) {
            $value->rule_register( $id, @ops );
            next REGISTRATION;
        }
        Marpa::R3::exception(
            'Registration: with unknown type: ',
            Data::Dumper::Dumper($registration)
        );
    } ## end REGISTRATION: for my $registration ( @{ $recce->[...]})

    STEP: while (1) {
        my ( $value_type, @value_data ) = $value->stack_step();

        if ($trace_values) {
            EVENT: while (1) {
                my $event = $value->event();
                last EVENT if not defined $event;
                my ( $event_type, @event_data ) = @{$event};
                if ( $event_type eq 'MARPA_STEP_TOKEN' ) {
                    my ( $token_id, $token_value_ix, $token_value ) = @event_data;
                    trace_token_evaluation( $slr, $value, $token_id,
                        $token_value );
                    next EVENT;
                } ## end if ( $event_type eq 'MARPA_STEP_TOKEN' )
                say {$trace_file_handle} join q{ },
                    'value event:',
                    map { $_ // 'undef' } $event_type, @event_data
                    or Marpa::R3::exception('say to trace handle failed');
            } ## end EVENT: while (1)

            if ( $trace_values >= 9 ) {
                for my $i ( reverse 0 .. $value->highest_index ) {
                    printf {$trace_file_handle} "Stack position %3d:\n", $i,
                        or
                        Marpa::R3::exception('print to trace handle failed');
                    print {$trace_file_handle} q{ },
                        Data::Dumper->new( [ \$value->absolute($i) ] )
                        ->Terse(1)->Dump
                        or
                        Marpa::R3::exception('print to trace handle failed');
                } ## end for my $i ( reverse 0 .. $value->highest_index )
            } ## end if ( $trace_values >= 9 )

        } ## end if ($trace_values)

        last STEP if not defined $value_type;
        next STEP if $value_type eq 'trace';

        if ( $value_type eq 'MARPA_STEP_NULLING_SYMBOL' ) {
            my ($token_id) = @value_data;
            my $value_ref = $nulling_closures->[$token_id];
            my $result;

            my @warnings;
            my $eval_ok;

            DO_EVAL: {
                local $SIG{__WARN__} = sub {
                    push @warnings, [ $_[0], ( caller 0 ) ];
                };

                $eval_ok = eval {
                    local $Marpa::R3::Context::rule =
                        $null_values->[$token_id];
                    $result = $value_ref->($semantics_arg0, []);
                    1;
                };

            } ## end DO_EVAL:

            if ( not $eval_ok or @warnings ) {
                my $fatal_error = $EVAL_ERROR;
                code_problems(
                    {   fatal_error => $fatal_error,
                        eval_ok     => $eval_ok,
                        warnings    => \@warnings,
                        where       => 'computing value',
                        long_where  => 'Computing value for null symbol: '
                            . $tracer->symbol_name($token_id),
                    }
                );
            } ## end if ( not $eval_ok or @warnings )

            $value->result_set($result);
            trace_token_evaluation( $slr, $value, $token_id, \$result )
                if $trace_values;
            next STEP;
        } ## end if ( $value_type eq 'MARPA_STEP_NULLING_SYMBOL' )

        if ( $value_type eq 'MARPA_STEP_RULE' ) {
            my ( $rule_id, $values ) = @value_data;
            my $closure = $rule_closures->[$rule_id];

            next STEP if not defined $closure;
            my $result;

                # TODO: DELETE THIS
                die if  ref $values ne 'ARRAY' ;

            if ( ref $closure eq 'CODE' ) {
                my @warnings;
                my $eval_ok;
                local $SIG{__WARN__} = sub {
                    push @warnings, [ $_[0], ( caller 0 ) ];
                };
                local $Marpa::R3::Context::rule = $rule_id;

                $eval_ok = eval {
                    $result = $closure->( $semantics_arg0, $values );
                    1;
                };

                if ( not $eval_ok or @warnings ) {
                    my $fatal_error = $EVAL_ERROR;
                    code_problems(
                        {
                            fatal_error => $fatal_error,
                            eval_ok     => $eval_ok,
                            warnings    => \@warnings,
                            where       => 'computing value',
                            long_where  => 'Computing value for rule: '
                              . $tracer->brief_rule($rule_id),
                        }
                    );
                } ## end if ( not $eval_ok or @warnings )
            } ## end if ( ref $closure eq 'CODE' )
            else {
                $result = ${$closure};
            }
            $value->result_set($result);

            if ($trace_values) {
                say {$trace_file_handle}
                    trace_stack_1( $slr, $value, $values,
                    $rule_id )
                    or Marpa::R3::exception('Could not print to trace file');
                print {$trace_file_handle}
                    'Calculated and pushed value: ',
                    Data::Dumper->new( [$result] )->Terse(1)->Dump
                    or Marpa::R3::exception('print to trace handle failed');
            } ## end if ($trace_values)

            next STEP;

        } ## end if ( $value_type eq 'MARPA_STEP_RULE' )

        if ( $value_type eq 'MARPA_STEP_TRACE' ) {

            if ( my $trace_output = trace_op( $slr, $value ) ) {
                print {$trace_file_handle} $trace_output
                    or Marpa::R3::exception('Could not print to trace file');
            }

            next STEP;

        } ## end if ( $value_type eq 'MARPA_STEP_TRACE' )

        die "Internal error: Unknown value type $value_type";

    } ## end STEP: while (1)

    return \( $value->absolute(0) );

}

# INTERNAL OK AFTER HERE _marpa_

sub Marpa::R3::Scanless::R::and_node_tag {
    my ( $slr, $and_node_id ) = @_;
    my $bocage            = $slr->[Marpa::R3::Internal::Scanless::R::B_C];
    my $recce_c           = $slr->[Marpa::R3::Internal::Scanless::R::R_C];
    my $parent_or_node_id = $bocage->_marpa_b_and_node_parent($and_node_id);
    my $origin         = $bocage->_marpa_b_or_node_origin($parent_or_node_id);
    my $origin_earleme = $recce_c->earleme($origin);
    my $current_earley_set =
        $bocage->_marpa_b_or_node_set($parent_or_node_id);
    my $current_earleme = $recce_c->earleme($current_earley_set);
    my $cause_id        = $bocage->_marpa_b_and_node_cause($and_node_id);
    my $predecessor_id = $bocage->_marpa_b_and_node_predecessor($and_node_id);

    my $middle_earley_set = $bocage->_marpa_b_and_node_middle($and_node_id);
    my $middle_earleme    = $recce_c->earleme($middle_earley_set);

    my $position = $bocage->_marpa_b_or_node_position($parent_or_node_id);
    my $irl_id   = $bocage->_marpa_b_or_node_irl($parent_or_node_id);

#<<<  perltidy introduces trailing space on this
    my $tag =
          'R'
        . $irl_id . q{:}
        . $position . q{@}
        . $origin_earleme . q{-}
        . $current_earleme;
#>>>
    if ( defined $cause_id ) {
        my $cause_irl_id = $bocage->_marpa_b_or_node_irl($cause_id);
        $tag .= 'C' . $cause_irl_id;
    }
    else {
        my $symbol = $bocage->_marpa_b_and_node_symbol($and_node_id);
        $tag .= 'S' . $symbol;
    }
    $tag .= q{@} . $middle_earleme;
    return $tag;
}

sub trace_token_evaluation {
    my ( $slr, $value, $token_id, $token_value ) = @_;
    my $slg = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
    my $tracer =
        $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];
    my $trace_file_handle =
        $slr->[Marpa::R3::Internal::Scanless::R::TRACE_FILE_HANDLE];

    my $order   = $slr->[Marpa::R3::Internal::Scanless::R::O_C];
    my $tree    = $slr->[Marpa::R3::Internal::Scanless::R::T_C];

    my $nook_ix = $value->_marpa_v_nook();
    if ( not defined $nook_ix ) {
        print {$trace_file_handle} "Nulling valuator\n"
            or Marpa::R3::exception('Could not print to trace file');
        return;
    }
    my $or_node_id = $tree->_marpa_t_nook_or_node($nook_ix);
    my $choice     = $tree->_marpa_t_nook_choice($nook_ix);
    my $and_node_id =
        $order->_marpa_o_and_node_order_get( $or_node_id, $choice );
    my $token_name;
    if ( defined $token_id ) {
        $token_name = $tracer->symbol_name($token_id);
    }

    print {$trace_file_handle}
        'Pushed value from ',
        $slr->and_node_tag( $and_node_id ),
        ': ',
        ( $token_name ? qq{$token_name = } : q{} ),
        Data::Dumper->new( [ \$token_value ] )->Terse(1)->Dump
        or Marpa::R3::exception('print to trace handle failed');

    return;

} ## end sub trace_token_evaluation

sub trace_stack_1 {
    my ( $slr, $value, $args, $rule_id ) = @_;
    my $recce_c = $slr->[Marpa::R3::Internal::Scanless::R::R_C];
    my $slg = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
    my $tracer =
        $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];
    my $bocage  = $slr->[Marpa::R3::Internal::Scanless::R::B_C];
    my $order   = $slr->[Marpa::R3::Internal::Scanless::R::O_C];
    my $tree    = $slr->[Marpa::R3::Internal::Scanless::R::T_C];

    my $argc       = scalar @{$args};
    my $nook_ix    = $value->_marpa_v_nook();
    my $or_node_id = $tree->_marpa_t_nook_or_node($nook_ix);
    my $choice     = $tree->_marpa_t_nook_choice($nook_ix);
    my $and_node_id =
        $order->_marpa_o_and_node_order_get( $or_node_id, $choice );

    return 'Popping ', $argc,
        ' values to evaluate ',
        $slr->and_node_tag( $and_node_id ),
        ', rule: ', $tracer->brief_rule($rule_id);

} ## end sub trace_stack_1

sub trace_op {

    my ( $slr, $value ) = @_;
    my $slg = $slr->[Marpa::R3::Internal::Scanless::R::SLG];
    my $tracer = $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER];

    my $trace_output = q{};
    my $trace_values =
        $slr->[Marpa::R3::Internal::Scanless::R::TRACE_VALUES] // 0;

    return $trace_output if not $trace_values >= 2;

    my $grammar_c = $tracer->[Marpa::R3::Internal::Trace::G::C];
    my $bocage    = $slr->[Marpa::R3::Internal::Scanless::R::B_C];
    my $order     = $slr->[Marpa::R3::Internal::Scanless::R::O_C];
    my $tree      = $slr->[Marpa::R3::Internal::Scanless::R::T_C];

    my $nook_ix    = $value->_marpa_v_nook();
    my $or_node_id = $tree->_marpa_t_nook_or_node($nook_ix);
    my $choice     = $tree->_marpa_t_nook_choice($nook_ix);
    my $and_node_id =
        $order->_marpa_o_and_node_order_get( $or_node_id, $choice );
    my $trace_irl_id = $bocage->_marpa_b_or_node_irl($or_node_id);
    my $virtual_rhs  = $grammar_c->_marpa_g_irl_is_virtual_rhs($trace_irl_id);
    my $virtual_lhs  = $grammar_c->_marpa_g_irl_is_virtual_lhs($trace_irl_id);

    return $trace_output
        if $bocage->_marpa_b_or_node_position($or_node_id)
        != $grammar_c->_marpa_g_irl_length($trace_irl_id);

    return $trace_output if not $virtual_rhs and not $virtual_lhs;

    if ( $virtual_rhs and not $virtual_lhs ) {

        $trace_output .= join q{},
            'Head of Virtual Rule: ',
            $slr->and_node_tag( $and_node_id ),
            ', rule: ', $tracer->brief_irl($trace_irl_id),
            "\n",
            'Incrementing virtual rule by ',
            $grammar_c->_marpa_g_real_symbol_count($trace_irl_id), ' symbols',
            "\n"
            or Marpa::R3::exception('Could not print to trace file');

        return $trace_output;

    } ## end if ( $virtual_rhs and not $virtual_lhs )

    if ( $virtual_lhs and $virtual_rhs ) {

        $trace_output .= join q{},
            'Virtual Rule: ',
            $slr->and_node_tag( $and_node_id ),
            ', rule: ', $tracer->brief_irl($trace_irl_id),
            "\nAdding ",
            $grammar_c->_marpa_g_real_symbol_count($trace_irl_id),
            "\n";

        return $trace_output;

    } ## end if ( $virtual_lhs and $virtual_rhs )

    if ( not $virtual_rhs and $virtual_lhs ) {

        $trace_output .= join q{},
            'New Virtual Rule: ',
            $slr->and_node_tag( $and_node_id ),
            ', rule: ', $tracer->brief_irl($trace_irl_id),
            "\nReal symbol count is ",
            $grammar_c->_marpa_g_real_symbol_count($trace_irl_id),
            "\n";

        return $trace_output;

    } ## end if ( not $virtual_rhs and $virtual_lhs )

    return $trace_output;
} ## end sub trace_op

sub value_trace {
    my ( $value, $trace_flag ) = @_;
    return $value->_marpa_v_trace($trace_flag);
}

1;

# vim: expandtab shiftwidth=4:
