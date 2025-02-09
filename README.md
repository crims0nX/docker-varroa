# Varroa docker image

A docker container for the [varroa](https://gitlab.com/passelecasque/varroa) musica tool.

>[!NOTE]
>Adaption of [linuxserver/syncthing](https://github.com/linuxserver/docker-syncthing). Credits to the [LinuxServer.io](https://linuxserver.io) team.

## Usage

To help you get started creating a container from this image you can either use docker-compose or the docker cli.

>[!NOTE]
>Unless a parameter is flaged as 'optional', it is *mandatory* and a value must be provided.

### docker-compose (recommended)

```yaml
---
services:
  varroa:
    image: crimsonhub/varroa:latest
    container_name: varroa
    hostname: varroa #optional
    environment:
      - PUID=1000
      - PGID=1000
      - UMASK=022
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
docker run --name varroa --rm -d \
  -e PUID=1000 \
  -e PGID=1000 \
  -e UMASK=022 \
  -e TZ=Etc/UTC \
  -p 19080:19080 \
  -p 19081:19081 \
  -v $(pwd)/config:/config \
  -v $(pwd)/watch:/watch \
  -v $(pwd)/downloads:/downloads \
  -v $(pwd)/library:/library \
  crimsonhub/varroa:latest
```

### Building locally

If you want to make local modifications to these images for development purposes or just to customize the logic:

* Clone and cd into the repository:

```bash
git clone https://github.com/crimsonhub/docker-varroa
cd docker-varroa
```

* Run:

```bash
docker build --no-cache --progress=plain -t crimsonhub/varroa .
```

> The ARM variants can be built on x86_64 hardware and vice versa using `lscr.io/linuxserver/qemu-static`
> 
> ```bash
> docker run --rm --privileged lscr.io/linuxserver/qemu-static --reset
> ```
> 
> Once registered you can define the dockerfile to use with `-f Dockerfile.aarch64`.


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
