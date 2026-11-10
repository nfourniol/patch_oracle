#!/bin/bash
###########
#
# This script send an email to an existing smtp server

# Read of parameter
HOST=$1
MAIL_FROM=$2
MAIL_TO=$3
SUBJECT=$4
CONTENT=$5

CLEAN_MAIL_TO=$(echo $MAIL_TO | sed "s/'//g")       # Remove simple quote present in MAIL_TO
ESCAPED_CONTENT=$(echo "$CONTENT" | sed 's/"/\"/g') # Escape double quotes
IFS=';'
for email in $CLEAN_MAIL_TO
do
  # --connect-timeout / --max-time: never block the calling script if the SMTP server does not answer
  curl --silent --show-error --connect-timeout 10 --max-time 60 smtp://${HOST} --mail-from "$MAIL_FROM" --mail-rcpt "$email" -T <(echo -e "From: ${MAIL_FROM}\nTo: ${email}\nContent-type: text/plain;charset=utf-8\nSubject: ${SUBJECT}\n\n${ESCAPED_CONTENT}")
done

IFS=$' \t\n'
