FROM l3iggs/lamp
MAINTAINER l3iggs <l3iggs@live.com>
# Report issues here: https://github.com/l3iggs/docker-owncloud/issues
# Say thanks by adding a star or a comment here: https://registry.hub.docker.com/u/l3iggs/owncloud/

# remove info.php
RUN rm /srv/http/info.php

# to mount SAMBA shares: 
RUN pacman -S --noconfirm --needed smbclient

# for video file previews
RUN pacman -S --noconfirm --needed ffmpeg

# for document previews
RUN pacman -S --noconfirm --needed libreoffice-fresh

# Install owncloud
RUN pacman -S --noconfirm --needed owncloud

# Install owncloud addons
RUN pacman -S --noconfirm --needed owncloud-app-bookmarks
RUN pacman -S --noconfirm --needed owncloud-app-calendar
RUN pacman -S --noconfirm --needed owncloud-app-contacts
RUN pacman -S --noconfirm --needed owncloud-app-documents

# enable large file uploads
ENV MAX_UPLOAD_SIZE 30G
RUN sed -i "s,php_value upload_max_filesize 513M,php_value upload_max_filesize ${MAX_UPLOAD_SIZE},g" /usr/share/webapps/owncloud/.htaccess
RUN sed -i "s,php_value post_max_size 513M,php_value post_max_size ${MAX_UPLOAD_SIZE},g" /usr/share/webapps/owncloud/.htaccess
RUN sed -i 's,<IfModule mod_php5.c>,<IfModule mod_php5.c>\nphp_value output_buffering Off,g' /usr/share/webapps/owncloud/.htaccess

# setup Apache for owncloud
ADD owncloud.conf /etc/httpd/conf/extra/owncloud.conf
RUN sed -i 's,Options Indexes FollowSymLinks,Options -Indexes,g' /etc/httpd/conf/httpd.conf
RUN sed -i '$a Include conf/extra/owncloud.conf' /etc/httpd/conf/httpd.conf
RUN echo ServerName ${HOSTNAME} >> /etc/httpd/conf/httpd.conf
RUN chown -R http:http /usr/share/webapps/owncloud/

# expose web server ports
EXPOSE 80
EXPOSE 443

# expose some important directories as volumes
#VOLUME ["/usr/share/webapps/owncloud/data"]
#VOLUME ["/etc/webapps/owncloud/config"]

# place your ssl cert files in here. name them server.key and server.crt
#VOLUME ["/https"]

# start apache and mysql servers
CMD cd /usr; /usr/bin/mysqld_safe --datadir=/var/lib/mysql& /usr/bin/apachectl -DFOREGROUND
