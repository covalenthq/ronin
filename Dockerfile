# Build Geth in a stock Go builder container
FROM golang:1.21.12-alpine3.19@sha256:09bee2477a2a56bed70692baa08a394d5b20eebaf6a2e6a620a1eb22200c42c8 as builder

RUN apk add --no-cache make gcc musl-dev linux-headers git libstdc++-dev

COPY . /opt
RUN cd /opt && make ronin

# Pull Geth into a second stage deploy alpine container
FROM alpine:3.18@sha256:48d9183eb12a05c99bcc0bf44a003607b8e941e1d4f41f9ad12bdcc4b5672f86

RUN apk add --no-cache ca-certificates openssl=3.1.6-r0 busybox=1.36.1-r7
WORKDIR "/opt"

ENV PASSWORD ''
ENV PRIVATE_KEY ''
ENV BOOTNODES ''
ENV VERBOSITY 3
ENV SYNC_MODE 'snap'
ENV NETWORK_ID '2021'
ENV ETHSTATS_ENDPOINT ''
ENV NODEKEY ''
ENV FORCE_INIT 'true'
ENV RONIN_PARAMS ''
ENV INIT_FORCE_OVERRIDE_CHAIN_CONFIG 'false'
ENV ENABLE_FAST_FINALITY 'true'
ENV ENABLE_FAST_FINALITY_SIGN 'false'
ENV BLS_PRIVATE_KEY ''
ENV BLS_PASSWORD ''
ENV BLS_AUTO_GENERATE 'false'
ENV BLS_SHOW_PRIVATE_KEY 'false'
ENV GENERATE_BLS_PROOF 'false'

COPY --from=builder /opt/build/bin/ronin /usr/local/bin/ronin
COPY --from=builder /opt/genesis/ ./
COPY --from=builder /opt/docker/chainnode/entrypoint.sh ./

EXPOSE 7000 6060 8545 8546 30303 30303/udp

ENTRYPOINT ["./entrypoint.sh"]
