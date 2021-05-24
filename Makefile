# Sources :
#	https://www.docker.com/blog/getting-started-with-docker-for-arm-on-linux/
#	https://schinckel.net/2021/02/12/docker-%2B-makefile/



IMAGE := bensuperpc/cc65
DATE := $(shell date +%Y-%m-%d)
UUID := $(shell cat /proc/sys/kernel/random/uuid)
DOCKER := docker

.PHONY: build push clean qemu_x86 build_amd64 build_arm64 build_armv5 build_armv6 build_armv7 build_riscv64 build_ppc64le

build_amd64: Dockerfile
	$(DOCKER) buildx build . -t $(IMAGE):amd64-$(DATE)-$(UUID) -t $(IMAGE):latest --platform linux/amd64

build_arm64: Dockerfile
	$(DOCKER) buildx build . -t $(IMAGE):arm64-$(DATE)-$(UUID) -t $(IMAGE):latest --platform linux/arm64

build_arm: Dockerfile
	$(DOCKER) buildx build . -t $(IMAGE):arm-$(DATE)-$(UUID) -t $(IMAGE):latest --platform linux/arm

build_armv5: Dockerfile
	$(DOCKER) buildx build . -t $(IMAGE):armv5-$(DATE)-$(UUID) -t $(IMAGE):armv5-latest --platform linux/arm/v5

build_armv6: Dockerfile
	$(DOCKER) buildx build . -t $(IMAGE):armv6-$(DATE)-$(UUID) -t $(IMAGE):armv6-latest --platform linux/arm/v6

build_armv7: Dockerfile
	$(DOCKER) buildx build . -t $(IMAGE):armv7-$(DATE)-$(UUID) -t $(IMAGE):armv7-latest --platform linux/arm/v7

build_riscv64: Dockerfile
	$(DOCKER) buildx build . -t $(IMAGE):riscv64-$(DATE)-$(UUID) -t $(IMAGE):riscv64-latest --platform linux/riscv64

build_ppc64le: Dockerfile
	$(DOCKER) buildx build . -t $(IMAGE):ppc64le-$(DATE)-$(UUID) -t $(IMAGE):ppc64le-latest --platform linux/ppc64le

build: build_amd64 build_arm64 build_arm build_armv5 build_armv6 build_armv7 build_riscv64 build_ppc64le

push: build
	$(DOCKER) image push $(IMAGE) --all-tags

# https://github.com/linuxkit/linuxkit/tree/master/pkg/binfmt
qemu_x86:
	$(DOCKER) run --rm --privileged linuxkit/binfmt:5d33e7346e79f9c13a73c6952669e47a53b063d4-amd64

clean:
	$(DOCKER) images --filter='reference=$(IMAGE)' --format='{{.Repository}}:{{.Tag}}' | xargs -r docker rmi
