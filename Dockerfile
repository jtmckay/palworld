FROM cm2network/steamcmd

# Incoming arguments as environment variables
ARG GAME_PATH
ENV GAME_PATH=${GAME_PATH}

ARG PUBLIC_IP
ENV PUBLIC_IP=${PUBLIC_IP}

ARG PUBLIC_PORT
ENV PUBLIC_PORT=${PUBLIC_PORT}

ARG MAX_PLAYERS
ENV MAX_PLAYERS=${MAX_PLAYERS}

ARG COMMUNITY_SERVER
ENV COMMUNITY_SERVER=${COMMUNITY_SERVER}

ARG SERVER_NAME
ENV SERVER_NAME=${SERVER_NAME}

ARG SERVER_DESCRIPTION
ENV SERVER_DESCRIPTION=${SERVER_DESCRIPTION}

ARG SERVER_PASSWORD
ENV SERVER_PASSWORD=${SERVER_PASSWORD}

ARG ADMIN_PASSWORD
ENV ADMIN_PASSWORD=${ADMIN_PASSWORD}

# Set environment variables
ENV TIMEZONE=Europe/Berlin \
    DEBIAN_FRONTEND=noninteractive \
    PUID=0 \
    PGID=0 \
    ALWAYS_UPDATE_ON_START=true \
    MULTITHREAD_ENABLED=true

# Palworld

WORKDIR $GAME_PATH

VOLUME [ "/palworld" ]

EXPOSE $PUBLIC_PORT/udp

# Credit: https://github.com/jammsen/docker-palworld-dedicated-server/blob/master/servermanager.sh
RUN /home/steam/steamcmd/steamcmd.sh +force_install_dir "/palworld" +login anonymous +app_update 2394010 validate +quit \
echo ">>> Doing an update of the gameserver" \
/home/steam/steamcmd/steamcmd.sh +force_install_dir "/palworld" +login anonymous +app_update 2394010 validate +quit \
echo ">>> Starting the gameserver" \
cd $GAME_PATH \
echo "Checking if config exists" \
if [ ! -f ${GAME_PATH}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini ]; then echo "No config found, generating one" if [ ! -d ${GAME_PATH}/Pal/Saved/Config/LinuxServer ]; then mkdir -p ${GAME_PATH}/Pal/Saved/Config/LinuxServer fi cp ${GAME_PATH}/DefaultPalWorldSettings.ini ${GAME_PATH}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini fi \
sed -i "s/PublicIP=\"[^\"]*\"/PublicIP=\"$PUBLIC_IP\"/" ${GAME_PATH}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini \
sed -i "s/PublicPort=[0-9]*/PublicPort=$PUBLIC_PORT/" ${GAME_PATH}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini \
echo "Setting server name to $SERVER_NAME" \
sed -i "s/ServerName=\"[^\"]*\"/ServerName=\"$SERVER_NAME\"/" ${GAME_PATH}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini \
sed -i "s/ServerDescription=\"[^\"]*\"/ServerDescription=\"$SERVER_DESCRIPTION\"/" ${GAME_PATH}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini \
sed -i "s/ServerPassword=\"[^\"]*\"/ServerPassword=\"$SERVER_PASSWORD\"/" ${GAME_PATH}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini \
sed -i "s/AdminPassword=\"[^\"]*\"/AdminPassword=\"$ADMIN_PASSWORD\"/" ${GAME_PATH}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini \
sed -i "s/ServerPlayerMaxNum=[0-9]*/ServerPlayerMaxNum=$MAX_PLAYERS/" ${GAME_PATH}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini \
START_OPTIONS="$START_OPTIONS EpicApp=PalServer" \
START_OPTIONS="$START_OPTIONS -useperfthreads -NoAsyncLoadingThread -UseMultithreadForDS" \
./PalServer.sh "$START_OPTIONS"
