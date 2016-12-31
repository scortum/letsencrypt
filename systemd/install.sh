#!/bin/bash -e

IMAGE_NAME=scortum/letsencrypt
VERSION=latest
DOCKER_CONTAINER_NAME=scortum-letsencrypt
WEBSERVER_IMAGE=nginx-proxy


cat > /etc/default/${DOCKER_CONTAINER_NAME} << EOF
DOCKER_IMAGE=${IMAGE_NAME}:${VERSION}
DOCKER_CONTAINER_NAME=${DOCKER_CONTAINER_NAME}
LOCAL_DIR=/data/${DOCKER_CONTAINER_NAME}
WEBSERVER_IMAGE=${WEBSERVER_IMAGE}
EOF

cat > /lib/systemd/system/${DOCKER_CONTAINER_NAME}.timer << EOF
[Unit]
Description=Every Other Month

[Timer]
# https://www.freedesktop.org/software/systemd/man/systemd.time.html
OnCalendar=weekly
# OnCalendar=monthly
# OnCalendar=*-0/2-01 00:00:00

Unit=${DOCKER_CONTAINER_NAME}.service

[Install]
WantedBy=multi-user.target
EOF

cat > /lib/systemd/system/${DOCKER_CONTAINER_NAME}.service << EOF
[Unit]
Description=Tigger a Letsencrypt run to get a cert
Requires=docker.service
After=docker.service

[Service]
# Using “oneshot” makes it so that the script will be run the first time, and then 
# systemd thinks that you don’t want to run it again, and will turn off the timer we make next.
# Type=oneshot
Type=simple
EnvironmentFile=/etc/default/${DOCKER_CONTAINER_NAME}
ExecStartPre=-/usr/bin/docker kill \${DOCKER_CONTAINER_NAME}
ExecStartPre=-/usr/bin/docker rm \${DOCKER_CONTAINER_NAME}
ExecStartPre=/usr/bin/docker pull \${DOCKER_IMAGE}
ExecStartPre=/usr/bin/docker stop \${WEBSERVER_IMAGE}
ExecStart=/usr/bin/docker run --name \${DOCKER_CONTAINER_NAME}      \
                              -p 80:80                              \
                              -p 443:443                            \
                              -v \${LOCAL_DIR}/certs:/certs         \
                              -v /etc/localtime:/etc/localtime:ro   \
                              \${DOCKER_IMAGE}
ExecStop=/usr/bin/docker stop --time=10 \${DOCKER_CONTAINER_NAME} 
ExecStopPost=/usr/bin/docker start \${WEBSERVER_IMAGE}

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload


echo \# Start timer, as root
echo systemctl start myscript.timer
echo \# Enable timer to start at boot
echo systemctl enable myscript.timer
