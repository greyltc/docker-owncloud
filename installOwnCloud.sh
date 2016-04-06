#!/usr/bin/env bash
set -e -u -o pipefail

# remove info.php (prevents server info leak)
rm /srv/http/info.php

# to mount SMB shares: 
pacman -S --noconfirm --noprogress --needed smbclient

# for video file previews
pacman -S --noconfirm --noprogress --needed ffmpeg

# for document previews
pacman -S --noconfirm --noprogress --needed libreoffice-fresh

# not 100% sure what needs this:
pacman -S --noconfirm --noprogress --needed gamin

# owncloud itself
su docker -c 'pacaur -Sw --noprogressbar --noedit --noconfirm owncloud-archive'
pacman -U --noconfirm --needed /tmp/pacaurtmp-docker/owncloud-archive/owncloud-archive-${OC_VERSION}-any.pkg.tar
# temporary (remove @v9.0.1) fix for https://github.com/l3iggs/docker-owncloud/issues/83
sed -i 's,<IfModule mod_php5.c>,<IfModule mod_php7.c>,g' /usr/share/webapps/owncloud/.htaccess

# setup Apache for owncloud
cp /etc/webapps/owncloud/apache.example.conf /etc/httpd/conf/extra/owncloud.conf
sed -i 's,Alias /owncloud "/usr/share/webapps/owncloud",Alias /${TARGET_SUBDIR} "/usr/share/webapps/owncloud",g' /etc/httpd/conf/extra/owncloud.conf
sed -i '$a Include conf/extra/owncloud.conf' /etc/httpd/conf/httpd.conf

# reduce docker layer size
cleanup-image
