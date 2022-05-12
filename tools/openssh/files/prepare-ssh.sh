#!/bin/bash

# Create user if needed
getent passwd ${SFTP_TEST_USER} > /dev/null
if [ $? != 0 ]; then
    useradd -m -s /bin/bash ${SFTP_TEST_USER}
    passwd ${SFTP_TEST_USER} <<EOF
${SFTP_TEST_PWD}
${SFTP_TEST_PWD}
EOF
fi

# Generate unique ssh keys for this container, if needed
if [ ! -f /etc/ssh/id_key ]; then
    ssh-keygen -t ed25519 -f /etc/ssh/id_key -N ''
fi

# Restrict access from other users
chmod 600 /etc/ssh/id_key

mkdir -p /home/${SFTP_TEST_USER}/.ssh
cat /tmp/sftp-key.pub >> /home/${SFTP_TEST_USER}/.ssh/authorized_keys
chmod -R 700 /home/${SFTP_TEST_USER}/.ssh && chmod -R 600 /home/${SFTP_TEST_USER}/.ssh/*
chown -R ${SFTP_TEST_USER} /home/${SFTP_TEST_USER}/.ssh
