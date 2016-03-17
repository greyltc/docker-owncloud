FROM greyltc/lamp-aur
MAINTAINER Grey Christoforo <grey@christoforo.net>
# Report issues with this to the GitHub project: https://github.com/l3iggs/docker-owncloud/issues
# Say thanks by adding a star or a comment here: https://registry.hub.docker.com/u/l3iggs/owncloud/
# and/or staring the project on GitHub

# set environmnt variable defaults
ENV TARGET_SUBDIR owncloud
ENV ALLOW_INSECURE false
ENV OC_VERSION '*'

# add owncloud permissions setting/fixing script
ADD setPerms.sh /usr/sbin/set-oc-perms

# do the install things
ADD installOwnCloud.sh /usr/sbin/install-owncloud
RUN install-owncloud

# add our config.php stub
ADD configs/config.php /usr/share/webapps/owncloud/config/config.php
RUN chown http:http /usr/share/webapps/owncloud/config/config.php; \
    chmod 0640 /usr/share/webapps/owncloud/config/config.php

# add our cron stub
ADD configs/cron.conf /etc/cron.d/owncloud

# add our apache config stub
ADD configs/apache.conf /etc/httpd/conf/extra/owncloud.conf

# expose some important directories as volumes
#VOLUME ["/usr/share/webapps/owncloud/data"]
#VOLUME ["/etc/webapps/owncloud/config"]
#VOLUME ["/usr/share/webapps/owncloud/apps"]

# place your ssl cert files in here. name them server.key and server.crt
#VOLUME ["/root/sslKeys"]

# start the servers, then wait forever
CMD start-servers; sleep infinity
