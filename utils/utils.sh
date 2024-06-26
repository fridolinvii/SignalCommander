#bin/bash




# Function to print messages with timestamp
timestamp_echo() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') $1"
}


# Check if the folder tmp exists, if not, create it
FOLDER_PATH_TMP=$SCRIPT_DIR"/tmp"
if [ ! -d "$FOLDER_PATH_TMP" ]; then
  # If the folder does not exist, create it
  mkdir -p "$FOLDER_PATH_TMP"
fi


#########################################################

LOCKFILE="$SCRIPT_DIR/tmp/signal_listening.lock"

# Check if lock file exists
if [ -e "$LOCKFILE" ] && kill -0 "$(cat $LOCKFILE)"; then
    echo "Script is already running."
    exit 1
fi

# Create a lock file with the current process ID
echo $$ > "$LOCKFILE"

# Ensure the lock file is removed when the script exits
trap 'rm -f "$LOCKFILE"' EXIT
