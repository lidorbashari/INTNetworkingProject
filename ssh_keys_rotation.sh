#!/bin/bash

# Check if the private instance IP is provided as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <private-instance-ip>"
  exit 1
fi

PRIVATE_INSTANCE_IP=$1

# Paths to new and old key files
NEW_KEY_PATH="$HOME/new_key"
NEW_KEY_PATH_PUB="$NEW_KEY_PATH.pub"
OLD_KEY_PATH="$HOME/.ssh/id_rsa"

# Generate a new SSH key pair
ssh-keygen -t rsa -b 2048 -f "$NEW_KEY_PATH" -q -N ""

# Copy the new public key to the private instance's authorized_keys
ssh -i "$OLD_KEY_PATH" ubuntu@"$PRIVATE_INSTANCE_IP" "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys" < "$NEW_KEY_PATH_PUB"

# Remove the old public key from the private instance's authorized_keys
OLD_PUB_KEY=$(ssh-keygen -y -f "$OLD_KEY_PATH")
ssh -i "$OLD_KEY_PATH" ubuntu@"$PRIVATE_INSTANCE_IP" "grep -v \"$OLD_PUB_KEY\" ~/.ssh/authorized_keys > ~/.ssh/authorized_keys.tmp && mv ~/.ssh/authorized_keys.tmp ~/.ssh/authorized_keys"

# Verify that the new key works
ssh -i "$NEW_KEY_PATH" -o "StrictHostKeyChecking=no" ubuntu@"$PRIVATE_INSTANCE_IP" "echo 'New key is working!'"

# Print a message indicating the new key path
echo "Key rotation complete. Use the new key at $NEW_KEY_PATH to connect to the private instance."

# Optional: remove the old key from the local machine
# rm -f "$OLD_KEY_PATH" "$OLD_KEY_PATH.pub"
