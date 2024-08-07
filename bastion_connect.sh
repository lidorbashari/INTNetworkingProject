#!/bin/bash

KEY_PATH = /home/lidorbashari/aws_key/lidorbashari.pem
if [ -z "$KEY_PATH" ]; then
  echo "KEY_PATH env var is expected"
  exit 5
fi

# Check if the JSON file exists
if [ ! -f ec2_instances.json ]; then
  echo "The file ec2_instances.json does not exist"
  exit 1
fi

# Parse JSON to get the public and private IP addresses
public_instance_ip=$(jq -r '.public_instance_ip' ec2_instances.json)
private_instance_ip=$(jq -r '.private_instance_ip' ec2_instances.json)

# Debugging output to check the parsed values
echo "Public IP value: $public_instance_ip"
echo "Private IP value: $private_instance_ip"

# Check if the public_instance_ip is a valid IPv4 address
if [[ ! $public_instance_ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "The value provided for public_instance_ip in ec2_instances.json is not a valid IPv4 address"
  exit 1
  fi

if [ $# -lt "1" ]; then
  echo "Please provide bastion IP address"
  exit 5
fi

PUBLIC_INSTANCE_IP=$1
PRIVATE_INSTANCE_IP=$2
COMMAND=$3
if [ -n "$PRIVATE_INSTANCE_IP" ]; then
  # Connect to the private instance using ProxyJump
  echo "Connecting to the private instance $PRIVATE_INSTANCE_IP through the public instance $PUBLIC_INSTANCE_IP"
  if [ -z "$COMMAND" ]; then
    # Interactive SSH session
    ssh -i "$KEY_PATH" -o "ProxyJump ubuntu@$PUBLIC_INSTANCE_IP" ubuntu@$PRIVATE_INSTANCE_IP
  else
    # Run command on the private instance
    echo "Running command on private instance: $COMMAND"
    ssh -i "$KEY_PATH" -o "ProxyJump ubuntu@$PUBLIC_INSTANCE_IP" ubuntu@$PRIVATE_INSTANCE_IP "$COMMAND"
  fi
else
  # Connect directly to the public instance
  echo "Connecting directly to the public instance $PUBLIC_INSTANCE_IP"
  ssh -i "$KEY_PATH" ubuntu@$PUBLIC_INSTANCE_IP
fi
else
  ssh -i "$KEY_PATH" ubuntu@"$PUBLIC_INSTANCE_IP"
fi