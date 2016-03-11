#!/bin/bash -e

APP_NAME=letsencrypt

error() {
  local parent_lineno="$1"
  local message="$2"
  local code="${3:-1}"
  if [[ -n "$message" ]] ; then
    echo "Error on or near line ${parent_lineno}: ${message}; exiting with status ${code}"
  else
    echo "Error on or near line ${parent_lineno}; exiting with status ${code}"
  fi
  exit "${code}"
}
trap 'error ${LINENO}' ERR


build() {
  docker build -t ${APP_NAME} .
}

rebuild() {
  docker build --no-cache -t $APP_NAME . 
}

run() {
  docker stop $APP_NAME || true
  docker rm $APP_NAME || true
  docker run -d --name $APP_NAME \
             -v /etc/localtime:/etc/localtime:ro \
             -v /tmp/$APP_NAME:/certs \
             -p 80:80   \
             -p 443:443 \
             $APP_NAME
}

enter() {
  docker exec -it $APP_NAME sh
}

shell() {
  docker run -it --rm \
             -v /etc/localtime:/etc/localtime:ro \
             -v /tmp/$APP_NAME:/certs \
             -p 80:80   \
             -p 443:443 \
             $APP_NAME sh
}





# Does a cleanup:
# http://www.projectatomic.io/blog/2015/07/what-are-docker-none-none-images/
#

clean() {
  local DANGLING_IMAGES=$(docker images -f "dangling=true" -q)
  [[ ${DANGLING_IMAGES} ]] && docker rmi ${DANGLING_IMAGES}

  local STOPPED_CONTAINERS=$(docker ps -a -q)
  [[ ${STOPPED_CONTAINERS} ]] && docker rm ${STOPPED_CONTAINERS}
 }

help() {
  declare -F
}

if [[ $@ ]]; then
 "$@"
else
  build
fi



	
