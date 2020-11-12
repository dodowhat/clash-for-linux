#!/bin/bash

cd $(dirname $(realpath $0))

if [ ! -d "runtime" ]
then
    mkdir runtime
fi

cp configs/* runtime/

ln -s -f $(realpath core/Country.mmdb) runtime/