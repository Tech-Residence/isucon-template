FROM ubuntu:22.04

ENV TZ="Asia/Tokyo"
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && \
  apt-get install -y \
  openssh-client \
  sudo \
  rsync \
  git \
  ansible \
  ansible-lint
