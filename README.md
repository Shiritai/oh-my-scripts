# oh-my-scripts

The scripting tool for container environment build-up development. OH MY SCRIPTS!!!

For (Traditional) Chinese document, please check [this document](./README.zh_TW.md).

Containerization is a great technology. It allows tasks such as building, removing, and migrating identical environments to perform far faster than virtual machines. With it, we can almost instantly deploy services using pre-built images by others.

That being said, for developers providing services, those who build a service or a corresponding ready-to-use container environment, writing a Dockerfile and scripts, followed by `docker build` and then `docker run` to verify the results, and then modifying the `Dockerfile` and repeating the process, is still a tedious, time-consuming, and inelegant.

Is there a way to break the status quo? Is there a tool that can greatly accelerate container development? One that can provide developers with a ready-to-use and easily reusable library of environment templates, allowing them to maximize the advantages of containers? This is the goal of `oh-my-scripts`.

## Usage

### Introduction

Run `run.sh`。

It has many parameters. You can refer to the first half of `run.sh` under the section `Customizable Parameters` for variable settings.

```bash
# ----------- [Customizable Parameters] -----------

BASE_IMG=${BASE_IMG:-"ubuntu:20.04"}
IMG_NAME=${IMG_NAME:-oh-my-c} # oh-my-container

LOCALE=${LOCALE:-$(locale -a | grep -v C | grep -v POSIX | head -n 1)}
TZ=${TZ:-$(timedatectl show | grep -E 'Timezone=' | grep -E -o "[a-zA-Z]+\/[a-zA-Z]+")}

# Systemd support
USE_SYSTEMD=${USE_SYSTEMD:-yes} # yes or no

$USERNAME=${$USERNAME:-$USER} # Username of the container
# Feel free to change user password if needed
USER_PSWD=${USER_PSWD:-"CHANGE_ME"}

USE_GPU=${USE_GPU:-no} # yes or no

# ...

# ----------- [Execution Part] -----------
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

## Roadmap

### Dev tools

* **Establish a testing framework**
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
