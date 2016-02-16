FROM greyltc/lamp
MAINTAINER Grey Christoforo <grey@christoforo.net>
# Report issues with this to the GitHub project: https://github.com/l3iggs/docker-owncloud/issues
# Say thanks by adding a star or a comment here: https://registry.hub.docker.com/u/l3iggs/owncloud/
# and/or staring the project on GitHub

# set environmnt variable defaults
ENV MAX_UPLOAD_SIZE 30G
ENV TARGET_SUBDIR owncloud
ENV OC_VERSION '8.2.2-2'

# remove info.php
RUN rm /srv/http/info.php

# to to run cron as HTTP
RUN pacman -S --noconfirm --needed sudo

# to mount SAMBA shares: 
RUN pacman -S --noconfirm --needed smbclient

# for video file previews
RUN pacman -S --noconfirm --needed ffmpeg

# for document previews
RUN pacman -S --noconfirm --needed libreoffice-fresh

# tweaks for PHP caching with APCu
RUN pacman -S --noconfirm --needed php-apcu-bc
RUN sed -i '$a extension=apc.so' /etc/php/conf.d/apcu.ini
RUN sed -i '$a apc.enable_cli=1' /etc/php/conf.d/apcu.ini

# Install owncloud
RUN pacman -Sw --noconfirm --needed owncloud
RUN pacman -U --noconfirm --needed /var/cache/pacman/pkg/owncloud-${OC_VERSION}-any.pkg.tar.xz
RUN mkdir -p /usr/share/webapps/owncloud/data

# add our custom config.php
ADD configs/oc-config.php /usr/share/webapps/owncloud/config/config.php

# Install owncloud addons
RUN pacman -S --noconfirm --needed owncloud-app-bookmarks
RUN pacman -S --noconfirm --needed owncloud-app-calendar
RUN pacman -S --noconfirm --needed owncloud-app-contacts
RUN pacman -S --noconfirm --needed owncloud-app-documents
RUN pacman -S --noconfirm --needed owncloud-app-gallery

# disable Apache's dav in favor of the dav built into OC
RUN sed -i 's,^DAVLockDB /home/httpd/DAV/DAVLock,#&,g' /etc/httpd/conf/httpd.conf
RUN sed -i 's,^LoadModule dav_module modules/mod_dav.so,#&,g' /etc/httpd/conf/httpd.conf
RUN sed -i 's,^LoadModule dav_fs_module modules/mod_dav_fs.so,#&,g' /etc/httpd/conf/httpd.conf
RUN sed -i 's,^LoadModule dav_lock_module modules/mod_dav_lock.so,#&,g' /etc/httpd/conf/httpd.conf

# enable large file uploads
RUN sed -i 's,<IfModule mod_php5.c>,<IfModule mod_php7.c>,g' /usr/share/webapps/owncloud/.htaccess
RUN sed -i "s,php_value upload_max_filesize 513M,php_value upload_max_filesize ${MAX_UPLOAD_SIZE},g" /usr/share/webapps/owncloud/.htaccess
RUN sed -i "s,php_value post_max_size 513M,php_value post_max_size ${MAX_UPLOAD_SIZE},g" /usr/share/webapps/owncloud/.htaccess

# set up PHP for owncloud
RUN sed -i 's/open_basedir = \/srv\/http\/:\/home\/:\/tmp\/:\/usr\/share\/pear\/:\/usr\/share\/webapps\//open_basedir = \/srv\/http\/:\/home\/:\/tmp\/:\/usr\/share\/pear\/:\/usr\/share\/webapps\/:\/etc\/webapps\//g' /etc/php/php.ini  # fixes issue with config not editable and occ errors (Issue #44)
RUN sed -i 's/;extension=posix.so/extension=posix.so/g' /etc/php/php.ini  # needed for cron / occ (Issue #42)

# setup Apache for owncloud
RUN cp /etc/webapps/owncloud/apache.example.conf /etc/httpd/conf/extra/owncloud.conf
RUN sed -i '/<VirtualHost/,/<\/VirtualHost>/d' /etc/httpd/conf/extra/owncloud.conf
RUN sed -i 's,Alias /owncloud /usr/share/webapps/owncloud/,Alias /${TARGET_SUBDIR} /usr/share/webapps/owncloud/,g' /etc/httpd/conf/extra/owncloud.conf
RUN sed -i '/<Directory \/usr\/share\/webapps\/owncloud\/>/a Header always add Strict-Transport-Security "max-age=15768000; includeSubDomains; preload"' /etc/httpd/conf/extra/owncloud.conf
RUN sed -i 's,php_admin_value open_basedir "[^"]*,&:/dev/urandom,g' /etc/httpd/conf/extra/owncloud.conf
RUN sed -i '$a Include conf/extra/owncloud.conf' /etc/httpd/conf/httpd.conf

# expose some important directories as volumes
#VOLUME ["/usr/share/webapps/owncloud/data"]
#VOLUME ["/etc/webapps/owncloud/config"]
#VOLUME ["/usr/share/webapps/owncloud/apps"]

# place your ssl cert files in here. name them server.key and server.crt
#VOLUME ["/root/sslKeys"]

# Enable cron (Issue #42)
RUN pacman -S --noconfirm --needed cronie
RUN systemctl enable cronie.service
ADD configs/cron.conf /etc/oc-cron.conf
RUN crontab /etc/oc-cron.conf
RUN systemctl start cronie.service; exit 0 # force success due to issue with cronie start https://goo.gl/DcGGb

# fixup the permissions (because appairently the package maintainer can't get it right)
ADD fixPerms.sh /root/fixPerms.sh
RUN chmod +x /root/fixPerms.sh
RUN /root/fixPerms.sh

# start the servers then go to bed
CMD start-servers; sleep infinity
