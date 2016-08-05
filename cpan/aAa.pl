use 5.010;
use Pegex;
use Data::Dumper;

$grammar = "
A: a A a | a a
a: /(a)/
";

for my $n ( 2 .. 17 ) {
    my $result;
    my $ok = eval {
        $result = Dumper( pegex( $grammar, 'Pegex::Tree' )
              ->parse( Pegex::Input->new( string => ( 'a' x $n ) ) ) );
        1;
    };
    say $EVAL_ERROR if !$ok;
    say "$n: $result";
}
