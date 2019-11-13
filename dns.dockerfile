#!/usr/bin/env -S docker build --compress -t pvtmert/atlassian:dns -f

FROM debian

RUN apt update
RUN apt dist-upgrade -y && \
	apt install -y nano dnsmasq net-tools dnsutils

EXPOSE 53 5353
WORKDIR /data

COPY *.conf ./

CMD dnsmasq -d -C dns.conf
