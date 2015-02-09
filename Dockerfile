FROM l3iggs/lamp
MAINTAINER l3iggs <l3iggs@live.com>

# install some owncloud optional deps
RUN pacman -Suy --noconfirm --needed smbclient
#RUN pacman -Suy --noconfirm --needed ffmpeg
# libreoffice-common no longer exists
#RUN pacman -Suy --noconfirm --needed  libreoffice-common

# Install owncloud
RUN pacman -Suy --noconfirm --needed owncloud

# enable large file uploads
RUN sed -i 's,;php_value upload_max_filesize 513M,php_value upload_max_filesize 30G,g' /usr/share/webapps/owncloud/.htaccess
RUN sed -i 's,;php_value post_max_size 513M,php_value post_max_size 30G,g' /usr/share/webapps/owncloud/.htaccess
RUN echo "output_buffering = 0" >> /usr/share/webapps/owncloud/.htaccess

# setup Apache for owncloud
RUN cp /etc/webapps/owncloud/apache.example.conf /etc/httpd/conf/extra/owncloud.conf
RUN echo "Include conf/extra/owncloud.conf" >> /etc/httpd/conf/httpd.conf
RUN chown -R http:http /usr/share/webapps/owncloud/

# start apache and mysql
CMD cd '/usr'; /usr/bin/mysqld_safe --datadir='/var/lib/mysql'& apachectl -DFOREGROUND
