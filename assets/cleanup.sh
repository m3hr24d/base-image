#!/usr/bin/env bash
set -eu
[[ ${DEBUG} == true ]] && set -x

source /build/env-defaults.sh

# Purge build dependencies and cleanup apt
DEBIAN_FRONTEND=noninteractive apt-get purge -y --auto-remove ${BUILD_PACKAGES_DEPENDENCIES}

# Remove apt proxy config
rm -f /etc/apt/apt.conf.d/01proxy

apt-get clean
rm -rf /build /var/lib/apt/lists/* /tmp/* /var/tmp/*
