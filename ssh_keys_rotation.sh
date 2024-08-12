#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <private-instance-ip>"
  exit 1
fi

PRIVATE_IP=$1
NEW_KEY_PATH="/home/ubuntu/.ssh/new_key"
OLD_KEY_PATH="/home/ubuntu/.ssh/id_rsa"

ssh-keygen -t rsa -b 4096 -f $NEW_KEY_PATH -N ""
scp -i ${OLD_KEY_PATH} "${NEW_KEY_PATH}.pub" ubuntu@"${PRIVATE_INSTANCE_IP}":"~/.ssh/"

ssh -i ${OLD_KEY_PATH} ubuntu@"${PRIVATE_INSTANCE_IP}" "cat ~/.ssh/new_key.pub > ~/.ssh/authorized_keys"

ssh -i ${NEW_KEY_PATH} ubuntu@"${PRIVATE_INSTANCE_IP}" "echo 'New key works!'"

ssh -i ${NEW_KEY_PATH} ubuntu@"${PRIVATE_INSTANCE_IP}" "rm ~/.ssh/new_key.pub"