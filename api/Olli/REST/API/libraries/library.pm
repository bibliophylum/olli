package Olli::REST::API::libraries::library ;
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

    my $SQL = "select id, year, name, established, fee_nonresident_single, fee_nonresident_family, case when is_registered_charity then 'registered' else '' end as is_registered_charity, case when has_access_copyright_license then 'access-copyright' else '' end as has_access_copyright_license, case when has_board_minutes_on_website then 'board-minutes' else '' end as has_board_minutes_on_website, strategic_plan_start, strategic_plan_end, case when has_technology_plan then 'tech-plan' else '' end as has_technology_plan, case when is_confirmed then 'confirmed' else 'pending' end as is_confirmed from libraries where id=?";
    my $lib = $dbh->selectrow_hashref($SQL, { Slice => {} }, $self->libid);

    # Municipalities contributing to this library
    my $muns_aref = $dbh->selectall_arrayref(
        "select m.id, m.name, lm.contribution from libmun lm left join municipalities m on m.id=lm.municipality_id where lm.library_id=?",
        { Slice => {} },
        $self->libid()
        );

    $dbh->disconnect;
    
#    my $json =  to_json( { municipalities => $aref } );

    $response->data()->{'api_mess'} = 'Hello, this is Olli REST API: libraries/:library' ;
    $response->data()->{'library'} = $lib;
    $response->data()->{'contributors'} = $muns_aref;
    return Apache2::Const::HTTP_OK ;
}

# Authorize the GET method.
sub isAuth{
    my ($self, $method, $req) = @ _; 
    return $method eq 'GET';
}

1 ;