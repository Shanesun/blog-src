---
title: 在macOS中搭建自己的DNS服务器
date: 2018-05-09 17:08:59
tags:
- DNS Server
categories: 工具
---
最近实验了一下配置nginx多站点，顺便也给自己跑在本机上的几个服务上了个域名(当然是直接用Hosts强行解析到127.0.0.1的......)。但是吧，用Hosts强行解析，总觉得有点别扭，所以试着在本机搭一个DNS服务器。

<!-- more -->

# 前提条件

0. 一台安装有macOS的电脑(不过，本文使用的dnsmasq在任何一个UNIX-like操作系统上也可以使用，所以要说成"一台安装有UNIX-like操作系统的电脑"也可以。至于Windows？抱歉我懒得去试。)
1. Homebrew或类似的包管理工具(或者您要是愿意，编译安装也不是不可以，只要您能解决一路上遇到的问题)
2. 一个终端模拟器

# 安装

安装过程很简单，使用包管理工具安装即可

```bash
$ brew install dnsmasq
```

# 配置

安装成功之后，编辑**/usr/local/etc/dnsmasq.conf**文件，修改如下内容：

```conf
# Never forward plain names (without a dot or domain part)
domain-needed
# Never forward addresses in the non-routed address spaces.
bogus-priv

# 将所有.local的域名全部解析到本机回环地址
address=/local/127.0.0.1
address=/local/::1

# 不读入/etc/hosts
no-hosts

# 如果不想dnsmasq载入/etc/resolv.conf，则解除该行注释
#no-resolv
```

然后我这里希望仍然使用路由器作为主要的DNS服务器，dnsmasq仅用来解析.local域名，所以还需要配置系统的/etc/resolver。

**注意：这一步操作仅在macOS中测试通过，不保证其他操作系统下的可用性**

```bash
# 首先创建/etc/resolver目录
sudo mkdir -p /etc/resolver

# 然后配置local域名使用127.0.0.1上的DNS解析
echo "nameserver 127.0.0.1" > local
```

# 测试

在这之前，我已经在本机配置了nginx服务器，并将Aria2前端配置了域名aria.boris1993.local，所以我使用浏览器直接访问这个域名，打开成功，Q.E.D.

**注意：nslookup貌似不会读取/etc/resolver的配置，至少在我的电脑上，nslookup aria.boris1993.local的结果是NXDOMAIN**
