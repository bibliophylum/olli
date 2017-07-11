=begin comment
	Mykel Shumay
	Brandon University
	Public Library Services Branch
	Manitoba Sport, Culture and Heritage

	This script computes the Pearson Correlation Coefficient between pairs of value sets.

	V01 (2017.07.11):
		Currently, the pair is strictly branches.active_memberships and municipalities.population.
		Later versions will easily allow arbitrary pairings, along with the automatic processing of multiple pairings.
	
	V02 (2017.07.11):
		Altered to be much more robust.
		Mostly allows arbitrary choice of pairings through the specification of the tables and the two fields.
		Foreign keys for joins still need to be elegantly dealt with to allow fully automated PCC calculations.
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

my $yt = 'municipalities';
my $yfield = 'population';
my $yfieldVal;
my $yfieldSum = 0;
my $yfieldAvg = 0;
my $yfieldSD = 0;
my @yfieldArr;

# Filter on the year of branch tuples
my $validYear = 2015;

# Obtains array reference to join of $xt and $yt
$SQL = "SELECT $xfield as x_$xfield, $xt.year as x_year, $xt.id as x_id, $yt.* FROM $xt INNER JOIN $yt on $xt.municipality_id = $yt.id";
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

# print $res_xtIDIdx . "\n";
# print $res_xfieldIdx . "\n";
# print $res_xtYearIdx . "\n";
# print $res_ytIDIdx . "\n";
# print $res_yfieldIdx . "\n";

for (my $n = 0; $n < $resRows; $n++){
	#$member = $branchesRes->[$n][9];
	#$pop = $munRes->[$n][3];
	#print "n = $n\n";
	#my $branch = $branchesRes->[$n][0];
	#print "Current branch = $branch\n";

	# Notes which tuples hold valid values and won't skew output due to errors
	if ($res->[$n][$res_xtYearIdx] == $validYear && defined $res->[$n][$res_ytIDIdx] && $res->[$n][$res_xfieldIdx] > 0 && $res->[$n][$res_yfieldIdx] > 0){# && $branchesRes->[$n][branchesIDIdx] != 842){
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
print $xfield . " = $xfieldAvg\n";
print $yfield . "branchesPopAvg = $yfieldAvg\n\n";

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