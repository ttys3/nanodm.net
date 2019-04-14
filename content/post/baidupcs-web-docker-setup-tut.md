---
title: "如何在小钢炮固件/群晖/威联通里下载百度网盘里的文件"
date: 2019-04-13 17:26:47
slug: baidupcs-web-docker-setup-tut
lastmod: 
tags: ["docker", "baidupcs", "小钢炮", "N1", "QNAP", "Synology", "群晖", "威联通"]
categories: ["教程"]
draft: false
---

为了方便大家在小钢炮(NanoDM)和群晖/威联通里下载百度网盘里的文件,老灯创建了一个amd64/arm64 架构自适应的baidupcs-go-web的镜像.

地址在这里：https://hub.docker.com/r/80x86/baidupcs

这个镜像的使用很简单，映射两个目录加一个端口就OK了.

`/app/Downloads` 下载文件保存目录，此目录需要映射到host机上面的可写文件夹（任意用户可写文件夹,因为基于安全问题，在docker里我并没有让baidupcs以root权限跑)

`/app/.config/BaiduPCS-Go` baidupcs-web的配置文件保存目录，可以设置成和上面的一样，但是老灯还是建议分开的好

`5299` 端口，可以映射到host机的 `5299` 端口或者任意你自己喜欢的端口，只要你能记住。。。

web UI的访问地址为：`http://主机IP:5299`

假设你的NA/群晖/威联通 机器的 IP 地址是: `192.168.8.201`, 则访问地址是： `http://192.168.8.201:5299` ，
如果你想通过DDNS从外网访问，你需要手动添加一个端口映射.


如果你熟悉命令行，那么，在小钢炮上面跑baidupcs就是一句命令的事儿：
假设下载目录是 `/media/wd3t/baidupcs` ，配置目录： `/media/wd3t/baidupcs-config`


```bash
docker run -d \
--name=baidupcs \
--restart always \
-v /media/wd3t/baidupcs:/app/Downloads \
-v /media/wd3t/baidupcs-config:/app/.config/BaiduPCS-Go \
-p 5299:5299 \
80x86/baidupcs:latest
```

如果不打想命令行，那么，也可以通过友好的UI来进行安装，下面老灯就开始图文讲解了.
一般来说，大家看到图就懂了，因此只有必要的地方老灯才会加以解说.


## 1. 如何在小钢炮(NanoDM)里安装使用baidupcs-go-web

首先确保你已经启用并且启动了docker, docker UI成功安装且处于正常运行状态:

![NanoDM baidupcs docker step 1](/img/2019/04/baidupcs-web-docker-setup-tut/ndm-baidupcs-1.png)

然后点击`Add container` 添加容器：

![NanoDM baidupcs docker step 2](/img/2019/04/baidupcs-web-docker-setup-tut/ndm-baidupcs-2.png)

按下图配置好，注意在Image处填写： `80x86/baidupcs:latest`

![NanoDM baidupcs docker step 3](/img/2019/04/baidupcs-web-docker-setup-tut/ndm-baidupcs-3.png)

映射好容器里的两个路径: `/app/Downloads` 和 `/app/.config/BaiduPCS-Go`，注意映射的host 目录要有任意用可写权限:
![NanoDM baidupcs docker step 4](/img/2019/04/baidupcs-web-docker-setup-tut/ndm-baidupcs-4.png)

![NanoDM baidupcs docker step 5](/img/2019/04/baidupcs-web-docker-setup-tut/ndm-baidupcs-5.png)

配置好之后，最后点击`Deploy the container`创建容器:
![NanoDM baidupcs docker step 6](/img/2019/04/baidupcs-web-docker-setup-tut/ndm-baidupcs-6.png)

成功之后，会显示绿色的`running`状态：
![NanoDM baidupcs docker step 7](/img/2019/04/baidupcs-web-docker-setup-tut/ndm-baidupcs-7.png)

日志:
![NanoDM baidupcs docker step 8](/img/2019/04/baidupcs-web-docker-setup-tut/ndm-baidupcs-8.png)

baidupcs web UI打开效果：
![NanoDM baidupcs docker step 9](/img/2019/04/baidupcs-web-docker-setup-tut/ndm-baidupcs-9.png)


----------------------------------------------------------------------------------------------

## 2. 如何在QNAP(威联通)里安装使用baidupcs-go-web

QNAP有一个更友好的UI用于创建容器, 我们打开`Container Station`, 然后搜索镜像： `80x86/baidupcs`，
找到下图的镜像后，点击`创建`：

![QNAP baidupcs docker step 1](/img/2019/04/baidupcs-web-docker-setup-tut/QNAP-baidupcs-1.png)

这里直接点下一步:
![QNAP baidupcs docker step 2](/img/2019/04/baidupcs-web-docker-setup-tut/QNAP-baidupcs-2.png)

可以根据自己的需求，限制一下CPU和内存使用,再点进`高级配置`:
![QNAP baidupcs docker step 3](/img/2019/04/baidupcs-web-docker-setup-tut/QNAP-baidupcs-3.png)

映射好`5299`端口，主机这边的端口可自行设定，右边容器处的端口`5299`是固定的：
![QNAP baidupcs docker step 4](/img/2019/04/baidupcs-web-docker-setup-tut/QNAP-baidupcs-4.png)

路径映射，映射好容器里的两个路径: `/app/Downloads` 和 `/app/.config/BaiduPCS-Go`，

这里我把baidupcs的配置文件映射到了volume(存储空间), 下载路径则映射到了现有的一个下载目录:

![QNAP baidupcs docker step 5](/img/2019/04/baidupcs-web-docker-setup-tut/QNAP-baidupcs-5.png)

![QNAP baidupcs docker step 6](/img/2019/04/baidupcs-web-docker-setup-tut/QNAP-baidupcs-6.png)

创建成功：
![QNAP baidupcs docker step 7](/img/2019/04/baidupcs-web-docker-setup-tut/QNAP-baidupcs-7.png)

日志查看：
![QNAP baidupcs docker step 8](/img/2019/04/baidupcs-web-docker-setup-tut/QNAP-baidupcs-8.png)

----------------------------------------------------------------------------------------------

## 3. 如何在Synology(群晖)里安装使用baidupcs-go-web

syno里面管理docker的app就叫Docker，如果没有，你需要安装一下.
功能和QNAP的 `Container Station` 类似. 个人觉得在容器建立的流程这里QNAP的UI显得很直观.

在syno里面，你得先通过搜索`baidupcs`找到对应的镜像后，下载镜像:
![synology baidupcs docker step 1](/img/2019/04/baidupcs-web-docker-setup-tut/synology-baidupcs-1.png)

![synology baidupcs docker step 2](/img/2019/04/baidupcs-web-docker-setup-tut/synology-baidupcs-2.png)

然后再到`映像`那里选择下载的点击`启动`开始创建容器:
![synology baidupcs docker step 3](/img/2019/04/baid两个路径: `/app/Downloads` 和 `/app/.config/BaiduPCS-Go`upcs-web-docker-setup-tut/synology-baidupcs-3.png)
两个路径: `/app/Downloads` 和 `/app/.config/BaiduPCS-Go`
适量限制下，然后点击`高级设置`:两个路径: `/app/Downloads` 和 `/app/.config/BaiduPCS-Go`
![synology baidupcs docker step 4](/img/2019/04/baid两个路径: `/app/Downloads` 和 `/app/.config/BaiduPCS-Go`upcs-web-docker-setup-tut/synology-baidupcs-4.png)
两个路径: `/app/Downloads` 和 `/app/.config/BaiduPCS-Go`
勾选这个可以让容器开机自启:两个路径: `/app/Downloads` 和 `/app/.config/BaiduPCS-Go`
![synology baidupcs docker step 5](/img/2019/04/baid两个路径: `/app/Downloads` 和 `/app/.config/BaiduPCS-Go`upcs-web-docker-setup-tut/synology-baidupcs-5.png)

同样的，映射好两个路径: `/app/Downloads` 和 `/app/.config/BaiduPCS-Go`,
注意下载的目录要有写权限，在群晖上面一般来说是everyone权限才能让其它用户写:

![synology baidupcs docker step 6](/img/2019/04/baidupcs-web-docker-setup-tut/synology-baidupcs-6.png)

![synology baidupcs docker step 7](/img/2019/04/baidupcs-web-docker-setup-tut/synology-baidupcs-7.png)

![synology baidupcs docker step 8](/img/2019/04/baidupcs-web-docker-setup-tut/synology-baidupcs-8.png)

![synology baidupcs docker step 9](/img/2019/04/baidupcs-web-docker-setup-tut/synology-baidupcs-9.png)

![synology baidupcs docker step 10](/img/2019/04/baidupcs-web-docker-setup-tut/synology-baidupcs-10.png)

![synology baidupcs docker step 11](/img/2019/04/baidupcs-web-docker-setup-tut/synology-baidupcs-11.png)


欢迎关注老灯的微信公众号：路由器的那些事儿  （iproute2)

![](/img/2019/04/why-filebrowser-raise-wrong-credentials-error-even-with-right-credentials/7d15018e-d35a-4b22-b49f-fdb9e6872bc5.png)


--EOF