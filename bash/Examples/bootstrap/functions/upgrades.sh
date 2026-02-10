#!/usr/bin/env bash

upgrades_install() {

if dpkg -s "unattended-upgrades" >/dev/null 2>&1; then
    echo "Package unattended-upgrades is already installed,skipping..."
else
    sudo apt-get update && sudo apt-get -y install unattended-upgrades
fi

}

upgrades_configure() {

echo "-----------------------------"
echo "Configure Unattended Upgrades"
echo "-----------------------------"

# Install unattended-upgrades
upgrades_install

# Configure unattended-upgrades
local upgrades_config="/etc/apt/apt.conf.d/50unattended-upgrades"

if [[ -f "$upgrades_config" ]]; then

    echo "Enabling updates"
    sudo sed -i 's/^\/\/\t"${distro_id}:${distro_codename}-updates";$/\t"${distro_id}:${distro_codename}-updates";/' "$upgrades_config"
    #grep ".*${distro_codename}-updates\";$" $upgrades_config

    echo "Enabling MinimalSteps"
    sudo sed -i 's/^\/\/Unattended-Upgrade::MinimalSteps "true";$/Unattended-Upgrade::MinimalSteps "true";/' "$upgrades_config"
        
    echo "Remove Unused Kernel Packages"
    sudo sed -i 's/^\/\/Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";$/Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";/' "$upgrades_config"

    echo "Remove Unused Dependencies (equivalent to apt-get autoremove)"
    sudo sed -i 's/^\/\/Unattended-Upgrade::Remove-Unused-Dependencies "false";$/Unattended-Upgrade::Remove-Unused-Dependencies "true";/' "$upgrades_config"

    echo "Automatically reboot *WITHOUT CONFIRMATION*"
    sudo sed -i 's/^\/\/Unattended-Upgrade::Automatic-Reboot "false";$/Unattended-Upgrade::Automatic-Reboot "true";/' "$upgrades_config"   

    echo "Automatically reboot even if there are users currently logged in when Unattended-Upgrade::Automatic-Reboot is set to true"
    sudo sed -i 's/^\/\/Unattended-Upgrade::Automatic-Reboot-WithUsers "true";$/Unattended-Upgrade::Automatic-Reboot-WithUsers "false";/' "$upgrades_config" 

    echo "Uncommented strings:"
    grep -Pv '^(//|\s*$)' $upgrades_config     

fi

}

