---
title: 在macOS中通过SSH进行X11转发
date: 2018-08-17 17:31:48
tags:
- XQuartz
- X11
categories: [工具, SSH]
---
本文记录如何在macOS中安装X11客户端，并通过SSH进行X11转发。

<!-- more -->

# 安装X11客户端

在macOS中，可以使用`XQuartz`作为X11客户端。可以到[XQuartz Releases](https://www.xquartz.org/releases/)下载安装包手动安装，也可使用`Homebrew`安装。

使用`Homebrew`安装`XQuartz`的命令如下：

```bash
$ brew cask install xquartz
```

注意安装期间需要提供管理员密码以完成安装。安装完成之后需要完全退出并重启终端模拟器。

# 检查远程服务器配置

编辑`/etc/ssh/sshd_config`，设定如下条目：

```
X11Forwarding yes
X11DisplayOffset 10
```

然后重启`sshd`使配置生效：

```bash
sudo systemctl restart sshd
```

# 转发远程X11程序

使用`ssh -X`连接到远程服务器，执行任意X11程序，然后程序的窗口就会在本机显示。