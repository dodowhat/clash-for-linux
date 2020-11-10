#!/bin/bash

cd $(dirname $(realpath $0))

which jq > /dev/null 2>&1

if [ $? -ne 0 ]
then
    echo "jq not installed"
    exit 1
fi

which curl > /dev/null 2>&1

if [ $? -ne 0 ]
then
    echo "\`cURL\` not installed"
    exit 1
fi

PID=$(pidof clash)
if [ ! -z "${PID}" ]; then
    kill -9 ${PID}
fi

EXTERNAL_CONTROLLER="$(cat runtime/external-controller.json | jq -r '."external-controller"')"

nohup core/clash -d runtime -ext-ctl ${EXTERNAL_CONTROLLER} > /dev/null 2>&1 &

CONFIG_FILE=$(cat runtime/config-file.json | jq -r '."config-file"')

HTTP_HEADER="Content-Type: application/json"

if [ ! -z "${CONFIG_FILE}" ]
then
    CONFIG_FILE=$(realpath ${CONFIG_FILE})
    curl -X PUT -H "${HTTP_HEADER}" -d "{\"path\": \"${CONFIG_FILE}\"}" "${EXTERNAL_CONTROLLER}/configs"
fi

RULE_PROXY=$(cat runtime/rule-proxy.json)

GROUP=$(echo ${RULE_PROXY} | jq -r '.group')

PROXY=$(echo ${RULE_PROXY} | jq -r '.proxy')

if [ ! -z "${GROUP}" ] && [ ! -z "${PROXY}" ]
then
    curl -X PUT -H "${HTTP_HEADER}" -d "{\"name\": \"${PROXY}\"}" "${EXTERNAL_CONTROLLER}/proxies/${GROUP}"
    curl -X PUT -H "${HTTP_HEADER}" -d "{\"name\": \"${PROXY}\"}" "${EXTERNAL_CONTROLLER}/proxies/GLOBAL"
fi

CONFIGS=$(cat runtime/configs.json)

curl -X PATCH -H "${HTTP_HEADER}" -d "${CONFIGS}" "${EXTERNAL_CONTROLLER}/configs"