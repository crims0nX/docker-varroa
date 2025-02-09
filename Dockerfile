# syntax=docker/dockerfile:1
ARG ALPINE_VER=3.21
FROM ghcr.io/linuxserver/baseimage-alpine:$ALPINE_VER AS builder

# build variables
ARG VARROA_RELEASE

# RUN \
#  echo "**** install build packages ****" && \
#   apk add --no-cache \
#     # build-base \
#     # git \
#     # yq-go \
#     # go \
#     # ca-certificates

# Using the latest release
# RUN \
#   echo "**** fetch source code ****" && \
#   if [ -z ${VARROA_RELEASE+x} ]; then \
#     VARROA_RELEASE=$(curl -sX GET "https://gitlab.com/api/v4/projects/2399282/releases" \
#     | jq -r '.[0].tag_name'); \
#   fi && \
#   mkdir -p \
#     /tmp/varroa && \
#   curl -o \
#   /tmp/varroa-src.tar.gz -L \
#     "https://gitlab.com/passelecasque/varroa/-/archive/${VARROA_RELEASE}/varroa-${VARROA_RELEASE}.tar.gz" && \
#   tar xf \
#   /tmp/varroa-src.tar.gz -C \
#     /tmp/varroa --strip-components=1 && \
#   echo "**** compile varroa  ****" && \
#   cd /tmp/varroa && \
#   make build-bin

# Hard-coded commit (https://gitlab.com/passelecasque/varroa/-/tree/7a4f8474a96f564fa8d2609f2c99725d1353ca79)
# RUN \
#   echo "**** git clone ****" && \
#   mkdir -p /tmp && cd /tmp && \
#   git clone https://gitlab.com/passelecasque/varroa.git && \
#   cd varroa && \
#   git checkout 7a4f8474a96f564fa8d2609f2c99725d1353ca79 && \
#   echo "**** compile varroa ****" && \
#   make deps build-bin && \
#   mkdir -p /app/varroa && \
#   cp varroa varroa-fuse varroa_bash_completion varroa.user.js /app/varroa && \
#   echo "**** cleanup ****" && \
#   rm -rf /tmp/*

# Download the binaries directly from pipeline job and not compile it
RUN \
  echo "**** Donwload varroa binary ****" && \
  cd /tmp && \
  wget https://gitlab.com/passelecasque/varroa/-/jobs/8454336382/artifacts/download?file_type=archive -O varroa.zip && \
  unzip varroa.zip -d varroa && \
  rm varroa.zip

############## runtime stage ##############
FROM ghcr.io/linuxserver/baseimage-alpine:$ALPINE_VER

# set version label
LABEL maintainer="crims0nX"

ENV HOME="/app"  

RUN \
 echo "**** runtime deps ****" && \
  apk add --no-cache \
    libc6-compat ca-certificates openssl strace
# gcompat

# RUN \
#   echo "**** create var lib folder ****" && \
#   install -d -o abc -g abc \
#     /var/lib/syncthing

# Init files
COPY root/ /

## varroa
# COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /tmp/varroa/ /varroa

# Append 'b' to original binary
RUN mv /varroa/varroa /varroa/varroab
RUN install -m 755 /varroa/varroab /varroa/varroa-fuse /app
# Use 'varroa.sh' as proxy to the binary.
RUN install -m 755 --no-target-directory /defaults/varroa.sh /app/varroa

# This doesnt work on s6 init setup!
# WORKDIR /config

# ports and volumes
EXPOSE 19080 19081

VOLUME /config
