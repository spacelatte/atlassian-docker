#!/usr/bin/env docker build --compress -t pvtmert/atlassian:bamboo -f

FROM pvtmert/atlassian:base

ARG VERSION=6.1.1

RUN curl -#L https://www.atlassian.com/software/bamboo/downloads/binary/atlassian-bamboo-${VERSION}.tar.gz \
	| tar --strip-components=1 -xz

EXPOSE 8085

ENV BAMBOO_HOME /home

CMD ./bin/start-bamboo.sh -fg
