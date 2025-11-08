#!/bin/sh
sudo chmod -x /etc/update-motd.d/*
sudo apt update && sudo apt install inxi screenfetch ansiweather

wget -O /tmp/Ubuntu.iso https://releases.ubuntu.com/20.04/ubuntu-20.04-desktop-amd64.iso  