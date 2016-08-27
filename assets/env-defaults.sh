#!/usr/bin/env bash
set -eu

# Runit
RUNIT_DIR=/etc/runit
SERVICE_AVAILABLE_DIR="$RUNIT_DIR/service"
SERVICE_ENABLED_DIR='/service'

BUILD_PACKAGES_DEPENDENCIES='git curl autoconf automake make libtool file g++ gcc gperf uuid-dev'
