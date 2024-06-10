#!/bin/bash

# Get and print the script's absolute path
SCRIPT_PATH=$(readlink -f "$0" 2>/dev/null || realpath "$0")
# Get the directory of the script
SCRIPT_DIR=$(dirname "$SCRIPT_PATH")
echo "Absolute path to .env:  $SCRIPT_DIR""/.env"

# include the config file
source $SCRIPT_DIR"/.env"

#################################################################
# SET VARIABLES
#################################################################
# Where the messages are received
RECEIVED_MESSAGES_FILE=$SCRIPT_DIR"/tmp/received_messages.json"
# commands and url extract from signal
URL=$SCRIPT_DIR"/tmp/url.txt"
# which is the file which is send back to the signal group
LOG_FILE=$SCRIPT_DIR"/tmp/transmission.txt"
# cheatsheet file
CHEATSHEET_FILE=$SCRIPT_DIR"/cheatsheet.txt"
#################################################################


# Execute signal-cli receive command and save the output to a file
echo "Listening for messages..."
signal-cli --output=json receive > $RECEIVED_MESSAGES_FILE




##########
source $SCRIPT_DIR"/utils/torrent.sh"





