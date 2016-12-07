#!/usr/bin/env bash
set -eu
[[ ${DEBUG} == true ]] && set -x

source /build/env-defaults.sh

DEBIAN_FRONTEND=noninteractive apt-get install -y cron

CRON_SERVICE_DIRECTORY=${SERVICE_AVAILABLE_DIR}/cron

# Create service and env directories
mkdir -p ${CRON_SERVICE_DIRECTORY}/env
touch ${CRON_SERVICE_DIRECTORY}/run
chmod +x ${CRON_SERVICE_DIRECTORY}/run

cat << 'EOF' > ${CRON_SERVICE_DIRECTORY}/run
#!/usr/bin/env sh
set -eu

exec 2>&1

DAEMON=/usr/sbin/cron
USER=root
EXTRA_OPTS=${EXTRA_OPTS:-}

test -x ${DAEMON} || exit 0

[ -r /etc/default/cron ] && . /etc/default/cron

exec chpst -u ${USER} -e ./env ${DAEMON} -f ${EXTRA_OPTS}
EOF

if [[ "$DISABLE_AUTO_START_SERVICES" == true ]]; then
    touch ${CRON_SERVICE_DIRECTORY}/down
fi

# Enable cron service
ln -s ${CRON_SERVICE_DIRECTORY} ${SERVICE_ENABLED_DIR}

# Remove useless cron entries.
rm -f /etc/cron.daily/apt
rm -f /etc/cron.daily/dpkg
