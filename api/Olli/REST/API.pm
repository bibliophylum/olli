package Olli::REST::API ;
use warnings ;
use strict ;

use Olli::REST::API::municipalities;

use base qw/Apache2::REST::Handler/;

# Implement the GET HTTP method.
sub GET{
    my ($self, $request, $response) = @_ ;
    $response->data()->{'api_mess'} = 'Hello, this is Olli REST API' ;
    return Apache2::Const::HTTP_OK ;
}

# Authorize the GET method.
sub isAuth{
    my ($self, $method, $req) = @ _; 
    return $method eq 'GET';
}

sub buildNext{
    my ( $self , $frag , $req ) = @_ ;
    
    my $subh = Olli::REST::API::municipalities->new($self) ;
#    $subh->{'userid'} = $frag  ;
    return $subh ;
}

1 ;
