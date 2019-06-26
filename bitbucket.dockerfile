#!/usr/bin/env docker build --compress -t pvtmert/atlassian:bitbucket -f

FROM pvtmert/atlassian:base

ARG VERSION=5.1.3

RUN curl -#L https://www.atlassian.com/software/stash/downloads/binary/atlassian-bitbucket-${VERSION}.tar.gz \
	| tar --strip-components=1 -xz


EXPOSE 7990

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV BITBUCKET_HOME /home

RUN mkdir -p "${BITBUCKET_HOME}/shared"
RUN ( \
	echo "#server.port=7990";                \
	echo "#server.scheme=http";              \
	echo "#server.secure=false";             \
	echo "#server.proxy-port=80";            \
	echo "#server.proxy-name=atlassian";     \
	echo "server.context-path=/bitbucket";  \
) | tee -a "${BITBUCKET_HOME}/shared/bitbucket.properties"

CMD ./bin/start-bitbucket.sh -fg
