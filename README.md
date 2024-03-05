# palworld
## Setup server
Make a "game" directory in the root of this repository.
`mkdir game`

Change permissions to allow everything.
`chmod 777 game`

Copy the .env.example to .env
`cp .env.example .env`

Update relevant values. EG: IP, PORT, WORLD_OPTION_SETTINGS
`nano .env`

Load env variables
`source .env`

Start server
`sudo docker-compose up -d`

## Push new build
```
docker build -t palworld .
docker tag palworld jtmckay/palworld:latest
docker push jtmckay/palworld:latest
```

### Automagically run commands
Edit cron
`sudo crontab -e`

### Make a backup of game files
Copy to target from source
`tar cfz ~/backups/saved-$(date +%Y%m%d_%H%M%S).tar.gz ~/palworld/game/Pal/Saved/`
Everyday at noon UTC (5am MST)
`0 12 * * * tar cfz ~/backups/saved-$(date +%Y%m%d_%H%M%S).tar.gz ~/palworld/game/Pal/Saved/`

### Reboot server
`/sbin/shutdown -r`
Everyday at noon UTC +5 minutes
`0 12 * * * /sbin/shutdown -r +5`

### Update .env
All variables must be single lines going into docker
#### Update .env.example
#### Load variables
`source .env.example`
#### Update .env
`echo "WORLD_OPTION_SETTINGS='$WORLD_OPTION_SETTINGS'" >> .env`
#### Delete old line
