#!/usr/bin/env bash
set -eu
[[ ${DEBUG} == true ]] && set -x

source /build/env-defaults.sh

mkdir -p ${SERVICE_ENABLED_DIR}

# Create environments directory and script
mkdir -p ${ENVIRONMENTS_DIR}
touch ${ENVIRONMENTS_SCRIPT}
ln -s ${ENVIRONMENTS_SCRIPT} /etc/profile.d/

# Apt is configured to use apt-cacher-ng if exists.
if [ "$APT_CACHER_SERVER" != '' ]; then
    echo "Acquire::http::Proxy \"$APT_CACHER_SERVER\";" > /etc/apt/apt.conf.d/01proxy;
    echo 'Acquire::https::Proxy "false";' >> /etc/apt/apt.conf.d/01proxy;
fi

# Update & upgrade packages
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y ${BUILD_PACKAGES_DEPENDENCIES}
DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y
