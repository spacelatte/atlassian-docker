#!/usr/bin/env make -j4 -f

%.docker: %.dockerfile
	chmod +x $<
	./$< .

default: docker-compose.yml $(addsuffix .docker, base crowd bamboo bitbucket confluence)
	chmod +x ./$<
	./$< up
