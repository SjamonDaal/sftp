FROM alpine:latest
MAINTAINER Adrian Dvergsdal [atmoz.net]

# Steps done in one RUN layer:
# - Install packages
# - Fix default group (1000 does not exist)
# - OpenSSH needs /var/run/sshd to run
# - Remove generic host keys, entrypoint generates unique keys
# <<<<<<< master
RUN apt-get update && \
    apt-get -y install openssh-server cron && \
    rm -rf /var/lib/apt/lists/* && \
=======
RUN echo "@community http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    apk add --no-cache bash shadow@community openssh openssh-sftp-server && \
    sed -i 's/GROUP=1000/GROUP=100/' /etc/default/useradd && \
# >>>>>>> alpine
    mkdir -p /var/run/sshd && \
    rm -f /etc/ssh/ssh_host_*key*

COPY files/refresh-users-cron /etc/cron.d/
COPY files/sshd_config /etc/ssh/sshd_config
COPY files/create-sftp-user /usr/local/bin/
COPY files/add-new-users /usr/local/bin/
COPY files/entrypoint /

RUN chmod 0644 /etc/cron.d/refresh-users-cron
RUN crontab /etc/cron.d/refresh-users-cron

EXPOSE 22

ENTRYPOINT ["/entrypoint"]
