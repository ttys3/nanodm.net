---
title: "N1 PT下载小钢炮固件 20190326-20190411 更新日志"
date: 2019-04-11T20:55:19+08:00
slug: nanodm-n1-20190411-changelog
lastmod: 
tags: ["PT", "小钢炮"]
categories: ["更新日志"]
draft: false
---


这次的背景音乐是： 又又 - 你的样子

中间过门是一段又又拉的小提琴，非常赞.

{{% music id="32807379" auto="1" %}}


## 0411 固件(测试版)

1. 增加 fusermount （给rclone之类的程序挂载使用)

2. 增加 ipset 命令

3. 内核： 
    增加ipset和 xt_set 模块支持, 可选启用：
```bash
modprobe ip_set
modprobe ip_set_hash_ip
modprobe ip_set_hash_net
modprobe ip_set_bitmap_ip
modprobe ip_set_list_set
modprobe xt_set
```

## 0402 固件(测试版)

1. docker默认的镜像源换成了阿里云镜像 (https://registry.docker-cn.com)

    增加 `docker-compose`, `docker-proxy`

2. dashboard 1.5.6 和 frp 0.25.3 更新

    dashboard 1.5.6:
    frp 新增加多个选项，密码框后面都添加上了小眼睛.

    修复 IPv6 直接用IP访问时，顶部的按钮URL地址错误的问题.


    frp 更新到最新的0.25.3:

    frpc 新增加WEB UI直接编辑配置 + 代码高亮配置 + 炫酷配色主题切换

    如需要访问frpc admin ui,请修改 `Admin Listen Addr` 为 `0.0.0.0`
    ，同时修改一下`Admin Password`


    ![输入图片说明](img/frpc-status-new.png)

    ![输入图片说明](img/frpc-new-option.png)


    ![monokai](img/monokai.png)

    ![eclipse](img/eclipse.png)

    ![mdn-like](img/mdn-like.png)

    ![icecoder](img/icecoder.png)

    ![zenburn](img/zenburn.png)


之前版本的用户也可通过包管理来更新:

```bash
#备份配置
cp /etc/frpc.ini /etc/frpc.ini.bak
cp /etc/dashboard/system.toml /etc/dashboard/system.toml.bak

#更新
opkg update
opkg install --force-reinstall hacklog-dashboard
opkg install --force-reinstall frp

#恢复配置
mv /etc/frpc.ini.bak /etc/frpc.ini
mv /etc/dashboard/system.toml.bak /etc/dashboard/system.toml

#重启服务
/etc/init.d/S99dashboard restart
/etc/init.d/S93frp restart
```


## 0327 固件(测试版)

1. 增加简易docker配置页.

2. 美化了之前可以把人丑哭的登录界面。 （背景可以自己换成***的美腿照，这个也是支持的）

把图片放到 `/usr/local/apps/dashboard/theme/darkmatter/static/img/wallpaper/` 目录下即可。

会随机选择图片。如要固定一张，只放一张即可。

![](/img/2019-04-12.00-09-33.jpg)


关于docker:
默认情况下UI Running Status为Not installed. 即未安装。
通过点击 ”Install or Re-Install Docker UI“ 按钮即可一键安装Docker UI管理工具。
(docker要先开起来！请看下面0326更新说明开启docker)
视你的网速而定，这里可能要等待几十秒到几分钟。
安装好之后状态是这样的：

![](img/2019-04-12.00-04-31-docker-cfg.png)

## 0326 固件(测试版)

1. 新增加docker
内核，启动以下支持：
```
       CONFIG_BLK_CGROUP
       CONFIG_CGROUPS
       CONFIG_CGROUP_CPUACCT
       CONFIG_CGROUP_DEVICE
       CONFIG_CGROUP_FREEZER
       CONFIG_CGROUP_WRITEBACK
       CONFIG_CGROUP_SCHED
       CONFIG_CGROUP_PIDS
```

2. 增加jellyfin (修复了和kodi的jellyfin插件配合时，客户端解码直接播放的问题）!
3. 增加netatalk（暂无WEB UI）
4. ncdu: update to 1.14 ， 修复中文字符显示乱码的问题.
5. 增加 mount.cifs 
6. frpc.ini: filemanager: default use tcp
7. aria2.conf: add default user-agent option
8. python2: enable zlib, hashlib,ssl certifi and buildroot package ca-certificates for qbittorrent python searchengine
9. add transmission-cli support
10. add ffmpeg support, add x265 and x265 cli, x264 cli
11. gerbera: libupnp18: update to 1.8.4 修复gerbera重启后端口号自动+1的问题
12. rootfs 的空间增加到 800M


由于docker和姐夫并不是所有人都会用，因此，默认没有自启动。需要的，首次，自己进Startup设置成yes, 并且点一下start 就启动了(下次会自动启动）,

由于docker等的数据默认也存在/var下面的子目录，因此，这个版本起，

默认把/dev/data分区划分给力/var （大概有4.3GB可用空间，小一点的docker镜像完全没问题的). 暂时没给docker做GUI, 等...


### 关于固件体积变化

> 一直以来，固件都比较注较小巧和高效。

> 细心的朋友会发现这次的固件体积大了很多：刷机包增加到 144M的大小。

> 关于0326之后的固件体积为什么增加了，我解释一下.

> 主要的空间增加来自docker和jellyfin. 其中

> jellyfin 104.8M占用了apps目录约64%的空间。 

> docker约 129.9 M (48.5+41.2+28.7+5.9+5.6),  大概占用了 /usr/bin  83.3% （31.1+26.4+18.4+3.8+3.6 ）的空间。


### 友情提示

> N1跑jellyfin转码播放就不要去尝试了
> 死机了不要找老灯.
> 这个jellyfin在N1上面只能配合kodi的jellyfin插件在客户端转码播放的。（这也是一开始加入jellyfin的原因）
> 不适合在N1上面服务端转码。。。
> 这也是老灯一开始拒绝加入jellyfin的原因。
