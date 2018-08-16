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

### 配置用来接收安全通知的邮箱地址

第一步中可以配置一个用于接收安全通知的邮箱地址，如果不想接收，则可以留空。

![Begin installation](/images/install-oracle-12c-on-suse-linux/begin-installation.png)

### 选择安装模式

接下来选择安装模式。安装程序提供了三种安装模式：`创建并配置数据库`、`仅安装数据库软件`、`升级已有数据库`。因为这次是全新安装，并希望在安装过程中完成必要的配置，所以选择`创建并配置数据库`。

![Install options](/images/install-oracle-12c-on-suse-linux/install-option.png)

### 选择安装类型

然后是选择安装类型，我们这里选择`Server class`。

![System class](/images/install-oracle-12c-on-suse-linux/system-class.png)

### 选择单机或集群

本例中我们将安装一个单机实例，所以选择`Single instance database installation`。

![Install option](/images/install-oracle-12c-on-suse-linux/install-option.png)

### 选择安装方法

这一步提供了两种安装方法：

- 标准安装：完整安装数据库，并使用默认配置
- 高级安装：提供更详细的安装配置功能
  
本例中将使用高级安装，以尽可能地涵盖安装过程的各个步骤。

![Install type](/images/install-oracle-12c-on-suse-linux/install-type.png)

### 选择数据库版本

安装程序提供了两种版本可选：企业版和普通版。我们这里选择企业版。

![Database edition](/images/install-oracle-12c-on-suse-linux/database-edition.png)

### 指定安装位置

`Oracle base`指定到`/opt/oracle/app/oracle`；

`Software location`指定到`/opt/oracle/app/oracle/product/12.2.0/dbhome_1`

![Install location](/images/install-oracle-12c-on-suse-linux/install-location.png)

### 设定Inventory directory

由于是首次安装，需要指定`Inventory directory`来存放安装过程中的元数据文件。我们这里指定到`/opt/oracle/app/oraInventory`，并指定`oinstall`组对该目录有写权限。

![Inventory directory](/images/install-oracle-12c-on-suse-linux/inventory-directory.png)

### 设定数据库使用场景

安装程序提供了两种使用场景，分别对应两种使用情景。我们这里选择面向通常使用场景的`General Purpose / Trasaction Processing`。

![Configuration type](/images/install-oracle-12c-on-suse-linux/configuration-type.png)

### 设定数据库标识符

这一步保持默认，不做修改。

![Database identifiers](/images/install-oracle-12c-on-suse-linux/database-identifiers.png)

### 配置数据库属性

这一步中分别需要配置分配给数据库的内存空间、数据库所使用的字符集、以及是否安装演示数据库。

内存空间分配页面中，保持默认配置不变。

![Configuration options - memory](/images/install-oracle-12c-on-suse-linux/conf-opts-memory.png)

字符集保持默认不变，即使用Unicode。

![Configuration options - character sets](/images/install-oracle-12c-on-suse-linux/conf-opts-charset.png)

是否安装演示数据库页面根据实际需要决定是否勾选。

![Configuration options - sample schemas](/images/install-oracle-12c-on-suse-linux/conf-opts-sample-schema.png)

### 选择数据库存储方式

这一步可以选择使用文件系统来储存数据，或者使用`Oracle Automatic Storage Management`。我们这里使用本地文件系统，并指定数据目录为`/opt/oracle/app/oracle/oradata`。

![Database storage](/images/install-oracle-12c-on-suse-linux/database-storage.png)

### 数据库管理选项

这一步中可以将该实例注册到`Oracle Enterprise Manager (EM)`来实现集中管理。因为我们没有`EM`，所以留空。如果使用`EM`，则根据页面提示填写。

![Management options](/images/install-oracle-12c-on-suse-linux/management-options.png)

### 恢复功能配置

这里可以指定是否启用恢复功能，以及如果启用，恢复数据将存放在哪里。存放恢复数据的分区至少需要`25480MB`的空间。

![Recovery options](/images/install-oracle-12c-on-suse-linux/recovery-options.png)

### 密码设定

这里可以选择分别为`SYS`、`SYSTEM`、`PDBADMIN`设定不同的密码，也可以共用同一套密码。同时安装程序会检测密码是否符合Oracle的建议。

![Schema passwords](/images/install-oracle-12c-on-suse-linux/recovery-options.png)

### 配置各个角色对应的用户组

这里用于指定数据库中各个角色分别对应于操作系统中的哪些用户组。这里保持默认。

![Operating system groups](/images/install-oracle-12c-on-suse-linux/os-groups.png)

### 配置总结

在这一步可以对上面的配置最后做一次检查。确认无误后点击`Install`开始安装。

![Summary](/images/install-oracle-12c-on-suse-linux/summary.png)

### 开始安装

然后就是漫长的安装过程。

![Installing](/images/install-oracle-12c-on-suse-linux/installing.png)

点击`Details`可以在弹窗中查看安装过程的详细信息。

![Details](/images/install-oracle-12c-on-suse-linux/installing-details.png)

在安装过程中，可能需要用户以`root`身份执行一些脚本，跟随安装程序提示执行即可。

![Run scripts as root](/images/install-oracle-12c-on-suse-linux/run-scripts-as-root.png)

等待全部安装步骤完成后，`Oracle 12c`安装完成。
