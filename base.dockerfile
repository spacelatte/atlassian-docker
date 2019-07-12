#!/usr/bin/env docker build --compress -t pvtmert/atlassian:base -f

FROM debian:9

WORKDIR /data

RUN apt update && apt dist-upgrade -y && apt install -y nano \
	git curl xz-utils nginx-full procps net-tools dnsutils \
	build-essential openjdk-8-jre-headless openssl ssl-cert

RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

RUN openssl genrsa -out priv.key 4096
RUN openssl req -new -key priv.key -out req.csr -days 3650 -subj '/CN=*'
RUN openssl x509 -req -in req.csr -signkey priv.key -out cert.crt -days 3650

RUN sed -i.old 's:assistive_technologies=:#assistive_technologies=:' /etc/java-8-openjdk/accessibility.properties

RUN ln -sf ../../../data/nginx.conf /etc/nginx/sites-enabled/default
COPY *.xml *.html *.conf ./

RUN nginx -t
RUN keytool -importcert -file cert.crt -alias selfsigned \
	-keystore /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/security/cacerts \
	-storepass changeit -noprompt

RUN keytool -import -trustcacerts \
	-keystore /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/security/cacerts \
	-storepass changeit -noprompt -alias root -file cert.crt

CMD [ "nginx", "-g", "daemon off;" ]
