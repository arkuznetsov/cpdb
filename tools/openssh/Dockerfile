FROM debian:bullseye

ARG SFTP_TEST_USER=user
ARG SFTP_TEST_PWD=P@ssw0rd
ENV SFTP_TEST_USER=${SFTP_TEST_USER}
ENV SFTP_TEST_PWD=${SFTP_TEST_PWD}

COPY files/sshd_config /etc/ssh/sshd_config
COPY files/prepare-ssh.sh /tmp/
COPY files/sftp-key.pub /tmp/

# Steps done in one RUN layer:
# - Install packages
# - OpenSSH needs /var/run/sshd to run
# - Remove generic host keys, entrypoint generates unique keys
RUN apt-get update && \
    apt-get -y install openssh-server && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /var/run/sshd && \
    chmod +x /tmp/prepare-ssh.sh && \
    /tmp/prepare-ssh.sh

EXPOSE 22

ENTRYPOINT ["/usr/sbin/sshd","-D","-e"]

