# oh-my-scripts

## 懶人包

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

### 例子

如果想

* 建立 image
* 其基於 `osrf/ros:humble-desktop-full`
* 稱為 `oh-my-novnc`
* 支援 Gnome GUI
* 支援 `ssh`、`novnc`
* 僅暴露 ssh port 為 `1234`

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
> 如果想立刻運行容器，請將最後一個參數改成 `OMS_MODE=br`。
>
> 容器名稱預設會和印象名稱相同，可透過 `CONTAINER_NAME` 覆寫。

## 概述

容器化 (Containerization) 是個好東西，它使快速建立、消除、移植相同環境等任務有著遠超於虛擬機的表現，使我們幾乎一瞬間就能利用他人建構好的 image 快速部署服務。

話雖如此，作為提供服務的開發者，即建構某服務或某環境對應之開箱即用容器的開發者而言，撰寫 `Dockerfile` 與腳本，將其 `docker build` 後 `docker run` 來驗證結果，再修改 `Dockerfile` 重複前述過程的循環仍然是個冗長費神且不優雅的過程。

有沒有方法能打破現狀呢？有沒有個工具可以大幅加速容器的開發？能提供開發者一套現成且易於重用的環境模板庫，讓開發者能更大限度地享受容器所帶來的優勢？這便是 `oh-my-scripts` 的目標。

## 用法 Usage

### 介紹 Introduction

執行 `run.sh`。

其有許多參數，可參閱 `run.sh` 前半部 `Customizable Parameters` 做變數的設定。

> [!TIP]
> 可用 `OMS_MODE=d ./run.sh` (dry-run) 顯示所有執行用參數。

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

`run.sh` 會依序:

* 如果需要 `docker build`
  * 準備 build 參數
  * 將 `scripts/<DIR>` 壓縮成 `scripts-<DIR>.zip`
    * `utils`, `common`, `custom` 和 `app` 只會在壓縮檔不存在時壓縮，因假設這裡面的資料不太會變動。若有變動，請刪掉壓縮檔，可使用 `clean.sh` 刪除所有 `scripts-*` 壓縮檔。
    * `dev` 每次需要 `build` 時都會重新壓縮，假設當中的檔案時常變動。
  * 產生 `.dockerignore`
  * `docker build`
  * 刪除產生的 `.dockerignore` 和 `scripts-dev.zip`
* `docker run`
  * 外掛會依照以下順序安裝
    * `core` -> `common` -> `app` -> `custom` -> `dev`

### 放入客製化外掛 Add you own plugins

請將客製化腳本放在 `scripts/custom` 或 `scripts/dev` 中:

> 外掛即含有 `setup.sh` 的資料夾，可參見 `custom` 和 `dev` 底下的 `README.md`。

* `scripts/custom`: 放入您已經開發好的，穩定的外掛
* `scripts/dev`: 放入您正在開發的，不穩定的外掛

當您確認 `scripts/dev` 的某個外掛能穩定運作，可以將其移入 `scripts/custom`，如果已經執行過 `run.sh`，此時請刪除產生的 `scripts-custom.zip`。

## 功能 Features

目前支援下列功能。

### 使用者相關

|功能|參數|預設值|備注|
|:-:|:-:|:-:|:-:|
|user name|`USERNAME`|as current user||
|user password|`USE_USER_PSWD`|no|`USER_PSWD` default to `CHANGE_ME`|

### 核心功能 `core`

|功能|參數|預設值|
|:-:|:-:|:-:|
|locale|`LOCALE`|as host<br>(detect using `locale`)|
|timezone|`TZ`|as host<br>(detect using `timedatectl`)|
|systemd|`USE_SYSTEMD`|yes|

### 基本功能 `common`

基本功能全部可選，預設皆為不使用，以 `USE_` 為前綴的參數預設皆為 `no`。

|功能|參數|可選項|可選項預設值|
|:-:|:-:|:-:|:-:|
|ssh|`USE_SSH`|`SSH_PORT`|22|
|vnc|`USE_VNC`|`VNC_PORT`|5901|
|||`VNC_PSWD`|`vncpswd`|
|noVNC|`USE_NO_VNC`|`NO_VNC_PORT`|6901|
|zsh + oh-my-zsh|`USE_OMZ`|Please provide your `.zshrc`<br>and other zsh related dotfiles<br>and put them into `common/omz`|Dotfiles prefixed with<br>`example` in `common/omz`|
|Nvidia GPU|`USE_GPU`|||
|GUI (Gnome)|`USE_GUI`|||

### 應用程式 `app`

將 `USE_APP` 設為 `yes` 來使用以下應用程式，預設不使用。

若要使用這些軟體，建議將 `USE_GUI` 設為 `yes`，或提供 GUI 對應的腳本至 `custom` 或 `dev`

* Firefox: Linux 上最好用的瀏覽器
* vscode: 好用的 IDE

## 測試

### 新增一個測試

在 `.github/workflows/tests.yml`，我們可以新增一個測試工作如下:

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

如果當中用到的鏡像可受益於其他測試工作，可以考慮將共用的容器建構步驟獨立成一個建構工作，並在測試工作依賴建構工作的運行結果，便能加速測試流程。

* 建構工作

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
  
* 測試工作

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

### 用預先建構好的鏡像

若想進行耗時的測試工作，比如安裝套件耗時的工作，可以考慮使用預先建構的鏡像來加速測試，該鏡像應該只安裝套件而不涉及任何設定。

可以將 `Dockerfile` 放在 `tests/prebuild-scripts/<image_name>/Dockerfile` 並執行 `tests/prebuild-all.sh` 來 ***互動式的*** 建構鏡像。

```bash
> <REPO>/scripts/run-with-utils.sh <REPO>/tests/prebuild-all.sh
[INFO] Checking <...>/oh-my-scripts/tests for Dockerfile
[INFO] Checking <...>/oh-my-scripts/tests/prebuild-scripts for Dockerfile
[INFO] Checking <...>/oh-my-scripts/tests/prebuild-scripts/gnome-vnc for Dockerfile
[INFO] Find Dockerfile in gnome-vnc, do you want to build this image? [y/N]
<PLEASE ANSWER THIS QUESTION FOR ALL THE IMAGES [y/N]>
```

> [!NOTE]
> 請注意 `<REPO>/tests/prebuild-all.sh` 會用到 `<REPO>/scripts/utils` 定義的函式。

接著便能將鏡像標記並上傳，以上面的 `gnome-vnc` 為例:

```bash
docker image tag oh-my-scripts:gnome-vnc <DOCKER_HUB_USER>/oh-my-scripts:gnome-vnc
docker push <DOCKER_HUB_USER>/oh-my-scripts:gnome-vnc
```

> [!IMPORTANT]
> 請通知[我](https://github.com/Shiritai) (shingekinocore@gmail.com) 您想用我的鏡像遠端或直接用您的遠端.

## 未來目標 Roadmap

### 開發輔助 Dev tools

* 容器運行後執行之命令的自動記錄 (命令 - 結果)，並進一步自動腳本化
* 容器的建構平行化: 支援同時建立多個容器，其建構時的的差異只有一小部分，對這些差異和對應的容器建立 pair 來追蹤，方便開發者快速嘗試多種 build 的 image

### 客製化輔助 Customize tools

* 將參數指派做成互動式 / 非互動式的設定檔
* 新 `common` plugins
  * `audio` 使 noVNC 能支援音訊傳輸
  * `wine` 使容器支援運行 windows 相容程式
* 支援更多 Linux distributions
  * Ubuntu (current)
  * Arch Linux (support)
  * Alpine Linux
