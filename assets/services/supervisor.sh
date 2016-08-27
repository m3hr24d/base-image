#!/usr/bin/env bash
set -eu
[[ ${DEBUG} == true ]] && set -x

source /build/env-defaults.sh

SUPERVISOR_SERVICE_DIRECTORY=${SERVICE_AVAILABLE_DIR}/supervisor

DEBIAN_FRONTEND=noninteractive apt-get install -y supervisor

sed -i 's#logfile=/var/log/supervisor/supervisord.log#;logfile=/var/log/supervisor/supervisord.log#g' /etc/supervisor/supervisord.conf

mkdir -p ${SUPERVISOR_SERVICE_DIRECTORY}
touch ${SUPERVISOR_SERVICE_DIRECTORY}/run
chmod +x ${SUPERVISOR_SERVICE_DIRECTORY}/run

cat << 'EOF' > ${SUPERVISOR_SERVICE_DIRECTORY}/run
#!/usr/bin/env sh
set -eu

exec 2>&1

DAEMON=/usr/bin/supervisord
USER=root

# Include supervisor defaults if available
if [ -f /etc/default/supervisor ] ; then
    . /etc/default/supervisor
fi
DAEMON_OPTS="-nc /etc/supervisor/supervisord.conf $DAEMON_OPTS"

mkdir -p /var/log/supervisor
test -x ${DAEMON} || exit 0

exec chpst -u ${USER} -e ./env ${DAEMON} ${DAEMON_OPTS}
EOF

# Enable supervisor service
ln -s ${SUPERVISOR_SERVICE_DIRECTORY} ${SERVICE_ENABLED_DIR}
cp -r ${SERVICE_AVAILABLE_DIR}/skeleton/log ${SUPERVISOR_SERVICE_DIRECTORY}
