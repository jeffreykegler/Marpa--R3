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

package Marpa::R3::MetaAST;

use 5.010001;
use strict;
use warnings;

use vars qw($VERSION $STRING_VERSION);
$VERSION        = '4.001_047';
$STRING_VERSION = $VERSION;
## no critic(BuiltinFunctions::ProhibitStringyEval)
$VERSION = eval $VERSION;
## use critic

package Marpa::R3::Internal::MetaAST;

use English qw( -no_match_vars );

sub new {
    my ( $class, $p_rules_source ) = @_;
    my $meta_recce = Marpa::R3::Internal::Scanless::meta_recce();
    eval { $meta_recce->read($p_rules_source) }
        or Marpa::R3::exception( "Parse of BNF/Scanless source failed\n",
        $EVAL_ERROR );
    if ( my $ambiguity_status = $meta_recce->ambiguous() ) {
        Marpa::R3::exception( "Parse of BNF/Scanless source failed:\n",
            $ambiguity_status );
    }
    my $value_ref = $meta_recce->value();
    Marpa::R3::exception('Parse of BNF/Scanless source failed')
        if not defined $value_ref;
    my $ast = { meta_recce => $meta_recce, top_node => ${$value_ref} };
    return bless $ast, $class;
} ## end sub new

sub Marpa::R3::Internal::MetaAST::Parse::substring {
    my ( $parse, $start, $length ) = @_;
    my $meta_slr      = $parse->{meta_recce};
    my $string        = $meta_slr->literal( $start, $length );
    chomp $string;
    return $string;
} ## end sub Marpa::R3::Internal::MetaAST::Parse::substring

sub Marpa::R3::Internal::MetaAST::Parse::line_column {
    my ( $parse, $pos ) = @_;
    return Marpa::R3::Internal::line_column($parse->{p_dsl}, $pos);
}

# Assign symbols, creating "ordinary" symbols if no symbol
# already exists
sub Marpa::R3::Internal::MetaAST::Parse::symbol_assign_ordinary {
    my ( $parse, $symbol_name, $subg ) = @_;
    my $wsym = $parse->{symbols}->{$subg}->{$symbol_name};
    return $wsym if $wsym;
    # say STDERR "symbol_assign_ordinary($symbol_name, $subg)";
    my $symbol_data = {
        dsl_form    => $symbol_name,
        name_source => 'lexical'
    };
    $parse->xsy_assign( $symbol_name, $symbol_data );
    $symbol_data = { xsy => $symbol_name };
    $parse->symbol_names_set( $symbol_name, $subg,
        $symbol_data );
}

sub ast_to_hash {
    my ($ast, $p_dsl) = @_;
    my $hashed_ast = {};

    $hashed_ast->{meta_recce} = $ast->{meta_recce};
    bless $hashed_ast, 'Marpa::R3::Internal::MetaAST::Parse';

    $hashed_ast->{p_dsl} = $p_dsl;
    $hashed_ast->{xpr}->{l0} = {};
    $hashed_ast->{xpr}->{g1} = {};
    $hashed_ast->{rules}->{l0} = [];
    $hashed_ast->{rules}->{g1} = [];
    my $g1_symbols = $hashed_ast->{symbols}->{g1} = {};

    my ( undef, undef, @statements ) = @{ $ast->{top_node} };

    # This is the last ditch exception catcher
    # It forces all Marpa exceptions to be die's,
    # then catches them and rethrows using Carp.
    #
    # The plan is to use die(), with higher levels
    # catching and re-die()'ing after adding
    # helpful location information.  After the
    # re-throw it is caught here and passed to
    # Carp.
    my $eval_ok = eval {
        local $Marpa::R3::JUST_DIE = 1;
        $_->evaluate($hashed_ast) for @statements;
        1;
    };
    Marpa::R3::exception($EVAL_ERROR) if not $eval_ok;

    # Add the augment rule
    {
        my $start_lhs = $hashed_ast->{'start_lhs'}
          // $hashed_ast->{'first_lhs'};
        Marpa::R3::exception('No rules in SLIF grammar')
          if not defined $start_lhs;
        my $augment_lhs = '[:start:]';
        my $symbol_data = {
            dsl_form    => $augment_lhs,
            name_source => 'internal',
        };
        $hashed_ast->xsy_create( $augment_lhs, $symbol_data );
        $hashed_ast->symbol_names_set( $augment_lhs, 'g1', { xsy => $augment_lhs } );

        my $rule_data = {
            start  => 0,
            length => 0,
            lhs    => $augment_lhs,
            rhs    => [$start_lhs],
            action => '::first'
        };
        $hashed_ast->symbol_assign_ordinary($start_lhs, 'g1');
        my $wrl = $hashed_ast->xpr_create( $rule_data, 'g1' );
        push @{ $hashed_ast->{rules}->{g1} }, $wrl;
    } ## end sub Marpa::R3::Internal::MetaAST::start_rule_create

    my %stripped_character_classes = ();
    {
        my $character_classes = $hashed_ast->{character_classes};
        for my $symbol_name ( sort keys %{$character_classes} ) {
            my ($re) = @{ $character_classes->{$symbol_name} };
            $stripped_character_classes{$symbol_name} = $re;
        }
    }
    $hashed_ast->{character_classes} = \%stripped_character_classes;

    return $hashed_ast;
} ## end sub ast_to_hash

# This class is for pieces of RHS alternatives, as they are
# being constructed
my $PROTO_ALTERNATIVE = 'Marpa::R3::Internal::MetaAST::Proto_Alternative';

sub Marpa::R3::Internal::MetaAST::Proto_Alternative::combine {
    my ( $class, @hashes ) = @_;
    my $self = bless {}, $class;
    for my $hash_to_add (@hashes) {
        for my $key ( keys %{$hash_to_add} ) {
            ## expect to be caught and rethrown
            die qq{A Marpa rule contained a duplicate key\n},
                qq{  The key was "$key"\n}
                if exists $self->{$key};
            $self->{$key} = $hash_to_add->{$key};
        } ## end for my $key ( keys %{$hash_to_add} )
    } ## end for my $hash_to_add (@hashes)
    return $self;
} ## end sub Marpa::R3::Internal::MetaAST::Proto_Alternative::combine

sub Marpa::R3::Internal::MetaAST::Parse::bless_hash_rule {
    my ( $parse, $hash_rule, $blessing, $naming, $original_lhs ) = @_;
    return if (substr $Marpa::R3::Internal::SUBGRAMMAR, 0, 1) eq 'l0';

    $naming //= $original_lhs;
    $hash_rule->{name} = $naming;

    return if not defined $blessing;
    FIND_BLESSING: {
        last FIND_BLESSING if $blessing =~ /\A [\w] /xms;
        return if $blessing eq '::undef';

        # Rule may be half-formed, but assume we have lhs
        if ( $blessing eq '::lhs' ) {
            $blessing = $original_lhs;
            if ( $blessing =~ / [^ [:alnum:]] /xms ) {
                Marpa::R3::exception(
                    qq{"::lhs" blessing only allowed if LHS is whitespace and alphanumerics\n},
                    qq{   LHS was <$original_lhs>\n}
                );
            } ## end if ( $blessing =~ / [^ [:alnum:]] /xms )
            $blessing =~ s/[ ]/_/gxms;
            last FIND_BLESSING;
        } ## end if ( $blessing eq '::lhs' )
        Marpa::R3::exception( qq{Unknown blessing "$blessing"\n} );
    } ## end FIND_BLESSING:
    $hash_rule->{bless} = $blessing;
    return 1;
} ## end sub Marpa::R3::Internal::MetaAST::Parse::bless_hash_rule

sub Marpa::R3::Internal::MetaAST_Nodes::bare_name::name { return $_[0]->[2] }

sub Marpa::R3::Internal::MetaAST_Nodes::reserved_action_name::name {
    my ( $self, $parse ) = @_;
    return $self->[2];
}

sub Marpa::R3::Internal::MetaAST_Nodes::reserved_event_name::name {
    my ( $self, $parse ) = @_;
    my $name = $self->[2];
    $name =~ s/\A : /'/xms;
    return $name;
}

sub Marpa::R3::Internal::MetaAST_Nodes::action_name::name {
    my ( $self, $parse ) = @_;
    return $self->[2]->name($parse);
}

sub Marpa::R3::Internal::MetaAST_Nodes::alternative_name::name {
    my ( $self, $parse ) = @_;
    return $self->[2]->name($parse);
}

sub Marpa::R3::Internal::MetaAST_Nodes::event_name::name {
    my ( $self, $parse ) = @_;
    return $self->[2]->name($parse);
}

sub Marpa::R3::Internal::MetaAST_Nodes::array_descriptor::name {
    return $_[0]->[2];
}

sub Marpa::R3::Internal::MetaAST_Nodes::reserved_blessing_name::name {
    return $_[0]->[2];
}

sub Marpa::R3::Internal::MetaAST_Nodes::blessing_name::name {
    my ( $self, $parse ) = @_;
    return $self->[2]->name($parse);
}

sub Marpa::R3::Internal::MetaAST_Nodes::standard_name::name {
    return $_[0]->[2];
}

sub Marpa::R3::Internal::MetaAST_Nodes::Perl_name::name {
    return $_[0]->[2];
}

sub Marpa::R3::Internal::MetaAST_Nodes::lhs::name {
    my ( $values, $parse ) = @_;
    my ( undef, undef, $symbol ) = @{$values};
    return $symbol->name($parse);
}

# After development, delete this
sub Marpa::R3::Internal::MetaAST_Nodes::lhs::evaluate {
    my ( $values, $parse ) = @_;
    return $values->name($parse);
}

sub Marpa::R3::Internal::MetaAST_Nodes::quantifier::evaluate {
    my ($data) = @_;
    return $data->[2];
}

sub Marpa::R3::Internal::MetaAST_Nodes::op_declare::op {
    my ($values) = @_;
    return $values->[2]->op();
}

sub Marpa::R3::Internal::MetaAST_Nodes::op_declare_match::op {
    my ($values) = @_;
    return $values->[2];
}

sub Marpa::R3::Internal::MetaAST_Nodes::op_declare_bnf::op {
    my ($values) = @_;
    return $values->[2];
}

sub Marpa::R3::Internal::MetaAST_Nodes::bracketed_name::name {
    my ($values) = @_;
    my ( undef, undef, $bracketed_name ) = @{$values};

    # normalize whitespace
    $bracketed_name =~ s/\A [<] \s*//xms;
    $bracketed_name =~ s/ \s* [>] \z//xms;
    $bracketed_name =~ s/ \s+ / /gxms;
    return $bracketed_name;
} ## end sub Marpa::R3::Internal::MetaAST_Nodes::bracketed_name::name

sub Marpa::R3::Internal::MetaAST_Nodes::single_quoted_name::name {
    my ($values) = @_;
    my ( undef, undef, $single_quoted_name ) = @{$values};

    # normalize whitespace
    $single_quoted_name =~ s/\A ['] \s*//xms;
    $single_quoted_name =~ s/ \s* ['] \z//xms;
    $single_quoted_name =~ s/ \s+ / /gxms;
    return $single_quoted_name;
} ## end sub Marpa::R3::Internal::MetaAST_Nodes::single_quoted_name::name

sub Marpa::R3::Internal::MetaAST_Nodes::parenthesized_rhs_primary_list::evaluate
{
    my ( $data, $parse ) = @_;
    my ( undef, undef, @values ) = @{$data};
    my @symbol_lists = map { $_->evaluate($parse); } @values;
    my $flattened_list =
        Marpa::R3::Internal::MetaAST::Symbol_List->combine(@symbol_lists);
    $flattened_list->mask_set(0);
    return $flattened_list;
} ## end sub Marpa::R3::Internal::MetaAST_Nodes::parenthesized_rhs_primary_list::evaluate

sub Marpa::R3::Internal::MetaAST_Nodes::rhs::evaluate {
    my ( $data, $parse ) = @_;
    my ( $start, $length, @values ) = @{$data};
    my $rhs = eval {
        my @symbol_lists = map { $_->evaluate($parse) } @values;
        my $flattened_list =
            Marpa::R3::Internal::MetaAST::Symbol_List->combine(@symbol_lists);
        bless {
            rhs  => $flattened_list->names($parse),
            mask => $flattened_list->mask()
            },
            $PROTO_ALTERNATIVE;
    };
    if ( not $rhs ) {
        my $eval_error = $EVAL_ERROR;
        chomp $eval_error;
        Marpa::R3::exception(
            qq{$eval_error\n},
            q{  RHS involved was },
            $parse->substring( $start, $length )
        );
    } ## end if ( not $rhs )
    return $rhs;
} ## end sub Marpa::R3::Internal::MetaAST_Nodes::rhs::evaluate

sub Marpa::R3::Internal::MetaAST_Nodes::rhs_primary::evaluate {
    my ( $data, $parse ) = @_;
    my ( undef, undef, @values ) = @{$data};
    my @symbol_lists = map { $_->evaluate($parse) } @values;
    return Marpa::R3::Internal::MetaAST::Symbol_List->combine(@symbol_lists);
} ## end sub Marpa::R3::Internal::MetaAST_Nodes::rhs_primary::evaluate

sub Marpa::R3::Internal::MetaAST_Nodes::rhs_primary_list::evaluate {
    my ( $data, $parse ) = @_;
    my ( undef, undef, @values ) = @{$data};
    my @symbol_lists = map { $_->evaluate($parse) } @values;
    return Marpa::R3::Internal::MetaAST::Symbol_List->combine(@symbol_lists);
} ## end sub Marpa::R3::Internal::MetaAST_Nodes::rhs_primary_list::evaluate

sub Marpa::R3::Internal::MetaAST_Nodes::action::evaluate {
    my ( $values, $parse ) = @_;
    my ( undef, undef, $child ) = @{$values};
    return bless { action => $child->name($parse) }, $PROTO_ALTERNATIVE;
}

sub Marpa::R3::Internal::MetaAST_Nodes::blessing::evaluate {
    my ( $values, $parse ) = @_;
    my ( undef, undef, $child ) = @{$values};
    return bless { bless => $child->name($parse) }, $PROTO_ALTERNATIVE;
}

sub Marpa::R3::Internal::MetaAST_Nodes::naming::evaluate {
    my ( $values, $parse ) = @_;
    my ( undef, undef, $child ) = @{$values};
    return bless { name => $child->name($parse) }, $PROTO_ALTERNATIVE;
}

sub Marpa::R3::Internal::MetaAST_Nodes::right_association::evaluate {
    my ($values) = @_;
    return bless { assoc => 'R' }, $PROTO_ALTERNATIVE;
}

sub Marpa::R3::Internal::MetaAST_Nodes::left_association::evaluate {
    my ($values) = @_;
    return bless { assoc => 'L' }, $PROTO_ALTERNATIVE;
}

sub Marpa::R3::Internal::MetaAST_Nodes::group_association::evaluate {
    my ($values) = @_;
    return bless { assoc => 'G' }, $PROTO_ALTERNATIVE;
}

sub Marpa::R3::Internal::MetaAST_Nodes::eager_specification::evaluate {
    my ($values) = @_;
    my $child = $values->[2];
    return bless { eager => $child->value() }, $PROTO_ALTERNATIVE;
}

sub Marpa::R3::Internal::MetaAST_Nodes::event_specification::evaluate {
    my ($values) = @_;
    return bless { event => ( $values->[2]->event() ) }, $PROTO_ALTERNATIVE;
}

sub Marpa::R3::Internal::MetaAST_Nodes::event_initialization::event {
    my ($values)         = @_;
    my $event_name       = $values->[2];
    my $event_initializer = $values->[3];
    return [$event_name->name(), $event_initializer->on_or_off()],
} ## end sub Marpa::R3::Internal::MetaAST_Nodes::event_specification::evaluate

sub Marpa::R3::Internal::MetaAST_Nodes::proper_specification::evaluate {
    my ($values) = @_;
    my $child = $values->[2];
    return bless { proper => $child->value() }, $PROTO_ALTERNATIVE;
}

sub Marpa::R3::Internal::MetaAST_Nodes::pause_specification::evaluate {
    my ($values) = @_;
    my $child = $values->[2];
    return bless { pause => $child->value() }, $PROTO_ALTERNATIVE;
}

sub Marpa::R3::Internal::MetaAST_Nodes::priority_specification::evaluate {
    my ($values) = @_;
    my $child = $values->[2];
    return bless { priority => $child->value() }, $PROTO_ALTERNATIVE;
}

sub Marpa::R3::Internal::MetaAST_Nodes::rank_specification::evaluate {
    my ($values) = @_;
    my $child = $values->[2];
    return bless { rank => $child->value() }, $PROTO_ALTERNATIVE;
}

sub Marpa::R3::Internal::MetaAST_Nodes::null_ranking_specification::evaluate {
    my ($values) = @_;
    my $child = $values->[2];
    return bless { null_ranking => $child->value() }, $PROTO_ALTERNATIVE;
}

sub Marpa::R3::Internal::MetaAST_Nodes::null_ranking_constant::value {
    return $_[0]->[2];
}

sub Marpa::R3::Internal::MetaAST_Nodes::before_or_after::value {
    return $_[0]->[2];
}

sub Marpa::R3::Internal::MetaAST_Nodes::event_initializer::on_or_off
{
    my ($values) = @_;
    my (undef, undef, $is_activated) = @{$values};
    return 1 if not defined $is_activated;
    my (undef, undef, $on_or_off) = @{$is_activated};
    return $on_or_off eq 'on' ? 1 : 0;
}

sub Marpa::R3::Internal::MetaAST_Nodes::boolean::value {
    return $_[0]->[2];
}

sub Marpa::R3::Internal::MetaAST_Nodes::signed_integer::value {
    return $_[0]->[2];
}

sub Marpa::R3::Internal::MetaAST_Nodes::separator_specification::evaluate {
    my ( $values, $parse ) = @_;
    my $child = $values->[2];
    return bless { separator => $child->name($parse) }, $PROTO_ALTERNATIVE;
}

sub Marpa::R3::Internal::MetaAST_Nodes::adverb_item::evaluate {
    my ( $values, $parse ) = @_;
    my $child = $values->[2]->evaluate($parse);
    return bless $child, $PROTO_ALTERNATIVE;
}

sub Marpa::R3::Internal::MetaAST_Nodes::default_rule::evaluate {
    my ( $values, $parse ) = @_;
    my ( $start, $length, undef, $op_declare, $raw_adverb_list ) = @{$values};
    my $subgrammar = $op_declare->op() eq q{::=} ? 'g1' : 'l0';
    my $adverb_list = $raw_adverb_list->evaluate($parse);

    # A default rule clears the previous default
    my %default_adverbs = ();
    $parse->{default_adverbs}->{$subgrammar} = \%default_adverbs;

    ADVERB: for my $key ( keys %{$adverb_list} ) {
        my $value = $adverb_list->{$key};
        if ( $key eq 'action' and $subgrammar eq 'g1' ) {
            $default_adverbs{$key} = $adverb_list->{$key};
            next ADVERB;
        }
        if ( $key eq 'bless' and $subgrammar eq 'g1' ) {
            $default_adverbs{$key} = $adverb_list->{$key};
            next ADVERB;
        }
        die qq{Adverb "$key" not allowed in $subgrammar default rule\n},
            '  Rule was ', $parse->substring( $start, $length ), "\n";
    } ## end ADVERB: for my $key ( keys %{$adverb_list} )
    ## no critic(Subroutines::ProhibitExplicitReturnUndef)
    return undef;
} ## end sub Marpa::R3::Internal::MetaAST_Nodes::default_rule::evaluate

sub Marpa::R3::Internal::MetaAST_Nodes::discard_default_statement::evaluate {
    my ( $data, $parse ) = @_;
    my ( $start, $length, $raw_adverb_list ) = @{$data};
    local $Marpa::R3::Internal::SUBGRAMMAR = 'g1';

    my $adverb_list = $raw_adverb_list->evaluate($parse);
    if ( exists $parse->{discard_default_adverbs} ) {
        my $problem_rule = $parse->substring( $start, $length );
        Marpa::R3::exception(
            qq{More than one discard default statement is not allowed\n},
            qq{  This was the rule that caused the problem:\n},
            qq{  $problem_rule\n}
        );
    } ## end if ( exists $parse->{discard_default_adverbs} )
    $parse->{discard_default_adverbs} = {};
    ADVERB: for my $key ( keys %{$adverb_list} ) {
        my $value = $adverb_list->{$key};
        if ( $key eq 'event' and defined $value ) {
            $parse->{discard_default_adverbs}->{$key} = $value;
            next ADVERB;
        }
        Marpa::R3::exception(
            qq{"$key" adverb not allowed as discard default"});
    } ## end ADVERB: for my $key ( keys %{$adverb_list} )
    ## no critic(Subroutines::ProhibitExplicitReturnUndef)
    return undef;
} ## end sub Marpa::R3::Internal::MetaAST_Nodes::discard_default_statement::evaluate

sub Marpa::R3::Internal::MetaAST_Nodes::lexeme_default_statement::evaluate {
    my ( $data, $parse ) = @_;
    my ( $start, $length, $raw_adverb_list ) = @{$data};
    local $Marpa::R3::Internal::SUBGRAMMAR = 'g1';

    my $adverb_list = $raw_adverb_list->evaluate($parse);
    if ( exists $parse->{lexeme_default_adverbs} ) {
        my $problem_rule = $parse->substring( $start, $length );
        Marpa::R3::exception(
            qq{More than one lexeme default statement is not allowed\n},
            qq{  This was the rule that caused the problem:\n},
            qq{  $problem_rule\n}
        );
    } ## end if ( exists $parse->{lexeme_default_adverbs} )
    $parse->{lexeme_default_adverbs} = {};
    ADVERB: for my $key ( keys %{$adverb_list} ) {
        my $value = $adverb_list->{$key};
        if ( $key eq 'action' ) {
            $parse->{lexeme_default_adverbs}->{$key} = $value;
            next ADVERB;
        }
        if ( $key eq 'bless' ) {
            $parse->{lexeme_default_adverbs}->{$key} = $value;
            next ADVERB;
        }
        Marpa::R3::exception(
            qq{"$key" adverb not allowed as lexeme default"});
    } ## end ADVERB: for my $key ( keys %{$adverb_list} )
    ## no critic(Subroutines::ProhibitExplicitReturnUndef)
    return undef;
} ## end sub Marpa::R3::Internal::MetaAST_Nodes::lexeme_default_statement::evaluate

sub Marpa::R3::Internal::MetaAST_Nodes::inaccessible_statement::evaluate {
    my ( $data, $parse ) = @_;
    my ( $start, $length, $inaccessible_treatment ) = @{$data};
    local $Marpa::R3::Internal::SUBGRAMMAR = 'g1';

    if ( exists $parse->{defaults}->{if_inaccessible} ) {
        my $problem_rule = $parse->substring( $start, $length );
        Marpa::R3::exception(
            qq{More than one inaccessible default statement is not allowed\n},
            qq{  This was the rule that caused the problem:\n},
            qq{  $problem_rule\n}
        );
    }
    $parse->{defaults}->{if_inaccessible} = $inaccessible_treatment->value();
    return undef;
}

sub Marpa::R3::Internal::MetaAST_Nodes::inaccessible_treatment::value {
    return $_[0]->[2];
}

sub Marpa::R3::Internal::MetaAST_Nodes::priority_rule::evaluate {
    my ( $values, $parse ) = @_;
    my ( $start, $length, $raw_lhs, $op_declare, $raw_priorities ) =
        @{$values};

    my $subgrammar = $op_declare->op() eq q{::=} ? 'g1' : 'l0';
    my $xpr_ordinal = 0;

    my $lhs = $raw_lhs->name($parse);
    $parse->{'first_lhs'} //= $lhs if $subgrammar eq 'g1';
    local $Marpa::R3::Internal::SUBGRAMMAR = $subgrammar;

    my ( undef, undef, @priorities ) = @{$raw_priorities};
    my $priority_count = scalar @priorities;
    my @working_rules  = ();

    $parse->{rules}->{$subgrammar} //= [];
    my $rules = $parse->{rules}->{$subgrammar};

    my $default_adverbs = $parse->{default_adverbs}->{$subgrammar};

    my $xrlid = xrl_create($parse, {
            lhs => $lhs,
            start => $start,
            length => $length,
            precedence_count => $priority_count,
        }
        );
    if ( $priority_count <= 1 ) {
        ## If there is only one priority
        my ( undef, undef, @alternatives ) = @{ $priorities[0] };

        for my $alternative_ix (0 .. $#alternatives) {
            my ($alternative_start, $alternative_length,
                $raw_rhs,           $raw_adverb_list
            ) = @{$alternatives[$alternative_ix]};
            my ( $proto_rule, $adverb_list );
            my $eval_ok = eval {
                $proto_rule  = $raw_rhs->evaluate($parse);
                $adverb_list = $raw_adverb_list->evaluate($parse);
                1;
            };
            if ( not $eval_ok ) {
                my $eval_error = $EVAL_ERROR;
                chomp $eval_error;
                Marpa::R3::exception(
                    qq{$eval_error\n},
                    qq{  The problem was in this RHS alternative:\n},
                    q{  },
                    $parse->substring( $alternative_start, $alternative_length ),
                    "\n"
                );
            } ## end if ( not $eval_ok )
            my @rhs_names = @{ $proto_rule->{rhs} };
            my @mask      = @{ $proto_rule->{mask} };
            if ( ( substr $subgrammar, 0, 1 ) eq 'l'
                and grep { !$_ } @mask )
            {
                Marpa::R3::exception(
                    qq{hidden symbols are not allowed in lexical rules (rule's LHS was "$lhs")}
                );
            }
            $parse->symbol_assign_ordinary($_, $subgrammar) for $lhs, @rhs_names;
            my %hash_rule = (
                start  => ( $alternative_ix ? $alternative_start  : $start ),
                length => ( $alternative_ix ? $alternative_length : $length ),
                subkey => ++$xpr_ordinal,
                lhs    => $lhs,
                rhs    => \@rhs_names,
                mask   => \@mask,
                xrlid  => $xrlid,
            );

            my $action;
            my $blessing;
            my $naming;
            my $null_ranking;
            my $rank;
            ADVERB: for my $key ( keys %{$adverb_list} ) {
                my $value = $adverb_list->{$key};
                if ( $key eq 'action' ) {
                    $action = $adverb_list->{$key};
                    next ADVERB;
                }
                if ( $key eq 'assoc' ) {

                    # OK, but ignored
                    next ADVERB;
                }
                if ( $key eq 'bless' ) {
                    $blessing = $adverb_list->{$key};
                    next ADVERB;
                }
                if ( $key eq 'name' ) {
                    $naming = $adverb_list->{$key};
                    next ADVERB;
                }
                if ( $key eq 'null_ranking' ) {
                    $null_ranking = $adverb_list->{$key};
                    next ADVERB;
                }
                if ( $key eq 'rank' ) {
                    $rank = $adverb_list->{$key};
                    next ADVERB;
                }
                my ( $line, $column ) =
                    $parse->{meta_recce}->line_column($start);
                die qq{Adverb "$key" not allowed in an prioritized rule\n},
                    '  Rule was ', $parse->substring( $start, $length ), "\n";
            } ## end ADVERB: for my $key ( keys %{$adverb_list} )

            $action //= $default_adverbs->{action};
            if ( defined $action ) {
                Marpa::R3::exception(
                    qq{actions not allowed in lexical rules (rule's LHS was "$lhs")}
                ) if  ( substr $subgrammar, 0, 1 ) eq 'l';
                $hash_rule{action} = $action;
            } ## end if ( defined $action )

            $rank //= $default_adverbs->{rank};
            if ( defined $rank ) {
                Marpa::R3::exception(
                    qq{ranks not allowed in lexical rules (rule's LHS was "$lhs")}
                ) if  ( substr $subgrammar, 0, 1 ) eq 'l';
                $hash_rule{rank} = $rank;
            } ## end if ( defined $rank )

            $null_ranking //= $default_adverbs->{null_ranking};
            if ( defined $null_ranking ) {
                Marpa::R3::exception(
                    qq{null-ranking allowed in lexical rules (rule's LHS was "$lhs")}
                ) if  ( substr $subgrammar, 0, 1 ) eq 'l';
                $hash_rule{null_ranking} = $null_ranking;
            } ## end if ( defined $rank )

            $blessing //= $default_adverbs->{bless};
            if (defined $blessing
                and
                 ( substr $subgrammar, 0, 1 ) eq 'l' 
                )
            {
                Marpa::R3::exception(
                    'bless option not allowed in lexical rules (rules LHS was "',
                    $lhs, '")'
                );
            }

            $parse->bless_hash_rule( \%hash_rule, $blessing, $naming, $lhs );

            my $wrl = $parse->xpr_create( \%hash_rule, $subgrammar );
            push @{$rules}, $wrl;
        } ## end for my $alternative (@alternatives)
        ## no critic(Subroutines::ProhibitExplicitReturnUndef)
        return undef;
    } ## end if ( $priority_count <= 1 )

    for my $priority_ix ( 0 .. $priority_count - 1 ) {
        my $priority = $priority_count - ( $priority_ix + 1 );
        my ( undef, undef, @alternatives ) = @{ $priorities[$priority_ix] };
        for my $alternative (@alternatives) {
            my ($alternative_start, $alternative_length,
                $raw_rhs,           $raw_adverb_list
            ) = @{$alternative};
            my ( $adverb_list, $rhs );
            my $eval_ok = eval {
                $adverb_list = $raw_adverb_list->evaluate($parse);
                $rhs         = $raw_rhs->evaluate($parse);
                1;
            };
            if ( not $eval_ok ) {
                my $eval_error = $EVAL_ERROR;
                chomp $eval_error;
                Marpa::R3::exception(
                    qq{$eval_error\n},
                    qq{  The problem was in this RHS alternative:\n},
                    q{  },
                    $parse->substring( $alternative_start, $alternative_length ),
                    "\n"
                );
            } ## end if ( not $eval_ok )
            push @working_rules, [ $priority, $rhs, $adverb_list, $alternative_start, $alternative_length ];
        } ## end for my $alternative (@alternatives)
    } ## end for my $priority_ix ( 0 .. $priority_count - 1 )

    # Default mask (all ones) is OK for this rule
    my @arg0_action = ();
    @arg0_action = ( action => '::first' ) if $subgrammar eq 'g1';

    # Internal rule top priority rule for <$lhs>
    $parse->symbol_assign_ordinary($lhs, $subgrammar);
    my @priority_rules = (
        {
            start => $start,
            length => $length,
            lhs   => $lhs,
            rhs   => [ $parse->prioritized_symbol( $lhs, 0 ) ],
            subkey => ++$xpr_ordinal,
            @arg0_action,
        }
    );

    # Internal rule for symbol <$lhs> priority transition
    push @priority_rules,
      {
        start => $start,
        length => $length,
        lhs   => $parse->prioritized_symbol( $lhs, $_ - 1 ),
        rhs   => [ $parse->prioritized_symbol( $lhs, $_ ) ],
        subkey => ++$xpr_ordinal,
        @arg0_action
      }
      for 1 .. $priority_count - 1;
  RULE: for my $priority_rule (@priority_rules) {
        my $wrl = $parse->xpr_create( $priority_rule, $subgrammar );
        push @{$rules}, $wrl;
    }

    RULE: for my $working_rule (@working_rules) {
        my ( $priority, $rhs, $adverb_list, $alternative_start, $alternative_length ) = @{$working_rule};
        my @new_rhs = @{ $rhs->{rhs} };
        my @arity   = grep { $new_rhs[$_] eq $lhs } 0 .. $#new_rhs;
        my $rhs_length  = scalar @new_rhs;

        my $current_exp = $parse->prioritized_symbol( $lhs, $priority );
        my @mask = @{ $rhs->{mask} };
        if ( (  substr $subgrammar, 0, 1 ) eq 'l' and grep { !$_ } @mask )
        {
            Marpa::R3::exception(
                'hidden symbols are not allowed in lexical rules (rules LHS was "',
                $lhs, '")'
            );
        }
        my %new_xs_rule = (
            lhs    => $current_exp,
            start  => $alternative_start,
            length => $alternative_length,
            subkey => ++$xpr_ordinal,
            xrlid => $xrlid,
        );
        $new_xs_rule{mask} = \@mask;

        my $action;
        my $assoc;
        my $blessing;
        my $naming;
        my $rank;
        my $null_ranking;
        ADVERB: for my $key ( keys %{$adverb_list} ) {
            my $value = $adverb_list->{$key};
            if ( $key eq 'action' ) {
                $action = $adverb_list->{$key};
                next ADVERB;
            }
            if ( $key eq 'assoc' ) {
                $assoc = $adverb_list->{$key};
                next ADVERB;
            }
            if ( $key eq 'bless' ) {
                $blessing = $adverb_list->{$key};
                next ADVERB;
            }
            if ( $key eq 'name' ) {
                $naming = $adverb_list->{$key};
                next ADVERB;
            }
            if ( $key eq 'null_ranking' ) {
                $null_ranking = $adverb_list->{$key};
                next ADVERB;
            }
            if ( $key eq 'rank' ) {
                $rank = $adverb_list->{$key};
                next ADVERB;
            }
            my ( $line, $column ) = $parse->{meta_recce}->line_column($start);
            die qq{Adverb "$key" not allowed in a prioritized rule\n},
                '  Rule was ', $parse->substring( $start, $length ), "\n";
        } ## end ADVERB: for my $key ( keys %{$adverb_list} )

        $assoc //= 'L';

        $action //= $default_adverbs->{action};
        if ( defined $action ) {
            Marpa::R3::exception(
                qq{actions not allowed in lexical rules (rule's LHS was "$lhs")}
            ) if  ( substr $subgrammar, 0, 1 ) eq 'l';
            $new_xs_rule{action} = $action;
        } ## end if ( defined $action )

        $null_ranking //= $default_adverbs->{null_ranking};
        if ( defined $null_ranking ) {
            Marpa::R3::exception(
                qq{null-ranking not allowed in lexical rules (rule's LHS was "$lhs")}
            ) if  ( substr $subgrammar, 0, 1 ) eq 'l';
            $new_xs_rule{null_ranking} = $null_ranking;
        } ## end if ( defined $rank )

        $rank //= $default_adverbs->{rank};
        if ( defined $rank ) {
            Marpa::R3::exception(
                qq{ranks not allowed in lexical rules (rule's LHS was "$lhs")}
            ) if  ( substr $subgrammar, 0, 1 ) eq 'l';
            $new_xs_rule{rank} = $rank;
        } ## end if ( defined $rank )

        $blessing //= $default_adverbs->{bless};
        if ( defined $blessing
            and ( substr $subgrammar, 0, 1 ) eq 'l' )
        {
            Marpa::R3::exception(
                'bless option not allowed in lexical rules (rules LHS was "',
                $lhs, '")'
            );
        }

        $parse->bless_hash_rule( \%new_xs_rule, $blessing, $naming, $lhs );

        my $next_priority = $priority + 1;

        # This is probably a mis-feature.  It probably should be
        # $next_priority = $priority if $next_priority >= $priority_count;
        # However, I probably will not change this, because some apps
        # may be relying on this behavior.
        $next_priority = 0 if $next_priority >= $priority_count;

        my $next_exp = $parse->prioritized_symbol( $lhs, $next_priority);

        if ( not scalar @arity ) {
            $new_xs_rule{rhs} = \@new_rhs;
            $parse->symbol_assign_ordinary($_, $subgrammar) for @new_rhs;
            my $wrl = $parse->xpr_create( \%new_xs_rule, $subgrammar );
            push @{$rules}, $wrl;
            next RULE;
        }

        if ( scalar @arity == 1 ) {
            die 'Unnecessary unit rule in priority rule' if $rhs_length == 1;
            $new_rhs[ $arity[0] ] = $current_exp;
        }
        DO_ASSOCIATION: {
            if ( $assoc eq 'L' ) {
                $new_rhs[ $arity[0] ] = $current_exp;
                for my $rhs_ix ( @arity[ 1 .. $#arity ] ) {
                    $new_rhs[$rhs_ix] = $next_exp;
                }
                last DO_ASSOCIATION;
            } ## end if ( $assoc eq 'L' )
            if ( $assoc eq 'R' ) {
                $new_rhs[ $arity[-1] ] = $current_exp;
                for my $rhs_ix ( @arity[ 0 .. $#arity - 1 ] ) {
                    $new_rhs[$rhs_ix] = $next_exp;
                }
                last DO_ASSOCIATION;
            } ## end if ( $assoc eq 'R' )
            if ( $assoc eq 'G' ) {
                for my $rhs_ix ( @arity[ 0 .. $#arity ] ) {
                    $new_rhs[$rhs_ix] = $parse->prioritized_symbol( $lhs, 0 );
                }
                last DO_ASSOCIATION;
            } ## end if ( $assoc eq 'G' )
            die qq{Unknown association type: "$assoc"};
        } ## end DO_ASSOCIATION:

        $parse->symbol_assign_ordinary($_, $subgrammar) for @new_rhs;
        $new_xs_rule{rhs} = \@new_rhs;
        my $wrl = $parse->xpr_create( \%new_xs_rule, $subgrammar );
        push @{$rules}, $wrl;
    } ## end RULE: for my $working_rule (@working_rules)
    ## no critic(Subroutines::ProhibitExplicitReturnUndef)
    return undef;
} ## end sub Marpa::R3::Internal::MetaAST_Nodes::priority_rule::evaluate

sub Marpa::R3::Internal::MetaAST_Nodes::empty_rule::evaluate {
    my ( $values, $parse ) = @_;
    my ( $start, $length, $raw_lhs, $op_declare, $raw_adverb_list ) =
        @{$values};

    my $subgrammar = $op_declare->op() eq q{::=} ? 'g1' : 'l0';

    my $lhs = $raw_lhs->name($parse);
    $parse->{'first_lhs'} //= $lhs if $subgrammar eq 'g1';
    local $Marpa::R3::Internal::SUBGRAMMAR = $subgrammar;

    my $xrlid = xrl_create($parse, {
            lhs => $lhs,
            start => $start,
            length => $length,
        }
        );
    # description => qq{Empty rule for <$lhs>},
    my %rule = (
        lhs   => $lhs,
        start => $start,
        length => $length,
        rhs   => [],
        xrlid => $xrlid,
    );
    my $adverb_list = $raw_adverb_list->evaluate($parse);

    my $default_adverbs = $parse->{default_adverbs}->{$subgrammar};

    my $action;
    my $blessing;
    my $naming;
    my $rank;
    my $null_ranking;
    ADVERB: for my $key ( keys %{$adverb_list} ) {
        my $value = $adverb_list->{$key};
        if ( $key eq 'action' ) {
            $action = $adverb_list->{$key};
            next ADVERB;
        }
        if ( $key eq 'bless' ) {
            $blessing = $adverb_list->{$key};
            next ADVERB;
        }
        if ( $key eq 'name' ) {
            $naming = $adverb_list->{$key};
            next ADVERB;
        }
        if ( $key eq 'null_ranking' ) {
            $null_ranking = $adverb_list->{$key};
            next ADVERB;
        }
        if ( $key eq 'rank' ) {
            $rank = $adverb_list->{$key};
            next ADVERB;
        }
        my ( $line, $column ) = $parse->{meta_recce}->line_column($start);
        die qq{Adverb "$key" not allowed in an empty rule\n},
            '  Rule was ', $parse->substring( $start, $length ), "\n";
    } ## end ADVERB: for my $key ( keys %{$adverb_list} )

    $action //= $default_adverbs->{action};
    if ( defined $action ) {
        Marpa::R3::exception(
            qq{actions not allowed in lexical rules (rule's LHS was "$lhs")}
        ) if  ( substr $subgrammar, 0, 1 ) eq 'l';
        $rule{action} = $action;
    } ## end if ( defined $action )

    $null_ranking //= $default_adverbs->{null_ranking};
    if ( defined $null_ranking ) {
        Marpa::R3::exception(
            qq{null-ranking not allowed in lexical rules (rule's LHS was "$lhs")}
        ) if  ( substr $subgrammar, 0, 1 ) eq 'l';
        $rule{null_ranking} = $null_ranking;
    } ## end if ( defined $null_ranking )

    $rank //= $default_adverbs->{rank};
    if ( defined $rank ) {
        Marpa::R3::exception(
            qq{ranks not allowed in lexical rules (rule's LHS was "$lhs")}
        ) if  ( substr $subgrammar, 0, 1 ) eq 'l';
        $rule{rank} = $rank;
    } ## end if ( defined $rank )

    $blessing //= $default_adverbs->{bless};
    if ( defined $blessing
        and ( substr $subgrammar, 0, 1 ) eq 'l' )
    {
        Marpa::R3::exception(
            qq{bless option not allowed in lexical rules (rule's LHS was "$lhs")}
        );
    }
    $parse->bless_hash_rule( \%rule, $blessing, $naming, $lhs );

    $parse->symbol_assign_ordinary($lhs, $subgrammar);
    my $wrl = $parse->xpr_create( \%rule, $subgrammar );
    # mask not needed
    push @{ $parse->{rules}->{$subgrammar} }, $wrl;

    ## no critic(Subroutines::ProhibitExplicitReturnUndef)
    return undef;
} ## end sub Marpa::R3::Internal::MetaAST_Nodes::empty_rule::evaluate

sub Marpa::R3::Internal::MetaAST_Nodes::lexeme_rule::evaluate {
    my ( $values, $parse ) = @_;
    my ( $start, $length, $symbol, $unevaluated_adverb_list ) = @{$values};

    my $symbol_name  = $symbol->name();
    my $declarations = $parse->{lexeme_declarations}->{$symbol_name};
    if ( defined $declarations ) {
        my ( $line, $column ) = $parse->{meta_recce}->line_column($start);
        die "Duplicate lexeme rule for <$symbol_name>\n",
            "  Only one lexeme rule is allowed for each symbol\n",
            "  Location was line $line, column $column\n",
            '  Rule was ', $parse->substring( $start, $length ), "\n";
    } ## end if ( defined $declarations )

    my $adverb_list = $unevaluated_adverb_list->evaluate();
    my %declarations;
    ADVERB: for my $key ( keys %{$adverb_list} ) {
        my $raw_value = $adverb_list->{$key};
        if ( $key eq 'action' ) {
            $declarations{$key} = $raw_value;
            next ADVERB;
        }
        if ( $key eq 'blessing' ) {
            $declarations{$key} = $raw_value;
            next ADVERB;
        }
        if ( $key eq 'eager' ) {
            $declarations{$key} = 1 if $raw_value;
            next ADVERB;
        }
        if ( $key eq 'event' ) {
            $declarations{$key} = $raw_value;
            next ADVERB;
        }
        if ( $key eq 'pause' ) {
            if ( $raw_value eq 'before' ) {
                $declarations{$key} = -1;
                next ADVERB;
            }
            if ( $raw_value eq 'after' ) {
                $declarations{$key} = 1;
                next ADVERB;
            }
            my ( $line, $column ) = $parse->{meta_recce}->line_column($start);
            die qq{Bad value for "pause" adverb: "$raw_value"},
                "  Location was line $line, column $column\n",
                '  Rule was ', $parse->substring( $start, $length ), "\n";
        } ## end if ( $key eq 'pause' )
        if ( $key eq 'priority' ) {
            $declarations{$key} = $raw_value + 0;
            next ADVERB;
        }
        my ( $line, $column ) = $parse->{meta_recce}->line_column($start);
        die qq{"$key" adverb not allowed in lexeme rule"\n},
            "  Location was line $line, column $column\n",
            '  Rule was ', $parse->substring( $start, $length ), "\n";
    } ## end ADVERB: for my $key ( keys %{$adverb_list} )
    if ( exists $declarations{'event'} and not exists $declarations{'pause'} )
    {
        my ( $line, $column ) = $parse->{meta_recce}->line_column($start);
        die
            qq{"event" adverb not allowed without "pause" adverb in lexeme rule"\n},
            "  Location was line $line, column $column\n",
            '  Rule was ', $parse->substring( $start, $length ), "\n";
    } ## end if ( exists $declarations{'event'} and not exists $declarations...)
    if ( exists $declarations{'pause'} and not exists $declarations{'event'} )
    {
        my ( $line, $column ) = $parse->{meta_recce}->line_column($start);
        die
            qq{"pause" adverb not allowed without "event" adverb in lexeme rule"\n},
            qq{  Events must be named with the "event" adverb\n},
            "  Location was line $line, column $column\n",
            '  Rule was ', $parse->substring( $start, $length ), "\n";
    } ## end if ( exists $declarations{'event'} and not exists $declarations...)
    $parse->{lexeme_declarations}->{$symbol_name} = \%declarations;
    ## no critic(Subroutines::ProhibitExplicitReturnUndef)
    return undef;
} ## end sub Marpa::R3::Internal::MetaAST_Nodes::lexeme_rule::evaluate

sub Marpa::R3::Internal::MetaAST_Nodes::statements::evaluate {
    my ( $data, $parse ) = @_;
    my ( undef, undef, @statement_list ) = @{$data};
    map { $_->evaluate($parse) } @statement_list;
    return undef;
} ## end sub Marpa::R3::Internal::MetaAST_Nodes::statements::evaluate

sub Marpa::R3::Internal::MetaAST_Nodes::statement::evaluate {
    my ( $data, $parse ) = @_;
    my ( undef, undef, $child ) = @{$data};
    $child->evaluate($parse);
    ## no critic(Subroutines::ProhibitExplicitReturnUndef)
    return undef;
} ## end sub Marpa::R3::Internal::MetaAST_Nodes::statement::evaluate

sub Marpa::R3::Internal::MetaAST_Nodes::null_statement::evaluate {
    return undef;
}

sub Marpa::R3::Internal::MetaAST_Nodes::statement_group::evaluate {
    my ( $data, $parse ) = @_;
    my ( undef, undef, $statements ) = @{$data};
    $statements->evaluate($parse);
    ## no critic(Subroutines::ProhibitExplicitReturnUndef)
    return undef;
}

sub Marpa::R3::Internal::MetaAST_Nodes::start_rule::evaluate {
    my ( $values, $parse ) = @_;
    my ( $start, $length, $symbol ) = @{$values};
    if ( defined $parse->{'start_lhs'} ) {
        my ( $line, $column ) = $parse->{meta_recce}->line_column($start);
        die qq{There are two start rules\n},
            qq{  That is not allowed\n},
            '  The second start rule is ',
            $parse->substring( $start, $length ),
            "\n",
            "  Problem occurred at line $line, column $column\n";
    } ## end if ( defined $parse->{'start_lhs'} )
    $parse->{'start_lhs'} = $symbol->name($parse);
    ## no critic(Subroutines::ProhibitExplicitReturnUndef)
    return undef;
} ## end sub Marpa::R3::Internal::MetaAST_Nodes::start_rule::evaluate

sub Marpa::R3::Internal::MetaAST_Nodes::discard_rule::evaluate {
    my ( $values, $parse ) = @_;
    my ( $start, $length, $symbol, $raw_adverb_list ) = @{$values};

    local $Marpa::R3::Internal::SUBGRAMMAR = 'l0';
    my $discard_lhs = '[:discard:]';
    my $symbol_data = {
        dsl_form    => $discard_lhs,
        name_source => 'internal',
    };
    $parse->xsy_create( $discard_lhs, $symbol_data );
    $parse->symbol_names_set(
        $discard_lhs,
        'l0',
        {   # description  => qq{Internal LHS for lexer discard}
        }
    );
    my $rhs         = $symbol->names($parse);
    my $discard_symbol = $rhs->[0];
    my $rhs_as_event         = $symbol->event_name($parse);
    my $adverb_list = $raw_adverb_list->evaluate($parse);
    my $event;
    my $eager;
    ADVERB: for my $key ( keys %{$adverb_list} ) {
        my $value = $adverb_list->{$key};
        if ( $key eq 'eager' ) {
            $eager = 1 if $value;
            next ADVERB;
        }
        if ( $key eq 'event' ) {
            $event = $value;
            next ADVERB;
        }
        Marpa::R3::exception(
            qq{"$key" adverb not allowed with discard rule"});
    } ## end ADVERB: for my $key ( keys %{$adverb_list} )

    my $discard_symbol_data = $parse->discard_symbol_assign($discard_symbol);
    if ($eager) {
        $discard_symbol_data->{eager} = $eager;
    }

    # Discard rule
    my %rule_hash = (
        lhs => $discard_lhs,
        rhs => [$discard_symbol],
        start => $start,
        length => $length,
        symbol_as_event => $rhs_as_event
    );
    $rule_hash{event} = $event if defined $event;
    my $wrl = $parse->xpr_create( \%rule_hash, 'l0' );
    push @{ $parse->{rules}->{l0} }, $wrl;
    ## no critic(Subroutines::ProhibitExplicitReturnUndef)
    return undef;
} ## end sub Marpa::R3::Internal::MetaAST_Nodes::discard_rule::evaluate

sub Marpa::R3::Internal::MetaAST_Nodes::quantified_rule::evaluate {
    my ( $values, $parse ) = @_;
    my ( $start, $length, $lhs, $op_declare, $rhs, $quantifier,
        $proto_adverb_list )
        = @{$values};

    my $subgrammar = $op_declare->op() eq q{::=} ? 'g1' : 'l0';

    my $lhs_name = $lhs->name($parse);
    $parse->{'first_lhs'} //= $lhs_name if $subgrammar eq 'g1';
    local $Marpa::R3::Internal::SUBGRAMMAR = $subgrammar;

    my $quantifier_string = $quantifier->evaluate($parse);
    my $xrlid = xrl_create($parse, {
            lhs => $lhs_name,
            start => $start,
            length => $length,
        }
        );

    my $adverb_list     = $proto_adverb_list->evaluate($parse);
    my $default_adverbs = $parse->{default_adverbs}->{$subgrammar};

    # Some properties of the sequence rule will not be altered
    # no matter how complicated this gets
    my %sequence_rule = (
        start => $start,
        length => $length,
        xrlid => $xrlid,
        rhs => [ $rhs->name($parse) ],
        min => ( $quantifier_string eq q{+} ? 1 : 0 )
    );

    my $action;
    my $blessing;
    my $naming;
    my $separator;
    my $proper;
    my $rank;
    my $null_ranking;
    ADVERB: for my $key ( keys %{$adverb_list} ) {
        my $value = $adverb_list->{$key};
        if ( $key eq 'action' ) {
            $action = $adverb_list->{$key};
            next ADVERB;
        }
        if ( $key eq 'bless' ) {
            $blessing = $adverb_list->{$key};
            next ADVERB;
        }
        if ( $key eq 'name' ) {
            $naming = $adverb_list->{$key};
            next ADVERB;
        }
        if ( $key eq 'proper' ) {
            $proper = $adverb_list->{$key};
            next ADVERB;
        }
        if ( $key eq 'rank' ) {
            $rank = $adverb_list->{$key};
            next ADVERB;
        }
        if ( $key eq 'null_ranking' ) {
            $null_ranking = $adverb_list->{$key};
            next ADVERB;
        }
        if ( $key eq 'separator' ) {
            $separator = $adverb_list->{$key};
            next ADVERB;
        }
        my ( $line, $column ) = $parse->{meta_recce}->line_column($start);
        die qq{Adverb "$key" not allowed in quantified rule\n},
            '  Rule was ', $parse->substring( $start, $length ), "\n";
    } ## end ADVERB: for my $key ( keys %{$adverb_list} )

    # mask not needed
    $sequence_rule{lhs} = $lhs_name;

    $sequence_rule{separator} = $separator
        if defined $separator;
    $sequence_rule{proper} = $proper if defined $proper;

    $action //= $default_adverbs->{action};
    if ( defined $action ) {
        Marpa::R3::exception(
            qq{actions not allowed in lexical rules (rule's LHS was "$lhs")}
        ) if  ( substr $subgrammar, 0, 1 ) eq 'l';
        $sequence_rule{action} = $action;
    } ## end if ( defined $action )

    $null_ranking //= $default_adverbs->{null_ranking};
    if ( defined $null_ranking ) {
        Marpa::R3::exception(
            qq{null-ranking not allowed in lexical rules (rule's LHS was "$lhs")}
        ) if  ( substr $subgrammar, 0, 1 ) eq 'l';
        $sequence_rule{null_ranking} = $null_ranking;
    } ## end if ( defined $null_ranking )

    $rank //= $default_adverbs->{rank};
    if ( defined $rank ) {
        Marpa::R3::exception(
            qq{ranks not allowed in lexical rules (rule's LHS was "$lhs")}
        ) if  ( substr $subgrammar, 0, 1 ) eq 'l';
        $sequence_rule{rank} = $rank;
    } ## end if ( defined $rank )

    $blessing //= $default_adverbs->{bless};
    if ( defined $blessing and ( substr $subgrammar, 0, 1 ) eq 'l' )
    {
        Marpa::R3::exception(
            qq{bless option not allowed in lexical rules (rule's LHS was "$lhs")}
        );
    }
    $parse->symbol_assign_ordinary($_, $subgrammar) for $lhs_name, @{$sequence_rule{rhs}};
    $parse->symbol_assign_ordinary($separator, $subgrammar) if defined $separator;
    $parse->bless_hash_rule( \%sequence_rule, $blessing, $naming, $lhs_name );

    my $wrl = $parse->xpr_create( \%sequence_rule, $subgrammar );
    push @{ $parse->{rules}->{$subgrammar} }, $wrl;
    ## no critic(Subroutines::ProhibitExplicitReturnUndef)
    return undef;

} ## end sub Marpa::R3::Internal::MetaAST_Nodes::quantified_rule::evaluate

sub Marpa::R3::Internal::MetaAST_Nodes::completion_event_declaration::evaluate
{
    my ( $values, $parse ) = @_;
    my ( $start, $length, $raw_event, $raw_symbol_name ) = @{$values};
    my $symbol_name       = $raw_symbol_name->name();
    my $completion_events = $parse->{completion_events} //= {};
    if ( defined $completion_events->{$symbol_name} ) {
        my ( $line, $column ) = $parse->{meta_recce}->line_column($start);
        die qq{Completion event for symbol "$symbol_name" declared twice\n},
            qq{  That is not allowed\n},
            '  Second declaration was ', $parse->substring( $start, $length ),
            "\n",
            "  Problem occurred at line $line, column $column\n";
    } ## end if ( defined $completion_events->{$symbol_name} )
    $completion_events->{$symbol_name} = $raw_event->event();
    ## no critic(Subroutines::ProhibitExplicitReturnUndef)
    return undef;
} ## end sub Marpa::R3::Internal::MetaAST_Nodes::completion_event_declaration::evaluate

sub Marpa::R3::Internal::MetaAST_Nodes::nulled_event_declaration::evaluate {
    my ( $values, $parse ) = @_;
    my ( $start, $length, $raw_event, $raw_symbol_name ) = @{$values};
    my $symbol_name   = $raw_symbol_name->name();
    my $nulled_events = $parse->{nulled_events} //= {};
    if ( defined $nulled_events->{$symbol_name} ) {
        my ( $line, $column ) = $parse->{meta_recce}->line_column($start);
        die qq{nulled event for symbol "$symbol_name" declared twice\n},
            qq{  That is not allowed\n},
            '  Second declaration was ', $parse->substring( $start, $length ),
            "\n",
            "  Problem occurred at line $line, column $column\n";
    } ## end if ( defined $nulled_events->{$symbol_name} )
    $nulled_events->{$symbol_name} = $raw_event->event();
    ## no critic(Subroutines::ProhibitExplicitReturnUndef)
    return undef;
} ## end sub Marpa::R3::Internal::MetaAST_Nodes::nulled_event_declaration::evaluate

sub Marpa::R3::Internal::MetaAST_Nodes::prediction_event_declaration::evaluate
{
    my ( $values, $parse ) = @_;
    my ( $start, $length, $raw_event, $raw_symbol_name ) = @{$values};
    my $symbol_name       = $raw_symbol_name->name();
    my $prediction_events = $parse->{prediction_events} //= {};
    if ( defined $prediction_events->{$symbol_name} ) {
        my ( $line, $column ) = $parse->{meta_recce}->line_column($start);
        die qq{prediction event for symbol "$symbol_name" declared twice\n},
            qq{  That is not allowed\n},
            '  Second declaration was ', $parse->substring( $start, $length ),
            "\n",
            "  Problem occurred at line $line, column $column\n";
    } ## end if ( defined $prediction_events->{$symbol_name} )
    $prediction_events->{$symbol_name} = $raw_event->event();
    ## no critic(Subroutines::ProhibitExplicitReturnUndef)
    return undef;
} ## end sub Marpa::R3::Internal::MetaAST_Nodes::prediction_event_declaration::evaluate

sub Marpa::R3::Internal::MetaAST_Nodes::alternatives::evaluate {
    my ( $values, $parse ) = @_;
    return bless [ map { $_->evaluate( $_, $parse ) } @{$values} ],
        ref $values;
}

sub Marpa::R3::Internal::MetaAST_Nodes::alternative::evaluate {
    my ( $values, $parse ) = @_;
    my ( $start, $length, $rhs, $adverbs ) = @{$values};
    my $alternative = eval {
        Marpa::R3::Internal::MetaAST::Proto_Alternative->combine(
            map { $_->evaluate($parse) } $rhs, $adverbs );
    };
    if ( not $alternative ) {
        Marpa::R3::exception(
            $EVAL_ERROR, "\n",
            q{  Alternative involved was },
            $parse->substring( $start, $length )
        );
    } ## end if ( not $alternative )
    return $alternative;
} ## end sub Marpa::R3::Internal::MetaAST_Nodes::alternative::evaluate

sub Marpa::R3::Internal::MetaAST_Nodes::single_symbol::names {
    my ( $values, $parse ) = @_;
    my ( undef, undef, $symbol ) = @{$values};
    return $symbol->names($parse);
}

sub Marpa::R3::Internal::MetaAST_Nodes::single_symbol::name {
    my ( $values, $parse ) = @_;
    my ( undef, undef, $symbol ) = @{$values};
    return $symbol->name($parse);
}

sub Marpa::R3::Internal::MetaAST_Nodes::single_symbol::event_name {
    my ( $values, $parse ) = @_;
    my ( undef, undef, $symbol ) = @{$values};
    return $symbol->event_name($parse);
}

sub Marpa::R3::Internal::MetaAST_Nodes::single_symbol::literal {
    my ( $values, $parse ) = @_;
    my ( $start, $length ) = @{$values};
    return $parse->substring($start, $length);
}

sub Marpa::R3::Internal::MetaAST_Nodes::single_symbol::evaluate {
    my ( $values, $parse ) = @_;
    my ( undef, undef, $symbol ) = @{$values};
    return Marpa::R3::Internal::MetaAST::Symbol_List->new(
        $symbol->name($parse) );
} ## end sub Marpa::R3::Internal::MetaAST_Nodes::single_symbol::evaluate

sub Marpa::R3::Internal::MetaAST_Nodes::Symbol::evaluate {
    my ( $values, $parse ) = @_;
    my ( undef, undef, $symbol ) = @{$values};
    return $symbol->evaluate($parse);
}

sub Marpa::R3::Internal::MetaAST_Nodes::symbol::name {
    my ( $self, $parse ) = @_;
    return $self->[2]->name($parse);
}

sub Marpa::R3::Internal::MetaAST_Nodes::symbol::event_name {
    my ( $self, $parse ) = @_;
    return $self->[2]->name($parse);
}

sub Marpa::R3::Internal::MetaAST_Nodes::symbol::names {
    my ( $self, $parse ) = @_;
    return $self->[2]->names($parse);
}

sub Marpa::R3::Internal::MetaAST_Nodes::symbol_name::evaluate {
    my ($self) = @_;
    return $self->[2];
}

sub Marpa::R3::Internal::MetaAST_Nodes::symbol_name::name {
    my ( $self, $parse ) = @_;
    return $self->evaluate($parse)->name($parse);
}

sub Marpa::R3::Internal::MetaAST_Nodes::symbol_name::names {
    my ( $self, $parse ) = @_;
    return [ $self->name($parse) ];
}

sub Marpa::R3::Internal::MetaAST_Nodes::adverb_list::evaluate {
    my ( $data, $parse ) = @_;
    my ( undef, undef, $adverb_list_items ) = @{$data};
    return undef if not defined $adverb_list_items;
    return $adverb_list_items->evaluate($parse);
} ## end sub Marpa::R3::Internal::MetaAST_Nodes::adverb_list::evaluate

sub Marpa::R3::Internal::MetaAST_Nodes::null_adverb::evaluate {
    return {};
}

sub Marpa::R3::Internal::MetaAST_Nodes::adverb_list_items::evaluate {
    my ( $data, $parse ) = @_;
    my ( undef, undef, @raw_items ) = @{$data};
    my (@adverb_items) = map { $_->evaluate($parse) } @raw_items;
    return Marpa::R3::Internal::MetaAST::Proto_Alternative->combine(
        @adverb_items);
} ## end sub Marpa::R3::Internal::MetaAST_Nodes::adverb_list::evaluate

sub Marpa::R3::Internal::MetaAST_Nodes::character_class::event_name {
    my ( $data,  $parse )  = @_;
    my ( $start, $length ) = @{$data};
    return $parse->substring( $start, $length );
}

sub Marpa::R3::Internal::MetaAST_Nodes::character_class::names {
    my ( $self, $parse ) = @_;
    return [ $self->name($parse) ];
}

sub Marpa::R3::Internal::MetaAST_Nodes::character_class::name {
    my ( $self, $parse ) = @_;
    return $self->evaluate($parse)->name($parse);
}

sub Marpa::R3::Internal::MetaAST_Nodes::character_class::evaluate {
    my ( $values, $parse ) = @_;
    my ( $start, $length, $character_class ) = @{$values};
    my $subgrammar = $Marpa::R3::Internal::SUBGRAMMAR;
    if ( ( substr $subgrammar, 0, 1 ) eq 'l' ) {
        return Marpa::R3::Internal::MetaAST::Symbol_List->char_class_to_symbol(
            $parse, $character_class );
    }

    # If here, in G1
    # Character classes and strings always go into L0, for now
    my $lexer_symbol = do {
        local $Marpa::R3::Internal::SUBGRAMMAR = 'l0';
        Marpa::R3::Internal::MetaAST::Symbol_List->char_class_to_symbol( $parse,
            $character_class );
    };
    my $lexical_lhs  = $parse->internal_lexeme($character_class);
    my $lexical_rhs  = $lexer_symbol->names($parse);
    my %lexical_rule = (
        start  => $start,
        length => $length,
        lhs    => $lexical_lhs,
        rhs    => $lexical_rhs,
        mask   => [1],
    );
    my $wrl = $parse->xpr_create( \%lexical_rule, 'l0' );
    push @{ $parse->{rules}->{l0} }, $wrl;
    my $g1_symbol =
      Marpa::R3::Internal::MetaAST::Symbol_List->new($lexical_lhs);
    return $g1_symbol;
}

sub Marpa::R3::Internal::MetaAST_Nodes::single_quoted_string::evaluate {
    my ( $values, $parse ) = @_;
    my ( $start, $length, $string ) = @{$values};
    my @symbols = ();

    my $end_of_string = rindex $string, q{'};
      my $unmodified_string = substr $string, 0, $end_of_string+1;
      my $raw_flags = substr $string, $end_of_string+1;
    my $flags = Marpa::R3::Internal::MetaAST::flag_string_to_flags($raw_flags);
    my $subgrammar = $Marpa::R3::Internal::SUBGRAMMAR;

    # If we are currently in a lexical grammar, the strings go there
    # If we are currently in G1, the strings always go into L0
    my $lexical_grammar = $subgrammar eq 'g1' ? 'l0' : $subgrammar;

    for my $char_class (
        map { '[' . ( quotemeta $_ ) . ']' . $flags } split //xms,
        substr $unmodified_string,
        1, -1
        )
    {
        local $Marpa::R3::Internal::SUBGRAMMAR = $lexical_grammar;
        my $symbol =
            Marpa::R3::Internal::MetaAST::Symbol_List->char_class_to_symbol(
            $parse, $char_class );
        push @symbols, $symbol;
    } ## end for my $char_class ( map { '[' . ( quotemeta $_ ) . ']'...})
    my $list = Marpa::R3::Internal::MetaAST::Symbol_List->combine(@symbols);
    return $list if $Marpa::R3::Internal::SUBGRAMMAR ne 'g1';
    my $lexical_lhs       = $parse->internal_lexeme($string);
    my $lexical_rhs       = $list->names($parse);
    my %lexical_rule      = (
        start => $start,
        length => $length,
        lhs  => $lexical_lhs,
        rhs  => $lexical_rhs,
        # description => "Internal rule for single-quoted string $string",
        mask => [ map { ; 1 } @{$lexical_rhs} ],
    );
    my $wrl = $parse->xpr_create( \%lexical_rule, 'l0' );
    push @{ $parse->{rules}->{$lexical_grammar} }, $wrl;
    my $g1_symbol =
        Marpa::R3::Internal::MetaAST::Symbol_List->new($lexical_lhs);
    return $g1_symbol;
} ## end sub Marpa::R3::Internal::MetaAST_Nodes::single_quoted_string::evaluate

package Marpa::R3::Internal::MetaAST::Symbol_List;

use English qw( -no_match_vars );

sub new {
    my ( $class, $name ) = @_;
    return bless { names => [ q{} . $name ], mask => [1] }, $class;
}

sub combine {
    my ( $class, @lists ) = @_;
    my $self = {};
    $self->{names} = [ map { @{ $_->names() } } @lists ];
    $self->{mask}  = [ map { @{ $_->mask() } } @lists ];
    return bless $self, $class;
} ## end sub combine

sub Marpa::R3::Internal::MetaAST::char_class_to_re {
    my ($cc_components) = @_;
    die if ref $cc_components ne 'ARRAY';
    my ( $char_class, $flags ) = @{$cc_components};
    $flags = $flags ? '(' . q{?} . $flags . ')' : q{};
    my $regex;
    my $error;
    if ( not defined eval { $regex = qr/$flags$char_class/xms; 1; } ) {
        $error = qq{Problem in evaluating character class: "$char_class"\n};
        $error .= qq{  Flags were "$flags"\n} if $flags;
        $error .= $EVAL_ERROR;
    }
    return $regex, $error;
}

sub Marpa::R3::Internal::MetaAST::flag_string_to_flags {
    my ($raw_flag_string) = @_;
    return q{} if not $raw_flag_string;
    my @raw_flags = split m/:/xms, $raw_flag_string;
    my %flags = ();
    RAW_FLAG: for my $raw_flag (@raw_flags) {
        next RAW_FLAG if not $raw_flag;
        if ( $raw_flag eq 'i' ) {
            $flags{'i'} = 1;
            next RAW_FLAG;
        }
        if ( $raw_flag eq 'ic' ) {
            $flags{'i'} = 1;
            next RAW_FLAG;
        }
        Carp::croak(
            qq{Bad flag for character class\n},
            qq{  Flag string was $raw_flag_string\n},
            qq{  Bad flag was $raw_flag\n}
        );
    } ## end RAW_FLAG: for my $raw_flag (@raw_flags)
    my $cooked_flags = join q{}, sort keys %flags;
    return $cooked_flags;
} ## end sub flag_string_to_flags

# Return the character class symbol name,
# after ensuring everything is set up properly
sub char_class_to_symbol {
    my ( $class, $parse, $char_class ) = @_;

    my $end_of_char_class = rindex $char_class, q{]};
    my $unmodified_char_class = substr $char_class, 0, $end_of_char_class + 1;
    my $raw_flags = substr $char_class, $end_of_char_class + 1;
    my $flags = Marpa::R3::Internal::MetaAST::flag_string_to_flags($raw_flags);
    my $subgrammar = $Marpa::R3::Internal::SUBGRAMMAR;

    # character class symbol name always start with TWO left square brackets
    my $symbol_name = '[' . $unmodified_char_class . $flags . ']';
    $parse->{character_classes} //= {};
    my $cc_hash = $parse->{character_classes};
    my ( undef, $symbol ) = $cc_hash->{$symbol_name};
    if ( not defined $symbol ) {

        my $cc_components = [ $unmodified_char_class, $flags ];

 # Fast fail on badly formed char_class -- we re-evaluate the regex just in time
 # before we register characters.
        my ( $regex, $eval_error ) =
          Marpa::R3::Internal::MetaAST::char_class_to_re($cc_components);
        Carp::croak( 'Bad Character class: ',
            $char_class, "\n", 'Perl said ', $eval_error )
          if not $regex;

        $symbol = Marpa::R3::Internal::MetaAST::Symbol_List->new($symbol_name);
        $cc_hash->{$symbol_name} = [ $cc_components, $symbol ];

        # description  => "Character class: $char_class"
        my $symbol_data = {
            dsl_form    => $char_class,
            name_source => 'internal',
        };

        # description  => "Character class: $char_class"
        $parse->xsy_create( $symbol_name, $symbol_data );
        $symbol_data = { xsy => $symbol_name };
        $parse->symbol_names_set( $symbol_name, $subgrammar, $symbol_data );
    } ## end if ( not defined $symbol )
    return $symbol;
} ## end sub char_class_to_symbol

sub Marpa::R3::Internal::MetaAST::Parse::symbol_names_set {
    my ( $parse, $symbol, $subgrammar, $args ) = @_;
    my $symbol_type = $subgrammar eq 'g1' ? 'g1' : 'l0';
    my $wsyid = $parse->{next_wsyid}++;
    $parse->{symbols}->{$symbol_type}->{$symbol}->{wsyid} = $wsyid;
    for my $arg_type (keys %{$args}) {
        my $value = $args->{$arg_type};
        $parse->{symbols}->{$symbol_type}->{$symbol}->{$arg_type} = $value;
    }
    return $parse->{symbols}->{$symbol_type}->{$symbol};
}

# Return the priotized symbol name,
# after ensuring everything is set up properly
sub Marpa::R3::Internal::MetaAST::Parse::prioritized_symbol {
    my ( $parse, $base_symbol, $priority ) = @_;

    # character class symbol name always start with TWO left square brackets
    my $symbol_name = $base_symbol . '[' . $priority . ']';
    my $current_symbol_data =
      $parse->{symbols}
      ->{ $Marpa::R3::Internal::SUBGRAMMAR eq 'g1' ? 'g1' : 'l0' }
      ->{$symbol_name};
    return $symbol_name if defined $current_symbol_data;

    # description  => "<$base_symbol> at priority $priority"
    my $symbol_data = {
        dsl_form    => $base_symbol,
        name_source => 'lexical',
    };
    $parse->xsy_assign( $base_symbol, $symbol_data );
    $symbol_data = { xsy => $base_symbol };
    $parse->symbol_names_set( $symbol_name, $Marpa::R3::Internal::SUBGRAMMAR,
        $symbol_data );
    return $symbol_name;
} ## end sub Marpa::R3::Internal::MetaAST::Parse::prioritized_symbol

sub Marpa::R3::Internal::MetaAST::Parse::discard_symbol_assign {
    my ( $parse, $symbol_name ) = @_;

    my $current_symbol_data =
        $parse->{symbols}->{'l0'}->{$symbol_name};
    return $symbol_name if defined $current_symbol_data;

    my $symbol_data = {
        dsl_form    => $symbol_name,
        name_source => 'lexical',
    };
    $parse->xsy_assign( $symbol_name, $symbol_data );
    $symbol_data = { xsy => $symbol_name };
    return $parse->symbol_names_set( $symbol_name, 'l0', $symbol_data );
} ## end sub Marpa::R3::Internal::MetaAST::Parse::prioritized_symbol

sub Marpa::R3::Internal::MetaAST::Parse::xsy_create {
    my ( $parse, $symbol_name, $args ) = @_;
    my $xsy_data = $parse->{xsy}->{$symbol_name} = {};

    # Do I need to copy any more?
    # Can't I just use $args?
    for my $datum (keys %{$args}) {
        my $value = $args->{$datum};
        $xsy_data->{$datum} = $value;
    }
    return $xsy_data;
}

sub Marpa::R3::Internal::MetaAST::Parse::xsy_assign {
    my ( $parse, $symbol_name, $args ) = @_;
    my $xsy_data = $parse->{xsy}->{$symbol_name};
    return $xsy_data if $xsy_data;
    return $parse->xsy_create( $symbol_name, $args );
}

# eXternal RuLe
# At the moment, these are only for rules which can share
# a LHS with a precedenced rule.
sub Marpa::R3::Internal::MetaAST::xrl_create {
    my ( $parse, $new_xrl ) = @_;
    my $lhs    = $new_xrl->{lhs};
    my $start  = $new_xrl->{start};
    my $length = $new_xrl->{length};
    $new_xrl->{precedence_count} //= 1;
    my $xrlid = sprintf '%s@%d+%d', $lhs, $start, $length;
    my $xrls_by_lhs = $parse->{xrls_by_lhs}->{$lhs};

    my $earlier_xrl = $xrls_by_lhs->[0];
    if (    $earlier_xrl
        and $earlier_xrl->{precedence_count} > 1
        || $new_xrl->{precedence_count} > 1 )
    {

        # If there was an earlier precedenced xrl
        # that needed to be unique for this LHS,
        # it was the only pre-existing xrl.
        # That's because we will never add another one, once it is on
        # list of XRLs by LHS.
        Marpa::R3::Internal::X->new(
            {
                desc      => 'LHS not unique when required',
                xrl1      => $earlier_xrl,
                xrl2      => $new_xrl,
                to_string => sub {
                    my $self   = shift;
                    my @string = ('Precedenced LHS not unique');

                    my $pos1 = $self->{xrl1}->{start};
                    my $len1 = $self->{xrl1}->{length};
                    push @string,
                      Marpa::R3::Internal::substr_as_2lines(
                        (
                            $self->{xrl1}->{precedence_count} > 1
                            ? 'First precedenced rule'
                            : 'First rule'
                        ),
                        $parse->{p_dsl},
                        $pos1, $len1, 74
                      );

                    my $pos2 = $self->{xrl2}->{start};
                    my $len2 = $self->{xrl2}->{length};
                    push @string,
                      Marpa::R3::Internal::substr_as_2lines(
                        (
                            $self->{xrl2}->{precedence_count} > 1
                            ? 'Second precedenced rule'
                            : 'Second rule'
                        ),
                        $parse->{p_dsl},
                        $pos2, $len2, 74
                      );
                    push @string, q{};

                    return join "\n", @string;
                }
            }
        )->throw();
    }

    my $xrl_by_id = $parse->{xrl}->{$xrlid} = $new_xrl;
    push @{ $parse->{xrls_by_lhs}->{$lhs} }, $new_xrl;
    return $xrlid;
}

sub Marpa::R3::Internal::MetaAST::Parse::xpr_create {
    my ( $parse, $args, $subgrammar ) = @_;

    # The eXternal ALTernative is the argument hash,
    # slightly adjusted.
    $subgrammar //= 'g1';
    $args->{subgrammar} //= $subgrammar;
    $args->{subkey} //= 0;
    my $rule_id = join q{,}, $subgrammar, $args->{lhs}, @{$args->{rhs}};
    my $hash_by_xprid = $parse->{xpr}->{$subgrammar};
    if ( exists $hash_by_xprid->{$rule_id} ) {
        my $other_xpr = $hash_by_xprid->{$rule_id};
        my $pos1   = $other_xpr->{start};
        my $len1   = $other_xpr->{length};
        my $pos2   = $args->{start};
        my $len2   = $args->{length};
        my @string = (
            "Duplicate rules:",
            Marpa::R3::Internal::substr_as_2lines(
                'First rule', $parse->{p_dsl}, $pos1, $len1, 74
            ),
            Marpa::R3::Internal::substr_as_2lines(
                'Second rule', $parse->{p_dsl}, $pos2, $len2, 74
            )
        );
        Marpa::R3::exception( join "\n", @string, q{} );
    }
    $hash_by_xprid->{$rule_id} = $args;

    # Now create the initial working rule
    my %wrl = (
        xprid => $rule_id,
        subgrammar => $subgrammar,
    );
    # Shallow copy
    for my $field (
        qw(lhs action rank
        null_ranking min separator proper )
      )
    {
        $wrl{$field} = $args->{$field} if defined $args->{$field};
    }
    # 'rhs' needs special treatment --
    #    a deeper code and creation of the xpr_dot field
    {
        my $rhs = $args->{rhs};
        my $xpr_datum = $rhs;
        my @array = @{$rhs};
        $wrl{rhs} = \@array;
        $wrl{xpr_dot} = [0 .. (scalar @array) ]
    }

    # Return the initial working rule
    return \%wrl;

}

# Return the prioritized symbol name,
# after ensuring everything is set up properly
sub Marpa::R3::Internal::MetaAST::Parse::internal_lexeme {
    my ( $parse, $dsl_form, @grammars ) = @_;

    # character class symbol name always start with TWO left square brackets
    my $lexical_lhs_index = $parse->{lexical_lhs_index}++;
    my $lexical_symbol    = "[Lex-$lexical_lhs_index]";

    # description  => qq{Internal lexical symbol for "$dsl_form"}
    my $symbol_data = {
        dsl_form => $dsl_form,
        name_source => 'internal'
    };
    $parse->xsy_assign( $lexical_symbol, $symbol_data );
    $symbol_data = { xsy => $lexical_symbol };
    $parse->symbol_names_set( $lexical_symbol, $_, $symbol_data ) for qw(g1 l0);
    return $lexical_symbol;
} ## end sub Marpa::R3::Internal::MetaAST::Parse::internal_lexeme

sub name {
    my ($self) = @_;
    my $names = $self->{names};
    Marpa::R3::exception( 'list->name() on symbol list of length ',
        scalar @{$names} )
        if scalar @{$names} != 1;
    return $self->{names}->[0];
} ## end sub name
sub names { return shift->{names} }
sub mask  { return shift->{mask} }

sub mask_set {
    my ( $self, $mask ) = @_;
    return $self->{mask} = [ map {$mask} @{ $self->{mask} } ];
}

1;

# vim: expandtab shiftwidth=4:
