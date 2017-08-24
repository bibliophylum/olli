package Olli::REST::API::munMapping;
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

sub GET {
	my ($self, $request, $response) = @_ ;
	dbPrepare();
	my $q = CGI->new;
	my $munParam = ($q->param('munID'))[0];
	my $chosenOutput;

	if(defined $munParam){
		$chosenOutput = getSpecificMunData();
	}
	else{
		$chosenOutput = getMunMapping();
	}
	
	$response->data()->{'rawOutput'} = $chosenOutput;
	$dbh->disconnect;
	return Apache2::Const::HTTP_OK ;
}

sub getMunMapping{
	$SQL = "select * from mun_geo_gis";
	$sth = $dbh->prepare($SQL) or die "Prepare exception: $DBI::errstr!";
	$sth->execute() or die "Execute exception: $DBI::errstr";
	my $munMapping = $sth->fetchall_arrayref();
	return $munMapping;
}

sub getSpecificMunData{
	$SQL = "select * from mun_geo_gis";
	$sth = $dbh->prepare($SQL) or die "Prepare exception: $DBI::errstr!";
	$sth->execute() or die "Execute exception: $DBI::errstr";
	my $munMapping = $sth->fetchall_arrayref();
	return $munMapping;
}

sub isAuth{
	my ($self, $method, $req) = @_;
    return $method eq 'GET';
}