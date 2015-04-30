FROM l3iggs/lamp
MAINTAINER l3iggs <l3iggs@live.com>
# Report issues here: https://github.com/l3iggs/docker-owncloud/issues
# Say thanks by adding a comment here: https://registry.hub.docker.com/u/l3iggs/owncloud/

# remove info.php
RUN rm /srv/http/info.php

# install some owncloud optional deps
RUN pacman -S --noconfirm --needed smbclient
RUN pacman -S --noconfirm --needed ffmpeg
# libreoffice-common no longer exists
#RUN pacman -S --noconfirm --needed  libreoffice-common

# Install owncloud
RUN pacman -S --noconfirm --needed owncloud

# Install owncloud addons
RUN pacman -S --noconfirm --needed owncloud-app-bookmarks
RUN pacman -S --noconfirm --needed owncloud-app-calendar
RUN pacman -S --noconfirm --needed owncloud-app-contacts
RUN pacman -S --noconfirm --needed owncloud-app-documents

# enable large file uploads
RUN sed -i 's,php_value upload_max_filesize 513M,php_value upload_max_filesize 30G,g' /usr/share/webapps/owncloud/.htaccess
RUN sed -i 's,php_value post_max_size 513M,php_value post_max_size 30G,g' /usr/share/webapps/owncloud/.htaccess
RUN sed -i 's,<IfModule mod_php5.c>,<IfModule mod_php5.c>\nphp_value output_buffering Off,g' /usr/share/webapps/owncloud/.htaccess

# setup Apache for owncloud
ADD owncloud.conf /etc/httpd/conf/extra/owncloud.conf
RUN sed -i 's,Options Indexes FollowSymLinks,Options -Indexes,g' /etc/httpd/conf/httpd.conf
RUN sed -i '$a Include conf/extra/owncloud.conf' /etc/httpd/conf/httpd.conf
RUN chown -R http:http /usr/share/webapps/owncloud/

# expose web server ports
EXPOSE 80
EXPOSE 443

# expose some important directories as volumes
VOLUME ["/usr/share/webapps/owncloud/data"]
VOLUME ["/etc/webapps/owncloud/config"]

# place your ssl cert files in here. name them server.key and server.crt
VOLUME ["/https"]

# TODO: figure out why this directory does not already exist
RUN mkdir /run/httpd

# start apache and mysql servers
CMD cd /usr; /usr/bin/mysqld_safe --datadir=/var/lib/mysql& /usr/bin/apachectl -DFOREGROUND
