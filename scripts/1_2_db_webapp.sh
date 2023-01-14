#!/bin/bash

echo "INSTALLING ed25519 AUTHENTICATION module for Mariadb"
kathara exec database -- mariadb -e "INSTALL SONAME 'auth_ed25519';"

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
kathara exec database -- mariadb -e "CREATE USER fapraweb@192.168.1.12 IDENTIFIED VIA ed25519 USING PASSWORD('%gQ-22Fa?Wh5');"

kathara exec database -- mariadb -e "GRANT ALL ON fapraweb.* TO 'fapraweb'@'192.168.1.12' IDENTIFIED BY '%gQ-22Fa?Wh5' WITH GRANT OPTION;"
kathara exec database -- mariadb -e "FLUSH PRIVILEGES;"

echo "ALLOWING REMOTE ACCESS to Mariadb"
kathara exec database -- sed -i 's/bind-address/#bind-address/g' /etc/mysql/mariadb.conf.d/50-server.cnf

kathara exec database -- service mariadb restart

