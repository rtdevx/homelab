#!/usr/bin/env bash

sysctl_apply() {

echo "---------------"
echo "Applying sysctl"
echo "---------------"

echo "net.ipv4.ip_forward =1" | sudo tee /etc/sysctl.d/99-bootstrap.conf >/dev/null
sudo sysctl -p /etc/sysctl.d/99-bootstrap.conf

}