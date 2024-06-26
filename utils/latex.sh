#bin/bash



# load the url from the file
message=$(cat $URL)
group_id=$(cat $GROUP_ID_URL)

echo "LATEX"
echo $message


# Loop through each magnet link
send_transmission=false
line_number=1
while IFS= read -r message_line; do
  # Display the message
  echo "Message in torrent.sh: $message_line"
  group_id_latex=$(sed "${line_number}q;d" "$GROUP_ID_URL")
  # Start the download with transmission-cli
  
  # check if "*tex" is in message_line
  if [[ $message_line == *".tex" ]]; then
      echo "Found tex message" 

      echo "Check if only one zip file is attached"
      file_count=$(ls "$ATTACHMENT"*.zip 2>/dev/null | wc -l)
      # Check the file count and perform actions based on the count
      if [ "$file_count" -eq 0 ]; then
        echo "No .zip files found."
        signal-cli send -g "$group_id_latex" -m "[Bot] ERROR. No zip files found."
      elif [ "$file_count" -eq 1 ]; then
        echo "One .zip file found."
        # Unzip the file
        unzip -d $SCRIPT_DIR"/tmp/LATEX"  $ATTACHMENT*.zip
        # Compile the latex file
        cd $SCRIPT_DIR"/tmp/LATEX"
        file_path=$(find . -name "Thesis_Carla.tex" -exec dirname {} \;)
        if [ -z "$file_path" ]; then
          echo "No such file found."
        else
          echo "File found in directory: $file_path"
          cd $file_path
          pwd
          
          #output=$(pdflatex -interaction=nonstopmode $message_line 2>&1)
          output=$(latexmk -f -pdf -interaction=nonstopmode $message_line 2>&1)

          if echo "$output" | grep -q "no output PDF file produced!"; then
              echo "A fatal error may occurred during LaTeX compilation."
              signal-cli send -g "$group_id_latex" -m "[Bot] A fatal error may occurred during LaTeX compilation." -a "${message_line%.tex}.log"
          else
              echo "LaTeX compilation completed successfully."
              signal-cli send -g $group_id_latex -m "[Bot] Here is your PDF" -a "${message_line%.tex}.pdf"
          fi
        fi
        cd $SCRIPT_DIR

      else
        echo "Multiple .zip files found."
        signal-cli send -g "$group_id_latex" -m "[Bot] ERROR. Multiple zip files found. Please send only one .zip file or try again."
      fi


      
      

      send_transmission=true
      group_id_latex=$(sed "${line_number}q;d" "$GROUP_ID_URL")
  fi

  line_number=$((line_number + 1))
done < "$URL"
