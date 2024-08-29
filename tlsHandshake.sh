#!/bin/bash

ip_address=$1

# Client Hello
client_hello=$(curl -s -X POST http://${ip_address}:8080/clienthello \
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
  echo "Client Hello request failed"
  exit 1
fi

echo "Client Hello request sent successfully"

sessionID=$(echo ${client_hello} | jq -r '.sessionID')
serverCert=$(echo ${client_hello} | jq -r '.serverCert')

if [ -z ${sessionID} ] || [ -z ${serverCert} ]; then
  echo "Failed to parse sessionID or serverCert"
  exit 1
fi

echo "sessionID is: $sessionID"
echo "serverCert is: $serverCert"
echo "$serverCert" > servercert.pem
echo "Saved sessionID and serverCert"

# Download CA certificate
echo "Downloading the CA certificate file"
rm -f cert-ca-aws.pem
wget https://exit-zero-academy.github.io/DevOpsTheHardWayAssets/networking_project/cert-ca-aws.pem
if [ ! -f cert-ca-aws.pem ]; then
  echo "Failed to download the CA certificate file"
  exit 1
fi

# Verify Server Certificate
openssl verify -CAfile cert-ca-aws.pem servercert.pem > /dev/null 2>&1
if [[ $? -eq 0 ]]; then
    echo "Server Certificate: OK"
else
    echo "Server Certificate is invalid."
    exit 5
fi

# Generate Master Key
openssl rand -base64 32 > master_key
if [ ! -f master_key ]; then
  echo "Failed to generate master key"
  exit 1
fi

# Encrypt the Master Key using Server's Public Key
openssl smime -encrypt -aes-256-cbc -in master_key -outform DER -out encrypted_master_key.bin servercert.pem
if [ $? -ne 0 ]; then
  echo "Failed to encrypt master key"
  exit 1
fi

# Base64 encode the encrypted master key
encrypted_master_key=$(base64 -w 0 < encrypted_master_key.bin)

# Send Encrypted Master Key to Server
response_keyexchange=$(curl -s -X POST http://${ip_address}:8080/keyexchange \
-H "Content-Type: application/json" \
-d "{
    \"sessionID\": \"${sessionID}\",
    \"masterKey\": \"${encrypted_master_key}\",
    \"sampleMessage\": \"Hi server, please encrypt me and send to client!\"
}")

if [ $? -ne 0 ] ; then
  echo "Key exchange request failed"
  exit 1
fi

# Extract and Decrypt Encrypted Sample Message
SAMPLE_MESSAGE=$(echo "${response_keyexchange}" | jq -r '.encryptedSampleMessage')

if [ -z "$SAMPLE_MESSAGE" ]; then
    echo "Failed to retrieve encrypted sample message"
    exit 1
fi

# Decode the encrypted message
echo "${SAMPLE_MESSAGE}" | base64 -d > encrypted_message.bin

# Decrypt the message using the master key
DECRYPTED_MESSAGE=$(openssl enc -d -aes-256-cbc -pbkdf2 -kfile master_key -in encrypted_message.bin)

sampleMessage="Hi server, please encrypt me and send to client!"

# Verify Decrypted Message
if [[ "$DECRYPTED_MESSAGE" != "$sampleMessage" ]]; then
    echo "Server symmetric encryption using the exchanged master-key has failed."
    exit 6
else
    echo "Client-Server TLS handshake has been completed successfully"
    exit 0
fi

# Clean up
rm -f encrypted_message.bin master_key cert-ca-aws.pem servercert.pem encrypted_master_key.bin