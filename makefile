#!/usr/bin/env make -f

JOBS := 1
SUFF := atl
IMAG := pvtmert/atlassian

%.docker: %.dockerfile
	chmod +x $<
	./$< .

default:
	# use 'containers', 'compose' or 'run'

containers: $(addsuffix .docker, dns base data jira crowd bamboo bitbucket confluence)

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
	echo dns base data jira crowd bamboo bitbucket confluence | tr \  \\n \
	| xargs -P$(JOBS) -n1 -I% -- docker $@ $(IMAG):%; echo $$?

down:
	ssh -oBatchMode=yes mgr.$(SUFF) -- docker stack rm $(SUFF);
	sleep 5; for i in mgr {0..5}; do \
		ssh -oBatchMode=yes $$i.$(SUFF) -- "\
			docker ps -qa | xargs docker stop; \
			yes | docker container prune;  \
			yes | docker network prune;    \
			yes | docker volume prune;     \
			yes | docker image prune;      \
			yes | docker system prune -f;  \
		" & \
	done; wait;

fetch:
	for i in mgr {0..5}; do \
		ssh -oBatchMode=yes $$i.$(SUFF) -- "\
			echo dns base data jira crowd bamboo bitbucket confluence \
			| xargs -P$(JOBS) -d\\  -n1 -I% -- docker pull $(IMAG):%; \
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
