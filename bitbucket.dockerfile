#!/usr/bin/env docker build --compress -t pvtmert/atlassian:bitbucket -f

FROM pvtmert/atlassian:base

ARG VERSION=5.1.3

RUN curl -#L https://www.atlassian.com/software/stash/downloads/binary/atlassian-bitbucket-${VERSION}.tar.gz \
	| tar --strip-components=1 -xz


EXPOSE 7990

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV BITBUCKET_HOME /home

CMD ./bin/start-bitbucket.sh -fg
