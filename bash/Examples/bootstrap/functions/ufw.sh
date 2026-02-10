#!/usr/bin/env bash

ufw_configure() { 

echo "-------------"
echo "Configure UFW"
echo "-------------"

    # Install ufw
    if dpkg -s "ufw" >/dev/null 2>&1; then
        echo "Package 'ufw' is already installed,skipping..."
    else

        sudo apt-get update && sudo apt-get install -y "ufw"

    if systemctl status "$ssh_daemon" >/dev/null 2>&1; then 

        sudo ufw allow OpenSSH

    fi

    sudo ufw --force enable
    
fi

}