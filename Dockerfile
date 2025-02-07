# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-alpine:3.20 as buildstage

# build variables
ARG VARROA_RELEASE

RUN \
 echo "**** install build packages ****" && \
  apk add --no-cache \
    build-base \
    ca-certificates \
    yq-go \
    go

# Run make commands to prepare and build the binary
RUN go get -u github.com/divan/depscheck
RUN go get github.com/warmans/golocc

RUN \
  echo "**** fetch source code ****" && \
  if [ -z ${VARROA_RELEASE+x} ]; then \
    VARROA_RELEASE=$(curl -sX GET "https://gitlab.com/api/v4/projects/2399282/releases" \
    | yq '.[0].tag_name'); \
  fi && \
  mkdir -p \
    /tmp/varroa && \
  curl -o \
  /tmp/varroa-src.tar.gz -L \
    "https://gitlab.com/passelecasque/varroa/-/archive/${VARROA_RELEASE}/varroa-${VARROA_RELEASE}.tar.gz" && \
  tar xf \
  /tmp/varroa-src.tar.gz -C \
    /tmp/varroa --strip-components=1 && \
  echo "**** compile syncthing  ****" && \
  cd /tmp/varroa && \
  go mod download && \
  CGO_ENABLED=0 go build -ldflags '-extldflags "-static"' varroa

RUN echo 'varroa privilegies' && ls -la /tmp/varroa

############## runtime stage ##############
FROM ghcr.io/linuxserver/baseimage-alpine:3.20

# set version label
LABEL maintainer="crims0nX"

# environment settings
ENV HOME="/config"

# RUN \
#   echo "**** create var lib folder ****" && \
#   install -d -o abc -g abc \
#     /var/lib/syncthing

# copy files from build stage and local files
COPY root/ /
## varroa
COPY --from=buildstage /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=buildstage /tmp/varroa/varroa /usr/bin/

# ports and volumes
EXPOSE 9080 9081

VOLUME /config
VOLUME /watch
VOLUME /downloads

