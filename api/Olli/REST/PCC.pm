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

=end comment
=cut

package Olli::REST::PCC;
use warnings;
use strict;
use base qw/Apache2::REST::Handler/;
use DBI;
use List::MoreUtils qw(firstidx);


my $SQL;
my $sth;
my $dbh;
my @output;
my @validOutput;
my $numValidOutput;
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
		determinePairPCC(\@pairList, $iter, \@output);

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
		determinePairPCC(\@pairList, $iter, \@output);

		if($output[$iter][0][1] != -1){
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

	for(my $valiter = 0; $valiter < $numValidOutput; $valiter++){
		for(my $i = 0; $i < @{$output[$valiter]}; $i++){
			# print "output[$i] = " . $output[$iter][$i][1] . "\n";
			printf "%s: %.3f\n", $validOutput[$valiter][$i][0], $validOutput[$valiter][$i][1];
		}
		print "\n";
	}

	print "Number valid output pairs: $numValidOutput\n";

	$dbh->disconnect;
	print "\nEnd of script\n";
}

sub determinePairPCC{

	my ($refPairList, $pairListIdx, $refOutput) = @_;
	my @pairList = @{$refPairList};
	my $output = @$refOutput;

	my $xt = $pairList[$pairListIdx][0];
	my $xfield = $pairList[$pairListIdx][1];

	my $yt = $pairList[$pairListIdx][2];
	my $yfield = $pairList[$pairListIdx][3];
	
	print "\n($pairListIdx) determinePairPCC of $xt.$xfield & $yt.$yfield\n";

	my $xt_yt_same = ($xt eq $yt);

	my $xfieldVal;
	my $xfieldSum = 0;
	my $xfieldAvg = 0;
	my $xfieldSD = 0;
	my @xfieldArr;

	my $yfieldVal;
	my $yfieldSum = 0;
	my $yfieldAvg = 0;
	my $yfieldSD = 0;
	my @yfieldArr;
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
		AND (ccu.table_name='$xt' OR ccu.table_name='$yt') AND (tc.table_name='$xt' OR tc.table_name='$yt')";
		
		$sth = $dbh->prepare($SQL) or die "Prepare exception: $DBI::errstr!";
		$sth->execute() or die "Execute exception: $DBI::errstr";

		$foreignArr = $sth->fetchall_arrayref();
		$foreignArrNames = $sth->{NAME};
	}

	my $foreign_xtTableIdx = firstidx { $_ eq 'table_name' } @$foreignArrNames;
	my $foreign_xtColIdx = firstidx { $_ eq 'column_name' } @$foreignArrNames;
	my $foreign_ytTableIdx = firstidx { $_ eq 'foreign_table_name' } @$foreignArrNames;
	my $foreign_ytColIdx = firstidx { $_ eq 'foreign_column_name' } @$foreignArrNames;

	# Obtains array reference to $xt fields
	if($xt_yt_same){
		$SQL = "SELECT CAST($xfield as decimal(10,2)) as x_$xfield,"
		#. " $xt.year as x_year,"
		. " $xt.id as x_id, CAST($yfield as decimal(10,2)) FROM $xt";
	}
	# Obtains array reference to join of $xt and $yt
	else{
		if(@$foreignArr != 1){
			print "ERROR: NO DIRECT FOREIGN KEY RELATIONSHIP BETWEEN $xt AND $yt\n";
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

			# $SQL = #"SELECT CAST($xfield as decimal(10,2)) as x_$xfield,"

			# if foreign key from $xt, continue
			if($xt eq $foreignArr->[0][$foreign_xtTableIdx]){
				$SQL = "SELECT CAST($xfield as decimal(10,2)) as x_$xfield,"
					#"SELECT $xfield as x_$xfield,"
					#. " $xt.year as x_year,"
					. " $xt.id as x_id,"
					. " CAST($yfield as decimal(10,2)), $yt.* FROM $xt INNER JOIN $yt"
					. " on $xt.$foreignArr->[0][$foreign_xtColIdx] = $yt.$foreignArr->[0][$foreign_ytColIdx]";
			}
			# if foreign key from $yt, swap table names
			else{
				$SQL = "SELECT CAST($xfield as decimal(10,2)) as x_$xfield,"
					#"SELECT $xfield as x_$xfield,"
					#. " $xt.year as x_year,"
					. " $xt.id as x_id,"
					. " CAST($yfield as decimal(10,2)), $yt.* FROM $xt INNER JOIN $yt"
					. " on $yt.$foreignArr->[0][$foreign_xtColIdx] = $xt.$foreignArr->[0][$foreign_ytColIdx]";
			}
			# print "\nSQL: $SQL\n\n";
		}
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
		if (#$res->[$n][$res_xtYearIdx] == $validYear &&
		defined $res->[$n][$res_ytIDIdx]
		&& defined $res->[$n][$res_xfieldIdx]
		&& defined $res->[$n][$res_yfieldIdx]){# && $res->[$n][$res_xfieldIdx] > 0 && $res->[$n][$res_yfieldIdx] > 0){
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
		print "\tERROR: NO VALID TUPLES\n";
		errorOutput($xt, $xfield, $yt, $yfield, $pairListIdx, \@output);
		return;
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

	# Computation of Standard Deviations of both $xfield and appropriate $yfield
	for (my $n = 0; $n < $resRows; $n++){
		if($resValidTuples[$n]){
			# print "$n\n";
			$xfieldSD += ($xfieldArr[$n]-$xfieldAvg)**2;
			$yfieldSD += ($yfieldArr[$n]-$yfieldAvg)**2;
		}
	}

	$xfieldSD /= $resNumValidTuples;
	$xfieldSD = sqrt($xfieldSD);

	$yfieldSD /= $resNumValidTuples;
	$yfieldSD = sqrt($yfieldSD);

	# Computation of Pearson's Correlation Coefficient
	my $PCC;
	my $PCCsum = 0;
	for (my $n = 0; $n < $resRows; $n++){
		if($resValidTuples[$n]){
			if($xfieldSD != 0 && $yfieldSD != 0){
				$PCC = (($xfieldArr[$n]-$xfieldAvg)*($yfieldArr[$n]-$yfieldAvg))/($xfieldSD*$yfieldSD);
				$PCCsum += $PCC;
			}

			#print "PCC = $PCC\n";
			#<STDIN>
		}
	}
	my $PCCavg = $PCCsum/$resNumValidTuples;

	print "Number valid tuples: $resNumValidTuples\n";

	# Descriptors for each output value
	$output[$pairListIdx][0][0] = $xt . "." . $xfield . '_Avg';
	$output[$pairListIdx][1][0] = $xt . "." . $xfield . '_SD';
	$output[$pairListIdx][2][0] = $yt . "." . $yfield . '_Avg';
	$output[$pairListIdx][3][0] = $yt . "." . $yfield . '_SD';
	$output[$pairListIdx][4][0] = 'PCC_Avg';

	# Actual output values
	$output[$pairListIdx][0][1] = $xfieldAvg;
	$output[$pairListIdx][1][1] = $xfieldSD;
	$output[$pairListIdx][2][1] = $yfieldAvg;
	$output[$pairListIdx][3][1] = $yfieldSD;
	$output[$pairListIdx][4][1] = $PCCavg;
}

sub errorOutput{
	my ($xt, $xfield, $yt, $yfield, $pairListIdx, $refOutput) = @_;
	my $output = @$refOutput;

	$output[$pairListIdx][0][0] = $xt . "." . $xfield . '_Avg';
	$output[$pairListIdx][1][0] = $xt . "." . $xfield . '_SD';
	$output[$pairListIdx][2][0] = $yt . "." . $yfield . '_Avg';
	$output[$pairListIdx][3][0] = $yt . "." . $yfield . '_SD';
	$output[$pairListIdx][4][0] = 'PCC_Avg';

	$output[$pairListIdx][0][1] = -1;
	$output[$pairListIdx][1][1] = -1;
	$output[$pairListIdx][2][1] = -1;
	$output[$pairListIdx][3][1] = -1;
	$output[$pairListIdx][4][1] = 0;
}

# Authorize the GET method.
sub isAuth{
	my ($self, $method, $req) = @_;
    return $method eq 'GET';
}