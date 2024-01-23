# palworld

Make a "game" directory in the root of this repository.
`mkdir game`

Change permissions to allow everything.
`chmod 777 game`


## Push new build
```
docker build -t palworld .
docker tag palworld jtmckay/palworld:latest
docker push jtmckay/palworld:latest
```
