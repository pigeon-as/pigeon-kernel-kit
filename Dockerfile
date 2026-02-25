FROM ubuntu:24.04 AS builder

ARG ARCH=x86_64
ARG VERSION=6.1.102

RUN apt-get update && apt-get install -y --no-install-recommends \
    bc \
    bison \
    ca-certificates \
    cpio \
    curl \
    flex \
    gcc \
    gcc-aarch64-linux-gnu \
    libelf-dev \
    libssl-dev \
    make \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
COPY configs/ configs/
COPY scripts/ scripts/

RUN ARCH=${ARCH} VERSION=${VERSION} scripts/build.sh

FROM scratch
COPY --from=builder /src/dist/ /
