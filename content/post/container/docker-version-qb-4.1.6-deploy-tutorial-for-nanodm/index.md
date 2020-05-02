---
title: "小钢炮使用docker版qb 4.1.6 简明教程"
date: 2020-05-02T19:15:07+08:00
tags:
  - old-site
---

> 原文由 @也无荒野也无灯 发表于 2019-07-20 14:44

> 原文地址（已经不可访问): `http://nanodm.net:8092/archives/43/`


# 小钢炮使用docker版qb 4.1.6 简明教程

这不是一个手把手教程，这是一个简明教程，适合有折腾经验的童鞋.

其它机器和Linux发行版，请参考 https://hub.docker.com/r/80x86/qbittorrent 部署容器.

此教程同时适用于N1和贝壳云.

带有 **4.1.6*** tag 的镜像为官方原版代码镜像.

## 此docker镜像的特点

1. 在dashboard里可以点击自动登录
2. 在dashboard里可以查看qb的日志
3. 支持自定义BT和http web端口
4. 支持绑定qb的配置,数据和下载目录
5. multiarch:同时支持amd64/arm64机器
6. 在官方源码的基础上，应用小钢炮版的UI优化补丁


## 1.禁用原生qb的启动脚本

直接把 `S92qbittorrent` 重命名为 `S92qbittorrent.disabled` 并移动到上层目录 ， 用命令的话，可以像下面这样操作：

```
mv /etc/init.d/S92qbittorrent /etc/S92qbittorrent.disabled
```
你也可以选择用图形化的工具操作。

## 2.停止原生qb进程

保险起见，你可以登录qb web UI,并暂停掉所有的任务，然后：

```
killall qbittorrent-nox
```
你可以用以下命令检测qb是否已经杀死：
```
ps aux | grep -v grep | grep qbittorrent-nox
```
如果已经干掉了，不会有结果.

## 3.备份

先备份以下两个目录：
```
/var/lib/qbittorrent/.config/qBittorrent
/var/lib/qbittorrent/.local/share/data/qBittorrent
```

可以ssh进去然后用cp命令，windows用户可以用sftp或者winscp

注意以`.`开头的目录默认不显示，你需要直接把路径粘贴进去.

## 4. 部署docker容器

这里老灯已经写好了一个一键部署的脚本，你只需要下载（一定确认下载成功了）并执行一次即可：

如果你的东西不是全下载到一个默认路径下，有其它路径，请先查看下面的 **6. 修复保存到非默认下载路径的种子** 再执行下面的操作：

```
wget http://rom.nanodm.net/beikeyun/qb.docker.sh
#按6修改 qb.docker.sh
#再执行
sh ./qb.docker.sh
```

否则你可以一步搞定：

```
wget http://rom.nanodm.net/beikeyun/qb.docker.sh && sh ./qb.docker.sh
```
这里需要下载镜像，视你网络情况的好坏，大概需要几十秒到几分钟.

执行成功后，进docker UI看看，你会看到一个名为`qbittorrent` 的新容器处于运行状态.

你可以在dashboard点击`qBittorrent`按钮直接登入qb web UI.

所有的qb配置都是直接使用了之前的,除了一点：默认下载路径设置成了 `/downloads`

## 5. 修复保存到默认下载路径的种子
 
在建立容器时增加一个原下载路径的同名映射：
比如：
```shell
-v /media/old/movie:/media/old/movie
```
这样，容器里的/media/old/movie 就指向了host机的/media/old/movie了，文件依旧存在。 

## 6. 修复保存到非默认下载路径的种子

同样，这里也是增加一个原下载路径的同名映射：

比如,你之前有少数种子保存到了`/media/other`目录下,

而你之前的默认下载路径是`/media/wd10t/qb/download`

那么,你需要修改shell脚本的命令，在 `-v "$DOWNLOAD_PATH":/downloads` 一行下面增加一行
```
-v /media/other:/media/other \
```
现在我们已经把 /media/other 绑定到容器里的： `/media/other`
这样，对于旧的种子，我们就不用改种子的路径了。

## 7. Troubleshooting

### 7.1 如果显示IO错误，一般是没有权限创建文件，修复方法像这样：

```
chown -R qbittorrent:users /media/wd10t/qb/download/ssd001
```
如果还不行，用777大法：
```
chmod -R 777 /media/wd10t/qb/download/ssd001
```

### 7.2 如果有种子变红了，成了error(错误)状态了，怎么办？

一般是显示file size missmatch 或者 file missing找不到文件，
出现这个问题的典型原因就是：因为文件不存在。
（但是并不是真的不存在，只是qb记录的路径，和实际文件当前所处的位置，不一样，
因此，我们只需要简单的设置回正确的路径就行了)

此时，不用着急。千万不要随意操作。

因为我们只操作了qb,并没有动文件，因此，硬盘上的文件是一定原封存在的。如果qb报错说找不到文件，

可以尝试下载路径后，用force recheck(强制重新检查)修复。

如果还不行，你可以截图，说明详细问题，来群里讨论。


如果修复路径之后还遇到问题：

1. 种子处于100% 的完成（completed）状态

这种情况只需要选中这些种子，然后右击，resume (恢复) 即可恢复到做种(seeding) 状态

2. 种子处于0% 的暂停(paused)状态，点击force recheck也没有反应 （很确定文件是存在的）

这种情况，一般是非正常关闭qb,导致fastresume文件没有被保存或损坏（种子是完成的，fastresume文件也存在，但是大小是0字节），因此丢失了单个种子的进度。
此时千万不要点击resume,即使你已经设置了正确的文件位置。因为fastresume文件信息不对，qb会认为你的下载进度是0，从而明明文件已经存在了，还从头开始下载。
这种情况，我们需要删除这个种子（千万不要勾选删除文件），
然后重新从PT站点下载同一个种子(根据种子的Trackers信息我们可以知道是哪个站的，根据名称(右击种子，选择copy name)和文件大小，我们就可以找到对应的种子)，
然后添加回来，添加的时候要注意设置正确的路径
（如果之前下载的就是非默认路径的话，如果文件在默认路径就不用管）， 在确定文件存在的情况下，可以勾选skip hash check.

3. 如果你之前有备份 BT_Backup那个目录

在重启后出现种子数量变少的情况，可以尝试停止qb,然后恢复备份的种子及其fastresume文件.

docker 容器的网络模式
https://cizixs.com/2016/06/12/docker-network-modes-explained/
