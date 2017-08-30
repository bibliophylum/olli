=begin comment
	Mykel Shumay
	Brandon University
	Public Library Services Branch
	Manitoba Sport, Culture and Heritage

	This script sums the valid census characteristic subvalues for all given valid municipalities.

	V01 (2017.08.04):
		- First version for browser implementation.

	V02 (2017.08.14):
		- Added 'getValidMunList' sub, returns a list containing the id and name of all valid municipalities.

	V03 (2017.08.):
		- Added check in 'munGrouping' sub for census characteristics that were percentages.
			- This is hardcoded, as only chars (3, 33, 235) are percentages.

=end comment
=cut

package Olli::REST::API::munGrouping;
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

my $censusMunVals = [];

# dbPrepare();
# my $censusMunVals = munCensusSorting();
# munGrouping([600]);

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
	my $chosenOutput;

	# If muns not specified, gets list of id and name of all valid muns.
	if(! defined $munParam[0]){
		$chosenOutput = getValidMunList();
	}
	# Else, gets grouping of the census values of the specified muns.
	else{
		$chosenOutput = munGrouping(\@munParam);
	}

	$response->data()->{'rawOutput'} = $chosenOutput;
	return Apache2::Const::HTTP_OK ;
}

sub getValidMunList{
	$censusMunVals = munCensusSorting();
	my $validMunList;
	my $listIdx = 0;
	my $name;

	for(my $m_id = 1; $m_id < @{$censusMunVals}; $m_id++){
		if (defined $censusMunVals->[$m_id]){
			$SQL = "select name from municipalities where id = $m_id";
			$sth = $dbh->prepare($SQL) or die "Prepare exception: $DBI::errstr!";
			$sth->execute() or die "Execute exception: $DBI::errstr";
			$name = $sth->fetchall_arrayref();

			$validMunList->[$listIdx][0] = $m_id;
			$validMunList->[$listIdx][1] = $name;
			$listIdx++;
		}
	}
	return $validMunList;
}

sub munGrouping{
	my ($munChoiceArr) = @_;
	# my $censusMunVals = munCensusSorting();
	my $censusSums;
	my $currentMun;

	if(@{$munChoiceArr} == 0){
		# print "ERROR! No chosen municipalities!\n";
		exit;
	}

	if(! checkMunValidity($censusMunVals, $munChoiceArr)){
		# print "ERROR! Invalid municipalities!\n";
		exit;
	}

	# print "Length of censusMunVals: " . @{$censusMunVals} . "\n";
	# print (defined $censusMunVals->[$munChoiceArr->[0]]);

	for(my $chosenMunIdx = 0; $chosenMunIdx < @{$munChoiceArr}; $chosenMunIdx++){
		$currentMun = $munChoiceArr->[$chosenMunIdx];
		# print "currentMun: " . $currentMun . "\n";
		if(defined $censusMunVals->[$currentMun]){
			for(my $c_id = 1; $c_id < @{$censusMunVals->[$currentMun]}; $c_id++){
				# print "c_id: " . $c_id . "\n";
				if(defined $censusMunVals->[$currentMun][$c_id]){
					for(my $inner = 1; $inner < 4; $inner++){
						$censusSums->[$c_id][$inner] += $censusMunVals->[$currentMun][$c_id][0][$inner];
					}
				}
				# else{
				# 	print $currentMun . "." . $c_id . " not defined!\n";
				# }
			}
		}
		else{
			# print "ERROR! Invalid municipality within loop!\n";
			exit;
		}
	}

	my $formatted;
	my $c_id_idx = 0; # Tracks next empty index of $formatted.
	for(my $c_id = 1; $c_id < @{$censusSums}; $c_id++){
		if(defined $censusSums->[$c_id]){
			$formatted->[$c_id_idx][0][0] = $c_id; # Stores census characteristic id
			$SQL = "select value from census_characteristics where id = $c_id";
			$sth = $dbh->prepare($SQL) or die "Prepare exception: $DBI::errstr!";
			$sth->execute() or die "Execute exception: $DBI::errstr";
			$formatted->[$c_id_idx][0][1] = $sth->fetchall_arrayref()->[0][0];
			for(my $inner = 1; $inner < @{$censusSums->[$c_id]}; $inner++){
				# Stores each characteristic subvalue
				# Checks if is a percentage. If so, divides each value by number of municipalities chosen.
				if($c_id == 3 || $c_id == 33 || $c_id == 235){
					$formatted->[$c_id_idx][1][$inner] = $censusSums->[$c_id][$inner] / @{$munChoiceArr};
				}
				else{
					$formatted->[$c_id_idx][1][$inner] = $censusSums->[$c_id][$inner];
				}
			}
			$c_id_idx++;
		}
	}
	return $formatted;
}

sub munCensusSorting{
	$SQL = "select census_year.value as cen_year_value,
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

	my @vals; # Holds all valid data in standard format
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

			push @{$vals
				[$current_m_id]
				[$current_char_id]},
				@currentArr;
		}
	}
	return \@vals;
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

# Returns 1 if the passed municipality id choices are valid, else returns 0.
sub checkMunValidity{
	my ($givenArr, $munChoiceArr) = @_;

	if(@{$munChoiceArr} < 1){
		return 0;
	}

	for(my $m_id_idx = 0; $m_id_idx < @{$munChoiceArr}; $m_id_idx++){
		if(
			! defined $munChoiceArr->[$m_id_idx]
			|| ! looks_like_number($munChoiceArr->[$m_id_idx])
			|| $munChoiceArr->[$m_id_idx] < 1
			|| ! defined $givenArr->[$munChoiceArr->[$m_id_idx]]
			){
				return 0;
		}
	}
	return 1;
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