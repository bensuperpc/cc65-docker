# cc65 docker container

Containerized [cc65 toolchain](https://github.com/cc65/cc65)
[![cc65-docker](https://github.com/Bensuperpc/cc65-docker/actions/workflows/main.yml/badge.svg)](https://github.com/Bensuperpc/cc65-docker/actions/workflows/main.yml)

Usage:
```
# docker run --rm -v ${PWD}:${PWD} -w ${PWD} -it bensuperpc/cc65
```

Build (If you want):
```
# docker build -t bensuperpc/cc65 .
```
