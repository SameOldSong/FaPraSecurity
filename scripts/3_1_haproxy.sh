#!/bin/bash

echo "UPGRADING apt-get"
kathara exec server1 -- apt-get update -y
kathara exec server1 -- apt-get upgrade -y

echo "HAPROXY INSTALL"
kathara exec server1 -- apt-get -o Dpkg::Options::="--force-confold" -y install haproxy


echo "HAPROXY DOWNLOAD CONFIG file from Git"

kathara exec server1 --  apt-get -o Dpkg::Options::="--force-confold" -y install git

kathara exec server1 -- /bin/bash -c "git clone https://github.com/SameOldSong/FaPraSecurity.git;cp FaPraSecurity/haproxy.cfg /etc/haproxy/;rm -r FaPraSecurity"

echo "HAPROXY generate CERTIFICATE for WEB CLIENT"

kathara exec server1 -- /bin/bash -c "openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -sha256 -nodes -days 30 -subj '/C=DE/ST=BW/L=Stuttgart/O=FaPra/CN=server1'; cat cert.pem key.pem > /etc/ssl/private/full_ha.pem; chmod -R 644 /etc/ssl/private/full_ha.pem; rm cert.pem; rm key.pem"

echo "COPY CERTIFICATE from webserver"
kathara exec server1 -- apt-get -o Dpkg::Options::="--force-confold" -y install sshpass
kathara exec server1 -- sshpass -p 'scppwd' scp -o StrictHostKeyChecking=no scpu@192.168.1.12:/home/scpu/webcert.pem /etc/ssl/certs/

kathara exec server1 -- chmod 644 /etc/ssl/certs/webcert.pem


echo "CLEAN UP scp user and temp certificates on WEBSERVER"
kathara exec webserver -- /bin/bash -c  "rm -r /home/scpu/*"
kathara exec webserver -- /bin/bash -c  "deluser scpu"




kathara exec server1 -- service haproxy restart






