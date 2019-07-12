#!/usr/bin/env docker build --compress -t pvtmert/atlassian:dns -f

FROM debian:9

RUN apt update && apt dist-upgrade -y && \
	apt install -y nano dnsmasq net-tools dnsutils

EXPOSE 53
EXPOSE 5353
WORKDIR /data

COPY *.conf ./

CMD dnsmasq -d -C dns.conf
