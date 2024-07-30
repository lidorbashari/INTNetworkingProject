#!/bin/bash


if [ -z "$KEY_PATH" ]; then
  echo "KEY_PATH env var is expected"
  exit 5
fi

if [ $# -eq "1"]; then
  ssh -i "KEY_PATH" ubuntu"$1"
  exit 1
  fi

if [ $# -eq "0" ]; then
  echo "Please provide bastion IP address"
  exit 5
fi

if [ $# -eq "2"]; then
  ssh -J "$KEY_PATH" ubuntu@"$1" ubuntu@"$2"
fi

if [ "$#" -eq "3" ]; then
  ssh -J "$KEY_PATH" ubuntu@"$1" ubuntu"$2"
  $3
fi