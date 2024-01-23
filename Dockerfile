FROM cm2network/steamcmd

# Set environment variables
ENV TIMEZONE=Europe/Berlin \
    DEBIAN_FRONTEND=noninteractive \
    PUID=0 \
    PGID=0 \
    ALWAYS_UPDATE_ON_START=true \
    MULTITHREAD_ENABLED=true \
    COMMUNITY_SERVER=true \
    WORLD_OPTION_SETTINGS='Difficulty=NoneDayTimeSpeedRate=1.000000NightTimeSpeedRate=1.000000ExpRate=1.000000PalCaptureRate=1.000000PalSpawnNumRate=1.000000PalDamageRateAttack=1.000000PalDamageRateDefense=1.000000PlayerDamageRateAttack=1.000000PlayerDamageRateDefense=1.000000PlayerStomachDecreaceRate=1.000000PlayerStaminaDecreaceRate=1.000000PlayerAutoHPRegeneRate=1.000000PlayerAutoHpRegeneRateInSleep=1.000000PalStomachDecreaceRate=1.000000PalStaminaDecreaceRate=1.000000PalAutoHPRegeneRate=1.000000PalAutoHpRegeneRateInSleep=1.000000BuildObjectDamageRate=1.000000BuildObjectDeteriorationDamageRate=1.000000CollectionDropRate=1.000000CollectionObjectHpRate=1.000000CollectionObjectRespawnSpeedRate=1.000000EnemyDropItemRate=1.000000DeathPenalty=AllbEnablePlayerToPlayerDamage=FalsebEnableFriendlyFire=FalsebEnableInvaderEnemy=TruebActiveUNKO=FalsebEnableAimAssistPad=TruebEnableAimAssistKeyboard=FalseDropItemMaxNum=3000DropItemMaxNum_UNKO=100BaseCampMaxNum=128BaseCampWorkerMaxNum=15DropItemAliveMaxHours=1.000000bAutoResetGuildNoOnlinePlayers=FalseAutoResetGuildTimeNoOnlinePlayers=72.000000GuildPlayerMaxNum=20PalEggDefaultHatchingTime=72.000000WorkSpeedRate=1.000000bIsMultiplay=FalsebIsPvP=FalsebCanPickupOtherGuildDeathPenaltyDrop=FalsebEnableNonLoginPenalty=TruebEnableFastTravel=TruebIsStartLocationSelectByMap=TruebExistPlayerAfterLogout=FalsebEnableDefenseOtherGuildPlayer=FalseCoopPlayerMaxNum=4ServerPlayerMaxNum=32ServerName="Default Palworld Server"ServerDescription=""AdminPassword=""ServerPassword=""PublicPort=8211PublicIP=""RCONEnabled=FalseRCONPort=25575Region=""bUseAuth=TrueBanListURL="https://api.palworldgame.com/api/banlist.txt"'

# Palworld
ENV GAME_PATH="/palworld"

VOLUME [ "/palworld" ]

RUN echo ">>> Copying servermanager.sh"
ADD --chmod=777 servermanager.sh /servermanager.sh

CMD ["/servermanager.sh"]
