# Copyright Vadim Eisenberg 2017
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# set EXECUTABLE_DIRECTORY according to your specific environment
# run swift build and see where the output executable is created

# this is a stripped down version of the file documented at 
# https://stackoverflow.com/a/47243701
# which came with the above license

prefix ?= /usr/local
bindir ?= $(prefix)/bin
libdir ?= $(prefix)/lib

REPODIR = $(shell pwd)
BUILDDIR = $(REPODIR)/.build

EXECUTABLE_DIRECTORY = ./.build/x86_64-apple-macosx/debug
TEST_RESOURCES_DIRECTORY = ./.build/x86_64-apple-macosx/debug/xcprojectlintPackageTests.xctest/Contents/Resources/

error:
	@echo "Please choose one of the following targets: build, clean, test, xcode"
	exit 2

build:
	swift build

release:
	swift build --configuration release --disable-sandbox --build-path "$(BUILDDIR)"

install: release
	@install -d "$(bindir)" "$(libdir)"
	@install "$(BUILDDIR)/release/xcprojectlint" "$(bindir)"

uninstall:
	@rm -rf "$(bindir)/xcprojectlint"

copyTestResources: build
	mkdir -p ${TEST_RESOURCES_DIRECTORY}
	cp -r TestData ${TEST_RESOURCES_DIRECTORY}

run: build
	${EXECUTABLE_DIRECTORY}/xcprojectlint

test: copyTestResources
	swift test

xcode:
	swift package generate-xcodeproj
	@echo "To run the unit tests, refer to “README.md”."

clean:
	swift package reset

.PHONY: run build install uninstall test copyTestResources clean xcode
