# Copyright 2022 Dave Verwer, Sven A. Schmidt, and other contributors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

SHELL = /bin/bash

prefix ?= /usr/local
bindir ?= $(prefix)/bin
libdir ?= $(prefix)/lib
srcdir = Sources

REPODIR = $(shell pwd)
BUILDDIR = $(REPODIR)/.build
SOURCES = $(wildcard $(srcdir)/**/*.swift)

.DEFAULT_GOAL = build

build:
	swift build -c release

test:
	swift test

validate-spi-manifest: $(SOURCES)
	@swift build \
		-c release \
		--disable-sandbox \
		--scratch-path "$(BUILDDIR)"

.PHONY: install
install: validate-spi-manifest
	@install -d "$(bindir)"
	@install "$(shell swift build -c release --show-bin-path)/validate-spi-manifest" "$(bindir)"

.PHONY: uninstall
uninstall:
	@rm -rf "$(bindir)/validate-spi-manifest"

.PHONY: clean
distclean:
	@rm -f $(BUILDDIR)/release
