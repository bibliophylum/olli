package Olli::REST::API::municipalities ;
use warnings ;
use strict ;
use base qw/Apache2::REST::Handler/;
use DBI;
#use JSON;


# Implement the GET HTTP method.
sub GET_dummy{
    my ($self, $request, $response) = @_ ;
    # dummy data
    my @muns = (
	{name => "Albert", pop => "1234"},
	{name => "Bob", pop => "2345"},
	{name => "Charlie", pop => "3456"}
	);
    $response->data()->{'api_mess'} = 'Hello, this is Olli REST API: municipalities' ;
    $response->data()->{'municipalities'} = \@muns;
    return Apache2::Const::HTTP_OK ;
}

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

    my $SQL = "select id, year, name, population, case when is_bilingual then 'bilingual' else '' end as is_bilingual, case when is_northern then 'northern' else '' end as is_northern from municipalities order by year, name";
    my $aref = $dbh->selectall_arrayref($SQL, { Slice => {} });
    $dbh->disconnect;
    
#    my $json =  to_json( { municipalities => $aref } );

    $response->data()->{'api_mess'} = 'Hello, this is Olli REST API' ;
    $response->data()->{'municipalities'} = $aref;
    return Apache2::Const::HTTP_OK ;
}

# Authorize the GET method.
sub isAuth{
    my ($self, $method, $req) = @ _; 
    return $method eq 'GET';
}

1 ;
