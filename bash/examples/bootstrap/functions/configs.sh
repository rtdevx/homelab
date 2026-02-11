#!/usr/bin/env bash

set_hostname() {
    
local name="servername"

echo "------------------------"
echo "Configs: Set Server Name"
echo "------------------------"

    echo "$name" | sudo tee /etc/hostname
    sudo hostnamectl set-hostname "$name"
}

set_timezone() {

local timezone="Europe/London"

echo "------------------------"
echo "Configs: Set Timezone"
echo "------------------------"

    sudo timedatectl set-timezone "$timezone"
    sudo timedatectl
}