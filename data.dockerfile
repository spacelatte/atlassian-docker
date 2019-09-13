#!/usr/bin/env -S docker build --compress -t pvtmert/atlassian:data -f

FROM debian:9

ARG DEBIAN_FRONTEND=noninteractive

RUN echo mysql-server mysql-server/root_password       password "" | debconf-set-selections
RUN echo mysql-server mysql-server/root_password_again password "" | debconf-set-selections

RUN apt update && apt dist-upgrade -y && apt install -y \
	mysql-server postgresql-all openssh-server

RUN echo "listen_addresses = '*'"         | tee -a /etc/postgresql/9.6/main/postgresql.conf
RUN echo "host  all  all  0.0.0.0/0  md5" | tee -a /etc/postgresql/9.6/main/pg_hba.conf
RUN sed -i 's: md5: trust:g'                       /etc/postgresql/9.6/main/pg_hba.conf
RUN sed -i 's:^max_connections = 100:max_connections = 1000:g' \
	/etc/postgresql/9.6/main/postgresql.conf

RUN service postgresql start; sleep 1; \
	for app in jira crowd bamboo bitbucket confluence; do ( \
			echo "CREATE USER     ${app};"                            ;\
			echo "CREATE DATABASE ${app};"                            ;\
			echo "GRANT ALL PRIVILEGES ON DATABASE ${app} TO ${app};" ;\
		) | psql -hlocalhost -Upostgres; \
	done; service postgresql stop

RUN echo "PermitRootLogin yes"      | tee -a /etc/ssh/sshd_config
RUN echo "PermitEmptyPasswords yes" | tee -a /etc/ssh/sshd_config
RUN sed -i 's:^UsePAM yes:UsePAM no:g'       /etc/ssh/sshd_config

WORKDIR /data

COPY *.conf ./

EXPOSE 3306
EXPOSE 5432

CMD true; \
	service ssh start; \
	service ssh status; \
	service mysql start; \
	service mysql status; \
	service postgresql start; \
	service postgresql status; \
	tail -f \
		/var/log/mysql/error.log \
		/var/log/postgresql/postgresql-9.6-main.log
