#!/usr/bin/env bash

# Include sources
. functions/configs.sh
. functions/packages.sh
. functions/ssh.sh
. functions/sysctl.sh
. functions/ufw.sh
. functions/upgrades.sh
. functions/users.sh

# Configure log file
logfile="/var/log/bootstrap.log"

sudo touch "$logfile"
sudo chown "$USER:$USER" "$logfile"
sudo chmod 0644 "$logfile"

# Call Functions
users_configure >"$logfile"        # ./functions/users.sh 

packages_install >>"$logfile"       # ./functions/packages.sh
packages_remove >>"$logfile"         # ./functions/packages.sh
#docker_install >>"$logfile"          # ./functions/packages.sh
packages_cleanup >>"$logfile"        # ./functions/packages.sh 

sysctl_apply >>"$logfile"            # ./functions/sysctl.sh 

ssh_configure >>"$logfile"           # ./functions/ssh.sh
ssh_provision_keys >>"$logfile"      # ./functions/ssh.sh 
ssh_disable_root >>"$logfile"        # ./functions/ssh.sh

ufw_configure >>"$logfile"           # ./functions/ufw.sh

upgrades_configure >>"$logfile"      # ./functions/upgrades.sh

#set_hostname >>"$logfile"            # ./functions/configs.sh
set_timezone >>"$logfile"            # ./functions/configs.sh

#echo -e "\n*********************************\n"
#echo "Bootstrap Completed Successfully"
#echo -e "\n*********************************\n"
#echo "Users created: ${USERS[*]}"
#echo "Packages installed: ${PACKAGES[*]}"

# Set owner for log file to root
sudo chown "root:root" "$logfile"
sudo cat "$logfile"