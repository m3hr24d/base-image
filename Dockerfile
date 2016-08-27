FROM dockerzone/debian
MAINTAINER Mohammad Abdoli Rad <m.abdolirad@gmail.com>

STOPSIGNAL SIGCONT
LABEL Description='A minimal Debian base image modified for Docker'

ARG APT_CACHER_SERVER
ARG INSTALL_SSHD=false
ARG INSTALL_CRON=false
ARG INSTALL_SYSLOG_NG=true
ARG INSTALL_NGINX=false
ARG INSTALL_SUPERVISOR=false
ARG INSTALL_GEARMAN=false
ARG INSTALL_TINYDNS=false
ARG DEBUG=false

ENV ENVIRONMENTS_DIR=/etc/stuff/environments \
    ENVIRONMENTS_SCRIPT=/etc/stuff/environments.sh

ADD ./assets /build
RUN chmod -R 755 /build/* \
    && mv /build/bin/* /sbin \
    && mv /build/runit /etc \
    && mkdir -p /etc/runit/1.d

RUN /build/prepare.sh \
    && /build/install-services.sh \
    && /build/cleanup.sh

ENTRYPOINT ["/sbin/entrypoint"]
