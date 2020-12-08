#!/bin/bash

cd $(dirname $(realpath $0))

which curl > /dev/null 2>&1

if [ $? -ne 0 ]
then
    echo "\`cURL\` not installed"
    exit 1
fi

cd core

CURRENT_VERSION=$(./clash -v | awk '{print $2}')
echo $CURRENT_VERSION

LATEST_VERSION=$(curl https://api.github.com/repos/Dreamacro/clash/tags | jq -r '.[0] | .name')
echo $LATEST_VERSION

if [[ "${CURRENT_VERSION}" == "${LATEST_VERSION}" ]]; then
    echo "Already up to date."
    exit 1
fi

BASENAME="clash-linux-amd64-${LATEST_VERSION}"

FILENAME="${BASENAME}.gz"

curl -L "https://github.com/Dreamacro/clash/releases/latest/download/${FILENAME}" --output ${FILENAME}

if [ $? -eq 0 ]; then
    gzip -d ${FILENAME}
    mv ${BASENAME} clash
    chmod u+x clash
fi;