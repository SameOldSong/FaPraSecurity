#!/bin/bash


echo "FORWARDING OVER ROUTERDMZ"
port=80
server=192.168.1.10
echo "Forwarding PORT ${port} on ROUTERDMZ to SERVER ${server}"

kathara exec routerdmz -- iptables -A FORWARD -i eth1 -o eth0 -p tcp --syn --dport $port -m conntrack --ctstate NEW -j ACCEPT

kathara exec routerdmz -- iptables -A FORWARD -i eth0 -o eth1 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

kathara exec routerdmz -- iptables -t nat -A PREROUTING -i eth1 -p tcp --dport $port -j DNAT --to-destination $server

kathara exec server1 -- service haproxy restart




#echo "PERSISTING  IPTABLES"
#kathara exec server1 -- /bin/sh -c "iptables-save > /etc/iptables/rules.v4"
