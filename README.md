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

### Make a backup of game files
Copy to target from source
`tar cfz ~/backups/saved-$(date +%Y%m%d_%H%M%S).tar.gz ~/palworld/games/Pal/Saved/`

### Reboot server automatically
Edit cron
`sudo crontab -e`
Everyday at noon UTC
`0 12 * * * /sbin/shutdown -r +5`
