#!/usr/bin/env make -f

JOBS := 1
SUFF := atl
IMAG := pvtmert/atlassian

%.docker: %.dockerfile
	chmod +x $<
	./$< .

default:
	# use 'containers', 'compose' or 'run'

containers: $(addsuffix .docker, cc dns base data jira crowd bamboo bitbucket confluence)

compose: docker-compose.yml containers
	chmod +x ./$<
	./$< up

run: compose

fixshebang:
	sed -i 's:/usr/bin/env:/usr/bin/env -S:' *.dockerfile docker-compose.yml

altbuild:
	grep env base.dockerfile *.dockerfile | tr : \  | while read x; do \
		y=( $$x ); $${y[@]:2:5}:$${y[@]:7:4} $${y[0]} .; \
	done

push pull:
	echo cc dns base data jira crowd bamboo bitbucket confluence | tr \  \\n \
	| xargs -P$(JOBS) -n1 -I% -- docker $@ $(IMAG):%; echo $$?

down:
	ssh -oBatchMode=yes mgr.$(SUFF) -- docker stack rm $(SUFF);
	sleep 5; for i in mgr {0..5}; do \
		echo; ssh -oBatchMode=yes $$i.$(SUFF) -- "\
			docker ps -qa | xargs docker stop; \
			yes | docker container prune -f; \
			yes | docker network prune   -f; \
			yes | docker volume prune    -f; \
			yes | docker image prune     -f; \
			yes | docker system prune    -f; \
		" & \
	done; wait;

fetch:
	for i in mgr {0..5}; do \
		ssh -oBatchMode=yes $$i.$(SUFF) -- "\
			echo cc dns base data jira crowd bamboo bitbucket confluence \
			| xargs -n1 | xargs -P$(JOBS) -n1 -I% -- docker pull $(IMAG):%; \
		" & \
	done; wait

stat:
	for i in mgr {0..5}; do \
		ssh -oBatchMode=yes $$i.$(SUFF) -- "\
			docker system df ; \
			docker ps -a     ; \
		" ; \
	done 2>/dev/null

up:
	scp -oBatchMode=yes docker-compose.yml mgr.$(SUFF):.
	ssh -oBatchMode=yes mgr.$(SUFF) -- docker stack deploy -c docker-compose.yml $(SUFF)
	# ok

rb:
	ssh mgr.$(SUFF) -- 'uname; \
		sudo mkdir -p /opt/bin && \
		sudo curl -#kL https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$$(uname -s)-$$(uname -m) \
			-o /opt/bin/docker-compose && \
		sudo chmod +x /opt/bin/docker-compose'
	ssh -oBatchMode=yes         mgr.$(SUFF) -- rm -vrf  $@/
	ssh -oBatchMode=yes         mgr.$(SUFF) -- mkdir -p $@/
	scp -oBatchMode=yes -vr ./* mgr.$(SUFF):$@/
	ssh -oBatchMode=yes         mgr.$(SUFF) -- "cd $@/; docker build -t $(IMAG):base -f base.dockerfile ."
	ssh -oBatchMode=yes         mgr.$(SUFF) -- "cd $@/; /opt/bin/docker-compose build --compress --parallel"
	ssh -oBatchMode=yes         mgr.$(SUFF) -- "docker images --format {{.Repository}}:{{.Tag}} \
		| grep -v '<none>' | grep $(IMAG) | xargs -n1 -P$(JOBS) -- docker push"
	ssh -oBatchMode=yes         mgr.$(SUFF) -- rm -vrf $@/
