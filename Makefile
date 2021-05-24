# Sources :
#	https://www.docker.com/blog/getting-started-with-docker-for-arm-on-linux/
#	https://schinckel.net/2021/02/12/docker-%2B-makefile/



IMAGE := bensuperpc/cc65
TAG := $(shell date '+%Y%m%d')-$(shell git rev-parse --short HEAD)
DATE_FULL := $(shell date +%Y-%m-%d_%H:%M:%S)
UUID := $(shell cat /proc/sys/kernel/random/uuid)
DOCKER := docker

.PHONY: build push clean qemu_x86 build_amd64 build_arm64 build_armv5 build_armv6 build_armv7 build_riscv64 build_ppc64le

build_amd64: Dockerfile
	$(DOCKER) buildx build . -t $(IMAGE):amd64-$(TAG) -t $(IMAGE):latest -t $(IMAGE):amd64-latest --build-arg BUILD_DATE=$(DATE_FULL) --platform linux/amd64

build_arm64: Dockerfile
	$(DOCKER) buildx build . -t $(IMAGE):arm64-$(TAG) -t $(IMAGE):arm64-latest --build-arg BUILD_DATE=$(DATE_FULL) --platform linux/arm64

build_arm: Dockerfile
	$(DOCKER) buildx build . -t $(IMAGE):arm-$(TAG) -t $(IMAGE):arm-latest --build-arg BUILD_DATE=$(DATE_FULL) --platform linux/arm

build_armv5: Dockerfile
	$(DOCKER) buildx build . -t $(IMAGE):armv5-$(TAG) -t $(IMAGE):armv5-latest --build-arg BUILD_DATE=$(DATE_FULL) --platform linux/arm/v5

build_armv6: Dockerfile
	$(DOCKER) buildx build . -t $(IMAGE):armv6-$(TAG) -t $(IMAGE):armv6-latest --build-arg BUILD_DATE=$(DATE_FULL) --platform linux/arm/v6

build_armv7: Dockerfile
	$(DOCKER) buildx build . -t $(IMAGE):armv7-$(TAG) -t $(IMAGE):armv7-latest --build-arg BUILD_DATE=$(DATE_FULL) --platform linux/arm/v7

build_ppc64le: Dockerfile
	$(DOCKER) buildx build . -t $(IMAGE):ppc64le-$(TAG) -t $(IMAGE):ppc64le-latest --build-arg BUILD_DATE=$(DATE_FULL) --platform linux/ppc64le

build_s390x: Dockerfile
	$(DOCKER) buildx build . -t $(IMAGE):s390x-$(TAG) -t $(IMAGE):s390x-latest --build-arg BUILD_DATE=$(DATE_FULL) --platform linux/s390x

# Not workin for now
build_riscv64: Dockerfile
	$(DOCKER) buildx build . -t $(IMAGE):riscv64-$(TAG) -t $(IMAGE):riscv64-latest --build-arg BUILD_DATE=$(DATE_FULL) --platform linux/riscv64

build: build_amd64 build_arm64 build_arm build_armv5 build_armv6 build_armv7 build_ppc64le build_s390x

push: build
	$(DOCKER) image push $(IMAGE) --all-tags

# https://github.com/linuxkit/linuxkit/tree/master/pkg/binfmt
qemu_x86:
	$(DOCKER) run --rm --privileged linuxkit/binfmt:5d33e7346e79f9c13a73c6952669e47a53b063d4-amd64

clean:
	$(DOCKER) images --filter='reference=$(IMAGE)' --format='{{.Repository}}:{{.Tag}}' | xargs -r docker rmi
