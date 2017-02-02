# OpenVPN client configuration file client.ovpn

* General options

```
client
dev tun
proto udp
remote <your_server_ip> 1194
resolv-retry infinite
nobind
persist-key
persist-tun
comp-lzo
verb 3
cipher AES-256-CBC
auth-user-pass
<ca>
...
</ca>
<cert>
...
</cert>
<key>
...
</key>
```

* Enable PAM user authentication: `auth-user-pass`

* Option 1: External

```
ca /path/to/ca.crt
cert /path/to/client.crt
key /path/to/client.key
```

* Option 2: Embedded

```
<ca>
...
</ca>
<cert>
...
</cert>
<key>
...
</key>
<tls-auth>
...
</tls-auth>
```
