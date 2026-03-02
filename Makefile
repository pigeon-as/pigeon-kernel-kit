SHELL := /bin/bash
.SHELLFLAGS := -euo pipefail -c

ARCH ?= x86_64
VERSION ?= 6.1.155
FIRECRACKER_VERSION ?= v1.14.2

.PHONY: build build-local verify get-config e2e clean

build:
	docker build \
		--build-arg ARCH=$(ARCH) \
		--build-arg VERSION=$(VERSION) \
		--output type=local,dest=build \
		.

build-local:
	ARCH=$(ARCH) VERSION=$(VERSION) scripts/build.sh

verify:
	scripts/verify.sh $(or $(CONFIG),build/.config)

get-config:
	FIRECRACKER_VERSION=$(FIRECRACKER_VERSION) KERNEL_VERSION=$(basename $(VERSION)) scripts/get-config.sh

e2e:
	scripts/e2e.sh

clean:
	rm -rf build/ dist/ linux-*
