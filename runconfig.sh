#!/bin/bash

# Configure Apache httpd.conf file
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.orig
sed -ie 's/#ServerName\ www\.example\.com\:80/ServerName\ www\.'$APP_NAME'\:80/g' /etc/httpd/conf/httpd.conf

# Rename the mediawiki folder and set permissions
mv /var/www/html/$WIKIVER /var/www/html/$APP_NAME
chown -R apache:apache /var/www/html/$APP_NAME
chmod -R 775 /var/www/html/$APP_NAME

# Rename the mediawiki apache config file
mv /etc/httpd/conf.d/mediawiki.conf /etc/httpd/conf.d/$APP_NAME.conf

# Run MySQL Install Script
sed -ie 's/database_name_here/'$MYSQL_DB'/g' /tmp/mysql_setup.sql
sed -ie 's/mysql_server/'$MYSQL_SERVER'/g' /tmp/mysql_setup.sql
sed -ie 's/mysql_user_here/'$APP_USER'/g' /tmp/mysql_setup.sql
sed -ie 's/mysql_password_here/'$APP_PASS'/g' /tmp/mysql_setup.sql

# Initialize MySQL
service mysqld start && mysql < /tmp/mysql_setup.sql && rm -fr /tmp/mysql_setup.sql*

# Set the MySQL root password
mysqladmin -u root password $MYSQL_PASS

# SET apache environment variables in /etc/sysconfig/httpd
echo "# Set Apache Environment Variables that will be passed to Apache via PassEnv (Must have mod_env enabled)" >> /etc/sysconfig/httpd
echo "APP=\"$APP_NAME\"" >> /etc/sysconfig/httpd
echo "SVRALIAS=\"$APACHE_SVRALIAS\"" >> /etc/sysconfig/httpd
echo "HOSTNAME=\`hostname\`" >> /etc/sysconfig/httpd

echo "# Export the variables to PassEnv" >> /etc/sysconfig/httpd
echo "export APP SVRALIAS HOSTNAME" >> /etc/sysconfig/httpd

# Set mysql and apache to start on boot and then Start Apache
echo "service mysqld start" >> ~/.bashrc
echo "service httpd start" >> ~/.bashrc
service httpd start

# Unset the Mysql password variable
unset MYSQL_PASS MYSQL_SERVER MYSQL_DB APP_USER APP_PASS

# Remove the runconfig line
sed -ie 's/\/tmp\/\.\/runconfig.sh/#\/tmp\/\.\/runconfig.sh/g' ~/.bashrc

