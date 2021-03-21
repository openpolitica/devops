# Docker image to connect to MySQL database

There is an official image for mysql-server in docker, but unfortunately I
couldn't find a suitable image for client of mysql. There is a client located
at https://github.com/s83/docker-mysql-client. However, it doesn't
provide `mysql_config_editor`, which is used in our scripts.

To build this image you could use the following command:
```bash
docker build -t <user>/mysql-client:latest -f Dockerfile .
```

Then, to use with the scripts provided here, you could employ the following
command:
```bash
docker run --rm -it --name mysql1 --mount type=bind,source="$(pwd)",target=/home --entrypoint=/bin/bash --env MYSQL_HOST=<hostname>
--env MYSQL_PWD=<password> --env MYSQL_TCP_PORT=3306 luighiv/mysql-client:latest
```

You could run in the folder where are the scripts, in the way they could be
accesible from the container and use the commands for script.
