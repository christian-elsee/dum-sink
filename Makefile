.DEFAULT_GOAL := all
.SHELLFLAGS := -euo pipefail $(if $(TRACE),-x,) -c
.ONESHELL:
.DELETE_ON_ERROR:

## env ##########################################
export NAME := $(shell basename $(PWD))
export PATH := dist/bin:$(PATH)

## interface ####################################
all: distclean dist build check
install:

## main #########################################
distclean:
	: ## $@
	rm -rf dist

dist:
	: ## $@
	mkdir -p $@ $@/bin


build: OVERLAYS ?=
build: base.yaml
	: ## $@
	cat $< $(OVERLAYS) \
		| yq --yaml-output --explicit-start -s add \
		| tee dist/cluster.yaml \
		| md5sum \
		| cut -f1 -d" " \
		| tee dist/checksum

	{ eksctl create cluster \
			--dry-run \
			-f dist/cluster.yaml \
		| tee /dev/fd/100 \
		| sed -E 's/Assume[^:]*\:\s*//' \
				>dist/plan.yaml \
	;} 100>&1

check: dist/plan.yaml
	: ## $@
	<$< yq --yaml-output --explicit-start -re .

install: dist/plan.yaml
	: ## $@
	eksctl create cluster \
		-f $< \
	||:
	eksctl utils write-kubeconfig \
		-f dist/plan.yaml	\
		--kubeconfig dist/kubeconfig
	eksctl get cluster -f $< -oyaml \
		| tee dist/get-cluster.yaml

	# create a tarball and publish to artifacts
	tar -cv \
			-C dist \
			-f dist/cluster.tar.$(shell cat dist/checksum) \
			--exclude="bin" \
			--exclude="cluster.tar.$(shell cat dist/checksum)" \
		.
	cp dist/cluster.tar.$(shell cat dist/checksum) assets

test:
	: ## $@
	prove -v

clean: dist/plan.yaml
	: ## $@
	eksctl delete cluster -f $<

setup: assets
	: ## $@
	pwd \
		| awk -F/ '{ printf "%s/%s/%s", $$(NF-2), $$(NF-1), $$NF }' \
		| xargs -0 -- go mod init \
	||:
	go mod tidy

assets:
	: ## $@

