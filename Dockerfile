##
## Dockerfile
## VALHEIM ARM64 Container
##

# Use Ubuntu 22.04 as base
FROM ubuntu:22.04

# Set timezone environment variables (change the timezone to your system's location)
ENV TZ=Africa/Johannesburg
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install necessary packages
RUN DEBIAN_FRONTEND=noninteractive apt update && apt install -y curl python3 sudo expect-dev software-properties-common 
RUN DEBIAN_FRONTEND=noninteractive apt install -y libatomic1 libpulse-dev libpulse0

# Download Install FEX script to temp file
RUN curl --silent https://raw.githubusercontent.com/FEX-Emu/FEX/main/Scripts/InstallFEX.py --output /tmp/InstallFEX.py

# FEX installer has to install RootFS on the user we want to run the program
# Run as steam user, auto answer yes for all prompts and auto extract on "FEXRootFSFetcher"
# also makes it run with unbuffer because it's fucking shit (TLDR wants to run under zenity when we don't have a display, isatty call being stupid)
RUN sed -i 's@\["FEXRootFSFetcher"\]@"sudo -u steam bash -c \\"unbuffer FEXRootFSFetcher -y -x\\"", shell=True@g' /tmp/InstallFEX.py

# Run verification on steam user
RUN sed -i 's@\["FEXInterpreter", "/usr/bin/uname", "-a"\]@"sudo -u steam bash -c \\"FEXInterpreter /usr/bin/uname -a\\"", shell=True@g' /tmp/InstallFEX.py

# Create user steam
RUN useradd -m steam

# Run Install FEX and remove the temp file
RUN python3 /tmp/InstallFEX.py && rm /tmp/InstallFEX.py

# Change user to steam
USER steam

# Go to /home/steam/Steam
WORKDIR /home/steam/Steam

# Download and extract SteamCMD
RUN curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf - 

# Copy init-server.sh to container
COPY --chmod=755 ./init-server.sh /home/steam/init-server.sh

# Set default environment variables (make sure these match the values in the docker-compose.yml file)
ENV SERVER_NAME="MyAwesomeServer" \
    PUBLIC=0 \
    WORLD_NAME="MyAwesomeWorld" \
    SERVER_PASS="MySuperSecretPassword" \
    UPDATE="true" \
    SAVE_DIR="/data" \
    PORT=2456 \
    INSTANCEID=1

# Expose ports needed
EXPOSE 2456/udp 2457/udp 2458/udp

# Change user back to root
USER root

# Copy docker-entrypoint.sh to container
COPY --chmod=755 ./docker-entrypoint.sh /docker-entrypoint.sh

# Run it
ENTRYPOINT ["/bin/sh", "/docker-entrypoint.sh"]
CMD ["/home/steam/init-server.sh"]

