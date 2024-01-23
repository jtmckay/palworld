FROM cm2network/steamcmd

# Set environment variables
ENV TIMEZONE=Europe/Berlin \
    DEBIAN_FRONTEND=noninteractive \
    PUID=0 \
    PGID=0 \
    ALWAYS_UPDATE_ON_START=true \
    MAX_PLAYERS=32 \
    MULTITHREAD_ENABLED=true \
    COMMUNITY_SERVER=true \
    RCON_ENABLED=true \
    RCON_PORT=25575 \
    PUBLIC_PORT=8211

# Palworld
ENV GAME_PATH="/palworld"

VOLUME [ "/palworld" ]

EXPOSE 15637/udp

RUN echo ">>> Copying servermanager.sh"
ADD --chmod=777 servermanager.sh /servermanager.sh

CMD ["/servermanager.sh"]
