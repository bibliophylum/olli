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
	
	V16 (2017.07.27):
		- 'listSpecificNormalizedValues' sub improved to allow the user to specify multiple census characteristic ids for a chosen municipality.

	V17 (2017.07.27):
		- 'findMutuallyValidChars' sub allows the user to choose multiple valid municipalities, then finds all census characteristics that are valid across all chosen municipalities.
			- This sub will eventually replace the first portion of 'listSpecificNormalizedValues' sub.

	V18 (2017.07.28):
		- 'listSpecificNormalizedValues' sub now uses 'findMutuallyValidChars' sub to gather one or more valid municipalities from the user, then allows the user to choose one or more census characteristics that are valid for all chosen municipalities.
		- 'normalizeCensusValues2' sub replaced 'normalizeCensusValues' sub.

	V19 (2017.07.28):
		- 'listSpecificNormalizedValues' sub now takes parameters (characteristics array, municipalities array), checks if everything is valid, then prints out the results without asking for input.
			- Future versions will instead return some standardized form of the output.
		- Rid 'normalized' array from 'normalizeCensusValues' sub reallocation/duplication across all subs.

	V20 (2017.07.28):
		- 'listSpecificNormalizedValues' sub now takes a boolean value as 1st parameter, determines whether the results will be printed to the screen.
		- 'listSpecificNormalizedValues' sub now returns output in standardized structure, specified within the sub.

	V21 (2017.07.28):
		- Census characteristic id check error fixed in 'listSpecificNormalizedValues' sub.
		- 'munCensusSorting' sub now allows census entries that have a "Total" subvalue of 0.
		- 'censusMun' sub deleted.
		- Odd behaviour with municipality id 2, where every census characteristic is seen as valid, even though they are not. This municipality shouldn't even get through munCensusSorting, as its year is 2014.
			- Possible issue with initial $SQL in 'munCensusSorting' sub not joining mun_cen and municipalities correctly.
			- Instead of 2 (2014 year), the 2011 municipality has an id of 458.
			- Even if those municipalities are blocked altogether, 'findMutuallyValidChars' sub still sees municipality id 2 to be valid (through inspection of the array 'normalized'). Although, the sub 'normalizeCensusValues' that passes the array 'normalized' to 'findMutuallyValidChars' sub doesn't see municipality id 2 to be valid. It seems to be the only value that does this, oddly enough, everything else is fine.
			- For now, this municipality is manually invalidated in 'findMutuallyValidChars', but it may be a symptom of a larger issue.
		- Minor cleansing all around.

	V22 (2017.07.31):
		- 'findMutuallyValidChars' sub modified to allow passed municipality ids param.
			- Checks if each id is valid. If so, continues, else asks for manual entry of valid municipalities.
			- 1st param to 'findMutuallyValidChars' sub determines whether any results are printed to screen.

	V23 (2017.08.01):
		- 'findSimilarValueChars' sub finds all characteristic subValues for a given municipality that are within +- a given tolerance of another given characteristic subvalue of that municipality.
			- 'listSimilarValueChars' sub lists the results of 'findSimilarValueChars' sub.

	V24 (2017.08.02):
		- All subs related to census data moved to censusCorrelate.pm

	V25 (2017.08.08):
		- Old/useless code removed.

=end comment
=cut

package Olli::REST::API::pairAnalysis;
use warnings;
use strict;
use base qw/Apache2::REST::Handler/;
use DBI;
use List::MoreUtils qw(firstidx);
use Heap::Simple;
use Scalar::Util qw(looks_like_number);
use CGI;


my $SQL;
my $sth;
my $dbh;

my @output;
my @validOutput;
my $numValidOutput;

my $database = "olli";
my $dsn = "dbi:Pg:database=$database;host=localhost;port=5432";
my $userid = "olli";
my $password = "olli";

# Filter on the year of $xt's tuples (filtering is by substring, you may include any year however you want.)
# Example: $validYears = '2013_,asdf20142015' would give valid records from 2013 through 2015.
# If $validYears = '', there is no filtering by year.
my $validYears = '2015';

# Names of census characteristic subvalues. The first value is a spacer, may be used for the municipality's population.
my $innerNames = [
	'',
	'Total',
	'Male',
	'Female'
];

sub dbPrepare{
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
	my $chosenOutput = allPairs();
	$response->data()->{'rawOutput'} = $chosenOutput;
	$dbh->disconnect;
	return Apache2::Const::HTTP_OK ;
}

sub allPairs{
	my @pairList;

	$SQL = "select table_name from information_schema.tables where table_schema = 'public' and table_catalog = 'olli'"
		. " and table_name not like 'contact'"
		. " and table_name not like 'mun_geo'"
		. " and table_name not like 'mun_cen'"
		. " and table_name not like 'technology'"
		;
	$sth = $dbh->prepare($SQL) or die "Prepare exception: $DBI::errstr!";
	$sth->execute() or die "Execute exception: $DBI::errstr";
	my $dbTables = $sth->fetchall_arrayref();
	
	my @dbStructure;

	for(my $n = 0; $n < @$dbTables; $n++){
		$dbStructure[$n][0] = $dbTables->[$n][0];
		
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
				$dbStructure[$n][1][$dbStructure_mIndex] = $data->[$m][0];
				$dbStructure_mIndex++;
			}
		}
	}

	# Pair up all useful columns
	my $numTables = @dbStructure;
	
	my $pairIdx = 0;
	my $numPairs = 0;
	for(my $n = 0; $n < $numTables; $n++){
		for(my $m = 0; defined $dbStructure[$n][1] && $m < @{$dbStructure[$n][1]}; $m++){
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
			}

			# Pairs each column with each column not in the same table, no duplication
			for(my $n2 = $n + 1; $n2 < $numTables; $n2++){

				for(my $m2 = $m + 1; defined $dbStructure[$n2][1] &&  $m2 < @{$dbStructure[$n2][1]}; $m2++){
					$pairList[$pairIdx++] = 
						[
							$dbStructure[$n][0],
							$dbStructure[$n][1][$m],
							$dbStructure[$n2][0],
							$dbStructure[$n2][1][$m2]
						];
					$numPairs++;
				}
			}
		}
	}

	my $validPairList;

	$numValidOutput = 0;
	for(my $iter = 0; $iter < @pairList; $iter++){
		pairAnalysis(\@pairList, $numPairs, $iter, \@output);

		if($output[$iter][0][1] != -2){
			$validOutput[$numValidOutput][@{$output[$iter]}+1][0] = $iter;
			$validPairList->[@{$validPairList}] = $pairList[$iter];
			for(my $i = 0; $i < @{$output[$iter]}; $i++){
				# print "output[$i] = " . $output[$iter][$i][1] . "\n";
				# printf "%s: %.3f\n", $output[$iter][$i][0], $output[$iter][$i][1];
				$validOutput[$numValidOutput][$i][0] = $output[$iter][$i][0];
				$validOutput[$numValidOutput][$i][1] = $output[$iter][$i][1];
			}
			$numValidOutput++;
		}
	}

	# print "\n\nALL VALID OUTPUT:\n\n";
	my @origPair;

	for(my $valiter = 0; $valiter < $numValidOutput; $valiter++){
		@origPair = @{$pairList[$validOutput[$valiter][@{$output[0]}+1][0]]};
		# print $origPair[0] . "." . $origPair[1] . " &\n" . $origPair[2] . "." . $origPair[3] . "\n";
		for(my $i = 0; $i < @{$output[$validOutput[$valiter][@{$output[0]}+1][0]]}; $i++){
			# print "output[$i] = " . $output[$iter][$i][1] . "\n";
			# printf "\t%s: %.3f\n", $validOutput[$valiter][$i][0], $validOutput[$valiter][$i][1];
		}
		# print "\n";
	}

	# print "Number valid output pairs: $numValidOutput\n";
	return [$validPairList, \@validOutput];
}

# Calculates average municipality population, given a list of municipality populations.
sub calculateAvgMunPops{
	my $censusMunVals = @_;

	my $SQL = "select id, population from municipalities";
	$sth = $dbh->prepare($SQL) or die "Prepare exception: $DBI::errstr!";
	$sth->execute() or die "Execute exception: $DBI::errstr";
	my $munTable = $sth->fetchall_arrayref();

	my $sum = 0;
	my $numMuns = 0;
	my $max = 0;

	for(my $row = 0; $row < @{$munTable}; $row++){
		if(defined $censusMunVals->[$munTable->[$row][0]]){
			if($censusMunVals->[$munTable->[$row][0]] > $max){
				$max = $censusMunVals->[$munTable->[$row][0]];
			}
			$sum += $munTable->[$row][1];
			$numMuns++;
		}
	}
	my $avg = $sum/$numMuns;
	# print "NUM_MUN: $numMuns, AVG_POP: $avg\n";
	return [$avg, $max];
}

# Takes an array and element, returns whether the element is present within the array.
sub checkArrForElem{
	my ($arr, $elem) = @_;
	for(my $n = 0; $n < @{$arr}; $n++){
		if($arr->[$n] eq $elem){
			return 1; # elem found in arr
		}
	}
	return 0; # elem not found in arr
}

# Trims whitespace on either side of a given string.
sub trim {
	my $s = shift;
	$s =~ s/^\s+|\s+$//g;
	return $s;
}

sub pairAnalysis{
	my ($pairList, $numPairs, $pairListIdx, $refOutput) = @_;

	my $xt = $pairList->[$pairListIdx][0];
	my $xfield = $pairList->[$pairListIdx][1];

	my $yt = $pairList->[$pairListIdx][2];
	my $yfield = $pairList->[$pairListIdx][3];

	# printf "\n(%d/%d) pairAnalysis of %s.%s & %s.%s\n", $pairListIdx, $numPairs, $xt, $xfield, $yt, $yfield;

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
			. " $xt.id as x_id, CAST($yfield as decimal(10,2)) FROM $xt";
		}
	}
	# Obtains array reference to join of $xt and $yt
	else{
		if(@$foreignArr != 1){
			# print "ERROR: NO DIRECT KEY RELATIONSHIP BETWEEN $xt AND $yt\n";
			errorOutput($xt, $xfield, $yt, $yfield, $pairListIdx, \@output);
			return;
		}
		else{
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
				# print "Both have year\n";
				$SQL = $startSQL
					. " ,$xt.year as x_year"
					. " ,$yt.year as y_year"
					. " ,$xt.id as x_id"
					. " ,$yt.id as y_id"
					. " ,CAST($yfield as decimal(10,2))"
					. " FROM $xt"
					. $joinSQL
					. " where $xt.year = $yt.year and '$validYears' like '%' || $xt.year || '%'";
			}
			# Only table $xt has year field
			elsif(!($validYears eq '') && $xt_yearIdx != -1){
				# print "$xt has year\n";
				$SQL = $startSQL
					. " ,$xt.year as x_year"
					. " ,$xt.id as x_id"
					. " ,$yt.id as y_id"
					. " ,CAST($yfield as decimal(10,2))"
					. " FROM $xt"
					. $joinSQL
					. " where '$validYears' like '%' || $xt.year || '%'";
			}
			# Only table $yt has year field
			elsif(!($validYears eq '') && $yt_yearIdx != -1){
				# print "$yt has year\n";
				$SQL = $startSQL
					. " ,$yt.year as y_year"
					. " ,$xt.id as x_id"
					. " ,$yt.id as y_id"
					. " ,CAST($yfield as decimal(10,2))"
					. " FROM $xt"
					. $joinSQL
					. " where '$validYears' like '%' || $yt.year || '%'";
			}
			# Neither tables $xt or $yt have year fields
			else{
				if(!($validYears eq '')){
					# print "Neither has year\n";
				}
				$SQL = $startSQL
					. " ,$xt.id as x_id"
					. " ,$yt.id as y_id"
					. " ,CAST($yfield as decimal(10,2))"
					. " from $xt"
					. $joinSQL;
			}
		}
	}

	$sth = $dbh->prepare($SQL) or die "Prepare exception: $DBI::errstr!";
	$sth->execute() or die "Execute exception: $DBI::errstr";
	my @res = @{$sth->fetchall_arrayref()};
	my $resNames = $sth->{NAME};

	my $resRows = @res;
	my $resCols = @{$res[0]};

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
			&& defined $res[$n][$res_yfieldIdx]
			# && $res->[$n][$res_xfieldIdx] > 0 && $res->[$n][$res_yfieldIdx] > 0
			){
			$resValidTuples[$n] = 1;
			$resNumValidTuples++;
		}
		else{
			$resValidTuples[$n] = 0;
		}
	}

	if($resNumValidTuples == 0){
		# print "ERROR: NO VALID TUPLES\n";
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
			$sum += $fieldArr->[$n];
		}
	}

	$avg = $sum/$resNumValidTuples;

	for (my $n = 0; $n < $resRows; $n++){
		if($resValidTuples->[$n]){
			$SD += ($fieldArr->[$n]-$avg)**2;
		}
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
}

# Computes Pearson Correlation Coefficient of value-set pair, appends values to output array.
sub computePCC{
	my ($resRows,
		$xfieldArr, $yfieldArr,
		$resValidTuples, $resNumValidTuples,
		$pairListIdx, $givenOutput) = @_;

	my $xfieldAvg = $givenOutput->[$pairListIdx][0][1];
	my $xfieldSD = $givenOutput->[$pairListIdx][1][1];

	my $yfieldAvg = $givenOutput->[$pairListIdx][2][1];
	my $yfieldSD = $givenOutput->[$pairListIdx][3][1];

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
				$PCC = (($xfieldArr->[$n]-$xfieldAvg)*($yfieldArr->[$n]-$yfieldAvg))/($xfieldSD*$yfieldSD);
				$PCCsum += $PCC;
			}
		}
	}
	my $PCCavg = $PCCsum/$resNumValidTuples;

	my $outputElemIdx;
	if(defined $givenOutput->[$pairListIdx]){
		$outputElemIdx = @{$givenOutput->[$pairListIdx]};
	}
	else{
		$outputElemIdx = 0;
	} 

	# Descriptors for each output value
	$givenOutput->[$pairListIdx][$outputElemIdx][0] = 'PCC';

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

		$results->[$xelem->[1]][0] = [$xelem->[0], $rank];
		$results->[$yelem->[1]][1] = [$yelem->[0], $rank];
	}

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
		# print "ERROR (computeSpearmanRCC): outputElemIdx == 0, does not see other output values\n";
		<STDIN>;
	}

	# Appending RCC value to output array
	$output[$pairListIdx][$outputElemIdx][0] = "SpearmanRCC";
	$output[$pairListIdx][$outputElemIdx][1] = $RCC;
}

# Stores values that are interpreted as invalid.
sub errorOutput{
	my ($xt, $xfield, $yt, $yfield, $pairListIdx, $givenOutput) = @_;

	$givenOutput->[$pairListIdx][0][0] = $xt . "." . $xfield . '_Avg';
	$givenOutput->[$pairListIdx][1][0] = $xt . "." . $xfield . '_SD';
	$givenOutput->[$pairListIdx][2][0] = $yt . "." . $yfield . '_Avg';
	$givenOutput->[$pairListIdx][3][0] = $yt . "." . $yfield . '_SD';
	$givenOutput->[$pairListIdx][4][0] = 'PCC';
	$givenOutput->[$pairListIdx][5][0] = 'SpearmanRCC';

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
		$char_id,
		$censusMunValidList,
		$censusMunSizeList,
		$pairListIdx,
		$givenOutput) = @_;

	my $munAvg = 0;
	my $munSD = 0;
	my $censusAvgsArr;
	my $SDarr;
	my $censusMunNumValid = 0;

	# Does not take into account any census entries other than the first for each mun for each characteristic,
	# as there really shouldn't be more than one. More than one means that the same census row was entered more than once,
	# being either the same values (Total, Male, Female) or different ones.
	for(my $innerVal = 1; $innerVal < 4; $innerVal++){
		for(my $m_id = 1; $m_id < @{$censusMunVals}; $m_id++){
			if($censusMunValidList->[$m_id] && defined $censusMunVals->[$m_id][$char_id]){
				$censusAvgsArr->[$innerVal] += $censusMunVals->[$m_id][$char_id][$innerVal];
				$censusMunNumValid++;
			}
		}
	}

	for(my $innerVal = 1; $innerVal < 4; $innerVal++){
		$censusAvgsArr->[$innerVal] /= $censusMunNumValid;
		# print "censusAvgsArr->[$innerVal]: $censusAvgsArr->[$innerVal]\n";
		# <STDIN>;
		for(my $m_id = 1; $m_id < @{$censusMunVals}; $m_id++){
			if($censusMunValidList->[$m_id] && defined $censusMunVals->[$m_id][$char_id]){
				$SDarr->[$innerVal] += ($censusMunVals->[$m_id][$char_id][$innerVal]
					- $censusAvgsArr->[$innerVal])**2;
			}
		}
		$SDarr->[$innerVal] /= $censusMunNumValid;
		$SDarr->[$innerVal] = sqrt($SDarr->[$innerVal]);
		# print "SDarr->[$innerVal] = $SDarr->[$innerVal]\n";
	}

	for(my $m_id = 1; $m_id < @{$censusMunVals}; $m_id++){
		if($censusMunValidList->[$m_id]){
			$munAvg += $censusMunVals->[$m_id][$char_id][0];
		}
	}

	$munAvg /= $censusMunNumValid;
	# print "munAvg: $munAvg\n";

	for(my $m_id = 1; $m_id < @{$censusMunVals}; $m_id++){
		if($censusMunValidList->[$m_id] && defined $censusMunVals->[$m_id][$char_id]){
			$munSD += ($censusMunVals->[$m_id][$char_id][0] - $munAvg)**2;
		}
	}

	$munSD /= $censusMunNumValid;
	$munSD = sqrt($munSD);

	my $PCC;
	my $PCCarr;
	my $PCCsum;
	my ($p11, $p12, $p21, $p22, $p3);
	
	for(my $innerVal = 1; $innerVal < 4; $innerVal++){
		$PCCsum = 0;
		for(my $m_id = 1; $m_id < @{$censusMunVals}; $m_id++){
			if($censusMunValidList->[$m_id] && defined $censusMunVals->[$m_id][$char_id]){
				# print "Valid m_id: $m_id\n";
				$p11 = $censusMunVals->[$m_id][$char_id][$innerVal];
				$p12 = $censusAvgsArr->[$innerVal];

				$p21 = $censusMunVals->[$m_id][$char_id][0];
				$p22 = $munAvg;

				$p3 = ($munSD * $SDarr->[$innerVal]);

				$PCC = (($censusMunVals->[$m_id][$char_id][$innerVal]
					- $censusAvgsArr->[$innerVal])
					* ($censusMunVals->[$m_id][$char_id][0] - $munAvg)) /
					  ($munSD * $SDarr->[$innerVal]);

				$PCCarr->[$innerVal] += $PCC;
			}
		}
		$PCCarr->[$innerVal] /= $censusMunNumValid;
	}
}

# Authorize the GET method.
sub isAuth{
	my ($self, $method, $req) = @_;
    return $method eq 'GET';
}