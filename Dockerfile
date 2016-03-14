FROM greyltc/lamp
MAINTAINER Grey Christoforo <grey@christoforo.net>
# Report issues with this to the GitHub project: https://github.com/l3iggs/docker-owncloud/issues
# Say thanks by adding a star or a comment here: https://registry.hub.docker.com/u/l3iggs/owncloud/
# and/or staring the project on GitHub

# set environmnt variable defaults
ENV MAX_UPLOAD_SIZE 30G
ENV TARGET_SUBDIR owncloud
ENV OC_VERSION '*'

# do the install things
ADD install-ownCloud.sh /usr/sbin/install-owncloud
RUN install-owncloud

# add our config.php stub
ADD configs/oc-config.php /usr/share/webapps/owncloud/config/config.php

# add our cron stub
ADD configs/oc-cron.conf /etc/cron.d/oc-cron.conf

# expose some important directories as volumes
VOLUME ["/usr/share/webapps/owncloud/data:Z"]
VOLUME ["/etc/webapps/owncloud/config:Z"]
VOLUME ["/usr/share/webapps/owncloud/apps:Z"]

# place your ssl cert files in here. name them server.key and server.crt
VOLUME ["/root/sslKeys:Z"]

# fox up some permissions
# script lifted from here:
# https://doc.owncloud.org/server/9.0/admin_manual/installation/installation_wizard.html#setting-strong-directory-permissions
ADD fixPerms.sh /usr/sbin/fix-oc-perms
RUN fix-oc-perms

# start the servers, then wait forever
CMD start-servers; sleep infinity
