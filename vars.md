# Environment variables for server

* To enable run: `source /etc/openvpn/easy-rsa/vars`
* Example:

```shell
export EASY_RSA="`pwd`"
export OPENSSL="openssl"
export PKCS11TOOL="pkcs11-tool"
export GREP="grep"
export KEY_CONFIG=`$EASY_RSA/whichopensslcnf $EASY_RSA`
export KEY_DIR="$EASY_RSA/keys"
echo NOTE: If you run ./clean-all, I will be doing a rm -rf on $KEY_DIR

export PKCS11_MODULE_PATH="dummy"
export PKCS11_PIN="dummy"
export KEY_SIZE=2048
export CA_EXPIRE=3650
export KEY_EXPIRE=3650

export KEY_COUNTRY="ES"
export KEY_PROVINCE="CAT"
export KEY_CITY="Barcelona"
export KEY_ORG="Eurecat"
export KEY_EMAIL="notifications-bigdata@eurecat.org"
export KEY_OU="Big Data Analytics Unit"
export KEY_NAME="server"
export KEY_CN="example.com"
```

> NOTE: pwd = /etc/openvpn/easy-rsa
