# Sources :
#	https://www.docker.com/blog/getting-started-with-docker-for-arm-on-linux/
#	https://schinckel.net/2021/02/12/docker-%2B-makefile/


IMAGE := bensuperpc/cc65
TAG := $(shell date '+%Y%m%d')-$(shell git rev-parse --short HEAD)
DATE_FULL := $(shell date +%Y-%m-%d_%H:%M:%S)
UUID := $(shell cat /proc/sys/kernel/random/uuid)
DOCKER := docker

ARCH_LIST = amd64 arm64 arm ppc64le s390x riscv64

$(ARCH_LIST): Dockerfile
	$(DOCKER) buildx build . -f Dockerfile -t $(IMAGE):$@-$(TAG) -t $(IMAGE):$@-latest --build-arg BUILD_DATE=$(DATE_FULL) --platform linux/$@

armv5: Dockerfile
	$(DOCKER) buildx build . -f Dockerfile -t $(IMAGE):armv5-$(TAG) -t $(IMAGE):armv5-latest --build-arg BUILD_DATE=$(DATE_FULL) --platform linux/arm/v5

armv6: Dockerfile
	$(DOCKER) buildx build . -f Dockerfile -t $(IMAGE):armv6-$(TAG) -t $(IMAGE):armv6-latest --build-arg BUILD_DATE=$(DATE_FULL) --platform linux/arm/v6
	
armv7: Dockerfile
	$(DOCKER) buildx build . -f Dockerfile -t $(IMAGE):armv7-$(TAG) -t $(IMAGE):armv7-latest --build-arg BUILD_DATE=$(DATE_FULL) --platform linux/arm/v7

	
build: $(ARCH_LIST)

push: build
	$(DOCKER) image push $(IMAGE) --all-tags

# https://github.com/linuxkit/linuxkit/tree/master/pkg/binfmt
qemu_x86:
	$(DOCKER) run --rm --privileged linuxkit/binfmt:5d33e7346e79f9c13a73c6952669e47a53b063d4-amd64

clean:
	$(DOCKER) images --filter='reference=$(IMAGE)' --format='{{.Repository}}:{{.Tag}}' | xargs -r docker rmi

.PHONY: build push clean qemu_x86 $(ARCH_LIST)