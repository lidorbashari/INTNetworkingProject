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
if [ ! -f ${cert-ca-aws.pem} ]; then
  echo " can't downloading the CA certificate file"
  exit 1
fi

openssl verify -CAfile cert-ca-aws.pem cert.pem > /dev/null
if [ $? -eq 0 ]; then
	echo 'Cert.pem: OK'
else
	echo "Server Certificate is invalid."
	exit 5
fi