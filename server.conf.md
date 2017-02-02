# OpenVPN server configuration file server.conf

* Default configuration

```
;local a.b.c.d
port 1194
proto udp
dev tun

ca /etc/openvpn/easy-rsa/keys/ca.crt
cert /etc/openvpn/easy-rsa/keys/server.crt
key /etc/openvpn/easy-rsa/keys/server.key
dh /etc/openvpn/easy-rsa/keys/dh2048.pem
;tls-auth ta.key 0

server 10.8.0.0 255.255.255.0
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

;compress lz4-v2
;push "compress lz4-v2"
comp-lzo

;max-clients 100

user nobody
group nobody
persist-key
persist-tun

status /var/log/openvpn-status.log
log /var/log/openvpn.log
log-append /var/log/openvpn.log
verb 3

explicit-exit-notify 0

plugin /usr/lib64/openvpn/plugins/openvpn-plugin-auth-pam.so login

push "route 172.31.48.0 255.255.240.0"
topology subnet
```

* For PAM authentication

```
plugin /usr/lib64/openvpn/plugins/openvpn-plugin-auth-pam.so login
```

* For server-side routing

```
push "route <network_ip_to_allow> <network_ip_mask>"
topology subnet
```

* Extra parameters

```
;local a.b.c.d
;server-bridge 10.8.0.4 255.255.255.0 10.8.0.50 10.8.0.100
;server-bridge
;push "route 192.168.10.0 255.255.255.0"
;client-config-dir ccd
;route 192.168.40.128 255.255.255.248
;client-config-dir ccd
;route 10.9.0.0 255.255.255.252
;learn-address ./script
;topology subnet
;client-to-client
;duplicate-cn
;tls-auth ta.key 0
;compress lz4-v2
;push "compress lz4-v2"
;max-clients 100
;mute 20
```
