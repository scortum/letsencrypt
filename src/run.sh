#!/bin/sh -xe

EMAIL=mail@scortum.com
DOMAIN=docker.phon.name

letsencrypt certonly --standalone      \
                     --email ${EMAIL}  \
                     --agree-tos       \
                     -d ${DOMAIN}

cp -Lr /etc/letsencrypt/live /certs/.


