#!/bin/bash



echo "Download and replace COFNIGS for SEAFILE"
kathara exec server2 -- /bin/bash -c "git clone https://github.com/SameOldSong/FaPraSecurity.git;cp FaPraSecurity/seafile/ccnet.conf /opt/seafile/conf/;cp FaPraSecurity/seafile/seahub_settings.py /opt/seafile/conf/; cp FaPraSecurity/seafile/seafilehost.conf /opt/seafile/conf/seafile.conf;  rm -r FaPraSecurity"


echo "START SEAFILE"
kathara exec server2 -- /bin/bash -c "su -l seafile;cd /opt/seafile/seafile-server-latest; ./seafile.sh start"


echo "START SEAHUB"
kathara exec server2 -- /bin/bash -c "su -l seafile;cd /opt/seafile/seafile-server-latest; ./seahub.sh start"

echo "GENERATE Diffie-Helman parameters"
kathara exec server2 -- /bin/bash -c "openssl dhparam 2048 > /etc/nginx/dhparam.pem"

echo "START NGINX"
kathara exec server2 -- service nginx start
