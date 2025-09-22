#//////////////////////////////////////////////////////////////
#//                                                          //
#//  Generic docker images, 2025                             //
#//  Created: 30, May, 2021                                  //
#//  Modified: 21 September, 2025                            //
#//  file: -                                                 //
#//  -                                                       //
#//  Source:                                                 //
#//  OS: ALL                                                 //
#//  CPU: ALL                                                //
#//                                                          //
#//////////////////////////////////////////////////////////////

# =====================
# AUTOMATED VARIABLES
# =====================
GIT_SHA ?= $(shell git rev-parse HEAD)
GIT_ORIGIN ?= $(shell git config --get remote.origin.url) 

DATE ?= $(shell date -u +"%Y%m%d")
UUID ?= $(shell uuidgen)

CURRENT_USER ?= $(shell whoami)
UID ?= $(shell id -u ${CURRENT_USER})
GID ?= $(shell id -g ${CURRENT_USER})

# =====================
# USER DEFINED VARIABLES
# =====================

SUBDIRS ?= archlinux debian ubuntu

DOCKER_COMPOSITE_SOURCES ?= common.label-and-env common.entrypoint common.user

DOCKER_COMPOSITE_FOLDER_PATH ?= common/
DOCKER_COMPOSITE_PATH ?= $(addprefix $(DOCKER_COMPOSITE_FOLDER_PATH),$(DOCKER_COMPOSITE_SOURCES))

AUTHOR ?= bensuperpc
WEB_SITE ?= bensuperpc.org

# Base image
BASE_IMAGE_REGISTRY ?= docker.io

# Output docker image
OUTPUT_IMAGE_REGISTRY ?= docker.io
OUTPUT_IMAGE_PATH ?= bensuperpc
OUTPUT_IMAGE_NAME ?= multimedia
OUTPUT_IMAGE_VERSION ?= 1.0.0

TAG_WITH_BASE_IMAGE_NAME ?= no

TEST_IMAGE_CMD ?= ./test/test.sh
TEST_IMAGE_ARGS ?=
RUN_IMAGE_CMD ?=
RUN_IMAGE_ARGS ?=

BUILD_IMAGE_ARGS ?=

# Docker config
DOCKERFILE ?= Dockerfile
DOCKER_EXEC ?= docker
PROGRESS_OUTPUT ?= plain
BUILD_CONTEXT ?= $(shell pwd)

BIND_HOST_DIR ?= $(shell pwd)
BIND_CONTAINER_DIR ?= /work

# --push
DOCKER_DRIVER ?= --load
ARCH_LIST ?= linux/amd64
comma?= ,
PLATFORMS ?= $(subst $() $(),$(comma),$(ARCH_LIST))

# Max CPU and memory
CPUS ?= 8.0
CPU_SHARES ?= 1024
MEMORY ?= 16GB
MEMORY_RESERVATION ?= 2GB
TMPFS_SIZE ?= 4g
BUILD_IMAGE_CPU_SHARES ?= 1024
BUILD_IMAGE_MEMORY ?= 16GB

# Custom targets
CUSTOM_TARGET ?= help

TARGETS := all build test run clean purge update push pull version generate

# Merge all variables
MAKEFILE_VARS ?= AUTHOR="$(AUTHOR)" PLATFORMS="$(PLATFORMS)" \
	CPUS="$(CPUS)" CPU_SHARES="$(CPU_SHARES)" MEMORY="$(MEMORY)" MEMORY_RESERVATION="$(MEMORY_RESERVATION)" \
	BUILD_IMAGE_CPU_SHARES="$(BUILD_IMAGE_CPU_SHARES)" BUILD_IMAGE_MEMORY="$(BUILD_IMAGE_MEMORY)" WEB_SITE="$(WEB_SITE)" BIND_HOST_DIR="$(BIND_HOST_DIR)" \
	DOCKERFILE="$(DOCKERFILE)" DOCKER_EXEC="$(DOCKER_EXEC)" DOCKER_DRIVER="$(DOCKER_DRIVER)" BUILD_CONTEXT="$(BUILD_CONTEXT)" \
	GIT_SHA="$(GIT_SHA)" GIT_ORIGIN="$(GIT_ORIGIN)" DATE="$(DATE)" UUID="$(UUID)" \
	UID="$(UID)" GID="$(GID)" TMPFS_SIZE="$(TMPFS_SIZE)" BIND_CONTAINER_DIR="$(BIND_CONTAINER_DIR)" \
	TEST_IMAGE_CMD="$(TEST_IMAGE_CMD)" RUN_IMAGE_CMD="$(RUN_IMAGE_CMD)" PROGRESS_OUTPUT="$(PROGRESS_OUTPUT)" \
	BASE_IMAGE_REGISTRY="$(BASE_IMAGE_REGISTRY)" BUILD_IMAGE_ARGS="$(BUILD_IMAGE_ARGS)" \
	OUTPUT_IMAGE_REGISTRY="$(OUTPUT_IMAGE_REGISTRY)" OUTPUT_IMAGE_PATH="$(OUTPUT_IMAGE_PATH)" \
	OUTPUT_IMAGE_NAME="$(OUTPUT_IMAGE_NAME)" OUTPUT_IMAGE_VERSION="$(OUTPUT_IMAGE_VERSION)" \
	DOCKER_COMPOSITE_FOLDER_PATH="$(DOCKER_COMPOSITE_FOLDER_PATH)" \
	DOCKER_COMPOSITE_SOURCES="$(DOCKER_COMPOSITE_SOURCES)" \
	DOCKER_COMPOSITE_PATH="$(DOCKER_COMPOSITE_PATH)" TAG_WITH_BASE_IMAGE_NAME="$(TAG_WITH_BASE_IMAGE_NAME)"


.PHONY: default
default: $(addsuffix .test, $(SUBDIRS))

.PHONY: $(SUBDIRS)
$(SUBDIRS):
	rsync --progress --human-readable --archive --verbose --compress --acls --xattrs --bwlimit=500000 --stats --delete-during \
	    $(DOCKER_COMPOSITE_FOLDER_PATH) $@/common/

.PHONY: $(TARGETS)
$(TARGETS): %: $(addsuffix .%,$(SUBDIRS))

.SECONDEXPANSION:
$(foreach t,$(TARGETS),$(addsuffix .$(t),$(SUBDIRS))): $$(basename $$@)
	$(MAKE) $(MAKEFILE_VARS) -C $(basename $@) $(subst .,,$(suffix $@))

.PHONY: $(CUSTOM_TARGET)
$(CUSTOM_TARGET): $(addsuffix .$(CUSTOM_TARGET),$(SUBDIRS))

.SECONDEXPANSION:
$(addsuffix .$(CUSTOM_TARGET),$(SUBDIRS)): $$(basename $$@)
	$(MAKE) $(MAKEFILE_VARS) -C $(basename $@) $(CUSTOM_TARGET)

