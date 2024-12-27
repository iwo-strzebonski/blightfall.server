# Blightfall Server

## How to run the server

```bash
docker run -dp 25565:25565 -dp 8123:8123 -dp $YOUR_NAME/blightfall_server

docker run -dp 25565:25565 -dp 8123:8123 -dp 25575:25575 $YOUR_NAME/blightfall_server # with rcon

docker run -dp 25565:25565 -dp 8123:8123 --mount source=$VOLUME_NAME,destination=/usr/games/minecraft/server/world $YOUR_NAME/blightfall_server # with already existing volume
```

## How to build the server image

```bash
docker build . -t $YOUR_NAME/blightfall_server --build-arg EULA=true --build-arg MODPACK_VERSION=$MODPACK_VERSION
```

## How to publish the server image

```bash
docker push $YOUR_NAME/blightfall_server
```

## How to add a tag to the server image

```bash
docker tag $YOUR_NAME/blightfall_server:latest $YOUR_NAME/blightfall_server:$VERSION
```

## How to check available volumes

```bash
docker volume ls
```

## How to add an operator

### Old way
```bash
export CONTAINER_ID=$(docker container ls --filter=ancestor=$YOUR_NAME/blightfall_server -q | head -n1)
export RCON_PASSWORD=$(docker exec -it $CONTAINER_ID cat /usr/games/minecraft/server/server.properties | grep rcon.password | cut -d'=' -f2)

docker container ls
docker exec -it $CONTAINER_ID bash
echo '[{"uuid":"<uid>","name":"<name>","level":4}]' > ops.json
exit
docker restart $CONTAINER_ID
```

### New way (using rcon)
```bash
export CONTAINER_ID=$(docker container ls --filter=ancestor=$YOUR_NAME/blightfall_server -q | head -n1)
export RCON_PASSWORD=$(docker exec -it $CONTAINER_ID cat /usr/games/minecraft/server/server.properties | grep rcon.password | cut -d'=' -f2 | sed 's/\r$//')

docker exec -it $CONTAINER_ID mcrcon -p $RCON_PASSWORD "op <name>"
```
