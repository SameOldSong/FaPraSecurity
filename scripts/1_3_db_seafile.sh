#!/bin/bash


echo "CREATING DB USER for seafile"
kathara exec database -- mariadb -e "CREATE USER 'seafile'@'192.168.1.11' IDENTIFIED BY 'N0=22Sy-Fa?42';"

echo "CREATING DATABASES for seafile"
kathara exec database -- mariadb -e "create database ccnet_db character set = utf8;"
kathara exec database -- mariadb -e "create database seafile_db character set = utf8;"
kathara exec database -- mariadb -e "create database seahub_db character set = utf8;"

echo "PERMISSIONS for seafile user"

kathara exec database -- mariadb -e "GRANT ALL PRIVILEGES ON ccnet_db.* to 'seafile'@'192.168.1.11';"
kathara exec database -- mariadb -e "GRANT ALL PRIVILEGES ON seafile_db.* to 'seafile'@'192.168.1.11';"
kathara exec database -- mariadb -e "GRANT ALL PRIVILEGES ON seahub_db.* to 'seafile'@'192.168.1.11';"

kathara exec database -- mariadb -e "FLUSH PRIVILEGES;"





 
 
