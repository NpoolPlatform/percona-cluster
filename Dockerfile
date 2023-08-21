FROM uhub.service.ucloud.cn/entropypool_public/pmm-server:2.39.0

RUN mkdir -p /usr/local/bin
RUN mv /opt/entrypoint.sh  /opt/entrypoint-inner.sh

COPY .docker-tmp/consul /usr/bin/consul
COPY entrypoint.sh /opt

RUN chmod a+x /opt/entrypoint.sh
