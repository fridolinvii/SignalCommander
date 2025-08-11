#!/bin/bash

contacts=( $(signal-cli listContacts | awk '{print $2}') )
total=${#contacts[@]}

for i in "${!contacts[@]}"; do
  number=${contacts[i]}
  signal-cli removeContact "$number"
  echo -ne "Removing contacts: $((i+1)) / $total\r"
done
echo -ne "\nDone.\n"
