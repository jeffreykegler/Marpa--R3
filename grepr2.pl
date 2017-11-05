use 5.010;

use Data::Dumper;
use Marpa::R2;
use strict;
use warnings;

my $grammar = Marpa::R2::Grammar->new(
    {   source        => \(<<'END_OF_DSL'),
:default ::= action => [name,values]
lexeme default = action => [ start, length, value ]

# standard part of grammar
top ::= prefix target
  action => My_Actions::top
prefix ::= any* action => ::undef
any ~ [\D\d]

event 'hit!' = completed top

# custom part of grammar
target ::= x_pair+ action => [ start, length ]
x_pair ::= 'x' 'x'
END_OF_DSL
    }
);

my $target_rule_id;
RULE: for my $rule_id ($grammar->rule_ids()) {
  my ($lhs_id) = $grammar->rule_expand($rule_id);
  my $lhs_name = $grammar->symbol_name($lhs_id);
  if ($lhs_name eq 'target') {
     $target_rule_id = $rule_id;
     # say "LHS of rule $rule_id is $lhs_name";
     last RULE;
  }
}

sub My_Actions::top {
    my ($ppo, @children) = @_;
    return [grep { $_ } @children ];
}

my $recce = Marpa::R2::Scanless::R->new( { grammar => $grammar } );

my $input = '012xxx67890xxxxx6789x1234xx7890xxxx567';
my $length = length $input;
my @hits = ();
for (
    my $pos = $recce->read( \$input );
    $pos < $length;
    $pos = $recce->resume()
    )
{
  my $hit = scalar @{ $recce->events() };
  if ($hit) {
      my $items = $recce->progress();
      push @hits,
	map { [ $_->[2], $pos ] }
	grep { $_->[0] == $target_rule_id and $_->[1] == -1 }
	@{$items};
  }
}

say "Target: (xx)*";
say "Input: ", $input;
for my $hit (sort { $a->[0] <=> $b->[0] or $a->[1] <=> $b->[1] } @hits) {
   my ($start, $end) = @{$hit};
   say sprintf "Target found: start = %d, end = %d", $start, $end-1;
}
