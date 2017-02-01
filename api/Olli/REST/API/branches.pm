package Olli::REST::API::branches ;
use warnings ;
use strict ;
use base qw/Apache2::REST::Handler/;
use DBI;
#use JSON;


# Implement the GET HTTP method.
sub GET {
    my ($self, $request, $response) = @_ ;

    return Apache2::Const::HTTP_OK ;
}

# Authorize the GET method.
sub isAuth{
    my ($self, $method, $req) = @ _; 
    return $method eq 'GET';
}

# eg: branches/600
sub buildNext{
    my ( $self , $frag , $req ) = @_ ;
    
    my $subh = Olli::REST::API::branches::branch->new($self) ;
    $subh->{'branchid'} = $frag  ;
    return $subh ;
}
1 ;
