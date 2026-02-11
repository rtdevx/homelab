#!/usr/bin/env bash

# Create users
users_create() {

appuser="java"

if id "$appuser" >/dev/null 2>&1; then
    echo "User '$appuser' already exists."
else
    echo "Creating user '$appuser'"
    sudo useradd -r -s /usr/sbin/nologin "$appuser"
fi

}