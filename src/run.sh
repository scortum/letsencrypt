#!/bin/sh -xe


ls /certs | while read in; 
do
  DOMAIN="$in"
  EMAIL=mail@${DOMAIN}

  # if domain contains a dot
  if [ -z "${domain//[^.]/}" ]; then 

    letsencrypt certonly --standalone      \
                         --email ${EMAIL}  \
                         --agree-tos       \
                         -d ${DOMAIN}
  fi
done

# TODO: decide if only current certs should be copied - or if simlink should be changed
cp -Lr /etc/letsencrypt/live/* /certs/.


