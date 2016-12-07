#!/usr/bin/env bash
set -eu
[[ ${DEBUG} == true ]] && set -x

source /build/env-defaults.sh

GEARMAN_USER=gearman
GEARMAN_GROUP=gearman
GEARMAN_VERSION=1.1.12
GEARMAN_SERIES=1.2
GEARMAN_PKG_NAME=gearmand-${GEARMAN_VERSION}
GEARMAN_SERVICE_DIRECTORY=${SERVICE_AVAILABLE_DIR}/gearman

DEBIAN_FRONTEND=noninteractive apt-get install -y libevent-dev libboost-program-options-dev libboost-system-dev libboost-thread-dev

# Download and install Gearman
curl --retry 5 -SLO https://launchpad.net/gearmand/${GEARMAN_SERIES}/${GEARMAN_VERSION}/+download/${GEARMAN_PKG_NAME}.tar.gz
tar xzf ${GEARMAN_PKG_NAME}.tar.gz
cd ${GEARMAN_PKG_NAME}
./configure
make
make install

# Add Gearman user & group
useradd --system --comment='Gearman Job Server' --home-dir=/var/lib/gearman --user-group --shell=/bin/false ${GEARMAN_USER}

# Cleanup
rm -rf /${GEARMAN_PKG_NAME}
rm -f /${GEARMAN_PKG_NAME}.tar.gz

# Create service and env directories
mkdir -p ${GEARMAN_SERVICE_DIRECTORY}/env
touch ${GEARMAN_SERVICE_DIRECTORY}/run
chmod +x ${GEARMAN_SERVICE_DIRECTORY}/run

cat << 'EOF' > ${GEARMAN_SERVICE_DIRECTORY}/run
#!/usr/bin/env sh
set -eu

exec 2>&1

DAEMON=/usr/local/sbin/gearmand
USER=root
GEARMAN_USER=gearman

test -x ${DAEMON} || exit 0

exec chpst -u ${USER} -e ./env ${DAEMON} --user ${GEARMAN_USER} --verbose INFO --log-file stderr
EOF

# Enable gearman service
ln -s ${GEARMAN_SERVICE_DIRECTORY} ${SERVICE_ENABLED_DIR}
cp -r ${SERVICE_AVAILABLE_DIR}/skeleton/log ${GEARMAN_SERVICE_DIRECTORY}

if [[ "$DISABLE_AUTO_START_SERVICES" == true ]]; then
    touch ${GEARMAN_SERVICE_DIRECTORY}/down
    touch ${GEARMAN_SERVICE_DIRECTORY}/log/down
fi
