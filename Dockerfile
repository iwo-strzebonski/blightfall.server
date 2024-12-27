FROM ubuntu:24.04

LABEL org.opencontainers.image.source=https://github.com/iwo-strzebonski/blightfall_server

# Build arguments
ARG DEBIAN_FRONTEND=noninteractive
ARG EULA=false
ARG MODPACK_VERSION
ARG RCON_PASSWORD=zaq1@WSX

# Update the system
RUN apt-get update -y
RUN apt-get upgrade -y

WORKDIR /tmp

# Install the required packages
RUN apt-get install openjdk-8-jdk openjdk-8-jre -y --no-install-recommends
RUN apt-get install build-essential -y --no-install-recommends
RUN apt-get install wget -y --no-install-recommends
RUN apt-get install unzip -y --no-install-recommends
RUN apt-get install git -y --no-install-recommends

# Install mcrcon
RUN git clone https://github.com/Tiiffi/mcrcon.git
WORKDIR /tmp/mcrcon
RUN make
RUN make install
RUN cp mcrcon /usr/local/bin
RUN chmod +x /usr/local/bin/mcrcon
WORKDIR /tmp

# Initialize the server directory
RUN mkdir -p /usr/games/minecraft/server

# Make the server's directory a volume so it can be restored when creating a new container
VOLUME /usr/games/minecraft/server

# Download the server
RUN wget -O server.zip "https://servers.technicpack.net/Technic/servers/blightfall/Blightfall_Server_${MODPACK_VERSION}-CE.zip"
RUN unzip server.zip -d /usr/games/minecraft/server
RUN rm server.zip

RUN mv * /usr/games/minecraft/server

# Download Additional Mods
RUN wget "https://github.com/GTNewHorizons/GTNH-Web-Map/releases/download/0.3.34/gtnh-web-map-0.3.34.jar"
RUN mv gtnh-web-map-0.3.34.jar /usr/games/minecraft/server/mods

# Start server and prepare files and directories
RUN mkdir -p /usr/games/minecraft/server/dynmap/renderdata/custom
RUN wget -O DynmapAssets.zip "https://github.com/iwo-strzebonski/blightfall.server/releases/download/v${MODPACK_VERSION}/DynmapAssets-v${MODPACK_VERSION}.zip"
RUN unzip DynmapAssets.zip -d /usr/games/minecraft/server/dynmap/renderdata/custom
RUN rm DynmapAssets.zip

# Configure the server
WORKDIR /usr/games/minecraft/server

RUN rm start.bat
RUN echo "#!/bin/bash\n" | cat - start.sh > temp && mv temp start.sh

RUN chmod +x ./start.sh
RUN ./start.sh

RUN sed -i "/eula=false/c eula=${EULA}" eula.txt

RUN sed -i "s/-Xmx3G/-Xmx6G -XX:+UseG1GC -Dsun.rmi.dgc.server.gcInterval=2147483646 -XX:+UnlockExperimentalVMOptions -XX:G1NewSizePercent=20 -XX:G1ReservePercent=20 -XX:MaxGCPauseMillis=50 -XX:G1HeapRegionSize=32M/" start.sh

RUN sed -i "/enable-query/c enable-query=true" server.properties
RUN sed -i "/enable-rcon/c enable-rcon=true" server.properties
RUN echo "rcon.port=25575" >> server.properties
RUN echo "rcon.password=${RCON_PASSWORD}" >> server.properties
RUN sed -i "/motd/c motd=Pondering the orb..." server.properties
RUN sed -i "/enable-command-block/c enable-command-block=true" server.properties
RUN sed -i "/view-distance/c view-distance=12" server.properties
RUN sed -i "/online-mode/c online-mode=true" server.properties

# Clean up the system
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*
RUN rm -rf /var/cache/*
RUN rm -rf /tmp/*

# Expose ports
EXPOSE 25565
EXPOSE 25575
EXPOSE 8123

# Start the server
ENTRYPOINT [ "./start.sh" ] 
