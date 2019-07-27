#!/usr/bin/env docker build --compress -t pvtmert/atlassian:base -f

FROM debian:9

ARG DEBIAN_FRONTEND=noninteractive
ENV JAVA_HOME /opt/jdk8
ENV JRE_HOME ${JAVA_HOME}/jre
ENV PATH "${PATH}:${JAVA_HOME}/bin:${JRE_HOME}/bin"
WORKDIR /data

RUN apt update && apt dist-upgrade -y && apt install -y nano \
	git curl xz-utils nginx-full procps net-tools dnsutils \
	build-essential openssl ssl-cert #openjdk-8-jre-headless

RUN mkdir -p "${JAVA_HOME}" && \
	curl -#kL https://src.n0pe.me/~mert/jdk/jdk8u221.linux.x64.tar.gz \
	| tar --strip-components=1 -C "${JAVA_HOME}" -zx

RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

RUN openssl genrsa -out priv.key 4096
RUN ( \
		echo "[ req ]"                      ; \
		echo "prompt = no"                  ; \
		echo "default_bits = 4096"          ; \
		echo "default_md = sha256"          ; \
		echo "req_extensions  = req_ext"    ; \
		echo "x509_extensions = req_ext"    ; \
		echo "distinguished_name = dn"      ; \
		echo "[ dn ]"                       ; \
		echo "CN = Docker-Swarm/Stack"      ; \
		echo "[ req_ext ]"                  ; \
		echo "subjectAltName = @alt_names"  ; \
		echo "[ alt_names ]"                ; \
		echo "DNS.1 = *.atl.direct.n0pe.me" ; \
		echo "DNS.2 = *.direct.n0pe.me"     ; \
		echo "DNS.3 = *.internal"           ; \
		echo "DNS.4 = *.local"              ; \
		echo "DNS.5 = *.base"               ; \
		echo "DNS.6 = internal"             ; \
		echo "DNS.7 = local"                ; \
		echo "DNS.8 = base"                 ; \
		echo "DNS.9 = data"                 ; \
	) | openssl req -new -x509 -sha256 -key priv.key -out cert.crt -days 3650 -config /dev/stdin
#RUN openssl x509 -req -in req.csr -signkey priv.key -out cert.crt -days 3650

RUN test -e /etc/java-8-openjdk/accessibility.properties && \
	sed -i.old 's:assistive_technologies=:#assistive_technologies=:' \
	/etc/java-8-openjdk/accessibility.properties || echo "skipping..."

RUN ln -sf ../../../data/nginx.conf /etc/nginx/sites-enabled/default
COPY *.xml *.html *.conf ./
RUN nginx -t

### a
#RUN keytool -importcert -file cert.crt \
#	-keystore /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/security/cacerts \
#	-storepass changeit -alias selfsigned -noprompt
#RUN keytool -import -trustcacerts \
#	-keystore /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/security/cacerts \
#	-storepass changeit -noprompt -alias root -file cert.crt

### b
#RUN keytool -importcert -file cert.crt -keystore /etc/ssl/certs/java/cacerts \
#	-storepass changeit -alias selfsigned -noprompt
#RUN keytool -import -trustcacerts -keystore /etc/ssl/certs/java/cacerts \
#	-storepass changeit -noprompt -alias root -file cert.crt

### c
RUN keytool -importcert -file cert.crt \
	-keystore "${JAVA_HOME}/jre/lib/security/cacerts" \
	-storepass changeit -alias selfsigned -noprompt
RUN keytool -import -trustcacerts \
	-keystore "${JAVA_HOME}/jre/lib/security/cacerts" \
	-storepass changeit -noprompt -alias root -file cert.crt

RUN true \
	&& cp -v cert.crt /etc/ssl/certs/local.pem          \
	&& cp -v cert.crt /usr/local/share/ca-certificates/ \
	&& update-ca-certificates                           \
	&& cat cert.crt | tee -a /etc/ssl/certs/ca-certificates.crt

CMD [ "nginx", "-g", "daemon off;" ]
