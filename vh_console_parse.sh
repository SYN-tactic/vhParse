#!/bin/bash
# This script reads the input from a valheim server log and translates 
# the information into a friendlier format that can be directed wherever you wish.
function process_pattern {
  line=$1 # The line being processed
  pattern=$2 # The regex pattern to match
  message=$3 # The message to replace the pattern with
  if echo "$line" | grep -q -E "$pattern"; then
    message=$(echo "$line" | grep -E "$pattern" | sed -E "s/$pattern/$message/g" | tr -d '\r')
    echo "$message"
  fi
}
while read line; do
  # All numbers and letters: [A-Za-z0-9]+
  # All numbers: [0-9]+
  # All letters: [A-Za-z]+
  # process_pattern "$line" "pattern1 ([A-Za-z]+) ([0-9]+)" "Custom message for $pattern: \1 \2"
  # Grabs the steam id of the user
  process_pattern "$line" "^.*Got connection SteamID ([0-9]+)" "User \1 just connected to the server"
  process_pattern "$line" "(^.*) Got connection SteamID ([0-9]+)" "{\"steam_id\":\"\2\",\"connection_time\":\"$(date +"%s")\",\"event\":\"connected\"}"
  # Grabs the viking's name and ZDOID (whatever that is)
  process_pattern "$line" "Got character ZDOID from ([A-Za-z0-9]+) : ([A-Za-z0-9]+)" "Viking \1 has connected!"
  process_pattern "$line" "(^.*) Got character ZDOID from ([A-Za-z0-9]+) : ([A-Za-z0-9]+)" "{\"viking_name\":\"\2\",\"zdo_id\":\"\3\",\"event\":\"connected\"}"
  # Detects when a player has disconnected from the server; includes the steam id.
  process_pattern "$line" "Closing socket ([A-Za-z0-9]+)" "Viking \1 has left Valheim!"
  process_pattern "$line" "(^.*) Closing socket ([A-Za-z0-9]+)" "{\"steam_id\":\"\2\",\"connection_time\":\"$(date +%s)\",\"event\":\"disconnected\"}"

done < /dev/stdin
