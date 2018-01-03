---
title: 在macOS X中安装Shadowsocks和Simple Obfs
date: 2017-12-09 12:00:25
tags:
- Shadowsocks
- Simple Obfs
categories: 其他
---
最近入手了一台MacBook，自然必备的工具是不能少的。安装过程也遇到了些新的问题，在此记录以备不时之需。

<!--more-->

# 安装 HomeBrew

```bash
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

# 安装 Shadowsocks

```bash
brew install shadowsocks-libev
```

# 安装 simple-obfs

```bash
brew install simple-obfs
```

# 创建配置文件

```bash
cd /etc
sudo mkdir shadowsocks-libev
cd shadowsocks-libev
vim config.json
```

然后将以下内容复制到config.json，其中参数根据实际情况修改，plugin位置需要写绝对路径，路径可以通过 **which simple-obfs** 得到

```json
{
  "server":"SERVER_ADDRESS",
  "server_port":3128,
  "local_address":"0.0.0.0",
  "local_port":1080,
  "password":"PASSWORD",
  "method":"chacha20-ietf-poly1305",
  "fast_open":true,
  "interface":"en0",
  "plugin":"/usr/local/bin/obfs-local",
  "plugin_opts":"obfs=http;obfs-host=cloudfront.net"
}
```

# 修改自启动配置文件

```bash
vim /usr/local/opt/shadowsocks-libev/homebrew.mxcl.shadowsocks-libev.plist
```

修改为以下内容

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>Label</key>
    <string>homebrew.mxcl.shadowsocks-libev</string>
    <key>ProgramArguments</key>
    <array>
      <string>/usr/local/bin/ss-local</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/shadowsocks/shadowsocks.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/shadowsocks/shadowsocks.err</string>
  </dict>
</plist>

```

# 添加开机自启动

## 首先安装 **brew services**

```bash
brew services
```

## 然后启用 Shadowsocks 的自启动配置文件

```bash
brew services start shadowsocks-libev
```

至此在macOS X上安装Shadowsocks和simple-obfs结束，接下来就可以使用SOCKS或HTTP代理客户端使用该代理。如果要配置系统使用PAC，可以继续进行下列步骤。

# 安装 nginx

因为macOS的PAC仅接受HTTP位置，所以需要安装nginx来将本机作为一个HTTP服务器。

```bash
brew install nginx
```

# 使用 PAC 文件配置系统代理

## 使用 ProxyOmega 生成PAC脚本

使用Chrome插件SwitchyOmega生成PAC文件。同时，使用该插件配置Chrome浏览器的代理。

具体生成方法为：

1. 进入SwitchyOmega中Shadowsocks的配置条目
2. 在配置好协议、服务器地址、端口、以及Bypass List后，点击右上角的“生成PAC”(Export PAC)
3. 将生成的 PAC 文件复制到nginx的html目录，如“html/pac/autoproxy.pac”

## 配置系统代理

将系统代理的代理自动配置(Automatic Proxy Configuration)启用，URL填写**http://localhost:8080/pac/autoproxy.pac**(此处的端口号需按照你实际的 nginx 配置填写，默认为 8080；服务器路径也需要按照 PAC 文件的实际位置修改，此处的位置与上一步的配置相对应。)

## 检查是否成功生效

打开Safari，访问一个测试站点，如[Google](https://www.google.com)，如能正常访问则说明配置成功。
