#!/bin/bash

PUBLIC_IP=true
CLIENT_CONF=myproject

PAM=true

ROUTE=true
#NET=<network_ip>
NET=$(ipcalc -n $(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}') | cut -f2 -d'=')
#NETMASK=<network_mask>
NETMASK=$(ipcalc -m $(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}') | cut -f2 -d'=')

NAME=server
CN=example.com
COUNTRY=country
PROVINCE=province
CITY=city
ORG=org
EMAIL=myemail@example.com
OU=ou

VPNNET=10.8.0.0
