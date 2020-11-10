#!/bin/bash

PID=$(pidof clash)
if [ -z "$PID" ]; then
    echo "clash not running"
    exit 1
fi

EXTERNAL_CONTROLLER="$(cat runtime/external-controller.json | jq -r '."external-controller"')"

TIMEOUT=5000

NAME_WIDTH=20

TYPE_WIDTH=16

TEST_URL="https://gstatic.com/generate_204"

PROXIES="$(curl -s ${EXTERNAL_CONTROLLER}/proxies | jq '.proxies')"

GROUP=$(echo ${PROXIES} | jq 'map(select(.type == "Selector")) | .[] | [{group: .name}] + .all | select(contains(["DIRECT"]) | not)' | jq -r '.[0].group')

GROUP_CURRENT="$(echo ${PROXIES} | jq -r ".$GROUP.now")"

PROXIES="$(echo ${PROXIES} | jq 'map(select(has("all") | not))' | jq 'map(select(.name != "DIRECT" and .name != "REJECT"))')"

NAMES="$(echo ${PROXIES} | jq -r 'map(.name) | join(",")')"

IFS="," read -r -a NAMES <<< ${NAMES}
 
TYPES="$(echo ${PROXIES} | jq -r 'map(.type) | join(",")')"

IFS="," read -r -a TYPES <<< ${TYPES}

for INDEX in ${!NAMES[@]}
do
    FLAG=""
    if [[ "$GROUP_CURRENT" == "${NAMES[INDEX]}" ]]
    then
        FLAG+="[*]"
    fi
    NAME_FORMATED="$(printf "%-${NAME_WIDTH}s\t%3s\t%-${TYPE_WIDTH}s" "${NAMES[INDEX]}" "$FLAG" "${TYPES[INDEX]}")"
    NAME_ENCODED="$(echo ${NAMES[INDEX]} | sed 's/ /%20/g')"
    curl -s -G \
        --data-urlencode "timeout=${TIMEOUT}" \
        --data-urlencode "url=${TEST_URL}" \
        "${EXTERNAL_CONTROLLER}/proxies/${NAME_ENCODED}/delay" \
        | jq '.delay' | sed -e "s/^/${NAME_FORMATED}/g" -e "s/$/ ms/g" &
done

wait