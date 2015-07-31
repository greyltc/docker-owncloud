ocpath='/usr/share/webapps/owncloud'
htuser='http'
htgroup='http'
find ${ocpath}/ -type f -print0 | xargs -0 chmod 0640
find ${ocpath}/ -type d -print0 | xargs -0 chmod 0750
chown -R root:${htuser} ${ocpath}/
chown -R ${htuser}:${htgroup} ${ocpath}/apps/
chown -R ${htuser}:${htgroup} ${ocpath}/config/
chown -R ${htuser}:${htgroup} ${ocpath}/data/ || true
chown -R ${htuser}:${htgroup} ${ocpath}/themes/
chown root:${htuser} ${ocpath}/.htaccess
chown root:${htuser} ${ocpath}/data/.htaccess || true
chmod 0644 ${ocpath}/.htaccess
chmod 0644 ${ocpath}/data/.htaccess || true
