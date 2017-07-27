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

	V04 (2017.07.12):
		- 'determinePairPCC' subroutine calculates PCC of a given pairing, and returns the output within the given array.
		- A list of pairings may be processed by 'determinePairPCC'.

	V05 (2017.07.13):
		- Main body now in subroutine 'GET'.
		- Added 'isAuth' authorization subroutine for GET.
		- subroutine 'allPairs' pairs all columns across all tables, and sends each to 'determinePairPCC'.
			- Disregards general columns such as 'id' and 'year'.
			- Does not pair a column up with itself.
			- Disregards some tables that do not contain useful data.
			- At the moment, only produces valid output when a direct foreign key relationship is found between the two tables.
			- Filtering on year has been disabled, must be handled correctly (not all tables have a year field).
			- Not all fields of all tables are seen, later versions will process all.
			- Must handle some special cases with greater elegance.
			- Only pairs columns that are of type (integer, money, or numeric).

	V06 (2017.07.13):
		- Correctly finds and filters by year, if available.
			- If both tables have years, filter both tables by year.
			- If either table has year, filter by that.
			- If neither has year, don't attempt to filter by year.

	V07 (2017.07.14):
		- 'determinePCC' sub name changed to 'pairAnalysis'.
			- Now calls 'computeAvgSD' sub to calculate $xfield and $yfield averages and Standard Deviation.
			- Now calls 'computePCC' sub to calculate PCC, using results from 'computeAvgSD' sub.
		- Set up for easy "Plug 'n Play'" of algorithms in other subroutines.
		- Added ability to not filter by year by leaving $validYears = ''.
		- Less unnecessary memory allocation (variable/array duplication in subs), making better use of referencing.

	V08 (2017.07.17):
		- Added 'computeSpearmanRCC' sub, computes Spearman Rank Correlation Coefficient.
			- This puts a lesser weight on the tail-ends of each value set, as each value is now only seen as its rank amongst all other values in the set.
			- Winnipeg's values don't affect this value nearly as much as they do with PCC.
			- When Winnipeg's values are similar to all others, RCC should be similar to PCC.
			- Ranking is handled in a simple manner, in which all values have a distinct rank, even if many/all values are equal.
				- This may be changed to a different ranking system in the future.
	
	V09 (2017.07.20):
		- 'computeAvgSD' sub replaced by 'computePairAvgSD', which now simply calls 'computeSingleAvgSD' sub twice (once for each value set).
		- Added 'censusMun' sub, joins valid census entries with appropriate municipality entries.
			- All valid census value sets' averages and Standard Deviations are calculated.
				- Each of (Total, Male, Female) of each census_characteristics.id are computed separately and have their own values.
			- Future plans are to relate these results to the appropriate municipality values.
		- 'censusTest' was an attempt to pair census values with other tables and compute values using the same subroutines as for other pairs, but was not fruitful without much greater effort due to the n->1 nature of the relationship between the census table and other tables. This could possibly be modified in the future to still gain some insight into the mathematical relationships using existing subroutines.

	V10 (2017.07.24):
		- 'censusMun' sub calculates avg and SD of the set of valid municipalities' populations, and joins each municipality with the appropriate census values.
			- Later versions will hopefully properly implement some statistical analysis, but how that will be accomplished is yet to be determined.
		- 'munCensusSorting' sub is simply a portion of 'censusMun' sub's code, joining each municipality with the appropriate census values.
		- 'linkLibsMuns' sub takes output of 'munCensusSorting' sub and links each library_id to the appropriate municipality/census rows.
			- We currently do not have valid database entries to test or make use of this subroutine.

	V11 (2017.07.24):
		- 'calculateAvgMunPops' sub calculates the average population from valid municipalities given in the array from 'munCensusSorting' sub.
		- 'censusCalcAvgChars' sub calculates the average of each census characteristic's (Total, Male, Female) values given in the array from 'munCensusSorting' sub.
		- 'normalizeCensusValues' sub takes array given by 'munCensusSorting' sub, calls calculateAvgMunPops and censusCalcAvgChars, creates new array holding normalized census characteristic values for each municipality.
			- For municipality m,
				census characteristic c,
				inner characteristic indicator inner,
				averaged characteristic indicator innerCharAvg,
				and average population avgPop:

					m's c's normalized inner =
						(m's pop/avgPop)/(m's c's inner/innerCharAvg)

	V12 (2017.07.25):
		- 'listSpecificNormalizedValues' sub allows the user to specify a valid municipality and census characteristic, then prints the appropriate values from the normalized data.
		- The next version will feature a better implementation of normalization.

	V13 (2017.07.26):
		- 'normalizeCensusValues2' sub normalizes the municipality/census values in a better manner.
			- For each census characteristic subvalue E_c_i, each municipality m's census characteristic subvalue e_m_i is given the value of 
				e_m_i = ((e_m_i - E_c_i_min) / (E_c_i_max - E_c_i_min))
					* (m's pop);
				
			- Each e_m_i is then normalized again by the max of all e_x_i's to be put in a range from 0 -> 1. (Deprecated)
			- This gives normalized values that are per capita for each municipality, and allows us to compare between municipalities.
		- Currently using population values from municipalities table, conflicts with census populations.

	V14 (2017.07.26):
		- Fixed an issue of normalization giving really odd values due to trusting the municipalities table's population values, instead of what was given in the census table.
			- eg, mun_id 491 (Flin Flon Ext. Boundaries) has a population of 267, but the census population for that mun_id has a population value similar to mun_id 490 (City of Flin Flon), which is about 20x that of mun_id 491's.
			- Now that the census table's population values are being used, there is sometimes a slight discrepancy (up to 6%) as the census values seem to conflict slightly with themselves, but the normalized values now make sense.
			- The second normalization step in 'normalizeCensusValues2' sub is no longer needed; this was in place to try to make more sense of the incorrect output.

	V15 (2017.07.27):
		- 'findMinMaxNCharVals' sub asks the user to choose a valid municipality, and then how many of the minimum/maximum normalized census characteristic values for the chosen municipality to list in asc/desc order.
	
	
=end comment
=cut

package Olli::REST::PCC;
use warnings;
use strict;
use base qw/Apache2::REST::Handler/;
use DBI;
use List::MoreUtils qw(firstidx);
# use Heap::Binary;
# use Array::Heap;
# use Heap::Elem::Num;
use Heap::Simple;
use Scalar::Util qw(looks_like_number);


my $SQL;
my $sth;
my $dbh;
my @output;
my @validOutput;
my $numValidOutput;

# Filter on the year of $xt's tuples (filtering is by substring, you may include any year however you want.)
# Example: $validYears = '2013_,asdf20142015' would give valid records from 2013 through 2015.
my $validYears = '2015';

# GET();
# allPairs();
# censusTest();
# censusMun();
# munCensusSorting();
# linkLibsMuns();
# calculateAvgMunPops();
# test2();
# normalizeCensusValues();
# listSpecificNormalizedValues();
# normalizeCensusValues2();
findMinMaxNCharVals();

sub dbPrepare{
	my $database = "olli";
	my $dsn = "dbi:Pg:database=$database;host=localhost;port=5432";
	my $userid = "olli";
	my $password = "olli";

	$dbh = DBI->connect($dsn,
				$userid,
				$password,
				{AutoCommit => 1, 
					RaiseError => 1, 
					PrintError => 0,
				}
		) or die $DBI::errstr;
}

# Implement the GET HTTP method.
sub GET {
	my ($self, $request, $response) = @_ ;
	dbPrepare();


	my @pairList = (
		[
			'branches',
			'active_memberships',
			'municipalities',
			'population'
		],
		[
			'branches',
			'active_memberships',
			'branches',
			'floor_space'
		],
		[
			'branches',
			'active_memberships',
			'branches',
			'active_memberships'
		]
		);

	for(my $iter = 0; $iter < @pairList; $iter++){
		pairAnalysis(\@pairList, $iter, \@output);

		for(my $i = 0; $i < @{$output[$iter]}; $i++){
			# print "output[$i] = " . $output[$iter][$i][1] . "\n";
			printf "%s: %.3f\n", $output[$iter][$i][0], $output[$iter][$i][1];
		}
	}
	
	$dbh->disconnect;
	print "\nEnd of script\n";
	return Apache2::Const::HTTP_OK ;
}

sub allPairs{
	dbPrepare();

	my @pairList;

	$SQL = "select table_name from information_schema.tables where table_schema = 'public' and table_catalog = 'olli'"
		#. " and table_name not like '%' || 'census' || '%'"
		. " and table_name not like 'contact'"
		. " and table_name not like 'mun_geo'"
		. " and table_name not like 'mun_cen'"
		#. " and table_name not like 'financial'"
		. " and table_name not like 'technology'"
		#. " and table_name not like 'social_media'"
		#. " and table_name not like 'activities'"
		;
	$sth = $dbh->prepare($SQL) or die "Prepare exception: $DBI::errstr!";
	$sth->execute() or die "Execute exception: $DBI::errstr";
	my $dbTables = $sth->fetchall_arrayref();
	# my $dbTablesNames = $sth->{NAME};
	
	my @dbStructure;

	for(my $n = 0; $n < @$dbTables; $n++){
		# print @$dbTablesNames[$n] . "\n";
		$dbStructure[$n][0] = $dbTables->[$n][0];
		# print @$dbTables[$n] . "\n";
		# print "TABLE: $dbStructure[$n][0]\n";

		# $SQL = "select column_name from information_schema.columns where table_name = '$dbStructure[$n][0]'
		# 	and column_name not like '%' || '_id' || '%'
		# 	and column_name not like 'year'
		# 	and column_name not like 'name'
		# 	and column_name not like 'ils'
		# 	and column_name not like '%' || 'is_' || '%'";
		
		$SQL = "select attname
			from pg_attribute
			where attrelid = 'public.$dbStructure[$n][0]'::regclass
			and attnum > 0
			and not attisdropped
			and attname not like 'id'
			and attname not like '%' || '_id' || '%'
			and attname not like 'year'
			and attname not like 'name'
			and attname not like 'ils'
			and attname not like '%' || 'is_' || '%'
			and attname not like '%' || 'has_' || '%'";

		$sth = $dbh->prepare($SQL) or die "Prepare exception: $DBI::errstr!";
		$sth->execute() or die "Execute exception: $DBI::errstr";
		my $data = $sth->fetchall_arrayref();

		$SQL = "select column_name, data_type from information_schema.columns
			where table_name = '$dbStructure[$n][0]'
			and column_name not like 'id'
			and column_name not like '%' || '_id' || '%'
			and column_name not like 'year'
			and column_name not like 'name'
			and column_name not like 'ils'
			and column_name not like '%' || 'is_' || '%'
			and column_name not like '%' || 'has_' || '%'";
		$sth = $dbh->prepare($SQL) or die "Prepare exception: $DBI::errstr!";
		$sth->execute() or die "Execute exception: $DBI::errstr";
		my $dataTypes = $sth->fetchall_arrayref();

		my $dbStructure_mIndex = 0;
		for(my $m = 0; $m < $#{ $data }; $m++){
			if($dataTypes->[$m][1] eq 'integer' || $dataTypes->[$m][1] eq 'money' || $dataTypes->[$m][1] eq 'numeric'){
				# print "\tIS, $data->[$m][0]\n";
				# print "data->[$m][0] = " . $data->[$m][0] . "\n";
				$dbStructure[$n][1][$dbStructure_mIndex] = $data->[$m][0];
				# print $data->[$m][0] . "\n";
				# print "\t" . $dbStructure[$n][1][$dbStructure_mIndex] . "\n";
				$dbStructure_mIndex++;
			}
			else{
				# print "\tNOT, $data->[$m][0]\n";
			}
		}
	}

	# Pair up all useful columns
	my $numTables = @dbStructure;
	# print "\nnumTables: $numTables\n";
	
	my $pairIdx = 0;
	my $numPairs = 0;
	for(my $n = 0; $n < $numTables; $n++){
		# print "n = $n\n";
		for(my $m = 0; defined $dbStructure[$n][1] && $m < @{$dbStructure[$n][1]}; $m++){
			# print "\tm = $m\n";

			# Pairs each column with each other column within the same table, no duplication
			for(my $m2 = $m + 1; $m2 < @{$dbStructure[$n][1]}; $m2++){
				$pairList[$pairIdx++] = 
					[
						$dbStructure[$n][0],
						$dbStructure[$n][1][$m],
						$dbStructure[$n][0],
						$dbStructure[$n][1][$m2]
					];
				$numPairs++;
				# print "\t\tpairIdx = $pairIdx\n";
				# print "\t\t$dbStructure[$n][0]\n";
				# print "\t\t$dbStructure[$n][1][$m]\n";
				# print "\t\t$dbStructure[$n][0]\n";
				# print "\t\t$dbStructure[$n][1][$m2]\n";
			}

			# Pairs each column with each column not in the same table, no duplication
			for(my $n2 = $n + 1; $n2 < $numTables; $n2++){
				# print "  n2 = $n2\n";

				for(my $m2 = $m + 1; defined $dbStructure[$n2][1] &&  $m2 < @{$dbStructure[$n2][1]}; $m2++){
					$pairList[$pairIdx++] = 
						[
							$dbStructure[$n][0],
							$dbStructure[$n][1][$m],
							$dbStructure[$n2][0],
							$dbStructure[$n2][1][$m2]
						];
					$numPairs++;
					# print "\t\tpairIdx = $pairIdx\n";
					# print "\t\t$dbStructure[$n][0]\n";
					# print "\t\t$dbStructure[$n][1][$m]\n";
					# print "\t\t$dbStructure[$n2][0]\n";
					# print "\t\t$dbStructure[$n2][1][$m2]\n";
				}
			}
		}
	}

	$numValidOutput = 0;
	for(my $iter = 0; $iter < @pairList; $iter++){
		pairAnalysis(\@pairList, $numPairs, $iter, \@output);

		if($output[$iter][0][1] != -2){
			$validOutput[$numValidOutput][@{$output[$iter]}+1][0] = $iter;
			for(my $i = 0; $i < @{$output[$iter]}; $i++){
				# print "output[$i] = " . $output[$iter][$i][1] . "\n";
				# printf "%s: %.3f\n", $output[$iter][$i][0], $output[$iter][$i][1];
				$validOutput[$numValidOutput][$i][0] = $output[$iter][$i][0];
				$validOutput[$numValidOutput][$i][1] = $output[$iter][$i][1];
			}
			$numValidOutput++;
		}
	}

	print "\n\nALL VALID OUTPUT:\n\n";
	my @origPair;

	for(my $valiter = 0; $valiter < $numValidOutput; $valiter++){
		@origPair = @{$pairList[$validOutput[$valiter][@{$output[0]}+1][0]]};
		print $origPair[0] . "." . $origPair[1] . " &\n" . $origPair[2] . "." . $origPair[3] . "\n";
		for(my $i = 0; $i < @{$output[$validOutput[$valiter][@{$output[0]}+1][0]]}; $i++){
			# print "output[$i] = " . $output[$iter][$i][1] . "\n";
			printf "\t%s: %.3f\n", $validOutput[$valiter][$i][0], $validOutput[$valiter][$i][1];
		}
		print "\n";
	}

	print "Number valid output pairs: $numValidOutput\n";

	$dbh->disconnect;
	print "\nEnd of script.\n";
}

sub censusTest{
	dbPrepare();

	my $SQL_branchesSelect = ", b.year as b_year, b.id as b_id, b.library_id as b_library_id, b.municipality_id as b_municipality_id,
	b.name as b_name, cast(b.annual_rent as decimal(10,2)) as b_annual_rent, b.floor_space as b_floor_space, b.active_memberships as b_active_memberships,
	b.nonresident_single_memberships as b_nonresident_single_memberships, b.nonresident_family_memberships as b_nonresident_family_memberships";

	my $SQL_branchesJoin = " inner join branches as b on b.municipality_id = m.id and b.year = '2011'";

	my $SQL = "select mun_cen.municipality_id as mun_id, census_year.value as cen_year_id,
	c.total as c_total, c.male as c_male, c.female as c_female, c.division_id as c_division_id, c.subdivision_id as c_subdivision_id,
	m.id as m_id, m.year as m_year, m.name as m_name, m.population as m_population"
	. $SQL_branchesSelect . 
	", census_characteristics.id as census_char_id,
	census_characteristics.value as census_char_value
	from mun_cen
	inner join census as c on mun_cen.census_subdivision_id = c.subdivision_id
	inner join census_year on c.year_id = census_year.id
	inner join municipalities as m on mun_cen.municipality_id = m.id
	inner join census_characteristics on c.characteristics_id = census_characteristics.id"
	. $SQL_branchesJoin;

	$sth = $dbh->prepare($SQL) or die "Prepare exception: $DBI::errstr!";
	$sth->execute() or die "Execute exception: $DBI::errstr";

	my $arr = $sth->fetchall_arrayref();
	my $arrNames = $sth->{NAME};
	my $arrTypes = $sth->{pg_type};

	# for(my $n = 0; $n < @{$arrNames}; $n++){
	# 	print $arrNames->[$n] . " ($arrTypes->[$n])\n";
	# }

	# my $charValIdx = firstidx { $_ eq 'census_char_value' } @$arrNames;
	my $totalIdx = firstidx { $_ eq 'c_total'} @$arrNames;
	my $maleIdx = firstidx { $_ eq 'c_male'} @$arrNames;
	my $femaleIdx = firstidx { $_ eq 'c_female'} @$arrNames;
	my $characterIdIdx = firstidx { $_ eq 'census_char_id'} @$arrNames;
	my $rentIdx = firstidx { $_ eq 'b_annual_rent'} @$arrNames;
	my $floorSpaceIdx = firstidx { $_ eq 'b_floor_space'} @$arrNames;
	my $actvMemIdx = firstidx { $_ eq 'b_active_memberships'} @$arrNames;
	my $nonResSingMemIdx = firstidx { $_ eq 'b_nonresident_single_memberships'} @$arrNames;
	my $nonResFamlMemIdx = firstidx { $_ eq 'b_nonresident_family_memberships'} @$arrNames;

	my $varsList = [
		$rentIdx,
		$floorSpaceIdx,
		$actvMemIdx,
		$nonResSingMemIdx,
		$nonResFamlMemIdx
		];

	my $divIdx = firstidx { $_ eq 'c_division_id'} @$arrNames;
	my $subDivIdx = firstidx { $_ eq 'c_subdivision_id'} @$arrNames;

	my $censusValsList;
	#  $censusValsList layout:
	# 
	# Dim1: census_characteristics.id
	# Dim2: 
	# 	0: Descriptor of census values (total, male, female)
	# 	1: Actual census values in Dim3.Dim4 subarray
	# 	2: Number of elements in specific Dim3 subarrays
	# Dim3:
	# 	0: Specifier of which census value subarray (total, male, female)
	# Dim4:
	# 	0->n: Census values 

	my $censusDefined;
	my $sumList;
	my $censusValidIdxs;
	my $numValid;

	my $censusHasVals;
	my $censusValNames = [
		"Total",
		"Male",
		"Female"
	];

	$SQL = "select id, value from census_characteristics";
	$sth = $dbh->prepare($SQL) or die "Prepare exception: $DBI::errstr!";
	$sth->execute() or die "Execute exception: $DBI::errstr";
	my $census_charArr = $sth->fetchall_arrayref();

	for(my $n = 1; $n <= @{$census_charArr}; $n++){
		$censusValsList->[$n][0] = $census_charArr->[$n-1][1];
		$censusValsList->[$n][2][0] = 0;
		$censusValsList->[$n][2][1] = 0;
		$censusValsList->[$n][2][2] = 0;
	}

	my $currentCharId;

	my $munPopList;

	my $censusStandStructList;
	my $censusStandStructValidNum = 0;

	# Stores census total/male/female values for each valid row in $arr.
	for(my $n = 0; $n < @{$arr}; $n++){
		$numValid = 0;
		$currentCharId = $arr->[$n][$characterIdIdx];
		# print "\$currentCharId = $currentCharId\n";
		# print "\$n = $n\n";

		if(defined $arr->[$n][$totalIdx] && !($arr->[$n][$totalIdx] eq '')){
			# print "1\n";
			$censusValsList->[$currentCharId][1][0][$censusValsList->[$currentCharId][2][0]] = $arr->[$n][$totalIdx];
			
			$sumList->[0] += $censusValsList->[$currentCharId][1][0][$censusValsList->[$currentCharId][2][0]];
			if($censusValsList->[$currentCharId][1][0][$censusValsList->[$currentCharId][2][0]] != 0){
				$numValid++;
			}
			$censusDefined->[0]++;
			$censusHasVals->[$currentCharId][0] = 1;
			$censusValsList->[$currentCharId][2][0]++;

			# print $censusValsList->[$currentCharId][1][0][$n] . "\t";
			# print "\$arr->[$n][$totalIdx] = $arr->[$n][$totalIdx]\n";
			# print "\$censusValsList->[$currentCharId][1][0][$n] = " . $censusValsList->[$currentCharId][1][0][$n] . "\n";
		}
		if(defined $arr->[$n][$maleIdx] && !($arr->[$n][$maleIdx] eq '')){
			# print "\t2\n";
			$censusValsList->[$currentCharId][1][1][$censusValsList->[$currentCharId][2][1]] = $arr->[$n][$maleIdx];
			
			$sumList->[1] += $censusValsList->[$currentCharId][1][1][$censusValsList->[$currentCharId][2][1]];
			$numValid++;
			$censusDefined->[1]++;
			$censusHasVals->[$currentCharId][1] = 1;
			$censusValsList->[$currentCharId][2][1]++;

			# print $censusValsList->[$currentCharId][1][1][$n] . "\t";
			# print "\$censusValsList->[$currentCharId][1][1][$n] = " . $censusValsList->[$currentCharId][1][1][$n] . "\n";
		}
		if(defined $arr->[$n][$femaleIdx] && !($arr->[$n][$femaleIdx] eq '')){
			# print "\t\t3\n";
			$censusValsList->[$currentCharId][1][2][$censusValsList->[$currentCharId][2][2]] = $arr->[$n][$femaleIdx];
			
			$sumList->[2] += $censusValsList->[$currentCharId][1][2][$censusValsList->[$currentCharId][2][2]];
			$numValid++;
			$censusDefined->[2]++;
			$censusHasVals->[$currentCharId][2] = 1;
			$censusValsList->[$currentCharId][2][2]++;

			# print $censusValsList->[$currentCharId][1][2][$n] . "\t";
			# print "\$censusValsList->[$currentCharId][1][2][$n] = " . $censusValsList->[$currentCharId][1][2][$n] . "\n";
		}

		if($numValid == 3){
			$censusValidIdxs->[$n] = 1;
		}
		else{
			$censusValidIdxs->[$n] = 0;
		}
		# <STDIN>;
	}

	for(my $n = 0; $n < @{$arr}; $n++){
		if($censusValidIdxs->[$n]){
			$censusStandStructValidNum++;
			my $currentCharId = $arr->[$n][$characterIdIdx];
			$censusStandStructList->[$currentCharId][0][$n] = $arr->[$n][$totalIdx];
			$censusStandStructList->[$currentCharId][1][$n] = $arr->[$n][$maleIdx];
			$censusStandStructList->[$currentCharId][2][$n] = $arr->[$n][$femaleIdx];

			print "$currentCharId:\t$censusStandStructList->[$currentCharId][0][$n]\t$censusStandStructList->[$currentCharId][1][$n]\t$censusStandStructList->[$currentCharId][2][$n]\n";

			print "size: " . @{$censusStandStructList->[$currentCharId][0]} . "\n\n";
		}
	}
	<STDIN>;

	my @generalOutput;

	my $munIds;
	my $munVals;
	my $div;
	my $subDiv;

	my $SQL_munFields = "municipalities.id, municipalities.year, municipalities.name, municipalities.population";

	$SQL = "select " . $SQL_munFields . " from municipalities where false";
	$sth = $dbh->prepare($SQL) or die "Prepare exception: $DBI::errstr!";
	$sth->execute() or die "Execute exception: $DBI::errstr";
	my $munNames = $sth->{NAME};
	$sth->finish();

	my $munIdIdx = firstidx { $_ eq 'id'} @$munNames;
	my $munPopIdx = firstidx { $_ eq 'population'} @$munNames;

	my $munNumVals = 0;
	my $munPopVals;

	# Gathering all unique municipality ids that show up in the census data
	for(my $n = 0; $n < @{$censusValidIdxs}; $n++){
		# print "$n validity: " . $censusValidIdxs->[$n] . "\n";
		if($censusValidIdxs->[$n]){
			$div = $arr->[$n][$divIdx];
			$subDiv = $arr->[$n][$subDivIdx];
			# print "div: $div, subDiv: $subDiv\n";
			if(! defined $munIds->[$div][$subDiv]){
				
				print "Defining [$div][$subDiv]\n";
				
				$SQL = "select " . $SQL_munFields . " from mun_cen
				inner join municipalities on mun_cen.municipality_id = municipalities.id
				and municipalities.year = '2011' and census_division_id = '$div' and census_subdivision_id = '$subDiv'";

				$sth = $dbh->prepare($SQL) or die "Prepare exception: $DBI::errstr!";
				$sth->execute() or die "Execute exception: $DBI::errstr";

				# my $test = ;
				# for(my $mun = 0; $mun < @{$test}; $mun++){
				# print "$test->[0][0]\n";
				# }
				my $data = $sth->fetchall_arrayref()->[0];
				
				$munIds->[$div][$subDiv] = $data->[$munIdIdx];
				$munVals->[$munNumVals] = $data;
				for(my $val = 0; $val < @{$munVals->[$munNumVals]}; $val++){
					if(defined $munVals->[$munNumVals][$val]){
						print "$munNames->[$val]: $munVals->[$munNumVals][$val]\n";
					}
				}
				$munPopVals->[$munNumVals] = $munVals->[$munNumVals][3];
				$munNumVals++;
				# print "munNumVals = $munNumVals\n";
				print "\n";
				# <STDIN>;
			}
		}
	}
	<STDIN>;
	
	my $listIdx = 0;
	my @censusOutput;
	my $censusOutputDesc;

	my $censusOutputIdx = 0;
	for(my $censusValsIdx = 1; $censusValsIdx <= @{$census_charArr}; $censusValsIdx++){
		for(my $innerCensusValsIdx = 0; $innerCensusValsIdx < @{$censusValNames}; $innerCensusValsIdx++){
			if($censusHasVals->[$censusValsIdx][$innerCensusValsIdx]){
				computeSingleAvgSD('census',
				"\"" . $censusValsList->[$censusValsIdx][0] . "\"." . $censusValNames->[$innerCensusValsIdx],
					$censusValsList->[$censusValsIdx][2][$innerCensusValsIdx],
					$censusValsList->[$censusValsIdx][1][$innerCensusValsIdx],
					$censusHasVals,
					$censusValsList->[$censusValsIdx][2][$innerCensusValsIdx],
					$censusOutputIdx,
					\@censusOutput);

				print "\$censusOutput[$censusOutputIdx][0][0] = " . $censusOutput[$censusOutputIdx][0][0] . "\n";
				print "\$censusOutput[$censusOutputIdx][0][1] = " . $censusOutput[$censusOutputIdx][0][1] . "\n";
				print "\$censusOutput[$censusOutputIdx][1][0] = " . $censusOutput[$censusOutputIdx][1][0] . "\n";
				print "\$censusOutput[$censusOutputIdx][1][1] = " . $censusOutput[$censusOutputIdx][1][1] . "\n";

				$generalOutput[$censusOutputIdx][0][1] = $censusOutput[$censusOutputIdx][0][1];

				$generalOutput[$censusOutputIdx][1][1] = $censusOutput[$censusOutputIdx][1][1];

				$censusOutputDesc->[$censusOutputIdx][0] = $censusValsList->[$censusValsIdx][0];
				$censusOutputDesc->[$censusOutputIdx][1] = $censusValNames->[$innerCensusValsIdx];

				$censusOutputIdx++;
			}
			print "Done $censusValsIdx.$innerCensusValsIdx\n\n";
			# <STDIN>;
		}
	}

	print "\nCOMPLETED COMPUTATION OF AVERAGES AND STANDARD DEVIATIONS FOR EACH CENSUS VALUE SET.\n\n";
	
	my @munOutput;
	my $munOutputIdx = 0;

	print "\@{\$munPopVals} = " . @{$munPopVals} . "\n";
	<STDIN>;

	computeSingleAvgSD("municipalities", "population",
		$munNumVals, $munPopVals,
		$munPopVals, $munNumVals,
		$munOutputIdx, \@munOutput);

	for(my $censusIdx = 0; $censusIdx < @censusOutput; $censusIdx++){
		$generalOutput[$censusIdx][2][1] = $munOutput[$munOutputIdx][0][1];
		$generalOutput[$censusIdx][3][1] = $munOutput[$munOutputIdx][1][1];
		for(my $i = 0; $i < 4; $i++){
			print "\$generalOutput[$censusIdx][$i][1] = $generalOutput[$censusIdx][$i][1]\n";
		}
		print "\n";
	}
	<STDIN>;

	my $generalOutputIdx;

	for(my $munIdx = 0; $munIdx < @munOutput; $munIdx++){
		$censusOutputIdx = 0;
		for(my $censusValsIdx = 1; $censusValsIdx <= @{$census_charArr}; $censusValsIdx++){
			for(my $innerCensusValsIdx = 0; $innerCensusValsIdx < @{$censusValNames}; $innerCensusValsIdx++){
				$generalOutputIdx = ($munIdx+1)*($censusValidIdxs*3 + $innerCensusValsIdx);
				if($censusHasVals->[$censusValsIdx][$innerCensusValsIdx]){
					print "Computing $censusValsIdx.$innerCensusValsIdx\n";
					print "yfieldSize: " . @{$censusStandStructList->[1][0]} . "\n";
					<STDIN>;
					
					computePCC(
						(@censusOutput * @munOutput),
						$munPopVals,
						$censusStandStructList->[$censusValsIdx][$innerCensusValsIdx],
						$censusValidIdxs,
						$censusStandStructValidNum,
						$censusOutputIdx,
						\@generalOutput);
				
					$censusOutputIdx++;
				}
			}
		}
	}
}

sub censusMun{
	dbPrepare();

	my $SQL_branchesSelect = ", b.year as b_year, b.id as b_id, b.library_id as b_library_id, b.municipality_id as b_municipality_id,
	b.name as b_name, cast(b.annual_rent as decimal(10,2)) as b_annual_rent, b.floor_space as b_floor_space, b.active_memberships as b_active_memberships,
	b.nonresident_single_memberships as b_nonresident_single_memberships, b.nonresident_family_memberships as b_nonresident_family_memberships";

	my $SQL_branchesJoin = " inner join branches as b on b.municipality_id = m.id and b.year = '2011'";

	my $SQL = "select census_year.value as cen_year_id,
	c.total as c_total, c.male as c_male, c.female as c_female, c.division_id as c_division_id, c.subdivision_id as c_subdivision_id,
	m.id as m_id, m.year as m_year, m.name as m_name, m.population as m_population,
	census_characteristics.id as census_char_id,
	census_characteristics.value as census_char_value
	from mun_cen
	inner join census as c on mun_cen.census_subdivision_id = c.subdivision_id
	inner join census_year on c.year_id = census_year.id
	inner join municipalities as m on mun_cen.municipality_id = m.id and m.year = '2011'
	inner join census_characteristics on c.characteristics_id = census_characteristics.id";

	$sth = $dbh->prepare($SQL) or die "Prepare exception: $DBI::errstr!";
	$sth->execute() or die "Execute exception: $DBI::errstr";

	my $arr = $sth->fetchall_arrayref();
	my $arrNames = $sth->{NAME};
	my $arrTypes = $sth->{pg_type};

	# for(my $n = 0; $n < @{$arrNames}; $n++){
	# 	print $arrNames->[$n] . " ($arrTypes->[$n])\n";
	# }

	# my $charValIdx = firstidx { $_ eq 'census_char_value' } @$arrNames;
	my $totalIdx = firstidx { $_ eq 'c_total'} @$arrNames;
	my $maleIdx = firstidx { $_ eq 'c_male'} @$arrNames;
	my $femaleIdx = firstidx { $_ eq 'c_female'} @$arrNames;
	my $characterIdIdx = firstidx { $_ eq 'census_char_id'} @$arrNames;
	my $divIdx = firstidx { $_ eq 'c_division_id'} @$arrNames;
	my $subDivIdx = firstidx { $_ eq 'c_subdivision_id'} @$arrNames;

	my $m_idIdx = firstidx { $_ eq 'm_id'} @$arrNames;
	my $m_popIdx = firstidx { $_ eq 'm_population'} @$arrNames;

	my @censusMunVals;
	my @currentArr;
	my $currentRow;

	my $current_m_id;
	my $current_char_id;

	my $censusMunValidList;
	my $censusMunSizeList;

	my $numTuples = 0;

	my @censusOutput;
	my $censusValidVals;
	my $censusValidValsIdx;
	my $censusValidChars;

	# Holds population of each valid municipality
	my $munValidVals;
	my $munNumValidVals = 0;

	# Gathering all unique municipality ids that show up in the census data
	for(my $n = 0; $n < @{$arr}; $n++){
		
		$currentRow = $arr->[$n];

		# Only views census values that are valid
		# (ie, at least total > 0 and all values at least defined as a number)
		if(defined $currentRow->[$totalIdx]
			&& !($currentRow->[$totalIdx] eq '')
			&& $currentRow->[$totalIdx] !=0
			&& defined $currentRow->[$maleIdx]
			&& !($currentRow->[$maleIdx] eq '')
			&& defined $currentRow->[$femaleIdx]
			&& !($currentRow->[$femaleIdx] eq '')
			){

			@currentArr = [
				$currentRow->[$m_popIdx],
				$currentRow->[$totalIdx],
				$currentRow->[$maleIdx],
				$currentRow->[$femaleIdx]
			];

			$current_m_id = $arr->[$n][$m_idIdx];
			$current_char_id = $currentRow->[$characterIdIdx];

			push @{$censusMunVals
				[$current_m_id]
				[$current_char_id]},
				@currentArr;

			# print "m_id: $current_m_id\n";
			# print "c_idIdx: $current_char_id\n";

			$censusMunValidList->[$current_m_id] = 1;
			$censusMunSizeList->[$current_m_id]++;

			$munValidVals->[$munNumValidVals] = $currentRow->[$m_popIdx];
			$munNumValidVals++;

			$censusValidChars->[$n+1] = 1;

			# my $outerSize = $censusMunSizeList->[$current_m_id];
			# my $innerSize = @{$censusMunVals
			# 	[$current_m_id]
			# 	[$current_char_id]};

			if(defined $censusValidVals->[$current_char_id][0]){
				$censusValidValsIdx = @{$censusValidVals->[$current_char_id][0]};
			}
			else{
				$censusValidValsIdx = 0;
			}
			# print "censusValidValsIdx: $censusValidValsIdx\n";

			$censusValidVals->[$current_char_id][0][$censusValidValsIdx] = $currentRow->[$totalIdx];
			$censusValidVals->[$current_char_id][1][$censusValidValsIdx] = $currentRow->[$maleIdx];
			$censusValidVals->[$current_char_id][2][$censusValidValsIdx] = $currentRow->[$femaleIdx];

			$numTuples++;
			# print "outerSize: $outerSize, innerSize: $innerSize, numTuples: $numTuples\n";
			# print "\n";
			# <STDIN>;
		}
	}
	
	# <STDIN>;
	my $censusNames = [
		$arrNames->[$totalIdx],
		$arrNames->[$maleIdx],
		$arrNames->[$femaleIdx]
	];

	my $resRows;
	my $listIdx = 0;
	for($current_char_id = 1; $current_char_id < @{$censusValidVals}; $current_char_id++){
		if(defined $censusValidVals->[$current_char_id]){
			$resRows = @{$censusValidVals->[$current_char_id][0]};
			for(my $innerValIdx = 0; $innerValIdx < 3; $innerValIdx++){
				# print "computeSingleAvgSD for census $current_char_id.$innerValIdx\n";
				computeSingleAvgSD(
					"census",	#table
					$current_char_id . "_" . $innerValIdx . "($censusNames->[$innerValIdx])",	#field
					$resRows,	#resRows
					$censusValidVals->[$current_char_id][$innerValIdx],	#fieldArr
					$censusValidVals->[$current_char_id][$innerValIdx],	#resValidTuples
					$resRows,	#resNumValidTuples
					$listIdx,	#listIdx
					\@censusOutput	#givenOutput
					);
				
				print "$censusOutput[$listIdx][0][0]: $censusOutput[$listIdx][0][1]\n";
				print "$censusOutput[$listIdx][1][0]: $censusOutput[$listIdx][1][1]\n";
				print "\n";
				$listIdx++;
				# <STDIN>;
			}
		}
	}

	my @munOutput;
	$listIdx = 0;

	computeSingleAvgSD(
		"municipalities",
		"population",
		$munNumValidVals,
		$munValidVals,
		$munValidVals,
		$munNumValidVals,
		$listIdx,
		\@munOutput
		);

	# my @censusMunComputeOutput;
	# for(my $char_id = 0; $char_id < 254; $char_id++){
	# 	if($censusValidChars->[$char_id]){
	# 		censusMunComputePairPCC(
	# 			\@censusMunVals,	#censusMunVals
	# 			$char_id,	#char_id
	# 			$censusMunValidList,
	# 			$censusMunSizeList,
	# 			0,	#pairListIdx
	# 			\@censusMunComputeOutput	#givenOutput
	# 			);

	# 		print "$munOutput[$listIdx][0][0]: $munOutput[$listIdx][0][1]\n";
	# 		print "$munOutput[$listIdx][1][0]: $munOutput[$listIdx][1][1]\n";
	# 	}
	# }

	print "Done.\n";
}

sub munCensusSorting{
	# dbPrepare();

	my $SQL = "select census_year.value as cen_year_id,
	c.total as c_total, c.male as c_male, c.female as c_female, c.division_id as c_division_id, c.subdivision_id as c_subdivision_id,
	m.id as m_id, m.year as m_year, m.name as m_name, m.population as m_population,
	census_characteristics.id as census_char_id,
	census_characteristics.value as census_char_value
	from mun_cen
	inner join census as c on mun_cen.census_subdivision_id = c.subdivision_id
	inner join census_year on c.year_id = census_year.id
	inner join municipalities as m on mun_cen.municipality_id = m.id and m.year = '2011'
	inner join census_characteristics on c.characteristics_id = census_characteristics.id";

	$sth = $dbh->prepare($SQL) or die "Prepare exception: $DBI::errstr!";
	$sth->execute() or die "Execute exception: $DBI::errstr";

	my $arr = $sth->fetchall_arrayref();
	my $arrNames = $sth->{NAME};
	my $arrTypes = $sth->{pg_type};

	my $totalIdx = firstidx { $_ eq 'c_total'} @$arrNames;
	my $maleIdx = firstidx { $_ eq 'c_male'} @$arrNames;
	my $femaleIdx = firstidx { $_ eq 'c_female'} @$arrNames;
	my $characterIdIdx = firstidx { $_ eq 'census_char_id'} @$arrNames;
	my $divIdx = firstidx { $_ eq 'c_division_id'} @$arrNames;
	my $subDivIdx = firstidx { $_ eq 'c_subdivision_id'} @$arrNames;

	my $m_idIdx = firstidx { $_ eq 'm_id'} @$arrNames;
	my $m_popIdx = firstidx { $_ eq 'm_population'} @$arrNames;

	my @censusMunVals;
	my @currentArr;
	my $currentRow;

	my $current_m_id;
	my $current_char_id;

	my $censusMunValidList;
	my $censusMunSizeList;

	my $censusValidChars;

	my $munValidVals;
	my $munNumValidVals = 0;

	# Gathering all unique municipality ids that show up in the census data
	for(my $n = 0; $n < @{$arr}; $n++){
		$currentRow = $arr->[$n];
		# print "n: $n\n";

		# Only views census values that are valid
		# (ie, at least total > 0 and all values at least defined as a number)
		if(defined $currentRow->[$totalIdx]
			&& !($currentRow->[$totalIdx] eq '')
			&& $currentRow->[$totalIdx] !=0
			&& defined $currentRow->[$maleIdx]
			&& !($currentRow->[$maleIdx] eq '')
			&& defined $currentRow->[$femaleIdx]
			&& !($currentRow->[$femaleIdx] eq '')
			){

			# $SQL = "select c.total from census as c inner join mun_cen on mun_cen.census_subdivision_id = c.subdivision_id and c.subdivision_id = '$currentRow->[$subDivIdx]' inner join municipalities as m on m.id = mun_cen.municipality_id";
			
			# $sth = $dbh->prepare($SQL) or die "Prepare exception: $DBI::errstr!";
			# $sth->execute() or die "Execute exception: $DBI::errstr";

			# my $censusPop = $sth->fetchall_arrayref();

			@currentArr = [
				$currentRow->[$m_popIdx],
				$currentRow->[$totalIdx],
				$currentRow->[$maleIdx],
				$currentRow->[$femaleIdx]
			];

			$current_m_id = $arr->[$n][$m_idIdx];
			$current_char_id = $currentRow->[$characterIdIdx];

			push @{$censusMunVals
				[$current_m_id]
				[$current_char_id]},
				@currentArr;


			$censusMunValidList->[$current_m_id] = 1;
			$censusMunSizeList->[$current_m_id]++;

			$munValidVals->[$munNumValidVals] = $currentRow->[$m_popIdx];
			$munNumValidVals++;

			$censusValidChars->[$n+1] = 1;

			# print "current_char_id: $current_char_id, current_m_id: $current_m_id\n";
			# <STDIN>;
		}
	}
	# print "$censusMunVals[557][8][0][2]\n";
	return @censusMunVals;
}

# Links appropriate library id's to census data joined with municipalities.
sub linkLibsMuns{
	# dbPrepare();

	my ($censusMunVals) = @_;
	# my @censusMunVals = munCensusSorting();
	# print "$censusMunVals[557][8][0][0]\n";

	my $SQL = "select id as b_id, year as b_year, library_id as l_id, municipality_id	as m_id from branches where municipality_id is not null";

	$sth = $dbh->prepare($SQL) or die "Prepare exception: $DBI::errstr!";
	$sth->execute() or die "Execute exception: $DBI::errstr";
	my $branches = $sth->fetchall_arrayref();
	my $branchesNames = $sth->{NAME};

	my $l_id_idx = firstidx { $_ eq 'l_id'} @$branchesNames;
	my $m_id_idx = firstidx { $_ eq 'm_id'} @$branchesNames;

	my $links;
	my $currentRow;
	my $l_id;
	my $m_id;
	my $linkSubSize;

	for(my $row = 0; $row < @{$branches}; $row++){
		$currentRow = $branches->[$row];
		$l_id = $currentRow->[$l_id_idx];
		$m_id = $currentRow->[$m_id_idx];
		
		# print "m_id: " . $m_id . "\n";
		if(defined $censusMunVals->[$m_id]){
			$linkSubSize = @{$censusMunVals->[$m_id]};
			# print "\tlinkSubSize: $linkSubSize\n";
			$links->[$l_id][$linkSubSize] = $censusMunVals->[$m_id];
		}
	}

	return $links;
}

# Calculates average municipality population, given a list of municipality populations.
sub calculateAvgMunPops{
	my ($censusMunVals) = @_;

	my $SQL = "select id, population from municipalities";
	$sth = $dbh->prepare($SQL) or die "Prepare exception: $DBI::errstr!";
	$sth->execute() or die "Execute exception: $DBI::errstr";
	my $munTable = $sth->fetchall_arrayref();

	my $sum = 0;
	my $numMuns = 0;

	for(my $row = 0; $row < @{$munTable}; $row++){
		if(defined $censusMunVals->[$munTable->[$row][0]]){
			$sum += $munTable->[$row][1];
			$numMuns++;
		}
	}
	my $avg = $sum/$numMuns;
	print "NUM_MUN: $numMuns, AVG_POP: $avg\n";
	return $avg;
}

# Simple method, doesn't check if municipality is valid, and it takes the first tuple returned.
sub calculateMaxMunPops{
	my $SQL = "select population from municipalities where population = (select max(population) from municipalities);";
	$sth = $dbh->prepare($SQL) or die "Prepare exception: $DBI::errstr!";
	$sth->execute() or die "Execute exception: $DBI::errstr";
	my $maxPops = $sth->fetchall_arrayref();

	# print "MAX_POP: $maxPops->[0][0]\n";
	# <STDIN>;
	return $maxPops->[0][0];
}

# Takes array given by 'munCensusSorting' sub.
# Calls calculateAvgMunPops and censusCalcAvgChars.
# Creates new array holding normalized census characteristic values for each municipality.
# 	For municipality m,
# 		census characteristic c,
# 		inner characteristic indicator inner,
# 		averaged characteristic indicator innerCharAvg,
# 		and average population avgPop:
#
# 			m's c's normalized inner =
# 				(m's pop/avgPop)/(m's c's inner/innerCharAvg)
sub normalizeCensusValues{
	dbPrepare();

	my @censusMunVals = munCensusSorting();
	my $popAvg = calculateAvgMunPops(\@censusMunVals);
	# my $links = linkLibsMuns(\@censusMunVals);	

	my @normalized;
	my $charAvgs = censusCalcAvgChars(\@censusMunVals);
	my $currentNormPop;

	for(my $m_id = 1; $m_id < @censusMunVals; $m_id++){
		if(defined $censusMunVals[$m_id]){
			# print "Normalizing values of municipality $m_id\n";
			for(my $c_id = 1; $c_id < @{$censusMunVals[$m_id]}; $c_id++){
				if(defined $censusMunVals[$m_id][$c_id]){
					$currentNormPop = $censusMunVals[$m_id][$c_id][0][0]/$popAvg;
					# print "m_id: $m_id, c_id: $c_id, currentNormPop: $currentNormPop\n";
					for(my $inner = 1; $inner < 4; $inner++){
						if($currentNormPop == 0 || $charAvgs->[$c_id][$inner] == 0){
							$normalized[$m_id][$c_id][$inner] = 0;
						}
						else{
							$normalized[$m_id][$c_id][$inner] = $censusMunVals[$m_id][$c_id][0][$inner]/
								($currentNormPop * $charAvgs->[$c_id][$inner]);
						}

						# print "normalized[$m_id][$c_id][$inner]: $normalized[$m_id][$c_id][$inner]\n";
					}
				}
			}
		}
	}
	return @normalized;
}

# For each census characteristic subvalue E_c_i, each municipality m's census characteristic subvalue e_m_i is given the value of 
# 	e_m_i = ((e_m_i - E_c_i_min) / (E_c_i_max - E_c_i_min))
# 		* (m's pop i);
	
# Each e_m_i is then normalized again by the max of all e_x_i's to be put in a range from 0 -> 1.

# This gives normalized values that are per capita for each municipality, and allows us to compare between municipalities.
sub normalizeCensusValues2{
	dbPrepare();

	my @censusMunVals = munCensusSorting();
	# my $popAvg = calculateAvgMunPops(\@censusMunVals);
	# my $maxPop = calculateMaxMunPops();
	# my $links = linkLibsMuns(\@censusMunVals);
	# my $censusPop = getTrueCensus2011Pops(\@censusMunVals);

	my @normalized;
	# my $charAvgs = censusCalcAvgChars(\@censusMunVals);
	my $currentNormPop;

	my $charMinMax;
	my $resultsMax;

	my $currentPop;

	# Finding max and min for each census characteristic subvalue.
	for(my $m_id = 1; $m_id < @censusMunVals; $m_id++){
		if(defined $censusMunVals[$m_id]){
			# print "Normalizing values of municipality $m_id\n";
			for(my $c_id = 1; $c_id < @{$censusMunVals[$m_id]}; $c_id++){
				if(defined $censusMunVals[$m_id][$c_id]){
					# $currentPop = $censusMunVals[$m_id][$c_id][0][0];
					# print "m_id $m_id\'s currentPop: $currentPop\n";
					for(my $inner = 1; $inner < 4; $inner++){
						$currentPop = $censusMunVals[$m_id][8][0][$inner];
						if(! defined $charMinMax->[$c_id][$inner]){
							$charMinMax->[$c_id][$inner][0] = $censusMunVals[$m_id][$c_id][0][$inner]/$currentPop;
							$charMinMax->[$c_id][$inner][1] = $censusMunVals[$m_id][$c_id][0][$inner]/$currentPop;
						}
						else{
							# print "[$m_id][$c_id][0][$inner] = " . $censusMunVals[$m_id][$c_id][0][$inner] . "\n";
							if($censusMunVals[$m_id][$c_id][0][$inner]/$currentPop < $charMinMax->[$c_id][$inner][0]){
								$charMinMax->[$c_id][$inner][0] = $censusMunVals[$m_id][$c_id][0][$inner]/$currentPop;
							}
							if($censusMunVals[$m_id][$c_id][0][$inner]/$currentPop > $charMinMax->[$c_id][$inner][1]){
								$charMinMax->[$c_id][$inner][1] = $censusMunVals[$m_id][$c_id][0][$inner]/$currentPop;
							}
						}
						if($charMinMax->[$c_id][$inner][1] > 1.1){
							print "m_id: $m_id, [$c_id][$inner][1] = $charMinMax->[$c_id][$inner][1]\n";
							<STDIN>;
						}
					}
				}
			}
		}
	}

	# Applying first normalization step to census/municipality characteristic subvalues.
	for(my $m_id = 1; $m_id < @censusMunVals; $m_id++){
		if(defined $censusMunVals[$m_id]){
			# print "Normalizing values of municipality $m_id\n";
			for(my $c_id = 1; $c_id < @{$censusMunVals[$m_id]}; $c_id++){
				if(defined $censusMunVals[$m_id][$c_id]){
					for(my $inner = 1; $inner < 4; $inner++){
						$currentPop = $censusMunVals[$m_id][8][0][$inner];
						if($charMinMax->[$c_id][$inner][0] == $charMinMax->[$c_id][$inner][1]){
							$normalized[$m_id][$c_id][$inner] = 0.5;
							$resultsMax->[$c_id][$inner] = 0.5;
						}
						else{
							$normalized[$m_id][$c_id][$inner] = 
								((($censusMunVals[$m_id][$c_id][0][$inner]/$currentPop)-$charMinMax->[$c_id][$inner][0]) /
								($charMinMax->[$c_id][$inner][1] - $charMinMax->[$c_id][$inner][0]));

							# if($m_id == 609 && $c_id == 69){
							# 	print "c_id: $c_id.$inner, pop: $currentPop, val: $censusMunVals[$m_id][$c_id][0][$inner], norm: $normalized[$m_id][$c_id][$inner], min: $charMinMax->[$c_id][$inner][0], max: $charMinMax->[$c_id][$inner][1]\n";
							# 	<STDIN>;
							# }

							if(! defined $resultsMax->[$c_id][$inner] || $resultsMax->[$c_id][$inner] < $normalized[$m_id][$c_id][$inner]){
								$resultsMax->[$c_id][$inner] = $normalized[$m_id][$c_id][$inner];
							}
						}
					}
				}
			}
		}
	}

	# <STDIN>;
	return @normalized;
}

# Calculates average of each (Total, Male, Female) across all valid censusMunVals, stores averages in similar structure to censusMunVals.
sub censusCalcAvgChars{
	my ($censusMunVals) = @_;

	my $charAvgs;
	my $charNums;

	for(my $m_id = 1; $m_id < @{$censusMunVals}; $m_id++){
		if(defined $censusMunVals->[$m_id]){
			for(my $c_id = 1; $c_id < @{$censusMunVals->[$m_id]}; $c_id++){
				if(defined $censusMunVals->[$m_id][$c_id]){
					for(my $inner = 1; $inner < 4; $inner++){
						$charAvgs->[$c_id][$inner] += $censusMunVals->[$m_id][$c_id][0][$inner];
						$charNums->[$c_id]++;
						# print "charAvgs->[$c_id] = $charAvgs->[$c_id]\n";
					}
				}
			}
		}
	}

	for(my $c_id = 1; $c_id < @{$charAvgs}; $c_id++){
		if(defined $charNums->[$c_id]){
			for(my $inner = 1; $inner < 4; $inner++){
				$charAvgs->[$c_id][$inner] = $charAvgs->[$c_id][$inner]/$charNums->[$c_id];
				# print "charAvgs->[$c_id][$inner] = $charAvgs->[$c_id][$inner]\n";
			}
		}
	}

	return $charAvgs;
}

# Instead of using the population values from the municipalities table, get these values from the census data (specifically census characteristic 1, 'Population in 2011')
# This is a slow way to tackle this, although it is only done once for each valid municipality. This should be improved in the future.
sub getTrueCensus2011Pops{
	my ($censusMunVals) = @_;

	my $census2011Pops;

	for(my $m_id = 1; $m_id < @{$censusMunVals}; $m_id++){
		if(defined $censusMunVals->[$m_id]){
			print "m_id: $m_id\n";
			$SQL = "select c.total from census as c inner join mun_cen on mun_cen.census_subdivision_id = c.subdivision_id and characteristics_id = '1' inner join municipalities as m on m.id = mun_cen.municipality_id and m.id = '$m_id'";
			
			$sth = $dbh->prepare($SQL) or die "Prepare exception: $DBI::errstr!";
			$sth->execute() or die "Execute exception: $DBI::errstr";

			$census2011Pops->[$m_id] = $sth->fetchall_arrayref()->[0][0];
		}
	}

	<STDIN>;

	return $census2011Pops;

}

# Lists valid municipalities, lets the user choose one.
# Then lists valid census characteristics for that municipality, lets the user choose one.
# Shows normalized values for (Total, Male, Female) for the given characteristic for the given municipality.
sub listSpecificNormalizedValues{
	my @normalized = normalizeCensusValues2();

	my $SQL = "select id, name from municipalities";
	$sth = $dbh->prepare($SQL) or die "Prepare exception: $DBI::errstr!";
	$sth->execute() or die "Execute exception: $DBI::errstr";

	my $muns = $sth->fetchall_arrayref();

	my $munList;
	my $charList;
	my $munChoice;
	my $charChoice;

	# Gathers id and name from all valid municipalities.
	for(my $m_id = 0; $m_id < @normalized; $m_id++){
		if(defined $normalized[$m_id]){
			$SQL = "select id, name from municipalities where id = '$m_id'";

			$sth = $dbh->prepare($SQL) or die "Prepare exception: $DBI::errstr!";
			$sth->execute() or die "Execute exception: $DBI::errstr";
			$munList->[@{$munList}] = $sth->fetchall_arrayref()->[0];
		}
	}

	# Prints all valid municipalities for the user to choose from.
	for(my $n = 0; $n < @{$munList}; $n++){
		print $munList->[$n][0] . ": " . $munList->[$n][1] . "\n";
	}

	# Gets valid municipality id choice from user:
	do{
		print "\nChoose a municipality by typing in one of the id's above: ";
		$munChoice = <STDIN>;
		chomp $munChoice;

		if((!looks_like_number($munChoice)) || ! defined $normalized[$munChoice] || $munChoice <= 0){
			print "Not a valid municipality id!\n";
		}
	}while((!looks_like_number($munChoice)) || ! defined $normalized[$munChoice] || $munChoice <= 0);

	# Gathers id and value from all valid census characteristics (for the chosen municipality).
	for(my $c_id = 0; $c_id < @{$normalized[$munChoice]}; $c_id++){
		if(defined $normalized[$munChoice][$c_id]){
			$SQL = "select id, value from census_characteristics where id = '$c_id'";
			$sth = $dbh->prepare($SQL) or die "Prepare exception: $DBI::errstr!";
			$sth->execute() or die "Execute exception: $DBI::errstr";
			$charList->[@{$charList}] = $sth->fetchall_arrayref()->[0];
		}
	}

	# Prints all valid census characteristics (for the chosen municipality) for the user to choose from.
	print "\n\n";
	for(my $n = 0; $n < @{$charList}; $n++){
		print $charList->[$n][0] . ": " . $charList->[$n][1] . "\n";
	}

	# Gets valid census characteristic id choice from user:
	do{
		print "\nChoose a census characteristic by typing in one of the id's above: ";
		$charChoice = <STDIN>;
		chomp $charChoice;

		if((!looks_like_number($charChoice)) || ! defined $normalized[$munChoice][$charChoice]){
			print "Not a valid characteristic id!\n";
		}
	}while((!looks_like_number($charChoice)) || ! defined $normalized[$munChoice][$charChoice]);

	my $innerNames = [
		'',
		'Total',
		'Male',
		'Female'
	];

	# Gets name for chosen census characteristic:
	$SQL = "select value from census_characteristics where id = '$charChoice'";
	$sth = $dbh->prepare($SQL) or die "Prepare exception: $DBI::errstr!";
	$sth->execute() or die "Execute exception: $DBI::errstr";
	my $charValue = $sth->fetchall_arrayref()->[0][0];
	$charValue = trim($charValue);

	# Gets name for chosen municipality:
	$SQL = "select name from municipalities where id = '$munChoice'";
	$sth = $dbh->prepare($SQL) or die "Prepare exception: $DBI::errstr!";
	$sth->execute() or die "Execute exception: $DBI::errstr";
	my $munName = $sth->fetchall_arrayref()->[0][0];
	$munName =trim($munName);

	# Prints results:
	print "\nNormalized values (0 -> 1) of characteristic $charChoice ($charValue) per capita for municipality $munChoice ($munName) in comparison to all other municipalities:\n";
	for(my $inner = 1; $inner < 4; $inner++){
		print "\t" . $innerNames->[$inner] . ": " . $normalized[$munChoice][$charChoice][$inner] . "\n";
	}
	# print "Done listSpecificNormalizedValues sub\n";
}

# Lists valid municipalities, lets the user choose one.
# Asks for the number of minimum/maximum census characteristics values to display, in sorted ascending/descending (separately). This is ordered by subvalue (Total).
# Shows normalized values for (Total, Male, Female) for the given municipality.
sub findMinMaxNCharVals{
	my @normalized = normalizeCensusValues2();

	my $SQL = "select id, name from municipalities";
	$sth = $dbh->prepare($SQL) or die "Prepare exception: $DBI::errstr!";
	$sth->execute() or die "Execute exception: $DBI::errstr";

	my $muns = $sth->fetchall_arrayref();

	my $munList;
	my $charList;
	my $munChoice;
	my $numMinChars;
	my $numMaxChars;

	# Gathers id and name from all valid municipalities.
	for(my $m_id = 0; $m_id < @normalized; $m_id++){
		if(defined $normalized[$m_id]){
			$SQL = "select id, name from municipalities where id = '$m_id'";

			$sth = $dbh->prepare($SQL) or die "Prepare exception: $DBI::errstr!";
			$sth->execute() or die "Execute exception: $DBI::errstr";
			$munList->[@{$munList}] = $sth->fetchall_arrayref()->[0];
		}
	}

	# Prints all valid municipalities for the user to choose from.
	for(my $n = 0; $n < @{$munList}; $n++){
		print $munList->[$n][0] . ": " . $munList->[$n][1] . "\n";
	}

	# Gets valid municipality id choice from user:
	do{
		print "\nChoose a municipality by typing in one of the id's above: ";
		$munChoice = <STDIN>;
		chomp $munChoice;

		if((!looks_like_number($munChoice)) || ! defined $normalized[$munChoice] || $munChoice <= 0){
			print "Not a valid municipality id!\n";
		}
	}while((!looks_like_number($munChoice)) || ! defined $normalized[$munChoice] || $munChoice <= 0);

	for(my $c_id = 0; $c_id < @{$normalized[$munChoice]}; $c_id++){
		if(defined $normalized[$munChoice][$c_id]){
			$SQL = "select id, value from census_characteristics where id = '$c_id'";
			$sth = $dbh->prepare($SQL) or die "Prepare exception: $DBI::errstr!";
			$sth->execute() or die "Execute exception: $DBI::errstr";
			$charList->[@{$charList}] = $sth->fetchall_arrayref()->[0];
		}
	}

	my $innerNames = [
		'',
		'Total',
		'Male',
		'Female'
	];

	# @normalizedFilter stores only the valid census characteristics' values
	my @normalizedFilter;
	my $filterSize = 0;
	for(my $c_id = 0; $c_id < @{$normalized[$munChoice]}; $c_id++){
		if(defined $normalized[$munChoice][$c_id]){
			$normalizedFilter[$filterSize] = $normalized[$munChoice][$c_id];
			$normalizedFilter[$filterSize][4] = $c_id;	# Temporary solution to get sorted indices, other solutions don't seem to work properly. Is wasteful, duplication.
			# print "normalized[$munChoice][$c_id][1] = " . $normalized[$munChoice][$c_id][1] . "\n";
			# print "normalizedFilter[$filterSize][1] = " . $normalizedFilter[$filterSize][1] . "\n";
			# <STDIN>;
			$filterSize++;
		}
	}

	# Gets number of minimum elements from user:
	do{
		print "\nEnter the number of minimum (subvalue \"Total\") characteristic elements, between 1 and " . @normalizedFilter . ": ";
		$numMinChars = <STDIN>;
		chomp $numMinChars;

		if((!looks_like_number($numMinChars))){
			print "Not a number!\n";
		}
		elsif($numMinChars > @normalizedFilter || $numMinChars <= 0){
			print "Invalid number!\n";
		}
	}while((!looks_like_number($numMinChars)) || $numMinChars > @normalizedFilter || $numMinChars < 0);

	# Sorts @normalizedFilter by characteristic subvalue (Total) in ascending order.
	my @sorted_charValues = sort { $a->[1] <=> $b->[1] } @normalizedFilter;

	my $current_c_id;

	# Prints $numMinChars of minimum census characteristic subvalues from $sorted_charValues
	for(my $n = 0; $n < $numMinChars; $n++){
		$current_c_id = $sorted_charValues[$n]->[4];

		# Gets name for chosen census characteristic:
		$SQL = "select value from census_characteristics where id = '$current_c_id'";
		$sth = $dbh->prepare($SQL) or die "Prepare exception: $DBI::errstr!";
		$sth->execute() or die "Execute exception: $DBI::errstr";
		my $charValue = $sth->fetchall_arrayref()->[0][0];
		$charValue = trim($charValue);

		print "\nCharacteristic $current_c_id ($charValue):\n";
		for(my $inner = 1; $inner < 4; $inner++){
			print "\t$innerNames->[$inner]: $sorted_charValues[$n][$inner]\n";
		}
		# print "characteristic: $sorted_charValues[$n]->[4], sorted_charValues[$n] = " . $sorted_charValues[$n]->[1] . "\n";
	}

	# Gets number of maximum elements from user:
	do{
		print "\n\nEnter the number of maximum (subvalue \"Total\") characteristic elements, between 1 and " . @normalizedFilter . ": ";
		$numMaxChars = <STDIN>;
		chomp $numMaxChars;

		if((!looks_like_number($numMaxChars))){
			print "Not a number!\n";
		}
		elsif($numMaxChars > @normalizedFilter || $numMaxChars <= 0){
			print "Invalid number!\n";
		}
	}while((!looks_like_number($numMaxChars)) || $numMaxChars > @normalizedFilter || $numMaxChars < 0);

	# Prints $numMaxChars of maximum census characteristic subvalues from $sorted_charValues
	for(my $n = @sorted_charValues - 1; $n > @sorted_charValues - $numMaxChars - 1; $n--){
		$current_c_id = $sorted_charValues[$n]->[4];

		# Gets name for chosen census characteristic:
		$SQL = "select value from census_characteristics where id = '$current_c_id'";
		$sth = $dbh->prepare($SQL) or die "Prepare exception: $DBI::errstr!";
		$sth->execute() or die "Execute exception: $DBI::errstr";
		my $charValue = $sth->fetchall_arrayref()->[0][0];
		$charValue = trim($charValue);

		print "\nCharacteristic $current_c_id ($charValue):\n";
		for(my $inner = 1; $inner < 4; $inner++){
			print "\t$innerNames->[$inner]: $sorted_charValues[$n][$inner]\n";
		}
	}
}

# Trims whitespace on either side of a given string.
sub trim {
	my $s = shift;
	$s =~ s/^\s+|\s+$//g;
	return $s;
}

sub pairAnalysis{
	my ($pairList, $numPairs, $pairListIdx, $refOutput) = @_;
	# my @pairList = @$refPairList;
	# my $output = @$refOutput;

	my $xt = $pairList->[$pairListIdx][0];
	my $xfield = $pairList->[$pairListIdx][1];

	my $yt = $pairList->[$pairListIdx][2];
	my $yfield = $pairList->[$pairListIdx][3];

	printf "\n(%d/%d) pairAnalysis of %s.%s & %s.%s\n", $pairListIdx, $numPairs, $xt, $xfield, $yt, $yfield;

	my $xt_yt_same = ($xt eq $yt);

	my $foreignArr;
	my $foreignArrNames;

	my $foreign_xtTableIdx;
	my $foreign_xtColIdx;
	my $foreign_ytTableIdx;
	my $foreign_ytColIdx;

	if(!$xt_yt_same){
		$SQL = "SELECT DISTINCT tc.table_schema, tc.constraint_name, tc.table_name, kcu.column_name, ccu.table_name
		AS foreign_table_name, ccu.column_name AS foreign_column_name
		FROM information_schema.table_constraints tc
		JOIN information_schema.key_column_usage kcu ON tc.constraint_name = kcu.constraint_name
		JOIN information_schema.constraint_column_usage ccu ON ccu.constraint_name = tc.constraint_name
		WHERE constraint_type = 'FOREIGN KEY'
		AND (ccu.table_name='$xt' OR ccu.table_name='$yt') AND (tc.table_name='$xt' OR tc.table_name='$yt')";
		
		$sth = $dbh->prepare($SQL) or die "Prepare exception: $DBI::errstr!";
		$sth->execute() or die "Execute exception: $DBI::errstr";

		$foreignArr = $sth->fetchall_arrayref();
		$foreignArrNames = $sth->{NAME};

		$foreign_xtTableIdx = firstidx { $_ eq 'table_name' } @$foreignArrNames;
		$foreign_xtColIdx = firstidx { $_ eq 'column_name' } @$foreignArrNames;
		$foreign_ytTableIdx = firstidx { $_ eq 'foreign_table_name' } @$foreignArrNames;
		$foreign_ytColIdx = firstidx { $_ eq 'foreign_column_name' } @$foreignArrNames;
	}

	# Gets field names of table $xt
	$SQL = "Select * from $xt where false";
	$sth = $dbh->prepare($SQL) or die "Prepare exception: $DBI::errstr!";
	$sth->execute() or die "Execute exception: $DBI::errstr";
	my $xtNames = $sth->{NAME};
	$sth->finish();

	my $xt_yearIdx = firstidx { $_ eq 'year' } @$xtNames;

	# Gets field names of table $yt
	$SQL = "Select * from $yt where false";
	$sth = $dbh->prepare($SQL) or die "Prepare exception: $DBI::errstr!";
	$sth->execute() or die "Execute exception: $DBI::errstr";
	my $ytNames = $sth->{NAME};
	$sth->finish();

	my $yt_yearIdx = firstidx { $_ eq 'year' } @$ytNames;

	# Obtains array reference to $xt fields
	if($xt_yt_same){
		# Is year field
		if(!($validYears eq '') && $xt_yearIdx != -1){
			$SQL = "SELECT CAST($xfield as decimal(10,2)) as x_$xfield,"
			. " $xt.year as x_year,"
			. " $xt.id as x_id, CAST($yfield as decimal(10,2)) FROM $xt";
		}
		# No year field
		else{		
			$SQL = "SELECT CAST($xfield as decimal(10,2)) as x_$xfield,"
			#. " $xt.year as x_year,"
			. " $xt.id as x_id, CAST($yfield as decimal(10,2)) FROM $xt";
		}
	}
	# Obtains array reference to join of $xt and $yt
	else{
		if(@$foreignArr != 1){
			print "ERROR: NO DIRECT KEY RELATIONSHIP BETWEEN $xt AND $yt\n";
			errorOutput($xt, $xfield, $yt, $yfield, $pairListIdx, \@output);
			return;
		}
		else{
			# for(my $n = 0; $n < @$foreignArrNames; $n++){
			# 	print $foreignArrNames->[$n] . "\n";
			# }
			# print "\n";

			# print "Number of rows: " . @$foreignArr . "\n";

			# for(my $n = 0; defined $foreignArr->[0] && $n < @{$foreignArr->[0]}; $n++){
			# 	print $foreignArr->[0][$n] . "\n";
			# }
			# print "\n";

			# for(my $n = 0; $n < @$foreignArr; $n++){
			# 	print $foreignArr->[$n][1] . "\n";
			# }
			# print "\n";

			# print "\nforeign_xtTableIdx = $foreign_xtTableIdx, $foreignArr->[0][$foreign_xtTableIdx]\n";
			# print "foreign_xtColIdx = $foreign_xtColIdx, $xt.$foreignArr->[0][$foreign_xtColIdx]\n";
			# print "foreign_ytTableIdx = $foreign_ytTableIdx, $foreignArr->[0][$foreign_ytTableIdx]\n";
			# print "foreign_ytColIdx = $foreign_ytColIdx, $yt.$foreignArr->[0][$foreign_ytColIdx]\n\n";

			my $startSQL = "select cast($xfield as decimal(10,2)) as x_$xfield";
			my $joinSQL;

			# if foreign key from $xt:
			if($xt eq $foreignArr->[0][$foreign_xtTableIdx]){
				$joinSQL = " inner join $yt on $xt.$foreignArr->[0][$foreign_xtColIdx] = $yt.$foreignArr->[0][$foreign_ytColIdx]";
			}
			# if foreign key from $yt:
			else{
				$joinSQL = " inner join $yt on $yt.$foreignArr->[0][$foreign_xtColIdx] = $xt.$foreignArr->[0][$foreign_ytColIdx]";
			}

			# Both tables $xt and $yt have year fields
			# Will match years as well
			if(!($validYears eq '') && $xt_yearIdx != -1 && $yt_yearIdx != -1){
				print "Both have year\n";
				$SQL = $startSQL
					. " ,$xt.year as x_year"
					. " ,$yt.year as y_year"
					. " ,$xt.id as x_id"
					. " ,$yt.id as y_id"
					. " ,CAST($yfield as decimal(10,2))"
					#. " ,$yt.*"
					. " FROM $xt"
					. $joinSQL
					. " where $xt.year = $yt.year and '$validYears' like '%' || $xt.year || '%'";
			}
			# Only table $xt has year field
			elsif(!($validYears eq '') && $xt_yearIdx != -1){
				print "$xt has year\n";
				$SQL = $startSQL
					. " ,$xt.year as x_year"
					. " ,$xt.id as x_id"
					. " ,$yt.id as y_id"
					. " ,CAST($yfield as decimal(10,2))"
					#. " ,$yt.*"
					. " FROM $xt"
					. $joinSQL
					. " where '$validYears' like '%' || $xt.year || '%'";
			}
			# Only table $yt has year field
			elsif(!($validYears eq '') && $yt_yearIdx != -1){
				print "$yt has year\n";
				$SQL = $startSQL
					. " ,$yt.year as y_year"
					. " ,$xt.id as x_id"
					. " ,$yt.id as y_id"
					. " ,CAST($yfield as decimal(10,2))"
					#. " ,$yt.*"
					. " FROM $xt"
					. $joinSQL
					. " where '$validYears' like '%' || $yt.year || '%'";
			}
			# Neither tables $xt or $yt have year fields
			else{
				if(!($validYears eq '')){
					print "Neither has year\n";
				}
				$SQL = $startSQL
					. " ,$xt.id as x_id"
					. " ,$yt.id as y_id"
					. " ,CAST($yfield as decimal(10,2))"
					. " from $xt"
					# . " $yt.* FROM $xt"
					. $joinSQL;
			}
			# print "\nSQL: $SQL\n\n";
		}
	}

	$sth = $dbh->prepare($SQL) or die "Prepare exception: $DBI::errstr!";
	$sth->execute() or die "Execute exception: $DBI::errstr";
	my @res = @{$sth->fetchall_arrayref()};
	my $resNames = $sth->{NAME};

	# for(my $n = 0; $n < @$resNames; $n++){
	# 	print $resNames->[$n] . "\n";
	# }

	my $resRows = @res;



	# print "rows = $resRows\n";
	my $resCols = @{$res[0]};
	# print "cols = $resCols\n";
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
		if (#$res->[$n][$res_xtYearIdx] == $validYears &&
		defined $res[$n][$res_ytIDIdx]
		&& defined $res[$n][$res_xfieldIdx]
		&& defined $res[$n][$res_yfieldIdx]){# && $res->[$n][$res_xfieldIdx] > 0 && $res->[$n][$res_yfieldIdx] > 0){
			$resValidTuples[$n] = 1;
			$resNumValidTuples++;
			#print "Defined\n";
		}
		else{
			#print "Undefined.\n";
			$resValidTuples[$n] = 0;
		}
	}

	if($resNumValidTuples == 0){
		print "ERROR: NO VALID TUPLES\n";
		errorOutput($xt, $xfield, $yt, $yfield, $pairListIdx, \@output);
		return;
	}

	my @xfieldArr;
	my @yfieldArr;

	for (my $n = 0; $n < $resRows; $n++){
		if($resValidTuples[$n]){
			$xfieldArr[$n] = $res[$n][$res_xfieldIdx];
			$yfieldArr[$n] = $res[$n][$res_yfieldIdx];
		}
	}

	# print "resRows: $resRows\n";
	# print "xt: $xt\n";
	# print "xfield: $xfield\n";
	# print "yt: $yt\n";
	# print "yfield: $yfield\n";
	# <STDIN>;

	computePairAvgSD($xt, $xfield, $yt, $yfield,
			$resRows,
			\@xfieldArr, \@yfieldArr,
			\@resValidTuples, $resNumValidTuples,
			$pairListIdx, \@output);

	computePCC($resRows,
			\@xfieldArr, \@yfieldArr,
			\@resValidTuples, $resNumValidTuples,
			$pairListIdx, \@output);

	my @results;

	computeSpearmanRCC(\@xfieldArr, \@yfieldArr,
			\@results,
			\@resValidTuples, $resNumValidTuples,
			$pairListIdx, \@output);
}

# Computes averages and Standard Deviation of a pair of value-sets, appends values to output array.
sub computePairAvgSD{
	my ($xt, $xfield, $yt, $yfield,
		$resRows,
		$xfieldArr, $yfieldArr,
		$resValidTuples, $resNumValidTuples,
		$pairListIdx, $output) = @_;

	computeSingleAvgSD($xt, $xfield,
		$resRows, $xfieldArr,
		$resValidTuples, $resNumValidTuples,
		$pairListIdx, $output);

	computeSingleAvgSD($yt, $yfield,
		$resRows, $yfieldArr,
		$resValidTuples, $resNumValidTuples,
		$pairListIdx, $output);
}

# Computes average and Standard Deviation of single value set.
sub computeSingleAvgSD{
	my ($table,
		$field,
		$resRows,
		$fieldArr,
		$resValidTuples,
		$resNumValidTuples,
		$listIdx,
		$givenOutput) = @_;

	# print "resRows: $resRows\nresNumValidTuples: $resNumValidTuples\nlistIdx: $listIdx\n";

	my $sum = 0;
	my $avg = 0;
	my $SD = 0;

	# Sums $xfield and appropriate $yfield values for later averaging
	for (my $n = 0; $n < $resRows; $n++){
		if($resValidTuples->[$n]){
			# print "n: $n\n";
			$sum += $fieldArr->[$n];
			# print "\t\$sum = $sum\n";
		}
		# <STDIN>;
	}

	$avg = $sum/$resNumValidTuples;

	for (my $n = 0; $n < $resRows; $n++){
		if($resValidTuples->[$n]){
			# print "n: $n\n";
			$SD += ($fieldArr->[$n]-$avg)**2;
			# print "\t\$SD = $SD\n";
		}
		# <STDIN>;
	}

	$SD /= $resNumValidTuples;
	$SD = sqrt($SD);


	my $outputElemIdx;
	if(defined $givenOutput->[$listIdx]){
		$outputElemIdx = @{$givenOutput->[$listIdx]};
	}
	else{
		$outputElemIdx = 0;
	} 

	# Descriptors for each output value
	$givenOutput->[$listIdx][$outputElemIdx][0] = $table . "." . $field . '_Avg';
	$givenOutput->[$listIdx][$outputElemIdx+1][0] = $table . "." . $field . '_SD';

	# Actual output values
	$givenOutput->[$listIdx][$outputElemIdx][1] = $avg;
	$givenOutput->[$listIdx][$outputElemIdx+1][1] = $SD;

	# print "avg: $avg, SD: $SD\n";
}

# Computes Pearson Correlation Coefficient of value-set pair, appends values to output array.
sub computePCC{
	my ($resRows,
		$xfieldArr, $yfieldArr,
		$resValidTuples, $resNumValidTuples,
		$pairListIdx, $givenOutput) = @_;

	# my $resRows = @$res;

	my $xfieldAvg = $givenOutput->[$pairListIdx][0][1];
	my $xfieldSD = $givenOutput->[$pairListIdx][1][1];

	my $yfieldAvg = $givenOutput->[$pairListIdx][2][1];
	my $yfieldSD = $givenOutput->[$pairListIdx][3][1];

	# print "\n\$xfieldAvg: $xfieldAvg\n\$xfieldSD: $xfieldSD\n\$yfieldAvg: $yfieldAvg\n\$yfieldSD: $yfieldSD\n";
	# print "xfieldSize: " . @{$xfieldArr} . "\n";
	# print "yfieldSize: " . @{$yfieldArr} . "\n";
	# <STDIN>;

	# Computation of Pearson's Correlation Coefficient
	my $PCC;
	my $PCCsum = 0;
	my $x;
	my $y;
	for (my $n = 0; $n < $resRows; $n++){
		if($resValidTuples->[$n]){
			if($xfieldSD != 0 && $yfieldSD != 0){
				$x = $xfieldArr->[$n];
				$y = $yfieldArr->[$n];
				# print "\$n: $n\, \$x: $x, \$y: $y\n";
				# <STDIN>;

				$PCC = (($xfieldArr->[$n]-$xfieldAvg)*($yfieldArr->[$n]-$yfieldAvg))/($xfieldSD*$yfieldSD);
				$PCCsum += $PCC;
			}
		}
	}
	my $PCCavg = $PCCsum/$resNumValidTuples;

	# print "Number valid tuples: $resNumValidTuples\n";

	my $outputElemIdx;
	if(defined $givenOutput->[$pairListIdx]){
		$outputElemIdx = @{$givenOutput->[$pairListIdx]};
	}
	else{
		$outputElemIdx = 0;
	} 

	# Descriptors for each output value
	$givenOutput->[$pairListIdx][$outputElemIdx][0] = 'PCC_Avg';

	# Actual output values
	$givenOutput->[$pairListIdx][$outputElemIdx][1] = $PCCavg;
}

# Computes Spearman Rank Correlation Coefficient of value-set pair, appends value to output array.
sub computeSpearmanRCC{
	my ($xfieldArr, $yfieldArr,
		$results,
		$resValidTuples, $resNumValidTuples,
		$pairListIdx, $output) = @_;

	# Each heap is a max heap, with the largest element on top
	my $xheap = Heap::Simple->new(elements => "Array", order => ">");
	my $yheap = Heap::Simple->new(elements => "Array", order => ">");

	my $size = @$xfieldArr;
	# print "size: $size\n";

	my $xAvgRank = $size/2;
	my $yAvgRank = $size/2;


	for(my $n = 0; $n < $size; $n++){
		if($resValidTuples->[$n]){
			$xheap->insert([$xfieldArr->[$n], $n]);
			$yheap->insert([$yfieldArr->[$n], $n]);
		}
	}
	for(my $rank = 0; $rank < $resNumValidTuples; $rank++){
		my $xelem = $xheap->extract_top;
		push (@$xelem, $rank);
		my $yelem = $yheap->extract_top;
		push (@$yelem, $rank);
		# print "$xelem->[1],\t$yelem->[1]\t\t$xelem->[0]\t $yelem->[0]\n";

		$results->[$xelem->[1]][0] = [$xelem->[0], $rank];
		$results->[$yelem->[1]][1] = [$yelem->[0], $rank];
	}

	# for(my $n = 0; $n < $resNumValidTuples; $n++){
		# print "$results->[$n][0][0], $results->[$n][0][1]\t$results->[$n][1][0], $results->[$n][1][1]\n";
	# }

	my $covariance = 0;
	my $xrankSD = 0;
	my $yrankSD = 0;

	# Computation of Standard Deviations of both $xfield and appropriate $yfield
	for (my $n = 0; $n < $resNumValidTuples; $n++){
		if($resValidTuples->[$n]){
			# print "$n\n";
			$covariance += (($results->[$n][0][1]-$xAvgRank)*($results->[$n][1][1]-$yAvgRank));
			$xrankSD += ($results->[$n][0][1]-$xAvgRank)**2;
			$yrankSD += ($results->[$n][1][1]-$yAvgRank)**2;
		}
	}
	$covariance /= $resNumValidTuples;

	$xrankSD /= $resNumValidTuples;
	$xrankSD = sqrt($xrankSD);

	$yrankSD /= $resNumValidTuples;
	$yrankSD = sqrt($yrankSD);

	my $RCC = $covariance/($xrankSD*$yrankSD);

	my $outputElemIdx;
	if(defined $output[$pairListIdx]){
		$outputElemIdx = @{$output[$pairListIdx]};
	}
	else{
		$outputElemIdx = 0;
	} 

	if ($outputElemIdx == 0){
		print "ERROR (computeSpearmanRCC): outputElemIdx == 0, does not see other output values\n";
		<STDIN>;
	}

	# Appending RCC value to output array
	$output[$pairListIdx][$outputElemIdx][0] = "SpearmanRCC";
	$output[$pairListIdx][$outputElemIdx][1] = $RCC;
}

# Stores values that are interpreted as invalid.
sub errorOutput{
	my ($xt, $xfield, $yt, $yfield, $pairListIdx, $givenOutput) = @_;
	# my $output = @$givenOutput;

	$givenOutput->[$pairListIdx][0][0] = $xt . "." . $xfield . '_Avg';
	$givenOutput->[$pairListIdx][1][0] = $xt . "." . $xfield . '_SD';
	$givenOutput->[$pairListIdx][2][0] = $yt . "." . $yfield . '_Avg';
	$givenOutput->[$pairListIdx][3][0] = $yt . "." . $yfield . '_SD';
	$givenOutput->[$pairListIdx][4][0] = 'PCC_Avg';
	$givenOutput->[$pairListIdx][5][0] = 'RCC';

	$givenOutput->[$pairListIdx][0][1] = -2;
	$givenOutput->[$pairListIdx][1][1] = -2;
	$givenOutput->[$pairListIdx][2][1] = -2;
	$givenOutput->[$pairListIdx][3][1] = -2;
	$givenOutput->[$pairListIdx][4][1] = 0;
	$givenOutput->[$pairListIdx][5][1] = 0;
}

sub censusMunComputePairPCC{
	my (
		$censusMunVals,
		# $m_id,
		$char_id,
		$censusMunValidList,
		$censusMunSizeList,
		# $numValid,
		$pairListIdx,
		$givenOutput) = @_;

	# my $munField

	# @currentArr = [
	# 	$currentRow->[$m_popIdx],
	# 	$currentRow->[$totalIdx],
	# 	$currentRow->[$maleIdx],
	# 	$currentRow->[$femaleIdx]
	# ];

	# push @{$censusMunVals
	# 	[$current_m_id]
	# 	[$current_char_id]},
	# 	@currentArr;

	my $munAvg = 0;
	my $munSD = 0;

	my $censusAvgsArr;
	my $SDarr;

	my $censusMunNumValid = 0;

	# print "char_id: $char_id\n";
	# <STDIN>;	

	# Does not take into account any census entries other than the first for each mun for each characteristic,
	# as there really shouldn't be more than one. More than one means that the same census row was entered more than once,
	# being either the same values (Total, Male, Female) or different ones.
	for(my $innerVal = 1; $innerVal < 4; $innerVal++){
		# print "1innerVal: $innerVal\n";
		for(my $m_id = 1; $m_id < @{$censusMunVals}; $m_id++){
			# print "\t1m_id: $m_id\n";
			if($censusMunValidList->[$m_id] && defined $censusMunVals->[$m_id][$char_id]){
				$censusAvgsArr->[$innerVal] += $censusMunVals->[$m_id][$char_id][0][$innerVal];
				$censusMunNumValid++;
			}
		}
	}



	for(my $innerVal = 1; $innerVal < 4; $innerVal++){
		# print "2innerVal: $innerVal\n";
		$censusAvgsArr->[$innerVal] /= $censusMunNumValid;
		print "censusAvgsArr->[$innerVal]: $censusAvgsArr->[$innerVal]\n";
		# <STDIN>;
		for(my $m_id = 1; $m_id < @{$censusMunVals}; $m_id++){
			# print "\t2m_id: $m_id\n";
			if($censusMunValidList->[$m_id] && defined $censusMunVals->[$m_id][$char_id]){
				$SDarr->[$innerVal] += ($censusMunVals->[$m_id][$char_id][0][$innerVal]
					- $censusAvgsArr->[$innerVal])**2;
			}
		}
		$SDarr->[$innerVal] /= $censusMunNumValid;
		$SDarr->[$innerVal] = sqrt($SDarr->[$innerVal]);
		print "SDarr->[$innerVal] = $SDarr->[$innerVal]\n";
	}

	for(my $m_id = 1; $m_id < @{$censusMunVals}; $m_id++){
		if($censusMunValidList->[$m_id]){
			$munAvg += $censusMunVals->[$m_id][$char_id][0][0];
		}
	}

	$munAvg /= $censusMunNumValid;
	print "munAvg: $munAvg\n";

	for(my $m_id = 1; $m_id < @{$censusMunVals}; $m_id++){
		if($censusMunValidList->[$m_id] && defined $censusMunVals->[$m_id][$char_id]){
			$munSD += ($censusMunVals->[$m_id][$char_id][0][0] - $munAvg)**2;
			# print "pop of mun $m_id: $censusMunVals->[$m_id][$char_id][0][0]\n";
			# print "Additional SD: " . ($censusMunVals->[$m_id][$char_id][0][0] - $munAvg)**2 . "\n";
			# print "munSD = $munSD\n";
			# <STDIN>;
		}
	}

	$munSD /= $censusMunNumValid;
	$munSD = sqrt($munSD);
	print "munSD: $munSD\n";

	my $PCC;
	my $PCCarr;
	my $PCCsum;
	
	for(my $innerVal = 1; $innerVal < 4; $innerVal++){
		$PCCsum = 0;
		for(my $m_id = 1; $m_id < @{$censusMunVals}; $m_id++){
			if($censusMunValidList->[$m_id] && defined $censusMunVals->[$m_id][$char_id]){
				# print "Valid m_id: $m_id\n";
				my $p11 = $censusMunVals->[$m_id][$char_id][0][$innerVal];
				my $p12 = $censusAvgsArr->[$innerVal];

				my $p21 = $censusMunVals->[$m_id][$char_id][0][0];
				my $p22 = $munAvg;

				my $p3 = ($munSD * $SDarr->[$innerVal]);

				$PCC = (($censusMunVals->[$m_id][$char_id][0][$innerVal]
					- $censusAvgsArr->[$innerVal])
					* ($censusMunVals->[$m_id][$char_id][0][0] - $munAvg)) /
					  ($munSD * $SDarr->[$innerVal]);

				$PCCarr->[$innerVal] += $PCC;
				# print "PCCsum: $PCCsum\n\n";
			}
		}
		$PCCarr->[$innerVal] /= $censusMunNumValid;
		print "PCCarr->[$innerVal] = $PCCarr->[$innerVal]\n";
		# <STDIN>;
	}
}

# Authorize the GET method.
sub isAuth{
	my ($self, $method, $req) = @_;
    return $method eq 'GET';
}