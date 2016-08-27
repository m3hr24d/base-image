#!/usr/bin/env bash
set -eu
[[ ${DEBUG} == true ]] && set -x

source /build/env-defaults.sh

SERVICES_DIRECTORY='/build/services'
SERVICE_FILES=`ls ${SERVICES_DIRECTORY}`
SERVICES=(${SERVICE_FILES//.sh/})

for i in "${!SERVICES[@]}"
do
    SERVICE_NAME=${SERVICES[$i]}
    UPPERCASE_SERVICE_NAME=${SERVICE_NAME^^}
    INSTALL_VAR_NAME="INSTALL_${UPPERCASE_SERVICE_NAME//-/_}"

    eval "INSTALL=\${${INSTALL_VAR_NAME}}"
    SERVICE_SCRIPT="$SERVICES_DIRECTORY/$SERVICE_NAME.sh"

    if [[ "$INSTALL" == true ]]; then
        "$SERVICE_SCRIPT"
    fi
done
