FROM alpine:latest

# run scripts every hour and on container start
# meant for ip change detection

# use this like:
#  ip_bullshit:
#    network_mode: service:vpn
#    build:
#      dockerfile: ./ip-script.Dockerfile
#    volumes:
#      - ./whatever:/scripts

RUN apk --no-cache add curl

RUN touch crontab.tmp \
    && echo '@reboot /run.sh' >> crontab.tmp \
    && echo '0 * * * * /run.sh' >> crontab.tmp \
    && crontab crontab.tmp \
    && rm -rf crontab.tmp

CMD ["/usr/sbin/crond", "-f", "-l", "2"]

#RUN cat <<'EOF' > /run.sh
#EOF
COPY ./run.sh /run.sh
RUN chmod +x /run.sh
