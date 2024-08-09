#!/bin/bash

NEW_KEY=$(/home/ubuntu/.ssh/new_key)
OLD_KEY=$(~/.ssh/old_key)
ssh-keygen -t rsa -b 4096 -f ${OLD_KEY} -N ""
scp ~/.ssh/authorized_keys ~/.ssh/id.rsa ubuntu@"${private_instance_ip}"
ssh -i ~/.ssh/id.rsa ubuntu@"${private_instance_ip}" "cat ${new_key}.pub > ~/.ssh//autorized_keys && chmod 600 ~/.ssh//autorized_keys"
cp ${NEW_KEY} ${OLD_KEY}
