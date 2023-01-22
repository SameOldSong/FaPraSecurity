#!/bin/bash


echo "ADJUSTING  IPTABLES on DATABASE server"
kathara exec database -- iptables -A INPUT -p tcp --dport 3306 -s 192.168.1.12 -j ACCEPT
 
kathara exec database -- iptables -A INPUT -p tcp --dport 3306 -s 192.168.1.11 -j ACCEPT

kathara exec database -- iptables -A OUTPUT -p tcp --sport 3306 -d 192.168.1.11 -m state --state ESTABLISHED -j ACCEPT

kathara exec database -- iptables -A OUTPUT -p tcp --sport 3306 -d 192.168.1.12 -m state --state ESTABLISHED -j ACCEPT

kathara exec database -- iptables -P OUTPUT DROP
kathara exec database -- iptables -P INPUT DROP
kathara exec database -- iptables -P FORWARD DROP



echo "PERSISTING  IPTABLES on DATABASE server"
kathara exec database -- /bin/sh -c "/sbin/iptables-save > /etc/iptables/rules.v4"






 
 
