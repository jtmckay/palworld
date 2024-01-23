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
