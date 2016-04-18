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

package Marpa::R3::Recognizer;

use 5.010001;
use warnings;
use strict;
use English qw( -no_match_vars );

use vars qw($VERSION $STRING_VERSION);
$VERSION        = '4.001_000';
$STRING_VERSION = $VERSION;
## no critic(BuiltinFunctions::ProhibitStringyEval)
$VERSION = eval $VERSION;
## use critic

package Marpa::R3::Internal::Recognizer;

use English qw( -no_match_vars );

my $parse_number = 0;

# Not documented, at least for the moment
sub Marpa::R3::Recognizer::grammar {
    $_[0]->[Marpa::R3::Internal::Recognizer::GRAMMAR];
}

sub Marpa::R3::Recognizer::thin {
    $_[0]->[Marpa::R3::Internal::Recognizer::C];
}

# For the non-legacy case,
# I reset the ordering, forcing it to be recalculated
# for each parse series.
# But I do not actually allow the ranking method to
# be changed once a parse is created.
# Since I am stabilizing Marpa::R3, the "fix" should
# probably be to save the overhead, rather than
# to allow 'ranking_method' to be changed.
# But for now I will do nothing.
# JK -- Mon Nov 24 17:35:24 PST 2014
sub Marpa::R3::Scanless::R::reset_evaluation {
    my ($slr) = @_;
    my $recce =
        $slr->[Marpa::R3::Internal::Scanless::R::THICK_G1_RECCE];
    my $grammar = $recce->[Marpa::R3::Internal::Recognizer::GRAMMAR];
    my $package_source =
        $slr->[Marpa::R3::Internal::Scanless::R::RESOLVE_PACKAGE_SOURCE];
    if ( defined $package_source ) {
        $slr->[Marpa::R3::Internal::Scanless::R::RESOLVE_PACKAGE_SOURCE] =
            undef;
    } ## end if ( defined $package_source and $package_source ne ...)
    $slr->[Marpa::R3::Internal::Scanless::R::NO_PARSE]          = undef;
    $recce->[Marpa::R3::Internal::Recognizer::B_C]                   = undef;
    $recce->[Marpa::R3::Internal::Recognizer::O_C]                   = undef;
    $slr->[Marpa::R3::Internal::Scanless::R::PER_PARSE_CONSTRUCTOR] = undef;
    $slr->[Marpa::R3::Internal::Scanless::R::RESOLVE_PACKAGE]       = undef;
    $slr->[Marpa::R3::Internal::Scanless::R::NULL_VALUES]        = undef;

    $slr->[Marpa::R3::Internal::Scanless::R::REGISTRATIONS]         = undef;
    $slr->[Marpa::R3::Internal::Scanless::R::CLOSURE_BY_SYMBOL_ID] = undef;
    $slr->[Marpa::R3::Internal::Scanless::R::CLOSURE_BY_RULE_ID]   = undef;

    $recce->[Marpa::R3::Internal::Recognizer::T_C] = undef;
    $recce->[Marpa::R3::Internal::Recognizer::TREE_MODE] = undef;
    return;
} ## end sub Marpa::R3::Recognizer::reset_evaluation

sub Marpa::R3::Scanless::R::naif_set {
    my ( $slr, @arg_hashes ) = @_;
    my $recce =
        $slr->[Marpa::R3::Internal::Scanless::R::THICK_G1_RECCE];
    my $recce_c = $recce->[Marpa::R3::Internal::Recognizer::C];

    # This may get changed below
    my $trace_fh =
        $slr->[Marpa::R3::Internal::Scanless::R::TRACE_FILE_HANDLE];

    for my $args (@arg_hashes) {

        my $ref_type = ref $args;
        if ( not $ref_type or $ref_type ne 'HASH' ) {
            Carp::croak(
                'Marpa::R3 Recognizer expects args as ref to HASH, got ',
                ( "ref to $ref_type" || 'non-reference' ),
                ' instead'
            );
        } ## end if ( not $ref_type or $ref_type ne 'HASH' )

        state $recognizer_options = {
            map { ( $_, 1 ) }
                qw(
                end
                max_parses
                semantics_package
                ranking_method
                too_many_earley_items
                trace_actions
                trace_earley_sets
                trace_values
                )
        };

        if (my @bad_options =
            grep { not exists $recognizer_options->{$_} }
            keys %{$args}
            )
        {
            Carp::croak( 'Unknown option(s) for Marpa::R3 Recognizer: ',
                join q{ }, @bad_options );
        } ## end if ( my @bad_options = grep { not exists $recognizer_options...})

        if ( defined( my $value = $args->{'max_parses'} ) ) {
            $recce->[Marpa::R3::Internal::Recognizer::MAX_PARSES] = $value;
        }

        if ( defined( my $value = $args->{'semantics_package'} ) ) {

            # Not allowed once parsing is started
            if ( defined $recce->[Marpa::R3::Internal::Recognizer::B_C] ) {
                Marpa::R3::exception(
                    q{Cannot change 'semantics_package' named argument once parsing has started}
                );
            }

            $slr->[Marpa::R3::Internal::Scanless::R::RESOLVE_PACKAGE_SOURCE]
                //= 'semantics_package';
            if ( $slr
                ->[Marpa::R3::Internal::Scanless::R::RESOLVE_PACKAGE_SOURCE] ne
                'semantics_package' )
            {
                Marpa::R3::exception(
                    qq{'semantics_package' named argument in conflict with other choices\n},
                    qq{   Usually this means you tried to use the discouraged 'action_object' named argument as well\n}
                );
            } ## end if ( $recce->[...])
            $slr->[Marpa::R3::Internal::Scanless::R::RESOLVE_PACKAGE] =
                $value;
        } ## end if ( defined( my $value = $args->{'semantics_package'...}))

        if ( defined( my $value = $args->{'ranking_method'} ) ) {

            # Not allowed once parsing is started
            if ( defined $recce->[Marpa::R3::Internal::Recognizer::B_C] ) {
                Marpa::R3::exception(
                    q{Cannot change ranking method once parsing has started});
            }
            state $ranking_methods = { map { ($_, 0) } qw(high_rule_only rule none) };
            Marpa::R3::exception(
                qq{ranking_method value is $value (should be one of },
                ( join q{, }, map { q{'} . $_ . q{'} } keys %{$ranking_methods} ),
                ')' )
                if not exists $ranking_methods->{$value};
            $recce->[Marpa::R3::Internal::Recognizer::RANKING_METHOD] =
                $value;
        } ## end if ( defined( my $value = $args->{'ranking_method'} ...))

        if ( defined( my $value = $args->{'trace_actions'} ) ) {
            $recce->[Marpa::R3::Internal::Recognizer::TRACE_ACTIONS] = $value;
            if ($value) {
                say {$trace_fh} 'Setting trace_actions option'
                    or Marpa::R3::exception("Cannot print: $ERRNO");
            }
        } ## end if ( defined( my $value = $args->{'trace_actions'} ))

        if ( defined( my $value = $args->{'trace_values'} ) ) {
            $recce->[Marpa::R3::Internal::Recognizer::TRACE_VALUES] = $value;
            if ($value) {
                say {$trace_fh} 'Setting trace_values option'
                    or Marpa::R3::exception("Cannot print: $ERRNO");
            }
        } ## end if ( defined( my $value = $args->{'trace_values'} ) )

        if ( defined( my $value = $args->{'end'} ) ) {

            # Not allowed once evaluation is started
            if ( defined $recce->[Marpa::R3::Internal::Recognizer::B_C] ) {
                Marpa::R3::exception(
                    q{Cannot reset end once evaluation has started});
            }
            $recce->[Marpa::R3::Internal::Recognizer::END_OF_PARSE] = $value;
        } ## end if ( defined( my $value = $args->{'end'} ) )

        if ( defined( my $value = $args->{'too_many_earley_items'} ) ) {
            $recce_c->earley_item_warning_threshold_set($value);
        }

    } ## end for my $args (@arg_hashes)

    return 1;
} ## end sub Marpa::R3::Recognizer::set

sub Marpa::R3::Recognizer::latest_earley_set {
    my ($recce) = @_;
    my $recce_c = $recce->[Marpa::R3::Internal::Recognizer::C];
    return $recce_c->latest_earley_set();
}

sub Marpa::R3::Recognizer::check_terminal {
    my ( $recce, $name ) = @_;
    my $grammar = $recce->[Marpa::R3::Internal::Recognizer::GRAMMAR];
    return $grammar->check_terminal($name);
}

sub Marpa::R3::Recognizer::exhausted {
    my ($recce) = @_;
    my $recce_c = $recce->[Marpa::R3::Internal::Recognizer::C];
    return $recce_c->is_exhausted();
}

sub Marpa::R3::Recognizer::current_earleme {
    my ($recce) = @_;
    my $recce_c = $recce->[Marpa::R3::Internal::Recognizer::C];
    return $recce_c->current_earleme();
}

sub Marpa::R3::Recognizer::furthest_earleme {
    my ($recce) = @_;
    my $recce_c = $recce->[Marpa::R3::Internal::Recognizer::C];
    return $recce_c->furthest_earleme();
}

sub Marpa::R3::Recognizer::earleme {
    my ( $recce, $earley_set_id ) = @_;
    my $recce_c = $recce->[Marpa::R3::Internal::Recognizer::C];
    return $recce_c->earleme($earley_set_id);
}

sub Marpa::R3::Recognizer::expected_symbol_event_set {
    my ( $recce, $symbol_name, $value ) = @_;
    my $recce_c = $recce->[Marpa::R3::Internal::Recognizer::C];
    my $grammar = $recce->[Marpa::R3::Internal::Recognizer::GRAMMAR];
    my $symbol_id =
        $grammar->[Marpa::R3::Internal::Grammar::TRACER]
        ->symbol_by_name($symbol_name);
    Marpa::exception(qq{Unknown symbol: "$symbol_name"})
        if not defined $symbol_id;
    return $recce_c->expected_symbol_event_set( $symbol_id, $value );
} ## end sub Marpa::R3::Recognizer::expected_symbol_event_set

# Now useless and deprecated
sub Marpa::R3::Recognizer::strip { return 1; }

# Viewing methods, for debugging

sub Marpa::R3::Recognizer::progress {
    my ( $recce, $ordinal_arg ) = @_;
    my $recce_c = $recce->[Marpa::R3::Internal::Recognizer::C];
    my $latest_earley_set = $recce->latest_earley_set();
    my $ordinal;
    SET_ORDINAL: {
        if ( not defined $ordinal_arg ) {
            $ordinal = $latest_earley_set;
            last SET_ORDINAL;
        }
        if ( $ordinal_arg > $latest_earley_set ) {
            Marpa::R3::exception(
                qq{Argument out of bounds in recce->progress($ordinal_arg)\n},
                qq{   Argument specifies Earley set after the latest Earley set 0\n},
                qq{   The latest Earley set is Earley set $latest_earley_set\n}
            );
        } ## end if ( $ordinal_arg > $latest_earley_set )
        if ( $ordinal_arg >= 0 ) {
            $ordinal = $ordinal_arg;
            last SET_ORDINAL;
        }

        # If we are here, $ordinal_arg < 0
        $ordinal = $latest_earley_set + 1 + $ordinal_arg;
        Marpa::R3::exception(
            qq{Argument out of bounds in recce->progress($ordinal_arg)\n},
            qq{   Argument specifies Earley set before Earley set 0\n}
        ) if $ordinal < 0;
    } ## end SET_ORDINAL:
    my $result = [];
    $recce_c->progress_report_start($ordinal);
    ITEM: while (1) {
        my @item = $recce_c->progress_item();
        last ITEM if not defined $item[0];
        push @{$result}, [@item];
    }
    $recce_c->progress_report_finish();
    return $result;
} ## end sub Marpa::R3::Recognizer::progress

sub Marpa::R3::Recognizer::show_progress {
    my ( $recce, $start_ordinal, $end_ordinal ) = @_;
    my $grammar   = $recce->[Marpa::R3::Internal::Recognizer::GRAMMAR];
    my $grammar_c = $grammar->[Marpa::R3::Internal::Grammar::C];

    my $last_ordinal = $recce->latest_earley_set();

    if ( not defined $start_ordinal ) {
        $start_ordinal = $last_ordinal;
    }
    if ( $start_ordinal < 0 ) {
        $start_ordinal += $last_ordinal + 1;
    }
    else {
        if ( $start_ordinal < 0 or $start_ordinal > $last_ordinal ) {
            return
                "Marpa::PP::Recognizer::show_progress start index is $start_ordinal, "
                . "must be in range 0-$last_ordinal";
        }
    } ## end else [ if ( $start_ordinal < 0 ) ]

    if ( not defined $end_ordinal ) {
        $end_ordinal = $start_ordinal;
    }
    else {
        my $end_ordinal_argument = $end_ordinal;
        if ( $end_ordinal < 0 ) {
            $end_ordinal += $last_ordinal + 1;
        }
        if ( $end_ordinal < 0 ) {
            return
                "Marpa::PP::Recognizer::show_progress end index is $end_ordinal_argument, "
                . sprintf ' must be in range %d-%d', -( $last_ordinal + 1 ),
                $last_ordinal;
        } ## end if ( $end_ordinal < 0 )
    } ## end else [ if ( not defined $end_ordinal ) ]

    my $text = q{};
    for my $current_ordinal ( $start_ordinal .. $end_ordinal ) {
        my $current_earleme     = $recce->earleme($current_ordinal);
        my %by_rule_by_position = ();
        for my $progress_item ( @{ $recce->progress($current_ordinal) } ) {
            my ( $rule_id, $position, $origin ) = @{$progress_item};
            if ( $position < 0 ) {
                $position = $grammar_c->rule_length($rule_id);
            }
            $by_rule_by_position{$rule_id}->{$position}->{$origin}++;
        } ## end for my $progress_item ( @{ $recce->progress($current_ordinal...)})

        for my $rule_id ( sort { $a <=> $b } keys %by_rule_by_position ) {
            my $by_position = $by_rule_by_position{$rule_id};
            for my $position ( sort { $a <=> $b } keys %{$by_position} ) {
                my $raw_origins   = $by_position->{$position};
                my @origins       = sort { $a <=> $b } keys %{$raw_origins};
                my $origins_count = scalar @origins;
                my $origin_desc;
                if ( $origins_count <= 3 ) {
                    $origin_desc = join q{,}, @origins;
                }
                else {
                    $origin_desc = $origins[0] . q{...} . $origins[-1];
                }

                my $rhs_length = $grammar_c->rule_length($rule_id);
                my $item_text;

                # flag indicating whether we need to show the dot in the rule
                if ( $position >= $rhs_length ) {
                    $item_text .= "F$rule_id";
                }
                elsif ($position) {
                    $item_text .= "R$rule_id:$position";
                }
                else {
                    $item_text .= "P$rule_id";
                }
                $item_text .= " x$origins_count" if $origins_count > 1;
                $item_text
                    .= q{ @} . $origin_desc . q{-} . $current_earleme . q{ };
                $item_text
                    .= $grammar->show_dotted_rule( $rule_id, $position );
                $text .= $item_text . "\n";
            } ## end for my $position ( sort { $a <=> $b } keys %{...})
        } ## end for my $rule_id ( sort { $a <=> $b } keys ...)

    } ## end for my $current_ordinal ( $start_ordinal .. $end_ordinal)
    return $text;
} ## end sub Marpa::R3::Recognizer::show_progress

# Perform the completion step on an earley set

sub Marpa::R3::Recognizer::terminals_expected {
    my ($recce) = @_;
    my $recce_c = $recce->[Marpa::R3::Internal::Recognizer::C];
    my $grammar = $recce->[Marpa::R3::Internal::Recognizer::GRAMMAR];
    return [ map { $grammar->symbol_name($_) }
            $recce_c->terminals_expected() ];
} ## end sub Marpa::R3::Recognizer::terminals_expected

my @escape_by_ord = ();
$escape_by_ord[ ord q{\\} ] = q{\\\\};
$escape_by_ord[ ord eval qq{"$_"} ] = $_
    for "\\t", "\\r", "\\f", "\\b", "\\a", "\\e";
$escape_by_ord[0xa] = '\\n';
$escape_by_ord[$_] //= chr $_ for 32 .. 126;
$escape_by_ord[$_] //= sprintf( "\\x%02x", $_ ) for 0 .. 255;

sub Marpa::R3::escape_string {
    my ( $string, $length ) = @_;
    my $reversed = $length < 0;
    if ($reversed) {
        $string = reverse $string;
        $length = -$length;
    }
    my @escaped_chars = ();
    ORD: for my $ord ( map {ord} split //xms, $string ) {
        last ORD if $length <= 0;
        my $escaped_char = $escape_by_ord[$ord] // sprintf( "\\x{%04x}", $ord );
        $length -= length $escaped_char;
        push @escaped_chars, $escaped_char;
    } ## end for my $ord ( map {ord} split //xms, $string )
    @escaped_chars = reverse @escaped_chars if $reversed;
    IX: for my $ix ( reverse 0 .. $#escaped_chars ) {

        # only trailing spaces are escaped
        last IX if $escaped_chars[$ix] ne q{ };
        $escaped_chars[$ix] = '\\s';
    } ## end IX: for my $ix ( reverse 0 .. $#escaped_chars )
    return join q{}, @escaped_chars;
} ## end sub escape_string

# INTERNAL OK AFTER HERE _marpa_

sub Marpa::R3::Recognizer::use_leo_set {
    my ( $recce, $boolean ) = @_;
    my $recce_c = $recce->[Marpa::R3::Internal::Recognizer::C];
    return $recce_c->_marpa_r_is_use_leo_set($boolean);
}

# Not intended to be documented.
# Returns the size of the last completed earley set.
# For testing, especially that the Leo items
# are doing their job.
sub Marpa::R3::Recognizer::earley_set_size {
    my ( $recce, $set_id ) = @_;
    my $recce_c = $recce->[Marpa::R3::Internal::Recognizer::C];
    $set_id //= $recce_c->latest_earley_set();
    return $recce_c->_marpa_r_earley_set_size($set_id);
}

1;

# vim: set expandtab shiftwidth=4:
