#!/bin/bash

echo "UPGRADING apt-get"
kathara exec webserver -- apt-get update -y
kathara exec webserver -- apt-get upgrade -y

echo "GIT installation"
kathara exec webserver -- apt-get -o Dpkg::Options::="--force-confold" -y install git

echo "NODEJS installation"
kathara exec webserver -- apt-get -o Dpkg::Options::="--force-confold" -y install nodejs

echo "NPM installation"
kathara exec webserver -- apt-get -o Dpkg::Options::="--force-confold" -y install npm

#workaround. For some reason, npm throws error at first installation, but fixes it at second run (problem with systemd)
kathara exec webserver -- dpkg --configure -a 
kathara exec webserver -- apt-get -o Dpkg::Options::="--force-confold" -y install nodejs
kathara exec webserver -- apt-get -o Dpkg::Options::="--force-confold" -y install npm

echo "NPM PACKAGES"
kathara exec webserver -- sh -c "mkdir -p /var/www/fapraweb"
kathara exec webserver -- sh -c "cd /var/www/fapraweb;npm install express mariadb fs https"
kathara exec webserver -- sh -c "npm install pm2 -g"



echo "DOWNLOAD WEB PROJECT FROM GIT"
kathara exec webserver -- sh -c "cd /var/www; git clone https://github.com/SameOldSong/FaPraSecurity.git;cp -r FaPraSecurity/webapp/* /var/www/fapraweb/;rm -r FaPraSecurity"

kathara exec webserver -- sh -c "chmod u+x /var/www/fapraweb/index.js;chmod u+x /var/www/fapraweb/public/client.js;"



echo "COPY CA CERTIFICATE from database server"

kathara exec webserver -- apt-get -o Dpkg::Options::="--force-confold" -y install sshpass
kathara exec webserver -- sshpass -p 'scppwd' scp -o StrictHostKeyChecking=no scpu@192.168.1.13:/home/scpu/ca.pem /etc/ssl/certs/
kathara exec webserver -- sshpass -p 'scppwd' scp -o StrictHostKeyChecking=no scpu@192.168.1.13:/home/scpu/ca-key.pem /etc/ssl/private/


echo "Create WEBSERVER private key for MariaDB"
kathara exec webserver -- /bin/bash -c "cd  /etc/ssl/private/; openssl req -newkey rsa:4096 -days 365 -nodes -keyout dbclient-key.pem -out dbclient-req.pem -subj '/C=DE/ST=BW/L=Stuttgart/O=FaPra/CN=webserver'"

kathara exec webserver -- /bin/bash -c "cd  /etc/ssl/private/; openssl rsa -in dbclient-key.pem -out dbclient-key.pem"

echo "Create WEBSERVER CERTIFICATE for MariaDB"

kathara exec webserver -- /bin/bash -c "cd  /etc/ssl/certs/; openssl x509 -req -in /etc/ssl/private/dbclient-req.pem -days 365 -CA /etc/ssl/certs/ca.pem -CAkey /etc/ssl/private/ca-key.pem -set_serial 01 -out dbclient-cert.pem"

echo "Set certificates PERMISSIONS and ownership"

kathara exec webserver -- chmod 600  /etc/ssl/private/ca-key.pem
kathara exec webserver -- chmod 600  /etc/ssl/private/dbclient-key.pem
kathara exec webserver -- chmod 644  /etc/ssl/certs/ca.pem
kathara exec webserver -- chmod 644  /etc/ssl/certs/dbclient-cert.pem

echo "CLEAN UP scp user and temp certificates on DATABASE server"
kathara exec database -- /bin/bash -c  "rm -r /home/scpu/*"
kathara exec database -- /bin/bash -c  "deluser scpu"




echo "START WEB APP"
kathara exec webserver -- /bin/bash -c "cd /var/www/fapraweb; pm2 start index.js"

echo "CERTIFICATE for HAPROXY"
kathara exec webserver -- /bin/bash -c "openssl req -x509 -newkey rsa:4096 -keyout /etc/ssl/private/webkey.pem -out /etc/ssl/certs/webcert.pem -sha256 -nodes -days 30 -subj '/C=DE/ST=BW/L=Stuttgart/O=FaPra/CN=webserver'"

kathara exec webserver -- chmod 644 /etc/ssl/certs/webcert.pem
kathara exec webserver -- chmod 600 /etc/ssl/private/webkey.pem


echo "Install OPENSSH to enable HAPROXY to copy certificate"

#weird workaround that somehow works around error setting up systemd
kathara exec webserver -- apt-get -yq -o Dpkg::Options::="--force-confold" dist-upgrade
kathara exec webserver -- /bin/bash -c "TERM=linux DEBIAN_FRONTEND=noninteractive apt-get install -yq -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold'  openssh-server"

echo "START SSH service"
kathara exec webserver -- service ssh start

echo "TEMPORARY USER for SCP to copy stuff to HAPROXY"
kathara exec webserver -- useradd -m scpu
kathara exec webserver -- sh -c "echo 'scpu:scppwd' |  chpasswd"

kathara exec webserver -- cp /etc/ssl/certs/webcert.pem /home/scpu/
kathara exec webserver -- chown -R scpu /home/scpu
kathara exec webserver -- chmod 755 -R /home/scpu
