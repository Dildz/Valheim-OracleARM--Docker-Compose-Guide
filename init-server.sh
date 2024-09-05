# init-server.sh

## This script is used to start the Valheim server with the specified settings.
## It checks for read/write permissions, SteamCMD updates, and installs or updates the Valheim server.
## Once the server is installed or updated, it starts the server with the specified settings.
## Modify the log file path to match the location in the pre-setup.sh script.

#!/bin/bash

set -e
export PATH=/usr/local/bin/:$PATH

# Function to install or update the Valheim server
function installServer() {
  # Run SteamCMD to install or update the Valheim server
  FEXBash './steamcmd.sh +@sSteamCmdForcePlatformType linux +force_install_dir /valheim +login anonymous +app_update 896660 validate +quit'
}

# Main function to set up and start the server
function main() {
  # Check if we have proper read/write permissions for the server directory
  if [ ! -r "/valheim" ] || [ ! -w "/valheim" ]; then
      echo 'ERROR: I do not have read/write permissions to /valheim! Please run "chown -R 1000:1000 /valheim" on host machine, then try again.'
      exit 1
  fi

  # Check for SteamCMD updates
  echo 'Checking for SteamCMD updates...'
  FEXBash './steamcmd.sh +login anonymous +quit'

  # Check if the server is installed or if an update is required
  if [ ! -f "/valheim/valheim_server.x86_64" ] || [ "$UPDATE" = "true" ]; then
      echo 'Installing or updating the Valheim server... (This may take some time)'
      installServer
  fi

  # Fix for steamclient.so not being found by the server
  mkdir -p /home/steam/.steam/sdk64
  cp /home/steam/Steam/linux64/steamclient.so /home/steam/.steam/sdk64/steamclient.so

  echo 'Starting Valheim server... You can safely ignore any Steam errors shown here.'

  # Change to the server directory
  cd /valheim

  # Start the Valheim server with the specified settings (change the log file path to match the location in the pre-setup.sh script)
  log_file="/home/ubuntu/docker/logs/valheim.log"
  FEXBash "./valheim_server.x86_64 -nographics -batchmode -instanceid $INSTANCEID -name \"$SERVER_NAME\" -port $PORT -public $PUBLIC -world \"$WORLD_NAME\" -password \"$SERVER_PASS\" -savedir $SAVE_DIR -logFile /dev/stdout 2>&1 | tee -a $log_file -saveinterval 600 -backups 0"
}

# Run the main function
main
