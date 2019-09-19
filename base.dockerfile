#!/usr/bin/env -S docker build --compress -t pvtmert/atlassian:base -f

FROM debian

ARG DEBIAN_FRONTEND=noninteractive
RUN apt update
RUN apt dist-upgrade -y && apt install -y nano \
	git curl xz-utils nginx-full procps net-tools dnsutils \
	build-essential openssl ssl-cert #default-jdk-headless

ENV JAVA_HOME /opt/jdk8
ENV JRE_HOME ${JAVA_HOME}/jre
ENV PATH "${PATH}:${JAVA_HOME}/bin:${JRE_HOME}/bin"

RUN mkdir -p "${JAVA_HOME}" && \
	curl -#kL https://src.n0pe.me/~mert/jdk/jdk8u221.linux.x64.tar.gz \
	| tar --strip-components=1 -C "${JAVA_HOME}" -zx

WORKDIR /data
RUN ln -sf bash /bin/sh
ARG DOMAINS='*.direct.n0pe.me *.atl.direct.n0pe.me'
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
		echo "DNS.0 = swarm.docker"         ; \
		echo "DNS.1 = *.internal"           ; \
		echo "DNS.2 = *.local"              ; \
		echo "DNS.3 = *.base"               ; \
		echo "DNS.4 = internal"             ; \
		echo "DNS.5 = local"                ; \
		echo "DNS.6 = base"                 ; \
		echo "DNS.7 = data"                 ; \
		export X=8; for dom in ${DOMAINS}; do \
			echo "DNS.$((X++)) = ${dom}" ; \
		done; \
	) | tee ssl.cfg | openssl req -new -x509 -sha256 -newkey rsa:4096 \
	-keyout priv.key -out cert.crt  \
	-nodes -set_serial 0 -days 3650 \
	-config /dev/stdin

RUN test -e /etc/java-8-openjdk/accessibility.properties && \
	sed -i.old 's:assistive_technologies=:#assistive_technologies=:' \
	/etc/java-8-openjdk/accessibility.properties || echo "skipping..."

RUN keytool -importcert -file cert.crt \
	-keystore "${JAVA_HOME}/jre/lib/security/cacerts" \
	-storepass changeit -alias selfsigned -noprompt
RUN keytool -import -trustcacerts \
	-keystore "${JAVA_HOME}/jre/lib/security/cacerts" \
	-storepass changeit -noprompt -alias root -file cert.crt

RUN ln -sf /dev/stderr /var/log/nginx/error.log
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf ../../../data/nginx.conf /etc/nginx/sites-enabled/default
RUN ( \
		echo "stream {"                   ; \
		echo "  include stream.d/*.conf;" ; \
		echo "}"                          ; \
	) | tee -a /etc/nginx/nginx.conf
RUN mkdir -p /etc/nginx/stream.d && ( \
		echo "server {"                    ; \
		echo "  listen 53;"                ; \
		echo "  listen 53 udp reuseport;"  ; \
		echo "  proxy_pass 127.0.0.11:53;" ; \
		echo "  proxy_timeout 10s;"        ; \
		echo "}"                           ; \
	) | tee  /etc/nginx/stream.d/dns.conf
COPY *.xml *.html *.conf ./
RUN nginx -t

RUN true \
	&& cp -v cert.crt /etc/ssl/certs/local.pem          \
	&& cp -v cert.crt /usr/local/share/ca-certificates/ \
	&& update-ca-certificates                           \
	&& cat cert.crt | tee -a /etc/ssl/certs/ca-certificates.crt

CMD [ "nginx", "-g", "daemon off;" ]
