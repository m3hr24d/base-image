#!/usr/bin/env bash
set -eu
[[ ${DEBUG} == true ]] && set -x

source /build/env-defaults.sh

SSHD_SERVICE_DIRECTORY=${SERVICE_AVAILABLE_DIR}/sshd

DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server

mkdir -p ${SSHD_SERVICE_DIRECTORY}
touch ${SSHD_SERVICE_DIRECTORY}/run
chmod +x ${SSHD_SERVICE_DIRECTORY}/run

cat << 'EOF' > ${SSHD_SERVICE_DIRECTORY}/run
#!/usr/bin/env sh
set -eu

exec 2>&1

DAEMON=/usr/sbin/sshd
USER=root
SSHD_OPTS=''

test -x ${DAEMON} || exit 0
[ -r /etc/default/ssh ] && . /etc/default/ssh

# Will generate host keys if they don't already exist
/usr/bin/ssh-keygen -A

# Create the PrivSep empty dir
mkdir -p /var/run/sshd
chmod 0755 /var/run/sshd

if [ -e /etc/ssh/sshd_not_to_be_run ]; then
    echo 'OpenBSD Secure Shell server not in use (/etc/ssh/sshd_not_to_be_run)'
    exit 1
else
    ${DAEMON} ${SSHD_OPTS} -t || exit 1
fi

exec chpst -u ${USER} -e ./env ${DAEMON} ${SSHD_OPTS} -De
EOF

# Remove the host keys generated during openssh-server installation
rm -rf /etc/ssh/ssh_host_*_key /etc/ssh/ssh_host_*_key.pub

# Enable nginx service
ln -s ${SSHD_SERVICE_DIRECTORY} ${SERVICE_ENABLED_DIR}
cp -r ${SERVICE_AVAILABLE_DIR}/skeleton/log ${SSHD_SERVICE_DIRECTORY}
