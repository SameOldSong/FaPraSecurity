#!/bin/bash

echo "UPGRADING apt-get"
kathara exec server2 -- apt-get update -y
kathara exec server2 -- apt-get upgrade -y

echo "TOOLS"
kathara exec server2 -- apt-get -o Dpkg::Options::="--force-confold" -y install wget make systemctl

echo "LIBRARIES"
kathara exec server2 -- apt-get -o Dpkg::Options::="--force-confold" -y install gcc libpcre3-dev zlib1g-dev libluajit-5.1-dev libpcap-dev libssl-dev libnghttp2-dev libdumbnet-dev bison flex libdnet autoconf libtool

echo "Download and untar  DAQ"
kathara exec server2 -- /bin/bash -c "mkdir -p  /usr/src/snort"
kathara exec server2 -- /bin/bash -c "cd /usr/src/snort; wget https://www.snort.org/downloads/snort/daq-2.0.7.tar.gz;tar -xvzf daq-2.0.7.tar.gz;"

echo "Build DAQ"
kathara exec server2 -- /bin/bash -c "cd /usr/src/snort/daq-2.0.7;autoreconf -f -i;./configure; make; make install;"


echo "Download and untar  SNORT"
kathara exec server2 -- /bin/bash -c "cd /usr/src/snort; wget https://www.snort.org/downloads/snort/snort-2.9.20.tar.gz;tar -xvzf snort-2.9.20.tar.gz;"

"Build SNORT"
kathara exec server2 -- /bin/bash -c "cd /usr/src/snort/snort-2.9.20;./configure --enable-sourcefire; make; make install; ldconfig; ln -s /usr/local/bin/snort /usr/sbin/snort"

echo "Download SUBSCRIBER rules"

kathara exec server2 -- /bin/bash -c "cd /usr/src/snort/; wget https://snort.org/rules/snortrules-snapshot-29200.tar.gz?oinkcode=58a38f1a63dd54f466e80aa0e6d1170dc28a70d1 -O subscriber.tar.gz; tar -xvf /usr/src/snort/subscriber.tar.gz"

echo "Create SNORT DIRECTORIES and COPY SUBSCRIBER rules"

kathara exec server2 -- /bin/bash -c "mkdir -p /etc/snort/rules; cp -r /usr/src/snort/rules/* /etc/snort/rules; mkdir -p /etc/snort/so_rules; cp -r /usr/src/snort/so_rules/* /etc/snort/so_rules; mkdir -p /etc/snort/preproc_rules; cp -r /usr/src/snort/preproc_rules/* /etc/snort/preproc_rules; mkdir /var/log/snort; cp -r /usr/src/snort/etc/* /etc/snort/"

echo "GIT installation"
kathara exec server2 -- apt-get -o Dpkg::Options::="--force-confold" -y install git

echo "Copy CONFIG files FROM GIT"
kathara exec server2 -- /bin/bash -c "git clone https://github.com/SameOldSong/FaPraSecurity.git;cp FaPraSecurity/snort/snort.conf /etc/snort/; cp FaPraSecurity/snort/snort.service /lib/systemd/system/; rm -r FaPraSecurity;"

echo "SNORT AS SERVICE"

echo "SNORT USER"
kathara exec server2 -- /bin/bash -c "groupadd snort; useradd snort -r -s /sbin/nologin -c SNORT_IDS -g snort; chmod -R 5775 /etc/snort; chmod -R 5775 /var/log/snort; chown -R snort:snort /etc/snort; chown -R snort:snort /var/log/snort"

echo "SYSTEMCTL"
kathara exec server2 -- apt-get -o Dpkg::Options::="--force-confold" -y install systemctl

echo "START SNORT"
kathara exec server2 -- systemctl daemon-reload
kathara exec server2 -- systemctl start snort

echo "ENABLE SNORT"
kathara exec server2 -- systemctl enable snort
