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
      - 9080:9080
      - 9081:9081
    restart: unless-stopped
```

### docker cli

```bash
docker run -d \
  --name=varroa \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Etc/UTC \
  - 9080:9080 \
  - 9081:9081 \
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
| `-p 9080:9080` | Webserver HTTPS  |
| `-p 9081:9081` | Webserver HTTP   |
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

## Building locally

If you want to make local modifications to these images for development purposes or just to customize the logic:

```bash
git clone https://github.com/crims0nX/docker-varroa
cd docker-varroa
docker build \
  --no-cache \
  --pull \
  -t <img_url>/varroa:latest .
```

The ARM variants can be built on x86_64 hardware and vice versa using `lscr.io/linuxserver/qemu-static`

```bash
docker run --rm --privileged lscr.io/linuxserver/qemu-static --reset
```

Once registered you can define the dockerfile to use with `-f Dockerfile.aarch64`.

## Versions

* **06.06.24:** - Rebase to Alpine 3.20.
* **05.03.24:** - Rebase to Alpine 3.19.
* **05.09.23:** - Rebase to Alpine 3.18.
* **01.07.23:** - Deprecate armhf. As announced [here](https://www.linuxserver.io/blog/a-farewell-to-arm-hf)
* **13.02.23:** - Rebase to Alpine 3.17, migrate to s6v3.
* **17.08.22:** - Build on alpine 3.16 for go 1.18).
* **03.05.22:** - Rebase to alpine 3.15 (builds on edge for go 1.18).
* **05.10.21:** - Rebase to alpine 3.14.
* **12.05.21:** - Remove sysctl parameter again
* **03.05.21:** - Raise maximum UDP buffer size.
* **03.05.21:** - Add port mapping for 22000/udp.
* **29.01.21:** - Deprecate `UMASK_SET` in favor of UMASK in baseimage, see above for more information.
* **23.01.21:** - Rebasing to alpine 3.13.
* **15.09.20:** - Use go from alpine edge repo to compile. Remove duplicate UMASK env var. Add hostname setting.
* **01.06.20:** - Rebasing to alpine 3.12.
* **19.12.19:** - Rebasing to alpine 3.11.
* **28.06.19:** - Rebasing to alpine 3.10.
* **23.03.19:** - Switching to new Base images, shift to arm32v7 tag.
* **05.03.19:** - Update Build process for v1.1.0 release.
* **22.02.19:** - Rebasing to alpine 3.9.
* **16.01.19:** - Add pipeline logic and multi arch.
* **30.07.18:** - Rebase to alpine 3.8 and use buildstage.
* **13.12.17:** - Rebase to alpine 3.7.
* **25.10.17:** - Add env for manual setting of umask.
* **29.07.17:** - Simplify build structure as symlinks failing on > 0.14.32
* **28.05.17:** - Rebase to alpine 3.6.
* **08.02.17:** - Rebase to alpine 3.5.
* **01.11.16:** - Switch to compiling latest version from git source.
* **14.10.16:** - Add version layer information.
* **30.09.16:** - Fix umask.
* **09.09.16:** - Add layer badges to README.
* **28.08.16:** - Add badges to README.
* **11.08.16:** - Rebase to alpine linux.
* **18.12.15:** - Initial testing / release (IronicBadger)
* **24.09.15:** - Inital dev complete (Lonix)
