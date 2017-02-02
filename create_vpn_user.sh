#!/bin/bash

# must run as root

read -e -p "VPN username to create? " USERNAME

useradd $USERNAME -M -s /bin/false
passwd $USERNAME
