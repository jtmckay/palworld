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

RUN echo ">>> Installing/updating the gameserver" \
/home/steam/steamcmd/steamcmd.sh +force_install_dir "/palworld" +login anonymous +app_update 2394010 validate +quit

RUN echo ">>> Copying servermanager.sh over" \
ADD servermanager.sh /servermanager.sh

CMD ["/servermanager.sh"]
