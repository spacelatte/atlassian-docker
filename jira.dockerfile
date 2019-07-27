#!/usr/bin/env docker build --compress -t pvtmert/atlassian:jira -f

FROM pvtmert/atlassian:base

ARG VERSION=7.4.0

# https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-6.4.14.tar.gz
RUN curl -#kL https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-software-${VERSION}.tar.gz \
	| tar --strip-components=1 -xz


EXPOSE 8080

ENV JIRA_HOME /home
#ENV JAVA_HOME ${JAVA_HOME:-/usr/lib/jvm/java-8-openjdk-amd64}
#ENV JRE_HOME ${JAVA_HOME}/jre

#RUN sed -i.fix 's:"java version":"openjdk version":' bin/check-java.sh

COPY ./jira.server.xml ./conf/server.xml

CMD ./bin/start-jira.sh -fg
