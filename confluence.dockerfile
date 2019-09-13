#!/usr/bin/env -S docker build --compress -t pvtmert/atlassian:confluence -f

FROM pvtmert/atlassian:base

ARG VERSION=6.2.3

RUN curl -#kL https://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-${VERSION}.tar.gz \
	| tar --strip-components=1 -xz

EXPOSE 8090

ENV CONFLUENCE_HOME /home

RUN ( \
	echo; \
	echo confluence.home=/home; \
	echo; \
) | tee -a ./confluence/WEB-INF/classes/confluence-init.properties

COPY ./confluence.server.xml ./conf/server.xml

CMD ./bin/start-confluence.sh -fg
