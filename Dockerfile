FROM cm2network/steamcmd

# Set environment variables
ENV TIMEZONE=Europe/Berlin \
    DEBIAN_FRONTEND=noninteractive \
    PUID=0 \
    PGID=0 \
    ALWAYS_UPDATE_ON_START=true \
    MULTITHREAD_ENABLED=true

# Palworld
ENV GAME_PATH="/palworld"

VOLUME [ "/palworld" ]

EXPOSE 15637/udp

# Credit: https://github.com/jammsen/docker-palworld-dedicated-server/blob/master/servermanager.sh
RUN echo ">>> Installing/updating the gameserver" \
/home/steam/steamcmd/steamcmd.sh +force_install_dir "/palworld" +login anonymous +app_update 2394010 validate +quit

RUN echo ">>> Configuring the gameserver"
RUN cd $GAME_PATH
RUN echo "Making config dir"

USER root
RUN mkdir -m 777 -p ${GAME_PATH}/Pal/Saved/Config/LinuxServer
USER steam

RUN echo "Copying config"
RUN cp ${GAME_PATH}/DefaultPalWorldSettings.ini ${GAME_PATH}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini || true
RUN sed -i "s/PublicIP=\"[^\"]*\"/PublicIP=\"$PUBLIC_IP\"/" ${GAME_PATH}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini || true
RUN sed -i "s/PublicPort=[0-9]*/PublicPort=15637/" ${GAME_PATH}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini || true
RUN echo "Setting server name to $SERVER_NAME"
RUN sed -i "s/ServerName=\"[^\"]*\"/ServerName=\"$SERVER_NAME\"/" ${GAME_PATH}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini || true
RUN sed -i "s/ServerDescription=\"[^\"]*\"/ServerDescription=\"$SERVER_DESCRIPTION\"/" ${GAME_PATH}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini || true
RUN sed -i "s/ServerPassword=\"[^\"]*\"/ServerPassword=\"$SERVER_PASSWORD\"/" ${GAME_PATH}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini || true
RUN sed -i "s/AdminPassword=\"[^\"]*\"/AdminPassword=\"$ADMIN_PASSWORD\"/" ${GAME_PATH}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini || true
RUN sed -i "s/ServerPlayerMaxNum=[0-9]*/ServerPlayerMaxNum=$MAX_PLAYERS/" ${GAME_PATH}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini || true

CMD echo ">>> Starting the gameserver" && \
sleep 99999 && \
./PalServer.sh "EpicApp=PalServer -useperfthreads -NoAsyncLoadingThread -UseMultithreadForDS"
