FROM debian:buster-slim

LABEL maintainer="bensuperpc@gmail.com"
LABEL version="0.1"

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
	CFLAGS="-std=c99 -O2" make -j8 &&\
	make install &&\
	cd / &&\
	rm -rf /build &&\
	apt-get -y purge gcc && apt-get -y autoremove --purge && \
	rm -rf /var/lib/apt/lists/*

ENV PATH /opt/cc65/bin:$PATH

RUN git clone https://github.com/Bensuperpc/neslib.git && \
	cd neslib && make -j$(nproc) && rm -rf neslib

