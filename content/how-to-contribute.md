---
title: "如何参与贡献"
date: 2020-05-02T01:56:52+08:00
menu: "main"
weight: 40
---

## nanodm.net

nanodm hugo site

## 1. 如何本地浏览

没有安装hugo的可参考此文档<https://www.gohugo.org/doc/overview/installing/> 安装好hugo.

Windows用户需要特别注意，把`hugo.exe`所在的目录加入`PATH`环境变量以便在任何地方都可以直接执行`hugo`命令。

```bash
git clone https://github.com/ttys3/nanodm.net.git
cd nanodm.net
hugo server -D
```
然后打开 <http://localhost:1313/> 即可查看。


## 2. 我有文章想分享要怎么做

1. fork此仓库
2. clone你fork后的仓库到你本地
3. 添加页面并push到你的仓库
4. 提交一个PR（pull request)到这个仓库
5. 如果文章OK，这边merge了你的PR后，文章就会出现在网站

## 3. 如何添加页面

为方便管理文章和图片之间的关联，我们采用Hugo的`page bundle`方式来写文章。

1. 所有文章都在`content/post`目录下，采用markdown编写。
2. 每个文章都有自己的子目录,如`https://nanodm.net/post/nanodm-site-now-hosted-on-netlify/` 这个文章，
其markdown文章位于`content/post/nanodm-site-now-hosted-on-netlify/index.md`
3. 文章自己的资源文件（比如图片等）放在文章自己的目录下面, 具体可参数`https://nanodm.net/post/nanodm-site-now-hosted-on-netlify/` 这个文章
4. 推荐使用编辑器 vscode

## 4. vscode建议安装插件

打开 VS Code Quick Open (`Ctrl+P`), 粘贴以下命令并按`Enter`即可安装插件。
一些插件有一些注意事项，注意查看vscode插件页面的说明。

### 必备插件

[Markdown Paste](https://marketplace.visualstudio.com/items?itemName=telesoho.vscode-markdown-paste-image)

写markdown必备神器，直接`Ctrl+Alt+V` (`Cmd+Alt+V` on Mac)粘贴图片文件到当前markdown的目录并自动填写此图片的markdown代码。

支持Mac/Windows/Linux，为了使这个插件正常工作，要求：

1. Linux需要`xclip`
2. Windows需要`powershell`
3. Mac需要`pbpaste`

```bash
ext install telesoho.vscode-markdown-paste-image
```

[](https://raw.githubusercontent.com/telesoho/vscode-markdown-paste-image/master/res/markdown_paste_demo_min.gif)

[Hugo Language and Syntax Support](https://marketplace.visualstudio.com/items?itemName=budparr.language-hugo-vscode)

```bash
ext install budparr.language-hugo-vscode
```

[Hugo Shortcode Syntax Highlighting](https://marketplace.visualstudio.com/items?itemName=kaellarkin.hugo-shortcode-syntax)

```bash
ext install kaellarkin.hugo-shortcode-syntax
```

[Hugo Snippets](https://marketplace.visualstudio.com/items?itemName=fivethree.vscode-hugo-snippets)

```bash
ext install fivethree.vscode-hugo-snippets
```

[hugofy](https://marketplace.visualstudio.com/items?itemName=akmittal.hugofy)

```bash
ext install akmittal.hugofy
```

[Markdown All in One](https://marketplace.visualstudio.com/items?itemName=yzhang.markdown-all-in-one)

```bash
ext install yzhang.markdown-all-in-one
```

[Better TOML](https://marketplace.visualstudio.com/items?itemName=bungcip.better-toml)

```bash
ext install bungcip.better-toml
```

[toml-formatter](https://marketplace.visualstudio.com/items?itemName=Iceyer.toml-formatter)

```bash
ext install Iceyer.toml-formatter
```

[Table Formatter](https://marketplace.visualstudio.com/items?itemName=shuworks.vscode-table-formatter)

```bash
ext install shuworks.vscode-table-formatter
```

[markdownlint](https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint)

```bash
ext install DavidAnson.vscode-markdownlint
```

[Markdown Shortcuts](https://marketplace.visualstudio.com/items?itemName=mdickin.markdown-shortcuts)

```bash
ext install mdickin.markdown-shortcuts
```

[Markdown Preview Enhanced](https://marketplace.visualstudio.com/items?itemName=shd101wyy.markdown-preview-enhanced)

```bash
ext install shd101wyy.markdown-preview-enhanced
```

[Color Highlight](https://marketplace.visualstudio.com/items?itemName=naumovs.color-highlight)

```bash
ext install naumovs.color-highlight
```

[Front Matter](https://marketplace.visualstudio.com/items?itemName=eliostruyf.vscode-front-matter)

```bash
ext install eliostruyf.vscode-front-matter
```

### 可选插件

[Gruvbox Themes](https://marketplace.visualstudio.com/items?itemName=tomphilbin.gruvbox-themes)

```bash
ext install tomphilbin.gruvbox-themes
```

[Markdown Checkbox](https://marketplace.visualstudio.com/items?itemName=PKief.markdown-checkbox)

```bash
ext install PKief.markdown-checkbox
```

[Settings Sync](https://marketplace.visualstudio.com/items?itemName=Shan.code-settings-sync)

```bash
ext install Shan.code-settings-sync
```

[PostCSS syntax](https://marketplace.visualstudio.com/items?itemName=ricard.PostCSS)

```bash
ext install ricard.PostCSS
```

[Modelines](https://marketplace.visualstudio.com/items?itemName=chrislajoie.vscode-modelines)

```bash
ext install chrislajoie.vscode-modelines
```

[change-case](https://marketplace.visualstudio.com/items?itemName=wmaurer.change-case)

```bash
ext install wmaurer.change-case
```