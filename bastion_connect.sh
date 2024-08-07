
#!/bin/bash

if [ -z "$KEY_PATH" ]; then
  echo "KEY_PATH env var is expected"
  exit 5
fi


if [ $# -lt "1" ]; then
  echo "Please provide bastion IP address"
  exit 5
fi

PUBLIC_INSTANCE_IP=$1
PRIVATE_INSTANCE_IP=$2
COMMAND=$3

if [ -z "$PRIVATE_INSTANCE_IP" ]; then
  ssh -i $KEY_PATH ubuntu@$PUBLIC_INSYANCE_IP
   else
    if [ -z "$COMMAND" ]; then
    # Interactive SSH session
    ssh -i  "$KEY_PATH" ubuntu@"$PUBLIC_INSTANCE_IP" "ssh -i ~/.ssh/autorized_keys ubuntu@$PRIVATE_INSTANCE_IP"
     else
      ssh -i  "$KEY_PATH"  ubuntu@"$PUBLIC_INSTANCE_IP" "ssh -i ~/.ssh/autorized_keys ubuntu@$PRIVATE_INSTANCE_I "$COMMAND""
    fi
fi
