#!/bin/sh
set -eu

## set dyanmic seedbox IP
## docs: https://www.myanonamouse.net/api/endpoint.php/3/json/dynamicSeedbox.php
## create session, tell it to allow session to set dynamic seedbox IP
## settings: https://www.myanonamouse.net/preferences/index.php?view=security

mam_id=$(cat "$(dirname "$0")/mam_id")

# based on https://github.com/myanonamouse/seedboxapi/blob/main/wrapper.sh

OLDIP_FILE=/tmp/MAM.ip
COOKIEFILE=/cache/mam.cookies

if [ -f "$OLDIP_FILE" ]; then
    # Empty the IP file if it has not been rotated for more than 30 days, this will enforce session freshness.
    find "$OLDIP_FILE" -mtime +30 -delete
    OLDIP=$(cat "$OLDIP_FILE" 2>/dev/null)
else
    OLDIP=""
fi
NEWIP=$(wget -q https://ifconfig.co -O-)

# Check to see if the IP address has changed
if [ "${OLDIP}" = "${NEWIP}" ]; then
    echo "No IP change detected: $(date +"%Y-%m-%d %H:%M:%SZ"): $NEWIP"
    exit 0
else
    echo "New IP detected $(date +"%Y-%m-%d %H:%M:%SZ"): $OLDIP -> $NEWIP"
fi

if ! grep -q mam_id "${COOKIEFILE}"; then
    if [ -z "$mam_id" ]; then
        echo no mam_id, and no existing session.
        exit 1
    fi

    echo No existing session, creating new cookie file using mam_id from environment
    curl -s -b "mam_id=${mam_id}" -c "${COOKIEFILE}" https://t.myanonamouse.net/json/dynamicSeedbox.php > /tmp/MAM.output
    echo "response: '$(cat /tmp/MAM.output)'"

    if ! grep -qi '"success":true' /tmp/MAM.output; then
        echo mam_id passed on command line is invalid
        exit 1
    elif ! grep -q mam_id ${COOKIEFILE}; then
        echo Command successful, but failed to create cookie file.
        exit 1
    else
        echo New session created.
    fi
else
    curl -s -b "$COOKIEFILE" -c "$COOKIEFILE" https://t.myanonamouse.net/json/dynamicSeedbox.php > /tmp/MAM.output
    echo "response: '$(cat /tmp/MAM.output)'"
    if grep -q -E 'No Session Cookie|Invalid session' /tmp/MAM.output; then
        echo Current cookie file is invalid.  Please delete it, set the mam_id, and restart the container.
        exit 1
    fi

    # If that command worked, and we therefore got the success message
    # from MAM, update the OLDIP_FILE for the next execution
    if grep -qi '"success":true' /tmp/MAM.output; then
        echo "$NEWIP" > $OLDIP_FILE
    elif grep -q 'Last change too recent' /tmp/MAM.output; then
        echo Last update too recent - sleeping
    else
        echo Invalid response
        exit 1
    fi
fi
