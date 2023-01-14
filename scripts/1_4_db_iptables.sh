#!/bin/bash

echo "UPGRADING apt-get"
kathara exec webserver -- apt-get update -y
kathara exec webserver -- apt-get upgrade -y

echo "IPTABLES-PERSISTENT"
kathara exec webserver -- apt-get -o Dpkg::Options::="--force-confold" -y install iptables-persistent

echo "ADJUSTING  IPTABLES"
kathara exec database -- iptables -A INPUT -p tcp --dport 3306 -s 192.168.1.12 -j ACCEPT
 
kathara exec database -- iptables -A INPUT -p tcp --dport 3306 -s 192.168.1.11 -j ACCEPT

kathara exec database -- iptables -A OUTPUT -p tcp --sport 3306 -d 192.168.1.11 -m state --state ESTABLISHED -j ACCEPT

kathara exec database -- iptables -A OUTPUT -p tcp --sport 3306 -d 192.168.1.12 -m state --state ESTABLISHED -j ACCEPT

kathara exec database -- iptables -P OUTPUT DROP
kathara exec database -- iptables -P INPUT DROP
kathara exec database -- iptables -P FORWARD DROP


echo "PERSISTING  IPTABLES"
kathara exec database -- /bin/sh -c "iptables-save > /etc/iptables/rules.v4"






 
 
