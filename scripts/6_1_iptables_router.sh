#!/bin/bash


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
