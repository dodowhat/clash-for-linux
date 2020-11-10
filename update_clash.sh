#!/bin/bash

cd $(dirname $(realpath $0))

which curl > /dev/null 2>&1

if [ $? -ne 0 ]
then
    echo "\`cURL\` not installed"
    exit 1
fi

cd core

VERSION=$(curl https://api.github.com/repos/Dreamacro/clash/tags | jq -r '.[0] | .name')

BASENAME="clash-linux-amd64-${VERSION}"

FILENAME="${BASENAME}.gz"

curl -L "https://github.com/Dreamacro/clash/releases/latest/download/${FILENAME}" --output ${FILENAME}

if [ $? -eq 0 ]; then
    gzip -d ${FILENAME}
    mv ${BASENAME} clash
    chmod u+x clash
fi;