FROM python:3-alpine
MAINTAINER Alex

RUN apk --no-cache add letsencrypt

ADD src/run.sh  run.sh

EXPOSE 80 443
CMD "/run.sh"
    
