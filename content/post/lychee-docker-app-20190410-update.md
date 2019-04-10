---
title: "Lychee相册程序docker镜像更新20190410"
date: 2019-04-10T20:55:19+08:00
lastmod: 
tags: ["Lychee", "相册", "docker", "app"]
categories: ["更新记录"]
draft: false
---

## 城南旧事

Lychee相册程序 其实也是很久之前的一个项目，老灯当初把它port到SQLite版，

并且成功在MT7621的R6800路由器上面运行过.

现在有基于Laravel框架开发的新版本了，由于有DB抽象层，因此port SQLite也相对容易得多.

说容易，其实也还是挺麻烦的，老灯也是调试了蛮久，最终才顺利在N1上流畅运行. 

然后为了方便大家安装，老灯还打包好了docker镜像（AMD64和arm64版），

可去 docker hub 围观： https://hub.docker.com/r/80x86/lychee

最近老灯发现Lychee Laravel程序的作者也关注了老灯的Lychee repo,

并且已经默认把老灯用于小钢炮固件的一些修改合并到master分支了：

![lychee commit log](/img/2019/04/2019-04-10.22-58-19-lychee-commit-log.png)


## 更新记录

bug修复:

1. 修复 `Full Settings` 无法正常提交保存的bug

2. Lychee 默认图片导入路径修复

原来默认的路径是`/app/Lychee-Laravel/uploads/import/`,这个路径是错误的.

正确的路径是: `/app/Lychee-Laravel/public/uploads/import/` , 现已修复.

改进：

1. 增加 php_script_no_limit 选项，并默认设置成1，

    表示import 导入图片时，没有执行超时限制,

    如果设置成0，则表示遵循默认的PHP超时配置设定.

    (注意，这个选项只对导入图片生效)


2. docker 容器的工作目录设定为程序的目录 `/app/Lychee-Laravel`


## 如何更新

如果你之前已经在docker里安装过这个相册程序，直接点击容器的名字，进去之后，选择Recreate, 

然后勾选住Pull latest image, 就会拉取最新的镜像并重新创建容器，当它提示你是否替换当前的容器时，

选择是即可.

![lychee docker 如何更新](/img/2019/04/2019-04-10_23-18-lychee-docker-container-update.png)

------------------------------------------------------------------------

## 他山之石

另外，有网友反馈，lychee这个UI，对手机用户不太友好。
对此无灯也进行了一些研究。

找到一个对手机界面比较友好的相册前端UI： [nanogallery2](https://nanogallery2.nanostudio.org/)
[点此查看demo效果](http://nanogallery.brisbois.fr/)

![nanogallery2 screenshot](https://nanogallery2.nanostudio.org/img/screenshot_builder.jpg)


我想有时间的话可以用这个UI替换掉lychee原有的，或者，自己用这个UI打造一个新的相册程序也OK

还有一个比较节省时间的方案就是，引入 [ImageVue](https://www.photo.gallery/)

这是一个很老牌的相册程序，早期是基于flash的,叫 ImageVue，现在改成HTML5了. 一直以来就是那么优秀. 

无需mysql支持，特别适合跑在低功耗的arm设备上(比如N1这种神机).

新版换了个毫无识别度的名字：`X3 photo gallery` ， 老灯觉得还不如ImageVue好记和好搜索...

毕竟你搜索photo gallery能出来一大把东西, 而 `X3` 更抽象了...

如果需要了解更多关于X3的信息，老灯推荐看看[这个文章](https://yorkchou.com/iamgevue.html)

[点此查看网上其他用户的demo效果](https://gallery.yorkchou.com/)


![](/img/2019/04/2019-04-10.23-05-37-imagevue.png)

功能一览：

![imagevue功能一览](/img/2019/04/2019-04-10.23-06-06-imagevue-feature.png)