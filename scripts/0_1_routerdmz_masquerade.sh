#!/bin/bash

kathara exec routerdmz -- iptables -t nat -A POSTROUTING -j MASQUERADE 
