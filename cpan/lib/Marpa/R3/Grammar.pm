# Copyright 2016 Jeffrey Kegler
# This file is part of Marpa::R3.  Marpa::R3 is free software: you can
# redistribute it and/or modify it under the terms of the GNU Lesser
# General Public License as published by the Free Software Foundation,
# either version 3 of the License, or (at your option) any later version.
#
# Marpa::R3 is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser
# General Public License along with Marpa::R3.  If not, see
# http://www.gnu.org/licenses/.

package Marpa::R3::Grammar;

use 5.010001;

use warnings;

# There's a problem with this perlcritic check
# as of 9 Aug 2010
no warnings qw(recursion qw);

use strict;

use vars qw($VERSION $STRING_VERSION);
$VERSION        = '4.001_002';
$STRING_VERSION = $VERSION;
## no critic(BuiltinFunctions::ProhibitStringyEval)
$VERSION = eval $VERSION;
## use critic

package Marpa::R3::Internal::Grammar;

use English qw( -no_match_vars );

use Marpa::R3::Trace::G;

our %DEFAULT_SYMBOLS_RESERVED;
%DEFAULT_SYMBOLS_RESERVED = map { ($_, 1) } split //xms, '}]>)';

sub Marpa::R3::uncaught_error {
    my ($error) = @_;

    # This would be Carp::confess, but in the testing
    # the stack trace includes the hoped for error
    # message, which causes spurious success reports.
    Carp::croak( "libmarpa reported an error which Marpa::R3 did not catch\n",
        $error );
} ## end sub Marpa::R3::uncaught_error

package Marpa::R3::Internal::Grammar;

sub Marpa::R3::Grammar::g1_naif_new {
    my ( $class, $slg, $flat_args ) = @_;

    my $grammar = [];
    bless $grammar, $class;


    my $grammar_c = Marpa::R3::Thin::G->new( { if => 1 } );
    my $tracer = $grammar->[Marpa::R3::Internal::Grammar::TRACER] =
        $slg->[Marpa::R3::Internal::Scanless::G::G1_TRACER] =
        Marpa::R3::Trace::G->new($grammar_c);
    $tracer->[Marpa::R3::Internal::Trace::G::XSY_BY_ISYID] = [];
    $tracer->[Marpa::R3::Internal::Trace::G::RULES] = [];

    $grammar->g1_naif_set($slg, $flat_args);
    $tracer->[Marpa::R3::Internal::Trace::G::START_NAME] = '[:start]';
    $tracer->[Marpa::R3::Internal::Trace::G::NAME] = 'G1';

    return $grammar;
} ## end sub Marpa::R3::Grammar::new

sub Marpa::R3::Grammar::l0_naif_new {
    my ( $class, $slg, $start_name, $symbols, $rules ) = @_;

    my $grammar = [];
    bless $grammar, $class;

    my $grammar_c = Marpa::R3::Thin::G->new( { if => 1 } );
    my $tracer = $grammar->[Marpa::R3::Internal::Grammar::TRACER] =
        $slg->[Marpa::R3::Internal::Scanless::G::L0_TRACER] =
        Marpa::R3::Trace::G->new($grammar_c);
    $tracer->[Marpa::R3::Internal::Trace::G::XSY_BY_ISYID] = [];
    $tracer->[Marpa::R3::Internal::Trace::G::RULES] = [];
    $tracer->[Marpa::R3::Internal::Trace::G::START_NAME] = '[:start_lex]';
    $tracer->[Marpa::R3::Internal::Trace::G::NAME] = 'L0';

    for my $symbol ( sort keys %{$symbols} ) {
        my $properties = $symbols->{$symbol};
        assign_symbol( $slg, $grammar, $symbol, $properties );
    }

    add_user_rules( $slg, $grammar, $rules );

    return $grammar;
} ## end sub Marpa::R3::Grammar::new

sub Marpa::R3::Grammar::tracer {
    return $_[0]->[Marpa::R3::Internal::Grammar::TRACER];
}

sub Marpa::R3::Grammar::thin_symbol {
    my ( $grammar, $symbol_name ) = @_;
    return $grammar->[Marpa::R3::Internal::Grammar::TRACER]
        ->symbol_by_name($symbol_name);
}

sub Marpa::R3::Grammar::g1_naif_set {
    my ( $grammar, $slg, $flat_args ) = @_;

    my $tracer = $grammar->[Marpa::R3::Internal::Grammar::TRACER];
    my $grammar_c = $tracer->[Marpa::R3::Internal::Trace::G::C];

    if ( defined( my $value = $flat_args->{'symbols'} ) ) {
        for my $symbol ( sort keys %{$value} ) {
            my $properties = $value->{$symbol};
            assign_symbol( $slg, $grammar, $symbol, $properties );
        }
        delete $flat_args->{'symbols'};
    } ## end if ( defined( my $value = $flat_args->{'symbols'} ) )

    if ( defined( my $value = $flat_args->{'start'} ) ) {
        # TODO delete this
        delete $flat_args->{'start'};
    } ## end if ( defined( my $value = $flat_args->{'start'} ) )

    if ( defined( my $value = $flat_args->{'rules'} ) ) {
        add_user_rules( $slg, $grammar, $value );
        delete $flat_args->{'rules'};
    } ## end if ( defined( my $value = $flat_args->{'rules'} ) )

    my @bad_arguments = keys %{$flat_args};
    if (scalar @bad_arguments) {
        Marpa::R3::exception(
            q{Internal error: Bad named argument(s) to $naif_grammar->set() method}
                . join q{ },
            @bad_arguments
        );
    }

    return 1;
} ## end sub Marpa::R3::Grammar::set

sub assign_symbol {
    # $slg will be needed for the XSY's
    my ( $slg, $grammar, $name, $options ) = @_;

    my $tracer = $grammar->[Marpa::R3::Internal::Grammar::TRACER];
    my $grammar_c = $tracer->[Marpa::R3::Internal::Trace::G::C];
    my $symbol_id = $tracer->symbol_by_name($name);
    if ( defined $symbol_id ) {
        return $symbol_id;
    }
    $symbol_id = $tracer->symbol_new($name);

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
            $grammar_c->symbol_is_terminal_set( $symbol_id, $value );
            next PROPERTY;
        }
        if ( $property eq 'rank' ) {
            my $value = $options->{$property};
            Marpa::R3::exception(qq{Symbol "$name": rank must be an integer})
                if not Scalar::Util::looks_like_number($value)
                    or int($value) != $value;
            $grammar_c->symbol_rank_set($symbol_id) = $value;
            next PROPERTY;
        } ## end if ( $property eq 'rank' )
        Marpa::R3::exception(qq{Unknown symbol property "$property"});
    } ## end PROPERTY: for my $property ( keys %{$options} )

    return $symbol_id;

} ## end sub assign_symbol

# add one or more rules
sub add_user_rules {
    my ( $slg, $grammar, $rules ) = @_;

    for my $rule (@{$rules}) {
        add_user_rule( $slg, $grammar, $rule );
    }

    return;

} ## end sub add_user_rules

sub add_user_rule {
    my ( $slg, $grammar, $options ) = @_;

    Marpa::R3::exception('Missing argument to add_user_rule')
        if not defined $grammar
        or not defined $options;

    my $tracer = $grammar->[Marpa::R3::Internal::Grammar::TRACER];
    my $grammar_c = $tracer->[Marpa::R3::Internal::Trace::G::C];
    my $rules = $tracer->[Marpa::R3::Internal::Trace::G::RULES];
    my $default_rank = $grammar_c->default_rank();

    my ( $lhs_name, $rhs_names, $action, $blessing );
    my ( $min, $separator_name );
    my $rank;
    my $null_ranking;
    my $rule_name;
    my $slif_tag;
    my $mask;
    my $proper_separation = 0;
    my $keep_separation   = 0;

  OPTION: for my $option ( keys %{$options} ) {
        my $value = $options->{$option};
        if ( $option eq 'xaltid' )   {
            # TODO expand this
            next OPTION;
        }
        if ( $option eq 'name' )   { $rule_name = $value; next OPTION; }
        if ( $option eq 'tag' )    { $slif_tag  = $value; next OPTION; }
        if ( $option eq 'rhs' )    { $rhs_names = $value; next OPTION }
        if ( $option eq 'lhs' )    { $lhs_name  = $value; next OPTION }
        if ( $option eq 'action' ) { $action    = $value; next OPTION }
        if ( $option eq 'bless' )  { $blessing  = $value; next OPTION }
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
        if ( $option eq 'keep' ) { $keep_separation = $value; next OPTION }
        if ( $option eq 'mask' ) { $mask            = $value; next OPTION }
        if ( $option eq 'description' ) {

            # TODO: Delete this once description field eliminated
            next OPTION;
        }
        Marpa::R3::exception("Unknown user rule option: $option");
    } ## end OPTION: for my $option ( keys %{$options} )

    if ( defined $min and not Scalar::Util::looks_like_number($min) ) {
        Marpa::R3::exception(
            q{"min" must be undefined or a valid Perl number});
    }

    $rhs_names //= [];

    my @rule_problems = ();

    my $rhs_ref_type = ref $rhs_names;
    if ( not $rhs_ref_type or $rhs_ref_type ne 'ARRAY' ) {
        my $problem =
              "RHS is not ref to ARRAY\n"
            . '  Type of rhs is '
            . ( $rhs_ref_type ? $rhs_ref_type : 'not a ref' ) . "\n";
        my $d = Data::Dumper->new( [$rhs_names], ['rhs'] );
        $problem .= $d->Dump();
        push @rule_problems, $problem;
    } ## end if ( not $rhs_ref_type or $rhs_ref_type ne 'ARRAY' )
    if ( not defined $lhs_name ) {
        push @rule_problems, "Missing LHS\n";
    }

    if ( defined $rank
        and
        ( not Scalar::Util::looks_like_number($rank) or int($rank) != $rank )
        )
    {
        push @rule_problems, "Rank must be undefined or an integer\n";
    } ## end if ( defined $rank and ( not Scalar::Util::looks_like_number...))
    $rank //= $default_rank;

    $null_ranking //= 'low';
    if ( $null_ranking ne 'high' and $null_ranking ne 'low' ) {
        push @rule_problems,
            "Null Ranking must be undefined, 'high' or 'low'\n";
    }

    if ( scalar @rule_problems ) {
        my %dump_options = %{$options};
        delete $dump_options{grammar};
        my $msg = ( scalar @rule_problems )
            . " problem(s) in the following rule:\n";
        my $d = Data::Dumper->new( [ \%dump_options ], ['rule'] );
        $msg .= $d->Dump();
        for my $problem_number ( 0 .. $#rule_problems ) {
            $msg
                .= 'Problem '
                . ( $problem_number + 1 ) . q{: }
                . $rule_problems[$problem_number] . "\n";
        } ## end for my $problem_number ( 0 .. $#rule_problems )
        Marpa::R3::exception($msg);
    } ## end if ( scalar @rule_problems )


    # Is this is an ordinary, non-counted rule?
    my $is_ordinary_rule = scalar @{$rhs_names} == 0 || !defined $min;
    if ( defined $separator_name and $is_ordinary_rule ) {
        if ( defined $separator_name ) {
            Marpa::R3::exception(
                'separator defined for rule without repetitions');
        }
    } ## end if ( defined $separator_name and $is_ordinary_rule )

    my @rhs_ids = map {
                assign_symbol( $slg, $grammar, $_ )
        } @{$rhs_names};
    my $lhs_id = assign_symbol( $slg, $grammar, $lhs_name );

    my $base_rule_id;
    my $separator_id = -1;

    if ($is_ordinary_rule) {

        # Capture errors
        $grammar_c->throw_set(0);
        $base_rule_id = $grammar_c->rule_new( $lhs_id, \@rhs_ids );
        $grammar_c->throw_set(1);

    } ## end if ($is_ordinary_rule)
    else {
        Marpa::R3::exception('Only one rhs symbol allowed for counted rule')
            if scalar @{$rhs_names} != 1;

        # create the separator symbol, if we're using one
        if ( defined $separator_name ) {
            $separator_id = assign_symbol( $slg, $grammar, $separator_name ) ;
        } ## end if ( defined $separator_name )

        $grammar_c->throw_set(0);

        # The original rule for a sequence rule is
        # not actually used in parsing,
        # but some of the rewritten sequence rules are its
        # semantic equivalents.

        $base_rule_id = $grammar_c->sequence_new(
            $lhs_id,
            $rhs_ids[0],
            {   separator => $separator_id,
                proper    => $proper_separation,
                min       => $min,
            }
        );
        $grammar_c->throw_set(1);
    } ## end else [ if ($is_ordinary_rule) ]

    if ( not defined $base_rule_id or $base_rule_id < 0 ) {
        my $rule_description = rule_describe( $lhs_name, $rhs_names );
        my ( $error_code, $error_string ) = $grammar_c->error();
        $error_code //= -1;
        my $problem_description =
            $error_code == $Marpa::R3::Error::DUPLICATE_RULE
            ? 'Duplicate rule'
            : $error_string;
        Marpa::R3::exception("$problem_description: $rule_description");
    } ## end if ( not defined $base_rule_id or $base_rule_id < 0 )

    my $base_rule = $tracer->shadow_rule( $base_rule_id );

    if ($is_ordinary_rule) {

        # Only internal grammars can set a custom mask
        if ( not defined $mask ) {
            $mask = [ (1) x scalar @rhs_ids ];
        }
        $base_rule->[Marpa::R3::Internal::Rule::MASK] = $mask;
    } ## end if ($is_ordinary_rule)

    $base_rule->[Marpa::R3::Internal::Rule::DISCARD_SEPARATION] =
        $separator_id >= 0 && !$keep_separation;

    $base_rule->[Marpa::R3::Internal::Rule::ACTION_NAME] = $action;
    $grammar_c->rule_null_high_set( $base_rule_id,
        ( $null_ranking eq 'high' ? 1 : 0 ) );
    $grammar_c->rule_rank_set( $base_rule_id, $rank );

    if ( defined $rule_name ) {
        $base_rule->[Marpa::R3::Internal::Rule::NAME] = $rule_name;
    }
    if ( defined $slif_tag ) {
        $base_rule->[Marpa::R3::Internal::Rule::SLIF_TAG] = $slif_tag;
    } ## end if ( defined $slif_tag )
    if ( defined $blessing ) {
        $base_rule->[Marpa::R3::Internal::Rule::BLESSING] = $blessing;
    }

    return;

}

sub rule_describe {
    my ( $lhs_name, $rhs_names ) = @_;
    # wrap symbol names with whitespaces allowed by SLIF
    $lhs_name = "<$lhs_name>" if $lhs_name =~ / /;
    return "$lhs_name -> " . ( join q{ }, map { / / ? "<$_>" : $_ } @{$rhs_names} );
} ## end sub rule_describe

# INTERNAL OK AFTER HERE _marpa_
1;

# vim: expandtab shiftwidth=4:
