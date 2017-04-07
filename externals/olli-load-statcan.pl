#!/usr/bin/perl

use Getopt::Long;
use Text::CSV;
use DBI;
use POSIX qw(strftime);
use Data::Dumper;

my $infname;
my $verbose;
my $delete;
my $help;
GetOptions ("inf=s" => \$infname, "verbose"  => \$verbose, "delete" => \$delete, "help" => \$help);

if ($delete) {
    drop_tables();
    create_tables();
    exit;
}

if ($help || (!defined $infname)) {
    print "usage: $0 [--inf filename [--verbose]] | [--delete]\n";
    print "\tYEAR is 2011, defined as a constant in $0\n";
    exit;
}

# these need to match the fields in the csv
use constant {
    GEO_CODE => 0,
    PROV_NAME => 1,
    DIVISION => 2,
    SUBDIVISION => 3,
    SUBDIVISION_TYPE => 4,
    TOPIC => 5,
    CHARACTERISTICS => 6,
    NOTE => 7,
    TOTAL => 8,
    FLAG_TOTAL => 9,
    MALE => 10,
    FLAG_MALE => 11,
    FEMALE => 12,
    FLAG_FEMALE => 13
};
use constant YEAR => '2011';

my $dbh = DBI->connect("dbi:Pg:database=olli;host=localhost;port=5432",
                       "olli",
                       "olli",
                       {AutoCommit => 1, 
                        RaiseError => 1, 
                        PrintError => 0,
                       }
    );

my $censusYearId;
my $ary_ref = $dbh->selectrow_arrayref("select id from census_year where value=?", undef, YEAR);
if (defined $ary_ref) {
    print STDERR "Year " . YEAR . " already exists.  Aborting!\n";
    exit;
} else {
    $dbh->do("insert into census_year (value) values (?)", undef, YEAR);
    $ary_ref = $dbh->selectrow_arrayref("select id from census_year where value=?", undef, YEAR);
    $censusYearId = $ary_ref->[0];
}

#my @rows;
my $csv = Text::CSV->new ( { binary => 1 } )  # should set binary attribute.
    or die "Cannot use CSV: ".Text::CSV->error_diag ();

my $debug = 6;

my %subsInDivision;

my $characteristicOrderNumber = 1;  # maintain source data ordering of characteristics
my $currentTopicId;

my $now_string = strftime "%a %b %e %H:%M:%S %Y", localtime;
print "BEGIN: $now_string\n----------------------------\n";

open my $fh, "<:encoding(utf8)", $infname or die "$infname: $!";
while ( my $row = $csv->getline( $fh ) ) {
    #    $row->[2] =~ m/pattern/ or next; # 3rd field should match
    next if ($row->[0] =~ m/^$/);
    next if ($row->[0] =~ m/^Census Profile/);
    next if ($row->[0] =~ m/^Geo_Code/);
    #my @fields = @$row;
    #push @rows, $row;
    my $d_id = add_division($row->[DIVISION]);
    my $s_id = add_subdivision($d_id,$row->[SUBDIVISION],$row->[SUBDIVISION_TYPE]);
    my $t_id = add_topic($row->[TOPIC]);
    if ($t_id != $currentTopicId) {
	$currentTopicId = $t_id;
	$characteristicOrderNumber = 1;
    }
    my $c_id = add_characteristic($row->[CHARACTERISTICS],$row->[TOTAL]);
    add_data($censusYearId,$d_id,$s_id,$t_id,$c_id,$characteristicOrderNumber++,$row);
}
print "\ncreating div/sub relationships...\n" if ($verbose);
#print Dumper(\%subsInDivision);
foreach my $div (keys %subsInDivision) {
    print "\nDiv [$div]\t" if ($verbose);
    foreach my $sd (@{ $subsInDivision{$div} }) {
	print "$sd " if ($verbose);
	my $rv = $dbh->do("insert into census_div_sub (division_id,subdivision_id) values (?,?)", undef, $div,$sd);
	# print "$div/$sd: $rv\n" if ($verbose);
    }
}

$csv->eof or $csv->error_diag();
close $fh;
$dbh->disconnect or warn $dbh->errstr;
my $now_string = strftime "%a %b %e %H:%M:%S %Y", localtime;
print "END: $now_string\n----------------------------\n";



#-----------------------------------------------------------------------------------
sub add_division {
    my $div = shift;
    my $ary_ref = $dbh->selectrow_arrayref("select id from census_division where value=?", undef, $div);
    if (defined $ary_ref) {
	# already exists
    } else {
	$dbh->do("insert into census_division (value) values (?)", undef, $div);
	$ary_ref = $dbh->selectrow_arrayref("select id from census_division where value=?", undef, $div);
	print "$div\n" if ($verbose);
	$subsInDivision{$ary_ref->[0]} = (); # array of subdivisions in this division
    }
    return $ary_ref->[0];
}

#-----------------------------------------------------------------------------------
sub add_subdivision_type {
    my $sdt = shift;
    my $ary_ref = $dbh->selectrow_arrayref("select id from census_subdivision_type where value=?", undef, $sdt);
    if (defined $ary_ref) {
	# already exists
    } else {
	$dbh->do("insert into census_subdivision_type (value) values (?)", undef, $sdt);
	$ary_ref = $dbh->selectrow_arrayref("select id from census_subdivision_type where value=?", undef, $sdt);
    }
    return $ary_ref->[0];
}

#-----------------------------------------------------------------------------------
sub add_subdivision {
    my ($d,$sd,$sdt) = @_;
    my $sdt_id = add_subdivision_type($sdt);
    my $ary_ref = $dbh->selectrow_arrayref("select id from census_subdivision where value=? and sdtype_id=?", undef, $sd,$sdt_id);
    if (defined $ary_ref) {
	# already exists
    } else {
	$dbh->do("insert into census_subdivision (value,sdtype_id) values (?,?)", undef, $sd,$sdt_id);
	$ary_ref = $dbh->selectrow_arrayref("select id from census_subdivision where value=? and sdtype_id=?", undef, $sd,$sdt_id);
	print "\t$sd ($sdt)\n" if ($verbose);
	push @{$subsInDivision{$d}},$ary_ref->[0];
    }
    return $ary_ref->[0];
}

#-----------------------------------------------------------------------------------
sub add_topic {
    my $topic = shift;
    my $ary_ref = $dbh->selectrow_arrayref("select id from census_topic where value=?", undef, $topic);
    if (defined $ary_ref) {
	# already exists
    } else {
	$dbh->do("insert into census_topic (value) values (?)", undef, $topic);
	$ary_ref = $dbh->selectrow_arrayref("select id from census_topic where value=?", undef, $topic);
    }
    return $ary_ref->[0];
}

#-----------------------------------------------------------------------------------
sub add_characteristic {
    my ($characteristic,$sample_data) = @_;
    my $ary_ref = $dbh->selectrow_arrayref("select id from census_characteristics where value=?", undef, $characteristic);
    if (defined $ary_ref) {
	# already exists
    } else {
	my $format_mask = "999999";
	if ($sample_data =~ m/\./) {
	    my ($w,$d) = split(/\./,$sample_data);
	    $format_mask = join("D",$format_mask,('9' x (length $d)));
	}
	$dbh->do("insert into census_characteristics (value,format_mask) values (?,?)", undef, $characteristic, $format_mask);
	$ary_ref = $dbh->selectrow_arrayref("select id from census_characteristics where value=?", undef, $characteristic);
    }
    return $ary_ref->[0];
}

#-----------------------------------------------------------------------------------
sub add_data {
    my ($y_id,$d_id,$s_id,$t_id,$c_id,$c_ord,$data) = @_;
    my $rv = $dbh->do("insert into census (year_id,division_id,subdivision_id,topic_id,characteristics_id,ord,total,male,female) values (?,?,?,?,?,?,?,?,?)", 
		      undef, 
		      $y_id,
		      $d_id,
		      $s_id,
		      $t_id,
		      $c_id,
		      $c_ord,
		      $data->[TOTAL],
		      $data->[MALE],
		      $data->[FEMALE]
	);
    $ary_ref = $dbh->selectrow_arrayref("select id from census where year_id=? and division_id=? and subdivision_id=? and topic_id=? and characteristics_id=? and ord=?", undef, $y_id,$d_id,$s_id,$t_id,$c_id,$c_ord);
    return $ary_ref->[0];
}

#-----------------------------------------------------------------------------------
sub delete_year {
    my $year = shift;
    my $dbh = DBI->connect("dbi:Pg:database=olli;host=localhost;port=5432",
			   "olli",
			   "olli",
			   {AutoCommit => 1, 
			    RaiseError => 1, 
			    PrintError => 0,
			   }
	);
    $dbh->do("delete from census where year_id=(select id from census_year where value=?))", undef, $year);
    $dbh->do("delete from census_year where value=?)", undef, $year);
}


#-----------------------------------------------------------------------------------
sub drop_tables {
    my $dbh = DBI->connect("dbi:Pg:database=olli;host=localhost;port=5432",
			   "olli",
			   "olli",
			   {AutoCommit => 1, 
			    RaiseError => 1, 
			    PrintError => 0,
			   }
	);
    $dbh->do("drop table census");
    $dbh->do("drop table census_characteristics");
    $dbh->do("drop table census_topic");
    $dbh->do("drop table census_div_sub");
    $dbh->do("drop table census_subdivision");
    $dbh->do("drop table census_subdivision_type");
    $dbh->do("drop table census_division");
    $dbh->do("drop table census_year");
    $dbh->do("drop table mun_cen");
    
    $dbh->do("drop sequence census_id_seq");
    $dbh->do("drop sequence census_characteristics_id_seq");
    $dbh->do("drop sequence census_topic_id_seq");
    $dbh->do("drop sequence census_subdivision_id_seq");
    $dbh->do("drop sequence census_subdivision_type_id_seq");
    $dbh->do("drop sequence census_division_id_seq");
    $dbh->do("drop sequence census_year_id_seq");

}

#-----------------------------------------------------------------------------------
sub create_tables {
    print "For now, you will need to copy and run:\n";
    print "psql -U rld -h localhost -d rld -f ../updates/16-statcan.sql\n";
}


sub save_this_code_for_later {
    my $s = "
 select
  s.value as subdivision,
  st.value as type,
  t.value as topic,
  c.ord as ord,
  ch.value as characteristic,
  c.total as total,
  c.male as male,
  c.female as female
 from
  census c
  left join census_subdivision s on s.id=c.subdivision_id
  left join census_subdivision_type st on s.sdtype_id=st.id
  left join census_topic t on c.topic_id=t.id
  left join census_characteristics ch on c.characteristics_id=ch.id
 where
  s.value='Gimli'
  and st.value='Rural municipality'
 order by
  s.value,
  st.value,
  t.value,
  c.ord,
  ch.value;
";

    my $s2 = "
 select
  
";
    
}
