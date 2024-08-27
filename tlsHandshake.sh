#!/bin/bash
ip_adress=$1
client_hello=$(curl -s -X POST http://${ip_adress}:8080/clienthello \
-H "Content-Type: application/json" \
-d '{
   "version": "1.3",
   "ciphersSuites": [
      "TLS_AES_128_GCM_SHA256",
      "TLS_CHACHA20_POLY1305_SHA256"
   ],
   "message": "Client Hello"
}')

if [ $? -ne 0 ] ; then
  echo "client hello request are failed"
  exit 1
fi

echo "client hello request send succsusfuly"

sessionID=$(echo ${client_hello} || jq -r '.sessionID')
serverCert=$(echo ${client_hello} || jq -r '.serverCert')

if [ -z ${sessionID} ] && [ -Z ${serverCert} ]; then
  echo "filed to parse information from sessionID or serverCert"
  exit 1
fi

echo "sessionID is: $sessionID"
echo "serverCert is: $serverCert"
$serverCert>servercert.pem
echo "Saved sessionID and serverCert"

echo "Downloading the CA certificate file"
wget https://exit-zero-academy.github.io/DevOpsTheHardWayAssets/networking_project/cert-ca-aws.pem
rm cert-ca-aws.pem
if [ ! -f cert-ca-aws.pem ]; then
  echo " can't downloading the CA certificate file"
  exit 1
fi

openssl verify -CAfile cert-ca-aws.pem cert.pem > /dev/null 2>&1
if [[ $? -eq 0 ]]; then
	echo "Cert.pem: OK"
else
	echo "Server Certificate is invalid."
	exit 5
fi

# Generate a master key.
openssl rand -base64 32 > master_key

#encrypt the server certificate with the master key.
ENCRYPTED_MASTER_KEY=$(openssl smime -encrypt -aes-256-cbc -in master_key  -outform DER cert.pem | base64 -w 0)
response_keyexchange=$(curl -s -X POST http://"${PUBLIC_IP}":8080/keyexchange \
                -H "Content-Type: application/json" \
                -d '{
                        "sessionID":"'"${sid}"'",
                        "masterKey":"'"${ENCRYPTED_MASTER_KEY}"'",
                        "sampleMessage": "Hi server, please encrypt me and send to client!"
                }')


# Extract the encrypted sample message
SAMPLE_MESSAGE=$(echo "${response_keyexchange}" | jq -r '.encryptedSampleMessage')

# Decode and save the encrypted message
echo "${SAMPLE_MESSAGE}" | base64 -d > encrypted_message.bin

# Decrypt the message
DECRYPTED_MESSAGE=$(openssl enc -d -aes-256-cbc -pbkdf2 -kfile master_key -in encrypted_message.bin)

sampleMessage="Hi server, please encrypt me and send to client!"
#check if decryption succeeded
if [[ "$DECRYPTED_MESSAGE" != "$sampleMessage" ]]; then
	echo "Server symmetric encryption using the exchanged master-key has failed."
	exit 6
else
	echo "Client-Server TLS handshake has been completed successfully"
	exit 0
fi

# Print the decrypted message
echo "Decrypted message: ${DECRYPTED_MESSAGE}"

# Clean up
rm -f encrypted_message.bin master_key cert-ca-aws.pem