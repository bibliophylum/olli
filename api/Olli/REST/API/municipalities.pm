package Olli::REST::API::municipalities ;
use warnings ;
use strict ;
use base qw/Apache2::REST::Handler/;

# Implement the GET HTTP method.
sub GET{
    my ($self, $request, $response) = @_ ;
    # dummy data
    my @muns = (
	{name => "Albert", pop => "1234"},
	{name => "Bob", pop => "2345"},
	{name => "Charlie", pop => "3456"}
	);
    $response->data()->{'api_mess'} = 'Hello, this is Olli REST API' ;
    $response->data()->{'municipalities'} = \@muns;
    return Apache2::Const::HTTP_OK ;
}
# Authorize the GET method.
sub isAuth{
    my ($self, $method, $req) = @ _; 
    return $method eq 'GET';
}

1 ;
