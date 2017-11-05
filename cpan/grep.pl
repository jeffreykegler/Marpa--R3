use 5.010;

use Data::Dumper;
use Marpa::R3;

my $grammar = Marpa::R3::Grammar->new(
    {   source        => \(<<'END_OF_DSL'),
:default ::= action => [name,values]
lexeme default = action => [ start, length, value ]

# standard part of grammar
top ::= prefix target action => My_Actions::top
prefix ::= any* action => ::undef
any ~ [\D\d]

# custom part of grammar
target ::= x_pair+ action => [ start, length ]
x_pair ::= 'x' 'x'
END_OF_DSL
    }
);

sub My_Actions::top {
    my ($ppo, $children) = @_;
    return [grep { $_ } @{$children} ];
}

my $recce = Marpa::R3::Scanless::R->new( { grammar => $grammar } );

my $piece = 'yyyxxxyyyyyxxxxxyyyyxyyyyxxyyyyxxxxyyy';
my $input = $piece x 3;
$recce->read(\$input);
say $recce->show_earley_sets();
my $length = length $input;
TOKEN: for ( my $i = 0; $i < $length; $i++ ) {
    my $size = $recce->earley_set_size($i);
    say "Set $i, size=$size";
}
exit 0;

VALUE: while (1) {
  my $value_ref = $recce->value();
  last VALUE if not $value_ref;
  my $value = $$value_ref;
  # die Data::Dumper::Dumper($value);
  my @target_desc = @{$value};
  my ($start, $length) = @{$target_desc[0]};
  say "Match found at $start, length=$length";
}

