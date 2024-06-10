#bin/bash

source 

#################################################################
# SET VARIABLES
#################################################################
# commands and url extract from signal
URL=$SCRIPT_DIR"/tmp/url.txt"
# which is the file which is send back to the signal group
LOG_FILE=$SCRIPT_DIR"/tmp/transmission.txt"
# cheatsheet file
CHEATSHEET_FILE=$SCRIPT_DIR"/cheatsheet.txt"
#################################################################
##################################################################





touch $URL
timestamp_echo > $LOG_FILE
send_transmission=false

# Function to check the status of transmission-cli processes
check_status() {
  # List all running transmission-cli processes
  pgrep -fl transmission-cli | while read -r process; do
    # Extract the PID
    pid=$(echo $process | awk '{print $1}')
    
    # Display the command being executed
    echo "Process ID: $pid"
    echo "Command: $(ps -p $pid -o args=)"
    
    # Optionally, display more detailed information
    echo "---- Details ----"
    ps -p $pid -o %cpu,%mem,etime,args
    echo "-----------------"
    echo
  done
}


# Parse the JSON file and loop through each message
jq -r --arg groupId "$TARGET_GROUP_ID" '
  .envelope.syncMessage.sentMessage | select(.groupInfo.groupId == $groupId) | .message
' $RECEIVED_MESSAGES_FILE | while IFS= read -r message; do

  echo "$message" >> $URL

  short_message="${message:0:30}"

  # Display the short message
  echo "Message: $short_message"


  done



# load the url from the file
message=$(cat $URL)

# Loop through each magnet link
while IFS= read -r magnet_link; do
  # Start the download with transmission-cli
  
  # check if "magnet" is in magnet_link
  if [[ $magnet_link == *"magnet"* ]]; then
      echo "Downloading: "${magnet_link:0:10}...${magnet_link: -2}"" >> $LOG_FILE
      transmission-remote --add "$magnet_link" >> $LOG_FILE
      send_transmission=true
    continue
  fi

done < "$URL"


###########################################################################
# check log file for download status and send message to signal
###########################################################################




###########################################################################
# check if delete is in the file


if grep -q "delete_" $URL; then
  tokenid=$(cat $URL | grep -oP 'delete_\K.*')
  echo "Deleting torrents with tokenid: $tokenid" >> $LOG_FILE
  transmission-remote -t $tokenid -r
  sleep 1
  transmission-remote -l >> $LOG_FILE
  send_transmission=true
fi




if grep -q "help" $URL; then
  echo "Sending Cheatsheet" >> $LOG_FILE
  signal-cli send -g $TARGET_GROUP_ID -m "[Bot] Here is a Cheatsheet" -a $CHEATSHEET_FILE
  file=$CHEATSHEET_FILE
fi
if grep -q "status" $URL; then
  echo "Checking status of torrents" >> $LOG_FILE
  transmission-remote -l >> $LOG_FILE
  send_transmission=true
fi


if [[ "$send_transmission" == true ]]; then
  signal-cli send -g $TARGET_GROUP_ID -m "[Bot] Here is the Report" -a $LOG_FILE
fi


#check_status
transmission-remote -l 



# remove tmp files
rm $URL $LOG_FILE $RECEIVED_MESSAGES_FILE
