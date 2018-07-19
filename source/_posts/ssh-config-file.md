---
title: 使用SSH config简化SSH连接
date: 2018-01-09 14:08:33
tags:
- SSH
- Shell
categories: 工具
---
如果你有很多的服务器要连接，如果对你来说记住那些服务器的地址、端口实在是一种痛苦，如果你一直在寻找一种能够简化在命令行下连接SSH服务器的办法，那么，本文将给你提供一种解决问题的思路，那就是，使用SSH的config文件。

<!--more-->

# SSH config文件是什么

Open SSH客户端配置文件，允许你以配置项的形式，记录各个服务器的连接信息，并允许你使用一个定义好的别名来代替其对应的ssh命令参数。

# SSH config文件该怎么用

## 创建SSH config文件

通常来说，该文件会出现在两个地方，一个是`/etc/ssh/ssh_config`，一个是`~/.ssh/config`。

`/etc/ssh/ssh_config`文件通常用来定义全局范围上的SSH客户端参数，而`~/.ssh/config`则被用来定义每个用户自己的SSH客户端的配置。我们将要修改的，就是位于用户目录下的config文件。

如果`~/.ssh/config`文件不存在，那么也不用着急，这是正常的，只需要执行如下命令，即可新建一个空白的config文件

```bash
touch ~/.ssh/config
```

## 编写config条目

假如说，我们想连接到一台服务器，它的地址是example.server.com，端口号是2222，以用户admin登陆，并使用~/.ssh/id_rsa这个私钥验证身份。那么，我们需要在命令行里输入：

```bash
ssh admin@example.server.com -p 2222 -i ~/.ssh/id_rsa
```

嗯好吧，-i参数可以省略，但即使这样，命令还是很长，对吧？

那么我们把这个服务器的连接参数写到config文件里，就变成了这个样子：

```config
# 此处我为了美观起见，给每个子条目都缩进了一层，实际使用时缩进不影响文件的效果。

Host sample
    Hostname example.server.com
    Port 2222
    User admin
    Identityfile ~/.ssh/id_rsa
```

嗯，在这里，它还有了一个新名字，叫`sample`。

然后，我们只需要：

```bash
ssh sample
```

就可以连接到这台主机了。

# 这玩意有意思，我还想了解更多！

好吧，为了满足你的好奇心，我这里为你提供了3篇博客供你参考。当然，这三篇博客也是我编写本文时的参考文档。

[多个 SSH KEY 的管理](https://www.zybuluo.com/yangfch3/note/172120)

[How To Configure Custom Connection Options for your SSH Client](https://www.digitalocean.com/community/tutorials/how-to-configure-custom-connection-options-for-your-ssh-client)

[Simplify Your Life With an SSH Config File](http://nerderati.com/2011/03/17/simplify-your-life-with-an-ssh-config-file/)

另外，您也可以阅读ssh_config的手册页，来获得最原始的信息，阅读该手册的命令是：

```bash
man ssh_config
```