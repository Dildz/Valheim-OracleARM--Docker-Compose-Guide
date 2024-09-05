# pre-setup.sh

## This script is used to set up the directories and files needed for the Valheim server Docker container.
## It creates the necessary directories, clones the repository, and copies the files to the container's files directory.
## Once the files are copied, it builds the Docker image using the Dockerfile and docker-compose.yml files.
## Modify the container and github-repos directories as needed if you are not using the default paths.

#!/bin/bash

echo "Running pre-setup.sh ..."

# Set up directories
echo "Creating container directories..."
mkdir -p /home/ubuntu/docker/containers/valheim/data
mkdir -p /home/ubuntu/docker/containers/valheim/files
mkdir -p /home/ubuntu/docker/containers/valheim/logs
mkdir -p /home/ubuntu/docker/containers/valheim/server

# Define the container's file path
export VALHEIM_FILES=/home/ubuntu/docker/containers/valheim/files 

# Create a github-repos directory if it doesn't exist
echo "Creating GitHub repository directory..."
mkdir -p /home/ubuntu/github-repos

# Clone the repository
echo "Cloning the repository..."
cd /home/ubuntu/github-repos
git clone https://github.com/Dildz/valheim-arm64-lobbyboyz.git

# Copy the Dockerfile and scripts to the container's files directory
echo "Copying files to the container's files directory..."
cp /home/ubuntu/github-repos/valheim-arm64-lobbyboyz/docker-compose.yml $VALHEIM_FILES
cp /home/ubuntu/github-repos/valheim-arm64-lobbyboyz/docker-entrypoint.sh $VALHEIM_FILES
cp /home/ubuntu/github-repos/valheim-arm64-lobbyboyz/Dockerfile $VALHEIM_FILES
cp /home/ubuntu/github-repos/valheim-arm64-lobbyboyz/init-server.sh $VALHEIM_FILES
cp github-repos/valheim-arm64-lobbyboyz/restart-valheim.sh $VALHEIM_FILES

echo "Setup files have been copied. Proceeding to build the Docker image..."

# Navigate to the container's files directory
cd $VALHEIM_FILES

# Build the Docker image
echo "Building the Docker image..."
docker-compose build --no-cache

echo "Docker image build process should have completed successfully. If not, follow the instructions to troubleshoot."
echo "Now you can start the Valheim server using the [ docker-compose up -d ] command."
echo "Follow that command with [ docker-compose logs -f ] to view the server logs."
