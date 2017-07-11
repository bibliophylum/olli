echo Disabling existing site...
sudo a2dissite olli.conf

echo Unlinking olli configuration...
sudo unlink /etc/apache2/sites-available/olli.conf

echo Removing existing /opt/olli...
sudo rm -rf /opt/olli/app
sudo rm -rf /opt/olli/api
sudo rm -rf /opt/olli/conf
sudo rm -rf /opt/olli/devdocs
sudo rm -rf /opt/olli/logs
sudo rm -rf /opt/olli/testing

echo Creating new /opt/olli...
sudo mkdir /opt/olli

echo Changing ownership...
echo Enter username: 
read username
#sudo chown david:david /opt/olli
sudo chown $username:$username /opt/olli

echo Copying from dev...
cp -R app /opt/olli/app
cp -R api /opt/olli/api
cp -R conf /opt/olli/conf
cp -R devdocs /opt/olli/devdocs
cp -R logs /opt/olli/logs
cp -R testing /opt/olli/testing

#sudo chgrp -R devel /opt/olli/*

#echo Allowing write to message logs...
sudo chgrp -R www-data /opt/olli/logs
sudo chmod g+w /opt/olli/logs
#sudo chmod ugo+w /opt/olli/logs/messages.log

touch /opt/olli/logs/cgi_error_log
sudo chgrp www-data /opt/olli/logs/cgi_error_log

#echo Allowing web server to write to htdocs/tmp
#sudo chgrp www-data /opt/olli/htdocs/tmp
#sudo chmod g+w /opt/olli/htdocs/tmp

echo Creating symlink to apache sites-available
sudo ln -s /opt/olli/conf/olli.conf /etc/apache2/sites-available/olli.conf

echo Enabling site...
sudo a2ensite olli.conf

echo Enabling reverse proxy...
sudo a2enmod proxy_http

echo Enabling rewrite...
sudo a2enmod rewrite

echo Reloading apache...
sudo /etc/init.d/apache2 reload
#sudo service apache2 reload
