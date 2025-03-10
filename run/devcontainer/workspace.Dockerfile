FROM ubuntu

ARG CONTAINER_UID
ARG CONTAINER_GID

WORKDIR /workspace

RUN apt-get update \
 && apt-get install -y \
	sudo \
	git \
	curl \
	bats

RUN if [ ! "${CONTAINER_UID}:${CONTAINER_GID}" = "0:0" ]; then \
        deluser ubuntu \
        && addgroup --gid ${CONTAINER_GID} nonroot \
        && adduser --uid ${CONTAINER_UID} --gid ${CONTAINER_GID} --disabled-password nonroot \
        && echo 'nonroot ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers; \
    fi

USER ${CONTAINER_UID}:${CONTAINER_GID}
