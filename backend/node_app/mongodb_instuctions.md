# Mongodb on RPI
## Docker setup
Pull a working `Docker` image for the RPI
```bash
docker pull mongodb/mongodb-community-server:4.4.9-ubuntu2004
```
Start the docker container with the follwing settings: <br>
`-p 27017:27017` map the container port to host port <br>
set username and password <br>
`-e MONGO_INITDB_ROOT_USERNAME=admin` <br>
`-e MONGO_INITDB_ROOT_PASSWORD=admin` <br>
`--restart always` Container starts on system boot
```bash
docker run --name mongodb   -p 27017:27017   -d   -e MONGO_INITDB_ROOT_USERNAME=admin   -e MONGO_INITDB_ROOT_PASSWORD=admin   --restart always --memory="2g" --cpus="2"   mongodb/mongodb-community-server:4.4.9-ubuntu2004
```

## Work with MongoDB
Connect to the DB with `mongosh` <br>
```bash
mongosh "mongodb://admin:admin@<ip to the server>:27017"
```
