#!/bin/bash

# בדיקה אם KEY_PATH מוגדר
if [ -z "$KEY_PATH" ]; then
  echo "KEY_PATH env var is expected"
  exit 5
fi

# בדיקה אם ניתנו הפרמטרים הנדרשים
if [ -z "$1" ]; then
  echo "Please provide bastion IP address"
  exit 5
fi

if [ -z "$2" ]; then
  echo "Please provide target IP address"
  exit 5
fi

# הגדרת משתנים לפרמטרים
BASTION_IP=$1
TARGET_IP=$2

# הסרת הפרמטרים הראשונים (bastion IP ו-target IP)
shift 2

# אם קיימים פרמטרים נוספים, הם יהוו את הפקודה שצריך להריץ על השרת הפרטי
if [ "$#" -gt 0 ]; then
  CMD="$@"
  ssh -i "$KEY_PATH" -o ProxyJump=ubuntu@"$BASTION_IP" ubuntu@"$TARGET_IP" "$CMD"
else
  ssh -i "$KEY_PATH" -o ProxyJump=ubuntu@"$BASTION_IP" ubuntu@"$TARGET_IP"
fi
