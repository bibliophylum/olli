#!/usr/bin/perl
use Getopt::Long;
use Text::CSV;
use DBI;
use Carp;
use POSIX qw(strftime);
use Data::Dumper;

my $infname;
my $year;
my $verbose;
my $delete;
my $help;
GetOptions ("inf=s" => \$infname, "year=s" => \$year, "verbose"  => \$verbose, "delete" => \$delete, "help" => \$help);

if ($delete) {
    drop_tables();
    create_tables();
    exit;
}

if ($help || (!defined $infname) || (!defined $year)) {
    print "usage: $0 [--inf filename [--verbose]] | [--delete]\n";
    exit;
}

# these need to match the fields in the csv
use constant {
    DIV_ID => 0,   # don't trust this
    DIVISION => 1,
    SD_ID => 2,    # don't trust this
    BLANK_1 => 3,
    SUBDIVISION => 4,
    SD_TYPE => 5,
    BLANK_2 => 6,
    MUNICIPALITY => 7,
    MUNICIPALITY_2 => 8,
};

my $dbh = DBI->connect("dbi:Pg:database=olli;host=localhost;port=5432",
                       "olli",
                       "olli",
                       {AutoCommit => 1, 
                        RaiseError => 1, 
                        PrintError => 0,
                       }
    );

my $csv = Text::CSV->new ( { binary => 1 } )  # should set binary attribute.
    or die "Cannot use CSV: ".Text::CSV->error_diag ();

my $debug = 6;

my $now_string = strftime "%a %b %e %H:%M:%S %Y", localtime;
print "BEGIN: $now_string\n----------------------------\n";

open my $fh, "<:encoding(utf8)", $infname or die "$infname: $!";
while ( my $row = $csv->getline( $fh ) ) {
    #    $row->[2] =~ m/pattern/ or next; # 3rd field should match
    next if ($row->[0] =~ m/^$/);
    next if ($row->[0] =~ m/^#/);
    next if ($row->[MUNICIPALITY] eq '');
#    last if ($debug-- == 0);
    #my @fields = @$row;
    #push @rows, $row;
    #print Dumper($row);
    
    my $d_id = get_division($row->[DIVISION]);
    my $s_id = get_subdivision($d_id,$row->[SUBDIVISION],$row->[SD_TYPE]);
    my $m_id = get_municipality($row->[MUNICIPALITY]);
    add_data($d_id,$s_id,$m_id);
    if ($row->[MUNICIPALITY_2] ne '') {
	$m_id = get_municipality($row->[MUNICIPALITY_2]);
	add_data($d_id,$s_id,$m_id);
    }
}

$csv->eof or $csv->error_diag();
close $fh;
$dbh->disconnect or warn $dbh->errstr;
my $now_string = strftime "%a %b %e %H:%M:%S %Y", localtime;
print "END: $now_string\n----------------------------\n";



#------------------------------------------------------------------------------
sub get_division {
    my $div = shift;
    my $rv;
    my $ary_ref = $dbh->selectrow_arrayref("select id from census_division where value=?", undef, $div);
    if (defined $ary_ref) {
	# exists
	$rv = $ary_ref->[0];
    } else {
	carp "division [$div] not found in census_division table";
    }
    return $rv;
}

#------------------------------------------------------------------------------
sub get_subdivision {
    my ($d_id,$sd,$sdt) = @_;
    my $rv;
    my $ary_ref = $dbh->selectrow_arrayref("select id from census_subdivision_type where value=?", undef, $sdt);
    if (defined $ary_ref) {
	# exists
	my $sdt_id = $ary_ref->[0];
	$ary_ref = $dbh->selectrow_arrayref("select s.id from census_subdivision s left join census_div_sub ds on ds.subdivision_id=s.id where s.value=? and s.sdtype_id=? and ds.division_id=?", undef, $sd, $sdt_id, $d_id);
	if (defined $ary_ref) {
	    # exists
	    $rv = $ary_ref->[0];
	} else {
	    carp "subdivision [$sd/$sdt] with div_id [$d_id] not found in census_subdivision/census_div_sub table";
	}
    } else {
	carp "subdivision type [$sdt] not found in census_subdivision_type table";
    }
    return $rv;
}

#------------------------------------------------------------------------------
sub get_municipality {
    my $mun = shift;
    my $rv;
    my $ary_ref = $dbh->selectrow_arrayref("select id from municipalities where year=? and name=?", undef, $year, $mun);
    if (defined $ary_ref) {
	# exists
	$rv = $ary_ref->[0];
    } else {
	carp "municipality [$mun/" . $year . "] not found in municipalities table";
    }
    return $rv;
}

#------------------------------------------------------------------------------
sub add_data {
    my ($d_id,$s_id,$m_id) = @_;
    carp "no division id" unless (defined $d_id);
    carp "no subdivision id" unless (defined $s_id);
    carp "no municipality id" unless (defined $m_id);
    my $rv;
    if ((defined $d_id) && (defined $s_id) && (defined $m_id)) {
	$rv = $dbh->do("insert into mun_cen (census_division_id,census_subdivision_id,municipality_id) values (?,?,?)", undef, $d_id,$s_id,$m_id);
	if ($rv == 1) {
	    # added
	} else {
	    carp "add_data error, rv [$rv]";
	}
    } else {
	carp "missing data";
    }
    return $rv;
}

#------------------------------------------------------------------------------
sub drop_tables {
    my $dbh = DBI->connect("dbi:Pg:database=olli;host=localhost;port=5432",
			   "olli",
			   "olli",
			   {AutoCommit => 1, 
			    RaiseError => 1, 
			    PrintError => 0,
			   }
	);
    $dbh->do("drop table mun_cen");
    $dbh->disconnect or warn $dbh->errstr;
}

#------------------------------------------------------------------------------
sub create_tables {
    my $dbh = DBI->connect("dbi:Pg:database=olli;host=localhost;port=5432",
			   "olli",
			   "olli",
			   {AutoCommit => 1, 
			    RaiseError => 1, 
			    PrintError => 0,
			   }
	);
    $dbh->do("create table mun_cen (
       municipality_id integer not null,
       census_division_id integer not null,
       census_subdivision_id integer not null,
       primary key(municipality_id,census_division_id,census_subdivision_id)
)");
    $dbh->disconnect or warn $dbh->errstr;

}


