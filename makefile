#!/usr/bin/env make -f

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

fixshebang:
	sed -i 's:/usr/bin/env:/usr/bin/env -S:' *.dockerfile docker-compose.yml

altbuild:
	grep env base.dockerfile *.dockerfile | tr : \  | while read x; do \
		y=( $$x ); $${y[@]:2:5}:$${y[@]:7:4} $${y[0]} .; \
	done
