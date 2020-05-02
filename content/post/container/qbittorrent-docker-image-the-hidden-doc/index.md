---
title: "qbittorrent docker镜像：简介里没有说明的部分"
date: 2020-05-02T19:08:27+08:00
tags:
  - old-site
---

> 原文由 @也无荒野也无灯 发表于 2019-07-17 16:00

> 原文地址（已经不可访问): `http://nanodm.net:8092/archives/30/`

hub 页面 https://hub.docker.com/r/80x86/qbittorrent 我做了一些简单的使用说明。

但是其实对于想更好地使用这个镜像的人来说，还有很多东西，我在那个页面里没有写。

阅读此文前，建议先看完[《小钢炮使用docker版qb 4.1.6 简明教程》][1]http://nanodm.net:8092/archives/43/

20190720更新：
1. 增加了PUID和PGID环境变量定义uid和gid, 不再支持使用--user uid:gid的方式
2.以前下载的种子的目录，没有必要修复和移动,直接用-v作同路径映射即可.

```
-v /media/foo/movie:/media/foo/movie \
-v /media/bar/movie:/media/bar/movie
```

目录映射
====

容器默认设定了3个volume,分别是：
`/config` : qBittorrent 配置文件保存目录
`/data`: qBittorrent 数据保存目录(包括用于保存种子的BT_backup目录，日志目录等)
`/downloads`: 这个是下载文件保存目录

前面两个目录，在WEB UI是没有地方可以配置的，因此不存在任何问题。
`/downloads` 这个目录，这里要说一下，对于容器来说，这个目录是固定的。
因此，你不能也不需要在WEB UI里修改这个默认配置的路径。

不需要的原因是，这个目录我们其实是可以通过docker来映射到实体机的真实目录，就像这样：
![2019-07-17_16-04.png][2]

不能的原因是，为了防止有人修改这个配置，我实际上在docker容器中做了特殊处理，每次容器启动，这个配置都会还原成默认的
`/downloads`

env个性化配置
=====

`WEB_PORT`： Web UI的端口，默认是8080，因此打开UI的URL就是：`http://IP:8080/`
`BT_PORT`： 这个是BT的传入端口,默认为8999（一般建议修改成非常规端口，有些PT程序会禁止某此常用端口），
做种的时候，别人连接你就靠它了
`HOME`: qb 运行用户的家目录，这个实际上是config和data目录的父目录，一般来说不需要修改.

容器网络的选择
=======

docker实际上提供了多种不同的网络配置，最常见的就是host网络和bridge网络了。

**bridge网络**

这种形式的网络也是docker所推荐的。
创建容器的时候，如果没有特别指定，那么就默认为bridge网络。
也就是说，在不指定--network参数或者--network=bridge的情况下创建的容器其网络类型都是bridge。
在容器里，loopback地址指向的是容器自己，如果要访问host机，则需要通过docker0的IP，或host机的其它IP。

Docker在安装时会在宿主机上创建名为docker0的网桥，容器和docker0之间通过veth进行连接。
使用这种形式的网络，如果容器里的端口要允许从外面访问，则需要用-v参数暴露出来。
这里的端口映射，在Linux上面具体的实现，实际上就是通过iptables 做了基于端口的DNAT，具体的规则，可以用
`sudo iptables -L DOCKER -n -t nat` 来查看.

这里还需要注意的是，对于有公网IP的用户来说，qb的端口，在这种模式时，一定要在路由器上手动做端口映射。
因为bridge网络下面，qb 自身的UPNP功能无法正常工作。

适用于小钢炮的创建容器脚本：
```shell
IMAGE_NAME=80x86/qbittorrent
WEB_PORT=$(nvram get app.qb.listen_port)
DOWNLOAD_PATH=$(cat /var/lib/qbittorrent/.config/qBittorrent/qBittorrent.conf | grep -i 'Downloads\\SavePath' | cut -d'=' -f2)
BT_PORT=$(cat /var/lib/qbittorrent/.config/qBittorrent/qBittorrent.conf | grep -i 'Connection\\PortRangeMin' | cut -d'=' -f2)
QBT_AUTH_SERVER_ADDR=$(ip -4 addr show docker0 | grep inet | awk '{print $2}' | cut -d'/' -f1)
if [ "$DOWNLOAD_PATH" = "/downloads" ] || [ "$DOWNLOAD_PATH" = "/downloads/" ]; then
    echo "please set correct DOWNLOAD_PATH"
    exit -1
fi
docker run -d --name qbittorrent \
        -e PUID=$(id -u qbittorrent) \
        -e PGID=$(cat /etc/group | grep -e '^users' | cut -d':' -f3) \
        -e WEB_PORT=$WEB_PORT \
        -e BT_PORT=$BT_PORT \
        -e QBT_AUTH_SERVER_ADDR=$QBT_AUTH_SERVER_ADDR \
        --restart unless-stopped \
        -p $WEB_PORT:$WEB_PORT -p $BT_PORT:$BT_PORT/tcp -p $BT_PORT:$BT_PORT/udp \
        -v /var/lib/qbittorrent/.config/qBittorrent:/config \
        -v /var/lib/qbittorrent/.local/share/data/qBittorrent:/data \
        -v "$DOWNLOAD_PATH":/downloads \
        --mount type=tmpfs,destination=/tmp \
        ${IMAGE_NAME}
```

对于其它环境，一个更通用的脚本应该像这样：
```shell
# 配置开始
WEB_PORT=指定web端口
DOWNLOAD_PATH="指定下载目录"
BT_PORT=指定bt端口
CFG_PATH="指定配置保存目录"
DATA_PATH="指定数据保存目录"
RUN_USER="qbittorrent"
# 配置结束

IMAGE_NAME=80x86/qbittorrent
QBT_AUTH_SERVER_ADDR=$(ip -4 addr show docker0 | grep inet | awk '{print $2}' | cut -d'/' -f1)
docker run -d --name qbittorrent \
        -e PUID=$(id -u $RUN_USER) \
        -e PGID=$(id -g $RUN_USER) \
        -e WEB_PORT=$WEB_PORT \
        -e BT_PORT=$BT_PORT \
        -e QBT_AUTH_SERVER_ADDR=$QBT_AUTH_SERVER_ADDR \
        --restart unless-stopped \
        -p $WEB_PORT:$WEB_PORT -p $BT_PORT:$BT_PORT/tcp -p $BT_PORT:$BT_PORT/udp \
        -v "$CFG_PATH":/config \
        -v "$DATA_PATH":/data \
        -v "$DOWNLOAD_PATH":/downloads \
        --mount type=tmpfs,destination=/tmp \
        ${IMAGE_NAME}
```

**host网络**

在容器中可以看到host的所有网卡，并且连hostname也是host的。
在容器里，loopback地址指向的是容器自己，同时，也是host机。
如果qb容器以这种网络来运行，则不需要再用-v参数暴露端口，因为此时，qb是直接监听了host机的网卡。
由于减少了中转，因此，开销肯定会小一些，从性能上来说，是会稍好一点的。
根据我们具体的需求，其实用这种模式也可以的。

具体到小钢炮上面，如果要让qb跑在host网络下，可以这样：
```shell
IMAGE_NAME=80x86/qbittorrent
WEB_PORT=$(nvram get app.qb.listen_port)
DOWNLOAD_PATH=$(cat /var/lib/qbittorrent/.config/qBittorrent/qBittorrent.conf | grep -i 'Downloads\\SavePath' | cut -d'=' -f2)
BT_PORT=$(cat /var/lib/qbittorrent/.config/qBittorrent/qBittorrent.conf | grep -i 'Connection\\PortRangeMin' | cut -d'=' -f2)
QBT_AUTH_SERVER_ADDR="127.0.0.1"
if [ "$DOWNLOAD_PATH" = "/downloads" ] || [ "$DOWNLOAD_PATH" = "/downloads/" ]; then
    echo "please set correct DOWNLOAD_PATH"
    exit -1
fi
docker run -d --name qbittorrent \
        -e PUID=$(id -u qbittorrent) \
        -e PGID=$(cat /etc/group | grep -e '^users' | cut -d':' -f3) \
        -e WEB_PORT=$WEB_PORT \
        -e BT_PORT=$BT_PORT \
        -e QBT_AUTH_SERVER_ADDR=$QBT_AUTH_SERVER_ADDR \
        --restart unless-stopped \
        --network host \
        -v /var/lib/qbittorrent/.config/qBittorrent:/config \
        -v /var/lib/qbittorrent/.local/share/data/qBittorrent:/data \
        -v "$DOWNLOAD_PATH":/downloads \
        --mount type=tmpfs,destination=/tmp \
        ${IMAGE_NAME}
```

当然，上面这个脚本是适用于小钢炮的，可以自动取原来的配置文件启动docker,
对于其它机器，一个更通用的脚本大概如下：

```shell
# 配置开始
WEB_PORT=指定web端口
DOWNLOAD_PATH="指定下载目录"
BT_PORT=指定bt端口
CFG_PATH="指定配置保存目录"
DATA_PATH="指定数据保存目录"
RUN_USER="qbittorrent"
# 配置结束

IMAGE_NAME=80x86/qbittorrent
QBT_AUTH_SERVER_ADDR="127.0.0.1"
docker run -d --name qbittorrent \
        -e PUID=$(id -u $RUN_USER) \
        -e PGID=$(id -g $RUN_USER) \
        -e WEB_PORT=$WEB_PORT \
        -e BT_PORT=$BT_PORT \
        -e QBT_AUTH_SERVER_ADDR=$QBT_AUTH_SERVER_ADDR \
        --restart unless-stopped \
        --network host \
        -v "$CFG_PATH":/config \
        -v "$DATA_PATH":/data \
        -v "$DOWNLOAD_PATH":/downloads \
        --mount type=tmpfs,destination=/tmp \
        ${IMAGE_NAME}
```

Tips:
如果要以当前用户身份来跑容器，直接指定 `-e PUID=$UID 和 -e PGID=$GID` 即可.

如果增加目录绑定？
[小钢炮使用docker版qb 4.1.6 简明教程][3] 中有说明需要额外的绑定的情况，那么怎么添加？
最简单的时候用docker run创建容器时用`-v`参数指定。
或者在UI界面增加也是可以的，像这样：

![same-path-map-for-old-tr-2019-07-20_15-09.png][7]


-------------------------------------------------------------------------------

打命令太麻烦了？
========

你也可以通过UI来建立容器，但是你会发现，TNND 用UI工具弄起来居然比用命令还要麻烦。


对于一台支持docker的机器, 假设我们有规划如下的配置：
```
web端口 8084
bt端口  8999
下载目录  /media/10t/movie
配置保存目录 /media/10t/qb/config
数据保存目录 /media/10t/qb/data
用户id/gid：1007
```

step 1. 首先是填写镜像名称：`80x86/qbittorrent`
容器名称自己随意指定，然后绑定端口（仅bridge网络时需要）：
![qb-net-2019-07-17_16-43.png][5]

step 2. 指定 用户id/gid （更新：这一步已经合并到第5步）

step 3. 目录映射
对于小钢炮来说，一般像这样(上面两个路径是固定的，只有/downloads的映射是自定义)：
`/config` => `/var/lib/qbittorrent/.config/qBittorrent`
`/data`  =>  `/var/lib/qbittorrent/.local/share/data/qBittorrent`
`/downloads` 根据自己的情况填写
![xgp-2019-07-17_16-45.png][6]

其它机器（全自定义）：
这里要注意的是，如果用群晖，或者QNAP自带的docker工具创建容器，需要把这些映射的目录的权限设置成Everyone可读可写。
![dir-map-2019-07-17_16-47.png][8]

step 4. 网络选择，这两个随意选取一个（注意这里如果选择的是host类型，则第一步的端口映射需要删除）
![bridge-net.png][9]
![host-net-2019-07-17_16-48.png][10]

step 5. env 设置，注意这里的端口，跟我们规则的配置是对应的
![env-cfg-2019-07-17_16-48.png][11]

重要： 指定 用户id/gid：1007 （这里的1007请根据自己的情况填写，可以用`id   用户名`获取到)
对于小钢炮来说：

> 由于已经内建了qbittorent用户，因此可以用`id qbittorrent` 来获取,
> 但是，由于我们想要其它用户（比如fb）也有权限修改qb下载的文件,因此，我们要将组指定为小钢炮里的users组， users组id可以用
> `cat /etc/group | grep -e '^users' | cut -d':' -f3` 获取到, 一般是100
对于其它系统来说，比如群晖或QNAP，你可能希望将这个用户id和组id指定为everyone的，也可以指定为你当前登录用户的，
具体的话看你的需求。
![gid-uid-2019-07-20_14-37.png][12]

step 6. 重启策略配置,建议使用unless-stopped （不要看这个图的）
![restart-2019-07-17_16-49.png][13]

step 7. 最后，点击部署容器
![deploy-btn-2019-07-17_17-23.png][14]


  [1]: http://nanodm.net:8092/archives/43/
  [2]: 1071804084.png
  [3]: http://nanodm.net:8092/archives/43/
  [5]: 3573581574.png
  [6]: 803895380.png
  [7]: 1208881808.png
  [8]: 858342.png
  [9]: 2364746333.png
  [10]: 1630777408.png
  [11]: 2541702041.png
  [12]: 1050567877.png
  [13]: 957113298.png
  [14]: 956639810.png