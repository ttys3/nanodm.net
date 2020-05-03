---
title: "1分钟使用vscode建立Hugo博客"
date: 2020-05-03T22:25:34+08:00
---

NanoDM目前是使用Hugo建立的。很多人可能没听过Hugo, 或者觉得使用Hugo写博客会很麻烦。

在此，我们分享一个快速用于建立Hugo博客的vscode插件：[Hugofy](https://marketplace.visualstudio.com/items?itemName=ttys3.hugofy)

这个插件的作者已经很久没有更新了，因此我们这里安装的是一个fork后的持续更新版本。

Hugofy插件安装方法：

打开vscode, 输入 Ctrl+P，然后粘贴`ext install ttys3.hugofy` 即可快速完成插件安装。

注意:

> 使用Hugofy插件之前，一定要确保hugo可执行文件在`PATH` 环境变量所在的位置，如果你不懂这些，最粗暴的解决办法是把hugo.exe丢到`C:\Windows\`目录下面

hugo是基于golang开发的，天生跨平台。

Windows 下可使用`choco install hugo -confirm` 或 `scoop install hugo`快速安装hugo。
如果这两个工具你都没有，安装过程也非常简单,只需要下载合适你系统版本(xxxx-Windows-64bit.zip)的[Hugo 二进制](https://github.com/gohugoio/hugo/releases)。
为了更方便的使用，你应该把它安装到你的 `PATH` 环境变量所在的位置。

Mac可使用`brew install hugo` 快速安装hugo

Fedora/CentOS/RHEL 可使用 `sudo dnf install -y hugo` 快速安装hugo

Debian/Ubuntu `sudo apt-get install hugo`

ArchLinux `sudo pacman -Syu hugo`

1分钟使用vscode建立hugo博客视频

{{< video mp4="1分钟使用vscode建立hugo博客.mp4" >}}