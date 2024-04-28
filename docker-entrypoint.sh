#!/bin/sh

chown -R steam:steam /valheim
chmod -R 777 /valheim
chown -R steam:steam /data
chmod -R 777 /data
exec runuser -u steam "$@"