ARG DOCKER_IMAGE=debian:bullseye-slim
FROM $DOCKER_IMAGE AS builder

RUN apt-get update && apt-get -y install \
	less \
	vim \
	srecord \
	xa65 gawk avr-libc \
	gcc \
	g++ \
	git \
	make \
	ca-certificates \
	--no-install-recommends &&\
	mkdir /build && cd /build && git clone https://github.com/cc65/cc65.git &&\
	cd /build/cc65 &&\
	export PREFIX=/opt/cc65 &&\
	CFLAGS="-std=c99 -O2" make -j$(nproc) &&\
	make install &&\
	cd / &&\
	rm -rf /build &&\
	apt-get -y purge gcc && apt-get -y autoremove --purge && \
	rm -rf /var/lib/apt/lists/*

ARG DOCKER_IMAGE=debian:bullseye-slim
FROM $DOCKER_IMAGE AS runtime

LABEL author="Bensuperpc <bensuperpc@gmail.com>"
LABEL mantainer="Bensuperpc <bensuperpc@gmail.com>"

ARG VERSION="1.0.0"
ENV VERSION=$VERSION

RUN apt-get update && apt-get -y install \
	make git ca-certificates --no-install-recommends \
	&& apt-get -y autoremove --purge && \
	rm -rf /var/lib/apt/lists/*

ARG BUILD_DATE
ARG VCS_REF

COPY --from=builder /opt/cc65 /opt/cc65

ENV PATH /opt/cc65/bin:$PATH

RUN git clone https://github.com/Bensuperpc/neslib.git && \
	cd neslib && make -j$(nproc) && rm -rf neslib

LABEL org.label-schema.schema-version="1.0" \
	  org.label-schema.build-date=$BUILD_DATE \
	  org.label-schema.name="bensuperpc/cc65" \
	  org.label-schema.description="build cc65 compiler" \
	  org.label-schema.version=$VERSION \
	  org.label-schema.vendor="Bensuperpc" \
	  org.label-schema.url="http://bensuperpc.com/" \
	  org.label-schema.vcs-url="https://github.com/Bensuperpc/cc65-docker" \
	  org.label-schema.vcs-ref=$VCS_REF \
	  org.label-schema.docker.cmd="docker build -t bensuperpc/cc65 -f Dockerfile ."