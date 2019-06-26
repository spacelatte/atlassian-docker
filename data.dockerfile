#!/usr/bin/env docker build --compress -t pvtmert/atlassian:data -f

FROM debian

RUN echo "mysql-server mysql-server/root_password password mypassword"       | debconf-set-selections
RUN echo "mysql-server mysql-server/root_password_again password mypassword" | debconf-set-selections
RUN apt update && apt dist-upgrade -y && apt install -y \
	mysql-server

WORKDIR /data

COPY ./ ./

CMD service mysql start; service mysql status; tail -f /var/log/mysql/error.log
