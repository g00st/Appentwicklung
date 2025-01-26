# Mongodb on RPI
## Docker setup
Pull a working `Docker` image for the RPI
```bash
docker pull mongodb/mongodb-community-server:4.4.9-ubuntu2004
```

 Create folder for the DB
 ```bash
 mkdir ~/mongoDB
 cd mongoDB
 ```

 Create docker volume
 ```bash
 docker volume create MongoDB_Storage
 ```

 Docker compose
 ```bash
 touch docker-compose.yaml
 ```
 Add the following content to the file with a text editor fo your choise
 ```plaintext
 version: '3'
services:
  mongodb_4_4_9:
    image: mongodb/mongodb-community-server:4.4.9-ubuntu2004
    environment:
      - MONGO_INITDB_ROOT_USERNAME=root
      - MONGO_INITDB_ROOT_PASSWORD=password123
    ports:
      - 27017:27017
    volumes:
      - MongoDB_Storage:/data/db
volumes:
  MongoDB_Storage:
    external: true
 ```