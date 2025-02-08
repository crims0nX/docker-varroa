# Varroa docker image

A docker container for the [varroa](https://gitlab.com/passelecasque/varroa) musica tool.

>[!NOTE]
>Adaption of [linuxserver/syncthing](https://github.com/linuxserver/docker-syncthing). Credits for the [LinuxServer.io](https://linuxserver.io) team.

## Usage

To help you get started creating a container from this image you can either use docker-compose or the docker cli.

>[!NOTE]
>Unless a parameter is flaged as 'optional', it is *mandatory* and a value must be provided.

### docker-compose (recommended)

```yaml
---
services:
  varroa:
    image: <img_url>/varroa:latest
    container_name: varroa
    hostname: varroa #optional
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
    volumes:
      - /path/to/varroa/config:/config
      - /path/to/data1:/data1
      - /path/to/data2:/data2
    ports:
      - 19080:19080
      - 19081:19081
    restart: unless-stopped
```

### docker cli

```bash
docker run -d \
  --name=varroa \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Etc/UTC \
  -p 19080:19080 \
  -p 19081:19081 \
  -v /path/to/varroa/config:/config \
  -v /path/to/data1:/data1 \
  -v /path/to/data2:/data2 \
  --restart unless-stopped \
  <img_url>/varroa:latest
```

## Parameters

Containers are configured using parameters passed at runtime (such as those above). These parameters are separated by a colon and indicate `<external>:<internal>` respectively. For example, `-p 8080:80` would expose port `80` from inside the container to be accessible from the host's IP on port `8080` outside the container.

| Parameter | Function |
| :----: | --- |
| `-p 19080:19080` | Webserver HTTPS  |
| `-p 19081:19081` | Webserver HTTP   |
| `-e PUID=1000` | for UserID - see below for explanation |
| `-e PGID=1000` | for GroupID - see below for explanation |
| `-e TZ=Etc/UTC` | specify a timezone to use, see this [list](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List). |
| `-v /config` | Configuration files. |
| `-v /data1` | Data1 |
| `-v /data2` | Data2 |

## Environment variables from files (Docker secrets)

You can set any environment variable from a file by using a special prepend `FILE__`.

As an example:

```bash
-e FILE__MYVAR=/run/secrets/mysecretvariable
```

Will set the environment variable `MYVAR` based on the contents of the `/run/secrets/mysecretvariable` file.

## Umask for running applications

For all of our images we provide the ability to override the default umask settings for services started within the containers using the optional `-e UMASK=022` setting.
Keep in mind umask is not chmod it subtracts from permissions based on it's value it does not add. Please read up [here](https://en.wikipedia.org/wiki/Umask) before asking for support.

## User / Group Identifiers

When using volumes (`-v` flags), permissions issues can arise between the host OS and the container, we avoid this issue by allowing you to specify the user `PUID` and group `PGID`.

Ensure any volume directories on the host are owned by the same user you specify and any permissions issues will vanish like magic.

In this instance `PUID=1000` and `PGID=1000`, to find yours use `id your_user` as below:

```bash
id your_user
```

Example output:

```text
uid=1000(your_user) gid=1000(your_user) groups=1000(your_user)
```

## Docker Mods

The container should work with [linuxserver.io's docker mods](https://mods.linuxserver.io/?mod=universal "view available universal mods.")

[Docker Mods](https://github.com/linuxserver/docker-mods) enables additional functionality within the containers. The list of Mods available for this image (if any) as well as universal mods that can be applied to any one of our images can be accessed via the dynamic badges above.

## Support Info

* Shell access whilst the container is running:

    ```bash
    docker exec -it varroa /bin/bash
    ```

* To monitor the logs of the container in realtime:

    ```bash
    docker logs -f varroa
    ```

* Container version number:

    ```bash
    docker inspect -f '{{ index .Config.Labels "build_version" }}' varroa
    ```

<!-- * Image version number:

    ```bash
    docker inspect -f '{{ index .Config.Labels "build_version" }}' <img_url>/varroa:latest
    ``` -->

## Updating Info

Below are the instructions for updating containers:

### Via Docker Compose

* Update images:
  * All images:

        ```bash
        docker-compose pull
        ```

  * Single image:

        ```bash
        docker-compose pull varroa
        ```

* Update containers:
  * All containers:

        ```bash
        docker-compose up -d
        ```

  * Single container:

        ```bash
        docker-compose up -d varroa
        ```

* You can also remove the old dangling images:

    ```bash
    docker image prune
    ```

### Via Docker Run

* Update the image:

    ```bash
    docker pull lscr.io/linuxserver/varroa:latest
    ```

* Stop the running container:

    ```bash
    docker stop varroa
    ```

* Delete the container:

    ```bash
    docker rm varroa
    ```

* Recreate a new container with the same docker run parameters as instructed above (if mapped correctly to a host folder, your `/config` folder and settings will be preserved)
* You can also remove the old dangling images:

    ```bash
    docker image prune
    ```

### Image Update Notifications - Diun (Docker Image Update Notifier)

>[!TIP]
>We recommend [Diun](https://crazymax.dev/diun/) for update notifications. Other tools that automatically update containers unattended are not recommended or supported.

## Run locally

```bash
docker run --name varroa --rm -d \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Etc/UTC \
  -p 19080:19080 \
  -p 19081:19081 \
  -v $(pwd)/config:/config \
  -v $(pwd)/watch:/watch \
  -v $(pwd)/downloads:/downloads \
  -v $(pwd)/library:/library \
  crims0nX/varroa
```

## Building locally

If you want to make local modifications to these images for development purposes or just to customize the logic:

* Clone and cd into the repository:

```bash
git clone https://github.com/crims0nX/docker-varroa
cd docker-varroa
```

* Run:

```bash
docker build --no-cache --progress=plain -t crims0nX/varroa .
```

The ARM variants can be built on x86_64 hardware and vice versa using `lscr.io/linuxserver/qemu-static`

```bash
docker run --rm --privileged lscr.io/linuxserver/qemu-static --reset
```

Once registered you can define the dockerfile to use with `-f Dockerfile.aarch64`.
