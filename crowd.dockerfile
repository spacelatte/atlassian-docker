#!/usr/bin/env -S docker build --compress -t pvtmert/atlassian:crowd -f

FROM pvtmert/atlassian:base

ARG VERSION=2.12.0

RUN curl -#kL https://www.atlassian.com/software/crowd/downloads/binary/atlassian-crowd-${VERSION}.tar.gz \
	| tar --strip-components=1 -xz

COPY ./crowd.server.xml ./apache-tomcat/conf/server.xml

RUN ( \
	echo; \
	echo "crowd.home=/home"; \
	echo; \
) | tee -a ./crowd-webapp/WEB-INF/classes/crowd-init.properties

EXPOSE 8095

CMD ./start_crowd.sh run; tail -f ./apache-tomcat/logs/catalina.out
