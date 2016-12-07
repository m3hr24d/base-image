#!/usr/bin/env bash
set -eu
[[ ${DEBUG} == true ]] && set -x

source /build/env-defaults.sh

DEBIAN_FRONTEND=noninteractive apt-get install -y syslog-ng-core

SYSLOG_NG_SERVICE_DIRECTORY=${SERVICE_AVAILABLE_DIR}/syslog-ng

# Create service and env directories
mkdir -p ${SYSLOG_NG_SERVICE_DIRECTORY}/env
touch ${SYSLOG_NG_SERVICE_DIRECTORY}/run
chmod +x ${SYSLOG_NG_SERVICE_DIRECTORY}/run

# Replace the system() source because inside Docker we can't access /proc/kmsg.
sed -i -E 's/^(\s*)system\(\);/\1unix-stream("\/dev\/log");/' /etc/syslog-ng/syslog-ng.conf

# Uncomment 'SYSLOGNG_OPTS="--no-caps"' to avoid the following warning:
# syslog-ng: Error setting capabilities, capability management disabled; error='Operation not permitted'
sed -i 's/^#\(SYSLOGNG_OPTS="--no-caps"\)/\1/g' /etc/default/syslog-ng

cat << 'EOF' > ${SYSLOG_NG_SERVICE_DIRECTORY}/run
#!/usr/bin/env sh
set -eu

exec 2>&1

DAEMON='/usr/sbin/syslog-ng'
USER=root
SYSLOGNG_OPTS=''

test -x ${DAEMON} || exit 0
[ -r /etc/default/syslog-ng ] && . /etc/default/syslog-ng

exec /usr/bin/chpst -u ${USER} -e ./env ${DAEMON} -F ${SYSLOGNG_OPTS}
EOF

# Enable syslog-ng service
ln -s ${SYSLOG_NG_SERVICE_DIRECTORY} ${SERVICE_ENABLED_DIR}

if [[ "$DISABLE_AUTO_START_SERVICES" == true ]]; then
    touch ${SYSLOG_NG_SERVICE_DIRECTORY}/down
fi
