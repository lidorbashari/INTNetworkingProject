#!/bin/bash


if [ -z "$KEY_PATH" ]; then
  echo "KEY_PATH env var is expected"
  exit 5
fi

if [ $# -eq "1"]; then
  ssh -i "KEY_PATH" ubuntu"$1"
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
if [ -z "$COMMAND"]; then
  ssh -i "$KEY_PATH" "ProxyJump ubuntu@"$PUBLIC_INSTANCE_IP"" ubuntu@"$PRIVATE_INSTANCE_IP"
  else
    ssh -i "$KEY_PATH" "ProxyJump ubuntu@"$PUBLIC_INSTANCE_IP"" ubuntu@"$PRIVATE_INSTANCE_IP" "$COMMAND"
    else
      ssh -i "$KEY_PATH" ubuntu@$PUBLIC_INSTANCE_IP
fi
else
  ssh -i "$KEY_PATH" ubuntu@"$PUBLIC_INSTANCE_IP"
fi