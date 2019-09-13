#!/usr/bin/env -S docker build --compress -t pvtmert/atlassian:cc -f

FROM debian:8

ARG DEBIAN_FRONTEND=noninteractive

ENV S9S_ROOT_PASSWORD 1234
ENV S9S_CMON_PASSWORD 1234
ENV INNODB_BUFFER_POOL_SIZE 50

WORKDIR /data

RUN echo mysql-server mysql-server/root_password       password "" | debconf-set-selections
RUN echo mysql-server mysql-server/root_password_again password "" | debconf-set-selections

RUN apt update && apt dist-upgrade -y && apt install -y \
	lsb-release python dmidecode bc gnupg software-properties-common \
	nano wget curl

#ADD https://severalnines.com/scripts/install-cc?tO8kqTiuINLDD3AnjLvIkPc_RawPCNwCavdHZYZglYY, install-cc
#ADD https://severalnines.com/scripts/install-cc?qqStXIEuWHn5XIaPSGTM5MbnhjceUDuQhlSzKUPlS5g, install-cc
RUN curl -#kL "https://severalnines.com/scripts/install-cc" | bash
