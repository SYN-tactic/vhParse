#!/bin/bash
# Use this script to detect incoming log messages from the valheim server and send them to discord.
# This script will check to see if there is a local players.json file to grab more information about a player
# so that the messages sent to a server can be a little more comprehensive and useful.
# send messages to discord
# Usage: 
# msgd "the message you want to post" 
# How to send to the smarhome channel:
# msgd -c smarhome "Your message"
# make sure to link this to your path when first setting it up:
# ln -s /usr/local/bin/msgd ~/behome4linux/scripts/msgd.sh

WEBHOOK_URL=$1
CONTENT=$2

curl \
        -H "Content-Type: application/json" \
        -d '{"username":"dantes", "content":"'"$CONTENT"'"}' \
        $WEBHOOK_URL
# Example for how to send attachments:
# -F 'payload_json={}' - sets json body.
# -F "file1=@cat.jpg" - adds cat.jpg file as attachment.
# -F "file2=@images/dog.jpg" - adds dog.jpg file from images directory.
# Using -F also sets "Content-Type: multipart/form-data" header specifying it can be ommited.
#curl \
#  -F 'payload_json={"username": "test", "content": "hello"}' \
#  -F "file1=@cat.jpg" \
#  -F "file2=@images/dog.jpg" \
#  $WEBHOOK_URL