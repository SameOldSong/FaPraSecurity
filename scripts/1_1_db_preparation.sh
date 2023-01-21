#!/bin/bash

echo "UPGRADING apt-get"
kathara exec database -- apt-get update -y
kathara exec database -- apt-get upgrade -y

echo "SYSTEMCTL"
kathara exec database -- apt-get -o Dpkg::Options::="--force-confold" -y install systemctl


echo "MARIADB INSTALLATION"
kathara exec database -- apt-get -o Dpkg::Options::="--force-confold" -y install mariadb-server

echo "ALLOWING REMOTE ACCESS to Mariadb"
kathara exec database -- sed -i 's/bind-address/#bind-address/g' /etc/mysql/mariadb.conf.d/50-server.cnf

echo "MARIADB START"
kathara exec database -- service mariadb start
kathara exec database -- systemctl enable mariadb

echo "MARIADB Remove anonymous accounts"
kathara exec database -- mariadb -e "DELETE FROM mysql.user WHERE User='';"

echo "MARIADB Remove remote roots"
kathara exec database -- mariadb -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"

echo "MARIADB Remove test database"
kathara exec database -- mariadb -e "DROP DATABASE IF EXISTS test;"

kathara exec database -- mariadb -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"

kathara exec database -- mariadb -e "FLUSH PRIVILEGES;"

echo "MARIADB Restart"
kathara exec database -- service mariadb restart
