FROM ubuntu

ARG CONTAINER_USER=${CONTAINER_USER:-nonroot:nonroot}
ARG CONTAINER_UID=${CONTAINER_UID:-1000}
ARG CONTAINER_GID=${CONTAINER_GID:-1000}

RUN apt-get update \
 && apt-get install -y \
	sudo \
	git \
	curl \
	shunit2

RUN deluser ubuntu
RUN addgroup --gid ${CONTAINER_GID} nonroot \
 && adduser --uid ${CONTAINER_UID} --gid ${CONTAINER_GID} --disabled-password nonroot \
 && echo 'nonroot ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
	
USER ${CONTAINER_USER}
