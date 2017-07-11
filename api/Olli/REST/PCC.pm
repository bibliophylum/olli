=begin comment
	Mykel Shumay
	Brandon University
	Public Library Services Branch
	Manitoba Sport, Culture and Heritage

	This script computes the Pearson Correlation Coefficient between pairs of value sets.

	V01 (2017.07.11):
		Currently, the pair is strictly branches.active_memberships and municipalities.population.
		Later versions will easily allow arbitrary pairings, along with the automatic processing of multiple pairings.
=end comment
=cut

package Olli::REST::API::testQuery ;
use warnings ;
use strict;
use base qw/Apache2::REST::Handler/;
use DBI;
#use JSON;
use Data::Dumper;
#print Dumper(\%args);
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

#my $aref = $dbh->selectall_arrayref($SQL);#, { Slice => [] });

my $SQL;
my $sth;

# Obtains array reference to entire table branches
$SQL = "SELECT * FROM branches";
$sth = $dbh->prepare($SQL) or die "Prepare exception: $DBI::errstr!";
$sth->execute() or die "Execute exception: $DBI::errstr";
my $branchesRes = $sth->fetchall_arrayref();
my $branchesNames = $sth->{NAME};

my $branchesRows = @$branchesRes;
my $branchesCols = @{$branchesRes->[0]};
#print "branchesRows = $branchesRows\n";
#print "branchesCols = $branchesCols\n";

# Obtains array reference to entire table municipalities
$SQL = "SELECT * FROM municipalities";
$sth = $dbh->prepare($SQL) or die "Prepare exception: $DBI::errstr!";
$sth->execute() or die "Execute exception: $DBI::errstr";
my $munRes = $sth->fetchall_arrayref();
my $munNames = $sth->{NAME};

my $munRows = @$munRes;
my $munCols = @{$munRes->[0]};
#print "\nmunRows = $munRows\n";
#print "munCols = $munCols\n";

my @branchesVals;
my @branchesPercentMember;
my $floorSum = 0;
my $memberSum = 0;
my $floor;
my $member;
my $pop;

my $percentMemberSum = 0;
my $percentMemberNum = 0;
my $percentMemberAvg;

my @branchesValidTuples;
my $branchesNumValidTuples = 0;

# Filter on the year of branch tuples
my $validYear = 2015;

my $branchesIDIdx = firstidx { $_ eq 'id' } @$branchesNames;
my $branchesYearIdx = firstidx { $_ eq 'year' } @$branchesNames;
my $branchesMunIDIdx = firstidx { $_ eq 'municipality_id' } @$branchesNames;
my $branchesMemIdx = firstidx { $_ eq 'active_memberships' } @$branchesNames;

for (my $n = 0; $n < $branchesRows; $n++){
	#$member = $branchesRes->[$n][9];
	#$pop = $munRes->[$n][3];
	#print "n = $n\n";
	#my $branch = $branchesRes->[$n][0];
	#print "Current branch = $branch\n";

	# Notes which tuples hold valid values and won't skew output due to errors
	if ($branchesRes->[$n][$branchesYearIdx] == $validYear && defined $branchesRes->[$n][$branchesMunIDIdx] && $branchesRes->[$n][$branchesMemIdx] > 0){# && $branchesRes->[$n][branchesIDIdx] != 842){
		$branchesValidTuples[$n] = 1;
		$branchesNumValidTuples++;
	}
	else{
		#print "Undefined.\n";
		$branchesValidTuples[$n] = 0;
	}

}

my $branchesMemberSum = 0;
my $branchesMemberAvg;
my @branchesMemberArr;

my $branchesPopSum = 0;
my $branchesPopAvg;
my @branchesPopArr;
my $members = 0;

# Sums active_memberships and appropriate population values for later averaging
for (my $n = 0; $n < $branchesRows; $n++){
	if($branchesValidTuples[$n]){
		$branchesMemberArr[$n] = $branchesRes->[$n][9];
		$branchesMemberSum += $branchesMemberArr[$n];
		
		$SQL = "SELECT population FROM municipalities where id=$branchesRes->[$n][$branchesMunIDIdx]";
		$sth = $dbh->prepare($SQL) or die "Prepare exception: $DBI::errstr!";
		$sth->execute() or die "Execute exception: $DBI::errstr";
		$branchesPopArr[$n] = $sth->fetchrow_arrayref()->[0];
		$branchesPopSum += $branchesPopArr[$n];

		#print "branch: $branchesRes->[$n][0],\tpop: $branchesPopArr[$n],\tmembers: $branchesMemberArr[$n]\n";
	}
}

$branchesMemberAvg = $branchesMemberSum/$branchesNumValidTuples;
$branchesPopAvg = $branchesPopSum/$branchesNumValidTuples;
print "\nNumber valid tuples: $branchesNumValidTuples\n";
print "branchesMemberAvg = $branchesMemberAvg\n";
print "branchesPopAvg = $branchesPopAvg\n\n";

# Computation of Standard Deviations of both active_memberships and appropriate populations
my $branchesMemberSD = 0;
my $branchesPopSD = 0;

for (my $n = 0; $n < $branchesRows; $n++){
	if($branchesValidTuples[$n]){
		$branchesMemberSD += ($branchesMemberArr[$n]-$branchesMemberAvg)**2;
		$branchesPopSD += ($branchesPopArr[$n]-$branchesPopAvg)**2;
	}
}

$branchesMemberSD /= $branchesNumValidTuples;
$branchesMemberSD = sqrt($branchesMemberSD);

$branchesPopSD /= $branchesNumValidTuples;
$branchesPopSD = sqrt($branchesPopSD);

print "branchesMemberSD = $branchesMemberSD\n";
print "branchesPopSD = $branchesPopSD\n";

# Computation of Pearson's Correlation Coefficient
my $PCC;
my $PCCsum = 0;
for (my $n = 0; $n < $branchesRows; $n++){
	if($branchesValidTuples[$n]){
		$PCC = (($branchesPopArr[$n]-$branchesPopAvg)*($branchesMemberArr[$n]-$branchesMemberAvg))/($branchesMemberSD*$branchesPopSD);
		$PCCsum += $PCC;
		#print "PCC = $PCC\n";
		#<STDIN>
	}
}
my $PCCavg = $PCCsum/$branchesNumValidTuples;
print "\nPCCavg = $PCCavg\n";

print "\nEnd of script\n";