#!/bin/bash

echo "UPGRADING apt-get"
kathara exec server1 -- apt-get update -y
kathara exec server1 -- apt-get upgrade -y

echo "IPTABLES-PERSISTENT"
kathara exec server1 -- apt-get -o Dpkg::Options::="--force-confold" -y install iptables-persistent

echo "HAPROXY INSTALL"
kathara exec server1 -- apt-get -o Dpkg::Options::="--force-confold" -y install haproxy


echo "HAPROXY CONFIGURE ROUTING TO WEBSERVER"

kathara exec server1 -- /bin/bash -c "echo -e 'frontend fapraweb\n  bind :80\n  mode http\n  acl url_fapraweb path /fapraweb\n  default_backend fapraweb_webserver\n  use_backend fapraweb_webserver if url_fapraweb\n  redirect code 301 location / if url_fapraweb\n\nbackend fapraweb_webserver\n  mode http\n  balance roundrobin\n  server webserver1 192.168.1.12:5000'  >> /etc/haproxy/haproxy.cfg"

kathara exec server1 -- service haproxy restart


echo "FORWARDING OVER ROUTERDMZ"
port=80
server=192.168.1.10
echo "Forwarding PORT ${port} on ROUTERDMZ to SERVER ${server}"

kathara exec routerdmz -- iptables -A FORWARD -i eth1 -o eth0 -p tcp --syn --dport $port -m conntrack --ctstate NEW -j ACCEPT

kathara exec routerdmz -- iptables -A FORWARD -i eth0 -o eth1 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

kathara exec routerdmz -- iptables -t nat -A PREROUTING -i eth1 -p tcp --dport $port -j DNAT --to-destination $server

kathara exec server1 -- service haproxy restart


#echo "ADJUSTING  IPTABLES"
#kathara exec server1 -- iptables -A INPUT -p tcp --dport 80 -s 192.168.1.1 -j ACCEPT

#kathara exec server1 -- iptables -A INPUT -p tcp --sport 5000 -s 192.168.1.12 -j ACCEPT

#kathara exec server1 -- iptables -A OUTPUT -p tcp --sport 80 -d 192.168.1.11 -m state --state ESTABLISHED -j ACCEPT

#kathara exec server1 -- iptables -A OUTPUT -p tcp --sport 3306 -d 192.168.1.12 -m state --state ESTABLISHED -j ACCEPT

#kathara exec server1 -- iptables -P OUTPUT DROP
#kathara exec server1 -- iptables -P INPUT DROP
#kathara exec server1 -- iptables -P FORWARD DROP


#echo "PERSISTING  IPTABLES"
#kathara exec server1 -- /bin/sh -c "iptables-save > /etc/iptables/rules.v4"
