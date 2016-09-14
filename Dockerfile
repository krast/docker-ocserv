FROM alpine:3.4

MAINTAINER krast <krast@live.cn>

ENV OCSERV_VERSION=0.11.4

# install requires
RUN apk add --update --no-cache gnutls \
                                gnutls-utils \
                                iptables \
                                libev \
                                libintl \
                                libnl3 \
                                libseccomp \
                                linux-pam \
                                lz4 \
                                openssl \
                                readline \
                                sed

# build ocserv
ENV BUILD_REQUIRES="curl g++ \
                    gnutls-dev gpgme libev-dev libnl3-dev \
                    libseccomp-dev linux-headers linux-pam-dev \
                    lz4-dev make readline-dev tar xz \
                   ";

RUN apk add --no-cache $BUILD_REQUIRES \
    && curl -SL "ftp://ftp.infradead.org/pub/ocserv/ocserv-$OCSERV_VERSION.tar.xz" -o ocserv.tar.xz \
    && curl -SL "ftp://ftp.infradead.org/pub/ocserv/ocserv-$OCSERV_VERSION.tar.xz.sig" -o ocserv.tar.xz.sig \
    && gpg --keyserver pgp.mit.edu --recv-key 7F343FA7 \
    && gpg --keyserver pgp.mit.edu --recv-key 96865171 \
    && gpg --verify ocserv.tar.xz.sig \
    && mkdir -p /usr/src/ocserv \
    && tar -xf ocserv.tar.xz -C /usr/src/ocserv --strip-components=1 \
	  && rm ocserv.tar.xz* \
	  && cd /usr/src/ocserv \
    && ./configure \
	  && make \
	  && make install \
	  && cd / \
	  && rm -rf /usr/src/ocserv \
    && apk del $buildDeps \
	  && rm -rf /var/cache/apk/*

# config
RUN mkdir -p /etc/ocserv \
    && mkdir -p /etc/ocserv/config-per-group
COPY ocserv.conf /etc/ocserv/ocserv.conf
COPY All /etc/ocserv/config-per-group/All
COPY Route /etc/ocserv/config-per-group/Route
COPY entrypoint.sh /entrypoint.sh
RUN chmod 700 /entrypoint.sh

WORKDIR /etc/ocserv
EXPOSE 443/tcp
ENTRYPOINT ["/entrypoint.sh"]
CMD ["ocserv", "-c", "/etc/ocserv/ocserv.conf", "-f"]
