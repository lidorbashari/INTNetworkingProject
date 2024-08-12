#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <private-instance-ip>"
  exit 1
fi

PRIVATE_IP=$1
NEW_KEY_PATH="/home/ubuntu/.ssh/new_key"
OLD_KEY_PATH="/home/ubuntu/.ssh/id_rsa"

ssh-keygen -t rsa -b 4096 -f $NEW_KEY_PATH -N ""
scp -i "${NEW_KEY_PATH}.pub" ubuntu@"${PRIVATE_IP}":"~/.ssh/"

ssh -i ${OLD_KEY_PATH} ubuntu@"${PRIVATE_IP}" "cat ~/.ssh/new_key.pub > ~/.ssh/authorized_keys"
$NEW_KEY_PATH > ${OLD_KEY_PATH}
ssh -i ${NEW_KEY_PATH} ubuntu@"${PRIVATE_IP}" "rm ~/.ssh/new_key.pub"
