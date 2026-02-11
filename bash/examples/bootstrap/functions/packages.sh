#!/usr/bin/env bash

PACKAGES_INSTALL=(
    curl
    git
    htop
    fail2ban
)

PACKAGES_REMOVE=(
    cowsay
    exim4
    exim4-base
    exim4-config
    nano
)

packages_install() {

echo "--------------------"
echo "Packages: Installing"
echo "--------------------"

for pkg in "${PACKAGES_INSTALL[@]}"; do
    if dpkg -s "$pkg" >/dev/null 2>&1; then
        echo "Package '$pkg' is already installed,skipping..."
    else
        sudo apt-get update && sudo apt-get -y install "$pkg"
    fi
done

}

packages_remove() {

echo "------------------"
echo "Packages: Removing"
echo "------------------"

# If doesn't exist in PACKAGES_INSTALL

for pkg in "${PACKAGES_REMOVE[@]}"; do
    if dpkg -s "$pkg" >/dev/null 2>&1; then
        sudo apt-get -y purge "$pkg"        
    else
        echo "'$pkg' is not installed, skipping..."
    fi
done

}

packages_cleanup() {

echo "---------------------"
echo "Packages: Cleaning Up"
echo "---------------------"

    sudo apt-get autoremove -y
    sudo apt-get autoclean -y

}

docker_install() {

echo "------------------------"
echo "Packages: Docker Install"
echo "------------------------"

    sudo apt-get update -y
    sudo apt-get install -y \
        ca-certificates \
        curl \
        gnupg

    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
        sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null


    sudo apt-get update -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io

}