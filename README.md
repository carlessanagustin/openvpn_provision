# OpenVPN installation and configuration role

* Requirements: Centos7

## File description

```
.
├── README.md             # this documentation
├── Vagrantfile           # for launching Vagrant instances: client & server
├── client.ovpn.md        # client configuration parameters
├── config.sh      		  # configuration script
├── create_vpn_user.sh    # user/password creation script
├── install.sh            # installation script
├── server.conf.md        # server configuration parameters
└── vars.md               # server environment variables for keys
```

## Variables

* `config.sh` file

```shell
PUBLIC_IP=public ip to connect to
CLIENT_CONF=project name

PAM=authenticate via username/password

ROUTE=route traffic to NET network
NET=network ip address to route to
NETMASK=netmask associated

# certificate info
NAME=server
CN=example.com
COUNTRY=country
PROVINCE=province
CITY=city
ORG=org
EMAIL=myemail@example.com
OU=ou

VPNNET=vpn network address
```

## Steps

* @server: Install server

```
chmod +x install.sh
./install.sh
```

* @server: Create user and password

```
chmod +x create_vpn_user.sh
./create_vpn_user.sh
```

* @client: Send to new users
  * Created user and password
  * /root/client.ovpn

* @client: Recommended clients:
  * https://tunnelblick.net/
  * https://openvpn.net/
  * http://www.lobotomo.com/products/IPSecuritas/
  * http://www.vpntracker.com/
  * Ubuntu: `sudo apt-get install network-manager-openvpn-gnome`

### Auto login (unsecure)

* Add next line @ `client.ovpn`

```
auth-user-pass auth.txt
```

* Create file `auth.txt`

```
<username>
<password>
```
