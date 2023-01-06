#!/bin/bash

echo "UPGRADING apt-get"
kathara exec webserver -- apt-get update -y
kathara exec webserver -- apt-get upgrade -y

echo "IPTABLES-PERSISTENT"
kathara exec webserver -- apt-get -o Dpkg::Options::="--force-confold" -y install iptables-persistent

###kathara exec webserver -- sh -c "useradd-s /bin/bash -m -d /home/fapraweb fapraweb;usermod -aG sudo fapraweb"

#####kathara exec webserver -- sh -c "useradd fapraweb; echo 'fapraweb:h3-fA22§Wh-y' | chpasswd;usermod -aG sudo fapraweb"

echo "NODEJS"
kathara exec webserver -- apt-get -o Dpkg::Options::="--force-confold" -y install nodejs

echo "NPM"
kathara exec webserver -- apt-get -o Dpkg::Options::="--force-confold" -y install npm

echo "NPM PACKAGES"
kathara exec webserver -- sh -c "mkdir -p /var/www/fapraweb"
kathara exec webserver -- sh -c "cd /var/www/fapraweb;npm install express mariadb"
kathara exec webserver -- sh -c "npm install pm2 -g"

echo "INSTALL GIT"
kathara exec webserver -- apt-get -o Dpkg::Options::="--force-confold" -y install git

echo "DOWNLOAD WEB PROJECT FROM GIT"
kathara exec webserver -- sh -c "cd /var/www; git clone https://github.com/SameOldSong/FaPraSecurity.git;cp -r FaPraSecurity/* /var/www/fapraweb/;rm -r FaPraSecurity"

kathara exec webserver -- sh -c "chmod u+x /var/www/fapraweb/index.js;chmod u+x /var/www/fapraweb/public/client.js;"

kathara exec webserver -- sh -c "cd /var/www/fapraweb; DB_HOST=192.168.1.13 DB_USER=fapraweb DB_PWD=%gQ-22Fa?Wh5 pm2 start index.js --update-env"

