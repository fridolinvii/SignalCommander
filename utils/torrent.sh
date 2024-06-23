#bin/bash


#################################################################
# SET VARIABLES
#################################################################
# which is the file which is send back to the signal group
LOG_FILE=$SCRIPT_DIR"/tmp/transmission.txt"
#################################################################
##################################################################

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



# load the url from the file
message=$(cat $URL)

# Loop through each magnet link
while IFS= read -r magnet_link; do
  # Start the download with transmission-cli
  
  # check if "magnet" is in magnet_link
  if [[ $magnet_link == *"magnet"* ]]; then
      echo "Downloading: "${magnet_link:0:10}...${magnet_link: -2}"" >> $LOG_FILE
      transmission-remote --add "$magnet_link" >> $LOG_FILE
      sleep 1
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


