# base image
ARG ARCH=x86_64
FROM fedora:latest

# args
ARG VCS_REF
ARG BUILD_DATE

# environment
ENV ADMIN_PASSWORD=admin

# labels
LABEL maintainer="Florian Schwab <me@ydkn.io>" \
  org.label-schema.schema-version="1.0" \
  org.label-schema.name="ydkn/cups" \
  org.label-schema.description="Simple CUPS docker image" \
  org.label-schema.version="0.1" \
  org.label-schema.url="https://hub.docker.com/r/ydkn/cups" \
  org.label-schema.vcs-url="https://gitlab.com/ydkn/docker-cups" \
  org.label-schema.vcs-ref=$VCS_REF \
  org.label-schema.build-date=$BUILD_DATE

# install packages
RUN dnf install -y \
  sudo \
  cups \
  cups-filters \
  foomatic-db \
  foomatic-db-ppds \
  foomatic-db-engine \
  foomatic \
  hpijs \
  hplip \
  && dnf clean all

# add print user
RUN useradd -m -s /bin/bash admin \
  && usermod -aG wheel admin \
  && usermod -aG lp admin \
  && usermod -aG lpadmin admin

# disable sudo password checking
RUN echo 'admin ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/admin \
  && chmod 0440 /etc/sudoers.d/admin

# enable access to CUPS
RUN /usr/sbin/cupsd \
  && while [ ! -f /var/run/cups/cupsd.pid ]; do sleep 1; done \
  && cupsctl --remote-admin --remote-any --share-printers \
  && kill $(cat /var/run/cups/cupsd.pid) \
  && echo "ServerAlias *" >> /etc/cups/cupsd.conf

# copy /etc/cups for skeleton usage
RUN cp -rp /etc/cups /etc/cups-skel

# entrypoint
ADD docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT [ "docker-entrypoint.sh" ]

# default command
CMD ["cupsd", "-f"]

# volumes
VOLUME ["/etc/cups"]

# ports
EXPOSE 631