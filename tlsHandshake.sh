#!/bin/bash
SERVER_IP=$1
# בדיקת אם נמסר כתובת IP של השרת
if [ -z "$1" ]; then
  echo "Usage: bash tlsHandshake.sh <server-ip>"
  exit 1
fi

SERVER_IP="$1"

# שלב 1: שליחת Client Hello
echo "Sending Client Hello..."
CLIENT_HELLO_RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" -d '{
  "version": "1.3",
  "ciphersSuites": [
    "TLS_AES_128_GCM_SHA256",
    "TLS_CHACHA20_POLY1305_SHA256"
  ],
  "message": "Client Hello"
}' http://$SERVER_IP:8080/clienthello)

if [ $? -ne 0 ]; then
  echo "Failed to send Client Hello."
  exit 2
fi

echo "Client Hello sent successfully."

# שלב 2: פירוק התגובה של Server Hello
echo "Parsing Server Hello response..."
SESSION_ID=$(echo $CLIENT_HELLO_RESPONSE | jq -r '.sessionID')
SERVER_CERT=$(echo $CLIENT_HELLO_RESPONSE | jq -r '.serverCert')

if [ -z "$SESSION_ID" ] || [ -z "$SERVER_CERT" ]; then
  echo "Failed to parse Server Hello response."
  exit 3
fi

echo "Server Hello received: Session ID - $SESSION_ID"
echo $SERVER_CERT > cert.pem

# שלב 3: אימות תעודת השרת
echo "Verifying Server Certificate..."
wget -q https://exit-zero-academy.github.io/DevOpsTheHardWayAssets/networking_project/cert-ca-aws.pem -O cert-ca-aws.pem

openssl verify -CAfile cert-ca-aws.pem cert.pem

if [ $? -ne 0 ]; then
  echo "Server Certificate is invalid."
  exit 5
fi

echo "Server Certificate verified successfully."

# שלב 4: יצירת מפתח ראשי והצפנתו
echo "Generating and encrypting master key..."
MASTER_KEY=$(openssl rand -base64 32)
echo $MASTER_KEY > master-key.txt

ENCRYPTED_MASTER_KEY=$(openssl smime -encrypt -aes-256-cbc -in master-key.txt -outform DER cert.pem | base64 -w 0)

# שליחת המפתח המוצפן לשרת
echo "Sending encrypted master key to server..."
KEY_EXCHANGE_RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" -d "{
  \"sessionID\": \"$SESSION_ID\",
  \"masterKey\": \"$ENCRYPTED_MASTER_KEY\",
  \"sampleMessage\": \"Hi server, please encrypt me and send to client!\"
}" http://$SERVER_IP:8080/keyexchange)

if [ $? -ne 0 ]; then
  echo "Failed to send master key to the server."
  exit 4
fi

echo "Master key sent successfully."

# שלב 5: אימות ההודעה המוצפנת מהשרת
echo "Verifying the encrypted sample message..."
ENCRYPTED_SAMPLE_MESSAGE=$(echo $KEY_EXCHANGE_RESPONSE | jq -r '.encryptedSampleMessage')

# פענוח הודעת הדוגמה המוצפנת
DECODED_SAMPLE_MESSAGE=$(echo $ENCRYPTED_SAMPLE_MESSAGE | base64 -d)

# פענוח ההודעה המוצפנת
DECRYPTED_SAMPLE_MESSAGE=$(echo $DECODED_SAMPLE_MESSAGE | openssl enc -d -aes-256-cbc -pbkdf2 -k $MASTER_KEY)

if [ "$DECRYPTED_SAMPLE_MESSAGE" != "Hi server, please encrypt me and send to client!" ]; then
  echo "Server symmetric encryption using the exchanged master-key has failed."
  exit 6
fi

echo "Server symmetric encryption verified successfully."

# שלב 6: סיום התהליך
echo "Client-Server TLS handshake has been completed successfully."