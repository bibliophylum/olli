package Olli::REST::API::libraries ;
use warnings ;
use strict ;
use base qw/Apache2::REST::Handler/;
use DBI;
#use JSON;


# Implement the GET HTTP method.
sub GET {
    my ($self, $request, $response) = @_ ;

    # NOTE: "rld" should now be "olli" !!!
    my $dbh = DBI->connect("dbi:Pg:database=olli;host=localhost;port=5432",
			   "olli",
			   "olli",
			   {AutoCommit => 1, 
			    RaiseError => 1, 
			    PrintError => 0,
			   }
	) or die $DBI::errstr;
    
    $dbh->do("SET TIMEZONE='America/Winnipeg'");

    my $SQL = "select id, year, name, established, fee_nonresident_single, fee_nonresident_family, case when is_registered_charity then 'registered' else '' end as is_registered_charity, case when has_access_copyright_license then 'access-copyright' else '' end as has_access_copyright_license, case when has_board_minutes_on_website then 'board-minutes' else '' end as has_board_minutes_on_website, strategic_plan_start, strategic_plan_end, case when has_technology_plan then 'tech-plan' else '' end as has_technology_plan, case when is_confirmed then 'confirmed' else 'pending' end as is_confirmed from libraries order by year, name";
    my $aref = $dbh->selectall_arrayref($SQL, { Slice => {} });
    $dbh->disconnect;
    
#    my $json =  to_json( { municipalities => $aref } );

    $response->data()->{'api_mess'} = 'Hello, this is Olli REST API: libraries' ;
    $response->data()->{'libraries'} = $aref;
    return Apache2::Const::HTTP_OK ;
}

# Authorize the GET method.
sub isAuth{
    my ($self, $method, $req) = @ _; 
    return $method eq 'GET';
}

# eg: libraries/600
sub buildNext{
    my ( $self , $frag , $req ) = @_ ;
    print STDERR "libraries.pm buildNext [$frag]\n";
    my $subh;
    if ($frag eq "branches") {
	$subh = Olli::REST::API::libraries::branches->new($self) ;
    } else {
	$subh = Olli::REST::API::libraries::library->new($self) ;
	$subh->{'libid'} = $frag  ;
    }

    return $subh ;
}

1 ;

