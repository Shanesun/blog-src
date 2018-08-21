---
title: 在SuSE Linux上安装Oracle Database 12c手记
date: 2018-08-13 14:04:01
tags:
- Database
- Oracle 12c
categories: 
- 数据库
- Oracle
---
本文记录根据[Oracle官方安装文档](https://docs.oracle.com/en/database/oracle/oracle-database/12.2/ladbi/index.html)，在`openSuSE Leap 15.0`上安装`Oracle Database 12c`(以下简称`Oracle 12c`)的过程。

本文内容目前仅仅是一个大致的安装步骤的介绍，可能会在将来持续补充完善。

<!-- more -->

# 安装前准备

## 检查物理内存空间及swap空间

`Oracle 12c`要求最低`1GB`物理内存，建议安装`2GB`物理内存。

```bash
$ free -m
              total        used        free      shared  buff/cache   available
Mem:           3833         945         919         156        1968        2449
Swap:          8472           0        8472
```

可见本机物理内存总计`4GB`，满足需求。

`Oracle 12c`要求当物理内存在`2GB`~`16GB`之间时，swap空间需等同于物理内存大小。如上结果可见`swap`空间约为`8GB`，大于需求值。

## 检查软件配置

### 检查操作系统内核版本

本机操作系统为`openSuSE Leap 15`，套用安装文档关于`SUSE Linux Enterprise Server 12 SP1`的要求`3.12.49-11.1 or later`。

```bash
$ uname -r
4.12.14-lp150.12.13-default
```

可见内核版本满足需求。

### 检查服务器配置

```bash
# 检查 /tmp 目录空间
$ df -h | grep /tmp
/dev/sda1        40G   11G   29G  28% /tmp

# 检查硬盘空间是否大于7.5GB
$ df -h
Filesystem      Size  Used Avail Use% Mounted on
devtmpfs        1.9G     0  1.9G   0% /dev
tmpfs           1.9G  4.0K  1.9G   1% /dev/shm
tmpfs           1.9G   18M  1.9G   1% /run
tmpfs           1.9G     0  1.9G   0% /sys/fs/cgroup
/dev/sda1        40G   11G   29G  28% /
/dev/sda1        40G   11G   29G  28% /.snapshots
/dev/sda1        40G   11G   29G  28% /boot/grub2/x86_64-efi
/dev/sda1        40G   11G   29G  28% /boot/grub2/i386-pc
/dev/sda1        40G   11G   29G  28% /opt
/dev/sda1        40G   11G   29G  28% /tmp
/dev/sda1        40G   11G   29G  28% /var
/dev/sda1        40G   11G   29G  28% /root
/dev/sda1        40G   11G   29G  28% /srv
/dev/sda1        40G   11G   29G  28% /usr/local
/dev/sda3       250G  1.6G  249G   1% /home
tmpfs           384M  8.0K  384M   1% /run/user/1000
```

### 配置X11转发

编辑`/etc/ssh/sshd_config`，修改如下内容：

```
X11Forwarding yes
X11UseLocalhost yes
```

并在操作机上安装X11客户端，如`macOS`中的`xquartz`。

### 配置hosts文件

编辑hosts文件，写入本机的IP地址和机器名：

```
192.168.2.12    boris-x200
```

## 检查用户和组

### 检查Oracle Inventory和Oracle Inventory Group

```bash
$ more /etc/oraInst.loc
more: stat of /etc/oraInst.loc failed: No such file or directory

$ grep oinstall /etc/group
<NOTHING>
```

说明`Oracle Inventory Group`不存在。创建这个组。

```bash
$ sudo /usr/sbin/groupadd -g 54321 oinstall
```

### 创建一系列特权组

```bash
# Oracle Automatic Storage Management特权组
$ sudo /usr/sbin/groupadd -g 54327 asmdba

# Oracle Automatic Storage Management启动、停止特权组
$ sudo /usr/sbin/groupadd -g 54328 asmoper

# 数据库SYSDBA特权组
$ sudo /usr/sbin/groupadd -g 54322 dba

# 数据库SYSOPER特权组(有限的数据库管理权限)
$ sudo /usr/sbin/groupadd -g 54323 oper

# 数据库备份、恢复特权组
$ sudo /usr/sbin/groupadd -g 54324 backupdba

# Data Guard操作特权组
$ sudo /usr/sbin/groupadd -g 54325 dgdba

# Transparent Data Encryption keystore操作特权组
$ sudo /usr/sbin/groupadd -g 54326 kmdba

# Oracle RAC cluster日常管理特权组
$ sudo /usr/sbin/groupadd -g 54330 racdba
```

### 创建Oracle Software Owner User

```bash
# 创建用户
$ sudo /usr/sbin/useradd -u 54321 -g oinstall -G dba,asmdba,backupdba,dgdba,kmdba,racdba oracle

# 为该用户创建家目录，并设定umask
$ sudo /sbin/mkhomedir_helper oracle 022

# 为该用户设定密码
$ sudo passwd oracle
```

### 检查ulimit

在`/etc/security/limits.conf`配置如下内容

```conf
# Resource limits for user oracle
oracle          soft    nofile          1024
oracle          hard    nofile          65536
oracle          soft    nproc           2047
oracle          hard    nproc           16384
oracle          soft    stack           10240
oracle          hard    stack           32768
```

### 创建安装目录

```bash
# 创建应用安装目录
$ sudo mkdir -p /opt/oracle/app/oracle

# 创建存放安装程序的目录
$ sudo mkdir -p /opt/oracle/oracinstall

# 修改所有者和权限
$ sudo chown -R oracle:oinstall /opt/oracle
```

# 安装

## 准备安装程序

访问Oracle下载页面下载`Oracle 12c`安装程序，并解压到`/opt/oracle/oracinstall`。

解压完成后注意修改其所有者到`oracle:oinstall`。

## 开始安装

以下截图因为X11客户端的问题，图片色彩会有失真，还请读者见谅。

### 准备X11转发

首先启动`X11`客户端并完成连接配置。

使用`ssh`连接至服务器，以oracle用户登陆，并开启`X11`转发：

```bash
$ ssh -Y <其他参数> oracle@<地址>
```

然后检查`DISPLAY`环境变量：

```bash
$ echo $DISPLAY

# 如没有返回则需要配置DISPLAY环境变量
$ export DISPLAY=localhost:10.0

# 然后开启一个X11应用程序检查是否成功转发
$ xclock &
```

如果成功开启转发，则结果应类似下图：

![Check X11 forwarding](/images/install-oracle-12c-on-suse-linux/check-x11-forwarding.png)

### 启动安装程序

接下来启动安装程序：

```bash
# 进入安装程序所在位置并启动安装程序
$ cd /opt/oracle/oracinstall
$ ./runInstaller
# 监控日志输出并等待安装程序启动
```

### 配置邮箱地址

第一步中可以配置一个用于接收安全通知的邮箱地址，如果不需要则可以留空。

![Configure security updates](/images/install-oracle-12c-on-suse-linux/configure-security-updates.png)

### 选择安装模式

安装程序提供了三种安装模式：创建并配置数据库、仅安装数据库软件、升级已有数据库。我们这里选择仅安装数据库软件，配置将放到安装结束后进行。

![Installation option](/images/install-oracle-12c-on-suse-linux/installation-option.png)

### 选择如何安装数据库

安装程序提供了三种安装类型，我们这次将安装一个单实例数据库。

![Database installation options](/images/install-oracle-12c-on-suse-linux/database-installation-options.png)

### 选择要安装的版本

安装程序提供了两种版本可供安装：企业版和标准版。我们这里选择安装企业版。

![Database edition](/images/install-oracle-12c-on-suse-linux/database-edition.png)

### 设定安装位置

这一步中需要指定安装过程中的两个路径：

- Oracle base: 指定数据库软件及其相关配置文件所存放的位置
- Software location: 指定数据库软件的安装位置

此处需要确认该路径是否与`Software location`的路径匹配。

![Installation location](/images/install-oracle-12c-on-suse-linux/installation-location.png)

### 配置Oracle组所对应的操作系统用户组

这一步可以指定各个Oracle组所对应的操作系统用户组，检查并确认与上文所配置的组匹配。

![Operating system groups](/images/install-oracle-12c-on-suse-linux/os-groups.png)

### 总览

这一步可以检查前面每一步骤的配置是否正确。如检查无误则可继续。

![Summary](/images/install-oracle-12c-on-suse-linux/summary.png)

### 开始安装

接下来就是等待安装完成。点击`Details`按钮可以看到目前详细的进度。

![Install product](/images/install-oracle-12c-on-suse-linux/install-product.png)

期间需要用户以`root`权限执行脚本，根据弹窗给出的提示操作即可。

![Run script as root](/images/install-oracle-12c-on-suse-linux/run-script-as-root.png)

### 完成安装

安装成功结束后点击`Close`关闭安装程序。

# 首次启动配置

## 开放防火墙相关端口

如果需要使数据库可以接受来自外部的连接，则需要开放监听器所指定的端口。

## 创建数据库

使用`dbca`命令启动数据库配置向导(DBCA)，跟随向导创建数据库。

### 选择向导类型

`DBCA`首先会询问本次要进行什么操作，选择`Create a database`来创建一个数据库。

![DBCA - database operation](/images/install-oracle-12c-on-suse-linux/dbca-database-operation.png)

### 选择如何配置数据库

`DBCA`提供两种配置方式：标准模式和高级模式。我们这里选择高级模式。

![DBCA - creation mode](/images/install-oracle-12c-on-suse-linux/dbca-creation-mode.png)

### 选择部署模式

因为我们是要创建一个单机实例，所以`Database type`中选择`Oracle Single Instance Database`。

在下方的模版选择中，我们使用`General Purpose or Transaction Processing`。

![DBCA - deployment type](/images/install-oracle-12c-on-suse-linux/dbca-deployment-type.png)

### 设定数据库标识符

`Global database name`根据提示，需要遵循`name.domain`这样的格式，所以此处按照`SID.主机名`的方式填写。

`SID`按需修改，本例中设定为`orcldb`。

`Create as Container Database`保持不变。

![DBCA - database identification](/images/install-oracle-12c-on-suse-linux/dbca-database-identification.png)

### 配置存储设定

这一步如有定制的需要则选择自定义配置，否则选择套用选定模版。

![DBCA - storage option](/images/install-oracle-12c-on-suse-linux/dbca-storage-option.png)

### 配置快速恢复设定

在这一步按需配置快速恢复的设定。

![DBCA - fast recovery option](/images/install-oracle-12c-on-suse-linux/dbca-fast-recovery-option.png)

### 网络配置

这一步中我们需要新建一个监听器来监听数据库的连接。

选择`Create a new listener`来创建一个新的监听器，监听器名自行设定，端口保持`1521`不变。

**注意如果需要使数据库可以接受来自外部的连接，则需要配置防火墙放行监听器的端口。**

![DBCA - network configuration](/images/install-oracle-12c-on-suse-linux/dbca-network-configuration.png)

### Data Vault设定

这一步根据需要来设定是否开启`Database Vault`和`Label Security`。

![DBCA - data vault option](/images/install-oracle-12c-on-suse-linux/dbca-data-vault-option.png)

### 资源和属性配置

这一步用于配置内存、字符集等等属性。

#### Memory

`Memory`页用来选择内存管理方案。

![DBCA - configuration options - memory](/images/install-oracle-12c-on-suse-linux/dbca-configuration-options-memory.png)

#### Sizing

`Sizing`页用于配置 **块大小** 和 **最大并发连接数** 。这里需要注意，并发连接数一定要根据实际应用场景调整至适合的数值。本例由于是个人的测试环境，所以`300`完全满足这个场景的需要。

![DBCA - configuration options - sizing](/images/install-oracle-12c-on-suse-linux/dbca-configuration-options-sizing.png)

#### Character sets

`Character sets`页用于配置数据库所使用的字符集。数据库字符集选择`AL32UTF8`来使用`Unicode`。

`National character set`即国际化字符集，按需选择`UTF-16`或者`UTF-8`；

`Default language`即默认语言，根据实际使用场景选择；

`Default territory`即默认地区，同样根据实际使用场景选择。

![DBCA - configuration options - character sets](/images/install-oracle-12c-on-suse-linux/dbca-configuration-options-charset.png)

#### Connection mode

`Connection mode`页配置该实例是以独立服务器模式运行还是以共享服务器模式运行。本例中是独立服务器模式。

![DBCA - configuration options - connection mode](/images/install-oracle-12c-on-suse-linux/dbca-configuration-options-connmode.png)

#### Sample schemas

`Sample schemas`页可以选择是否安装演示数据库。

![DBCA - configuration options - sample schemas](/images/install-oracle-12c-on-suse-linux/dbca-configuration-options-sample-schemas.png)

全部完成后继续

### 管理选项

`Management options`中可以配置是否启用`Enterprise Manager`(EM)，以及可以注册到已有的`EM cloud control`中。

![DBCA - management options](/images/install-oracle-12c-on-suse-linux/dbca-management-options.png)

### 用户密码

`User credentials`用于配置特权用户的密码，可以为`SYS`，`SYSTEM`，`PDBADMIN`分别指定密码，也可以为其指定统一的密码。

![DBCA - user credentials](/images/install-oracle-12c-on-suse-linux/dbca-user-credentials.png)

### 数据库创建配置

`Creation option`中可以配置数据库创建过程中以及创建结束后的操作。

- `Create database`勾选后即可创建这个数据库。如果需要在创建结束后运行SQL脚本，则可以在`Post DB creation scripts`中填写各个脚本的路径，配置程序会按照先后顺序执行。
- `Save as a database template`勾选后，将会根据本次向导所设定的值，创建一个数据库模版。
- `Generate database creation scripts`勾选后，将会根据本次向导所设定的值，生成一个数据库创建脚本。以后使用此脚本即可创建出一个一模一样的数据库。

![DBCA - creation option](/images/install-oracle-12c-on-suse-linux/dbca-creation-option.png)

### 总览

这一步可以最后回顾前面步骤中所设定的值。如确认无误即可继续。

### 开始创建

在`Progress page`中可以看到当前数据库创建的进度。耐心等待数据库创建完成。

![DBCA - progress page](/images/install-oracle-12c-on-suse-linux/dbca-progress-page.png)

### 创建成功

在创建成功后，在最后一页会再次显示一些关键的连接信息。

![DBCA - finish](/images/install-oracle-12c-on-suse-linux/dbca-finish.png)

# 检查数据库连通性

打开适用于Oracle数据库的连接工具，比如`Oracle SQL Developer`，新建连接并填写连接信息，点击`Test`，如果`Status`为`Success`则说明以上配置全部成功，可以开始使用。

![Testing connection](/images/install-oracle-12c-on-suse-linux/testing-connection.png)
