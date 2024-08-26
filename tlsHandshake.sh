#!/bin/bash

client_hello=$( curl -s -X POST http://{$ip_adress}:8080 \
-H "Content-Type: application/json" \
-d '{
   "version": "1.3",
   "ciphersSuites": [
      "TLS_AES_128_GCM_SHA256",
      "TLS_CHACHA20_POLY1305_SHA256"
   ],
   "message": "Client Hello"
}'

echo ${client_hello}
