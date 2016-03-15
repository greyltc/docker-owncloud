#!/usr/bin/env bash
set -e -u -o pipefail

# remove info.php (prevents server info leak)
rm /srv/http/info.php

# to mount SAMBA shares: 
#pacman -S --noconfirm --noprogress --needed smbclient

# for video file previews
pacman -S --noconfirm --noprogress --needed ffmpeg

# for document previews
pacman -S --noconfirm --noprogress --needed libreoffice-fresh

# owncloud itself
su docker -c 'pacaur -Sw --noprogressbar --noedit --noconfirm owncloud-archive'
pacman -U --noconfirm --needed /tmp/pacaurtmp-docker/owncloud-archive/owncloud-archive-${OC_VERSION}-any.pkg.tar
rm -rf /tmp/pacaurtmp-docker

# official ownCloud addons
#pacman -S --noconfirm --noprogress --needed owncloud-app-bookmarks
#pacman -S --noconfirm --noprogress --needed owncloud-app-calendar
#pacman -S --noconfirm --noprogress --needed owncloud-app-contacts
#pacman -S --noconfirm --noprogress --needed owncloud-app-documents
#pacman -S --noconfirm --noprogress --needed owncloud-app-gallery

# setup Apache for owncloud
cp /etc/webapps/owncloud/apache.example.conf /etc/httpd/conf/extra/owncloud.conf
sed -i 's,Alias /owncloud "/usr/share/webapps/owncloud",Alias /${TARGET_SUBDIR} "/usr/share/webapps/owncloud",g' /etc/httpd/conf/extra/owncloud.conf
sed -i '/<Directory \/usr\/share\/webapps\/owncloud\/>/a   Header always add Strict-Transport-Security "max-age=15768000; includeSubDomains; preload"' /etc/httpd/conf/extra/owncloud.conf
sed -i '$a Include conf/extra/owncloud.conf' /etc/httpd/conf/httpd.conf

# install cron (Issue #42)
pacman -S --noconfirm --needed --noprogress cronie

