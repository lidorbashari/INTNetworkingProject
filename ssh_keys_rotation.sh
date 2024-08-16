  GNU nano 7.2                                                                            ssh_keys_rotation.sh
#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <private-instance-ip>"
  exit 1
fi

PRIVATE_INSTANCE_IP=$1
NEW_KEY_PATH="/home/ubuntu/.ssh/new_key"  # Absolute path to the new key
OLD_KEY_PATH="~/.ssh/id_rsa"  # Path to the old key (private key)




ssh-keygen -t rsa -b 4096 -f $NEW_KEY_PATH -N ""
scp ${NEW_KEY_PATH}.pub ubuntu@${PRIVATE_INSTANCE_IP}:/home/ubuntu/.ssh/
ssh -i ~/.ssh/id_rsa ubuntu@${PRIVATE_INSTANCE_IP} "cat /home/ubuntu/.ssh/new_key.pub > /home/ubuntu/.ssh/authorized_keys $$ exit"
chmod +w ~/.ssh/id_rsa
cat ~/.ssh/new_key > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
ssh -i ~/.ssh/id_rsa ubuntu@${PRIVATE_INSTANCE_IP}
