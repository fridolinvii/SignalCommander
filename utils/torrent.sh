#!/bin/bash


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
group_id=$(cat $GROUP_ID_URL)


# Loop through each magnet link
line_number=1
while IFS= read -r message_line; do
  # Display the message
  echo "Message in torrent.sh: $message_line"
  # Start the download with transmission-cli
  
  # check if "magnet" is in message_line
  if [[ $message_line == *"magnet"* ]]; then
      download_path_name=$(sed "${line_number}q;d" "$NAME_ID_URL")
      download_path=$TORRENT_DOWNLOAD_DIR"/$download_path_name"
      echo "Downloading: "${message_line:0:10}...${message_line: -2}"" >> $LOG_FILE
      transmission-remote --add "$message_line"  --download-dir "$download_path" >> $LOG_FILE
      sleep 1
      send_transmission=true
      group_id_torrent=$(sed "${line_number}q;d" "$GROUP_ID_URL")
  fi


  ###########################################################################
  # check if delete is in the file
  if [[ $message_line == "delete_"* ]]; then
    tokenid=$(echo $message_line | grep -oP 'delete_\K.*')
    echo "Deleting torrents with tokenid: $tokenid" >> $LOG_FILE
    transmission-remote -t $tokenid -r
    sleep 1
    transmission-remote -l >> $LOG_FILE
    send_transmission=true
    group_id_torrent=$(sed "${line_number}q;d" "$GROUP_ID_URL")
  fi

  if [[ $message_line == "status" ]]; then
    echo "Checking status of torrents" >> $LOG_FILE
    transmission-remote -l >> $LOG_FILE
    send_transmission=true
    group_id_torrent=$(sed "${line_number}q;d" "$GROUP_ID_URL")
  fi


  line_number=$((line_number + 1))
done < "$URL"


###########################################################################
# check log file for download status and send message to signal
###########################################################################


echo "Torrent Transmission"
echo "$send_transmission"
echo "$group_id_torrent"


if [[ "$send_transmission" == true ]]; then
  echo "Sending Message"
  echo "$group_id_torrent -m  -a $LOG_FILE"
  signal-cli send -g $group_id_torrent -m "[Bot] Here is the Report" -a $LOG_FILE
fi


#check_status
transmission-remote -l 


