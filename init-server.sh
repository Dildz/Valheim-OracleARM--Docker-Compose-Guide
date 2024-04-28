#!/bin/bash

set -e
export PATH=/usr/local/bin/:$PATH

function installServer() {
  FEXBash './steamcmd.sh +@sSteamCmdForcePlatformType linux +force_install_dir /valheim +login anonymous +app_update 896660 validate +quit'
}

function main() {
  # Check if we have proper read/write permissions
  if [ ! -r "/valheim" ] || [ ! -w "/valheim" ]; then
      echo 'ERROR: I do not have read/write permissions to /valheim! Please run "chown -R 1000:1000 valheim" on host machine, then try again.'
      exit 1
  fi

    # Check for SteamCMD updates
  echo 'Checking for SteamCMD updates...'
  FEXBash './steamcmd.sh +login anonymous +quit'

  # Check if the server is installed
  if [ ! -f "/valheim/valheim_server.x86_64" ] || [ $UPDATE = "true" ]; then
      echo 'Installing... (Do not panic if it looks stuck)'
      installServer
  fi

  # Fix for steamclient.so not being found
  mkdir -p /home/steam/.steam/sdk64
  cp /home/steam/Steam/linux64/steamclient.so /home/steam/.steam/sdk64/steamclient.so


  echo 'Starting server... You can safely ignore Steam errors! (Also the server has pretty much 0 logging, so just try connecting to it)'

  # Go to /valheim
  cd /valheim

  # Start server
  # export templdpath=$LD_LIBRARY_PATH
  # export LD_LIBRARY_PATH=./linux64:$LD_LIBRARY_PATH
  # export SteamAppId=892970
  TIMENOW=$(date +%Y_%m_%d_%H%M)
  FEXBash "./valheim_server.x86_64 -nographics -batchmode -instanceid $INSTANCEID -name $SERVER_NAME -port $PORT -public $PUBLIC -world $WORLD_NAME -password $SERVER_PASS -savedir $SAVE_DIR -logFile /data/server_$TIMENOW.log -saveinterval 600 -backups 0" # 2>/dev/null | tee -a "$LOG_FILE"
  # export LD_LIBRARY_PATH=$templdpath
}

main