#!/bin/bash
# must run as root

source config.sh

# colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
NC='\033[0m'
# colors

echo -e "${GREEN}Step 1 — Installing OpenVPN${NC}"

yum install -y epel-release
yum install -y vim sed curl wget
yum install -y openvpn easy-rsa

echo -e "${GREEN}Step 2 — Configuring OpenVPN${NC}"

cat << EOF > /etc/openvpn/server.conf
;local a.b.c.d
port 1194
proto udp
dev tun

ca /etc/openvpn/easy-rsa/keys/ca.crt
cert /etc/openvpn/easy-rsa/keys/server.crt
key /etc/openvpn/easy-rsa/keys/server.key
dh /etc/openvpn/easy-rsa/keys/dh2048.pem

server $VPNNET 255.255.255.0
ifconfig-pool-persist ipp.txt

;push "redirect-gateway def1 bypass-dhcp"
;push "dhcp-option DNS 8.8.8.8"
;push "dhcp-option DNS 8.8.4.4"

push "resolv-retry infinite"
push "comp-lzo"
push "cipher AES-256-CBC"

duplicate-cn
keepalive 10 60

cipher AES-256-CBC
comp-lzo
explicit-exit-notify 0
max-clients 30

user nobody
group nobody
persist-key
persist-tun

status     /var/log/openvpn-status.log
log        /var/log/openvpn.log
log-append /var/log/openvpn.log
verb 3
EOF

if $PAM
then
  echo "plugin $(find / -name openvpn-plugin-auth-pam.so) login" >> /etc/openvpn/server.conf
fi

if $ROUTE
then
  echo "push \"route $NET $NETMASK\"" >> /etc/openvpn/server.conf
  echo "topology subnet" >> /etc/openvpn/server.conf
fi

echo -e "${GREEN}Step 3 — Generating Keys and Certificates${NC}"
echo -e "${GREEN}SERVER${NC}"

mkdir -p /etc/openvpn/easy-rsa/keys
cp -rf /usr/share/easy-rsa/2.0/* /etc/openvpn/easy-rsa

sed -i -e 's~^export KEY_NAME="EasyRSA"~export KEY_NAME="'$NAME'"~g' /etc/openvpn/easy-rsa/vars
sed -i -e 's~^# export KEY_CN="CommonName"~export KEY_CN="'$CN'"~g' /etc/openvpn/easy-rsa/vars
sed -i -e 's~^export KEY_COUNTRY="US"~export KEY_COUNTRY="'$COUNTRY'"~g' /etc/openvpn/easy-rsa/vars
sed -i -e 's~^export KEY_PROVINCE="CA"~export KEY_PROVINCE="'$PROVINCE'"~g' /etc/openvpn/easy-rsa/vars
sed -i -e 's~^export KEY_CITY="SanFrancisco"~export KEY_CITY="'$CITY'"~g' /etc/openvpn/easy-rsa/vars
sed -i -e 's~^export KEY_ORG="Fort-Funston"~export KEY_ORG="'$ORG'"~g' /etc/openvpn/easy-rsa/vars
sed -i -e 's~^export KEY_EMAIL="me@myhost.mydomain"~export KEY_EMAIL="'$EMAIL'"~g' /etc/openvpn/easy-rsa/vars
sed -i -e 's~^export KEY_OU="MyOrganizationalUnit"~export KEY_OU="'$OU'"~g' /etc/openvpn/easy-rsa/vars

cp /etc/openvpn/easy-rsa/openssl-1.0.0.cnf /etc/openvpn/easy-rsa/openssl.cnf
cd /etc/openvpn/easy-rsa
source ./vars

./clean-all
# ./build-ca
export EASY_RSA="${EASY_RSA:-.}"
"$EASY_RSA/pkitool" --initca
# ./build-key-server server
export EASY_RSA="${EASY_RSA:-.}"
"$EASY_RSA/pkitool" --server server
./build-dh

#cd /etc/openvpn/easy-rsa/keys
#cp dh2048.pem ca.crt server.crt server.key /etc/openvpn

echo -e "${GREEN}Step 3 — Generating Keys and Certificates${NC}"
echo -e "${GREEN}CLIENT${NC}"

# mkdir -p /etc/openvpn/easy-rsa/keys
# cp -rf /usr/share/easy-rsa/2.0/* /etc/openvpn/easy-rsa
cd /etc/openvpn/easy-rsa

# ./build-key $CLIENT_CONF
echo "unique_subject = no" > keys/index.txt.attr
export EASY_RSA="${EASY_RSA:-.}"
"$EASY_RSA/pkitool" $CLIENT_CONF
echo "unique_subject = yes" > keys/index.txt.attr

echo -e "${GREEN}Step 4 — Routing${NC}"

yum install -y iptables-services
systemctl disable firewalld
systemctl mask firewalld
systemctl stop firewalld
systemctl enable iptables
systemctl start iptables
iptables --flush

iptables -t nat -A POSTROUTING -s $VPNNET/24 -o eth0 -j MASQUERADE
iptables-save > /etc/sysconfig/iptables

echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf

systemctl restart network.service

echo -e "${GREEN}Step 5 — Starting OpenVPN${NC}"
systemctl -f enable openvpn@server.service
systemctl stop openvpn@server.service
systemctl start openvpn@server.service

echo -e "${GREEN}Step 6 — Configuring a Client${NC}"

if $PUBLIC_IP
then
  ip=$(curl ipinfo.io/ip)
else
  ip=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d'/')
fi

cat << EOF > $HOME/$CLIENT_CONF.ovpn
client
dev tun
proto udp
remote $ip 1194
resolv-retry infinite
nobind
persist-key
persist-tun
comp-lzo
verb 3
cipher AES-256-CBC
EOF

if $PAM
then
  echo "auth-user-pass" >> $HOME/$CLIENT_CONF.ovpn
fi

echo "<ca>" >> $HOME/$CLIENT_CONF.ovpn
cat /etc/openvpn/easy-rsa/keys/ca.crt >> $HOME/$CLIENT_CONF.ovpn
echo "</ca>" >> $HOME/$CLIENT_CONF.ovpn
echo "<cert>" >> $HOME/$CLIENT_CONF.ovpn
cat /etc/openvpn/easy-rsa/keys/$CLIENT_CONF.crt >> $HOME/$CLIENT_CONF.ovpn
echo "</cert>" >> $HOME/$CLIENT_CONF.ovpn
echo "<key>" >> $HOME/$CLIENT_CONF.ovpn
cat /etc/openvpn/easy-rsa/keys/$CLIENT_CONF.key >> $HOME/$CLIENT_CONF.ovpn
echo "</key>" >> $HOME/$CLIENT_CONF.ovpn

echo -e "${RED}REVIEW client file location: $HOME/$CLIENT_CONF.ovpn${NC}"
echo -e "${RED}REVIEW server file location: /etc/openvpn/server.conf${NC}"
