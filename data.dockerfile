#!/usr/bin/env docker build --compress -t pvtmert/atlassian:data -f

FROM scratch

COPY ./ ./

