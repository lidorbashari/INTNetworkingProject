#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <private-instance-ip>"
  exit 1
fi

PRIVATE_INSTANCE_IP=$1
NEW_KEY_PATH="/home/ubuntu/.ssh/new_key"  # Absolute path to the new key
OLD_KEY_PATH="~/.ssh/id_rsa"  # Path to the old key (private key)




ssh-keygen -t rsa -b 4096 -f $NEW_KEY_PATH -N ""
scp ${NEW_KEY_PATH}.pub ubuntu@"$private_instance_ip":/home/ubuntu/.ssh
#chmod +w /home/ubuntu/.ssh/authorized_keys
ssh -i ubuntu@"$private_instance_ip" "cat ${new_key}" > /home/ubuntu/.ssh/authorized_keys
cat $NEW_KEY_PATH > OLD_KEY_PATH

