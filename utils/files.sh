#!/bin/bash


#################################################################
# SET VARIABLES
#################################################################
# which is the file which is send back to the signal group
LOG_FILE=$SCRIPT_DIR"/tmp/files_overview.txt"
#################################################################
##################################################################



# Function to expand a range (e.g., 3-5 becomes 3 4 5)
expand_range() {
    local range=$1
    if [[ $range == *"-"* ]]; then
        # Split the range into start and end
        local start=${range%-*}
        local end=${range#*-}
        # Loop from start to end
        echo $(seq $start $end)
    else
        # If it's a single number, just echo it
        echo $range
    fi
}



#################################################################


send_file_overview=false


line_number=1
while IFS= read -r message_line; do
  # Display the message
  echo "Message in files.sh: $message_line"
  # Start the download with transmission-cli
  
  # check if "magnet" is in message_line
  if [[ $message_line == "files_"* ]]; then
    
    download_path_name=$(sed "${line_number}q;d" "$NAME_ID_URL")
    download_path=$TORRENT_DOWNLOAD_DIR"/$download_path_name"

    ls $download_path | nl > $LOG_FILE
    group_id_files=$(sed "${line_number}q;d" "$GROUP_ID_URL")

    # Delete all files
    if [[ $message_line == "files_delete_all" ]]; then
      echo "All files deleted!" >> $LOG_FILE
      rm -r $download_path/*
    fi

    # Delete specific file
    if [[ $message_line == "files_delete_"* ]]; then
        echo "Delete specific file" 
        tokenid=$(echo $message_line | grep -oP 'files_delete_\K.*')
        echo $tokenid
        
        # Get the list of files and store them in an array
        files=($(ls $download_path/))

        

        # Loop over comma-separated values in tokenid
        IFS=',' read -ra entries <<< "$tokenid"
        for entry in "${entries[@]}"; do
            # Expand the range and loop over the expanded values
            for i in $(expand_range $entry); do
                # Adjust for zero-based index since ls output is 1-based in this case
                index=$((i - 1))
                if [[ $index -ge 0 && $index -lt ${#files[@]} ]]; then
                    # Get the file at the current index
                    file=${files[$index]}
                    echo "Processing file: $file"
                    # Delete the file
                    rm -r "$download_path/$file"
                    echo "File $file deleted!" >> $LOG_FILE
                    # Add your processing logic for each file here
                else
                    echo "Index $i is out of range."
                fi
            done
        done




      
    fi

    signal-cli send -g $group_id_files -m "[Bot] Here is the Report" -a $LOG_FILE

  fi


  sleep 1
  line_number=$((line_number + 1))
done < "$URL"
