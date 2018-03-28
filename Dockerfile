FROM ubuntu:16.04

ENV consul_version 0.9.3
ENV compose_version 1.20.1
ENV docker_version 18.03.0

label org.label-schema.schema-version="1.0"
label org.label-schema.build-date="2016-04-12T23:20:50.52Z"
label org.label-schema.name="docker-compose-deploy"
label org.label-schema.description="This service does awesome things with other things"
label org.label-schema.usage="/README.md"
label org.label-schema.vendor="Cloud4wi Inc."
label org.label-schema.vcs-url="https://gitlab.com/cloud4wi/docker-compose-deploy"
label org.label-schema.docker.cmd="docker run -d docker-compose-deploy server"
label org.label-schema.docker.cmd.help="docker exec -it $CONTAINER help"
label org.label-schema.docker.debug="docker exec -it $CONTAINER debug"

RUN set -ex; \
    apt-get update -qq; \
    apt-get install -y \
    jq \
    httpie \
    unzip

ADD https://releases.hashicorp.com/consul/${consul_version}/consul_${consul_version}_linux_amd64.zip /tmp/consul.zip
RUN unzip /tmp/consul.zip -d /usr/local/bin && \
    rm /tmp/consul.zip

ADD https://github.com/progrium/basht/releases/download/v0.1.0/basht_0.1.0_Linux_x86_64.tgz /tmp/basht.tgz
RUN tar xzvf /tmp/basht.tgz && \
    mv basht /usr/local/bin/basht && \
    rm /tmp/basht.tgz

ADD https://github.com/docker/compose/releases/download/${compose_version}/docker-compose-Linux-x86_64 /usr/local/bin/docker-compose

ADD https://download.docker.com/linux/static/stable/x86_64/docker-${docker_version}-ce.tgz /tmp/docker-ce.tgz
RUN tar xzvf /tmp/docker-ce.tgz && \
    mv docker /usr/local/bin/docker && \
    rm /tmp/docker-ce.tgz

RUN mkdir -p /usr/local/lib/bash

COPY README.md /
COPY Dockerfile /
COPY deploy /usr/local/bin
COPY lib.consul.sh /usr/local/lib/bash/
COPY tests /usr/local/src

RUN chmod +x /usr/local/bin/*

ENTRYPOINT [ "/usr/local/bin/deploy" ]
CMD [ "help" ]
