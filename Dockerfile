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
RUN if [ ! -f "/palworld/PalServer.sh" ]; then \
      # force a fresh install of all \
      echo ">>> Doing a fresh install of the gameserver" \
      /home/steam/steamcmd/steamcmd.sh +force_install_dir "/palworld" +login anonymous +app_update 2394010 validate +quit \
    fi \
    if [ $ALWAYS_UPDATE_ON_START == "true" ]; then \
      # force an update and validation \
      echo ">>> Doing an update of the gameserver" \
      /home/steam/steamcmd/steamcmd.sh +force_install_dir "/palworld" +login anonymous +app_update 2394010 validate +quit \
    fi \
    echo ">>> Starting the gameserver" \
    cd $GAME_PATH \
    echo "Checking if config exists" \
    if [ ! -f ${GAME_PATH}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini ]; then \
        echo "No config found, generating one" \
        if [ ! -d ${GAME_PATH}/Pal/Saved/Config/LinuxServer ]; then \
            mkdir -p ${GAME_PATH}/Pal/Saved/Config/LinuxServer \
        fi \
        # Copy default-config, which comes with the server to gameserver-save location \
        cp ${GAME_PATH}/DefaultPalWorldSettings.ini ${GAME_PATH}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini \
    fi \
    if [[ -n $PUBLIC_IP ]]; then \
        echo "Setting public ip to $PUBLIC_IP" \
        sed -i "s/PublicIP=\"[^\"]*\"/PublicIP=\"$PUBLIC_IP\"/" ${GAME_PATH}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini \
    fi \
    if [[ -n $PUBLIC_PORT ]]; then \
        echo "Setting public port to $PUBLIC_PORT" \
        sed -i "s/PublicPort=[0-9]*/PublicPort=$PUBLIC_PORT/" ${GAME_PATH}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini \
    fi \
    if [[ -n $SERVER_NAME ]]; then \
        echo "Setting server name to $SERVER_NAME" \
        sed -i "s/ServerName=\"[^\"]*\"/ServerName=\"$SERVER_NAME\"/" ${GAME_PATH}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini \
        if [[ "$SERVER_NAME" == *"###RANDOM###"* ]]; then \
            RAND_VALUE=$RANDOM \
            echo "Found standard template, using random numbers in server name" \
            sed -i -e "s/###RANDOM###/$RAND_VALUE/g" ${GAME_PATH}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini \
            echo "Server name is now jammsen-docker-generated-$RAND_VALUE" \
        fi \
    fi \
    if [[ -n $SERVER_DESCRIPTION ]]; then \
        echo "Setting server description to $SERVER_DESCRIPTION" \
        sed -i "s/ServerDescription=\"[^\"]*\"/ServerDescription=\"$SERVER_DESCRIPTION\"/" ${GAME_PATH}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini \
    fi \
    if [[ -n $SERVER_PASSWORD ]]; then \
        echo "Setting server password to $SERVER_PASSWORD" \
        sed -i "s/ServerPassword=\"[^\"]*\"/ServerPassword=\"$SERVER_PASSWORD\"/" ${GAME_PATH}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini \
    fi \
    if [[ -n $ADMIN_PASSWORD ]]; then \
        echo "Setting server admin password to $ADMIN_PASSWORD" \
        sed -i "s/AdminPassword=\"[^\"]*\"/AdminPassword=\"$ADMIN_PASSWORD\"/" ${GAME_PATH}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini \
    fi \
    if [[ -n $MAX_PLAYERS ]]; then \
        echo "Setting max-players to $MAX_PLAYERS" \
        sed -i "s/ServerPlayerMaxNum=[0-9]*/ServerPlayerMaxNum=$MAX_PLAYERS/" ${GAME_PATH}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini \
    fi \
    START_OPTIONS="" \
    if [[ -n $COMMUNITY_SERVER ]] && [[ $COMMUNITY_SERVER == "true" ]]; then \
        START_OPTIONS="$START_OPTIONS EpicApp=PalServer" \
    fi \
    if [[ -n $MULTITHREAD_ENABLED ]] && [[ $MULTITHREAD_ENABLED == "true" ]]; then \
        START_OPTIONS="$START_OPTIONS -useperfthreads -NoAsyncLoadingThread -UseMultithreadForDS" \
    fi \
    ./PalServer.sh "$START_OPTIONS"
