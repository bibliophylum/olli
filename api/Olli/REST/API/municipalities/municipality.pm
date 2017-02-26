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
    my $dbh = DBI->connect("dbi:Pg:database=olli;host=localhost;port=5432",
			   "olli",
			   "olli",
			   {AutoCommit => 1, 
			    RaiseError => 1, 
			    PrintError => 0,
			   }
	) or die $DBI::errstr;
    
    $dbh->do("SET TIMEZONE='America/Winnipeg'");

    # municipality id is in $self->munid() (from ../municipalities.pm's buildNext)

    
    # Base municipality data
    my $SQL = "select id, year, name, population, case when is_bilingual then 'bilingual' else '' end as is_bilingual, case when is_northern then 'northern' else '' end as is_northern from municipalities where id=?";
    my $muni = $dbh->selectrow_hashref($SQL, { Slice => {} }, $self->munid() );


    # Libraries that this municipality contributes to
    my $libs_aref = $dbh->selectall_arrayref(
        "select l.id, l.name, lm.contribution from libmun lm left join libraries l on l.id=lm.library_id where lm.municipality_id=?",
        { Slice => {} },
        $self->munid()
        );

    
    # Census info for this municipality
    # get most recent census year less than or equal to the municipality year
    my $census_year = $dbh->selectrow_hashref(
	"select id,value as year from census_year where value <= ? order by value desc limit 1",
	undef,
	$muni->{'year'}
	);

    my $c = $dbh->selectall_arrayref(
	"select t.value as topic, ch.value as characteristic, c.ord as ord, sum(CAST(coalesce(nullif(c.male,   ''),'0') AS numeric)) as male, sum(CAST(coalesce(nullif(c.female, ''),'0') AS numeric)) as female, sum(CAST(coalesce(nullif(c.total,  ''),'0') AS numeric)) as total from census c  left join mun_cen mc on mc.census_subdivision_id = c.subdivision_id left join census_topic t on t.id=c.topic_id left join census_characteristics ch on ch.id=c.characteristics_id where mc.municipality_id = ? group by t.value, c.ord, ch.value order by t.value, c.ord, ch.value",
	{ Slice => {} },
	$self->munid()
	);

    my @census;
    my $topic = { 'topic' => $c->[0]->{'topic'}, 'details' => [] };
    foreach my $cen (@$c) {
	if ($cen->{'topic'} ne $topic->{'topic'}) {
	    push @census, { %$topic };
	    $topic = { 'topic' => $cen->{'topic'}, 'details' => [] };
	}
	push @{ $topic->{'details'} }, $cen;
    }
    
    $dbh->disconnect;
    
    $response->data()->{'api_mess'} = 'Hello, this is Olli REST API' ;
    $response->data()->{'municipality'} = $muni;
    $response->data()->{'contributions'} = $libs_aref;
    $response->data()->{'census_year'} = $census_year;
    $response->data()->{'census'} = \@census;
#    $response->data()->{'census'} = \@census;
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
