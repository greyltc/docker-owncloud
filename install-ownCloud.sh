#!/usr/bin/env bash
set -e -u -o pipefail

# remove info.php (prevents server info leak)
rm /srv/http/info.php

# to mount SAMBA shares: 
pacman -S --noconfirm --noprogress --needed smbclient

# for video file previews
pacman -S --noconfirm --noprogress --needed ffmpeg

# for document previews
pacman -S --noconfirm --noprogress --needed libreoffice-fresh

# owncloud itself
pacman -Sw --noconfirm --noprogress --needed owncloud
pacman -U --noconfirm --needed /var/cache/pacman/pkg/owncloud-${OC_VERSION}-any.pkg.tar.xz

# official ownCloud addons
pacman -S --noconfirm --noprogress --needed owncloud-app-bookmarks
pacman -S --noconfirm --noprogress --needed owncloud-app-calendar
pacman -S --noconfirm --noprogress --needed owncloud-app-contacts
pacman -S --noconfirm --noprogress --needed owncloud-app-documents
pacman -S --noconfirm --noprogress --needed owncloud-app-gallery

# enable large file uploads
sed -i 's,<IfModule mod_php5.c>,<IfModule mod_php7.c>,g' /usr/share/webapps/owncloud/.htaccess
sed -i "s,php_value upload_max_filesize 513M,php_value upload_max_filesize ${MAX_UPLOAD_SIZE},g" /usr/share/webapps/owncloud/.htaccess
sed -i "s,php_value post_max_size 513M,php_value post_max_size ${MAX_UPLOAD_SIZE},g" /usr/share/webapps/owncloud/.htaccess

# set up PHP for owncloud
sed -i 's/open_basedir = \/srv\/http\/:\/home\/:\/tmp\/:\/usr\/share\/pear\/:\/usr\/share\/webapps\//open_basedir = \/srv\/http\/:\/home\/:\/tmp\/:\/usr\/share\/pear\/:\/usr\/share\/webapps\/:\/etc\/webapps\//g' /etc/php/php.ini  # fixes issue with config not editable and occ errors (Issue #44)
sed -i 's/;extension=posix.so/extension=posix.so/g' /etc/php/php.ini  # needed for cron / occ (Issue #42)

# setup Apache for owncloud
cp /etc/webapps/owncloud/apache.example.conf /etc/httpd/conf/extra/owncloud.conf
sed -i '/<VirtualHost/,/<\/VirtualHost>/d' /etc/httpd/conf/extra/owncloud.conf
sed -i 's,Alias /owncloud /usr/share/webapps/owncloud/,Alias /${TARGET_SUBDIR} /usr/share/webapps/owncloud/,g' /etc/httpd/conf/extra/owncloud.conf
sed -i '/<Directory \/usr\/share\/webapps\/owncloud\/>/a Header always add Strict-Transport-Security "max-age=15768000; includeSubDomains; preload"' /etc/httpd/conf/extra/owncloud.conf
sed -i 's,php_admin_value open_basedir "[^"]*,&:/dev/urandom,g' /etc/httpd/conf/extra/owncloud.conf
sed -i '$a Include conf/extra/owncloud.conf' /etc/httpd/conf/httpd.conf

# install cron (Issue #42)
pacman -S --noconfirm --needed --noprogress cronie
