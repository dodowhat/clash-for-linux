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

RUNTIME_PATH="runtime"

if [ ! -d "${RUNTIME_PATH}" ]
then
    mkdir ${RUNTIME_PATH}
fi

function create_if_not_exists
{
    FILENAME="$1"

    if [ ! -f "${RUNTIME_PATH}/${FILENAME}" ]
    then
        cp configs/${FILENAME} ${RUNTIME_PATH}/
    fi
}

if [ ! -f "${RUNTIME_PATH}/Country.mmdb" ]
then
    ln -s $(realpath core/Country.mmdb) ${RUNTIME_PATH}/
fi

create_if_not_exists "external-controller.json"

EXTERNAL_CONTROLLER="$(cat runtime/external-controller.json | jq -r '."external-controller"')"

nohup core/clash -d runtime -ext-ctl ${EXTERNAL_CONTROLLER} > /dev/null 2>&1 &

wait

create_if_not_exists "config-file.json"

CONFIG_FILE=$(cat runtime/config-file.json | jq -r '."config-file"')

HTTP_HEADER="Content-Type: application/json"

if [ ! -z "${CONFIG_FILE}" ]
then
    CONFIG_FILE=$(realpath ${CONFIG_FILE})
    curl -X PUT -H "${HTTP_HEADER}" -d "{\"path\": \"${CONFIG_FILE}\"}" "${EXTERNAL_CONTROLLER}/configs"
fi

create_if_not_exists "rule-proxy.json"

RULE_PROXY=$(cat runtime/rule-proxy.json)

GROUP=$(echo ${RULE_PROXY} | jq -r '.group')

PROXY=$(echo ${RULE_PROXY} | jq -r '.proxy')

if [ ! -z "${GROUP}" ] && [ ! -z "${PROXY}" ]
then
    curl -X PUT -H "${HTTP_HEADER}" -d "{\"name\": \"${PROXY}\"}" "${EXTERNAL_CONTROLLER}/proxies/${GROUP}"
    curl -X PUT -H "${HTTP_HEADER}" -d "{\"name\": \"${PROXY}\"}" "${EXTERNAL_CONTROLLER}/proxies/GLOBAL"
fi

create_if_not_exists "configs.json"

CONFIGS=$(cat runtime/configs.json)

curl -X PATCH -H "${HTTP_HEADER}" -d "${CONFIGS}" "${EXTERNAL_CONTROLLER}/configs"