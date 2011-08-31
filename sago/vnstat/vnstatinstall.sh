#!/bin/bash
#
# This scripts installs the vnstat network traffic monitor as well as a php front end for it
# The php front end is very simple to configure and just needs to be in a web accessible directory
# which is (will be) assumed to be /usr/local/apache unless specified as an argument when the script is invoked.
#
# Files are being pulled from
# centos-mirror2 / ks.sagonet.com
# /storage/local/data/kickstart/tools/vnstat
#
#

cd /root
/usr/bin/wget http://ks.sagonet.com/tools/vnstat/vnstat-1.6-1.el4.rf.i386.rpm
rpm -Uvh vnstat-1.6-1.el4.rf.i386.rpm

# Check for PHP the lazy way
if php --version &> /dev/null
then echo -e '\033[32m PHP is installed.\033[0m'
else echo -e '\033[31m PHP is required for the vnstat PHP front end GUI to function, please verify PHP is installed correctly.\033[0m'
fi

# Set up the web host directory
#cd /var/www/html

mkdir -p /usr/local/apache/htdocs/vnstat
cd /usr/local/apache/htdocs/vnstat

/usr/local/apache/bin/htpasswd -b -c /usr/local/apache/.vnstat_htpasswd admin n3tst4ts

touch .htaccess
echo 'AuthUserFile /usr/local/apache/.vnstat_htpasswd' > .htaccess
echo 'AuthGroupFile /dev/null' >> .htaccess
echo 'AuthName EnterPassword' >> .htaccess
echo 'AuthType Basic' >> .htaccess
echo 'require user admin' >> .htaccess


# Install the PHP GUI
/usr/bin/wget http://ks.sagonet.com/tools/vnstat/vnstat_php_frontend-1.4.1.tar.gz
#wget http://www.sqweek.com/sqweek/files/vnstat_php_frontend-1.4.1.tar.gz
tar zxvf vnstat_php_frontend-1.4.1.tar.gz
mv vnstat_php_frontend-1.4.1 vnstat
cd vnstat
sed -i.old -e "s|vnstat_bin*......|vnstat_bin = '/usr/bin/vnstat'|g" config.php
#$vnstat_bin = '/usr/bin/vnstat';

# Have to initialize the interface and create a database for it
/usr/bin/vnstat -u -i eth0

echo -e '\033[32m vnstat has been installed. The GUI is at serverip/vnstat/index.php and you can run vnstat in the console simply with #vnstat -d\033[0m'
echo -e '\033[32m see man vnstat for more reporting options and additional features\033[0m'

