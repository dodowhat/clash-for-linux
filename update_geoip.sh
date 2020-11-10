#!/bin/bash

cd $(dirname $(realpath $0))

which curl > /dev/null 2>&1

if [ $? -ne 0 ]
then
    echo "\`cURL\` not installed"
    exit 1
fi

cd core

FILENAME="Country.mmdb"

FILENAME_TEMP="${FILENAME}.temp"

curl -L "https://github.com/Dreamacro/maxmind-geoip/releases/latest/download/${FILENAME}" --output ${FILENAME_TEMP}

if [ $? -eq 0 ]
then
    mv ${FILENAME_TEMP} ${FILENAME}
fi

if [ -f ${FILENAME_TEMP} ]
then
    rm ${FILENAME_TEMP}
fi