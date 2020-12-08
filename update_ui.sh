#!/bin/bash

cd $(dirname $(realpath $0))

which curl > /dev/null 2>&1

if [ $? -ne 0 ]
then
    echo "\`cURL\` not installed"
    exit 1
fi

# BASENAME="clash-dashboard"
# URL="https://github.com/Dreamacro/clash-dashboard/archive/gh-pages.zip"

BASENAME="yacd"
URL="https://github.com/haishanh/yacd/archive/gh-pages.zip"

DIRNAME="${BASENAME}-gh-pages"

FILENAME="${DIRNAME}.zip"

curl -L ${URL} --output ${FILENAME}

if [ $? -eq 0 ]; then
    unzip ${FILENAME}
    mv ${DIRNAME} ui
    rm ${FILENAME}
fi;