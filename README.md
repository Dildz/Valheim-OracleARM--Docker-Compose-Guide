# Valheim Arm64 Dedicated Server

Runs SteamCMD and Valheim with [FEX](https://github.com/FEX-Emu/FEX) (Only tested on Oracle Cloud free tier)

## Getting started

1. Make the following directories for the Valheim container - mine are as follows:
```
/home/ubuntu/docker/containers/valheim/files
```
```
/home/ubuntu/docker/containers/valheim/server
```
```
/home/ubuntu/docker/storage/valheim/data
```
Make a log file for the Valheim server (to be used for processing by a Discord Bot)
```
/home/ubuntu/docker/logs/valheim.log
```
2. Clone the GitHub repository to a location of choosing:
```
git clone https://github.com/Dildz/valheim-arm64-lobbyboyz
```
3. Copy the Dockerfile, yml & sh files to /home/ubuntu/docker/containers/valheim/files
4. Build the container with:
```
docker build --no-cache -t valheim-server .
```
5. Start the container using:
```
docker compose up -d
```

The default port for your server is 2456 (UDP)

### Example Docker Compose file
```yml
version: "3"

services:
  valheim:
    build:
      context: /home/ubuntu/docker/containers/valheim/files
      dockerfile: Dockerfile
    container_name: valheim
    environment:
      - SERVER_NAME=MyServer
      - WORLD_NAME=Server
      - SERVER_PASS=password
      - PUBLIC=0
      - UPDATE=true
      - PORT=2456
    ports:
      - "2456:2456/udp"
      - "2457:2457/udp"
      - "2458:2458/udp"
      - "27015:27015/tcp"
    volumes:
      - "/home/ubuntu/docker/storage/valheim/data:/data:rw"
      - "/home/ubuntu/docker/containers/valheim/server:/valheim:rw"
      - "/home/ubuntu/docker/logs/valheim.log:/home/ubuntu/docker/logs/valheim.log"
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "/bin/bash", "/home/steam/healthcheck.sh"]
      interval: 1m
      timeout: 10s
      retries: 3
```

### Environment variables

There are environment variables that you can set in the docker-compose.yml file
- SERVER_NAME
- WORLD_NAME
- SERVER_PASS (this needs to be longer than 5 characters)
- PUBLIC (if server is publicly discoverable)
- UPDATE
- PORT

## Based on
- https://github.com/TeriyakiGod/steamcmd-docker-arm64
- https://github.com/thijsvanloef/palworld-server-docker
- https://github.com/jammsen/docker-palworld-dedicated-server

## Notes
I use ZeroTier One for connecting clients to the server as this is a private server for the LobbyBoyz Discord community.