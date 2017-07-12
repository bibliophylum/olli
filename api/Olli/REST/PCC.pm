=begin comment
	Mykel Shumay
	Brandon University
	Public Library Services Branch
	Manitoba Sport, Culture and Heritage

	This script computes the Pearson Correlation Coefficient between pairs of value sets.

	V01 (2017.07.11):
		- Currently, the pair is strictly branches.active_memberships and municipalities.population.
		- Later versions will easily allow arbitrary pairings, along with the automatic processing of multiple pairings.
	
	V02 (2017.07.11):
		- Altered to be much more robust.
		- Mostly allows arbitrary choice of pairings through the specification of the tables and the two fields.
		- Foreign keys for joins still need to be elegantly dealt with to allow fully automated PCC calculations.

	V03 (2017.07.12):
		- Obtains relevant foreign key relationships for both $xt and $yt tables, if they are not the same tables.
		- Joins based on the determined shared key, presupposes no knowledge of either table or field, fully general.
		- Correctly handles currency conversion for arithmetic operations.
		- This all allows one to simply specify the two tables and two fields of the pair, even pairings within the same table, and the script handles all of the smaller details.
		- Later versions will hopefully automatically disregard unusable entries, regardless of chosen tables; much of this should be dealt with within the database beforehand, but this script should become robust enough to handle these issues on its own.

=end comment
=cut

package Olli::REST::PCC;
use warnings ;
use strict;
use base qw/Apache2::REST::Handler/;
use DBI;
use List::MoreUtils qw(firstidx);


my $database = "olli";
my $dsn = "dbi:Pg:database=$database;host=localhost;port=5432";
my $userid = "olli";
my $password = "olli";

my $dbh = DBI->connect($dsn,
			   $userid,
			   $password,
			   {AutoCommit => 1, 
			    RaiseError => 1, 
			    PrintError => 0,
			   }
	) or die $DBI::errstr;

my $SQL;
my $sth;

my $xt = 'branches';
my $xfield = 'active_memberships';
my $xfieldVal;
my $xfieldSum = 0;
my $xfieldAvg = 0;
my $xfieldSD = 0;
my @xfieldArr;

my $yt = 'branches';
my $yfield = 'annual_rent';
my $yfieldVal;
my $yfieldSum = 0;
my $yfieldAvg = 0;
my $yfieldSD = 0;
my @yfieldArr;

my $xt_yt_same = ($xt eq $yt);

# if($xt_yt_same){
# 	print "Same tables\n";
# }
# else{
# 	print "Not same tables\n";
# }

# Filter on the year of $xt's tuples
my $validYear = 2015;

# Foreign key sample from municipalities:
#table_schema |        constraint_name        | table_name |   column_name   | foreign_table_name | foreign_column_name
#public       | branches_municipality_id_fkey | branches   | municipality_id | municipalities     | id

my $foreignArr;
my $foreignArrNames;

if(!$xt_yt_same){
	$SQL = "SELECT DISTINCT tc.table_schema, tc.constraint_name, tc.table_name, kcu.column_name, ccu.table_name
	AS foreign_table_name, ccu.column_name AS foreign_column_name
	FROM information_schema.table_constraints tc
	JOIN information_schema.key_column_usage kcu ON tc.constraint_name = kcu.constraint_name
	JOIN information_schema.constraint_column_usage ccu ON ccu.constraint_name = tc.constraint_name
	WHERE constraint_type = 'FOREIGN KEY'
	AND (ccu.table_name='$xt' OR ccu.table_name='$yt')
	AND (tc.table_name='$xt' OR tc.table_name='$yt')";
	
	$sth = $dbh->prepare($SQL) or die "Prepare exception: $DBI::errstr!";
	$sth->execute() or die "Execute exception: $DBI::errstr";

	$foreignArr = $sth->fetchall_arrayref();
	$foreignArrNames = $sth->{NAME};

	# for(my $n = 0; $n < @$foreignArrNames; $n++){
	# 	print $foreignArrNames->[$n] . "\n";
	# }
	# print "\n";

	# for(my $n = 0; $n < @{$foreignArr->[0]}; $n++){
	# 	print $foreignArr->[0][$n] . "\n";
	# }
	# print "\n";

	# for(my $n = 0; $n < @$foreignArr; $n++){
	# 	print $foreignArr->[$n][1] . "\n";
	# }
	# print "\n";
}

my $foreign_xtTableIdx = firstidx { $_ eq 'table_name' } @$foreignArrNames;
my $foreign_xtColIdx = firstidx { $_ eq 'column_name' } @$foreignArrNames;
my $foreign_ytTableIdx = firstidx { $_ eq 'foreign_table_name' } @$foreignArrNames;
my $foreign_ytColIdx = firstidx { $_ eq 'foreign_column_name' } @$foreignArrNames;

# Obtains array reference to $xt fields
if($xt_yt_same){
	$SQL = "SELECT CAST($xfield as decimal(10,2)) as x_$xfield, $xt.year as x_year, $xt.id as x_id, CAST($yfield as decimal(10,2)) FROM $xt";
}
# Obtains array reference to join of $xt and $yt
else{
	$SQL = "SELECT CAST($xfield as decimal(10,2)) as x_$xfield, $xt.year as x_year, $xt.id as x_id, CAST($yfield as decimal(10,2)), $yt.* FROM $xt INNER JOIN $yt on $xt.$foreignArr->[0][$foreign_xtColIdx] = $yt.$foreignArr->[0][$foreign_ytColIdx]";
}

$sth = $dbh->prepare($SQL) or die "Prepare exception: $DBI::errstr!";
$sth->execute() or die "Execute exception: $DBI::errstr";
my $res = $sth->fetchall_arrayref();
my $resNames = $sth->{NAME};

# for(my $n = 0; $n < @$resNames; $n++){
# 	print $resNames->[$n] . "\n";
# }

my $resRows = @$res;
my $resCols = @{$res->[0]};
# print "\nresRows = $resRows\n";
# print "resCols = $resCols\n";

my @resValidTuples;
my $resNumValidTuples = 0;

my $res_xtIDIdx = firstidx { $_ eq 'x_id' } @$resNames;
my $res_xfieldIdx = firstidx { $_ eq 'x_' . $xfield } @$resNames;
my $res_xtYearIdx = firstidx { $_ eq 'x_year' } @$resNames;
my $res_ytIDIdx = firstidx { $_ eq 'id' } @$resNames;
my $res_yfieldIdx = firstidx { $_ eq $yfield} @$resNames;

for (my $n = 0; $n < $resRows; $n++){
	# Notes which tuples hold valid values
	if ($res->[$n][$res_xtYearIdx] == $validYear && defined $res->[$n][$res_ytIDIdx]){# && $res->[$n][$res_xfieldIdx] > 0 && $res->[$n][$res_yfieldIdx] > 0){
		$resValidTuples[$n] = 1;
		$resNumValidTuples++;
		#print "Defined\n";
	}
	else{
		#print "Undefined.\n";
		$resValidTuples[$n] = 0;
	}
}

# Sums $xfield and appropriate $yfield values for later averaging
for (my $n = 0; $n < $resRows; $n++){
	if($resValidTuples[$n]){
		$xfieldArr[$n] = $res->[$n][$res_xfieldIdx];
		$xfieldSum += $xfieldArr[$n];
		
		$yfieldArr[$n] = $res->[$n][$res_yfieldIdx];
		$yfieldSum += $yfieldArr[$n];

		#print "x_id: $res->[$n][$res_xtIDIdx],\t$xfield: $xfieldArr[$n],\t$yfield: $yfieldArr[$n]\n";
	}
}

$xfieldAvg = $xfieldSum/$resNumValidTuples;
$yfieldAvg = $yfieldSum/$resNumValidTuples;
print "\nNumber valid tuples: $resNumValidTuples\n";
print $xfield . "Avg = $xfieldAvg\n";
print $yfield . "Avg = $yfieldAvg\n\n";

# Computation of Standard Deviations of both $xfield and appropriate $yfield
for (my $n = 0; $n < $resRows; $n++){
	if($resValidTuples[$n]){
		$xfieldSD += ($xfieldArr[$n]-$xfieldAvg)**2;
		$yfieldSD += ($yfieldArr[$n]-$yfieldAvg)**2;
	}
}

$xfieldSD /= $resNumValidTuples;
$xfieldSD = sqrt($xfieldSD);

$yfieldSD /= $resNumValidTuples;
$yfieldSD = sqrt($yfieldSD);

print "xfieldSD = $xfieldSD\n";
print "yfieldSD = $yfieldSD\n";

# Computation of Pearson's Correlation Coefficient
my $PCC;
my $PCCsum = 0;
for (my $n = 0; $n < $resRows; $n++){
	if($resValidTuples[$n]){
		$PCC = (($xfieldArr[$n]-$xfieldAvg)*($yfieldArr[$n]-$yfieldAvg))/($xfieldSD*$yfieldSD);
		$PCCsum += $PCC;
		#print "PCC = $PCC\n";
		#<STDIN>
	}
}
my $PCCavg = $PCCsum/$resNumValidTuples;
print "\nPCCavg = $PCCavg\n";

print "\nEnd of script\n";