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

# 安装HomeBrew

```bash
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

# 安装Shadowsocks

```bash
brew install shadowsocks-libev
```

# 安装simple-obfs

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
        "local_port":1080,
        "password":"PASSWORD",
        "method":"chacha20-ietf-poly1305",
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
  </dict>
</plist>

```

# 添加开机自启动

## 首先安装 **brew services**

```bash
brew services
```

## 然后启用Shadowsocks的自启动配置文件

```bash
brew services start shadowsocks-libev
```

至此在macOS X上安装Shadowsocks和simple-obfs结束，接下来就可以使用SOCKS或HTTP代理客户端使用该代理。