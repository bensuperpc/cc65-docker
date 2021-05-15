# cc65 docker container

Containerized [cc65 toolchain](https://github.com/cc65/cc65)

Usage:
```
# docker run --rm -v ${PWD}:${PWD} -w ${PWD} -it bensuperpc/cc65
```

Build (If you want):
```
# docker build -t bensuperpc/cc65 .
```
