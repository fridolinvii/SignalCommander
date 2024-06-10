#!/bin/bash

# Get and print the script's absolute path
SCRIPT_PATH=$(readlink -f "$0" 2>/dev/null || realpath "$0")
# Get the directory of the script
SCRIPT_DIR=$(dirname "$SCRIPT_PATH")
echo "Absolute path to .env:  $SCRIPT_DIR""/.env"



# Function to print messages with timestamp
timestamp_echo() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}











# include the config file
source $SCRIPT_DIR"/.env"


# Execute signal-cli receive command and save the output to a file
timestamp_echo
echo "Listening for messages..."
signal-cli --output=json receive > $RECEIVED_MESSAGES_FILE




##########
source $SCRIPT_DIR"/utils/torrent.sh"





