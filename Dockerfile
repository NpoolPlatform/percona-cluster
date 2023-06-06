FROM percona/pmm-server:2.37.0

RUN mkdir -p /usr/local/bin
RUN mv /opt/entrypoint.sh  /opt/entrypoint-inner.sh

COPY .docker-tmp/consul /usr/bin/consul
COPY entrypoint.sh /opt

RUN chmod a+x /opt/entrypoint.sh
