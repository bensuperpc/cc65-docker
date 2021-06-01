# cc65 docker container

### _cc65 compilet in docker_
 [![forthebadge](https://forthebadge.com/images/badges/built-with-love.svg)](https://forthebadge.com) [![forthebadge](https://forthebadge.com/images/badges/powered-by-jeffs-keyboard.svg)](https://forthebadge.com) [![forthebadge](https://forthebadge.com/images/badges/contains-cat-gifs.svg)](https://forthebadge.com)

[![cc65](https://github.com/Bensuperpc/cc65-docker/actions/workflows/main.yml/badge.svg)](https://github.com/Bensuperpc/cc65-docker/actions/workflows/main.yml)

# New Features !

  - Mutli-build step (Reduce image size)

#### Install
You need Linux distribution like Ubuntu or Manjaoro

```sh
git clone https://github.com/Bensuperpc/cc65-docker
```
```sh
cd cc65-docker
```
#### Usage

```sh
docker run --rm -v ${PWD}:${PWD} -w ${PWD} -it bensuperpc/cc65
```
#### Build
```sh
make linux/amd64 or docker build -t bensuperpc/cc65 .
```

### Todos

 - Write Tests
 - Continue dev. :D

### More info : 
- https://github.com/cc65/cc65

License
----

MIT License


**Free Software forever !**
   
 
