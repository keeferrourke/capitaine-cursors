#!/bin/bash

docker build -t capitaine-cursors-build -<<EOF
FROM ubuntu

WORKDIR /app

ENV DEBIAN_FRONTEND=noninteractive
RUN mkdir _build; \
    apt-get update; \
    apt-get install -y --no-install-recommends inkscape x11-apps bc; \
    apt-get clean -y; \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/*
EOF

docker run --rm -it \
    --user "$(id -u):$(id -g)" \
    --volume "${PWD}:/app" \
    --entrypoint="./build.sh" \
    capitaine-cursors-build "$@"
