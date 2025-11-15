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

#RUN cat <<'EOF' > /detect.sh
#EOF
COPY ./detect.sh /detect.sh
RUN chmod +x /detect.sh
