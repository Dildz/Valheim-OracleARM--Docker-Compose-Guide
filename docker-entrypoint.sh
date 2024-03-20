#!/bin/sh

chown -R steam:steam /valheim
chmod -R 777 /valheim
exec runuser -u steam "$@"