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
# commands and url extract from signal
URL=$SCRIPT_DIR"/tmp/url.txt"
# cheatsheet file
CHEATSHEET_FILE=$SCRIPT_DIR"/cheatsheet.txt"
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
### Process the received messages
################################################################

# Check if any messages were received
message=$(cat $RECEIVED_MESSAGES_FILE)
# if message is empty, exit
if [ -z "$message" ]; then
  echo "No message found"
  rm $RECEIVED_MESSAGES_FILE
  exit 1
fi

# Parse the JSON file and loop through each message
jq -r --arg groupId "$TARGET_GROUP_ID" '
  .envelope.syncMessage.sentMessage | select(.groupInfo.groupId == $groupId) | .message
' $RECEIVED_MESSAGES_FILE | while IFS= read -r message; do

  echo "$message" >> $URL

  short_message="${message:0:30}"

  # Display the short message
  echo "Message: $short_message"
  done


# check if the message is a help message
if cat $URL | grep -q "help"; then
  echo "Sending Cheatsheet" >> $LOG_FILE
  signal-cli send -g $TARGET_GROUP_ID -m "[Bot] Here is a Cheatsheet" -a $CHEATSHEET_FILE
fi
################################################################



################################################################
#### USE CASES
################################################################
# Torrent
source $SCRIPT_DIR"/utils/torrent.sh"


################################################################
# remove the received messages file from tmp
rm $RECEIVED_MESSAGES_FILE $URL

