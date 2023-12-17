# Build Stage
FROM golang:1.18-bullseye AS builder

ARG checkout="master"
ARG git_url="https://github.com/ElementsProject/peerswap"

RUN git clone $git_url /go/src/github.com/ElementsProject/peerswap \
&&  cd /go/src/github.com/ElementsProject/peerswap \
&&  git checkout $checkout \
&&  make lnd-release


# Final Stage
FROM debian:bullseye-slim as final

RUN apt-get update \
&& apt-get install -y bash jq curl vim ca-certificates

COPY --from=builder /go/bin/peerswapd /bin/
COPY --from=builder /go/bin/pscli /bin/

VOLUME /root/.peerswap

# Expose grpc,rest ports.
EXPOSE 42069 42070

# Run the application
ENTRYPOINT ["peerswapd"]
