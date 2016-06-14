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

# for image previews
pacman -S --noconfirm --noprogress --needed imagemagick ghostscript openexr openexr openexr libxml2 librsvg libpng libwebp

# not 100% sure what needs this:
pacman -S --noconfirm --noprogress --needed gamin

# owncloud itself
su docker -c 'pacaur -m --noprogressbar --noedit --noconfirm owncloud-archive'
pacman -U --noconfirm --needed /home/docker/.cache/pacaur/owncloud-archive/owncloud-archive-${OC_VERSION}-any.pkg.tar

# setup Apache for owncloud
cp /etc/webapps/owncloud/apache.example.conf /etc/httpd/conf/extra/owncloud.conf
sed -i 's,Alias /owncloud "/usr/share/webapps/owncloud",Alias /${TARGET_SUBDIR} "/usr/share/webapps/owncloud",g' /etc/httpd/conf/extra/owncloud.conf
sed -i '$a Include conf/extra/owncloud.conf' /etc/httpd/conf/httpd.conf

# reduce docker layer size
cleanup-image
