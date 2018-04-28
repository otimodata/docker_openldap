FROM otimo/cyrus-sasl-build AS ldap-build
LABEL Name="openldap-build" Intermediate="yes" \
    Maintainer="Otimo Data AB"

ARG name=openldap
ARG version=2.4.46
ARG checksum=9a90dcb86b99ae790ccab93b7585a31fbcbeec8c94bf0f7ab0ca0a87ea0c4b2d

WORKDIR /build

COPY patch/*.patch ./

RUN echo "${checksum}  ${name}-${version}.tgz" > CHECKSUM \
        && sha256sum -c CHECKSUM \
        || [ $? == 1 ] && wget ftp://ftp.openldap.org/pub/OpenLDAP/openldap-release/${name}-${version}.tgz \
        && sha256sum -c CHECKSUM \
\
    && tar -xzf ${name}-${version}.tgz \
    && cd ${name}-${version} \
    && patch -Np1 -i ../libressl.patch \
    && patch -Np1 -i ../openldap-2.4-ppolicy.patch \
    && patch -Np1 -i ../openldap-2.4.11-libldap_r.patch \
    && sed -i '/^STRIP/s,-s,,g' build/top.mk \
    && libtoolize --force && aclocal && autoconf \
    && ./configure \
        --prefix=/usr \
        --sysconfdir=/etc \
        --libexecdir=/usr/lib \
        --localstatedir=/run \
        --disable-static \
        --with-tls=openssl \
        --with-cyrus-sasl \
        --enable-dynamic \
        --enable-crypt \
        --enable-spasswd \
        --enable-slapd \
        --enable-modules \
        --enable-rlookups \
        --enable-backends=mod \
        --enable-mdb \
        --disable-perl \
        --disable-ndb \
        --disable-sql \
        --disable-shell \
        --disable-bdb \
        --disable-hdb \
        --enable-overlays=mod \
    && sed -i 's/"run" LDAP_DIRSEP "ldapi"/"ldapi"/g' include/ldap_defaults.h \
    && make \
    && make depend \
    && make install DESTDIR=/build/install \
\
    && cd /build/install \
    && rm -rf usr/include \
    && rm -rf usr/share \
    && rm -rf run/run \
    && rm etc/openldap/*.default \
    && rm etc/openldap/slapd.conf \
    && find . -name "*.la" -exec rm {} \; \
    && for path in $(find usr/sbin/ -type l); do ln -sf slapd $path; done \
    && mv usr/lib/slapd usr/sbin/ \
    && tar --remove-files -czf /build/symlinks.tgz $(find . -type l) \
    && sed -i -e 's:run/run:run/openldap:g' -e 's:run/openldap-data:srv/openldap/data:g' etc/openldap/slapd.ldif \
    && strip usr/bin/* || true \
    && strip usr/sbin/* || true \
    && strip usr/lib/*.so* || true \
    && strip usr/lib/openldap/*.so* || true \
    && mkdir usr/lib/sasl2


FROM scratch AS builder
COPY --from=ldap-build /bin/pause /bin/
COPY --from=ldap-build /build/install/. /
COPY --from=ldap-build /build/symlinks.tgz /tmp/

COPY --from=ldap-build \
    /usr/lib/libuuid.so \
    /usr/lib/libltdl.so.7 \
    /usr/lib/libsasl2.so.3 /usr/lib/

COPY files/ /


FROM alpine:3.7
LABEL Name="openldap" \
    Maintainer="Otimo Data AB"

COPY --from=builder / /

RUN tar -xvzf /tmp/symlinks.tgz \
    && rm -rf /tmp/symlinks.tgz \
    && rm -rf /etc/init.d \
    && addgroup -S -g 3006 openldap \
    && adduser -S -u 3006 -D -h /srv/openldap -s /bin/sh -G openldap openldap \
    && ln -sf libuuid.so /usr/lib/libuuid.so.1 \
    && chmod +x /start.sh

EXPOSE 389 636

STOPSIGNAL SIGTERM

CMD ["/start.sh"]
