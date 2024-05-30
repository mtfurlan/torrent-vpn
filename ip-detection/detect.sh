#!/bin/sh
set -eu

cIP=/tmp/currentIP
cD=/tmp/currentDate
lIP=/tmp/lastIP
lD=/tmp/lastDate

if [ -e "$lD" ] || [ -e "$lD" ]; then
    lastDate=$(date -d "$(cat "$lD")" -D "%Y-%m-%d %H:%M:%SZ" +"%s")
    now=$(date +%s)
    if [ "$(( now - 3600 ))" -lt "$lastDate" ]; then
        echo "too recent"
        exit 0
    fi
fi

wget ifconfig.co -O "$cIP"
date +"%Y-%m-%d %H:%M:%SZ" > "$cD"

if [ ! -e "$lIP" ] || ! cmp -s "$cIP" "$lIP" ; then
    echo "IP changed from"
    echo "$(cat "$lIP") at $(cat "$lD")"
    echo "to"
    echo "$(cat "$cIP") at $(cat "$cD")"
    if [ -e "${CHANGE_SCRIPT:-/not/a/real/path}" ]; then
        "$CHANGE_SCRIPT"
    else
        echo >&2 "please set CHANGE_SCRIPT"
    fi

    cp "$cIP" "$lIP"
    cp "$cD" "$lD"
else
    echo "no change"
fi
