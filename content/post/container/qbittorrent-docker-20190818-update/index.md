---
title: "qBittorrent docker 20190818更新"
date: 2020-05-02T19:21:43+08:00
tags:
  - old-site
---

> 原文由 @也无荒野也无灯 发表于 2019-08-18 08:48

> 原文地址（已经不可访问): `http://nanodm.net:8092/archives/52/`

1.docker hub地址
============

[https://hub.docker.com/r/80x86/qbittorrent][1]
欢迎star 和 下载使用.

这可能是独一无二的qb docker镜像.
这可能是最用心的qb docker镜像.

2.本次修改
============

此docker镜像的创建者，一周 7x 24小时在使用docker版的qb.
针对使用上的习惯，对源码做了很多优化.

本次的改进基于最新的稳定版qb 4.1.7， 主要的改进有：

1. 增加日志查看器. 双击可复制日志信息. 彩色显示不同级别的日志。
2. 增加 `latest-nova` tag (与普通版的主要区别是，此镜像增加python3以支持qb的nova种子搜索引擎）


3.建议的更新流程
============


> 暂停所有种子，recreate更新之后，恢复所有种子.

如果你想由原来的版本，更换为nova版：
则不能直接recreate更新，需要选择`Duplicate/Edit`，然后，Image 处修改为： `80x86/qbittorrent:latest-nova` 再Deploy

（原先用的默认版本，是 `80x86/qbittorrent:latest`)

> 如果遇到日志页面不能显示，可尝试浏览器“强制清空缓存“（ctrl+shift+i再右击刷新按钮清空）


4.效果截图
============

日志查看效果：
![qb-webui-log-viewer-2019-08-17_22-18.wm.png][2]

为了演示nova搜索，老灯特意做了一个基于网络上开放API的nova引擎插件：

cilimao插件： `http://rom.nanodm.net/N1/qb/cilimao.py`

![qb-search-engine-2019-08-18_08-32.wm.png][3]

nova搜索和下载bt资源：
![qb-download-searched-2019-08-18_08-35.wm.png][4]


  [1]: https://hub.docker.com/r/80x86/qbittorrent
  [2]: 2650040656.png
  [3]: 3895426657.png
  [4]: 3005128239.png