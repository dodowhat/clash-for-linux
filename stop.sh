#!/bin/bash

PID=$(pidof clash)
if [ ! -z "$PID" ]; then
    kill -9 $PID
fi