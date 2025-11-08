#!/bin/bash
# Execute: curl https://raw.githubusercontent.com/rtdevx/homelab/refs/heads/main/bash/motd/install.sh | bash

# Disable all current default MOTD’s daemon scripts
sudo chmod -x /etc/update-motd.d/*

# Install prerequisites
sudo apt update && sudo apt upgrade -y && sudo apt install -y inxi screenfetch ansiweather show-motd

# Download custom MOTD script
sudo wget -O /etc/update-motd.d/01-custom https://raw.githubusercontent.com/rtdevx/homelab/refs/heads/main/bash/motd/01-custom

# Make the custom MOTD script executable
sudo chmod +x /etc/update-motd.d/01-custom