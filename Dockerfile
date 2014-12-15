#this is the Arch Linux base
FROM base/devel:latest
MAINTAINER l3iggs <l3iggs@live.com>

# update yaourt db
RUN yaourt -Suya --noconfirm

# install owncloud
RUN pacman -Suy --noconfirm owncloud
