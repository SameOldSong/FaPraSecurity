#!/bin/bash

echo "UPGRADING apt-get"
kathara exec webserver -- apt-get update -y
kathara exec webserver -- apt-get upgrade -y

echo "GIT installation"
kathara exec webserver -- apt-get -o Dpkg::Options::="--force-confold" -y install git

echo "NODEJS installation"
kathara exec webserver -- apt-get -o Dpkg::Options::="--force-confold" -y install nodejs

#workaround. For some reason, nodejs throws error at first installation, but fixes it at second run (problem with systemd)
kathara exec webserver -- apt-get -o Dpkg::Options::="--force-confold" -y install nodejs

echo "NPM installation"
kathara exec webserver -- apt-get -o Dpkg::Options::="--force-confold" -y install npm

echo "NPM PACKAGES"
kathara exec webserver -- sh -c "mkdir -p /var/www/fapraweb"
kathara exec webserver -- sh -c "cd /var/www/fapraweb;npm install express mariadb fs https"
kathara exec webserver -- sh -c "npm install pm2 -g"



echo "DOWNLOAD WEB PROJECT FROM GIT"
kathara exec webserver -- sh -c "cd /var/www; git clone https://github.com/SameOldSong/FaPraSecurity.git;cp -r FaPraSecurity/webapp/* /var/www/fapraweb/;rm -r FaPraSecurity"

kathara exec webserver -- sh -c "chmod u+x /var/www/fapraweb/index.js;chmod u+x /var/www/fapraweb/public/client.js;"

#kathara exec webserver -- sh -c "cd /var/www/fapraweb; DB_HOST=192.168.1.13 DB_USER=fapraweb DB_PWD=%gQ-22Fa?Wh5 pm2 start index.js --update-env"

echo "COPY CA CERTIFICATE from database server"

kathara exec webserver -- apt-get -o Dpkg::Options::="--force-confold" -y install sshpass
kathara exec webserver -- sshpass -p 'scppwd' scp scpu@192.168.1.13:/home/scpu/* /etc/ssl/certs/




echo "Create WEBSERVER private key for MariaDB"
kathara exec database -- /bin/bash -c "cd  /etc/ssl/certs/; openssl req -newkey rsa:4096 -days 365 -nodes -keyout dbclient-key.pem -out dbclient-req.pem -subj '/C=DE/ST=BW/L=Stuttgart/O=FaPra/CN=webserver'"

kathara exec database -- /bin/bash -c "cd  /etc/ssl/certs/; openssl rsa -in dbclient-key.pem -out dbclient-key.pem"

echo "Create WEBSERVER CERTIFICATE for MariaDB"

kathara exec database -- /bin/bash -c "cd  /etc/ssl/certs/; openssl x509 -req -in dbclient-req.pem -days 365 -CA ca.pem -CAkey ca-key.pem -set_serial 01 -out dbclient-cert.pem"

echo "Set certificates PERMISSIONS and ownership"

kathara exec database -- chmod 600  /etc/ssl/certs/ca-key.pem
kathara exec database -- chmod 600  /etc/ssl/certs/dbclient-key.pem
kathara exec database -- chmod 644  /etc/ssl/certs/ca.pem
kathara exec database -- chmod 644  /etc/ssl/certs/dbclient-cert.pem
