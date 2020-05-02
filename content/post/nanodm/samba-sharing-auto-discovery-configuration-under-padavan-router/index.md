---
title: "padavan路由器下samba共享自动发现配置"
date: 2020-05-02T19:01:09+08:00
tags:
  - old-site
---


> 原文由 @也无荒野也无灯 发表于 2019-05-12 02:27

> 原文地址（已经不可访问): `http://nanodm.net:8092/archives/26/`

## 1. padavan路由器配置

关master, 开wins.

USB Application - Common Setting -  SMB Server (Windows Network Neighborhood)

Work Group 设置为 `WORKGROUP` （这个一般默认就是）
Enable Master Browser 设置为 No
![2019-05-12_02-19.png][1]

再到 Administration - Services - Windows Internet Name Service (WINS)

启用 WINS Service
Work Group 设置为 `WORKGROUP` （这个一般默认就是）
Enable Master Browser 设置为 No
![2019-05-12_02-19_1.png][2]

## 2. Master 配置

padavan路由器不开master, 因此我们选一台当master, 这里就用贝壳云来当master吧：
开master, 开smb

![2019-05-12_02-20.png][3]

## 3. 同一局域网内其它samba服务配置
关master, 开smb
n1 配置举例：
![2019-05-12_02-20_1.png][4]

## 4. Linux (gnome3桌面环境）下显示效果

![Screenshot from 2019-05-12 02-28-44.png][5]


  [1]: 3250509557.png
  [2]: 2810353197.png
  [3]: 3329215904.png
  [4]: 2862586862.png
  [5]: 3070000896.png