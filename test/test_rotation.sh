set -e

export KEY_PATH=$(pwd)/private_key
OLD_KEYS=$(bash bastion_connect.sh $PUBLIC_IP $PRIVATE_IP "cat ~/.ssh/authorized_keys")

echo "Public keys found in the ~/.ssh/authorized_keys file in your private instance:"
echo -e "------------------------------------------------------------------------------\n\n"

echo $OLD_KEYS

echo -e "\n\nCopying the rotation script into your public instance."
echo -e "Command: scp ssh_keys_rotation.sh ubuntu@$PUBLIC_IP:/home/ubuntu/\n\n"

scp ssh_keys_rotation.sh ubuntu@$PUBLIC_IP:/home/ubuntu/

echo -e "\n\nConnecting to your public instance and executing the rotation script."
echo -e "Command: ssh -i $KEY_PATH ubuntu@$PUBLIC_IP \"./ssh_keys_rotation.sh $PRIVATE_IP\"\n\n"

ssh -i $KEY_PATH ubuntu@$PUBLIC_IP "./ssh_keys_rotation.sh $PRIVATE_IP"

NEW_KEYS=$(bash bastion_connect.sh $PUBLIC_IP $PRIVATE_IP "cat ~/.ssh/authorized_keys")

echo "Public keys found in the ~/.ssh/authorized_keys file in your private

echo '✅ Rotation done successfully!'
