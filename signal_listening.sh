#!/bin/bash


# Get and print the script's absolute path
SCRIPT_PATH=$(readlink -f "$0" 2>/dev/null || realpath "$0")
# Get the directory of the script
SCRIPT_DIR=$(dirname "$SCRIPT_PATH")
echo "Absolute path to .env:  $SCRIPT_DIR""/.env"

source $SCRIPT_DIR"/utils/utils.sh"


#################################################################
# SET VARIABLES
#################################################################
# Where the messages are received
RECEIVED_MESSAGES_FILE=$SCRIPT_DIR"/tmp/received_messages.json"
################################################################



################################################################
# Load environment variables
source $SCRIPT_DIR"/.env"

################################################################



# Execute signal-cli receive command and save the output to a file
timestamp_echo
echo "Listening for messages..."
signal-cli --output=json receive > $RECEIVED_MESSAGES_FILE



################################################################
# Check if any messages were received
message=$(cat $RECEIVED_MESSAGES_FILE)
# if message is empty, exit
if [ -z "$message" ]; then
  echo "No message found"
  rm $RECEIVED_MESSAGES_FILE
  exit 1
fi
################################################################



################################################################
#### USE CASES
################################################################
# Torrent
source $SCRIPT_DIR"/utils/torrent.sh"





# rm $RECEIVED_MESSAGES_FILE
