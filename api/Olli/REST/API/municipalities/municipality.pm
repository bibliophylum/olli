package Olli::REST::API::municipalities::municipality ;
use warnings ;
use strict ;
use base qw/Apache2::REST::Handler/;
use DBI;
#use JSON;

# Implement the GET HTTP method.
sub GET {
    my ($self, $request, $response) = @_ ;

    # NOTE: "rld" should now be "olli" !!!
    my $dbh = DBI->connect("dbi:Pg:database=rld;host=localhost;port=5432",
			   "rld",
			   "rld",
			   {AutoCommit => 1, 
			    RaiseError => 1, 
			    PrintError => 0,
			   }
	) or die $DBI::errstr;
    
    $dbh->do("SET TIMEZONE='America/Winnipeg'");

    # municipality id is in $self->munid() (from ../municipalities.pm's buildNext)
    
    my $SQL = "select id, year, name, population, case when is_bilingual then 'bilingual' else '' end as is_bilingual, case when is_northern then 'northern' else '' end as is_northern from municipalities where id=?";
    my $href = $dbh->selectrow_hashref($SQL, { Slice => {} }, $self->munid() );
    $dbh->disconnect;
    
    $response->data()->{'api_mess'} = 'Hello, this is Olli REST API' ;
    $response->data()->{'municipality'} = $href;
    return Apache2::Const::HTTP_OK ;
}

# Authorize the GET method.
sub isAuth{
    my ($self, $method, $req) = @ _; 
    return $method eq 'GET';
}

# eg: municipalities/600
#sub buildNext{
#    my ( $self , $frag , $req ) = @_ ;
#    
#    my $subh = Apache2::REST::Handler::municipalities::municipality->new($self) ;
#    $subh->{'munid'} = $frag  ;
#    return $subh ;
#}


1 ;
