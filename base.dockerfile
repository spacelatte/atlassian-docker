#!/usr/bin/env docker build --compress -t pvtmert/atlassian:base -f

FROM debian

WORKDIR /data

RUN apt update && apt dist-upgrade -y && apt install -y \
	git curl xz-utils nginx-full procps net-tools \
	build-essential openjdk-8-jre-headless

RUN sed -i.old 's:assistive_technologies=:#assistive_technologies=:' /etc/java-8-openjdk/accessibility.properties

RUN ln -sf ../../../data/nginx.conf /etc/nginx/sites-enabled/default
COPY ./ ./

CMD [ "nginx", "-g", "daemon off;" ]
