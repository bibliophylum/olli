package Olli::REST::API::branches::branch ;
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

    # Branch's parent library
    my $lib = $dbh->selectrow_hashref(
	"select l.id, l.year, l.name from libraries l left join branches b on b.library_id = l.id where b.id=?",
	{ Slice => {} }, 
	$self->branchid()
	);

    # Branch
    my $branch = $dbh->selectrow_hashref(
	"select b.municipality_id, m.name as located, b.name as branch, b.symbol, b.facility_owner, b.annual_rent, b.floor_space, b.active_memberships, b.nonresident_single_memberships, b.nonresident_family_memberships, b.facility_term_expires, b.is_confirmed from branches b left join municipalities m on m.id=b.municipality_id where b.id=?",
	{ Slice => {} },
	$self->branchid()
	);

    # Hours of operation
    my $hours_aref = $dbh->selectall_arrayref(
	"select b.name as branch, h.seasonal, h.season_begins, h.season_ends, h.sunday, h.monday, h.tuesday, h.wednesday, h.thursday, h.friday, h.saturday, h.per_week, h.is_confirmed from hours_of_operation h left join branches b on b.id=h.branch_id where h.branch_id=?",
	{ Slice => {} },
	$self->branchid()
	);

    # Contacts
    my $contacts_aref = $dbh->selectall_arrayref(
	"select b.name as branch, c.librarian, c.phone, c.fax, c.email_general, c.email_admin, c.email_ill, c.street, c.box, c.town, c.province, c.postal_code, c.website, c.catalogue from contact c left join branches b on b.id=c.branch_id where c.branch_id=?",
	{ Slice => {} },
	$self->branchid()
	);

    # Collections
    my $collections_aref = $dbh->selectall_arrayref(
	"select b.name as branch, c.english, c.french, c.other, c.serial_subscriptions, c.is_confirmed from collections c left join branches b on b.id=c.branch_id where c.branch_id=?",
	{ Slice => {} },
	$self->branchid()
	);

    # Circulations
    my $circulations_aref = $dbh->selectall_arrayref(
	"select b.name as branch, c.adult, c.children, c.audio_visual, c.ebooks, c.is_confirmed from circulations c left join branches b on b.id=c.branch_id where c.branch_id=?",
	{ Slice => {} },
	$self->branchid()
	);
    
    $dbh->disconnect;
    
#    my $json =  to_json( { municipalities => $aref } );

    $response->data()->{'api_mess'} = 'Hello, this is Olli REST API: libraries/:library' ;
    $response->data()->{'library'} = $lib;
    $response->data()->{'branch'} = $branch;
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
