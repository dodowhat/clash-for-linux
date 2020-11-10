#!/bin/bash

NAME_WIDTH=35

FLAG_WIDTH=25

TYPE_WIDTH=16

EXTERNAL_CONTROLLER="$(cat runtime/external-controller.json | jq -r '."external-controller"')"

if [[ ! -z "$1" ]] && [[ "$1" != "-s" ]]
then
    printf "[OPTIONS]\n"
    printf "%-${FLAG_WIDTH}s %-${NAME_WIDTH}s\n" "" "show status"
    printf "%-${FLAG_WIDTH}s %-${NAME_WIDTH}s\n" "-s" "switch proxy"
    exit 1
fi

PROXIES="$(curl -s $EXTERNAL_CONTROLLER/proxies | jq '.proxies')"

GROUP=$(echo $PROXIES | jq 'map(select(.type == "Selector")) | .[] | [{group: .name}] + .all | select(contains(["DIRECT"]) | not)' | jq -r '.[0].group')

GROUP_CURRENT="$(echo $PROXIES | jq -r ".$GROUP.now")"

PROXIES="$(echo $PROXIES | jq 'map(select(has("all") | not))' | jq 'map(select(.name != "DIRECT" and .name != "REJECT"))')"

NAMES="$(echo $PROXIES | jq -r 'map(.name) | join(",")')"

IFS="," read -r -a NAMES <<< $NAMES
 
TYPES="$(echo $PROXIES | jq -r 'map(.type) | join(",")')"

IFS="," read -r -a TYPES <<< $TYPES

printf "[Proxies]\n"

for INDEX in ${!NAMES[@]}
do
    FLAG="[$INDEX]"
    if [[ ${NAMES[INDEX]} == $GROUP_CURRENT ]]
    then
        FLAG+=" [*]"
    fi
    printf "%-${FLAG_WIDTH}s %-${NAME_WIDTH}s \t %-${TYPE_WIDTH}s\n" "$FLAG" "${NAMES[INDEX]}" "${TYPES[INDEX]}"
done

if [ -z "$1" ]
then
    exit 1
fi

printf "\nType number in '[]', press 'Enter' to confirm\n"

read -p "select proxy: " "PROXY_INDEX"

if [ "$PROXY_INDEX" -lt 0 ] || [ "$PROXY_INDEX" -gt "${#NAMES[@]}" ]
then
    echo "Number out of range"
    exit 1
fi

HTTP_HEADER="Content-Type: application/json"

HTTP_CODE_1=$(curl -s -o /dev/null -w "%{http_code}" -X PUT -H "${HTTP_HEADER}" -d "{\"name\": \"${NAMES[PROXY_INDEX]}\"}" "$EXTERNAL_CONTROLLER/proxies/${GROUP}")

HTTP_CODE_2=$(curl -s -o /dev/null -w "%{http_code}" -X PUT -H "${HTTP_HEADER}" -d "{\"name\": \"${NAMES[PROXY_INDEX]}\"}" "$EXTERNAL_CONTROLLER/proxies/GLOBAL")

if [ ${HTTP_CODE_1} -ge 200 ] && [ ${HTTP_CODE_1} -lt 300 ] && [ ${HTTP_CODE_2} -ge 200 ] && [ ${HTTP_CODE_1} -lt 300 ]
then
    echo "{\"group\": \"${GROUP}\", \"proxy\": \"${NAMES[PROXY_INDEX]}\"}" | jq '.' > runtime/rule-proxy.json
    echo "switch to \"${NAMES[PROXY_INDEX]} ${TYPES[PROXY_INDEX]}\" succeed"
fi