FROM alpine:3.10 as builder

LABEL maintainer="ljm625 <ljm625@gmail.com> "



WORKDIR /

RUN  apk update && \
    apk add --no-cache git  build-base linux-headers wget && \
    git clone https://github.com/wangyu-/udp2raw-tunnel.git  && \
    cd udp2raw-tunnel && \
    make dynamic && \
    mv udp2raw_dynamic /bin/udp2raw && \
    cd / && \
    git clone https://github.com/wangyu-/UDPspeeder.git && \
    cd UDPspeeder && \
    make && \
    install speederv2 /bin


FROM mritd/shadowsocks:3.3.4

SHELL ["/bin/bash", "-c"]

RUN apk update && \
    apk add --no-cache libstdc++ iptables && \
    rm -rf /var/cache/apk/* && \
    mkdir -p /etc/v2ray/ && \
    touch /etc/v2ray/v2ray.crt && \
    touch /etc/v2ray/v2ray.key
COPY --from=builder /bin/udp2raw /usr/bin
COPY --from=builder /bin/speederv2 /usr/bin

COPY runit /etc/service
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
