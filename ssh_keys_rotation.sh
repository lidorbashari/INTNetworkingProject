  GNU nano 7.2                                                                            ssh_keys_rotation.sh
#!/bin/bash

#check if an IP address has been entered
if [ -z "$1" ]; then
  echo "Usage: $0 <private-instance-ip>"
  exit 1
fi

#Defining variables
PRIVATE_INSTANCE_IP=$1
NEW_KEY_PATH="/home/ubuntu/.ssh/new_key"  # Absolute path to the new key
OLD_KEY_PATH="/home/ubuntu/.ssh/id_rsa"   # Path to the old key (private key)



#generation key
ssh-keygen -t rsa -b 4096 -f $NEW_KEY_PATH -N ""

#move key to private instance
scp ${NEW_KEY_PATH}.pub ubuntu@${PRIVATE_INSTANCE_IP}:/home/ubuntu/.ssh/
#move key to authorized_keys
ssh -i ~/.ssh/id_rsa ubuntu@${PRIVATE_INSTANCE_IP} "cat /home/ubuntu/.ssh/new_key.pub > /home/ubuntu/.ssh/authorized_keys $$ exit"
#Change permissions
chmod +w ~/.ssh/id_rsa

#move key to id_rsa, and remote the old key
cat ~/.ssh/new_key > ~/.ssh/id_rsa
rm ~/.ssh/new_key ~/.ssh/new_key.pub
chmod 600 ~/.ssh/id_rsa

#connect to private instance
ssh -i ~/.ssh/id_rsa ubuntu@${PRIVATE_INSTANCE_IP}