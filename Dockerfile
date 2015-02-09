FROM l3iggs/archlinux
MAINTAINER l3iggs <l3iggs@live.com>

# install apache and php
RUN pacman -Suy --noconfirm --needed apache php php-apache openssl php-intl

# setup php
RUN sed -i 's,LoadModule rewrite_module modules/mod_rewrite.so,LoadModule rewrite_module modules/mod_rewrite.so\nLoadModule php5_module modules/libphp5.so,g' /etc/httpd/conf/httpd.conf
RUN sed -i 's,LoadModule mpm_event_module modules/mod_mpm_event.so,LoadModule mpm_prefork_module modules/mod_mpm_prefork.so,g' /etc/httpd/conf/httpd.conf
RUN echo "Include conf/extra/php5_module.conf" >> /etc/httpd/conf/httpd.conf
RUN sed -i 's,;extension=iconv.so,extension=iconv.so,g' /etc/php/php.ini
RUN sed -i 's,;extension=xmlrpc.so,extension=xmlrpc.so,g' /etc/php/php.ini
RUN sed -i 's,;extension=zip.so,extension=zip.so,g' /etc/php/php.ini
RUN sed -i 's,;extension=bz2.so,extension=bz2.so,g' /etc/php/php.ini
RUN sed -i 's,;extension=curl.so,extension=curl.so,g' /etc/php/php.ini
RUN sed -i 's,;extension=ftp.so,extension=ftp.so,g' /etc/php/php.ini

# for ssl
RUN pacman -Suy --noconfirm --needed openssl
RUN sed -i 's,;extension=openssl.so,extension=openssl.so,g' /etc/php/php.ini
RUN sed -i 's,#LoadModule ssl_module modules/mod_ssl.so,LoadModule ssl_module modules/mod_ssl.so,g' /etc/httpd/conf/httpd.conf
RUN sed -i 's,#LoadModule socache_shmcb_module modules/mod_socache_shmcb.so,LoadModule socache_shmcb_module modules/mod_socache_shmcb.so,g' /etc/httpd/conf/httpd.conf
RUN sed -i 's,#Include conf/extra/httpd-ssl.conf,Include conf/extra/httpd-ssl.conf,g' /etc/httpd/conf/httpd.conf

# generate a self-signed cert
WORKDIR /etc/httpd/conf
ENV SUBJECT /C=US/ST=CA/L=CITY/O=ORGANIZATION/OU=UNIT/CN=localhost
RUN openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out server.key
RUN chmod 600 server.key
RUN openssl req -new -key server.key -out server.csr -subj $SUBJECT
RUN openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt
RUN mkdir /https
RUN ln -s /etc/httpd/conf/server.crt /https/server.crt
RUN ln -s /etc/httpd/conf/server.key /https/server.key
RUN sed -i 's,/etc/httpd/conf/server.crt,/https/server.crt,g' /etc/httpd/conf/extra/httpd-ssl.conf
RUN sed -i 's,/etc/httpd/conf/server.key,/https/server.key,g' /etc/httpd/conf/extra/httpd-ssl.conf

# for php-gd
RUN pacman -Suy --noconfirm --needed php-gd
RUN sed -i 's,;extension=gd.so,extension=gd.so,g' /etc/php/php.ini

# for php-mcrypt
RUN pacman -Suy --noconfirm --needed php-mcrypt
RUN sed -i 's,;extension=mcrypt.so,extension=mcrypt.so,g' /etc/php/php.ini

# for php-xcache
RUN pacman -Suy --noconfirm --needed php-xcache
RUN sed -i 's,;extension=xcache.so,extension=xcache.so,g' /etc/php/conf.d/xcache.ini

# for exif support
RUN pacman -Suy --noconfirm --needed exiv2
RUN sed -i 's,;extension=exif.so,extension=exif.so,g' /etc/php/php.ini

# for sqlite database
RUN pacman -Suy --noconfirm --needed sqlite php-sqlite
RUN sed -i 's,;extension=sqlite3.so,extension=sqlite3.so,g' /etc/php/php.ini
RUN sed -i 's,;extension=pdo_sqlite.so,extension=pdo_sqlite.so,g' /etc/php/php.ini

# for mariadb (mysql) database
RUN pacman -Suy --noconfirm --needed mariadb
RUN sed -i 's,;extension=pdo_mysql.so,extension=pdo_mysql.so,g' /etc/php/php.ini
RUN sed -i 's,;extension=mysql.so,extension=mysql.so,g' /etc/php/php.ini
#RUN sed -i 's,mysql.trace_mode = Off,mysql.trace_mode = On,g' /etc/php/php.ini
#RUN sed -i 's,mysql.default_host =,mysql.default_host = localhost,g' /etc/php/php.ini
#RUN sed -i 's,mysql.default_user =,mysql.default_user = root,g' /etc/php/php.ini

# Install owncloud
RUN pacman -Suy --noconfirm --needed owncloud
RUN sed -i 's,;php_value upload_max_filesize 513M,php_value upload_max_filesize 30G,g' /usr/share/webapps/owncloud/.htaccess
RUN sed -i 's,;php_value post_max_size 513M,php_value post_max_size 30G,g' /usr/share/webapps/owncloud/.htaccess
RUN echo "output_buffering = 0" >> /usr/share/webapps/owncloud/.htaccess


# install some owncloud optional deps
RUN pacman -Suy --noconfirm --needed php-apcu smbclient ffmpeg libreoffice-common

# setup Apache for owncloud
RUN cp /etc/webapps/owncloud/apache.example.conf /etc/httpd/conf/extra/owncloud.conf
RUN echo "Include conf/extra/owncloud.conf" >> /etc/httpd/conf/httpd.conf
RUN chown -R http:http /usr/share/webapps/owncloud/

# start apache and mysql
CMD cd '/usr'; /usr/bin/mysqld_safe --datadir='/var/lib/mysql'& apachectl -DFOREGROUND
