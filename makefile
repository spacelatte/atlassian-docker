#!/usr/bin/env make -j4 -f

%.docker: %.dockerfile
	chmod +x $<
	./$< .

default:
	# use 'containers', 'compose' or 'run'

containers: $(addsuffix .docker, base crowd bamboo bitbucket confluence)

compose: docker-compose.yml containers
	chmod +x ./$<
	./$< up

run: compose
