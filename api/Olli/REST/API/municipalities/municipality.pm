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

    # There may be more than one census division/subdivision for a given municipality
    # (especially on or after 2015 amalgamation)... so we need to handle that.
    my $muncen = $dbh->selectall_arrayref(
	"select census_division_id,census_subdivision_id from mun_cen where municipality_id=?",
	{ Slice => {} },
	$self->munid()
	);

    my @census;
    foreach my $mc (@$muncen) {
	my $census_details = $dbh->selectall_arrayref(
	    "select y.value as year, d.value as division, s.value as subdivision, sdt.value as type, t.value as topic, c.ord as ord, ch.value as characteristic, ch.format_mask, c.total, c.male, c.female from census c left join census_year y on y.id=c.year_id left join census_division d on d.id=c.division_id left join census_subdivision s on s.id=c.subdivision_id left join census_subdivision_type sdt on sdt.id=s.sdtype_id left join census_topic t on t.id=c.topic_id left join census_characteristics ch on ch.id=c.characteristics_id where y.id=? and d.id=? and s.id=? order by year,division,subdivision,type,topic,ord,characteristic",
	    { Slice => {} },
	    $census_year->{id},
	    $mc->{census_division_id},
	    $mc->{census_subdivision_id}
	    );
	push @census, $census_details;
    }
    #    print Dumper($census[0]);

    my %c = ();
    my $c = \%c;
    foreach my $cdarr (@census) {
	foreach my $cd (@$cdarr) {
	    if (!defined $c{ $cd->{topic} }) {
		$c{ $cd->{topic} } = {};
	    }
	    if (!defined $c{ $cd->{topic} }->{ $cd->{ord} }) {
		my @arr;
		$c{ $cd->{topic} }->{ $cd->{ord} } = { 
		    'characteristic' => $cd->{characteristic},
		    'format_mask' => $cd->{format_mask},
		    'census_areas' => \@arr
		};
	    }
	    my $ca = { 'division' => $cd->{division},
		       'subdivision' => $cd->{subdivision},
		       'sd_type' => $cd->{type},
		       'total' => $cd->{total},
		       'male' => $cd->{male},
		       'female' => $cd->{female}
	    };
	    push @{ $c{ $cd->{topic} }->{ $cd->{ord} }->{census_areas} }, $ca;
	}
    }

    $dbh->disconnect;
    
    $response->data()->{'api_mess'} = 'Hello, this is Olli REST API' ;
    $response->data()->{'municipality'} = $muni;
    $response->data()->{'contributions'} = $libs_aref;
    $response->data()->{'census_year'} = $census_year;
    $response->data()->{'census'} = $c;
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
