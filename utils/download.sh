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
  echo "Message in download.sh: $message_line"
  # Start the download with transmission-cli
  
  # check if "magnet" is in message_line
  if [[ $message_line == "download_"* ]]; then
  group_id_files=$(sed "${line_number}q;d" "$GROUP_ID_URL")
  zip_path=$SCRIPT_DIR/utils/_api


    if [[ $message_line == "download_stop" ]]; then
       rm -r $zip_path
    fi


    if [[ $message_line == "download_stop" || $message_line == "download_status" ]]; then
        if ps aux | grep -v grep | grep gunicorn > /dev/null
        then
            echo "Gunicorn is running" >> $LOG_FILE
            if [[ $message_line == "download_stop" ]]; then          
                echo "Stopping gunicorn" >> $LOG_FILE  
                pid_gunicorn=$(ps aux | grep gunicorn  | awk '{print$2}' | head -n 1)
                echo "Killing Gunicorn with PID: $pid_gunicorn"
                kill -9 $pid_gunicorn
            fi  
        else
            echo "Gunicorn is not running." >> $LOG_FILE
        fi
        if ps aux | grep -E "ssh[[:space:]]+.*$PORT_LOCAL:0.0.0.0:$PORT_GLOBAL" | grep -v grep > /dev/null
        then
            # If gunicorn is running, do something
            echo "SSH is running" >> $LOG_FILE
            if [[ $message_line == "download_stop" ]]; then          
                echo "Stopping SSH" >> $LOG_FILE
                pid_ssh=$(ps aux | grep -E "ssh[[:space:]]+.*$PORT_LOCAL:0.0.0.0:$PORT_GLOBAL" | grep -v grep | awk '{print $2}')
                echo "Killing SSH with PID: $pid_ssh"
                kill -9 $pid_ssh
            fi
        else
            echo "SSH is not running." >> $LOG_FILE
        fi

    else     # Check if gunicorn is running
        if ps aux | grep -v grep | grep gunicorn > /dev/null
        then
            # If gunicorn is running, do something
            echo "Gunicorn is already running. Can not generate Link." > $LOG_FILE
            echo "Gunicorn is already running. Can not generate Link." 
        else
            signal-cli send -g $group_id_files -m "[Bot] Creating Link. This may take a while."
            download_path_name=$(sed "${line_number}q;d" "$NAME_ID_URL")
            download_path=$TORRENT_DOWNLOAD_DIR"/$download_path_name"

            _tokenid=$(echo $message_line | grep -oP 'download_\K.*')
            # Extract time
            if [[ "$_tokenid" == *_* ]]; then
              UPTIME=$(echo $_tokenid | grep -oP '_\K.*')
            fi
            tokenid="${_tokenid%%_*}"




            echo ZIP: $tokenid
            
            # Get the list of files and store them in an array
            mkdir -p $zip_path
            zip_file=$DOWLOAD_FILE_NAME
            PASSWD=($(openssl rand -hex 32))

            ########################################################
            # List the files in download_path with numbers (nl adds line numbers)
            index_list=$(ls $download_path | nl)

            # Loop over comma-separated values in tokenid
            IFS=',' read -ra entries <<< "$tokenid"
            for entry in "${entries[@]}"; do
                # Expand the range and loop over the expanded values
                for index in $(expand_range $entry); do
                    # Extract the file name corresponding to the current index
                    selected_text=$(echo "$index_list" | awk -v i="$index" '$1 == i {print $2}')
                    
                    # If the file exists, process it
                    if [[ -n $selected_text ]]; then
                        echo "Processing file: $selected_text"
                        # Construct the file path
                        full_file_path="$download_path/$selected_text"
                        
                        # Optionally, uncomment the following line to zip the files
                        7z a -p$PASSWD -mhe=on "$zip_path/$zip_file" "$full_file_path"
                    else
                        echo "No file found for index: $index" 
                        echo "No file found for index: $index" >> $LOG_FILE
                    fi
                done
            done


            ########################################################
            touch $SCRIPT_DIR/utils/_api/__init__.py
            echo "FOLDER_PATH = '$zip_path'" > $SCRIPT_DIR/utils/_api/api_variabels.py
            echo "filename = '$zip_file'" >> $SCRIPT_DIR/utils/_api/api_variabels.py
            site_address=($(openssl rand -hex 32))
            echo "token_id = '$site_address'" >> $SCRIPT_DIR/utils/_api/api_variabels.py
            echo "port_local = '$PORT_LOCAL'" >> $SCRIPT_DIR/utils/_api/api_variabels.py

            ########################################################
            sleep 10


            echo "Starting ssh"
            nohup ssh -i $PATH_PRIVATE_KEY -tt -R $PORT_LOCAL:0.0.0.0:$PORT_GLOBAL $DOCKER_USER_NAME@$DOCKER_SITE_ADDRESS -p $PORT_SSH >  $SCRIPT_DIR/ssh.log 2>&1 &
            pid_ssh=$!

            sleep 30

            echo "Starting gunicorn"
            source $SCRIPT_DIR/$VENV_NAME/bin/activate
            cd $SCRIPT_DIR/utils
            echo "Check if gunicorn is installed: " $(which gunicorn)
            # nohup gunicorn -w 4 -b 0.0.0.0:$PORT_LOCAL api:api >  $SCRIPT_DIR/gunicorn.log 2>&1 &
            nohup gunicorn -k gevent --workers=4 --timeout=300 -b 0.0.0.0:$PORT_LOCAL app:api > $SCRIPT_DIR/gunicorn.log 2>&1 &
            pid_gunicorn=$!
            sleep 10
            cd $SCRIPT_DIR

            echo $DOCKER_SITE_ADDRESS/$site_address >> $LOG_FILE
            echo Password: $PASSWD  >> $LOG_FILE
            echo "Link is available for $UPTIME" >> $LOG_FILE
            echo "-----------------------------------------------"

            echo SSH: $pid_ssh 
            echo GUNICORN: $pid_gunicorn

            bash -c "(sleep $UPTIME; kill -9 $pid_ssh $pid_gunicorn; rm -r $zip_path)" >> $SCRIPT_DIR/kill.log 2>&1 &

            fi
        fi


    signal-cli send -g $group_id_files -m "[Bot] Here is the Report" -a $LOG_FILE
    fi
  sleep 1
  line_number=$((line_number + 1))
done < "$URL"




