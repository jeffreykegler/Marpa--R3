use 5.010;

use Data::Dumper;
use Marpa::R2;

my $grammar = Marpa::R2::Scanless::G->new(
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

sub My_Actions::top {
    my ($ppo, @children) = @_;
    return [grep { $_ } @children ];
}

my $recce = Marpa::R2::Scanless::R->new( { grammar => $grammar } );

my $input = 'yyyxxxyyyyyxxxxxyyyyxyyyyxxyyyyxxxxyyy';
my $length = length $input;
for (
    my $pos = $recce->read( \$input );
    $pos < $length;
    $pos = $recce->resume()
    )
{
  EVENT:
    for my $event ( @{ $recce->events() } ) {
	my ($name) = @{$event};
	say "Event $name at $pos";
    }
}

