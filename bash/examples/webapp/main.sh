#!/usr/bin/env bash

. functions/appinstall.sh
. functions/packages.sh
. functions/users.sh

users_create
packages_install
java_configure