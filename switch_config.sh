#!/bin/bash

cd $(dirname $(realpath $0))

if [ -z "$1" ]
then
    echo "Usage: $(basename $0) [CONFIG_FILE]"
    exit 1
fi

CONFIG_PATH_ABS=$(realpath $1)

EXTERNAL_CONTROLLER="$(cat runtime/external-controller.json | jq -r '."external-controller"')"

HTTP_HEADER="Content-Type: application/json"

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X PUT -H "${HTTP_HEADER}" -d "{\"path\": \"$CONFIG_PATH_ABS\"}" "${EXTERNAL_CONTROLLER}/configs")

if [ ${HTTP_CODE} -ge 200 ] && [ ${HTTP_CODE} -lt 300 ]
then
    echo "{\"config-file\": \"${CONFIG_PATH_ABS}\"}" | jq '.' > runtime/config-file.json
    cp configs/rule-proxy.json runtime/rule-proxy.json
    echo "succeed"
fi