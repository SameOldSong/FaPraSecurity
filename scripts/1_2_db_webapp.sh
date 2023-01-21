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
kathara exec database -- mkdir -p /etc/my.cnf.d/certificates/

echo "Create CA KEYS"
kathara exec database -- /bin/bash -c "cd /etc/my.cnf.d/certificates/; openssl genrsa 4096 > ca-key.pem"


kathara exec server1 -- /bin/bash -c "echo -e 'frontend fapraweb\n  bind :80\n  mode http\n  acl url_fapraweb path /fapraweb\n  default_backend fapraweb_webserver\n  use_backend fapraweb_webserver if url_fapraweb\n  redirect code 301 location / if url_fapraweb\n\nbackend fapraweb_webserver\n  mode http\n  balance roundrobin\n  server webserver1 192.168.1.12:5000'  >> /etc/haproxy/haproxy.cfg"


kathara exec database -- service mariadb restart

