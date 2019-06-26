#!/usr/bin/env docker build --compress -t pvtmert/atlassian:base -f

FROM debian

WORKDIR /data

RUN apt update && apt dist-upgrade -y && apt install -y \
	git curl xz-utils nginx-full procps net-tools dnsutils \
	build-essential openjdk-8-jre-headless openssl ssl-cert

RUN openssl genrsa -out priv.key 4096
RUN openssl req -new -key priv.key -out req.csr -days 3650 -subj '/CN=*'
RUN openssl x509 -req -in req.csr -signkey priv.key -out cert.crt -days 3650

RUN sed -i.old 's:assistive_technologies=:#assistive_technologies=:' /etc/java-8-openjdk/accessibility.properties

RUN ln -sf ../../../data/nginx.conf /etc/nginx/sites-enabled/default
COPY *.xml *.html *.conf ./

CMD [ "nginx", "-g", "daemon off;" ]
