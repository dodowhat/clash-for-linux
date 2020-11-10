#!/bin/bash

cd $(dirname $(realpath $0))

if [ ! -d "runtime" ]
then
    mkdir runtime
fi

cd runtime

which curl > /dev/null 2>&1

if [ $? -ne 0 ]
then
    echo "\`cURL\` not installed"
    exit 1
fi

if [ -z "$1" ]
then
    echo "Usage: $(basename $0) [SUBSCRIPTION_NAME]"
    exit 1
fi

FILENAME="subscription.json"

if [ ! -f "$FILENAME" ]
then
    echo '{}' > $FILENAME
fi

URL=$(cat ${FILENAME} | jq -r ".$1")

if [[ ${URL} == "null" ]]
then
    echo "Subscription name not exists"
    exit 1
fi

FILENAME="$1.yml"

FILENAME_TEMP="${FILENAME}.temp"

curl -L ${URL} --output ${FILENAME_TEMP}

if [ $? -eq 0 ]
then
    mv ${FILENAME_TEMP} ${FILENAME}
fi

if [ -f ${FILENAME_TEMP} ]
then
    rm ${FILENAME_TEMP}
fi