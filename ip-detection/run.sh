#!/bin/sh
set -eu


scriptDir=/scripts

if [ ! -d "$scriptDir" ]; then
    echo "please mount your scripts into /scripts"
    exit 5
fi

find "$scriptDir" -maxdepth 1 -type f -executable -exec echo "running {}" \; -exec {} \;
