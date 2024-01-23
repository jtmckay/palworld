#!/bin/bash

# Credit: https://github.com/jammsen/docker-palworld-dedicated-server/blob/master/servermanager.sh

GAME_PATH="/palworld"

function installServer() {
    # force a fresh install of all
    echo ">>> Doing a fresh install of the gameserver"
    /home/steam/steamcmd/steamcmd.sh +force_install_dir "/palworld" +login anonymous +app_update 2394010 validate +quit
    mkdir -p ~/.steam/sdk614/
    /home/steam/steamcmd/steamcmd.sh +login anonymous +app_update 1007 +quit
    cp ~/Steam/steamapps/common/Steamworks\ SDK\ Redist/linux64/steamclient.so ~/.steam/sdk64/
}

function updateServer() {
    # force an update and validation
    echo ">>> Doing an update of the gameserver"
    /home/steam/steamcmd/steamcmd.sh +force_install_dir "/palworld" +login anonymous +app_update 2394010 validate +quit
}

function startServer() {
    # IF Bash extendion usaged:
    # https://stackoverflow.com/a/13864829
    # https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_06_02

    echo ">>> Starting the gameserver"
    cd $GAME_PATH

    echo "Checking if config exists"
    echo "[/Script/Pal.PalGameWorldSettings]" > ${GAME_PATH}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
    echo "OptionSettings=(${WORLD_OPTION_SETTINGS//$'\n'/,})" >> ${GAME_PATH}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini

    if [[ ! -z ${PUBLIC_IP+x} ]]; then
        echo "Setting public ip to $PUBLIC_IP"
        sed -i "s/PublicIP=\"[^\"]*\"/PublicIP=\"$PUBLIC_IP\"/" ${GAME_PATH}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
    fi
    if [[ ! -z ${PUBLIC_PORT+x} ]]; then
        echo "Setting public port to $PUBLIC_PORT"
        sed -i "s/PublicPort=[0-9]*/PublicPort=$PUBLIC_PORT/" ${GAME_PATH}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
    fi
    if [[ ! -z ${SERVER_NAME+x} ]]; then
        echo "Setting server name to $SERVER_NAME"
        sed -i "s/ServerName=\"[^\"]*\"/ServerName=\"$SERVER_NAME\"/" ${GAME_PATH}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
        if [[ "$SERVER_NAME" == *"###RANDOM###"* ]]; then
            RAND_VALUE=$RANDOM
            echo "Found standard template, using random numbers in server name"
            sed -i -e "s/###RANDOM###/$RAND_VALUE/g" ${GAME_PATH}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
            echo "Server name is now jammsen-docker-generated-$RAND_VALUE"
        fi
    fi
    if [[ ! -z ${SERVER_DESCRIPTION+x} ]]; then
        echo "Setting server description to $SERVER_DESCRIPTION"
        sed -i "s/ServerDescription=\"[^\"]*\"/ServerDescription=\"$SERVER_DESCRIPTION\"/" ${GAME_PATH}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
    fi
    if [[ ! -z ${SERVER_PASSWORD+x} ]]; then
        echo "Setting server password to $SERVER_PASSWORD"
        sed -i "s/ServerPassword=\"[^\"]*\"/ServerPassword=\"$SERVER_PASSWORD\"/" ${GAME_PATH}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
    fi
    if [[ ! -z ${ADMIN_PASSWORD+x} ]]; then
        echo "Setting server admin password to $ADMIN_PASSWORD"
        sed -i "s/AdminPassword=\"[^\"]*\"/AdminPassword=\"$ADMIN_PASSWORD\"/" ${GAME_PATH}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
    fi

    START_OPTIONS=""
    if [[ -n $COMMUNITY_SERVER ]] && [[ $COMMUNITY_SERVER == "true" ]]; then
        START_OPTIONS="$START_OPTIONS EpicApp=PalServer"
    fi
    if [[ -n $MULTITHREAD_ENABLED ]] && [[ $MULTITHREAD_ENABLED == "true" ]]; then
        START_OPTIONS="$START_OPTIONS -useperfthreads -NoAsyncLoadingThread -UseMultithreadForDS"
    fi
    ./PalServer.sh "$START_OPTIONS"
}

function startMain() {
    # Check if server is installed, if not try again
    if [ ! -f "/palworld/PalServer.sh" ]; then
        installServer
    fi
    if [ $ALWAYS_UPDATE_ON_START == "true" ]; then
        updateServer
    fi
    startServer
}

term_handler() {
	kill -SIGTERM $(pidof PalServer-Linux-Test)
	tail --pid=$(pidof PalServer-Linux-Test) -f 2>/dev/null
	exit 143;
}

trap 'kill ${!}; term_handler' SIGTERM

startMain &
killpid="$!"
while true
do
  wait $killpid
  exit 0;
done