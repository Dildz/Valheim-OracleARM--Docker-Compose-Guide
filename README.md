# Valheim Arm64 Dedicated Server

Runs SteamCMD and Valheim with [FEX](https://github.com/FEX-Emu/FEX) (Only tested on Oracle Cloud free tier)

## Getting started

1. Make a docker-compose.yml file in a folder of your choice
2. Create `valheim` sub-directory on the folder and run `chmod 777 valheim` for full permissions or use `chown -R 1000:1000 valheim/`.
3. Start via `docker compose up -d` (Starts detached, you can use `docker compose down` to stop it)
4. The default port for your server is 2456 (UDP)

## Docker Compose
```yml
version: "3"

services:
  valheim_local:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: valheim_local
    environment:
      - SERVER_NAME=TheDistrict
      - WORLD_NAME=District
      - SERVER_PASS=password
      - PUBLIC=0
      - UPDATE=true
    ports:
      - "2456:2456/udp"
      - "2457:2457/udp"
      - "2458:2458/udp"
      - "27015:27015"
    volumes:
      - "../valheim/data:/data:rw"
      - "../valheim/server:/valheim:rw"
    restart: unless-stopped
```

### Environment variables

There are environment variables that you can set in the docker-compose.yml file
- SERVER_NAME
- WORLD_NAME
- SERVER_PASS (this needs to be longer than 5 characters)
- PUBLIC (if server is publically discoverable)
- UPDATE

## Based on
- https://github.com/TeriyakiGod/steamcmd-docker-arm64
- https://github.com/thijsvanloef/palworld-server-docker
- https://github.com/jammsen/docker-palworld-dedicated-server
