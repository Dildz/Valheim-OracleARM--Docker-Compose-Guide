# Valheim Arm64 Dedicated Server

Runs SteamCMD and Valheim with [FEX](https://github.com/FEX-Emu/FEX) (Only tested on Oracle Cloud free tier)

## Getting started

1. Make a docker-compose.yml file (see example below) in the same folder as the Dockerfile and the rest of the scripts
2. Create `valheim` sub-directory in the same folder and run `chmod 777 valheim` for full permissions or use `chown -R 1000:1000 valheim/`.
3. Start via `docker compose up -d` (Starts detached, you can use `docker compose down` to stop it)
4. The default port for your server is 2456 (UDP)

### Example Docker Compose file
```yml
version: "3"

services:
  valheim_local:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: valheim_local
    environment:
      - SERVER_NAME=MyServer
      - WORLD_NAME=Server
      - SERVER_PASS=password
      - PUBLIC=0
      - UPDATE=true
      - PORT=2456
    ports:
      - "2456:2456/udp"
    volumes:
      - "./valheim/data:/data:rw"
      - "./valheim/server:/valheim:rw"
    restart: unless-stopped
```

### Environment variables

There are environment variables that you can set in the docker-compose.yml file
- SERVER_NAME
- WORLD_NAME
- SERVER_PASS (this needs to be longer than 5 characters)
- PUBLIC (if server is publically discoverable)
- UPDATE
- PORT

## Based on
- https://github.com/TeriyakiGod/steamcmd-docker-arm64
- https://github.com/thijsvanloef/palworld-server-docker
- https://github.com/jammsen/docker-palworld-dedicated-server

## Running multiple instances with separate external IPs on the same server

This is actually not specific to Valheim, but will work for running a number of arbitrary Docker containers, with each container on its own network. The method described here is for multiple network interfaces with each interface having its own IP address (this may or may not work for a single network interface with multiple IP addresses assigned).

(Tested on Oracle Cloud with an Ubuntu 22.04 server)

1. Add a new network interface to your server (it's OK for the NIC to be on the same subnet, but it needs to have a public IP). Note the private IP address (in this example, the primary NIC has an IP address of `10.0.0.58` and the secondary NIC has an IP address of `10.0.0.67`)

2. In your instance, run `ip addr` to see what to see what the name of the new network interface is. Here the new instance is `enp1s0`
```txt
2: enp0s6: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9000 qdisc mq state UP group default qlen 1000
    link/ether 02:00:17:01:98:27 brd ff:ff:ff:ff:ff:ff
    inet 10.0.0.58/24 metric 100 brd 10.0.0.255 scope global enp0s6
       valid_lft forever preferred_lft forever
    inet6 fe80::17ff:fe01:9827/64 scope link 
       valid_lft forever preferred_lft forever
3: enp1s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 02:00:17:00:96:7c brd ff:ff:ff:ff:ff:ff
```
3. For the Docker container that you want to be run with the secondary network interface, edit the docker-compose file to create a new bridge network that your Docker container will use (make sure to choose a subnet that does not overlap with any other subnets that are currently in use on the server). The new network should have IP masquerading disabled. Also, change any port bindings in the `ports` section to start with the private IP address of your secondary NIC 

(see `valheim1-docker-compose.yml` in the `examples` folder for an example of what the above changes should look like). 


4. (for Ubuntu 18.04 and above) Add a new netplan file under `/etc/netplan` to configure Internet routes for the new network interface, as well as routing the Docker network created in step 3 to the private IP address of the secondary network interface 

(see the `51-enp1s0.yaml` in the `examples` folder for an example of what the netplan config should look like). 


5. Run `sudo netplan apply` to apply the routes for the new network interface to the routing table (server may need to be rebooted after this step).

6. Add a new rule to `iptables` to change the source ip address of all packets originating from the Docker network created in step 3 (take care to get the correct name) to the private IP address of the secondary network interface
```
sudo iptables -t nat -A POSTROUTING -s 172.21.0.0/16 ! -o valheim1_net -j SNAT --to-source 10.0.0.67
```
Note that this rule will not persist across reboots, so make sure to have it run on startup.

7. For any other Docker containers that you run, if you want to bind a port you must make sure to change any port bindings in the `ports` section to start with the private IP address of the NIC that the container will be run with. By default, Docker will bind ports on all network interfaces if the host IP in the binding is not specified.

(see `valheim2-docker-compose.yml` in the `examples` folder for an example of what this change should look like).

## Based on
- https://github.com/moby/moby/issues/30053#issuecomment-1077041045 
