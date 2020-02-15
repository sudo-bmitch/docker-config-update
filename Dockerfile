ARG DOCKER_VER=stable
FROM docker:${DOCKER_VER}

RUN apk add --no-cache jq

COPY docker-config-update /usr/local/bin/

ENTRYPOINT [ "/usr/local/bin/docker-config-update" ]
