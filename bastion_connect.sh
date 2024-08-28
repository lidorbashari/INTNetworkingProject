#!/bin/bash

#Defining variables
PUBLIC_IP=$1
PRIVATE_IP=$2
COMMAND=$3
KEY_PATH_2=/home/ubuntu/.ssh/id_rsa

#check if enter ip address
if [ $# -eq 0 ]; then
  echo "Please provide bastion IP address"
  exit 5
fi

#connect to public instance
if [ "$#" -eq 1 ]; then
ssh -i "${KEY_PATH}" ubuntu@"$PUBLIC_IP"
fi

#check if $var is expected
if [ -z "${KEY_PATH}" ]; then
  echo "KEY_PATH env var is expected"
  exit 5
fi

#connect to private machine
if [[ "$#" -eq 2 || "$#" -eq 3 ]]; then
    ssh -t -i "${KEY_PATH}" ubuntu@"${PUBLIC_IP}" "ssh -i ${KEY_PATH_2} ubuntu@${PRIVATE_IP} ${COMMAND}"
fi











