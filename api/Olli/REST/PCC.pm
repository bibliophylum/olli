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
allPairs();

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
	dbPrepare;

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


	# if($xt_yt_same){
	# 	print "Same tables\n";
	# }
	# else{
	# 	print "Not same tables\n";
	# }

	# Foreign key sample from municipalities:
	#table_schema |        constraint_name        | table_name |   column_name   | foreign_table_name | foreign_column_name
	#public       | branches_municipality_id_fkey | branches   | municipality_id | municipalities     | id

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

	computeAvgSD($xt, $xfield, $yt, $yfield,
			\@res,
			$res_xtIDIdx, $res_xfieldIdx, $res_yfieldIdx,
			\@xfieldArr, \@yfieldArr,
			\@resValidTuples, $resNumValidTuples,
			$pairListIdx, \@output);

	computePCC(\@res,
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
sub computeAvgSD{
	my ($xt, $xfield, $yt, $yfield,
		$res,
		$res_xtIDIdx, $res_xfieldIdx, $res_yfieldIdx,
		$xfieldArr, $yfieldArr,
		$resValidTuples, $resNumValidTuples,
		$pairListIdx, $output) = @_;

	my $resRows = @$res;

	my $xfieldSum = 0;
	my $xfieldAvg = 0;
	my $xfieldSD = 0;

	my $yfieldSum = 0;
	my $yfieldAvg = 0;
	my $yfieldSD = 0;

	# Sums $xfield and appropriate $yfield values for later averaging
	for (my $n = 0; $n < $resRows; $n++){
		if($resValidTuples->[$n]){
			$xfieldArr->[$n] = $res->[$n][$res_xfieldIdx];
			$xfieldSum += $xfieldArr->[$n];
			
			$yfieldArr->[$n] = $res->[$n][$res_yfieldIdx];
			$yfieldSum += $yfieldArr->[$n];

			#print "x_id: $res->[$n][$res_xtIDIdx],\t$xfield: $xfieldArr[$n],\t$yfield: $yfieldArr[$n]\n";
		}
	}

	$xfieldAvg = $xfieldSum/$resNumValidTuples;
	$yfieldAvg = $yfieldSum/$resNumValidTuples;

	# Computation of Standard Deviations of both $xfield and appropriate $yfield
	for (my $n = 0; $n < $resRows; $n++){
		if($resValidTuples->[$n]){
			# print "$n\n";
			$xfieldSD += ($xfieldArr->[$n]-$xfieldAvg)**2;
			$yfieldSD += ($yfieldArr->[$n]-$yfieldAvg)**2;
		}
	}

	$xfieldSD /= $resNumValidTuples;
	$xfieldSD = sqrt($xfieldSD);

	$yfieldSD /= $resNumValidTuples;
	$yfieldSD = sqrt($yfieldSD);

	my $outputElemIdx;
	if(defined $output[$pairListIdx]){
		$outputElemIdx = @{$output[$pairListIdx]};
	}
	else{
		$outputElemIdx = 0;
	} 

	# Descriptors for each output value
	$output[$pairListIdx][$outputElemIdx][0] = $xt . "." . $xfield . '_Avg';
	$output[$pairListIdx][$outputElemIdx+1][0] = $xt . "." . $xfield . '_SD';
	$output[$pairListIdx][$outputElemIdx+2][0] = $yt . "." . $yfield . '_Avg';
	$output[$pairListIdx][$outputElemIdx+3][0] = $yt . "." . $yfield . '_SD';

	# Actual output values
	$output[$pairListIdx][$outputElemIdx][1] = $xfieldAvg;
	$output[$pairListIdx][$outputElemIdx+1][1] = $xfieldSD;
	$output[$pairListIdx][$outputElemIdx+2][1] = $yfieldAvg;
	$output[$pairListIdx][$outputElemIdx+3][1] = $yfieldSD;
}

# Computes Pearson Correlation Coefficient of value-set pair, appends values to output array.
sub computePCC{
	my ($res,
		$xfieldArr, $yfieldArr,
		$resValidTuples, $resNumValidTuples,
		$pairListIdx, $output) = @_;

	my $resRows = @$res;

	my $xfieldAvg = $output[$pairListIdx][0][1];
	my $xfieldSD = $output[$pairListIdx][1][1];

	my $yfieldAvg = $output[$pairListIdx][2][1];
	my $yfieldSD = $output[$pairListIdx][3][1];

	# Computation of Pearson's Correlation Coefficient
	my $PCC;
	my $PCCsum = 0;
	for (my $n = 0; $n < $resRows; $n++){
		if($resValidTuples->[$n]){
			if($xfieldSD != 0 && $yfieldSD != 0){
				$PCC = (($xfieldArr->[$n]-$xfieldAvg)*($yfieldArr->[$n]-$yfieldAvg))/($xfieldSD*$yfieldSD);
				$PCCsum += $PCC;
			}
		}
	}
	my $PCCavg = $PCCsum/$resNumValidTuples;

	print "Number valid tuples: $resNumValidTuples\n";

	my $outputElemIdx;
	if(defined $output[$pairListIdx]){
		$outputElemIdx = @{$output[$pairListIdx]};
	}
	else{
		$outputElemIdx = 0;
	} 

	# Descriptors for each output value
	$output[$pairListIdx][$outputElemIdx][0] = 'PCC_Avg';

	# Actual output values
	$output[$pairListIdx][$outputElemIdx][1] = $PCCavg;
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
	print "size: $size\n";

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
	for(my $n = 0; $n < $resNumValidTuples; $n++){
		# print "$results->[$n][0][0], $results->[$n][0][1]\t$results->[$n][1][0], $results->[$n][1][1]\n";
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
		print "ERROR (computeSpearmanRCC): outputElemIdx == 0, does not see other output values\n";
		<STDIN>;
	}

	# Appending RCC value to output array
	$output[$pairListIdx][$outputElemIdx][0] = "SpearmanRCC";
	$output[$pairListIdx][$outputElemIdx][1] = $RCC;
}

# Stores values that are interpreted as invalid.
sub errorOutput{
	my ($xt, $xfield, $yt, $yfield, $pairListIdx, $refOutput) = @_;
	my $output = @$refOutput;

	$output[$pairListIdx][0][0] = $xt . "." . $xfield . '_Avg';
	$output[$pairListIdx][1][0] = $xt . "." . $xfield . '_SD';
	$output[$pairListIdx][2][0] = $yt . "." . $yfield . '_Avg';
	$output[$pairListIdx][3][0] = $yt . "." . $yfield . '_SD';
	$output[$pairListIdx][4][0] = 'PCC_Avg';
	$output[$pairListIdx][5][0] = 'RCC';

	$output[$pairListIdx][0][1] = -2;
	$output[$pairListIdx][1][1] = -2;
	$output[$pairListIdx][2][1] = -2;
	$output[$pairListIdx][3][1] = -2;
	$output[$pairListIdx][4][1] = 0;
	$output[$pairListIdx][5][1] = 0;
}

# Authorize the GET method.
sub isAuth{
	my ($self, $method, $req) = @_;
    return $method eq 'GET';
}