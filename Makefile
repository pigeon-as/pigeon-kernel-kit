SHELL := /bin/bash
.SHELLFLAGS := -euo pipefail -c

ARCH ?= x86_64
VERSION ?= 6.1.102

.PHONY: build build-local verify get-config clean

build:
	docker build \
		--build-arg ARCH=$(ARCH) \
		--build-arg VERSION=$(VERSION) \
		--output type=local,dest=build \
		.

build-local:
	ARCH=$(ARCH) VERSION=$(VERSION) scripts/build.sh

verify:
	scripts/verify.sh $(or $(CONFIG),build/config)

get-config:
	scripts/get-config.sh

clean:
	rm -rf build/ dist/ linux-*
