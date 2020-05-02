---
title: "PT tracker批量修改工具 bt-tracker-changer "
date: 2020-05-02T19:16:42+08:00
tags:
  - old-site
---

> 原文由 @也无荒野也无灯 发表于 2019-07-20 23:48
> 原文地址（已经不可访问): `http://nanodm.net:8092/archives/46/`

敬告
==

本工具仅供测试研究使用。不对因使用而产生的任何问题负责。
做任何操作前请自行备份。

工具下载
====

[bt-tracker-changer-v1.0.1.zip][1]

主要是最近“发生了一些事情”，
（比如，馒头的tp 变 pt, gzt 域名变更了， 春天变SSD了等)
有些人不想改hosts解决，就是想要批量修改啊，
就是想要批量修改啊，
就是想要批量修改啊，
你有什么办法？
不要试图去阻止他，写个命令行工具给他让他去折腾吧（你真坏）

安装
==

里面有两个可执行文件， `.amd64`的是给Linux 64位机器用的， `.arm64`的是给Linux arm64机器用的.
自行copy为系统里的 `/usr/local/bin/bt-tracker-changer` 即可
最后别忘记添加执行权限：

```shell
chmod a+rx /usr/local/bin/bt-tracker-changer
```

使用
==

使用太简单了.

```
bt-tracker-changer -s "需要修改tracker的种子所在目录" -d "修改之后的种子保存目录" -f '旧的tracker地址' -t '新tracker地址'
```

如果需要就地修改（修改之后保存覆盖原文件），则只需要省略 -d 参数即可：

```
bt-tracker-changer -s "需要修改tracker的种子所在目录" -f '旧的tracker地址' -t '新tracker地址'
```

如果只是想查看一下种子信息，可以这样：

```shell
bt-tracker-changer -i -s "种子目录"
```

帮助信息：

```shell
bt-tracker-changer -h
 -------------------------------------------------------
 ===== bt-tracker-changer v1.0.1 by HuangYeWuDeng  =====
 -------------------------------------------------------
Usage of ./release/bt-tracker-changer:
  -b string
        the directory to backup the torrent before change it (default "backup")
  -d string
        the destination directory for saving changed torrents
  -f string
        old tracker URL
  -h    this help
  -i    only show torrent info, do not change
  -s string
        the source torrents directory
  -t string
        new tracker URL
```

  [1]: bt-tracker-changer-v1.0.1.zip
