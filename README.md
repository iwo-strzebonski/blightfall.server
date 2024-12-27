# Blightfall Server

## How to run the server

```bash
docker run -dp 25565:25565 -dp 8123:8123 -dp [your_name]/blightfall_server
docker run -dp 25565:25565 -dp 8123:8123 -dp 25575:25575 [your_name]/blightfall_server # with rcon
docker run -dp 25565:25565 -dp 8123:8123 --mount source=<volume_name>,destination=/usr/games/minecraft/server/world [your_name]/blightfall_server # with volume
```

## How to build the server image

```bash
docker build . -t [your_name]/blightfall_server --build-arg EULA=true --build-arg MODPACK_VERSION=[modpack_version]
```

## How to publish the server image

```bash
docker push [your_name]/blightfall_server
```

## How to add a tag to the server image

```bash
docker tag [your_name]/blightfall_server:latest [your_name]/blightfall_server:[tag]
```

## How to check available volumes

```bash
docker volume ls
```

## How to add an operator

### Old way
```bash
docker container ls
docker exec -it <container_id> /bin/bash
echo '[{"uuid":"<uid>","name":"<name>","level":4}]' > ops.json
exit
docker restart <container_id>
```

### New way (using rcon)
```bash
docker run -it --rm --network container:<container_id> --entrypoint /bin/bash [your_name]/blightfall_server
```
