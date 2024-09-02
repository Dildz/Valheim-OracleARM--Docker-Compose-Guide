#!/bin/sh

# docker-entrypoint.sh

# Set ownership and permissions for the server and data directories
chown -R steam:steam /valheim
chmod -R 777 /valheim
chown -R steam:steam /data
chmod -R 777 /data

# Ensure log directory has the correct permissions
chown -R steam:steam /home/ubuntu/docker/logs
chmod -R 777 /home/ubuntu/docker/logs

# Execute the command as the steam user
exec runuser -u steam -- "$@"
