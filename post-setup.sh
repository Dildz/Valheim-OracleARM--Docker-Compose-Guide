# post-setup.sh

## This script will setup a cron task to restart the Valheim server using the restart-valheim.sh script.
## The cron task will run once a day at midnight system time.
## Modify the cron task as needed to change the restart time, frequency and restart script location.

#!/bin/bash

echo "Running post-setup.sh ..."

# Set up the cron task to restart the Valheim server
echo "Setting up the cron task to restart the Valheim server..."

# Define the path to the restart script
RESTART_SCRIPT="/home/ubuntu/docker/containers/valheim/files/restart-valheim.sh"

# Define the cron task
cron_task="0 0 * * * $RESTART_SCRIPT"

# Add the cron task to the crontab, checking for existing entries to prevent duplicates
(crontab -l 2>/dev/null | grep -q "$RESTART_SCRIPT") || (crontab -l 2>/dev/null; echo "$cron_task") | crontab -

echo "Cron task has been set up to restart the Valheim server daily at midnight system time."
