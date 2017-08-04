=begin comment
	Mykel Shumay
	Brandon University
	Public Library Services Branch
	Manitoba Sport, Culture and Heritage

	This script normalizes the valid census characteristic subvalues for all valid municipalities.

	V01 (2017.08.04):
		- First version for browser implementation.
		- Crude, but it works for both multiple municipalities and census characteristics when valid.
		- More robust error handling and input validation to come in future versions.

=end comment
=cut

package Olli::REST::API::censusNormalization;
use warnings;
use strict;
use base qw/Apache2::REST::Handler/;
use DBI;
use List::MoreUtils qw(firstidx);
use Scalar::Util qw(looks_like_number);
use CGI;

my $SQL;
my $sth;
my $dbh;

my $database = "olli";
my $dsn = "dbi:Pg:database=$database;host=localhost;port=5432";
my $userid = "olli";
my $password = "olli";

# Filter on the year of $xt's tuples (filtering is by substring, you may include any year however you want.)
# Example: $validYears = '2013_,asdf20142015' would give valid records from 2013 through 2015.
# If $validYears = '', there is no filtering by year.
# my $validYears = '2015';

# Names of census characteristic subvalues.
# The first index holds the population of the appropriate municipality.
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
sub GET{
    my ($self, $request, $response) = @_ ;
	dbPrepare();
	my $q = CGI->new;
	my @munParam = $q->multi_param('munID');
	my @charParam = $q->multi_param('charID');
	my $chosenOutput = listSpecificNormalizedValues(0,\@charParam,\@munParam);
	my $chosenOutput = rearrange($chosenOutput);

    $response->data()->{'output'} = $chosenOutput;
    return Apache2::Const::HTTP_OK ;
}

sub munCensusSorting{
	# dbPrepare();

	my $SQL = "select census_year.value as cen_year_value,
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
	my $c_yearIdx = firstidx { $_ eq 'cen_year_value'} @$arrNames;

	my $m_idIdx = firstidx { $_ eq 'm_id'} @$arrNames;
	my $m_popIdx = firstidx { $_ eq 'm_population'} @$arrNames;
	my $m_yearIdx = firstidx { $_ eq 'm_year'} @$arrNames;

	my @censusMunVals; # Holds all valid data in standard format
	my @currentArr; # Temporary storage of array to be pushed to @censusMunVals
	my $currentRow; # Temporary storage of tuple
	my $current_m_id;
	my $current_char_id;

	# Gathering all unique municipality ids that show up in the census data
	for(my $n = 0; $n < @{$arr}; $n++){
		$currentRow = $arr->[$n];

		# Only views census values that are valid
		# (ie, all values at least defined as a number and at least total > 0)
		if(defined $currentRow->[$totalIdx]
			&& !($currentRow->[$totalIdx] eq '')
			# && $currentRow->[$totalIdx] !=0
			&& defined $currentRow->[$maleIdx]
			&& !($currentRow->[$maleIdx] eq '')
			&& defined $currentRow->[$femaleIdx]
			&& !($currentRow->[$femaleIdx] eq '')
			# && $currentRow->[$m_yearIdx] eq $currentRow->[$c_yearIdx]
			# && $currentRow->[$c_yearIdx] eq '2011'
			&& $currentRow->[$m_yearIdx] eq '2011'
			&& $currentRow->[$subDivIdx] != 9
			){
				if($currentRow->[$subDivIdx] == 9){
					print "for mun 2, char $currentRow->[$characterIdIdx] is valid.\n";
					print "year: " . $currentRow->[$m_yearIdx] . "\n";
					exit 0;
				}

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
		}
	}
	# <STDIN>;
	return @censusMunVals;
}

# Links appropriate library id's to census data joined with municipalities.
sub linkLibsMuns{
	my $censusMunVals = @_;

	my $SQL = "select id as b_id, year as b_year, library_id as l_id, municipality_id as m_id from branches where municipality_id is not null";
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

# For each census characteristic subvalue E_c_i, each municipality m's census characteristic subvalue e_m_i is given the value of 
# 	e_m_i = ((e_m_i - E_c_i_min) / (E_c_i_max - E_c_i_min))
# 		* (m's pop i);
	
# Each e_m_i is then normalized again by the max of all e_x_i's to be put in a range from 0 -> 1.

# This gives normalized values that are per capita for each municipality, and allows us to compare between municipalities.
sub normalizeCensusValues{
	# dbPrepare();

	my @censusMunVals = munCensusSorting();
	my $normalized; # Holds normalized values for each valid census characteristic subvalue for each valid municipality (range of 0 -> 1)
	my $charMinMax; # Holds min ([0]) and max ([1]) for each subvalue of each census characteristic.
	my $currentPop; # Used in loops to reduce text and declarations.

	# Finding max and min for each census characteristic subvalue.
	for(my $m_id = 1; $m_id < @censusMunVals; $m_id++){
		if(defined $censusMunVals[$m_id]){
			# print "Normalizing values of municipality $m_id\n";
			# <STDIN>;

			if($m_id == 2){
				print "normalizeCensusValues sub (1): m_id of 2 is seen as valid!\n";
				# print "Aborting!\n";
				# exit 0;
			}

			for(my $c_id = 1; $c_id < @{$censusMunVals[$m_id]}; $c_id++){
				if(defined $censusMunVals[$m_id][$c_id]){
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
						# if($charMinMax->[$c_id][$inner][1] > 1.1){
						# 	print "m_id: $m_id, [$c_id][$inner][1] = $charMinMax->[$c_id][$inner][1]\n";
						# 	<STDIN>;
						# }
					}
				}
			}
		}
	}

	# Applying first normalization step to census/municipality characteristic subvalues.
	for(my $m_id = 1; $m_id < @censusMunVals; $m_id++){
		if(defined $censusMunVals[$m_id]){
			if($m_id == 2){
				print "normalizeCensusValues sub (2): m_id of 2 is seen as valid!\n";
				# print "Aborting!\n";
				# exit 0;
			}
			# print "Normalizing values of municipality $m_id\n";
			for(my $c_id = 1; $c_id < @{$censusMunVals[$m_id]}; $c_id++){
				if(defined $censusMunVals[$m_id][$c_id]){
					for(my $inner = 1; $inner < 4; $inner++){
						$currentPop = $censusMunVals[$m_id][8][0][$inner];
						if($charMinMax->[$c_id][$inner][0] == $charMinMax->[$c_id][$inner][1]){
							$normalized->[$m_id][$c_id][$inner] = 0.5;
						}
						else{
							$normalized->[$m_id][$c_id][$inner] = 
								((($censusMunVals[$m_id][$c_id][0][$inner]/$currentPop)-$charMinMax->[$c_id][$inner][0]) /
								($charMinMax->[$c_id][$inner][1] - $charMinMax->[$c_id][$inner][0]));

							# if($m_id == 609 && $c_id == 69){
							# 	print "c_id: $c_id.$inner, pop: $currentPop, val: $censusMunVals[$m_id][$c_id][0][$inner], norm: $normalized->[$m_id][$c_id][$inner], min: $charMinMax->[$c_id][$inner][0], max: $charMinMax->[$c_id][$inner][1]\n";
							# 	<STDIN>;
							# }
						}
					}
				}
			}
		}
	}
	return $normalized;
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
# This is a slow way to tackle this, although it is only done once for each valid municipality. This should be improved in the future, if ever used.
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
	return $census2011Pops;
}

# Lists valid municipalities, lets the user choose one.
# Then lists valid census characteristics for that municipality, lets the user choose however many they want.
# Shows normalized values for (Total, Male, Female) for the given municipality's given characteristics.
sub listSpecificNormalizedValues{
	my ($printOutput, $charParams, $munParams) = @_;
	my $normalized = normalizeCensusValues();

	my $munChoiceArr;
	my $mutuallyValidChars;
	my $charList;
	my $tempChoice; # Temporarily holds user input of municipality id
	my @charChoiceArr;
	my $more = 1; # Whether there is more user input to be received.

	# If valid choices, use passed parameters as chosen municipality and census characteristics indices.
	if(checkCharValidity($normalized, $charParams, $munParams)){
		$munChoiceArr = $munParams;
		@charChoiceArr = @{$charParams};
	}
	else{
		return; # Produces an error instead of an infinite loop.
	}
	# else{
	# 	($munChoiceArr, $mutuallyValidChars) = findMutuallyValidChars($printOutput, $normalized, $munParams);

	# 	for(my $c_id = 0; $c_id < @{$mutuallyValidChars}; $c_id++){
	# 		if($mutuallyValidChars->[$c_id]){
	# 			$SQL = "select id, value from census_characteristics where id = '$c_id'";
	# 			$sth = $dbh->prepare($SQL) or die "Prepare exception: $DBI::errstr!";
	# 			$sth->execute() or die "Execute exception: $DBI::errstr";
	# 			$charList->[@{$charList}] = $sth->fetchall_arrayref()->[0];
	# 		}
	# 	}

	# 	# Prints all valid census characteristics (for the chosen municipality) for the user to choose from.
	# 	print "\nPossible census characteristics:\n";
	# 	for(my $n = 0; $n < @{$charList}; $n++){
	# 		print $charList->[$n][0] . ": " . $charList->[$n][1] . "\n";
	# 	}

	# 	# Gets valid census characteristic id choices from user:
	# 	# Currently does not protect from the same value occuring more than once in @charChoiceArr.
	# 	print "\nContinue entering census characteristics by typing in one at a time from the list of the id's above. Enter \"end\" once you're finished.\n";
	# 	do{
	# 		print "\n(" . @charChoiceArr . ") Enter a valid characteristic id: ";
	# 		$tempChoice = <STDIN>;
	# 		chomp $tempChoice;
	# 		trim($tempChoice);

	# 		if((!looks_like_number($tempChoice))
	# 			|| ! $mutuallyValidChars->[$tempChoice]
	# 			|| $tempChoice < 1){
			
	# 			if(uc($tempChoice) eq uc("end")){
	# 				$more = 0;
	# 			}
	# 			else{
	# 				print "Not a valid characteristic id!\n";
	# 			}
	# 		}
	# 		else{
	# 			$tempChoice += 0; # Easy method of removing leading zeros, else the same characteristic id could be entered multiple times.
	# 			if(!checkArrForElem(\@charChoiceArr, $tempChoice)){
	# 				$charChoiceArr[@charChoiceArr] = $tempChoice;
	# 				# push (@charChoiceArr, $charChoice);
	# 			}
	# 			else{
	# 				print "Chosen characteristic id has already been recorded!\n";
	# 			}
	# 		}
	# 	}while($more);
	# 	print "\n";
	# }

	my $munName;
	my $munNames;

	my $chosenOutput;
	# $chosenOutput structure:
	# 1st Dim: characteristic choice index of $charChoiceArr
	# 	2nd Dim:
	# 		0: characteristic information
	# 			0: characteristic id
	# 			1: characteristic value (name of the characteristic)
	# 		1:
	#			Dim: municipality choice index of $munChoiceArr
	# 				0: municipality information
	# 					0: municipality id
	# 					1: municipality name
	# 				1: normalized results for current municipality
	# 					1: Total
	# 					2: Male
	# 					3: Female


	if($printOutput){
		print "Results:\n";
	}

	# For each given census characteristic choice, get the appropriate values
	for(my $choiceIdx = 0; $choiceIdx < @charChoiceArr; $choiceIdx++){
		# Gets name for chosen census characteristic:
		$SQL = "select value from census_characteristics where id = '$charChoiceArr[$choiceIdx]'";
		$sth = $dbh->prepare($SQL) or die "Prepare exception: $DBI::errstr!";
		$sth->execute() or die "Execute exception: $DBI::errstr";
		my $charValue = $sth->fetchall_arrayref()->[0][0];
		$charValue = trim($charValue);

		# Prints results:
		if($printOutput){
			print "Characteristic $charChoiceArr[$choiceIdx] ($charValue):\n";
		}
		$chosenOutput->[$choiceIdx][0][0] = $charChoiceArr[$choiceIdx];
		$chosenOutput->[$choiceIdx][0][1] = $charValue;

		for(my $m_id_idx = 0; $m_id_idx < @{$munChoiceArr}; $m_id_idx++){
			$SQL = "select name from municipalities where id = '$munChoiceArr->[$m_id_idx]'";
			$sth = $dbh->prepare($SQL) or die "Prepare exception: $DBI::errstr!";
			$sth->execute() or die "Execute exception: $DBI::errstr";
			$munName = $sth->fetchall_arrayref()->[0][0];
			$munNames->[$m_id_idx] =trim($munName);

			if($printOutput){
				print "Municipality $munChoiceArr->[$m_id_idx] ($munNames->[$m_id_idx]):\n";
			}
			$chosenOutput->[$choiceIdx][1][$m_id_idx][0][0] = $munChoiceArr->[$m_id_idx];
			$chosenOutput->[$choiceIdx][1][$m_id_idx][0][1] = $munNames->[$m_id_idx];

			for(my $inner = 1; $inner < 4; $inner++){
				if($printOutput){
					print "\t" . $innerNames->[$inner] . ": " . $normalized->[$munChoiceArr->[$m_id_idx]][$charChoiceArr[$choiceIdx]][$inner] . "\n";
				}
				$chosenOutput->[$choiceIdx][1][$m_id_idx][1][$inner] = $normalized->[$munChoiceArr->[$m_id_idx]][$charChoiceArr[$choiceIdx]][$inner];
			}
		}
		if($printOutput){
			print "\n";
		}
	}
	return $chosenOutput;
}

# Switches structure of $chosenOutput to be the municipality choice index first, then each characteristic census choice index.
sub rearrange{
	my ($chosenOutput) = @_;
	my $newChosenOutput;

	# Place each municipality's information (id and name)
	for(my $m_id_idx = 0; $m_id_idx < @{$chosenOutput->[0][1]}; $m_id_idx++){
		$newChosenOutput->[$m_id_idx][0] = $chosenOutput->[0][1][$m_id_idx][0];
	}

	for(my $c_id_idx = 0; $c_id_idx < @{$chosenOutput}; $c_id_idx++){
		for(my $m_id_idx = 0; $m_id_idx < @{$chosenOutput->[$c_id_idx][1]}; $m_id_idx++){

			# Place each census char's information into each municipality
			$newChosenOutput->[$m_id_idx][1][$c_id_idx][0] = $chosenOutput->[$c_id_idx][0];

			# Place the results of each census char in each municipality
			$newChosenOutput->[$m_id_idx][1][$c_id_idx][1] = $chosenOutput->[$c_id_idx][1][$m_id_idx][1];
		}
	}
	return $newChosenOutput;
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

# Allows the user to choose multiple valid municipalities, then finds all census characteristics that are valid across all chosen municipalities.
# Returns the list of valid municipality choices and the list of census characteristics that are valid across all chosen municipalities.
sub findMutuallyValidChars{
	my ($printOutput, $normalized, $munParams) = @_;
	
	my $munList;
	my $charList;
	my $munChoice;
	my $more = 1;
	my $current_m_id;
	my $mutuallyValidChars;

	# PATCHWORK, NOT OPTIMAL!
	# Municipality id of 2 is getting through as valid, even though it should have been disregarded from the start. The reason for this is unknown.
	undef $normalized->[2];

	my $munChoiceArr = [];
	
	if(checkMunValidity($normalized, $munParams)){
		$munChoiceArr = $munParams;
	}
	else{
		# Gathers id and name from all valid municipalities.
		for(my $m_id = 0; $m_id < @{$normalized}; $m_id++){
			if(defined $normalized->[$m_id]){
				# if($m_id == 2){
				# 	print "findMutuallyValidChars: m_id of 2 is seen as valid!\n\n";
					# print "Aborting!\n";
					# exit 0;
				# }
				$SQL = "select id, name from municipalities where id = '$m_id'";
				$sth = $dbh->prepare($SQL) or die "Prepare exception: $DBI::errstr!";
				$sth->execute() or die "Execute exception: $DBI::errstr";

				$munList->[@{$munList}] = $sth->fetchall_arrayref()->[0];
			}
		}

		if($printOutput){
			# Prints all valid municipalities for the user to choose from.
			print "Valid municipalities:\n";
			for(my $n = 0; $n < @{$munList}; $n++){
				print $munList->[$n][0] . ": " . $munList->[$n][1] . "\n";
			}
		}

		print "\nContinue entering municipalities by typing in one at a time from the list of the id's above. Enter \"end\" once you're finished.\n";
		do{
			print "\n(" . @{$munChoiceArr} . ") Enter a valid municipality id: ";
			$munChoice = <STDIN>;
			chomp $munChoice;
			trim($munChoice);

			if((!looks_like_number($munChoice))
				|| ! defined $normalized->[$munChoice]
				|| $munChoice < 1){
			
				if(uc($munChoice) eq uc("end")){
					if(@{$munChoiceArr} == 0){
						print "Must enter at least one valid municipality id!\n";
					}
					else{
						$more = 0;
					}
				}
				else{
					print "Not a valid characteristic id!\n";
				}
			}
			else{
				$munChoice += 0; # Easy method of removing leading zeros, else the same characteristic id could be entered multiple times.
				if(!checkArrForElem($munChoiceArr, $munChoice)){
					$munChoiceArr->[@{$munChoiceArr}] = $munChoice;
					# push (@munChoiceArr, $munChoice);
				}
				else{
					print "Chosen municipality id has already been recorded!\n";
				}
			}
		}while($more);
	}

	# Uses max(id) instead of count(id) as there could possibly be gaps, but we address each census characteristic by the actual id.
	$SQL = "select max(id) from census_characteristics";
	$sth = $dbh->prepare($SQL) or die "Prepare exception: $DBI::errstr!";
	$sth->execute() or die "Execute exception: $DBI::errstr";
	my $numChars = $sth->fetchall_arrayref()->[0][0];

	# Start each as valid, invalidates if at least one municipality doesn't have valid value for each characteristic.
	for(my $n = 0; $n < $numChars; $n++){
		$mutuallyValidChars->[$n] = 1;
	}

	# Gathers id and value from all valid census characteristics (for the chosen municipality).
	for(my $m_id_idx = 0; $m_id_idx < @{$munChoiceArr}; $m_id_idx++){
		$current_m_id = $munChoiceArr->[$m_id_idx];
		for(my $c_id = 0; $c_id < @{$normalized->[$current_m_id]}; $c_id++){
			if(! defined $normalized->[$current_m_id][$c_id]){
				$mutuallyValidChars->[$c_id] = 0;
			}
		}
	}
	return ($munChoiceArr, $mutuallyValidChars);
}

# Returns 1 if the passed municipality id choices are valid, else returns 0.
sub checkMunValidity{
	my ($normalized, $munChoiceArr) = @_;

	if(@{$munChoiceArr} < 1){
		return 0;
	}

	for(my $m_id_idx = 0; $m_id_idx < @{$munChoiceArr}; $m_id_idx++){
		if(
			! defined $munChoiceArr->[$m_id_idx]
			|| ! looks_like_number($munChoiceArr->[$m_id_idx])
			|| $munChoiceArr->[$m_id_idx] < 1
			|| ! defined $normalized->[$munChoiceArr->[$m_id_idx]]
			){
				return 0;
		}
	}
	return 1;
}

# Returns 1 if the passed census characteristics and municipality choices are valid together, else returns 0.
sub checkCharValidity{
	my ($normalized, $charChoiceArr, $munChoiceArr) = @_;

	if(! defined $charChoiceArr || ! defined $munChoiceArr || @{$charChoiceArr} < 1 || @{$munChoiceArr} < 1){
		return 0; # Not valid or not specified
	}

	for(my $c_id_idx = 0; $c_id_idx < @{$charChoiceArr}; $c_id_idx++){
		for(my $m_id_idx = 0; $m_id_idx < @{$munChoiceArr}; $m_id_idx++){
			if(
				! defined $charChoiceArr->[$c_id_idx]
				|| ! defined $munChoiceArr->[$m_id_idx]
				|| ! looks_like_number($charChoiceArr->[$c_id_idx])
				|| ! looks_like_number($munChoiceArr->[$m_id_idx])
				|| $charChoiceArr->[$c_id_idx] < 1
				|| $munChoiceArr->[$m_id_idx] < 1
				|| ! defined $normalized->[$munChoiceArr->[$m_id_idx]][$charChoiceArr->[$c_id_idx]]
				){
				return 0; # Not valid choices lists
			}
		}
	}
	return 1; # Valid choices lists
}

# Lists valid municipalities, lets the user choose one.
# Asks for the number of minimum/maximum census characteristics values to display, in sorted ascending/descending (separately). This is ordered by subvalue (Total).
# Shows normalized values for (Total, Male, Female) for the given municipality.
sub findMinMaxNCharVals{
	my $normalized = normalizeCensusValues();

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
	for(my $m_id = 0; $m_id < @{$normalized}; $m_id++){
		if(defined $normalized->[$m_id]){
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

		if((!looks_like_number($munChoice)) || ! defined $normalized->[$munChoice] || $munChoice <= 0){
			print "Not a valid municipality id!\n";
		}
	}while((!looks_like_number($munChoice)) || ! defined $normalized->[$munChoice] || $munChoice <= 0);

	for(my $c_id = 0; $c_id < @{$normalized->[$munChoice]}; $c_id++){
		if(defined $normalized->[$munChoice][$c_id]){
			$SQL = "select id, value from census_characteristics where id = '$c_id'";
			$sth = $dbh->prepare($SQL) or die "Prepare exception: $DBI::errstr!";
			$sth->execute() or die "Execute exception: $DBI::errstr";
			$charList->[@{$charList}] = $sth->fetchall_arrayref()->[0];
		}
	}

	# @normalizedFilter holds only the valid census characteristics' values
	my @normalizedFilter;
	my $filterSize = 0;
	for(my $c_id = 0; $c_id < @{$normalized->[$munChoice]}; $c_id++){
		if(defined $normalized->[$munChoice][$c_id]){
			$normalizedFilter[$filterSize] = $normalized->[$munChoice][$c_id];
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

# Prints list returned by 'findSimilarValueChars' sub to the screen.
sub listSimilarValueChars{
	my ($printOutput, $normalized, $chosenMun, $chosenChar, $chosenSubvalue, $tolerance) = @_;

	if(! defined $normalized->[$chosenMun]){
		print "ERROR: Given municipality not valid!\n";
		exit 0;
	}
	if(! defined $normalized->[$chosenMun][$chosenChar]){
		print "ERROR: Given characteristic id not valid for the municipality!\n";
		exit 0;
	}

	my $simList = findSimilarValueChars($printOutput, $normalized, $chosenMun, $chosenChar, $chosenSubvalue, $tolerance);

	$SQL = "select value from census_characteristics where id = '$chosenChar'";
	$sth = $dbh->prepare($SQL) or die "Prepare exception: $DBI::errstr!";
	$sth->execute() or die "Execute exception: $DBI::errstr";
	my $charValue = $sth->fetchall_arrayref()->[0][0];
	my $chosenCharValue = trim($charValue);

	printf "Within $tolerance of characteristic $chosenChar ($chosenCharValue)\'s \"$innerNames->[$chosenSubvalue]\" subValue of %.4f:\n", $normalized->[$chosenMun][$chosenChar][$chosenSubvalue];
	for(my $n = 0; $n < @{$simList}; $n++){
		print "\nCharacteristic $simList->[$n][0]\n";
		print "$simList->[$n][1]\n";
		printf "%.4f\n", $simList->[$n][2];
	}
}

# Given a choice of municipality and subValue of a census characteristic, returns characteristic id and value of each subValue of every other characteristic for that municipality that is within +- $tolerance.
sub findSimilarValueChars{
	my ($printOutput, $normalized, $chosenMun, $chosenChar, $chosenSubvalue, $tolerance) = @_;

	if(! defined $normalized->[$chosenMun]){
		print "ERROR: Given municipality not valid!\n";
		exit 0;
	}
	if(! defined $normalized->[$chosenMun][$chosenChar]){
		print "ERROR: Given characteristic id not valid for the municipality!\n";
		exit 0;
	}

	my $orig = $normalized->[$chosenMun][$chosenChar][$chosenSubvalue];
	my $current;

	my $simList = [];
	for(my $c_id = 1; $c_id < @{$normalized->[$chosenMun]}; $c_id++){
		if(defined $normalized->[$chosenMun][$c_id] && $c_id != $chosenChar){
			$current = $normalized->[$chosenMun][$c_id][$chosenSubvalue];

			# Checks if $current is within +- $tolerance of $orig, inclusive
			if(
			$orig - $current >= 0 && $orig - $current <= $tolerance
			|| $current - $orig >= 0 && $current - $orig <= $tolerance
			){
				# Gets name of satisfying characteristic:
				$SQL = "select value from census_characteristics where id = '$c_id'";
				$sth = $dbh->prepare($SQL) or die "Prepare exception: $DBI::errstr!";
				$sth->execute() or die "Execute exception: $DBI::errstr";
				my $charValue = $sth->fetchall_arrayref()->[0][0];
				$charValue = trim($charValue);

				$simList->[@{$simList}] = [$c_id, $charValue, $current];
			}
			else{
			}
		}
	}
	return $simList;
}

# Trims whitespace on either side of a given string.
sub trim {
	my $s = shift;
	$s =~ s/^\s+|\s+$//g;
	return $s;
}

# Authorize the GET method.
sub isAuth{
	my ($self, $method, $req) = @_;
    return $method eq 'GET';
}