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
GROUP_ID_URL=$SCRIPT_DIR"/tmp/group_id.txt"
# cheatsheet file
CHEATSHEET_FILE=$SCRIPT_DIR"/cheatsheet.html"
# Attachment saved
ATTACHMENT=~/.local/share/signal-cli/attachments/
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


jq -r --argjson groupIds "$TARGET_GROUP_ID" '
  .envelope |
  if .syncMessage != null and (.syncMessage.sentMessage.groupInfo.groupId // "" | IN($groupIds[])) then
    {message: .syncMessage.sentMessage.message, groupId: .syncMessage.sentMessage.groupInfo.groupId}
  elif .dataMessage != null and (.dataMessage.groupInfo.groupId // "" | IN($groupIds[])) then
    {message: .dataMessage.message, groupId: .dataMessage.groupInfo.groupId}
  else
    empty
  end
' $RECEIVED_MESSAGES_FILE | while IFS= read -r line; do
    echo $line
    if [[ $line == *"message"* ]]; then
        url=${line#*'message": "'}
        url=${url%'",'*}
        echo $url >> "$URL"
        echo "Message: ${url:0:30}"
    elif [[ $line == *"groupId"* ]]; then
        groupid=${line#*'groupId": "'}
        groupid=${groupid%'"'*}
        echo $groupid >> "$GROUP_ID_URL"
    fi
done

# Check if the message is a help message and send the cheatsheet to the corresponding group ID
line_number=1
while IFS= read -r message_line; do
  if echo "$message_line" | grep -q "help"; then
    group_id=$(sed "${line_number}q;d" "$GROUP_ID_URL")
    if [ -n "$group_id" ]; then
      echo "Sending Cheatsheet to $group_id" >> "$LOG_FILE"
      signal-cli send -g "$group_id" -m "[Bot] Here is a Cheatsheet" -a "$CHEATSHEET_FILE"
    fi
  fi
  line_number=$((line_number + 1))
done < "$URL"
################################################################



################################################################
#### USE CASES
################################################################
# Torrent
source $SCRIPT_DIR"/utils/torrent.sh"

# latex
source $SCRIPT_DIR"/utils/latex.sh"

################################################################
# remove the received messages file from tmp
rm -r $SCRIPT_DIR/tmp/*

# delete downloaded attachments
rm -r "$ATTACHMENT"*
