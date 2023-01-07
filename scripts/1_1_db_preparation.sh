#!/bin/bash

kathara exec routerdmz -- iptables -t nat -A POSTROUTING -j MASQUERADE 

echo "UPGRADING apt-get"
kathara exec database -- apt-get update -y
kathara exec database -- apt-get upgrade -y

echo "SYSTEMCTL"
kathara exec database -- apt-get -o Dpkg::Options::="--force-confold" -y install systemctl

echo "IPTABLES-PERSISTENT"
kathara exec database -- apt-get -o Dpkg::Options::="--force-confold" -y install iptables-persistent


echo "MARIADB INSTALLATION"
kathara exec database -- apt-get -o Dpkg::Options::="--force-confold" -y install mariadb-server

echo "MARIADB START"
kathara exec database -- service mariadb start
kathara exec database -- systemctl enable mariadb

echo "MARIADB SECURITY"
kathara exec database -- mariadb -e "DELETE FROM mysql.user WHERE User='';"

kathara exec database -- mariadb -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"

kathara exec database -- mariadb -e "DROP DATABASE IF EXISTS test;"

kathara exec database -- mariadb -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"

kathara exec database -- mariadb -e "FLUSH PRIVILEGES;"

