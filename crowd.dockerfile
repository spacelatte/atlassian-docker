#!/usr/bin/env docker build --compress -t pvtmert/atlassian:crowd -f

FROM pvtmert/atlassian:base

ARG VERSION=2.12.0

RUN curl -#L https://www.atlassian.com/software/crowd/downloads/binary/atlassian-crowd-${VERSION}.tar.gz \
	| tar --strip-components=1 -xz

CMD ./bin/start-crowd.sh
