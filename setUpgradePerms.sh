#!/usr/bin/env bash
ocpath='/usr/share/webapps/owncloud'
htuser='http'
htgroup='http'
rootuser='root'

chown -R ${htuser}:${htgroup} ${ocpath}
