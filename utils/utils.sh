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