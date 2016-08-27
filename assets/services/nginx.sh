#!/usr/bin/env bash
set -eu
[[ ${DEBUG} == true ]] && set -x

source /build/env-defaults.sh

NGINX_SERVICE_DIRECTORY=${SERVICE_AVAILABLE_DIR}/nginx

DEBIAN_FRONTEND=noninteractive apt-get install -y nginx

mkdir -p ${NGINX_SERVICE_DIRECTORY}
touch ${NGINX_SERVICE_DIRECTORY}/run
chmod +x ${NGINX_SERVICE_DIRECTORY}/run

cat << 'EOF' > ${NGINX_SERVICE_DIRECTORY}/run
#!/usr/bin/env sh
set -eu

exec 2>&1

DAEMON=/usr/sbin/nginx
USER=root

test -x ${DAEMON} || exit 0

mkdir -p /var/log/nginx

exec chpst -u ${USER} -e ./env ${DAEMON} -c /etc/nginx/nginx.conf  -g "daemon off;"
EOF

# Enable nginx service
ln -s ${NGINX_SERVICE_DIRECTORY} ${SERVICE_ENABLED_DIR}
cp -r ${SERVICE_AVAILABLE_DIR}/skeleton/log ${NGINX_SERVICE_DIRECTORY}
