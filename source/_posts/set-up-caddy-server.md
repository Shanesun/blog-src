---
title: 配置Caddy作为静态网站服务器和前置代理
date: 2018-07-19 16:42:30
tags:
- WebServer
- Caddy
categories: 工具
---
之前听闻有个新的Web Server，名曰Caddy，其配置简单，还默认启用HTTP/2，并且可以自动申请Let's Encrypt的HTTPS证书。试用了一番，觉得不错，便把这个博客的服务程序换成了Caddy。在这里呢，记录一下安装和配置的过程。

<!--more-->

# 安装

万事第一步，先安装。

## 下载页面概览

打开[Caddy](https://caddyserver.com/download)的下载页面，页面的内容简洁明了，左侧是4个要配置的项，右侧是每个配置项实际的内容。

![Download Page Overview](/images/caddy/caddy-download-overview.png)

## 选择运行平台

首先，选择好Caddy要在哪个操作系统下运行。Caddy支持的平台还是足够多的，而且覆盖到了主流的操作系统，所以甭管您是Windows，还是Linux，抑或是BSD，都可以运行Caddy。因为我的服务器运行的是64位Ubuntu，所以选择`Linux 64-bit`。

实话说，看到Plan 9的时候，心里还是被惊到了。

![Choosing Platform](/images/caddy/caddy-download-choose-platform.png)

## 选择插件

接下来是选择要安装哪些插件，通常来说，根据自己的需要来选择就可以了。如果后期要安装更多的插件的话，重新来下载页面勾选需要的插件并重新安装就可以了。毕竟是用Go写的，最后就一个可执行文件，替换掉原来的，就算重装好了。

我的需求有这么几点：

1. 我需要Caddy可以作为一个反向代理，所以选择了`http.forwardproxy`插件
2. 我的博客的源文件放置于我的GitHub中，我希望Caddy可以直接clone这个仓库，并且能通过WebHook监听这个仓库的更新事件，所以选择了`http.git`插件
3. 我在使用Cloudflare的DNS服务，并且Caddy可以通过DNS验证的方式申请HTTPS证书，所以需要`tls.dns.cloudflare`插件
4. 我想要Caddy作为一个系统服务，并且可以随系统自动启动，但是我又懒得自己写配置文件，所以使用`hook.service`插件来为我提供已经写好并经过了测试的配置文件

![Choosing Plugins](/images/caddy/caddy-download-choose-plugins.png)

## 选择是否开启遥测功能

Caddy提供了一个叫做“遥测”的功能，可以监控您的Caddy实例的状态。具体针对该功能的描述，可以到其文档页面[Telemetry](https://caddyserver.com/docs/telemetry)阅读。这个功能开启与否与功能无关，开不开看您心情。

## 选择适合您的许可证

接下来，就是选择您要使用哪一种许可证来运行Caddy。像在下的博客是个人项目，不涉及商业应用，所以当然选择个人许可证。

![Choosing License](/images/caddy/caddy-download-choose-license.png)

## 下载

终于，到了下载这一步了。Caddy提供了多种下载的方式，您可以在浏览器中将可执行文件下载到本地，或者通过命令行来下载，还可以直接使用一句话脚本来安装。

![Install Methods](/images/caddy/caddy-download-methods.png)

# 配置


