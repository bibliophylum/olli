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

    # Branches
    my $branches_aref = $dbh->selectall_arrayref(
	"select b.municipality_id, m.name as located, b.name as branch, b.symbol, b.facility_owner, b.annual_rent, b.floor_space, b.active_memberships, b.nonresident_single_memberships, b.nonresident_family_memberships, b.facility_term_expires, b.is_confirmed from branches b left join municipalities m on m.id=b.municipality_id where b.library_id=? order by b.name",
	{ Slice => {} },
	$self->libid()
	);

    # Hours of operation
    my $hours_aref = $dbh->selectall_arrayref(
	"select b.name as branch, h.seasonal, h.season_begins, h.season_ends, h.sunday, h.monday, h.tuesday, h.wednesday, h.thursday, h.friday, h.saturday, h.per_week, h.is_confirmed from hours_of_operation h left join branches b on b.id=h.branch_id where h.branch_id in (select id from branches where library_id=?) order by b.name, h.seasonal",
	{ Slice => {} },
	$self->libid()
	);

    # Contacts
    my $contacts_aref = $dbh->selectall_arrayref(
	"select b.id as branch_id, b.name as branch, c.librarian, c.phone, c.fax, c.email_general, c.email_admin, c.email_ill, c.street, c.box, c.town, c.province, c.postal_code, c.website, c.catalogue from contact c left join branches b on b.id=c.branch_id where c.branch_id in (select id from branches where library_id=?) order by b.name",
	{ Slice => {} },
	$self->libid()
	);

    # Collections
    my $collections_aref = $dbh->selectall_arrayref(
	"select b.name as branch, c.english, c.french, c.other, c.serial_subscriptions, c.is_confirmed from collections c left join branches b on b.id=c.branch_id where c.branch_id in (select id from branches where library_id=?) order by b.name",
	{ Slice => {} },
	$self->libid()
	);

    # Circulations
    my $circulations_aref = $dbh->selectall_arrayref(
	"select b.name as branch, c.adult, c.children, c.audio_visual, c.ebooks, c.is_confirmed from circulations c left join branches b on b.id=c.branch_id where c.branch_id in (select id from branches where library_id=?) order by b.name",
	{ Slice => {} },
	$self->libid()
	);
    
    $dbh->disconnect;
    
#    my $json =  to_json( { municipalities => $aref } );

    $response->data()->{'api_mess'} = 'Hello, this is Olli REST API: libraries/:library' ;
    $response->data()->{'library'} = $lib;
    $response->data()->{'contributors'} = $muns_aref;
    $response->data()->{'branches'} = $branches_aref;
    $response->data()->{'hours'} = $hours_aref;
    $response->data()->{'contacts'} = $contacts_aref;
    $response->data()->{'collections'} = $collections_aref;
    $response->data()->{'circulations'} = $circulations_aref;
    return Apache2::Const::HTTP_OK ;
}

# Authorize the GET method.
sub isAuth{
    my ($self, $method, $req) = @ _; 
    return $method eq 'GET';
}

1 ;
