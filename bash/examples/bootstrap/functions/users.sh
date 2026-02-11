#!/usr/bin/env bash

USERS=(
    robk
    ansible
    git
)

# Create users
users_create() {

echo "---------------"
echo "Users: Creating"
echo "---------------"

for user in "${USERS[@]}"; do
    if id "$user" >/dev/null 2>&1; then
        echo "User '$user' already exists"
    else
        echo "Creating user '$user'"
        sudo useradd -m -s /bin/bash "$user"
    fi
done

}

# Call all modules
users_configure() {

users_create

}