#!/usr/bin/env docker build --compress -t pvtmert/atlassian:storage -f

FROM debian

WORKDIR /data

RUN apt update && apt dist-upgrade -y && apt install -y \
	nfs-common nfs-kernel-server nano

RUN ( \
	echo; \
	echo "/data *(insecure,rw,sync,no_subtree_check,all_squash,anonuid=0,anongid=0,crossmnt,fsid=0)"; \
	echo; \
) | tee -a /etc/exports

CMD service nfs-kernel-server start; exportfs -ra; tail -f /var/log/daemon.log
