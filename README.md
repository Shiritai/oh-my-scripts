# oh-my-scripts

> [!NOTE]
> For Chinese document, please check [this document (中文文檔).](./README.zh_TW.md)

## TL;DR

```bash
> OMS_MODE=h ./run.sh
oh-my-scripts:
    The scripting tool for container environment build-up development. OH MY SCRIPTS!!!

Usage: OMS_MODE=<MODE_FLAGs> [ARG=VALUE]... ./run.sh

Possible <MODE_FLAGs>:
    b: build image
    r: run container
    br: build image and run container
    d: dry-run mode, will only shows all the arguments in json form without conducting any real sction
    h: print this help message and exit

For all possible [ARG=VALUE]s, please refer to the parameter part of this scripts
```

### Quick Examples

If we want to

* build a image
* based on `osrf/ros:humble-desktop-full`
* named `oh-my-novnc`
* with Gnome GUI support
* with `ssh` and `novnc` support
* with ssh port exposed on `1234`

```bash
BASE_IMG=osrf/ros:humble-desktop-full \
IMG_NAME=oh-my-novnc \
USE_SSH=yes \
SSH_PORT=1234 \
USE_USER_PWSD=yes \ # optional for ssh login
USER_PSWD=<YOUR_PASSWORD> \ # default to "CHANGE_ME"
USE_GUI=yes \ # will install the minimal Gnome GUI for us
USE_NO_VNC=yes \ # for port exposure, please assign `NO_VNC_PORT`
VNC_PSWD=<VNC_LOGIN_PASSWORD> \ # optional, default to "vnc_pswd"
OMS_MODE=b ./run.sh
```

> [!TIP]
> If we want to run the image immediately, change the last argument to `OMS_MODE=br`.
>
> The container name will default to the image name, or you can set `CONTAINER_NAME` to overwrite it.

## Abstract

Containerization is a great technology. It allows tasks such as building, removing, and migrating identical environments to perform far faster than virtual machines. With it, we can almost instantly deploy services using pre-built images by others.

That being said, for developers providing services, those who build a service or a corresponding ready-to-use container environment, writing a Dockerfile and scripts, followed by `docker build` and then `docker run` to verify the results, and then modifying the `Dockerfile` and repeating the process, is still a tedious, time-consuming, and inelegant.

Is there a way to break the status quo? Is there a tool that can greatly accelerate container development? One that can provide developers with a ready-to-use and easily reusable library of environment templates, allowing them to maximize the advantages of containers? This is the goal of `oh-my-scripts`.

## Usage

### Introduction

Run `run.sh`。

It has many parameters. You can refer to the first half of `run.sh` under the section `Customizable Parameters` for variable settings.

> [!TIP]
> You can use `OMS_MODE=d ./run.sh` (dry-run) to show the arguments for execution.

```bash
# ----------- [Customizable Parameters] -----------

BASE_IMG=${BASE_IMG:-'ubuntu:20.04'}
IMG_NAME=${IMG_NAME:-'oh-my-c'}
CONTAINER_NAME=${CONTAINER_NAME:-IMG_NAME}

LOCALE=${LOCALE:-$((locale -a | grep -v C | grep -v POSIX | head -n 1) || echo '')}
TZ=${TZ:-$(timedatectl show | grep -E 'Timezone=' | grep -E -o '[a-zA-Z]+\/[a-zA-Z]+' 2>/dev/null || echo "")}

# Systemd support
USE_SYSTEMD=${USE_SYSTEMD:-'yes'} # yes or no

# Username of the container
USERNAME=${USERNAME:-$USER}

# ...

# ----------- [Util Part] -----------
```

`run.sh` will:

* If `docker build` is needed
  * Prepare building arguments
  * Zip `scripts/<DIR>` to `scripts-<DIR>.zip`
    * `utils`, `common`, `custom` and `app` will only be zipped when the corresponding zip file does not present. If there is any change to these part, please delete the corresponding zip file or run `clean.sh` to remove them.
    * `dev` will re-zip anytime, files inside it are considered to be changed frequently
  * Generate `.dockerignore`
  * `docker build`
  * Remove generated `.dockerignore`, `scripts-dev.zip`
* if `docker run` is needed, run it
  * Plugins will be installed with the following order
    * `core` -> `common` -> `app` -> `custom` -> `dev`

### Add you own plugins

Please put your plugin scripts to `scripts/custom` or `scripts/dev`.

> Def of plugin: directory in which `setup.sh` presents, see `README.md` in `custom` or `dev` for more info.

* `scripts/custom`: stable container plugins
* `scripts/dev`: unstable container plugins

When some plugin in `scripts/dev` is tested to be stable, feel free to put them into `scripts/custom` and remove generated `scripts-custom.zip`.

## Features

Currently, the following features are supported.

### User related

|Features|Argument|Default|p.s.|
|:-:|:-:|:-:|:-:|
|user name|`USERNAME`|as current user||
|user password|`USE_USER_PSWD`|no|`USER_PSWD` default to `CHANGE_ME`|

### `core`

|Features|Argument|Default|
|:-:|:-:|:-:|
|locale|`LOCALE`|as host<br>(detect using `locale`)|
|timezone|`TZ`|as host<br>(detect using `timedatectl`)|
|systemd|`USE_SYSTEMD`|yes|

### `common`

All basic features are optional and disabled by default. Parameters prefixed with `USE_` are set to `no` by default.

|Features|Argument|optional argument|default value of<br>optional argument|
|:-:|:-:|:-:|:-:|
|ssh|`USE_SSH`|`SSH_PORT`|22|
|vnc|`USE_VNC`|`VNC_PORT`|5901|
|||`VNC_PSWD`|`vncpswd`|
|noVNC|`USE_NO_VNC`|`NO_VNC_PORT`|6901|
|zsh + oh-my-zsh|`USE_OMZ`|Please provide your `.zshrc`<br>and other zsh related dotfiles<br>and put them into `common/omz`|Dotfiles prefixed with<br>`example` in `common/omz`|
|Nvidia GPU|`USE_GPU`|||
|GUI (Gnome)|`USE_GUI`|||

### `app`

Set `USE_APP` to `yes` to use the following applications, which are disabled (set to `no`) by default.

If you want to use these software applications, it is recommended to set `USE_GUI` to `yes`, or provide the corresponding GUI scripts to the `custom` or `dev` directories.

* Firefox: best browser on Linux
* vscode: handy IDE

## Test

### Add a new test

In `.github/workflows/tests.yml`, we can add a simplest test job like:

```yaml
simple-test:

  runs-on: ubuntu-latest

  steps:
  - uses: actions/checkout@v4

  - name: Build and run image
    run: OMS_MODE=br IMG_NAME=... ... ${{ github.workspace }}/run.sh

  - name: Check build result A
    run: docker exec ..., docker ps | grep ..., or else

  - name: Check build result B
    run: docker exec ..., docker ps | grep ..., or else
  
  ...
```

If the image you use can be benefit by other builds, you can then first upload the built image as artifact and download them in the other jobs to speedup test suite.

* Build job

  ```yaml
  build-simple-image:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4
      
      - name: Build image
        run: |
          OMS_MODE=b IMG_NAME=<ARTIFACT_NAME> ... ${{ github.workspace }}/run.sh
      
      - name: Export image
        run: |
          docker save <ARTIFACT_NAME> > <ARTIFACT_NAME>.tar
          cp <ARTIFACT_NAME>.tar /tmp/<ARTIFACT_NAME>.tar
      
      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: <ARTIFACT_NAME>
          path: /tmp/<ARTIFACT_NAME>.tar
  ```
  
* Job that use built image

  ```yaml
  simple-test:

    runs-on: ubuntu-latest
    needs: [build-simple-image]
    if: ${{ needs.build-simple-image.result == 'success' }}

    steps:
    - uses: actions/checkout@v4
    
    - name: Download artifact
      uses: actions/download-artifact@v4
      with:
        name: <ARTIFACT_NAME>
        path: /tmp
    
    - name: Load image
      run: |
        docker load --input /tmp/<ARTIFACT_NAME>.tar
        docker image ls -a

    - name: Build and run image
      run: |
        OMS_MODE=br IMG_NAME=<ARTIFACT_NAME> ... ${{ github.workspace }}/run.sh
  ```

### Pre-builds

To conduct unit or integration test on some new `core`/`common` plugin, which the build time may consume so much time, we can take the advantage of prebuild image that install and only install packages we need without further configurations.

We can put the `Dockerfile` into `tests/prebuild-scripts/<image_name>/Dockerfile` and run `tests/prebuild-all.sh` to build all images ***INTERACTIVELY***.

```bash
> <REPO>/scripts/run-with-utils.sh <REPO>/tests/prebuild-all.sh
[INFO] Checking <...>/oh-my-scripts/tests for Dockerfile
[INFO] Checking <...>/oh-my-scripts/tests/prebuild-scripts for Dockerfile
[INFO] Checking <...>/oh-my-scripts/tests/prebuild-scripts/gnome-vnc for Dockerfile
[INFO] Find Dockerfile in gnome-vnc, do you want to build this image? [y/N]
<PLEASE ANSWER THIS QUESTION FOR ALL THE IMAGES [y/N]>
```

> [!NOTE]
> Note that `<REPO>/tests/prebuild-all.sh` also use functions defined in `<REPO>/scripts/utils`.

Then you can mark the image to be uploadable and upload to docker hub. For example, the `gnome-vnc` image:

```bash
docker image tag oh-my-scripts:gnome-vnc <DOCKER_HUB_USER>/oh-my-scripts:gnome-vnc
docker push <DOCKER_HUB_USER>/oh-my-scripts:gnome-vnc
```

> [!IMPORTANT]
> Please let [me](https://github.com/Shiritai) (shingekinocore@gmail.com) know you want to use my remote image repo or you can just use your own remote.

## Roadmap

### Dev tools

* Automatically record the commands executed after the container is running (commands - results), and further automate the scripting process
* Parallelize container building: support the simultaneous creation of multiple containers with only minor differences in their construction. Track these differences and their corresponding containers as pairs, making it easier for developers to quickly experiment with various built images.

### Customize tools

* Make parameter assignments into interactive/non-interactive configuration files
* New `common` plugins
  * `audio` to make noVNC supports audio streaming
  * `wine` run windows compatible program
* Support more Linux distributions
  * Ubuntu (current)
  * Arch Linux (support)
  * Alpine Linux
