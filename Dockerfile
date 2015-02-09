FROM l3iggs/lamp
MAINTAINER l3iggs <l3iggs@live.com>

# install some owncloud optional deps
RUN sudo pacman -Suy --noconfirm --needed smbclient
#RUN pacman -Suy --noconfirm --needed ffmpeg
# libreoffice-common no longer exists
#RUN pacman -Suy --noconfirm --needed  libreoffice-common

# Install owncloud
RUN sudo pacman -Suy --noconfirm --needed owncloud

# enable large file uploads
RUN sudo sed -i 's,;php_value upload_max_filesize 513M,php_value upload_max_filesize 30G,g' /usr/share/webapps/owncloud/.htaccess
RUN sudo sed -i 's,;php_value post_max_size 513M,php_value post_max_size 30G,g' /usr/share/webapps/owncloud/.htaccess
RUN sudo sed -i '$a output_buffering = 0' /usr/share/webapps/owncloud/.htaccess


# setup Apache for owncloud
RUN sudo cp /etc/webapps/owncloud/apache.example.conf /etc/httpd/conf/extra/owncloud.conf
RUN sudo sed -i '$a Include conf/extra/owncloud.conf' /etc/httpd/conf/httpd.conf
RUN sudo chown -R http:http /usr/share/webapps/owncloud/

# start apache and mysql
CMD cd '/usr'; sudo /usr/bin/mysqld_safe --datadir='/var/lib/mysql'& sudo apachectl -DFOREGROUND
