
all:
	@echo 'try: make [ build | run | shell | rm ]'

build: Dockerfile
	docker build --tag=last .

run: build
	docker run -it -P --name=last last

shell: build
	docker run -it -P --name=last last /bin/bash

rm:
	docker rm last
