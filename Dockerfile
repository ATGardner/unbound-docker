# renovate: datasource=github-releases depName=NLnetLabs/unbound extractVersion=^release-(?<version>.*)$
ARG UNBOUND_VERSION=1.26.1

FROM alpine:3.23 AS build
ARG UNBOUND_VERSION
RUN apk add --no-cache \
    build-base \
    openssl-dev \
    expat-dev \
    libevent-dev \
    curl
RUN curl -fsSL "https://nlnetlabs.nl/downloads/unbound/unbound-${UNBOUND_VERSION}.tar.gz" -o /tmp/unbound.tar.gz \
    && mkdir /tmp/unbound \
    && tar xzf /tmp/unbound.tar.gz -C /tmp/unbound --strip-components=1
WORKDIR /tmp/unbound
RUN ./configure \
        --prefix=/usr \
        --sysconfdir=/etc \
        --localstatedir=/var \
        --with-username=unbound \
        --with-libevent \
        --with-ssl \
        --disable-static \
    && make -j"$(nproc)" \
    && make install DESTDIR=/tmp/install

FROM alpine:3.23
RUN apk add --no-cache \
    libevent \
    openssl \
    expat \
    curl \
    && addgroup -S unbound \
    && adduser -S -D -H -G unbound unbound
COPY --from=build /tmp/install/usr/sbin/unbound* /usr/sbin/
COPY --from=build /tmp/install/usr/lib/libunbound* /usr/lib/
COPY entrypoint.sh /sbin/entrypoint.sh
COPY root.hints /var/lib/unbound/root.hints
RUN chmod 755 /sbin/entrypoint.sh

ENTRYPOINT ["/sbin/entrypoint.sh"]
