# base image
ARG ARCH=x86_64
FROM fedora:latest

# args
ARG VCS_REF
ARG BUILD_DATE

# environment
ENV ADMIN_PASSWORD=admin

# labels
LABEL maintainer="Bruno Finger <bruno.k.finger@gmail.com>" \
  org.label-schema.schema-version="1.0" \
  org.label-schema.name="brunofin/cups" \
  org.label-schema.description="Simple CUPS docker image" \
  org.label-schema.version="0.1" \
  org.label-schema.url="https://hub.docker.com/r/brunofin/cups" \
  org.label-schema.vcs-url="https://github.com/brunofin/docker-cups" \
  org.label-schema.vcs-ref=$VCS_REF \
  org.label-schema.build-date=$BUILD_DATE

# install packages
RUN dnf install -y \
  expect \
  cups \
  cups-filters \
  foomatic-db \
  foomatic-db-ppds \
  foomatic \
  hpijs \
  hplip \
  wget \
  polkit \
  dbus \
  gnupg2 \
  file \
  && dnf clean all

# add print user
RUN useradd -m -s /bin/bash admin \
  && usermod -aG wheel admin \
  && usermod -aG lp admin

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
