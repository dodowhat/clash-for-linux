#!/bin/bash

cd $(dirname $(realpath $0))

if [ ! -d "runtime" ]
then
    mkdir runtime
fi

cp configs/* runtime/

if [ -f "runtime/Country.mmdb" ]
then
    rm "runtime/Country.mmdb"
fi
ln -s $(realpath core/Country.mmdb) runtime/