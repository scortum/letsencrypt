FROM python:3-alpine
MAINTAINER Alex

RUN apk --no-cache add letsencrypt
RUN apk --no-cache add bind-tools

ADD src/run.sh  run.sh

ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]

EXPOSE 80 443
CMD ["/run.sh"]
