FROM alpine:latest

# gluetun doens't support post vpn up scripts
# this will cron and run a script on change, at most once every hour
# TODO: confirm that it's not once every 2 cause it runs once every 1,
# but bash script also has a too recent check

# use this like:
#  ip_bullshit:
#    network_mode: service:vpn
#    build:
#      dockerfile: ./ip-script.Dockerfile
#    environment:
#      - CHANGE_SCRIPT=/vpn-startup-scripts/myanonamouse.sh
#    volumes:
#      - ./config/vpn-startup-scripts:/vpn-startup-scripts

RUN apk --no-cache add curl

RUN touch crontab.tmp \
    && echo '@reboot /detect.sh' >> crontab.tmp \
    && echo '0 * * * * /detect.sh' >> crontab.tmp \
    #&& echo '* * * * * sh -c /detect.sh ' >> crontab.tmp \
    && crontab crontab.tmp \
    && rm -rf crontab.tmp

CMD ["/usr/sbin/crond", "-f", "-l", "2"]

RUN cat <<'EOF' > /detect.sh
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
        "$CHANGE_SCRIPT" "$(cat "$cIP")"
    else
        echo >&2 "please set CHANGE_SCRIPT"
    fi

    cp "$cIP" "$lIP"
    cp "$cD" "$lD"
else
    echo "no change"
fi
EOF
RUN chmod +x /detect.sh
