#
# Dockerfile for openconnect-proxy
#

FROM alpine:edge AS ocproxy-builder

RUN set -xe \
    && apk add --no-cache \
               --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/ \
               automake \
               autoconf \
               build-base \
               libevent-dev \
               linux-headers \
    && mkdir -p /usr/local/src \
    && wget -qO- https://github.com/cernekee/ocproxy/archive/v1.60.tar.gz \
    | tar vxz -C /usr/local/src

RUN set -xe \
    && cd /usr/local/src/ocproxy-1.60 \
    && autoreconf --install \
    && ./configure \
    && make

FROM alpine:edge

LABEL maintainer="YGAM" description="OCProxy PulseVPN - Alpine" location="/"

RUN set -xe \
    && apk add --no-cache \
               --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/ \
               libevent \
               openconnect \
               openssl
               
COPY --from=ocproxy-builder /usr/local/src/ocproxy-1.60/ocproxy /usr/local/bin/ocproxy
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
EXPOSE 1080
ENTRYPOINT ["/entrypoint.sh"]
CMD ["--help"]
