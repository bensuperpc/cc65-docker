ARG DOCKER_IMAGE=debian:buster-slim
FROM $DOCKER_IMAGE

LABEL author="Bensuperpc <bensuperpc@gmail.com>"
LABEL mantainer="Bensuperpc <bensuperpc@gmail.com>"

ARG BUILD_VERSION="1.0.0"
ENV BUILD_VERSION=$BUILD_VERSION

RUN apt-get update && apt-get -y install \
	less \
	vim \
	srecord \
	xa65 gawk avr-libc \
	gcc \
	git \
	make &&\
	mkdir /build && cd /build && git clone https://github.com/cc65/cc65.git &&\
	cd /build/cc65 &&\
	export PREFIX=/opt/cc65 &&\
	CFLAGS="-std=c99 -O2" make -j$(nproc) &&\
	make install &&\
	cd / &&\
	rm -rf /build &&\
	apt-get -y purge gcc && apt-get -y autoremove --purge && \
	rm -rf /var/lib/apt/lists/*

ENV PATH /opt/cc65/bin:$PATH

RUN git clone https://github.com/Bensuperpc/neslib.git && \
	cd neslib && make -j$(nproc) && rm -rf neslib

ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.name="bensuperpc/cc65"
LABEL org.label-schema.description="build cc65 compiler"
LABEL org.label-schema.version=$BUILD_VERSION
LABEL org.label-schema.vendor="Bensuperpc"
LABEL org.label-schema.url="http://bensuperpc.com/"
LABEL org.label-schema.vcs-url="https://github.com/Bensuperpc/cc65-docker"
LABEL org.label-schema.vcs-ref=$VCS_REF
LABEL org.label-schema.docker.cmd="docker build -t bensuperpc/cc65-docker -f Dockerfile ."