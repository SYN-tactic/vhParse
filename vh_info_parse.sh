#!/bin/bash
WEBHOOK_URL="$DISCORD_VALHEIM_WEBHOOK"
# Use this script to extract information about the player from the valheim logs.
# I want to be able to extract the steam ID, the player name, I guess the ZDOID?, and then
# pull the player's profile link and picture from steam.
# I'll save the image info just in a subdirectory of the script directory, and I'll use something like
# jq to save/parse json about individual players, saved to a players.json file.
STEAM_NAME=""
function get_steam_name {
  STEAMID=$1
  STEAM_NAME=$(curl -I https://steamcommunity.com/profiles/$STEAMID | grep Location | sed 's/Location: https:\/\/steamcommunity.com\/id\///g' | sed 's/\///g' | tr -d '\r')
  return 0
}

function get_steam_info {
  line=$1 # The line being processed
  STEAMID=$(jq -r '.steam_id' <<< "$line")
  PROFILE_LINK="https://steamcommunity.com/profiles/$STEAMID"
  # jq --arg STEAMID $STEAMID -r '{(.steam_id): {last_connected: .connection_time, status: .event}}' <<< "$line"
  ONLINE_STATUS=$(jq -r --arg STEAMID "$STEAMID"  '.event' <<< "$line")
  if [ "$ONLINE_STATUS" == "connected" ]; then
    ONLINE_STATUS="online"
    # echo "Player $STEAMID is online"
  else
    ONLINE_STATUS="offline"
    # echo "Player $STEAMID is offline"
  fi
  PLAYER_INFO=$(jq --arg STEAMID "$STEAMID" --arg STATUS "$ONLINE_STATUS" --arg LINK "$PROFILE_LINK" '{last_connected: .connection_time, status: $STATUS, profile_link: $LINK}' <<< "$line")
  if jq --arg STEAMID $STEAMID -e '.[$STEAMID]' players.json >/dev/null 2>&1; then
    # echo "Edit the players.json file with the updated event information"
    jq --arg STEAMID "$STEAMID" --argjson PLAYER_INFO "$PLAYER_INFO" '.[$STEAMID] = .[$STEAMID] + $PLAYER_INFO' players.json > tmp.json && mv tmp.json players.json
  else
    # echo "Player is not yet present in file"
    jq --arg STEAMID "$STEAMID" --argjson PLAYER_INFO "$PLAYER_INFO" '. + {$STEAMID : $PLAYER_INFO}' players.json > tmp.json && mv tmp.json players.json
  fi
  
  if jq --arg STEAMID $STEAMID -e '.[$STEAMID].steam_name' players.json >/dev/null 2>&1; then
      # echo "Steam name is already present"
      STEAM_NAME=$(jq -r --arg STEAMID "$STEAMID" '.[$STEAMID].steam_name' players.json)
    else 
      # echo "Steam name is NOT present"
      get_steam_name "$STEAMID"
      if [ "$STEAM_NAME" == "" ]; then
        jq --arg STEAMID "$STEAMID" --arg STEAM_NAME "$STEAM_NAME" '.[$STEAMID].steam_name = ""' players.json > tmp.json && mv tmp.json players.json
      else
        jq --arg STEAMID "$STEAMID" --arg STEAM_NAME "$STEAM_NAME" '.[$STEAMID].steam_name = $STEAM_NAME' players.json > tmp.json && mv tmp.json players.json
      fi
  fi

  if jq --arg STEAMID $STEAMID -e '.[$STEAMID].viking_name' players.json >/dev/null 2>&1; then
    # echo "Steam name is already present"
    VIKING_NAME=$(jq -r --arg STEAMID "$STEAMID" '.[$STEAMID].viking_name' players.json)
  else
    VIKING_NAME=""
  fi
  # echo "Steam Name is: $STEAM_NAME"
}

while read line; do
  # Print the line in case it's needed somewhere else
  echo "$line"
  # Check to see if jq recognizes the line as json
  if jq -e . >/dev/null 2>&1 <<<"$line"; then
    get_steam_info "$line"
    DISPLAY_NAME="$VIKING_NAME"
    if [ "$VIKING_NAME" == "" ]; then
      DISPLAY_NAME="$STEAM_NAME"
    elif [ "$STEAM_NAME" == "" ]; then
      DISPLAY_NAME="Unknown"
    fi
    if [ "$ONLINE_STATUS" == "online" ]; then
      echo "The Viking [$DISPLAY_NAME]($PROFILE_LINK) has arrived in Valheim!🍻"
      ./send_discord.sh "$WEBHOOK_URL" "The Viking [$DISPLAY_NAME]($PROFILE_LINK) has arrived in Valheim!🍻"
    elif [ "$ONLINE_STATUS" == "offline" ]; then
      echo "The Viking [$DISPLAY_NAME]($PROFILE_LINK) has left to greener pastures.🐄"
      pwd
      ./send_discord.sh "$WEBHOOK_URL" "The Viking [$DISPLAY_NAME]($PROFILE_LINK) has left to greener pastures.🐄"
    else 
      echo 'Player status is unknown'
    fi
  fi

done < /dev/stdin