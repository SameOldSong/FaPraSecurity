#!/bin/bash


#ed25519 was required for our initial setup with user-password authentication
#website authenticates with certificates, without password
#Seafile does not support ed25519, only mysql_native_password
#echo "INSTALLING ed25519 AUTHENTICATION module for Mariadb"
#kathara exec database -- mariadb -e "INSTALL SONAME 'auth_ed25519';"


echo "CREATING DATABASE for web app"
kathara exec database -- mariadb -e "CREATE DATABASE fapraweb;"
kathara exec database -- mariadb -e "CREATE TABLE fapraweb.quotes(item_id INT AUTO_INCREMENT, quote VARCHAR(255), PRIMARY KEY(item_id));"

echo "ADDING CONTENT to web app database"
kathara exec database -- mariadb -e "INSERT INTO fapraweb.quotes (quote) VALUES('A clean house is a sign of a wasted life');"
kathara exec database -- mariadb -e "INSERT INTO fapraweb.quotes (quote) VALUES('It turns out being an adult is mostly just googling how to do stuff');"
kathara exec database -- mariadb -e "INSERT INTO fapraweb.quotes (quote) VALUES('Nothing makes a person more productive than the last minute');"
kathara exec database -- mariadb -e "INSERT INTO fapraweb.quotes (quote) VALUES('Before you marry a person, you should first make them use a computer with slow Internet to see who they really are');"
kathara exec database -- mariadb -e "INSERT INTO fapraweb.quotes (quote) VALUES('Laugh a lot. It burns a lot of calories');"
kathara exec database -- mariadb -e "INSERT INTO fapraweb.quotes (quote) VALUES('Do not take life too seriously. You will never get out of it alive');"



echo "CREATING USER for web app"
#kathara exec database -- mariadb -e "CREATE USER fapraweb@192.168.1.12 IDENTIFI#ED VIA ed25519 USING PASSWORD('%gQ-22Fa?Wh5');"

kathara exec database -- mariadb -e "CREATE USER 'fapraweb'@'192.168.1.12';"
kathara exec database -- mariadb -e "GRANT ALL PRIVILEGES ON fapraweb.* TO 'fapraweb'@'192.168.1.12' REQUIRE X509;"

kathara exec database -- mariadb -e "FLUSH PRIVILEGES;"

echo "OPENSSL installation"
kathara exec database -- apt-get -o Dpkg::Options::="--force-confold" -y install openssl

echo "FOLDER for certificates"
kathara exec database -- /bin/bash -c "mkdir -p /etc/my.cnf.d/certificates"

echo "Create CA private key"
kathara exec database -- /bin/bash -c "cd /etc/my.cnf.d/certificates; openssl genrsa 4096 > ca-key.pem"

echo "Create CA CERTIFICATE"
kathara exec database -- /bin/bash -c "cd /etc/my.cnf.d/certificates; openssl req -new -x509 -nodes -days 365 -key ca-key.pem -out ca.pem -subj '/C=DE/ST=BW/L=Stuttgart/O=FaPra/CN=database'"

echo "Create MARIADB private key"
kathara exec database -- /bin/bash -c "cd /etc/my.cnf.d/certificates; openssl req -newkey rsa:4096 -days 365 -nodes -keyout dbserver-key.pem -out dbserver-req.pem -subj '/C=DE/ST=BW/L=Stuttgart/O=FaPra/CN=maria'"

kathara exec database -- /bin/bash -c "cd /etc/my.cnf.d/certificates; openssl rsa -in dbserver-key.pem -out dbserver-key.pem"

echo "Create MariaDB CERTIFICATE"

kathara exec database -- /bin/bash -c "cd /etc/my.cnf.d/certificates; openssl x509 -req -in dbserver-req.pem -days 365 -CA ca.pem -CAkey ca-key.pem -set_serial 01 -out dbserver-cert.pem"

echo "Set certificates PERMISSIONS and ownership"

kathara exec database -- chown -R mysql:mysql /etc/my.cnf.d
kathara exec database -- chmod 600 /etc/my.cnf.d/certificates/ca-key.pem
kathara exec database -- chmod 600 /etc/my.cnf.d/certificates/dbserver-key.pem
kathara exec database -- chmod 644 /etc/my.cnf.d/certificates/ca.pem
kathara exec database -- chmod 644 /etc/my.cnf.d/certificates/dbserver-cert.pem

echo "Change MARIADB configuration"
kathara exec database -- apt-get -o Dpkg::Options::="--force-confold" -y install git
kathara exec database -- /bin/bash -c "git clone https://github.com/SameOldSong/FaPraSecurity.git;cp FaPraSecurity/mariadb/50-server.cnf /etc/mysql/mariadb.conf.d/; rm -r FaPraSecurity"


kathara exec database -- service mariadb restart

echo "OPENSSH SERVER installation for certificates transfer to webserver"

kathara exec database -- apt-get -yq -o Dpkg::Options::="--force-confold" dist-upgrade 
kathara exec database -- /bin/bash -c "TERM=linux DEBIAN_FRONTEND=noninteractive apt-get install -yq -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold'  openssh-server"

echo "START SSH service"
kathara exec database -- service ssh start

echo "TEMPORARY USER for SCP to webserver"
kathara exec database -- useradd -m scpu
kathara exec database -- sh -c "echo 'scpu:scppwd' |  chpasswd"

kathara exec database -- cp /etc/my.cnf.d/certificates/ca.pem /home/scpu/
kathara exec database -- cp /etc/my.cnf.d/certificates/ca-key.pem /home/scpu/
kathara exec database -- chown -R scpu /home/scpu

