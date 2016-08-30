#!/usr/bin/env bash
set -eu
[[ ${DEBUG} == true ]] && set -x

source /build/env-defaults.sh

TINYDNS_SERVICE_DIRECTORY=${SERVICE_AVAILABLE_DIR}/tinydns

mkdir -p /package
chmod 1755 /package
cd /package
curl --retry 5 -SLO http://cr.yp.to/djbdns/djbdns-1.05.tar.gz
tar -zxvpf djbdns-1.05.tar.gz
cd /package/djbdns-1.05
echo gcc -O2 -include /usr/include/errno.h > conf-cc
make
make setup check
useradd --system --comment='TinyDns' --home-dir /var/lib/tinydns --no-create-home --user-group --shell /bin/false tinydns
useradd --system --comment='DnsLog' --home-dir /var/lib/dnslog --no-create-home --user-group --shell /bin/false dnslog
tinydns-conf tinydns dnslog /etc/tinydns 0.0.0.0

# Create Tinydns service directory
mkdir -p ${TINYDNS_SERVICE_DIRECTORY}
touch ${TINYDNS_SERVICE_DIRECTORY}/run
chmod +x ${TINYDNS_SERVICE_DIRECTORY}/run

mkdir -p ${TINYDNS_SERVICE_DIRECTORY}/log
touch ${TINYDNS_SERVICE_DIRECTORY}/log/run
chmod +x ${TINYDNS_SERVICE_DIRECTORY}/log/run

echo "$TINYDNS_SERVICE_DIRECTORY/root" > /etc/tinydns/env/ROOT 
cp -ar /etc/tinydns/root ${TINYDNS_SERVICE_DIRECTORY}/
cp -ar /etc/tinydns/env ${TINYDNS_SERVICE_DIRECTORY}/
rm -rf /package /etc/tinydns

cat << 'EOF' > ${TINYDNS_SERVICE_DIRECTORY}/run
#!/usr/bin/env sh
set -eu

exec 2>&1

DAEMON=/usr/local/bin/tinydns
USER=tinydns

test -x ${DAEMON} || exit 0

exec chpst -U ${USER} -e ./env ${DAEMON}
EOF

cat << 'EOF' > ${TINYDNS_SERVICE_DIRECTORY}/log/run
#!/usr/bin/env sh
set -eu

exec 2>&1

LOG_DIR=/var/log/runit/tinydns
USER=dnslog
GROUP=dnslog

# Create log dir and fix owner & mode
mkdir -p ${LOG_DIR}
chown ${USER}:${GROUP} ${LOG_DIR}
chmod 700 ${LOG_DIR}

exec /usr/bin/chpst -U ${USER} /usr/bin/svlogd -tt ${LOG_DIR}
EOF

# Enable tinydns service
ln -s ${TINYDNS_SERVICE_DIRECTORY} ${SERVICE_ENABLED_DIR}
