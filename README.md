# Setting up Valheim server with docker for Ubuntu on Oracle Cloud ARM64

Runs SteamCMD and Valheim with [FEX](https://github.com/FEX-Emu/FEX) (Only tested on Oracle Cloud ARM64 free tier)

## Installing Docker
First of all you need Docker. [Official setup guide here.](https://docs.docker.com/engine/install/ubuntu/)

This guide is for ubuntu but you can find guides for other operating systems/distributions on their website.

Here is a summary of the install commands...

Step 1: Update the Package Index and Install Prerequisites
```
sudo apt-get update
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
```

Step 2: Add Docker’s Official GPG Key
```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```

Step 3: Set Up the Stable Repository
```
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

Step 4: Update the Package Index Again
```
sudo apt-get update
```

Step 5: Install latest Docker Engine
```
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

Step 6: Enable and Start Docker
```
sudo systemctl enable docker
```
```
sudo systemctl start docker
```

Step 5: Add user to the docker group & activate the changes
```
sudo usermod -aG docker $USER
```
```
newgrp docker
```

You can verify your Docker installation by running `docker --version` or by running `docker run hello-world`

## Pre-Setup
Use the pre-setup.sh file found in [Releases](https://github.com/Dildz/valheim-arm64-lobbyboyz) to create the docker folders, clone the Github repository, copy the required files into the files directory and build the container.

Download & place the pre_setup.sh file in your home folder & run with:
```
cd ~
```
```
./pre-setup.sh
```

It will take a while, but once it is finished you can safely remove this file as you are now ready for the next steps.

## Starting the docker container
Next we are going start the container for the 1st time with the following commands:
```
cd $HOME/docker/containers/valheim/files
```
```
docker-compose up -d && docker-compose logs -f
```

## Post-Setup
Once the server has finished starting for the 1st time we are going to exit out of the live-logs by pressing **Ctrl + C**

Then we are going to run the post-setup.sh script in the github repo folder:
```
cd $HOME/github-repos/Valheim-OracleARM--Docker-Compose-Guide
```
```
./post-setup.sh
```

This will create a cron-job that restarts the Valheim server every day at midnight.

## Notes
- I use ZeroTier One for connecting clients to my server as this is a private server for the LobbyBoyz Discord community.
- You are welcome to fork this repository and modify according to your own needs.
- All files are clearly commented & you are expected to modify names/ports/passwords/directory locations etc according to your setup.

If you make any mistakes or any step fails & you would like to start over - use the following set of commands run from within the files directory:
```
cd $HOME/docker/containers/valheim/files
```
Stop & remove the container:
```
docker-compose down
```
Remove the container image:
```
docker rmi valheim
```
Clean up build files:
```
docker builder prune
```
Remove the contents of the container's server & data folders:
```
sudo rm -rf /home/ubuntu/docker/containers/valheim/server/*
```
```
sudo rm -rf /home/ubuntu/docker/containers/valheim/data/*
```

You can now re-run the build command as follows:
```
docker-compose build --no-cache
```
When completed, run:
```
docker-compose up -d
```
```
docker-compose logs -f
```

## Based on
- https://github.com/TeriyakiGod/steamcmd-docker-arm64
- https://github.com/thijsvanloef/palworld-server-docker
- https://github.com/jammsen/docker-palworld-dedicated-server
- https://github.com/hadizh/valheim-arm64
