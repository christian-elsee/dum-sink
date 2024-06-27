.DEFAULT_GOAL := all
.SHELLFLAGS := -euo pipefail $(if $(TRACE),-x,) -c
.ONESHELL:
.DELETE_ON_ERROR:

## env ##########################################
export NAME := $(shell basename $(PWD))
export PATH := dist/bin:$(PATH)

## interface ####################################
all: distclean dist lint build check
install:

## main #########################################
distclean:
	: ## $@
	rm -rf dist

dist:
	: ## $@
	mkdir -p $@ $@/bin

lint:
	go vet ./... ||:

build: 
	: ## $@
	go build -o dist/build main.go

check: dist/build
	: ## $@

setup: assets
	: ## $@
	pwd \
		| awk -F/ '{ printf "%s/%s/%s", $$(NF-2), $$(NF-1), $$NF }' \
		| xargs -0 -- go mod init \
	||:
	go mod tidy

assets:
	: ## $@

