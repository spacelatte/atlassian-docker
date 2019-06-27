#!/usr/bin/env docker build --compress -t pvtmert/atlassian:data -f

FROM debian

RUN echo mysql-server mysql-server/root_password password ""       | debconf-set-selections
RUN echo mysql-server mysql-server/root_password_again password "" | debconf-set-selections
RUN apt update && apt dist-upgrade -y && apt install -y \
	mysql-server postgresql-all

RUN echo "listen_addresses = '*'" | tee -a /etc/postgresql/9.6/main/postgresql.conf
RUN echo "host  all  all  0.0.0.0/0  md5" | tee -a /etc/postgresql/9.6/main/pg_hba.conf
RUN sed -i 's: md5: trust:g' /etc/postgresql/9.6/main/pg_hba.conf

RUN service postgresql start; sleep 1; \
	psql -hlocalhost -U postgres -c "CREATE DATABASE jira;";       \
	psql -hlocalhost -U postgres -c "CREATE DATABASE crowd;";      \
	psql -hlocalhost -U postgres -c "CREATE DATABASE bamboo;";     \
	psql -hlocalhost -U postgres -c "CREATE DATABASE bitbucket;";  \
	psql -hlocalhost -U postgres -c "CREATE DATABASE confluence;"; \
	service postgresql stop

WORKDIR /data

COPY ./ ./

EXPOSE 3306
EXPOSE 5432

CMD true; \
	service mysql start; \
	service mysql status; \
	service postgresql start; \
	service postgresql status; \
	tail -f \
		/var/log/mysql/error.log \
		/var/log/postgresql/postgresql-9.6-main.log
