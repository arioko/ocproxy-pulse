FROM ubuntu:22.04 AS ocproxy-builder

RUN apt-get update && \
    apt-get install -y gcc binutils make automake autoconf libevent-dev linux-headers-generic wget tar && \
    mkdir -p /usr/local/src && \
    wget -qO- https://github.com/cernekee/ocproxy/archive/v1.60.tar.gz | tar vxz -C /usr/local/src

RUN cd /usr/local/src/ocproxy-1.60 && \
    autoreconf --install && \
    ./configure && \
    make

FROM ubuntu:22.04

LABEL maintainer="YGAM"

ENV TZ Europe/Madrid
ENV LANGUAGE es_ES
ENV LANG es_ES.UTF-8
ENV LC_ALL es_ES.UTF-8

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y curl bash tzdata jq locales locales-all openconnect openssl openfortivpn libevent-dev net-tools && \
    ln -snf /usr/share/zoneinfo/Europe/Madrid /etc/localtime && echo "Europe/Madrid" > /etc/timezone

# Configuramos el idioma
RUN sed -i '/es_ES.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=es_ES.UTF-8 LANGUAGE=es_ES LC_ALL=es_ES.UTF-8

#COPY ./cert /cert
COPY --from=ocproxy-builder /usr/local/src/ocproxy-1.60/ocproxy /usr/local/bin/ocproxy
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY ./openssl.cnf /openssl.cnf
ENV OPENSSL_CONF=/openssl.cnf

EXPOSE 1080

ENTRYPOINT ["/entrypoint.sh"]
CMD ["--help"]
