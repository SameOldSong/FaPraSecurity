#!/bin/bash

echo "UPGRADING apt-get"
kathara exec webserver -- apt-get update -y
kathara exec webserver -- apt-get upgrade -y


echo "NODEJS installation"
kathara exec webserver -- apt-get -o Dpkg::Options::="--force-confold" -y install nodejs

echo "NPM installation"
kathara exec webserver -- apt-get -o Dpkg::Options::="--force-confold" -y install npm

echo "NPM PACKAGES"
kathara exec webserver -- sh -c "mkdir -p /var/www/fapraweb"
kathara exec webserver -- sh -c "cd /var/www/fapraweb;npm install express mariadb fs https"
kathara exec webserver -- sh -c "npm install pm2 -g"

echo "GIT installation"
kathara exec webserver -- apt-get -o Dpkg::Options::="--force-confold" -y install git

echo "DOWNLOAD WEB PROJECT FROM GIT"
kathara exec webserver -- sh -c "cd /var/www; git clone https://github.com/SameOldSong/FaPraSecurity.git;cp -r FaPraSecurity/webapp/* /var/www/fapraweb/;rm -r FaPraSecurity"

kathara exec webserver -- sh -c "chmod u+x /var/www/fapraweb/index.js;chmod u+x /var/www/fapraweb/public/client.js;"

kathara exec webserver -- sh -c "cd /var/www/fapraweb; DB_HOST=192.168.1.13 DB_USER=fapraweb DB_PWD=%gQ-22Fa?Wh5 pm2 start index.js --update-env"

