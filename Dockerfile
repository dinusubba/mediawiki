############################################################
# Dockerfile to build a MediaWiki server
# Based on centos/6.6
############################################################

# Set the base image to Centos 6.6 Base
FROM centos:centos6.6

# File Author / Maintainer
MAINTAINER Dinesh Vanipenta vdineshsreddy@gmail.com

#*************************
#*       Versions        *
#*************************
ENV WIKIVER mediawiki-1.23.6


#**********************************
#* Override Enabled ENV Variables *
#**********************************
ENV APP_NAME mediawiki.local
ENV APACHE_SVRALIAS www.mediawiki.local localhost
ENV MYSQL_SERVER 127.0.0.1
ENV MYSQL_PASS root
ENV MYSQL_DB my_wiki
ENV APP_USER admin
ENV APP_PASS admin@123


#*************************
#*  Update and Pre-Reqs  *
#*************************
RUN yum clean all && \
yum -y update && \
yum -y install wget httpd mod_rewrite mod_ssl mod_env php php-common php-cli php-mysql php-xml php-pdo php-xcache xcache-admin php-intl mysql mysql-server perl ImageMagick && \
rm -fr /var/cache/*

RUN yum -y install tar 

#**************************
#*   Add Required Files   *
#**************************
ADD runconfig.sh /tmp/
ADD mediawiki.conf /etc/httpd/conf.d/
ADD mysql_setup.sql /tmp/


#*************************
#*  Application Install  *
#*************************
# Grab mediawiki and install it
RUN cd /var/www/html/ && \
wget https://releases.wikimedia.org/mediawiki/1.23/$WIKIVER.tar.gz && \
tar -xzvf $WIKIVER.tar.gz && \
rm *.tar.gz



#************************
#* Post Deploy Clean Up *
#************************



#**************************
#*  Config Startup Items  *
#**************************
RUN chmod +x /tmp/runconfig.sh && \
echo "/tmp/./runconfig.sh" >> ~/.bashrc

CMD /bin/bash

#****************************
#* Expose Applicatoin Ports *
#****************************
# Expose ports to other containers only
EXPOSE 80
EXPOSE 443
