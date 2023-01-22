#!/bin/bash


echo "IPTABLES-PERSISTENT"
kathara exec webserver -- apt-get -o Dpkg::Options::="--force-confold" -y install iptables-persistent
