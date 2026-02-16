#!/usr/bin/env bash

PACKAGES_INSTALL=(
    default-jre
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