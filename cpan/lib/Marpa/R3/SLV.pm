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
$VERSION        = '4.001_050';
$STRING_VERSION = $VERSION;
## no critic(BuiltinFunctions::ProhibitStringyEval)
$VERSION = eval $VERSION;
## use critic

package Marpa::R3::Internal_V;

use Scalar::Util qw(blessed tainted);
use English qw( -no_match_vars );

our $PACKAGE = 'Marpa::R3::Scanless::V';

# Set those common args which are at the Perl level.
sub slv_common_set {
    my ( $slv, $flat_args ) = @_;
    if ( my $value = $flat_args->{'trace_file_handle'} ) {
        $slv->[Marpa::R3::Internal_V::TRACE_FILE_HANDLE] = $value;
    }
    my $trace_file_handle =
      $slv->[Marpa::R3::Internal_V::TRACE_FILE_HANDLE];
    delete $flat_args->{'trace_file_handle'};
    return $flat_args;
}

our $CONTEXT_EXCEPTION_CLASS = __PACKAGE__ . '::Context_Exception';

sub Marpa::R3::Context::bail {   ## no critic (Subroutines::RequireArgUnpacking)
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
    my $slv = $Marpa::R3::Context::valuer;
    my ( $start, $end ) =
      $slv->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ), <<'END_OF_LUA', '>*' );
local slv = ...
return slv.this_step.start_es_id, slv.this_step.es_id
END_OF_LUA
    return $start, $end;
} ## end sub Marpa::R3::Context::g1_range

sub Marpa::R3::Context::lc_range {
    my $slv = $Marpa::R3::Context::valuer;
    my ( $lc_range ) =
      $slv->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ), <<'END_OF_LUA', '>*' );
local slv = ...
local slr = slv.slr
local g1_first = slv.this_step.start_es_id
local g1_last = slv.this_step.es_id - 1
local l0_first_b, l0_first_p = slr:g1_to_block_first(g1_first)
local l0_last_b, l0_last_p = slr:g1_to_block_last(g1_last)
return slr:lc_range_brief(l0_first_b, l0_first_p, l0_last_b, l0_last_p)
END_OF_LUA
    return $lc_range;
}

sub Marpa::R3::Context::g1_span {
    my $slv = $Marpa::R3::Context::valuer;
    my ( $start, $length ) =
      $slv->call_by_tag( ( '@' . __FILE__ . ':' . __LINE__ ), <<'END_OF_LUA', '>*' );
local slv = ...
local start = slv.this_step.start_es_id + 0
local length = (start - slv.this_step.es_id) + 1
return start, length
END_OF_LUA
    return $start, $length;
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
        my ( $warning, $package, $filename, $problem_line ) = @{$warning_data};
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

}

sub Marpa::R3::Scanless::V::new {
    my ( $class, @args ) = @_;

    my $slv = [];

    # Set recognizer args to default
    # Lua equivalent is set below

    my ( $flat_args, $error_message ) = Marpa::R3::flatten_hash_args( \@args );
    Marpa::R3::exception( sprintf $error_message, '$slv->new' )
      if not $flat_args;
    $flat_args = slv_common_set( $slv, $flat_args );

    my $slr = $flat_args->{recognizer};
    Marpa::R3::exception(
        qq{Marpa::R3::Scanless::V::new() called without a "recognizer" argument} )
      if not defined $slr;
    $slv->[Marpa::R3::Internal_V::SLR] = $slr;
    delete $flat_args->{recognizer};

    my $slr_class = 'Marpa::R3::Scanless::R';
    if ( not blessed $slr or not $slr->isa($slr_class) ) {
        my $ref_type = ref $slr;
        my $desc = $ref_type ? "a ref to $ref_type" : 'not a ref';
        Marpa::R3::exception(
            qq{'recognizer' named argument to new() is $desc\n},
            "  It should be a ref to $slr_class\n"
        );
    }

    $slv->[Marpa::R3::Internal_V::TRACE_FILE_HANDLE] //=
      $slr->[Marpa::R3::Internal_R::TRACE_FILE_HANDLE];

    my $trace_file_handle =
      $slv->[Marpa::R3::Internal_V::TRACE_FILE_HANDLE];

    my $lua = $slr->[Marpa::R3::Internal_R::L];
    $slv->[Marpa::R3::Internal_V::L] = $lua;

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
            local slv = slr:slv_new(flat_args)
            if not slv then return 'ok', -1 end
            return 'ok', slv.regix
        end)
END_OF_LUA

    return if $regix < 0;
    $slv->[Marpa::R3::Internal_V::REGIX]  = $regix;

    return bless $slv, $class;
}

sub Marpa::R3::Scanless::V::DESTROY {
    # say STDERR "In Marpa::R3::Scanless::V::DESTROY before test";
    my $slv = shift;
    my $lua = $slv->[Marpa::R3::Internal_V::L];

    # If we are destroying the Perl interpreter, then all the Marpa
    # objects will be destroyed, including Marpa's Lua interpreter.
    # We do not need to worry about cleaning up the
    # recognizer is an orderly manner, because the Lua interpreter
    # containing the recognizer will be destroyed.
    # In fact, the Lua interpreter may already have been destroyed,
    # so this test is necessary to avoid a warning message.
    return if not $lua;
    # say STDERR "In Marpa::R3::Scanless::V::DESTROY after test";

    my $regix = $slv->[Marpa::R3::Internal_V::REGIX];
    $slv->call_by_tag(
        ('@' . __FILE__ . ':' . __LINE__),
        <<'END_OF_LUA', '');
    local slv = ...
    local regix = slv.regix
    _M.unregister(_M.registry, regix)
END_OF_LUA
}

sub Marpa::R3::Scanless::V::set {
    my ( $slv, @args ) = @_;

    my ($flat_args, $error_message) = Marpa::R3::flatten_hash_args(\@args);
    Marpa::R3::exception( sprintf $error_message, '$slv->set()' ) if not $flat_args;
    $flat_args = slv_common_set($slv, $flat_args);
    my $trace_file_handle =
      $slv->[Marpa::R3::Internal_V::TRACE_FILE_HANDLE];

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
    return;
}

# Returns false if no parse
sub Marpa::R3::Scanless::V::value {
    my ( $slv, $per_parse_arg ) = @_;
    my $slr    = $slv->[Marpa::R3::Internal_V::SLR];
    my $slg    = $slr->[Marpa::R3::Internal_R::SLG];

    my $trace_actions =
      $slg->[Marpa::R3::Internal_G::TRACE_ACTIONS] // 0;
    my $trace_file_handle =
      $slv->[Marpa::R3::Internal_V::TRACE_FILE_HANDLE];

        my $semantics_arg0 = $per_parse_arg // {};
        my $constants = $slg->[Marpa::R3::Internal_G::CONSTANTS];
        my $null_values = $slg->[Marpa::R3::Internal_G::NULL_VALUES];
        my $nulling_closures =
          $slg->[Marpa::R3::Internal_G::CLOSURE_BY_SYMBOL_ID];
        my $rule_closures =
          $slg->[Marpa::R3::Internal_G::CLOSURE_BY_RULE_ID];

    local $Marpa::R3::Context::rule = undef;
    local $Marpa::R3::Context::irlid = undef;
    local $Marpa::R3::Context::grammar = $slg;
    local $Marpa::R3::Context::recognizer  = $slr;
    local $Marpa::R3::Context::valuer  = $slv;

    my %value_handlers = (
        trace => sub {
            my ($msg) = @_;
            my $nl = ( $msg =~ /\n\z/xms ) ? '' : "\n";
            print {$trace_file_handle} $msg, $nl;
            return 'ok';
        },
        terse_dump => sub {
            my ($value) = @_;
            my $dumped = Data::Dumper->new( [$value] )->Terse(1)->Dump;
            chomp $dumped;
            return 'ok', $dumped;
        },
        constant => sub {
            my ($constant_ix) = @_;
            my $constant = $constants->[$constant_ix];
            return 'sig', [ 'S', $constant ];
        },
        perl_undef => sub {
            return 'sig', [ 'S', undef ];
        },
        bless => sub {
            my ( $value, $blessing_ix ) = @_;
            my $blessing = $constants->[$blessing_ix];
            return 'sig', [ 'S', ( bless $value, $blessing ) ];
        },
        perl_nulling_semantics => sub {
            my ($token_id) = @_;
            my $value_ref = $nulling_closures->[$token_id];
            my $result;
            my @warnings;
            my $eval_ok;
          DO_EVAL: {
                local $SIG{__WARN__} = sub {
                    push @warnings, [ $_[0], ( caller 0 ) ];
                };
                $eval_ok = eval {
                    my $irlid = $null_values->[$token_id];
                    local $Marpa::R3::Context::irlid = $irlid;
                    local $Marpa::R3::Context::production_id =
                      $slg->g1_rule_to_production_id($irlid);
                    $result = $value_ref->( $semantics_arg0, [] );
                    1;
                };
            } ## end DO_EVAL:
            if ( not $eval_ok or @warnings ) {
                my $fatal_error = $EVAL_ERROR;
                code_problems(
                    {
                        fatal_error => $fatal_error,
                        eval_ok     => $eval_ok,
                        warnings    => \@warnings,
                        where       => 'computing value',
                        long_where  => 'Computing value for null symbol: '
                          . $slg->g1_symbol_display($token_id),
                    }
                );
            } ## end if ( not $eval_ok or @warnings )
            return 'sig', [ 'S', $result ];
        },
        perl_rule_semantics => sub {
            my ( $irlid, $values ) = @_;
            # say Data::Dumper::Dumper($values);
            my $closure = $rule_closures->[$irlid];
            my $result;
            if ( defined $closure ) {
                my @warnings;
                my $eval_ok;
                local $SIG{__WARN__} = sub {
                    push @warnings, [ $_[0], ( caller 0 ) ];
                };
                local $Marpa::R3::Context::irlid = $irlid;
                local $Marpa::R3::Context::production_id =
                  $slg->g1_rule_to_production_id($irlid);
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
                              . $slg->g1_rule_show($irlid),
                        }
                    );
                } ## end if ( not $eval_ok or @warnings )
            }
            return 'sig', [ 'S', $result ];
        }
    );

    my ($cmd, $final_value) =
 $slv->coro_by_tag(
        ( '@' . __FILE__ . ':' . __LINE__ ),
        {
            signature => '',
            args      => [],
            handlers  => \%value_handlers
        },
        <<'END_OF_LUA');
        local slv = ...
        return slv:value()
END_OF_LUA

    return if $cmd ne 'ok';
    return \($final_value);

}

# not to be documented
sub Marpa::R3::Scanless::V::call_by_tag {
    my ( $slv, $tag, $codestr, $signature, @args ) = @_;
    my $lua   = $slv->[Marpa::R3::Internal_V::L];
    my $regix = $slv->[Marpa::R3::Internal_V::REGIX];

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
    my $lua        = $slv->[Marpa::R3::Internal_V::L];
    my $regix      = $slv->[Marpa::R3::Internal_V::REGIX];
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
    my $slr = $slv->[Marpa::R3::Internal_V::SLR];

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
    my $slr = $slv->[Marpa::R3::Internal_V::SLR];
    my $slg = $slr->[Marpa::R3::Internal_R::SLG];

    my ($text, $nrl_id, $position)
        = $slv->call_by_tag(
    ('@' . __FILE__ . ':' . __LINE__),
        <<'END_OF_LUA', 'i', $or_node_id);
        local slv, or_node_id = ...
        local slr = slv.slr
        local bocage = slv.lmw_b
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
    my $slr = $slv->[Marpa::R3::Internal_V::SLR];
    my $ambiguity_level = $slv->ambiguity_level();
    return q{No parse} if $ambiguity_level <= 0;
    return q{} if $ambiguity_level == 1;
    # ASF must be created for end location of SLV (not SLR!)
    my $asf = Marpa::R3::ASF->new( { recognizer => $slr, end => $slv->g1_pos() } );
    die 'Could not create ASF' if not defined $asf;
    my $ambiguities = Marpa::R3::Internal::ASF::ambiguities($asf);
    my @ambiguities = grep {defined} @{$ambiguities}[ 0 .. 1 ];
    return Marpa::R3::Internal::ASF::ambiguities_show( $asf, \@ambiguities );
} ## end sub Marpa::R3::Scanless::R::ambiguous

sub Marpa::R3::Scanless::V::ambiguity_level {
    my ($slv) = @_;

    my ($metric) = $slv->call_by_tag(
    ('@' . __FILE__ . ':' . __LINE__),
    <<'END__OF_LUA', '>*' );
    local slv = ...
    return slv:ambiguity_level()
END__OF_LUA
    return $metric;
}

sub Marpa::R3::Scanless::V::g1_pos {
    my ( $slv ) = @_;
    my ($g1_pos) = $slv->call_by_tag(
    ('@' . __FILE__ . ':' . __LINE__),
    <<'END__OF_LUA', '>*' );
    local slv = ...
    return slv:g1_pos()
END__OF_LUA
    return $g1_pos;
}

# not to be documented
sub Marpa::R3::Scanless::V::regix {
    my ( $slv ) = @_;
    my $regix = $slv->[Marpa::R3::Internal_V::REGIX];
    return $regix;
}

1;

# vim: expandtab shiftwidth=4:
