#!/bin/sh
# Execute: curl https://raw.githubusercontent.com/rtdevx/homelab/refs/heads/main/bash/motd/install.sh | bash

sudo chmod -x /etc/update-motd.d/*
sudo apt update && sudo apt upgrade -y && sudo apt install -y inxi screenfetch ansiweather

sudo wget -O /etc/update-motd.d/01-custom https://raw.githubusercontent.com/rtdevx/homelab/refs/heads/main/bash/motd/01-custom

sudo chmod +x /etc/update-motd.d/01-custom