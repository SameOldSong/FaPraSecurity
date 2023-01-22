#!/bin/bash

echo "UPGRADING apt-get"
kathara exec server2 -- apt-get update -y
kathara exec server2 -- apt-get upgrade -y

echo "PYTHON INSTALL"
kathara exec server2 -- apt-get -o Dpkg::Options::="--force-confold" -y install python3 python3-setuptools python3-pip libmariadb-dev

kathara exec server2 -- apt-get -o Dpkg::Options::="--force-confold" -y install memcached libmemcached-dev libffi-dev

echo "PIP3 Packages"

kathara exec server2 -- /bin/bash -c "pip3 install --timeout=3600 django==3.2.* Pillow pylibmc captcha jinja2 sqlalchemy==1.4.3 django-pylibmc django-simple-captcha python3-ldap mysqlclient pycryptodome==3.12.0 cffi==1.14.0 lxml"

echo "DIRECTORIES and USER for seafile"
kathara exec server2 -- /bin/bash -c "mkdir /opt/seafile; adduser seafile; chown -R seafile: /opt/seafile"

echo "WGET"
kathara exec server2 -- apt-get -o Dpkg::Options::="--force-confold" -y install wget

echo "DOWNLOAD SEAFILE"
kathara exec server2 -- /bin/bash -c "cd /opt/seafile; wget https://download.seadrive.org/seafile-server_9.0.9_x86-64.tar.gz; tar xf seafile-server_9.0.9_x86-64.tar.gz"

echo "NGINX"
kathara exec server2 -- apt-get -o Dpkg::Options::="--force-confold" -y install nginx

kathara exec server2 -- /bin/bash -c "touch /etc/nginx/sites-available/seafile.conf; rm /etc/nginx/sites-enabled/default;rm /etc/nginx/sites-available/default;ln -s /etc/nginx/sites-available/seafile.conf /etc/nginx/sites-enabled/seafile.conf"

echo "OPENSSL CERTIFICATE NGINX SEAFILE"
kathara exec server2 -- apt-get -o Dpkg::Options::="--force-confold" -y install openssl

kathara exec server2 -- /bin/bash -c "openssl req -x509 -newkey rsa:4096 -sha256 -days 365 -nodes -keyout /etc/ssl/private/example.key -out /etc/ssl/private/example.crt -subj '/C=DE/ST=BW/L=Stuttgart/O=FaPra/CN=seafile'"

kathara exec server2 -- chmod 600 /etc/ssl/private/example.cert
kathara exec server2 -- chmod 600 /etc/ssl/private/example.key

echo "GIT"
kathara exec server2 -- apt-get -o Dpkg::Options::="--force-confold" -y install git

echo "Download SEAFILE.CONF for NGINX"
kathara exec server2 -- sh -c " git clone https://github.com/SameOldSong/FaPraSecurity.git;cp FaPraSecurity/seafile/seafile.conf /etc/nginx/sites-available/;rm -r FaPraSecurity"




