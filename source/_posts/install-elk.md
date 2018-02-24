---
title: 搭建ELK日志平台
date: 2018-02-04 16:50:31
tags:
- ELK
- Elastic Search
- Logstash
- Kibana
categories: Java
---
最近搭建了一次ELK日志平台，在此记录一下安装步骤

<!--more-->

# 安装JRE

首先这套平台是基于Java的，所以Java运行环境当然是不能少。但因为这上面不涉及Java的开发，所以不需要装JDK，装JRE就够了，还能省下一些磁盘空间。我这里选择JRE8u161。

我这次选择使用tar包手动安装。

首先，将tar包复制到/opt目录并解压。

```bash
sudo cp jre-8u161-linux-x64.tar.gz /opt/
cd /opt
sudo tar xvzf jre-8u161-linux-x64.tar.gz

# 养成好习惯，用不着的文件及时清理
sudo rm jre-8u161-linux-x64.tar.gz
```

然后配置环境变量

```bash
# 当然这里你可以随意选择你喜欢的编辑器，你甚至可以使用Emacs
sudo vi /etc/profile
```

增加如下内容

```profile
export JAVA_HOME=/opt/jre1.8.0_161

# 我个人习惯把PATH的设定放在最下面
export PATH=$JAVA_HOME/bin:$PATH
```

然后重新载入/etc/profile使配置生效，并检查Java环境是否配置正确

```bash
source /etc/profile
java -version
```

输出如下内容

```
java version "1.8.0_161"
Java(TM) SE Runtime Environment (build 1.8.0_161-b12)
Java HotSpot(TM) 64-Bit Server VM (build 25.161-b12, mixed mode)
```

至此Java环境配置完成

# 安装Elastic Search

Elastic Search需要调整文件描述符大于65535、最大线程数大于4096、以及vm.max_map_count大于262144

```
# vim /etc/security/limits.conf

#Insert following lines
* hard nofile 65536
* soft nofile 65536
* hard nproc  4096
* soft nproc  4096

# vim /etc/sysctl.conf

#Insert following line
vm.max_map_count=262144

# sysctl -p
```

首先新建一个名为elk的用户，用于运行ELK平台

```bash
useradd -m elk
```

然后将Elastic Search的安装包复制到elk的用户目录并解压，进入Elastic Search的bin目录后运行

```
nohup ./elasticsearch & tail -f nohup.out
```

以启动并监控启动过程

# 参考文献
+ [Elastic Search Installation Guide](https://www.elastic.co/guide/en/elasticsearch/reference/current/_installation.html)
+ [Logstash Installation Guide]()
+ [Kibana Installation Guide]()