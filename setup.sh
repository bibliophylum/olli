#Installs needed prerequisites
#Installs apache2

echo Updating repositories...
sudo apt -qq update

echo Installing libpcre3 and libpcre3-dev
sudo apt -qq install libpcre3
sudo apt -qq install libpcre3-dev

printf '\nAPACHE DOWNLOAD:\nhttp://httpd.apache.org/download.cgi\n'

while : ; do
	printf "\nInput absolute path to unzipped apache2 source:\n"
	read apache2DownDir
	if [ -d $apache2DownDir ]; then
		break
	else
		printf "INCORRECT PATH\n"
	fi
done

OrigDir=$PWD
cd $apache2DownDir

printf "\nConfiguring, compiling, and installing Apache...\n"
sudo ./configure -q
sudo make -s
sudo make -s install

sudo apt -qq install libapache2-mod-perl2

sudo apt -qq install libapache2-mod-perl2-dev

sudo apt -qq install postgresql-server-dev-9.5

sudo apt -qq install libpq-dev

echo \nInstalling DBD::Pg
sudo cpan DBD::Pg

echo \nInstalling ZConf::DBI
sudo cpan ZConf::DBI

cd $OrigDir
